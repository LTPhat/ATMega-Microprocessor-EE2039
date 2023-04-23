; Write a program to perform the following task: LED on in 1s after one press/release switch (Anti-vibration included, MC time delay is ignored).
; Input: Switch at PB0
; Output: Single LED at PC0

; Approach:
; - Anti-vibration module by loop (Chapter 6)
; - Choose CLKTO, N = 1024 -> Tclkto = 1024/8 = 128 uS -> n = 1s/128us = 8000 = 7812.5 
; 7812 = 252.31 -> TCNT0 = -252, overflow max counter = 31

.DEF	COUNT = R19			; overflow counter
.EQU	LED_OUT = 0
.EQU	SW = 0
.EQU	NUM = 31
.EQU	TP = -252
.ORG	0
RJMP	MAIN
.ORG	0x40
MAIN:
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, (1 << LED_OUT)
	OUT		DDRC, R16		; Set PC0 output
	LDI		R16, 0x00
	OUT		DDRB, R16		; Set PB0 input
	SBI		PORTB, SW		; Pull-up resistor for PB0
	LDI		R17, 0x00	
	OUT		TCCR0A, R17		; Timer0 NOR mode
	LDI		R17, 0x00
	OUT		TCCR0B, R17		; Stop Timer0
	CBI		PORTC, LED_OUT	; Initialize LED = 0
	LDI		COUNT, NUM		; Initialize overflow max counter
START:
	;Detect SW press
	LDI		R18, 50
SW_PRESS:
	SBIC	PINB, SW		; Check PB0 = 0
	RJMP	START			; If not, come back START to wait
	DEC		R18				; If yes, decrease counter
	BRNE	SW_PRESS		; Loop full 50 times
	;Detect SW release
SW_RELEASE:
	LDI		R18, 50
BACK:
	SBIS	PINB, SW		; Check PB0 = 1
	RJMP	SW_RELEASE		; If not, come back SW_RELEASE to wait 
	DEC		R18				; If yes, decrease counter
	BRNE	BACK			; Loop full 50 times
	;////Done detect SW press/release
	SBI		PORTC, LED_OUT	; LED on
	RCALL	DELAY_1S		; call module delay 1s
	CBI		PORTC, LED_OUT	; LED off
	RJMP	START
;///////////////
; Module DELAY_1S
DELAY_1S:
	LDI		R17, TP		; Load R17 = -252
	OUT		TCNT0, R17	; Set initial value for Timer0
	LDI		R17, 0x05	; Set CLKTO mode, N = 1024, Timer0 start to count
	OUT		TCCR0B, R17	
WAIT:
	IN		R17, TIFR0	; Get status of TIFR0 register
	SBRS	R17, TOV0	; Check TOV0 = 1 (Overflow)
	RJMP	WAIT		; If not, come back to WAIT
	OUT		TIFR0, R17	; Overflow, set TOV0 = 1, clear
	LDI		R17, 0x00	
	OUT		TCCR0B, R17	; Stop Timer0
	DEC		COUNT		; Decrease overflow counter by 1
	BRNE	DELAY_1S	; Continue if overflow don't reach overflow counter max (31)
	LDI		COUNT, NUM	; If reach overflow counter max, reset count for next delay
	RET

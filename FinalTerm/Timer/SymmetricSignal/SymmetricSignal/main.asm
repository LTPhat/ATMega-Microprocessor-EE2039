; Write a program using Timer0 to create a symmetric signal on PB1, choose CLKIO (N=1)
; Calculate the period of signal at PB1


.ORG		0
RJMP		MAIN
.ORG		0x40
MAIN:	
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, 0x02
	OUT		DDRB, R16	; PB1 output
	LDI		R17, 0x00
	OUT		TCCR0A, R17	; NOR mode
	LDI		R17, 0x00
	OUT		TCCR0B, R17	; Stop Timer0 at first
START:
	RCALL	DELAY		; Delay to create signal width
	IN		R17, PORTB	; Take current status of portB
	EOR		R17, R16	; Inverse PB1
	OUT		PORTB, R17
	RJMP	START
DELAY:
	LDI		R17, 0xA0	; Set TCNT = 0xA0 = -96 (Initial value)
	OUT		TCNT0, R17
	LDI		R17, 0x01	
	OUT		TCCR0B, R17	; CS02:CS00 = R17 !=0 -> Timer0 start to count
WAIT:
	IN		R17, TIFR0	; Get status of TIFR0
	SBRS	R17, TOV0	; Check if TOV0 = 1 (Overflow)
	RJMP	WAIT		; If not, continue to WAIT
	OUT		TIFR0, R17	; Set TOV0 = 1, clear
	LDI		R17, 0x00	
	OUT		TCCR0B, R17	; CS02:CS00 = 0x00 --> Stop Timer0
	RET

; Calculate:
; Number of pulse counted: 0x00 - 0xA0 = 96
; CLKIO (N=1) -> T0 = 1/8 = 0.125 uS
; --> Period of a symmetric signal at PB1: T = 2.96.T0 = 24uS 



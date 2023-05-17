; Write a program to create two symmetric square signal with a phase difference of 90 degree.
; Frequency F0 = 2kHz, output to PC0 and PC1

; To create two square signal with 90 degree of phase difference, let OCF0B = OCF0A/2
; Mode CTC
; F0 = 2kHz -> T0 = 0.5 ms -> T0/2 = 0.25ms = Tosc.n.N
; -> n.N = 2000 -> n = 250, N = 8
; N = 8 -> OCF0A = 250 - 1 = 249, OCF0B = 125 - 1 = 124
.INCLUDE <M324PDEF.INC>
.EQU	F0_A = 0	; PC0 = Signal A
.EQU	F0_B = 1	; PC1 = Singal B
.ORG	0
RJMP	MAIN
.ORG	0x40
MAIN:
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, (1<<F0_A) | (1<<F0B)	; PC0, PC1 output
	OUT		DDRC, R16
	LDI		R16, 249					; Set OCR0A = 249
	OUT		OCR0A, R16
	LDI		R16, 124					; Set OCR0B = 124
	OUT		OCR0B, R16
	LDI		R16, 0x02					; CTC mode
	OUT		TCCR0A, R16
	LDI		R16, 0x02					; Timer0 start to count, N = 8
	OUT		TCCR0B, R16
START:
	IN		R17, TIFR0		; Get status of TIFR0 (OCF0A and OCF0B are in TIFR0)
	SBRC	R17, OCF0B		; Check OCF0B = 0
	RJMP	B_PROCESS		; OCF0B = 1, process signal B
	SBRS	R17, OCF0A		; Check OCF0A = 1
	RJMP	START			; If OCF0A = 0, come back to start
	OUT		TIFR0, R17		; Clear OCF0A of signal A
	IN		R17, PORTC		; Get status of PORTC
	LDI		R16, (1<<F0_A)	; Set bit 1 at PC0 (Signal A)
	EOR		R17, R16		; Invert PC0
	OUT		PORTC, R17
	RJMP	START
B_PROCESS:
	OUT		TIFR0, R17		; Clear OCF0B of signal B
	IN		R17, PORTC		; Get status of PORTC
	LDI		R16, (1 << F0B)	; Set bit 1 at PC1 (Signal B)
	EOR		R17, R16		; Invert PC1
	OUT		PORTC, R17		
	RJMP	START

; Expand:
; If the phase difference:
; 60 degree, set OCF0B = 2/3OCF0A 
; 30 degree, set OCF0B = 5/6OCF0A
; 45 degree, set OCF0B = 3/4OCF0A 


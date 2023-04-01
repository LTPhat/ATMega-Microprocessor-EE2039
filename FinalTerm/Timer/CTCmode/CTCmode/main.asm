; Write a program to create a symmetric square signal output to PB1, T = 24uS using Timer0 in CTC mode
; Then calculate accurately the real period of output signal

; Timer0 in CTC mode
; 1) Set value (n-1) to OCR0x (x = A, B), n is number of pulses 
; 2) Set CTC mode by setting WGM02:WGM00 = 010, set CLKT0 by setting CS02:CS00 to get N
; 3) Set CS02:CS00 != 000, Timer0 start to count up
; 4) Constantly check OCF0x = 1 at every loop, if yes, exit loop
; 5) Clear OCF0x by set 1 to OCF0x
; 6) Stop Timer0 by setting CS02:CS00 = 000


; T/2 = 12uS
; With N = 1 -> Tclkto = 0.125 uS -> n = 12uS/0.125uS = 96 = 0x60
; -> Set $60 - 1 = $5F to OCR0A (Compare value)
.INCLUDE <M324PDEF.INC>
.EQU	P_OUT = 1
.ORG	0
RJMP	MAIN
.ORG	0x40
MAIN:
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, (1<<P_OUT)
	OUT		DDRB, R16		; PB1 output
	LDI		R17, 0x5F		; Set compare value
	OUT		OCR0A, R17
	LDI		R17, 0x02		
	OUT		TCCR0A, R17		; Set CTC mode
	LDI		R17, 0x01		; Set CLKTO, N = 1, Timer0 start to count up
	OUT		TCCR0B, R17
START:
	IN		R17, TIFR0		; Get status TIFR0	(1MC)
	SBRS	R17, OCF0A		; Check equal to compare value (2/1MC)
	RJMP	START			; If not, come back to START (2MC)
	OUT		TIFR0, R17		; Clear OCFR0A (Set to 1) (1MC)
	IN		R17, PORTB		; Get status of PORTB (1MC)
	EOR		R17, R16		; Invert PB01	(1MC)
	OUT		PORTB, R17		; Output portB	(1MC)
	RJMP	START			; (4MC)

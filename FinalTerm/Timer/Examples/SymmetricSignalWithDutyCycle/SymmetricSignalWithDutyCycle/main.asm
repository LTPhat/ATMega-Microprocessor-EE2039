; Write a program to create symmetric square signal F = 1Khz, duty cicle 30%, output to PC5.
; Calculate and modify to get minimum time error estimation



; First, calculate to choose N 
; F = 1kHz -> T = 1000us -> Thigh = 300us, Tlow = 700us
; Choose N = 64 to get minimum error. 
; N = 64 -> Tclkto = 8uS 
;-> n1 = 300/8 = 37.5 -> n1 = 37
;-> n2 = 700/8 = 87.5 -> n2 = 87

.INCLUDE<M324PDEF.INC>
.EQU	P_OUT = 5		; PC5 output
.EQU	T_high = -37	; Counter high logic
.EQU	T_low = -87		; Counter low logic
.ORG	0
RJMP	MAIN
.ORG	0x40
MAIN:
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, (1 << P_OUT)
	OUT		DDRC, R16		; Set PC5 output
	LDI		R17, 0x00
	OUT		TCCR0A, R17		; Set NOR mode
	LDI		R17, 0x00
	OUT		TCCR0B, R17		; Stop Timer0 first
START:
	SBI		PORTC, P_OUT	; Set PC5 = 1 (1MC)
	LDI		R17, T_high		; Set counter for logic 1 to R17 (1MC)
	RCALL	DELAY_T0		; Call module (3MC)
	CBI		PORTC, P_OUT	; Set PC5 = 0 (1MC)
	LDI		R17, T_low		; Set counter for logic 0 to R17 (1MC)
	RCALL	DELAY_T0
	RJMP	START

;////////////////////
;Module DELAY_T0
; INPUT: R17 (counter)
DELAY_TO:
	OUT		TCNT0, R17		; Set inital value to count (1MC)
	LDI		R17, 0x03		; Set CLKIO, N = 64	(1MC)
	OUT		TCCR0B, R17		; (1MC)
WAIT:
	IN		R17, TIFR0		; Get status of TIFR (1MC)
	SBRS	R17, TOV0		; Check if TOV0 = 1 (2/1MC)
	RJMP	WAIT			; (2MC)
	OUT		TIFR0, R17		; = SBI TIRF0, TOV0 -> Clear TOV0 (1MC)
	LDI		R17, 0x00		; (1MC)
	OUT		TCCR0B, R1		; Stop Timer0 (1MC)
	RET						; (4MC)

; Calculate accurately (Tclkto = 64/8 = 8uS, 1MC = 1/Fosc = 0.125uS)
; DELAY_T0: 15MC
; T_high =  37.8     +		 5.0.125		+ 15.0.125 =  298.5 uS
;         (counter)         (in main)        (delay_To)
; T_low =   87.8     +		 7.0.125		+ 15.0.125 =  698.75 uS
;         (counter)			(in main)         (delay_To)
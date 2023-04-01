; Write a program using Timer0 to perform module X until Timer0 is overflow, with CLKIO = CLK/64. Timer0 starts to count up from value 0
;
; First, write the default starting value to TCNT0 register
; Set up NOR mode by setting WGM02:WGM00 = 000
; Set up frequency of clock signal by setting CS02:CS00 = 0x03 (N = 64)
; - CS02: CS00 = 000 --> Stop Timer0
; - CS02: CS00 != 000 --> Timer0 start to count up
; - Constantly check TOV0 flag in every loop to check if TOV0 = 1 (Timer0 overflow) -> Exit the loop
; - Clear TOV0 by setting TOV0 to 1 to detect the next overflow
; - Stop Timer0 by setting CS2:CS00 = 000


.ORG	0
RJMP	MAIN
.ORG	0x40
MAIN:	
	LDI		R17, 0x00	; Initial value of Timer0
	OUT		TCNT0, R17	; Set to TCNT0 register
	OUT		TCCR0A, R17	; Set NOR mode
	OUT		TCCR0B, R17	; Stop Timer0 first
	LDI		R17, 0x03	;
	OUT		TCCR0B, R17	; Choose CLKIO mode (N=64); Timer0 starts to count up
WAIT:
	IN		R17, TIFR0	; Get status of TIFR0 register
	SBRC	TIFR0, TOV0	; Check if TOV0 = 0 
	RJMP	OVER_FLOW	; If TOV0 = 1 (Overflow) -> Jump OVER_FLOW
	RCALL	MODULE_X	; If TOV0 = 0; call module X
	RJMP	WAIT
OVER_FLOW:
	SBI		TIRF0, TOV0	; Set TOV0 1
	LDI		R17, 0x00
	OUT		TCCR0B, R17	; Stop Timer0
	RJMP	EXIT
EXIT:		
RJMP	EXIT
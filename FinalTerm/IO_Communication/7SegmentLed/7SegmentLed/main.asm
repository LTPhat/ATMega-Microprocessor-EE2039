; Write a program to take input from DIPSW4 and 


.INCLUDE <M324PDEF.INC>
.EQU		OUTPORT = PORTB
.EQU		IOSETB = DDRB
.ORG		0
RJMP		MAIN
.ORG		0X40
MAIN:		
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, 0xFF		
	OUT		IOSETB, R16		; PORTB output
	LDI		R16, 0xF0		
	OUT		DDRC, R16		; PC0-PC4 input
	LDI		R16, 0x0F
	OUT		PORTC, R16		; Pull up resistor for PC0-PC4
START:	
	IN		R17, PINC			; Take data from PORTC
	ANDI		R17, 0x0F		; Cover 4 low-byte
	LDI		ZH, HIGH(TAB_7 << 1); High byte of the address of TAB7
	LDI		ZL, LOW(TAB_7 << 1)	; Low byte of the address of TAB7
	ADD		R30, R17			; C?ng offset vào ZL
	LDI		R17, 0	
	ADC		R31, R17			; Add carry flag with ZH
	LPM		R17,Z				; Get 7 segment code and save at R17
	OUT		OUTPORT, R17		; Output 
	RJMP	START
TAB_7:
	.DB		0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E
			
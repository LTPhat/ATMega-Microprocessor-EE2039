;a. LCD phân bi?t gi?a các l?nh và d? li?u là thông qua vi?c s? d?ng chân ?i?u khi?n ???c g?i là chân RS (??ng ký Ch?n). Khi chân RS ???c ??t ? m?c logic th?p (0), d? li?u ???c g?i t?i LCD ???c hi?u là l?nh. Khi chân RS ???c ??t ? m?c logic cao (1), d? li?u ???c g?i ???c hi?u là d? li?u s? ???c hi?n th? trên màn hình.
;b. Ngoài cách ??c bit BUSY, ta có th? th?c hi?n nh? sau: Sau m?i l?nh ghi/??c vào CPU, ta làm ch??ng trình ch? kho?ng 2 ms tr??c khi th?c hi?n l?nh k? ti?p. Tuy nhiên, cách làm này s? làm cho ch??ng trình không ??t hi?u n?ng cao nh?t n?u ta cho th?i gian tr? quá dài. N?u ta gi?m th?i gian tr? này thì có th? làm LCD ho?t ??ng sai.
;c. Mã ngu?n:
	.ORG	0
	.EQU RS = 0
	.EQU RW = 1
	.EQU EN = 2
	.EQU CR = $0D	; Enter
	.EQU NULL = $00 ; End string

	.ORG 0
	RJMP MAIN
	.ORG 0X40
MAIN:
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, $FF
	OUT DDRA, R16	;PA7,6,5,4,2,1,0 is output
	CBI PORTA, RS	;Recieve command
	CBI PORTA, RW	;Write data
	CBI PORTA, EN	;Unenable LCD
	CALL RESET_LCD
	CALL INIT_LCD4
START:
	CBI PORTA, RS
	LDI R17, $01	;Clear display before 
	RCALL OUT_LCD4_2
	LDI R16, 20		;Delay 20ms after clearing
	RCALL DELAY_US
	CBI PORTA, RS
	LDI R17, $80	;Pointer start at line1, pos1
	RCALL OUT_LCD4_2
	LDI ZH, HIGH(TAB<<1)
	LDI ZL, LOW(TAB<<1)
LINE1:
	LPM R17, Z+
	CPI R17, CR		;Check enter code
	BREQ DOWN
	SBI PORTA, RS	;Display on LCD
	RCALL OUT_LCD4_2
	RJMP LINE1
DOWN:
	LDI R16, 1		;Xuong dong phai doi 100us
	RCALL DELAY_US
	CBI PORTA, RS
	LDI R17, $C0	;Set pointer to line2 pos1
	RCALL OUT_LCD4_2
LINE2:
	LPM R17, Z+
	CPI R17, NULL
	BREQ DONE
	SBI PORTA, RS
	RCALL OUT_LCD4_2
	RJMP LINE2
DONE:
	RJMP DONE

OUT_LCD4:
	OUT PORTA, R17
	SBI PORTA, EN
	CBI PORTA, EN
	RET

OUT_LCD4_2:
	LDI R16, 1		;Delay 1us
	RCALL DELAY_US
	IN R16, PORTA
	ANDI R16, (1<<RS)
	PUSH R16
	PUSH R17
	ANDI R17, $F0
	OR R17, R16
	RCALL OUT_LCD4
	LDI R16, 1		;Delay 1us between first and second access
	RCALL DELAY_US
	POP R17
	POP R16
	SWAP R17
	ANDI R17, $F0
	OR R17, R16
	RCALL OUT_LCD4
	RET

INIT_LCD4:
	LDI R18, $28	;Function set 
	LDI R19, $01	;Clear display
	LDI R20, $0C	;Display on, pointer off
	LDI R21, $06	
	CBI PORTA, RS
	MOV R17, R18
	RCALL OUT_LCD4_2
	MOV R17, R19	;Clear display
	RCALL OUT_LCD4_2
	LDI R16, 20		;Delay 20ms after clearing display
	RCALL DELAY_US
	MOV R17, R20
	RCALL OUT_LCD4_2
	MOV R17, R21
	RCALL OUT_LCD4_2
	RET

RESET_LCD:
	LDI R16, 250		;Delay 25ms
	RCALL DELAY_US
	LDI R16, 250		;Delay 25ms
	RCALL DELAY_US
	CBI PORTA, RS
	LDI R17, $30		;Lan 1
	RCALL OUT_LCD4

	LDI R16, 250		;Delay 25ms
	RCALL DELAY_US
	LDI R16, 170		;Delay 17ms
	RCALL DELAY_US
	CBI PORTA, RS
	LDI R17, $30		;Lan 2
	RCALL OUT_LCD4

	LDI R16, 2			;Delay 200us
	RCALL DELAY_US
	CBI PORTA, RS
	LDI R17, $32		;Lan 3
	RCALL OUT_LCD4_2
	RET

DELAY_US:
	MOV R15, R16
	LDI R16, 200
LP1:
	MOV R14, R16
LP2:
	NOP
	DEC R14
	BRNE LP2
	DEC R15
	BRNE LP1
	RET
TAB:
	.DB "TN VXL-AVR",$0D,"Nhom: ","06",$00

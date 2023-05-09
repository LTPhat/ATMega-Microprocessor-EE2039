; Sử dụng ngắt COMPARE_MATCH của timer 1 như ở Bài 2 để xuất số 1-2-3-4 ra 4 LED 7 đoạn với tần số quét 50 Hz. 
; LE0: Điều khiển tích cực LED
; LE1: Điều khiển data ra chốt
    .EQU P_OUT = 0
	.EQU P_OUT_LED = PORTA
	.EQU DD_P_OUT_LED = DDRA
	.EQU LE_0 = 0
	.EQU LE_1 = 1
	.EQU P_CONTROL_E = PORTC
	.EQU DD_P_CONTROL_E = DDRC

;------------------------------;
	.DEF DATA_DISPLAY = R21
	.DEF DATA_DISPLAY_7SEG = R22    ; Dữ liệu HEX của LED
	.DEF LED_ACTIVE = R23           ; Điều khiển tích cực LED
	.DEF DATA_DISPLAY_LED = R24 

	.ORG 0
	RJMP MAIN
;-------Interrupt vecto table----------;
	.ORG $1A
	RJMP TIMER1_COMPA
;-------Interrupt vecto table----------;

	.ORG $40
MAIN:
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16

	CALL CONFIG_7SEG
	CALL INIT_TIMER1_CTC

	SEI						;Global interrupt
	LDI R17, (1 << OCIE1A)	;Enable interrupt at A channel
	STS TIMSK1, R17
START:
	RJMP START

DISPLAY_7SEG:
	LDI R25, $FF
	OUT P_OUT_LED, R25			;Turn off led
	SBI P_CONTROL_E, LE_1
	CBI P_CONTROL_E, LE_1

	LDI ZH, HIGH(TABLE_7SEG<<1)
	LDI ZL, LOW(TABLE_7SEG<<1)
	ADD ZL, DATA_DISPLAY

	LPM DATA_DISPLAY_7SEG, Z
	OUT P_OUT_LED, DATA_DISPLAY_7SEG
	SBI P_CONTROL_E, LE_0
	CBI P_CONTROL_E, LE_0

	LDI ZH, HIGH(TABLE_CONTROL<<1)
	LDI ZL, LOW(TABLE_CONTROL<<1)
	ADD ZL, LED_ACTIVE

	LPM DATA_DISPLAY_LED, Z
	OUT P_OUT_LED, DATA_DISPLAY_LED
	SBI P_CONTROL_E, LE_1
	CBI P_CONTROL_E, LE_1
	RET

TIMER1_COMPA:
	IN R18, PORTC
	EOR R18, R16
	OUT PORTC, R18
	CALL DISPLAY_7SEG
	INC DATA_DISPLAY
	INC LED_ACTIVE
	CPI LED_ACTIVE, 4
	BREQ RESET_LED
	RJMP DONE
RESET_LED:
	LDI DATA_DISPLAY, 1
	LDI LED_ACTIVE, 0
DONE:
	RETI

CONFIG_7SEG:
	SBI DDRC, 0					;PC0 is out
	LDI DATA_DISPLAY, 1
	LDI LED_ACTIVE, 0
	LDI R16, (1 << P_OUT)
	SER R17
	OUT DD_P_OUT_LED, R17		;PortA is output
	SBI DD_P_CONTROL_E, LE_0	;PC0 is LE0 that is output
	SBI DD_P_CONTROL_E, LE_1	;PC1 is LE1	that is output
	CBI P_CONTROL_E, LE_0		;Block latch
	CBI P_CONTROL_E, LE_1		;Block latch
	RET

INIT_TIMER1_CTC:
	LDI R17, HIGH(39999)
	STS OCR1AH, R17
	LDI R17, LOW(39999)
	STS OCR1AL, R17
	LDI R17, $00
	STS TCCR1A, R17										;Mode CTC
	LDI R17, (1 << WGM12) | (1 << CS10)	;Mode CTC, timer run with prescaler = 1
	STS TCCR1B, R17
	RET

	.ORG $200
TABLE_7SEG: 
	.DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83
	.DB 0XC6,0XA1,0X86,0X8E

TABLE_CONTROL:
	.DB 0b00001110, 0b00001101, 0b00001011, 0b00000111

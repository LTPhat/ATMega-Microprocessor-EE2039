; Write a program to communicate with LCD in 4-bits mode by performing following task:
; - Reset source provision
; - Write INIT_LCD4 module to set up LCD.
; - Write OUT_LCD4_2 module to respectively output two byte of data.
; - Write DELAY_US module to do delay task.
; - Output to LCD: "Troi oi!"
;				"Thien than dangiu qua zayy!"

; Note: When retrieving command or data, the command/data is splitted into 2 pair (each has 4 bits) and is showed in turn from high 4-bit to low 4-bit
; in combination with control signals. Morever, there must be a delay of 100us between two command/data retrievals

.INCLUDE <M324PDEF.INC>
.EQU	LCD = PORTC		; LCD is connected to port C
.EQU	RS = 0			; bit RS
.EQU	RW = 1			; bit RW
.EQU	E = 2			; bit 2
.EQU	CR = $0D		; Enter hexcode
.EQU	NULL = $00		; Ending hexcode

.ORG	0
RJMP	MAIN
.ORG	0X40
MAIN:
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16	
	LDI		R16, 0XFF
	OUT		DDRC, R16	; Port C is output
	CBI		PORTC, RS	; RS = PC0 = 0
	CBI		PORTC, RW	; RW = PC1 = 0
	CBI		PORTC, E	; E = PC2 = 0, forbit retrievals
// Reset/ Activate LCD
	LDI		R16, 250	; delay 25ms
	RCALL	DELAY_US
	LDI		R16, 250	; delay 25ms
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0, write command mode
	LDI		R17, $30	; Command code = $30, first time
	RCALL	OUT_LCD		; output to LCD
	LDI		R16, 42		; delay 4.2ms
	RCALL	DELAY_US	
	CBI		PORTC, RS	; RS = 0, write command mode
	LDI		R17, $30	; Command code = $30, second time
	RCALL	OUT_LCD		; output to LCD
	LDI		R16, 2		; delay 200uS
	RCALL	DELAY_US	
	CBI		LCD, RS
	LDI		R17, $32	
	RCALL	OUT_LCD4_2	; output 1 byte
	LDI		R18, $28	; Function set: 4bit, 2line, font 5x8
	LDI		R19, $01	; Clear display
	LDI		R20, $0C	; Display on, cursor off
	LDI		R21, $06	; Entry mode set
	RCALL	INIT_LCD4	; module to activate 4-bit LCD

START:
	CBI		PORTC, RS		; RS = 0, write command mode
	LDI		R17, $01		; Clear display
	RCALL	OUT_LCD4_2		; output 2 byte command
	LDI		R16, 20			; delay 2ms
	RCALL	DELAY_US	
	CBI		PORTC, RS		; RS = 0, write command mode
	LDI		R17, $83		; Cursor at row 1 points to 4th position
	RCALL	OUT_LCD4_2
	LDI		ZH, HIGH(TAB << 1)
	LDI		ZL, LOW(TAB << 1)
FIRST_LINE:
	LPM		R17, Z+			; Get ASCII code of current char, add 1 to pointer
	CPI		R17, CR			; Check if that char is enter code
	BREQ	DOWN			; If yes, move down
	SBI		PORTC, RS		; RS = 1, write data mode
	RCALL	OUT_LCD4_2		; Output that char to LCD
	RJMP	FIRST_LINE
DOWN:
	LDI		R16, 1			; delay 100us
	RCALL	DELAY_US
	CBI		PORTC, RS		; RS = 0, write command mode
	LDI		R17, $C2		; Cursor at row 2 points to 3rd position
	RCALL	OUT_LCD4_2		
SECOND_LINE:
	LPM		R17, Z+			;Get ASCII code of current char, add 1 to pointer
	CPI		R17, NULL		; Check if that char is ending code
	BREQ	WAIT			; If yes, move to WAIT
	SBI		PORTC, RS		; RS = 1, write data mode
	RCALL	OUT_LCD4_2		; Output that char to LCD
	RJMP	SECOND_LINE
WAIT: 
	LDI		R16, 1			; delay 100us
	RCALL	DELAY_US
HERE: 
	RJMP	HERE

;//////////////////////
; Module: INIT_LCD4: Activate 4-bit LCD
;		R18, $28	; Function set: 4bit, 2line, font 5x8
;		R19, $01	; Clear display
;		R20, $0C	; Display on, cursor off
;		R21, $06	; Entry mode set: Cursor shift right, screen not shift
; RS = 0, RW = 0

INIT_LCD4:
	CBI:	PORTC, RS		; RS = 0, write command code
	MOV		R17, R18		; R18 = Function set
	RCALL	OUT_LCD4_2		; Output 1 byte data
	MOV		R17, R19		; R19 = Clear display
	RCALL	OUT_LCD4_2
	LDI		R16, 20			; Delay 2ms
	RCALL	DELAY_US
	MOV		R17, R20		; R20 = Display
	RCALL	OUT_LCD4_2
	MOV		R17, R21		; R21 - Entry mode set
	RCALL	OUT_LCD4_2
	RET
;////////////////////
; Module DELAY_US: Delay R16x100us (Fosc = 8Mhz)
; INPUT: R16
DELAY_US:	
	MOV		R15, R16		; 1MC move R16 to R15 
	LDI		R16, 200		; 1MC using R16
L1:	
	MOV		R14, R16		; 1MC for using R14
L2: 
	NOP						; 1MC
	DEC		R14				; 1MC
	BRNE	L2				; 2/1 MC
	DEC		R15				; 1MC
	BRNE	L1				; 2/1 MC
	RET

TAB: .DB	"Troi oi", $0D, "Thien than dangiu qua zayy!", $00
;///////////////////////
; Module OUT_LCD4: Output command/data to LCD
; Input: R17 containing command/data with high 4-bit
OUT_LCD4:
	OUT		PORTC, R17
	SBI		PORTC, E
	CBI		PORTC, E
	RET
;///////////////////////
; Module OUT_LCD4_2: Output command/data to LCD
; Input: R17 containing command/data 
; RS = 0 (command)/ 1 (data), bit RW = 0 (write)
; Using module OUT_LCD4
OUT_LCD4_2:
	LDI		R16, 1			; Delay 100uS
	RCALL	DELAY_US
	IN		R16, PORTC		; Get data of portC 
	ANDI	R16, (1<<RS)	; Fill bit RS
	PUSH	R16
	PUSH	R17
	AND		R17, $F0		; Get high 4-bit
	OR		R17, R16		; combine with bit RS
	RCALL	OUT_LCD4		; output to LCD
	LDI		R16, 1			; Delay 100uS
	RCALL	DELAY_US
	POP		R17				; recover R17
	POP		R16				; recover R16
	SWAP	R17				; invert nibble of R17
	AND		R17, $F0		; Get high 4-bit
	OR		R17, R16		; combine with bit RS
	RCALL	OUT_LCD4
	RET
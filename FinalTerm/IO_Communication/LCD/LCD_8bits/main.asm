; Write a program to communicate with LCD 16x2 in 8-bits mode to perform following task:
; - Reset source provision of LCD
; - Write a module to activate LCD
; - Output LCD: "	Hello!
;				""Thien than dangiu"


.INCLUDE	<M324PDEF.INC>
.EQU		OUTPORT = PORTB		; Port B show data
.EQU		CONTROL	= PORTC		; Port C control
.EQU		RS = 0				; Get command mode
.EQU		RW = 1				; Read data mode
.EQU		E = 2				; bit E
.EQU		CR = $0D			; Enter hex code
.EQU		NULL = $00			; Null hex code
.ORG		0
RJMP		MAIN
.ORG		0X40
MAIN:	
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, 0x07
	OUT		DDRC, R16	; Set PC0-PC2 output to control LCD
	CBI		PORTC, RS	; RS = PC0 = 0 -> Get command mode
	CBI		PORTC, RW	; RW = 1 -> LCD write-mode
	LDI		R16, 0XFF
	OUT		DDRB, R16	; PortB output

// Reset source provision - LCD set up
	LDI		R16, 250	; delay 25ms
	RCALL	DELAY_US	; module delay_us x R16
	LDi		R16, 250	; delay 25ms twice
	RCALL	DELAY_US	; module delay_us x R16
	CBI		PORTC, RS	; RS = 0, command mode
	LDI		R17, $30	; Hex code $30 first
	RCALL	OUT_LCD		; Output LCD
	LDI		R16, 42		; delay 42ms
	RCALL	DELAY_US
	CBI		PORTC, RS
	LDI		R17, $30	; Hex code $30 twice
	RCALL	OUT_LCD
	LDI		R16, 2		; delay 200us
	RCALL	DELAY_US	
	CBI		PORTC, RS
	LDI		R17, $30	; Hex code $30 third
	RCALL	OUT_LCD
	LDI		R18, $38	; Function set: 2 line, font 5x8
	LDI		R19, $01	; Clear display
	LDI		R20, $0C	; Display on, off cursor
	LDI		R21, $06	; Entry mode set right shift DDRAM pointer, LCD screen not shift
	RCALL	INIT_LCD8	; module activate 8-bit LCD
START:
	LDI		R16, 1		; delay 100us
	RCALL	DELAY_US	
	CBI		PORTC, RS	; Command mode
	LDI		R17, $83	; Cursor at row 1 points to 4th position
	RCALL	OUT_LCD
	LDI		ZH, HIGH(TAB<<1)
	LDI		ZL, LOW(TAB<<1)	; Z-pointer points to the address of data table
FIRST_LINE:
	LPM		R17, Z+		; Get ASCII of char from FLASH ROM
	CPI		R17, CR		; Check if the char is enter code
	BREQ	DOWN		; If yes, move down line
	LDI		R16, 1		; delay 100uS
	RCALL	DELAY_US
	SBI		PORTC, RW	; RW = 1, LCD write-mode
	RCALL	OUT_LCD		; Output ASCII code to LCD
	RJMP	FIRST_LINE
DOWN:
	LDI		R16, 1		; Delay 100uS
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0, write command mode
	LDI		R17, $C2	; Cursor at row 2 points to 3th-position
	RCALL	OUT_LCD	
SECOND_LINE:
	LPM		R17, Z+		; Get ASCII of char from FLASH ROM
	CPI		R17, NULL	; Check if the char is null (ending char)
	BREQ	WAIT		; If yes, move to WAIT
	LDI		R16, 1		; delay 100uS
	RCALL	DELAY_US
	SBI		PORTC, RS	; RS = 1, write data mode
	RCALL	OUT_LCD		; Output ASCII code to LCD
	RJMP	SECOND_LINE
WAIT: 
	LDI		R16, 1		; delay 100uS
	RCALL	DELAY_US
HERE:
	RJMP	HERE
;/////////////////////
; Module INIT_LCD8 activate LCD in 4-bit mode 
; INPUT
;R18, $38	; Function set: 2 line, font 5x8
;R19, $01	; Clear display
;R20, $0C	; Display on, off cursor
;R21, $06	; Entry mode set right shift DDRAM pointer, LCD screen not shift

INIT_LCD8:
	LDI		R16, 1		; delay 100 uS
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0 -> Write command mode
	MOV		R17, R18	; R18 = function set
	RCALL	OUT_LCD		
	LDI		R16, 1		; delay 100uS
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0 -> Write command mode
	MOV		R17, R19	; R19 = Clear display
	RCALL	OUT_LCD
	LDI		R16, 20		; delay 2ms after CLEAR_DISPLAY
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0 -> Write command mode
	MOV		R17, R20	; R20, $0C	; Display on, off cursor
	RCALL	OUT_LCD		
	LDI		R16, 1		; delay 100us
	RCALL	DELAY_US
	CBI		PORTC, RS	; RS = 0 -> Write command mode
	MOV		R17, R21	; ;R21, $06	; Entry mode set right shift DDRAM pointer, LCD screen not shift
	RCALL	OUT_LCD	
	RET
;/////////////////////
; Module OUT_LCD: Output command/data to LCD screen
; INPUT: 
; - R17: Register containing command/data to output
OUT_LCD:
	OUT		OUTPORT, R17
	SBI		PORTC, E		; enable output LCD
	CBI		PORTC, E		; forbit output LCD
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

TAB: .DB	"Hello!", $0D, "Thien than dangiu", $00

	
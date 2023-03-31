;f. Có hi?n t??ng run phím ??i v?i bàn phím ma tr?n. M?t trong nh?ng cách x? lý là dùng các ch??ng trình t?o tr? m?t kho?ng th?i gian sau khi nh?n tín hi?u nh?n/nh?.
;g. Mã ngu?n c?a ch??ng trình (có ch?ng run nh?n/nh?)
.org	0
rjmp reset_handler ; reset

.equ	LCDPORT = PORTA   ; Set signal port reg to PORTA
.equ	LCDPORTDIR = DDRA   ; Set signal port dir reg to PORTA
.equ	LCDPORTPIN = PINA	; Set clear signal port pin reg to PORTA
.equ	LCD_RS	= PINA0
.equ	LCD_RW	= PINA1
.equ	LCD_EN	= PINA2
.equ	LCD_D7	= PINA7
.equ	LCD_D6	= PINA6
.equ	LCD_D5	= PINA5
.equ	LCD_D4	= PINA4
.def	LCDData = r16

;******************************* Program ID *********************************

;PORTD		-> CONTROL KEYPAD
;PORTC		-> BAR LED

;********************************MAIN******************************
reset_handler:
	CALL	LCD_Init
	SER R16
	OUT DDRC, R16

	LDI ZL, 0
	LDI ZH, 7

	LDI R16, $30
	MOV R10, R16	;DIGIT -> ASCII
	LDI R16, $37
	MOV R11, R16	;ALPHA -> ASCII

	CLR R15

; display the first line of information
start:

	CALL KEY_PAD_SCAN
	MOV R24, R23
	OUT PORTC, R24

	CPI R24, 0XFF
	BREQ CLEAR
	CPI R24, 10
	BRCC ALPHA

	ADD R24, R10	;ASCII -> DIGIT
	ST Z+, R24		;DATA
	ST Z, R15		;END LINE

	LDI ZL, 0
	LDI ZH, 7

	CLR R16
	CLR R17
	CALL LCD_Move_Cursor
	CALL LCD_Send_String
    RJMP start

ALPHA:
	ADD R24, R11	;ASCII -> ALPHA
	ST Z+, R24		;DATA
	ST Z, R15		;END LINE

	LDI ZL, 0
	LDI ZH, 7

	CLR R16
	CLR R17
	CALL LCD_Move_Cursor
	CALL LCD_Send_String
    rjmp start

CLEAR:
    ldi r16, 0x01    ; Clear Display
    call LCD_Send_Command
    rjmp start

;*******************************FUNCTION**************************************


;************INIT************;
LCD_Init:
    ; Set up data direction register for Port A
    ldi r16, 0b11110111  ; set PA7-PA4 as outputs, PA2-PA0 as output
    out LCDPORTDIR, r16
    ; Wait for LCD to power up
    call	DELAY_10MS
	call	DELAY_10MS
    
    ; Send initialization sequence
	ldi r16, 0x02    ; Function Set: 4-bit interface
    call LCD_Send_Command
    ldi r16, 0x28    ; Function Set: enable 5x7 mode for chars 
    call LCD_Send_Command
	ldi r16, 0x0C    ; Display Control: Display OFF, Cursor OFF
    call LCD_Send_Command
    ldi r16, 0x01    ; Clear Display
    call LCD_Send_Command
    ldi r16, 0x80    ; Clear Display
    call LCD_Send_Command
    ret


;*******************SEND CMD******************;
LCD_Send_Command:
	push	r17
	call	LCD_wait_busy	; check if LCD is busy 
	mov	r17,r16		;save the command				
    ; Set RS low to select command register
    ; Set RW low to write to LCD
	andi	r17,0xF0
    ; Send command to LCD
    out LCDPORT, r17  
	nop
	nop
    ; Pulse enable pin
    sbi LCDPORT, LCD_EN
    nop
    nop
    cbi LCDPORT, LCD_EN
    swap	r16
	andi	r16,0xF0
    ; Send command to LCD
    out LCDPORT, r16   
    ; Pulse enable pin
    sbi LCDPORT, LCD_EN
	nop
	nop
	cbi	LCDPORT, LCD_EN
	pop	r17
    ret

;**************SEND DATA****************;
LCD_Send_Data:
	push	r17
	call	LCD_wait_busy	;check if LCD is busy
	mov		r17,r16		;save the command				
    ; Set RS high to select data register
    ; Set RW low to write to LCD
	andi	r17,0xF0
	ori		r17,0x01
    ; Send data to LCD
    out LCDPORT, r17   
	nop
    ; Pulse enable pin
    sbi LCDPORT, LCD_EN
    nop
    cbi LCDPORT, LCD_EN
    ; Delay for command execution
	;send the lower nibble
	nop
    swap	r16
	andi	r16,0xF0
	; Set RS high to select data register
    ; Set RW low to write to LCD
	andi	r16,0xF0
	ori		r16,0x01
    ; Send command to LCD
    out LCDPORT, r16
	nop
    ; Pulse enable pin
    sbi LCDPORT, LCD_EN
    nop
    cbi LCDPORT, LCD_EN
	pop	r17
    ret


;*************************SET_CURSOR*******************;
LCD_Move_Cursor:

    cpi	r16,0	;check if first row
	brne	LCD_Move_Cursor_Second
	andi	r17, 0x0F
	ori		r17,0x80    
	mov		r16,r17
    ; Send command to LCD
    call LCD_Send_Command
	ret
LCD_Move_Cursor_Second:
	 cpi	r16,1	;check if second row
	 brne	 LCD_Move_Cursor_Exit	;else exit 
	 andi	r17, 0x0F
	 ori		r17,0xC0   
	 mov		r16,r17 
    ; Send command to LCD
    call LCD_Send_Command
LCD_Move_Cursor_Exit:
    ; Return from function
    ret


;*******************SEND STRING****************;
LCD_Send_String:
    push    ZH                              ; preserve pointer registers
    push    ZL
	push	LCDData

; fix up the pointers for use with the 'lpm' instruction
//    lsl     ZL                              ; shift the pointer one bit left for the lpm instruction
//    rol     ZH
; write the string of characters
LCD_Send_String_01:
    LD    LCDData, Z+                        ; get a character
    cpi     LCDData,  0                        ; check for end of string
    breq    LCD_Send_String_02          ; done

; arrive here if this is a valid character
    call    LCD_Send_Data          ; display the character
    rjmp    LCD_Send_String_01          ; not done, send another character

; arrive here when all characters in the message have been sent to the LCD module
LCD_Send_String_02:
	pop		LCDData
    pop     ZL                              ; restore pointer registers
    pop     ZH
    ret


;***************LCD_WAIT_BUSY****************;
LCD_wait_busy:
	push	r16
	ldi r16, 0b00000111  ; set PA7-PA4 as input, PA2-PA0 as output
       out LCDPORTDIR, r16
	ldi	r16,0b11110010	; set RS=0, RW=1 for read the busy flag
	out	LCDPORT, r16
	nop
 LCD_wait_busy_loop:
      sbi LCDPORT, LCD_EN
       nop
	nop
	in	r16, LCDPORTPIN
	cbi	LCDPORT, LCD_EN
	nop
	sbi LCDPORT, LCD_EN
    nop
	nop
    cbi LCDPORT, LCD_EN
	nop
	andi	r16,0x80
	cpi		r16,0x80
	breq	LCD_wait_busy_loop
	ldi r16, 0b11110111  ; set PA7-PA4 as output, PA2-PA0 as output
    out LCDPORTDIR, r16
	ldi	r16,0b00000000	; set RS=0, RW=1 for read the busy flag
	out	LCDPORT, r16	
	pop	r16
	ret


;*******************DELAY10MS******************;
DELAY_10MS:
	LDI R16,10
LOOP2:
	LDI R17,250
LOOP1:
	NOP
	DEC R17
	BRNE LOOP1
	DEC R16
	BRNE LOOP2
	RET

KEY_PAD_SCAN:

;PD_0 -> PD_3: OUTPUT, COL
;PD_4 -> PD_7: INPUT, ROW

	LDI R16, $0F
	OUT DDRD, R16

	LDI R16, $F0
	OUT PORTD, R16
	CALL BUTTON
	
	LDI R22, 0B11110111	;INITIAL COLUMN MASK
	LDI R23, 0			;INITIAL PRESSED ROW VALUE
	LDI R24, 3			;SCANNING COLUMN INDEX

KEYPAD_SCAN_LOOP:
	OUT PORTD, R22
	SBIC PIND, 4		;CHECK ROW 0
	RJMP KEYPAD_SCAN_CHECK_COL2
	RJMP KEYPAD_SCAN_FOUND		;ROW 0 IS PRESSED

KEYPAD_SCAN_CHECK_COL2:

	SBIC PIND, 5		;CHECK ROW 1
	RJMP KEYPAD_SCAN_CHECK_COL3
	LDI R23, 1			;ROW 1 IS PRESSED
	RJMP KEYPAD_SCAN_FOUND

KEYPAD_SCAN_CHECK_COL3:

	SBIC PIND, 6		;CHECK ROW 2
	RJMP KEYPAD_SCAN_CHECK_COL4
	LDI R23, 2			;ROW 2 IS PRESSED
	RJMP KEYPAD_SCAN_FOUND

KEYPAD_SCAN_CHECK_COL4:

	SBIC PIND, 7		;CHECK ROW 3
	RJMP KEYPAD_SCAN_NEXT_ROW
	LDI R23, 3			;ROW 3 IS PRESSED
	RJMP KEYPAD_SCAN_FOUND

KEYPAD_SCAN_NEXT_ROW:
	
	CPI R24, 0
	BREQ KEYPAD_SCAN_NOT_FOUND
	ROR R22
	DEC R24
	RJMP KEYPAD_SCAN_LOOP

KEYPAD_SCAN_FOUND:

    ; combine row and column to get key value (0-15)
	;key code = row*4 + col
    LSL R23 ; shift row value 4 bits to the left
	LSL R23
    ADD R23, R24 ; add row value to column value

	RET

KEYPAD_SCAN_NOT_FOUND:
	LDI R23, 0XFF	;NO KEY PRESSED
	RET

BUTTON:
	LDI R17, 50
DEBOUNCING_1:
	IN R16, PIND
	CPI R16, $FF	;DETECTE STATUS OF BUTTON
	BREQ BUTTON
	DEC R17
	BRNE DEBOUNCING_1

	RET

; module lcd_send_data, module lcd_command is similar to previous sections.    

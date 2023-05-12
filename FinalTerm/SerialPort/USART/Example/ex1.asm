; Viết chương trình thu chuỗi ký tự từ cổng USART0, cộng thêm $05 vào mỗi byte và lưu vào SRAM bắt đầu từ địa chỉ $100. Quá trình thu kết thúc khi gặp ký tự $0D. Sau khi thu phát ra lại cổng USART0 các giá trị vừa chuyển đổi xong
; Cho baudrate = 9600, 8bit data, 1 stopbit, Fosc = 8MHz, no party


.INCLUDE <M324PDEF.INC>
.DEF DATA_RX = R18
.DEF DATA_TX = R19
.ORG    0
RJMP    MAIN
.ORG    0x40
MAIN:
    RCALL   USART_INIT
LOOP0:
    LDI     XH, $01
    LDI     XL, $00     ; Lưu địa chỉ đầu 
AGAIN:
    RCALL   USART_RECEIVER_CHAR
    MOV     R20, DATA_RX
    CPI     R20, $0D
    BREQ    NEXT
    LDI     R16, $05
    ADD     R20, R16
    ST      X+, R20
    RJMP    AGAIN
NEXT:
    ST      X, DATA_RX
    MOV     R29, XH         ; Lưu địa chỉ cuối trước khi kết thúc thu vào con trỏ Y
    MOV     R28, XL
    LDI     XH, $01         ; Load lại địa chỉ ban đầu để phát những ký tự đã thu
    LDI     XL, $00
TRANSLOOP:
    LDI     DATA_TX, X+
    RCALL   USART_SEND_CHAR
    CPI     R26, R28        ; So sánh địa chỉ XL = YL
    BRNE    TRANSLOOP       ; Không bằng, tiếp tục phát
    CPI     R27, R29        ; Tiếp tục so sánh XH = YH
    BRNE    TRANSLOOP
    RJMP    LOOP0           ; Nếu X = Y chứng tỏ đã phát xong, quay lại vòng lặp LOOP0
;-------------------------------
USART_INIT:
	LDI R16, (1<<RXEN0) | (1<<TXEN0)	;Enable transmitter and receiver
	STS UCSR0B, R16

	LDI R16, $00
	STS UBRR0H, R16
	LDI R16, 51				;Set baudrate to 9600bps with 8Mhz clock
	STS UBRR0L, R16

	LDI R16, (1<<UCSZ01) | (1<<UCSZ00)	;8 bit data, no parity, 1 stop bit
	STS UCSR0C, R16
	RET
USART_SEND_CHAR:
	PUSH R17
	WAIT_USART_SEND:
	LDS R17, UCSR0A
	SBRS R17, UDRE0				;bit UDRE0 = 1 then continue to send char
	RJMP WAIT_USART_SEND
	STS UDR0, DATA_TX			;Write new data
	POP R17
	RET

USART_RECEIVER_CHAR:
	PUSH R17
	WAIT_USART_RECEIVE:
	LDS R17, UCSR0A
	SBRS R17, RXC0					;bit RXC0 = 1 then continue to receive char
	RJMP WAIT_USART_RECEIVE
	LDS DATA_RX, UDR0				;Read new data
	POP R17
	RET

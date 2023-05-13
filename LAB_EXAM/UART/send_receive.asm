
;c)	Setup chương trình Hercules với baudrate 9600, 8 bit data, no parity, 1 stop, no handshake.
;d)	Sử dụng các ví dụ mẫu trong tài liệu thí nghiệm, viết chương trình khởi động UART0 với các thông số như trên, chờ nhận một byte từ UART0 và phát ngược lại UART0.

    .DEF DATA_RX = R18
	.DEF DATA_TX = R19

	.ORG 0
	RJMP MAIN
	.ORG $40
MAIN:
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16 

	CALL USART_INIT
	CLR DATA_RX
	CLR DATA_TX
START:
	CALL USART_RECEIVER_CHAR
	MOV DATA_TX, DATA_RX
	CALL USART_SEND_CHAR
	RJMP  START

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

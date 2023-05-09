CONFIG_USART:
	LDI R16, 0
	STS UBRR0H, R16
	LDI R16, 51
	STS UBRR0L, R16

	LDI R16, (1 << UCSZ00) | (1 << UCSZ01)		;8bit data 1 stop bit, no-parity
	STS UCSR0C, R16
	
	LDI R16, (1 << RXEN0) | (1 << RXCIE0)		;Enable receive and enable to interrupt receive
	STS UCSR0B, R16
	RET

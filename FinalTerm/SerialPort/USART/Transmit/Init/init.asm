; Khởi tạo UART0, cho phép phát. Chế độ khung data 8 bit, no party bit, 1 stopbit, baud rate 9600, fosc = 8Mhz

.ORG    0
.EQU    TXEN0 = 3
.EQU    UCSZ01 = 1
.EQU    UCSZ00 = 0

USART0_INIT:
    LDI     R16, (1<<TXEN0)         ; Transmit enable
    STS     USCR0B, R16
    LDI     R16, (1<<UCSZ01) | (1<<UCSZ00)  ; 8 bit data, no party, 1 stop bit
    STS     USCR0C, R16
    LDI     R16, 0x00
    STS     UBRR0H, R16                 ; Add high byte 
    LDI     R16, 51
    STS     UBRR0L, R16                 ; Baud rate = 9600, Fosc = 8Mhz, n = 51
    RET
    
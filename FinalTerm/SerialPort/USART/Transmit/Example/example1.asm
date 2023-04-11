; Viết chương trình phát liên tục ký tự A ra cổng nối tiếp USART0
; Chế độ 8 bit data, 1 stop bit, no party, baud rate 9600, fosc = 8Mhz

.ORG        0
RJMP        MAIN    
.ORG        0x40
MAIN:
    LDI     R16, (1 << TXEN0)       ; Transmit enable
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZ01) | (1 << UCSZ00)  ; 8 bit data, no party, 1 stop bit
    STS     UCSR0C, R16
    LDI     R16, 0x00
    STS     UBRRH, R16
    LDI     R16, 51
    STS     UBRRL, R16          ; baud rate = 9600, n = 51
AGAIN:
    LDS     R17, UCSR0A
    SBRS    R17, UDRE0          ; Kiểm tra UDR0 còn trống không
    RJMP    AGAIN               ; UDR0 = 0, bộ đệm phát đầy, quay lại chờ
    LDI     R16, 'A'
    STS     UDR0, R16
    RJMP    AGAIN
    
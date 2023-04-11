; Viết chương trình thu 1 byte dữ liệu từ cổng nối tiếp và xuất ra portA. Biết rằng bên phát sử dụng khung 8 bit dữ liệu, 1 stop bit, no party, baud rate = 9600, fosc = 8MHz

.ORG        0
RJMP        MAIN
.ORG        0x40
MAIN:
    LDI     R16, RXEN0      ; Receive enable
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZN01) | (1 << UCSZN00)    ; 8bit data
    STS     UCSR0C, R16
    LDI     R16, 0x00
    STS     UBRR0H, R16
    LDI     R16, 51         ; Baud rate = 9600, n = 51
    STS     UBRRL, R16
    LDI     R21, 0xFF
    OUT     DDRA, R21       ; PortA output
AGAIN:
    LDI     R17, UCSR0A
    SBRS    R17, RXC0       ; Cờ RXC0 = 1, thu xong
    RJMP    AGAIN
    LDS     R16, URD0       ; Khi RXC = 1,  đọc dữ liệu từ thanh ghi URD0 ở bộ thu
    OUT     PORTA, R16
    RJMP    AGAIN
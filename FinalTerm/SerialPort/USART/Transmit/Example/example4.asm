; Viết chương trình phát dữ liệu 9bit ra cổng nối tiếp USART0 với bit thứ 9 là LSB của R17, 8 bit thấp là mã ASCII của ký tự A
; USART 9 bit, 1 stop bit, no party, baud rate = 9600, fosc = 8MHz


.ORG        0
RJMP        MAIN
.ORG        0x40
MAIN:
    LDI     R21, HIGH(RAMEND)
    OUT     SPH, R21
    LDI     R21, LOW(RAMEND)
    OUT     SPL, R21
    RCALL   USART_INIT
    LDI     R17, 0x01       ; Khởi tạo giá trị R17, khi đó LSB = 1
    LDI     R16, "A"
AGAIN:
    RCALL   USART_TRANS_9BIT
    RJMP    AGAIN

USART_INIT:
    LDI     R16, (1 << TXEN0) | (1 << RXEN0) | (1 << UCSZ02)    ; mode 9 bit data, thu phát đồng thời
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZ01) | (1 << UCSZ02)         ; UCSZ0[2:0] = 111 -> mode 9 bit data
    STS     UCSR0C, R16
    LDI     R16, 0x00
    STS     UBRR0H, R16
    LDI     R16, 51         ; Baud rate = 9600
    STS     UBRR0L, R16
    RET

USART_TRANS_9BIT:
    LDS     R19, UCSR0A
    SBRS    R19, UDRE0      ; Check UDRE0 = 1
    RJMP    USART_TRANS_9BIT
    ; Copy bit thứ 9 của R17 vào TX8B0 trước khi nạp 8 bit thấp
    LDS     R18, UCSR0B
    BST     R17, 0      ; Cất bit 0 R17 vào cờ T
    BLD     R18, 0      ; Nạp cờ T vào bit 0 của R18
    STS     UCSR0B, R18
    STS     UDR0, R16
    RET
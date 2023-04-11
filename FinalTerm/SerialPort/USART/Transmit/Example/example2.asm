; Viết chương trình phát liên tục chuỗi "YES" ra cổng nối tiếp USART 0.
; Frame 8 bit data, no party, baud rate = 9600, fosc = 8MHz, CKDIV8 = 1

.ORG        0
RJMP        MAIN
.ORG        0x40
MAIN:
    LDI     R21, HIGH(RAMEND)
    OUT     SPH, R21
    LDI     R21, LOW(RAMEND)
    OUT     SPL, R21
    ; Usart0 init
    LDI     R16, (1 << TXEN0)       ; Transmit enable
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZ01) | (1 << UCSZ00)  ; 8 bit data, no party, 1 stop bit
    STS     UCSR0C, R16
    LDI     R16, 0x00
    STS     UBRR0H, R16
    LDI     R16, 51                 ; Set baud rate
    STS     UBRR0L, R16
AGAIN:
    LDI     R17, "Y"
    RCALL   USART_TRANS
    LDI     R17, "E"
    RCALL   USART_TRANS
    LDI     R17, "S"
    RCALL   USART_TRANS
    RJMP    AGAIN
USART_TRANS:                    ; Module transmit data
    LDI     R19, USCR0A
    SBRS    R19, UDRE0          ; Check UDRE0 = 1
    RJMP    USART_TRANS         ; If no, come back and wait
    STS     UDR0, R17
    RET


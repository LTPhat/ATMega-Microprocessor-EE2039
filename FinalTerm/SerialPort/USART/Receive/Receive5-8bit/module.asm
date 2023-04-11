; Viết module minh họa việc thu dữ liệu dựa trên cờ hoàn thành thu RXCn

USART_REC:
    LDS     R17, UCSR0A
    SBRS    R17, RXC0       ; Kiểm tra RXC0 = 1
    RJMP    USART_REC
    LDS     R16, URD0
    RET

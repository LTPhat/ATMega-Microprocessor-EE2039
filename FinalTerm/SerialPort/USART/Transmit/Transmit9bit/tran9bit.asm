; Viết chương trình con truyền data 9 bit, 8 bit thấp ở R16
USART_TRANS_9BIT:
    LDS     R18, UCSR0A
    SBRS    R18, UDRE0
    RJMP    USART_TRANS_9BIT
    LDS     R18, UCSR0B
    BST     R17, 0      ; Lưu bit thứ 9 vào cờ T
    BLD     R18, 0      ; Chuyển cờ T sng bit - của R18
    ANDI    R18, 0x01   ; Lọc bit 0
    STS     UCSR0B, R18 ; Truyền bit thứ 9 bằng cách ghi vào UCSR0B
    STS     UDR0, R16   ; Truyền 8 bit thấp
    RET
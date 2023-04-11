; Khi phát dữ liệu 9 bit (UCSZn = 111) bit phát thứ 9 được ghi vào thanh ghi TXB8n (bit 0 của thanh ghi UCSRnB) trước khi byte thấp của dữ liệu được ghi vào UDRn
; Viết chương trình minh họa chế độ truyền 9 bit, giả sử dữ liệu phát được lưu ở thanh ghi R17 (LSB là bit 9 của dữ liệu), và R16


USART_TRANS_9BIT:
    LDS     R18, UCSR0A
    SBRS    R18, UDRE0          ; Chờ bộ đệm trống
    RJMP    USART_TRANS_9BIT    ; UDRE0 = 0, bộ đệm đầy, quay lại chờ
    ; Copy bit phát thứ 9 từ R17 vào TXB80
    LDS     R18, UCSR0B
    ANDI    R18, 0XFE   ; TX8B0 = 0
    SBRC    R17, 0      ; Kiểm tra LSB của R17 (bit thứ 9) có bằng 0 không
    ORI     R18, 1      ; R18 OR 1
    STS     UCSR0B, R18
    STS     UDR0, R16   ; Chuyển 8 bit thấp vào thanh ghi đệm thu
    RET
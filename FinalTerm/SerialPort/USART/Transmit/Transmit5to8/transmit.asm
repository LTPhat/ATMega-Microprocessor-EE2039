; Viết module con minh họa việc truyền dữ liệu dựa trên việc kiểm tra trạng thái cờ UDREn


; Dữ liệu cần truyền lưu ở R16

USART_TRANS:
    LDS     R17, UCSR0A
    SBRS    R17, UDRE0      ; Kiểm tra bit UDRE0 (bit 5 của thanh ghi UCSR0A)
    RJMP    USART_TRANS     ; Nếu USCR0A = 0, bộ đệm phát đầy, quay lại chờ
    STS     UDR0, R16       ; Nếu USCR0A = 1, bộ đệm phát trống, ghi dữ liệu vào bộ đệm phát
    RET
; Viết chương trình liên tục thu dữ liệu từ cổng nối tiếp USART. Nếu dữ liệu thu được là chữ thường từ a-z thì đổi qua chữ in tương ứng và phát ngược lại
; Khung 8 bit data, no party, baud rate = 9600, fosc = 8Mhz


.ORG        0x00
RJMP        MAIN
.ORG        0x40
MAIN:
    LDI     R21, HIGH(RAMEND)
    OUT     SPH, R21
    LDI     R21, LOW(RAMEND)
    OUT     SPL, R21
    CALL    USART_INIT
AGAIN:
    CALL    USART_REC           ; Gọi chương trình con lưu ký tự
    CPI     R16, "a"
    BRCC    NEXT_CHECK          ; Nếu cờ C = 0 (R16 >= a), chuyển tới NEXT_CHECK
    RJMP    AGAIN               ; Nếu R16 < a, quay lại nhận ký tự khác
NEXT_CHECK:
    CPI     R16, "z"+1
    BRCS    LOWCASE             ; Nếu a <= R16 <= "z" + 1 thì chuyển tới LOWCASE
    RJMP    AGAIN
LOWCASE:
    SUBI    R16, $0x20          ; Chuyển chữ thường thành chữ hoa
    MOV     R18, R16            ; Chuyển sang dữ liệu đầu vào của chương trình con
    CALL    USART_TRANS
    RJMP    AGAIN

USART_INIT: ; Chương trình con khởi tạo USART0
    LDI     R16, (1 << TXEN0) | (1 << RXEN0)        ; Cho phép thu phát
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZ01) | (1 << UCSZ00)      ; Mode truyền 8 bit
    STS     UCSR0C, R16
    LDI     R16, 0x00   
    STS     UBRR0H, R16
    LDI     R16, 51         ; Baud rate = 9600
    STS     UBRR0L, R16
    RET
USART_REC:
    ; Output: Dữ liệu nhận được lưu trong thanh ghi R16
    LDS     R17, UCSR0A
    SBRS    R17, RXC0       ; Check RXC0 = 1 (Nếu bằng 1 mới tiến hành nhận)
    RJMP    USART_REC
    LDS     R16, UDR0       ; Nếu cờ RXC0 = 1, lưu dữ liệu nhận từ thanh ghi UDR0 vào R16
    RET
USART_TRANS:
    ; Input: Dữ liệu sắp phát lưu ở thanh ghi R18
    LDS     R17, UCSR0A
    SBRS    R17, UDRE0      ; Kiểm tra cờ UDRE0
    RJMP    USART_TRANS
    STS     UDR0, R18
    RET
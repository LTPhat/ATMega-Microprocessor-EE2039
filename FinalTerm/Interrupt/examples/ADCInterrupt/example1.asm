; Viết chương trình sử dụng ngắt thu và phát USART0 (baud rate = 9600, 8 bit, 1 stop bit, no party) thực hiệnL
; - Thu chuỗi ký tự kết thúc bằng ký tự CR = $0D từ USART0, cất vào SRAM địa chỉ đầu 0x200
; - Khi thu xong ký tự CR, lặp vòng thu lại từ đầu và phát chuỗi ký tự thu được ra USART0 cho đến khi phát xong ký tự CR
; - Khi phát xong ký tự CR ngưng phát, cho đến khi thu ký tự CR sẽ phát tiếp chuỗi ký tự mới thu


; Khi mới khởi động cho phép thu phát và ngắt thu, cấm ngắt phát chờ thu trước
; Trong ISR ngắt thu thực hiện thu từng ký tự cất vào buffer, nếu ký tự thu = CR, lặp vòng thu lại chuỗi mới và cho phép ngắt bộ đệm phát USART0
; Trong ISR ngắt phát, thực hiện phát từng ký tự từ buffer, nếu ký tự phát = mã CR, kết thúc phát và cấm ngắt phát


.EQU        SR_BUF  = 0x200
.ORG        0
RJMP        MAIN
.ORG        0x028           ; Điểm vào ISR USART0_RX
RJMP        USART0_RX_ISR
.ORG        0x002A          ; Điểm vào ISR_UDRE_ISR
RJMP        USART0_UDRE_ISR
.ORG        0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, 0x00
    STS     UBRR0H, R16         
    LDI     R16, 51             ; Baud rate = 9600
    STS     UBRR0L, R16
    SEI                         ; Set I = 1
    LDI     R16, (3 << UCSZ00)  ; 8 bit data, 1 stop bit, no party
    STS     UCSR0C, R16
    LDI     R16, (1 << RXEN0) | (1 << RXCIE0) | (1 << TXEN0)    ; Cho phép thu/ phát, cho phép ngắt thu
    STS     UCSR0B, R16
    LDI     XH, HIGH(SR_BUF)    ; X trỏ tới địa chỉ của buffer
    LDI     XL, LOW(SR_BUF)
HERE: RJMP  HERE
; --------------
USART0_RX_ISR:
    PUSH    R17             ; cất R17
    IN      R17, SREG       ; cất SREG
    PUSH    R17
    LDS     R17, UDR0       ; Thu ký tự
    ST      X+, R17         ; Lưu vào buffer, sau đó tăng địa chỉ buffer
    CPI     R17, $0D        ; So sánh với mã CR
    BRNE    EXIT_RX         ; Nếu khác, thoát
    LDI     XH, HIGH(SR_BUF)    ; Nếu gặp mã CR, thực hiện yêu cầu đề bài
    LDI     XL, LOW(SR_BUF)     ; Load lại địa chỉ ban đầu của buffer
    LDS     R17, UCSR0B
    ORI     R17, (1 << UDRIE0)  ; Cho phép ngắt bộ đệm phát USART0
    STS     UCSR0B, R17
EXIT_RX:
    POP     R17         ; phục hồi SREG
    OUT     SREG, R17
    POP     R17         ; Phục hồi R17
    RETI
;------------------
USART0_UDRE_ISR:
    PUSH    R17             ; cất R17
    IN      R17, SREG       ; cất SREG
    PUSH    R17
    LD      R17, X+         ; Lấy kí tự từ buffer và tăng địa chỉ buffer
    STS     UDR0, R17       ; phát ký tự
    CPI     R17, $0D        ; Kiểm tra ký tự = mã CR
    BRNE    EXIT_UDR
    LDI     XH, HIGH(SR_BUF)    ; Nếu gặp mã CR, thực hiện yêu cầu đề bài
    LDI     XL, LOW(SR_BUF)     ; Load lại địa chỉ ban đầu của buffer
    LDS     R17, UCSR0B
    CBR     R17, (1 << UDRIE0)  ; Cấm ngắt bộ đệm phát
    STS     UCSR0B, R17
EXIT_UDR:
    POP     R17
    OUT     SREG, R17           ; phục hồi SREG
    POP     R17                 ; phục hồi R17
    RETI
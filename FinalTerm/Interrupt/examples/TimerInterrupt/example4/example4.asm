; Viết chương trình tạo ngõ ra sóng PC0 và PC1 như hình sử dụng Timer2
; Cách làm:
; Ban đầu cho Timer2 chạy mô thức CTC, hệ số chia N = 128, đặt các giá trị so sánh OCR2A = TOP = 259, OCR2B = 124. Khi đạt kết quả so sánh kênh A, chuyển Timer2 chạy mô thức NOR cùng hệ số N, đặt giá trị bộ đếm TCNT2 = -125, khi timer2 tràn trở về mô thức CTC
; Các hoạt động ngắt:
; - Ngắt kết quả so sánh kênh B: Đảo bit PC1
; - Ngắt kết quả so sánh kênh A: Đặt PC0 = 1, chuyển Timer2 sang mô thức NOR
; - Timer 2 tràn ở mô thức NOR: Đặt PC0 = 0, chuyển Timer2 về CTC

.EQU        F0 = 0
.EQU        F1 = 1
.ORG        0
RJMP        MAIN
.ORG        0x0012        ; ISR TIMER2_COMPA
RJMP        TIMER2_COMPA_ISR
.ORG        0x0014        ; ISR TIMER2_COMPB
RJMP        TIMER2_COMPB_ISR
.ORG        0x0016        ; ISR TIMER2_OVF
RJMP        TIMER2_OVF_ISR
.ORG        0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16 
    LDI     R16, (1 << F0) | (1 << F1)
    OUT     DDRC, R16       ; PC0, PC1 output
    CBI     PORTC, F0       ; Ban đầu PC0 = 0
    CBI     PORTC, F1       ; Ban đầu PC1 = 0
    LDI     R18, (1 << F1)  ; Khởi tạo MASK để đảo bit PC1, R18 = MASK
    LDI     R16, 249        ; Giá trị nạp vào OCCR2A
    STS     OCCR2A, R16
    LDI     R16, 124        ; Giá trị nạp vào OCCR2B
    STS     OCCR2B, R16
START:
    LDI     R16, 0x02       ; Mode CTC
    STS     TCCR2A, R16
    LDI     R16, 0x05       ; Timer2 bắt đầu chạy, N = 128
    STS     TCCR2B, R16
    SEI                     ; Set cờ I = 1, cho phép ngắt toàn cục
    LDI     R16, (1 << OCIE2A) | (1 << OCIE2B) |(1 << TOIE2)
    STS     TIMSK2, R16
HERE:       RJMP    HERE
;-----------------
TIMER2_COMPA_ISR:
    SBI     PORTC, F0       ; Set PC0 = 1
    LDI     R16, 0x00       ; Đặt Timer2 mode NOR
    STS     TCCR2A, R16
    LDI     R16, -125       ; Đặt giá trị đếm vào TCNT2, mode NOR
    STS     TCNT2, R16
    LDS     R16, TIMSK2
    CBR     R16, (1 << OCIE2A) ; Cấm ngắt TIMER2_COMPA trong khi chạy mode NOR
    STS     TIMSK2, R16
    RETI
;-------------------
TIMER2_COMPB_ISR:
    IN      R17, PORTC      ; Đọc PortC
    EOR     R17, R18        ; Đảo bit PC1
    OUT     PORTC, R17      ; Xuất PORTC
    RETI
;---------------------
TIMER2_OVF_ISR:
    CBI     PORTC, F0       ; Clear PC0
    LDI     R16, 0x02       ; Timer2 mode CTC
    STS     TCCR2A, R16
    SBI     TIFR2, OCF2A    ; Xóa cờ so sánh kênh A Timer2
    LDS     R16, TIMSK2
    SBR     R16, (1 << OCIE2A)  ; Cho phép ngắt so sánh kênh A
    STS     TIMSK2, R16
    RETI

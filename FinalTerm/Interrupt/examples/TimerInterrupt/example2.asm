; Viết chương trình tạo chuỗi xung vuông tần số 1kHz, CKNV = 30%, ngõ ra PC5, sử dụng ngắt Timer2 tràn

; Chọn Timer2 chạy trong mô thức NOR, hệ số chia N = 64, thời gian đếm mức 1 là 37 xung, thời gian đếm mức 2 là 87 xung

.EQU    P_OUT = 5
.EQU    T_HIGH = -37
.EQU    T_LOW = -87
.ORG    0
RJMP    MAIN
.ORG    0x16                ; Vecto ngắt của ISR TIMER2_OVF
RJMP    TIMER2_OVER_ISR
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, (1 << P_OUT)
    OUT     DDRC, R16       ; PC5 output
    LDI     R17, 0x00
    STS     TCCR2A, R17     ; Timer2 mode NOR
    LDI     R17, 0x03       ; N = 64
    STS     TCCR2B, R17
    SEI                     ; Cờ I = 1, cho phép ngắt toàn cục
    LDI     R17, (1 << TOIE2)   ; Cho phép ngắt Timer2
    STS     TIMSK2, R17
    CBI     PORTC, P_OUT    ; Ban đầu PC5 = 0
START:      RJMP    START
;---------------
TIMER2_OVER_ISR:
    LDI     R17, 0x00
    STS     TCCR2B, R17     ; Dừng Timer2
    IN      R17, PORTC      ; 
    EOR     R17, R16        ; Đảo bit PC5
    OUT     PORTC, R17      ; Xuất ra port C
    SBIC    PORTC, P_OUT    ; Kiểm tra PC5 = 0
    RJMP    HIGH_DELAY      ; Nếu PC5 = 1, chuyển sang HIGH_DELAY để nạp giá trị delay cho mức 1
    LDI     R17, T_LOW      ; Nếu PC5 = 0, nạp T_LOW vào cho lần delay mức 0 kế tiếp
    RJMP    CONT
HIGH_DELAY:
    LDI     R17, T_HIGH     ; Nạp TCNT2 = T_HIGH
CONT:
    STS     TCNT2, R17      ; Nạp giá trị đếm
    LDI     R17, 0x03       ; Timer2 bắt đầu chạy lại, N = 64
    STS     TCCR2B, R17
    RETI

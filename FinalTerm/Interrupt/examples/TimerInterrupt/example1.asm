; Viết chương trình tạo sóng đối xứng có chu kì 24uS sử dụng Timer0 ngắt, output ra PB1

.EQU    P_OUT   1
.ORG    0
RJMP    MAIN
.ORG    0x24                    ; Vecto ngắt tràn Timer0
RJMP    TIMER0_OVER_ISR
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, (1 << P_OUT)
    OUT     DDRB, R16           ; PB1 output
    LDI     R17, 96             ; Nạp giá trị delay vào TCNT0
    OUT     TCNT0, R17
    LDI     R17, 0x00           ; WG01:00 = 00 Timer0 mode NOR
    OUT     TCCR0A, R17
    LDI     R17, 0x01           ; WG02 = 0, CS02:00 = 001 : Timer 0 NOR mode, N = 1
    OUT     TCCR0B, R17
    SEI                         ; Set cờ I lên 1, cho phép ngắt toàn cục
    LDI     R17, (1 << TOIE0)   ; Cho phép ngắt Timer0 tràn
    STS     TIMSK0, R17         
START:      RJMP    START
;-----------------------------
TIMER0_OVER_ISR:    ; ISR chạy khi cờ báo tràn Timer0 set lên 1
    LDI     R17, 0x00   
    OUT     TCCR0B, R17         ; Dừng Timer0
    LDI     R17, -96            ; Nạp lại giá trị delay cho lần kế tiếp sau khi ngắt
    OUT     TCCN0, R17
    IN      R17, PORTB          ; Đọc trạng thái PORTB
    EOR     R17, R16            ; Đảo bit PB1
    OUT     PORTB, R17
    LDI     R17, 0x01           ; Đặt N = 1, Timer bắt đầu chạy tiếp
    OUT     TCCR0B, R17
    RETI
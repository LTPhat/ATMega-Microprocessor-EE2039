; Viết chương trình tạo sóng vuông có tần số F = 500Hz ở ngõ ra PB7
; Sóng vuông có chu kỳ nhiệm vụ DC = 20%
; Biết rằng Fosc = 8MHz và CKDIV8 = 1 (chưa lập trình)

; 1MC = 1CK = 1/8 MHz = 125 ns
; T = 1/F = 1/500 Hz = 2ms = 2000 uS
; tH = 20%.T = 400 uS = 400 000 nS = 4.(200.4).T
; Chọn m = 4, n = 200 

; tL = T -tH = 1600 uS = 4.400 uS = 4tH
; Sai số : 3m + 4(MC) = 16 MC = 2uS


.ORG    0
SBI     DDRB, 7                 ; Bit 7 của port B làm output
DELAY_tH:   SBI     PORTB, 7    ; Set trạng thái 1
            RCALL   DELAY_400
            CBI     PORT7, 7    ; Set trạng thái 0
            LDI     R19, 4      ; Set m = 4
DELAY_tL:   RCALL   DELAY_400
            DEC     R19
            BRNE    DELAY_tL
            RJMP    DELAY_tH

DELAY_400:          LDI     R21, 4
OUTTER_LOOP:        LDI     R20, 200
INNER_LOOP:         NOP
                    DEC     R20
                    BRNE    INNER_LOOP
                    DEC     R21
                    BRNE    OUTTER_LOOP
                    RET
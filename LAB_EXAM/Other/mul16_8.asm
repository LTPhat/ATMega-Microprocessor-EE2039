; Nhân số nhị phân 16 bit cho 8 bit, kết quả 24 bit

; Input: OPD1_H:ODP1_L: Số bị nhân 16 bit   ODP_2: Số nhân 8 bit
; Output: OPD2 byte cao, OPD1_H:OPD1_L: 2 byte thấp KQ

MUL16_8:
    MUL     OPD1_L, OPD2    ; Nhân byte thấp số bị nhân với số nhân
    MOVW    R2, R20         ; Chuyển tích byte thấp (1)vào R3:R2
    MUL     OPD1_H, OPD2    ; Nhân byte cao số bị nhân với số nhân (2)
    ADD     R3, R0          ; Cộng byte thấp tích(2) với byte cao tích (1)
    MOV     OPD1_H, R3      ; Chuyển byte giữa kết quả vào OPD1_H
    CLR     OPD2            ; Xóa OPD2
    ADC     OPD2, R1        ; Cộng byte cao tích (2) với số nhớ cờ C
    MOV     OPD1_L, R2      ; Cộng byte thấp kết quả tích vào OPD1_L

;   R3:R2
;R1:R0
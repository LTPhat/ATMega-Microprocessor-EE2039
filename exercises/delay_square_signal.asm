; Viết chương trình tạo sóng vuông có tần số F = 500Hz ở ngỡ ra PB7
; Biết sóng vuông có chu kỳ nhiệm vụ DC = 50 %


; DC = t_H/T (%) là thời gian trong một chu kỳ xung tích cực ở mức 1

; Tạo delay bằng loop:
; DELAY:        LDI     R20, n      1   MC
;       LAP:    DEC     R20         n   MCs
;               BRNE    LAP         2n  MCs
; Số MC trong mỗi DELAY: 3n (0 <= n <= 255)
; 1MC = 1uS

; T = 1/F = 2ms => DC = 1ms = 1000 (uS)
; 3n = 1000 => n = 333 > 255 --> Thêm lệnh NOP (1 NOP = 1 MC)
; Lúc này số MC trong 1 DELAY function = 4n = 1000 => n = 250


.ORG        0
SBI         DDRB, 7         ; Set bit 7 của thanh ghi I/O DDRB của port B lên 1 --> Port B xuất
LAP:    SBI PORTB, 7        ; Set bit 7 của thanh ghi port B lên 1
        LDI R20, 250        ; Tạo delay T/2 cho trạng thái 1
DELAY1:     NOP
            DEC     R20         ; Giảm n xuống 1
            BRNE    DELAY       ; Lặp cho đến khi n = 0
            CBI     PORTB, 7    ; Clear bit 7 của portB về 0
DELAY2:     LDI     R20, 250    ; Tạo delay T/2 cho trạng thái 0
            NOP
            DEC     R20
            BRNE    DELAY2
            RJMP    LAP         ; Quay trở lại chu kỳ tiếp theo    
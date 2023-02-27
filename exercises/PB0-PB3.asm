; Viết chương trình thực hiện chức năng điều khiển trạng thái các chân port PB0 đến PB3 thông qua hai trạng thái của 2 bit PD0 và PD1
; PD1   PD0     Control
; 0     0       Bù PB0
; 0     1       Bù PB1
; 1     0       Bù PB2
; 1     1       Bù PB3

.ORG    0
CLR     R20
OUT     DDRD    R20     ; Port D nhập
SER     R20
OUT     DDRB    R20     ; Port B xuất


LAP:    IN      R21, PORTB  ; Lấy giá trị của port B hiện tại
        IN      R20, PIND   ; Lấy giá trị nhập của port D
        ANDI    R20, 0b00000011 ; Lấy hai bit cuối PD0  PD1
        CPI     R20, 0
        BRNE    SS1             ; Nếu R20 khác 0 chuyển tới label SS1
        LDI     R22, 0b00000001 ;
        EOR     R21, R22        ; R20 XOR R22
        RJMP    CONTINUE
SS1:    CPI     R20, 1
        BRNE    SS2
        LDI     R22, 0b00000010
        EOR     R21, R22
        RJMP    CONTINUE
SS2:    CPI     R20, 2
        BRNE    SS3
        LDI     R22, 0b00000100
        EOR     R21, R22
        RJMP    CONTINUE
SS3:    LDI     R22, 0b00001000
        EOR     R21, R22
        RJMP    CONTINUE
CONTINUE:   OUT     PORTB, R21
            RJMP    LAP
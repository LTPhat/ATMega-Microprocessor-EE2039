; Delay 200ms



DELAY200_MS:
LDI R17, 25
LDI R16, 249
OUT OCR0A, R16
LDI R16, 0x02
OUT TCCR0A, R16
LDI R16, 0x04
OUT TCCR0B, R16
LOOP1:
    IN      R18, TIFR0
    SBRS    R18, OCF0A
    RJMP    LOOP1
    OUT     TIF0, R18
    DEC     R25
    BRNE    LOOP1
    RET



.ORG 0x02
RJMP    INT0_ISR:
.ORG 0x40
MAIN:
    LDI R16, 0x02
    STS EICRA, R16      ; Khai bao nguon tac dong canh xuong
    LDI R16, (1<<INT0)  ; Cho phep ngat ngoai INT
    STS EIMSK, R16
    SEI
    SBI PORTD, 2        
    LDI R16, 0xFF
    OUT DDRA, R16       ; Port A Xuat
    LDI XH, HIGH(TAB<<1)
    LDI XL, LOW(TAB<<1)
HERE: RJMP HERE
PCINT0_ISR:
    LDI R22, 4      ; So chuoi xuat
    LOOP:
    LD  R18, X+
    OUT PORTA, R18
    RCALL DELAY200_MS
    DEC R22
    BRNE    LOOP
    RETI
TAB:
.DB 0x18, 0x3C, 0x7E, 0xFF
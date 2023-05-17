; Tạo chuỗi xung vuông đối xứng lệnh pha nhau pi/2, Fo=2khz



MAIN:
    LDI R16, 0x03
    OUT DDRC, R16
    SBI PORTC, 0
    SBI PORTC, 1
    LDI R16, 0x02
    OUT TCCR0A, R16
    LDI R16, 249
    OUT OCR0A, R16
    LDI R16, 124
    OUT OCR0B, R16
    LDI R16, 0x02
    OUT TCCR0B, R16
LOOP:
    IN      R17, TIFR0
    SBRS    R17, OCF0B
    RJMP    CH_A
    RJMP    CH_B
    


CH_A:
    IN      R17, TIFR0
    SBRS    R17, OCF0A
    RJMP    LOOP
    OUT     TIFR0, R17
    IN      R19, PORTC
    LDI     R20, (1<<PC0)
    EOR     R19, R20
    OUT     PORTC, R19
    RJMP    LOOP

CH_B:
    OUT     TIFR0, R17
    LDI     R16, (1<<PC1)
    IN      R18, PORTC
    EOR     R18, R16
    OUT     PORTC, R18
    RJMP    LOOP


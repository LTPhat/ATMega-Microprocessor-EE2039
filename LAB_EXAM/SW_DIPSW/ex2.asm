




LOOP:
    IN      R16, PINA
    ANDI    R16, 0x03
    CPI     R16, 0x00
    BREQ    SO0
    CPI     R16, 0x01
    BREQ    SO1
    CPI     R16, 0x02
    BREQ    SO2
    CPI     R16, 0x03
    BREQ    SO3
    RJMP    LOOP
SO0:
    LDI     R17, '0'
    OUT     PORTB, R17
SO1:
......














SO0:

; SW 1 = 0; Xuat n
; SW 1 = 1; Xuat y




.DEF    SW = 0
.DEF    OUTPORT = PORTB

CBI     DDRC, 0
SBI     PORTC, 0
LDI     R16, 0xFF
OUT     DDRB, R16

LOOP: 
    IN      R16, PINC
    SBRC    R16, SW
    RJMP    OUTPUTY                     ; Khog nhan
    LDI     R17, 'N'                    ; Nhan
    OUT     OUTPORT, R17
    RJMP    LOOP
OUTPUTY:    
    LDI     R17, 'Y'
    OUT     OUTPORT, R17
    RJMP    LOOP

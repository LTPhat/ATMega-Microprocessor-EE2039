;a) Khi Swich nh?n/nh?, gi� tr? ch�n Port b?ng 0/1.
;b) ?? LED s�ng, ch�n port xu?t ra m?c logic 1.
;c) M� ngu?n:
LDI R16, 0X02
OUT DDRA, R16
LDI R16, 0X01
OUT PORTA, R16
LOOP:
SBIC PINA, 0
RJMP OFF
SBI PORTA, 1
RJMP LOOP
OFF:
CBI PORTA, 1
RJMP LOOP

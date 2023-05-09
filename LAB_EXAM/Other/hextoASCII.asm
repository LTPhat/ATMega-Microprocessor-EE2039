;HEX_ASC chuyển từ mã Hex sang mã ASCII
;Input R17=mã Hex,Output R18=mã ASCII
;------------------------------------------
HEX_ASC:CPI R17,0X0A
BRCS NUM
LDI R18,0X37
RJMP CHAR
NUM: LDI R18,0X30
CHAR: ADD R18,R17
RET

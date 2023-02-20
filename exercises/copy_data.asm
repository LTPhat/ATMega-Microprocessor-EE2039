;Sao chép 5 ô nhớ SRAM có địa chỉ đầu là 100H vào lần lượt các thanh ghi từ R16 đến R20

LDI YH, 0x01    ; high byte of address
LDI YL, 0x00    ; low byte of address
LD	R16, Y
LDD R17, Y + 1
LDD R18, Y + 2
LDD R19, Y + 3
LDD R20, Y + 4 
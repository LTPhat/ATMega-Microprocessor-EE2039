; Viết chương trình nhập dữ liệu liên tục từ port A là số có dấu 8 bit. Tìm trị tuyệt đối của nó và xuất ra Port C.
; Biết rằng chương trình sẽ kết thúc khi giá trị nhập về bằng 0, giá trị này cũng xuất ra port C


.ORG    0
LDI     R16, 0 
OUT     DDRA, R16           ;Port A ở chế độ nhập
LDI     R16, $FF
OUT     DDRC, R16           ;Port C ở chế độ xuất
LAP:    IN      R16, PINA   ;Lấy dữ liệu từ port A
        CPI     R16, 0
        BREQ    KETTHUC     ;Nếu R16 bằng 0, kết thúc
        BRPL    XUAT        ;Nếu R16 lớn hơn 0, xuất 
        NEG     R16         ;Lấy bù 2 nếu R16 nhỏ hơn 0
XUAT:   OUT     PORTC, R16
        RJMP    LAP
KETTHUC:OUT     PORTC, R16
ENDING: RJMP    ENDING



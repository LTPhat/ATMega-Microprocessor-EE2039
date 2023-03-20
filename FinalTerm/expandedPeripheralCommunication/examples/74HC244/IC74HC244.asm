; Giao tiếp ngoại vi nhập mở rộng dùng IC74HC244


; OE = 0 --> Cho phép xuất data từ IC
; OE = 1 --> Cấm xuất



; Viết chương trình nhận data từ U2, U3 lưu vào các thanh ghi lần lượt là R17, R18


.ORG        0
LDI         R16, 0X00   
OUT         DDRB, R16       ; port B chức năng nhập
SBI         DDRC, 0         ; PC0 = output, điều khiển U2
SBI         DDRC, 1         ; PC1 = output, điểu khiển U3
SBI         PORTC, 0        ; PC0 = 1; khóa đệm U2, cấm xuất từ U2
SBI         PORTC, 1        ; PC1 = 1; khóa đệm U3, cấm xuất từ U3
CBI         PORTC, 0        ; PC0 = 0; mở đệm U2 cho phép xuất data vào port B
IN          R17, PINB       ; Lấy dữ liệu xuất từ U2 vào port B lưu vào R17
SBI         PORTC, 0        ; PC0 = 1; khóa đệm U2 sau khi xuất
CBI         PORTC, 1        ; Mở đệm U3 cho phép xuất data từ U3 vào portB
IN          R18, PINB       ; Lấy dữ liệu xuất từ U3 vào port B lưu vào R18
SBI         PORTC, 1        ; Khóa đệm U3 sau khi xuất 
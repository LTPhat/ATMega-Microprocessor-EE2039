; Giao tiếp mở rộng ngoại vi xuất sử dụng IC 74HC573


; Tóm tắt hoạt động 74HC573

; OE = 1, Qn = High Z --> Cấm xuất
; OE = 0; Qn = Dn ---> Cho phép xuất
; LE điều khiển mở chốt với OE = 0


; Viết chương trình xuất data từ R17 ra U2 và xuất data từ R18 ra U3, chọn portB là port xuất dữ liệu

.ORG        0
LDI         R16, 0XFF
OUT         DDRB, R16   ; Port B là port xuất
SBI         DDRC, 0     ; PC0 output, tín hiệu PC0 là ngõ vào điểu khiển của U2
SBI         DDRC, 1     ; PC1 output điều khiển U3
CBI         PORTC, 0    ; Khóa chốt U2
CBI         PORTC, 1    ; Khóa chốt U3

OUT         PORTB, R17  ; Xuất dữ liệu từ R17 ra port B chờ sẵn
SBI         PORTC, 0    ; Mở chốt U2, lúc này data từ port B chờ sẵn xuất ra U2
CBI         PORTC, 0    ; Khóa chốt U2 sau khi U2 nhận được data từ port B
OUT         PORTB, R18  ; Xuất dữ liệu R18 ra port B
SBI         PORTC, 1    ; Mở chốt U3, U3 lấy dữ liệu R18
CBI         PORTC, 1    ; Đóng chốt U3
;  Giả sử 3 bit thấp của portC được kết nối đến 3 công tắc. Viết chương trình gửi các ký tự ASCII đến portD tương ứng với các giá trị nhận được từ các công tắc như sau:

;   PC2-PC0           Mã ASCII
;   000                 "0"
;   001                 "1"
;   010                 "2"
;   011                 "3"
;   100                 "4"
;   101                 "5"
;   110                 "6"
;   111                 "7"


.ORG        0       
LDI         R16, 0
OUT         DDRC, R16                           ; Thiết lập portC là cổng nhập
LDI         R16, 0XFF
OUT         PORTC, R16                          ; PortC có điện trở kéo lên
OUT         DDRD, R16                           ; PortD là cổng xuất
LDI         R20, 0                              ; Lấy byte cao của địa chỉ (Lấy 00 trong 002x)
BEGIN:      IN      R16, PINC                   ; Đọc trạng thái của công tắc ở PORTC hiện tại
            ANDI    R16, 0b00000111             ; Lấy 3 bit cuối PC2-PC0
            LDI     ZL, LOW(ASCII TABLE << 1)   ; Lấy địa chỉ byte thấp của dữ liệu bảng
            ADD     ZL, R16                     ; Lấy số chỉ trong dữ liệu tương ứng với giá trị của R16 đọc được
            LPM     R17, Z                      ; Lấy mã ASCII tương ứng
            OUT     PORTD, R17
            RJMP    BEGIN
.ORG            20                              ; Địa chỉ lưu dữ liệu bảng
ASCII   TABLE:  .DB '0', '1', '2', '3', '4', '5', '6', '7'
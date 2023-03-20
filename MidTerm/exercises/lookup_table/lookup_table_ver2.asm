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

; Thực hiện trường hợp tổng quát cho địa chỉ của data ASCII


; Bài này khác với bài lookup_table là phải xử lý byte cao của bảng ASCII khi cờ C nhảy lên 1
; Bài lookup_table cho sẵn địa chỉ của ASCII là 0020 nên byte cao là 00 không cần cập nhật

; Hướng đi:
; 1) Thiết lập trạng thái sử dụng các cổng IO
; 2) Đọc data từ các công tắc (port C)
; 3) Lấy giá trị 3 bit thấp (OFFSET)
; 4) Đặt địa chỉ con trỏ Z vào đầu bảng tra
; 5) Cộng OFFSET vào ZL để lấy số chỉ của dữ liệu trong bảng
; 6) Kiểm tra cờ C, nếu cờ C = 1 có nghĩa là ZL+ OFFSET vượt quá 8bit nên phải cập nhât ZH, nếu cờ C = 0 thì lấy nội dung tại số chỉ tương ứng (ZL+OFFSET) trong bảng tra
; 7) Xuất ra PORT D


.ORG        0       
LDI         R16, 0
OUT         DDRC, R16                           ; Thiết lập portC là cổng nhập
LDI         R16, 0XFF
OUT         PORTC, R16                          ; PortC có điện trở kéo lên
OUT         DDRD, R16                           ; PortD là cổng xuất
LAP:        IN      R20, PINC                   ; Lấy trạng thái của port C hiện tại
            ANDI    R20, 0B00000111             ; Lấy 3 bit thấp PC2-PC0
            LDI     ZH, HIGH(ASCII << 1)        ; Lấy byte cao của địa chỉ bảng tra         
            LDI     ZL, LOW(ASCII << 1)         ; Lấy byte thấp
            ADD     ZL, R20                     ; Lấy số chỉ của dữ liệu tương ứng với R20 đọc được
            BRCC    FINAL
            INC     ZH                          ; Nếu cờ C = 1, tổng vượt quá 8 bit, set lại ZH 
FINAL:      LPM     R17, Z                      ; Lấy nội dung ứng với số chỉ của R20 + ZL trong bảng tra
            OUT     PORTD, R17                  ; Xuất ra portD
            RJMP    LAP                         ; Quay lại LAP tiếp tục nhận dữ liệu từ port C
ASCII:      .DB '0', '1', '2', '3', '4', '5', '6', '7'
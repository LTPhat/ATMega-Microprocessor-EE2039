; Viết chương trình BCD_7SEG thực hiện chuyển số BCD 1 decade là ngõ vào của 4 bit thấp port A thành mã led 7 đoạn loại cathode chung (cạnh a ở vị trí LSB), xuất ra Port D
; 

;Digit to Display    h g f e d c b a     Hex code

;0                       11000000            C0

;1                       11111001            F9

;2                       10100100            A4

;3                       10110000            B0

;4                       10011001            99

;5                       10010010            92

;6                       10000010            82

;7                       11111000            F8

;8                       10000000            80

;9                       10010000            90

; Lập bảng chứa mã HEX CODE của LED 7 đoạn Cathode chung với x = 0, 1 .. 9.
; x là số BCD nhận được từ 4 bit thấp, 0 <= x <= 9. Tuy nhiên với 4 bit nhị phân nhận từ port A vẫn có khả năng BCD tương ứng đi từ 10 đến 15
; Xét trường hợp: 0 <= x <= 9, cộng x với địa chỉ đầu tiên của bảng và lấy data tương ứng với vị trí đó ta được kết quả
; Xét trường hợp: 10 < x <= 15, quay lại vòng lặp tiếp tục nhận input từ port A



.ORG            0
LDI             R16, 0X00
OUT             DDRC, R16                           ; Thiết lập portA là cổng nhập
LDI             R16, 0XFF
OUT             PORTA, R16                          ; PortC có điện trở kéo lên
OUT             DDRD, R16                           ; PortD là cổng xuất
LAP:        IN      R20, PINC                       ; Lấy trạng thái của port A hiện tại
            ANDI    R20, 0B00001111                 ; Lấy 4 bit thấp PA3-PA0
            LDI     ZH, HIGH(LED7 << 1)             ; Lấy byte cao của địa chỉ bảng tra         
            LDI     ZL, LOW(LED7 << 1)              ; Lấy byte thấp
            ADD     ZL, R20                         ; Lấy số chỉ của dữ liệu tương ứng với R20 đọc được
            BRCC    FINAL
            INC     ZH                              ; Nếu cờ C = 1, tổng vượt quá 8 bit, set lại ZH 
FINAL:      LPM     R17, Z                          ; Lấy nội dung ứng với số chỉ của R20 + ZL trong bảng tra
            OUT     PORTD, R17                      ; Xuất ra portD
            RJMP    LAP                             ; Quay lại LAP tiếp tục nhận dữ liệu từ port A
.LED7:      .DB '0XC0', '0XF9', '0XA4', '0XB0', '0X99', '0X92', '0X82', '0XF8', '0X80', '0X90'
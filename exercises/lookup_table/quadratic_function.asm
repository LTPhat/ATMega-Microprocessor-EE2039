; Viết chương trình tính giá trị của biểu thức Y = x^2 + 2x + 3 và xuất ra portA.
; Biết rằng x là số BCD nhận được từ 4 bit thấp của port B

; Hướng đi:
; Lập bảng chứa giá trị của biểu thức Y với x = 0, 1 .. 9.
; x là số BCD nhận được từ 4 bit thấp, 0 <= x <= 9. Tuy nhiên với 4 bit nhị phân nhận từ port A vẫn có khả năng BCD tương ứng đi từ 10 đến 15
; Xét trường hợp: 0 <= x <= 9, cộng x với địa chỉ đầu tiên của bảng và lấy data tương ứng với vị trí đó ta được kết quả
; Xét trường hợp: 10 < x <= 15, quay lại vòng lặp tiếp tục nhận input từ port A

.ORG        0       
LDI         R16, 0
OUT         DDRA, R16                           ; Thiết lập portA là cổng nhập
LDI         R16, 0XFF
OUT         PORTA, R16                          ; PortC có điện trở kéo lên
OUT         DDRB, R16                           ; PortB là cổng xuất
LAP:        IN      R20, PORTA                  ; Lấy 8 bit dữ liệu trạng thái từ port C
            ANDI    R20, 0B00001111             ; Lấy 4 bit thấp PA3-PA0
            CPI     R20, 10                     ; So sánh với 10
            BRSH    LAP                         ; Nếu lớn hơn 10, mã BCD không hợp lệ quay lại LAP chờ input portA
            LDI     ZH, HIGH(VALUE << 1)        ; Lấy byte cao của địa chỉ bảng tra         
            LDI     ZL, LOW(VALUE << 1)         ; Lấy byte thấp
            ADD     ZL, R20                     ; Lấy số chỉ của dữ liệu tương ứng với R20 đọc được
            BRCC    FIND_VALUE
            INC     ZH
FIND_VALUE: LPM     R17, Z                      ; Load data tại số chỉ ZL+R20 trong bảng tra
            OUT     PORTB, R17                  ; Xuất ra portB
            RJMP    LAP                         ; Quay lại LAP tiếp tục nhận dữ liệu từ port A
VALUE:  .DB '0x03', '0x06', '0x0B', '0x12', '0x1B', '0x26', '0x33', '0x42', '0x53', '0x66'
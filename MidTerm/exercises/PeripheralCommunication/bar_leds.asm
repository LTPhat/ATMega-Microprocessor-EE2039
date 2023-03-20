; Viết chương trình đọc trạng thái các SW và hiển thị dãy LED (bar LED) nếu có 1 SW nhấn/nhả như sau:
; - SW0: Tối dãy LED
; - SW1: Sáng 4 LED có trọng số thấp
; - SW2: Sáng 4 LED có trọng số cao
; - SW3: Sáng toàn bộ dãy LED
; Chương trình có chống rung SW và 4 SW được nối vào port B có trọng số thấp


; Chống rung bằng cách kiểm tra SW nhấn/nhả 50 lần để xác định trạng thái SW, trả về mã SW nhấn tương ứng

; Hướng đi
; - Viết module GET_KEY trả về mã nút nhấn và cờ C = 1 khi nhận diện có nút nhấn hoặc cờ C = 0 khi không có nút nhấn
; - Kiểm tra nhấn SW bằng vòng lặp 50 lần 
; - Kiểm tra nhả SW bằng vòng lặp 50 lần
; - Xuất kết quả ra LED theo mã nút nhấn tương ứng với đề bài


.INCLUDE    <M324PDEF.INC>
.EQU        OUTPORT=PORTC       ; OUTPORT = địa chỉ I/0 của port C
.ORG        0                   ; Mở đầu chương trình 
RJMP        MAIN                ; Nhảy đến nhãn MAIN
.ORG        0X40                ; Chương trình MAIN bắt đầu từ địa chỉ 0X40 để chừa vị trí từ 0X00 đến 0x3F cho việc thực hiện chương trình ngắt (nếu có)
MAIN:       LDI         R16, HIGH(RAMEND)   ; Khai váo vùng Stack
            OUT         SPH, R16        
            LDI         R16, LOW(RAMEND)
            OUT         SPL, R16
            LDI         R16, 0XF0
            OUT         DDRB, R16           ; Khai báo 4 bit cuối của portB bằng 0, tạo chức năng nhập cho PB3-PB0
            LDI         R16, 0X0F           
            OUT         PORTB, R16          ; Khai báo điện trở kéo lên cho PB3-PB0
            LDI         R16, 0XFF
            OUT         DDRC, R16           ; Khai báo PORTC có chức năng xuất
            LDI         R16, 0X00
            OUT         PORTC, R16          ; Tất cả các LED ban đầu tắt
WAIT_0:     LDI     R16, 50     ; Bắt đầu kiểm tra nhấn phím, kiểm tra 50 lần trạng thái nhấn
BACK_1:     RCALL   GET_KEY
            BRCC    WAIT_0      ; Nếu hàm GET_KEY trả về kết quả cờ C = 0 (không có nút nhấn), quay về WAIT_0
            DEC     R16         ; GET_KEY trả về cờ C = 1 (có nút nhấn), tiếp tục kiểm tra xem cho đến hết 50 lần 
            BRNE    BACK_1      ; Khi R16 != 0 tiếp tục kiểm tra nút nhấn
            PUSH    R17         ; Sau khi xác định có nút nhấn sau 50 lần, đẩy kết quả mã nút nhấn vào R17
WAIT_1:     LDI     R16, 50     ; Tương tự, kiểm tra 50 lần trạng thái nhả nút
BACK_2:     RCALL   GET_KEY
            BRCS    WAIT_1      ; Hàm GET_KEY trả kết quả cờ C = 1 (có nút nhấn, chưa nhả), quay lại WAIT_1
            DEC     R16         ; Hàm GET_KEY trả về cờ C = 0 (có nhả phím), tiếp tục kiểm tra cho đến hết 50 lần
            BRNE    BACK_2      ; Khi R16 != 0, tiếp tục kiểm tra nhả phím
            POP     R17         ; Sau khi kiểm tra nhấn, nhả thành công -> Xác nhận có một lần nhấn phím, lấy kết quả R17 là mã nút nhấn ra
            CPI     R17, 0      ; Thực hiện so sánh mã nút nhấn và chuyển đến chế độ theo yêu cầu của đề bài
            BREQ    MODE_0
            CPI     R17, 1
            BREQ    MODE_1
            CPI     R17, 2
            BREQ    MODE_2
            CPI     R17, 3
            BREQ    MODE_3
            RJMP    WAIT_0          ; Kết thúc một lần nhấn phím, quay lại WAIT_0 chờ lần nhấn tiếp theo
MODE_0:     LDI     R18, 0X00
            OUT     OUTPORT, R18    ; Hiến thị mode 0
MODE_1:     LDI     R18, 0X0F      
            OUT     OUTPORT, R18    ; Hiển thị mode 1
MODE_2:     LDI     R18, 0XF0
            OUT     OUTPORT, R18    ; Hiển thị mode 2
MODE_3:     LDI     R18, 0XFF
            OUT     OUTPORT, R18    ; Hiển thị mode 3
; Module GET_KEY
; Return R17 = Mã nút nhấn SW và C = 1 và có SW nhấn
; Return C = 0 nếu không có nút nhấn
GET_KEY:    LDI     R17, 4      ; R17 chứa số SW
            MOV     R20, R17    ; Sao chép R17 sang R17, giữ giá trị 17, dùng R20 và R17 để xác định mã nút nhấn
            IN      R19, PINB   ; Đọc mã nút nhấn từ PORTB
            ANDI    R19, 0X0F   ; Chỉ lấy 4 bit thấp để đọc trạng thái PB3-PB0
            CPI     R19, 0XFF   ; So sánh R19 với 1111, nếu giống thì chứng tỏ không có nút nhấn, ngược lại là có nút nhấn
            BRNE    CHECK_KEY
NO_KEY:     CLC                 ; Clear cờ C để xuất ra output của GET_KEY
            RJMP EXIT
CHECK_KEY:  ROR     R19         ; Dịch phải R19, LSB lưu vào cờ C
            BRCC    KEY_CODE    ; Nếu cờ C = 0, có nút nhấn tại vị trí LSB vừa dịch, chuyển tới KEY_CODE
            DEC     R20         ; Chưa gặp cờ C, tiếp tục dịch để tìm bit 0
            BRNE    CHECK_KEY   
            RJMP    NO_KEY
KEY_CODE:   SUB     R17, R20    ; Lấy vị trí có nút nhấn (mã SW)
            SEC                 ; Set cờ C = 1 để xuất ra kết quả của hàm GET_KEY
EXIT:       RET

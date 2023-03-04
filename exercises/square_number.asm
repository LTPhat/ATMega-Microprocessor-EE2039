; Cho một số 16 bit chứa ở ô nhớ có địa chỉ 100H, 101H (địa chỉ thấp hơn chứa byte thấp) Kiểm tra xem số đó có phải là số chính phương hay không
; Nếu là số chính phương, xuất giá trị 1 ra bit thứ 7 của port C
; Nếu không là số chính phương, xuất giá trị 0 ra bit thứ 7 của port C


; Hướng đi:
; Cho biến chạy từ 1, mỗi lần lặp nhân với chính nó, kiểm tra kết quả lớn hơn hay bằng số ban đầu thì thoát vòng lặp
; Kiểm tra lại một lần nữa, nếu tích lớn hơn thì số ban đầu không là số chính phương, ngược lại là số chính phương


; Kiểm tra: Gọi số cần kiểm tra là A, tích biến chạy là B
; - Kiểm tra HIGH: Nếu B_high <= A_high ---> Kiểm tra xem B_high = A_high không: Nếu bằng thì chuyển sang kiểm tra B_low A_low, nếu nhỏ hơn thì tiếp tục tăng counter, tính tích và kiểm tra lại
;                  Nếu B_high > A_high ---> B > A, dừng vòng lặp trả về không phải scp
; - Kiểm tra LOW:  Nếu B_low <= A_low ---> Kiểm tra xem B_low = A_low không: Nếu bằng chứng tỏ B_high = A_high, B_low = A_low, kết luận là scp, nếu nhỏ hơn thì B_high = A_high, B_low < A_low, tiếp tục tăng counter, tính tích và kiểm tra lại
;                  Nếu B_low > A_low ---> B_high = A_high, B_low > A_low --> B > A, kết luận không là scp



.INCLUDE    <M324PDEF.INC>
.ORG            0
SBI             DDRC, 7                     ; Set bit thứ 7 của port C xuất
LDS             R16, $100                   ; Load byte thấp của số cần kiểm tra
LDS             R17, $101                   ; Load byte cao của số cần kiểm tra
MOV             R20, R17                    ; Tạo R20 là byte cao của số cần kiểm tra dùng để so sánh
MOV             R19, R16                    ; Tạo R21 là byte thấp của số cần kiểm tra dùng để so sánh
INC             R20                         ; Tăng byte của số cần kiểm tra lên 1 để dùng BRLO rẽ nhánh khi byte cao của tích <= R17
INC             R19                         ; Tăng byte thấp của số cần kiểm tra lên 1 để dùng BRLO rẽ nhánh khi byte thấp của tích <= R16
LDI             R22, 1                      ; Tạo biến chạy lưu trong R22
LAP:            MUL     R22, R22            ; Lấy biến chạy nhân chính nó, kết quả là số 16 bit lưu trong R1:R0
                CP      R20, R1             ; So sánh byte cao của tích và (byte cao của số cần kt + 1)
                BRLO    CHECK_HIGH_EQUAL    ; R1 < R20 hay R1 <= R17 chuyển sang kiểm tra hai byte này có bằng nhau không
                RJMP    NOT_SQUARE          ; Nếu R1 > R20 hay R1 > R1, lúc này byte cao kết quả phép nhân lớn hơn nên chuyển tới nhãn không là scp
CHECK_HIGH_EQUAL:   CP      R17, R1         ; So sánh R17 (byte cao thật của số cần tìm) với byte cao của tích
                    BRNE    CONT            ; Nếu không bằng chứng tỏ R1 < R17, hay tích đang nhỏ hơn số cần tìm, tiếp tục tăng counter và lặp 
                    RJMP    CHECK_LOW       ; Nếu hai byte cao bằng nhau, tiếp tục check byte thấp
CONT:               INC     R22
                    RJMP    LAP
CHECK_LOW:          CP      R19, R0         ; So sánh R19 và R0 
                    BRLO    CHECK_LOW_EQUAL ; Nếu R0 < R19 hay R0 <= R16, chuyển sang check hai byte thấp có bằng nhau không
                    RJMP    NOT_SQUARE      ; Nếu R0 >= R19 hay R0 > R16, chứng tỏ byte hai byte cao bằng nhau nhưng byte thấp của tích lớn hơn nên không là scp
CHECK_LOW_EQUAL:    CP      R16, R0         ; So sánh R19 và R0
                    BRNE    CONT            ; Nếu R0 khác R19, hay R0 < R19 thì tiếp tục tăng counter và lặp
                    RJMP    SQUARE          ; Nếu R0 = R19, thì ta có R17 = R1, R16 = R0 hay tích bằng chính số cần kiểm tra, chốt là scp
NOT_SQUARE:         CBI     PORTC, 7        ; Nếu không là scp, xuất 0 ra bit thứ 7 của port C
                    RJMP    EXIT
SQUARE:             SBI     PORTC, 7        ; Nếu là scp, xuất 1 ra bit thứ 7 của port C
                    RJMP    EXIT
EXIT:               RJMP    EXIT
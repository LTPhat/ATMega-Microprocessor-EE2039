; Viết chương trình có nhiệm vụ đếm số ô nhớ trong vùng nhớ SRAM có số bit 1 bằng số bit 0. Biết rằng số ô nhớ cần đếm chứa trong ô nhớ có địa chỉ 100H
; Vùng ô nhớ SRAM bắt đầu từ địa chỉ 200H, kết quả cất vào ô nhớ RAM nội có địa chỉ 1FFH
;


; Chương trình con BIT1_COUNT
; Input: R20 --> Ô nhớ cần kiểm tra
; Output:R21 --> Số lượng bit 1 của R20


.ORG        0
CLR         R17                 ; R17 là kết quả cần tính, ban đầu cho bằng 0
LDS         R22, $100           ; Load số lượng ô nhớ cần kiểm tra là nội dung của thanh ghi $100, đồng thời là bộ đếm
LDI         ZL, LOW($200)       ; Load byte thấp của địa chỉ đầu tiên của vùng SRAM
LDI         ZH, HIGH($200)      ; Load byte cao
LAP:        LD      R20, Z+     ; Load ô nhớ con trỏ Z trỏ tới hiện tại  
            RCALL   BIT1_COUNT  ; Gọi chương trình con đếm số bit 1
            CPI     R21, 4      ; So sánh số bit 1 đếm được với 4, 
            BRNE    CONT        ; Nếu số bit 1 khác 4, chuyển tới CONT
            INC     R17         ; Nếu số bit 1 bằng 4, tăng kết quả lên 1
CONT:       DEC     R22         ; Giảm bộ đếm đi 1
            BRNE    LAP         ; Nếu chưa hết độ dài của khối dữ liệu quay lại LAP
            STS     $1FF, R17   
EXIT:       RJMP    EXIT
BIT1_COUNT: LDI     R23, 8              ; Số lượng bit cần kiểm tra
            CLR     R21                 ; Khai báo số lượng bit 1 ban đầu bằng 0
            LOOP:   LSR     R20         ; Dịch trái R20, bit thứ 7 quay vào cờ C
                    BRCC    CONTINUE    ; Nếu cờ C = 0, chuyển tới CONTINUE
                    INC     R21         ; Nếu cờ C = 1, tăng bộ đếm bit 1 lên 1 đơn vị
CONTINUE:   DEC     R23                 ; Giảm số lượng bit cần kiểm tra
            BRNE    LOOP                ; Nếu số lượng bit cần kiểm tra còn lại khác 0, tiếp tục LOOP
            RET                         ; Nếu số lượng bit cần kiểm tra bằng 0, kết thúc ct con, kết quả lưu ở R21



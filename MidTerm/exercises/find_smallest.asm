; Viết chương trình tìm phần từ nhỏ nhất trong 1 khối dữ liệu SRAM. Chiều dài của khối dữ liệu lưu trong ô nhớ 141H (giả sử khác 0) và địa chỉ bắt đầu khối ở trong ô nhớ 142H và 143H (ô nhớ chứa địa chỉ thấp chứa byte thấp của địa chỉ bắt đầu) (giả sử vẫn nằm trong SRAM)
; Kết quả lưu vào ô nhớ 140H, giả sử khối dữ liệu chứa các số nhị phân không dấu.

; Hướng đi: 
; - Load chiều dài khối dữ liệu là nội dung ô nhớ 140H.
; - Địa chỉ bắt đầu khối dữ liệu gồm 2 byte chưa biết, byte thấp là nội dung của ô nhớ 142H, byte cao là nội dung ô nhớ 143H
; - Bằng cách dùng con trỏ X cho XL = nội dung 142H, ZH = nội dung 143H ta thu được 2 byte là địa chỉ bắt đầu của khối dữ liệu
; - Load nội dung của X là phần tử đầu tiên của khối dữ liệu, gán min_val = phần tử đầu tiên
; - Load bằng hậu tố cộng, mỗi lần load địa chỉ khối dữ liệu tăng 1, so sánh với min_val:
;    - Nếu nhỏ hơn min_val, cập nhật min_val
;    - Còn lại, giữ nguyên min_val
; - Trừ bộ đếm chiều dài đi 1 và tiếp tục lặp cho đến khi chiều dài bằng 0


.INCLUDE    <M324PDEF.INC>
.DEF        MIN_VAL, R20            ; Đặt MIN_VAL = R20
.EQU        SAVE_ADDRESS, 0X15      ; Địa chỉ lưu kết quả, chính là địa chỉ SRAM của R21
.ORG        0                       ; Mở đầu chương trình 
RJMP        MAIN                    ; Nhảy đến nhãn MAIN
.ORG        0X40                    ; Chương trình MAIN bắt đầu từ địa chỉ 0X40 để chừa vị trí từ 0X00 đến 0x3F cho việc thực hiện chương trình ngắt (nếu có)
MAIN:       LDS     XL, 0X142       ; Load nội dung của 142H là byte thấp của địa chỉ bắt đầu
            LDS     XH, 0X143       ; Byte cao địa chỉ bắt đầu
            LD      MIN_VAL, X+     ; Load phần tử đầu tiên
            LDS     R22, 0X141      ; Lấy nội dung của địa chỉ 141H là độ dài khối dữ liệu
            SUBI    R22, 1          ; Do đã load phần tử đầu tiên và đặt làm MIN_VAL nên còn lặp R22 - 1 lần
LAP:        LD      R16, X+         ; Load phần tử tiếp và tăng Z lên 1
            CP      MIN_VAL, R16    ; So sánh MIN_VAL và phần tử vừa laod
            BRCC    UPDATE          ; Cờ C = 0, R16 < MIN_VAL => MIN_VAL = R16
            DEC     R22             ; Giảm bộ đếm
            BRNE    LAP             ; Bộ đếm khác 0, tiếp tục lặp và load phần tử kế tiếp
            RJMP    STORE
UPDATE:     MOV     MIN_VAL, R16    ; Di chuyển R16 vào MIN_VAL
            DEC     R22             ; Giảm bộ đếm sau khi UPDATE
            RJMP    LAP
STORE:      STS     SAVE_ADDRESS, MIN_VAL   ; Lưu MIN_VAL vào R21
            RJMP    EXIT
EXIT:       RJMP    EXIT                    ; Kết thúc ctrinh

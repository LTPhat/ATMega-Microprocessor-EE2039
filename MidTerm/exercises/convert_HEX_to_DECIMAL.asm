; Giả sử có một số HEX được lưu trong RAM tại địa chỉ $315. Viết chương trình đổi số này sang hệ thập phân. Kết quả các chữ số thập phân từ hàng từ thấp đến cao lần lượt lưu tại các ô nhớ 0x322, 0x323, 0x324



; Hướng đi
; Thực hiện phép chia số HEX lấy được từ thanh ghi $315 cho 10 bằng vòng lặp các lần trừ 
; Sau lần 1, số dư của phép chia là chữ số hàng đơn vị, lưu thương số
; Sau lần 2, số dư là hàng chục và thương số là hàng trăm.

; R20 ban đầu là số bị chia, cập nhật R20 sau mỗi lần trừ kết quả cuối cùng R20 là số dư, số chia R21, R22 là kết quả của phép chia

.EQU    HEX_NUM_ADDRESS = 0x315
.EQU    DONVI = 0x222
.EQU    CHUC = 0x223
.EQU    TRAM = 0x224
LDS     R20, $315                   ; Lấy nội dung ô nhớ $315 lưu vào R20
LDI     R21, 10                     ; Load số chia bằng 10 vào R21
LDI     R22, 0                      ; 
LAP1:   INC     R22                 ; Tăng kết quả phép chia lên 1 sau mỗi lần trừ
        SUB     R20, R21
        BRCC    LAP1
        DEC     R22                 ; Trừ kết quả phép chia đi 1 do lần cuối làm cờ nhớ C lên 1 
        ADD     R20, R21            ; Lấy số dư
        STS     DONVI, R20          ; Lưu số dư lần 1 vào ô nhớ đơn vị
        MOV     R20, R22            ; Chuyển R22 là kết quả lần lặp trước vào R20 để tiếp tục vòng lặp 2
        LDI     R22, 0              ; Load lại R22 là kết quả cho lần lặp 2
LAP2:   INC     R22
        SUB     R20, R21
        BRCC    LAP2
        DEC     R22                 ; R22 lúc này là chữ số hàng trăm
        ADD     R20, R21            ; R20 lúc này là số dư của lần lặp 2, hay chữ số hàng chục
        STS     CHUC, R20
        STS     TRAM, R22
EXIT    RJMP    EXIT




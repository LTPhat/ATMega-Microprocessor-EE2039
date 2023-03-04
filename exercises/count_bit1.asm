; Viết chương trình SOBIT_1 có nhiệm vụ đếm số bit 1 có trong một byte là nội dung của một ô nhớ A. Biết địa chỉ của ô nhớ A ở trong ô nhớ 142H và 143H (ô nhớ chứa địa chỉ thấp chứa byte thấp của A)
; Kết quả số bit 1 đếm được cất vào thanh ghi R21

; Hướng đi:
; Tìm địa chỉ ô nhớ A bằng cách dùng thanh ghi pointer 16 bit load byte cao và byte thấp của A từ hai thanh ghi đã cho
; Sử dụng lệnh dịch hoặc lệnh quay bit và đếm số lần trạng thái cờ C là 1 sau mỗi lần dịch
; Lưu kết quả vào R21

.ORG        0 
LDS         ZL, 0x142                   ; Nội dung của ô nhớ 0x142 là byte thấp địa chỉ của A
LDS         ZH, 0x143                   ; Nội dung của ô nhớ 0x142 là byte cao địa chỉ của A, lúc này Z pointer gồm 2 byte là địa chỉ của A
LD          R20, Z                      ; Lấy nội dung của địa chỉ mà con trỏ Z đang trỏ đến hiện tại
LDI         R16, 8                      ; Bộ đếm số bit có trong nội dung
CLR         R21, 0                      ; Bộ đếm số bit 1 ban đầu bằng 0
LAP:        ROR     R20                 ; Quay phải R20, LSB cho vào cờ C
            BRCC    CONT                ; Nếu cờ C = 0, chuyển tới CONT
            INC     R21                 ; Nêu cờ C = 1, tăng bộ đếm bit 1
CONT:       DEC     R16                 ; Giảm số lần lặp
            BRNE    LAP                 ; Nếu số lần lặp chưa bằng 0, tiếp tục LAP
EXIT:       JRMP    EXIT                ; Kết thúc, kết quả lưu vào R21


; Viết chương trình đọc trạng thái của một công tắc được kết nối đến chân PB4 và lưu vào LSB của nội dung một ô nhớ RAM có địa chỉ 0x200


.ORG        0
.EQU        SAVED_ADD = 0x200           ; Khao báo địa chỉ lấy nội dung cần thay đổi 
CBI         DDRB, 4                     ; Khai báo bit 4 của PORTC nhập
SBI         PORTB, 4                    ; Khai báo diện trở kéo lên PORTB
IN          R17, PINB                   ; Lấy dữ liệu từ port B lưu vào R17
BST         R17, 4                      ; Lưu PB4 vào cờ T
LDS         R16, $200                   ; Lấy nội dung của ô nhớ $200
BLD         R16, 0                      ; Sao chép bit T vào bit 0 của R16
STS         SAVED_ADD, R16              ; Lưu R16 mới vào địa chỉ ban đầu
HERE:       RJMP    HERE                ; Kết thúc chương trình
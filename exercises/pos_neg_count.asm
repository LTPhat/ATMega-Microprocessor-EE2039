; Cho 100 bytes số có dấu nằm trong bộ nhớ SRAM bắt đầu từ địa chỉ $400. Viết chương trình xuất ra PortC số lượng số âm và xuất ra port D số lượng số dương.

; Hướng đi
; - Dùng pointer trỏ đến nội dung của ô nhớ $400 để lấy bytes đầu tiên, tăng con trỏ lên 1
; - Với byte load lên ở mỗi vòng lặp, so sánh với 0 (ghi nhớ khi so sánh hai số có dấu rẽ nhánh dùng lệnh BRLT, BRGE)
;    - Nếu lớn hơn hoặc bằng 0 (BRGE), tiếp tục so sánh với 0 dùng BRNE, BREQ, nếu đúng thì byte đó lớn hơn 0, tăng COUNT_POS
;    - Nếu nhỏ hơn 0, tăng COUNT_NEG
;    - Giảm bộ đếm bytes và tiếp tục vòng lặp nếu bộ đếm bytes khác 0



.INCLUDE    <M324PDEF.INC>
.DEF        COUNT_POS = R22
.DEF        COUNT_NEG  = R21
.ORG        0
LDI         R20, 100            ; Load bộ đếm 100 bytes
CLR         COUNT_POS           ; Set bộ đêm số âm bằng 0
CLR         COUNT_NEG           ; Set bộ đêm số dương bằng 0
LDI         R16, 0xFF           
OUT         PORTC, R16          ; PortC xuất 
OUT         PORTD, R16          ; PortD xuất
LDI         XL, LOW($400)       ; Load byte thấp của địa chỉ đầu tiên 
LDI         XH, HIGH($400)      ; Load byte cao của địa chỉ đầu tiên
LOOP:       LD      R16, X+     ; Load byte mà con trỏ đang trỏ đến hiện tại, tăng con trỏ lên 1
            CPI     R16, 0      ; So sánh byte có dấu với số 0
            BRGE    CONT_CHECK  ; Nếu byte có dấu đó lớn hơn hoặc bằng 0, chuyển đến kiểm tra tiếp CONT_CHECK để kiểm tra lớn hơn hay không
            RJMP    INC_NEG     ; Nếu byte có dấu đó nhỏ hơn hoặc bằng 0, tăng bộ đếm số số âm
CONT_CHECK: CPI     R16, 0      ; Tiếp tục so sánh với 0
            BRNE    INC_POS     ; Nếu không bằng, có nghĩa byte đó lớn hơn không, chuyển tới tăng bộ đếm số dương
            RJMP    COUNTER     ; Nếu bằng 0, không tăng bộ đếm nào và chuyển tới COUNTER
INC_POS:    INC     COUNT_POS   ; Tăng bộ đếm số dương lên 1
            RJMP    COUNTER     ; Check counter
INC_NEG:    INC     COUNT_NEG   ; Tăng bộ đếm số âm lên 1
            RJMP    COUNTER     ; Check counter
COUNTER:    DEC     R20         ; Giảm bytes counter
            BRNE    LAP         ; Quay lại vòng lặp nếu bytes counter chưa bằng 0
            RJMP    OUTPUT
OUTPUT:     OUT     PORTC, COUNT_NEG    ; Xuất số số âm ra portC
            OUT     PORTD, COUNT_POS    ; Xuất số số dương ra portd
            RJMP    EXIT
EXIT:       RJMP    EXIT




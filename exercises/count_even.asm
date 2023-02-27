; Đếm số ô nhớ chứa giá trị chẵn có trong 100 ô nhớ SRAM có địa chỉ đầu là $100, kết quả cất vào ô nhớ SRAM có địa chỉ $FF


.ORG    0
LDI     YL, $00             ;Y_LOW = LOW($100)
LDI     YH, $01             ;Y_HIGH = HIGH($100)
LDI     R16, 100            ;Bộ đếm số ô nhớ
LDI     R17                 ;Bộ đếm số ô nhớ có giá trị chẵn

LAP:    LD      R18, Y+     ;Lấy nội dung của ô nhớ mà con trỏ hiện đang trỏ tới, sau đó con trỏ tăng lên 1
        SBRS    R18, 0      ;Xét bit thứ 0 của nội dung chứa trong thanh ghi R18 có bằng 1 hay không, nếu đúng thì bỏ lệnh kế
        INC     R17         ;Nếu sai (bit thứ 0 là 0) thì tăng R17 lên 1
        DEC     R16         ;Giảm R16 đi 1
        BRNE    LAP         ;Nếu R16 khác 0, quay lại LAP
        STS     $FF, R17     
;Viết chương trình tính tổng chuỗi ô nhớ SRAM bắt đầu từ địa chỉ 200H, biết rằng số ô nhớ SRAM là nội dung của ô nhớ SRAM có địa chỉ 1FFH (giả sử khác 0)
;Tổng tính được là một số 16 bit được cất vào cặp ô nhớ SRAM có địa chỉ là 1FDH và 1FEH (ô nhớ có địa chỉ cao chứa byte cao của tổng)


; Giải thuật
; SumH_SumL = 0
; Length = (1FFH)
; X_pointer --> (200H)
; LAP:
; SumL = SumL + (X_pointer)
; If Carry_flag = 1; SumH = SumH + 1
; Length = Length - 1
; If length > 0 LAP
; Store SumH --> 1FEH; SumL --> 1FDH


.ORG    0
LDI     R20, 0                  ;SumL = 0;
MOV     R21, R20                ;SumH = 0;
LDS     R19, $1FF               ;Nội dung của địa chỉ 1FF là số phần tử cần tính tổng
LDI     XL, LOW($200)           ;X_LOW = 00H
LDI     XH, HIGH($200)          ;X_HIGH = 02H
LAP:    LD      R16, X+         ;Lấy nội dung ô nhớ mà con trỏ X chỉ đến hiện tại, sau đó con trở tăng 1 đơn vị
        ADD     R20, R16        ;SumL = SumL + R16
        BRCC    CONT            ;Nếu cờ Carry = 0, tiếp tục
        INC     R21             ;Nếu cở Carry = 1, SumH = SumH + 1
CONT:   DEC     R19             ;Giảm số phần tử cần tính đi 1
        BRNE    LAP             ;Nếu R19 != 0, quay lại LAP
        STS     $1FD, R20       ;Lưu SumL
        STS     $1FE, R21       ;Lưu SumH
        ENDING  RJMP    ENDING 
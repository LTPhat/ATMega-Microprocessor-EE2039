; Cho 20 bytes nằm trong bộ nhớ SRAM bắt đầu từ địa chỉ $250. Viết chương trình xuất ra những byte chẵn ra port A


.ORG        0
LDI         R22, 20             ; Load bộ đếm
LDI         ZL, LOW($250)       ; Load byte thấp của địa chỉ bắt đầu
LDI         ZH, HIGH($250)      ; Load byte cao của địa chỉ bắt đầu
LOOP        LD  R16, Z+         ; Load byte mà con trỏ hiện trỏ tới, sau đó tăng con trỏ lên 1
SBRS        R16, 0              ; Nếu bit 0 của R16 bằng 1 (Số lẻ thì bỏ qua lệnh kế)
            RJMP    OUTPORT     ; Nếu bit 0 của R16 bằng 0 (Số chẵn)
CONT:       DEC     R22         ; Giảm bộ đếm
            BRNE    LOOP        ; Nếu bộ đếm chưa bằng 0, quay lại LOOP
            RJMP    EXIT
OUTPORT:    OUT     PORTA, R16
            RJMP    CONT
EXIT:       RJMP    EXIT        ; Kết thúc ctr
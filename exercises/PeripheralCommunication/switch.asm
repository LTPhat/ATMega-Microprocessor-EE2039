; Viết chương trình giao tiếp nút nhấn sao cho mỗi lần nhấn SW đèn LED D sẽ lần lượt sáng/ tối. 
; Chương trình có module chống rung SW

; Với MCU324 khi mới reset hệ thống, thanh ghi SP trỏ vào địa chỉ đỉnh 0x08FF. Tuy nhiên để mang tính tổng quát ta vẫn ghi các lệnh khởi động vùng Stack
; để khi áp dụng cho các MCU khác trong họ AVR có reset khởi động vùng Stack không phải ở đỉnh vẫn đúng!

; Sử dụng chương trình DELAY_10ms bằng vòng lặp sau khi nhấn nút nhấn để chống rung
; 1 MCU = 125 nS
; 10ms = 80000 MCU = (4.n).m => n = 250, m = 80




.INCLUDE    <M324PDEF.INC>              ; Import file định nghĩa các ký hiệu sử dụng cho MCU324P
.ORG        0
RJMP        MAIN                        ; Nhảy đến chương trình chính
.ORG        0X40                        ; Địa chỉ bắt đầu chương trình chính
MAIN        LDI     R16, HIGH(RAMEND)   ; Đưa stack lên vùng địa chỉ cao
            OUT     SPH, R16
            LDI     R16, LOW(RAMEND)    ; Vùng địa chỉ thấp của Stack
            OUT     SPL, R16
            CBI     DDRB, 0             ; Set bit 0 của thanh ghi DDRB bằng 0, hay set PB0 là ngõ vào của nút nhấn
            SBI     PORTB, 0            ; Set bit 0 của thanh ghi PORT B bằng 1, thiết lập điện trở kéo lên ở bit 0 của PORT B
            SBI     DDRC, 0             ; Set bit 0 của thanh ghi DDRC bằng 1, hay set PC0 là ngõ ra
            CBI     PORTC, 0            ; Set ngõ ra ban đầu tại PC0 bằng 0, đèn tối
WAIT:       SBIC    PINB, 0             ; PB0 nhận data cho vào PINB, nếu PB0 = 0 (có nút nhấn) thì bỏ qua lệnh kế
            RJMP    WAIT                ; Nếu không có nút nhấn, trở lại WAIT
            RCALL   DELAY_10ms          ; Nếu có nút nhấn, gọi chương trình con DELAY_10ms chống rung
            SBIC    PINB, 0             ; Đọc lại trạng thái nút nhấn tại PB0 sau khi delay 10ms
            RJMP    WAIT                ; Nếu PB = 1 (nút nhấn nhả) thì quay lại WAIT chờ nhấn nút
            LDI     R17, 1
            IN      R18, PORTC          ; Lấy trạng thái đèn hiện tại
            EOR     R18, R17            ; Lấy bù trạng thái đèn
            OUT     PORTC, R18          ; Xuất trạng thái đèn ra PC0 sau khi đảo
            RJMP    WAIT                ; Quay lại vòng lặp chờ nút nhấn
; Module DELAY_10ms
DELAY_10ms:
            LDI     R21, 80             ; Load m
            LOOP1:  LDI     R22, 250    ; Load n
            LOOP2:  DEC     R22         ; 1MC
                    NOP                 ; 1MC
                    BRNE    LOOP2       ; 2-1MC
                    DEC     R21         ; 1MC
                    BRNE    LOOP1       ; 2-1MC
                    RET                 ; 4MC


; CTC hiển thị 4 LED AC bằng pp quét
; Input: BCD_BUF+1 : BCD_BUF+4 chứa 4 digit BCD ngàn, trăm chục đơn vị
; Sử dụng CTC DELAY_1MS, GET_7SEG
.EQU  OUTPORT = PORTB  
.DEF  COUNT = R18
SCAN_4LA_1:
    LDI     COUNT, 4
    LDI     R19, 0xFE   ; Mã quét anode bắt đầu từ LED0
    LDI     XH, HIGH(BCD_BUF + 5)   ; X trở địa chỉ buffer sau hàng đơn vị
    LDI     XL, LOW(BCD_BUF + 5)
LOOP:
    LDI     R17, 0xFF   ; Xóa hiển thị LED
    OUT     OUTPORT, R17
    SBI     PORTC, 1    ; Mở chốt U3
    CBI     PORTC, 1    ; Đóng chốt U3
    LD      R17, -X     ; Giảm X, nạp số BCD từ buffer
    RCALL   GET_7SEG    ; Lấy mã 7 đoạn
    OUT     OUTPORT, R17 ; Xuất mã 7 đoạn
    SBI     PORTC, 0    ; Mở chốt U2
    CBI     PORTC, 0    ; Đóng chốt U2
    RCALL   DELAY_1MS   ; Tạo trễ 1ms sáng đèn
    SEC                 ; C = 1 chuẩn bị quay trái
    ROL     R19         ; Mã quét anode kế tiếp
    DEC     COUNT       ; Đếm số lần quét
    BRNE    LOOP        ; thoát khi quét đủ 4 lần
    RET
GET_7SEG:
    LDI     ZH, HIGH(TAB_7SA << 1)
    LDI     ZL, LOW(TAB_7SA << 1)
    ADD     R30, R17
    LDI     R17, 0
    ADC     R31, R17
    LPM     R17, Z
    RET
TABLE_7SA: 
	.DB 0XC0, 0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X8
	.DB 0XC6,0XA1,0X86,0X8E
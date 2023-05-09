; CTC CHUYỂN SỐ NHỊ PHÂN 16 BIT SANG SỐ BCD 
;****************************************************************************************
;INPUT: R21:R20 <-- SỐ NHỊ PHÂN 16 BIT
;OUTPUT:SỐ BCD 5 DIGIT(DECADE):
;BCD0-BCD4=$200-$204(SRAM)
;SỬ DỤNG CTC DIV16_8: SỐ CHIA = 10(R16)
.EQU BCD_BUF=0X200  ; Đổi giá trị địa chỉ ở đây
.DEF COUNT1=R18
;****************************************************************************************
BIN16_BCD:
LDI XH,HIGH(BCD_BUF);X trỏ địa chỉ đầu buffer BCD
LDI XL,LOW(BCD_BUF)
LDI COUNT1,5 ;đếm số byte bộ nhớ
LDI R17,0X00 ;nạp giá trị 0
LOOP_CL:
ST X+,R17 ;xóa buffer bộ nhớ
DEC COUNT1 ;đếm đủ 5 byte
BRNE LOOP_CL
LDI OPD2,10 ;nạp SC
DIV_NXT:
RCALL DIV16_8 ;chia số nhị phân 16 bit cho 10
ST -X,OPD3 ;cất số dư v{o buffer
CPI OPD1_L,0 ;thương số=0?
BRNE DIV_NXT ;khác 0 chia tiếp
RET
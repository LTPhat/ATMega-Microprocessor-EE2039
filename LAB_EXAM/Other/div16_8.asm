;DIV16_8 chia số nhị phân 16 bit OPD1 cho 8 bit OPD2
;****************************************************************************************
;Input: OPD1_H,OPD1_L= SBC(GPR16-31)
; OPD2=SC(GPR0-31)
;Output:OPD1_H,OPD1_L=thương số
; OPD3=DS(GPR0-31)
;Sử dụng COUNT(GPR16-31)


.DEF OPD1_L=R20
.DEF OPD1_H=R21
.DEF OPD2=R22
.DEF OPD3=R23
.DEF COUNT2=R19
;****************************************************************************************
DIV16_8: LDI COUNT2,16 ;COUNT=đếm 16
CLR OPD3 ;xóa dư số
SH_NXT: CLC ;C=0=bit thương số
LSL OPD1_L ;dịch tr|i SBC L,bit0=C=thương số
ROL OPD1_H ;quay trái SBC H,C=bit7
ROL OPD3 ;dịch bit7 SBC H v{o dư số
BRCS OV_C ;tr{n bit C=1,chia được
SUB OPD3,OPD2 ;trừ dư số với số chia
BRCC GT_TH ;C=0 chia được
ADD OPD3,OPD2 ;C=1 không chia được,không trừ
Một số CTC thường sử dụng cho Atmega324P- GV:Lê Thị Kim Anh Trang 3
RJMP NEXT
OV_C: SUB OPD3,OPD2 ;trừ dư số với số chia
GT_TH: SBR OPD1_L,1 ;chia được,thương số=1
NEXT: DEC COUNT2 ;đếm số lần dịch SBC
BRNE SH_NXT ;chưa đủ tiếp tục dịch bit
RET

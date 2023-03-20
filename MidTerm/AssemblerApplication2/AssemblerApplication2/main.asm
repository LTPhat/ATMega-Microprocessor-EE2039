; Chuyển số thập nhị phân 1 byte thành số BCD 3 chữ số


.ORG 0

LDS		R20, $200 ; load s? b? chia
LDI		R21, 10;  load s? chia
LDI		R22, 0;

; Lấy chữ số hàng đơn vị
FIRST:	INC		R22
		SUB		R20, R21
		BRCC	FIRST
		DEC		R22			;R22 là thương số
		ADD		R20, R21	;R20 là phần dư (chữ số hàng đơn vị)
		STS		$201, R20	
		MOV		R20, R22	; Sao chép R22 qua R20 tiếp tục chia
		CLR		R22
; Lấy chữ số hàng chục
SECOND:	INC		R22
		SUB		R20, R21
		BRCC	SECOND
		INC		R22
		DEC		R22			; R22 là chữ số hàng trăm
		ADD		R20, R21	; R21 là chữ số hàng chục
		STS		$202, R21
		STS		$203, R22

THIRD:	RJMP	THIRD	; End 
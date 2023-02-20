; Xóa 5 ô nhớ SRAM có địa chỉ từ 100H đến 104H

// Cach 1: Goi dia chi truc tiep

LDI		R16, 0
STS		$100, R16
STS		$101, R16
STS		$102, R16
STS		$103, R16
STS		$104, R16

// Cach 2: Dung con tro Y

LDI		R16, 0
LDI		YL, 0x00
LDI		YH, 0x01
STS		Y+, R16
STS		Y+, R16
STS		Y+, R16
STS		Y+, R16
STS		Y+, R16


// Cach 3: Dung vong lap

LDI		R16, 0; clear
LDI		R17, 5; counter
LDI		YL, 0x00
LDI		YH, 0x01
LAP:	ST		Y+, R16
		DEC		R17;
		BRNE	LAP

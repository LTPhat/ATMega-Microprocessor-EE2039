;a) L?y gi� tr? t? 2 nibble b?ng c�ch s? d?ng thanh ghi l�m MASK v?i c�c bit t?i v? tr� c?a nibble c?n l?y c� gi� tr? 1 v� th?c hi?n to�n t? AND gi?a thanh ghi MASK v?i PORTA.
;b) M� ngu?n:
ldi   R16, 0x00
out  DDRA, R16   ; port A nh?p
ldi   R16, 0xFF
out  DDRB, R16   ; port B xu?t
out  PORTA, R16 ; port A c� ?i?n tr? k�o l�n
loop:	in      R17, PINA     ; ??c d? li?u 8 bit t? port A
		COM		R17
		mov   R18, R17        ; sao ch�p R17 sang R18
		ldi   R16, 0xF0      ; kh?i t?o thanh ghi MASk
		and   R17, R16        ; l?y nibble cao l?u ? R17
		swap  R17
		swap  R16               ; ??o nibble R16
		and   R18, R16       ; l?y nibble th?p l?u ? R18
		mul   R17, R18        ; nh�n hai nibble, k?t qu? l?u l� s? 8bit l?u ? R0
		mov   R16, R0          ; L?y R16 l?u k?t qu? 
		out    PORTB, R16  ; Xu?t k?t qu? ra port B
		rjmp  loop

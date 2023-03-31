;a) L?y giá tr? t? 2 nibble b?ng cách s? d?ng thanh ghi làm MASK v?i các bit t?i v? trí c?a nibble c?n l?y có giá tr? 1 và th?c hi?n toán t? AND gi?a thanh ghi MASK v?i PORTA.
;b) Mã ngu?n:
ldi   R16, 0x00
out  DDRA, R16   ; port A nh?p
ldi   R16, 0xFF
out  DDRB, R16   ; port B xu?t
out  PORTA, R16 ; port A có ?i?n tr? kéo lên
loop:	in      R17, PINA     ; ??c d? li?u 8 bit t? port A
		COM		R17
		mov   R18, R17        ; sao chép R17 sang R18
		ldi   R16, 0xF0      ; kh?i t?o thanh ghi MASk
		and   R17, R16        ; l?y nibble cao l?u ? R17
		swap  R17
		swap  R16               ; ??o nibble R16
		and   R18, R16       ; l?y nibble th?p l?u ? R18
		mul   R17, R18        ; nhân hai nibble, k?t qu? l?u là s? 8bit l?u ? R0
		mov   R16, R0          ; L?y R16 l?u k?t qu? 
		out    PORTB, R16  ; Xu?t k?t qu? ra port B
		rjmp  loop

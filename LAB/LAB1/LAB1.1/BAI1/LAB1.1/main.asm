;a) L?y giá tr? t? 2 nibble b?ng cách s? d?ng thanh ghi làm MASK v?i các bit t?i v? trí c?a nibble c?n l?y có giá tr? 1 và th?c hi?n toán t? AND gi?a thanh ghi MASK v?i PORTA.
;VD: L?y nibble cao c?a port A l?u vào r17
;ldi  r16, 0xFF  ; Set DDR A to input 
;out DDRA, r16
;ldi  r17, 0xF0
;ldi  r16, PINA
;and  r17, portA
;b) Enable ?i?n tr? pullup b?ng cách cho xu?t giá tr? 1 ra các chân c?a PORTA.
;c) Do s? d?ng ?i?n tr? kéo lên, khi Switch ? tr?ng thái ON/OFF, giá tr? chân Port b?ng 1/0.
;d) Khi chân port ? tr?ng thái 1, BARLED sáng.
;e) Mã ngu?n ch??ng trình:
	ldi   R16, 0xFF  
	out  DDRB, R16 ; port B xu?t
	ldi   R16, 0x00 ; 
	out   DDRA, R16 ; port A nh?p
	ldi    R16, 0xFF  
	out   PORTA, R16; port A có ?i?n tr? kéo lên
	loop:  in r16, PINA  ; ??c bit t? portA ; 
	com    r16
	out    PORTB, r16 ; Xu?t ra port B 
	rjmp loop ; Quay l?i vòng l?p


;a) L?y gi� tr? t? 2 nibble b?ng c�ch s? d?ng thanh ghi l�m MASK v?i c�c bit t?i v? tr� c?a nibble c?n l?y c� gi� tr? 1 v� th?c hi?n to�n t? AND gi?a thanh ghi MASK v?i PORTA.
;VD: L?y nibble cao c?a port A l?u v�o r17
;ldi  r16, 0xFF  ; Set DDR A to input 
;out DDRA, r16
;ldi  r17, 0xF0
;ldi  r16, PINA
;and  r17, portA
;b) Enable ?i?n tr? pullup b?ng c�ch cho xu?t gi� tr? 1 ra c�c ch�n c?a PORTA.
;c) Do s? d?ng ?i?n tr? k�o l�n, khi Switch ? tr?ng th�i ON/OFF, gi� tr? ch�n Port b?ng 1/0.
;d) Khi ch�n port ? tr?ng th�i 1, BARLED s�ng.
;e) M� ngu?n ch??ng tr�nh:
	ldi   R16, 0xFF  
	out  DDRB, R16 ; port B xu?t
	ldi   R16, 0x00 ; 
	out   DDRA, R16 ; port A nh?p
	ldi    R16, 0xFF  
	out   PORTA, R16; port A c� ?i?n tr? k�o l�n
	loop:  in r16, PINA  ; ??c bit t? portA ; 
	com    r16
	out    PORTB, r16 ; Xu?t ra port B 
	rjmp loop ; Quay l?i v�ng l?p


;d.	Theo nh? datasheet c?a 74HC595, t?n s? clock cao nh?t mà nó có th? ho?t ??ng ???c là bao nhiêu
;- Theo datasheet, t?n s? clock cao nh?t mà 74HC595 có th? ho?t ??ng ???c là 31MHz ? nhi?t ?? 25? khi Vcc = 6V.
;e.	N?u mu?n m? r?ng hi?n th? ra 16 LED thì ta ph?i làm nh? th? nào?
;- N?u mu?n m? r?ng hi?n th? ra 16 LED thì ta n?i thêm m?t IC d?ch vào, pin DS c?a IC d?ch th? 2 n?i v?i pin Q7’ c?a IC d?ch th?
;f.	Mã ngu?n v?i chú thích
.def shiftData = r20 ; Define the shift data register
.equ clearSignalPort = PORTB ; Set clear signal port to PORTB
.equ clearSignalPin = 3 ; Set clear signal pin to pin 0 of PORTB
.equ shiftClockPort = PORTB ; Set shift clock port to PORTB
.equ shiftClockPin = 2 ; Set shift clock pin to pin 1 of PORTB
.equ latchPort = PORTB ; Set latch port to PORTB
.equ latchPin = 1 ; Set latch pin to pin 0 of PORTB
.equ shiftDataPort = PORTB ; Set shift data port to PORTB
.equ shiftDataPin = 0 ; Set shift data pin to pin 3 of PORTB
main:
call initport
ldi shiftData,0x55
call cleardata
recall:
call shiftoutdata
rjmp recall
; Initialize ports as outputs
initport:
ldi r24, (1<<clearSignalPin)|(1<<shiftClockPin)|(1<<latchPin)|(1<<shiftDataPin) 
out DDRB, r24 ; Set DDRB to output
ret
ldi shiftData,0x55
cleardata:
cbi clearSignalPort, clearSignalPin ; Set clear signal pin to low 
; Wait for a short time
sbi clearSignalPort, clearSignalPin ; Set clear signal pin to high
ret
; Shift out data
shiftoutdata:
cbi shiftClockPort, shiftClockPin
ldi r18, 8
ldi r17, 8
sbi shiftDataPort, shiftDataPin ; Set shift data pin to high
shift_on:
sbi shiftClockPort, shiftClockPin ; Set shift clock pin to high
cbi shiftClockPort, shiftClockPin ; Set shift clock pin to low
dec r18
breq begin_shift_off
call DELAY_500MS
sbi latchPort, latchPin ; Set latch pin to high
cbi latchPort, latchPin ; Set latch pin to low
rjmp shift_on
begin_shift_off:
cbi shiftDataPort, shiftDataPin ; Set shift data pin to low
shift_off:
sbi shiftClockPort, shiftClockPin ; Set shift clock pin to high
cbi shiftClockPort, shiftClockPin ; Set shift clock pin to low
dec r17
breq Retired
call DELAY_500MS
sbi latchPort, latchPin ; Set latch pin to high
cbi latchPort, latchPin ; Set latch pin to low
rjmp shift_off
Retired:
ret
DELAY_500MS:	
ldi R16, 50
LOOP3:
ldi R17, 80
LOOP1:
ldi R18, 250
LOOP2:
dec R18 
nop
brne LOOP2
dec R17
brne LOOP1
dec R16
brne LOOP3
ret

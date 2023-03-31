.include "m328pdef.inc" ; Define Atmega file 
.def temp = r18 ; Define a temporary register 
.def count = r16 ; Define count variable
.org 0x0000 ; 

;Define stack pointer
ldi temp, LOW(RAMEND) ; Initialize the stack pointer 
out SPL, temp 
ldi temp, HIGH(RAMEND)
out SPH, temp 

;Define LCD 
ldi temp, 0x38 ; Function set: 8-bit interface, 2 lines, 5x7 dots 
call lcd_send_command 
ldi temp, 0x0C ; Display on, cursor off, blink off 
call lcd_send_command
ldi temp, 0x01 ; Clear display 
call lcd_send_command

; Define input-output
cbi DDRA, 0 ; Set Swich input is PA0
sbi PORTA, 0; Pull-up resistor for PA0
ldi  temp, 0XFF
out DDRB, temp : Port B  Barleds (Output)
out DDRC, temp : Port C  LCD (Output)
loop:
sbic  PORTA, 0     ; Check if PA0 = 0 (Switch pressed)
rjmp loop              ; if not, come back to loop
rcall DELAY_10ms
sbic  PORTA, 0    ; Check if PA0 = 0 again 
rjmp loop              ; if PA0=1, come back loop
inc count               ; If yes, increment count
out PORTB, count ; Output count to bar LEDs
call lcd_send_data ; sent count to LCD
rjmp loop
; module DELAY_10ms
DELAY_10ms: 
LDI     R21, 80             
LOOP1:  LDI     R22, 250    
LOOP2:  DEC     R22        
        NOP                 
        BRNE    LOOP2      
        DEC     R21         
        BRNE    LOOP1        
        RET                 
; module lcd_send_command (command code in r18)
lcd_send_command:
push r17 
call LCD_wait_busy ; check if LCD is busy 
mov r17,r18 ;save the command 
; Set RS low to select command register 
; Set RW low to write to LCD 
andi r17,0xF0 ; Send command to LCD 
out LCDPORT, r17 
nop 
nop 
; Pulse enable pin 
sbi LCDPORT, LCD_EN 
nop 
nop 
cbi LCDPORT, LCD_EN 
swap r18 andi r18,0xF0 ; Send command to LCD
out LCDPORT, r18 
; Pulse enable pin 
sbi LCDPORT, LCD_EN 
nop 
nop 
cbi LCDPORT, LCD_EN 
pop r17 
ret

LCD_wait_busy:
LCD_wait_busy:
push r18 
ldi r18, 0b00000111 ; set PA7-PA4 as input, PA2-PA0 as output 
out LCDPORTDIR, r18 
ldi r18,0b11110010 
; set RS=0, RW=1 for read the busy flag 
out LCDPORT, r18
nop 

LCD_wait_busy_loop:
sbi LCDPORT, LCD_EN 
nop 
nop 
in r18, LCDPORTPIN 
cbi LCDPORT, LCD_EN 
nop 
sbi LCDPORT, LCD_EN
nop 
nop cbi LCDPORT, LCD_EN 
nop 
andi r18,0x80 
cpi r16=8,0x80 
breq LCD_wait_busy_loop 
ldi r18, 0b11110111 ; set PA7-PA4 as output, PA2-PA0 as output out LCDPORTDIR, r18 
ldi r18,0b00000000 
; set RS=0, RW=1 for read the busy flag 
out LCDPORT, r16 
pop r16 
ret

;module lcd_send_data (data is r16-count)
lcd_send_data:
push r17 call LCD_wait_busy ;check if LCD is busy 
mov r17,r16 ;save the command 

; Set RS high to select data register 
; Set RW low to write to LCD 
andi r17,0xF0 
ori r17,0x01 

; Send data to LCD
out LCDPORT, r17 
nop 
; Pulse enable pin 
sbi LCDPORT, LCD_EN 
nop 
cbi LCDPORT, LCD_EN 
; Delay for command execution ;send the lower nibble 
nop 
swap r16 
andi r16,0xF0 
; Set RS high to select data register 
; Set RW low to write to LCD 
andi r16,0xF0 
ori r16,0x01 
; Send command to LCD 
out LCDPORT, r16 
nop 
; Pulse enable pin 
sbi LCDPORT, LCD_EN 
nop 
cbi LCDPORT, LCD_EN 
pop r17 
ret

 /*
 * Assembler_g.asm
 *
 *  Created: 18.06.2015 13:09:22
 *   Author: Sheraz Azad, Heiko Pantermehl und Sven Marquardt
 */ 

 .include "m644PAdef.inc"

 .equ A = 1					; Lampe A
 .equ Timer = 5

 .cseg						; Hier beginnt der Programmcode
		
 start:
		ser R16				;R16 = 0xFF
		ser R17
		ser R18
		out DDRA, R16		;PORTA als Ausgabe konfigurieren
		ldi R16, A			;initialisieren		
		ldi R18, 0
		
outer:
		ldi R17, Timer
		out PORTA, R16		;Lampe A ausgeben
		inc R16				;A = A + 1

inner:
		dec R17
		cp R17, R18
		breq outer2
		jmp inner

outer2:
		ldi R17, Timer
		out PORTA, R16		
		dec	R16				;A = A - 1

inner2:
		dec R17
		cp R17, R18
		breq outer
		jmp inner2
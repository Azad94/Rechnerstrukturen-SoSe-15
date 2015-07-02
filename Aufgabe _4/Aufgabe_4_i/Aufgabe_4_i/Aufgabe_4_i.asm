/*
 *  Aufgabe_4_h.asm
 *
 *  Created: 24.06.2015 13:43:11
 *  Author: Sheraz Azad, Sven Marquardt  und Heiko Pantermehl
 *  Quelle: http://www.grzesina.de/avr/ports/ports.html
 */ 
 
.include "m644PAdef.inc"	; device: ATmega 644PA

	.cseg			; dies ist Code
	
	.equ muster_1 = 0x06		;Bits die beim ersten Muster angehen
	.equ muster_2 = 0x09		;Bits die beim zweiten Muster angehen

	ser R16						
	ldi R16, 0x3F				;Ausgabe definieren
	out DDRD, R16	

	ldi R18, muster_1			
	out PORTD, R18				;"Standard"-Ausgabe 

				; ********** HAUPTPROGRAMM **********
start:
	;--- Taster überprüfen (bedingt jeweiliges Muster ausgeben)

	SBIC PIND, 6				
	jmp Taster_1_gedrueckt

	SBIC PIND, 7				
	jmp Taster_2_gedrueckt

	jmp start

Taster_1_gedrueckt:

	ldi R18, muster_2
	out PORTD, R18
	jmp start

Taster_2_gedrueckt:

	ldi R18, muster_1
	out PORTD, R18
	jmp start
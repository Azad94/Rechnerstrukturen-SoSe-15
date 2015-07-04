/*
 * interruptWithIOHandling.asm
 *
 *  Created: 03.07.2015 22:31:06
 *   Author: Sven
 */ 
 ;Die meisten Infos hab ich von hier http://www.mikrocontroller.net/articles/AVR-Tutorial:_Interrupts
 ;dieses Programm soll verdeutlichen wie in Interrupt mit einer IO zu händeln ist
 ;Wichtig zu befolgen ist ein Interrupt sollte so schnell wie möglich beendet werden es kann sonst zu einem Stau der Interrupts führen
 ;Dadurch könnten Interrupts verloren gehen oder schimmeres
 ;reti wird deshalb benutzt weil ansonsten jedes Interrupt weitere Interrupt sperrt dies wird duch reti verhindert
 ;rjmp vielleicht nciht nötig nur bei 4byte registern AUSPROBIEREN!!
	.include  "m644PAdef.inc"
	.org 0x000					;Steht für Reset und bedeutet start der Hardware alles wurde zurückgesetzt und programm fängt am kleinsten Bit(LBI) wieder an 
		rjmp main
	.org INT0addr				;Steht auch für einen festen bit wie im reset kann allerdings von Mikrocontroller zu Mikrocontroller variieren deswegen lieber die 
		rjmp int0_handler		;begiffe verwenden das macht es leichter dieses Programm auf ander Mikrocontroller zu porten da diese begriffe durch die eingebudene Header datei 
								;definiert sind
	.org OC1Aaddr
		rjmp OCR1A_isr
	.org 3*INT_VECTORS_SIZE
	.cseg
/********************************************************/
	; ISR Timer1 Compare Interrupt A
	OCR1A_isr:
	push r16 ; Kontext retten
	; Code der ISR weggelassen
	pop r16 ; Register restaurierten
	reti ; Return from Interrupt

/********************************************************/


/********************************************************/
;	ISR External Interrupt 0: INT0 
int0_handler:	
	push r16
	push r17
	ldi r17,0xFF			; Wert für Toggeln von Bit0
	out PORTD, r17			; Neuen Wert ausgeben
	pop r17					; Register restaurierten
	pop r16					; Register restaurierten
	reti					; Return from Interrupt;
;

/********************************************************/
; ----- Initialisierung des INT0 auf änderung -----
InitINT0:
	push r16
	push r17
	ldi r17,0x02			; Wert für (ISC01,ISC00) einstellung für rückflanke da unsere taster immer eins haben genau das was wir haben wollen
	lds r16, EICRA			; Config EICRA in laden wichtig um die änderungen beobachten zu können im io View auf den EXTERNAL_INTERRUPT schalten dort sieht man dann die isc0 bis 2 
	or r16,r17				; ISC01 in EICRA setzen
	sts EICRA, r16			; und nach EICRA speichern
	sbi EIMSK, 0			; Nur INT0 starten
	pop r17
	pop r16
	ret
/********************************************************/

/*******************************************************/
/*Hauptprogramm hier wird der Stack initalisiert und anschließend die Ausgabe der Ampel 
bewerkstelligt. Hierhin springt das programm bei reset als erstes*/
main:
; ----- Initialisierung der grundlegenden Funktionen -----
; Initialisieren des Stacks am oberen Ende des RAM
; 16 bit SP wird als SPH:SPL im IO-Space angesprochen
	ldi r16, LOW(RAMEND) ; low-Byte von RAMEND nach r16
	out SPL, r16 ; in low-byte des SP ausgeben
; der SP liegt im IO-Space
	ldi r16, HIGH(RAMEND) ; high-Byte von RAMEND nach r16
	out SPH, r16 ; in high-byte des SP ausgeben
; ab hier kann der Stack verwendet werden
	call InitINT0 ; INT0 initialisieren
	sei
	ldi R17, 0x03
	out DDRD, R17
stay:
	sbi PortD, 1
	nop
	cbi PORTD, 1
	nop
	jmp stay
/*******************************************************/	
/*
 * INT0Demo.asm
 *
 *  Created: 28.12.2012 21:33:59
 *   Author: Ole
 */ 
.include "m644PAdef.inc"	; device: ATmega 644PA
	.cseg			; dies ist Code
; ----- Am Beginn des Codespeichers liegt die Vektortabelle -----
;		Hier nur Sprungtabelle anlegen. Mindestens für den 
;		Reset-Interrupt (An Adresse 0):
	.org	0		; Am Anfang des Code-Speicher 
	jmp start		; Sprung bei reset
	.org INT0addr	; Ext. INT0 Interrupt
	jmp INT0_isr	; Ext. INT0 Interrupt
; ----- Programm beginnt hinter der Vektortabelle: -----
	.org 2*INT_VECTORS_SIZE
; hier kommen die Interrupt Service Routinen hin, wenn benutzt
/********************************************************/
;	ISR External Interrupt 0: INT0 
INT0_isr:	
	push r16
	push r17
	ldi r17,0x01			; Wert für Toggeln von Bit0
	in r16, PORTD			; PORT-wert lesen
	eor r16,r17				; XOR PORTD xor 1 --> toggle
	out PORTD, r16			; Neuen Wert ausgeben
	pop r17					; Register restaurierten
	pop r16					; Register restaurierten
	reti					; Return from Interrupt;
;


; ----- Initialisierung des INT0 auf Rueckflanke -----
InitINT0:
	push r16
	push r17
	ldi r17,0x02			; Wert für (ISC01,ISC00)
	lds r16, EICRA			; Config EICRA in laden
	or r16,r17				; ISC01 in EICRA setzen
	sts EICRA, r16			; und nach EICRA speichern
	sbi EIMSK, 0			; Nur INT0 starten
	pop r17
	pop r16
	ret



; ***** Einsprungpunkt in das Hauptprogramm *****
start:
; ----- Initialisierung der grundlegenden Funktionen -----
	; Initialisieren des Stacks am oberen Ende des RAM
    ; 16 bit SP wird als SPH:SPL im IO-Space angesprochen 
    ldi r16, LOW(RAMEND)	; low-Byte von RAMEND nach r16
    out SPL, r16	; in low-byte des SP ausgeben
					; der SP liegt im IO-Space 
    ldi r16, HIGH(RAMEND)	; high-Byte von RAMEND nach r16
    out SPH, r16		; in high-byte des SP ausgeben
    ; ab hier kann der Stack verwendet werden 

	call InitINT0		; INT0 initialisieren
	sei					; global Interrupt enable
	; testroutine: PortD konfigurieren
	ldi r17, 0x03		; PortD [1..0] als Ausgabe
	out DDRD, r17		; PortD als Ausgabe
stay:
	jmp stay			; Endlosschleife
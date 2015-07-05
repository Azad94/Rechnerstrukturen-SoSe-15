/*
 * INT0Demo.asm
 *
 *  Created: 28.12.2012 21:33:59
 *   Author: Ole
 */ 
.include "m644PAdef.inc"	; device: ATmega 644PA
; ----- Am Beginn des Codespeichers liegt die Vektortabelle -----
;		Hier nur Sprungtabelle anlegen. Mindestens für den 
;		Reset-Interrupt (An Adresse 0):
	.org	0		; Am Anfang des Code-Speicher 
	jmp start		; Sprung bei reset
	.org $0008		;External Pin wurden angesprochen heißt PINA(7..0)
	jmp PCINT0_isr
	.org OC1Aaddr
	jmp OCRA1A_isr
; ***** Hier werden die "Variablen" definiert
	.dseg				; dies sind Daten
T1count:		.byte 1		; Zähler für Wartefunktion mit Timer1
Nachtmodus:		.byte 1		;Nachtmodus
Bereitschaft:	.byte 1		;Bereitschaft 
Zustand:		.byte 1		;Welchen Zustand bestizen wir für die Bereitschaft
	.cseg			; dies ist Code
; ----- Platz um .equ definitionen vorzunehmen
#ifdef DEBUG 
.equ	T1Counter = 10			; Debug-Timer-Wert für xxs
#else
.equ	T1Counter = 98			; Timer-Wert für 0,1s
#endif
.equ Timer=5						; Zeit zum warten 0.,5s
; ----- Programm beginnt hinter der Vektortabelle: -----
	.org 4*INT_VECTORS_SIZE
; hier kommen die Interrupt Service Routinen hin, wenn benutzt
/********************************************************/
;	ISR External Interrupt 0: PCINT0 
PCINT0_isr:	
	push r16				;
	sbis PINA,5
	ldi Nachtmodus, 0x01	;Nachtmodus an
	sbis PINA,6
	ldi Nachtmodus, 0x00	;Nachtmodus aus
	sbis PINA,7
	call BereitschaftPruefen	;Bereitschaft an
	pop r16					; Register restaurierten
	reti					; Return from Interrupt;
;


BereitschaftPruefen:
	push R16
	push R17
	push R18
	ldi R16, Zustand
	ldi R17, 0x05
	ldi R18, 0x01
	cp	R16,R18
	brge BereitschaftAn
	cpi R16,R17
	brge BereitschaftAn
	pop R18
	pop R17
	pop R16
	ret
BereitschaftAn:
	ldi Bereitschaft, 0x01
	ret


/********************************************************/
;	ISR Timer1 Compare Interrupt A
OCRA1A_isr:
	push r16				; Register auf den Stack retten
    in   r16, SREG			; Statusregister zum Sichern nach R16
	push r16				; und auf den Stack
	lds r16, T1count		; Zählwert lesen
	tst r16					; schon Null?
	breq noDec				; ja: nichts weiter Abziehen
	dec r16					; T1count--
	sts T1count, r16		; und abspeichern
noDec:
    pop r16					; die Statusregister von Stack holen
	out SREG, r16			; und wieder herstellen
	pop r16					; Register restaurierten
	reti					; Return from Interrupt;
;

; ----- Initialisierung des PCINT0-----
InitPCINT0:
	push r16
	push r17
	ldi R16 , 0x01	; Setze Die PINA(7..0) als external Interrupt
	sts PCICR, R16
	ldi R16, 0xE0
	sts PCMSK0, R16
	pop r17
	pop r16
	ret
;

; ----- Initialisierung von Timer1 auf 0,1s Periode -----
InitTImer1:
	; beim 644PA sind Timer1-Register Memory.mapped
	push r17
	ldi r17, HIGH(T1Counter)	; Timer-Schwelle 
	sts OCR1AH, r17				; byte-weise 
	ldi r17, LOW(T1Counter)		; nach OCR1A
	sts OCR1AL, r17
	clr r17					; r17=0 
	sts TCNT1H, r17			; Counter=0
	sts TCNT1L, r17
	sts TCCR1A, r17			; configure to CTC-Mode	
#ifdef DEBUG 
	ldi r17, 0b0001010		; CTC-mode, prescaler 8 für DEBUG 
#else 
	ldi r17, 0b0001101		; CTC-mode, prescaler 1024 
#endif
	sts TCCR1B, r17				
	; und den OC1A intrerrupt einschalten:
	lds r17, TIMSK1			; Interruptmaske Timer1 
	ori r17, 0b00000010		; OCIE1A setzen
	sts TIMSK1, r17			; und abspeichern
	pop r17
	ret
;
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

	call InitPCINT0		; PCINT0 auf PIINA 5,6,7 initialisieren
	call InitTimer1		; Timer1 initalisieren
	sei					; global Interrupt enable
	ldi Nachtmodus, 0x01
	
stay:
	jmp stay			; Endlosschleife
/*
 * Aufgabe_i.asm
 *
 *  Created: 30.06.2015 19:48:28
 *   Author: Sven
 */ 
 .include "m644PAdef.inc"
 .cseg
 ;Nur ein Test sollte aber mit unseren alten aufgabe funktionieren
 ; Initialisierungscode weggelassen
ldi r16, 0xFF
         out DDRB, r16     ; Alle Pins am Port B durch Ausgabe von 0xFF ins
                           ; Richtungsregister DDRB als Ausgang konfigurieren
         ldi r16, 0x00
         out DDRD, r16     ; Alle Pins am Port D durch Ausgabe von 0x00 ins
                           ; Richtungsregister DDRD als Eingang konfigurieren
 
         ldi r16, 0xE0     ; An allen Pins vom Port D die Pullup-Widerstände
         out PORTD, r16    ; aktivieren. Dies geht deshalb durch eine Ausgabe
                           ; nach PORTD, da ja der Port auf Eingang gestellt ist.
loop:
         in r16, PIND      ; an Port D anliegende Werte (Taster) nach r16 einlesen
         out PORTB, r16    ; Inhalt von r16 an Port B ausgeben
         rjmp loop         ;  zu "loop:" -> Endlosschleife

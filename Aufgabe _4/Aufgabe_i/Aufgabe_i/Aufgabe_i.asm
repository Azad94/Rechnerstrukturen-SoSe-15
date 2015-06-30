/*
 * Aufgabe_i.asm
 *
 *  Created: 30.06.2015 19:48:28
 *   Author: Sven
 */ 

 ;Nur ein Test sollte aber mit unseren alten aufgabe funktionieren
 ; Initialisierungscode weggelassen
push r20 ; r20 auf den Stack retten
ser r20 ; r20=0xFF
out DDRD, r20 ; PortD als Ausgang verwenden
ldi r20, 0x55 ; Warte-Anzeige definieren
out PORTD, r20 ; und ausgeben
waitkey:
nop
sbis PINA,4 ; Verlasse Schleife, wenn [ENTER] gedrückt
jmp waitkey ; sonst springe zum Schleifenanfang
ser r20 ; flag Ende
out PORTD, r20 ; und ausgeben
pop r20 ; Restaurieren des Zählregisters
stay:
jmp stay 


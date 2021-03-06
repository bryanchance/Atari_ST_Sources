DEFINITION MODULE GEMDOSIO;

(*
 * Konfiguriert den gesamten TOS-Bildschirm als Ausgabemedium f�r die
 * Funktionen aus 'InOut'.
 *
 * Die Ein-/Ausgaben erfolgen durch Verwendung des 'Console'-Moduls
 * �ber die GEMDOS-Routinen, soda� Datei-Umlenkungen, z.B. durch eine
 * Command-Shell, m�glich sind. Allerdings k�nnen hiermit getriebene
 * InOut-Aufrufe durch Dr�cken von <Control-C> jederzeit zum Programm-
 * abbruch f�hren.
 *
 * Achtung: Wird dieses Modul statt 'GEMIO' eingebunden, d�rfen keine
 * GEM-Funktionen verwendet werden !
 *
 * Das gelinkte Programm sollte als Dateiendung 'TOS' oder 'TTP' statt 'PRG'
 * erhalten.
 *
 * Sollen die InOut-Ausgaben eines Programms auch unter der Shell �ber
 * den TOS-Bildschirm gehen, so ist dies Modul dort direkt vor (!)
 * dem InOut-Modul zu importieren. Desweiteren ist die Endung des Moduls
 * durch Verwendung der $E-Compileroption auf "MOS" einzustellen.
 *
 * Beispiel:
 *
 *   MODULE Test; (*$E MOS *)
 *     IMPORT GEMDOSIO;
 *     FROM InOut IMPORT Write, Read, WriteString;
 *   ... usw.
 *)

END GEMDOSIO.

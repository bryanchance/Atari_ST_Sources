MODULE VT52Test;

(*
 * Test-Programm f�r VT52-Modul
 *
 * Achtung: Unbedingt die Return-Taste und nicht die Space-Taste dr�cken,
 *  weil sonst durch den "Read"-Aufruf Leerzeichen ausgegeben werden und
 *  das evtl. zu Verwunderung f�hrt!
 *)

FROM VT52 IMPORT GetGotoRowColSeq, Seq, Codes;

FROM InOut IMPORT Write, WriteLn, WriteString, Read;

VAR i: CARDINAL;

PROCEDURE WriteVT52 (c: Codes);
  BEGIN
    WriteString (Seq [c])
  END WriteVT52;

PROCEDURE GotoRowCol (row, col: CARDINAL);
  VAR s: ARRAY [0..4] OF CHAR;
  BEGIN
    GetGotoRowColSeq (row, col, s);
    WriteString (s)
  (* Beim H�nisch- und Megamax-Modula kann auch folgendes geschrieben werden:
    WriteString ( GotoRowColSeq (row, col) )
  *)
  END GotoRowCol;

PROCEDURE wait;
  VAR ch: CHAR;
  BEGIN
    (*
      WriteVT52 (cursorOn);
    *)
    Read (ch);
    (*
      WriteVT52 (cursorOff);
    *)
  END wait;

BEGIN
  (*
    WriteVT52 (cursorOff);
  *)
  WriteLn;
  WriteString ('Dr�cke nach einer Ausgabe mit "..." am Ende immer eine Taste!');
  WriteLn;
  WriteLn;
  WriteString ('Bildschirm wird gel�scht...');
  wait;
  WriteVT52 (clearScreen);
  WriteLn;
  WriteLn;
  WriteVT52 (saveRowCol);
  WriteString ('Hier folgt ein gro�es "V": ');
  Write ('\');
  WriteVT52 (down);
  Write ('\');
  WriteVT52 (right);
  WriteVT52 (right);
  Write ('/');
  WriteVT52 (down);
  WriteVT52 (left);
  WriteVT52 (left);
  WriteVT52 (left);
  WriteString ('\/');
  WriteVT52 (up);
  WriteVT52 (up);
  WriteVT52 (right);
  Write ('/');
  WriteVT52 (restoreRowCol);
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn;
  WriteString ('Oben wird eine neue Zeile eingef�gt...');
  wait;
  WriteVT52 (home);
  WriteVT52 (moveUp);
  WriteString ('Hier ist die eingef�gte Zeile. Und nun nochmal dasselbe...');
  wait;
  WriteVT52 (home);
  WriteVT52 (insertLine);
  WriteString ('Diese Zeile wurde ganz oben eingef�gt und nun wieder entfernt...');
  wait;
  WriteVT52 (deleteLine);
  wait;
  WriteLn;
  WriteVT52 (insertLine);
  WriteString ('Diese Zeile wurde darunter eingef�gt und nun wieder entfernt...');
  wait;
  WriteVT52 (deleteLine);
  GotoRowCol (12, 0);
  WriteString ('Das war fein...');
  wait;
  WriteVT52 (clearLine);
  GotoRowCol (24, 0);
  WriteString ('Dies steht nun ganz unten...');
  wait;
  WriteVT52 (down);      (* darf nicht scrollen *)
  WriteVT52 (down);      (* darf nicht scrollen *)
  WriteVT52 (moveDown);  (* mu� scrollen *)
  WriteVT52 (firstCol);
  WriteString ('Jetzt nicht mehr...');
  wait;
  GotoRowCol (15, 0);
  WriteString ('Das verschwindet gleich ->');
  WriteVT52 (saveRowCol);
  WriteString (' M�ll M�ll M�ll...');
  wait;
  WriteVT52 (restoreRowCol);
  WriteVT52 (clearEOL);
  WriteLn;
  WriteString ('M�ll M�ll <- Das mu� auch weg...');
  wait;
  WriteVT52 (firstCol);
  FOR i:= 1 TO 9 DO WriteVT52 (right) END;
  WriteVT52 (clearBOL);
  WriteVT52 (down);
  WriteString ('Nun wird alles vor dieser Zeile gel�scht...');
  wait;
  WriteVT52 (firstCol);
  WriteVT52 (clearBOS);
  WriteLn;
  WriteString ('Und jetzt alles hiernach...');
  wait;
  WriteVT52 (clearEOS);
  WriteLn;
  WriteLn;
  WriteString ('Die ');
  WriteVT52 (reverseOn);
  WriteString ('Mitte');
  WriteVT52 (reverseOff);
  WriteString (' ist invers...');
  WriteLn;
  WriteLn;
  WriteString ('Und das ist das Ende...');
  wait;
END VT52Test.

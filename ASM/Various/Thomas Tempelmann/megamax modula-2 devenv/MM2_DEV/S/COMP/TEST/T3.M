MODULE T3; (*$M+, E MOS, X+ *)

IMPORT RandomGen;
FROM SYSTEM IMPORT ASSEMBLER;
(*
IMPORT MathLib0;
*)
IMPORT TOSIO;
FROM InOut IMPORT WriteLn, WriteString, WriteReal, WriteCard;

TYPE x = (sdfcgjsdlgjdlgsjdlg, dfgkjdgljdgdfgdfgdsgdfg,
          sdklsjfklsjkefjsefkljefikplf, skefjlwefjlvjslferv,
          kdfjdlgjwkjwejwugijwegjlks, sdfgjsfljsdflksfjlsfcjsfksfjlk,
          sdfkjsflkjfslfjsljsfklsfjlskfs, sjfwefgzhbwzegfjhfg);

(*$L-*)
PROCEDURE eiei;
  BEGIN
    
  END eiei;

PROCEDURE eio23;
  BEGIN
    eiei
  END eio23;

TYPE Str10 = ARRAY [0..1] OF CHAR;

PROCEDURE wr (s,s2: Str10); END wr;

VAR a,b:LONGREAL; c: CARDINAL; ar: ARRAY [0..0] OF CARDINAL;

VAR r: ARRAY [0..1] OF RECORD a,b: CARDINAL END;

PROCEDURE tc;
  VAR i: CARDINAL;
  BEGIN
    FOR i:= 0 TO 1000 DO
      WriteCard (RandomGen.Rnd () DIV 8 MOD 2,2);
    END
  END tc;

BEGIN
  tc;
(*
  c:= 1;
  c:= ar[c];
  a:= 3.1415926535897931;
  b:= a*a;
  (*ASSEMBLER BREAK END;*)
  a:= MathLib0.pi;
  WriteReal (a, 20, 16);
  a:= 3.1415926535897931;
  WriteReal (a, 20, 16);
  a:= 0.;
  ASSEMBLER
        ;FMOVECR #0,FP0
        ;FMOVE.D FP0,a
  END;
  WriteReal (a, 20, 16);
*)
END T3.
 
(* $FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFED708C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C$FFF1658C�$0000035AT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000035$000000B9$0000037A$FFED708C$FFED708C$0000038A$0000037A$0000031D$00000378$00000388$FFED708C$00000351$00000360$FFED708C$FFED708C$00000029���*)

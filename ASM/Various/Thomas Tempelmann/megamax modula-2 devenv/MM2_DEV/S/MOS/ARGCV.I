IMPLEMENTATION MODULE ArgCV;

(*$Y+,R-,C-*)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, WORD, BYTE, TSIZE;

FROM PrgCtrl IMPORT ActiveProcess;


PROCEDURE InitArgCV ( VAR ArgC : CARDINAL; VAR ArgV : ARRAY OF PtrArgStr );

  VAR comlin : Address;
      i, quote : Cardinal;
      append, inword : Boolean;
      p: Address;

  PROCEDURE Peek (p:Address) : CHAR;
    (*$L-*)
    BEGIN
      ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1,A3
      END
    END Peek;
    (*$L=*)
  
  PROCEDURE Poke (p:Address;v:Byte);
    (*$L-*)
    BEGIN
      ASSEMBLER
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.B  D0,(A0)
      END
    END Poke;
    (*$L=*)
  
  PROCEDURE isspace (c:Char):Boolean;
    BEGIN
      RETURN (c=' ') OR (c=11c) OR (c=15c) OR (c=12c)
    END isspace;
  
  PROCEDURE newWd;
    BEGIN
      IF argc <= HIGH (argv) THEN
        ArgV[argc] := PtrArgStr(p);
      END;
      Inc (argc);
    END newWd;
  
  PROCEDURE tstQuote (n:CARDINAL);
    BEGIN
      IF quote = n THEN
        Poke (p,0C);
        quote := 0
      ELSIF ~inword & (quote=0) THEN
        Poke (p,0C);
        quote := n;
        INC (p);
        newWd;
        DEC (p)
      END
    END tstQuote;
  
  BEGIN
    inword := False;
    quote := 0;
    argc := 1;    (* always have at least program name *)
    
    comlin:= ActiveProcess();
    Inc (comlin, 128);
    p := comlin+1L;
    
    FOR i:= 1 TO ORD (Peek(comlin)) DO
        IF isspace(Peek(p)) THEN
            IF quote=0 THEN
                inword := False;
                Poke (p,0C)
            ELSE
                Poke (p,' ')
            END;
        ELSIF Peek(p) = '"' THEN
            tstQuote (1);
        ELSIF Peek(p) = "'" THEN
            tstQuote (2);
        ELSE
            IF ~inword & (quote=0) THEN
                inword := True;
                newWd
            END
        END;
        Inc (p);
    END;
    Poke (p,0C);  (* make sure last string is null terminated *)
    
    i:=argc;
    WHILE i<=HIGH(argv) DO
      ArgV[i] := PtrArgStr(p);
      Inc (i)
    END;
    
    argv[0] := p;          (* no program name *)
    
  END InitArgCV;

END ArgCV.
 
(* $FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$0000008F$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1$FFF96AE1�$000003E1T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFEDDBC1$0000008F$0000006E$0000004F$FFEDB15C$000001C1$000003E1$000003FE$000003E5$000003F3$FFEDB15C$FFEDB15C$00000026$000005A4$000005BA$000005A4���*)

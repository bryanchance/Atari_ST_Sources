MODULE ConvDec;

(* Versch�nert '.DEC'-Files, die von DECSYM erzeugt werden. *)

FROM Strings IMPORT String, Concat, Split, Delete, PosLen, Space, Length,
                Pos, Compare, Relation;

FROM Directory IMPORT FileAttrSet, DirEntry, DirQuery;

FROM Files IMPORT Access, File, Open, Create, Close, EOF, ReplaceMode,
                GetStateMsg, State;
FROM Text IMPORT EOL;
IMPORT Text;

FROM InOut IMPORT ReadString, WriteLn, WriteString;


VAR df, sf: File; ok: BOOLEAN;


PROCEDURE copytext;
  
  VAR l: ARRAY [0..79] OF CHAR;  i: INTEGER;
  
  BEGIN
    WHILE ~EOF (sf) DO
      Text.ReadString (sf, l);
      WHILE Pos ('(*', l, 0) >= 0 DO
        i:= Pos ('(*', l, 0);
        Delete (l, i, Pos ('*)', l, 0) + 2 - i, ok)
      END;
      Text.WriteString (df, l);
      Text.WriteLn (df)
    END;
  END copytext;


VAR name: String;

BEGIN
  WriteString ('Input: ');
  ReadString (name);
  Open ( sf, name, readSeqTxt );
  GetStateMsg (State (sf), name);
  WriteString (name);
  WriteLn;
  WriteString ('Output: ');
  ReadString (name);
  Create ( df, name, writeSeqTxt, replaceOld );
  GetStateMsg (State (sf), name);
  WriteString (name);
  WriteLn;
  copytext;
  Close ( df );
  Close ( sf )
END ConvDec.
 
(* $FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$000004FA$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470�$000003D3T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000001D0$00000415$00000404$00000415$000003F6$000003D3$0000014B$00000170$000001D0$000003D3$000004C3$FFF71026$000004FA$000002F5$000001D0$000001F2���*)

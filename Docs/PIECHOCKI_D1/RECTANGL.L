
               TEXT

               INCLUDE       "LINEQU.L"
               INCLUDE       "INIT_TOS.L"
               INCLUDE       "MACROS.L"

               SETBLOCK

               PRINTLINE     CADRE
               WAIT
               PEXEC         NUL,ZERO,PRG,#0

               DC.W          $A000
               movea.l       a0,a5

               move.l        #CONTROL,ticontrol(a0)
               move.l        #INTIN,tiintin(a0)
               move.l        #PTSIN,tiptsin(a0)
               move.l        #INTOUT,tiintout(a0)
               move.l        #PTSOUT,tiptsout(a0)



               move          #1,_fg_bp_1(a5)
               move          #0,_fg_bp_2(a5)

               move          #0,_wrt_mode(a5)

               move          #7,_patmsk(a5)
               move.l        #FILL,_patptr(a5)

               move          #129,_x1(a5)
               move          #24,_y1(a5)
               move          #496,_x2(a5)
               move          #183,_y2(a5)

               DC.W          $A005
               WAIT

               TERM

               DATA

FILL           DC.W          %0111111111111110
               DC.W          %0100000000000010
               DC.W          %0101000000001010
               DC.W          %0101111111111010
               DC.W          %0101000000001010
               DC.W          %0100000000000010
               DC.W          %0111111111111110
               DC.W          %0000000000000000

CADRE          DC.B          27,'E','Je vais tracer un carr� avec $A005 '
               DC.B          'apr�s avoir charg� CADRE.PRG ',0

NUL            DC.B          0
ZERO           DC.B          0
PRG            DC.B          'A:\CADRE.PRG',0

               BSS

               INCLUDE       "TABLEAU.L"

               END


 
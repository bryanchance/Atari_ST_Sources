
               TEXT

               INCLUDE       "INIT_TOS.L"
               INCLUDE       "MACROS.L"
               INCLUDE       "TIMERS.L"
               INCLUDE       "MACROS_2.L"

               SETBLOCK

               SUPER

               PRINTLINE     LA
               CCONOUT       #13
               CCONOUT       #10
               WAIT
               TIMERA        PRG,50,%111


BOUCLE         HEXA          VAL
               CCONOUT       #13
               CCONOUT       #10
               WAIT
               cmpi.b        #'Q',d0
               beq           RETOUR
               cmpi.b        #'q',d0
               beq           RETOUR
               jmp           BOUCLE


PRG            add.l         #1,VAL
               bclr          #5,$FFFA0F
               RTE

RETOUR         USER
               STOPTIMEA
               TERM

               DATA

LA             DC.B          27,'E','Routine sous interruption (TIMER A )'
               DC.B          ' qui incr�mente le',13,10,'contenu de la va'
               DC.B          'riable affich�e ([Q] pour QUITTER) ...',0

               BSS

               DS.B          500
PILE           DS.B          1
SAUV_SP        DS.L          1
VAL            DS.L          1


               END
 
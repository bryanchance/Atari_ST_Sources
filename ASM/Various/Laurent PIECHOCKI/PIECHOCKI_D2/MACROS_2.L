

          TEXT

SAUVE     MACRO
          movem.l   d0-d7/a0-a6,-(sp)
          ENDM

RESTORE   MACRO
          movem.l   (sp)+,d0-d7/a0-a6
          ENDM



HEXA      MACRO     $\1
          SAUVE
          move.l    \1,d1
          moveq     #0,d2
DECAL     addi.b    #4,d2
          cmpi.b    #36,d2
          beq       FIN
          move.l    d1,d3
          rol.l     d2,d3
          andi.l    #%1111,d3
          cmpi.b    #9,d3
          bgt       HEX
DECIMAL   addi.b    #$30,d3
          CCONOUT   d3
          jmp       DECAL
HEX       addi.b    #$37,d3
          CCONOUT   d3
          jmp       DECAL
FIN       RESTORE
          ENDM


BINAIRE   MACRO     $\1
          SAUVE
          move.L    \1,d1
          move      #31,d3

LOOK      move      #'0',d0
          lsl.l     #1,d1

          bcc       ZERO
          move      #'1',d0
ZERO      CCONOUT   d0
          dbf       d3,LOOK
          RESTORE
          ENDM

          END


 
* Rndpcopy -Kopiert quasi zuf�llig (pixelweise) eine Hires-Seite in eine Andere
* Aufruf:       rndpcopy(quelle,ziel)

.text
.xdef _rndpcopy
_rndpcopy:      movem.l d0-d5/a0-a3,-(a7) *Register retten
                move.w  #63999,d4       *Zahl der Durchl�ufe
                clr.w   d5              *d5 l�schen

rp_j0:          movea.l 44(a7),a2       *Quelladresse laden
                movea.l 48(a7),a3       *Zieladresse laden
rp_j0a:         move.w  d5,d3           *d5 merken
                lsl.w   #4,d5           *d5 * 16
                add.w   d3,d5           *d5 + d3
                add.w   #87,d5          *d5 + 87
                cmp.w   #63999,d5       *d5 < 64000 ?
                bhi.s   rp_j0a          *Nein --> Zur�ck

                clr.l   d1              *Damit Bits 16 bis 31 gel�scht
                move.w  d5,d1           *Zufallswert kopieren
                lsr.w   #1,d1           *Durch 2
                and.w   #$fff8,d1       *Da 8er-Gruppen
                adda.l  d1,a2           *Quelladresse
                adda.l  d1,a3           *Zieladresse

                move.w  d5,d0           *Bitnummer
                and.w   #$f,d0          *Bits 8-15 l�schen

                clr.w   d1              *Z�hler
rp_j1:          move.w  0(a2,d1.w),d2   *Quellwert holen
                move.w  0(a3,d1.w),d3   *Zielwert holen
                btst    d0,d2           *Bit testen
                bne.s   rp_j2           *Gesetzt --> Weiter
                bclr    d0,d3           *Bit l�schen
                bra.s   rp_j3           *Weiter
rp_j2:          bset    d0,d3           *Bit setzen
rp_j3:          move.w  d3,0(a3,d1.w)   *Zielwert schreiben
                addq.w  #2,d1           *Z�hler erh�hen
                cmp.w   #8,d1           *Z�hler == 8 ?
                bne.s   rp_j1           *Nein --> Zur�ck

                dbra    d4,rp_j0        *Zur�ck in Hauptschleife

                movem.l (a7)+,d0-d5/a0-a3 *Register holen
                rts                     *Ende

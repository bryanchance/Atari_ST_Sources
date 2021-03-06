/***********************************************/
/* Modulname      : MINI1.C                    */
/* Autor          : Thomas Binder              */
/* Zweck:         : Miniprogramm, das aus      */
/*                  GAMEFIX heraus gespeichert */
/*                  werden kann und wie "OK/   */
/*                  Booten" wirkt, also einen  */
/*                  "Magic Pack" im Speicher   */
/*                  anlegt und dann einen      */
/*                  Reset ausl�st.             */
/* Compiler       : Pure C 1.0                 */
/* Erstellt am    : 28.08.1993                 */
/* Letzte �nderung: 03.09.1993                 */
/***********************************************/

#include <tos.h>
#include <aes.h>
#include <portab.h>
#include <falcon.h>
#include <string.h>
#include "gamefix.h"

/* Prototypen */
LONG set(void);

/* Globale Variablen */
extern WORD mtype;
char loadprogram[129] = "\x0\x0\xab\xce";
char commandline[] = "";

LONG main(void)
{
    char    stdpath[129],
            *backslash;
    
    /* Programm beenden, wenn die alte Bild- */
    /* schirmadresse aktiviert werden soll, */
    /* aber kein ST-Kompatibilit�smodus aktiv */
    /* ist */
    if (settings[_SCRBASE])
        if (!(Vsetmode(-1) & STMODES))
            return(0L);
    /* Welcher Monitor ist dran? */
    mtype = mon_type();
    /* Einstellroutine aufrufen */
    Supexec(set);
    /* Soll ein Programm nachgeladen werden? */
    if (loadprogram[0])
    {
        /* Wenn ja, dessen Pfad zum aktuellen */
        /* machen */
        if (loadprogram[1] == ':')
        {
            Dsetdrv((WORD)loadprogram[0] - 65);
            strcpy(stdpath, &loadprogram[2]);
        }
        else
            strcpy(stdpath, loadprogram);
        if ((backslash = strrchr(stdpath, '\\'))
            != 0L)
        {
            backslash[1] = 0;
        }
        Dsetpath(stdpath);
        /* Programm laden & ausf�hren */
        return(Pexec(0, loadprogram, commandline,
            0L));
    }
    return(0L);
}
/* Modulende */

DEFINITION MODULE Directory;

(*
 * ---------------------------------------
 *   Operationen auf Dateien und Ordnern
 * ---------------------------------------
 *
 *     Z.B. L�schen, Umbenennen, Durchsuchen einzelner Ordner
 *     oder Setzen/Abfragen der Standard-Pfade.
 *     Auch Funktion zum Ermitteln der Texte f�r GEMDOS-Fehlernummern
 *
 * Zu den Namenskonventionen siehe Modul 'FileNames'!
 *
 * Die DTA ist die Adresse auf einen Puffer (hier "SearchRec" genannt), der
 * von den GEMDOS-Funktionen "Fsfirst" und "Fsnext" verwendet wird, um
 * darin interne sowie Anwender-Daten abzulegen. Werden "Fsfirst"-Aufrufe
 * verschachtelt (bzw. die dabei angesprochenen Ordner), mu� jeder Zugriff
 * seinen eigenen Puffer verwenden.
 * Viele Funktionen machen Gebrauch von "Fsfirst" und "Fsnext". 'DirQuery'
 * sorgt selbst f�r ein korrektes Setzen der DTA. Die restlichen Funktionen
 * ('FileExists', 'GetDirEntry', 'MakeFullPath', 'SearchFirst' und
 * 'SearchNext') verwenden die aktuelle DTA. Vom Programmstart an ist
 * immer automatisch eine g�ltige DTA eingestellt. Werden ausschlie�lich
 * die hiesigen Funktionen
 *   'FileExists', 'GetDirEntry', 'MakeFullPath' und 'DirQuery'
 * verwendet, braucht man sich um die DTA nicht weiter k�mmern. Lediglich,
 * wenn 'SearchFirst' und 'SearchNext' verwendet werden, mu� bei dazwischen
 * erfolgenden Aufrufen von
 *   'FileExists', 'GetDirEntry', 'MakeFullPath' oder einem erneuten
 *   (verschachtelten) Aufruf von 'SearchFirst'
 * die DTA zuvor neu gesetzt werden (siehe dazu 'GetDTA', 'SetDTA').
 *
 * Einige Funktionen haben einen 'result'-Parameter. Dieser dient dazu,
 * evtl. w�hrend der Operation aufgetretene Fehler zu signalisieren.
 * Ist der 'result'-Wert nach dem Aufruf negativ, ist ein Fehler aufgetreten.
 * Die Fehlernummern entsprechen den in 'Files' verwendeten und sind im
 * Modul 'MOSGlobals' definiert.
 * Der Text zu den Fehlernummern kann mit der Funktion 'GetErrMsg' ermittelt
 * werden (diese ist identisch mit 'GetStateMsg' aus 'Files').
 *
 * Alle Routinen, die einen Parameter vom Typ 'Drive' haben, k�nnen statt
 * der Laufwerkskennung ('drvA', usw) auch einfach 'defaultDrv' �bergeben,
 * womit dann automatisch das Default-Laufwerk angesprochen wird.
 *)

FROM SYSTEM     IMPORT BYTE, WORD;
FROM MOSGlobals IMPORT FileStr, PathStr, DriveStr, NameStr, PfxStr, SfxStr,
                       Time, Date, Drive, DriveSet;


TYPE    (* Kennzeichen (Attribut) f�r einen Directory-Eintrag *)
        FileAttr     = (readOnlyAttr,           (* Datei nicht beschreibbar *)
                        hiddenAttr,             (* Eintrag unsichtbar *)
                        systemAttr,             (* (Unsichtbare) Systemdatei *)
                        volLabelAttr,           (* Diskname *)
                        subdirAttr,             (* Subdirectory *)
                        archiveAttr);           (* Archivierte Datei *)

        FileAttrSet  = SET OF FileAttr;

        (* Daten eines Directory-Eintrages *)
        DirEntry     = RECORD
                         name: NameStr;
                         attr: FileAttrSet;
                         time: Time;
                         date: Date;
                         size: LONGCARD
                       END;

        SearchRec    = RECORD
                         internal: ARRAY [0..20] OF BYTE;
                         attr: FileAttrSet;
                         time: CARDINAL;
                         date: CARDINAL;
                         size: LONGCARD;
                         name: ARRAY [0..13] OF CHAR;
                       END;

        DTA          = POINTER TO SearchRec;  (* "Disk Transfer Address" *)


        DirQueryProc = PROCEDURE ( REF (* path: *) ARRAY OF CHAR,
                                       (* entry:*) DirEntry      ): BOOLEAN;

CONST   (* F�r Funktionen DirQuery und SearchFirst: *)
        QueryFiles = FileAttrSet {};            (* Nur Dateien *)
        QueryAll   = FileAttrSet {subdirAttr};  (* Dateien & Ordner *)
    (* "QueryFolders" unterst�tzt GEMDOS leider nicht *)



PROCEDURE Delete (REF name: ARRAY OF CHAR; VAR result: INTEGER);
  (*
   * L�scht eine Datei, kein Subdirectory.
   *
   * Wenn Datei nicht vorhanden, liefert 'result' den positiven
   * Wert 'MOSGlobals.fNotDeleted'
   *)

PROCEDURE Rename (REF fromName, toName: ARRAY OF CHAR; VAR result: INTEGER);
  (*
   * Benennt Datei von 'fromName' nach 'toName' um.
   * (Ab TOS 1.4 k�nnen hiermit auch Ordnernamen ge�ndert werden)
   *
   * Wenn Zieldatei existiert, wird 'MOSGlobals.fFileExists' (negativer Wert)
   * geliefert und der Name nicht ge�ndert; ggf. vorher 'Delete (toName)'
   * aufrufen.
   *)


PROCEDURE FileExists ( REF fileName: ARRAY OF CHAR ): BOOLEAN;
  (*
   * Liefert TRUE, wenn die angegebene Datei existiert.
   * Liefert nicht TRUE bei evtl. existierenden Ordnern!
   *)

PROCEDURE PathExists ( REF path: ARRAY OF CHAR ): BOOLEAN;
  (*
   * Liefert TRUE, wenn der angegebene Pfad existiert.
   * Wird ein Dateiname mitsamt eines Pfades angegeben, wird nur der
   * Pfad gepr�ft, nicht das Vorhandensein der Datei selbst.
   *)


PROCEDURE GetFileAttr ( REF filename: ARRAY OF CHAR;
                        VAR attr: FileAttrSet; VAR result: INTEGER );
  (*
   * Ermittelt Dateikennzeichen (Attribut) einer Datei (nicht Ordner!).
   *
   * Attribute von anderen Directory-Eintr�gen k�nnen mit 'GetDirEntry'
   * ermittelt werden.
   *)

PROCEDURE SetFileAttr ( REF filename: ARRAY OF CHAR; attr: FileAttrSet;
                        VAR result: INTEGER );
  (*
   * Setzt Dateikennzeichen (Attribut) einer Datei.
   *)

PROCEDURE GetDirEntry ( REF name: ARRAY OF CHAR;
                        VAR entry: DirEntry; VAR result: INTEGER );
  (*
   * Liefert den Directory-Eintrag einer Datei oder Ordner in 'entry'.
   *)

(*$H+*)
PROCEDURE DirQuery (REF wildcard: ARRAY OF CHAR;
                        select  : FileAttrSet;
                        dirProc : DirQueryProc;
                    VAR result  : INTEGER);
  (*
   * Liefert alle Dateien/Ordnernamen aus einem Ordner.
   *
   * Ruft 'dirProc' wiederholt f�r alle zu 'wildcard' passenden Directory-
   * eintr�gen auf, solange 'dirProc' TRUE liefert.
   * Wegen $H+ k�nnen auch lokale Prozeduren an 'dirProc' �bergeben werden.
   * Beispiele f�r 'wildcard' siehe Funktion 'NameMatching' weiter unten.
   * F�r 'select' bieten sich v.A. die folg. Konstanten an:
   *  'QueryFiles' findet alle Dateien, keine Ordner und keine Volume-Labels;
   *  'QueryAll' findet alle Dateien und Ordner, keine Volume-Labels;
   *  'FileAttrSet {volLabelAttr}' findet nur Volume-Labels (uninteressant);
   *
   * Ist das Verzeichnis leer bzw. treffen keine Dateien auf den 'wildcard'
   * zu, liefert 'result' den positiven Wert 'fNoMatchingFiles'.
   *
   * Diese Funktion ist Re-entrant-f�hig, sie kann also innerhalb der 'dirProc'
   * wiederum aufgerufen werden.
   *)


PROCEDURE SetDefaultPath ( REF path: ARRAY OF CHAR; VAR result: INTEGER );
  (*
   * Setzt den Default-Pfad des aktuellen Laufwerks. Ist in 'path' eine
   * Laufwerkskennung enthalten, wird dieses Laufwerk auch zum Aktuellen.
   *)

PROCEDURE GetDefaultPath ( VAR path: ARRAY OF CHAR );
PROCEDURE DefaultPath (): PathStr;
  (*
   * Beide Funktionen liefert den Default-Pfad, also Laufwerkskennung
   * (wie bei 'DefaultDrive') und aktuellen Pfad des Laufwerks (wie bei
   * 'GetCurrentDir').
   *)


PROCEDURE CreateDir ( REF path: ARRAY OF CHAR; VAR result: INTEGER );
  (*
   * Legt einen neuen Ordner an.
   *)

PROCEDURE DeleteDir ( REF path: ARRAY OF CHAR; VAR result: INTEGER );
  (*
   * L�scht einen Ordner. Er mu� dazu leer sein!
   *)


PROCEDURE GetCurrentDir ( driveNo: Drive; VAR path: ARRAY OF CHAR );
  (*
   * Liefert den aktuellen Pfad eines Laufwerks.
   *
   * Liefert den Pfadnamen des Laufwerks 'driveNo', der angesprochen wird,
   * wenn in einem Pfadnamen nicht vom Root-Directory ausgegangen wird
   * (also wenn ein Pfadname z.B. "HU.GO" oder "B:ABC.E", aber nicht
   * "\HU.GO" bzw. "B:\ABC.E" ist).
   * Der Pfad wird immer mit einem '\' (Backslash) abgeschlossen, beim
   * Root-Dir (Hauptverzeichnis) wird nur '\' geliefert.
   * Entgegen der Angaben im Handbuch wird nie der Laufwerksbuchstabe
   * mitgeliefert. Dieser kann einfach durch Aufruf von 'DriveToStr (driveno)'
   * ermittelt werden (Beim akt. Laufwerk nehme man die einfachere Funktion
   * 'GetDefaultPath').
   * 'path' sollte mindestens 128 Zeichen gro� sein.
   *)

PROCEDURE SetCurrentDir ( driveNo: Drive; REF path: ARRAY OF CHAR;
                          VAR result: INTEGER );
  (*
   * Setzt den aktuellen Pfad eines Laufwerks.
   *
   * Anm.: Der Fehler des GEMDOS, da� nur der Pfad des aktuellen Laufwerks
   *       bestimmbar ist, tritt bei dieser Funktion nicht in Erscheinung.
   *)


PROCEDURE DrivesOnline (): DriveSet;
  (*
   * Liefert ein SET aller ansprechbaren Laufwerke.
   *)

PROCEDURE SetDefaultDrive ( driveNo: Drive );
  (*
   * Setzt das Laufwerk, das angesprochen wird, wenn in einem Pfadnamen
   * kein Laufwerk angegeben wird (= Default-Laufwerk).
   * 'driveNo':='defaultDrv' wird ignoriert.
   *)

PROCEDURE DefaultDrive (): Drive;
  (*
   * Liefert das Default-Laufwerk, liefert nie 'defaultDrv'.
   *)

PROCEDURE FreeSpace ( driveNo: Drive ): LONGCARD;
  (*
   * Liefert noch freien Platz des Laufwerks in Bytes.
   * Liefert Null, wenn Laufwerk nicht ansprechbar.
   * Durchf�hrung kann u.U. mehrere Sekunden dauern.
   *)


PROCEDURE MakeFullPath ( VAR pathOrFileName: ARRAY OF CHAR;
                         VAR result: INTEGER );
  (*
   * pr�ft, ob der angegebene Pfad existiert und vervollst�ndigt ihn
   * ggf. zu einem kompletten Pfadnamen aus Laufwerksbuchstaben und
   * ganzem Pfad.
   * Zudem wird der Name ggf. in Gro�buchstaben umgewandelt.
   *
   * Tritt ein Fehler auf ('result' < 0), bleibt 'pathOrFileName' unver�ndert.
   *
   * Es kann wahlweise nur der Pfad (mu� dann mit '\' oder ':' abschlie�en,
   * z.B., indem vorher 'ValidatePath' aufgerufen wird) oder ein Dateiname
   * (mit oder ohne Pfad) angegeben werden.
   * Der Pfad mu� beim Aufruf tats�chlich erreichbar (vorhanden) sein, da
   * in jedem Fall dieser Pfad zur Pr�fung angesprochen wird. Wird ein
   * Dateiname angegeben, braucht diese nicht zu existieren - auf sie wird
   * nicht zugegriffen.
   * Ist der Pfad nicht erreichbar, liefert 'result' entsprechend einen
   * negativen Wert als Fehlerkennung.
   *
   * Beispiele (der aktuelle Pfad sei "D:\TEST\DATEN\"):
   *   'D001.DAT'           ergibt  'D:\TEST\DATEN\D001.DAT'
   *   '..\D001.DAT'        ergibt  'D:\TEST\D001.DAT'
   *   'D:\D001.DAT'        ergibt  'D:\D001.DAT'
   *   ''                   ergibt  'D:\TEST\DATEN\'
   *   'BIN\'               ergibt  'D:\TEST\DATEN\BIN\'
   *   'D:\BLA\D001.DAT'    liefert -34 in 'result', falls der Ordner 'BLA'
   *                          nicht existiert.
   *)


PROCEDURE GetDTA ( VAR dta: DTA );
  (*
   * Ermittelt die aktuelle DTA
   *)

PROCEDURE SetDTA ( dta: DTA );
  (*
   * Setzt eine neue DTA. Dazu mu� 'dta' auf einen Puffer von mind. 44 Byte
   * ('SearchRec') zeigen.
   *)

PROCEDURE SearchFirst ( REF wildcard: ARRAY OF CHAR;
                            select  : FileAttrSet;
                        VAR result  : INTEGER );

PROCEDURE SearchNext  ( VAR result  : INTEGER );
  (*
   * Funktionen wie 'Dirquery'. Hierbei wird jedoch keine Prozedur angegeben,
   * die f�r alle Directory-Eintr�ge aufgerufen wird, sondern es mu� selbst
   * eine Schleife gebildet werden und auch die DTA ggf. neu gesetzt werden
   * (s.o.).
   *
   * Sobald keine auf 'wildcard' zutreffenden Dateien mehr gefunden werden,
   * wird 'fNoMoreFiles' (-49) in 'result' geliefert. Dieser Wert wird also
   * auch schon bei 'SearchFirst' geliefert, wenn �berhaupt keine Dateien
   * zutreffen. Dem gegen�ber liefert die Original-GEMDOS-Funktion "Fsfirst"
   * dann den Wert 'fFileNotFound' (-33) und erst "Fsnext" w�rde -49 liefern.
   *
   * Beispiel:
   *   VAR  dta: DTA;  entry: DirEntry;
   *   BEGIN
   *     NEW (dta);
   *     SetDTA (dta);
   *     SearchFirst ('*.*', QueryFiles, result);
   *     WHILE result # fNoMoreFiles DO
   *       GetDTAEntry (dta, entry);
   *       ... Operationen mit 'entry'...
   *       SearchNext (result)
   *     END;
   *)

PROCEDURE GetDTAEntry ( dta: DTA; VAR entry: DirEntry );
  (*
   * Wandelt die 'SearchRec'-Daten einer DTA in einen 'DirEntry'.
   * Es ist jedoch ebenso m�glich, auf die SearchRec-Daten direkt zuzugreifen,
   * Datum und Zeit ('date', 'time') k�nnen dann beispielsweise mit Hilfe
   * von 'Clock.UnpackDate/Time' in die �blichen Records umgewandelt werden.
   *)


PROCEDURE ForceMediaChange ( driveNo: Drive );
  (*
   * Simuliert einen Disk-Wechsel auf dem angegebenen Laufwerk,
   * soda� beim n�chsten Disk-Zugriff mit Sicherheit alle Daten
   * neu von der Disk eingelesen werden (die evtl. vom TOS/GEMDOS
   * gepufferten Daten werden ignoriert).
   * Diese Funktion wurde nach einer Anleitung von Atari
   * (TOS Release Notes v. 20. Mai 1988) implementiert und ist
   * damit verl��lich f�r alle TOS-Versionen anwendbar.
   *)


PROCEDURE GetErrMsg ( number: INTEGER; VAR errMsg: ARRAY OF CHAR );
  (*
   * Liefert in 'msg' einen String (H�chstl�nge 32 Zeichen), der eine
   * Beschreibung der zugeh�rigen Fehlernummer 'number' enth�lt.
   * Funktion ist identisch mit 'Files.GetStateMsg'.
   *)

END Directory.

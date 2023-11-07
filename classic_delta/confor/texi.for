      SUBROUTINE EXIA (ITM, IVCON, ITYPMK, LIDAT, ITYPC, NSTAT, NORNG,      TEXI
     * NC, ISTAT, MS, IUNRNG, IC)
 
C* REVISED 13-MAY-91.
C* CONVERTS AN ATTRIBUTE TO EXIR FORMAT.
 
C  ITM RECEIVES THE ITEM.
C  IVCON RECEIVES THE VALUE CONSTRAINTS.
C  ITYPMK RECEIVES TYPESETTING MARKS.
C  LIDAT RECEIVES THE (MAXIMUM) DIMENSION OF ITM, IVCON, ITYPMK.
C  ITYPC RECEIVES THE CHARACTER TYPES.
C  NSTAT RECEIVES THE NUMBERS OF STATES.
C  NORNG RECEIVES WHERE TO NORMAL RANGES.
C  NC RECEIVES THE NUMBER OF CHARACTERS.
C  ISTAT RECEIVES WORKING SPACE OF LENGTH MS.
C  MS RECEIVES THE MAXIMUM NUMBER OF STATES.
C  IUNRNG RECEIVES WHETHER TO USE NORMAL RANGES.
C  IC RECEIVES THE CHARACTER NUMBER.
C
      DIMENSION ITM(LIDAT),IVCON(LIDAT),ITYPMK(LIDAT),
     * ITYPC(NC),NSTAT(NC),NORNG(NC),ISTAT(MS)
C
      COMMON /ITSXXX/ ITSS
      COMMON /JSTXXX/ IOUT(132,5),LOUT,ICAP,
     * JIOUT(5),IENDWD(5),INDEN(5),LWIDTH(5),PSEQ,SEQINC,NSQDIG
      COMMON /NUMXXX/ KNUM(10),KDEC,KMINUS
      COMMON /SYMXXX/ KPOINT,KDASH,KSTAR,KVERT,KEQUAL,KCOMMA,KSEMIC,
     * KCOLON,KSTOP,KSOL,KLPAR,KRPAR,KDOLLA,KQUEST,KEXCL,KAT,KLBRACE,
     * KRBRACE
      COMMON /TPSXXX/ ITPSET,NTYPMK,IFBEGIN,IFEND
C
C---  COLLECT INFORMATION ABOUT ATTRIBUTE.
C
C--   INITIALIZE.
      JTYPC = IABS(ITYPC(IC))
      GO TO (10,10,12,12,14),JTYPC
C     MULTISTATE.
   10 NS = NSTAT(IC)
      ICODED = 0
      CALL SETIA (ISTAT, NS, 0)
      GO TO 30
C     NUMERIC.
   12 IB = IVCON(IC)
      VMAX = RELIN(IVCON(IB))
      IE = IB + 1
      VMIN = RELIN(IVCON(IE))
      GO TO 30
C     TEXT.
   14 LS = 0
C
   30 IF (ITM(IC).LE.0)  GO TO 800
      JG = ITM(IC)
      JGN = JG + ITM(JG)
      JSG = JG + 1
C
C--   SCAN ATTRIBUTE.
   50 IF (JSG.GE.JGN)  GO TO 800
        ITS = ITM(JSG+1)
        IPS = IDIM(ITS,ITSS)
        IF (IPS.GE.2)  GO TO 700
        JB = JSG + 2
        JE = JSG + ITM(JSG) - 1
        GO TO (100,100,300,300,500), JTYPC
C-      MULTISTATE.
  100   IF (ITS.LE.0)  GO TO 700
        ICODED = 1
        IF (IPS.EQ.1)  GO TO 180
        IF (JTYPC.EQ.2 .AND. ITS.EQ.1)  GO TO 140
C       UNORDERED MULTISTATE, OR ORDERED MULTISTATE WITH 'AND'.
        DO 110 J = JB, JE
        IS = ITM(J)
  110     ISTAT(IS) = 1
        GO TO 700
C       ORDERED MULTISTATE WITH 'TO'.
  140   IB = ITM(JB)
        IE = ITM(JE)
        DO 142 IS = IB, IE
  142     ISTAT(IS) = 1
        GO TO 700
C       VARIABLE.
  180   CALL SETIA (ISTAT, NS, 1)
        GO TO 700
C
C-      NUMERIC.
  300   IF (ITS.LE.0)  GO TO 700
        IF (IPS.EQ.1)  GO TO 380
C       USE NORMAL RANGE?
        IF (ITS.EQ.1)  THEN
          NV = JE - JB + 1
          IF (NV.GT.3.AND.IUNRNG.NE.0.AND.NORNG(IC).NE.0)  THEN
            JB = JB + 1
            JE = JE - 1
          ENDIF
        ENDIF
        IF (JTYPC.EQ.4)  GO TO 340
C       INTEGER NUMERIC.
        DO 310 J = JB, JE
          VMIN = AMIN1(FLOAT(ITM(J)),VMIN)
  310     VMAX = AMAX1(FLOAT(ITM(J)),VMAX)
        GO TO 700
C       REAL NUMERIC.
  340   DO 350 J = JB, JE
          VMIN = AMIN1(RELIN(ITM(J)),VMIN)
  350     VMAX = AMAX1(RELIN(ITM(J)),VMIN)
        GO TO 700
C       VARIABLE.
  380   VMIN = RELIN(IVCON(IB))
        VMAX = RELIN(IVCON(IE))
        GO TO 700
C
C-    TEXT.
  500   IF (ITS.GT.0)  GO TO 700
        LS = ITM(JSG) - 4
        CALL DELETS (ITM(JSG+3), ITM(JSG+3), LIDAT, KCOMMA, LS)
        CALL DELETS (ITM(JSG+3), ITM(JSG+3), LIDAT, KSTAR, LS)
        GO TO 800
C-
  700   JSG = JSG + ITM(JSG)
        GO TO 50
C
C---  OUTPUT ATTRIBUTE.
  800 IENDWD(4) = JIOUT(4)
      GO TO (810,810,830,830,850), JTYPC
C
C-    MULTISTATE.
  810 DO 816 IS = 1, NS
        IF (ICODED.EQ.0)  GO TO 816
        IF (ISTAT(IS).EQ.1)  CALL JSTS (KNUM(2), -1, 4)
        IF (ISTAT(IS).NE.1)  CALL JSTS (KNUM(3), -1, 4)
  816   CALL JSTS (KCOMMA, -1, 4)
      GO TO 1000
C
C-    NUMERIC
  830 IF (VMIN.LE.VMAX)  CALL JSTR (VMIN, -5, -1, 4, 0)
      CALL JSTS (KCOMMA, -1, 4)
      IF (VMIN.LE.VMAX)  CALL JSTR (VMAX, -5, -1, 4, 0)
      CALL JSTS (KCOMMA, -1, 4)
      GO TO 1000
C
C-    TEXT.
  850 IF (LS.GT.0)
     * CALL JSTOTP (ITM(JSG+3), LS, -1, ITYPMK, LIDAT, 4, 0, 0)
      CALL JSTS (KCOMMA, -1, 4)
C---
 1000 RETURN
      END
      SUBROUTINE EXICHA (ITYPC, NSTAT, ICDES, LCDES, NC, IAS, MS,           TEXI
     * IVCON, ITYPMK, LIDAT, ICSTR, LCSTR, IC, JCEX)
 
C* REVISED 4-MAY-92.
C* OUTPUTS A CHARACTER DESCRIPTION IN EXIR FORMAT.
C
C  ITYPC RECEIVES THE CHARACTER TYPES.
C  NSTAT RECEIVES THE NUMBERS OF STATES.
C  ICDES RECEIVES THE STARTING POSITIONS OF THE CHARACTER DESCRIPTIONS.
C  LCDES RECEIVES THE LENGTHS OF THE CHARACTER DESCRIPTIONS.
C  NC RECEIVES THE NUMBER OF CHARACTERS.
C  IAS RECEIVES WORKING SPACE OF LENGTH MS.
C  MS RECEIVES THE MAXIMUM NUMBER OF STATES.
C  IVCON RECEIVES THE VALUE CONSTRAINTS.
C  ITYPMK RECEIVES TYPESETTING MARKS.
C  LIDAT RECEIVES THE DATA BUFFER LENGTH.
C  ICSTR. IF ISTYPE.EQ.1, ICSTR RECEIVES THE CHARACTER DESCRIPTIONS.
C    IF ISTYPE.NE.1, ICSTR IS WORKING SPACE. SEE SUBR. FETCHC.
C  LCSTR RECEIVES THE LENGTH OF ICSTR.
C  IC RECEIVES THE CHARACTER NUMBER.
C  JCEX RECEIVES AND RETURNS THE NUMBER OF THE LAST EXIR DESCRIPTOR
C    OUTPUT.
C
      DIMENSION ITYPC(NC),NSTAT(NC),
     * ICDES(NC),LCDES(NC),IAS(MS),IVCON(LIDAT),ITYPMK(LIDAT),
     * ICSTR(LCSTR),MCODE(4),MORD(10),MTO(2),MBY(2),MINN(2),MNAME(4)
C
      CHARACTER*1 LCODE(4),LORD(10),LTO(2),LBY(2),LINN(2),LNAME(4)
C
      COMMON /SYMXXX/ KPOINT,KDASH,KSTAR,KVERT,KEQUAL,KCOMMA,KSEMIC,
     * KCOLON,KSTOP,KSOL,KLPAR,KRPAR,KDOLLA,KQUEST,KEXCL,KAT,KLBRACE,
     * KRBRACE
C
      DATA LCODE(1),LCODE(2),LCODE(3),LCODE(4)/'C','O','D','E'/
      DATA LORD(1),LORD(2),LORD(3),LORD(4),LORD(5),LORD(6),LORD(7),
     * LORD(8),LORD(9),LORD(10)/'O','R','D','E','R',' ','F','R','O','M'/
      DATA LTO(1),LTO(2)/'T','O'/
      DATA LBY(1),LBY(2)/'B','Y'/
      DATA LINN(1),LINN(2)/'I','N'/
      DATA LNAME(1),LNAME(2),LNAME(3),LNAME(4)/'N','A','M','E'/
C
C--   CONVERT CHARACTER VARIBLES TO INTEGER REPRESENTATION.
      CALL COPCIA (LCODE, MCODE, 4)
      CALL COPCIA (LORD, MORD, 10)
      CALL COPCIA (LTO, MTO, 2)
      CALL COPCIA (LBY, MBY, 2)
      CALL COPCIA (LINN, MINN ,2)
      CALL COPCIA (LNAME, MNAME, 4)
C
C--   GET CHARACTER DESCRIPTION.
      CALL FETCHC (ICSTR, LCSTR, ICDES, LCDES, NC, IC, IAC, IAS, MS)
C
C--   OUTPUT DESCRIPTORS.
      JTYPC = IABS(ITYPC(IC))
      NS = NSTAT(IC)
C
      GO TO (100,100,300,300,500), JTYPC
C
C-    MULTISTATE CHARACTER.
  100 DO 180 IS = 1, NS
        CALL ENDLN (4)
        CALL INDENT (0,4)
        JCEX = JCEX + 1
        CALL WSENT (ICSTR(IAC), LCSTR, 0, 0, 0, 0, 0, ITYPMK, LIDAT, 4)
        CALL JSTI (IS, 0, 4)
        CALL JSTS (KLPAR, -1, 4)
        CALL JSTI (JCEX, -1, 4)
        CALL JSTS (KCOMMA, 0, 4)
        CALL JSTOUT (MCODE, 4, -1, 4, 0)
        CALL JSTS (KCOMMA, 0, 4)
        I = IAS(IS)
        CALL WSENT (ICSTR(I), LCSTR, 0, 0, 0, 0, -1, ITYPMK, LIDAT, 4)
        CALL JSTS (KCOMMA, 0, 4)
        CALL JSTWD (9, 0, ITYPMK, LIDAT, 4)
        CALL WSENT (ICSTR(I), LCSTR, 0, 0, 0, 0, -1, ITYPMK, LIDAT, 4)
        CALL JSTS (KRPAR, -1, 4)
        CALL JSTS (KCOMMA, -1, 4)
  180   CONTINUE
      GO TO 1000
C
C-    NUMERIC CHARACTER.
  300 CALL ENDLN (4)
      CALL INDENT (0, 4)
      JCEX = JCEX + 1
      CALL WSENT (ICSTR(IAC), LCSTR, 0, 0, 0, 0, 0, ITYPMK, LIDAT, 4)
      CALL JSTWD (10, 0, ITYPMK, LIDAT, 4)
      CALL JSTS (KLPAR, -1, 4)
      CALL JSTI (JCEX, -1, 4)
      CALL JSTS (KCOMMA, 0, 4)
      CALL JSTOUT (MORD, 10, 0, 4, 0)
      J = IVCON (IC)
      CALL JSTR (RELIN(IVCON(J)), -5, 0, 4, 1)
      CALL JSTOUT (MTO, 2, 0, 4, 0)
      J = J + 1
      CALL JSTR (RELIN(IVCON(J)), -5, 0, 4, 1)
      CALL JSTOUT (MBY, 2, 0, 4, 0)
      J = J + 1
      CALL JSTR (RELIN(IVCON(J)), -5, -1, 4, 1)
      IF (NSTAT(IC).LE.0)  GO TO 320
      CALL ENDWD (4)
      CALL JSTOUT (MINN, 2, 0, 4, 0)
      I = IAS (1)
      CALL WSENT (ICSTR(I), LCSTR, 0, 0, 0, 0, -1, ITYPMK, LIDAT, 4)
  320 CALL JSTS (KRPAR, -1, 4)
      CALL JSTS (KCOMMA, -1, 4)
      CALL ENDLN (4)
      CALL INDENT (0, 4)
      JCEX = JCEX + 1
      CALL WSENT (ICSTR(IAC), LCSTR, 0, 0, 0, 0, 0, ITYPMK, LIDAT, 4)
      CALL JSTWD (11, 0, ITYPMK, LIDAT, 4)
      CALL JSTS (KLPAR, -1, 4)
      CALL JSTI (JCEX, 0, 4)
      CALL JSTS (KEQUAL, 0, 4)
      CALL JSTI (JCEX-1, -1, 4)
      CALL JSTS (KRPAR, -1, 4)
      CALL JSTS (KCOMMA, -1, 4)
      GO TO 1000
C
C-    TEXT CHARACTER.
  500 CALL ENDLN (4)
      CALL INDENT (0, 4)
      JCEX = JCEX + 1
      CALL WSENT (ICSTR(IAC), LCSTR, 0, 0, 0, 0, 0, ITYPMK, LIDAT, 4)
      CALL JSTS (KLPAR, -1, 4)
      CALL JSTI (JCEX, -1, 4)
      CALL JSTS (KCOMMA, 0, 4)
      CALL JSTOUT (MNAME, 4, -1, 4, 0)
      CALL JSTS (KCOMMA, 0, 4)
      CALL JSTI (100, -1, 4)
      CALL JSTS (KRPAR, -1, 4)
      CALL JSTS (KCOMMA, -1, 4)
C--
 1000 RETURN
      END
      SUBROUTINE EXICRD (ITYPC, NSTAT, IMC, NC)                             TEXI
C
C* REVISED 26-JUL-89.
C  OUTPUTS CONTROL CARDS FOR EXIR.
C
C  ITYPC RECEIVES THE CHARACTER TYPES.
C  NSTAT RECEIVES THE NUMBERS OF STATES.
C  IMC RECEIVES THE CHARACTER MASK.
C  NC RECEIVES THE NUMBER OF CHARACTERS.
C
      DIMENSION ITYPC(NC),NSTAT(NC),IMC(NC)
      CHARACTER*1 KODEXI(2,1)
C
      COMMON /BLKXXX/ KBLANK
      COMMON /DELXXX/ KDPLUS,KDSTAR,KDNUM,KDSOL,KDLBRA,KDRBRA,
     * KDCOM,KDRANG,KDAMP,KDCOLN,KDSTOP,KDINF,KDLPAR,KDRPAR,KDBSLSH
      COMMON /INPXXX/ IBUF(121),JBUF,JBDAT,JEDAT,IDERR,NCERR,NSERR,NWERR
      COMMON /SYMXXX/ KPOINT,KDASH,KSTAR,KVERT,KEQUAL,KCOMMA,KSEMIC,
     * KCOLON,KSTOP,KSOL,KLPAR,KRPAR,KDOLLA,KQUEST,KEXCL,KAT,KLBRACE,
     * KRBRACE
C
C     1-ND.
      DATA KODEXI(1,1),KODEXI(2,1)/'N','D'/
C
      CALL ENDLN (4)
C
C--   READ NEXT RECORD.
   50 CALL RDBUFS (ISTAR)
        JBUF = 1
        IF (ISTAR.NE.0)  GO TO 4000
C
C--     REPLACE VARIABLES WITH VALUES, AND OUTPUT RECORD.
C
C-      OUTPUT UP TO NEXT NUMERO OR END OF RECORD.
   60   CALL FINDS (KDNUM, IBUF, JBUF, JEDAT, JF)
          IF (JF.GT.JBUF)  CALL JSTOUT (IBUF(JBUF), JF-JBUF, -1, 4, 0)
          IF (JF.GE.JEDAT)  GO TO 3000
C
C-        FIND END OF VARIABLE (BLANK OR STAR).
          JBUF = JF + 1
          JE = JEDAT
          CALL FINDS (KBLANK, IBUF, JBUF, JE, JF)
          JE = JF
          CALL FINDS (KSTAR, IBUF, JBUF, JE, JF)
          IF (JF.LE.JBUF)  GO TO 900
          CALL CONPHR (KODEXI, 2, 1, 2, IBUF, JBUF, JF-1, ICODE, JE)
          IF (ICODE.LE.0)  GO TO 910
C
C-        ACT ON KEY WORD.
C         GO TO (100), ICODE
C
C         NUMBER OF DESCRIPTORS.
          N = 0
          DO 140 IC = 1, NC
            IF (IMC(IC).EQ.0)  GO TO 140
            JTYPC = IABS(ITYPC(IC))
            GO TO (112,112,116,116,120), JTYPC
  112       N = N + NSTAT(IC)
            GO TO 140
  116       N = N + 2
            GO TO 140
  120       N = N + 1
  140       CONTINUE
          CALL JSTI (N, -1, 4)
          GO TO 2000
C
C--       ERROR MESSAGE.
  900     JE = JF
  910     CALL MESSA (12, 3, JE)
C--
 2000     JBUF = JE
          GO TO 60
C
 3000   CALL ENDLN (4)
        IF (JF.LE.1)  CALL BLKLIN (1, 0, 4)
        GO TO 50
C--
 4000 RETURN
      END
      SUBROUTINE EXITC (ITYPC, IMC, NSTAT, ICDES, LCDES, NC,                TEXI
     * MM1S, MS, IVCON, ITYPMK, LIDAT, ICSTR, LCSTR)
 
C* REVISED 4-MAY-92.
C* OUTPUTS CHARACTER LIST IN EXIR FORMAT.
C
C  ITYPC RECEIVES THE CHARACTER TYPES.
C  IMC RECEIVES THE CHARACTER MASK.
C  NSTAT RECEIVES THE NUMBERS OF STATES.
C  ICDES RECEIVES THE STARTING POSITIONS OF THE CHARACTER DESCRIPTIONS.
C  LCDES RECEIVES THE LENGTHS OF THE CHARACTER DESCRIPTIONS.
C  NC RECEIVES THE NUMBER OF CHARACTERS.
C  MM1S RECEIVES WORDING SPACE OF LENGTH MS.
C  MS RECEIVES THE MAXIMUM NUMBER OF STATES.
C  IVCON RECEIVES THE VALUE CONSTRAINTS.
C  ITYPMK RECEIVES TYPESETTING MARKS.
C  LIDAT RECEIVES THE DATA BUFFER LENGTH.
C  ICSTR. IF ISTYPE.EQ.1, ICSTR RECEIVES THE CHARACTER DESCRIPTIONS.
C    IF ISTYPE.NE.1, ICSTR IS WORKING SPACE. SEE SUBR. FETCHC.
C  LCSTR RECEIVES THE LENGTH OF ICSTR.
C
      DIMENSION ITYPC(NC),IMC(NC),NSTAT(NC),
     * ICDES(NC),LCDES(NC),MM1S(MS),IVCON(LIDAT),ITYPMK(LIDAT),
     * ICSTR(LCSTR)
C
      COMMON /JSTXXX/ IOUT(132,5),LOUT,ICAP,
     * JIOUT(5),IENDWD(5),INDEN(5),LWIDTH(5),PSEQ,SEQINC,NSQDIG
      COMMON /SYMXXX/ KPOINT,KDASH,KSTAR,KVERT,KEQUAL,KCOMMA,KSEMIC,
     * KCOLON,KSTOP,KSOL,KLPAR,KRPAR,KDOLLA,KQUEST,KEXCL,KAT,KLBRACE,
     * KRBRACE
C
C
      JCEX = 0
      PSEQ = 0.
      INDEN(4) = 6
C
      DO 100 IC = 1, NC
        IF (IMC(IC).EQ.0)  GO TO 100
        CALL BLKLIN (1, 0, 4)
        CALL EXICHA (ITYPC, NSTAT, ICDES, LCDES, NC, MM1S, MS,
     *   IVCON, ITYPMK, LIDAT, ICSTR, LCSTR, IC, JCEX)
  100   CONTINUE
C
      JOUT = JIOUT(4)
      IOUT(JOUT,4) = KSTAR
      CALL ENDLN (4)
      INDEN(4) = 0
      RETURN
      END
      SUBROUTINE EXITI (IDAT, ITYPMK, LIDAT, ITYPC, NSTAT, IMC,             TEXI
     * NORNG, NC, ISTAT, MS, IVCON, IMI, JI, IUNRNG)
 
C* REVISED 13-MAY-91.
C* CONVERTS AN ITEM TO EXIR FORMAT AND OUTPUTS IT.
C
C  IDAT RECEIVES THE MAIN ITEM.
C  ITYPMK RECEIVES TYPESETTING MARKS.
C  LIDAT RECEIVES THE DATA BUFFER SIZE.
C  ITYPC RECEIVES THE CHARACTER TYPES.
C  NSTAT RECEIVES THE NUMBERS OF STATES.
C  IMC RECEIVES THE CHARACTER MASK.
C  NORNG RECEIVES WHERE TO USE NORMAL RANGES.
C  NC RECEIVES THE NUMBER OF CHARACTERS.
C  ISTAT IS WORKING SPACE OF LENGTH MS.
C  MS RECEIVES THE MAXIMUM NUMBER OF STATES.
C  IVCON RECEIVES THE VALUE CONSTRAINTS.
C  IVCON RECEIVES THE VALUE CONSTRAINTS.
C  IMI RECEIVES THE ITEM MASK.
C  JI RECEIVES THE ITEM NUMBER.
C  IUNRNG RECEIVES WHETHER TO USE NORMAL RANGES.
 
      DIMENSION IDAT(LIDAT),ITYPMK(LIDAT),ITYPC(NC),
     * NSTAT(NC),IMC(NC),NORNG(NC),ISTAT(MS),IVCON(LIDAT),IMI(JI)
C
      COMMON /JSTXXX/ IOUT(132,5),LOUT,ICAP,
     * JIOUT(5),IENDWD(5),INDEN(5),LWIDTH(5),PSEQ,SEQINC,NSQDIG
      COMMON /SYMXXX/ KPOINT,KDASH,KSTAR,KVERT,KEQUAL,KCOMMA,KSEMIC,
     * KCOLON,KSTOP,KSOL,KLPAR,KRPAR,KDOLLA,KQUEST,KEXCL,KAT,KLBRACE,
     * KRBRACE
C
C     SKIP MASKED-OUT ITEM.
      IF (IMI(JI).EQ.0)  GO TO 2000
C
C--   OUTPUT ATTRIBUTES.
      CALL BLKLIN (1, 0, 4)
      DO 1000 IC = 1, NC
        IF (IMC(IC).EQ.0)  GO TO 1000
        CALL EXIA (IDAT, IVCON, ITYPMK, LIDAT, ITYPC, NSTAT, NORNG, NC,
     *   ISTAT, MS, IUNRNG, IC)
 1000   CONTINUE
C--
      JOUT = JIOUT(4)
      IOUT(JOUT,4) = KSTAR
      CALL ENDLN (4)
C
 2000 RETURN
      END
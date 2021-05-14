/***** REXX *********************************************************/
/****                                                            ****/
/**** (C) Copyright IBM Corp. 2011, 2021                         ****/
/****                                                            ****/

PDSMEMin  = 'userid.GENAPP.CNTL'
CICSHLQ   = 'CTS540.CICS710'
CPSMHLQ   = 'CTS540.CPSM540'
CICSLIC   = 'CTS540.CICS710.LIC'
CSDNAME   = 'userid.GENAPP.DFHCSD'
USRHLQ    = 'userid'
COBOLHLQ  = 'PP.COBOL390.V610'
CEEHLQ    = 'CEE'
DB2HLQ    = 'SYS2.DB2.V12'
DB2RUN    = 'DSNV12P3'
SQLID     = 'userid'
DB2SSID   = 'DKM1'
DB2DBID   = 'GENASA1'
DB2CCSID  = '285'
DB2PLAN   = 'DSNTIA12'
WSIMHLQ   = 'PP.WSIM.V110'
ZFSHOME   = '/u/userid'
TORAPPL   = 'IYI0TOR1'
AORAPPL   = 'IYI0AOR1'
DORAPPL   = 'IYI0DOR1'
TORSYSID  = 'TOR1'
AORSYSID  = 'AOR1'
DORSYSID  = 'DOR1'
CMASAPPL  = 'IYI0CMAS'
CMASYSID  = 'ICMA'
WUIAPPL   = 'IYI0WUI'
WUISYSID  = 'IWUI'

"ISPEXEC VPUT (CICSHLQ CPSMHLQ CICSLIC USRHLQ COBOLHLQ DB2HLQ CEEHLQ)"
"ISPEXEC VPUT (CSDNAME DB2RUN SQLID DB2SSID DB2DBID DB2CCSID DB2PLAN)"
"ISPEXEC VPUT (TORAPPL AORAPPL DORAPPL TORSYSID AORSYSID DORSYSID)"
"ISPEXEC VPUT (CMASAPPL CMASYSID WUIAPPL WUISYSID WSIMHLQ ZFSHOME)"

PDSexec = Substr(PDSMEMin,1,Pos('.CNTL',PDSMEMin)-1) || '.EXEC'
"ALTLIB ACTIVATE APPLICATION(EXEC)  DATASET('"||PDSexec||"')"

PDSDBRM = "'" || Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".DBRMLIB'"
PDSMAPC = "'" || Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".MAPCOPY'"
PDSLOAD = "'" || Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".LOAD'"
PDSMSGS = "'" || Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".MSGTXT'"
WSIMLOG = "'" || Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".LOG'"
WSIMSTL =        Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".WSIM"
"ISPEXEC VPUT (PDSDBRM PDSMACP PDSLOAD PDSMSGS WSIMLOG WSIMSTL)"
SOURCEX =        Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".SRC"
KSDSCUS =     Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".KSDSCUST.TXT"
KSDSPOL =     Left(PDSMEMin,Pos('.CNTL',PDSMEMin)-1) || ".KSDSPOLY.TXT"
LOADX   = STRIP(PDSLOAD,,"'")
MAPCOPX = STRIP(PDSMAPC,,"'")
DBRMLIX = STRIP(PDSDBRM,,"'")
WSIMLGX = STRIP(WSIMLOG,,"'")
WSIMWSX = STRIP(WSIMSTL,,"'")
WSIMMSX = STRIP(PDSMSGS,,"'")
"ISPEXEC VPUT (KSDSPOL KSDSCUS SOURCEX LOADX MAPCOPX DBRMLIX)"
"ISPEXEC VPUT (WSIMLGX WSIMWSX WSIMMSX)"

If SYSDSN(PDSDBRM) ^= 'OK' Then Do
  "ALLOC DD(DB1) DA("||PDSDBRM||") New Like('"PDSMEMin"')"
  If RC = 0 Then "Free DD(DB1)"
End
If SYSDSN(PDSMAPC) ^= 'OK' Then Do
  "ALLOC DD(MC1) DA("||PDSMAPC||") New Like('"PDSMEMin"')"
  If RC = 0 Then "Free DD(MC1)"
End
If SYSDSN(PDSLOAD) ^= 'OK' Then Do
  "ALLOC DD(LM1) DA("||PDSLOAD||") New Space(5,2) Cylinders " ||,
    "BlkSize(6144) Dir(8) DSorg(PO) Recfm(U) Dsntype(LIBRARY)"
  If RC = 0 Then "Free DD(LM1)"
End
If SYSDSN(PDSMSGS) ^= 'OK' Then Do
  "ALLOC DD(DB1) DA("||PDSMSGS||") New Like('"PDSMEMin"')"
  If RC = 0 Then "Free DD(DB1)"
End
If SYSDSN(WSIMLOG) ^= 'OK' Then Do
  "ALLOC DD(LM1) DA("||WSIMLOG||") New Space(20,5) Cylinders " ||,
    "LrecL(27994) BlkSize(27998) Dir(0) DSorg(PS) Recfm(V B)"
  If RC = 0 Then "Free DD(LM1)"
End

ISPEXEC "LMINIT DATAID(IN) DATASET('"PDSMEMin"')"
If RC ^= 0 Then Do
  Say PDSMEMin 'Return code' RC 'from LMINIT'
  Exit RC
End

ISPEXEC 'LMOPEN DATAID(&IN)'
If RC ^= 0 Then Do
  Say PDSMEMin 'Return code' RC 'from LMOPEN'
  Exit RC
End

List_rc  = 0
Counter  = 0
Memname. = ''

Do Until List_rc ^= 0
  ISPEXEC 'LMMLIST DATAID(&IN) OPTION(LIST) MEMBER(MEMBER)'
  List_rc = RC
  If RC = 0 Then Do
    If Left(Member,1) ^= '@' then Do
      Counter = Counter + 1
      Member = Space(Member)
      MemInName.Counter  = PDSMEMIN || '(' || Member || ')'
      MemOutName.Counter = PDSMEMOUT || '(' || Member || ')'
      MemName.Counter    = Member
      'ISPEXEC EDIT DATAID('IN') Member(' || Member || ') Macro(MAC1)'
    End
  End
  MemName.0 = Counter
End

Say '===> ' Counter 'Members customised'

ISPEXEC 'LMCLOSE DATAID(&IN)'
If RC ^= 0 Then Do
  Say PDSMEMin 'Return code' RC 'from LMCLOSE'
  Exit RC
End

ISPEXEC 'LMFREE DATAID(&IN)'
If RC ^= 0 Then Do
  Say PDSMEMin 'Return code' RC 'from LMFREE'
  Exit RC
End

"ISPEXEC EDIT DATASET('" || WSIMSTL || "(ONCICS)') Macro(MAC1)"

"ALTLIB DEACTIVATE APPLICATION(EXEC)"

Exit 0

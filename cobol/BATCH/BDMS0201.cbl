

      *@ @(#) MetaWare Technologies Cobol-Translater 12.1.1.0 18/12/2014        
000100 IDENTIFICATION DIVISION.                                                 
000200* MOVED TO $C1400A.FARS.LICPDS.SRCELIB.V3P0                               
000300*       FROM $C1400A.FEDS.DEVPDS.SRCELIB                                  
000400*       AS OF 14:51:24 01/23/89 (89.023) BY GCM                           
000500* MOVED TO $C1400A.FARS.PROPDS.SRCELIB                                    
000600*       FROM $C1104A.DMCS.ACCPDS.SRCELIB.V0P1                             
000700*       AS OF 13:05:44 08/24/88 (88.237)                                  
000710* COBOL 370 CONVERSION 10/19/98 - BOB WILLIAMS/SAIC                       
000800 PROGRAM-ID.   BDMS0201.                                                  
000900 AUTHOR.       COPYRIGHT BY CDSI.                                         
001000 DATE-WRITTEN. 11-15-87.                                                  
001100 DATE-COMPILED.                                                           
001200******************************************************************        
001300***                                                             **        
001400*** IDENTIFICATION AND DESCRIPTION                              **        
001500*** ------------------------------                              **        
001600***   A. NAME:    BDMS0201                                      **        
001700***   B. TITLE:   MAINTENANCE OF A MASTER FILE                  **        
001800***   C. PURPOSE: THIS PROGRAM HANDLES THE MAINTENANCE OF A     **        
001900***               MASTER FILE.  ALONG WITH THE ACTIVITY FILE    **        
002000***               (ADDS, DELETES & CHANGES), THE MASTER FILE    **        
002100***               IS RUN AGAINST THE RESPECTIVE FDT-FILE.       **        
002200***   D. RESTRICTIONS AND LIMITATIONS: NONE                     **        
002300***   E. ENTRY AND EXIT: NOT APPLICABLE                         **        
002400***                                                             **        
002500*** INPUT, OUTPUT, AND CONTROL                                  **        
002600*** --------------------------                                  **        
002700***   A. INPUTS                                                 **        
002800***      (1) PARAMETERS: NOT APPLICABLE                         **        
002900***      (2) FILES:      MASTER-IN-FILE, TRANS-IN-FILE AND      **        
003000***                      FDT FILE                               **        
003100***      (3) TABLES:     FDT TABLE IS USED TO STORE FIELD-      **        
003200***                      DESCRIPTORS                            **        
003300***   B. OUTPUTS                                                **        
003400***      (1) PARAMETERS: NOT APPLICABLE                         **        
003500***      (2) FILES:      MASTER-OUT-FILE, TRANS-OUT-FILE, PRINT **        
003600***                      FILE                                   **        
003700***   C. WORK-FILES                                             **        
003800***      (1) PARAMETERS: NOT APPLICABLE                         **        
003900***      (2) FILES:      NOT APPLICABLE                         **        
004000***   D. CALLS: NOT APPLICABLE                                  **        
004100***   E. MACROS AND INCLUDED CODE: NOT APPLICABLE               **        
004200***   F. MESSAGE AND ERRORS                                     **        
004300***      (1) MESSAGE: 'BEGIN PROCESSING' AT THE BEGINNING OF    **        
004400***                   THE PROCESSING                            **        
004500***                   'END PROCESSING' AT THE END OF THE        **        
004600***                   PROCESSING                                **        
004700***                   'TRANS INPUT OUT OF SEQUENCE" IF ANY OF   **        
004800***                   THE TRANSACTION RECORD OUT OF SEQUENCE,   **        
004900***                   RUN TERMINATES                            **        
005000***                   'MASTER RCD HAS INVALID FIELD DEF;        **        
005100***                   A-N-M-S' IF ANY OF THE FIELD IN THE       **        
005200***                   MASTER RECORD IS NOT ALPHANUMERIC, NOT    **        
005300***                   NUMERIC, NOT BLANK OR NUMERIC, NOT SIGNED **        
005400***                   NUMERIC, RUN TERMINATES                   **        
005500***      (2) ERROR:   'RUN BEING TERMINATED WITH OC7 ' IF ANY   **        
005600***                   OF THE ABOVE MESSAGES DISPLAYED THEN RUN  **        
005700***                   TERMINATES                                **        
005800***                                                             **        
005900*** JOB CONTROL INFORMATION                                     **        
006000*** -----------------------                                     **        
006100***   A. JOB STREAM PROTOTYPE                                   **        
006200***                                                             **        
006300***  //USERUPD  EXEC PGM=BDMS0201                               **        
006400***  //*--------------------------------------------------------**        
006500***  //*            UPDATE CLIENT MASTER FILE                   **        
006600***  //*--------------------------------------------------------**        
006700***  //*                                                        **        
006800***  //SYSOUT       DD  SYSOUT=A                                **        
006900***  //SYSDBOUT     DD  SYSOUT=A                                **        
007000***  //IN1          DD  DSN=BDMS0201.#1.OCLIENT,                **        
007100***  //             UNIT=3330-1,VOL=SER=FAR001,                 **        
007200***  //             DCB=(RECFM=FB,LRECL=128,BLKSIZE=4224),      **        
007300***  //             DISP=(OLD,PASS,KEEP)                        **        
007400***  //IN2      DD  DSN=&SCLTRANS,                              **        
007500***  //             DCB=(RECFM=FB,LRECL=128,BLKSIZE=4224),      **        
007600***  //             DISP=(OLD,DELETE,DELETE)                    **        
007700***  //IN3      DD  DSN=FARS.PARMLIB(FARSFDTC),DISP=SHR         **        
007800***  //OUT1     DD  DSN=BDMS0201.#1.NCLIENT,                    **        
007900***  //             UNIT=3330-1,VOL=SER=FAR001,                 **        
008000***  //             SPACE=(TRK,(100,20),RLSE),                  **        
008100***  //             DCB=(RECFM=FB,LRECL=128,BLKSIZE=4224),      **        
008200***  //             DISP=(NEW,KEEP,DELETE)                      **        
008300***  //OUT2     DD  DSN=&ERTRANS,                               **        
008400***  //             DCB=(RECFM=FB,LRECL=128,BLKSIZE=4224),      **        
008500***  //             DISP=(MOD,PASS,DELETE)                      **        
008600***  //PRINT1    DD SYSOUT=A,DCB=BLKSIZE=1330                   **        
008700***  //             DCB=(RECFM=FB,LRECL=128,BLKSIZE=4224),      **        
008800***  //             DISP=(NEW,DELETE,DELETE)                    **        
008900***                                                             **        
009000***   B. CICS/VS TABLE: NOT APPLICABLE                          **        
009100***   C. OTHER NOTES: NONE                                      **        
009200***                                                             **        
009300*** PROCESS DESCRIPTION                                         **        
009400*** -------------------                                         **        
009500***   1. PROGRAM UPDATES ALL OF FARS MASTER-FILES               **        
009600***   2. READ FDT-FILE (FIELD-DESCRIPTOR-TABLE)                 **        
009700***      (A) STORES FIELD-DESCRIPTORS                           **        
009800***      (B) FIELD EDITING CRITERIA SPECIFIES THE BEGINING      **        
009900***          LOCATION, THE LENGTH, AND THE FORMAT OF THE VARIOUS**        
010000***          FIELDS.  THESE ENABLE THE PROGRAM TO SET UP THE    **        
010100***          SYS-FLAGS FOR EACH RECORD BEFORE ITS WRITTEN OUT   **        
010200***          TO THE ERTRANS-FILE                                **        
010300***   3. READ INPUT MASTER-FILE                                 **        
010400***      (A) CHECKS FOR INVALID-KEY (IF INVALID KEY IS FOUND    **        
010500***          PRINTS UPDATE STATISTICS & RUN IS TERMINATED)      **        
010600***   4. READ INPUT TRANSACTION-FILE                            **        
010700***      A) PRINTS MAIN-HEADINGS                                **        
010800***      B) CHECKS FOR INVALID TRANS-KEY (IF INVALID-KEY IS     **        
010900***         FOUND, THE RECORD IS FLAGED & WRITTEN OUT TO THE    **        
011000***         ERTRANS-FILE                                        **        
011100***      C) CHECKS FOR CLIENT-BREAK                             **        
011200***      D) TEST FOR INVALID TC, PROCESS ACCORDING TO TRANS-    **        
011300***         CODE & SEQ-RECORD-NO                                **        
011400***         --TC 01-- ADD A NEW RECORD TO THE FILE              **        
011500***                   SEQ-RECORD-NO SHOULD NOT BE IN THE FILE   **        
011600***         --TC 02-- DELETE A RECORD FROM THE FILE             **        
011700***                   SEQ-RECORD-NO SHOULD BE IN THE FILE       **        
011800***         --TC 03-- MODIFY A RECORD IN THE FILE               **        
011900***                   SEQ-RECORD-NO SHOULD BE IN THE FILE       **        
012000***   5. WRITES UPDATED MASTER-FILE                             **        
012100***   6. WRITES ERTRANS-FILE                                    **        
012200***   7. PRODUCES UPDATE REPORT & RUN STATISTICS                **        
012300***                                                             **        
012400*** MODIFICATION HISTORY                                        **        
012500*** --------------------                                        **        
012600***   A. GENERAL REQUEST ID: NOT APPLICABLE                     **        
012700***   B. NAME: NOT APPLICABLE                                   **        
012800***   C. DATE: NOT APPLICABLE                                   **        
012900***   D. DESCRIPTION: NOT APPLICABLE                            **        
013000***                                                             **        
013100***                                                             **        
013200******************************************************************        
013300 REMARKS.    THIS PROGRAM HANDLES THE MAINTENANCE (ADDS, DELETES,         
013400         AND CHANGES) OF A MASTER FILE.  GENERALIZED TECHNIQUES           
013500         ARE USED FOR BUILDING CONTROL KEYS AND UPDATING FIELDS           
013600         SO THAT LOCATIONS AND/OR EXTENTS CAN BE ALTERED WITHOUT          
013700         IMPACTING THE SOURCE CODE; LIMITATIONS ARE.....                  
013800         1. FDT RCD (BLANK, BLANK, 1) MUST END WITH A BLANK               
013900            FIELD OR CONTAIN A MAX OF 14 FIELDS                           
014000         2. MAX LENGTH FOR MATCH KEY FIELDS IS 40 CHAR (TOTAL)            
014100         3. CLIENT CODE ASSUMED TO BE IN POSITION 2-4                     
014200         4. 'S' FLD DESCRIPTOR NOT AUTHORIZED WITH FDT KEY RCDS           
014300         5. MAX OF 15 POSITIONS FOR SIGN FLD ACCUMULATION.                
014400   NOTE - THIS PROGRAM IS SAME AS  FARS0200 WITH THE FOLLOWING            
014500          CHANGES...AN OUTPUT FILE (OUT3) HAS BEEN ADDED TO               
014600          WRITE ALL CHANGES MADE TO THE MASTER FILE DURING AN             
014700          UPDATE RUN (I.E., ANY CHANGE OR ADD RECORD) DELETE              
014800          TRANSACTIONS ARE NOT INCLUDED...D2...11/9/87.                   
014900 ENVIRONMENT DIVISION.                                                    
      *+{Migration -  Set EBCDIC Collating Sequence
       CONFIGURATION SECTION.
          OBJECT-COMPUTER.
              PROGRAM COLLATING SEQUENCE IS SPECIAL-SEQUENCE. 
          SPECIAL-NAMES.
              ALPHABET SPECIAL-SEQUENCE IS EBCDIC
              C01 IS TOP-OF-PAGE.
      *+}
015000*CONFIGURATION SECTION.                                                   
015010****COB370 CHANGE                                                 370     
015020*SPECIAL-NAMES.                                                   370     
015030*    C01 IS TOP-OF-PAGE.                                          370     
015040****COB370 END                                                    370     
      *{ Tr-Source-Computer-Bis 1.3                                             
015100*SOURCE-COMPUTER. IBM-370.                                                
      *--                                                                       
       SOURCE-COMPUTER. UNIX-MF.                                                
      *}                                                                        
      *{ Tr-Object-Computer-Bis 1.1                                             
015200*OBJECT-COMPUTER. IBM-370.                                                
      *--                                                                       
      * OBJECT-COMPUTER. UNIX-MF.                                               
                                                                                
      *}                                                                        
015300 INPUT-OUTPUT SECTION.                                                    
015400 FILE-CONTROL.                                                            
      *{ Tr-Select-Sequential 1.3                                               
015500*    SELECT FDT-FILE        ASSIGN TO UT-S-IN3.                           
      *--                                                                       
           SELECT FDT-FILE        ASSIGN TO UT-S-IN3                            
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
015600*    SELECT PRNTR           ASSIGN TO UT-S-PRINTR1.                       
      *--                                                                       
           SELECT PRNTR           ASSIGN TO UT-S-PRINTR1                        
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
015700*    SELECT MASTER-IN-FILE  ASSIGN TO UT-S-IN1.                           
      *--                                                                       
           SELECT MASTER-IN-FILE  ASSIGN TO UT-S-IN1                            
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
015800*    SELECT MASTER-OUT-FILE ASSIGN TO UT-S-OUT1.                          
      *--                                                                       
           SELECT MASTER-OUT-FILE ASSIGN TO UT-S-OUT1                           
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
015900*    SELECT TRANS-OUT-FILE  ASSIGN TO UT-S-OUT2.                          
      *--                                                                       
           SELECT TRANS-OUT-FILE  ASSIGN TO UT-S-OUT2                           
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
016000*    SELECT TRANS-OUT-MSTR  ASSIGN TO UT-S-OUT3.                          
      *--                                                                       
           SELECT TRANS-OUT-MSTR  ASSIGN TO UT-S-OUT3                           
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
      *{ Tr-Select-Sequential 1.3                                               
016100*    SELECT TRANS-IN-FILE   ASSIGN TO UT-S-IN2.                           
      *--                                                                       
           SELECT TRANS-IN-FILE   ASSIGN TO UT-S-IN2                            
              ORGANIZATION LINE SEQUENTIAL.                                     
      *}                                                                        
016200 DATA DIVISION.                                                           
016300 FILE SECTION.                                                            
016400 FD  PRNTR                                                                
016500     RECORDING MODE IS F                                                  
016600     LABEL RECORDS ARE STANDARD                                           
016700     bLOCK CONTAINS 0 RECORDS                                             
016800     DATA RECORD IS PRINT                                                 
016810****COB370 CHANGE                                                 370     
016900**** RECORD 133 CHARACTERS.                                       370     
016910     RECORD 132 CHARACTERS.                                       370     
017000 01  PRINT.                                                               
017100**** 03  CRG-CTL                              PIC X.              370     
017120****COB370 END                                                    370     
017200     03  PRT                                  PIC X(132).                 
017300 FD  MASTER-IN-FILE                                                       
017400     RECORDING MODE IS F                                                  
017500     LABEL RECORDS ARE STANDARD                                           
017600     BLOCK CONTAINS 0 RECORDS                                             
017700     DATA RECORD IS MASTER-RECORD-IN.                                     
017800 01  MASTER-RECORD-IN.                                                    
017900     03  M-REC-ID                             PIC X.                      
018000     03  M-CLIENT                             PIC X(3).                   
018100     03  M-TC                                 PIC X(2).                   
018200     03  M-DATE.                                                          
018300       05  M-MO                               PIC 9(2).                   
018400       05  M-DAY                              PIC 9(2).                   
018500       05  M-YR                               PIC 9(2).                   
018600     03  M-SEQ-NUMBER                         PIC 9(3).                   
018700     03  FILLER                               PIC X(65).                  
018800     03  FILLER                               PIC X(48).                  
018900 FD  MASTER-OUT-FILE                                                      
019000     RECORDING MODE IS F                                                  
019100     LABEL RECORDS ARE STANDARD                                           
019200     BLOCK CONTAINS 0 RECORDS                                             
019300     DATA RECORD IS MASTER-RECORD-OUT.                                    
019400 01  MASTER-RECORD-OUT.                                                   
019500     03  FILLER                               PIC X(112).                 
019600     03  MSTR-UPD-FLD                         PIC X(16).                  
019700 FD  TRANS-IN-FILE                                                        
019800     RECORDING MODE IS F                                                  
019900     LABEL RECORDS ARE STANDARD                                           
020000     BLOCK CONTAINS 0 RECORDS                                             
020100     DATA RECORD IS TRANS-RECORD.                                         
020200 01  TRANS-RECORD.                                                        
020300     03  T-REC-ID                             PIC X.                      
020400     03  T-CLIENT                             PIC X(3).                   
020500     03  T-TC                                 PIC X(2).                   
020600       88  ADD-TRANSACTION         VALUE '01'.                            
020700       88  DELETE-TRANSACTION      VALUE '02'.                            
020800       88  MODIFY-TRANSACTION      VALUE '03'.                            
020900     03  T-DATE                               PIC X(6).                   
021000     03  T-SEQ-NUMBER                         PIC 9(3).                   
021100     03  FILLER                               PIC X(97).                  
021200     03  T-SYSTEM-FLAGS                       PIC X(16).                  
021300 FD  TRANS-OUT-FILE                                                       
021400     RECORDING MODE IS F                                                  
021500     LABEL RECORDS ARE STANDARD                                           
021600     BLOCK CONTAINS 0 RECORDS                                             
021700     DATA RECORD IS TRANS-REC-FLAGGED.                                    
021800 01  TRANS-REC-FLAGGED.                                                   
021900     03  FILLER                               PIC X(114).                 
022000     03  TF-SYS-FLAGS.                                                    
022100       05  TF-MAINT-FLAG                      PIC XX.                     
022200       05  FILLER                             PIC X(12).                  
022300 FD  TRANS-OUT-MSTR                                                       
022400     RECORDING MODE IS F                                                  
022500     LABEL RECORDS ARE STANDARD                                           
022600     BLOCK CONTAINS 0 RECORDS                                             
022700     DATA RECORD IS TRANS-OUT-MSTR-RCD.                                   
022800 01  TRANS-OUT-MSTR-RCD.                                                  
022900     03  FILLER                               PIC X(128).                 
023000 FD  FDT-FILE                                                             
023100     RECORDING MODE IS F                                                  
023200     LABEL RECORDS ARE STANDARD                                           
023300     BLOCK CONTAINS 0 RECORDS                                             
023400     DATA RECORD IS FDT-RECORD.                                           
023500 01  FDT-RECORD.                                                          
023600     03  FILLER                               PIC X(80).                  
023700******************************************************************        
023800******************************************************************        
023900 WORKING-STORAGE SECTION.                                                 
024000 01  DEBUG-AID1.                                                          
024100   03  FILLER                    PIC X(44)          VALUE                 
024200                   '*** BDMS0201 WORKING STORAGE BEGINS HERE ***'.        
024300 01  COMPILE-DATE                PIC X(20).                               
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024400*01  FDT-REC-INDEX               PIC 9999           COMP.                 
      *--                                                                       
       01  FDT-REC-INDEX               PIC 9(18) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024500*01  FDT-FIELD-INDEX             PIC 9999           COMP.                 
      *--                                                                       
       01  FDT-FIELD-INDEX             PIC 9(18) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024600*01  CLIENT-CODE-LENGTH          PIC 9999           COMP.                 
      *--                                                                       
       01  CLIENT-CODE-LENGTH          PIC 9(18) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024700*01  CLIENT-PTR                  PIC 9999           COMP.                 
      *--                                                                       
       01  CLIENT-PTR                  PIC 9(18) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024800*01  KEY-PTR                     PIC 9999           COMP.                 
      *--                                                                       
       01  KEY-PTR                     PIC 9(18) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
024900*01  COMPONENT-INDEX             PIC 9999           COMP.                 
      *--                                                                       
       01  COMPONENT-INDEX             PIC 9(4) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
025000*01  RECORD-PTR                  PIC 9999           COMP.                 
      *--                                                                       
       01  RECORD-PTR                  PIC 9(18) COMP-5.                         
      *}                                                                        
025100 01  HOLD-DATE.                                                           
025200     03  H-MM                    PIC XX.                                  
025300     03  FILLER                  PIC X.                                   
025400     03  H-DD                    PIC XX.                                  
025500     03  FILLER                  PIC X.                                   
025600     03  H-YY                    PIC XX.                                  
025700 01  STATIC-DATA.                                                         
025800     03  UPD-DATE.                                                        
025900         05  UPD-MM              PIC XX.                                  
026000         05  UPD-DD              PIC XX.                                  
026100         05  UPD-YY              PIC XX.                                  
026200     03  FILLER                  PIC X(10)          VALUE SPACES.         
026300 01  MASTER-EOF-SW               PIC 9              VALUE 0.              
026400   88  MORE-MASTER-RECS             VALUE 0.                              
026500   88  MASTER-EOF                   VALUE 1.                              
026600 01  TRANS-EOF-SW                PIC 9              VALUE 0.              
026700   88  MORE-TRANS-RECS              VALUE 0.                              
026800   88  TRANS-EOF                    VALUE 1.                              
026900 01  FDT-EOF-SW                  PIC 9              VALUE 0.              
027000   88  MORE-FDT-RECS                VALUE 0.                              
027100   88  FDT-EOF                      VALUE 1.                              
027200 01  ADD-OUTSTNG                 PIC 9              VALUE 0.              
027300   88  NO-ADD-TR-OUTSTANDING        VALUE 0.                              
027400   88  ADD-TR-OUTSTANDING           VALUE 1.                              
027500 01  CHG-OUTSTNG                 PIC 9              VALUE 0.              
027600   88  NO-CHG-TR-OUTSTANDING        VALUE 0.                              
027700   88  CHG-TR-OUTSTANDING           VALUE 1.                              
027800 01  NEW-PAGE                    PIC X              VALUE '1'.            
027900 01  SINGLE-SP                   PIC X              VALUE ' '.            
028000 01  DBL-SP                      PIC X              VALUE '0'.            
028100 01  TRPL-SP                     PIC X              VALUE '-'.            
028200 01  BLANK-LINE                  PIC X(132)         VALUE SPACES.         
028300******************************************************************        
028400*** THIS SW INDICATES THE PRESENCE OR ABSENCE OF AN ASTERISK   ***        
028500*** IN THE FIRST BYTE OF THE FIELD                             ***        
028600******************************************************************        
028700 01  ASTER-INDICATOR             PIC 9              VALUE 0.              
028800   88  NO-ASTERISK                  VALUE 0.                              
028900   88  ASTERISK-FOUND               VALUE 1.                              
029000 01  BLANK-INDICATOR             PIC 9              VALUE 0.              
029100   88  BLANKS-ONLY                  VALUE 0.                              
029200   88  NON-BLANK-FOUND              VALUE 1.                              
029300 01  KEY-VALIDITY-SW             PIC 9              VALUE 0.              
029400   88  VALID-KEY                    VALUE 0.                              
029500   88  INVALID-KEY                  VALUE 1.                              
029600 01  CLIENT-BREAK-SW             PIC 9              VALUE 0.              
029700   88  SAME-CLIENT                  VALUE 0.                              
029800   88  CLIENT-BREAK                 VALUE 1.                              
029900******************************************************************        
030000***  THIS AREA IS USED TO ACCUMULATE COUNTS FOR VARIOUS FILES  ***        
030100******************************************************************        
030200 01  RECORD-COUNTERS.                                                     
030300     03  T-READ-CNT              PIC 9(15).                                
030400     03  T-WRITTEN-CNT           PIC 9(15).                                
030500     03  T-BYPASS-CNT            PIC 9(15).                                
030600     03  INVALID-T-KEY-CNT       PIC 9(15).                                
030700     03  INVALID-T-TC-CNT        PIC 9(15).                                
030800     03  GOOD-ADD-CNT            PIC 9(15).                                
030900     03  INVALID-ADD-CNT         PIC 9(15).                                
031000     03  GOOD-DEL-CNT            PIC 9(15).                                
031100     03  INVALID-DEL-CNT         PIC 9(15).                                
031200     03  GOOD-MOD-CNT            PIC 9(15).                                
031300     03  INVALID-MOD-CNT         PIC 9(15).                                
031400     03  M-READ-CNT              PIC 9(15).                                
031500     03  M-WRITTEN-CNT           PIC 9(15).                                
031600     03  TM-WRITTEN-CNT          PIC 9(08).                                
031700******************************************************************        
031800*** THE AG PREFIX BELOW STANDS FOR AGGREGATE TOTALS            ***        
031900******************************************************************        
032000 01  AGGREGATE-RCD-CTRS.                                                  
032100     03  AG-BAD-T-KEY-CNT        PIC 9(15).                                
032200     03  AG-BAD-T-TC-CNT         PIC 9(15).                                
032300     03  AG-GOOD-ADD-CNT         PIC 9(15).                                
032400     03  AG-BAD-ADD-CNT          PIC 9(15).                                
032500     03  AG-GOOD-DEL-CNT         PIC 9(15).                                
032600     03  AG-BAD-DEL-CNT          PIC 9(15).                                
032700     03  AG-GOOD-MOD-CNT         PIC 9(15).                                
032800     03  AG-BAD-MOD-CNT          PIC 9(15).                                
032900     03  TOTAL-VALID             PIC 9(15).                                
033000     03  TOTAL-ERRORS            PIC 9(15).                                
033100     03  TOTAL-SUM               PIC 9(15).                                
033200 01  EOF-INDICATOR               PIC 9              VALUE 1.              
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
033300*01  LINECNT                     PIC 9999         COMP VALUE ZERO.        
      *--                                                                       
       01  LINECNT                     PIC 9(4) COMP-5 VALUE ZERO.              
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
033400*01  LOOP-CNT                    PIC 9999         COMP VALUE ZERO.        
      *--                                                                       
       01  LOOP-CNT                    PIC 9(4) COMP-5 VALUE ZERO.              
      *}                                                                        
033500 01  MASTER-KEY                  PIC X(40)      VALUE HIGH-VALUES.        
033600 01  TRANS-KEY                   PIC X(40)          VALUE SPACES.         
033700 01  NEW-REC-KEY                 PIC X(40)          VALUE SPACES.         
033800 01  CTR-LENGTH                  PIC 99      VALUE 15.                    
033900 01  CTR-PTR                     PIC 99.                                  
034000 01  CTR-PTR-MV                  PIC 99.                                  
034100 01  MASTER-HOLD.                                                         
034200     03  FILLER                  PIC X(128).                              
034300 01  ABEND-COUNTER.                                                       
034400     03  ABEND-CTR               PIC 9.                                   
034500 01  FLD-ACCUMULATOR.                                                     
034600   03  FLD-ACC  OCCURS 15 TIMES  PIC 9.                                   
034700 01  FIELD-SIGN                  PIC X.                                   
034800 01  FILLER REDEFINES FIELD-SIGN.                                         
034900     03  SIGN-POSITION           PIC S9.                                  
035000 01  MSTR-SIGNED-FLD             PIC S9(15).                              
035100 01  FILLER REDEFINES MSTR-SIGNED-FLD.                                    
035200   03  M-CTR    OCCURS  15 TIMES PIC X.                                   
035300 01  TRAN-SIGNED-FLD             PIC S9(15).                              
035400 01  FILLER REDEFINES TRAN-SIGNED-FLD.                                    
035500   03  T-CTR    OCCURS  15 TIMES PIC X.                                   
035600******************************************************************        
035700***  FILE DEFINITION RECS (FDT)   ---  80 BYTES                ***        
035800******************************************************************        
035900 01  FILE-KEY-DESCRIPTOR.                                                 
036000   03  FB1-FILE-ID               PIC X.                                   
036100   03  FB1-SEQ-NUMB              PIC X(3).                                
036200   03  FB1-FIELD-NO              PIC 99.                                  
036300   03  FILLER                    PIC X(4).                                
036400   03  FB1-FIELD-DEFNS OCCURS 14 TIMES.                                   
036500******************************************************************        
036600* A=ALPHANUMERIC, N=NUMERIC, M=NUMERIC OR BLANK, S=SIGNED NUMERIC         
036700******************************************************************        
036800     05  FB1-FORMAT              PIC X.                                   
036900     05  FB1-LOCATION            PIC 99.                                  
037000     05  FB1-LENGTH              PIC 99.                                  
037100***                                                                       
037200 01  FIXED-FIELDS-DESCRIPTOR.                                             
037300   03  FB2-FILE-ID               PIC X.                                   
037400   03  FB2-SEQ-NUMB              PIC X(3).                                
037500   03  FB2-FIELD-NO              PIC 99.                                  
037600   03  FILLER                    PIC X(4).                                
037700   03  FB2-FIELD-DEFNS OCCURS 14 TIMES.                                   
037800     05  FB2-FORMAT              PIC X.                                   
037900     05  FB2-LOCATION            PIC 99.                                  
038000     05  FB2-LENGTH              PIC 99.                                  
038100***                                                                       
038200 01  FDT-NN-REC.                                                          
038300   03  FNN-FILE-ID               PIC X.                                   
038400   03  FNN-SEQ-NUMB              PIC 9(3).                                
038500   03  FNN-FIELD-NO              PIC 99.                                  
038600   03  FILLER                    PIC X(4).                                
038700   03  FNN-FIELD-DEFNS OCCURS 14 TIMES.                                   
038800     05  FNN-FORMAT              PIC X.                                   
038900     05  FNN-LOCATION            PIC 99.                                  
039000     05  FNN-LENGTH              PIC 99.                                  
039100******************************************************************        
039200***  THIS TABLE IS USED TO STORE FIELD DESCRIPTORS             ***        
039300******************************************************************        
039400 01  FDT-REC-ARRAY.                                                       
039500   02  FDT-FIELD-DESCRIPTORS OCCURS 999 TIMES.                            
039600     03  FXX-FILE-ID             PIC X.                                   
039700     03  FXX-SEQ-NUMB            PIC 9(3).                                
039800     03  FXX-FIELD-NO            PIC 99.                                  
039900     03  FILLER                  PIC X(4).                                
040000     03  FXX-FIELD-DEFNS OCCURS 14 TIMES.                                 
040100       05  FXX-FORMAT            PIC X.                                   
040200       05  FXX-LOCATION          PIC 99.                                  
040300       05  FXX-LENGTH            PIC 99.                                  
040400 01  HEADR1-LINE.                                                         
040500   03  FILLER                    PIC X(39)          VALUE SPACES.         
040600   03  H1                        PIC X(49)          VALUE                 
040700              'A C T I V I T Y   T O T A L S   B Y   C L I E N T'.        
040800   03  FILLER                    PIC X(44)          VALUE SPACES.         
040900 01  H2-LINE.                                                             
041000   03  FILLER                    PIC X(1)           VALUE SPACE.          
041100   03  Q                         PIC X(120)         VALUE                 
041200         'CLIENT     -------01---------  -------02---------   ----        
      -    '-03---------   ----INVALID------        ----TOTAL ACTIVITY--        
      -    '---'.                                                               
041500   03  FILLER                    PIC XXX            VALUE '---'.          
041600   03  FILLER                    PIC X(8)           VALUE SPACES.         
041700 01  H3-LINE.                                                             
041800   03  FILLER                    PIC X(3)           VALUE SPACES.         
041900   03  Z                         PIC X(120)         VALUE                 
042000         'ID       ADDITIONS   ERRORS  DELETIONS   ERRORS    CHANG        
042100-    'ES   ERRORS   T-KEY     T-CODE         VALID     ERRORS             
042200-    '  SU'.                                                              
042300   03  FILLER                    PIC A              VALUE 'M'.            
042400   03  FILLER                    PIC X(8)           VALUE SPACES.         
042500 01  DET1-LINE.                                                           
042600   03  FILLER                    PIC X(2)           VALUE SPACES.         
042700   03  P-CLIENT                  PIC X(3).                                
042800   03  FILLER                    PIC X(9)           VALUE SPACES.         
042900   03  F1                        PIC Z(6)9.                               
043000   03  FILLER                    PIC X(2)           VALUE SPACES.         
043100   03  F2                        PIC Z(6)9.                               
043200   03  FILLER                    PIC X(4)           VALUE SPACES.         
043300   03  F3                        PIC Z(6)9.                               
043400   03  FILLER                    PIC X(2)           VALUE SPACES.         
043500   03  F4                        PIC Z(6)9.                               
043600   03  FILLER                    PIC X(4)           VALUE SPACES.         
043700   03  F5                        PIC Z(6)9.                               
043800   03  FILLER                    PIC X(2)           VALUE SPACES.         
043900   03  F6                        PIC Z(6)9.                               
044000   03  FILLER                    PIC X(1)           VALUE SPACES.         
044100   03  F7                        PIC Z(6)9.                               
044200   03  FILLER                    PIC X(4)           VALUE SPACES.         
044300   03  F8                        PIC Z(6)9.                               
044400   03  FILLER                    PIC X(7)           VALUE SPACES.         
044500   03  TOT-VALID                 PIC Z(6)9          DISPLAY.              
044600   03  FILLER                    PIC X(4)           VALUE SPACES.         
044700   03  TOT-ERRORS                PIC Z(6)9.                               
044800   03  FILLER                    PIC X(4)           VALUE SPACES.         
044900   03  TOT-SUM                   PIC Z(6)9.                               
045000   03  FILLER                    PIC X(7)           VALUE SPACES.         
045100 01  MASTER-REC-ARRAY.                                                    
045200   03  RECORD-ELMNT      OCCURS 128 TIMES PIC X.                          
045300 01  TRANS-REC-ARRAY REDEFINES MASTER-REC-ARRAY.                          
045400   03  FILLER                    PIC X(128).                              
045500 01  PRE-DEFINED-REC-ARRAY REDEFINES MASTER-REC-ARRAY.                    
045600     03  PRE-DRA-ID              PIC XXXX.                                
045700     03  FILLER                  PIC X(8).                                
045800     03  PRE-DRA-SEQ.                                                     
045900         05  PRE-DRA-CLASS       PIC X.                                   
046000         05  FILLER              PIC XX.                                  
046100     03  PRE-DRA-EMPNO.                                                   
046200         05  PRE-DRA-VENDNO.                                              
046300             07  PRE-DRA-OBJ     PIC XX.                                  
046400             07  FILLER          PIC XXXX.                                
046500         05  FILLER              PIC X(6).                                
046600     03  PRE-DRA-R REDEFINES PRE-DRA-EMPNO.                               
046700         05  PRE-DRA-RCS1        PIC X(5).                                
046800         05  PRE-DRA-RCS2        PIC XX.                                  
046900         05  FILLER              PIC X(5).                                
047000     03  FILLER                  PIC X(53).                               
047100     03  PRE-DRA-FCAAAAA         PIC X(7).                                
047200     03  FILLER                  PIC XXXX.                                
047300     03  PRE-DRA-PPPPP           PIC X(5).                                
047400     03  FILLER                  PIC X(33).                               
047500 01  KEY-WORKAREA.                                                        
047600   03  KEY-WORK     OCCURS 40 TIMES  PIC X.                               
047700 01  PRE-DEFINED-KEY-AREA REDEFINES KEY-WORKAREA.                         
047800     03  PRE-DKA-C.                                                       
047900         05  PRE-DKA-C-ID        PIC XXXX.                                
048000         05  PRE-DKA-C-NNN.                                               
048100             07  PRE-DKA-C-SEQ   PIC XXX.                                 
048200             07  FILLER          PIC X(33).                               
048300     03  PRE-DKA-H REDEFINES PRE-DKA-C.                                   
048400         05  PRE-DKA-H-ID        PIC XXXX.                                
048500         05  PRE-DKA-H-NNN.                                               
048600             07  PRE-DKA-H-FCAAAAA PIC X(7).                              
048700             07  PRE-DKA-H-PPPPP PIC X(5).                                
048800             07  PRE-DKA-H-SEQ   PIC XXX.                                 
048900             07  FILLER          PIC X(21).                               
049000     03  PRE-DKA-E REDEFINES PRE-DKA-C.                                   
049100         05  PRE-DKA-E-ID        PIC XXXX.                                
049200         05  PRE-DKA-E-NNN.                                               
049300             07  PRE-DKA-E-EMPNO PIC X(12).                               
049400             07  PRE-DKA-E-SEQ   PIC XXX.                                 
049500             07  FILLER          PIC X(21).                               
049600     03  PRE-DKA-O REDEFINES PRE-DKA-C.                                   
049700         05  PRE-DKA-O-ID        PIC XXXX.                                
049800         05  PRE-DKA-O-NNN.                                               
049900             07  PRE-DKA-O-CLASS PIC X.                                   
050000             07  PRE-DKA-O-OBJ   PIC XX.                                  
050100             07  PRE-DKA-O-SEQ   PIC XXX.                                 
050200             07  FILLER          PIC X(30).                               
050300     03  PRE-DKA-R REDEFINES PRE-DKA-C.                                   
050400         05  PRE-DKA-R-ID        PIC XXXX.                                
050500         05  PRE-DKA-R-RCS1      PIC X(5).                                
050600         05  PRE-DKA-R-NNN.                                               
050700             07  PRE-DKA-R-RCS2  PIC XX.                                  
050800             07  PRE-DKA-R-SEQ   PIC XXX.                                 
050900             07  FILLER          PIC X(26).                               
051000     03  PRE-DKA-V REDEFINES PRE-DKA-C.                                   
051100         05  PRE-DKA-V-ID        PIC XXXX.                                
051200         05  PRE-DKA-V-NNN.                                               
051300             07  PRE-DKA-V-VENDNO PIC X(6).                               
051400             07  PRE-DKA-V-SEQ   PIC XXX.                                 
051500             07  FILLER          PIC X(27).                               
051600******************************************************************        
051700*** TR-CLIENT-CTLFLD IS FOR DETERMINING CLIENT BREAKS          ***        
051800******************************************************************        
051900 01  TR-CLIENT-CTLFLD                PIC XXX  VALUE HIGH-VALUES.          
052000 01  NEW-MASTER-REC-HOLD-AREA.                                            
052100   03  FILLER                    PIC X(128).                              
052200 01  MASTER-CHG-ARRAY.                                                    
052300   03  CHANGE-RECORD OCCURS 128 TIMES PIC X.                              
052400 01  MSTR-DATE-CHG REDEFINES MASTER-CHG-ARRAY.                            
052500   03  FILLER                    PIC X(112).                              
052600   03  MSTR-DATE-UPD             PIC X(16).                               
052700*****                                                                     
052800 01  RULE-CARD.                                                           
052900   03  R-FILE-ID                 PIC X.                                   
053000   03  R-SEQ-NUMB                PIC XXX.                                 
053100   03  R-FIELD-NO                PIC 99.                                  
053200   03  FILLER                    PIC X(4).                                
053300   03  R-FIELD-DEFNS OCCURS 14 TIMES.                                     
053400     05  R-FORMAT                PIC X.                                   
053500     05  R-LOCATION              PIC 99.                                  
053600     05  R-LENGTH                PIC 99.                                  
053700******************************************************************        
053800 01  EOJ-LINE1.                                                           
053900   03  FILLER                    PIC X(9)       VALUE 'TRANS-IN='.        
054000   03  F20                       PIC Z(6)9.                               
054100   03  FILLER                    PIC X(14)          VALUE SPACES.         
054200   03  FILLER                    PIC X(10)     VALUE 'TRANS-OUT='.        
054300   03  F21                       PIC Z(6)9.                               
054400   03  FILLER                    PIC X(33)          VALUE SPACES.         
054500   03  FILLER                   PIC X(15) VALUE 'TRANS-BYPASSED='.        
054600   03  F22                       PIC Z(6)9.                               
054700   03  FILLER                    PIC X(30)          VALUE SPACES.         
054800 01  EOJ-LINE2.                                                           
054900   03  F23                       PIC Z(6)9.                               
055000   03  FILLER                  PIC X(16) VALUE ' MASTERS-IN  +  '.        
055100   03  F24                       PIC Z(6)9.                               
055200   03  FILLER                   PIC X(15) VALUE ' ADDITIONS  -  '.        
055300   03  F25                       PIC Z(6)9.                               
055400   03  FILLER                PIC X(18) VALUE ' DELETIONS     =  '.        
055500   03  F26                       PIC Z(6)9.                               
055600   03  FILLER                    PIC X(12)   VALUE ' MASTERS-OUT'.        
055700   03  FILLER                    PIC X(43)          VALUE SPACES.         
055800 01  FLAG-SET.                                                            
055900   03  SEQNUMB-ERROR             PIC X              VALUE '0'.            
056000   03  DUPLICATE-ERROR           PIC X              VALUE '0'.            
056100   03  NO-MATCHING-MASTER        PIC X              VALUE '0'.            
056200   03  INVALID-TC                PIC X              VALUE '0'.            
056300   03  FIELD-EDIT-ERROR          PIC X              VALUE '0'.            
056400   03  FILLER                    PIC X              VALUE '0'.            
056500   03  FILLER                    PIC X              VALUE '0'.            
056600   03  FILLER                    PIC X              VALUE '0'.            
056700   03  FILLER                    PIC X              VALUE '0'.            
056800   03  FILLER                    PIC X              VALUE '0'.            
056900   03  FILLER                    PIC X              VALUE '0'.            
057000   03  FILLER                    PIC X              VALUE '0'.            
057100 01  ZERO-FLAGS.                                                          
057200   03  FILLER                    PIC X(12)   VALUE '000000000000'.        
057300 01  BINARY-FLAG.                                                         
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
057400*  02  FLAG-VALUE                PIC 9(4)           COMP.                 
      *--                                                                       
         02  FLAG-VALUE                PIC 9(4) COMP-5.                         
      *}                                                                        
057500 01  ZERO-FLAG.                                                           
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
057600*  03  NORMAL-PROCESSING-FLAG    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  NORMAL-PROCESSING-FLAG    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
057700 01  WORK-7-FLAGS.                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
057800*  03  T-MAINT-FLAG              PIC 9(4)           COMP.                 
      *--                                                                       
         03  T-MAINT-FLAG              PIC 9(4) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
057900*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058000*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058100*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058200*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058300*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058400*  03  FILLER                    PIC 9(4)           COMP VALUE 0.         
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5 VALUE 0.                 
      *}                                                                        
058500 01  WORK-8-FLAGS.                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058600*  03  BATCH-FLAG                PIC 9(4)           COMP.                 
      *--                                                                       
         03  BATCH-FLAG                PIC 9(4) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058700*  03  FILLER                    PIC 9(4)           COMP.                 
      *--                                                                       
         03  FILLER                    PIC 9(4) COMP-5.                         
      *}                                                                        
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
058800*  03  FORMAT-ACCT-FLAG          PIC 9(4)           COMP.                 
      *--                                                                       
         03  FORMAT-ACCT-FLAG          PIC 9(4) COMP-5.                         
      *}                                                                        
058900   03  FILLER                    PIC X(10).                               
058910****COB370 FIELDS                                                         
058911 01  CRG-CTL                     PIC X.                           370     
058920 01  DATE-ACCEPT.                                                 370     
058930      05  DATE-ACCEPT-YY       PIC XX.                            370     
058940      05  DATE-ACCEPT-MM       PIC XX.                            370     
058950      05  DATE-ACCEPT-DD       PIC XX.                            370     
058960 01  DATE-CURRENT.                                                370     
058970      05  DATE-CURRENT-MM      PIC XX.                            370     
058980      05  FILLER               PIC X VALUE '/'.                   370     
058990      05  DATE-CURRENT-DD      PIC XX.                            370     
058991      05  FILLER               PIC X VALUE '/'.                   370     
058992      05  DATE-CURRENT-YY      PIC XX.                            370     
058993****COB370 END                                                    370     
059000 LINKAGE SECTION.                                                         
059100 01  XYZ-POSTING-DATE-OVERRIDE.                                           
      *{ convert-comp-comp4-binary-to-comp5 1.8                                 
059200*    03  XYZ-PD-LEN              PIC S9(4)          COMP.                 
      *--                                                                       
           03  XYZ-PD-LEN              PIC S9(4) COMP-5.                        
      *}                                                                        
059300     03  XYZ-POST-DATE.                                                   
059400         05  XYZ-PD-MM           PIC XX.                                  
059500         05  XYZ-PD-DD           PIC XX.                                  
059600         05  XYZ-PD-YY           PIC XX.                                  
059700     03  XYZ-PD-OPTION           PIC X.                                   
059800******************************************************************        
059900 PROCEDURE DIVISION USING XYZ-POSTING-DATE-OVERRIDE.                      
060000******************************************************************        
060100***  THIS PARAGRAPH INITIATES VALUES, READS MASTER FILE AND    ***        
060200***  PROCESSES IT UNTIL THE END OF FILE                        ***        
060300******************************************************************        
060400 010-MAINLINE.                                                            
060500     PERFORM 100-HOUSEKEEPING.                                            
060600     PERFORM 410-MASTER-READ.                                             
060700     PERFORM 200-ACTIVITY-PROCESSING THRU 220-AP-EXIT                     
060800         UNTIL TRANS-EOF.                                                 
060900 050-TR-EOF-RTN.                                                          
061000     IF ADD-TR-OUTSTANDING                                                
061100       MOVE NEW-MASTER-REC-HOLD-AREA TO MASTER-RECORD-OUT                 
061200       PERFORM 420-MASTER-WRITE.                                          
061300     PERFORM 650-CLIENT-BREAK.                                            
061400     PERFORM 475-SYN-MASTER UNTIL MASTER-EOF.                             
061500 075-EOJ.                                                                 
061600     PERFORM 680-DISPLAY-OF-UPDATE-STATS.                                 
061700     CLOSE PRNTR  , MASTER-IN-FILE, MASTER-OUT-FILE,                      
061800           TRANS-IN-FILE,  TRANS-OUT-FILE, FDT-FILE,                      
061900           TRANS-OUT-MSTR.                                                
062000*    RESET TRACE.                                                         
062100     DISPLAY '    BDMS0201 END PROCESSING'.                               
      *{ Ba-Stop-Run-Statement 1.1                                              
062200*    STOP RUN.                                                            
      *--                                                                       
           EXIT PROGRAM.                                                        
      *}                                                                        
062300******************************************************************        
062400***  THIS PARAGRAPH INITIATES VALUES                           ***        
062500******************************************************************        
062600 100-HOUSEKEEPING.                                                        
062700     DISPLAY '    BDMS0201 BEGIN PROCESSING'.                             
062800     MOVE WHEN-COMPILED TO COMPILE-DATE.                                  
062900     DISPLAY '    VERSION....... ', COMPILE-DATE.                         
063000     MOVE ZEROS TO RECORD-COUNTERS, AGGREGATE-RCD-CTRS.                   
063010****COB370 CHANGE                                                 370     
063100**** MOVE CURRENT-DATE TO HOLD-DATE.                              370     
063110     ACCEPT DATE-ACCEPT FROM DATE.                                370     
063120     MOVE DATE-ACCEPT-YY TO DATE-CURRENT-YY.                      370     
063130     MOVE DATE-ACCEPT-MM TO DATE-CURRENT-MM.                      370     
063140     MOVE DATE-ACCEPT-DD TO DATE-CURRENT-DD.                      370     
063150     MOVE DATE-CURRENT TO HOLD-DATE.                              370     
063160****COB370 END                                                    370     
063200     IF XYZ-PD-LEN > ZERO                                                 
063300       IF XYZ-POST-DATE NUMERIC                                           
063400         MOVE XYZ-PD-MM TO H-MM                                           
063500         MOVE XYZ-PD-DD TO H-DD                                           
063600         MOVE XYZ-PD-YY TO H-YY.                                          
063700     MOVE H-MM         TO UPD-MM.                                         
063800     MOVE H-DD         TO UPD-DD.                                         
063900     MOVE H-YY         TO UPD-YY.                                         
064000     DISPLAY '    UPDATE DATE USED=' UPD-DATE.                            
064100     OPEN INPUT MASTER-IN-FILE, TRANS-IN-FILE, FDT-FILE,                  
064200          OUTPUT MASTER-OUT-FILE, TRANS-OUT-FILE, PRNTR  ,                
064300          TRANS-OUT-MSTR.                                                 
064400     READ FDT-FILE INTO FILE-KEY-DESCRIPTOR, AT END                       
064500       MOVE EOF-INDICATOR TO FDT-EOF-SW.                                  
064600     READ FDT-FILE INTO FIXED-FIELDS-DESCRIPTOR, AT END                   
064700       MOVE EOF-INDICATOR TO FDT-EOF-SW.                                  
064800     MOVE SPACES TO TR-CLIENT-CTLFLD.                                     
064900     PERFORM 660-HEADER-PRINT.                                            
065000     MOVE FB1-LENGTH (2) TO CLIENT-CODE-LENGTH.                           
065100     MOVE SPACES TO FDT-REC-ARRAY.                                        
065200     PERFORM 110-FDT-ARRAY-BUILD UNTIL FDT-EOF.                           
065300******************************************************************        
065400***  THIS PARAGRAPH STORES FDT FIELD DESCRIPTORS INTO TABLE    ***        
065500******************************************************************        
065600 110-FDT-ARRAY-BUILD.                                                     
065700     READ FDT-FILE INTO FDT-NN-REC AT END                                 
065800       MOVE EOF-INDICATOR TO FDT-EOF-SW.                                  
065900     IF MORE-FDT-RECS                                                     
066000       MOVE FNN-SEQ-NUMB TO FDT-REC-INDEX                                 
066100       MOVE FDT-NN-REC TO FDT-FIELD-DESCRIPTORS (FDT-REC-INDEX).          
066200******************************************************************        
066300***  THIS SECTION READS TRANS FILE, EDITS IT                   ***        
066400***  IF THE RECORD KEY IS VALID ONE, IT ADDS OR DELETES OR     ***        
066500***  MODIFIES THE MASTER RECORD OTHERWISE IT WRITES ERTRANS    ***        
066600***  RECORD TO SIGNIFY THE ERROR                               ***        
066700******************************************************************        
066800 200-ACTIVITY-PROCESSING SECTION.                                         
066900     READ TRANS-IN-FILE AT END                                            
067000       MOVE EOF-INDICATOR TO TRANS-EOF-SW                                 
067100       GO TO 220-AP-EXIT.                                                 
067200     ADD 1 TO T-READ-CNT.                                                 
067300     IF T-READ-CNT = 1                                                    
067400       MOVE T-CLIENT TO TR-CLIENT-CTLFLD                                  
067500       PERFORM 470-SYN-MSTR-RTN.                                          
067600     MOVE T-SYSTEM-FLAGS TO WORK-8-FLAGS.                                 
067700     IF BATCH-FLAG = NORMAL-PROCESSING-FLAG AND                           
067800          FORMAT-ACCT-FLAG = NORMAL-PROCESSING-FLAG                       
067900       MOVE TRANS-RECORD TO TRANS-REC-ARRAY                               
068000       PERFORM 510-KEY-BUILD THRU 520-KB-EXIT                             
068100       IF INVALID-KEY                                                     
068200         MOVE 0   TO KEY-VALIDITY-SW                                      
068300         MOVE '1' TO FIELD-EDIT-ERROR                                     
068400         ADD 1    TO INVALID-T-KEY-CNT                                    
068500         PERFORM 440-TR-WRITE                                             
068600       ELSE                                                               
068700         MOVE KEY-WORKAREA TO TRANS-KEY                                   
068800         PERFORM 630-CLIENT-BREAK-TEST                                    
068900         IF ADD-TRANSACTION OR DELETE-TRANSACTION OR                      
069000             MODIFY-TRANSACTION                                           
069100           PERFORM 210-SELECT-FN                                          
069200         ELSE                                                             
069300           MOVE '1' TO INVALID-TC                                         
069400           ADD 1    TO INVALID-T-TC-CNT                                   
069500           PERFORM 440-TR-WRITE                                           
069600     ELSE                                                                 
069700       ADD 1 TO T-BYPASS-CNT                                              
069800       MOVE ZERO-FLAGS TO FLAG-SET                                        
069900       ADD 1 TO INVALID-T-KEY-CNT                                         
070000       PERFORM 440-TR-WRITE.                                              
070100     GO TO 220-AP-EXIT.                                                   
070200******************************************************************        
070300***  DEPENDING ON THE THE TRANSACITON CODE (ADD,DELETE,OR      ***        
070400***  MODIFY) THIS PARAGRAPH PERFORMS ADD, DELETE AND MODITY    ***        
070500******************************************************************        
070600 210-SELECT-FN.                                                           
070700     IF ADD-TRANSACTION                                                   
070800       PERFORM 310-ADD-RTN                                                
070900     ELSE                                                                 
071000       IF DELETE-TRANSACTION                                              
071100         PERFORM 320-DELETE-RTN THRU 330-DR-EXIT                          
071200       ELSE                                                               
071300         PERFORM 350-MODIFY-RTN THRU 370-MR-EXIT.                         
071400 220-AP-EXIT.                                                             
071500     EXIT.                                                                
071600 300-FUNCTION SECTION.                                                    
071700******************************************************************        
071800*** THIS PARAGRAPH VALIDATES AND ADDS RECORD TO THE FILE        **        
071900******************************************************************        
072000 310-ADD-RTN.                                                             
072100     IF ADD-TR-OUTSTANDING AND NEW-REC-KEY = TRANS-KEY                    
072200       MOVE '1' TO DUPLICATE-ERROR                                        
072300       ADD 1 TO INVALID-ADD-CNT                                           
072400       PERFORM 440-TR-WRITE                                               
072500     ELSE                                                                 
072600       PERFORM 315-ADD-OUTSTANDING-TEST                                   
072700       PERFORM 430-MASTER-WRITE-READ UNTIL                                
072800         MASTER-EOF OR MASTER-KEY NOT < TRANS-KEY                         
072900       IF MASTER-EOF OR MASTER-KEY NOT = TRANS-KEY                        
073000         PERFORM 560-TR-SEQ-CHECK                                         
073100         PERFORM 570-TR-FIELD-EDIT                                        
073200         MOVE ZERO-FLAGS TO FLAG-SET                                      
073300         MOVE TRANS-RECORD TO NEW-MASTER-REC-HOLD-AREA                    
073400         MOVE TRANS-KEY TO NEW-REC-KEY                                    
073500         ADD 1 TO GOOD-ADD-CNT                                            
073600         PERFORM 440-TR-WRITE                                             
073700         MOVE 1 TO ADD-OUTSTNG                                            
073800       ELSE                                                               
073900         MOVE '1' TO DUPLICATE-ERROR                                      
074000         ADD 1 TO INVALID-ADD-CNT                                         
074100         PERFORM 440-TR-WRITE.                                            
074200 315-ADD-OUTSTANDING-TEST.                                                
074300     IF ADD-TR-OUTSTANDING AND NEW-REC-KEY NOT = TRANS-KEY                
074400       MOVE NEW-MASTER-REC-HOLD-AREA TO MASTER-RECORD-OUT                 
074500       PERFORM 420-MASTER-WRITE                                           
074600       MOVE 0 TO ADD-OUTSTNG.                                             
074700******************************************************************        
074800*** THIS PARAGRAPH VALIDATES AND DELETE RECORD FROM THE FILE    **        
074900******************************************************************        
075000 320-DELETE-RTN.                                                          
075100     IF NO-ADD-TR-OUTSTANDING                                             
075200       IF MASTER-EOF OR MASTER-KEY > TRANS-KEY                            
075300         MOVE '1' TO NO-MATCHING-MASTER                                   
075400         PERFORM 440-TR-WRITE                                             
075500         ADD 1 TO INVALID-DEL-CNT                                         
075600       ELSE                                                               
075700         IF MASTER-KEY = TRANS-KEY                                        
075800           ADD 1 TO GOOD-DEL-CNT                                          
075900           MOVE ZERO-FLAGS TO FLAG-SET                                    
076000           PERFORM 440-TR-WRITE                                           
076100           PERFORM 410-MASTER-READ                                        
076200           GO TO 330-DR-EXIT                                              
076300         ELSE                                                             
076400           PERFORM 430-MASTER-WRITE-READ                                  
076500           GO TO 320-DELETE-RTN                                           
076600     ELSE                                                                 
076700       IF NEW-REC-KEY > TRANS-KEY                                         
076800         DISPLAY 'TRANS INPUT OUT OF SEQUENCE'                            
076900         GO TO 999-ABEND                                                  
077000       ELSE                                                               
077100         IF NEW-REC-KEY = TRANS-KEY                                       
077200           ADD 1 TO GOOD-DEL-CNT                                          
077300           MOVE ZERO-FLAGS TO FLAG-SET                                    
077400           PERFORM 440-TR-WRITE                                           
077500           MOVE 0 TO ADD-OUTSTNG                                          
077600           GO TO 330-DR-EXIT                                              
077700         ELSE                                                             
077800           MOVE NEW-MASTER-REC-HOLD-AREA TO MASTER-RECORD-OUT             
077900           PERFORM 420-MASTER-WRITE                                       
078000           MOVE 0 TO ADD-OUTSTNG                                          
078100           GO TO 320-DELETE-RTN.                                          
078200 330-DR-EXIT.                                                             
078300     EXIT.                                                                
078400******************************************************************        
078500*** THIS PARAGRAPH VALIDATES AND MODIFY RECORD IN THE FILE      **        
078600******************************************************************        
078700 350-MODIFY-RTN. 
078800     IF ADD-TR-OUTSTANDING                                                
078900       IF NEW-REC-KEY = TRANS-KEY                                         
079000         GO TO 360-MODIFY-TR                                              
079100       ELSE
079200         IF NEW-REC-KEY < TRANS-KEY                                       
079300           MOVE NEW-MASTER-REC-HOLD-AREA TO MASTER-RECORD-OUT             
079400           PERFORM 420-MASTER-WRITE                                       
079500           MOVE 0  TO ADD-OUTSTNG                                         
079600           GO TO 350-MODIFY-RTN                                           
079700         ELSE                                                             
079800           DISPLAY 'TRANS INPUT OUT-OF-SEQ'                               
079900           GO TO 999-ABEND                                                
080000     ELSE                                                                 
080100       PERFORM 430-MASTER-WRITE-READ UNTIL                                
080200         MASTER-EOF  OR MASTER-KEY NOT < TRANS-KEY                        
080300       IF MASTER-EOF OR MASTER-KEY NOT = TRANS-KEY                        
080400         MOVE '1' TO NO-MATCHING-MASTER                                   
080500         PERFORM 440-TR-WRITE                                             
080600         ADD 1 TO INVALID-MOD-CNT                                         
080700         GO TO 370-MR-EXIT.                                               
080800 360-MODIFY-TR.                                                           
080900     PERFORM 560-TR-SEQ-CHECK.                                            
081000     PERFORM 570-TR-FIELD-EDIT.                                           
081100     MOVE STATIC-DATA TO MSTR-DATE-UPD.                                   
081200     MOVE 1  TO CHG-OUTSTNG.                                              
081300     IF ADD-TR-OUTSTANDING                                                
081400       MOVE MASTER-CHG-ARRAY TO NEW-MASTER-REC-HOLD-AREA                  
081500       MOVE TRANS-KEY TO NEW-REC-KEY                                      
081600     ELSE                                                                 
081700       MOVE MASTER-CHG-ARRAY TO MASTER-RECORD-IN.                         
081800     ADD 1 TO GOOD-MOD-CNT.                                               
081900     MOVE ZERO-FLAGS TO FLAG-SET.                                         
082000     PERFORM 440-TR-WRITE.                                                
082100 370-MR-EXIT.                                                             
082200     EXIT.                                                                
082300 400-I-O SECTION.                                                         
082400******************************************************************        
082500***  THIS PARAGRAPH READS MASTER FILE, BUILD THE MATCH KEY     ***        
082600***  IF KEY IS INVALID THEN DISPLAY MESSAGE AND RUN TERMINATES ***        
082700******************************************************************        
082800 410-MASTER-READ.                                                         
082900     READ MASTER-IN-FILE INTO MASTER-HOLD AT END                          
083000       MOVE EOF-INDICATOR TO MASTER-EOF-SW.                               
083100     IF MORE-MASTER-RECS                  
083200       MOVE MASTER-RECORD-IN TO MASTER-REC-ARRAY                          
083300       PERFORM 510-KEY-BUILD THRU 520-KB-EXIT                             
083400       ADD 1 TO M-READ-CNT                                                
083500       IF INVALID-KEY                                                     
083600         DISPLAY 'MASTER RCD HAS INVALID FIELD DEF; A-N-M-S'              
083700         GO TO 999-ABEND                                                  
083800       ELSE                                                               
083900         MOVE KEY-WORKAREA TO MASTER-KEY.                                 
084000 420-MASTER-WRITE.                                                        
084100     MOVE STATIC-DATA TO MSTR-UPD-FLD.                                    
084200     MOVE  MASTER-RECORD-OUT TO TRANS-OUT-MSTR-RCD.                       
084300     WRITE MASTER-RECORD-OUT.                                             
084400     ADD 1 TO M-WRITTEN-CNT.                                              
084500     WRITE TRANS-OUT-MSTR-RCD.                                            
084600     ADD 1 TO TM-WRITTEN-CNT.                                             
084700 430-MASTER-WRITE-READ.                                                   
084800     IF CHG-TR-OUTSTANDING                                                
084900       MOVE 0 TO CHG-OUTSTNG                                              
085000       MOVE MASTER-RECORD-IN TO TRANS-OUT-MSTR-RCD                        
085100       WRITE TRANS-OUT-MSTR-RCD                                           
085200       ADD 1 TO TM-WRITTEN-CNT.                                           
085300     MOVE MASTER-RECORD-IN TO MASTER-RECORD-OUT.                          
085400     WRITE MASTER-RECORD-OUT.                                             
085500     ADD 1 TO M-WRITTEN-CNT.                
085600     PERFORM 410-MASTER-READ.                                             
085700******************************************************************        
085800***  THIS PARAGRAPH FIRST CALLS 'BDMSXX20' BY USING TWO FIELDS ***        
085900***  FLAG-SET AND BINARY-FLAG THEN WRITES TRANS RECORD         ***        
086000******************************************************************        
086100 440-TR-WRITE.                                                            
086200     MOVE TRANS-RECORD TO TRANS-REC-FLAGGED.                              
086300     CALL 'BDMSXX20' USING FLAG-SET, BINARY-FLAG.                         
086400     MOVE ZERO-FLAGS TO FLAG-SET.                                         
086500     MOVE FLAG-VALUE TO T-MAINT-FLAG.                                     
086600     MOVE BINARY-FLAG TO TF-MAINT-FLAG.                                   
086700     WRITE TRANS-REC-FLAGGED.                                             
086800     ADD 1 TO T-WRITTEN-CNT.                                              
086900***************************************************************           
087000** PARS 470 THRU 480 ARE USED TO SYNCHRONIZE THE MASTER FILE **           
087100** TO FIRST RECORD OF THE MATCHING TRAN BY USER CODE.        **           
087200***************************************************************           
087300 470-SYN-MSTR-RTN.                                                        
087400     IF (T-READ-CNT = 1 AND T-CLIENT < M-CLIENT) OR                       
087500        (CLIENT-BREAK  AND T-CLIENT < M-CLIENT)                           
087600       NEXT SENTENCE                                                      
087700     ELSE                                                                 
087800       PERFORM 475-SYN-MASTER UNTIL                                       
087900       MASTER-EOF OR T-CLIENT NOT < M-CLIENT                              
088000       IF M-READ-CNT > 0                                                  
088100         MOVE MASTER-HOLD TO MASTER-REC-ARRAY                             
088200         PERFORM 510-KEY-BUILD THRU 520-KB-EXIT                           
088300         IF INVALID-KEY                                                   
088400           DISPLAY 'MASTER RCD  FIELD DEF NOT =  A-N-M-S'                 
088500           GO TO 999-ABEND                                                
088600         ELSE                                                             
088700           MOVE KEY-WORKAREA TO MASTER-KEY.                               
088800 475-SYN-MASTER.                                                          
088900     IF CHG-TR-OUTSTANDING                                                
089000       MOVE 0 TO CHG-OUTSTNG                                              
089100       MOVE MASTER-RECORD-IN TO TRANS-OUT-MSTR-RCD                        
089200       WRITE TRANS-OUT-MSTR-RCD                                           
089300       ADD 1 TO TM-WRITTEN-CNT.                                           
089400     WRITE MASTER-RECORD-OUT FROM MASTER-RECORD-IN.                       
089500     ADD 1 TO M-WRITTEN-CNT.                                              
089600     IF MORE-MASTER-RECS                                                  
089700       PERFORM 480-SYN-MASTER-RD.                                         
089800 480-SYN-MASTER-RD.                                                       
089900     READ MASTER-IN-FILE INTO MASTER-HOLD AT END                          
090000       MOVE EOF-INDICATOR TO MASTER-EOF-SW.                               
090100     IF MORE-MASTER-RECS                                                  
090200       ADD 1 TO M-READ-CNT.                                               
090300 500-SERVICE-SUBROUTINES SECTION.                                         
090400****************************************************************          
090500** PARAGRAPHS 510-550 ARE USED TO BUILD THE MATCH KEYS USED FOR           
090600** MATCHING THE MASTER AND TRAN RECORDS.  UP TO 40 CHARACTERS             
090700** ARE GENERATED USING THE BLANK, BLANK 1 FDT RCD...THE MATCH             
090800** KEY THEN IS MOVED TO EITHER, MASTER-KEY OR TRANS-KEY.                  
090900**************************************************************            
091000 510-KEY-BUILD.                                                           
091100     MOVE ZEROS TO KEY-WORKAREA, KEY-VALIDITY-SW.                         
091200     MOVE 1 TO KEY-PTR, COMPONENT-INDEX.                                  
091300     IF FB1-FILE-ID = 'C'                                                 
091400       MOVE PRE-DRA-ID       TO PRE-DKA-C-ID                              
091500       MOVE PRE-DRA-SEQ      TO PRE-DKA-C-SEQ                             
091600       IF PRE-DKA-C-NNN NOT NUMERIC                                       
091700         MOVE 1 TO KEY-VALIDITY-SW                                        
091800         GO TO 520-KB-EXIT                                                
091900       ELSE                                                               
092000         NEXT SENTENCE                                                    
092100     ELSE                                                                 
092200     IF FB1-FILE-ID = 'E'                                                 
092300       MOVE PRE-DRA-ID       TO PRE-DKA-E-ID                              
092400       MOVE PRE-DRA-EMPNO    TO PRE-DKA-E-EMPNO                           
092500       MOVE PRE-DRA-SEQ      TO PRE-DKA-E-SEQ                             
092600       IF PRE-DKA-E-NNN NOT NUMERIC                                       
092700         MOVE 1 TO KEY-VALIDITY-SW                                        
092800         GO TO 520-KB-EXIT                                                
092900       ELSE                                                               
093000         NEXT SENTENCE                                                    
093100     ELSE                                                                 
093200     IF FB1-FILE-ID = 'H'                                                 
093300       MOVE PRE-DRA-ID       TO PRE-DKA-H-ID                              
093400       MOVE PRE-DRA-FCAAAAA  TO PRE-DKA-H-FCAAAAA                         
093500       MOVE PRE-DRA-PPPPP    TO PRE-DKA-H-PPPPP                           
093600       MOVE PRE-DRA-SEQ      TO PRE-DKA-H-SEQ                             
093700       IF PRE-DKA-H-NNN NOT NUMERIC                                       
093800         MOVE 1 TO KEY-VALIDITY-SW                                        
093900         GO TO 520-KB-EXIT                                                
094000       ELSE                                                               
094100         NEXT SENTENCE                                                    
094200     ELSE                                                                 
094300     IF FB1-FILE-ID = 'O'                                                 
094400       MOVE PRE-DRA-ID       TO PRE-DKA-O-ID                              
094500       MOVE PRE-DRA-CLASS    TO PRE-DKA-O-CLASS                           
094600       MOVE PRE-DRA-OBJ      TO PRE-DKA-O-OBJ                             
094700       MOVE PRE-DRA-SEQ      TO PRE-DKA-O-SEQ                             
094800       IF PRE-DKA-O-NNN NOT NUMERIC                                       
094900         MOVE 1 TO KEY-VALIDITY-SW                                        
095000         GO TO 520-KB-EXIT                                                
095100       ELSE                                                               
095200         NEXT SENTENCE                                                    
095300     ELSE                                                                 
095400     IF FB1-FILE-ID = 'R'                                                 
095500       MOVE PRE-DRA-ID       TO PRE-DKA-R-ID                              
095600       MOVE PRE-DRA-RCS1     TO PRE-DKA-R-RCS1                            
095700       MOVE PRE-DRA-RCS2     TO PRE-DKA-R-RCS2                            
095800       MOVE PRE-DRA-SEQ      TO PRE-DKA-R-SEQ                             
095900       IF PRE-DKA-R-NNN NOT NUMERIC                                       
096000         MOVE 1 TO KEY-VALIDITY-SW                                        
096100         GO TO 520-KB-EXIT                                                
096200       ELSE                                                               
096300         NEXT SENTENCE                                                    
096400     ELSE                                                                 
096500     IF FB1-FILE-ID = 'V'                                                 
096600       MOVE PRE-DRA-ID       TO PRE-DKA-V-ID                              
096700       MOVE PRE-DRA-VENDNO   TO PRE-DKA-V-VENDNO                          
096800       MOVE PRE-DRA-SEQ      TO PRE-DKA-V-SEQ                             
096900       IF PRE-DKA-V-NNN NOT NUMERIC                                       
097000         MOVE 1 TO KEY-VALIDITY-SW                                        
097100         GO TO 520-KB-EXIT                                                
097200       ELSE                                                               
097300         NEXT SENTENCE                                                    
097400     ELSE                                                                 
097500     PERFORM 530-COMPONENT-BUILD UNTIL                                    
097600       FB1-FORMAT (COMPONENT-INDEX) = SPACE.                              
097700 520-KB-EXIT.                                                             
097800     EXIT.                                                                
097900******************************************************************        
098000***  THIS PARAGRAPH BUILDS COMPONENTS ACCORDING TO FB1-FIELD-NO***        
098100******************************************************************        
098200 530-COMPONENT-BUILD.                                                     
098300     IF FB1-FIELD-NO > COMPONENT-INDEX OR FB1-FIELD-NO = 0                
098400       MOVE FB1-LOCATION (COMPONENT-INDEX) TO RECORD-PTR                  
098500     ELSE                                                                 
098600       ADD 100, FB1-LOCATION (COMPONENT-INDEX) GIVING                     
098700             RECORD-PTR.                                                  
098800     PERFORM 540-CHAR-EDIT-MV                                             
098900       FB1-LENGTH  (COMPONENT-INDEX) TIMES.                               
099000     ADD 1 TO COMPONENT-INDEX.                                            
099100******************************************************************        
099200***  THIS PARAGRAPH EDITS FORMAT FIELD AND MOVES ELEMENT TO    ***        
099300***  THE KEY WORKING AREA                                      ***        
099400******************************************************************        
099500 540-CHAR-EDIT-MV.                                                        
099600     IF FB1-FORMAT (COMPONENT-INDEX) = 'A'                                
099700         PERFORM 550-MV-CHAR                                              
099800     ELSE                                                                 
099900       IF FB1-FORMAT (COMPONENT-INDEX) = 'N'                              
100000         IF RECORD-ELMNT (RECORD-PTR) IS NUMERIC                          
100100           PERFORM 550-MV-CHAR                                            
100200         ELSE                                                             
100300           MOVE 1 TO KEY-VALIDITY-SW                                      
100400           GO TO 520-KB-EXIT                                              
100500       ELSE                                                               
100600         IF FB1-FORMAT (COMPONENT-INDEX) = 'M'                            
100700           IF RECORD-ELMNT (RECORD-PTR) IS NUMERIC OR                     
100800               RECORD-ELMNT (RECORD-PTR) = SPACE                          
100900             PERFORM 550-MV-CHAR                                          
101000           ELSE                                                           
101100             MOVE 1 TO KEY-VALIDITY-SW                                    
101200             GO TO 520-KB-EXIT                                            
101300         ELSE                                                             
101400           MOVE 1 TO KEY-VALIDITY-SW                                      
101500           GO TO 520-KB-EXIT.                                             
101600 550-MV-CHAR.                                        
101700     MOVE RECORD-ELMNT (RECORD-PTR) TO KEY-WORK (KEY-PTR).                
101800     ADD 1 TO RECORD-PTR, KEY-PTR.                                        
101900***************************************************************           
102000** THIS PARAGRAPH VALIDATES THE RECORD SEQUENCE NUMBER IN THE             
102100** TRAN RCD FOR A RANGE OF 000 - 999 IN POSITION 13-15.                   
102200***************************************************************           
102300 560-TR-SEQ-CHECK.                                                        
102400     MOVE T-SEQ-NUMBER TO FDT-REC-INDEX.                                  
102500     IF T-SEQ-NUMBER IS NOT NUMERIC OR FDT-REC-INDEX >                    
102600       999 OR FDT-FIELD-DESCRIPTORS (FDT-REC-INDEX) = SPACES              
102700       MOVE '1' TO SEQNUMB-ERROR                                          
102800       PERFORM 440-TR-WRITE                                               
102900       IF ADD-TRANSACTION                                                 
103000         ADD 1 TO INVALID-ADD-CNT                                         
103100         GO TO 220-AP-EXIT                                                
103200       ELSE                                                               
103300         ADD 1 TO INVALID-MOD-CNT                                         
103400         GO TO 220-AP-EXIT.                                               
103500***************************************************************           
103600** PARAGRAPHS 570 - 596 ARE PERFORMED FOR EACH ADD OR MODIFY              
103700** TRANS, THE FIXED FDT DESCRIPTORS, AND THE FDT DECRRIPTIONS             
103800** ARE APPLIED TO THE MATCHING MASTER OR NEW MASTER, WHICH                
103900** THE CASE MAY BE                                                        
104000***************************************************************           
104100 570-TR-FIELD-EDIT.                                                       
104200     MOVE TRANS-RECORD TO TRANS-REC-ARRAY.                                
104300     IF MODIFY-TRANSACTION                                                
104400       IF ADD-TR-OUTSTANDING                                              
104500         MOVE NEW-MASTER-REC-HOLD-AREA TO MASTER-CHG-ARRAY                
104600       ELSE                                                               
104700         MOVE MASTER-RECORD-IN TO MASTER-CHG-ARRAY.                       
104800     MOVE FIXED-FIELDS-DESCRIPTOR TO RULE-CARD.                           
104900     MOVE 1 TO FDT-FIELD-INDEX.                                           
105000     PERFORM 580-FIELD-EDITS UNTIL                                        
105100       R-FORMAT (FDT-FIELD-INDEX) = SPACE OR                              
105200           FDT-FIELD-INDEX > 14.                                          
105300     MOVE 1 TO FDT-FIELD-INDEX.                                           
105400     MOVE FDT-FIELD-DESCRIPTORS (FDT-REC-INDEX) TO RULE-CARD.             
105500     PERFORM 580-FIELD-EDITS UNTIL                                        
105600       R-FORMAT (FDT-FIELD-INDEX) = SPACE OR                              
105700           FDT-FIELD-INDEX > 14.                                          
105800 580-FIELD-EDITS.                                                         
105900     IF R-FIELD-NO > FDT-FIELD-INDEX OR R-FIELD-NO = 0                    
106000       MOVE R-LOCATION (FDT-FIELD-INDEX) TO RECORD-PTR                    
106100     ELSE                                                                 
106200       ADD 100, R-LOCATION (FDT-FIELD-INDEX) GIVING RECORD-PTR.           
106300     MOVE 0 TO BLANK-INDICATOR, LOOP-CNT, ASTER-INDICATOR.                
106400     IF MODIFY-TRANSACTION                                                
106500       MOVE 1 TO LOOP-CNT                                                 
106600       PERFORM 600-ASTER-SEARCH-RTN                                       
106700       IF ASTERISK-FOUND                                                  
106800         MOVE 0 TO ASTER-INDICATOR                                        
106900       ELSE                                                               
107000         PERFORM 583-FIELD-EDIT                                           
107100     ELSE                                                                 
107200       PERFORM 590-CHAR-EDIT THRU 596-C-EXIT                              
107300             R-LENGTH (FDT-FIELD-INDEX) TIMES.                            
107400     ADD 1 TO FDT-FIELD-INDEX.                                            
107500******************************************************************        
107600***  THIS PARAGRAPH EDITS FIELD IF FIELD IS NOT BLANK THEN     ***        
107700***  IT SETS UP THE LENGTH                                     ***        
107800******************************************************************        
107900 583-FIELD-EDIT.                                                          
108000     PERFORM 620-SPACE-COMP-RTN UNTIL                                     
108100       NON-BLANK-FOUND OR LOOP-CNT > R-LENGTH (FDT-FIELD-INDEX).          
108200     IF NON-BLANK-FOUND                                                   
108300       MOVE 0 TO BLANK-INDICATOR, LOOP-CNT,                               
108400           MSTR-SIGNED-FLD, TRAN-SIGNED-FLD                               
108500       COMPUTE CTR-PTR =                                                  
108600         CTR-LENGTH - R-LENGTH (FDT-FIELD-INDEX) + 1                      
108700       MOVE CTR-PTR TO CTR-PTR-MV                                         
108800       PERFORM 590-CHAR-EDIT THRU 596-C-EXIT                              
108900             R-LENGTH (FDT-FIELD-INDEX) TIMES                             
109000       IF LOOP-CNT > 0                                                    
109100         ADD TRAN-SIGNED-FLD TO MSTR-SIGNED-FLD                           
109200         SUBTRACT R-LENGTH (FDT-FIELD-INDEX) FROM RECORD-PTR              
109300         PERFORM 585-MV-SIGN-FLD                                          
109400           R-LENGTH (FDT-FIELD-INDEX) TIMES.                              
109500 585-MV-SIGN-FLD.                                                         
109600     MOVE M-CTR (CTR-PTR-MV) TO CHANGE-RECORD (RECORD-PTR).               
109700     ADD 1 TO CTR-PTR-MV, RECORD-PTR.                                     
109800******************************************************************        
109900***  THIS EDITS FORMAT FIELD IF IT DOESN'T PASS TESTS THEN     ***        
110000***  RECORD IS WRITTEN INTO PRINT FILE TO SIGNIFY THE ERROR    ***        
110100******************************************************************        
110200 590-CHAR-EDIT.                                                           
110300     IF R-FORMAT (FDT-FIELD-INDEX) = 'A'                                  
110400       GO TO 595-CHAR-OK.                                                 
110500     IF R-FORMAT (FDT-FIELD-INDEX) = 'N' AND                              
110600         RECORD-ELMNT (RECORD-PTR) IS NUMERIC                             
110700       GO TO 595-CHAR-OK.                                                 
110800     IF R-FORMAT (FDT-FIELD-INDEX) = 'M' AND                              
110900        (RECORD-ELMNT (RECORD-PTR) IS NUMERIC OR                          
111000        RECORD-ELMNT (RECORD-PTR) = SPACE)                                
111100       GO TO 595-CHAR-OK.                                                 
111200     IF R-FORMAT (FDT-FIELD-INDEX) = 'S' AND                              
111300        RECORD-ELMNT (RECORD-PTR) IS NUMERIC                              
111400        ADD 1 TO LOOP-CNT                                                 
111500       GO TO 595-CHAR-OK.                                                 
111600     IF R-FORMAT (FDT-FIELD-INDEX) = 'S'                                  
111700       MOVE RECORD-ELMNT (RECORD-PTR) TO FIELD-SIGN                       
111800       ADD 1 TO LOOP-CNT                                                  
111900       IF R-LENGTH (FDT-FIELD-INDEX) = LOOP-CNT                           
112000         IF SIGN-POSITION POSITIVE OR SIGN-POSITION ZERO                  
112100           OR SIGN-POSITION NEGATIVE  GO TO 595-CHAR-OK.                  
112200     MOVE '1' TO FIELD-EDIT-ERROR.                                        
112300     PERFORM 440-TR-WRITE.                                                
112400     IF ADD-TRANSACTION                                                   
112500       ADD 1 TO INVALID-ADD-CNT                                           
112600     ELSE                                                                 
112700       ADD 1 TO INVALID-MOD-CNT.                                          
112800     GO TO 220-AP-EXIT.                                                   
112900 595-CHAR-OK.                                                             
113000     IF MODIFY-TRANSACTION                                                
113100       IF LOOP-CNT = 0                                                    
113200         MOVE RECORD-ELMNT (RECORD-PTR) TO                                
113300         CHANGE-RECORD (RECORD-PTR)                                       
113400       ELSE                                                               
113500         MOVE RECORD-ELMNT (RECORD-PTR) TO T-CTR (CTR-PTR)                
113600         MOVE CHANGE-RECORD (RECORD-PTR) TO M-CTR (CTR-PTR)               
113700         ADD 1 TO CTR-PTR.                                                
113800     ADD 1 TO RECORD-PTR.                                                 
113900 596-C-EXIT.                                                              
114000     EXIT.                                                                
114100***************************************************************           
114200**  PARAGRAPHS 600 - 610 ARE USED TO SET THE SELECTED MASTER              
114300**  FIELD TO SPACES WHEN THE MATCHING TRAN HAS AN '*' IN THE              
114400**  FIRST POSITION OF THE FIELD.                                          
114500***************************************************************           
114600 600-ASTER-SEARCH-RTN.                                                    
114700     IF RECORD-ELMNT (RECORD-PTR) = '*'                                   
114800       PERFORM 610-BLANK-CHAR-RTN R-LENGTH                                
114900             (FDT-FIELD-INDEX) TIMES                                      
115000       MOVE 1 TO ASTER-INDICATOR.                                         
115100 610-BLANK-CHAR-RTN.                                                      
115200     MOVE SPACE TO CHANGE-RECORD (RECORD-PTR).                            
115300     ADD 1 TO RECORD-PTR.                                                 
115400***************************************************************           
115500**  PARAGRAPH 620 DETERMINES IF A FIELD SPECIFIED BY A MODIFY             
115600**  TRAN IS NON BLANK BEFORE APPLYING FIELD TO MASTER                     
115700***************************************************************           
115800 620-SPACE-COMP-RTN.                                                      
115900     IF RECORD-ELMNT (RECORD-PTR) = SPACE                                 
116000       ADD 1 TO RECORD-PTR, LOOP-CNT                                      
116100     ELSE                                                                 
116200       SUBTRACT 1 FROM LOOP-CNT                                           
116300       SUBTRACT LOOP-CNT FROM RECORD-PTR                                  
116400       MOVE 1 TO BLANK-INDICATOR.                                         
116500 630-CLIENT-BREAK-TEST.                                                   
116600     IF T-CLIENT NOT = TR-CLIENT-CTLFLD                                   
116700       PERFORM 650-CLIENT-BREAK.                                          
116800 650-CLIENT-BREAK.                                                        
116900     PERFORM 670-DETAIL-PRINT.                                            
117000     MOVE T-CLIENT TO TR-CLIENT-CTLFLD.                                   
117100     ADD INVALID-T-KEY-CNT TO AG-BAD-T-KEY-CNT.                           
117200     ADD INVALID-T-TC-CNT  TO AG-BAD-T-TC-CNT.                            
117300     MOVE ZEROS TO INVALID-T-TC-CNT, INVALID-T-KEY-CNT.                   
117400     ADD GOOD-ADD-CNT    TO AG-GOOD-ADD-CNT.                              
117500     ADD INVALID-ADD-CNT TO AG-BAD-ADD-CNT.                               
117600     ADD GOOD-DEL-CNT    TO AG-GOOD-DEL-CNT.                              
117700     ADD INVALID-DEL-CNT TO AG-BAD-DEL-CNT.                               
117800     ADD GOOD-MOD-CNT    TO AG-GOOD-MOD-CNT.                              
117900     ADD INVALID-MOD-CNT TO AG-BAD-MOD-CNT.                               
118000     MOVE ZEROS TO GOOD-ADD-CNT, INVALID-ADD-CNT,                         
118100           GOOD-MOD-CNT, INVALID-MOD-CNT,                                 
118200           GOOD-DEL-CNT, INVALID-DEL-CNT.                                 
118300     MOVE 1 TO CLIENT-BREAK-SW.                                           
118400     PERFORM 470-SYN-MSTR-RTN.                                            
118500     MOVE 0 TO CLIENT-BREAK-SW.                                           
118600******************************************************************        
118700***  THIS IS HEADING ROUTINE TO PRINT HEADINGS                 ***        
118800******************************************************************        
118900 660-HEADER-PRINT.                                                        
119000     MOVE HEADR1-LINE TO PRT.                                             
119100     MOVE NEW-PAGE TO CRG-CTL.                                            
119200     PERFORM 700-PRINT.                                                   
119300     MOVE H2-LINE TO PRT.                                                 
119400     MOVE TRPL-SP TO CRG-CTL.                                             
119500     PERFORM 700-PRINT.                                                   
119600     MOVE H3-LINE TO PRT.                                                 
119700     MOVE SINGLE-SP TO CRG-CTL.                                           
119800     PERFORM 700-PRINT.                                                   
119900     MOVE BLANK-LINE TO PRT.                                              
120000     MOVE DBL-SP TO CRG-CTL.                                              
120100     PERFORM 700-PRINT.                                                   
120200******************************************************************        
120300***  THIS IS DETAIL PRINT ROUTINE TO WRITE DETAIL LINE         ***        
120400******************************************************************        
120500 670-DETAIL-PRINT.                                                        
120600     MOVE TR-CLIENT-CTLFLD TO P-CLIENT.                                   
120700     MOVE GOOD-ADD-CNT TO F1.                                             
120800     MOVE GOOD-DEL-CNT TO F3.                                             
120900     MOVE GOOD-MOD-CNT TO F5.                                             
121000     MOVE INVALID-ADD-CNT TO F2.                                          
121100     MOVE INVALID-DEL-CNT TO F4.                                          
121200     MOVE INVALID-MOD-CNT TO F6.                                          
121300     MOVE INVALID-T-KEY-CNT TO F7.                                        
121400     MOVE INVALID-T-TC-CNT TO F8.                                         
121500     ADD GOOD-ADD-CNT, GOOD-DEL-CNT, GOOD-MOD-CNT                         
121600           GIVING TOTAL-VALID.                                            
121700     ADD INVALID-ADD-CNT, INVALID-DEL-CNT,                                
121800           INVALID-MOD-CNT, INVALID-T-KEY-CNT,                            
121900           INVALID-T-TC-CNT GIVING TOTAL-ERRORS.                          
122000     ADD TOTAL-VALID, TOTAL-ERRORS GIVING TOTAL-SUM.                      
122100     MOVE TOTAL-VALID TO TOT-VALID.                                       
122200     MOVE TOTAL-ERRORS TO TOT-ERRORS.                                     
122300     MOVE TOTAL-SUM TO TOT-SUM.                                           
122400     MOVE DET1-LINE TO PRT.                                               
122500     MOVE TRPL-SP TO CRG-CTL.                                             
122600     PERFORM 700-PRINT.                                                   
122700******************************************************************        
122800***  THIS PARAGRAPH DISPLAYS THE RUN STATISTICS                ***        
122900******************************************************************        
123000 680-DISPLAY-OF-UPDATE-STATS.                                             
123100     MOVE 'TOT' TO P-CLIENT.                                              
123200     MOVE AG-GOOD-ADD-CNT TO F1.                                          
123300     MOVE AG-GOOD-DEL-CNT TO F3.                                          
123400     MOVE AG-GOOD-MOD-CNT TO F5.                                          
123500     MOVE AG-BAD-ADD-CNT TO F2.                                           
123600     MOVE AG-BAD-DEL-CNT TO F4.                                           
123700     MOVE AG-BAD-MOD-CNT TO F6.                                           
123800     MOVE AG-BAD-T-KEY-CNT TO F7.                                         
123900     MOVE AG-BAD-T-TC-CNT TO F8.                                          
124000     ADD AG-GOOD-ADD-CNT, AG-GOOD-DEL-CNT,                                
124100           AG-GOOD-MOD-CNT GIVING TOTAL-VALID.                            
124200     ADD AG-BAD-ADD-CNT, AG-BAD-DEL-CNT,                                  
124300           AG-BAD-MOD-CNT, AG-BAD-T-KEY-CNT,                              
124400           AG-BAD-T-TC-CNT GIVING TOTAL-ERRORS.                           
124500     ADD TOTAL-VALID, TOTAL-ERRORS GIVING TOTAL-SUM.                      
124600     MOVE TOTAL-VALID TO TOT-VALID.                                       
124700     MOVE TOTAL-ERRORS TO TOT-ERRORS.                                     
124800     MOVE TOTAL-SUM TO TOT-SUM.                                           
124900     MOVE DET1-LINE TO PRT.                                               
125000     MOVE TRPL-SP TO CRG-CTL.                                             
125100     PERFORM 700-PRINT.                                                   
125200     MOVE T-READ-CNT TO F20.                                              
125300     MOVE T-WRITTEN-CNT TO F21.                                           
125400     MOVE T-BYPASS-CNT TO F22.                                            
125500     MOVE M-READ-CNT TO F23.                                              
125600     MOVE AG-GOOD-ADD-CNT TO F24.                                         
125700     MOVE AG-GOOD-DEL-CNT TO F25.                                         
125800     MOVE M-WRITTEN-CNT TO F26.                                           
125900     MOVE EOJ-LINE1 TO PRT.                                               
126000     MOVE NEW-PAGE TO CRG-CTL.                                            
126100     PERFORM 700-PRINT.                                                   
126200     MOVE EOJ-LINE2 TO PRT.                                               
126300     MOVE TRPL-SP TO CRG-CTL.                                             
126400     PERFORM 700-PRINT.                                                   
126500     DISPLAY TM-WRITTEN-CNT '....TRAN/MSTR CHANGE RCDS WRITTEN.'.         
126600 690-EXIT.                                                                
126700     EXIT.                                                                
126800 700-PRINT.                                                               
126810****COB370 CHANGE                                                 370     
126900**** WRITE PRINT AFTER POSITIONING CRG-CTL LINES.                 370     
127000     IF CRG-CTL = NEW-PAGE                                                
127010       WRITE PRINT AFTER ADVANCING TOP-OF-PAGE                    370     
127100       MOVE 1 TO LINECNT                                                  
127200     ELSE                                                                 
127300       IF CRG-CTL = SINGLE-SP                                             
127310         WRITE PRINT AFTER ADVANCING 1 LINE                       370     
127400         ADD 1 TO LINECNT                                                 
127500       ELSE                                                               
127600       IF CRG-CTL = DBL-SP                                                
127610         WRITE PRINT AFTER ADVANCING 2 LINES                      370     
127700         ADD 2 TO LINECNT                                                 
127800       ELSE                                                               
127810         WRITE PRINT AFTER ADVANCING 3 LINES                      370     
127900         ADD 3 TO LINECNT.                                                
127910****COB370 END                                                    370     
128000 999-ABEND.                                                               
128100     DISPLAY 'JOB BEING TERMINATED WITH S0C7 - SEE ABOVE MSG'             
128200     MOVE SPACE TO ABEND-COUNTER.                                         
128300     ADD 1 TO ABEND-CTR.                                                  
      *{ Ba-Stop-Run-Statement 1.1                                              
128400*    STOP RUN.                                                            
      *--                                                                       
           EXIT PROGRAM.                                                        
      *}                                                                        


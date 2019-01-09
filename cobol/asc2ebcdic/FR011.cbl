       IDENTIFICATION DIVISION.
*     *@ (c) Oracle:convert-buffer-rec.pgm. $Revision: 1.11 $
*     *Version with ZoneGroupe for numeric (display/packed) fields
       PROGRAM-ID. FR011.
       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.
       01  REC-LENGTH           PIC S9(4) COMP-5.
       01  DISCRIM-RULE-RESULT  PIC X(30) VALUE SPACE. 

      * Special process for display number.
      * Because here in rule, "sign leading" is right,
      * however, in copybook, always no "sign leading".
      * So have to use char type for "MOVE".
      * Please check how it is used in rule.
       01  MW-DISCRIM-TO-TRANSCODE.
           03 FILLER PIC X.
  
       01  CPY-LEN           PIC S9(8) COMP-5.
       01  TRANSCODE-STR     PIC X(40000).
       01  MW-CHECK-ONE-CHAR PIC X.
      
      $set sourceformat"free"
 COPY CONVERTMW.
$set sourceformat"fixed"


       01  MW-SORTIE-REC.
           02 FILE0-REC0.
              05 X-DATA01.
                   06 DATA01          PIC 9(4).
              05 DATA02               PIC X(4).
              05 X-DATA03.
                   06 DATA03          PIC 9(7)  COMP-3.


       LINKAGE SECTION.
       01  L-MW-ENTREE-REC.
           02 MW-BINARY-DATA.
              05 X-D-DATA01.
                   06 D-DATA01        PIC 9(4).
              05 D-DATA02             PIC X(4).
              05 X-D-DATA03.
                   06 D-DATA03        PIC 9(7)  COMP-3.
      *   CNV-LEN:    The length of the data needs conversion
      *               from the begining of the COPY book.
      *               It also returns the COPY book's length when:
      *                 1. CNV-LEN > COPY book's length.
      *                 2. CNV-LEN = 0
      *               In other cases, it keeps the input value.
       77 CNV-LEN                 PIC S9(8) COMP-5.

       PROCEDURE DIVISION USING L-MW-ENTREE-REC, CNV-LEN.

       MAIN-RTN.

      *      DISPLAY "===== INPUT PARAMETER =====".
      *      DISPLAY "CNV-LEN:     " CNV-LEN.
      *      DISPLAY "===========================".
           MOVE LENGTH OF L-MW-ENTREE-REC TO CPY-LEN.
           IF CNV-LEN > CPY-LEN THEN
             DISPLAY "== ERR: DATA is larger than COPY BOOK =="
             DISPLAY "        CNV-LEN:     " CNV-LEN
             DISPLAY "        CPY-LEN:     " CPY-LEN
             MOVE CPY-LEN TO CNV-LEN
           ELSE
             IF CNV-LEN > 0 THEN
                PERFORM MOVE-BINARY-VALUES-TO-COBOL THRU
                        E-MOVE-BINARY-VALUES-TO-COBOL
             ELSE
                MOVE CPY-LEN TO CNV-LEN
             END-IF
           END-IF.

           GOBACK.

      *  Process for conversion.
       MOVE-BINARY-VALUES-TO-COBOL.
           MOVE SPACES TO MW-SORTIE-REC



           MOVE 4 TO REC-LENGTH
           CALL 'art_a2e' using  X-D-DATA01,
                                      BY VALUE REC-LENGTH

           MOVE 4 TO REC-LENGTH
           CALL 'art_a2e' using  D-DATA02,
                                      BY VALUE REC-LENGTH

      * This is meaningless
           MOVE D-DATA03 TO DATA03
           .
       E-MOVE-BINARY-VALUES-TO-COBOL.
           EXIT.
      
      

       FIN-ERREUR.
           GOBACK.


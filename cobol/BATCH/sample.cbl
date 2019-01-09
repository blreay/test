       IDENTIFICATION DIVISION.
       PROGRAM-ID. sample.
       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
          01 COUNT-AA  PIC 9(7) COMP-5.
       PROCEDURE DIVISION.
       P-START.
          MOVE 500 TO COUNT-AA.
          DISPLAY "----START------".
          PERFORM AA THRU E-AA UNTIL COUNT-AA <10.
          DISPLAY "---BYE---------".
           EXIT PROGRAM RETURNING  0.

       AA.
          DISPLAY "---Inside AA-----" COUNT-AA "--".
          SUBTRACT 1 FROM COUNT-AA GIVING COUNT-AA.
          PERFORM BB.
       E-AA.
          EXIT.

       BB.
          DISPLAY "---Inside BB-----".
          GO TO E-AA.


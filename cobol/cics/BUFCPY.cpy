      **=============================================================**
      * Copybook for covsatmc / covsatms
      * Add alignment fillers for only ARTKIX / TMA integration
      * The alignment should be deleted on CICS (for TMA).
      **=============================================================**
            05  HEAD.
                10  ACH PIC X(1).
      * alignment for char Ach;
      *         10  FILLER PIC X(01).
                10  BSH PIC S9(4) COMP-5.
                10  CSTR PIC X(40).
      * alignment for char Cstr(9);
      *         10  FILLER PIC X(04).
            05  FILLER32.
                10  DLO32 PIC S9(9) COMP.
                10  ECA PIC X(20).
                10  FILLER REDEFINES ECA OCCURS 2 TIMES.
                    15  EACH PIC X(2).
                    15  EBSH PIC S9(4) COMP-5.
                    15  ECED PIC X(6).
                10  FFI PIC X(32000).
                10  FILLER PIC X(4).
            05  FILLER64 REDEFINES FILLER32.
                10  DLO64 PIC S9(18) COMP.
                10  ECA1 PIC X(20).
                10  FILLER REDEFINES ECA1 OCCURS 2 TIMES.
                    15  EACH1 PIC X(2).
                    15  EBSH1 PIC S9(4) COMP-5.
                    15  ECED1 PIC X(6).
                10  FFI1 PIC X(32000).

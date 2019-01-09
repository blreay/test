      **=============================================================**
      * Copybook for DATCLT / DATSVR
      **=============================================================**
            03  A-CHAR PIC X(01).
            03  B-SHORT PIC S9(4) COMP.
            03  C-STRING PIC X(40).
            03  D-LONG32 PIC S9(09) COMP.
            03  E-CARRAY PIC X(20).
            03  F-ZONED PIC 9(05)V99.
            03  FILLER REDEFINES F-ZONED.
                05  X-ZONED PIC X(07).
            03  G-FLOAT COMP-1.
            03  FILLER REDEFINES G-FLOAT.
                05  X-FLOAT PIC X(04).
            03  H-DOUBLE COMP-2.
            03  FILLER REDEFINES H-DOUBLE.
                05  X-DOUBLE PIC X(08).
            03  I-PACKED PIC S9(07)V99 COMP-3.
            03  FILLER REDEFINES I-PACKED.
                05  X-PACKED PIC X(05).

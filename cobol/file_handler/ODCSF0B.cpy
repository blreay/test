      * ------------------------------------------------------------
      * Customer's record description
      *  -Record's length : 266
      * ------------------------------------------------------------
       01 VS-ODCSF0-RECORD.
          05 VS-CUSTIDENT           PIC 9(006).
          05 VS-CUSTLNAME           PIC X(030).
          05 VS-CUSTFNAME           PIC X(020).
          05 VS-CUSTADDRS           PIC X(030).
          05 VS-CUSTCITY            PIC X(020).
          05 VS-CUSTSTATE           PIC X(002).
          05 VS-CUSTBDATE           PIC 9(008).
          05 VS-CUSTBDATE-G         REDEFINES VS-CUSTBDATE.
           10 VS-CUSTBDATE-CC PIC 9(002).
           10 VS-CUSTBDATE-YY PIC 9(002).
           10 VS-CUSTBDATE-MM PIC 9(002).
           10 VS-CUSTBDATE-DD PIC 9(002).
          05 VS-CUSTEMAIL           PIC X(040).
          05 VS-CUSTPHONE           PIC 9(010).
          05 VS-FILLER              PIC X(100).
      * ------------------------------------------------------------
      

#!/bin/bash

COB_HOME_MF=/opt/microfocus/cobol
COB_HOME_CIT=/newspace/shenhui/tools/cobol-it-3.3.13-b

# judge input parameter
if [ $# -ne 1 ]; then
   echo "Usage $0 MF|COBOL-IT"
   return 
fi

if [ $1 != "MF" -a $1 != "COBOL-IT" -a $1 != "CIT" ]; then
   echo "Usage $0 MF|COBOL-IT"
   return 
fi

if [ $1 = $COB ]; then
   return 
fi

if [ $1 = "CIT" ]; then
   COB=COBOL-IT
else
   COB=$1
fi

if [ $COB = "MF" ]; then
   COB_HOME=$COB_HOME_MF
   COBDIR=${COB_HOME}

   REPSTRING=${COB_HOME_CIT//\//\\\/}\/bin
   echo $PATH | grep -q $REPSTRING   
   if [ $? -eq 0 ]; then
      PATH=${PATH//:$REPSTRING/}
   fi
   PATH=$PATH:$COB_HOME/bin

   REPSTRING=${COB_HOME_CIT//\//\\\/}\/lib
   echo $LD_LIBRARY_PATH | grep -q $REPSTRING   
   if [ $? -eq 0 ]; then
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH//:$REPSTRING/}
   fi
   LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COB_HOME/lib

   REPSTRING=${COB_HOME_CIT//\//\\\/}\/share\/cobol-it\/copy
   echo $COBCPY | grep -q $REPSTRING
   if [ $? -eq 0 ]; then
      COBCPY=${COBCPY//:$REPSTRING/}
   fi
   COBCPY=$COBCPY:${COB_HOME}/cpylib

elif [ $COB = "COBOL-IT" ]; then
   COB_HOME=$COB_HOME_CIT
   COBDIR=${COB_HOME}

   REPSTRING=${COB_HOME_MF//\//\\\/}\/bin
   echo $PATH | grep -q $REPSTRING   
   if [ $? -eq 0 ]; then
      PATH=${PATH//:$REPSTRING/}
   fi
   PATH=$PATH:$COB_HOME/bin

   REPSTRING=${COB_HOME_MF//\//\\\/}\/lib
   echo $LD_LIBRARY_PATH | grep -q $REPSTRING   
   if [ $? -eq 0 ]; then
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH//:$REPSTRING/}
   fi
   LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COB_HOME/lib

   REPSTRING=${COB_HOME_MF//\//\\\/}\/cpylib
   echo $COBCPY | grep -q $REPSTRING   
   if [ $? -eq 0 ]; then
      COBCPY=${COBCPY//:$REPSTRING/}
   fi
   COBCPY=$COBCPY:${COB_HOME}/share/cobol-it/copy
else
   echo "Usage $0 MF|COBOL-IT"
   return
fi

export COB
export COB_HOME
export COBDIR

export PATH
export LD_LIBRARY_PATH
export COBCPY


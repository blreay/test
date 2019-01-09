#
# NAME:     Makefile.linux
#
#
# VERSION:	1.1
#
#
#                                                         
#   (C) COPYRIGHT International Business Machines Corp.   
#   1993, 2013                                            
#   All Rights Reserved                                   
#   Licensed Materials - Property of IBM                  
#   5724-B44                                              
#                                                         
#   US Government Users Restricted Rights -               
#   Use, duplication or disclosure restricted by          
#   GSA ADP Schedule Contract with IBM Corp.              
#                                                         
#                                                                       
#            NOTICE TO USERS OF THE SOURCE CODE EXAMPLES                
#                                                                       
# INTERNATIONAL BUSINESS MACHINES CORPORATION PROVIDES THE SOURCE CODE  
# EXAMPLES, BOTH INDIVIDUALLY AND AS ONE OR MORE GROUPS, AS IS          
# WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,            
# INCLUDING, BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF               
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE     
# RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOURCE CODE EXAMPLES,   
# BOTH INDIVIDUALLY AND AS ONE OR MORE GROUPS, IS WITH YOU.  SHOULD     
# ANY PART OF THE SOURCE CODE EXAMPLES PROVE DEFECTIVE, YOU (AND NOT    
# IBM) ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR OR     
# CORRECTION.  THIS PROGRAM MAY BE USED, EXECUTED, COPIED, MODIFIED     
# AND DISTRIBUTED WITHOUT ROYALTY FOR THE PURPOSE OF DEVELOPING,        
# MARKETING, OR DISTRIBUTING.                                           
#                                                                       
#                                                                       
#

CICS_ROOT=/usr/lpp/cics
CICS_CCFLAGS=-I$(CICS_ROOT)/include
CCFLAGS=$(SAMPLE_CCFLAGS)
CICS_LDFLAGS=-L$(CICS_ROOT)/lib
LINKFLAGS=$(SAMPLE_LDFLAGS)
LDLIBS=$(SAMPLE_LDLIBS)
CBLFLAGS=-rw MESSAGES -rw MENU
COPYPATH=/usr/lpp/cics/include:.
CICSTRAN_ARGS=-e -d

SAMPLE_CCFLAGS=$(CICS_CCFLAGS)
LDFLAGS=-liconv

all : cicsping cicspong
cicsping : cicsping.ccs
	cicstcl $(CICSTRAN_ARGS) -lC cicsping.ccs
cicspong : cicspong.ccs
	cicstcl $(CICSTRAN_ARGS) -lC cicspong.ccs

clean: 
	rm *.o cicsping cicspong

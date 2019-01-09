#ifndef IDEA_H 
#define IDEA_H 
 
typedef unsigned char	byte;		/* 1 byte = 8 bits  (unsigned) */
typedef unsigned short	word16;		/* 2 byte = 16 bits (unsigned) */
typedef unsigned int	word32;		/* 4 byte = 32 bits (unsigned) */
typedef int		s_word32;	/* 4 byte = 32 bits (signed) */
 
/* It is possible to change this values.                                      */ 
 
#define Idea_nofRound                 8 /* number of rounds                   */ 
#define Idea_userKeyLen               8 /* user key length (8 or larger)      */ 
 
/******************************************************************************/ 
/* Do not change the lines below.                                             */ 
 
#define Idea_dataLen                       4 /* plain-/ciphertext block length*/ 
#define Idea_keyLen    (Idea_nofRound * 6 + 4) /* en-/decryption key length   */ 
 
#define Idea_dataSize       (Idea_dataLen * 2) /* 8 bytes = 64 bits           */ 
#define Idea_userKeySize (Idea_userKeyLen * 2) /* 16 bytes = 128 bits         */ 
#define Idea_keySize         (Idea_keyLen * 2) /* 104 bytes = 832 bits        */ 
 
typedef word16 Idea_Data[Idea_dataLen]; 
typedef word16 Idea_UserKey[Idea_userKeyLen]; 
typedef word16 Idea_Key[Idea_keyLen]; 
 
/******************************************************************************/ 
/* void Idea_Crypt (Idea_Data dataIn, Idea_Data dataOut, Idea_Key key)        */ 
/*                                                                            */ 
/* Encryption and decryption algorithm IDEA. Depending on the value of 'key'  */ 
/* 'Idea_Crypt' either encrypts or decrypts 'dataIn'. The result is stored    */ 
/* in 'dataOut'.                                                              */ 
/* pre:  'dataIn'  contains the plain/cipher-text block.                      */ 
/*       'key'     contains the encryption/decryption key.                    */ 
/* post: 'dataOut' contains the cipher/plain-text block.                      */ 
/*                                                                            */ 
/******************************************************************************/ 
/* void Idea_InvertKey (Idea_Key key, Idea_Key invKey)                        */ 
/*                                                                            */ 
/* Inverts a decryption/encrytion key to a encrytion/decryption key.          */ 
/* pre:  'key'    contains the encryption/decryption key.                     */ 
/* post: 'invKey' contains the decryption/encryption key.                     */ 
/*                                                                            */ 
/******************************************************************************/ 
/* void Idea_ExpandUserKey (Idea_UserKey userKey, Idea_Key key)               */ 
/*                                                                            */ 
/* Expands a user key of 128 bits to a full encryption key                    */ 
/* pre:  'userKey' contains the 128 bit user key                              */ 
/* post: 'key'     contains the encryption key                                */ 
/*                                                                            */ 
/******************************************************************************/ 
 
#ifdef __cplusplus 
extern "C" 
{ 
#endif 
		  void Idea_Crypt (Idea_Data dataIn, Idea_Data dataOut, Idea_Key key); 
		    void Idea_InvertKey (Idea_Key key, Idea_Key invKey); 
			  void Idea_ExpandUserKey (Idea_UserKey userKey, Idea_Key key); 
#ifdef __cplusplus 
} 
#endif 
 
#endif /* IDEA_H */

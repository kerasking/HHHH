/*
 *  KBase64.h
 *  kathy
 *
 *  Created by Jellen Chan on 09-5-6.
 *  Copyright 2009 Zixer Lab.. All rights reserved.
 *
 */
#ifndef __KT_BASE64_H
#define __KT_BASE64_H

class KBase64
{
public:
	static int encode(unsigned char *outputBuf, unsigned int *outputLen,
					  unsigned char *inputBuf, unsigned int inputLen);
	static int decode(unsigned char *outputBuf, unsigned int *outputLen,
					  unsigned char* inputBuf, unsigned int inputLen);
	
};

#endif


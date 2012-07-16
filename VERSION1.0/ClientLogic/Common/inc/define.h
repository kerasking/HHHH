/*
 *  define.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-5.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __DEFINE_H__
#define __DEFINE_H__

//typedef unsigned int OBJID;

#define SEND_DATA(bao) do{\
	NDSocket* skt = NDEngine::NDDataTransThread::DefaultThread()->GetSocket();\
	if (skt)\
		skt->Send(&bao);\
}while(0)

#define ShowProgressBar (NDUISynLayer::Show())
#define CloseProgressBar (NDUISynLayer::Close())
#define srandom(x) rand()
#define random(x) rand()

/**
* 添加类似objective-c 下的常用变量或者宏
* @author 郭浩
*/

#ifndef YES
#define YES true
#endif

#ifndef NO
#define NO false
#endif

typedef unsigned int UInt32 ;
typedef unsigned short UInt16 ;
typedef unsigned char UInt8 ;

#define SAFE_DELETE(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete pObject;\
		pObject = 0;\
	}\
} while (false)

#define SafeDeleteArray(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete [] pObject;\
		pObject = 0;\
	}\
} while (false)

#endif // __DEFINE_H__
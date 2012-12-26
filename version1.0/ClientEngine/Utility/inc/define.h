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

#include "../../../cocos2d-x/cocos2dx/cocoa/CCObject.h"

#ifdef ANDROID
#include <stdlib.h>
#endif

#define SEND_DATA(bao) do{\
	NDSocket* skt = NDEngine::NDDataTransThread::DefaultThread()->GetSocket();\
	if (skt)\
		skt->Send(&bao);\
}while(0)

#define ShowProgressBar (NDUISynLayer::Show())
#define CloseProgressBar (NDUISynLayer::Close())
#define srandom(x) rand()
#define random(x) rand()

#define BEGIN_ND_NAMESPACE namespace NDEngine{
#define END_ND_NAMESPACE }

/**
* 添加类似objective-c 下的常用变量或者宏
* @author 郭浩
*/

#pragma warning(disable:4006)
#pragma warning(disable:4221)

#ifndef YES
#define YES true
#endif

#ifndef NO
#define NO false
#endif

#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
typedef double NSTimeInterval;

#define NSUInteger int

#ifndef nil
	#define nil 0
#endif

typedef cocos2d::CCObject base,*id;
typedef unsigned int UInt32;
typedef unsigned short UInt16;
typedef unsigned char UInt8;
#endif

#ifdef ANDROID
#define MAX_PATH 2048
typedef unsigned char Byte;
#endif

typedef enum
{
	MainSceneBegin = 10010,
	BottomSpeedBar,
	PlayerAttr,
	PlayerBackBag
}NMAINSCENECHILDTAG;

#define CCStringRef NDSharedPtr<cocos2d::CCString>

#define SAFE_DELETE(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete pObject;\
		pObject = 0;\
	}\
} while (false)

#define SAFE_DELETE_ARRAY(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		delete [] pObject;\
		pObject = 0;\
	}\
} while (false)

#define SAFE_RELEASE(pObject)\
do \
{\
	if (0 != pObject)\
	{\
		pObject->release();\
		pObject = 0;\
	}\
} while (false)

#define NS_NDENGINE_BGN		namespace NDEngine{
#define NS_NDENGINE_END		}
#define USING_NS_ND			using namespace NDEngine;

#define ND_ASSERT_NO_RETURN(bValue) \
if (bValue) \
{ \
	return; \
}

#define ND_ASSERT_HAS_RETURN(bValue, returnValue) \
if (bValue) \
{ \
	return returnValue; \
}

#endif // __DEFINE_H__
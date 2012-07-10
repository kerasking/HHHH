/*
 *  define.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-5.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __DEFINE_H__
#define __DEFINE_H__

//typedef unsigned int OBJID;

#include <string>
#include <vector>
#include <map>
#include <set>
#include "NDDataTransThread.h"
#include "NDSocket.h"

using std::string;
using std::vector;
using std::pair;
using std::map;
using std::set;

#define FONT_NAME @"Arial-BoldMT"

#define VERSION_IPHONE (40)

#define SIN0 (0)
#define SIN15 (0.259f)
#define SIN30 (0.5f)
#define SIN45 (0.707f)
#define SIN60 (0.866f)
#define SIN75 (0.966f)
#define SIN90 (1)

#define COS0 (1)
#define COS15 (0.966f)
#define COS30 (0.866f)
#define COS45 (0.707f)
#define COS60 (0.5f)
#define COS75 (0.259f)
#define COS90 (0)

#define EPSILON_E4 (float)(1E-4)
#define CompareEqualFloat(a, b) ((fabs(a-b)<EPSILON_E4)?1:0)

#define SAFE_DELETE(p)					\
do{										\
delete p;							\
p = NULL;							\
}while(0)

#define SAFE_DELETE_ARRAY(p)				\
do{										\
delete[] p;							\
p = NULL;							\
}while(0)

#define SAFE_DELETE_NODE(p)				\
		do{								\
		if (p){							\
		if (p->GetParent())				\
			p->RemoveFromParent(true);	\
		else							\
			delete p;					\
		p = NULL; } }while(0)


#define INTCOLORTOCCC3(color) (ccc3(color>>16&0xff, color>>8&0xff,color&0xff))
#define INTCOLORTOCCC4(color) (ccc4(color>>16&0xff, color>>8&0xff, color&0xff,255))

#define SEND_DATA(bao) do{\
	NDSocket* skt = NDEngine::NDDataTransThread::DefaultThread()->GetSocket();\
	if (skt)\
		skt->Send(&bao);\
}while(0)

#define ShowProgressBar (NDUISynLayer::Show())
#define CloseProgressBar (NDUISynLayer::Close())

#define for_vec(vec,iterator) for(iterator it = vec.begin(); it != vec.end(); it++)

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define ShowView(delegate, title, tag, maxlen) \
do{ \
NDUICustomView *view = new NDUICustomView; \
view->Initialization(); \
view->SetDelegate(delegate); \
std::vector<int> vec_id; vec_id.push_back(1); \
std::vector<std::string> vec_str; vec_str.push_back(title); \
view->SetEdit(1, vec_id, vec_str); \
if(maxlen != 0) \
view->SetEditMaxLength(maxlen, 0); \
view->SetTag(tag); \
view->Show(); \
NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene(); \
if (scene) \
{ \
	scene->AddChild(view); \
} \
}while(0)

#define VerifyViewNum(refView) \
do{ \
std::string text = (refView).GetEditText(0); \
if (!(VerifyUnsignedNum(text))) \
{ \
	(refView).ShowAlert(NDCommonCString("NumberRequireTip")); \
	return false; \
}}while(0)

#define VerifyViewNum1(refView) \
do{ \
std::string text = (refView).GetEditText(1); \
if (!(VerifyUnsignedNum(text))) \
{ \
(refView).ShowAlert(NDCommonCString("NumberRequireTip")); \
return false; \
}}while(0)

#define VerifyViewNum2(refView) \
do{ \
std::string text = (refView).GetEditText(2); \
if (!(VerifyUnsignedNum(text))) \
{ \
(refView).ShowAlert(NDCommonCString("NumberRequireTip")); \
return false; \
}}while(0)


#endif // __DEFINE_H__
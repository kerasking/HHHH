/*
 *  basedefine.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-5.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __BASEDEFINE_H__
#define __BASEDEFINE_H__

#include <string>
#include <vector>
#include <map>
#include <set>
#include <zlib/zconf.h>

#define OBJID			unsigned int
//#define ID_VEC			std::vector<OBJID>
#define FONT_NAME		"Arial-BoldMT"
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

#define INTCOLORTOCCC3(color) (ccc3(color>>16&0xff, color>>8&0xff,color&0xff))
#define INTCOLORTOCCC4(color) (ccc4(color>>16&0xff, color>>8&0xff, color&0xff,255))

#ifdef DEBUG
#define NDAsssert(e) assert(e)
#else
#define NDAsssert(e)
#endif

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define for_vec(vec,iterator) for(iterator it = vec.begin(); it != vec.end(); it++)

#define SAFE_DELETE_NODE(p)				\
	do{								\
	if (p){							\
	if (p->GetParent())				\
	p->RemoveFromParent(true);	\
		else							\
		delete p;					\
		p = NULL; } }while(0)

enum{	UI_TAG_BEGIN	= 10000,	UI_TAG_DIALOG,};

enum{	UI_ZORDER_BEGIN	= 0,	UI_ZORDER_DIALOG = 1000,};

#endif // __DEFINE_H__
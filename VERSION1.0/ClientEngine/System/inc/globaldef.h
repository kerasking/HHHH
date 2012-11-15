/*
 *  globaldef.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _GLOBAL_DEF_H_ZJH_
#define _GLOBAL_DEF_H_ZJH_

#include <stdio.h>
#include <sstream>
#include <vector>
#include <deque>
#include <set>
#include <map>
#include "BaseType.h"

#include "TableDef.h"
#include "EnumDef.h"
//client engine inc
#include "UtilityInc.h"
#include "NDSocket.h"
#include "NDDataTransThread.h"

using namespace NDEngine;
// enum
// {
// 	UI_TAG_BEGIN	= 10000,
// 	UI_TAG_DIALOG,
// };
// 
// enum
// {
// 	UI_ZORDER_BEGIN	= 0,
// 	UI_ZORDER_DIALOG = 1000,
// };

enum ONTIMER_TAG
{
	ONTIMER_TAG_INIT = 9000,
	ONTIMER_TAG_LOGIN,
};

//typedef unsigned long			OBJID;

// set
typedef std::vector<OBJID> ID_VEC;
typedef std::deque<OBJID> ID_DEQ;
typedef std::set<OBJID> ID_SET;
typedef std::map<OBJID, OBJID> ID_MAP;

#define SEND_DATA(bao) do{\
	NDSocket* skt = NDEngine::NDDataTransThread::DefaultThread()->GetSocket();\
	if (skt)\
	skt->Send(&bao);\
}while(0)

#define ShowProgressBar (NDUISynLayer::Show())
#define CloseProgressBar (NDUISynLayer::Close())

#include "NDLocalization.h"
#include "ScriptInc.h"

#define NDLog(str, ...)  

//#include "NDUtility.h"
//#include "NDMsgDefine.h"

#endif //_GLOBAL_DEF_H_ZJH_

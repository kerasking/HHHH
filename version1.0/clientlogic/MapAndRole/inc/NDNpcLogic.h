//---------------------------------------------------------------
//	NDNpcLogic.h
//	NpcÂß¼­
//---------------------------------------------------------------

#pragma once

#include "define.h"
#include "typedef.h"
#include "platform.h"

NS_NDENGINE_BGN

using namespace NDEngine;
using namespace cocos2d;

class NDNpc;
class NDPlayer;
class NDNpcLogic;

////////////////////////////////////////////////////////////////////////////
//HeroÈÎÎñÂß¼­
class NDHeroTaskLogic
{
private:
	NDHeroTaskLogic()
	{
		tickLastRefresh.tv_sec = 0;
		tickLastRefresh.tv_usec = 0;
		idlistAccept = new ID_VEC();
		idCanAccept = new ID_VEC();
	}

public:
	~NDHeroTaskLogic()
	{
		if (idlistAccept)
		{
			idlistAccept->clear();
			delete idlistAccept;

			idCanAccept->clear();
			delete idCanAccept;
		}
	}

public:
	static NDHeroTaskLogic& Instance() {
		static NDHeroTaskLogic* pLogic = NULL;
		if (!pLogic)
		{
			pLogic = new NDHeroTaskLogic();
		}
		return *pLogic;
	}

public:
	void tickHero() 
	{
//         struct cc_timeval currentTime;
//         if (CCTime::gettimeofdayCocos2d(&currentTime, NULL) != 0)
//         {
//             return;
//         }
//         double fDeltaTime = (currentTime.tv_sec - tickLastRefresh.tv_sec)*1000.0f + (currentTime.tv_usec - tickLastRefresh.tv_usec) / 1000.0f;
// 
// 		if (TAbs(fDeltaTime) > 1000*3) //3 second
// 		{
			refreshListAccepted();

			refreshCanAcceptList();

// 			tickLastRefresh = currentTime;
// 		}
	}

	void tickNpc( NDNpcLogic* npcLogic );

private:
	void refreshListAccepted();
	bool refreshCanAcceptList();
	int getHeroID();

private:
	ID_VEC* idlistAccept;
	ID_VEC* idCanAccept;
	struct cc_timeval tickLastRefresh;
};


////////////////////////////////////////////////////////////////////////////
//NpcÂß¼­
class NDNpcLogic 
{
private:
	NDNpcLogic();

public:
	NDNpcLogic( NDNpc* inOwner )
	{
		Owner = inOwner;
		idlist = new ID_VEC();
		tickLastRefresh.tv_sec = 0;
		tickLastRefresh.tv_usec = 0;
	}

	~NDNpcLogic()
	{
		if (idlist)
		{
			idlist->clear();
			delete idlist;
		}
	}

public:
	void RefreshTaskState();

private:
public:
	bool GetTaskListByNpc(ID_VEC& idVec);
	bool GetPlayerCanAcceptList(ID_VEC& idVec);
	
private:
public:
	friend class NDHeroTaskLogic;

	NDNpc* Owner;
	ID_VEC* idlist;
	struct cc_timeval tickLastRefresh;
};

NS_NDENGINE_END
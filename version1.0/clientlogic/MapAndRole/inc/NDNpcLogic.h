//---------------------------------------------------------------
//	NDNpcLogic.h
//	NpcÂß¼­
//---------------------------------------------------------------

#pragma once

#include "define.h"
#include "typedef.h"

NS_NDENGINE_BGN

using namespace NDEngine;

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
		tickLastRefresh = 0;
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
		if (TAbs(GetTickCount() - tickLastRefresh) > 1000*3) //3 second
		{
			refreshListAccepted();

			refreshCanAcceptList();

			tickLastRefresh = GetTickCount();
		}
	}

	void tickNpc( NDNpcLogic* npcLogic );

private:
	void refreshListAccepted();
	bool refreshCanAcceptList();
	int getHeroID();

private:
	ID_VEC* idlistAccept;
	ID_VEC* idCanAccept;
	DWORD tickLastRefresh;
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
		tickLastRefresh = 0;
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
	bool GetTaskListByNpc(ID_VEC& idVec);
	bool GetPlayerCanAcceptList(ID_VEC& idVec);
	
private:
	friend NDHeroTaskLogic;

	NDNpc* Owner;
	ID_VEC* idlist;
	DWORD tickLastRefresh;
};

NS_NDENGINE_END
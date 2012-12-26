//---------------------------------------------------------------
//	NDNpcLogic.h
//	Npc逻辑
//---------------------------------------------------------------

#pragma once

#include "define.h"
#include "typedef.h"
#include "platform.h"
#include "ObjectTracker.h"

NS_NDENGINE_BGN

using namespace NDEngine;
using namespace cocos2d;
using namespace std;

class NDNpc;
class NDPlayer;
class NDNpcLogic;

////////////////////////////////////////////////////////////////////////////
//Hero任务逻辑
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
//Npc逻辑
class NDNpcLogic 
{
private:
	NDNpcLogic();

public:
	NDNpcLogic( NDNpc* inOwner )
	{
		INC_NDOBJ("NDNpcLogic");

		Owner = inOwner;
		idlist = new ID_VEC();
		tickLastRefresh.tv_sec = 0;
		tickLastRefresh.tv_usec = 0;
	}

	~NDNpcLogic()
	{
		DEC_NDOBJ("NDNpcLogic");

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

////////////////////////////////////////////////////////////////////////////
// 将Npc关联的TaskId列表缓存一下，静态数据
class NDNpcTaskIdCache
{
private:
	typedef vector<unsigned int> TASK_LIST;
	map<int,TASK_LIST*> mapData;
	typedef map<int,TASK_LIST*>::iterator ITER_DATA;

private:
	NDNpcTaskIdCache() {}

public:
	static NDNpcTaskIdCache& getInstance()
	{
		static NDNpcTaskIdCache s_obj;
		return s_obj;
	}

	TASK_LIST* queryTaskList( const int idNpc )
	{
		ITER_DATA iter = mapData.find( idNpc );
		if (iter != mapData.end())
			return iter->second;
		return NULL;
	}

	bool queryTaskList( const int idNpc, TASK_LIST& taskList )
	{
		TASK_LIST* pTaskList = queryTaskList( idNpc );
		if (pTaskList)
		{
			taskList = *pTaskList; //copy.
			return true;
		}
		return false;
	}

	void addTaskList( const int idNpc, TASK_LIST& vecTaskList )
	{
		if (!queryTaskList( idNpc ))
		{
			TASK_LIST* newTaskList = new TASK_LIST;
			if (newTaskList)
			{
				*newTaskList = vecTaskList; //copy.
				mapData[ idNpc ] = newTaskList;
			}
		}
	}

public:
	void destroy()
	{
		for (ITER_DATA iter = mapData.begin(); iter != mapData.end(); ++iter)
		{
			SAFE_DELETE( iter->second );
		}
		mapData.clear();
	}

	int getCnt()
	{
		return mapData.size();
	}

	string dump()
	{
		char line[100] = "";
		sprintf( line, "NDNpcTaskIdCache has %d npc cached.\r\n", getCnt() );
		return line;
	}
};

NS_NDENGINE_END
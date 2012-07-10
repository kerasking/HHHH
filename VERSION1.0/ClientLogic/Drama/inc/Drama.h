/*
 *  Drama.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _DRAMA_H_ZJH_
#define _DRAMA_H_ZJH_

#include "Singleton.h"
#include "DramaCommandBase.h"
#include "NDTimer.h"
#include <list>

#define DramaObj	Drama::GetSingleton()

class Drama : 
public TSingleton<Drama>,
public ITimerCallback
{
public:
	Drama();
	~Drama();
	
	void Start();
	void AddCommond(DramaCommandBase* command);
	void QuitGame();
private:
	typedef std::list<DramaCommandBase*>	COMMANDQUE;
	typedef COMMANDQUE::iterator			COMMANDQUE_IT;
	
	COMMANDQUE m_queueCommond, m_queueCommondExcute;
	NDTimer m_timer;
	
private:
	void End();
	void StartUpdate();
	void EndUpdate();
	void Update();
	
	bool FillExcuteQueue();
	bool ReleaseQueue(bool bExcute);
	
private:
	void OnTimer(OBJID tag);
};

#endif // _DRAMA_H_ZJH_
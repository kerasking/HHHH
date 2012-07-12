/*
 *  ScriptGlobalEvent.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _SCRIPT_GLOBAL_EVENT_H_ZJH_
#define _SCRIPT_GLOBAL_EVENT_H_ZJH_

typedef enum
{
	GLOBALEVENT_BEGIN = 100,
	GE_GENERATE_GAMESCENE				= GLOBALEVENT_BEGIN,
	GE_ITEM_UPDATE						= GLOBALEVENT_BEGIN + 1,
	GE_KILL_MONSTER						= GLOBALEVENT_BEGIN + 2,
    GE_LOGIN_GAME						= GLOBALEVENT_BEGIN + 3,
	//GE_JUEWEI_UPDATE,
	//GE_RANK_UPDATE,
	//GE_MONEY_UPDATE,
	//GE_HORNER_UPDATE,
	GE_SWITCH							= GLOBALEVENT_BEGIN + 4,
	GE_ONMOVE							= GLOBALEVENT_BEGIN + 5,
	GE_ONMOVE_END						= GLOBALEVENT_BEGIN + 6,
	GE_QUITGAME							= GLOBALEVENT_BEGIN + 7,
	GLOBALEVENT_END,
}GLOBALEVENT;
	
class ScriptGlobalEvent : public NDEngine::ScriptObject
{
public:
	virtual void OnLoad();
	static void OnEvent(GLOBALEVENT eEvent, int param1=0, int param2=0, int param3=0);
};

#endif // _SCRIPT_GLOBAL_EVENT_H_ZJH_
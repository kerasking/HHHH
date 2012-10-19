/*
 *  ScriptTimer.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-3-9.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ScriptTimer.h"

unsigned int RegisterTimer(LuaObject func, float fInterval)
{
	return ScriptTimerMgrObj.AddTimer(func, fInterval);
}

void UnRegisterTimer(unsigned int nTag)
{
	ScriptTimerMgrObj.RemoveTimer(nTag);
}

void ScriptTimerMgr::OnLoad()
{
	ETCFUNC("RegisterTimer", RegisterTimer);
	ETCFUNC("UnRegisterTimer", UnRegisterTimer);
}

void ScriptTimerMgr::OnTimer(OBJID tag)
{
	std::map<OBJID, LuaObject>::iterator it = m_kMapFunc.find(tag);

	if (it == m_kMapFunc.end())
	{
		return;
	}

	LuaObject& fun = it->second;

	if (fun.IsFunction())
	{
		LuaFunction<void> luaFunc(fun);
		luaFunc(tag);
	}
}

unsigned int ScriptTimerMgr::AddTimer(LuaObject func, float fInterval)
{
	if (!func.IsFunction())
	{
		return 0;
	}

	OBJID nId = m_idAlloc.GetID();

	m_kMapFunc.insert(std::make_pair(nId, func));
	m_kTimer.SetTimer(this, nId, fInterval);

	return nId;
}

bool ScriptTimerMgr::RemoveTimer(OBJID tag)
{
	std::map<OBJID, LuaObject>::iterator it = m_kMapFunc.find(tag);

	if (it == m_kMapFunc.end())
	{
		return false;
	}

	m_kMapFunc.erase(it);

	m_idAlloc.ReturnID(tag);

	m_kTimer.KillTimer(this, tag);

	return true;
}

bool ScriptTimerMgr::RemoveAllTimer()
{
	std::map<OBJID, LuaObject>::iterator it = m_kMapFunc.begin();

	while (it != m_kMapFunc.end())
	{
		OBJID nId = it->first;

		m_kMapFunc.erase(it++);

		m_kTimer.KillTimer(this, nId);
	}

	m_idAlloc.reset();
	return true;
}
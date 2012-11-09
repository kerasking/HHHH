/*
 *  ScriptTask.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "ScriptTask.h"
#include "NDPlayer.h"
#include "globaldef.h"
#include "ScriptInc.h"
#include "Singleton.h"
#include "UINpcDlg.h"
#include "ScriptGameData.h"

#include <sstream>

using namespace LuaPlus;

namespace NDEngine {

//#pragma mark npc交互对话框与数据单例
class ScriptNpcDlgData : 
public TSingleton<ScriptNpcDlgData>
{
public:
	void OpenNpcDlg(int nId)
	{
		if (!m_dlg)
		{
			CUINpcDlg *dlg = new CUINpcDlg;
			dlg->Initialization(nId);
			m_dlg = dlg->QueryLink();
		}
		
		m_dlg->SetId(nId);
		m_dlg->SetTaskState(false);
		m_dlg->ClearOptions();
	}
	
	void OpenTaskDlg(int nId)
	{
		if (!m_dlg)
		{
			CUINpcDlg *dlg = new CUINpcDlg;
			dlg->Initialization(nId);
			m_dlg = dlg->QueryLink();
			return;
		}
		
		m_dlg->SetId(nId);
		m_dlg->SetTaskState(true);
		m_dlg->ClearOptions();
	}
	
	bool CloseDlg()
	{
		if (!m_dlg)
		{
			return false;
		}
		
		m_dlg->Close();
		
		return true;
	}
	
	void SetTitle(const char* title)
	{
		if (!m_dlg)
		{
			return;
		}
		
		m_dlg->SetTitle(title);
	}
	
	void SetContent(const char* content)
	{
		if (!m_dlg)
		{
			return;
		}
		
		m_dlg->SetContent(content);
	}
	
	void SetInfo(const char* award)
	{
		if (!m_dlg)
		{
			return;
		}
		
		m_dlg->SetInfo(award);
	}
	
	void AddOption(const char* opt, int nAction)
	{
		if (!opt || !m_dlg)
		{
			return;
		}
		DLGOPION dlgOpt;
		dlgOpt.strOption	= opt;
		dlgOpt.nAction		= nAction;
		m_dlg->AddOption(dlgOpt);
	}
	
	unsigned int GetOptionCount()
	{
		if (!m_dlg)
		{
			return 0;
		}
		return m_dlg->GetOptionCount();
	}
private:
	int							m_nNpcId;
	CAutoLink<CUINpcDlg>		m_dlg;
};

//#pragma mark npc与任务脚本接口

void OpenNpcDlg(int nNpcId)
{
	ScriptNpcDlgData::GetSingleton().OpenNpcDlg(nNpcId);
}

void SetTitle(const char* title)
{
	ScriptNpcDlgData::GetSingleton().SetTitle(title);
}

void SetContent(const char* content)
{
	ScriptNpcDlgData::GetSingleton().SetContent(content);
}

void SetTaskAward(const char* award)
{
	ScriptNpcDlgData::GetSingleton().SetInfo(award);
}

void AddOpt(const char* opt, int nAction)
{
	ScriptNpcDlgData::GetSingleton().AddOption(opt, nAction);
}

int GetOptCount()
{
	return ScriptNpcDlgData::GetSingleton().GetOptionCount();
}

void OpenTaskDlg(int nTaskId)
{
	ScriptNpcDlgData::GetSingleton().OpenTaskDlg(nTaskId);
}

bool CloseDlg()
{
	return ScriptNpcDlgData::GetSingleton().CloseDlg();
}

void OnDealTask(int nTaskId)
{
	ScriptMgr& script = ScriptMgr::GetSingleton();
	std::stringstream ssTaskFunc;
	ssTaskFunc << "TASK_FUNCTION_" << nTaskId;
	bool bRet = script.IsLuaFuncExist(ssTaskFunc.str().c_str(), "TASK");
	if (bRet)
	{
		script.excuteLuaFunc(ssTaskFunc.str().c_str(), "TASK", nTaskId);
	}
	else 
	{
		script.excuteLuaFunc("TASK_FUNCTION_COMMON", "TASK", nTaskId);
	}
}

void ScriptTaskLoad()
{
	ETCFUNC("OpenNpcDlg",		OpenNpcDlg)
	ETCFUNC("SetTitle",			SetTitle)
	ETCFUNC("SetContent",		SetContent)
	ETCFUNC("AddOpt",			AddOpt)
	ETCFUNC("OpenTaskDlg",		OpenTaskDlg)
	ETCFUNC("OnDealTask",		OnDealTask)
	ETCFUNC("CloseDlg",			CloseDlg);
	ETCFUNC("GetOptCount",		GetOptCount);
	ETCFUNC("SetTaskAward",		SetTaskAward);
}

int ScriptGetTaskState(int nTaskId)
{
	int nRoleId = NDPlayer::defaultHero().m_nID;
	unsigned long ulVal = ScriptGameDataObj.GetData<unsigned long long>(eScriptDataRole, nRoleId, eRoleDataTask, nTaskId, 2);
	return ulVal;
}

}
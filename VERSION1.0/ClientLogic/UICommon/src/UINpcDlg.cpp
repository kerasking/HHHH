/*
 *  UINpcDlg.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-2-21.
 *  Copyright 2012 (Õ¯¡˙)DeNA. All rights reserved.
 *
 */

#include "UINpcDlg.h"
#include "ScriptMgr.h"
#include <sstream>

IMPLEMENT_CLASS(CUINpcDlg, CUIDialog)

CUINpcDlg::CUINpcDlg()
{
	INIT_AUTOLINK(CUINpcDlg);
	
	m_bTaskState		= false;
	m_nId				= 0;
}

CUINpcDlg::~CUINpcDlg()
{
}

void CUINpcDlg::Initialization(int nNpcId)
{
	CUIDialog::Initialization();
	
	SetId(nNpcId);
	
	//…Ë÷√Õº∆¨
	NDPicture* picPortrait = ScriptMgrObj.excuteLuaFunc<NDPicture*>("GetNpcPotraitPic", "NPC", nNpcId);
	this->SetPicture(picPortrait);
}

void CUINpcDlg::SetId(int nId)
{
	m_nId	= nId; 
}

void CUINpcDlg::SetTaskState(bool bSet)
{
	m_bTaskState	= bSet;
}

void CUINpcDlg::OnClickOpt(int nOptIndex)
{
	if (size_t(nOptIndex) >= m_vId.size())
	{
		return;
	}
	
	if (m_bTaskState)
	{
		OnTaskClick(m_vId[nOptIndex]);
	}
	else
	{
		OnNpcClick(m_vId[nOptIndex]);
	}
}

void CUINpcDlg::OnNpcClick(int nAction)
{
	ScriptMgr& script = ScriptMgr::GetSingleton();
	bool bRet = script.excuteLuaFunc("NPC_OPTION_COMMON", "NPC", m_nId, nAction);
	if (!bRet)
	{
		std::stringstream ssNpcFunc;
		ssNpcFunc << "NPC_OPTION_" << m_nId;
		script.excuteLuaFunc(ssNpcFunc.str().c_str(), "NPC", m_nId, nAction);
	}
}

void CUINpcDlg::OnTaskClick(int nAction)
{
	ScriptMgr& script = ScriptMgr::GetSingleton();
	bool bRet = script.excuteLuaFunc("TASK_OPTION_COMMON", "TASK", m_nId, nAction);
	if (!bRet)
	{
		std::stringstream ssTaskFunc;
		ssTaskFunc << "TASK_OPTION_" << m_nId;
		script.excuteLuaFunc(ssTaskFunc.str().c_str(), "TASK", m_nId, nAction);
	}
}
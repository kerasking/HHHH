/*
 *  GlobalDialog.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-9.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "GlobalDialog.h"
#include "NDUISynLayer.h"
#include "define.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDUtility.h"

using namespace NDEngine;

void GlobalShowDlg(std::string title, std::string content, float seconds/* = 0*/)
{
	GlobalDialogObj.Show(NULL, title.c_str(), content.c_str(), seconds, NULL);
}

void GlobalShowDlg(NDEngine::NDObject* delegate, std::string title, std::string content, float seconds/* = 0*/)
{
	GlobalDialogObj.Show(delegate, title.c_str(), content.c_str(), seconds, NULL);
}

uint GlobalShowDlg(
	NDEngine::NDObject* delegate,
	const char* title, 
	const char* text,
	uint second,					// second-倒计时,若为0则无倒计时
	const char* ortherButtons,
	.../*must NULL end*/
	)
{
	std::vector<GlobalDialogBtnContent> btns;
	
	va_list argumentList;
	char *eachObject;
	
	if (ortherButtons) 
	{	
		btns.push_back(GlobalDialogBtnContent(std::string(ortherButtons)));
		va_start(argumentList, ortherButtons);
		while ((eachObject = va_arg(argumentList, char*))) 
		{
			btns.push_back(GlobalDialogBtnContent(std::string(eachObject)));
		}
		va_end(argumentList);
	}
	
	return GlobalDialogObj.Show(delegate, title, text, second, btns);
}

///////////////////////////////////////////////////

#define MAX_FACTORY_ID (2147483647) // (2^31-1)

CIDFactory::CIDFactory()
{
	reset();
}

CIDFactory::~CIDFactory()
{
}

unsigned int CIDFactory::GetID()
{
	if (m_vecRecyle.empty())
	{
		if (m_uiCurID == MAX_FACTORY_ID)
		{
			NDLog("id factory roll");
			//roll
			m_uiCurID = 1;
		}else
		{
			m_uiCurID++;
		}
		return m_uiCurID;
	}
	
	unsigned int uiRet = m_vecRecyle.back();
	m_vecRecyle.pop_back();
	return uiRet;
}

void CIDFactory::ReturnID(unsigned int iID)
{
	if (iID > MAX_FACTORY_ID)
	{
		return;
	}
	m_vecRecyle.push_back(iID);
}

void CIDFactory::reset()
{
	m_uiCurID = 0;
	m_vecRecyle.clear();
}

///////////////////////////////////////////////
static CGlobalDialog * globaldialog = NULL;

IMPLEMENT_CLASS(CGlobalDialog, NDObject)

CGlobalDialog& CGlobalDialog::getSingleton()
{
	if (globaldialog == NULL)
	{
		globaldialog = new CGlobalDialog;
	}
	return *globaldialog;
}

CGlobalDialog::CGlobalDialog()
{
	m_bInBattle = false;
}

CGlobalDialog::~CGlobalDialog()
{
	quitGame();
}

unsigned int CGlobalDialog::Show(NDObject* delegate, const char* title, const char* text, uint timeout, const char* ortherButtons,.../*must NULL end*/)
{
//	s_dlg_info *p = new s_dlg_info;
//	s_dlg_info& info = *p;
//	info.delegate = delegate;
//	info.title += title ? title : "";
//	info.text += text ? text : "";
//	info.cancelbtn += cancleButton ? cancleButton : "";
//	info.bShowing = false;
//	info.uiID = m_idAlloc.GetID();
//	std::vector<std::string>& btns = info.btns;
	
	std::vector<GlobalDialogBtnContent> btns;
	va_list argumentList;
	char *eachObject;
	
	if (ortherButtons) 
	{	
		btns.push_back(GlobalDialogBtnContent(std::string(ortherButtons)));
		va_start(argumentList, ortherButtons);
		while ((eachObject = va_arg(argumentList, char*))) 
		{
			btns.push_back(GlobalDialogBtnContent(std::string(eachObject)));
		}
		va_end(argumentList);
	}
	
	//m_listDlg.push_back(p);
//	
//	deal();
	
//	return info.uiID;
	return Show(delegate, title, text, timeout, btns);
}

unsigned int CGlobalDialog::Show(NDEngine::NDObject* delegate, const char* title, const char* text, uint timeout, const std::vector<std::string>& ortherButtons)
{
	std::vector<GlobalDialogBtnContent> vec_btns;
	
	for_vec(ortherButtons, std::vector<std::string>::const_iterator)
	{
		vec_btns.push_back(GlobalDialogBtnContent(*it));
	}
	
	return Show(delegate, title, text, timeout, vec_btns);
}

unsigned int CGlobalDialog::Show(NDEngine::NDObject* delegate, const char* title, const char* text, uint timeout, const std::vector<GlobalDialogBtnContent>& ortherButtons)
{
	s_dlg_info *p = new s_dlg_info;
	s_dlg_info& info = *p;
	info.delegate = delegate;
	info.title += title ? title : "";
	info.text += text ? text : "";
	//info.cancelbtn += cancleButton ? cancleButton : "";
	info.bShowing = false;
	info.uiID = m_idAlloc.GetID();
	info.btns = ortherButtons;
	info.timeout = timeout;
	
	m_listDlg.push_back(p);
	
	deal();
	
	return info.uiID;
}

/*
void CGlobalDialog::DisappearedAfterSeconds(float seconds)
{
	m_timer.SetTimer(this, 1, seconds);
}
*/

/*
void CGlobalDialog::OnTimer(OBJID tag)
{		
	if (m_dlg) 
	{
		m_dlg->Close();
	}	
	m_timer.KillTimer(this, 1);
}
*/

void CGlobalDialog::deal()
{
	if (m_listDlg.empty())
	{
		m_bInBattle = false;
		return;
	}
	
	if (m_bInBattle) 
	{
		std::list<s_dlg_info*>::iterator it = m_listDlg.begin();
		for (; it != m_listDlg.end(); it++)
		{
			delete *it;
		}
		m_listDlg.clear();
		m_bInBattle = false;
		return;
	}
	
	s_dlg_info *p = m_listDlg.front();
	
	if (p && p->bShowing && !m_dlg)
	{ // 对话框被关掉了,但是内部保存的数据还没清掉
		m_listDlg.pop_front();
		
		if (!m_listDlg.empty())
			p = m_listDlg.front();
	}
	
	if (p && !p->bShowing)
	{
		p->bShowing = true;
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetTag(p->uiID);
		dlg->SetDelegate(this);
		CloseProgressBar;
		std::vector<bool> vec_arrow;
		std::vector<std::string> vec_str;
		for_vec(p->btns, std::vector<GlobalDialogBtnContent>::iterator)
		{
			vec_str.push_back((*it).str);
			vec_arrow.push_back((*it).bArrow);
		}
		dlg->Show(p->title.c_str(), p->text.c_str(), p->cancelbtn.c_str(), vec_str, vec_arrow);
		dlg->SetTime(p->timeout);
		
		m_dlg = dlg->QueryLink();
		
		// 停止怪物ai
		NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (runningScene && runningScene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			((GameScene*)runningScene)->SetUIShow(true);
		}
	}
}

void CGlobalDialog::quitGame()
{
	std::list<s_dlg_info*>::iterator it = m_listDlg.begin();
	for (; it != m_listDlg.end(); it++)
	{
		if (*it && !(*it)->bShowing)
		{
			delete *it;
		}
	}
	m_listDlg.clear();
	m_idAlloc.reset();
}

void CGlobalDialog::OnDialogShow(NDUIDialog* dialog)
{
	if (m_listDlg.empty())
	{
		return;
	}
	
	s_dlg_info *p = m_listDlg.front();
	
	NDAsssert(int(p->uiID) == dialog->GetTag());
	
	if (p->delegate)
	{
		NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (p->delegate);
		if (delegate) 
		{
			delegate->OnDialogShow(dialog);
		}
	}
}

void CGlobalDialog::OnDialogClose(NDUIDialog* dialog)
{
	// 恢复怪物ai
	NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (runningScene && runningScene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
		((GameScene*)runningScene)->SetUIShow(false);
	}
	
	if (m_listDlg.empty())
	{
		return;
	}
	
	s_dlg_info *p = m_listDlg.front();
	
	NDAsssert(int(p->uiID) == dialog->GetTag());
	
	NDAsssert(p->bShowing);
	
	if (p->delegate)
	{
		NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (p->delegate);
		if (delegate) 
		{
			delegate->OnDialogClose(dialog);
		}
	}
	
	m_listDlg.pop_front();
	
	m_idAlloc.ReturnID(dialog->GetTag());
	
	deal();
}

void CGlobalDialog::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (m_listDlg.empty())
	{
		return;
	}
	
	s_dlg_info *p = m_listDlg.front();
	
	NDAsssert(int(p->uiID) == dialog->GetTag());
	
	if (p->delegate)
	{
		NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (p->delegate);
		if (delegate) 
		{
			delegate->OnDialogButtonClick(dialog, buttonIndex);
		}
	}
}

bool CGlobalDialog::OnDialogTimeOut(NDUIDialog* dialog)
{
	if (m_listDlg.empty())
	{
		return false;
	}
	
	s_dlg_info *p = m_listDlg.front();
	
	NDAsssert(int(p->uiID) == dialog->GetTag());
	
	if (p->delegate)
	{
		NDUIDialogDelegate* delegate = dynamic_cast<NDUIDialogDelegate*> (p->delegate);
		if (delegate) 
		{
			return delegate->OnDialogTimeOut(dialog);
		}
	}
	
	return false;
}

#pragma mark 游戏退出对话框(附倒计时关闭功能)

#define TAG_TIMER_QUIT (16314)

IMPLEMENT_CLASS(GameQuitDialog, NDUIDialog)

GameQuitDialog* GameQuitDialog::s_GameQuitDialog = NULL;

void GameQuitDialog::DefaultShow(std::string title, std::string content, float seconds /*= 0.0f*/, bool replace/*=false*/)
{
	if (!s_GameQuitDialog)
	{
		s_GameQuitDialog = new GameQuitDialog;
		s_GameQuitDialog->Initialization();
		s_GameQuitDialog->Show(title.c_str(), content.c_str(), NDCommonCString("Ok"), NULL);
		s_GameQuitDialog->SetTime(seconds);
	}
	else if (replace)
	{
		s_GameQuitDialog->SetTitle(title.c_str());
		s_GameQuitDialog->SetContent(content.c_str());
		s_GameQuitDialog->SetTime(seconds);
	}
}

GameQuitDialog::GameQuitDialog()
{
}

GameQuitDialog::~GameQuitDialog()
{
	s_GameQuitDialog = NULL;
}

void GameQuitDialog::Initialization()
{
	NDUIDialog::Initialization();
}

void GameQuitDialog::Close()
{
	NDUIDialog::Close();
	
	quitGame();
}

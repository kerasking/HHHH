/*
 *  GlobalDialog.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-9.
 *  Copyright 2011 (����)DeNA. All rights reserved.
 *
 */

#ifndef _GLOBAL_DIALOG_H_
#define _GLOBAL_DIALOG_H_

#include "NDUIDialog.h"
#include <list>
#include "NDTimer.h"

using namespace NDEngine;

#define GlobalDialogObj (CGlobalDialog::getSingleton())

void GlobalShowDlg(std::string title, std::string content, float seconds = 0);
void GlobalShowDlg(NDEngine::NDObject* delegate, std::string title,
		std::string content, float seconds = 0);
uint GlobalShowDlg(NDEngine::NDObject* delegate, const char* title,
		const char* text, uint second,				// second-倒计�??,若为0则无倒计�??
		const char* ortherButtons, .../*must NULL end*/
		);

class CIDFactory
{
	enum
	{
		max_id = 65535,
	};
public:
	CIDFactory();
	~CIDFactory();

	unsigned int GetID();
	void ReturnID(unsigned int uiID);
	void reset();
private:
	std::vector<unsigned int> m_vecRecyle;
	unsigned int m_uiCurID;
};

typedef struct _tagGlobalDialogBtnContent
{
	std::string str;
	bool bArrow;
	_tagGlobalDialogBtnContent(std::string str, bool bArrow = false)
	{
		this->str = str;
		this->bArrow = bArrow;
	}
} GlobalDialogBtnContent;

class CGlobalDialog: public NDEngine::NDObject,
		public NDEngine::NDUIDialogDelegate
{
	DECLARE_CLASS (CGlobalDialog)
public:
	static CGlobalDialog& getSingleton();
	~CGlobalDialog();

	void OnDialogShow(NDEngine::NDUIDialog* dialog);override
	void OnDialogClose(NDEngine::NDUIDialog* dialog);override
	void OnDialogButtonClick(NDEngine::NDUIDialog* dialog,
			unsigned int buttonIndex);override
	bool OnDialogTimeOut(NDEngine::NDUIDialog* dialog);override
	void SetInBattle(bool bInBattle)
	{
		this->m_bInBattle = bInBattle;
	}
public:
	// �??全局对话框列表中加入对话�??,返回该对话框的tag
	unsigned int Show(NDEngine::NDObject* delegate, const char* title,
			const char* text, uint timeout, const char* ortherButtons,
			.../*must NULL end*/);
	unsigned int Show(NDEngine::NDObject* delegate, const char* title,
			const char* text, uint timeout,
			const std::vector<std::string>& ortherButtons);
	unsigned int Show(NDEngine::NDObject* delegate, const char* title,
			const char* text, uint timeout,
			const std::vector<GlobalDialogBtnContent>& ortherButtons);
	void quitGame();
	void DisappearedAfterSeconds(float seconds);
	//void OnTimer(OBJID tag); override
private:
	CGlobalDialog();
	void deal();

private:
	struct s_dlg_info
	{
		NDEngine::NDObject* delegate;
		std::string title;
		std::string text;
		std::vector<GlobalDialogBtnContent> btns;
		std::string cancelbtn;
		bool bShowing;
		unsigned char uiID;
		uint timeout;
	};

	std::list<s_dlg_info*> m_listDlg;
	CIDFactory m_kIDAlloc;
	bool m_bInBattle;
	CAutoLink<NDUIDialog> m_kDialog;
	//NDUIDialog* m_dlg;
	//NDTimer m_timer;
};

class GameQuitDialog: public NDUIDialog
{
	DECLARE_CLASS (GameQuitDialog)
public:
	~GameQuitDialog();
	static void DefaultShow(std::string title, std::string content,
			float seconds = 0.0f, bool replace = false);
private:
	GameQuitDialog();
	void Close();
	void Initialization();

private:

	static GameQuitDialog* ms_pkGameQuitDialog;
};

#endif // _GLOBAL_DIALOG_H_

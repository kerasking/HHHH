/*
 *  UIDialog.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-22.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_DIALOG_H_
#define _UI_DIALOG_H_

#include "NDUILayer.h"
#include "UISpriteNode.h"
#include "UIHyperlink.h"
#include "globaldef.h"


using namespace NDEngine;

typedef struct _TAGDLGOPION
{
	std::string strOption;
	int			nAction;
}DLGOPION;

typedef std::vector<DLGOPION>		VEC_DLG_OPTION;
typedef VEC_DLG_OPTION::iterator	VEC_DLG_OPTION_IT;

class CUIDlgOptBtn :
public NDUIButton
{
	DECLARE_CLASS(CUIDlgOptBtn)
	CUIDlgOptBtn();
	~CUIDlgOptBtn();
	
public:
	void Initialization(); override
	void SetFrameRect(CGRect rect); override
	void SetBoundRect(CGRect rect);
	void SetLinkText(const char* text);
	void SetLinkTextFontSize(unsigned int uiFontSize);
	void SetLinkTextColor(cocos2d::ccColor4B color);
	
private:
	CUIHyperlinkText*			m_textHpyerlink;
	CUISpriteNode*				m_sprTip;
};

//////////////////////////////////////////////////////////////////////

class CUIDialog :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITargetDelegate
{
	DECLARE_CLASS(CUIDialog)
	CUIDialog();
	~CUIDialog();

public:
	void Initialization(); override
	void SetTitle(const char* title);
	void SetContent(const char* content);
	void SetInfo(const char* info);
	void SetPicture(NDPicture* pic);
	void SetOptions(VEC_DLG_OPTION& vOpt);
	void AddOption(DLGOPION& dlgOpt);
	void AddOption(const char* opt, int nAction);
	unsigned int GetOptionCount();
	void ClearOptions();
	void Close();
	
protected:
	virtual void OnClickOpt(int nOptIndex);
	virtual bool OnClose();
protected:
	typedef std::vector<CUIDlgOptBtn*>		VEC_UI_OPT;
	typedef VEC_UI_OPT::iterator			VEC_UI_OPT_IT;
	
	ID_VEC				m_vId;
	VEC_UI_OPT			m_vUiOpt;
	unsigned int		m_uiOptHeight;
	
private:
	void ClrOption();
	void AddOpt(const char* text, int nAction);
	void SetUIText(const char* text, int nTag);
private:
	void OnButtonClick(NDUIButton* button); override
	bool OnTargetBtnEvent(NDUINode* uinode, int targetEvent);
};

#endif // _UI_DIALOG_H_
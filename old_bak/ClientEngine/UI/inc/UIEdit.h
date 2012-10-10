/*
 *  UIEdit.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_EDIT_H_ZJH_
#define _UI_EDIT_H_ZJH_

#include "NDPicture.h"
#include "CommonInput.h"
#include "NDUINode.h"

using namespace NDEngine;

class CUIEdit :
public NDUINode,
public CInputBase
{
	DECLARE_CLASS(CUIEdit)
	CUIEdit();
	~CUIEdit();
	
public:
	void Initialization(); override
	
	void SetText(const char* pszText);
	const char* GetText();
	
	void SetPassword(bool bSet);
	bool IsPassword();
	
	void SetMaxLength(unsigned int nLen);
	unsigned GetMaxLength();
	
	void SetMinLength(unsigned int nLen);
	unsigned GetMinLength();
	
	void SetImage(NDPicture* pic);
	void SetFocusImage(NDPicture* pic);
	
	void EnableAdjustView(bool bEnable);
	
	bool IsTextLessMinLen();
	bool IsTextMoreMaxLen();
	
private:
	NDPicture*					m_picImage;
	NDPicture*					m_picFocusImage;
	IPlatformInput*				m_pPlatformInput;
	unsigned int				m_nMinLen;
	unsigned int				m_nMaxLen;
	std::string					m_strText;
	bool						m_bPassword;
	bool						m_bEnableAjdustView;
	bool						m_bRecacl;
	
private:
	void InitInput();
	
protected:
	void draw(); override
	void SetVisible(bool visible); override
	
protected:
	bool OnInputReturn(CInputBase* base); override
	bool OnInputTextChange(CInputBase* base, const char* inputString); override
    void OnInputFinish(CInputBase* base); override
};

#endif // _UI_EDIT_H_ZJH_

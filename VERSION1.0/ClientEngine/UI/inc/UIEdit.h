/*
 *  UIEdit.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 网龙(DeNA). All rights reserved.
 *
 */




#ifndef _UI_EDIT_H_ZJH_
#define _UI_EDIT_H_ZJH_

#include "NDPicture.h"
#include "CommonInput.h"
#include "NDUINode.h"
#include "NDUILabel.h"
#include "NDDirector.h"

using namespace NDEngine;
//** chh 2012-06-19 **//
#define TEXT_LEFT_BORDER (5*NDDirector::DefaultDirector()->GetScaleFactor())    //输入框左边距设置
#define TEST_TEXT "测"                       //测试文字用于取文字大小
class CUIEdit :
public NDUINode,
public CInputBase
{
	DECLARE_CLASS(CUIEdit)
	CUIEdit();
	~CUIEdit();
	
public:
    static CUIEdit*	sharedCurEdit();
    
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
    void SetTextSize(unsigned int nSize);
	void SetTextColor(ccColor4B color);
    void SetFlag( int iFlag ){ m_iFlag = iFlag; }
    int GetFlag(){ return m_iFlag; }
	
private:
	NDPicture*					m_picImage;
	NDPicture*					m_picFocusImage;
	IPlatformInput*				m_pPlatformInput;
	static CUIEdit*             g_pCurUIEdit;
	unsigned int				m_nMinLen;
	unsigned int				m_nMaxLen;
	std::string					m_strText;
	bool						m_bPassword;
	bool						m_bEnableAjdustView;
	bool						m_bRecacl;
	ccColor4B					m_colorText;
	NDUILabel*					m_lbText;
	unsigned int                m_nTextSize;
    int                         m_iFlag;
	
private:
	void InitInput();
	void SetShowText(const char* text);
	void SetShowTextColor(ccColor4B color);
	void SetShowTextFontSize(int nFontSize);
	
protected:
	void draw(); override
	void SetVisible(bool visible); override
public:
	void SetFrameRect(CCRect rect); override
	bool AutoInputReturn(); 
	
protected:
	bool OnInputReturn(CInputBase* base); override
	bool OnInputTextChange(CInputBase* base, const char* inputString); override
    void OnInputFinish(CInputBase* base); override
	bool OnClick(NDObject* object); override
};

#endif // _UI_EDIT_H_ZJH_

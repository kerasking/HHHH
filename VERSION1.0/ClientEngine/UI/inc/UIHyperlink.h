/*
 *  UIHyperlink.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-23.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_HYPER_LINK_H_ZJH_
#define _UI_HYPER_LINK_H_ZJH_

#include "NDTextNode.h"
#include "NDUIButton.h"

using namespace NDEngine;

class CUIHyperlinkText : public NDUINode
{
	DECLARE_CLASS(CUIHyperlinkText)
	CUIHyperlinkText();
	~CUIHyperlinkText();
	
public:
	void Initialization(); override
	void SetLinkBoundRect(CGRect rectBound);
	void SetLinkText(const char* text);
	void SetLinkTextFontSize(unsigned int uiFontSize);
	void SetLinkTextColor(cocos2d::ccColor4B color);
	void SetLinkTextAlignment(int alignment);
	void EnableLine(bool bEnable);
	const char* GetLinkText();
	bool IsLineEnable();
	int  GetLinkTextAlignment();
private:
	CGRect					m_rectLinkRect;
	unsigned int			m_uiLinkFontSize;
	cocos2d::ccColor4B		m_colorLinkFont;
	NDUIText*				m_uiLinkText;
	bool					m_bLineEnabel;
	std::string				m_strText;
	LabelTextAlignment		m_alignment;
};

////////////////////////////////////////////////////////////////////////////

class CUIHyperlinkButton : public NDUIButton
{
	DECLARE_CLASS(CUIHyperlinkButton)
	CUIHyperlinkButton();
	~CUIHyperlinkButton();
	
public:
	void Initialization(); override
	void SetLinkBoundRect(CGRect rectBound);
	void SetLinkText(const char* text);
	void SetLinkTextFontSize(unsigned int uiFontSize);
	void SetLinkTextColor(cocos2d::ccColor4B color);
	void EnableLine(bool bEnable);
	void SetLinkTextAlignment(int alignment);
	int	 GetLinkTextAlignment();
private:
	CUIHyperlinkText*	m_hyperlinkText;
	
public:
	void draw();
};


#endif // _UI_HYPER_LINK_H_ZJH_
/*
 *  UICheckBox.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _CUI_CHECK_BOX_H_ZJH_
#define _CUI_CHECK_BOX_H_ZJH_

#include "NDUINode.h"
#include "NDUILabel.h"
#include "NDUIImage.h"
#include <string>

using namespace NDEngine;

class CUICheckBox :
public NDUINode
{
	DECLARE_CLASS(CUICheckBox)
	
	CUICheckBox();
	~CUICheckBox();
	
public:
	//void Initialization(const char* imgUnCheck, const char* imgCheck); hide
    void Initialization(NDPicture* imgUnCheck, NDPicture* imgCheck); hide
	
	void SetSelect(bool bSelect);
	bool IsSelect();
	
	void SetText(const char* text);
	const char* GetText();
	
	void SetTextFontColor(ccColor4B color);
	void SetTextFontSize(unsigned int unSize);
	
private:
	bool				m_bSelect;
	NDUIImage*			m_imgCheck;
	NDUIImage*			m_imgUnCheck;
	NDUILabel*			m_lbText;
	bool				m_bTextReCacl;
		
public:
	bool OnClick(NDObject* object); override
	
protected:
	void draw(); override
public:
	void SetFrameRect(CGRect rect); override
protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override
};

#endif // _CUI_CHECK_BOX_H_ZJH_
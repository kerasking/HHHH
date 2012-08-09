/*
 *  UIEdit.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIEdit.h"
#include "NDTargetEvent.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	#include "IphoneInput.h"
#endif

IMPLEMENT_CLASS(CUIEdit, NDUINode)
CUIEdit::CUIEdit()
{
	m_picImage				= NULL;
	m_picFocusImage			= NULL;
	m_pPlatformInput		= NULL;
	m_nMinLen				= 0;
	m_nMaxLen				= 0;
	m_bPassword				= false;
	m_bEnableAjdustView		= true;
	m_bRecacl				= true;
}

CUIEdit::~CUIEdit()
{
	CC_SAFE_DELETE(m_picImage);
	CC_SAFE_DELETE(m_picFocusImage);
	CC_SAFE_DELETE(m_pPlatformInput);
}

void CUIEdit::Initialization()
{
	NDUINode::Initialization();
	
	InitInput();
}

void CUIEdit::SetText(const char* pszText)
{
	m_strText	= pszText ? pszText : "";
	
	if (m_pPlatformInput)
	{
		m_pPlatformInput->SetText(m_strText.c_str());
	}
}

const char* CUIEdit::GetText()
{
	return m_strText.c_str();
}

void CUIEdit::SetPassword(bool bSet)
{
	m_bPassword	= bSet;
}

bool CUIEdit::IsPassword()
{
	return m_bPassword;
}

void CUIEdit::SetMaxLength(unsigned int nLen)
{
	m_nMaxLen	= nLen;
    if(m_pPlatformInput){
        m_pPlatformInput->SetLengthLimit(nLen);
    }
}

unsigned CUIEdit::GetMaxLength()
{
	return m_nMaxLen;
}

void CUIEdit::SetMinLength(unsigned int nLen)
{
	m_nMinLen	= nLen;
}

unsigned CUIEdit::GetMinLength()
{
	return m_nMinLen;
}

void CUIEdit::SetImage(NDPicture* pic)
{
	if (m_picImage)
	{
		CC_SAFE_DELETE(m_picImage);
	}
	
	m_picImage	= pic;
}

void CUIEdit::SetFocusImage(NDPicture* pic)
{
	if (m_picFocusImage)
	{
		CC_SAFE_DELETE(m_picFocusImage);
	}
	
	m_picFocusImage	= pic;
}

void CUIEdit::EnableAdjustView(bool bEnable)
{
	m_bEnableAjdustView	= bEnable;
}

bool CUIEdit::IsTextLessMinLen()
{
	return m_strText.size() < m_nMinLen;
}

bool CUIEdit::IsTextMoreMaxLen()
{
	return m_strText.size() > m_nMaxLen;
}

void CUIEdit::InitInput()
{
	if (m_pPlatformInput)
	{
		return;
	}
	
	// 加上平台处理,暂时先用iphone初始始 todo
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	m_pPlatformInput	= new CIphoneInput();
	m_pPlatformInput->Init();
	m_pPlatformInput->SetInputDelegate(this);
	m_pPlatformInput->Show();
#endif
}

void CUIEdit::draw()
{
	NDUINode::draw();
	
	if (!this->IsVisibled())
	{
		return;
	}
	
	CGRect	scrRect	= this->GetScreenRect();
	
	if (m_bRecacl && m_pPlatformInput)
	{
		m_pPlatformInput->SetFrame(scrRect.origin.x, scrRect.origin.y, scrRect.size.width, scrRect.size.height);
		m_pPlatformInput->SetText(m_strText.c_str());
		m_pPlatformInput->EnableSafe(m_bPassword);
		m_pPlatformInput->EnableAutoAdjust(m_bEnableAjdustView);
		m_bRecacl	= false;
	}
	
	NDPicture* pic = m_picImage;
	
	if (m_pPlatformInput && m_pPlatformInput->IsInputState() && m_picFocusImage)
	{
		pic	= m_picFocusImage;
	}
	
	if (pic)
	{
		pic->DrawInRect(scrRect);
	}
}

void CUIEdit::SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	
	if (m_pPlatformInput)
	{
		if (visible)
		{
			m_pPlatformInput->Show();
		}
		else 
		{
			m_pPlatformInput->Hide();
		}
	}
}

bool CUIEdit::OnInputReturn(CInputBase* base) 
{
	if (this != base)
	{
		return false;
	}
	
	if (!m_pPlatformInput)
	{
		return true;
	}
	
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";
	
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_RETURN))
	{
		return false;
	}
	
	return true; 
}
bool CUIEdit::OnInputTextChange(CInputBase* base, const char* inputString)
{ 
	if (this != base)
	{
		return false;
	}
	
	if (!m_pPlatformInput)
	{
		return true;
	}

	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_TEXT_CHANGE, inputString ? inputString : ""))
	{
		return false;
	}
	
	return true; 
}
void CUIEdit::OnInputFinish(CInputBase* base)
{
    if (this != base)
	{
		return;
	}
	
	if (!m_pPlatformInput)
	{
		return;
	}
	
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";
	
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_INPUT_FINISH))
	{
		return;
	}
}
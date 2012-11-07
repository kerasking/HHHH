/*
 *  UIEdit.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 网龙(DeNA). All rights reserved.
 *
 */

#include "UIEdit.h"
#include "ScriptUI.h"
#include "IphoneInput.h"
#include "NDDirector.h"
#include "define.h"
//#include "I_Analyst.h"

CUIEdit* CUIEdit::g_pCurUIEdit = NULL;
IMPLEMENT_CLASS(CUIEdit, NDUINode)
CUIEdit::CUIEdit()
{
	m_picImage				= NULL;
	m_picFocusImage			= NULL;
	m_pPlatformInput		= NULL;
	m_nMinLen				= 0;
	m_nMaxLen				= 9999;
	m_bPassword				= false;
	m_bEnableAjdustView		= true;
	m_bRecacl				= true;
	m_colorText				= ccc4(255, 255, 255, 255);
    //m_colorText				= ccc4(255, 0, 255, 255);
    m_iFlag                 = 0;
}

CUIEdit::~CUIEdit()
{
	SAFE_DELETE(m_lbText);
	SAFE_DELETE(m_picImage);
	SAFE_DELETE(m_picFocusImage);
    if(g_pCurUIEdit == this)
        g_pCurUIEdit = NULL;
	SAFE_DELETE(m_pPlatformInput);
}
CUIEdit* CUIEdit::sharedCurEdit()
{
    return g_pCurUIEdit;
}

void CUIEdit::Initialization()
{
	NDUINode::Initialization();
	
	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	//m_lbText->SetTextAlignment(LabelTextAlignmentLeftCenter);
	m_lbText->SetFontSize(14);
    //m_lbText->SetHasFontBoderColor(false);
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
	InitInput();
}
void CUIEdit::SetTextSize(unsigned int nSize)
{
    m_nTextSize = nSize * NDDirector::DefaultDirector()->GetScaleFactor();
    
    m_lbText->SetFontSize(nSize);
	if (m_pPlatformInput)
	{
		m_pPlatformInput->SetFontSize(nSize);
	}
    
    
}
void CUIEdit::SetText(const char* pszText)
{
	m_strText	= pszText ? pszText : "";
	
	if (m_pPlatformInput)
	{
		m_pPlatformInput->SetText(m_strText.c_str());
	}
	SetShowText(pszText);
}

const char* CUIEdit::GetText()
{
	return m_strText.c_str();
}

void CUIEdit::SetPassword(bool bSet)
{
	m_bPassword	= bSet;
	this->SetShowText(m_strText.c_str());
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
		SAFE_DELETE(m_picImage);
	}
	
	m_picImage	= pic;
}

void CUIEdit::SetFocusImage(NDPicture* pic)
{
	if (m_picFocusImage)
	{
		SAFE_DELETE(m_picFocusImage);
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

void CUIEdit::SetTextColor(ccColor4B color)
{
	m_colorText	= color;
	if (!m_pPlatformInput)
	{
		return;
	}
	m_pPlatformInput->SetTextColor(color.r / 255, color.g / 255, color.b / 255, color.a / 255);
	SetShowTextColor(color);
}
void CUIEdit::InitInput()
{
	if (m_pPlatformInput)
	{
		return;
	}
	
	// 加上平台处理,暂时先用iphone初始始 todo
	m_pPlatformInput	= new CIphoneInput();
	m_pPlatformInput->Init();
	m_pPlatformInput->SetInputDelegate(this);
	m_pPlatformInput->Hide();
	this->SetTextColor(m_colorText);
}
void CUIEdit::SetShowText(const char* text)
{
	if (!m_lbText) 
	{
		return;
	}
	if (!text)
	{
		m_lbText->SetText("");
		return;
	}
	std::string str		= text;
	if (IsPassword())
	{
		int nStrLen		= str.size();
		str				= "";
		for (int i = 0; i < nStrLen; i++) 
		{
			str			+= "*";
		}
	}
	m_lbText->SetText(str.c_str());
}
void CUIEdit::SetShowTextColor(ccColor4B color)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(color);
	}
}
void CUIEdit::SetShowTextFontSize(int nFontSize)
{
	if (m_lbText)
	{
		m_lbText->SetFontSize(nFontSize);
	}
}

void CUIEdit::draw()
{
    //TICK_ANALYST(ANALYST_CUIEdit);
	NDUINode::draw();
	
	if (!this->IsVisibled())
	{
		return;
	}
	
	CGRect	scrRect	= this->GetScreenRect();
	
	if (m_pPlatformInput)
	{
        //** chh 2012-06-19 **//
        CGRect scrRect = m_lbText->GetFrameRect();
        CGSize textSize = getStringSize(TEST_TEXT,m_lbText->GetFontSize());
        int HBorder = (this->GetScreenRect().size.height-textSize.height)/2;
        
        
		m_pPlatformInput->SetFrame(scrRect.origin.x, scrRect.origin.y+HBorder, scrRect.size.width, scrRect.size.height);
	}
	if (m_bRecacl && m_pPlatformInput)
	{
		m_pPlatformInput->SetText(m_strText.c_str());
		m_pPlatformInput->EnableSafe(m_bPassword);
		m_pPlatformInput->EnableAutoAdjust(m_bEnableAjdustView);
		m_pPlatformInput->SetStyleNone();
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
	if (m_pPlatformInput && !m_pPlatformInput->IsShow() && m_lbText)
	{
		CGRect rectText		= m_lbText->GetScreenRect();
		if (!CompareEqualFloat(rectText.origin.x, scrRect.origin.x) || 
			!CompareEqualFloat(rectText.origin.y, scrRect.origin.y))
		{
            CGRect rect = scrRect;
            rect.origin.x += TEXT_LEFT_BORDER;
            m_lbText->SetFrameRect(rect);
		}
        //m_lbText->SetFrameRect(scrRect);
		m_lbText->draw();
	}
}

void CUIEdit::SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	
	if (m_pPlatformInput)
	{
		if (visible)
		{
			//m_pPlatformInput->Show();
		}
		else 
		{
			m_pPlatformInput->Hide();
		}
	}
}
void CUIEdit::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	if (m_lbText)
	{
        CGRect rect = this->GetScreenRect();
        rect.origin.x += TEXT_LEFT_BORDER;
		m_lbText->SetFrameRect(rect);
	}
	m_bRecacl	= true;
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
	
	SetShowText(m_strText.c_str());
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
	return true; 
}
bool CUIEdit::AutoInputReturn() 
{
	if (!m_pPlatformInput)
	{
		return true;
	}
    //Is Hide Allready
	if (!m_pPlatformInput->IsShow())
    {
        return true;
    }
	const char* text	= m_pPlatformInput->GetText();
	m_strText			= text ? text : "";
	
	SetShowText(m_strText.c_str());
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
	return true; 
}

bool CUIEdit::OnInputTextChange(CInputBase* base, const char* inputString)
{ 
	if (this != base)
	{
		return false;
	}
	
    const char* text	= m_pPlatformInput->GetText();
    unsigned int strcount = strlen(text);
    if (strcount >= m_nMaxLen) {
        //** chh 2012-08-14 **//
        //return false;
    }
	if (!m_pPlatformInput)
	{
		return true;
	}
    if ( 1 == m_iFlag )
    {
        int i;
        for(i=0;inputString[i];i++)
        {
            if((inputString[i]<48)||(inputString[i]>57))
                return false;
        }
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
	
	SetShowText(m_strText.c_str());
    
	if (!OnScriptUiEvent(this, TE_TOUCH_EDIT_INPUT_FINISH))
	{
		return;
	}
	if (m_pPlatformInput)
	{
		m_pPlatformInput->Hide();
	}
}
bool CUIEdit::OnClick(NDObject* object)
{
	if (m_pPlatformInput)
	{
        g_pCurUIEdit = this;
		m_pPlatformInput->Show();
	}
    
	OnScriptUiEvent(this, TE_TOUCH_BTN_CLICK);//++Guosen 2012.8.1//点击时传递按钮点击事件给LUA脚本，
    
	return true;
}

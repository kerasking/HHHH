/*
 *  UIHyperlink.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-2-23.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIHyperlink.h"
#include "CCPointExtension.h"
#include "NDUtility.h"

IMPLEMENT_CLASS(CUIHyperlinkText, NDUINode)

CUIHyperlinkText::CUIHyperlinkText()
{
	m_uiLinkText			= NULL;
	m_uiLinkFontSize		= 14;
	m_colorLinkFont			= ccc4(255, 255, 0, 255);
	m_rectLinkRect			= CGRectZero;
	m_bLineEnabel			= true;
	m_alignment				= LabelTextAlignmentLeft;
}

CUIHyperlinkText::~CUIHyperlinkText()
{
}

void CUIHyperlinkText::Initialization()
{
	NDUINode::Initialization();
}

void CUIHyperlinkText::SetLinkBoundRect(CGRect rectBound)
{
	m_rectLinkRect			= rectBound;
	
	if ("" != m_strText)
	{
		std::string text = m_strText;
		SetLinkText(text.c_str());
	}
}

void CUIHyperlinkText::SetLinkText(const char* text)
{
	SAFE_DELETE_NODE(m_uiLinkText);
	
	m_strText = "";
	
	CGRect rect = CGRectZero;
	
	if (!text || 0 == strlen(text))
	{
		rect.size = CGSizeZero;
		this->SetFrameRect(rect);
		return;
	}
	
	CGSize textSize;
	textSize.width	= m_rectLinkRect.size.width;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, m_uiLinkFontSize);
	textSize.width	= NDUITextBuilder::DefaultBuilder()->StringWidthAfterFilter(text, textSize.width, m_uiLinkFontSize);
	m_uiLinkText	= NDUITextBuilder::DefaultBuilder()->Build(text, m_uiLinkFontSize, textSize, 
															   m_colorLinkFont, false, m_bLineEnabel); 
	CGRect rectText	= CGRectMake(0, 0, textSize.width, textSize.height);
	if ( LabelTextAlignmentLeft == m_alignment )
	{
		rect.origin.y	= (m_rectLinkRect.size.height - rectText.size.height) / 2;
	}
	else if ( LabelTextAlignmentRight == m_alignment )
	{
		rect.origin.x	= (m_rectLinkRect.size.width - rectText.size.width);
		rect.origin.y	= (m_rectLinkRect.size.height - rectText.size.height) / 2;
	}
	else if ( LabelTextAlignmentCenter == m_alignment )
	{
		rect.origin.x	= (m_rectLinkRect.size.width - rectText.size.width) / 2;
		rect.origin.y	= (m_rectLinkRect.size.height - rectText.size.height) / 2;
	}
	rect.origin			= ccpAdd(m_rectLinkRect.origin, rect.origin);
	rect.size			= rectText.size;
	
	m_uiLinkText->SetFrameRect(rectText);
	this->AddChild(m_uiLinkText);
	this->SetFrameRect(rect);
	m_strText			= text;
}

void CUIHyperlinkText::SetLinkTextFontSize(unsigned int uiFontSize)
{
	m_uiLinkFontSize	= uiFontSize;
}

void CUIHyperlinkText::SetLinkTextColor(ccColor4B color)
{
	m_colorLinkFont		= color;
}

void CUIHyperlinkText::SetLinkTextAlignment(int alignment)
{
	m_alignment			= (LabelTextAlignment)alignment;
}

void CUIHyperlinkText::EnableLine(bool bEnable)
{
	m_bLineEnabel		= bEnable;
}

const char* CUIHyperlinkText::GetLinkText()
{
	return m_strText.c_str();
}

bool CUIHyperlinkText::IsLineEnable()
{
	return m_bLineEnabel;
}

int CUIHyperlinkText::GetLinkTextAlignment()
{
	return m_alignment;
}

bool CUIHyperlinkText::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_uiLinkText)
	{
		m_uiLinkText	= NULL;
	}
	return true;
}
////////////////////////////////////////////////////////////////////////////

IMPLEMENT_CLASS(CUIHyperlinkButton, NDUIButton)

CUIHyperlinkButton::CUIHyperlinkButton()
{	
	m_hyperlinkText		= NULL;
	m_rectLinkRect		= CGRectZero;
}

CUIHyperlinkButton::~CUIHyperlinkButton()
{
}

void CUIHyperlinkButton::Initialization()
{
	NDUIButton::Initialization();
	
	this->CloseFrame();
	
	m_hyperlinkText		= new CUIHyperlinkText;
	m_hyperlinkText->Initialization();
	this->AddChild(m_hyperlinkText);
}

void CUIHyperlinkButton::SetLinkBoundRect(CGRect rectBound)
{
	if (!m_hyperlinkText)
	{
		return;
	}
	
	m_rectLinkRect		= rectBound;
	this->SetFrameRect(rectBound);
	rectBound.origin	= CGPointZero;
	m_hyperlinkText->SetLinkBoundRect(rectBound);
}

void CUIHyperlinkButton::SetLinkText(const char* text)
{
	if (!m_hyperlinkText)
	{
		return;
	}
	
	m_hyperlinkText->SetLinkText(text);
	CGRect rect		= this->GetFrameRect();
	CGRect rectText = m_hyperlinkText->GetFrameRect();
	rect.size		= rectText.size;
	int nAlign		= m_hyperlinkText->GetLinkTextAlignment();
	if (LabelTextAlignmentLeft != nAlign)
	{
		rect.origin	= ccpAdd(m_rectLinkRect.origin, rectText.origin);
		m_hyperlinkText->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
	}
	this->SetFrameRect(rect);
}

void CUIHyperlinkButton::SetLinkTextFontSize(unsigned int uiFontSize)
{
	if (!m_hyperlinkText)
	{
		return;
	}
	
	m_hyperlinkText->SetLinkTextFontSize(uiFontSize);
}

void CUIHyperlinkButton::SetLinkTextColor(ccColor4B color)
{
	if (!m_hyperlinkText)
	{
		return;
	}
	
	m_hyperlinkText->SetLinkTextColor(color);
}

void CUIHyperlinkButton::SetLinkTextAlignment(int alignment)
{	
	if (!m_hyperlinkText)
	{
		return;
	}
	
	return m_hyperlinkText->SetLinkTextAlignment(alignment);
}

int CUIHyperlinkButton::GetLinkTextAlignment()
{
	if (!m_hyperlinkText)
	{
		return 0;
	}
	
	return m_hyperlinkText->GetLinkTextAlignment();
}

void CUIHyperlinkButton::EnableLine(bool bEnable)
{
	if (!m_hyperlinkText)
	{
		return;
	}
	
	bool bUpdate  = m_hyperlinkText->IsLineEnable() != bEnable;
	m_hyperlinkText->EnableLine(bEnable);
	if (bUpdate)
	{
		std::string str = m_hyperlinkText->GetLinkText();
		this->SetLinkText(str.c_str());
	}
}

void CUIHyperlinkButton::draw()
{
	NDUIButton::draw();
}
bool CUIHyperlinkButton::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_hyperlinkText)
	{
		m_hyperlinkText	= NULL;
	}
	return true;
}

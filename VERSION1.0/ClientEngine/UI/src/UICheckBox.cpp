/*
 *  UICheckBox.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UICheckBox.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "NDPicture.h"
#include "NDTextNode.h"
#include "NDUtility.h"
#include "ScriptUI.h"
#include "NDTargetEvent.h"
#include "NDDirector.h"
#include "NDPath.h"
#include <string>
//#include "I_Analyst.h"

const int TAG_UITEXT	= 13869;

IMPLEMENT_CLASS(CUICheckBox, NDUINode)

CUICheckBox::CUICheckBox()
{
	m_lbText		= NULL;
	m_imgCheck		= NULL;
	m_imgUnCheck	= NULL;
	m_bSelect		= false;
	m_bTextReCacl	= false;
}

CUICheckBox::~CUICheckBox()
{
	
}

# if 0
void CUICheckBox::Initialization(const char* imgUnCheck, const char* imgCheck)
{
	NDUINode::Initialization();
	
	NDPicturePool& pool	= *(NDPicturePool::DefaultPool());
	
	std::string strUnCheckPath	= imgUnCheck ? imgUnCheck : GetImgPath("Res00/btn_hook_normal.png");
	std::string strCheckPath	= imgCheck ? imgCheck : GetImgPath("Res00/btn_hook_select.png");
	
	m_imgCheck	= new NDUIImage;
	m_imgCheck->Initialization();
	m_imgCheck->SetPicture(pool.AddPicture(strCheckPath), true);
	this->AddChild(m_imgCheck);
	
	m_imgUnCheck	= new NDUIImage;
	m_imgUnCheck->Initialization();
	m_imgUnCheck->SetPicture(pool.AddPicture(strUnCheckPath), true);
	this->AddChild(m_imgUnCheck);
	
	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	this->AddChild(m_lbText);
}
#endif 

void CUICheckBox::Initialization(NDPicture* imgUnCheck, NDPicture* imgCheck)
{
	NDUINode::Initialization();
	
	NDPicturePool& pool	= *(NDPicturePool::DefaultPool());
    if (!imgUnCheck)
    {
        std::string strUnCheckPath	= NDPath::GetImgPath("Res00/btn_hook_normal.png");
        imgUnCheck = pool.AddPicture(strUnCheckPath.c_str());
    }
    if (!imgCheck)
    {
        std::string strCheckPath	= NDPath::GetImgPath("Res00/btn_hook_select.png");
        imgCheck = pool.AddPicture(strCheckPath.c_str());
    }
	
	//std::string strUnCheckPath	= imgUnCheck ? imgUnCheck : GetImgPath("Res00/btn_hook_normal.png");
	//std::string strCheckPath	= imgCheck ? imgCheck : GetImgPath("Res00/btn_hook_select.png");
	
	m_imgCheck	= new NDUIImage;
	m_imgCheck->Initialization();
	m_imgCheck->SetPicture(imgCheck, true);
	this->AddChild(m_imgCheck);
	
	m_imgUnCheck	= new NDUIImage;
	m_imgUnCheck->Initialization();
	m_imgUnCheck->SetPicture(imgUnCheck, true);
	this->AddChild(m_imgUnCheck);
	
	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	this->AddChild(m_lbText);
}

void CUICheckBox::SetSelect(bool bSelect)
{
	m_bSelect	= bSelect;
}

bool CUICheckBox::IsSelect()
{
	return m_bSelect;
}

void CUICheckBox::SetText(const char* text)
{
	if (!m_lbText)
	{
		return;
	}
	
	m_lbText->SetText(text ? text : "");
	
	m_bTextReCacl = true;
}

const char* CUICheckBox::GetText()
{
	if (!m_lbText)
	{
		return "";
	}
	
	return m_lbText->GetText().c_str();
}

void CUICheckBox::SetTextFontColor(ccColor4B color)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(color);
	}
}

void CUICheckBox::SetTextFontSize(unsigned int unSize)
{
	if (m_lbText)
	{
		m_lbText->SetFontSize(unSize);
	}
	
	m_bTextReCacl = true;
}

bool CUICheckBox::OnClick(NDObject* object) 
{ 
	if (this != object)
	{
		return false;
	}
	
	m_bSelect	= !m_bSelect;
	
	OnScriptUiEvent(this, TE_TOUCH_CHECK_CLICK);
	
	return true; 
}

void CUICheckBox::draw()
{
 //   TICK_ANALYST(ANALYST_CUICheckBox);	
	NDUINode::draw();
	
	if (!this->IsVisibled())
	{
		return;
	}
	
	if ( (!m_lbText || m_lbText->GetText() == "")  && m_bTextReCacl )
	{
		CCRect scrRect  = this->GetScreenRect();
		if (m_imgCheck)
		{
			CCRect rect		= m_imgCheck->GetFrameRect();
			rect.origin		= CCPointZero;
			rect.size		= scrRect.size;
			m_imgCheck->SetFrameRect(rect);
		}
		
		if (m_imgUnCheck)
		{
			CCRect rect		= m_imgUnCheck->GetFrameRect();
			rect.origin		= CCPointZero;
			rect.size		= scrRect.size;
			m_imgUnCheck->SetFrameRect(rect);
		}
	}
	else if (m_lbText && m_bTextReCacl)
	{
		float	fBaseY			= 0;
		float	fStartX			= 0;
		float	fBoundWidth		= 0;
		if (m_imgUnCheck)
		{
			CCRect rect		= m_imgUnCheck->GetFrameRect();
			fBaseY			= rect.size.height + rect.origin.y;
			fStartX			= rect.size.width + rect.origin.x;
			fBoundWidth		= this->GetFrameRect().size.width - fStartX;
		}
		else
		{
			fBaseY			= this->GetFrameRect().size.height;
		}
		
		const char* str			= m_lbText->GetText().c_str();
		unsigned int fontsize	= m_lbText->GetFontSize();
		
		//float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
		//if (!CompareEqualFloat(fScaleFactor, 0.0f))
		//{
		//	fontsize	= fontsize / fScaleFactor; 
		//}
		
		CCSize textSize;
		textSize.width	= fBoundWidth;
		textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(str, textSize.width, fontsize);
		textSize.width	= NDUITextBuilder::DefaultBuilder()->StringWidthAfterFilter(str, textSize.width, fontsize);
		
		NDUIText* text	= NDUITextBuilder::DefaultBuilder()->Build(str, fontsize, textSize, m_lbText->GetFontColor());
		if (text)
		{
			this->RemoveChild(TAG_UITEXT, true);
			text->SetFrameRect(CCRectMake(fStartX,  fBaseY - textSize.height, textSize.width, textSize.height));
			text->SetTag(TAG_UITEXT);
			this->AddChild(text);
		}
		
		m_bTextReCacl	= false;
	}
	
	if (m_imgCheck)
	{
		m_imgCheck->SetVisible(m_bSelect);
	}
	
	if (m_imgUnCheck)
	{
		m_imgUnCheck->SetVisible(!m_bSelect);
	}
}

void CUICheckBox::SetFrameRect(CCRect rect)
{
	NDUINode::SetFrameRect(rect);
	
	if (m_imgCheck)
	{
		CCSize size	= m_imgCheck->GetPicSize();
		if (size.height > rect.size.height)
		{
			size.height = rect.size.height;
		}
		m_imgCheck->SetFrameRect(CCRectMake(0, (rect.size.height - size.height) / 2, size.width, size.height));
	}
	
	if (m_imgUnCheck)
	{
		CCSize size	= m_imgUnCheck->GetPicSize();
		if (size.height > rect.size.height)
		{
			size.height = rect.size.height;
		}
		m_imgUnCheck->SetFrameRect(CCRectMake(0, (rect.size.height - size.height) / 2, size.width, size.height));
	}
}
bool CUICheckBox::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_imgCheck)
	{
		m_imgCheck		= NULL;
	}
	else if (pNode == m_imgUnCheck)
	{
		m_imgUnCheck	= NULL;
	}
	else if (pNode == m_lbText)
	{
		m_lbText		= NULL;
	}
	return true;
}

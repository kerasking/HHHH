/*
 *  UIRadioButton.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIRadioButton.h"
#include "NDTargetEvent.h"

IMPLEMENT_CLASS(CUIRadioButton,CUICheckBox)

CUIRadioButton::CUIRadioButton()
{
	INIT_AUTOLINK(CUIRadioButton);
}

CUIRadioButton::~CUIRadioButton()
{
}

void CUIRadioButton::Initialization(const char* imgUnCheck, const char* imgCheck)
{
	std::string strUnCheckPath	= imgUnCheck ? imgUnCheck : "";//todo(zjh)GetImgPath("Res00/btn_circle_normal.png");
	std::string strCheckPath	= imgCheck ? imgCheck : "";//todo(zjh)GetImgPath("Res00/btn_circle_select.png");
	
	CUICheckBox::Initialization(strUnCheckPath.c_str(), strCheckPath.c_str());
}

bool CUIRadioButton::OnClick(NDObject* object)
{
	if (this != object)
	{
		return false;
	}
	
	this->DispatchClickOfViewr(object);
	
	return true;
}

IMPLEMENT_CLASS(CUIRadioGroup, NDUINode)
	
CUIRadioGroup::CUIRadioGroup()
{
}

CUIRadioGroup::~CUIRadioGroup()
{
}

void CUIRadioGroup::AddRadio(CUIRadioButton* radio)
{
	this->RemoveRadio(radio);
	
	if (NULL == radio)
	{
		return;
	}
	
	if (m_vRadioLink.empty())
	{
		radio->SetSelect(true);
	}
	
	m_vRadioLink.push_back(radio->QueryLink());
	
	radio->AddViewer(this);
}

void CUIRadioGroup::RemoveRadio(CUIRadioButton* radio)
{
	if (!radio)
	{
		return;
	}
	
	VEC_RADIO_LINK_IT it = m_vRadioLink.begin();
	
	while (it != m_vRadioLink.end())
	{
		CUIRadioButton* p = (*it).Pointer();
		
		if ( !( !p || p == radio) )
		{	
			it++;
			continue;
		}
		
		it = m_vRadioLink.erase(it);
	}
	
	radio->RemoveViewer(this);
}

bool CUIRadioGroup::ContainRadio(CUIRadioButton* radio)
{
	if (!radio)
	{
		return false;
	}
	
	VEC_RADIO_LINK_IT it = m_vRadioLink.begin();
	for (; it != m_vRadioLink.end(); it++) 
	{
		CUIRadioButton* p = (*it).Pointer();
		if (p && p == radio)
		{
			return true;
		}
	}
	
	return false;
}

void CUIRadioGroup::SetIndexSelected(unsigned int nIndex)
{
	size_t size	= m_vRadioLink.size();
	if (nIndex >= size)
	{
		return;
	}
	
	SetRadioSelected(m_vRadioLink[nIndex].Pointer());
}

void CUIRadioGroup::SetRadioSelected(CUIRadioButton* radio)
{
	if (!radio || !ContainRadio(radio))
	{
		return;
	}
	
	size_t size	= m_vRadioLink.size();
	
	for (size_t i = 0; i < size; i++) 
	{
		
		CUIRadioButton* p = m_vRadioLink[i].Pointer();
		if (p)
		{
			p->SetSelect(p == radio);
		}
	}	
}

CUIRadioButton* CUIRadioGroup::GetSelectedRadio()
{
	size_t nIndex	= GetSelectedIndex();
	
	if (size_t(-1) == nIndex)
	{
		return NULL;
	}
	
	return m_vRadioLink[nIndex].Pointer();
}

unsigned int CUIRadioGroup::GetSelectedIndex()
{
	size_t size	= m_vRadioLink.size();
	
	for (size_t i = 0; i < size; i++) 
	{
		
		CUIRadioButton* p = m_vRadioLink[i].Pointer();
		if (p && p->IsSelect())
		{
			return i;
		}
	}
	
	return size_t(-1);
}

bool CUIRadioGroup::OnClick(NDObject* object)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIRadioButton)))
	{
		return false;
	}
	
	if (!ContainRadio((CUIRadioButton*)object))
	{
		return false;
	}
	
	VEC_RADIO_LINK_IT it = m_vRadioLink.begin();
	for (; it != m_vRadioLink.end(); it++) 
	{
		CUIRadioButton* p = (*it).Pointer();
		if ( !p )
		{
			continue;
		}
		
		p->SetSelect(p == object);
	}
	
	OnScriptUiEvent(this, TE_TOUCH_RADIO_GROUP);
	
	return true;
}

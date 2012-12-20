/*
 *  UITabLogic.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-5-11.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UITabLogic.h"
#include "NDUIButton.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(CUITabLogic, NDUINode)

CUITabLogic::CUITabLogic()
{
	INC_NDOBJ_RTCLS
}

CUITabLogic::~CUITabLogic()
{
	DEC_NDOBJ_RTCLS
}

void CUITabLogic::AddTab(NDUIButton* tab, NDUINode* client)
{
	if (!tab)
	{
		return;
	}
	
	TAB_DATA tabdata;
	tabdata.tab			= tab->QueryProtocolLink();
	
	if (client)
	{
		tabdata.client		= client->QueryProtocolLink();
	}
	
	if (tab)
	{
		tab->AddViewer(this);
	}
	
	m_vTabData.push_back(tabdata);
}

bool CUITabLogic::OnClick(NDObject* object)
{
	VEC_TAB_DATA_IT	it		= m_vTabData.begin();
	
	int nSelIndex			= -1;
	
	for (int i = 0; it != m_vTabData.end(); it++, i++) 
	{
		if (object == (*it).tab.Pointer())
		{
			nSelIndex		= i;
			break;
		}
	}

	if (-1 == nSelIndex)
	{
		return false;
	}
	
	this->SelectWithIndex(nSelIndex);
	
	return true;
}

void CUITabLogic::Select(NDUIButton* tab)
{
	this->OnClick(tab);
}

void CUITabLogic::SelectWithIndex(int nIndex)
{
	if (nIndex < 0 || nIndex >= (int)m_vTabData.size())
	{
		return;
	}
	
	for (size_t i = 0; i < m_vTabData.size(); i++) 
	{
		bool bSel			= i == size_t(nIndex);
		
		NODE_TAB& tab		= m_vTabData[i].tab;
		NODE_CLIENT client	= m_vTabData[i].client;
		
		if (tab && tab->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButton* btn	= (NDUIButton*)tab.Pointer();
			
			//guohao NDUIBUTTON.H
			//btn->TabSel(bSel);
		}
		
		if (client && client->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
		{
			NDUINode* node	= (NDUINode*)client.Pointer();
			node->SetVisible(bSel);
		}
	}
}
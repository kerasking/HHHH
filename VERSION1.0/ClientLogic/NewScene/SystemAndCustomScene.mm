/*
 *  SystemAndCustomScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SystemAndCustomScene.h"
#include "SystemAndCustomLayer.h"
#include "NDUtility.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"

enum 
{
	eSysAndCusBegin = 0,
	eSysAndCusSystem = eSysAndCusBegin,
	eSysAndCusCustom,
	eSysAndCusEnd,
};

enum
{
	eSysBegin = 0,
	eSysSet = eSysBegin,
	eSysEnd,
};

enum  
{
	eCustomBegin = 0,
	eCustomGongGao = eCustomBegin,
	eCustomActivity,
	eCustomDeclare,
	eCustomPassword,
	eCustomFeedBack,
	eCustomEnd,
};

IMPLEMENT_CLASS(SystemAndCustomScene, NDCommonSocialScene)

SystemAndCustomScene::SystemAndCustomScene()
{
	m_tabSystem = m_tabCustom = NULL;
}

SystemAndCustomScene::~SystemAndCustomScene()
{
	CustomActivity::ClearData();
	
	CustomDeclaration::ClearDeclareData();
}

SystemAndCustomScene* SystemAndCustomScene::Scene(bool onlySetting/*=false*/)
{
	SystemAndCustomScene *scene = new SystemAndCustomScene;
	
	scene->Initialization(onlySetting);
	
	return scene;
}

void SystemAndCustomScene::Initialization(bool onlySetting/*=false*/)
{
	NDCommonSocialScene::Initialization();
	
	if (onlySetting) 
		InitTab(1);
	else
		InitTab(eSysAndCusEnd);
	
	for(int j = eSysAndCusBegin; j < eSysAndCusEnd; j++)
	{
		if (onlySetting && j != eSysAndCusSystem) 
			continue;
			
		TabNode* tabnode = GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = 18*(17+j);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	SetClientLayerBackground(eSysAndCusSystem, true);
	InitSystem(GetClientLayer(eSysAndCusSystem));
	
	if (!onlySetting) 
	{
		SetClientLayerBackground(eSysAndCusCustom, true);
		InitCustom(GetClientLayer(eSysAndCusCustom));
	}
	
	SetTabFocusOnIndex(eSysAndCusSystem);
}

void SystemAndCustomScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void SystemAndCustomScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonSocialScene::OnTabLayerSelect(tab, lastIndex, curIndex);
}

void SystemAndCustomScene::OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex)
{
	if (tab == m_tabCustom)
	{
		if (curIndex == eCustomActivity)
		{
			if (CustomActivity::HasData()) return;
			
			ShowProgressBar;
			NDTransData bao(_MSG_ACTIVITY);
			SEND_DATA(bao);
		}
		else if (curIndex == eCustomDeclare)
		{
			if (CustomDeclaration::HasDeclareData()) return;
			
			ShowProgressBar;
			NDTransData bao(_MSG_CUSTOMER_SERVICE);
			SEND_DATA(bao);
		}
	}
}

void SystemAndCustomScene::InitSystem(NDUIClientLayer* client)
{	
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	m_tabSystem = new NDHFuncTab;
	m_tabSystem->Initialization(1);
	m_tabSystem->SetDelegate(this);
	
	const char * title[eSysEnd] = 
	{
		NDCommonCString("set"),
	};
	
	for (int i = eSysBegin; i < eSysEnd; i++) 
	{
		TabNode* tabnode = m_tabSystem->GetTabNode(i);
		
		tabnode->SetText(title[i]);
	}
	
	NDUIClientLayer *clientTab = m_tabSystem->GetClientLayer(0);
	
	SystemSetting *settting = new SystemSetting;
	settting->Initialization();
	settting->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
	clientTab->AddChild(settting);
	
	client->AddChild(m_tabSystem);
}

void SystemAndCustomScene::InitCustom(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	m_tabCustom = new NDHFuncTab;
	m_tabCustom->Initialization(5);
	m_tabCustom->SetDelegate(this);
	
	const char * title[eCustomEnd] = 
	{
		NDCommonCString("GongGao"),
		NDCommonCString("active"),
		NDCommonCString("declare"),
		NDCommonCString("password"),
		NDCommonCString("feedback"),
	};
	
	NDUILayer *tmp[eCustomEnd] =
	{
		new CustomGongGao,
		new CustomActivity,
		new CustomDeclaration,
		new CustomPassword,
		new CustomFeedBack,
	};
	
	for (int i = eCustomBegin; i < eCustomEnd; i++) 
	{
		TabNode* tabnode = m_tabCustom->GetTabNode(i);
		
		tabnode->SetText(title[i]);
		
		NDUIClientLayer *clientTab = m_tabCustom->GetClientLayer(i);
		
		if (i == eCustomDeclare)
			((CustomDeclaration*)(tmp[i]))->Initialization();
		else
			tmp[i]->Initialization();
		tmp[i]->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
		clientTab->AddChild(tmp[i]);
	}
	
	client->AddChild(m_tabCustom);
	
	//tab->SetFocusTabIndex(eCustomBegin);
}

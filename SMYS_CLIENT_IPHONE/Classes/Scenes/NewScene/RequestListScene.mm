/*
 *  RequestListScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RequestListScene.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "NewHelpScene.h"

enum 
{
	eListBegin = 0,
	eRequestList = eListBegin,
	eHelp,
	eListEnd,
};

IMPLEMENT_CLASS(RequestListScene, NDCommonScene)

RequestListScene* RequestListScene::Scene()
{
	RequestListScene *scene = new RequestListScene;
	
	scene->Initialization();
	
	return scene;
}

RequestListScene::RequestListScene()
{
	m_tabNodeSize.width = 150;
	m_request = NULL;
	m_tabFunc = NULL;
	m_btnClear = NULL;
}

RequestListScene::~RequestListScene()
{
}

void RequestListScene::Initialization()
{
	NDCommonScene::Initialization();
	
	SAFE_DELETE_NODE(m_btnNext);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *pic = pool.AddPicture(GetImgPathNew("newui_btn.png"));
	
	NDPicture *picClear = pool.AddPicture(GetImgPathNew("request_clear.png"));
	
	CGSize size = pic->GetSize();
	
	CGSize sizeClear = picClear->GetSize();
	
	m_btnClear = new NDUIButton;
	
	m_btnClear->Initialization();
	
	m_btnClear->SetFrameRect(CGRectMake(7, 37-size.height, size.width, size.height));
	
	m_btnClear->SetBackgroundPicture(pic, NULL, false, CGRectZero, true);
	
	m_btnClear->SetImage(picClear, true, CGRectMake((size.width-sizeClear.width)/2, (size.height-sizeClear.height)/2, sizeClear.width, sizeClear.height), true);
	
	m_btnClear->SetDelegate(this);
	
	m_layerBackground->AddChild(m_btnClear);
	
	const char * tabtext[eListEnd] = 
	{
		NDCommonCString("ImmedInfo"),
		NDCommonCString("help")
	};
	
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 150, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 150, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == eRequestList) 
		{
			this->InitRequestList(client);
		}
		
		if (i == eHelp) 
		{
			this->InitHelp(client);
		}
	}
	
	this->SetTabFocusOnIndex(eRequestList, true);
}

void RequestListScene::InitRequestList(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	m_tabFunc = new NDFuncTab;
	m_tabFunc->Initialization(1, CGPointMake(0, 5), CGSizeMake(25, 63), 0, 0, true);
	m_tabFunc->SetDelegate(this);
	
	for(int j =0; j<1; j++)
	{
		TabNode* tabnode = m_tabFunc->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = 18*5;
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	client->AddChild(m_tabFunc);
	
	m_request = new NewGameUIRequest;
	m_request->Initialization();
	m_tabFunc->GetClientLayer(0)->AddChild(m_request);
}

void RequestListScene::InitHelp(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tabFunc = new NDFuncTab;
	tabFunc->Initialization(1, CGPointMake(325, 5), CGSizeMake(25, 63), 0, 0, false, 480-325);
	tabFunc->SetDelegate(this);
	
	for(int j =0; j<1; j++)
	{
		TabNode* tabnode = tabFunc->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = 18*15;
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	client->AddChild(tabFunc);
	
	//NDUIClientLayer* clientTab =  tabFunc->GetClientLayer(0);
	NewHelpLayer *helpLayer = new NewHelpLayer;
	helpLayer->Initialization();
	helpLayer->SetFrameRect(CGRectMake(0, 0, sizeClient.width, sizeClient.height));
	client->AddChild(helpLayer);
}

void RequestListScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnClear)
	{
		if (m_request)
			m_request->clearRequest();
	}
	else
	{
		OnBaseButtonClick(button);
	}
}

void RequestListScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonScene::OnTabLayerSelect(tab, lastIndex, curIndex);
	
	if (m_btnClear) 
	{
		m_btnClear->SetVisible(curIndex == eRequestList);
	}
}
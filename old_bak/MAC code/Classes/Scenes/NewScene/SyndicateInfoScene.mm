/*
 *  SyndicateInfoScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-9-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateInfoScene.h"
#include "NDDirector.h"
#include "NDPicture.h"
#include "NDUtility.h"
#include "NDUIMemo.h"
#include "NDPath.h"

IMPLEMENT_CLASS(SyndicateInfoScene, NDCommonSocialScene)

SyndicateInfoScene::SyndicateInfoScene()
{
	
}

SyndicateInfoScene::~SyndicateInfoScene()
{
	
}

void SyndicateInfoScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void SyndicateInfoScene::Initialization(const string& strTabTitle, const string& strInfo)
{
	NDCommonSocialScene::Initialization();
	
	this->SetDelegate(this);
	
	SAFE_DELETE_NODE(m_tab);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize titleSize = getStringSize(strTabTitle.c_str(), 18);
	
	NDHFuncTab *tab = new NDHFuncTab;
	tab->Initialization(1, CGSizeMake(titleSize.width + 10, 34));
	tab->SetFrameRect(CGRectMake(0, 0, titleSize.width + 10, 40));
	TabNode* tabnode = tab->GetTabNode(0);
	tabnode->SetImage(pool.AddPicture(NDPath::GetImgPathNew("newui_tab_unsel.png"), titleSize.width + 10, 31), 
					  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_sel.png"), titleSize.width + 10, 34),
					  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_selarrow.png")));
	
	tabnode->SetText(strTabTitle.c_str());
	tabnode->SetTextColor(ccc4(245, 226, 169, 255));
	tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
	tabnode->SetTextFontSize(18);
	
	this->AddChild(tab);
	
	NDUIImage* bg = new NDUIImage;
	bg->Initialization();
	bg->SetFrameRect(CGRectMake(0, 43, 480, 272));
	bg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 480, 272), true);
	this->AddChild(bg);
	
	NDUIMemo* memo = new NDUIMemo;
	memo->Initialization();
	memo->SetFontColor(ccc4(187, 19, 19, 255));
	memo->SetBackgroundColor(ccc4(107, 158, 156, 0));
	memo->SetFrameRect(CGRectMake(20.0f, 57, 440.0f, 230.0f));
	memo->SetText(strInfo.c_str());
	this->AddChild(memo);
	
	this->SetTabFocusOnIndex(0, true);
}


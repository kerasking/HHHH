/*
 *  SelectBagScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SelectBagScene.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "ItemMgr.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDMsgDefine.h"
#include "define.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "NDPath.h"
#include <sstream>

#define title_height (28)
#define money_image ([[NSString stringWithFormat:@"%s", NDPath::GetImgPath("money.png")] UTF8String])
#define emoney_image ([[NSString stringWithFormat:@"%s", NDPath::GetImgPath("emoney.png")] UTF8String])

IMPLEMENT_CLASS(SelectBagScene, NDScene)

SelectBagScene::SelectBagScene()
{
	m_menuLayer = NULL;
	m_itembagPlayer = NULL;
	m_imageNumMoney = NULL;
	m_imageNumEMoney = NULL;
	m_picMoney = NULL;
	m_picEMoney = NULL;
	m_imageMoney = NULL;
	m_imageEMoney = NULL;
//	m_picBag = NULL;
//	m_imageBag = NULL;
	m_iType = 0;
	m_iNpcID = 0;
	
	m_lbTitle = NULL;
}	

SelectBagScene::~SelectBagScene()
{
	SAFE_DELETE(m_picMoney);
	SAFE_DELETE(m_picEMoney);
	//SAFE_DELETE(m_picBag);
}

void SelectBagScene::Initialization(int iType, int iNpcID)
{
	m_iType = iType;
	
	m_iNpcID = iNpcID;
	
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetDelegate(this);
	m_menuLayer->SetBackgroundColor(BKCOLOR4);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winSize.width, title_height));
	m_menuLayer->AddChild(m_lbTitle);
	
	m_picMoney = NDPicturePool::DefaultPool()->AddPicture(money_image);
	m_picMoney->Cut(CGRectMake(0, 0, 16, 16)); 
	m_picEMoney = NDPicturePool::DefaultPool()->AddPicture(emoney_image);
	m_picEMoney->Cut(CGRectMake(0, 0, 16, 16));
	
	m_imageEMoney =  new NDUIImage;
	m_imageEMoney->Initialization();
	m_imageEMoney->SetPicture(m_picMoney);
	m_imageEMoney->SetFrameRect(CGRectMake(320, 8, 16, 16));
	m_menuLayer->AddChild(m_imageEMoney);
	
	m_imageMoney =  new NDUIImage;
	m_imageMoney->Initialization();
	m_imageMoney->SetPicture(m_picEMoney);
	m_imageMoney->SetFrameRect(CGRectMake(80, 8, 16, 16));
	m_menuLayer->AddChild(m_imageMoney);
	
	NDPlayer& player = NDPlayer::defaultHero();
	m_imageNumEMoney = new ImageNumber;
	m_imageNumEMoney->Initialization();
	m_imageNumEMoney->SetTitleRedNumber(player.eMoney);
	m_imageNumEMoney->SetFrameRect(CGRectMake(108, 8, 60, 11));
	m_menuLayer->AddChild(m_imageNumEMoney);
	
	m_imageNumMoney = new ImageNumber;
	m_imageNumMoney->Initialization();
	m_imageNumMoney->SetTitleRedNumber(player.money);
	m_imageNumMoney->SetFrameRect(CGRectMake(348, 8, 60, 11));
	m_menuLayer->AddChild(m_imageNumMoney);
	
	//m_picBag = NDPicturePool::DefaultPool()->AddPicture(bag_image);
//	m_picBag->Cut(CGRectMake(240, 160, 36, 19));
//	CGSize sizeBag = m_picBag->GetSize();
//	
//	m_imageBag =  new NDUIImage;
//	m_imageBag->Initialization();
//	m_imageBag->SetPicture(m_picBag);
//	m_imageBag->SetFrameRect(CGRectMake((winSize.width-sizeBag.width)/2, 6, sizeBag.width, sizeBag.height));
//	m_menuLayer->AddChild(m_imageBag);
	
	std::vector<Item*> vec_item;
	m_itembagPlayer = new GameItemBag;
	m_itembagPlayer->Initialization(vec_item);
	m_itembagPlayer->SetDelegate(this);
	m_itembagPlayer->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itembagPlayer->SetFrameRect(CGRectMake((winSize.width-ITEM_BAG_W)/2, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menuLayer->AddChild(m_itembagPlayer);
	
	UpdateBag();
}

bool SelectBagScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (item) 
	{
		std::stringstream ss; ss << item->getItemName() << " x " << int(item->iAmount);
		m_itembagPlayer->SetTitle(ss.str());
	} 
	else 
	{
		m_itembagPlayer->SetTitle("");
	}
	
	if (item && bFocused) 
	{
		NDTransData bao(_MSG_FARM_PRODUCE);
		bao << (unsigned char)m_iType << int(m_iNpcID) << int(item->iID);
		SEND_DATA(bao);
	}
	
	return true;
}

void SelectBagScene::UpdateBag()
{
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	
	std::vector<int> rules;
	
	std::string title;
	
	switch (m_iType) 
	{
		case 0:
			title = NDCommonCString("ZhongZhi");
			rules.push_back(8);
			rules.push_back(3);
			rules.push_back(0);
			rules.push_back(1);
			break;
		case 2:
			title = NDCommonCString("ShiFei");
			rules.push_back(8);
			rules.push_back(2);
			rules.push_back(0);
			rules.push_back(2);
			break;
		case 1:
			title = NDCommonCString("YangZhi");
			rules.push_back(8);
			rules.push_back(3);
			rules.push_back(0);
			rules.push_back(2);
			break;
		case 3:
			title = NDCommonCString("WeiSiLiao");
			rules.push_back(8);
			rules.push_back(2);
			rules.push_back(0);
			rules.push_back(3);
			break;
		case 4:
		case 5:
			title = NDCommonCString("JiaSuUp");
			rules.push_back(8);
			rules.push_back(2);
			rules.push_back(0);
			rules.push_back(6);
			break;
		default:
			title = "";
			break;
	}
	
	m_lbTitle->SetText(title.c_str());
	
	if (rules.empty()) {
		m_itembagPlayer->UpdateItemBag(itemlist);
	}else {
		m_itembagPlayer->UpdateItemBag(itemlist, rules);
	}
}

void SelectBagScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menuLayer->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void SelectBagScene::AfterClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (item && bFocused) {
		NDDirector::DefaultDirector()->PopScene();
	}
}

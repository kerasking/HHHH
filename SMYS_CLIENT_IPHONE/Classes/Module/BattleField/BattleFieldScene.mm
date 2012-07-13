/*
 *  BattleFieldScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "BattleFieldScene.h"
#include "NDUtility.h"
#include "BattleFieldData.h"
#include "BattleFieldApply.h"
#include "BattleFieldMgr.h"
#include "NDUISynLayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "ItemMgr.h"

#include <sstream>

IMPLEMENT_CLASS(BattleFieldScene, NDCommonSocialScene)

BattleFieldScene* BattleFieldScene::s_BFScene = NULL;

BattleFieldScene::BattleFieldScene()
{
	m_shop = NULL;
	
	m_apply = NULL;
	
	m_backstroy = NULL;
	
	s_BFScene = this;
	
	m_iCurDealBfDesc = eBattleField;
}

BattleFieldScene::~BattleFieldScene()
{
	s_BFScene = NULL;
}

BattleFieldScene* BattleFieldScene::Scene()
{
	BattleFieldScene *scene = new BattleFieldScene;
	
	scene->Initialization();
	
	return scene;
}

void BattleFieldScene::Initialization()
{
	NDCommonSocialScene::Initialization();
	
	InitTab(eBattleFieldEnd);
	
	for(int j = eBattleFieldBegin; j < eBattleFieldEnd; j++)
	{
		TabNode* tabnode = GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int index = 0;
		if (j == eBattleField)
			index = 20;
		else if (j == eBattleFieldShop)
			index = 19;
		else if (j == eBattleFieldBackStory)
			index = 21;
		int startX = 18*(index);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	SetClientLayerBackground(eBattleField);
	
	SetClientLayerBackground(eBattleFieldBackStory, true);
	
	SetClientLayerBackground(eBattleFieldShop, true);
	
	// 每次都清掉,去请求
	BattleField::mapApplyDesc.clear();
	
	this->SetTabFocusOnIndex(eBattleField, true);
}

void BattleFieldScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void BattleFieldScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonSocialScene::OnTabLayerSelect(tab, lastIndex, curIndex);
	
	if (curIndex == eBattleField || curIndex == eBattleFieldBackStory) 
	{
		map_bf_desc& desc = BattleField::mapApplyDesc;
		if (desc.empty())
		{
			BattleFieldMgrObj.SendRequestBfDesc();
			m_iCurDealBfDesc = curIndex;
			return;
		}
		
		if (curIndex == eBattleField)
			ShowBattleField();
		else if (curIndex == eBattleFieldBackStory)
			ShowBackStory();
	}
	else if (curIndex == eBattleFieldShop)
	{
		if (BattleField::mapItemInfo.empty() || BattleField::mapDesc.empty())
		{
			BattleField::mapItemInfo.clear();
			BattleField::mapDesc.clear();

			NDTransData bao(_MSG_SHOP_BATTLE);
			SEND_DATA(bao);
			ShowProgressBar;
			
			return;
		}
		
		ShowShop();
	}
}

void BattleFieldScene::InitBattleFiled(NDUIClientLayer* client)
{
	if (!client) return;
	
	m_apply = new BattleFieldApply;
	
	m_apply->Initialization();
	
	client->AddChild(m_apply);
}

void BattleFieldScene::OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex)
{
	
}

void BattleFieldScene::InitShop(NDUIClientLayer* client)
{	
	if (!client) return;
	
	m_shop = new BattleFieldShop;
	 
	m_shop->Initialization();
	 
	client->AddChild(m_shop); 
}

void BattleFieldScene::InitBackStory(NDUIClientLayer* client)
{
	if (!client) return;
	
	m_backstroy = new BattleFieldBackStory;
	
	m_backstroy->Initialization();
	
	client->AddChild(m_backstroy);
}

void BattleFieldScene::UpdateShop()
{
	if (!s_BFScene) return;
	
	if (s_BFScene->m_shop) s_BFScene->m_shop->UpdateShopInfo();
}

void BattleFieldScene::ShowBattleField()
{
	if (m_apply) return;
	
	InitBattleFiled(GetClientLayer(eBattleField));
	
	this->SetTabFocusOnIndex(eBattleField);
}

void BattleFieldScene::ShowBackStory()
{
	if (m_backstroy) return;
	
	InitBackStory(GetClientLayer(eBattleFieldBackStory));
}

void BattleFieldScene::ShowShop()
{
	if (m_shop) return;

	InitShop(GetClientLayer(eBattleFieldShop));
}

void BattleFieldScene::DealRecvBFDesc()
{
	if (m_iCurDealBfDesc == eBattleFieldBackStory)
		ShowBackStory();
	else if (m_iCurDealBfDesc == eBattleField)
		ShowBattleField();
}

#pragma mark 战场内死亡

#define TAG_TIMER_RELIVE (105)

IMPLEMENT_CLASS(BattleFieldRelive, NDUILayer)

BattleFieldRelive* BattleFieldRelive::s_instance = NULL;

int BattleFieldRelive::s_time = 0;

void BattleFieldRelive::SetTimeCount(int time)
{
	s_time = time;
}

void BattleFieldRelive::Show(int time/*=0*/)
{
	if (!s_instance)
	{
		NDDirector& director = *(NDDirector::DefaultDirector());
		NDScene* scene = director.GetRunningScene();
		while (scene && !scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			if (!director.PopScene())
				break;
			
			scene = director.GetRunningScene();
		}
		
		scene = director.GetRunningScene();
		
		if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			NDLog(@"BattleFieldRelive::Show faile since can not get gamescene");
			return;
		}
		
		s_instance = new BattleFieldRelive;
		s_instance->Initialization();
		scene->AddChild(s_instance, UIDIALOG_Z);
	}
	
	s_instance->SetTime(time == 0 ? s_time : time);
}

void BattleFieldRelive::Hide()
{
	if (s_instance)
	{
		NDPlayer::defaultHero().setSafeProtected(true);
	}
	
	SAFE_DELETE_NODE(s_instance);
}

BattleFieldRelive::~BattleFieldRelive()
{
	ShowMask(false);
	
	s_instance = NULL;
}

void BattleFieldRelive::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	ShowMask(true);
	
	this->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	
	CGSize sizeRelive = CGSizeMake(100, 40);
	
	CGRect rectRelive = CGRectMake((winsize.width - sizeRelive.width)/2, 
								   (winsize.height - sizeRelive.height*2)/2, 
								    sizeRelive.width, sizeRelive.height);
	
	m_btnRelive = new NDUIButton;
	m_btnRelive->Initialization();
	m_btnRelive->SetFontSize(14);
	m_btnRelive->CloseFrame();
	m_btnRelive->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnRelive->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), rectRelive.size.width, rectRelive.size.height, true),
									 pool.AddPicture(GetImgPathNew("bag_btn_click.png"), rectRelive.size.width, rectRelive.size.height, true),
									 false, CGRectZero, true);
	m_btnRelive->SetFrameRect(rectRelive);
	m_btnRelive->SetTitle(NDCommonCString("relive"));
	m_btnRelive->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnRelive->SetFontSize(16);
	m_btnRelive->SetDelegate(this);
	this->AddChild(m_btnRelive);
	
	m_lbTime = new NDUILabel;
	m_lbTime->Initialization();
	m_lbTime->SetFontSize(14);
	m_lbTime->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbTime->SetTextAlignment(LabelTextAlignmentRight);
	m_lbTime->SetFrameRect(CGRectMake(0, (sizeRelive.height-14)/2, sizeRelive.width-10, 38));
	m_lbTime->SetFontColor(ccc4(255, 0, 0, 255));
	m_btnRelive->AddChild(m_lbTime);
	
	rectRelive.origin.y += rectRelive.size.height;
	m_btnReliveInCurPlace = new NDUIButton;
	m_btnReliveInCurPlace->Initialization();
	m_btnReliveInCurPlace->SetFontSize(12);
	m_btnReliveInCurPlace->CloseFrame();
	m_btnReliveInCurPlace->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnReliveInCurPlace->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), rectRelive.size.width, rectRelive.size.height, true),
									 pool.AddPicture(GetImgPathNew("bag_btn_click.png"), rectRelive.size.width, rectRelive.size.height, true),
									 false, CGRectZero, true);
	m_btnReliveInCurPlace->SetFrameRect(rectRelive);
	m_btnReliveInCurPlace->SetTitle(NDCommonCString("ReliveInPlace"));
	m_btnReliveInCurPlace->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnReliveInCurPlace->SetFontSize(16);
	m_btnReliveInCurPlace->SetDelegate(this);
	this->AddChild(m_btnReliveInCurPlace);
}

void BattleFieldRelive::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);
	
	if (tag == TAG_TIMER_RELIVE)
	{
		if (m_iCurTime > 0)
		{
			m_iCurTime -= 1;
			
			std::stringstream ss; ss << m_iCurTime;
			
			if (m_lbTime)
				m_lbTime->SetText(ss.str().c_str());
		}
		else
		{
			m_btnRelive->EnalbelBackgroundGray(false);
			
			//m_btnReliveInCurPlace->EnalbelBackgroundGray(false);
			
			if (m_lbTime)
				m_lbTime->SetText("");
			m_timer.KillTimer(this, TAG_TIMER_RELIVE);
		}
	}
}

void BattleFieldRelive::SetTime(int time)
{
	if (time <= 0)
	{
		m_btnRelive->EnalbelBackgroundGray(false);
		
		//m_btnReliveInCurPlace->EnalbelBackgroundGray(false);
		
		m_timer.KillTimer(this, TAG_TIMER_RELIVE);
		
		return;
	}
	
	m_btnRelive->EnalbelBackgroundGray(true);
	
	//m_btnReliveInCurPlace->EnalbelBackgroundGray(true);
	
	m_timer.SetTimer(this, TAG_TIMER_RELIVE, 1);
	
	m_iCurTime = time;
}

void BattleFieldRelive::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnReliveInCurPlace)
	{
		/*
		VEC_ITEM& itemList = ItemMgrObj.GetPlayerBagItems();
		for (size_t i = 0; i < itemList.size(); i++) {
			Item& item = *itemList.at(i);
			if (item.iItemType == 28000003) {
				sendItemUse(item);
				//table->SetVisible(false);
				return;
			}
		}
		showDialog("您没有复活道具");
		*/
		BattleFieldMgrObj.SendRequestBfRelive(true);
		return;
	}
	
	if (button == m_btnRelive)
	{
		if (m_iCurTime > 0)
			return;
		
		BattleFieldMgrObj.SendRequestBfRelive(button == m_btnReliveInCurPlace);
			
		return;
	}
}

BattleFieldRelive::BattleFieldRelive()
{
	m_layerMask = NULL;
	
	m_lbTime = NULL;
	
	m_btnRelive = m_btnReliveInCurPlace = NULL;
	
	m_iCurTime = 0;
}

void BattleFieldRelive::ShowMask(bool show)
{
	if (!show)
	{
		SAFE_DELETE_NODE(m_layerMask);
		
		return;
	}
	
	if (!m_layerMask)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (!scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
			return;
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		
		CGRect rectMask = CGRectMake(0, 0, winsize.width, winsize.height);
		
		m_layerMask = new NDUIMaskLayer;
		m_layerMask->Initialization();
		m_layerMask->SetFrameRect(rectMask);
		scene->AddChild(m_layerMask, MAP_MASKLAYER_Z);
	}
}

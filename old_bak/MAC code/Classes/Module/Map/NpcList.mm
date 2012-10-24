/*
 *  NpcList.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NpcList.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include "ChatInput.h"
#include "NDMapMgr.h"
#include "NDNpc.h"
#include "NDWorldMapData.h"
#include "CGPointExtension.h"
#include "AutoPathTip.h"

IMPLEMENT_CLASS(NpcList, NDUIMenuLayer)

NpcList* NpcList::s_instance = NULL;

void NpcList::refreshScroll()
{
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			NpcList *list = new NpcList;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList();
}

NDMapSwitch * GetMapSwitch(int iIndex)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	if (scene) 
	{
		NDMapLayer* maplayer = NDMapMgrObj.getMapLayerOfScene(scene);
		if (maplayer) 
		{
			NDMapData *mapdata = maplayer->GetMapData();
			
			if (mapdata && mapdata.switchs)
			{
				if (iIndex < int([mapdata.switchs count])) 
				{
					return [mapdata.switchs objectAtIndex:iIndex];
				}
			}
		}
	}
	
	return nil;
}

std::string GetDesMapStr(int srcMapId, int srcPassIndex)
{
	std::string name = NDCommonCString("NoOpen"), des = "";
	int destMapId = [[NDWorldMapData SharedData] getDestMapIdWithSourceMapId:srcMapId passwayIndex:srcPassIndex];
	if (destMapId > 0) 
	{
		PlaceNode *placeNode = [[NDWorldMapData SharedData] getPlaceNodeWithMapId:destMapId];
		if (placeNode) 
		{
			name = [placeNode.name UTF8String];
			
			int dx = name.find("(", 0);
			if (-1 == dx) 
			{
				dx = name.find(NDCommonCString("LianJiSec"), 0);
				if (-1 != dx) 
				{
					des = name.substr(0, dx);
				}
				else
				{
					des = name;
				}
			} 
			else 
			{
				des = name.substr(0, dx);
			}
		}
	}
	
	return des;
}


void NpcList::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void NpcList::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	this->releaseElement();
	
	const NDMapMgr::VEC_NPC& npcs = NDMapMgrObj.GetNpc();
	
	bool bChangeClr = false;
	NDNpc* npc = NULL;
	int iSizeNpc = 0;
	for (NDMapMgr::VEC_NPC::const_iterator it = npcs.begin(); it != npcs.end(); it++) {
		npc = *it;
		if (npc->GetType() == 6) {
			continue;
		}
		iSizeNpc++;
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = npc->m_id;
		se->m_text1 = npc->m_name;
		se->m_text2 = npc->dataStr;
		se->m_state = ES_ONLINE;
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), se);
		
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		sec->AddCell(st);
	}
	
	// 切屏
	NDMapMgr& mgr = NDMapMgrObj;
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	if (scene) 
	{
		NDMapLayer* maplayer = mgr.getMapLayerOfScene(scene);
		if (maplayer) 
		{
			NDMapData *mapdata = maplayer->GetMapData();
			
			if (mapdata && mapdata.switchs)
			{
				NSArray	*switchs = mapdata.switchs;
				
				for (int i = 0; i < (int)[switchs count]; i++)
				{
					NDMapSwitch *mapswitch = [switchs objectAtIndex:i];
					if (mapswitch) 
					{
						SocialElement* se = new SocialElement;
						this->m_vElement.push_back(se);
						se->m_id = -1;
						se->m_text1 = NDCommonCString("SwitcGo");
						se->m_text2 = mapswitch.descDesMap == nil ? "" : [mapswitch.descDesMap UTF8String];
						se->m_state = ES_ONLINE;
						se->m_param = i;
						
						SocialTextLayer* st = new SocialTextLayer;
						st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
										   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), se);
						
						if (bChangeClr) {
							st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
						} else {
							st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
						}
						
						bChangeClr = !bChangeClr;
						sec->AddCell(st);
					}
				}
			}
		}
	}
	
	this->m_tlMain->ReflashData();
	
	if (m_title && iSizeNpc) 
	{
		char buf[100] = {0x00};
		sprintf(buf, "区域NPC列表[1~%d]", iSizeNpc);
		m_title->SetText(buf);
	}
}

NpcList::NpcList()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
}

NpcList::~NpcList()
{
	s_instance = NULL;
	this->releaseElement();
}

void NpcList::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				this->RemoveFromParent(true);
			}
		}
	}
}

void NpcList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		int nHeight = 0;
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = NULL;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("自动导航");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("任务列表");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
		
		NDPlayer& role = NDPlayer::defaultHero();
		
		NDNpc* npc = NULL;
		if (m_curSelEle->m_id != -1) 
		{
			npc = NDMapMgrObj.GetNpcByID(m_curSelEle->m_id);
			if (npc == NULL) {
				return;
			}
		}
		else 
		{
			// 前往切屏点 me那边展示不管选啥都直接寻路过去
			if (CanAutoPath()) 
			{
				NDMapSwitch *mapswitch = GetMapSwitch(m_curSelEle->m_param);
				if (mapswitch) 
				{
					AutoPathTipObj.work(m_curSelEle->m_text2);
					this->OnButtonClick(this->GetCancelBtn());
					role.Walk(ccp(mapswitch.x*MAP_UNITSIZE, mapswitch.y*MAP_UNITSIZE), SpriteSpeedStep4);
				}
			}
			
			return;
		}
		
		switch (cellIndex) {
			case 0:
			{
				if (!CanAutoPath()) return;
				
				AutoPathTipObj.work(m_curSelEle->m_text1);
				this->OnButtonClick(this->GetCancelBtn());
				role.Walk(npc->GetPosition(), SpriteSpeedStep4);
			}
				break;
			case 1:
			{
				ShowProgressBar;
				NDTransData bao(_MSG_QUERY_TASK_LIST);
				bao << m_curSelEle->m_id;
				SEND_DATA(bao);
			}
				break;
			default:
				break;
		}
	}
}

void NpcList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	m_title = new NDUILabel;
	m_title->Initialization();
	m_title->SetText("区域NPC列表");
	m_title->SetFontSize(15);
	m_title->SetTextAlignment(LabelTextAlignmentCenter);
	m_title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	m_title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(m_title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 30, 476, 240));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
}

string NpcList::getCurNpcName()
{
	if (s_instance && s_instance->m_curSelEle) {
		return s_instance->m_curSelEle->m_text1;
	}
	return  "";
}

void NpcList::Close()
{
	if (s_instance) {
		s_instance->RemoveFromParent(true);
	}
}

bool NpcList::CanAutoPath()
{
	NDPlayer& role = NDPlayer::defaultHero();
	
	// 前往切屏点 me那边展示不管选啥都直接寻路过去
	if (role.IsInState(USERSTATE_BOOTH)) {
		GlobalShowDlg("提示", "您正处于摆摊状态中，暂时无法使用自动导航功能！");
		return false;
	}
	if (!role.isTeamLeader()
		&& role.isTeamMember()) {
		GlobalShowDlg("提示", "您不是队长，暂时无法使用自动导航功能！");
		return false;
	}
	if (role.IsInState(USERSTATE_HU_BIAO)) {
		GlobalShowDlg("提示", "您正在跑镖中，暂时无法使用自动导航功能！");
		return false;
	}
	
	return true;
}

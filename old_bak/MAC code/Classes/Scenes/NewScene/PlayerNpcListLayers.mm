/*
 *  PlayerNpcListLayers.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PlayerNpcListLayers.h"
#include "GameScene.h"
#include "NDMapMgr.h"
#include "NDUtility.h"
#include "NDNpc.h"
#include "NDDirector.h"
#include "CGPointExtension.h"
#include "NDPath.h"
#include "AutoPathTip.h"
#include "NDUISynLayer.h"
#include "OtherPlayerInfoScene.h"
#include "PlayerNpcListScene.h"
#include "ChatInput.h"
#include "EmailSendScene.h"
#include "NDPath.h"
#include <sstream>
#include "I_Analyst.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NpcTaskLayer, NDUILayer)

NpcTaskLayer::NpcTaskLayer()
{
	m_tlTasks = NULL;
	m_lbTaskTitle = NULL;
}

NpcTaskLayer::~NpcTaskLayer()
{
}

void NpcTaskLayer::ShowTaskInfo()
{
	if (m_tlTasks) {
		NDDataSource* ds = m_tlTasks->GetDataSource();
		if (ds) {
			NDSection* sec = ds->Section(0);
			if (sec) {
				uint uFocus = sec->GetFocusCellIndex();
				if (uFocus < sec->Count()) {
					NDUINode* cell = sec->Cell(uFocus);
					if (cell) {
						int idTask = cell->GetTag();
						
						Task* pTask = NewPlayerTask::QueryAcceptableTask(idTask);
						if (pTask && m_lbTaskTitle) {
							m_lbTaskTitle->SetText(pTask->taskTitle.c_str());
							m_taskInfo.RefreshTaskInfo(pTask, true);
						}
					}
				}
			}
		}
	}
}

void NpcTaskLayer::Initialization(vector<pair<int, string> >& vTasks)
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 1, 454, 279));
	this->SetBackgroundColor(ccc4(245, 226, 168, 255));

	NDUIImage* imgLeftBg = new NDUIImage;
	imgLeftBg->Initialization();
	imgLeftBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"), false), true);
	imgLeftBg->SetFrameRect(CGRectMake(0, 4, 203, 262));
	this->AddChild(imgLeftBg);
	
	NDUIImage* imgRightBg = new NDUIImage;
	imgRightBg->Initialization();
	imgRightBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), false), true);
	imgRightBg->SetFrameRect(CGRectMake(204, 0, 252, 274));
	this->AddChild(imgRightBg);
	
	m_lbTaskTitle = new NDUILabel;
	m_lbTaskTitle->Initialization();
	m_lbTaskTitle->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbTaskTitle->SetFrameRect(CGRectMake(3, 6, 100, 20));
	this->AddChild(m_lbTaskTitle);
	
	NDUIContainerScrollLayer *scrollLayer = new NDUIContainerScrollLayer;
	scrollLayer->Initialization();
	scrollLayer->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("attr_role_bg.png"), 194, 184), true);
	scrollLayer->SetFrameRect(CGRectMake(0, 29, 194, 184));
	this->AddChild(scrollLayer);
	m_taskInfo.SetScrollLayer(scrollLayer);
	
	
	m_tlTasks = new NDUITableLayer;
	m_tlTasks->Initialization();
	m_tlTasks->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlTasks->VisibleSectionTitles(false);
	m_tlTasks->SetFrameRect(CGRectMake(215, 10, 220, 244));
	m_tlTasks->VisibleScrollBar(false);
	m_tlTasks->SetCellsInterval(2);
	m_tlTasks->SetCellsRightDistance(0);
	m_tlTasks->SetCellsLeftDistance(0);
	m_tlTasks->SetDelegate(this);
	this->AddChild(m_tlTasks);
	NDDataSource* ds = new NDDataSource;
	m_tlTasks->SetDataSource(ds);
	
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	int cnt = vTasks.size();
	for (int i = 0; i < cnt; i++)
	{
		int idTask = vTasks.at(i).first;
		string& sTask = vTasks.at(i).second;
		
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(false);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(sTask.c_str());
		
		propDetail->SetFocusTextColor(ccc4(187, 19, 19, 255));
		propDetail->SetTag(idTask);
		
		sec->AddCell(propDetail);
	}
	
	sec->SetFocusOnCell(0);
	
	//m_tlTasks->ReflashData();
}

void NpcTaskLayer::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	int idTask = cell->GetTag();
	bool bAcceptable = false;
	Task* pTask = NDPlayer::defaultHero().GetPlayerTask(idTask);
	if (!pTask) {
		bAcceptable = true;
		pTask = NewPlayerTask::QueryAcceptableTask(idTask);
	}
	
	if (!pTask) {
		NDTransData bao(_MSG_QUERY_TASK_LIST_EX);
		bao << (unsigned char)0 << int(0);
		SEND_DATA(bao);
		ShowProgressBar;
	} else {
		m_lbTaskTitle->SetText(pTask->taskTitle.c_str());
		m_taskInfo.RefreshTaskInfo(pTask, bAcceptable);
	}
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NpcRole, NDUINode)

NpcRole::NpcRole()
{
	m_npc = NULL;
	m_switchPoint = NULL;
}

NpcRole::~NpcRole()
{
	SAFE_DELETE(m_npc);
	SAFE_DELETE(m_switchPoint);
}

void NpcRole::Initialization(NDLightEffect* switchPoint)
{
	NDUINode::Initialization();
	
	std::string sprFullPath = NDPath::GetAnimationPath();
	sprFullPath.append("scene_ani_99.spr");
	
	m_switchPoint = new NDLightEffect;
	m_switchPoint->Initialization(sprFullPath.c_str());
	m_switchPoint->SetLightId(0, false);
}

void NpcRole::Initialization(NDNpc* npc)
{
	NDUINode::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	m_npc = new NDNpc;
	m_npc->m_id = npc->m_id;
	m_npc->col	= npc->col;
	m_npc->row	= npc->row;
	m_npc->look	= npc->look;
	
	m_npc->SetCamp(npc->GetCamp());
	m_npc->SetNpcState(npc->GetNpcState());
	m_npc->m_name = npc->m_name;
	
	m_npc->dataStr = npc->dataStr;
	m_npc->SetType(npc->GetType());
	m_npc->Initialization(m_npc->look);
	m_npc->initUnpassPoint();
	
	this->AddChild(m_npc);
}


void NpcRole::draw()
{
	CGRect scrRect = this->GetScreenRect();
	if (m_npc) {
		m_npc->SetPosition(ccp(scrRect.origin.x + 49, scrRect.origin.y + 80));
		m_npc->RunAnimation(true);
	} else if (m_switchPoint) {
		m_switchPoint->SetPosition(ccp(scrRect.origin.x + 28, scrRect.origin.y + 20));
		m_switchPoint->Run(CGSizeMake(480, 320));
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NpcNode, NDUIButton)

NpcNode::NpcNode()
{
	m_npcRole = NULL;
	m_bSwitchPoint = false;
}

NpcNode::~NpcNode()
{
	
}

void NpcNode::SetSwitchPoint(NDLightEffect* switchPoint)
{
	if (!m_npcRole) {
		m_bSwitchPoint = true;
		m_npcRole = new NpcRole;
		m_npcRole->Initialization(switchPoint);
		this->AddChild(m_npcRole);
	}
}

void NpcNode::SetNpc(NDNpc* npc)
{
	if (!m_npcRole && !npc->IsFarmNpc()) {
		m_bSwitchPoint = false;
		m_npcRole = new NpcRole;
		m_npcRole->Initialization(npc);
		this->AddChild(m_npcRole);
	}
}

void NpcNode::Initialization()
{
	NDUIButton::Initialization();
	this->CloseFrame();
	this->SetBackgroundPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("role_bg.png")));
	this->SetFocusImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("role_bg_focus.png")));
	//this->SetFocusColor(ccc4(100, 200, 100, 90));
}

void NpcNode::draw()
{
    TICK_ANALYST(ANALYST_NpcNode);	
	NDUINode::draw();
	
	if (this->IsVisibled()) {
		NDNode* parentNode = this->GetParent();
		if (parentNode) 
		{
			if (parentNode-IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)parentNode;
				
				CGRect scrRect = this->GetScreenRect();
				
				//draw focus 
				if (uiLayer->GetFocus() == this) 
				{
					if (m_focusStatus == FocusImage && m_focusImage)
					{
						m_focusImage->DrawInRect(scrRect);
					}
				} else {
					if (m_picBG)
					{
						m_picBG->DrawInRect(scrRect);
					}
				}
			}
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NpcListLayer, NDUIContainerHScrollLayer)

NpcListLayer* NpcListLayer::s_instance = NULL;

void NpcListLayer::processTaskList(NDTransData& data)
{
	CloseProgressBar;
	if (s_instance) {
		s_instance->ShowNpcTask(data);
	}
}

void NpcListLayer::ShowNpcTask(NDTransData& data)
{
	vector<pair<int, string> > vTasks;
	NDPlayer& role = NDPlayer::defaultHero();
	int cnt = data.ReadInt();
	
	if (cnt <= 0) {
		return;
	}
	
	if (m_npcListScene) {
		m_npcListScene->RemoveNpcControlLayer();
	}
	
	for (int i = 0; i < cnt; i++)
	{
		int idTask = data.ReadInt();
		string sTask = data.ReadUnicodeString();
		sTask += " ";
		sTask += role.GetPlayerTask(idTask) == NULL ? NDCommonCString("WeiJieGuo") : NDCommonCString("YiJieGuo");
		
		std::stringstream ss;
		ss << (i+1) << ".";
		ss << sTask;
		
		vTasks.push_back(make_pair(idTask, ss.str()));
	}
	
	if (!m_npcTask) {
		m_npcTask = new NpcTaskLayer;
		m_npcTask->Initialization(vTasks);
		this->GetParent()->AddChild(m_npcTask);
	}
}

void NpcListLayer::ShowNpcTaskInfo()
{
	if (m_npcTask) {
		m_npcTask->ShowTaskInfo();
	}
}

void NpcListLayer::refreshNpcTaskInfo()
{
	if (s_instance) {
		s_instance->ShowNpcTaskInfo();
	}
}

NpcListLayer::NpcListLayer()
{
	s_instance = this;
	
	m_bNpcInit = false;
	
	m_focusNpcNode = NULL;
	m_switchPoint = NULL;
	m_npcTask = NULL;
	m_npcListScene = NULL;
}

NpcListLayer::~NpcListLayer()
{
	s_instance = NULL;
	SAFE_DELETE(m_switchPoint);
}

bool NpcListLayer::OnClickTask()
{
	if (m_focusNpcNode) {
		if (m_focusNpcNode->IsSwitchPoint()) {
			return false;
		}
		
		int idTargetNpc = m_focusNpcNode->GetTag();
		
		ShowProgressBar;
		NDTransData bao(_MSG_QUERY_TASK_LIST);
		bao << idTargetNpc;
		SEND_DATA(bao);
		
		return true;
	}
	return false;
}

NDMapSwitch* GetMapSwitchByIndex(int iIndex)
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

void NpcListLayer::OnClickDaoHang()
{
	if (m_focusNpcNode) {
		if (!CanAutoPath()) return;
		
		if (m_focusNpcNode->IsSwitchPoint()) {
			int iIndex = m_focusNpcNode->GetTag();
			NDMapSwitch *mapswitch = GetMapSwitchByIndex(iIndex);
			if (mapswitch) 
			{
				NDDirector::DefaultDirector()->PopScene(true);
				NDPlayer& player = NDPlayer::defaultHero();
				if (player.CanSwitch(mapswitch.x, mapswitch.y))
				{
					player.DirectSwitch(mapswitch.x, mapswitch.y, mapswitch.mapIndex);
					return;
				}
				AutoPathTipObj.work(mapswitch.nameDesMap == nil ? "" : [mapswitch.nameDesMap UTF8String]);
				player.Walk(ccp(mapswitch.x*MAP_UNITSIZE, mapswitch.y*MAP_UNITSIZE), SpriteSpeedStep4, true);
			}
		} else {
			int idTargetNpc = m_focusNpcNode->GetTag();
			NDNpc* targetNpc = NDMapMgrObj.GetNpc(idTargetNpc);
			if (targetNpc) {
				DirectNpc(targetNpc);
			}
		}
	}
}

void NpcListLayer::OnClickTab()
{
	if (m_npcTask) {
		m_npcTask->RemoveFromParent(true);
		m_npcTask = NULL;
	}
}

void NpcListLayer::draw()
{
	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
	
	NDUILayer::draw();
	
	if (!m_bNpcInit) {
		m_bNpcInit = true;
		
		// npc
		const NDMapMgr::VEC_NPC& npcs = NDMapMgrObj.GetNpc();
		
		GLfloat fStartX = 3;
		GLfloat fSecondRowY = 114;
		bool bSecondRow = false;
		
		NDNpc* npc = NULL;
		for (NDMapMgr::VEC_NPC::const_iterator it = npcs.begin(); it != npcs.end(); it++) {
			npc = *it;
			if (npc->GetType() == 6) {
				continue;
			}
			
			NpcNode* npcNode = new NpcNode;
			npcNode->Initialization();
			npcNode->SetFrameRect(CGRectMake(fStartX, bSecondRow ? fSecondRowY : 0, 101, 111));
			npcNode->SetNpc(npc);
			this->AddChild(npcNode);
			npcNode->SetDelegate(this);
			if (bSecondRow) {
				fStartX += 106;
			}
			bSecondRow = !bSecondRow;
			
			npcNode->SetTag(npc->m_id);
			
			if (npc->IsFarmNpc()) 
			{
				NDUILabel* lbName = new NDUILabel;
				lbName->Initialization();
				lbName->SetText(npc->m_name.c_str());
				lbName->SetFrameRect(CGRectMake(0, 50, 101, 20));
				lbName->SetTextAlignment(LabelTextAlignmentCenter);
				lbName->SetFontSize(14);
				lbName->SetFontColor(ccc4(187, 19, 19, 255));
				npcNode->AddChild(lbName);
				continue;
			}
			
			NDUILabel* lbName = new NDUILabel;
			lbName->Initialization();
			lbName->SetText(npc->m_name.c_str());
			lbName->SetFrameRect(CGRectMake(0, 83, 101, 20));
			lbName->SetTextAlignment(LabelTextAlignmentCenter);
			lbName->SetFontSize(14);
			lbName->SetFontColor(ccc4(187, 19, 19, 255));
			npcNode->AddChild(lbName);
			
			NDUILabel* lbDatastr = new NDUILabel;
			lbDatastr->Initialization();
			lbDatastr->SetText(npc->dataStr.c_str());
			lbDatastr->SetFrameRect(CGRectMake(0, 6, 101, 20));
			lbDatastr->SetTextAlignment(LabelTextAlignmentCenter);
			lbDatastr->SetFontSize(12);
			lbDatastr->SetFontColor(ccc4(187, 19, 19, 255));
			npcNode->AddChild(lbDatastr);
			
			NPC_STATE npcState = npc->GetNpcState();
			if ( (npcState & QUEST_CANNOT_ACCEPT) > 0)
			{
				NDUIImage* imgTask = new NDUIImage;
				imgTask->Initialization();
				imgTask->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPath("task_state_1.png")), true);
				imgTask->SetFrameRect(CGRectMake(70, 30, 16, 17));
				npcNode->AddChild(imgTask);
			} 
			else if ( (npcState & QUEST_CAN_ACCEPT) > 0) 
			{
				NDUIImage* imgTask = new NDUIImage;
				imgTask->Initialization();
				imgTask->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPath("task_state_2.png")), true);
				imgTask->SetFrameRect(CGRectMake(70, 30, 20, 18));
				npcNode->AddChild(imgTask);
			} 
			else if ( (npcState & QUEST_NOT_FINISH) > 0)
			{
				NDUIImage* imgTask = new NDUIImage;
				imgTask->Initialization();
				imgTask->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPath("task_state_3.png")), true);
				imgTask->SetFrameRect(CGRectMake(70, 30, 16, 18));
				npcNode->AddChild(imgTask);
			} 
			else if ( (npcState & QUEST_FINISH) > 0)
			{
				NDUIImage* imgTask = new NDUIImage;
				imgTask->Initialization();
				imgTask->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPath("task_state_4.png")), true);
				imgTask->SetFrameRect(CGRectMake(70, 30, 16, 17));
				npcNode->AddChild(imgTask);
			}
			if (it == npcs.begin()) {
				this->SetFocus(npcNode);
				this->OnButtonClick(npcNode);
			}
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
							NpcNode* npcNode = new NpcNode;
							npcNode->Initialization();
							npcNode->SetFrameRect(CGRectMake(fStartX, bSecondRow ? fSecondRowY : 0, 101, 111));
							this->AddChild(npcNode);
							npcNode->SetDelegate(this);
							npcNode->SetSwitchPoint(m_switchPoint);
							if (bSecondRow) {
								fStartX += 106;
							}
							bSecondRow = !bSecondRow;
							
							npcNode->SetTag(i);
							
							string dataStr = string(NDCommonCString("GoTo")) + ":" + (mapswitch.nameDesMap == nil ? "" : [mapswitch.nameDesMap UTF8String]);
							
							NDUILabel* lbName = new NDUILabel;
							lbName->Initialization();
							lbName->SetText(dataStr.c_str());
							lbName->SetFrameRect(CGRectMake(0, 83, 101, 20));
							lbName->SetTextAlignment(LabelTextAlignmentCenter);
							lbName->SetFontSize(14);
							lbName->SetFontColor(ccc4(187, 19, 19, 255));
							npcNode->AddChild(lbName);
						}
					}
				}
			}
		}
		
		this->refreshContainer();
	}
}

void NpcListLayer::Initialization(PlayerNpcListScene* npcListScene)
{
	NDUIContainerHScrollLayer::Initialization();
	
	m_npcListScene = npcListScene;
	
	//this->SetBackgroundColor(ccc4(255, 0, 0, 255));
	/*m_layerBtn = new NDUILayer;
	m_layerBtn->Initialization();
	m_layerBtn->SetFrameRect(CGRectMake(0, 243, 480, 36));
	
	m_btnTask = new NDUIButton;
	m_btnTask->Initialization();
	m_btnTask->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("btn_0.png")), false, CGRectZero, true);
	m_btnTask->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnTask->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPathBattleUI("itemchildback.png"), false), false, CGRectZero, true);
	m_btnTask->SetTitle("任务");
	m_btnTask->SetFrameRect(CGRectMake(0, 0, 39, 35));
	m_btnTask->SetDelegate(this);
	m_layerBtn->AddChild(m_btnTask);
	
	m_btnDaoHang = new NDUIButton;
	m_btnDaoHang->Initialization();
	m_btnDaoHang->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("btn_0.png")), false, CGRectZero, true);
	m_btnDaoHang->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnDaoHang->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath:: GetImgPathBattleUI("itemchildback.png"), false), false, CGRectZero, true);
	m_btnDaoHang->SetTitle("导航");
	m_btnDaoHang->SetFrameRect(CGRectMake(440, 0, 39, 35));
	m_btnDaoHang->SetDelegate(this);
	m_layerBtn->AddChild(m_btnDaoHang);*/
}

void NpcListLayer::OnButtonClick(NDUIButton* button)
{
	/*if (button == m_btnTask) {
		if (m_focusNpcNode) {
			int idTargetNpc = m_focusNpcNode->GetTag();
			
			ShowProgressBar;
			NDTransData bao(_MSG_QUERY_TASK_LIST);
			bao << idTargetNpc;
			SEND_DATA(bao);
			
			if (m_layerBtn) {
				m_layerBtn->RemoveFromParent(false);
			}
		}
	} else if (button == m_btnDaoHang) {
		if (m_focusNpcNode) {
			if (!CanAutoPath()) return;
			
			int idTargetNpc = m_focusNpcNode->GetTag();
			
			NDNpc* targetNpc = NDMapMgrObj.GetNpc(idTargetNpc);
			
			if (targetNpc) {
				NDDirector::DefaultDirector()->PopScene(true);
				AutoPathTipObj.work(targetNpc->dataStr);
				NDPlayer::defaultHero().Walk(targetNpc->GetPosition(), SpriteSpeedStep4);
			}
		}
	} else */if (button->IsKindOfClass(RUNTIME_CLASS(NpcNode))) {
		if (m_focusNpcNode == button) {
			// 双击
			if (!CanAutoPath()) return;
			
			if (m_focusNpcNode->IsSwitchPoint()) {
				int iIndex = m_focusNpcNode->GetTag();
				NDMapSwitch *mapswitch = GetMapSwitchByIndex(iIndex);
				if (mapswitch) 
				{
					NDDirector::DefaultDirector()->PopScene(true);
					NDPlayer& player = NDPlayer::defaultHero();
					if (player.CanSwitch(mapswitch.x, mapswitch.y))
					{
						player.DirectSwitch(mapswitch.x, mapswitch.y, mapswitch.passIndex);
						return;
					}
					AutoPathTipObj.work(mapswitch.nameDesMap == nil ? "" : [mapswitch.nameDesMap UTF8String]);
					player.Walk(ccp(mapswitch.x*MAP_UNITSIZE, mapswitch.y*MAP_UNITSIZE), SpriteSpeedStep4, true);
				}
			} else {
				int idTargetNpc = m_focusNpcNode->GetTag();
				NDNpc* targetNpc = NDMapMgrObj.GetNpc(idTargetNpc);
				if (targetNpc) {
					DirectNpc(targetNpc);
				}
			}
		} else {
			m_focusNpcNode = (NpcNode*)button;
		}
	}
}

bool NpcListLayer::DirectNpc(NDNpc *npc)
{
	if (!npc) return false;
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	CGPoint dstPoint;
	
	if (npc->getNearestPoint(player.GetPosition(), dstPoint))
	{
		NDDirector::DefaultDirector()->PopScene(true);
		
		NDPlayer& player = NDPlayer::defaultHero();
		
		CGPoint disPos = ccpSub(dstPoint, player.GetPosition());
		
		if (abs(int(disPos.x)) <= 32 && abs(int(disPos.y)) <= 32)
		{
			if (npc && npc->GetType() != 6) 
			{
				player.SendNpcInteractionMessage(npc->m_id);
//				if (npc->IsDirectOnTalk()) 
//				{
//					//npc朝向修改	
//					if (player.GetPosition().x > npc->GetPosition().x) 
//						npc->DirectRight(true);
//					else 
//						npc->DirectRight(false);
//				}
			}
		}
		else
		{
			AutoPathTipObj.work(npc->m_name);
			player.Walk(dstPoint, SpriteSpeedStep4, true);
		}
		
		return true;
	}
	
	return false;
}

bool NpcListLayer::CanAutoPath()
{
	NDPlayer& role = NDPlayer::defaultHero();
	
	// 前往切屏点 me那边展示不管选啥都直接寻路过去
	if (role.IsInState(USERSTATE_BOOTH)) {
		GlobalShowDlg(NDCommonCString("tip"), NDCommonCString("CantAutoPathBooth"));
		return false;
	}
	if (!role.isTeamLeader()
		&& role.isTeamMember()) {
		GlobalShowDlg(NDCommonCString("tip"), NDCommonCString("CantAutoPathTeam"));
		return false;
	}
	if (role.IsInState(USERSTATE_HU_BIAO)) {
		GlobalShowDlg(NDCommonCString("tip"), NDCommonCString("CantAutoPathBiao"));
		return false;
	}
	
	return true;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ManualRole, NDUINode)

ManualRole::ManualRole()
{
	m_role = NULL;
	m_ptOffset = CGPointZero;
}

ManualRole::~ManualRole()
{
}

void ManualRole::Initialization(NDManualRole* role)
{
	NDUINode::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	m_role = new NDManualRole;
	m_role->m_id = role->m_id;
	m_role->Initialization(role->dwLookFace);
	m_role->SetPositionEx(CGPointZero);
	this->AddChild(m_role);
	
	vector<int>& vEquipsID = role->m_vEquipsID;
	
	for (vector<int>::iterator it = vEquipsID.begin(); it != vEquipsID.end(); it++) {
		this->packEquip(*it);
	}
}

void ManualRole::draw()
{
	NDNode *pNodeParent = this->GetParent();
	
	if ( pNodeParent && pNodeParent->IsKindOfClass(RUNTIME_CLASS(NDUINode)) )
	{
		if ( !((NDUINode*)pNodeParent)->IsVisibled() )
			return;
	}

	CGRect scrRect = this->GetScreenRect();
	if (m_role) {
		m_role->SetPositionEx(ccp(scrRect.origin.x + m_ptOffset.x, scrRect.origin.y + m_ptOffset.y));
		m_role->RunAnimation(true);
	}
}

void ManualRole::packEquip(int idEquipType)
{
	if (!m_role) 
	{
		return;
	}
	
	NDItemType* item = ItemMgrObj.QueryItemType(idEquipType);
	
	if (!item) 
	{
		return;
	}
	
	int nID = item->m_data.m_lookface;
	int quality = idEquipType % 10;
	
	int aniId = 0;
	if (nID > 100000) 
	{
		aniId = (nID % 100000) / 10;
	}
	if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000) 
	{// 战宠
	}
	else if (nID >= 20000 && nID < 30000 || nID > 100000)
	{// 骑宠
	}
	else 
	{
		m_role->SetEquipment(nID, quality);
	}
}

void ManualRole::uppackEquip(int iPos)
{
	if (m_role) 
	{
		m_role->unpackEquip(iPos);
	}
}

void ManualRole::unpackAllEquip()
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		if (i == Item::eEP_Ride) 
		{
			continue;
		}
		uppackEquip(i);
	}
}

void ManualRole::SetOffset(CGPoint offset)
{
	m_ptOffset = offset;
}

void ManualRole::setFace(bool bRight)
{
	if (m_role) 
	{
		m_role->SetSpriteDir(!bRight ? 2 : 1);
	}
}

int ManualRole::getID()
{
	if (m_role) 
	{
		return m_role->m_id;
	}
	
	return 0;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PlayerNode, NDUIButton)

PlayerNode::PlayerNode()
{
	m_role = NULL;
}

PlayerNode::~PlayerNode()
{
	
}

void PlayerNode::Initialization()
{
	NDUIButton::Initialization();
	this->CloseFrame();
	this->SetBackgroundPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("role_bg.png")));
	this->SetFocusImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("role_bg_focus.png")));
	//this->SetFocusColor(ccc4(100, 200, 100, 90));
}

void PlayerNode::draw()
{
	NDUINode::draw();
	
	if (this->IsVisibled()) {
		NDNode* parentNode = this->GetParent();
		if (parentNode) 
		{
			if (parentNode-IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)parentNode;
				
				CGRect scrRect = this->GetScreenRect();
				
				//draw focus 
				if (uiLayer->GetFocus() == this) 
				{
					if (m_focusStatus == FocusImage && m_focusImage)
					{
						m_focusImage->DrawInRect(scrRect);
					}
				} else {
					if (m_picBG)
					{
						m_picBG->DrawInRect(scrRect);
					}
				}
			}
		}
	}
}

void PlayerNode::SetManualRole(NDManualRole* role)
{
	if (!m_role && role) {
		m_role = new ManualRole;
		m_role->Initialization(role);
		m_role->SetOffset(CGPointMake(49, 80));
		this->AddChild(m_role);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PlayerListLayer, NDUIContainerHScrollLayer)

PlayerListLayer::PlayerListLayer()
{
	m_focusPlayer = NULL;
	m_parentScene = NULL;
}

PlayerListLayer::~PlayerListLayer()
{
	
}

void PlayerListLayer::Initialization(PlayerNpcListScene* scene)
{
	NDUIContainerHScrollLayer::Initialization();
	
	m_parentScene = scene;
	
	this->SetFrameRect(CGRectMake(15, 15, 425, 230));
	
	GLfloat fStartX = 3;
	GLfloat fSecondRowY = 114;
	bool bSecondRow = false;
	
	NDMapMgr::map_manualrole& roles = NDMapMgrObj.GetManualRoles();
	NDMapMgr::map_manualrole_it it = roles.begin();
	for (; it != roles.end(); it++)
	{
		NDManualRole *role = it->second;
		if (!role->IsInState(USERSTATE_STEALTH)) //非隐形状态
		{
			PlayerNode* roleNode = new PlayerNode;
			roleNode->Initialization();
			roleNode->SetFrameRect(CGRectMake(fStartX, bSecondRow ? fSecondRowY : 0, 101, 111));
			roleNode->SetManualRole(role);
			roleNode->SetDelegate(this);
			this->AddChild(roleNode);
			
			if (bSecondRow) {
				fStartX += 106;
			}
			bSecondRow = !bSecondRow;
			
			roleNode->SetTag(role->m_id);
			
			NDUILabel* lbName = new NDUILabel;
			lbName->Initialization();
			lbName->SetText(role->m_name.c_str());
			lbName->SetFrameRect(CGRectMake(0, 6, 101, 20));
			lbName->SetTextAlignment(LabelTextAlignmentCenter);
			lbName->SetFontSize(13);
			lbName->SetFontColor(ccc4(187, 19, 19, 255));
			roleNode->AddChild(lbName);
			
			NDUIImage* imgLevel = new NDUIImage;
			imgLevel->Initialization();
			imgLevel->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("level_bg.png")), true);
			imgLevel->SetFrameRect(CGRectMake(6, 30, 23, 16));
			roleNode->AddChild(imgLevel);
			
			NDUILabel* lbLevel = new NDUILabel;
			lbLevel->Initialization();
			lbLevel->SetFontSize(9);
			lbLevel->SetFontColor(ccc4(255, 225, 108, 255));
			stringstream ss;
			ss << role->level;
			lbLevel->SetText(ss.str().c_str());
			lbLevel->SetFrameRect(CGRectMake(13, 32, 19, 13));
			roleNode->AddChild(lbLevel);
			
			NDUIImage* imgHpMp = new NDUIImage;
			imgHpMp->Initialization();
			imgHpMp->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("hp_mp.png")), true);
			imgHpMp->SetFrameRect(CGRectMake(33, 83, 34, 9));
			roleNode->AddChild(imgHpMp);
			
			NDUIRecttangle* rectHp = new NDUIRecttangle;
			rectHp->Initialization();
			rectHp->SetColor(ccc4(254, 0, 0, 255));
			rectHp->SetFrameRect(CGRectMake(35, 85, 31*((float)role->life / (float)role->maxLife), 1));
			roleNode->AddChild(rectHp);
			
			NDUIRecttangle* rectMp = new NDUIRecttangle;
			rectMp->Initialization();
			rectMp->SetColor(ccc4(66, 183, 250, 255));
			rectMp->SetFrameRect(CGRectMake(35, 89, 31/**((float)role->mana / (float)role->maxMana)*/, 1));
			roleNode->AddChild(rectMp);
			
			if (it == roles.begin()) {
				this->SetFocus(roleNode);
				this->OnButtonClick(roleNode);
			}
		}
	}
	
	this->refreshContainer();
}

void PlayerListLayer::draw()
{
	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
	
	NDUIContainerHScrollLayer::draw();
}

bool PlayerListLayer::IsPlayerStillThere(int idPlayer)
{
	NDManualRole *role = NDMapMgrObj.GetManualRole(idPlayer);
	if (!role)
	{
		showDialog(NDCommonCString("WenXinTip"), NDCommonCString("PlayerLeavedSec"));
		return false;
	}
	return true;
}

void PlayerListLayer::OnButtonClick(NDUIButton* button)
{
	if (button->IsKindOfClass(RUNTIME_CLASS(PlayerNode))) {
		int idPlayer = button->GetTag();
		if (m_focusPlayer == button) {
			// 切换到玩家信息界面
			if (this->IsPlayerStillThere(idPlayer)) {
				NDDirector::DefaultDirector()->PushScene(OtherPlayerInfoScene::Scene(NDMapMgrObj.GetManualRole(idPlayer)));
			}
		} else {
			m_focusPlayer = (PlayerNode*)button;
			
			// 重新初始化控件栏
			if (m_parentScene) {
				m_parentScene->RefreshPlayerControl(idPlayer);
			}
			
			this->IsPlayerStillThere(idPlayer);
		}
	}
}

void PlayerListLayer::OnClickControl(int tag)
{
	NDPlayer& player = NDPlayer::defaultHero();
	NDManualRole* role = NULL;
	if (m_focusPlayer) {
		role = NDMapMgrObj.GetManualRole(m_focusPlayer->GetTag());
	}
	
	if (!role) {
		return;
	}
	
	switch (tag) {
		case ePlayerTrade:
		{
			trade(role->m_id, 0);
		}
			break;
		case ePlayerJoinTeam:
		{
			NDTransData bao(_MSG_TEAM);
			bao << (unsigned short)MSG_TEAM_JOIN << player.m_id << role->m_id;
			SEND_DATA(bao);
		}
			break;
		case ePlayerInviteTeam:
		{
			NDTransData bao(_MSG_TEAM);
			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
			SEND_DATA(bao);
		}
			break;
		case ePlayerAddFriend:
		{
			sendAddFriend(role->m_name);
		}
			break;
		case ePlayerPrivateTalk:
		{
			PrivateChatInput::DefaultInput()->SetLinkMan(role->m_name.c_str());
			PrivateChatInput::DefaultInput()->Show();
		}
			break;
		case ePlayerPK:
		{
			sendPKAction(*role, BATTLE_ACT_PK);
		}
			break;
		case ePlayerReherse:
		{
			sendRehearseAction(role->m_id, REHEARSE_APPLY);
		}
			break;
		case ePlayerWatchBattle:
		{
			ShowProgressBar;
			NDTransData bao(_MSG_BATTLEACT);
			bao << Byte(BATTLE_ACT_WATCH) << Byte(0) << Byte(1) << int(role->m_id);
			SEND_DATA(bao);
		}
			break;
		case ePlayerBaiShi:
		{
			NDTransData bao(_MSG_TUTOR);
			bao << (unsigned char)1 << role->m_id;
			SEND_DATA(bao);
		}
			break;
		case ePlayerShouTu:
		{
			NDTransData bao(_MSG_TUTOR);
			bao << (unsigned char)4 << role->m_id;
			SEND_DATA(bao);
		}
			break;
		case ePlayerMail:
		{
			NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene(role->m_name));
		}
			break;
		case ePlayerInviteSyn:
		{
			sendInviteOther(role->m_name);
		}
			break;
		default:
			break;
	}
}



/*
 *  NDMiniMap.mm
 *  DragonDrive
 *
 *  Created by wq on 11-2-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMiniMap.h"
#include "NDUIBaseGraphics.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDMapMgr.h"
#include "NDNpc.h"
#include "NDPicture.h"
#include "NDPlayer.h"
#include "WorldMapScene.h"
#import "NDWorldMapData.h"
#include "NDBeforeGameMgr.h"
#include "PlayerNpcListScene.h"
#include <sstream>

#define max_mapname_len (10)

using namespace NDEngine;

IMPLEMENT_CLASS(Radar, NDUILayer)

Radar::Radar() : m_role(NDPlayer::defaultHero())
{
	this->scene = NULL;
	this->m_miniTaskPic = new NDPicture;
	m_miniTaskPic->Initialization(GetImgPath("mini_quest.png"));
	//m_miniTaskPic->Cut(CGRectMake(0.0f, 0.0f, 37.0f, 18.0f));
	
	this->x = 0;
	this->y = 0;
	this->timeCount = 0;
	this->scrollX = 0;
	this->scrollY = 0;
	
	this->MINI_W = 480 / SCALE_X;
	this->MINI_H = 640 / SCALE_Y;
	
//	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
//	this->startX = winSize.width - MINI_W - OFFSET_X - 42;
//	this->startY = 6.0f;
}

Radar::~Radar()
{
	SAFE_DELETE(this->m_miniTaskPic);
}

void Radar::Initialization()
{
	NDUILayer::Initialization();
}

bool Radar::TouchEnd(NDTouch* touch)
{
	NDDirector::DefaultDirector()->PushScene(PlayerNpcListScene::Scene());
	return true;
}

void Radar::draw()
{
	this->mapLogin();
	this->drawRole();
	this->drawNpc();
	this->drawEnemy();
	this->drawOtherRoles();
	this->drawSwitchMapPoint();
}

void Radar::mapLogin()
{
	CGRect rectScreen = this->GetScreenRect();
	this->startX = rectScreen.origin.x;
	this->startY = rectScreen.origin.y;
	
	CGSize size = this->scene->GetSize();
	if (size.width > 480) {
		this->MINI_W = 480 / SCALE_X;
	} else {
		this->MINI_W = size.width / SCALE_X;
	}
	if (size.height > 640) {
		this->MINI_H = 640 / SCALE_Y;
	} else {
		this->MINI_H = size.height / SCALE_Y;
	}
	
	CGPoint pos = this->m_role.GetPosition();
	this->scrollX = pos.x / SCALE_X - (MINI_W >> 1);
	this->scrollY = pos.y / SCALE_Y - (MINI_H >> 1);
	
	if (scrollX < 0) {
		scrollX = 0;
	} else if (scrollX + MINI_W > size.width / SCALE_X) {
		scrollX = size.width / SCALE_X - MINI_W;
	}
	if (scrollY < 0) {
		scrollY = 0;
	} else if (scrollY + MINI_H > size.height / SCALE_Y) {
		scrollY = size.height / SCALE_Y - MINI_H;
	}
}

void Radar::drawRole()
{
	CGPoint pos = this->m_role.GetPosition();
	
	this->x = pos.x / SCALE_X - this->scrollX;
	this->y = pos.y / SCALE_Y - this->scrollY;
	
	if (this->timeCount % 12 < 6) {
		if (this->x >= 0 && this->x <= MINI_W && this->y >= 0 && this->y <= MINI_H) {
			DrawRecttangle(CGRectMake(this->x + this->startX - DARK_WH, this->y + this->startY - DARK_WH, LIGHT_WH, LIGHT_WH),
						   ccc4(252, 252, 2, 255));
		}
	} else {
		if (x >= 0 && x <= MINI_W && y >= 0 && y <= MINI_H) {
			DrawRecttangle(CGRectMake(x + startX - HALF_DARK_WH, y + startY - HALF_DARK_WH, DARK_WH, DARK_WH),
						   ccc4(251, 174, 40, 255));
		}
	}
	this->timeCount++;
	if (this->timeCount > 50) {
		this->timeCount = 1;
	}
}

void Radar::drawMiniQuest(int npcState, int x, int y) {
	if ((npcState & NPC_STATE_GRAY_EXCALMATORY_MARK) > 0) { // 绿色
		this->m_miniTaskPic->Cut(CGRectMake(4, 0, 4, 9));
		this->m_miniTaskPic->DrawInRect(CGRectMake(x, y, 4, 9));
	} else if ((npcState & NPC_STATE_COLOR_EXCALMATORY_MARK) > 0) { // 红色
		this->m_miniTaskPic->Cut(CGRectMake(0, 0, 4, 9));
		this->m_miniTaskPic->DrawInRect(CGRectMake(x, y, 4, 9));
	} else if ((npcState & NPC_STATE_COLOR_QUESTION_MARK) > 0) { // 问号
		this->m_miniTaskPic->Cut(CGRectMake(8, 0, 6, 9));
		this->m_miniTaskPic->DrawInRect(CGRectMake(x - 1, y - 1, 6, 9));
	}
}

void Radar::drawNpc()
{
	NDMapMgr::VEC_NPC& vNpc = NDMapMgrObj.m_vNpc;
	
	for (size_t i = 0; i < vNpc.size(); i++) {
		NDNpc* npc = vNpc.at(i);
		if (!npc) {
			continue;
		}
		
		int tempX = (npc->col << 4) / SCALE_X - this->scrollX;
		int tempY = (npc->row << 4) / SCALE_Y - this->scrollY;
		
		if (tempX >= 0 && tempX <= this->MINI_W && tempY >= 0 && tempY <= this->MINI_H) {
			DrawRecttangle(CGRectMake(tempX + startX - HALF_DARK_WH, tempY + startY - HALF_DARK_WH, DARK_WH, DARK_WH), ccc4(0, 255, 0, 255));
			if (npc->GetNpcState() > NPC_STATE_NO_MARK) {
				this->drawMiniQuest(npc->GetNpcState(), tempX + startX - HALF_DARK_WH, tempY + startY - HALF_DARK_WH - 5);
			}
		}
	}
}

void Radar::drawEnemy()
{
	NDMapMgr::VEC_MONSTER& enemy_array = NDMapMgrObj.m_vMonster;
	
	for (size_t i = 0; i < enemy_array.size(); i++) {
		NDMonster* monster = enemy_array.at(i);
		if (!monster) {
			continue;
		}
		
		if (monster->state != MONSTER_STATE_DEAD/* && monster->camp != NDPlayer::defaultHero().GetCamp()*/) {
			CGPoint pos = monster->GetPosition();
			int tempX = pos.x / SCALE_X - this->scrollX;
			int tempY = pos.y / SCALE_Y - this->scrollY;
			if (tempX >= 0 && tempX <= this->MINI_W && tempY >= 0 && tempY <= this->MINI_H) {
				DrawRecttangle(CGRectMake(tempX + startX - HALF_DARK_WH, tempY + startY - HALF_DARK_WH, DARK_WH, DARK_WH), ccc4(255, 0, 0, 255));
			}
		}
	}
}

void Radar::drawOtherRoles()
{
	NDPlayer& player = NDPlayer::defaultHero();
	
	bool bBukuaiOrHubiao = false;
	if (player.IsInState(USERSTATE_BATTLE_POSITIVE)) 
	{
		bBukuaiOrHubiao = true;
	}
	
	set<int> rolePos;
	
	ccColor4B clr = ccc4(255, 255, 255, 255);
	NDMapMgr::map_manualrole& allRoles = NDMapMgrObj.m_mapManualrole;
	int tx = 0;
	int ty = 0;
	for (NDMapMgr::map_manualrole_it it = allRoles.begin(); it != allRoles.end(); it++) {
		NDManualRole* role = it->second;
		if (!role) {
			continue;
		}
		
		// role是劫匪
		if ((bBukuaiOrHubiao && role->IsInState(USERSTATE_BATTLE_NEGATIVE))) 
		{
			clr = ccc4(255, 0, 0, 255);
		}
		else 
		{
			clr = ccc4(255, 255, 255, 255);
		}
		
		if (player.IsInState(USERSTATE_BATTLEFIELD) && 
			role->IsInState(USERSTATE_BATTLEFIELD)  && 
			player.camp != role->camp)
		{
			clr = ccc4(255, 0, 0, 255);
		}
		
		
		CGPoint pos = role->GetPosition();
		short tempX = pos.x / SCALE_X - this->scrollX;
		short tempY = pos.y / SCALE_Y - this->scrollY;
		int key = tempX << 16 | tempY;
		
		tx = tempX + this->startX - HALF_DARK_WH;
		ty = tempY + this->startY - HALF_DARK_WH;
		
		if (tempX > 0 && tempX < this->MINI_W && tempY > 0 && tempY < this->MINI_H) {
			if (rolePos.count(key) == 0) {
				DrawRecttangle(CGRectMake(tx, ty, DARK_WH, DARK_WH), clr);
				rolePos.insert(key);
			}
		}
	}
}

void Radar::drawSwitchMapPoint()
{
	NSArray* switches = this->scene->GetSwitchs();
	
	NSEnumerator *theEnumerator = [switches objectEnumerator];
	NDMapSwitch *mapSwitch = NULL;
	while ((mapSwitch = [theEnumerator nextObject]) != NULL) {
		int tempX = (mapSwitch.x << 4) / SCALE_X - this->scrollX;
		int tempY = (mapSwitch.y << 4) / SCALE_Y - this->scrollY;
		if (tempX >= 0 && tempX <= this->MINI_W && tempY >= 0 && tempY <= this->MINI_H) {
			DrawRecttangle(CGRectMake(tempX + this->startX - 1, tempY + this->startY - 1, 3, 3),
						   ccc4(33, 213, 236, 255));
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDMiniMap, NDUIChildrenEventLayer)

NDMiniMap* NDMiniMap::s_instance = NULL;

NDMiniMap::NDMiniMap() : m_role(NDPlayer::defaultHero())
{	
	this->x = 0;
	this->y = 0;
	this->timeCount = 0;
	this->scrollX = 0;
	this->scrollY = 0;
	
	this->MINI_W = 480 / SCALE_X;
	this->MINI_H = 640 / SCALE_Y;
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	this->startX = winSize.width - MINI_W - OFFSET_X - 42;
	this->startY = OFFSET_Y;
	
	//CGRect miniMapRect = CGRectMake(80.0f, startY, MINI_W + DARK_WH, MINI_H + DARK_WH);
	
	s_instance = this;
	
	m_status = SS_SHOW;
}

NDMiniMap::~NDMiniMap()
{
	s_instance = NULL;
}

void NDMiniMap::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnMap) {
		// 打开世界地图界面
		if (scene) {
			//this->scene->PushWorldMapScene();
		}
	} else if (button == m_btnShrink) {
		switch (m_status) {
			case SS_SHOW:
			case SS_EXTENDING:
				this->m_status = SS_SHRINKING;
				break;
			case SS_HIDE:
			case SS_SHRINKING:
				this->m_status = SS_EXTENDING;
				break;
			default:
				break;
		}
	}
}

void NDMiniMap::Initialization()
{
	NDUIChildrenEventLayer::Initialization();
	
	NDUIImage* imgRadar = new NDUIImage;
	imgRadar->Initialization();
	imgRadar->SetPicture(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("radar.png"), false), true);
	imgRadar->SetFrameRect(CGRectMake(0, 0, 172, 66));
	this->AddChild(imgRadar);
	
	m_btnMap = new NDUIButton;
	m_btnMap->Initialization();
	m_btnMap->SetFrameRect(CGRectMake(0.0f, 0.0f, 106.0f, 51.0f));
	m_btnMap->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("show_map.png"), false), true, CGRectMake(4, 4, 30, 30), true);
	m_btnMap->SetDelegate(this);
	this->AddChild(m_btnMap);
	
	NDUIRecttangle* rectBg = new NDUIRecttangle();
	rectBg->Initialization();
	rectBg->SetFrameRect(CGRectMake(110.0f, 6.0f, MINI_W + DARK_WH, MINI_H + DARK_WH));
	rectBg->SetColor(ccc4(125, 125, 125, 125));
	this->AddChild(rectBg);
	
	NDUIPolygon* border = new NDUIPolygon();
	border->Initialization();
	border->SetFrameRect(CGRectMake(110.0f, 6.0f, MINI_W + DARK_WH, MINI_H + DARK_WH));
	border->SetLineWidth(1);
	border->SetColor(ccc3(0, 0, 0));
	this->AddChild(border);
	
	m_lbMapName = new NDUILabel;
	m_lbMapName->Initialization();
	m_lbMapName->SetFontSize(13);
	m_lbMapName->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbMapName->SetFrameRect(CGRectMake(36.0f, 15.0f, 480.0f, 17.0f));
	this->AddChild(m_lbMapName);
	
	m_lbServerName = new NDUILabel;
	m_lbServerName->Initialization();
	m_lbServerName->SetFontSize(13);
	m_lbServerName->SetFontColor(ccc4(255, 55, 0, 255));
	m_lbServerName->SetText(NDBeforeGameMgrObj.GetServerDisplayName().c_str());
	m_lbServerName->SetFrameRect(CGRectMake(36.0f, 31.0f, 80.0f, 17.0f));
	this->AddChild(m_lbServerName);
	
	m_radar = new Radar;
	m_radar->Initialization();
	m_radar->SetFrameRect(CGRectMake(111.0f, 7.0f, MINI_W, MINI_H));
	this->AddChild(m_radar);
	
	NDUIRecttangle* rectCoordBg = new NDUIRecttangle();
	rectCoordBg->Initialization();
	rectCoordBg->SetFrameRect(CGRectMake(111.0f, 42.0f, MINI_W + 1.0f, 16.0f));
	rectCoordBg->SetColor(ccc4(50, 50, 50, 125));
	this->AddChild(rectCoordBg);
	
	m_lbCoord = new NDUILabel;
	m_lbCoord->Initialization();
	m_lbCoord->SetFontSize(13);
	m_lbCoord->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbCoord->SetFrameRect(CGRectMake(117.0f, 42.0f, 50.0f, 17.0f));
	this->AddChild(m_lbCoord);
	
	m_btnShrink = new NDUIButton;
	m_btnShrink->Initialization();
	m_btnShrink->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("shrink_map.png"), false), false, CGRectMake(0, 0, 0, 0), true);
	m_btnShrink->SetFrameRect(CGRectMake(86.0f, 46.0f, 41.0f, 41.0f));
	m_btnShrink->SetDelegate(this);
	this->AddChild(m_btnShrink);
}

void NDMiniMap::draw()
{
	this->mapLogin();
	
	NDUILayer::draw();
}

const CGPoint PT_BTN_SHRINK_SHOW = CGPointMake(394.0f, 46.0f);
const CGPoint PT_BTN_SHRINK_HIDE = CGPointMake(442.0f, -6.0f);

const float SHRINK_STEP_X = 11.0f;
const float SHRINK_STEP_Y = 9.8f;

void NDMiniMap::mapLogin()
{
	if (m_status == SS_SHRINKING) {
		CGRect rtFrame = this->GetFrameRect();
		CGRect rtBtnShrink = m_btnShrink->GetScreenRect();
		bool bOk = true;
		// x轴
		if (rtBtnShrink.origin.x + SHRINK_STEP_X >= PT_BTN_SHRINK_HIDE.x) {
			rtFrame.origin.x += (PT_BTN_SHRINK_HIDE.x - rtBtnShrink.origin.x);
		} else {
			rtFrame.origin.x += SHRINK_STEP_X;
			bOk = false;
		}
		// y轴
		if (rtBtnShrink.origin.y - SHRINK_STEP_Y <= PT_BTN_SHRINK_HIDE.y) {
			rtFrame.origin.y -= (rtBtnShrink.origin.y - PT_BTN_SHRINK_HIDE.y);
		} else {
			rtFrame.origin.y -= SHRINK_STEP_Y;
			bOk = false;
		}
		
		if (bOk) {
			m_status = SS_HIDE;
		}
		
		this->SetFrameRect(rtFrame);
		
	} else if (m_status == SS_EXTENDING) {
		CGRect rtFrame = this->GetFrameRect();
		
		CGRect rtBtnShrink = m_btnShrink->GetScreenRect();
		bool bOk = true;
		// x轴
		if (rtBtnShrink.origin.x - SHRINK_STEP_X <= PT_BTN_SHRINK_SHOW.x) {
			rtFrame.origin.x -= (rtBtnShrink.origin.x - PT_BTN_SHRINK_SHOW.x);
		} else {
			rtFrame.origin.x -= SHRINK_STEP_X;
			bOk = false;
		}
		// y轴
		if (rtBtnShrink.origin.y + SHRINK_STEP_Y >= PT_BTN_SHRINK_SHOW.y) {
			rtFrame.origin.y += (PT_BTN_SHRINK_SHOW.y - rtBtnShrink.origin.y);
		} else {
			rtFrame.origin.y += SHRINK_STEP_Y;
			bOk = false;
		}
		
		if (bOk) {
			m_status = SS_SHOW;
		}
		
		this->SetFrameRect(rtFrame);
	}
	
	CGSize size = this->scene->GetSize();
	if (size.width > 480) {
		this->MINI_W = 480 / SCALE_X;
	} else {
		this->MINI_W = size.width / SCALE_X;
	}
	if (size.height > 640) {
		this->MINI_H = 640 / SCALE_Y;
	} else {
		this->MINI_H = size.height / SCALE_Y;
	}
	
	CGPoint pos = this->m_role.GetPosition();
	this->scrollX = pos.x / SCALE_X - (MINI_W >> 1);
	this->scrollY = pos.y / SCALE_Y - (MINI_H >> 1);
	

//	if (21005 == NDMapMgrObj.GetMapID()) 
//	{
//		this->m_lbMapName->SetText(NDCommonCString("MingYueLing"));
//	}
//	else
//	{
	SetMapName(NDMapMgrObj.mapName);
//	}
	
	stringstream ss;
	ss << "[" << (int)pos.x / MAP_UNITSIZE << "," << (int)pos.y / MAP_UNITSIZE << "]";
	this->m_lbCoord->SetText(ss.str().c_str());
	
	if (scrollX < 0) {
		scrollX = 0;
	} else if (scrollX + MINI_W > size.width / SCALE_X) {
		scrollX = size.width / SCALE_X - MINI_W;
	}
	if (scrollY < 0) {
		scrollY = 0;
	} else if (scrollY + MINI_H > size.height / SCALE_Y) {
		scrollY = size.height / SCALE_Y - MINI_H;
	}
}

void NDMiniMap::SetMapName(std::string name)
{
	if (m_lbMapName) {
		//if (name.size() > max_mapname_len)
//		{
//			std::string str = name.substr(0, max_mapname_len+1);
//			str += '\n';
//			NSString *strin = [NSString stringWithUTF8String:str.c_str()];
//			m_lbMapName->SetText(str.c_str());
//		}
//		else
			m_lbMapName->SetText(name.c_str());
	}
}

NDMiniMap* NDMiniMap::GetInstance()
{
	return s_instance;
}

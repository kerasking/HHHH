//
//  NDMonster.mm
//  DragonDrive
//
//  Created by jhzheng on 10-12-31.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDMonster.h"
#include "NDPath.h"
#include "NDMapData.h"
#include "NDMapLayer.h"
#include "NDUILayer.h"
#include "NDDirector.h"
#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDDirector.h"
#include "NDConstant.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "Battle.h"
#include "NDUISynLayer.h"
#include "CCPointExtension.h"
#include "NDAnimationGroupPool.h"
#include "SMGameScene.h"
#include "ScriptDataBase.h"
#include "NDDebugOpt.h"
#include "globaldef.h"
#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#define MONSTER_NAME_SIZE (12)
using namespace NDEngine;

IMPLEMENT_CLASS(NDMonster, NDBaseRole)

bool NDMonster::isRoleMonster(int lookface)
{
	return (lookface / 100000000 % 10) >= 3;
}

NDMonster::NDMonster() :
		m_nState(0)
{
	INIT_AUTOLINK (NDMonster);
	m_nSelfMoveRectW = NORMAL_MOVE_RECTW;
	m_nSelfMoveRectH = NORMAL_MOVE_RECTH;
	m_pkBossRing = NULL;
	m_bIsAutoAttack = true;

	m_nStopTimeCount = 0;

	m_nCurStopCount = 0;

	m_nCurMoveCount = 0;

	m_nCurCount = 0;

	m_bIsFrozen = false;

	m_nDeadTime = time(NULL);

	m_nFrozenTime = time(NULL);

	m_nAttackArea = 0;

	monsterInit();

	m_nMoveRectW = 0;
	m_nMoveRectH = 0;

	m_bBattleMap = false;
	m_bRoleMonster = false;

	m_bClear = false;

	m_nFigure = 0;

	m_lbName = NULL;

	m_bTurnFace = false;

	m_bCanBattle = true;

	m_nOriginal_x = 0;
	m_nOriginal_y = 0;

	m_dTimeBossProtect = 0.0f;
	m_bIsHunt = false;
	m_colorName	= ccc4(255, 0, 0, 255);
}

NDMonster::~NDMonster()
{
	SafeClearEffect (m_pkBossRing);
	m_lbName = NULL;
}

void NDMonster::Initialization(int idType)
{
//		ScriptDB* m_Db=new ScriptDB();
	m_strName = ScriptDBObj.GetS("monstertype", idType, DB_MONSTERTYPE_NAME);

	m_nType = idType;

	m_eCamp = CAMP_TYPE_NONE;
	m_nLevel = ScriptDBObj.GetN("monstertype", idType, DB_MONSTERTYPE_LEVEL);
	m_nAttackArea = ScriptDBObj.GetN("monstertype", idType,
			DB_MONSTERTYPE_ATK_AREA);
	int lookface = ScriptDBObj.GetN("monstertype", idType,
			DB_MONSTERTYPE_LOOKFACE);
	//lookface=100000000;
	int aiType = ScriptDBObj.GetN("monstertype", idType,
			DB_MONSTERTYPE_AI_TYPE);
//		sex = lookface / 100000000 % 10;
//		
//		if (lookface >= 20000 && lookface <= 20070 && lookface != 20030) {
//			turnFace = true;
//		}
	m_bRoleMonster = true;
	InitNonRoleData(m_strName, lookface, m_nLevel);
//		if ( sex >= 3 ) // isRoleMonster
//		{
//			m_bRoleMonster = true;
//			InitNonRoleData(m_name, lookface, level);
//		}else
//		{
//			
//			direct = lookface % 10;
//			
//			SetNormalAniGroup(lookface);
//		}

//		if (m_id > 0) 
//		{ //boss
//			m_nMonsterCatogary = MONSTER_BOSS;
//			self_move_rectw = BOSS_MOVE_RECTW;
//			self_move_rectH = BOSS_MOVE_RECTH;
//			
//			ElementMonsterDeal();
//		}
//		else 
//		{
	m_nMonsterCatogary = MONSTER_NORMAL;
	m_nSelfMoveRectW = NORMAL_MOVE_RECTW;
	m_nSelfMoveRectH = NORMAL_MOVE_RECTH;
//		}

	m_nSelfMoveRectX = GetPosition().x - (m_nSelfMoveRectW - BASE_BOTTOM_WH) / 2;
	m_nSelfMoveRectY = GetPosition().y - (m_nSelfMoveRectH - BASE_BOTTOM_WH) / 2;

	srandom (time(NULL));

m_bFaceRight	= random() % 2;

	if (aiType == 1)
	{
		m_bIsAutoAttack = true;
	}

	if (isUseAI())
	{
		m_bIsHunt = true;
		randomMonsterUseAI();
	}
	else
	{
		m_bIsHunt = false;
		randomMonsterNotAI();
	}
}

void NDMonster::setOriginalPosition(int o_x, int o_y)
{
	m_nOriginal_x = o_x;
	m_nOriginal_y = o_y;
}

void NDMonster::restorePosition()
{
	SetPosition(ccp(m_nOriginal_x, m_nOriginal_y));
}

void NDMonster::SetMoveRect(CGPoint point, int size)
{
	m_nSelfMoveRectW = size * 2 * MAP_UNITSIZE;
	m_nSelfMoveRectH = size * 2 * MAP_UNITSIZE;

// 	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 	NDMapData  *mapdata = NULL;
// 	if (layer) {
// 		mapdata=layer->GetMapData();
// 		if (mapdata){
// 			m_nSelfMoveRectH = mapdata->getRows()*MAP_UNITSIZE;
// 		}
// 	}

	m_nSelfMoveRectX = point.x - m_nSelfMoveRectW / 2;
	m_nSelfMoveRectY = 0;
}

void NDMonster::Initialization(int lookface, int idNpc, int lvl, bool bFaceRight/*=true*/)
{
//		if (lookface >= 20000 && lookface <= 20070 && lookface != 20030) {
//			turnFace = true;
//		} else {
//			turnFace = false;
//		}

// 	if (isRoleMonster(lookface))
// 	{
// 		m_bRoleMonster = true;
// 		InitNonRoleData("", lookface, lvl);
// 		SetNonRole(false);
// 	}
// 	else
// 	{
		SetNormalAniGroup(lookface);
		SetNonRole(true);
//	}

	m_nID = idNpc;

	m_bFaceRight = bFaceRight;
	m_nMonsterCatogary = MONSTER_Farm;
	m_nSelfMoveRectW = BOSS_MOVE_RECTW;
	m_nSelfMoveRectH = BOSS_MOVE_RECTH;

	m_nSelfMoveRectX = GetPosition().x - (m_nSelfMoveRectW - BASE_BOTTOM_WH) / 2;
	m_nSelfMoveRectY = GetPosition().y - (m_nSelfMoveRectH - BASE_BOTTOM_WH) / 2;

	if (isUseAI())
	{
		randomMonsterUseAI();
	}
	else
	{
		randomMonsterNotAI();
	}
}

void NDMonster::SetType(int type)
{
	m_nMonsterCatogary = type;
	if (type == MONSTER_NORMAL)
	{ //boss

		ElementMonsterDeal();
	}
}

bool NDMonster::OnDrawBegin(bool bDraw)
{
	if (!NDDebugOpt::getDrawRoleEnabled()) return false;

	if (m_nFigure == 0)
	{
		SetShadowOffset(0, 10);
		ShowShadow(true);
	}
	else
	{
		SetShadowOffset(-8, 10);
		ShowShadow(true, true);
	}

	NDBaseRole::OnDrawBegin(bDraw);

// 	if (!IsKindOfClass(RUNTIME_CLASS(NDBattlePet)) 
// 	    && GetParent()
// 	    && GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
// 	{
// 		drawName(bDraw);
// 	}

	if (m_pkBossRing && m_pkSubNode)
	{
		if (!m_pkBossRing->GetParent())
		{
			m_pkSubNode->AddChild(m_pkBossRing);
		}

		if (m_nMonsterCatogary == MONSTER_BOSS)
		{
			int iX = m_kPosition.x;
			int iY = m_kPosition.y-DISPLAY_POS_Y_OFFSET;
			iX += getGravityX()-GetWidth()/2;
			iY += BASE_BOTTOM_WH + 8;
			m_pkBossRing->SetPosition(ccp(iX, iY));
			m_pkBossRing->RunAnimation(bDraw);
		}
	}

// 	if (m_talkBox && m_talkBox->IsVisibled()) 
// 	{
// 		CGPoint scrPos = GetScreenPoint();
// 		scrPos.x -= DISPLAY_POS_X_OFFSET;
// 		scrPos.y -= DISPLAY_POS_Y_OFFSET;
// 		m_talkBox->SetDisPlayPos(ccp(scrPos.x, scrPos.y-getGravityY()+20));
// 	}

	return true;
}

void NDMonster::MoveToPosition(CGPoint toPos,
		SpriteSpeed speed/* = SpriteSpeedStep4*/, bool moveMap/* = false*/)
{
	if (GetParent())
	{
		NDLayer* layer = (NDLayer *) GetParent();
		if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			m_kPointList.clear();
			m_bMoveMap = moveMap;
			m_bIsMoving = true;
			m_nMovePathIndex = 0;
			m_kPointList.push_back(toPos);
		}
	}
}

void NDMonster::WalkToPosition(CGPoint toPos)
{
	if (GetPosition().x > toPos.x)
	{
		if (!m_bTurnFace)
			m_bReverse = m_bFaceRight = true;
		else
			m_bReverse = m_bFaceRight = false;
	}
	else
	{
		if (!m_bTurnFace)
			m_bReverse = m_bFaceRight = false;
		else
			m_bReverse = m_bFaceRight = true;
	}

//		if (m_bRoleMonster) {
	//NDLog("faceRight:%d",m_faceRight);
	m_bFaceRight = !m_bFaceRight;
	m_bReverse = !m_bReverse;
//		}
	MoveToPosition(toPos, SpriteSpeedStep4, false);
}

void NDMonster::Update(unsigned long ulDiff)
{
	if ((!GetParent() && m_nState == MONSTER_STATE_NORMAL) || m_bBattleMap)
	{
		return;
	}

// 	if (NDMapMgrObj.GetBattleMonster() == this)
// 	{
// 		return;
// 	}

	if (m_bIsFrozen)
	{
		if (time(NULL) - m_nFrozenTime >= FROZEN_TIME)
		{
			//setMonsterFrozen(false);
		}
	}

	switch (m_nState)
	{
	case MONSTER_STATE_DEAD:
	{
//				if (!(m_nMonsterCatogary == MONSTER_BOSS))
//				{ // 如果是精英怪直接不画就好
//					long intervalTime = [NSDate timeIntervalSinceReferenceDate] - deadTime;
//					if ( intervalTime > REFRESH_TIME ) 
//					{
//						monsterInit();
//						LogicDraw();
//					}
//					else 
//					{
//						LogicNotDraw();
//					}
//
//				}
//				else 
//				{
		//精英怪直接从内存释放
		LogicNotDraw();
//				}

		break;
	}
	case MONSTER_STATE_NORMAL:
	{
		// 玩家的碰撞检测放这吧
		doMonsterCollides();
		if (!m_bIsMonsterCollide) //&& T.getDialogList().size() == 0)
		{ // 非碰撞状态
			runLogic();
		}
		//drawMonster(g, offset_x, offset_y);
		break;
	}
	case MONSTER_STATE_BATTLE:
	{
		//drawMonster(g, offset_x, offset_y);
//				if (T.battleImage == null) {
//					T.battleImage = T.loadImage("battle.png",false);
//				}
//				T.drawImage(g, T.battleImage, x - aniGroup.getWidth() / 2 + (aniGroup.getGravityX()) - offset_x, y 
//							+ BASE_BOTTOM_WH - aniGroup.getHeight() - offset_y);
		break;
	}
	}
}

bool NDMonster::isUseAI()
{
	//if (GameScreen.role.isTeamLeader() || GameScreen.role.teamId == 0) {
	// 玩家非保护状态,普通攻击怪,并且只有当玩家等级大于怪物等级7级,怪物才不会有AI视野
	//if (isAutoAttack && !GameScreen.role.isSafeProtected() && m_nMonsterCatogary == MONSTER_NORMAL && !(level - GameScreen.role.getLevel() <= LEVEL_GRAY)) {
	if (m_nMonsterCatogary == MONSTER_Farm)
	{
		return false;
	}

	if (m_bIsAutoAttack && m_nMonsterCatogary == MONSTER_NORMAL)
	{
// 		int monsterRow = GetPosition().y / MAP_UNITSIZE;
// 		int monsterCol = GetPosition().x / MAP_UNITSIZE;
// 		int roleRow = NDPlayer::defaultHero().GetPosition().y / MAP_UNITSIZE;
// 		int roleCol = NDPlayer::defaultHero().GetPosition().x / MAP_UNITSIZE;
		int roleX = NDPlayer::defaultHero().GetPosition().x;
//		int roleY = NDPlayer::defaultHero().GetPosition().y;

		if (roleX >= m_nSelfMoveRectX && roleX <= m_nSelfMoveRectX + m_nSelfMoveRectW)
		//&& roleY >= selfMoveRectY
		//&& roleY <= selfMoveRectY + self_move_rectH)
		{ // 并且玩家在怪物的活动范围内
//					if (abs(monsterRow - roleRow) > MONSTER_VIEW_AI || abs(monsterCol - roleCol) > MONSTER_VIEW_AI)
//					{ // 距离太远就不用ai
//						return false;
//					} else 
//					{
			if (roleX > (m_nSelfMoveRectX + m_nSelfMoveRectW / 2 - 16)
					&& roleX < (m_nSelfMoveRectX + m_nSelfMoveRectW / 2 + 16))
			{
				NDPlayer::defaultHero().SetLocked(true);
				NDPlayer::defaultHero().stopMoving();
			}

			return true;
//					}
		}
	}
	//}
	return false;
}

int NDMonster::getRandomAIDirect()
{
	// 0表上,1表下,2左, 3右 ,-1表无方向
	int monsterRow = GetPosition().y / MAP_UNITSIZE;
	int monsterCol = GetPosition().x / MAP_UNITSIZE;
	int roleRow = NDPlayer::defaultHero().GetPosition().y / MAP_UNITSIZE;
	int roleCol = NDPlayer::defaultHero().GetPosition().x / MAP_UNITSIZE;

	int xDirect = dir_invalid; // -1表无方向
	int yDirect = dir_invalid; // -1表无方向

//	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 	NDMapData  *mapdata = NULL;
// 	if (!layer || !( mapdata = layer->GetMapData() )) 
// 	{
		//NDLog("getRandomAIDirect 地图层或地图数据为空");
		return dir_invalid;
//	}

// 	if (monsterCol < roleCol) 
// 	{
// 		if ( !mapdata->canPassByRow(monsterRow, monsterCol + 1) ) 
// 		{ // 该方向不能走
// 			xDirect = dir_invalid;
// 		} else {
// 			xDirect = dir_right;
// 		}
// 		//m_faceRight=false;
// 	} 
// 	else if (monsterCol > roleCol) 
// 	{
// 		if ( !mapdata->canPassByRow(monsterRow, monsterCol - 1))
// 		{// 该方向不能走
// 			xDirect = dir_invalid;
// 		} else 
// 		{
// 			xDirect = dir_left;
// 		}
// 		//m_faceRight=false;
// 	}
// 
// 	if (monsterRow < roleRow) 
// 	{
// 		if ( !mapdata->canPassByRow(monsterRow + 1, monsterCol) )
// 		{// 该方向不能走
// 			yDirect = dir_invalid;
// 		} else 
// 		{
// 			yDirect = dir_down;
// 		}
// 	} 
// 	else if (monsterRow > roleRow) 
// 	{
// 		if ( !mapdata->canPassByRow(monsterRow - 1 ,monsterCol) )
// 		{// 该方向不能走
// 			yDirect = dir_invalid;
// 		} else 
// 		{
// 			yDirect = dir_up;
// 		}
// 	}
// 
// 	if (xDirect == dir_invalid) 
// 	{
// 		return yDirect;
// 	} 
// 	else if (yDirect == dir_invalid) 
// 	{
// 		return xDirect;
// 	} 
// 	else 
// 	{
// 		srandom(time(NULL));
// 		int n = abs(random() % 2);
// 		if (n == 0) 
// 		{
// 			return xDirect;
// 		} else 
// 		{
// 			return yDirect;
// 		}
// 	}
}

void NDMonster::randomMonsterUseAI()
{
	m_nCurStopCount = 0;
	srandom (time(NULL));
	int m = getRandomAIDirect();
	//NDLog("monster ai direct:%d",m);
	if (m == dir_invalid)
	{ // -1表示无路径可走,防止掩码,那么按普通的随机走路
		m_bIsAIUseful = false;
		m_nMoveDirect = (random() % 4 + random() % 4) % 4;
		m_nMoveCount = random() % MOVE_MIN + random() % MOVE_MIN;
		m_nStopTimeCount = random() % ((m_nMoveCount + 1) * 10);
	}
	else
	{
		m_bIsAIUseful = true;
		m_nMoveDirect = m;
		m_nMoveCount = 1;
		m_nStopTimeCount = 0;
	}
	m_nCurMoveCount = 0;
	//setAnigroupFace();
	SetCurrentAnimation(MONSTER_MAP_MOVE, m_bFaceRight);
}

void NDMonster::randomMonsterNotAI()
{
	m_nCurStopCount = 0;
	m_nMoveDirect = (random() % 4 + random() % 4) % 4;
	m_nMoveCount = random() % MOVE_MIN + random() % MOVE_MIN;
	m_nStopTimeCount = random() % ((m_nMoveCount + 1) * 10);
	m_nCurMoveCount = 0;
	//setAnigroupFace();
	SetCurrentAnimation(MONSTER_MAP_MOVE, m_bFaceRight);
}

void NDMonster::setAnigroupFace()
{
	switch (m_nMoveDirect)
	{
	case dir_left:
	{
		m_bFaceRight = false;
		break;
	}
	case dir_right:
	{
		m_bFaceRight = true;
		break;
	}
	}

//		if (m_bRoleMonster) {
	m_bFaceRight = !m_bFaceRight;
	m_bReverse = !m_bReverse;
//		}
}

void NDMonster::setMonsterFrozen(bool f) // 精英怪才有冻结状态,防止战败后又遇怪
{
	m_bIsFrozen = f;
	if (f)
	{
		m_nFrozenTime = time(0);
	}
}

void NDMonster::monsterInit()
{
	m_nState = MONSTER_STATE_NORMAL;
	m_bIsMonsterCollide = false;
}

void NDMonster::runLogic()
{
	if (m_nMoveDirect == dir_invalid)
	{
		if (m_nCurStopCount >= m_nStopTimeCount)
		{
			if (isUseAI())
			{
				randomMonsterUseAI();
			}
			else
			{
				randomMonsterNotAI();
			}
		}
		else
		{
			m_nCurStopCount++;
			SetCurrentAnimation(MONSTER_MAP_STAND, m_bFaceRight);
		}

	}
	else
	{
		directLogic();
	}
}

void NDMonster::directLogic()
{
// 	int x = GetPosition().x;
// 	int y = GetPosition().y;
// 	int row = y / MAP_UNITSIZE;
// 	int col = x / MAP_UNITSIZE;
// 
// 	//NSString *s1 = [NSString stringWithUTF8String:m_name.c_str()];
// 	//NDLog("%@",s1);
// 
// 	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 	NDMapData  *mapdata = NULL;
// 	if (!layer || !( mapdata = layer->GetMapData() )) 
// 	{
// 		//NDLog("directLogic 地图层或地图数据为空");
// 		return;
// 	}
// 
// 	CGPoint pos; pos.x = x; pos.y = y;
// 
// 	switch (m_nMoveDirect) 
// 	{
// 	case dir_up: 
// 		{ // 上
// 			if ( (y - EVERY_MOVE_DISTANCE) >= m_nSelfMoveRectY && mapdata->canPassByRow(row - 1, col))
// 			{
// 				pos.y -= EVERY_MOVE_DISTANCE;
// 			} 
// 			else 
// 			{
// 				SetCurrentAnimation(MONSTER_MAP_STAND, m_bFaceRight);
// 			}
// 			break;
// 		}
// 	case dir_down: 
// 		{ // 下
// 			if ((y + BASE_BOTTOM_WH + EVERY_MOVE_DISTANCE) <= m_nSelfMoveRectY + m_nSelfMoveRectH && mapdata->canPassByRow(row + 1 ,col) ) 
// 			{
// 				pos.y += EVERY_MOVE_DISTANCE;
// 
// 			} 
// 			else 
// 			{
// 				SetCurrentAnimation(MONSTER_MAP_STAND, m_bFaceRight);
// 			}
// 			break;
// 		}
// 	case dir_left: 
// 		{ // 左
// 			if ( (x - EVERY_MOVE_DISTANCE) >= m_nSelfMoveRectX && mapdata->canPassByRow(row ,col - 1) ) 
// 			{
// 				pos.x -= EVERY_MOVE_DISTANCE;
// 
// 			} 
// 			else 
// 			{
// 				SetCurrentAnimation(MONSTER_MAP_STAND, m_bFaceRight);
// 			}
// 			break;
// 		}
// 	case dir_right:
// 		{ // 右
// 			if ( (x + BASE_BOTTOM_WH + EVERY_MOVE_DISTANCE) <= m_nSelfMoveRectX + m_nSelfMoveRectW && mapdata->canPassByRow(row ,col + 1) )
// 			{
// 				pos.x += EVERY_MOVE_DISTANCE;
// 
// 			} 
// 			else 
// 			{
// 				SetCurrentAnimation(MONSTER_MAP_STAND, m_bFaceRight);
// 			}
// 			break;
// 		}
// 	}
// 
// 	if (pos.x != x || pos.y != y) 
// 	{
// 		WalkToPosition(pos);
// 	}
// 
// 	m_nCurMoveCount++;
// 	if (m_nCurMoveCount >= EVERY_MOVE_COUNT) 
// 	{
// 		m_nCurMoveCount = 0;
// 		m_nCurCount++;
// 
// 		if (m_bIsAIUseful && isUseAI()) 
// 		{
// 			randomMonsterUseAI();
// 		}
// 	}
// 	if (m_nCurCount >= m_nMoveCount) 
// 	{
// 		m_nCurCount = 0;
// 		m_nMoveDirect = -1;
// 		m_bIsAIUseful = true;
// 	}
}

void NDMonster::LogicDraw()
{
// 	if (!GetParent())
// 	{
// 		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 		if (layer) 
// 		{
// 			layer->AddChild(this);
// 			// 其它操作
// 		}
// 	}
}

void NDMonster::LogicNotDraw(bool bClear /*= false*/)
{
	if (bClear)
	{
		// 其它操作
		//通知mapmgr把自己删除
		//NDMapMgrObj.ClearOneMonster(this);
		m_bClear = bClear;
		return;
	}

	if (GetParent())
	{
		// 其它操作
		GetParent()->RemoveChild(this, bClear);
	}
}

void NDMonster::doMonsterCollides()
{
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	if (kPlayer.IsInState(USERSTATE_FIGHTING) || kPlayer.IsSafeProtected()
			|| kPlayer.IsInState(USERSTATE_BF_WAIT_RELIVE)
			|| kPlayer.IsInState(USERSTATE_DEAD) || kPlayer.IsGathering()
			|| (kPlayer.isTeamMember() && !kPlayer.isTeamLeader())
			|| !m_bCanBattle)
	{
		m_bIsMonsterCollide = false;
		return;
	}

	if (m_nMonsterCatogary == MONSTER_BOSS
			&& time(NULL) - m_dTimeBossProtect < BOSS_PROTECT_TIME)
	{
		m_bIsMonsterCollide = false;
		return;
	}

	if (kPlayer.IsInState(USERSTATE_BATTLEFIELD)
			&& m_eCamp == kPlayer.m_eCamp)
	{
		m_bIsMonsterCollide = false;
		return;
	}

	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene)))
	{
		m_bIsMonsterCollide = false;
		return;
	}

/*
	int m_nScope = m_nAttackArea * 32;

	CGRect kRectRole = CGRectMake(NDPlayer::defaultHero().GetPosition().x - 32,
			NDPlayer::defaultHero().GetPosition().y - 32, 64, 64);
	CGRect kRectMonster = CGRectMake(GetPosition().x - m_nScope,
			GetPosition().y - m_nScope, getCollideW() + m_nScope * 2,
			getCollideH() + m_nScope * 2);

	bool bCollides = CGRectIntersectsRect(kRectRole, kRectMonster);
	*/

	//if (bCollides)
	//{ // 碰怪
		m_bIsMonsterCollide = true;

		//setWaitingBattle(true);

//			if ( m_nMonsterCatogary != MONSTER_GUARD )
//			{
		sendBattleAction();
//			} else 
//			{ 
		//final Dialog dialog = new Dialog(monster.monsterName,
//												 GameScreen.role.getName()
//												 + monster.getRandomDialogContent(),
//												 Dialog.PRIV_HIGH);
//				dialog.height = 208;
//				TextView operators[] = new TextView[1];
//				operators[0] = new TextView("确定");
//				operators[0].id = (301);
//				operators[0].parama = monster;
//				operators[0].setOnClickListener(this);
//				dialog.setOperator(operators);
//				T.addDialog(dialog);
//			}
//	}
}

int NDMonster::getCollideW()
{
	switch (m_nMonsterCatogary)
	{
	case MONSTER_NORMAL:
	{				// 普通怪
		return BASE_BOTTOM_WH;
	}
	case MONSTER_BOSS:
	{				// 守卫
		return BASE_BOTTOM_WH * 2;
	}
	}
	return BASE_BOTTOM_WH;
}

int NDMonster::getCollideH()
{
	switch (m_nMonsterCatogary)
	{
	case MONSTER_NORMAL:
	{				// 普通怪
		return BASE_BOTTOM_WH;
	}
	case MONSTER_BOSS:
	{				// 守卫
		return BASE_BOTTOM_WH * 2;
	}
	}
	return BASE_BOTTOM_WH;
}

void NDMonster::sendBattleAction()
{
	NDUISynLayer::Show();

	NDTransData kBao(_MSG_BATTLEACT);

	switch (m_nMonsterCatogary)
	{
	case MONSTER_NORMAL:
	{
		kBao << (unsigned char) BATTLE_ACT_CREATE; // Action值
		kBao << (unsigned char) 0; // btturn
		kBao << (unsigned char) 1; // datacount
		kBao << m_nID; // 怪物类型Id
		break;
	}
	case MONSTER_ELITE:
	{
		kBao << (unsigned char) BATTLE_ACT_CREATE; // Action值
		kBao << (unsigned char) 0; // btturn
		kBao << (unsigned char) 1; // datacount
		kBao << m_nID; // 怪物类型Id
		break;
	}
	case MONSTER_BOSS:
	{
		kBao << (unsigned char) BATTLE_ACT_CREATE_BOSS; // Action值
		kBao << (unsigned char) 0; // btturn
		kBao << (unsigned char) 1; // datacount
		kBao << m_nID; // 怪物Id
		break;
	}
	default:
		return;
		break;
	}

	NDDataTransThread::DefaultThread()->GetSocket()->Send(&kBao);
//	NDMapMgrObj.SetBattleMonster(this);
	NDPlayer::defaultHero().stopMoving(true);
}

void NDMonster::ElementMonsterDeal()
{
	if (!m_pkBossRing)
	{
//			bossRing = new NDSprite;
//			bossRing->Initialization([[NSString stringWithFormat:@"%@effect_101.spr", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()] ] UTF8String]);
//			bossRing->SetCurrentAnimation(0, false);
	}

	m_nMonsterCatogary = MONSTER_BOSS;
}

void NDMonster::setMonsterStateFromBattle(int result)
{
	switch (result)
	{
	case BATTLE_COMPLETE_WIN:
	{ // 玩家打赢
		setState (MONSTER_STATE_DEAD);
		break;
	}
	case BATTLE_COMPLETE_LOSE:
	case BATTLE_COMPLETE_NO:
	{ // 玩家打平或战斗失败
		if (m_nMonsterCatogary == MONSTER_BOSS)
		{
			//setMonsterFrozen(true);
			LogicDraw();
			NDPlayer::defaultHero().setSafeProtected(true);
		}
		else
		{
			setState (MONSTER_STATE_NORMAL);
		}
		break;
	}
	}
}

void NDMonster::startBattle()
{
	LogicNotDraw();
}

void NDMonster::endBattle()
{
	if (m_nMonsterCatogary == MONSTER_BOSS)
	{
		m_dTimeBossProtect = time(NULL);
	}
}

void NDMonster::setState(int monsterState)
{
	m_nState = monsterState;
	switch (m_nState)
	{
	case MONSTER_STATE_DEAD:
	{
		m_nDeadTime = time(NULL);
		break;
	}
	case MONSTER_STATE_NORMAL:
	{
		m_bIsMonsterCollide = false;
		if (m_nMonsterCatogary == MONSTER_BOSS && GetParent() == NULL)
		{
			LogicDraw();
		}
		break;
	}
	case MONSTER_STATE_BATTLE:
	{
		break;
	}
	}
}

void NDMonster::OnMoving(bool bLastPos)
{

}

void NDMonster::drawName(bool bDraw)
{
	if (!m_pkSubNode)
	{
		return;
	}

// 	NDPlayer& player = NDPlayer::defaultHero();
// 	CGPoint posPlayer = player.GetPosition();
// 	CGRect rect1 = CGRectMake(posPlayer.x - SHOW_NAME_ROLE_W,
// 			posPlayer.y - SHOW_NAME_ROLE_H, SHOW_NAME_ROLE_W << 1,
// 			SHOW_NAME_ROLE_H << 1);
// 	CGRect rect2 = CGRectMake(m_kPosition.x - DISPLAY_POS_X_OFFSET,
// 			m_kPosition.y - DISPLAY_POS_Y_OFFSET, 16, 16);
// 	//if (CGRectIntersectsRect(rect1, rect2)) { // 显示区域内的怪物名字
	int iColor = 0;
// 	if (m_nLevel - player.m_nLevel <= LEVEL_GRAY)
// 	{
// 		iColor = 0x555555;
// 	}
// 	else if (m_nLevel - player.m_nLevel <= LEVEL_GREEN)
// 	{
// 		iColor = 0x2cf611;
// 	}
// 	else if (m_nLevel - player.m_nLevel <= LEVEL_YELLOW)
// 	{
// 		iColor = 0xffff00;
// 	}
// 	else if (m_nLevel - player.m_nLevel <= LEVEL_ORANGE)
// 	{
// 		iColor = 0xffff00;
// 	}
// 	else
// 	{ // 太高级用红色显示
// 		iColor = 0xf4031f;
// 	}
// 	if (m_eCamp != CAMP_NEUTRAL && m_eCamp == player.GetCamp())
// 	{
// 		iColor = 0xffffff;
// 	}
// 	else if (m_eCamp != CAMP_NEUTRAL && m_eCamp != player.GetCamp())
// 	{
// 		iColor = 0xff0000;
// 	}

	iColor = 0xff0000;

	int iX = m_kPosition.x - DISPLAY_POS_X_OFFSET;
	int iY = m_kPosition.y - DISPLAY_POS_Y_OFFSET;
	iX += BASE_BOTTOM_WH / 2;
	//iY += BASE_BOTTOM_WH-getGravityY();
	iY -= getGravityY();

	CGSize size = getStringSize(m_strName.c_str(), MONSTER_NAME_SIZE);
	CGSize sizemap;
	sizemap = m_pkSubNode->GetContentSize();

	if (!m_lbName)
	{
		m_lbName = new NDUILabel;
		m_lbName->Initialization();
		m_lbName->SetFontSize(MONSTER_NAME_SIZE);
		m_lbName->SetText(m_strName.c_str());
	}

	if (!m_lbName->GetParent() && m_pkSubNode)
	{
		m_pkSubNode->AddChild(m_lbName);
	}

	if (m_bSetColor)
	{
		m_lbName->SetFontColor(m_colorName);
	}
	else
	{
		m_lbName->SetFontColor(INTCOLORTOCCC4(iColor));
	}

	m_lbName->SetFrameRect(
			CGRectMake(iX - size.width / 2,
					iY + NDDirector::DefaultDirector()->GetWinSize().height
							- sizemap.height, size.width, size.height + 5));

	if (bDraw)
	{
		m_lbName->draw();
	}
	//}
}

void NDMonster::SetCanBattle(bool bCanBattle)
{
	m_bCanBattle = bCanBattle;
}

bool NDMonster::CanBattele()
{
	return m_bCanBattle;
}

void NDMonster::changeLookface(int lookface)
{
//		if (lookface >= 20000 && lookface <= 20070 && lookface != 20030) {
//			turnFace = true;
//		} else {
//			turnFace = false;
//		}

	if (isRoleMonster(lookface))
	{
		m_bRoleMonster = true;
		{	//InitNonRoleData
			//m_id = 0; // 用户id
			m_nSex = lookface / 100000000 % 10; // 人物性别，1-男性，2-女性；
			m_nDirect = lookface % 10;
			m_nHairColor = lookface / 1000000 % 10;
			int tmpsex = (m_nSex - 1) / 2 - 1;
			if (tmpsex < 0 || tmpsex > 2)
			{
				tmpsex = 0;
			}
			SetHair(tmpsex + 1); // 发型

			SetHairImageWithEquipmentId (m_nHair);

			int flagOrRidePet = lookface / 10000000 % 10;
			if (flagOrRidePet > 0)
			{
				if (flagOrRidePet < 5)
				{
					m_eCamp = CAMP_TYPE(flagOrRidePet);
				}
				else
				{
					int id = (flagOrRidePet + 1995) * 10;
					SetEquipment(id, 0);
				}
			}

			m_nWeapon = getEquipmentLookFace(lookface, 0);
			m_nCap = getEquipmentLookFace(lookface, 1);
			m_nArmor = getEquipmentLookFace(lookface, 2);
			SetEquipment(m_nWeapon, 0); //武器
			SetEquipment(m_nCap, 0); //头盔
			SetEquipment(m_nArmor, 0); //胸甲

			//Load Animation Group
			CC_SAFE_DELETE (m_pkAniGroup);

			if (m_nSex % 2 == SpriteSexMale)
				m_pkAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSpr(MANUELROLE_HUMAN_MALE);
			else
				m_pkAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSpr(MANUELROLE_HUMAN_FEMALE);

			m_bFaceRight = m_nDirect == 2;
			SetFaceImageWithEquipmentId (m_bFaceRight);
			SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);

			defaultDeal();
		}
	}
	else
	{
		{ // SetNormalAniGroup
			if (lookface <= 0)
			{
				return;
			}

			m_nColorInfo = lookface / 100000 % 10;

			if (m_nColorInfo == 0)
				m_nColorInfo = -1;

//				if (m_aniGroup) 
//				{
//					[m_aniGroup release];
//				}
//				
//				m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:
//							  [NSString stringWithFormat:@"%@%d%s", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()], (lookface % 100000) / 10, ".spr"]
//							  ];

			m_bFaceRight = lookface % 10 == 2;
			SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
		}
	}

	SetNonRole(!isRoleMonster(lookface));
}

void NDMonster::SetNameColor(ccColor4B color)
{
	m_bSetColor		= true;
	m_colorName		= color;
}

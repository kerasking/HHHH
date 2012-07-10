//
//  NDMonster.mm
//  DragonDrive
//
//  Created by jhzheng on 10-12-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
#include "globaldef.h"
#include <time.h>
#include <stdlib.h>
#include <stdio.h>

using namespace NDEngine;

	IMPLEMENT_CLASS(NDMonster, NDBaseRole)
	
	bool NDMonster::isRoleMonster(int lookface)
	{
		return (lookface / 100000000 % 10) >= 3;
	}

	NDMonster::NDMonster() :
	state(0)
	{
		INIT_AUTOLINK(NDMonster);
		self_move_rectw = NORMAL_MOVE_RECTW;
		self_move_rectH = NORMAL_MOVE_RECTH;
		bossRing = NULL;
		isAutoAttack = true;
		
		stop_time_count = 0;
		
		curStopCount = 0;
		
		curMoveCount = 0;
		
		curCount = 0;
	
		isFrozen = false;
		
		deadTime = time(NULL);
		
		frozenTime = time(NULL);
		
		attackArea = 0;
		
		monsterInit();
		
		moveRectW = 0;
		moveRectH = 0;
		
		bBattleMap = false;
		m_bRoleMonster = false;
		
		bClear = false;
		
		figure = 0;
		
		m_lbName = NULL;
		
		turnFace = false;
		
		m_bCanBattle = true;
		
		original_x=0;
		original_y=0;
		
		m_timeBossProtect = 0.0f;
		isHunt=false;
	}
	
	NDMonster::~NDMonster()
	{
		SafeClearEffect(bossRing);
		m_lbName = NULL;
	}
	
	void NDMonster::Initialization(int idType)
	{
//		ScriptDB* m_Db=new ScriptDB();
		m_name=ScriptDBObj.GetS("monstertype", idType, DB_MONSTERTYPE_NAME);
		
		
		nType = idType;
		

		camp = CAMP_TYPE_NONE;
		level = ScriptDBObj.GetN("monstertype", idType,DB_MONSTERTYPE_LEVEL);
		attackArea = ScriptDBObj.GetN("monstertype", idType,DB_MONSTERTYPE_ATK_AREA);
		int lookface = ScriptDBObj.GetN("monstertype", idType,DB_MONSTERTYPE_LOOKFACE);
		//lookface=100000000;
		int aiType=ScriptDBObj.GetN("monstertype", idType,DB_MONSTERTYPE_AI_TYPE);
//		sex = lookface / 100000000 % 10;
//		
//		if (lookface >= 20000 && lookface <= 20070 && lookface != 20030) {
//			turnFace = true;
//		}
		m_bRoleMonster = true;
		InitNonRoleData(m_name, lookface, level);
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
//			monsterCatogary = MONSTER_BOSS;
//			self_move_rectw = BOSS_MOVE_RECTW;
//			self_move_rectH = BOSS_MOVE_RECTH;
//			
//			ElementMonsterDeal();
//		}
//		else 
//		{
		monsterCatogary = MONSTER_NORMAL;
		self_move_rectw = NORMAL_MOVE_RECTW;
		self_move_rectH = NORMAL_MOVE_RECTH;
//		}
		
		selfMoveRectX = GetPosition().x - (self_move_rectw - BASE_BOTTOM_WH) / 2;
		selfMoveRectY = GetPosition().y - (self_move_rectH - BASE_BOTTOM_WH) / 2;
		
		srandom(time(NULL));
		
		m_faceRight = random() % 2;
	
		if (aiType == 1 )
			isAutoAttack = true;
		
		if (isUseAI()) 
		{
			isHunt=true;
			randomMonsterUseAI();
		} else 
		{
			isHunt=false;
			randomMonsterNotAI();
		}
	}

	void NDMonster::setOriginalPosition(int o_x,int o_y){
		original_x=o_x;
		original_y=o_y;
	}

	void NDMonster::restorePosition(){
		this->SetPosition(ccp(original_x,original_y));
	}

	void NDMonster::SetMoveRect(CGPoint point,int size){

		self_move_rectw = size*2*MAP_UNITSIZE;
		self_move_rectH = size*2*MAP_UNITSIZE;
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		NDMapData  *mapdata = NULL;
		if (layer) {
			mapdata=layer->GetMapData();
			if (mapdata){
				self_move_rectH = mapdata->getRows()*MAP_UNITSIZE;
			}
		}

		
		
		selfMoveRectX = point.x - self_move_rectw / 2;
		selfMoveRectY = 0;
	}
	
	void NDMonster::Initialization(int lookface, int idNpc, int lvl)
	{
//		if (lookface >= 20000 && lookface <= 20070 && lookface != 20030) {
//			turnFace = true;
//		} else {
//			turnFace = false;
//		}
		
		if (isRoleMonster(lookface)) 
		{
			m_bRoleMonster = true;
			InitNonRoleData("", lookface, lvl);
			SetNonRole(false);
		} else {
			SetNormalAniGroup(lookface);
			SetNonRole(true);
		}
		
		m_id = idNpc;
		
		
		monsterCatogary = MONSTER_Farm;
		self_move_rectw = BOSS_MOVE_RECTW;
		self_move_rectH = BOSS_MOVE_RECTH;

		
		selfMoveRectX = GetPosition().x - (self_move_rectw - BASE_BOTTOM_WH) / 2;
		selfMoveRectY = GetPosition().y - (self_move_rectH - BASE_BOTTOM_WH) / 2;
		
		if (isUseAI()) 
		{
			randomMonsterUseAI();
		} else 
		{
			randomMonsterNotAI();
		}
	}

	void NDMonster::SetType(int type)
	{
		monsterCatogary = type;
		if (type==MONSTER_NORMAL) 
		{ //boss

			
			ElementMonsterDeal();
		}
	}
	
	bool NDMonster::OnDrawBegin(bool bDraw)
	{
		if (figure == 0) 
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
		
		if (this->GetParent()
			&& this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
		{
			drawName(bDraw);
		}
		
		
		if (bossRing && subnode)
		{
			if (!bossRing->GetParent())
			{
				subnode->AddChild(bossRing);
			}
			
			if (monsterCatogary == MONSTER_BOSS) 
			{
				int iX = m_position.x;
				int iY = m_position.y-DISPLAY_POS_Y_OFFSET;
				iX += getGravityX()-GetWidth()/2;
				iY += BASE_BOTTOM_WH + 8;
				bossRing->SetPosition(ccp(iX, iY));
				bossRing->RunAnimation(bDraw);
			}
		}
		
		return true;
	}

	void NDMonster::MoveToPosition(CGPoint toPos, SpriteSpeed speed/* = SpriteSpeedStep4*/, bool moveMap/* = false*/)
	{
		if (this->GetParent()) 
		{
			NDLayer* layer = (NDLayer *)this->GetParent();
			if (layer->IsKindOfClass(RUNTIME_CLASS(NDMapLayer))) 
			{
				m_pointList.clear();
				m_moveMap = moveMap;
				m_moving  = true;
				m_movePathIndex = 0;
				m_pointList.push_back(toPos);
			}		
		}
	}

	void NDMonster::WalkToPosition(CGPoint toPos)
	{
		if (this->GetPosition().x > toPos.x) 
		{
			if (!turnFace) 
				m_reverse = m_faceRight = true;		
			else
				m_reverse = m_faceRight = false;		
		}
		else 
		{
			if (!turnFace)
				m_reverse = m_faceRight = false;
			else
				m_reverse = m_faceRight = true;
		}
		
//		if (this->m_bRoleMonster) {
		//NDLog("faceRight:%d",m_faceRight);
		m_faceRight = !m_faceRight;
		m_reverse = !m_reverse;
//		}
		this->MoveToPosition(toPos, SpriteSpeedStep4, false);
	}

	void NDMonster::Update(unsigned long ulDiff)
	{
		if ((!this->GetParent() && state == MONSTER_STATE_NORMAL) || bBattleMap) 
		{
			return;
		}
		
		if (NDMapMgrObj.GetBattleMonster() == this)
		{
			return;
		}
		
		if (isFrozen) 
		{
			if (time(NULL) - frozenTime >= FROZEN_TIME) 
			{
				//setMonsterFrozen(false);
			}
		}
		
		switch (state) 
		{
			case MONSTER_STATE_DEAD: 
			{
//				if (!(monsterCatogary == MONSTER_BOSS))
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
				if (!isMonsterCollide) //&& T.getDialogList().size() == 0) 
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
			//if (isAutoAttack && !GameScreen.role.isSafeProtected() && monsterCatogary == MONSTER_NORMAL && !(level - GameScreen.role.getLevel() <= LEVEL_GRAY)) {
		if (monsterCatogary == MONSTER_Farm) {
			return false;
		}
		if ( isAutoAttack && monsterCatogary == MONSTER_NORMAL ) 
		{		
				int monsterRow = GetPosition().y / MAP_UNITSIZE;
				int monsterCol = GetPosition().x / MAP_UNITSIZE;
				int roleRow = NDPlayer::defaultHero().GetPosition().y / MAP_UNITSIZE;
				int roleCol = NDPlayer::defaultHero().GetPosition().x / MAP_UNITSIZE;
				int roleX = NDPlayer::defaultHero().GetPosition().x;
				int roleY = NDPlayer::defaultHero().GetPosition().y;
				
				if (roleX >= selfMoveRectX 
					&& roleX <= selfMoveRectX + self_move_rectw )
					//&& roleY >= selfMoveRectY 
					//&& roleY <= selfMoveRectY + self_move_rectH) 
				{ // 并且玩家在怪物的活动范围内
//					if (abs(monsterRow - roleRow) > MONSTER_VIEW_AI || abs(monsterCol - roleCol) > MONSTER_VIEW_AI)
//					{ // 距离太远就不用ai
//						return false;
//					} else 
//					{
					if (roleX>(selfMoveRectX + self_move_rectw/2-16)&&roleX<(selfMoveRectX + self_move_rectw/2+16))
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

	int  NDMonster::getRandomAIDirect()
	{
		// 0表上,1表下,2左, 3右 ,-1表无方向
		int monsterRow = GetPosition().y / MAP_UNITSIZE;
		int monsterCol = GetPosition().x / MAP_UNITSIZE;
		int roleRow = NDPlayer::defaultHero().GetPosition().y / MAP_UNITSIZE;
		int roleCol = NDPlayer::defaultHero().GetPosition().x / MAP_UNITSIZE;
		
		int xDirect = dir_invalid;// -1表无方向
		int yDirect = dir_invalid; // -1表无方向
		
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		NDMapData  *mapdata = NULL;
		if (!layer || !( mapdata = layer->GetMapData() )) 
		{
			//NDLog("getRandomAIDirect 地图层或地图数据为空");
			return dir_invalid;
		}
		
		if (monsterCol < roleCol) 
		{
			if ( !mapdata->canPassByRow(monsterRow, monsterCol + 1) ) 
			{ // 该方向不能走
				xDirect = dir_invalid;
			} else {
				xDirect = dir_right;
			}
			//m_faceRight=false;
		} 
		else if (monsterCol > roleCol) 
		{
			if ( !mapdata->canPassByRow(monsterRow, monsterCol - 1))
			{// 该方向不能走
				xDirect = dir_invalid;
			} else 
			{
				xDirect = dir_left;
			}
			//m_faceRight=false;
		}
		
		if (monsterRow < roleRow) 
		{
			if ( !mapdata->canPassByRow(monsterRow + 1, monsterCol) )
			{// 该方向不能走
				yDirect = dir_invalid;
			} else 
			{
				yDirect = dir_down;
			}
		} 
		else if (monsterRow > roleRow) 
		{
			if ( !mapdata->canPassByRow(monsterRow - 1 ,monsterCol) )
			{// 该方向不能走
				yDirect = dir_invalid;
			} else 
			{
				yDirect = dir_up;
			}
		}
		
		if (xDirect == dir_invalid) 
		{
			return yDirect;
		} 
		else if (yDirect == dir_invalid) 
		{
			return xDirect;
		} 
		else 
		{
			srandom(time(NULL));
			int n = abs(random() % 2);
			if (n == 0) 
			{
				return xDirect;
			} else 
			{
				return yDirect;
			}
		}
	}

	void NDMonster::randomMonsterUseAI()
	{
		curStopCount = 0;
		srandom(time(NULL));
		int m = getRandomAIDirect();
		//NDLog("monster ai direct:%d",m);
		if (m == dir_invalid) 
		{// -1表示无路径可走,防止掩码,那么按普通的随机走路
			isAiUseful = false;
			moveDirect =  (random()% 4 + random() % 4) % 4;
			moveCount = random() % MOVE_MIN + random() % MOVE_MIN;
			stop_time_count = random() % ((moveCount + 1) * 10);
		} else 
		{
			isAiUseful = true;
			moveDirect = m;
			moveCount = 1;
			stop_time_count = 0;
		}
		curMoveCount = 0;
		//setAnigroupFace();
		SetCurrentAnimation(MONSTER_MAP_MOVE, m_faceRight);
	}

	void NDMonster::randomMonsterNotAI()
	{
		curStopCount = 0;
		moveDirect =  (random()% 4 + random() % 4) % 4;
		moveCount = random() % MOVE_MIN + random() % MOVE_MIN;
		stop_time_count = random() % ((moveCount + 1) * 10);
		curMoveCount = 0;
		//setAnigroupFace();
		SetCurrentAnimation(MONSTER_MAP_MOVE, m_faceRight);
	}

	void NDMonster::setAnigroupFace() 
	{
		switch (moveDirect) 
		{
			case dir_left: 
			{
				m_faceRight = false;
				break;
			}
			case dir_right: 
			{
				m_faceRight = true;
				break;
			}
		}
		
//		if (this->m_bRoleMonster) {
			m_faceRight = !m_faceRight;
			m_reverse = !m_reverse;
//		}
	}
	
	void NDMonster::setMonsterFrozen(bool f) // 精英怪才有冻结状态,防止战败后又遇怪
	{
		isFrozen = f;
		if (f) 
		{
			frozenTime = time();
		}
	}

	void NDMonster::monsterInit()
	{
		state = MONSTER_STATE_NORMAL;
		isMonsterCollide = false;
	}

	void NDMonster::runLogic()
	{
		if (moveDirect == dir_invalid) 
		{
			if (curStopCount >= stop_time_count) 
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
				curStopCount++;
				SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
			}
			
		} 
		else 
		{
			directLogic();
		}
	}

	void NDMonster::directLogic()
	{
		int x = GetPosition().x;
		int y = GetPosition().y;
		int row = y / MAP_UNITSIZE;
		int col = x / MAP_UNITSIZE;
		
		//NSString *s1 = [NSString stringWithUTF8String:this->m_name.c_str()];
		//NDLog("%@",s1);
		
		NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		NDMapData  *mapdata = NULL;
		if (!layer || !( mapdata = layer->GetMapData() )) 
		{
			//NDLog("directLogic 地图层或地图数据为空");
			return;
		}
		
		CGPoint pos; pos.x = x; pos.y = y;
		
		switch (moveDirect) 
		{
			case dir_up: 
			{ // 上
				if ( (y - EVERY_MOVE_DISTANCE) >= selfMoveRectY && mapdata->canPassByRow(row - 1, col)
				{
					pos.y -= EVERY_MOVE_DISTANCE;
				} 
				else 
				{
					SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
				}
				break;
			}
			case dir_down: 
			{ // 下
				if ((y + BASE_BOTTOM_WH + EVERY_MOVE_DISTANCE) <= selfMoveRectY + self_move_rectH && mapdata->canPassByRow(row + 1 ,col) ) 
				{
					pos.y += EVERY_MOVE_DISTANCE;
					
				} 
				else 
				{
					SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
				}
				break;
			}
			case dir_left: 
			{ // 左
				if ( (x - EVERY_MOVE_DISTANCE) >= selfMoveRectX && mapdata->canPassByRow(row ,col - 1) ) 
				{
					pos.x -= EVERY_MOVE_DISTANCE;
					
				} 
				else 
				{
					SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
				}
				break;
			}
			case dir_right:
			{ // 右
				if ( (x + BASE_BOTTOM_WH + EVERY_MOVE_DISTANCE) <= selfMoveRectX + self_move_rectw && mapdata->canPassByRow(row ,col + 1) )
				{
					pos.x += EVERY_MOVE_DISTANCE;
					
				} 
				else 
				{
					SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
				}
				break;
			}
		}
		
		if (pos.x != x || pos.y != y) 
		{
			WalkToPosition(pos);
		}
		
		curMoveCount++;
		if (curMoveCount >= EVERY_MOVE_COUNT) 
		{
			curMoveCount = 0;
			curCount++;
			
			if (isAiUseful && isUseAI()) 
			{
				randomMonsterUseAI();
			}
		}
		if (curCount >= moveCount) 
		{
			curCount = 0;
			moveDirect = -1;
			isAiUseful = true;
		}
	}

	void NDMonster::LogicDraw()
	{
		if (!GetParent()) 
		{
			NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
			if (layer) 
			{
				layer->AddChild(this);
				// 其它操作
			}
		}
	}

	void NDMonster::LogicNotDraw(bool bClear /*= false*/)
	{
		if (bClear) 
		{
			// 其它操作
			//通知mapmgr把自己删除
			//NDMapMgrObj.ClearOneMonster(this);
			this->bClear = bClear;
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
		NDPlayer& player = NDPlayer::defaultHero();
		if ( player.IsInState(USERSTATE_FIGHTING) 
		    || player.IsSafeProtected() 
			|| player.IsInState(USERSTATE_BF_WAIT_RELIVE)
			|| player.IsInState(USERSTATE_DEAD)
			|| player.IsGathering()
			|| (player.isTeamMember() && !player.isTeamLeader())
			|| !m_bCanBattle) 
		{
			isMonsterCollide = false;
			return;
		}
			
		if (monsterCatogary == MONSTER_BOSS 
			&& time(NULL) - m_timeBossProtect < BOSS_PROTECT_TIME) 
		{
			isMonsterCollide = false;
			return;
		}
		
		if (player.IsInState(USERSTATE_BATTLEFIELD)
			&& this->camp == player.camp)
		{
			isMonsterCollide = false;
			return;
		}
		
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(CSMGameScene)))
		{
			isMonsterCollide = false;
			return;
		}
		

		int scope = attackArea * 32;

		CGRect rectRole = CGRectMake(NDPlayer::defaultHero().GetPosition().x-32,
									 NDPlayer::defaultHero().GetPosition().y-32, 
									 64,
									 64);
		CGRect rectMonster = CGRectMake(GetPosition().x-scope,
										GetPosition().y-scope,
										getCollideW()+scope*2,
										getCollideH()+scope*2);
		
		bool collides = CGRectIntersectsRect(rectRole, rectMonster);
		
		if (collides) 
		{ // 碰怪
			isMonsterCollide = true;
			
			//setWaitingBattle(true);
			
//			if ( monsterCatogary != MONSTER_GUARD )
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
		}
	}

	int NDMonster::getCollideW() 
	{
		switch (monsterCatogary) 
		{
			case MONSTER_NORMAL: 
			{// 普通怪
				return BASE_BOTTOM_WH;
			}
			case MONSTER_BOSS: 
			{// 守卫
				return BASE_BOTTOM_WH*2;
			}
		}
		return BASE_BOTTOM_WH;
	}

	int NDMonster::getCollideH()
	{
		switch (monsterCatogary) 
		{
			case MONSTER_NORMAL:
			{// 普通怪
				return BASE_BOTTOM_WH;
			}
			case MONSTER_BOSS: 
			{// 守卫
				return BASE_BOTTOM_WH*2;
			}
		}
		return BASE_BOTTOM_WH;
	}

	void NDMonster::sendBattleAction()
	{
		NDUISynLayer::Show();
		
		NDTransData bao(_MSG_BATTLEACT);
		
		switch (monsterCatogary)
		{
			case MONSTER_NORMAL: 
			{
				bao << (unsigned char)BATTLE_ACT_CREATE; // Action值
				bao << (unsigned char)0; // btturn
				bao << (unsigned char)1; // datacount
				bao << m_id; // 怪物类型Id
				break;
			}
			case MONSTER_ELITE: 
			{
				bao << (unsigned char)BATTLE_ACT_CREATE_ELITE; // Action值
				bao << (unsigned char)0; // btturn
				bao << (unsigned char)1; // datacount
				bao << m_id; // 怪物类型Id
				break;
			}
			case MONSTER_BOSS: 
			{
				bao << (unsigned char)BATTLE_ACT_CREATE_BOSS; // Action值
				bao << (unsigned char)0; // btturn
				bao << (unsigned char)1; // datacount
				bao << m_id; // 怪物Id
				break;
			}
			default:
				return;
				break;
		}
		
		NDDataTransThread::DefaultThread()->GetSocket()->Send(&bao);
		NDMapMgrObj.SetBattleMonster(this);
		NDPlayer::defaultHero().stopMoving(true);
	}
	
	void NDMonster::ElementMonsterDeal()
	{
		if (!bossRing) 
		{
//			bossRing = new NDSprite;
//			bossRing->Initialization([[NSString stringWithFormat:@"%@effect_101.spr", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()] ] UTF8String]);
//			bossRing->SetCurrentAnimation(0, false);
		}
		
		monsterCatogary = MONSTER_BOSS;
	}

	void NDMonster::setMonsterStateFromBattle(int result)
	{
		switch (result) 
		{
			case BATTLE_COMPLETE_WIN:
			{ // 玩家打赢
				setState(MONSTER_STATE_DEAD);
				break;
			}
			case BATTLE_COMPLETE_LOSE:
			case BATTLE_COMPLETE_NO:
			{// 玩家打平或战斗失败
				if (monsterCatogary == MONSTER_BOSS)
				{
					//setMonsterFrozen(true);
					LogicDraw();
					NDPlayer::defaultHero().setSafeProtected(true);
				} 
				else 
				{
					setState(MONSTER_STATE_NORMAL);
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
		if (monsterCatogary == MONSTER_BOSS) 
		{
			m_timeBossProtect = time(NULL);
		}
	}
		
	void NDMonster::setState(int monsterState)
	{
		state = monsterState;
		switch (state)
		{
			case MONSTER_STATE_DEAD:
			{
				deadTime = time(NULL);
				break;
			}
			case MONSTER_STATE_NORMAL: 
			{
				isMonsterCollide = false;
				if (monsterCatogary == MONSTER_BOSS && this->GetParent() == NULL) 
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
		if (!subnode) 
		{
			return;
		}
		
		NDPlayer& player = NDPlayer::defaultHero();
		CGPoint posPlayer = player.GetPosition();
		CGRect rect1 = CGRectMake(posPlayer.x-SHOW_NAME_ROLE_W, posPlayer.y-SHOW_NAME_ROLE_H, SHOW_NAME_ROLE_W << 1, SHOW_NAME_ROLE_H << 1);
		CGRect rect2 = CGRectMake(m_position.x-DISPLAY_POS_X_OFFSET, m_position.y-DISPLAY_POS_Y_OFFSET, 16, 16);
		//if (CGRectIntersectsRect(rect1, rect2)) { // 显示区域内的怪物名字
			int iColor = 0;
			if (level - player.level <= LEVEL_GRAY) {
				iColor = 0x555555;
			} else if (level - player.level <= LEVEL_GREEN) {
				iColor = 0x2cf611;
			} else if (level - player.level <= LEVEL_YELLOW) {
				iColor = 0xffff00;
			} else if (level - player.level <= LEVEL_ORANGE) {
				iColor = 0xffff00;
			} else { // 太高级用红色显示
				iColor = 0xf4031f;
			}
			if (camp != CAMP_NEUTRAL && camp == player.GetCamp()) {
				iColor = 0xffffff;
			} else if (camp != CAMP_NEUTRAL && camp != player.GetCamp()) {
				iColor = 0xff0000;
			}
			
			iColor = 0xff0000;
			
			int iX = m_position.x-DISPLAY_POS_X_OFFSET;
			int iY = m_position.y-DISPLAY_POS_Y_OFFSET;
			iX += BASE_BOTTOM_WH / 2;
			//iY += BASE_BOTTOM_WH-getGravityY();
			iY -= getGravityY();
			
			CGSize size = getStringSize(m_name.c_str(), 12);
			CGSize sizemap;
			sizemap = subnode->GetContentSize();
			
			if (!m_lbName) 
			{
				m_lbName = new NDUILabel;
				m_lbName->Initialization();
				m_lbName->SetFontSize(12);
				m_lbName->SetText(m_name.c_str());
			}
			
			if (!m_lbName->GetParent() && subnode) 
			{
				subnode->AddChild(m_lbName);
			}
			
			m_lbName->SetFontColor(INTCOLORTOCCC4(iColor));
			
			m_lbName->SetFrameRect(CGRectMake(iX-size.width/2, iY+NDDirector::DefaultDirector()->GetWinSize().height-sizemap.height, size.width, size.height+5));
			
			
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
				sex = lookface / 100000000 % 10; // 人物性别，1-男性，2-女性；
				direct = lookface % 10;
				hairColor = lookface / 1000000 % 10;
				int tmpsex = (sex - 1) / 2 - 1;
				if (tmpsex < 0 || tmpsex > 2) {
					tmpsex = 0;
				}
				this->SetHair(tmpsex+1); // 发型
				
				SetHairImageWithEquipmentId(hair);
				
				int flagOrRidePet = lookface / 10000000 % 10;
				if (flagOrRidePet > 0) {
					if (flagOrRidePet < 5) {
						camp = CAMP_TYPE(flagOrRidePet);
					}else {				
						int id = (flagOrRidePet + 1995)*10;
						SetEquipment(id,0);
					}
				}
				
				weapon	= getEquipmentLookFace(lookface, 0);
				cap			= getEquipmentLookFace(lookface, 1);
				armor		= getEquipmentLookFace(lookface, 2);
				SetEquipment(weapon, 0);//武器
				SetEquipment(cap, 0);//头盔
				SetEquipment(armor, 0);//胸甲
				
				//Load Animation Group
				CC_SAFE_DELETE(m_aniGroup);
				if (sex % 2 == SpriteSexMale)
					m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:[NSString stringWithUTF8String:MANUELROLE_HUMAN_MALE]];
				else
					m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:[NSString stringWithUTF8String:MANUELROLE_HUMAN_FEMALE]];
				
				m_faceRight = direct == 2;
				SetFaceImageWithEquipmentId(m_faceRight);
				SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
				
				defaultDeal();
			}
		} 
		else 
		{
			{ // SetNormalAniGroup
				if (lookface <= 0) {
					return;
				}
				
				colorInfo = lookface / 100000 % 10;
				
				if (colorInfo == 0)	colorInfo = -1;
				
//				if (m_aniGroup) 
//				{
//					[m_aniGroup release];
//				}
//				
//				m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:
//							  [NSString stringWithFormat:@"%@%d%s", [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()], (lookface % 100000) / 10, ".spr"]
//							  ];
				
				m_faceRight = lookface % 10 == 2;
				SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
			}
		}
		
		SetNonRole(!isRoleMonster(lookface));
	}

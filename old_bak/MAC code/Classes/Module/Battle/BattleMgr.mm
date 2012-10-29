/*
 *  BattleMgr.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "BattleMgr.h"
#import "NDPlayer.h"
#import "NDTransData.h"
#import "Battle.h"
#import "NDUISynLayer.h"

#import "NDMapMgr.h"
#import "NDDirector.h"
#import "BattleUtil.h"
#include <sstream>
#include "ItemMgr.h"
#include "LearnSkillUILayer.h"
#include "DianhuaUILayer.h"
#include "GameScene.h"
#include "PetSkillCompose.h"
#include "CPet.h"
#include "PlayerInfoScene.h"
#include "ScriptDataBase.h"
#include "ScriptGlobalEvent.h"
#include "DramaScene.h"
#include "DramaTransitionScene.h"

#define QUIT_BATTLE_TIMER_TAG (13621)
#define QUIT_DRAMA_TIMER_TAG (13622)

using std::stringstream;

using namespace NDEngine;

BattleMgr::BattleMgr() :
m_battle(NULL)
{
	NDNetMsgPool& pool = NDNetMsgPoolObj;
	pool.RegMsg(_MSG_BATTLE, this);
	pool.RegMsg(_MSG_CONTROLPOINT, this);
	pool.RegMsg(_MSG_EFFECT, this);
	pool.RegMsg(_MSG_BATTLEEND, this);
	pool.RegMsg(_MSG_SKILLINFO, this);
	pool.RegMsg(_MSG_BATTLE_SKILL_LIST, this);
	pool.RegMsg(_MSG_PLAYER_RECON, this);
	pool.RegMsg(_MSG_PLAYER_EXT_RECON, this);
	//	m_Db=new ScriptDB();
	m_quitTimer = NULL;
	battleReward = NULL;
    prebattleReward = NULL;
	battleMapId = 0;
	battleX=0;
	battleY=0;
	lastBattleTeamCount=0;
	m_iLastSceneMapDocID	= 0;
	m_iLastSceneScreenX		= 0;
	m_iLastSceneScreenY		= 0;
}

BattleMgr::~BattleMgr()
{
	this->ReleaseAllBattleSkill();
	if(battleReward)
	{
		SAFE_DELETE (battleReward);
	}
	if(prebattleReward)
	{
		SAFE_DELETE (prebattleReward);
	}
    
    ReleaseActionList();
}

void BattleMgr::RestoreActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();
	
	for (; it != m_vActionList1.end(); it++)
	{
		//SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		if(action)
		{
			action->action_status=ACTION_STATUS_WAIT;
		}
		
	}
	
	VEC_FIGHTACTION_IT it2 = m_vActionList2.begin();
	
	for (; it2 != m_vActionList2.end(); it2++)
	{
		//SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		if(action)
		{
			action->action_status=ACTION_STATUS_WAIT;
		}
		
	}

	
	VEC_FIGHTACTION_IT it3 = m_vActionList3.begin();
	
	for (; it3 != m_vActionList3.end(); it3++)
	{
		//SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		if(action)
		{
			action->action_status=ACTION_STATUS_WAIT;
		}
		
	}

}

void BattleMgr::ReleaseActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();
	
	for (; it != m_vActionList1.end(); it++)
	{
		//SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it)->m_vCmdList.begin();
		SAFE_DELETE((*it)->skill);
		for(; fm_it!=(*it)->m_vCmdList.end();fm_it++)
		{
			SAFE_DELETE(*fm_it);
		}
		(*it)->m_vCmdList.clear();
		SAFE_DELETE(*it);
		
	}
	
	m_vActionList1.clear();
	
	VEC_FIGHTACTION_IT it2 = m_vActionList2.begin();
	
	for (; it2 != m_vActionList2.end(); it2++)
	{
		//SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it2)->m_vCmdList.begin();
		for(; fm_it!=(*it2)->m_vCmdList.end();fm_it++)
		{
			SAFE_DELETE(*fm_it);
		}
		(*it2)->m_vCmdList.clear();
		SAFE_DELETE(*it2);
		
	}
	
	m_vActionList2.clear();
	
	VEC_FIGHTACTION_IT it3 = m_vActionList3.begin();
	
	for (; it3 != m_vActionList3.end(); it3++)
	{
		//SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it)->m_vCmdList.begin();
		for(; fm_it!=(*it3)->m_vCmdList.end();fm_it++)
		{
			SAFE_DELETE(*fm_it);
		}
		(*it3)->m_vCmdList.clear();
		SAFE_DELETE(*it3);
		
	}
	
	m_vActionList3.clear();
}

BattleSkill* BattleMgr::GetBattleSkill(OBJID idSkill)
{
	MAP_BATTLE_SKILL_IT it = this->m_mapBattleSkill.find(idSkill);
	return it == this->m_mapBattleSkill.end() ? NULL : it->second;
}

void BattleMgr::ReleaseAllBattleSkill()
{
	for (MAP_BATTLE_SKILL_IT it = this->m_mapBattleSkill.begin(); it != this->m_mapBattleSkill.end(); it++) {
		SAFE_DELETE(it->second);
	}
	this->m_mapBattleSkill.clear();
}

void BattleMgr::OnTimer(OBJID tag)
{
	if (tag == QUIT_BATTLE_TIMER_TAG) 
	{
		if ( m_battle && m_battle->IsEraseInOutEffectComplete()) 
		{
			quitBattle(false);
		}
        
	}
    else if(tag == QUIT_DRAMA_TIMER_TAG){
        //检测如果时战斗场景则加载界面
         
        
        if ( NDDirector::DefaultDirector()->GetRunningScene()->IsKindOfClass(RUNTIME_CLASS(DramaScene)))
        {
            return;
        }
        if ( NDDirector::DefaultDirector()->GetRunningScene()->IsKindOfClass(RUNTIME_CLASS(DramaTransitionScene)))
        {
            return;
        }       
        
        
        
        m_startDramaTimer->KillTimer(this, QUIT_DRAMA_TIMER_TAG);
        loadRewardUI();

    }
}

void BattleMgr::loadRewardUI()
{
    ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
    //ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",battleReward->exp);
    ScriptMgrObj.excuteLuaFunc("addSophMoney", "MonsterRewardUI", battleReward->soph, battleReward->money);	
    
    for(int i=0;i<5;i++)
    {
        if(battleReward->itemtype[i]!=0)
        {
            NDLog(@"addRewardItem:%d",battleReward->itemtype[i]);
            ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI",i+1,battleReward->itemtype[i],battleReward->item_amount[i]);
            
        }
    }
    
    for(int i=0;i<5;i++)
    {
        if(battleReward->iPetId[i] !=0)
        {
            NDLog(@"iPetId :%d;  iPetGainExp : %d", battleReward->itemtype[i], battleReward->iPetGainExp[i]);
            ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI", battleReward->iPetId[i], battleReward->iPetGainExp[i]);
        }
    }
    
    ScriptMgrObj.excuteLuaFunc("Refresh", "MonsterRewardUI");	
    
    //结果页面显示之后释放奖励物品
    if (battleReward != NULL)
    {
        SAFE_DELETE (battleReward);
    }      
}

bool BattleMgr::process(MSGID msgID, NDEngine::NDTransData* bao, int len)
{
	switch (msgID)
	{
		case _MSG_BATTLE:
			this->processBattleStart(*bao);
			break;
		case _MSG_CONTROLPOINT:
			this->processControlPoint(*bao);
			break;
		case _MSG_EFFECT:
			this->processBattleEffect(*bao);
			break;
		case _MSG_BATTLEEND:
			this->processBattleEnd(*bao);
			break;
		case _MSG_SKILLINFO:
			this->processSkillInfo(*bao, len);
			break;
		case _MSG_BATTLE_SKILL_LIST:
			this->processBattleSkillList(*bao, len);
			break;
		case _MSG_PLAYER_RECON:
		{
			NDMapMgrObj.processPlayer(bao, len);
		}
			break;
		case _MSG_PLAYER_EXT_RECON:
		{
			NDMapMgrObj.processPlayerExt(bao, len);
		}
			break;
		default:
			break;
	}
	return true;
}

void BattleMgr::processBattleSkillList(NDTransData& data, int len)
{
	if (this->m_battle) {
		this->m_battle->processBattleSkillList(data, len);
	}
}

void BattleMgr::processSkillInfo(NDTransData& data, int len)
{
	int btAction = data.ReadByte();
	int btCnt = data.ReadByte();
	int idPet = data.ReadInt();
	for (int i = 0; i < btCnt; i++) {
		if (btAction <= 2) { // 玩家或宠物技能
			int idSkill = data.ReadInt();
			int statusLast = data.ReadByte();
			int atkType = data.ReadInt();
			int area = data.ReadShort();
			int injury = data.ReadInt();
			int speed = data.ReadByte();
			int mpRequire = data.ReadInt();
			int atk_point = data.ReadByte();
			int def_point = data.ReadByte();
			int dis_point = data.ReadByte();
			int lvRequire = data.ReadInt();
			int money = data.ReadInt();
			int spRequire = data.ReadShort();
			int curSp = data.ReadShort();
			int iconIndex = data.ReadInt();
			Byte depFlag = data.ReadByte();
			Byte btCD = data.ReadByte();
			Byte btSlot = data.ReadByte();
			string name = data.ReadUnicodeString();
			string des = data.ReadUnicodeString();
			string update_required;
			if (depFlag == 1) {
				update_required = data.ReadUnicodeString();
			}
			BattleSkill* skill = this->GetBattleSkill(idSkill);
			NDPlayer& player = NDPlayer::defaultHero();
			// 技能信息已存在
			if (skill) {
				if (btAction == 0) { // 玩家技能
					player.AddSkill(idSkill);
					//GameScreen.role.addSkill(skill);
				} else if (btAction == 1) {
					//NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
					//					if (pet) {
					//						pet->AddSkill(idSkill);
					//					}
					PetMgrObj.AddSkill(player.m_id, idPet, idSkill);
					
					CUIPet *uiPet = PlayerInfoScene::QueryPetScene();
					
					if (uiPet)
					{
						uiPet->UpdateUI(idPet);
					}
				}
				continue;
			}
			
			skill = new BattleSkill;
			skill->setId(idSkill);
			skill->setStatusLast(statusLast);
			skill->setAtkType(SKILL_ATK_TYPE(atkType));
			skill->setArea(area);
			skill->setInjury(injury);
			skill->setSpeed(speed);
			skill->setMpRequire(mpRequire);
			skill->setAtk_point(atk_point);
			skill->setDef_point(def_point);
			skill->setDis_point(dis_point);
			skill->setLvRequire(lvRequire);
			skill->setMoney(money);
			skill->setSpRequire(spRequire);
			skill->setName(name);
			skill->setDes(des);
			skill->setCurSp(curSp);
			skill->setUpdate_required(update_required);
			skill->setIconIndex(iconIndex);
			skill->setCd(btCD);
			skill->SetSlot(btSlot);
			
			this->m_mapBattleSkill[idSkill] = skill;
			
			skill->SetSkillOwn(btAction == 0);
			
			if (btAction == 0) { // 玩家技能
				player.AddSkill(idSkill);
				//GameScreen.role.addSkill(skill);
			} else if (btAction == 1) {
				//NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
				//				if (pet) {
				//					pet->AddSkill(idSkill);
				//				}
				PetMgrObj.AddSkill(player.m_id, idPet, idSkill);
			}
		} else if (btAction == 3 || btAction == 4) {
			int idNextLevelSkill = data.ReadInt();
			int lqz = data.ReadShort();
			DianhuaUILayer::RefreshList(btAction, idNextLevelSkill, lqz);
		} else if (btAction == 5) { // 更新技能熟练度
			int idSk = data.ReadInt();
			int curSp = data.ReadShort();
			BattleSkill* sk = this->GetBattleSkill(idSk);
			if (sk) {
				sk->setCurSp(curSp);
			}
		}
		else if (btAction == 6) { // 更新技能槽
			int idSk = data.ReadInt();
			int btSlot = data.ReadShort();
			BattleSkill* sk = this->GetBattleSkill(idSk);
			if (sk) {
				sk->SetSlot(btSlot);
			}
		}
	}
	
	LearnSkillUILayer::RefreshSkillList();
	PetSkillCompose::refresh();
}

void BattleMgr::closeUI()
{
	NDDirector* director = NDDirector::DefaultDirector();
	NDScene* scene = director->GetRunningScene();
	while (scene) {
		if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			((GameScene*)scene)->OnBattleBegin();
			break;
		} else {
			director->PopScene();
			scene = director->GetRunningScene();
		}
	}
}

void BattleMgr::showBattleScene()
{
	if(m_battle)
	{
		m_battle->setBattleMap(battleMapId, battleX*MAP_UNITSIZE,battleY*MAP_UNITSIZE);
		NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		mapLayer->GetParent()->AddChild(m_battle);
		// 进入战斗,地图逻辑处理
		NDMapMgrObj.BattleStart();
		ScriptGlobalEvent::OnEvent(GE_BATTLE_BEGIN);
		//++Guosen 2012.7.6
		NDScene*  pGameScene = NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
		if ( pGameScene )
		{//此时隐藏下述三个UI
			NDUILayer * pLayer	= (NDUILayer *)pGameScene->GetChild(2010);//AffixNormalBoss//副本界面
			if ( pLayer )
				pLayer->SetVisible( false );
			pLayer	= (NDUILayer *)pGameScene->GetChild(2015);//Arena//竞技场界面
			if ( pLayer )
				pLayer->SetVisible( false );
			pLayer	= (NDUILayer *)pGameScene->GetChild(2035);//DynMapGuide//查看攻略界面
			if ( pLayer )
				pLayer->SetVisible( false );
		}
	}
}

void BattleMgr::SetBattleOver(void)
{
        if(m_battle != NULL)
        {
            m_battle->SetBattleOver();
        }
}
void BattleMgr::restartLastBattle()
{
	if(m_battle&&m_battle->GetParent()!=NULL) {
		m_battle->RemoveFromParent(true);
		m_battle=NULL;
	}
	if(battleMapId==0){
		return;
	}
	if (!m_battle)
	{
        int battleType= this->lastBattleType;
        if (battleType==BATTLE_TYPE_MONSTER) 
        {
             m_battle = new Battle(BATTLE_TYPE_MONSTER_PLAYBACK);
        }
        else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS)
		{
            m_battle = new Battle(BATTLE_TYPE_SPORTS_PLAYBACK);
        }
        
		m_battle->Initialization(BATTLE_STAGE_START);
		m_battle->StartEraseOutEffect();
		m_battle->setTeamAmout(lastBattleTeamCount);
	}

	for (VEC_FIGHTER_IT it = m_vFighter.begin(); it != m_vFighter.end(); it++)
	{
		NDLog(@"add_fighter");
		Fighter* fighter = *it;
		
		fighter->reStoreAttr();
		fighter->setBattle(m_battle);
//		fighter->LoadMonster(idlookface, level, strName);
		m_battle->AddFighter(fighter);
	}
	

	ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0);
	NDDirector* director = NDDirector::DefaultDirector();
	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);//设置播放切屏遮罩动画
	//mapLayer->SetBattleBackground(true);
	RestoreActionList();
	CGSize winSize = director->GetWinSize();
	m_battle->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	
	m_battle->InitEudemonOpt();
	m_battle->sortFighterList();
	m_battle->InitSpeedBar();
	//m_battle->SetVisible(false);
	director->EnableDispatchEvent(false);
	m_battle->RestartFight();
}

void BattleMgr::processBattleStart(NDEngine::NDTransData& bao)
{
	
	CloseProgressBar;
    ScriptMgrObj.excuteLuaFunc("PlayBattleMusic", "Music");
    
	//备份进入战斗前一场景的非副本地图数据ID及窗口位置//++Guosen 2012.7.5
	NDMapLayer * pMapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	if( pMapLayer && ( pMapLayer->GetMapIndex() < 3 ) )//3及以上是战斗时的背景
	{
		this->m_iLastSceneMapDocID	= pMapLayer->GetMapIndex();
		this->m_iLastSceneScreenX	= pMapLayer->GetScreenCenter().x;
		this->m_iLastSceneScreenY	= pMapLayer->GetScreenCenter().y;
	}
	
	Byte btPackageType = 0;
	Byte btBattleType = 0;
	Byte btTeamAmout=0;
	int map_id=0;
	unsigned short posX=0;
	unsigned short posY=0;
	
	bao >> btPackageType >> btBattleType>>btTeamAmout >>map_id>>posX>>posY;//>> btAction;

	bool bBattleStart = (btPackageType & 2>0);
	this->lastBattleType=btBattleType;

	if (bBattleStart && m_battle && m_battle->GetParent() != NULL) {
		quitBattle(false);
	}
	
	// add by jhzheng
	if (bBattleStart) {
		// 先关闭正在操作的ui界面
		CloseProgressBar;
		//		this->closeUI();
	}
	
	NDMapMgr& mapMgr = NDMapMgrObj;

	if (!m_battle)
	{
		m_battle = new Battle(btBattleType);
		m_battle->Initialization(BATTLE_STAGE_START);
		m_battle->StartEraseOutEffect();

	}
	
	if(btPackageType&1>0){
		m_battle->setTeamAmout(btTeamAmout);
		this->lastBattleTeamCount=btTeamAmout;
		for (VEC_FIGHTER_IT it = m_vFighter.begin(); it != m_vFighter.end(); it++)
		{
			SAFE_DELETE(*it);
		}
		m_vFighter.clear();
		ReleaseActionList();
	}
	
	Byte btAmout = 0;
	
	bao >> btAmout;
	
	m_battle->SetTurn(0);
	
	
	for (Byte i = 0; i < btAmout; i++)
	{
		int idObj = 0;
		int idType = 0; // 类型
		int idlookface = 0;
		ushort level = 0;
		Byte nFighterType = 0; // 玩家，怪物,幻兽
		int nLife = 0;
		int nLifeMax = 0;
		int nMana = 0;
		int nManaMax = 0;
		Byte btGroup=0;
		Byte btBattleTeam=0;
		Byte btStations=0;
		Byte btEquipAmount=0;
		int weapon_id=0;
		int model_id=0;
		int skillID=0;
		int atk_type=0;
        
        Byte nQuality=0;
		
		//int idPet = 0;
		idObj=bao.ReadInt();
		
		bao>>nFighterType;
		idType=bao.ReadInt();
		idlookface=bao.ReadInt();
		skillID=bao.ReadInt();
		level=bao.ReadShort();
		nLife=bao.ReadInt();
		nLifeMax=bao.ReadInt();
		nMana=bao.ReadInt();
		nManaMax=bao.ReadInt();
		bao>> btGroup>>btBattleTeam>>btStations>>btEquipAmount>>nQuality;
        
        
		std::string strName;
		strName=bao.ReadUnicodeString();
		//for(Byte i=0;i<btEquipAmount;i++){			// 人物装备
		//	int equipType=bao.ReadInt();
		//	if (equipType/100000==12)//武器
		//	{
		//		weapon_id=ScriptDBObj.GetN("itemtype", equipType, DB_ITEMTYPE_LOOKFACE);
		//	}else if(equipType/100000==15)
		//	{
		//		model_id=ScriptDBObj.GetN("itemtype",equipType,DB_ITEMTYPE_LOOKFACE);
		//	}
        //
		//}
		
		
		if (nFighterType ==	FIGHTER_TYPE_PET)
		{
			atk_type = ScriptDBObj.GetN( "pet_config", idType, DB_PET_CONFIG_ATK_TYPE );
		}else if (nFighterType == FIGHTER_TYPE_MONSTER)
		{
			atk_type = ScriptDBObj.GetN( "monstertype", idType, DB_MONSTERTYPE_ATK_TYPE );
		}
		
		
		FIGHTER_INFO info;
		info.level			= level;
		info.idObj			= idObj;
		info.idType			= idType;
		info.idlookface		= idlookface;
		info.skillId		= skillID;
		info.fighterType	= FIGHTER_TYPE(nFighterType);
		info.group			= BATTLE_GROUP(btGroup);
		info.original_life	= nLife;
		info.nLife			= nLife;
		info.nLifeMax		= nLifeMax;
		info.original_mana	= nMana;
		info.nMana			= nMana;
		info.nManaMax		= nManaMax;
		info.btBattleTeam	= btBattleTeam;
		info.btStations		= btStations;
		info.atk_type		= atk_type;
        info.nQuality       = nQuality;
		NDLog(@"id:%d,type:%d,fighterType,%d,group:%d,team:%d,pos:%d,life:%d", idObj,idType,nFighterType,btGroup,btBattleTeam,btStations,nLife);
		Fighter* fighter = new Fighter(info);
		fighter->setBattle(m_battle);
		
		if (model_id!=0)
		{
			idlookface=idlookface/100000*100000+model_id*100+idlookface%100;
		}
//		if (nFighterType == FIGHTER_TYPE_PET) {
			//				if (idObj == role.m_id) { // 主控角色
			// 停止走路
			fighter->LoadMonster(idlookface, level, strName);
			//				} else { // 周围玩家
			//					NDManualRole* player = mapMgr.GetManualRole(idObj);
			//					if (player) {
			//						CGPoint pos = CGPointZero;
			//						if (player->GetLastPointOfPath(pos))
			//						{
			//							player->SetPositionEx(pos);
			//							player->stopMoving(false, false);
			//						}
			//						else
			//						{
			//							player->stopMoving(true, false);
			//						}
			//						
			//						fighter->SetRole(player);
			//					}
			//				}
//		}else if (nFighterType == FIGHTER_TYPE_MONSTER) { // 右边的怪物
//			//				int lookface = 0;
//			//				bao >> lookface;
//			//				string name = bao.ReadUnicodeString();
//			fighter->LoadMonster(idlookface, level, strName);
//		}
		fighter->GetRole()->life=nLife;
		fighter->GetRole()->maxLife=nLifeMax;
		fighter->GetRole()->mana=nMana;
		fighter->GetRole()->maxMana=nManaMax;
		if(weapon_id!=0)
		{
			fighter->GetRole()->SetWeaponImage(weapon_id);
		}
		// 服务端下发的状态
		//			for (int j = 0; j < statusNum; j++) {
		//				int idStatus = bao.ReadInt();
		//				int idEffect = bao.ReadInt();
		//				Byte num = bao.ReadByte();
		//				string name = bao.ReadUnicodeString();
		//				string des = bao.ReadUnicodeString();
		//				fighter->addAStatus(new FighterStatus(idStatus, idEffect, num, name, des));
		//			}
		m_vFighter.push_back(fighter);
		m_battle->AddFighter(fighter);
		
		//			// 死亡处理
		//			if (info.nLife == 0)
		//			{
		//				fighter->setDieOK(true);
		//				dieAction(*fighter);
		//			}
	}
	
	if (bBattleStart) {
		/* comment by jhzheng
		 // 关闭正在操作的ui界面
		 CloseProgressBar;
		 this->closeUI();
		 */

		this->battleMapId=map_id;
		this->battleX=posX;
		this->battleY=posY;
		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0);//隐藏UI（不销毁）,//竞技场界面或副本界面及攻略界面要在装载好地图后再隐藏
		//++Guosen 2012.7.6
		NDScene*  pGameScene = NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
		if ( pGameScene )
		{//此时不隐藏掉下述三个UI
			NDUILayer * pLayer	= (NDUILayer *)pGameScene->GetChild(2010);//AffixNormalBoss//副本界面
			if ( pLayer )
				pLayer->SetVisible( true );
			pLayer	= (NDUILayer *)pGameScene->GetChild(2015);//Arena//竞技场界面
			if ( pLayer )
				pLayer->SetVisible( true );
			pLayer	= (NDUILayer *)pGameScene->GetChild(2035);//DynMapGuide//查看攻略界面
			if ( pLayer )
				pLayer->SetVisible( true );
		}
		
		if(btBattleType!=BATTLE_TYPE_SPORTS)
		{//非竞技场战斗销毁其他窗口？
			ScriptMgrObj.excuteLuaFunc("CloseMainUI", "",0);
		}
		NDDirector* director = NDDirector::DefaultDirector();
		NDMapLayer* mapLayer = mapMgr.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		
		//mapLayer->SetBattleBackground(true);
		
		CGSize winSize = director->GetWinSize();
		m_battle->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));


		mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);
        mapLayer->SetBattleType(btBattleType);
        
		m_battle->InitEudemonOpt();
		m_battle->sortFighterList();
		m_battle->InitSpeedBar();
		//m_battle->SetVisible(false);
		director->EnableDispatchEvent(false);

		

	}
	//}
}

void BattleMgr::processControlPoint(NDEngine::NDTransData& bao)
{
	Fighter* user = m_battle->GetMainUser();
	if (user)
	{
		bao >> user->m_atkPoint >> user->m_defPoint >> user->m_disPoint;
	}
}

void BattleMgr::processBattleEffect(NDEngine::NDTransData& bao)
{
	Byte btPackFlag=0; bao>>btPackFlag;
	
	Byte btEffectNum = 0; bao >> btEffectNum;
	if((btPackFlag&1)>0){
		cmdBefore = NULL;
	}
	
    int idSkillActor = 0;
    int idSkillTarget = 0;
	for (int i = 0; i < btEffectNum; i++) {
		BATTLE_EFFECT_TYPE btEffectType = BATTLE_EFFECT_TYPE(bao.ReadShort());
		int idActor = bao.ReadInt();
		long data=bao.ReadLong();
		
		int lookface;
        
		Command* cmd = NULL;
        if(btEffectType != BATTLE_EFFECT_TYPE_SKILL_EFFECT)
        {
            cmd = new Command();
            cmd->btEffectType = btEffectType;
            cmd->idActor = idActor;
        }

		switch(btEffectType){
			case BATTLE_EFFECT_TYPE_ATK:
				//cmd->idTarget=(int) data;
				//cmdBefore=cmd;
				//NDLog(@"%d ATK %d", idActor,cmd->idTarget);
				{
					Command* pCmd = new Command();
					pCmd->btEffectType	= BATTLE_EFFECT_TYPE_PLAY_ANIMATION;
					pCmd->idActor		= idActor;
					pCmd->idTarget		= 48;	//播放“反击”文字动画
					if ( cmdBefore )
					{
						m_battle->AddCommand(pCmd);
					}
					else
					{
						cmdBefore->cmdNext = pCmd;
						cmdBefore = pCmd;
					}
					cmd->idTarget		= (int)data;
					cmdBefore			= cmd;
				}
				break;
			case BATTLE_EFFECT_TYPE_SKILL:
				NDLog(@"%d SKILL ", idActor);
				cmd->skill=new BattleSkill();
				cmd->skill->setName(ScriptDBObj.GetS("skill_config",(unsigned int) data, DB_SKILL_CONFIG_NAME));
                if(data == 999999)//特指普通攻击
                {
                	//
                    Fighter* pFighter = GetBattle()->GetFighter(idActor);
                	int nAtkType = 0;
					if ( pFighter->m_info.fighterType == FIGHTER_TYPE_PET )
					{
        			    nAtkType = ScriptDBObj.GetN( "pet_config", pFighter->m_info.idType, DB_PET_CONFIG_ATK_TYPE );
					}
        			else if( pFighter->m_info.fighterType == FIGHTER_TYPE_MONSTER )
        			{
        			    nAtkType = ScriptDBObj.GetN( "monstertype", pFighter->m_info.idType, DB_MONSTERTYPE_ATK_TYPE );
        			}
        			
        			if ( nAtkType == FIGHTER_ATK_TYPE_PHY )
        			{//物理近攻
                        cmd->skill->setAtkType(SKILL_ATK_TYPE_NEAR);
        			}
        			else
        			{//物理远攻，法术远攻
                        cmd->skill->setAtkType(SKILL_ATK_TYPE_REMOTE);
        			}
                }
                else
                {
                    cmd->skill->setAtkType(SKILL_ATK_TYPE_REMOTE);//技能全部为远战
                    cmd->skill->setSelfEffect(ScriptDBObj.GetN("skill_config",(unsigned int) data, DB_SKILL_CONFIG_LOOKFACE_ID));
                    cmd->skill->setTargetEffect(ScriptDBObj.GetN("skill_config",(unsigned int) data, DB_SKILL_CONFIG_LOOKFACE_TARGET_ID));
                }
                cmd->skill->SetActId(MANUELROLE_ATTACK);
				
				cmd->skill->setId((unsigned int) data);
				cmdBefore=cmd;
				break;
			case BATTLE_EFFECT_TYPE_SKILL_TARGET:
                cmd->idTarget = (int) data;
				NDLog(@"SKILL atk:%d, target:%d", cmd->idActor, cmd->idTarget);
				break;
				
			case BATTLE_EFFECT_TYPE_SKILL_EFFECT_TARGET:
                cmd->idTarget = (int) data;
				NDLog(@"SKILL atk:%d, target:%d", cmd->idActor, cmd->idTarget);
                idSkillActor = idActor;//记住技能攻击目标
				idSkillTarget = (int) data;
				break;
			case BATTLE_EFFECT_TYPE_SKILL_EFFECT:
                if(idSkillActor && idSkillTarget)
                {
                    //idAction,data值为skill_result_cfg.id的组合，格式为AABBCC，各两位，最多三个表现
                    //6个表现前三个是攻击方，后三个是防守方
                    int idEffect[6];
                    idEffect[0] = idActor%100;
                    idEffect[1] = idActor/100%100;
                    idEffect[2] = idActor/10000;
                    idEffect[3] = data%100;
                    idEffect[4] = data/100%100;
                    idEffect[5] = data/10000;
                    for(int i = 0; i < 6; ++i)
                    {
                        if(idEffect[i] != 0)
                        {
                            cmd = new Command();
                            cmd->btEffectType = BATTLE_EFFECT_TYPE_SKILL_EFFECT;
                            cmd->idActor = (i<3) ? idSkillActor : idSkillTarget;
                            int lookface = ScriptDBObj.GetN("skill_result_cfg",(unsigned int) idEffect[i], DB_SKILL_RESULT_CFG_LOOKFACE);
                            cmd->idTarget = lookface;
                            NDLog(@"SKILL effect id:%d effect:%d", cmd->idActor, cmd->idTarget);
                            if(cmdBefore!=NULL && cmd){
                                cmdBefore->cmdNext = cmd;
                                cmdBefore = cmd;
                            }
                            cmd = NULL;//赋空，以防后面再加进去
                        }
                    }
                }
                else
                {
                    idSkillActor = 0;
                    idSkillTarget = 0;
                }
				break;
			case BATTLE_EFFECT_TYPE_LIFE:
				NDLog(@"%d HURT", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_MANA: // 气势
				NDLog(@"%d MANA", idActor);
				cmd->nMpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_DODGE:  // 闪避
				NDLog(@"%d DODGE", idActor);
				break;
			case BATTLE_EFFECT_TYPE_DRITICAL: // 暴击
				NDLog(@"%d DRITICAL", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_BLOCK:  // 格挡
				NDLog(@"%d BLOCK", idActor);
				break;
			case BATTLE_EFFECT_TYPE_COMBO:  // 连击
				NDLog(@"%d COMBO", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_STATUS_ADD: // 加状态，
				NDLog(@"%d STATUS_ADD", idActor);
				cmd->idTarget	= (int)data;// skill_result_cfg 的 ID
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LOST: // 取消状态
				NDLog(@"%d STATUS_CANCEL", idActor);
				cmd->idTarget	= (int)data;// skill_result_cfg 的 ID
				break;
			case BATTLE_EFFECT_TYPE_CTRL:
				break;
			case BATTLE_EFFECT_TYPE_ESCORTING://护驾/援护
				NDLog(@"%d ESCORTING", idActor);
				break;
			case BATTLE_EFFECT_TYPE_COOPRATION_HIT://合击
				NDLog(@"%d COOPRATION_HIT", idActor);
				break;
			case BATTLE_EFFECT_TYPE_CHANGE_POSTION://移位
				NDLog(@"%d CHANGE_POSTION", idActor);
				cmd->idTarget	= (int)data;//pos
				//cmdBefore = NULL;
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LIFE: // 状态去血
				NDLog(@"%d STATUS_LIFE", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_STATUS_MANA: // 状态去气
				NDLog(@"%d STATUS_MANA", idActor);
				cmd->nMpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_RESIST: // 免疫
				NDLog(@"%d STATUS_RESIST", idActor);
				break;
			case EFFECT_TYPE_TURN_END:   // 回合结束
				NDLog(@"%d TURN_END", idActor);
				cmdBefore=NULL;
				break;
			case EFFECT_TYPE_BATTLE_BEGIN:  // 战斗开始
				NDLog(@"%d BEGIN BATTLE", idActor);
				m_CurrentTeamId=idActor;
				cmd->idTarget	= (int)data;
				break;
			case EFFECT_TYPE_BATTLE_END:   // 战斗结束
				NDLog(@"%d END BATTLE", idActor);
				cmd->idActor	= m_CurrentTeamId;
				cmdBefore = NULL;
				break;
			case BATTLE_EFFECT_TYPE_DEAD:
				NDLog(@"%d DIE", idActor);
				break;
			case BATTLE_EFFECT_TYPE_PLAY_ANIMATION: // 对象身上播放指定动画
				NDLog(@"%d PLAY_ANIMATION", idActor);
				cmd->idTarget = (int) data;
				//cmdBefore = cmd;
				break;
			default:
				NDLog(@"%d NONE", idActor);
				break;
		}
        
        
		if( btEffectType == BATTLE_EFFECT_TYPE_ATK 
			|| btEffectType == BATTLE_EFFECT_TYPE_SKILL 
			|| btEffectType == EFFECT_TYPE_BATTLE_BEGIN 
			|| btEffectType == EFFECT_TYPE_BATTLE_END 
			|| btEffectType == BATTLE_EFFECT_TYPE_STATUS_LIFE 
			|| btEffectType == BATTLE_EFFECT_TYPE_STATUS_MANA 
			//|| btEffectType == BATTLE_EFFECT_TYPE_STATUS_ADD 
			//|| btEffectType == BATTLE_EFFECT_TYPE_STATUS_LOST 
			//|| btEffectType == BATTLE_EFFECT_TYPE_ESCORTING 
			//|| btEffectType == BATTLE_EFFECT_TYPE_COOPRATION_HIT 
			//|| btEffectType == BATTLE_EFFECT_TYPE_CHANGE_POSTION 
			//|| btEffectType == BATTLE_EFFECT_TYPE_PLAY_ANIMATION 
			|| cmdBefore == NULL
			&& cmd ){
			m_battle->AddCommand(cmd);
		}else if(cmdBefore != NULL && cmd){
			cmdBefore->cmdNext = cmd;
			cmdBefore = cmd;
		}
	}
	
	if ((btPackFlag&2)>0) {
        BOOL bIsDramaPlaying = ScriptMgrObj.excuteLuaFunc("IfDramaPlaying","Drama",0);
        if (bIsDramaPlaying == true){
            //m_battle->StartFight();
            return;
        }
        else{
            m_battle->StartFight();
        }
        
		
	}
}

void BattleMgr::BattleContinue()
{
    m_battle->StartFight();
}




string getStrItemsFromIntArray(vector<OBJID>& items) {
	stringstream ss;
	ItemMgr& itemMgr = ItemMgrObj;
	while (items.size() > 0) {
		OBJID idItemType = items.at(0);
		int count = 0;
		NDItemType* pItem = itemMgr.QueryItemType(idItemType);
		if (NULL == pItem) {
			NDLog(@"未找到物品类型：[%d]", idItemType);
			items.erase(items.begin());
			continue;
		}
		
		ss << pItem->m_name;
		
		for(vector<OBJID>::iterator it = items.begin(); it != items.end(); )
		{
			if(*it == idItemType) {
				count++;
				it = items.erase(it);
			} else {
				it++;
			}
		}
		
		ss << " * " << count;
		
		if (items.size() > 0) {
			ss << "\n";
		}
	}
	
	return ss.str();
}

void BattleMgr::processBattleEnd(NDEngine::NDTransData& bao)
{
	//NDMapMgr& mapMgr = NDMapMgrObj;
	Byte btBattleType = 0;
	int dwMoney = 0;
	int dwEMoney = 0;
	int dwExp = 0;
	int dwRepute = 0;
	int dwSoph = 0;   //将魂
	Byte dwSoldierNum = 0;     //出战的人数
	Byte btResult = 0;
	int dwHurt = 0;
	Byte btItemAmount = 0;    //奖励物品的种类
    pair<int, int> pSoldExp;

   bao >>btBattleType>> dwMoney >> dwEMoney >> dwExp
	>> dwRepute>>dwSoph >> btResult >>dwHurt
	>> btItemAmount >>dwSoldierNum;

	battleReward=new BattleReward();
	battleReward->money=dwMoney;
	battleReward->emoney=dwEMoney;
	battleReward->exp=dwExp;
	battleReward->repute=dwRepute;
    battleReward->soph = dwSoph;
	battleReward->battleResult=btResult;

 	vector<OBJID> vItems;
	if (btItemAmount > 0) 
    {
		for (int i = 0; i < btItemAmount; i++) 
        {
			OBJID idItemType = bao.ReadInt();
            OBJID idItemCount = bao.ReadInt();
			NDLog(@"receive_battle_rewardItem:%d",idItemType);
			battleReward->addItem(idItemType, idItemCount);
		}
	}   

    //this->battleReward->mSoldExp.clear();
    for(int i = 0; i < dwSoldierNum; i++)
    {
        bao >> battleReward->iPetId[i] >> battleReward->iPetGainExp[i];
        //this->battleReward->mSoldExp[pSoldExp.first] = pSoldExp.second;
    }

	if(m_battle) 
    {
		m_battle->setServerBattleResult(btResult);
	}
}
/************************************************************************************************************
 Function:         ShowBattleWinResult
 Description:    处理显示战斗胜利的结果 （包括副本战斗以及竞技场战斗）
 Input:               nBattleType 战斗类型
 Output:     
 other:
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 version:  1. add by tangziqin  2012.8.17   增加函数头注释      
 2.
 ************************************************************************************************************/
void BattleMgr::ShowBattleWinResult(int nBattleType)
{
    //副本战斗胜利 显示 DynMapSuccess.ini 页面
    if (BATTLE_TYPE_MONSTER == nBattleType)
    {
        //判断是否触发剧情
        if( true == ScriptMgrObj.excuteLuaFunc("GlobalEventBattleEnd", "Drama", BATTLE_COMPLETE_WIN)) 
        {
            if (m_startDramaTimer== NULL)
            {
                m_startDramaTimer = new NDTimer;
            }
            m_startDramaTimer->SetTimer(this, QUIT_DRAMA_TIMER_TAG, 1.0f);
        }
        else 
        {
            //显示 DynMapSuccess.ini 页面
            loadRewardUI();
        }
    }
    
    //竞技场战斗胜利  显示 SM_FIGHT_RESULT.ini 页面
    else if (BATTLE_TYPE_SPORTS == nBattleType ||  BATTLE_TYPE_BOSS == nBattleType)
    {
        NDLog(@"result,sports");
        ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
        ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI", BATTLE_COMPLETE_WIN, battleReward->money, battleReward->repute);
        //结果页面显示之后释放奖励物品
        if (battleReward != NULL)
        {
            SAFE_DELETE (battleReward);
        }      
    }
}

/************************************************************************************************************
 Function:         ShowBattleLoseResult
 Description:    处理显示战斗失败的结果 （包括副本战斗以及竞技场战斗）
 Input:               nBattleType 战斗类型
 Output:     
 other:
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 version:  1. add by tangziqin  2012.8.17   增加函数头注释      
 2.
 ************************************************************************************************************/
void BattleMgr::ShowBattleLoseResult(int nBattleType)
{
    //副本战斗失败 显示  BattleFailUI.ini 页面
    if (BATTLE_TYPE_MONSTER == nBattleType)
    {
        ScriptMgrObj.excuteLuaFunc("LoadUI", "BattleFailUI",0);
    }
    //竞技场战斗失败 显示    SM_FIGHT_RESULT.ini 页面
    else if (BATTLE_TYPE_SPORTS == nBattleType ||  BATTLE_TYPE_BOSS == nBattleType)
    {
        ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
        ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI", BATTLE_COMPLETE_LOSE, battleReward->money, battleReward->repute);
    }
    
    //结果页面显示之后释放奖励物品
    if (battleReward != NULL)
    {
        SAFE_DELETE (battleReward);
    }
}
/************************************************************************************************************
 Function:         ShowReplayWinResult
 Description:    处理显示战斗胜利回放的结果（包括副本战斗以及竞技场战斗）
 Input:               nBattleType 战斗类型
 Output:     
 other:
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 version:  1. add by tangziqin  2012.8.17   增加函数头注释      
 2.
 ************************************************************************************************************/
void BattleMgr::ShowReplayWinResult(int nBattleType)
{
    //竞技场成功回放 显示  SM_FIGHT_RESULT.ini 页面
    if (BATTLE_TYPE_SPORTS_PLAYBACK == nBattleType)
    {
        ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
        NDLog(@"money:%d--repute:%d",prebattleReward->money,prebattleReward->repute);
        ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI", BATTLE_COMPLETE_WIN, prebattleReward->money, prebattleReward->repute);
    }
    
    //副本战斗成功回放 显示  DynMapSuccess.ini
    else if (BATTLE_TYPE_MONSTER_PLAYBACK == nBattleType)
    {  
        NDLog(@"type:%d",m_battle->GetBattleType());
        ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
       // ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",prebattleReward->exp);
        ScriptMgrObj.excuteLuaFunc("addSophMoney", "MonsterRewardUI", prebattleReward->soph, prebattleReward->money);	
        
        for(int i=0;i<5;i++)
        {
            if(prebattleReward->itemtype[i]!=0)
            {
                NDLog(@"addRewardItem:%d",prebattleReward->itemtype[i]);
                ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI", i+1, prebattleReward->itemtype[i], prebattleReward->item_amount[i]);
                
            }
        }	
        
        for(int i=0;i<5;i++)
        {
            if(prebattleReward->iPetId[i] !=0)
            {
                NDLog(@"iPetId :%d;  iPetGainExp : %d", prebattleReward->itemtype[i], prebattleReward->iPetGainExp[i]);
                ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI", prebattleReward->iPetId[i], prebattleReward->iPetGainExp[i]);
            }
        }
        
        ScriptMgrObj.excuteLuaFunc("Refresh", "MonsterRewardUI");	
    }
}

/************************************************************************************************************
 Function:         ShowReplayLoseResult
 Description:    处理显示战斗失败回放的结果 （包括副本战斗以及竞技场战斗）
 Input:               nBattleType 战斗类型
 Output:     
 other:
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 version:  1. add by tangziqin  2012.8.17   增加函数头注释      
 2.
 ************************************************************************************************************/
void BattleMgr::ShowReplayLoseResult(int nBattleType)
{
    //竞技场挑战失败回放 显示  SM_FIGHT_RESULT.ini 页面
    if (BATTLE_TYPE_SPORTS_PLAYBACK == nBattleType)
    {
        ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
        ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI", BATTLE_COMPLETE_LOSE, prebattleReward->money, prebattleReward->repute);
    }
    //副本战斗失败回放 显示  BattleFailUI.ini
    else if (BATTLE_TYPE_MONSTER_PLAYBACK == nBattleType)
    {  
        ScriptMgrObj.excuteLuaFunc("LoadUI", "BattleFailUI",0);
    }
}

/************************************************************************************************************
 Function:         showBattleResult
 Description:    显示战斗结果
 Input:               
 Output:     
 other:
 －－－－－－－－－－－－－－－－修改说明－－－－－－－－－－－－－－－－－－－－－－－－
 version:  1. add by tangziqin  2012.8.17   增加函数头注释      
 2.
 ************************************************************************************************************/
void BattleMgr::showBattleResult()
{
	int battleType= m_battle->GetBattleType();
	BATTLE_COMPLETE battle_result = BATTLE_COMPLETE_LOSE;
    
    //关闭速战速决按钮
    ScriptMgrObj.excuteLuaFunc("CloseUI", "BattleMapCtrl");
    
    //为了回放界面显示奖励的物品，特记录奖励的东西
	if (battleReward != NULL)
	{
        if(prebattleReward == NULL)
        {
            prebattleReward = new BattleReward();
            if(prebattleReward == NULL)
            {
                SAFE_DELETE (battleReward);
                return;
            }     
        }
        *prebattleReward = *battleReward;
    }
    
    
	//是否有奖励，回放没有奖励，比赛有奖励
   if (battleReward != NULL)
   {
        battle_result = BATTLE_COMPLETE(battleReward->battleResult);
        
		if (battle_result == BATTLE_COMPLETE_WIN)
		{
             //处理显示战斗胜利的结果
            ShowBattleWinResult(battleType);
		}
        else if(battle_result == BATTLE_COMPLETE_LOSE)
		{
            //处理显示战斗失败的结果
            ShowBattleLoseResult(battleType);
        }
	}
    else 
    {
        //如果是竞技场中的 查看功能 或者副本中的攻略功能是没有奖励的                                                
        if ((BATTLE_TYPE_SPORTS == battleType) || (BATTLE_TYPE_MONSTER == battleType) || (prebattleReward == NULL))
        {
            //显示 SM_FIGHT_REPLAY.ini 页面
            SAFE_DELETE (prebattleReward);
            ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaFightReplayUI",0);
        }
        else  //副本战斗以及竞技场挑战回放功能
        {   
            if (prebattleReward == NULL)
            {
                return;
            }
            
            battle_result = BATTLE_COMPLETE(prebattleReward->battleResult);
            
            if(battle_result == BATTLE_COMPLETE_WIN)
            {
                //处理显示战斗胜利回放的结果
                ShowReplayWinResult(battleType);
            }
            else if(battle_result == BATTLE_COMPLETE_LOSE)
            {
                 //处理显示战斗失败回放的结果 
                ShowReplayLoseResult(battleType);
            }
        }
    }
}

void BattleMgr::quitBattle(bool bEraseOut/*=true*/)
{
	if (m_battle) {
		if (bEraseOut) 
		{
			if (!m_quitTimer) 
			{
				m_quitTimer = new NDTimer;
				m_quitTimer->SetTimer(this, QUIT_BATTLE_TIMER_TAG, 0.1f);
				m_battle->StartEraseInEffect();
			}
			return;
		}
		
		if (m_quitTimer) 
		{
			m_quitTimer->KillTimer(this, QUIT_BATTLE_TIMER_TAG);
			delete m_quitTimer;
			m_quitTimer = NULL;
		}
		
		BATTLE_COMPLETE battle_result = BATTLE_COMPLETE(m_battle->getServerBattleResult());
		int battleType= m_battle->GetBattleType();
		m_battle->RemoveFromParent(true);
        //++Guosen 2012.7.2
        NDScene*  pGameScene = NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
        if ( pGameScene )
        {
			NDUILayer * pLayerAffixNormalBoss = (NDUILayer *)pGameScene->GetChild(2010);//AffixNormalBoss//副本界面
			NDUILayer * pLayerArena = (NDUILayer *)pGameScene->GetChild(2015);//Arena//竞技场界面
			NDUILayer * pLayerDynMapGuide = (NDUILayer *)pGameScene->GetChild(2035);//DynMapGuide//查看攻略界面
            if ( pLayerAffixNormalBoss || pLayerArena || pLayerDynMapGuide )
            {
                ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",1);
                //还原地图--Guosen 2012.7.5
				NDMapLayer * pMapLayer = NDMapMgrObj.getMapLayerOfScene(pGameScene);//(NDDirector::DefaultDirector()->GetRunningScene());
				if ( pMapLayer && m_iLastSceneMapDocID )
				{//
					pMapLayer->SetBattleBackground(false);
					pMapLayer->replaceMapData( m_iLastSceneMapDocID, m_iLastSceneScreenX, m_iLastSceneScreenY );
					NDMapMgrObj.AddSwitch();
					m_iLastSceneMapDocID	= 0;
					m_iLastSceneScreenX		= 0;
					m_iLastSceneScreenY		= 0;
				} 
            }
        }
		

//		NDLog(@"result:%d",battle_result);
//		if(battleReward&&battle_result == BATTLE_COMPLETE_WIN)
//		{
//			if(battleType==BATTLE_TYPE_MONSTER)
//			{
//				NDLog(@"type:%d",m_battle->GetBattleType());
//				ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
//				ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",battleReward->exp);
//
//				for(int i=0;i<5;i++)
//				{
//					if(battleReward->itemtype[i]!=0)
//					{
//						NDLog(@"addRewardItem:%d",battleReward->itemtype[i]);
//						ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI",i+1,battleReward->itemtype[i],battleReward->item_amount[i]);
//				
//					}
//				}
//			}else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS){
//				NDLog(@"result,sports");
//				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
//				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
//			}
//		}else if(battle_result == BATTLE_COMPLETE_LOSE)
//		{
//			if(battleType==BATTLE_TYPE_MONSTER)
//			{
//				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
//				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
//			}else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS){
//				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
//				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
//			}
//		}
		m_battle = NULL;
		NDPlayer::defaultHero().SetLocked(false);

		
		if (NDMapMgrObj.isMonsterClear()&&battleType==BATTLE_TYPE_MONSTER){
			NDLog(@"dynmap cleared");
		//	ScriptMgrObj.excuteLuaFunc("OnBattleFinish","AffixBossFunc",NDMapMgrObj.GetMotherMapID(), 1);//--Guosen 2012.7.4 不再显示副本评价
		}
		
		NDPlayer::defaultHero().SetLocked(false);
//		GameScene* gs = (GameScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
//		if (gs) {
//			gs->SetUIShow(false);
//		}
	}
}

void BattleMgr::OnDramaFinish()
{
	NDLog(@"drama call back dynmap cleared");
	//ScriptMgrObj.excuteLuaFunc("OnBattleFinish","AffixBossFunc",NDMapMgrObj.GetMotherMapID(), 1);//--Guosen 2012.7.4 不再显示副本评价
}

/*
 *  BattleMgr.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "BattleMgr.h"
#include "NDPlayer.h"
#include "NDTransData.h"
#include "Battle.h"
#include "NDUISynLayer.h"

#include "NDMapMgr.h"
#include "NDDirector.h"
#include "BattleUtil.h"
#include <sstream>
//#include "ItemMgr.h"
//#include "LearnSkillUILayer.h"
//#include "DianhuaUILayer.h"
#include "GameScene.h"
//#include "PetSkillCompose.h"
#include "CPet.h"
//#include "PlayerInfoScene.h"
#include "ScriptDataBase.h"
#include "NDConstant.h"

#define QUIT_BATTLE_TIMER_TAG (13621)

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
	battleMapId = 0;
	battleX=0;
	battleY=0;
	lastBattleTeamCount=0;
}

BattleMgr::~BattleMgr()
{
	this->ReleaseAllBattleSkill();
	if(battleReward)
	{
		CC_SAFE_DELETE (battleReward);
	}
	ReleaseActionList();
}

void BattleMgr::RestoreActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();
	
	for (; it != m_vActionList1.end(); it++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		action->action_status=ACTION_STATUS_WAIT;
		
	}
	
	VEC_FIGHTACTION_IT it2 = m_vActionList2.begin();
	
	for (; it2 != m_vActionList2.end(); it2++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		action->action_status=ACTION_STATUS_WAIT;
		
	}

	
	VEC_FIGHTACTION_IT it3 = m_vActionList3.begin();
	
	for (; it3 != m_vActionList3.end(); it3++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action=(*it);
		action->action_status=ACTION_STATUS_WAIT;
		
	}

}

void BattleMgr::ReleaseActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();
	
	for (; it != m_vActionList1.end(); it++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it)->m_vCmdList.begin();
		CC_SAFE_DELETE((*it)->skill);
		for(; fm_it!=(*it)->m_vCmdList.end();fm_it++)
		{
			CC_SAFE_DELETE(*fm_it);
		}
		(*it)->m_vCmdList.clear();
		CC_SAFE_DELETE(*it);
		
	}
	
	m_vActionList1.clear();
	
	VEC_FIGHTACTION_IT it2 = m_vActionList2.begin();
	
	for (; it2 != m_vActionList2.end(); it2++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it2)->m_vCmdList.begin();
		for(; fm_it!=(*it2)->m_vCmdList.end();fm_it++)
		{
			CC_SAFE_DELETE(*fm_it);
		}
		(*it2)->m_vCmdList.clear();
		CC_SAFE_DELETE(*it2);
		
	}
	
	m_vActionList2.clear();
	
	VEC_FIGHTACTION_IT it3 = m_vActionList3.begin();
	
	for (; it3 != m_vActionList3.end(); it3++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it=(*it)->m_vCmdList.begin();
		for(; fm_it!=(*it3)->m_vCmdList.end();fm_it++)
		{
			CC_SAFE_DELETE(*fm_it);
		}
		(*it3)->m_vCmdList.clear();
		CC_SAFE_DELETE(*it3);
		
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
		CC_SAFE_DELETE(it->second);
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
					
					//CUIPet *uiPet = PlayerInfoScene::QueryPetScene();
					//
					//if (uiPet)
					//{
					//	uiPet->UpdateUI(idPet);
					//}
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
			//DianhuaUILayer::RefreshList(btAction, idNextLevelSkill, lqz);
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
	
	//LearnSkillUILayer::RefreshSkillList();
	//PetSkillCompose::refresh();
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
		m_battle = new Battle(BATTLE_TYPE_PLAYBACK);
		m_battle->Initialization(BATTLE_STAGE_START);
		m_battle->StartEraseOutEffect();
		m_battle->setTeamAmout(lastBattleTeamCount);
	}

	for (VEC_FIGHTER_IT it = m_vFighter.begin(); it != m_vFighter.end(); it++)
	{
		NDLog("add_fighter");
		Fighter* fighter = *it;
		
		fighter->reStoreAttr();
		fighter->setBattle(m_battle);
//		fighter->LoadMonster(idlookface, level, strName);
		m_battle->AddFighter(fighter);
	}
	

	ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0);
	NDDirector* director = NDDirector::DefaultDirector();
	NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
	//mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);
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
	
	Byte btPackageType = 0;
	Byte btBattleType = 0;
	Byte btTeamAmout=0;
	int map_id=0;
	unsigned short posX=0;
	unsigned short posY=0;
	
	bao >> btPackageType >> btBattleType>>btTeamAmout >>map_id>>posX>>posY;//>> btAction;
	
	bool bBattleStart = (btPackageType & 2>0);
	this->lastBattleType=btBattleType;
	
	//	if (btAction == BATTLE_STAGE_LEAVE_WATCH) {
	//		// 退出观战
	//		if (this->m_battle && m_battle->IsWatch()) {
	//			m_battle->setServerBattleResult(BATTLE_COMPLETE_END);
	//			if (m_battle->IsPracticeBattle()) {
	//				m_battle->setBattleStatus(Battle::BS_FIGHTER_SHOW_PAS);
	//			} else {
	//				this->quitBattle();
	//			}
	//			
	//			return;
	//		}
	//	}
	
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
	
	//	if (btAction == BATTLE_STAGE_START || btAction == BATTLE_STAGE_WATCH) // 进入战斗
	//	{
	// 初始化战斗对象
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
			CC_SAFE_DELETE(*it);
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
		USHORT level = 0;
		Byte nFighterType = 0; // 玩家，怪物,幻兽
		int nLife = 0;
		int nLifeMax = 0;
		int nMana = 0;
		int nManaMax = 0;
		Byte btGroup=0;
		Byte btBattleTeam=0;
		Byte btStations=0;
		Byte btEquipAmount=0;
		
		
		//int idPet = 0;
		idObj=bao.ReadInt();
		
		bao>>nFighterType;
		idType=bao.ReadInt();
		idlookface=bao.ReadInt();
		level=bao.ReadShort();
		nLife=bao.ReadInt();
		nLifeMax=bao.ReadInt();
		nMana=bao.ReadInt();
		nManaMax=bao.ReadInt();
		bao>> btGroup>>btBattleTeam>>btStations>>btEquipAmount;
		std::string strName;
		strName=bao.ReadUnicodeString();
		for(Byte i=0;i<btEquipAmount;i++){
			// 人物装备
		}
		
		FIGHTER_INFO info;
		info.level=level;
		info.idObj = idObj;
		info.idType = idType;
		info.idlookface = idlookface;
		info.fighterType = FIGHTER_TYPE(nFighterType);
		info.group = BATTLE_GROUP(btGroup);
		info.original_life=nLife;
		info.nLife = nLife;
		info.nLifeMax = nLifeMax;
		info.nMana = nMana;
		info.nManaMax = nManaMax;
		info.btBattleTeam=btBattleTeam;
		info.btStations=btStations;
		NDLog("id:%d,type:%d,fighterType,%d,group:%d,team:%d,pos:%d,life:%d", idObj,idType,nFighterType,btGroup,btBattleTeam,btStations,nLife);
		Fighter* fighter = new Fighter(info);
		fighter->setBattle(m_battle);
		
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
		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0);
		
		if(btBattleType!=BATTLE_TYPE_SPORTS)
		{
			ScriptMgrObj.excuteLuaFunc("CloseMainUI", "",0);
		}
		NDDirector* director = NDDirector::DefaultDirector();
		NDMapLayer* mapLayer = mapMgr.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
		
		//mapLayer->SetBattleBackground(true);
		
		CGSize winSize = director->GetWinSize();
		m_battle->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));


		//mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);
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
	
	
	for (int i = 0; i < btEffectNum; i++) {
		BATTLE_EFFECT_TYPE btEffectType = BATTLE_EFFECT_TYPE(bao.ReadShort());
		int idActor = bao.ReadInt();
		long data=bao.ReadLong();
		
		int lookface;
		Command* cmd = new Command();
		cmd->btEffectType = btEffectType;
		cmd->idActor = idActor;
		switch(btEffectType){
			case BATTLE_EFFECT_TYPE_ATK:
				
				cmd->idTarget=(int) data;
				cmdBefore=cmd;
				NDLog("%d ATK %d", idActor,cmd->idTarget);
				break;
			case BATTLE_EFFECT_TYPE_SKILL:
				NDLog("%d SKILL ", idActor);
				cmd->skill=new BattleSkill();
				cmd->skill->setName(ScriptDBObj.GetS("skill_config",(unsigned int) data, DB_SKILL_CONFIG_NAME));
				if(ScriptDBObj.GetN("skill_type",(unsigned int) data, DB_SKILL_CONFIG_BLOCK_TYPE)==2){
					cmd->skill->setAtkType(SKILL_ATK_TYPE_NEAR);
				}else{
					cmd->skill->setAtkType(SKILL_ATK_TYPE_REMOTE);
				}
				cmd->skill->setLookface(ScriptDBObj.GetN("skill_config",(unsigned int) data, DB_SKILL_CONFIG_ACT_ID), ScriptDBObj.GetN("skill_config",(unsigned int) data, DB_SKILL_CONFIG_LOOKFACE_ID), ScriptDBObj.GetN("skill_config",(unsigned int) data, DB_SKILL_CONFIG_LOOKFACE_TARGET_ID));
				cmd->skill->setId((unsigned int) data);
				cmdBefore=cmd;
				break;
			case BATTLE_EFFECT_TYPE_SKILL_TARGET:
				//				if(cmdBefore->btEffectType==BATTLE_EFFECT_TYPE_SKILL){
				cmd->idTarget=(int) data;
				NDLog("SKILL %d", cmd->idTarget);
				//				}
				break;
			case BATTLE_EFFECT_TYPE_LIFE:
				NDLog("%d HURT", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_MANA: // 气势
				NDLog("%d MANA", idActor);
				cmd->nMpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_DODGE:  // 闪避
				NDLog("%d DODGE", idActor);
				break;
			case BATTLE_EFFECT_TYPE_DRITICAL: // 暴击
				NDLog("%d DRITICAL", idActor);
				//				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_BLOCK:  // 格挡
				NDLog("%d BLOCK", idActor);
				break;
			case BATTLE_EFFECT_TYPE_COMBO:  // 格挡
				NDLog("%d COMBO", idActor);
				cmd->nHpLost=(int)data;
				break;
			case BATTLE_EFFECT_TYPE_STATUS_ADD: // 加状态
				NDLog("%d STATUS_ADD", idActor);
				lookface=ScriptDBObj.GetN("skill_result_type",(unsigned int)data,DB_SKILL_RESULT_CFG_LOOKFACE);
				cmd->status=new FighterStatus((unsigned int)data,lookface/1000,lookface%1000);
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LOST: // 取消状态
				NDLog("%d STATUS_CANCEL", idActor);
				lookface=ScriptDBObj.GetN("skill_result_type",(unsigned int)data,DB_SKILL_RESULT_CFG_LOOKFACE);
				cmd->status=new FighterStatus((unsigned int)data,lookface/1000,lookface%1000);
				break;
			case BATTLE_EFFECT_TYPE_STATUS_LIFE: // 状态去血
				NDLog("%d STATUS_LIFE", idActor);
				cmd->nHpLost=(int)data;
				break;
			case EFFECT_TYPE_TURN_END:   // 回合结束
				NDLog("%d TURN_END", idActor);
				cmdBefore=NULL;
				break;
			case EFFECT_TYPE_BATTLE_BEGIN:  // 战斗开始
				m_CurrentTeamId=idActor;
				cmd->idTarget=(int) data;
				NDLog("%d BEGIN BATTLE", idActor);
				break;
			case EFFECT_TYPE_BATTLE_END:   // 战斗结束
				cmd->idActor=m_CurrentTeamId;
				NDLog("%d END BATTLE", idActor);
				cmdBefore=NULL;
				break;
			case BATTLE_EFFECT_TYPE_DEAD:
				NDLog("%d DIE", idActor);
				break;
			default:
				NDLog("%d NONE", idActor);
				break;
		}
		if(btEffectType==BATTLE_EFFECT_TYPE_ATK||btEffectType==BATTLE_EFFECT_TYPE_SKILL||btEffectType==EFFECT_TYPE_BATTLE_BEGIN||btEffectType==EFFECT_TYPE_BATTLE_END||btEffectType==BATTLE_EFFECT_TYPE_STATUS_LIFE||cmdBefore==NULL){
			m_battle->AddCommand(cmd);
		}else if(cmdBefore!=NULL){
			cmdBefore->cmdNext=cmd;
			cmdBefore=cmd;
		}
	}
	
	if ((btPackFlag&2)>0) {
		m_battle->StartFight();
	}
}

string getStrItemsFromIntArray(vector<OBJID>& items) {
	stringstream ss;
	//ItemMgr& itemMgr = ItemMgrObj;
	//while (items.size() > 0) {
	//	OBJID idItemType = items.at(0);
	//	int count = 0;
	//	NDItemType* pItem = itemMgr.QueryItemType(idItemType);
	//	if (NULL == pItem) {
	//		NDLog("未找到物品类型：[%d]", idItemType);
	//		items.erase(items.begin());
	//		continue;
	//	}
	//	
	//	ss << pItem->m_name;
	//	
	//	for(vector<OBJID>::iterator it = items.begin(); it != items.end(); )
	//	{
	//		if(*it == idItemType) {
	//			count++;
	//			it = items.erase(it);
	//		} else {
	//			it++;
	//		}
	//	}
	//	
	//	ss << " * " << count;
	//	
	//	if (items.size() > 0) {
	//		ss << "\n";
	//	}
	//}
	//
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
	
	Byte btResult = 0;
	int dwHurt = 0;
	Byte btItemAmount = 0;

	bao >>btBattleType>> dwMoney >> dwEMoney >> dwExp
	>> dwRepute >> btResult >>dwHurt
	>> btItemAmount;
	
	NDLog("receive_battle_end:%d",btResult);
	
	this->battleReward=new BattleReward();
	this->battleReward->money=dwMoney;
	this->battleReward->emoney=dwEMoney;
	this->battleReward->exp=dwExp;
	this->battleReward->repute=dwRepute;
	this->battleReward->battleResult=btResult;
//	int nPetLoyal = btPetLoyal;
//	if (nPetLoyal > 127) {
//		nPetLoyal -= 256;
//	}
	
	vector<OBJID> vItems;
	if (btItemAmount > 0) {
		for (int i = 0; i < btItemAmount; i++) {
			OBJID idItemType = bao.ReadInt();
			NDLog("receive_battle_rewardItem:%d",idItemType);
			this->battleReward->addItem(idItemType, 1);
		}
	}
	
//	// 战斗胜利，获得战利品
//	if (btResult == BATTLE_RESULT_TYPE_WIN || btResult == BATTLE_RESULT_TYPE_DRAW) {
//		stringstream content;
//		
//		if (dwMoney != 0) {
//			content << NDCommonCString("get") << NDCommonCString("money") << "：" << dwMoney;
//		}
//		if (dwEMoney != 0) {
//			content << "\n" << NDCommonCString("get") << NDCommonCString("emoney") << "：" << dwEMoney;
//		}
//		if (dwExp != 0) {
//			content << "\n" << NDCommonCString("get") << NDCommonCString("exp") << "：" << dwExp;
//		}
//		if (dwRepute != 0) {
//			content << "\n" << NDCommonCString("get") << NDCommonCString("repute") << "：" << dwRepute;
//		}
//		if (dwHornor != 0) {
//			content << "\n" << NDCommonCString("get") << NDCommonCString("honur") << "：" << dwHornor;
//		}
//		if (strItems.size() > 0) {
//			content << "\n" << NDCommonCString("get") << NDCommonCString("item") << "：" << strItems;
//		}
//		if (ItemMgrObj.IsBagFull()) {
//			content << "\n" << NDCommonCString("BagFull");
//		}
//		if (nPetLoyal < 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("honest") << "：" << nPetLoyal;
//		} else if (btPetLoyal == 0) {
//			
//		} else {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("honest") << "：+" << nPetLoyal;
//		}
//		if (btPetAge != 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("ShouMing") << "：" << (int)btPetAge;
//		}
//		if (nPetExp != 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("exp") << "：" << nPetExp;
//		}
//		
//		string sServer = bao.ReadUnicodeString();
//		if (sServer.size() > 0) {
//			content << sServer;
//		}
//		
//		if (this->m_battle) {
//			this->m_battle->setRewardContent(content.str().c_str());
//		}
//		
//	} else if (btResult == BATTLE_RESULT_TYPE_LOSE) {
//		stringstream content;
//		
//		if (dwMoney != 0) {
//			content << NDCommonCString("sunsi") << NDCommonCString("money") << "：" << abs(dwMoney);
//		}
//		if (dwEMoney != 0) {
//			content << "\n" << NDCommonCString("sunsi") << NDCommonCString("emoney") << "：" << abs(dwEMoney);
//		}
//		if (dwExp != 0) {
//			content << "\n" << NDCommonCString("sunsi") << NDCommonCString("exp") << "：" << abs(dwExp);
//		}
//		if (dwRepute != 0) {
//			content << "\n" << NDCommonCString("sunsi") << NDCommonCString("repute") << "：" << abs(dwRepute);
//		}
//		if (dwHornor != 0) {
//			content << "\n" << NDCommonCString("sunsi") << NDCommonCString("honur") << "：" << abs(dwHornor);
//		}
//		if (strItems.size() > 0) {
//			content << "\n" << NDCommonCString("sunsi") << NDCommonCString("item") << "：" << strItems;
//		}
//		if (nPetLoyal < 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("honest") << "：" << nPetLoyal;
//		} else if (btPetLoyal == 0) {
//			
//		} else {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("honest") << "：+" << nPetLoyal;
//		}
//		if (btPetAge != 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("ShouMing") << "：" << (int)btPetAge;
//		}
//		if (nPetExp != 0) {
//			content << "\n" << NDCommonCString("pet") << NDCommonCString("exp") << "：" << nPetExp;
//		}
//		
//		if (this->m_battle) {
//			this->m_battle->setRewardContent(content.str().c_str());
//		}
//	}
	
	if(m_battle) {
		m_battle->setServerBattleResult(btResult);
//		if (m_battle->IsPracticeBattle()) {
//			m_battle->setBattleStatus(Battle::BS_FIGHTER_SHOW_PAS);
//		}
	}
	// 退出战斗,地图逻辑处理
//	NDMapMgrObj.BattleEnd(btResult);
}

void BattleMgr::showBattleResult()
{
	BATTLE_COMPLETE battle_result = BATTLE_COMPLETE(battleReward->battleResult);
	int battleType= m_battle->GetBattleType();
//	m_battle->RemoveFromParent(true);
	
	
	NDLog("result:%d,type:%d",battle_result,battleType);
	if(battleReward)
	{
		NDLog("battleReward");
		if(battle_result == BATTLE_COMPLETE_WIN)
		{
			if(battleType==BATTLE_TYPE_MONSTER)
			{
				NDLog("type:%d",m_battle->GetBattleType());
				ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",battleReward->exp);
				
				for(int i=0;i<5;i++)
				{
					if(battleReward->itemtype[i]!=0)
					{
						NDLog("addRewardItem:%d",battleReward->itemtype[i]);
						ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI",i+1,battleReward->itemtype[i],battleReward->item_amount[i]);
						
					}
				}
			}else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS){
				NDLog("result,sports");
				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
			}else if(battleType==BATTLE_TYPE_PLAYBACK){
				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,0,0);
			}
		}else if(battle_result == BATTLE_COMPLETE_LOSE)
		{
			if(battleType==BATTLE_TYPE_MONSTER)
			{
				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
			}else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS){
				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
			}else if(battleType==BATTLE_TYPE_PLAYBACK){
				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,0,0);
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
		

//		NDLog("result:%d",battle_result);
//		if(battleReward&&battle_result == BATTLE_COMPLETE_WIN)
//		{
//			if(battleType==BATTLE_TYPE_MONSTER)
//			{
//				NDLog("type:%d",m_battle->GetBattleType());
//				ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
//				ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",battleReward->exp);
//
//				for(int i=0;i<5;i++)
//				{
//					if(battleReward->itemtype[i]!=0)
//					{
//						NDLog("addRewardItem:%d",battleReward->itemtype[i]);
//						ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI",i+1,battleReward->itemtype[i],battleReward->item_amount[i]);
//				
//					}
//				}
//			}else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS){
//				NDLog("result,sports");
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
		
		if (NDMapMgrObj.isMonsterClear()&&battleType==BATTLE_TYPE_MONSTER){
			NDLog("dynmap cleared");
			ScriptMgrObj.excuteLuaFunc("OnBattleFinish","AffixBossFunc",NDMapMgrObj.GetMotherMapID(), 1);
		}
		
		NDPlayer::defaultHero().SetLocked(false);
//		GameScene* gs = (GameScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
//		if (gs) {
//			gs->SetUIShow(false);
//		}
	}
}

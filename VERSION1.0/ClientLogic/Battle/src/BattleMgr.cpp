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

///< #include "NDMapMgr.h" 临时性注释 郭浩
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
m_pkBattle(NULL)
{
	NDNetMsgPool& kPool = NDNetMsgPoolObj;
	kPool.RegMsg(_MSG_BATTLE, this);
	kPool.RegMsg(_MSG_CONTROLPOINT, this);
	kPool.RegMsg(_MSG_EFFECT, this);
	kPool.RegMsg(_MSG_BATTLEEND, this);
	kPool.RegMsg(_MSG_SKILLINFO, this);
	kPool.RegMsg(_MSG_BATTLE_SKILL_LIST, this);
	kPool.RegMsg(_MSG_PLAYER_RECON, this);
	kPool.RegMsg(_MSG_PLAYER_EXT_RECON, this);
	//	m_Db=new ScriptDB();
	m_pkQuitTimer = NULL;
	m_pkBattleReward = NULL;
	m_nBattleMapId = 0;
	m_nBattleX = 0;
	m_nBattleY = 0;
	m_nLastBattleTeamCount = 0;
}

BattleMgr::~BattleMgr()
{
	ReleaseAllBattleSkill();
	if (m_pkBattleReward)
	{
		CC_SAFE_DELETE (m_pkBattleReward);
	}
	ReleaseActionList();
}

void BattleMgr::RestoreActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();

	for (; it != m_vActionList1.end(); it++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action = (*it);
		action->m_eActionStatus = ACTION_STATUS_WAIT;

	}

	VEC_FIGHTACTION_IT it2 = m_vActionList2.begin();

	for (; it2 != m_vActionList2.end(); it2++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action = (*it);
		action->m_eActionStatus = ACTION_STATUS_WAIT;

	}

	VEC_FIGHTACTION_IT it3 = m_vActionList3.begin();

	for (; it3 != m_vActionList3.end(); it3++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		FightAction* action = (*it);
		action->m_eActionStatus = ACTION_STATUS_WAIT;

	}

}

void BattleMgr::ReleaseActionList()
{
	VEC_FIGHTACTION_IT it = m_vActionList1.begin();

	for (; it != m_vActionList1.end(); it++)
	{
		//CC_SAFE_DELETE((*it)->skill);
		VEC_FIGHTERCOMMAND_IT fm_it = (*it)->m_vCmdList.begin();
		CC_SAFE_DELETE((*it)->m_pkSkill);
		for (; fm_it != (*it)->m_vCmdList.end(); fm_it++)
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
		VEC_FIGHTERCOMMAND_IT fm_it = (*it2)->m_vCmdList.begin();
		for (; fm_it != (*it2)->m_vCmdList.end(); fm_it++)
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
		VEC_FIGHTERCOMMAND_IT fm_it = (*it)->m_vCmdList.begin();
		for (; fm_it != (*it3)->m_vCmdList.end(); fm_it++)
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
	MAP_BATTLE_SKILL_IT it = m_mapBattleSkill.find(idSkill);
	return it == m_mapBattleSkill.end() ? NULL : it->second;
}

void BattleMgr::ReleaseAllBattleSkill()
{
	for (MAP_BATTLE_SKILL_IT it = m_mapBattleSkill.begin();
			it != m_mapBattleSkill.end(); it++)
	{
		CC_SAFE_DELETE(it->second);
	}
	m_mapBattleSkill.clear();
}

void BattleMgr::OnTimer(OBJID tag)
{
	if (tag == QUIT_BATTLE_TIMER_TAG)
	{
		if (m_pkBattle && m_pkBattle->IsEraseInOutEffectComplete())
		{
			quitBattle(false);
		}
	}
}

bool BattleMgr::process(MSGID msgID, NDEngine::NDTransData* bao, int len)
{
	/***
	 * 临时性注释 郭浩
	 * all
	 */

// 	switch (msgID)
// 	{
// 		case _MSG_BATTLE:
// 			processBattleStart(*bao);
// 			break;
// 		case _MSG_CONTROLPOINT:
// 			processControlPoint(*bao);
// 			break;
// 		case _MSG_EFFECT:
// 			processBattleEffect(*bao);
// 			break;
// 		case _MSG_BATTLEEND:
// 			processBattleEnd(*bao);
// 			break;
// 		case _MSG_SKILLINFO:
// 			processSkillInfo(*bao, len);
// 			break;
// 		case _MSG_BATTLE_SKILL_LIST:
// 			processBattleSkillList(*bao, len);
// 			break;
// 		case _MSG_PLAYER_RECON:
// 		{
// 			NDMapMgrObj.processPlayer(bao, len);
// 		}
// 			break;
// 		case _MSG_PLAYER_EXT_RECON:
// 		{
// 			NDMapMgrObj.processPlayerExt(bao, len);
// 		}
// 			break;
// 		default:
// 			break;
// 	}
	return true;
}

void BattleMgr::processBattleSkillList(NDTransData& data, int len)
{
	if (m_pkBattle)
	{
		m_pkBattle->processBattleSkillList(data, len);
	}
}

void BattleMgr::processSkillInfo(NDTransData& data, int len)
{
	int btAction = data.ReadByte();
	int btCnt = data.ReadByte();
	int idPet = data.ReadInt();
	for (int i = 0; i < btCnt; i++)
	{
		if (btAction <= 2)
		{ // 玩家或宠物技能
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
			if (depFlag == 1)
			{
				update_required = data.ReadUnicodeString();
			}
			BattleSkill* pkSkill = GetBattleSkill(idSkill);
			NDPlayer& kPlayer = NDPlayer::defaultHero();
			// 技能信息已存在
			if (pkSkill)
			{
				if (btAction == 0)
				{ // 玩家技能
					kPlayer.AddSkill(idSkill);
					//GameScreen.role.addSkill(skill);
				}
				else if (btAction == 1)
				{
					//NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
					//					if (pet) {
					//						pet->AddSkill(idSkill);
					//					}
					PetMgrObj.AddSkill(kPlayer.m_nID, idPet, idSkill);

					//CUIPet *uiPet = PlayerInfoScene::QueryPetScene();
					//
					//if (uiPet)
					//{
					//	uiPet->UpdateUI(idPet);
					//}
				}
				continue;
			}

			pkSkill = new BattleSkill;
			pkSkill->setId(idSkill);
			pkSkill->setStatusLast(statusLast);
			pkSkill->setAtkType(SKILL_ATK_TYPE(atkType));
			pkSkill->setArea(area);
			pkSkill->setInjury(injury);
			pkSkill->setSpeed(speed);
			pkSkill->setMpRequire(mpRequire);
			pkSkill->setAtk_point(atk_point);
			pkSkill->setDef_point(def_point);
			pkSkill->setDis_point(dis_point);
			pkSkill->setLvRequire(lvRequire);
			pkSkill->setMoney(money);
			pkSkill->setSpRequire(spRequire);
			pkSkill->setName(name);
			pkSkill->setDes(des);
			pkSkill->setCurSp(curSp);
			pkSkill->setUpdate_required(update_required);
			pkSkill->setIconIndex(iconIndex);
			pkSkill->setCd(btCD);
			pkSkill->SetSlot(btSlot);

			m_mapBattleSkill[idSkill] = pkSkill;

			pkSkill->SetSkillOwn(btAction == 0);

			if (btAction == 0)
			{ // 玩家技能
				kPlayer.AddSkill(idSkill);
				//GameScreen.role.addSkill(skill);
			}
			else if (btAction == 1)
			{
				//NDBattlePet* pet = NDPlayer::defaultHero().battlepet;
				//				if (pet) {
				//					pet->AddSkill(idSkill);
				//				}
				PetMgrObj.AddSkill(kPlayer.m_nID, idPet, idSkill);
			}
		}
		else if (btAction == 3 || btAction == 4)
		{
			int idNextLevelSkill = data.ReadInt();
			int lqz = data.ReadShort();
			//DianhuaUILayer::RefreshList(btAction, idNextLevelSkill, lqz);
		}
		else if (btAction == 5)
		{ // 更新技能熟练度
			int idSk = data.ReadInt();
			int curSp = data.ReadShort();
			BattleSkill* sk = GetBattleSkill(idSk);
			if (sk)
			{
				sk->setCurSp(curSp);
			}
		}
		else if (btAction == 6)
		{ // 更新技能槽
			int idSk = data.ReadInt();
			int btSlot = data.ReadShort();
			BattleSkill* sk = GetBattleSkill(idSk);
			if (sk)
			{
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
	while (scene)
	{
		if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			((GameScene*) scene)->OnBattleBegin();
			break;
		}
		else
		{
			director->PopScene();
			scene = director->GetRunningScene();
		}
	}
}

void BattleMgr::showBattleScene()
{
	/***
	 * 临时性注释 郭浩
	 * all
	 */

// 	if(m_battle)
// 	{
// 		m_battle->setBattleMap(battleMapId, battleX*MAP_UNITSIZE,battleY*MAP_UNITSIZE);
// 		NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene());
// 		mapLayer->GetParent()->AddChild(m_battle);
// 		// 进入战斗,地图逻辑处理
// 		NDMapMgrObj.BattleStart();
// 	}
}

void BattleMgr::restartLastBattle()
{
	if (m_pkBattle && m_pkBattle->GetParent() != NULL)
	{
		m_pkBattle->RemoveFromParent(true);
		m_pkBattle = NULL;
	}
	if (m_nBattleMapId == 0)
	{
		return;
	}
	if (!m_pkBattle)
	{
		m_pkBattle = new Battle(BATTLE_TYPE_PLAYBACK);
		m_pkBattle->Initialization(BATTLE_STAGE_START);
		m_pkBattle->StartEraseOutEffect();
		m_pkBattle->setTeamAmout(m_nLastBattleTeamCount);
	}

	for (VEC_FIGHTER_IT it = m_vFighter.begin(); it != m_vFighter.end(); it++)
	{
		NDLog("add_fighter");
		Fighter* fighter = *it;

		fighter->reStoreAttr();
		fighter->setBattle(m_pkBattle);
//		fighter->LoadMonster(idlookface, level, strName);
		m_pkBattle->AddFighter(fighter);
	}

//	ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0); ///< 临时性注释 郭浩
	NDDirector* director = NDDirector::DefaultDirector();
	//NDMapLayer* mapLayer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene()); ///< 临时性注释 郭浩
	//mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);
	//mapLayer->SetBattleBackground(true);
	RestoreActionList();
	CGSize winSize = director->GetWinSize();
	m_pkBattle->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));

	m_pkBattle->InitEudemonOpt();
	m_pkBattle->sortFighterList();
	m_pkBattle->InitSpeedBar();
	//m_battle->SetVisible(false);
	director->EnableDispatchEvent(false);
	m_pkBattle->RestartFight();
}

void BattleMgr::processBattleStart(NDEngine::NDTransData& bao)
{

	CloseProgressBar;

	Byte btPackageType = 0;
	Byte btBattleType = 0;
	Byte btTeamAmout = 0;
	int map_id = 0;
	unsigned short posX = 0;
	unsigned short posY = 0;

	bao >> btPackageType >> btBattleType >> btTeamAmout >> map_id >> posX
			>> posY;	//>> btAction;

	bool bBattleStart = (btPackageType & 2 > 0);
	m_nLastBattleType = btBattleType;

	//	if (btAction == BATTLE_STAGE_LEAVE_WATCH) {
	//		// 退出观战
	//		if (m_battle && m_battle->IsWatch()) {
	//			m_battle->setServerBattleResult(BATTLE_COMPLETE_END);
	//			if (m_battle->IsPracticeBattle()) {
	//				m_battle->setBattleStatus(Battle::BS_FIGHTER_SHOW_PAS);
	//			} else {
	//				quitBattle();
	//			}
	//			
	//			return;
	//		}
	//	}

	if (bBattleStart && m_pkBattle && m_pkBattle->GetParent() != NULL)
	{
		quitBattle(false);
	}

	// add by jhzheng
	if (bBattleStart)
	{
		// 先关闭正在操作的ui界面
		CloseProgressBar;
		//		closeUI();
	}

	//NDMapMgr& mapMgr = NDMapMgrObj; ///< 临时性注释 郭浩

	//	if (btAction == BATTLE_STAGE_START || btAction == BATTLE_STAGE_WATCH) // 进入战斗
	//	{
	// 初始化战斗对象
	if (!m_pkBattle)
	{
		m_pkBattle = new Battle(btBattleType);
		m_pkBattle->Initialization(BATTLE_STAGE_START);
		m_pkBattle->StartEraseOutEffect();

	}

	if (btPackageType & 1 > 0)
	{
		m_pkBattle->setTeamAmout(btTeamAmout);
		m_nLastBattleTeamCount = btTeamAmout;
		for (VEC_FIGHTER_IT it = m_vFighter.begin(); it != m_vFighter.end();
				it++)
		{
			CC_SAFE_DELETE(*it);
		}
		m_vFighter.clear();
		ReleaseActionList();
	}

	Byte btAmout = 0;

	bao >> btAmout;

	m_pkBattle->SetTurn(0);

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
		Byte btGroup = 0;
		Byte btBattleTeam = 0;
		Byte btStations = 0;
		Byte btEquipAmount = 0;

		//int idPet = 0;
		idObj = bao.ReadInt();

		bao >> nFighterType;
		idType = bao.ReadInt();
		idlookface = bao.ReadInt();
		level = bao.ReadShort();
		nLife = bao.ReadInt();
		nLifeMax = bao.ReadInt();
		nMana = bao.ReadInt();
		nManaMax = bao.ReadInt();
		bao >> btGroup >> btBattleTeam >> btStations >> btEquipAmount;
		std::string strName;
		strName = bao.ReadUnicodeString();
		for (Byte i = 0; i < btEquipAmount; i++)
		{
			// 人物装备
		}

		FIGHTER_INFO info;
		info.level = level;
		info.idObj = idObj;
		info.idType = idType;
		info.idlookface = idlookface;
		info.fighterType = FIGHTER_TYPE(nFighterType);
		info.group = BATTLE_GROUP(btGroup);
		info.original_life = nLife;
		info.nLife = nLife;
		info.nLifeMax = nLifeMax;
		info.nMana = nMana;
		info.nManaMax = nManaMax;
		info.btBattleTeam = btBattleTeam;
		info.btStations = btStations;
		NDLog("id:%d,type:%d,fighterType,%d,group:%d,team:%d,pos:%d,life:%d",
				idObj, idType, nFighterType, btGroup, btBattleTeam, btStations,
				nLife);
		Fighter* fighter = new Fighter(info);
		fighter->setBattle(m_pkBattle);

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
		fighter->GetRole()->m_nLife = nLife;
		fighter->GetRole()->m_nMaxLife = nLifeMax;
		fighter->GetRole()->m_nMana = nMana;
		fighter->GetRole()->m_nMaxMana = nManaMax;

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
		m_pkBattle->AddFighter(fighter);

		//			// 死亡处理
		//			if (info.nLife == 0)
		//			{
		//				fighter->setDieOK(true);
		//				dieAction(*fighter);
		//			}
	}

	if (bBattleStart)
	{
		/* comment by jhzheng
		 // 关闭正在操作的ui界面
		 CloseProgressBar;
		 closeUI();
		 */

		m_nBattleMapId = map_id;
		m_nBattleX = posX;
		m_nBattleY = posY;
//		ScriptMgrObj.excuteLuaFunc("SetUIVisible", "",0); ///< 临时性注释 郭浩

		if (btBattleType != BATTLE_TYPE_SPORTS)
		{
			//ScriptMgrObj.excuteLuaFunc("CloseMainUI", "",0); ///< 临时性注释 郭浩
		}
		NDDirector* director = NDDirector::DefaultDirector();
		//NDMapLayer* mapLayer = mapMgr.getMapLayerOfScene(NDDirector::DefaultDirector()->GetRunningScene()); ///<临时性注释 郭浩

		//mapLayer->SetBattleBackground(true);

		CGSize winSize = director->GetWinSize();
		m_pkBattle->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));

		//mapLayer->showSwitchSprite(SWITCH_TO_BATTLE);
		m_pkBattle->InitEudemonOpt();
		m_pkBattle->sortFighterList();
		m_pkBattle->InitSpeedBar();
		//m_battle->SetVisible(false);
		director->EnableDispatchEvent(false);

	}
	//}
}

void BattleMgr::processControlPoint(NDEngine::NDTransData& bao)
{
	Fighter* user = m_pkBattle->GetMainUser();
	if (user)
	{
		bao >> user->m_atkPoint >> user->m_defPoint >> user->m_disPoint;
	}
}

void BattleMgr::processBattleEffect(NDEngine::NDTransData& bao)
{
	Byte btPackFlag = 0;
	bao >> btPackFlag;

	Byte btEffectNum = 0;
	bao >> btEffectNum;
	if ((btPackFlag & 1) > 0)
	{
		m_pkBeforeCommand = NULL;
	}

	for (int i = 0; i < btEffectNum; i++)
	{
		BATTLE_EFFECT_TYPE btEffectType = BATTLE_EFFECT_TYPE(bao.ReadShort());
		int idActor = bao.ReadInt();
		long data = bao.ReadLong();

		int lookface;
		Command* pkCommand = new Command();
		pkCommand->btEffectType = btEffectType;
		pkCommand->idActor = idActor;
		switch (btEffectType)
		{
		case BATTLE_EFFECT_TYPE_ATK:

			pkCommand->idTarget = (int) data;
			m_pkBeforeCommand = pkCommand;
			NDLog("%d ATK %d", idActor, pkCommand->idTarget);
			break;
		case BATTLE_EFFECT_TYPE_SKILL:
			NDLog("%d SKILL ", idActor);
			pkCommand->skill = new BattleSkill();
			pkCommand->skill->setName(
					ScriptDBObj.GetS("skill_config", (unsigned int) data,
							DB_SKILL_CONFIG_NAME));
			if (ScriptDBObj.GetN("skill_type", (unsigned int) data,
					DB_SKILL_CONFIG_BLOCK_TYPE) == 2)
			{
				pkCommand->skill->setAtkType(SKILL_ATK_TYPE_NEAR);
			}
			else
			{
				pkCommand->skill->setAtkType(SKILL_ATK_TYPE_REMOTE);
			}
			pkCommand->skill->setLookface(
					ScriptDBObj.GetN("skill_config", (unsigned int) data,
							DB_SKILL_CONFIG_ACT_ID),
					ScriptDBObj.GetN("skill_config", (unsigned int) data,
							DB_SKILL_CONFIG_LOOKFACE_ID),
					ScriptDBObj.GetN("skill_config", (unsigned int) data,
							DB_SKILL_CONFIG_LOOKFACE_TARGET_ID));
			pkCommand->skill->setId((unsigned int) data);
			m_pkBeforeCommand = pkCommand;
			break;
		case BATTLE_EFFECT_TYPE_SKILL_TARGET:
			//				if(cmdBefore->btEffectType==BATTLE_EFFECT_TYPE_SKILL){
			pkCommand->idTarget = (int) data;
			NDLog("SKILL %d", pkCommand->idTarget);
			//				}
			break;
		case BATTLE_EFFECT_TYPE_LIFE:
			NDLog("%d HURT", idActor);
			pkCommand->nHpLost = (int) data;
			break;
		case BATTLE_EFFECT_TYPE_MANA: // 气势
			NDLog("%d MANA", idActor);
			pkCommand->nMpLost = (int) data;
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
			pkCommand->nHpLost = (int) data;
			break;
		case BATTLE_EFFECT_TYPE_STATUS_ADD: // 加状态
			NDLog("%d STATUS_ADD", idActor);
			lookface = ScriptDBObj.GetN("skill_result_type",
					(unsigned int) data, DB_SKILL_RESULT_CFG_LOOKFACE);
			pkCommand->status = new FighterStatus((unsigned int) data,
					lookface / 1000, lookface % 1000);
			break;
		case BATTLE_EFFECT_TYPE_STATUS_LOST: // 取消状态
			NDLog("%d STATUS_CANCEL", idActor);
			lookface = ScriptDBObj.GetN("skill_result_type",
					(unsigned int) data, DB_SKILL_RESULT_CFG_LOOKFACE);
			pkCommand->status = new FighterStatus((unsigned int) data,
					lookface / 1000, lookface % 1000);
			break;
		case BATTLE_EFFECT_TYPE_STATUS_LIFE: // 状态去血
			NDLog("%d STATUS_LIFE", idActor);
			pkCommand->nHpLost = (int) data;
			break;
		case EFFECT_TYPE_TURN_END:   // 回合结束
			NDLog("%d TURN_END", idActor);
			m_pkBeforeCommand = NULL;
			break;
		case EFFECT_TYPE_BATTLE_BEGIN:  // 战斗开始
			m_nCurrentTeamId = idActor;
			pkCommand->idTarget = (int) data;
			NDLog("%d BEGIN BATTLE", idActor);
			break;
		case EFFECT_TYPE_BATTLE_END:   // 战斗结束
			pkCommand->idActor = m_nCurrentTeamId;
			NDLog("%d END BATTLE", idActor);
			m_pkBeforeCommand = NULL;
			break;
		case BATTLE_EFFECT_TYPE_DEAD:
			NDLog("%d DIE", idActor);
			break;
		default:
			NDLog("%d NONE", idActor);
			break;
		}
		if (btEffectType == BATTLE_EFFECT_TYPE_ATK
				|| btEffectType == BATTLE_EFFECT_TYPE_SKILL
				|| btEffectType == EFFECT_TYPE_BATTLE_BEGIN
				|| btEffectType == EFFECT_TYPE_BATTLE_END
				|| btEffectType == BATTLE_EFFECT_TYPE_STATUS_LIFE
				|| m_pkBeforeCommand == NULL)
		{
			m_pkBattle->AddCommand(pkCommand);
		}
		else if (m_pkBeforeCommand != NULL)
		{
			m_pkBeforeCommand->cmdNext = pkCommand;
			m_pkBeforeCommand = pkCommand;
		}
	}

	if ((btPackFlag & 2) > 0)
	{
		m_pkBattle->StartFight();
	}
}

string getStrItemsFromIntArray(vector<OBJID>& items)
{
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

	bao >> btBattleType >> dwMoney >> dwEMoney >> dwExp >> dwRepute >> btResult
			>> dwHurt >> btItemAmount;

	NDLog("receive_battle_end:%d", btResult);

	m_pkBattleReward = new BattleReward();
	m_pkBattleReward->m_nMoney = dwMoney;
	m_pkBattleReward->m_nEMoney = dwEMoney;
	m_pkBattleReward->m_nEXP = dwExp;
	m_pkBattleReward->m_nRepute = dwRepute;
	m_pkBattleReward->m_nBattleResult = btResult;
//	int nPetLoyal = btPetLoyal;
//	if (nPetLoyal > 127) {
//		nPetLoyal -= 256;
//	}

	vector < OBJID > vItems;
	if (btItemAmount > 0)
	{
		for (int i = 0; i < btItemAmount; i++)
		{
			OBJID idItemType = bao.ReadInt();
			NDLog("receive_battle_rewardItem:%d", idItemType);
			m_pkBattleReward->addItem(idItemType, 1);
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
//		if (m_battle) {
//			m_battle->setRewardContent(content.str().c_str());
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
//		if (m_battle) {
//			m_battle->setRewardContent(content.str().c_str());
//		}
//	}

	if (m_pkBattle)
	{
		m_pkBattle->setServerBattleResult(btResult);
//		if (m_battle->IsPracticeBattle()) {
//			m_battle->setBattleStatus(Battle::BS_FIGHTER_SHOW_PAS);
//		}
	}
	// 退出战斗,地图逻辑处理
//	NDMapMgrObj.BattleEnd(btResult);
}

void BattleMgr::showBattleResult()
{
	BATTLE_COMPLETE battle_result = BATTLE_COMPLETE(m_pkBattleReward->m_nBattleResult);
	int battleType = m_pkBattle->GetBattleType();
//	m_battle->RemoveFromParent(true);

	NDLog("result:%d,type:%d", battle_result, battleType);
	if (m_pkBattleReward)
	{
		NDLog("battleReward");
		if (battle_result == BATTLE_COMPLETE_WIN)
		{
			if (battleType == BATTLE_TYPE_MONSTER)
			{
				NDLog("type:%d", m_pkBattle->GetBattleType());
				/***
				 * 临时性注释 郭浩
				 * begin
				 */
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "MonsterRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetRewardExp", "MonsterRewardUI",battleReward->exp);
				/***
				 * 临时性注释 郭浩
				 * end
				 */

				for (int i = 0; i < 5; i++)
				{
					if (m_pkBattleReward->m_nItemTypes[i] != 0)
					{
						NDLog("addRewardItem:%d", m_pkBattleReward->m_nItemTypes[i]);
						//	ScriptMgrObj.excuteLuaFunc("addRewardItem", "MonsterRewardUI",i+1,battleReward->itemtype[i],battleReward->item_amount[i]); ///< 临时性注释 郭浩

					}
				}
			}
			/***
			 * 临时性注释 郭浩
			 * begin
			 */
// 			else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS)
// 			{
// 				NDLog("result,sports");
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
// 			}
// 			else if(battleType==BATTLE_TYPE_PLAYBACK)
// 			{
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,0,0);
// 			}
			/***
			 * 临时性注释 郭浩
			 * end
			 */
		}
		else if (battle_result == BATTLE_COMPLETE_LOSE)
		{
			/***
			 * 临时性注释 郭浩
			 * begin
			 */
// 			if(battleType==BATTLE_TYPE_MONSTER)
// 			{
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
// 			}
// 			else if(battleType==BATTLE_TYPE_SPORTS||battleType==BATTLE_TYPE_BOSS)
// 			{
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,battleReward->money,battleReward->repute);
// 			}
// 			else if(battleType==BATTLE_TYPE_PLAYBACK)
// 			{
// 				ScriptMgrObj.excuteLuaFunc("LoadUI", "ArenaRewardUI",0);
// 				ScriptMgrObj.excuteLuaFunc("SetResult","ArenaRewardUI",battle_result,0,0);
// 			}
			/***
			 * 临时性注释 郭浩
			 * end
			 */
		}
	}
}

void BattleMgr::quitBattle(bool bEraseOut/*=true*/)
{
	if (m_pkBattle)
	{
		if (bEraseOut)
		{
			if (!m_pkQuitTimer)
			{
				m_pkQuitTimer = new NDTimer;
				m_pkQuitTimer->SetTimer(this, QUIT_BATTLE_TIMER_TAG, 0.1f);
				m_pkBattle->StartEraseInEffect();
			}
			return;
		}

		if (m_pkQuitTimer)
		{
			m_pkQuitTimer->KillTimer(this, QUIT_BATTLE_TIMER_TAG);
			delete m_pkQuitTimer;
			m_pkQuitTimer = NULL;
		}

		BATTLE_COMPLETE battle_result = BATTLE_COMPLETE(
				m_pkBattle->getServerBattleResult());
		int battleType = m_pkBattle->GetBattleType();
		m_pkBattle->RemoveFromParent(true);

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
		m_pkBattle = NULL;

		/***
		 * 临时性注释 郭浩
		 * begin
		 */

// 		if (NDMapMgrObj.isMonsterClear()&&battleType==BATTLE_TYPE_MONSTER){
// 			NDLog("dynmap cleared");
// 			ScriptMgrObj.excuteLuaFunc("OnBattleFinish","AffixBossFunc",NDMapMgrObj.GetMotherMapID(), 1);
// 		}
		/***
		 * 临时性注释 郭浩
		 * end
		 */

		NDPlayer::defaultHero().SetLocked(false);
//		GameScene* gs = (GameScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
//		if (gs) {
//			gs->SetUIShow(false);
//		}
	}
}

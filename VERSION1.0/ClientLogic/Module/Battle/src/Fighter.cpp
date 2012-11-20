/*
 *  Fighter.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-19.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "Fighter.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "BattleUtil.h"
#include "NDUtility.h"
#include "NDMonster.h"
#include "Battle.h"
#include "ItemMgr.h"
#include "NDSprite.h"
#include "NDUILabel.h"
#include <sstream>
#include "CPet.h"
#include "NDDirector.h"
#include "NDDebugOpt.h"
using namespace NDEngine;

//IMPLEMENT_CLASS(Fighter,NDBaseFighter);

const int LEFT_BACK_X = 120; // 左边后排 x 坐标
const int LEFT_FRONT_X = 160; // 左边前排 x 坐标
const int RIGHT_FRONT_X = 320; // 右边后排 x 坐标
const int RIGHT_BACK_X = 360; // 右边前排 x 坐标

const int POS_INTERVAL_Y = 53; // y 轴间隔

const int STEP = 64;

Fighter::Fighter()
{
	m_pkActionWordImage = NULL;

	m_kRoleInParentPoint = CGPointMake(0.0f, 0.0f);
	m_pkRoleParent = NULL;
	m_pkRole = NULL;
	m_bRoleShouldDelete = false;
	m_nAttackPoint = 0;
	m_nDefencePoint = 0;
	m_nDistancePoint = 0;
	m_nNormalAtkType = ATKTYPE_NEAR;
//	m_effectType = EFFECT_TYPE_NONE;
	m_pkMainTarget = NULL;
	m_pkActor = NULL;
	m_bMissAtk = false;
	m_bHardAtk = false;
	m_bDefenceAtk = false;
	m_bFleeNoDie = false;
	m_bDefenceOK = false;
	m_bBeginAction = false;
	m_action = WAIT;
	m_actionType = ACTION_TYPE_NORMALATK;
//	m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE_NONE;
//	m_changeLifeTypePas = EFFECT_CHANGE_LIFE_TYPE_NONE;
	m_uiUsedItem = ID_NONE;
	m_nActionTime = 0;
	m_bIsEscape = false;
	m_bIsAlive = true;
	m_bWillBeAttack = false;
	m_pkParent = NULL;

	m_nX = 0;
	m_nY = 0;
	m_nOriginX = 0;
	m_nOriginY = 0;

	isVisibleStatus = true;

	m_bIsDodgeOK = false;
	m_bIsHurtOK = false;
	m_bIsDieOK = false;
	m_bIsDefenceOK = false;
	m_bIsAddLifeOK = false;
	m_bIsActionOK = true;
	m_bIsStatusPerformOK = false;
	m_bIsStatusOverOK = false;
	m_bShowName = false;
	m_pkSkillNameLabel = NULL;
	m_pkFighterNameLabel = NULL;
//	m_imgHurtNum = NULL;
	m_pkCritImage = NULL;
	m_pkBojiImage = NULL;
	m_eSkillAtkType = ATKTYPE_NEAR;

	m_pkProtectTarget = NULL;
	m_pkProtector = NULL;
	m_nHurtInprotect = 0;

	m_pkRareMonsterEffect = NULL;
	m_testVa = 1;
}

void Fighter::releaseStatus()
{
	for (VEC_FIGHTER_STATUS_IT it = m_vBattleStatusList.begin();
			it != m_vBattleStatusList.end(); it++)
	{
		CC_SAFE_DELETE(*it);
	}
	m_vBattleStatusList.clear();
}

Fighter::~Fighter()
{
	releaseStatus();

	if (m_pkRole)
	{
		m_pkRole->RemoveFromParent(false);
	}

	if (m_bRoleShouldDelete)
	{
		CC_SAFE_DELETE (m_pkRole);
	}

	if (m_pkRole && m_pkRoleParent)
	{
		m_pkRole->SetPositionEx(m_kRoleInParentPoint);
		m_pkRoleParent->AddChild(m_pkRole);
		if (m_pkRole->IsKindOfClass(RUNTIME_CLASS(NDManualRole)))
		{
			NDManualRole* role = (NDManualRole*)m_pkRole;
			role->SetAction(false);
		}
	}

//	CC_SAFE_DELETE(m_imgHurtNum); ///< 临时性注释 郭浩
	CC_SAFE_DELETE (m_pkCritImage);
	CC_SAFE_DELETE (m_pkBojiImage);
}

int countY(int teamAmount, BATTLE_GROUP group, int t, int pos)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	int st = pos - 1;
	int team = t - 1;
	if (teamAmount <= 2)
	{

		float h = winsize.height * 5 / 6;
		return winsize.height / 6 + h / 4 + (h / 4) * (st % 3);

	}
	else
	{
		float teamH = (winsize.height - winsize.height / 10 - 5) / 3;
		float teamY = winsize.height / 10 + 5 + teamH * (team % 3);

		return teamY + teamH / 4 + teamH / 4 * (st % 3);

		float teamW = winsize.width * 2 / 9;
		float teamOffset = teamW / 4;
		//		NDLog("team:%d,pos:%d",team,st);
		//		NDLog("x:%d,y:%d",originX,originY);
	}
}

int countX(int teamAmount, BATTLE_GROUP group, int t, int pos)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	int st = pos - 1;
	int team = t - 1;
	if (teamAmount <= 2)
	{

		if (group == BATTLE_GROUP_ATTACK) // 左边
		{
			return winsize.width / 2 - winsize.width / 8
					- winsize.width / 8 * (st / 3);
		}
		else // 右边
		{
			return winsize.width / 2 + winsize.width / 8
					+ winsize.width / 8 * (st / 3);
		}
	}
	else
	{

		float teamW = winsize.width * 2 / 9;
		float teamOffset = teamW / 4;
		if (group == BATTLE_GROUP_ATTACK) // 左边
		{

			float teamX = teamOffset * (team % 3);

			return teamX + teamW - teamW / 4 - teamW / 4 * (st / 3);
		}
		else // 右边
		{
			float teamX = teamW + teamW * 0.8 + teamW * (team / 3)
					+ teamOffset * (team % 3);

			return teamX + teamW / 4 + teamW / 4 * (st / 3);

		}
		//		NDLog("team:%d,pos:%d",team,st);
		//		NDLog("x:%d,y:%d",originX,originY);
	}
}

void Fighter::setPosition(int teamAmout)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
//	int st=m_info.btStations-1;
//	int team=m_info.btBattleTeam-1;
	m_nOriginX = countX(teamAmout, m_kInfo.group, m_kInfo.btBattleTeam,
			m_kInfo.btStations);
	m_nOriginY = countY(teamAmout, m_kInfo.group, m_kInfo.btBattleTeam,
			m_kInfo.btStations);

//	if (m_info.fighterType == FIGHTER_TYPE_MONSTER || m_info.fighterType == FIGHTER_TYPE_ELITE_MONSTER) {// 怪物的话，要错开站位
//		if (m_info.line == BATTLE_LINE_BACK) // 后排
//		{
//			originY -= 8;
//		}
//		else // 前排
//		{
//			originY += 8;
//		}
//	}

	m_nX = m_nOriginX;
	m_nY = m_nOriginY;
}

//void Fighter::AddCommand(FIGHTER_CMD* cmd)
//{
//	m_vCmdList.push_back(cmd);
//}

void Fighter::updatePos()
{
	m_pkRole->SetPositionEx(ccp(m_nX, m_nY));
	if (!isVisibleStatus)
	{
		NDUILabel* lbHover = (NDUILabel*) m_pkParent->GetChild(
				TAG_HOVER_MSG);
		if (lbHover)
		{
			CGSize sizeStr = getStringSize(lbHover->GetText().c_str(),
					DEFAULT_FONT_SIZE);
			lbHover->SetFrameRect(
					CGRectMake(m_nX - sizeStr.width / 2, m_nY - m_pkRole->GetHeight(),
							sizeStr.width, sizeStr.height));
		}
	}
	//NDUILabel* lbName = (NDUILabel*)m_parent->GetChild(TAG_FIGHTER_NAME);
	if (m_pkFighterNameLabel)
	{
		CGSize sizeStr = getStringSize(m_pkFighterNameLabel->GetText().c_str(),
				DEFAULT_FONT_SIZE);
		m_pkFighterNameLabel->SetFrameRect(
				CGRectMake(m_nX - sizeStr.width / 2,
						m_nY - m_pkRole->GetHeight() - sizeStr.height, sizeStr.width,
						sizeStr.height));
	}

	if (m_pkSkillNameLabel)
	{
		CGPoint pt = m_pkRole->GetPosition();
		CGSize sizeStr = getStringSize(m_pkSkillNameLabel->GetText().c_str(),
				DEFAULT_FONT_SIZE);
		m_pkSkillNameLabel->SetFrameRect(
				CGRectMake(pt.x + (m_pkRole->GetWidth() / 2),
						pt.y - (m_pkRole->GetHeight() / 2) - sizeStr.height,
						sizeStr.width, sizeStr.height));
	}
}

void Fighter::reStoreAttr()
{

	m_bMissAtk = false;
	m_bHardAtk = false;
	m_bDefenceAtk = false;
	m_bFleeNoDie = false;
	m_bDefenceOK = false;
	m_bBeginAction = false;
	m_action = WAIT;

	m_nActionTime = 0;
	m_bIsEscape = false;
	m_bIsAlive = true;
	m_bWillBeAttack = false;

	m_bIsDodgeOK = false;
	m_bIsHurtOK = false;
	m_bIsDieOK = false;
	m_bIsDefenceOK = false;
	m_bIsAddLifeOK = false;
	m_bIsActionOK = true;
	m_bIsStatusPerformOK = false;
	m_bIsStatusOverOK = false;
	m_bShowName = false;

	m_kInfo.nLife = m_kInfo.original_life;
	GetRole()->m_nLife = m_kInfo.nLife;
	GetRole()->m_nMaxLife = m_kInfo.nLifeMax;
	GetRole()->m_nMana = m_kInfo.nMana;
	GetRole()->m_nMaxMana = m_kInfo.nManaMax;
}

void Fighter::LoadEudemon()
{
//	int idLookFace = 0;
//	std::string strName = "";
//	PetInfo* petInfo = PetMgrObj.GetPet(m_info.idPet);
//	if (!petInfo) 
//	{
//		// 其它玩家的
//		Item item(m_info.idType);
//		strName		= item.getItemName();
//		idLookFace	= item.getLookFace();
//	}
//	else
//	{
//		strName		= petInfo->str_PET_ATTR_NAME;
//		idLookFace	= petInfo->data.int_PET_ATTR_LOOKFACE;
//	}
//	
//	m_bRoleShouldDelete = true;
//	NDBattlePet* role = new NDBattlePet;
//	role->Initialization(idLookFace);
//	role->m_name = strName;
//	m_role = role;
}

void Fighter::LoadRole(int nLookFace, int lev, const string& name)
{
	m_bRoleShouldDelete = true;
	NDManualRole *role = new NDManualRole;
	role->InitRoleLookFace(nLookFace);
	m_pkRole = role;
	m_pkRole->m_strName = name;
	m_pkRole->m_nLevel = lev;
	role->SetNonRole(false);
}

void Fighter::LoadMonster(int nLookFace, int lev, const string& name)
{
	m_bRoleShouldDelete = true;
	//nLookFace=4000000;

//	if(nLookFace/100000000%10>0&&nLookFace/100000000%10<=2){//人物
	NDManualRole *role = new NDManualRole;
	role->Initialization(nLookFace, true);
	role->m_dwLookFace = nLookFace;
	m_pkRole = role;
	m_eLookfaceType = LOOKFACE_MANUAL;
//	}else if (NDMonster::isRoleMonster(nLookFace)) {//人形怪
//		NDMonster *role = new NDMonster;
//		role->m_bRoleMonster = true;
//		role->InitNonRoleData(name, nLookFace, lev);
//		role->SetNonRole(false);
//		m_role=role;
//		m_lookfaceType=LOOKFACE_MANUAL;
//	} else {
//		NDMonster *role = new NDMonster;
//		role->SetNormalAniGroup(nLookFace);
//		role->SetNonRole(true);
//		m_role=role;
//		m_lookfaceType=LOOKFACE_MONSTER;
//	}

	m_strFighterName = name;
	m_pkRole->m_strName = name;
	m_pkRole->m_nLevel = lev;

	//m_info.bRoleMonster = role->m_bRoleMonster;
}

/*void Fighter::GetCurSubAniGroup(VEC_SAG& sagList)
 {
 VEC_SAG allSagList;
 m_role->GetSubAniGroup(allSagList);

 NDSubAniGroup* sag;
 for (VEC_SAG_IT it = allSagList.begin(); it != allSagList.end(); it++) {
 sag = *it;
 if (!sag) {
 continue;
 }

 bool bAdd = false;
 if (sag->getId() == 0) { // 非魔法特效
 if (sag->getType() == SUB_ANI_TYPE_SELF) {
 sag->fighter = this;
 sagList.push_back(sag);
 bAdd = true;
 } else if (sag->getType() == SUB_ANI_TYPE_NONE) {
 sagList.push_back(sag);
 bAdd = true;
 }
 } else { // 魔法特效
 if (sag->getId() == getUseSkill()->getSubAniID()) {
 if (sag->getType() == SUB_ANI_TYPE_SELF) {
 sag->fighter = this;
 sagList.push_back(sag);
 bAdd = true;
 } else if (sag->getType() == SUB_ANI_TYPE_TARGET) {

 VEC_FIGHTER& array = getArrayTarget();
 if (array.size() == 0) {// 如果没有目标数组，则制定目标为mainTarget
 sag->fighter = m_mainTarget;
 sagList.push_back(sag);
 bAdd = true;
 } else {
 for (size_t j = 0; j < array.size(); j++) {
 sag->fighter = array.at(j);
 sagList.push_back(sag);
 bAdd = true;
 }
 }

 } else if (sag->getType() == SUB_ANI_TYPE_NONE) {
 sag->fighter = this;
 sagList.push_back(sag);
 bAdd = true;
 }
 }
 }

 if (!bAdd) {
 SAFE_DELETE(sag);
 }
 }
 }*/

void Fighter::draw()
{
	drawRareMonsterEffect (isVisibleStatus);
	m_pkRole->RunAnimation(isVisibleStatus);
	//RunBattleSubAnimation(m_pkRole, this); ///<没实现？ 郭浩
	drawStatusAniGroup();
}

void Fighter::drawStatusAniGroup()
{
	for (VEC_FIGHTER_STATUS_IT it = m_vBattleStatusList.begin();
			it != m_vBattleStatusList.end(); it++)
	{
		if ((*it)->m_pkAniGroup)
		{
			NDSprite* role = (*it)->m_pkAniGroup->role;
			if (!role)
			{
				continue;
			}
			//	NDEngine::DrawSubAnimation(role, *((*it)->m_aniGroup)); ///< 临时性注释 郭浩
		}
	}
}

void Fighter::SetRole(NDBaseRole* role)
{
	m_pkRole = role;

	m_pkRoleParent = role->GetParent();
	m_kRoleInParentPoint = role->GetPosition();

	if (m_pkRoleParent)
	{
		role->RemoveFromParent(false);
	}

	switch (role->GetWeaponType())
	{
	case TWO_HAND_BOW:
		m_nNormalAtkType = ATKTYPE_DISTANCE;
		break;
	case DUAL_SWORD:
	case TWO_HAND_WAND:
	case TWO_HAND_WEAPON:
	case ONE_HAND_WEAPON:
	case WEAPON_NONE:
	case DUAL_KNIFE:
		m_nNormalAtkType = ATKTYPE_NEAR;
		break;
	}
}

void Fighter::AddAHurt(Fighter* actor, int btType, int hurtHP, int hurtMP,
		int dwData, HURT_TYPE ht)
{
	m_vHurt.push_back(Hurt(actor, btType, hurtHP, hurtMP, dwData, ht));
}

PAIR_GET_HURT Fighter::getHurt(Fighter* actor, int btType, int dwData, int type)
{

	PAIR_GET_HURT hurtRet;
	hurtRet.first = false;

	if (type == HURT_TYPE_PASSIVE)
	{		// 被动的，用btType去取dwData
		for (size_t i = 0; i < m_vHurt.size(); i++)
		{
			Hurt& hurt = m_vHurt.at(i);
			if (hurt.theActor == actor && hurt.btType == btType
					&& hurt.type == type && i == 0)
			{
				hurtRet.first = true;
				hurtRet.second = hurt;
				m_vHurt.erase(m_vHurt.begin() + i);
				break;
			}
		}
	}
	else if (type == HURT_TYPE_ACTIVE)
	{
		for (size_t i = 0; i < m_vHurt.size(); i++)
		{
			Hurt& hurt = m_vHurt.at(i);
			if (hurt.theActor == actor && hurt.dwData == dwData
					&& hurt.type == type)
			{
				hurtRet.first = true;
				hurtRet.second = hurt;
				m_vHurt.erase(m_vHurt.begin() + i);
				break;
			}
		}
	}

	return hurtRet;
}

void Fighter::AddAStatusTarget(StatusAction& f)
{
	m_kArrayStatusTarget.push_back(f);
}

void Fighter::AddATarget(Fighter* f)
{
	m_vTarget.push_back(f);
}

void Fighter::AddPasStatus(int dwData)
{
	m_vPasStatus.push_back(dwData);
}

bool Fighter::isCatchable()
{
//	bool ret = false;
//	if (isVisiable()) {
//		ret = m_info.catchFlag > 0 ? true : false;
//	}
	return false;
}

void Fighter::setEscape(bool esc)
{
	m_bIsEscape = esc;
	if (m_pkActionWordImage)
	{
		m_pkActionWordImage->RemoveFromParent(true);
		m_pkActionWordImage = NULL;
	}
}

bool Fighter::isVisiable()
{
	bool result = false;

//	if (m_info.fighterType == FIGHTER_TYPE_PET) {
//		if (escape) {
//			result = false;
//		} else {
//			result = true;
//		}
//	} else {
	if (m_bIsEscape || !m_bIsAlive)
	{
		result = false;
	}
	else
	{
		result = true;
	}
//	}

	return result;
}

bool Fighter::completeOneAction()
{
	bool result = false;

	if (m_nActionTime >= 20)
	{
		result = true;
	}
	return result;
}

bool Fighter::moveTo(int tx, int ty)
{

	bool arrive = false;

	if (abs(m_nX - tx) < STEP)
	{
		m_nX = tx;

	}
	else
	{
		if (m_nX > tx)
		{
			m_nX -= STEP;
		}
		else
		{
			m_nX += STEP;
		}
	}

	if (abs(m_nY - ty) < STEP)
	{
		m_nY = ty;
	}
	else
	{
		if (m_nY > ty)
		{
			m_nY -= STEP;
		}
		else
		{
			m_nY += STEP;
		}
	}

	if (m_nX == tx && m_nY == ty)
	{
		arrive = true;
	}

	return arrive;
}

void Fighter::hurted(int num)
{
	if (num == 0)
	{
		return;
	}

	m_vHurtNum.push_back(num);
}

void Fighter::setCurrentHP(int hp)
{
	if (hp <= 0)
	{
		m_kInfo.nLife = 0;
	}
	else if (hp > m_kInfo.nLifeMax)
	{
		m_kInfo.nLife = m_kInfo.nLifeMax;
	}
	else
	{
		m_kInfo.nLife = hp;
	}

	int currentId = BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if (currentId == m_kInfo.idObj)
	{
		//ScriptMgrObj.excuteLuaFunc("UpdateHp","FighterInfo",m_info.nLife,m_info.nLifeMax); ///< 临时性注释 郭浩
	}
}

void Fighter::setCurrentMP(int mp)
{
	if (mp <= 0)
	{
		m_kInfo.nMana = 0;
	}
	else if (mp > m_kInfo.nManaMax)
	{
		m_kInfo.nMana = m_kInfo.nManaMax;
	}
	else
	{
		m_kInfo.nMana = mp;
	}

	int currentId = BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if (currentId == m_kInfo.idObj)
	{
		//ScriptMgrObj.excuteLuaFunc("UpdateMp","FighterInfo",m_info.nMana,m_info.nManaMax); ///< 临时性注释 郭浩
	}
}

void Fighter::showFighterName(bool b)
{
	if (b)
	{
		if (m_bShowName)
		{
			return;
		}
		NDBaseRole* role = GetRole();
		if (role)
		{
			CGPoint pt = m_pkRole->GetPosition();
			m_pkFighterNameLabel = new NDUILabel;
			m_pkFighterNameLabel->Initialization();
			//lb_FighterName->SetTag(TAG_FIGHTER_NAME);
			m_pkFighterNameLabel->SetFontColor(ccc4(255, 255, 255, 255));
			m_pkFighterNameLabel->SetText(GetRole()->m_strName.c_str());
			m_pkFighterNameLabel->SetFontSize(DEFAULT_FONT_SIZE);
			CGSize sizefighterName = getStringSize(GetRole()->m_strName.c_str(),
					DEFAULT_FONT_SIZE);
			//fighterName->SetTag(TAG_FIGHTER_NAME);
			m_pkFighterNameLabel->SetFrameRect(
					CGRectMake(pt.x - sizefighterName.width / 2,
							pt.y - m_pkRole->GetHeight() - sizefighterName.height,
							sizefighterName.width, sizefighterName.height));
			m_pkParent->AddChild(m_pkFighterNameLabel);
		}
	}
	else
	{
		if (m_pkFighterNameLabel)
		{
			m_pkFighterNameLabel->RemoveFromParent(true);
			m_pkFighterNameLabel = NULL;
		}
	}
	m_bShowName = b;
}

void Fighter::showSkillName(bool b)
{
	if (b)
	{
		CGPoint pt = m_pkRole->GetPosition();
		m_pkSkillNameLabel = new NDUILabel;
		m_pkSkillNameLabel->Initialization();
		m_pkSkillNameLabel->SetFontColor(ccc4(254, 3, 9, 255));
		m_pkSkillNameLabel->SetText(m_strSkillName.c_str());
		CGSize sizeSkillName = getStringSize(m_strSkillName.c_str(),
				DEFAULT_FONT_SIZE);
		//lb_skillName->SetTag(TAG_SKILL_NAME);
		m_pkSkillNameLabel->SetFontSize(DEFAULT_FONT_SIZE);
		m_pkSkillNameLabel->SetFrameRect(
				CGRectMake(pt.x + (m_pkRole->GetWidth() / 2),
						pt.y - (m_pkRole->GetHeight() / 2) - sizeSkillName.height,
						sizeSkillName.width, sizeSkillName.height));
		m_pkParent->AddChild(m_pkSkillNameLabel);
	}
	else
	{
		if (m_pkSkillNameLabel)
		{
			m_pkSkillNameLabel->RemoveFromParent(true);
			m_pkSkillNameLabel = NULL;
		}
	}
}

void Fighter::showActionWord(ACTION_WORD index)
{
	if (m_pkActionWordImage)
	{
		return;
	}

	NDPicture* pic = NULL;
	switch (index)
	{
	case AW_DEF:
		pic = (m_pkParent->getActionWord(AW_DEF));
		break;
	case AW_FLEE:
		pic = (m_pkParent->getActionWord(AW_FLEE));
		break;
	case AW_DODGE:
		pic = (m_pkParent->getActionWord(AW_DODGE));
		break;
	default:
		break;
	}

	if (!pic)
	{
		return;
	}

	CGSize size = pic->GetSize();

	m_pkActionWordImage = new NDUIImage;
	m_pkActionWordImage->Initialization();
	m_pkActionWordImage->SetPicture(pic);
	m_pkActionWordImage->SetFrameRect(
			CGRectMake(m_nX - size.width / 2, m_nY - m_pkRole->GetHeight(),
					size.width, size.height));
	m_pkParent->AddChild(m_pkActionWordImage);
}

void Fighter::drawActionWord()
{
	//if (!m_role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
//	{
//		NDLog("dfdsfdsf");
//	}
	if (isAlive())
	{
		switch (m_action)
		{
		case FLEE_FAIL:
		case FLEE_SUCCESS:
			if (isBeginAction() && !isActionOK())
			{
				showActionWord(AW_FLEE);
				return;
			}
			break;
		case DEFENCE:
			showActionWord(AW_DEF);
			return;
		default:
			break;
		}

		if (m_bIsDodgeOK)		//&& isBeginAction())
		{
			showActionWord(AW_DODGE);
			return;
		}

		if (m_bIsDefenceOK)
		{
			showActionWord(AW_DEF);
			return;
		}
	}

	// 不显示
	if (m_pkActionWordImage)
	{
		m_pkParent->RemoveChild(m_pkActionWordImage, true);
		m_pkActionWordImage = NULL;
	}
}

void Fighter::setDieOK(bool bOK)
{
	if (m_pkActionWordImage && m_pkActionWordImage->GetParent())
	{
		m_pkActionWordImage->RemoveFromParent(true);
		m_pkActionWordImage = NULL;
	}

	m_bIsDieOK = bOK;
}

void Fighter::drawHurtNumber()
{

	drawHPMP();
	if (m_vHurtNum.size() <= 0)
	{
		return;
	}

	bool bEraseHurtNum = false;

	{
		HurtNumber& hn = m_vHurtNum.at(0);

		int w = GetNumBits(abs(hn.getHurtNum())) * 11;

		if (hn.isNew())
		{
			hn.beginAppear();

			// 初始化去血提示
			if (hn.getHurtNumberY() > 0)
			{

				//m_imgHurtNum = new ImageNumber; ///< 临时性注释 郭浩
				//m_imgHurtNum->Initialization(); ///< 临时性注释 郭浩

				if (m_bHardAtk)
				{
					NDPicture* picBaoJi = m_pkParent->GetBaoJiPic();
					m_pkCritImage = new NDUIImage;
					m_pkCritImage->Initialization();
					m_pkCritImage->SetPicture(picBaoJi);
					m_pkParent->AddChild(m_pkCritImage);

					//m_imgHurtNum->SetBigRedNumber(hn.getHurtNum(), false); ///< 临时性注释 郭浩

				}
				else
				{

					/***
					 * 临时性注释 郭浩
					 * begin
					 */
// 					if (hn.getHurtNum() > 0)
// 					{ // 加血
// 						m_imgHurtNum->SetBigGreenNumber(hn.getHurtNum(), false);
// 					}
// 					else
// 					{ // 去血
// 						m_imgHurtNum->SetBigRedNumber(hn.getHurtNum(), false);
// 					}
					/***
					 * 临时性注释 郭浩
					 * end
					 */
				}

				//	m_parent->AddChild(m_imgHurtNum); ///< 临时性注释 郭浩
			}
		}

		if (hn.getHurtNumberY() > 0)
		{
			/***
			 * 临时性注释 郭浩
			 */
			//if (m_bHardAtk)
			//{
			//	NDPicture* picBaoJi = m_parent->GetBaoJiPic();
			//	int bjW = picBaoJi->GetSize().width;
			//	int bjH = picBaoJi->GetSize().height;
			//	if (m_imgBaoJi)
			//	{
			//		m_imgBaoJi->SetFrameRect(CGRectMake(x - (bjW >> 1),
			//						    y - m_role->GetHeight() - bjH - hn.getHurtNumberY(),
			//						    bjW,
			//						    bjH));
			//	}
			//	if (m_imgHurtNum)
			//	{
			//		m_imgHurtNum->SetFrameRect(CGRectMake(x - (w >> 1),
			//						      y - m_role->GetHeight() - hn.getHurtNumberY() - bjH * 13 / 20,
			//						      m_imgHurtNum->GetNumberSize().width,
			//						      m_imgHurtNum->GetNumberSize().height));
			//	}
			//	
			//} 
			//else 
			//{
			//	if (m_imgHurtNum) 
			//	{
			//		m_imgHurtNum->SetFrameRect(CGRectMake(x - (w >> 1),
			//						      y - m_role->GetHeight() - hn.getHurtNumberY(),
			//						      m_imgHurtNum->GetNumberSize().width,
			//						      m_imgHurtNum->GetNumberSize().height));
			//	}
			//}
			/***
			 * 临时性注释 郭浩
			 * end
			 */

			hn.timeLost();
			bEraseHurtNum = hn.isDisappear();

		}
	}

	if (bEraseHurtNum)
	{
		m_vHurtNum.erase(m_vHurtNum.begin());
		// 删除去血提示
		if (m_pkCritImage)
		{
			m_pkCritImage->RemoveFromParent(false);
			CC_SAFE_DELETE (m_pkCritImage);
		}
		/***
		 * 临时性注释 郭浩
		 * begin
		 */
// 		if (m_imgHurtNum)
// 		{
// 			m_imgHurtNum->RemoveFromParent(false);
// 			CC_SAFE_DELETE(m_imgHurtNum);
// 		}
		/***
		 * 临时性注释 郭浩
		 * end
		 */
	}
}

void Fighter::drawHPMP()
{
	if (!isAlive())
	{
		return;
	}
	int drawx = m_pkRole->GetPosition().x;
	int drawy = m_pkRole->GetPosition().y;

	drawy -= m_pkRole->GetHeight();

	int w = 30;
	int h = 7;
	int lifew = 0;
//	int manaw=0;

	drawx -= w >> 1;
	if (m_kInfo.nLifeMax == 0)
	{
		lifew = 0;
	}
	else
	{
		if (m_kInfo.nLife >= m_kInfo.nLifeMax)
		{
			lifew = w - 4;
		}
		else
		{
			lifew = m_kInfo.nLife * (w - 4) / m_kInfo.nLifeMax;
		}

		if (lifew == 0)
		{
			if (m_kInfo.nLife == 0)
			{
				lifew = 0;
			}
			else
			{
				lifew = 1;
			}
		}
	}

//	if(m_info.nLifeMax==0){
//		manaw=0;
//	}else{
//		manaw = m_info.nMana * (w - 4) / m_info.nManaMax;
//		if (manaw == 0) {
//			if (m_info.nMana == 0) {
//				manaw = 0;
//			} else {
//				manaw = 1;
//			}
//		}
//	}

//	DrawRecttangle(CGRectMake(drawx, drawy, w, h), ccc4(247, 227, 231, 255));
//	DrawRecttangle(CGRectMake(drawx + 1, drawy + 1, w - 2, h - 2), ccc4(57, 0, 41, 255));

	/***
	 * 临时性注释 郭浩
	 * begin
	 */
// 	DrawRecttangle(CGRectMake(drawx + 2, drawy + 2, w - 4, h - 4), ccc4(148, 65, 74, 255));
// 	DrawRecttangle(CGRectMake(drawx + 2, drawy + 2, lifew, h - 4), ccc4(237, 83, 15, 255));
	/***
	 * 临时性注释 郭浩
	 * end
	 */
}

void Fighter::clearFighterStatus()
{
	m_vPasStatus.clear();
	m_vTarget.clear();
	m_kArrayStatusTarget.clear();
	BattleSkill bs;
	m_kUseSkill = bs;
}

int Fighter::getAPasStatus()
{
	int result = 0;

	VEC_PAS_STASUS_IT it = m_vPasStatus.begin();

	if (it != m_vPasStatus.end())
	{
		result = *it;
		m_vPasStatus.erase(it);
	}

	return result;
}

// 0-add, 1-remove
/*void Fighter::handleStatusPersist(int type, int dwdata) {
 int skillId = dwdata / 100;
 string str = "";
 switch (skillId) {
 case 111201:// 穿心剑
 case 131201:// 割裂
 str = "滴血";
 break;
 case 111202:// 破甲箭
 str = "破防";
 break;
 case 111102:// 火云刀
 case 121003:// 地狱鬼火
 str = "燃烧";
 break;
 case 111001:// 狮吼功
 str = "攻UP";
 break;
 case 111002:// 盾墙术
 str = "防UP";
 break;
 case 131402:// 一箭封喉
 str = "减速";
 break;
 case 131202:// 钝化
 str = "降敏";
 break;
 case 131001:// 隐遁
 str = "隐遁";
 break;
 case 121005:// 恢复
 str = "恢复";
 break;
 case 121006:// 神之祝福
 str = "神祝";
 break;

 }
 if (type == 0) {
 m_setStatusPersist.insert(str);
 } else if (type == 1) {
 m_setStatusPersist.erase(str);
 }
 }*/

void Fighter::removeAStatusAniGroup(FighterStatus* status)
{

	if (status->m_nLastEffectID == 404)
	{			// 隐身特殊处理
		isVisibleStatus = true;
		m_strMsgStatus = "";
		m_pkParent->RemoveChild(TAG_HOVER_MSG, true);
	}

	for (VEC_FIGHTER_STATUS_IT it = m_vBattleStatusList.begin();
			it != m_vBattleStatusList.end(); it++)
	{
		if ((*it)->m_nID == status->m_nID)
		{
			CC_SAFE_DELETE(*it);
			m_vBattleStatusList.erase(it);
			return;
		}
	}
}

void Fighter::setWillBeAtk(bool bSet)
{
	m_bWillBeAttack = bSet;

	if (bSet)
	{
//		NDPicture* pic = m_parent->GetBojiPic();
//		bool bReverse = m_info.group == BATTLE_GROUP_ATTACK;
//		pic->SetReverse(bReverse);
//		
//		CGRect rect = CGRectMake(x + m_role->GetWidth() / 2 + 5,
//					 y - 15,
//					 pic->GetSize().width,
//					 pic->GetSize().height);
//		
//		if (bReverse) {
//			rect.origin.x = rect.origin.x - m_role->GetWidth() - 10;
//		}
//		
//		if (!m_imgBoji) {
//			m_imgBoji = new NDUIImage;
//			m_imgBoji->Initialization();
//			m_parent->AddChild(m_imgBoji);
//		}
//		m_imgBoji->SetPicture(pic);
//		m_imgBoji->SetFrameRect(rect);

	}
	else
	{
//		if (m_imgBoji) {
//			m_imgBoji->RemoveFromParent(true);
//			m_imgBoji = NULL;
//		}
	}
}

void Fighter::addAStatus(FighterStatus* fs)
{
//	if (!fs) {
//		return;
//	}

//	int idSub = (fs.m_LastEffectID / 10000) % 1000;

//	NDAnimationGroup* effect;
	if (fs->m_nLastEffectID == 404)
	{
		// 隐身特殊处理
		isVisibleStatus = false;
		m_strMsgStatus = NDCommonCString("YingSheng");
		showHoverMsg(m_strMsgStatus.c_str());
	}

	NDLog("add a status");
	m_vBattleStatusList.push_back(fs);
}

void Fighter::setOnline(bool bOnline)
{
	if (bOnline)
	{
		if (!m_strMsgStatus.empty())
		{
			showHoverMsg(m_strMsgStatus.c_str());
		}
		else
		{
			m_pkParent->RemoveChild(TAG_HOVER_MSG, true);
		}
	}
	else
	{
		showHoverMsg(NDCommonCString("leave"));
	}
}

void Fighter::showHoverMsg(const char* str)
{
	NDUILabel* lbHover = (NDUILabel*) m_pkParent->GetChild(TAG_HOVER_MSG);
	if (!lbHover)
	{
		CGPoint pt = m_pkRole->GetPosition();
		lbHover = new NDUILabel;
		lbHover->Initialization();
		lbHover->SetFontColor(ccc4(0, 255, 100, 255));
		CGSize sizeStr = getStringSize(str, DEFAULT_FONT_SIZE);
		lbHover->SetTag(TAG_HOVER_MSG);
		lbHover->SetFrameRect(
				CGRectMake(pt.x - sizeStr.width / 2, pt.y - m_pkRole->GetHeight(),
						sizeStr.width, sizeStr.height));
		m_pkParent->AddChild(lbHover);
	}
	lbHover->SetText(str);
}

void Fighter::drawRareMonsterEffect(bool bVisible)
{
	// 稀有怪光环
	if (m_kInfo.fighterType == Fighter_TYPE_RARE_MONSTER && m_pkRole
			&& m_pkRole->GetParent())
	{
//		if (!m_rareMonsterEffect) 
//		{
//			m_rareMonsterEffect = new NDSprite;
//			m_rareMonsterEffect->Initialization(GetAniPath("effect_4001.spr"));
//			m_rareMonsterEffect->SetCurrentAnimation(0, false);
//			m_role->GetParent()->AddChild(m_rareMonsterEffect);
//
//		}
//		
//		m_rareMonsterEffect->SetPosition(ccp(x,y));
//			
//		m_rareMonsterEffect->RunAnimation(isVisibleStatus);
	}
	else
	{
		SAFE_DELETE_NODE (m_pkRareMonsterEffect);
	}
}
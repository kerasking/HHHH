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
using namespace NDEngine;

const int LEFT_BACK_X = 120; // 左边后排 x 坐标
const int LEFT_FRONT_X = 160; // 左边前排 x 坐标
const int RIGHT_FRONT_X = 320; // 右边后排 x 坐标
const int RIGHT_BACK_X = 360; // 右边前排 x 坐标

const int POS_INTERVAL_Y = 53; // y 轴间隔

const int STEP = 64;

Fighter::Fighter(const FIGHTER_INFO& fInfo)
{
	m_imgActionWord = NULL;

	m_ptRoleInParent = CGPointMake(0.0f, 0.0f);
	m_roleParent = NULL;
	m_role = NULL;
	m_bRoleShouldDelete = false;
	m_atkPoint = 0;
	m_defPoint = 0;
	m_disPoint = 0;
	m_info = fInfo;
	m_normalAtkType = ATKTYPE_NEAR;
//	m_effectType = EFFECT_TYPE_NONE;
	m_mainTarget = NULL;
	m_actor = NULL;
	m_bMissAtk = false;
	m_bHardAtk = false;
	m_bDefenceAtk = false;
	m_bFleeNoDie = false;
	m_bDefenceOK = false;
	beginAction = false;
	m_action = WAIT;
	m_actionType = ACTION_TYPE_NORMALATK;
//	m_changeLifeType = EFFECT_CHANGE_LIFE_TYPE_NONE;
//	m_changeLifeTypePas = EFFECT_CHANGE_LIFE_TYPE_NONE;
	m_idUsedItem = ID_NONE;
	m_actionTime = 0;
	escape = false;
	alive = true;
	willBeAtk = false;
	m_parent = NULL;

	x = 0;
	y = 0;
	originX = 0;
	originY = 0;

	isVisibleStatus = true;

	dodgeOK = false;
	hurtOK = false;
	dieOK = false;
	defenceOK = false;
	addLifeOK = false;
	actionOK = true;
	statusPerformOK = false;
	statusOverOK = false;
	m_bShowName = false;
	lb_skillName = NULL;
	lb_FighterName = NULL;
//	m_imgHurtNum = NULL; ///< 临时性注释 郭浩
	m_imgBaoJi = NULL;
	m_imgBoji = NULL;
	this->skillAtkType = ATKTYPE_NEAR;

	protectTarget = NULL;
	protector = NULL;
	hurtInprotect = 0;

	m_rareMonsterEffect = NULL;
}

void Fighter::releaseStatus()
{
	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin();
			it != battleStatusList.end(); it++)
	{
		CC_SAFE_DELETE(*it);
	}
	battleStatusList.clear();
}

Fighter::~Fighter()
{
	this->releaseStatus();

	if (m_role)
	{
		m_role->RemoveFromParent(false);
	}

	if (m_bRoleShouldDelete)
	{
		CC_SAFE_DELETE (m_role);
	}

	if (m_role && m_roleParent)
	{
		m_role->SetPositionEx(m_ptRoleInParent);
		m_roleParent->AddChild(m_role);
		if (m_role->IsKindOfClass(RUNTIME_CLASS(NDManualRole)))
		{
			NDManualRole* role = (NDManualRole*)m_role;
			role->SetAction(false);
		}
	}

//	CC_SAFE_DELETE(m_imgHurtNum); ///< 临时性注释 郭浩
	CC_SAFE_DELETE (m_imgBaoJi);
	CC_SAFE_DELETE (m_imgBoji);
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
		//		NDLog("x:%d,y:%d",this->originX,this->originY);
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
		//		NDLog("x:%d,y:%d",this->originX,this->originY);
	}
}

void Fighter::setPosition(int teamAmout)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
//	int st=this->m_info.btStations-1;
//	int team=this->m_info.btBattleTeam-1;
	this->originX = countX(teamAmout, this->m_info.group, m_info.btBattleTeam,
			this->m_info.btStations);
	this->originY = countY(teamAmout, this->m_info.group, m_info.btBattleTeam,
			this->m_info.btStations);

//	if (m_info.fighterType == FIGHTER_TYPE_MONSTER || m_info.fighterType == FIGHTER_TYPE_ELITE_MONSTER) {// 怪物的话，要错开站位
//		if (this->m_info.line == BATTLE_LINE_BACK) // 后排
//		{
//			this->originY -= 8;
//		}
//		else // 前排
//		{
//			this->originY += 8;
//		}
//	}

	this->x = this->originX;
	this->y = this->originY;
}

//void Fighter::AddCommand(FIGHTER_CMD* cmd)
//{
//	m_vCmdList.push_back(cmd);
//}

void Fighter::updatePos()
{
	this->m_role->SetPositionEx(ccp(this->x, this->y));
	if (!isVisibleStatus)
	{
		NDUILabel* lbHover = (NDUILabel*) this->m_parent->GetChild(
				TAG_HOVER_MSG);
		if (lbHover)
		{
			CGSize sizeStr = getStringSize(lbHover->GetText().c_str(),
					DEFAULT_FONT_SIZE);
			lbHover->SetFrameRect(
					CGRectMake(x - sizeStr.width / 2, y - m_role->GetHeight(),
							sizeStr.width, sizeStr.height));
		}
	}
	//NDUILabel* lbName = (NDUILabel*)this->m_parent->GetChild(TAG_FIGHTER_NAME);
	if (this->lb_FighterName)
	{
		CGSize sizeStr = getStringSize(lb_FighterName->GetText().c_str(),
				DEFAULT_FONT_SIZE);
		this->lb_FighterName->SetFrameRect(
				CGRectMake(x - sizeStr.width / 2,
						y - m_role->GetHeight() - sizeStr.height, sizeStr.width,
						sizeStr.height));
	}

	if (lb_skillName)
	{
		CGPoint pt = this->m_role->GetPosition();
		CGSize sizeStr = getStringSize(lb_skillName->GetText().c_str(),
				DEFAULT_FONT_SIZE);
		lb_skillName->SetFrameRect(
				CGRectMake(pt.x + (m_role->GetWidth() / 2),
						pt.y - (m_role->GetHeight() / 2) - sizeStr.height,
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
	beginAction = false;
	m_action = WAIT;

	m_actionTime = 0;
	escape = false;
	alive = true;
	willBeAtk = false;

	dodgeOK = false;
	hurtOK = false;
	dieOK = false;
	defenceOK = false;
	addLifeOK = false;
	actionOK = true;
	statusPerformOK = false;
	statusOverOK = false;
	m_bShowName = false;

	m_info.nLife = m_info.original_life;
	GetRole()->m_nLife = m_info.nLife;
	GetRole()->m_nMaxLife = m_info.nLifeMax;
	GetRole()->m_nMana = m_info.nMana;
	GetRole()->m_nMaxMana = m_info.nManaMax;
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
	m_role = role;
	m_role->m_name = name;
	m_role->m_nLevel = lev;
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
	m_role = role;
	m_lookfaceType = LOOKFACE_MANUAL;
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

	fighter_name = name;
	m_role->m_name = name;
	m_role->m_nLevel = lev;

	//this->m_info.bRoleMonster = role->m_bRoleMonster;
}

/*void Fighter::GetCurSubAniGroup(VEC_SAG& sagList)
 {
 VEC_SAG allSagList;
 this->m_role->GetSubAniGroup(allSagList);

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
 if (sag->getId() == this->getUseSkill()->getSubAniID()) {
 if (sag->getType() == SUB_ANI_TYPE_SELF) {
 sag->fighter = this;
 sagList.push_back(sag);
 bAdd = true;
 } else if (sag->getType() == SUB_ANI_TYPE_TARGET) {

 VEC_FIGHTER& array = this->getArrayTarget();
 if (array.size() == 0) {// 如果没有目标数组，则制定目标为mainTarget
 sag->fighter = this->m_mainTarget;
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
	m_role->RunAnimation(isVisibleStatus);
	RunBattleSubAnimation(m_role, this);
	this->drawStatusAniGroup();
}

void Fighter::drawStatusAniGroup()
{
	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin();
			it != battleStatusList.end(); it++)
	{
		if ((*it)->m_aniGroup)
		{
			NDSprite* role = (*it)->m_aniGroup->role;
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
	this->m_role = role;

	m_roleParent = role->GetParent();
	m_ptRoleInParent = role->GetPosition();

	if (m_roleParent)
	{
		role->RemoveFromParent(false);
	}

	switch (role->GetWeaponType())
	{
	case TWO_HAND_BOW:
		this->m_normalAtkType = ATKTYPE_DISTANCE;
		break;
	case DUAL_SWORD:
	case TWO_HAND_WAND:
	case TWO_HAND_WEAPON:
	case ONE_HAND_WEAPON:
	case WEAPON_NONE:
	case DUAL_KNIFE:
		this->m_normalAtkType = ATKTYPE_NEAR;
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
	arrayStatusTarget.push_back(f);
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
//	if (this->isVisiable()) {
//		ret = m_info.catchFlag > 0 ? true : false;
//	}
	return false;
}

void Fighter::setEscape(bool esc)
{
	this->escape = esc;
	if (m_imgActionWord)
	{
		m_imgActionWord->RemoveFromParent(true);
		m_imgActionWord = NULL;
	}
}

bool Fighter::isVisiable()
{
	bool result = false;

//	if (this->m_info.fighterType == FIGHTER_TYPE_PET) {
//		if (escape) {
//			result = false;
//		} else {
//			result = true;
//		}
//	} else {
	if (escape || !alive)
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

	if (this->m_actionTime >= 20)
	{
		result = true;
	}
	return result;
}

bool Fighter::moveTo(int tx, int ty)
{

	bool arrive = false;

	if (abs(x - tx) < STEP)
	{
		x = tx;

	}
	else
	{
		if (x > tx)
		{
			x -= STEP;
		}
		else
		{
			x += STEP;
		}
	}

	if (abs(y - ty) < STEP)
	{
		y = ty;
	}
	else
	{
		if (y > ty)
		{
			y -= STEP;
		}
		else
		{
			y += STEP;
		}
	}

	if (x == tx && y == ty)
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

	this->m_vHurtNum.push_back(num);
}

void Fighter::setCurrentHP(int hp)
{
	if (hp <= 0)
	{
		m_info.nLife = 0;
	}
	else if (hp > m_info.nLifeMax)
	{
		m_info.nLife = m_info.nLifeMax;
	}
	else
	{
		m_info.nLife = hp;
	}

	int currentId = BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if (currentId == m_info.idObj)
	{
		//ScriptMgrObj.excuteLuaFunc("UpdateHp","FighterInfo",m_info.nLife,m_info.nLifeMax); ///< 临时性注释 郭浩
	}
}

void Fighter::setCurrentMP(int mp)
{
	if (mp <= 0)
	{
		m_info.nMana = 0;
	}
	else if (mp > m_info.nManaMax)
	{
		m_info.nMana = m_info.nManaMax;
	}
	else
	{
		m_info.nMana = mp;
	}

	int currentId = BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if (currentId == m_info.idObj)
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
			CGPoint pt = this->m_role->GetPosition();
			this->lb_FighterName = new NDUILabel;
			this->lb_FighterName->Initialization();
			//this->lb_FighterName->SetTag(TAG_FIGHTER_NAME);
			this->lb_FighterName->SetFontColor(ccc4(255, 255, 255, 255));
			this->lb_FighterName->SetText(GetRole()->m_name.c_str());
			this->lb_FighterName->SetFontSize(DEFAULT_FONT_SIZE);
			CGSize sizefighterName = getStringSize(GetRole()->m_name.c_str(),
					DEFAULT_FONT_SIZE);
			//fighterName->SetTag(TAG_FIGHTER_NAME);
			lb_FighterName->SetFrameRect(
					CGRectMake(pt.x - sizefighterName.width / 2,
							pt.y - m_role->GetHeight() - sizefighterName.height,
							sizefighterName.width, sizefighterName.height));
			this->m_parent->AddChild(this->lb_FighterName);
		}
	}
	else
	{
		if (lb_FighterName)
		{
			this->lb_FighterName->RemoveFromParent(true);
			this->lb_FighterName = NULL;
		}
	}
	m_bShowName = b;
}

void Fighter::showSkillName(bool b)
{
	if (b)
	{
		CGPoint pt = this->m_role->GetPosition();
		lb_skillName = new NDUILabel;
		lb_skillName->Initialization();
		lb_skillName->SetFontColor(ccc4(254, 3, 9, 255));
		lb_skillName->SetText(m_strSkillName.c_str());
		CGSize sizeSkillName = getStringSize(m_strSkillName.c_str(),
				DEFAULT_FONT_SIZE);
		//lb_skillName->SetTag(TAG_SKILL_NAME);
		lb_skillName->SetFontSize(DEFAULT_FONT_SIZE);
		lb_skillName->SetFrameRect(
				CGRectMake(pt.x + (m_role->GetWidth() / 2),
						pt.y - (m_role->GetHeight() / 2) - sizeSkillName.height,
						sizeSkillName.width, sizeSkillName.height));
		this->m_parent->AddChild(lb_skillName);
	}
	else
	{
		if (lb_skillName)
		{
			this->lb_skillName->RemoveFromParent(true);
			lb_skillName = NULL;
		}
	}
}

void Fighter::showActionWord(ACTION_WORD index)
{
	if (m_imgActionWord)
	{
		return;
	}

	NDPicture* pic = NULL;
	switch (index)
	{
	case AW_DEF:
		pic = (this->m_parent->getActionWord(AW_DEF));
		break;
	case AW_FLEE:
		pic = (this->m_parent->getActionWord(AW_FLEE));
		break;
	case AW_DODGE:
		pic = (this->m_parent->getActionWord(AW_DODGE));
		break;
	default:
		break;
	}

	if (!pic)
	{
		return;
	}

	CGSize size = pic->GetSize();

	m_imgActionWord = new NDUIImage;
	m_imgActionWord->Initialization();
	m_imgActionWord->SetPicture(pic);
	m_imgActionWord->SetFrameRect(
			CGRectMake(this->x - size.width / 2, this->y - m_role->GetHeight(),
					size.width, size.height));
	this->m_parent->AddChild(m_imgActionWord);
}

void Fighter::drawActionWord()
{
	//if (!this->m_role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
//	{
//		NDLog("dfdsfdsf");
//	}
	if (this->isAlive())
	{
		switch (this->m_action)
		{
		case FLEE_FAIL:
		case FLEE_SUCCESS:
			if (isBeginAction() && !isActionOK())
			{
				this->showActionWord(AW_FLEE);
				return;
			}
			break;
		case DEFENCE:
			this->showActionWord(AW_DEF);
			return;
		default:
			break;
		}

		if (this->dodgeOK)		//&& isBeginAction())
		{
			this->showActionWord(AW_DODGE);
			return;
		}

		if (this->defenceOK)
		{
			this->showActionWord(AW_DEF);
			return;
		}
	}

	// 不显示
	if (m_imgActionWord)
	{
		this->m_parent->RemoveChild(m_imgActionWord, true);
		m_imgActionWord = NULL;
	}
}

void Fighter::setDieOK(bool bOK)
{
	if (m_imgActionWord && m_imgActionWord->GetParent())
	{
		m_imgActionWord->RemoveFromParent(true);
		m_imgActionWord = NULL;
	}

	this->dieOK = bOK;
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
					NDPicture* picBaoJi = this->m_parent->GetBaoJiPic();
					m_imgBaoJi = new NDUIImage;
					m_imgBaoJi->Initialization();
					m_imgBaoJi->SetPicture(picBaoJi);
					this->m_parent->AddChild(m_imgBaoJi);

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

				//	this->m_parent->AddChild(m_imgHurtNum); ///< 临时性注释 郭浩
			}
		}

		if (hn.getHurtNumberY() > 0)
		{
			/***
			 * 临时性注释 郭浩
			 */
			//if (m_bHardAtk)
			//{
			//	NDPicture* picBaoJi = this->m_parent->GetBaoJiPic();
			//	int bjW = picBaoJi->GetSize().width;
			//	int bjH = picBaoJi->GetSize().height;
			//	if (m_imgBaoJi)
			//	{
			//		m_imgBaoJi->SetFrameRect(CGRectMake(this->x - (bjW >> 1),
			//						    y - m_role->GetHeight() - bjH - hn.getHurtNumberY(),
			//						    bjW,
			//						    bjH));
			//	}
			//	if (m_imgHurtNum)
			//	{
			//		m_imgHurtNum->SetFrameRect(CGRectMake(this->x - (w >> 1),
			//						      this->y - m_role->GetHeight() - hn.getHurtNumberY() - bjH * 13 / 20,
			//						      m_imgHurtNum->GetNumberSize().width,
			//						      m_imgHurtNum->GetNumberSize().height));
			//	}
			//	
			//} 
			//else 
			//{
			//	if (m_imgHurtNum) 
			//	{
			//		m_imgHurtNum->SetFrameRect(CGRectMake(this->x - (w >> 1),
			//						      this->y - m_role->GetHeight() - hn.getHurtNumberY(),
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
		if (m_imgBaoJi)
		{
			m_imgBaoJi->RemoveFromParent(false);
			CC_SAFE_DELETE (m_imgBaoJi);
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
	int drawx = this->m_role->GetPosition().x;
	int drawy = this->m_role->GetPosition().y;

	drawy -= this->m_role->GetHeight();

	int w = 30;
	int h = 7;
	int lifew = 0;
//	int manaw=0;

	drawx -= w >> 1;
	if (this->m_info.nLifeMax == 0)
	{
		lifew = 0;
	}
	else
	{
		if (this->m_info.nLife >= this->m_info.nLifeMax)
		{
			lifew = w - 4;
		}
		else
		{
			lifew = this->m_info.nLife * (w - 4) / this->m_info.nLifeMax;
		}

		if (lifew == 0)
		{
			if (this->m_info.nLife == 0)
			{
				lifew = 0;
			}
			else
			{
				lifew = 1;
			}
		}
	}

//	if(this->m_info.nLifeMax==0){
//		manaw=0;
//	}else{
//		manaw = this->m_info.nMana * (w - 4) / this->m_info.nManaMax;
//		if (manaw == 0) {
//			if (this->m_info.nMana == 0) {
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
	this->m_vPasStatus.clear();
	this->m_vTarget.clear();
	this->arrayStatusTarget.clear();
	BattleSkill bs;
	this->useSkill = bs;
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

	if (status->m_LastEffectID == 404)
	{			// 隐身特殊处理
		isVisibleStatus = true;
		strMsgStatus = "";
		this->m_parent->RemoveChild(TAG_HOVER_MSG, true);
	}

	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin();
			it != this->battleStatusList.end(); it++)
	{
		if ((*it)->m_id == status->m_id)
		{
			CC_SAFE_DELETE(*it);
			battleStatusList.erase(it);
			return;
		}
	}
}

void Fighter::setWillBeAtk(bool bSet)
{
	this->willBeAtk = bSet;

	if (bSet)
	{
//		NDPicture* pic = this->m_parent->GetBojiPic();
//		bool bReverse = this->m_info.group == BATTLE_GROUP_ATTACK;
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
//		if (!this->m_imgBoji) {
//			this->m_imgBoji = new NDUIImage;
//			m_imgBoji->Initialization();
//			this->m_parent->AddChild(m_imgBoji);
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
	if (fs->m_LastEffectID == 404)
	{
		// 隐身特殊处理
		isVisibleStatus = false;
		this->strMsgStatus = NDCommonCString("YingSheng");
		this->showHoverMsg(strMsgStatus.c_str());
	}

	NDLog("add a status");
	this->battleStatusList.push_back(fs);
}

void Fighter::setOnline(bool bOnline)
{
	if (bOnline)
	{
		if (!this->strMsgStatus.empty())
		{
			this->showHoverMsg(strMsgStatus.c_str());
		}
		else
		{
			this->m_parent->RemoveChild(TAG_HOVER_MSG, true);
		}
	}
	else
	{
		this->showHoverMsg(NDCommonCString("leave"));
	}
}

void Fighter::showHoverMsg(const char* str)
{
	NDUILabel* lbHover = (NDUILabel*) this->m_parent->GetChild(TAG_HOVER_MSG);
	if (!lbHover)
	{
		CGPoint pt = this->m_role->GetPosition();
		lbHover = new NDUILabel;
		lbHover->Initialization();
		lbHover->SetFontColor(ccc4(0, 255, 100, 255));
		CGSize sizeStr = getStringSize(str, DEFAULT_FONT_SIZE);
		lbHover->SetTag(TAG_HOVER_MSG);
		lbHover->SetFrameRect(
				CGRectMake(pt.x - sizeStr.width / 2, pt.y - m_role->GetHeight(),
						sizeStr.width, sizeStr.height));
		this->m_parent->AddChild(lbHover);
	}
	lbHover->SetText(str);
}

void Fighter::drawRareMonsterEffect(bool bVisible)
{
	// 稀有怪光环
	if (m_info.fighterType == Fighter_TYPE_RARE_MONSTER && m_role
			&& m_role->GetParent())
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
		SAFE_DELETE_NODE (m_rareMonsterEffect);
	}
}

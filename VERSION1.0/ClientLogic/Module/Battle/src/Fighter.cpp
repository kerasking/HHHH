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
#include "NDPath.h"
#include "ScriptMgr.h"
#include "ObjectTracker.h"

using namespace NDEngine;

// const int LEFT_BACK_X = 120; // 左边后排 x 坐标
// const int LEFT_FRONT_X = 160; // 左边前排 x 坐标
// const int RIGHT_FRONT_X = 320; // 右边后排 x 坐标
// const int RIGHT_BACK_X = 360; // 右边前排 x 坐标
// 
// const int POS_INTERVAL_Y = 53; // y 轴间隔

const int STEP = 64;
//++Guosen 2012.6.29//
// 7 4 1    1 4 7
// 8 5 2    2 5 8
// 9 6 3    3 6 9
// g d a    a d g
// h e b    b e h
// i f c    c f i
//设置作战位置时的偏移// a,b,c~g,h,i为施放移位技能后，各军移动的位置
//以下坐标点是960*640时算出的位置  x=480±g_iXOffset[pos]
static int g_iXOffset[] = { //
	//3*3 九宫格
	//160, 160, 160,
	//280, 280, 280,
	//400, 400, 400,
	//-透视
	100, 130, 160,
	220, 250, 280,
	340, 370, 400,
	120, 150, 180,//新增各军移动的位置
	240, 270, 300,
	360, 390, 420,
};
//y=g_iYOffset[pos]
static int g_iYOffset[] = { //
	//3*3 九宫格
	//360, 480, 600, 
	//360, 480, 600, 
	//360, 480, 600, 
	//-透视
	390, 480, 600, 
	390, 480, 600, 
	390, 480, 600, 
	410, 500, 620,//新增各军移动的位置
	410, 500, 620, 
	410, 500, 620,
};
//状态小图标宽高
#define STATUS_ICON_WIDTH		(32)
#define STATUS_ICON_HEIGHT		(32)

//交战者血条/气条的宽高
#define HP_BAR_WIDTH	(120-STATUS_ICON_WIDTH)
#define HP_BAR_HEIGHT	(12-4)

#define STATUS_ICON_IMAGE		"Res00/StatusIcons1.png"

#define HP_BAR_FRO_IMAGE		"Res00/General/line/icon_TGauge4.png"
#define MP_BAR_FRO_IMAGE		"Res00/General/line/icon_TGauge5.png"
#define HPMP_BAR_BG_IMAGE		"Res00/General/line/icon_TGauge3.png"

//===========================================================================
Fighter::Fighter()
{
	INC_NDOBJ("Fighter");

	m_pkActionWordImage = NULL;

	m_kRoleInParentPoint = CCPointMake(0.0f, 0.0f);
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
	m_pkImgHurtNum = NULL;
	m_pkCritImage = NULL;
	m_pkBojiImage = NULL;
	m_eSkillAtkType = ATKTYPE_NEAR;

	m_pkProtectTarget = NULL;
	m_pkProtector = NULL;
	m_nHurtInprotect = 0;

	m_pkRareMonsterEffect = NULL;
	
	mana_full_ani=NULL;
	dritical_ani=NULL;
	dodge_ani=NULL;
	block_ani=NULL;
	m_bIsCriticalHurt=false;
	m_bIsAtkDritical=false;
	m_bIsDodge=false;
	m_bIsBlock=false;
	m_nRoleInitialHeight	= 0;
	m_iIconsXOffset			= 0;
	m_pHPBar				= NULL;
	m_pMPBar				= NULL;
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
	DEC_NDOBJ("Fighter");

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

	CC_SAFE_DELETE(m_pkImgHurtNum);
	CC_SAFE_DELETE (m_pkCritImage);
	CC_SAFE_DELETE (m_pkBojiImage);
}

//++Guosen 2012.6.29//计算交战者位置的X坐标
int countY(int teamAmount,BATTLE_GROUP group,int t,int pos ){
	//	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	//    int wsh = winsize.height;
	//    winsize.height /= 2;
	//	int st=pos-1;
	//	int team=t-1;
	//	if(teamAmount<=2){
	//		
	//		float h=winsize.height*5/6;
	//        int ti = winsize.height/6+h/4+(h/4)*(st%3);
	//		return wsh-ti;
	//
	//	}else{
	//		float teamH=(winsize.height-winsize.height/10-5)/3;
	//		float teamY=winsize.height/10+5+teamH*(team%3);
	//		
	//		 return winsize.height-teamY+teamH/4+teamH/4*(st%3);
	//		
	//		float teamW=winsize.width*2/9;
	//		float teamOffset=teamW/4;
	//		//		NDLog(@"team:%d,pos:%d",team,st);
	//		//		NDLog(@"x:%d,y:%d",this->originX,this->originY);
	//	}
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	int iY			= g_iYOffset[pos-1];
	return iY*winsize.height/640;
}

//++Guosen 2012.6.29//计算交战者位置的Y坐标
int countX(int teamAmount,BATTLE_GROUP group,int t,int pos ){
	//	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	//	int st=pos-1;
	//	int team=t-1;
	//	if(teamAmount<=2){
	//
	//		
	//		if (group == BATTLE_GROUP_ATTACK) // 左边
	//		{
	//			return winsize.width/2-winsize.width/8-winsize.width/8*(st/3);
	//		}
	//		else // 右边
	//		{
	//			return winsize.width/2+winsize.width/8+winsize.width/8*(st/3);
	//		}
	//	}else{
	//
	//		float teamW=winsize.width*2/9;
	//		float teamOffset=teamW/4;
	//		if (group == BATTLE_GROUP_ATTACK) // 左边
	//		{
	//			
	//			float teamX=teamOffset*(team%3);
	//			
	//			return teamX+teamW-teamW/4-teamW/4*(st/3);
	//		}
	//		else // 右边
	//		{
	//			float teamX=teamW+teamW*0.8+teamW*(team/3)+teamOffset*(team%3);
	//			
	//			return teamX+teamW/4+teamW/4*(st/3);
	//			
	//		}
	//		//		NDLog(@"team:%d,pos:%d",team,st);
	//		//		NDLog(@"x:%d,y:%d",this->originX,this->originY);
	//	}
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	int iXOffset	= g_iXOffset[pos-1];
	int iX			= 0;
	if (group == BATTLE_GROUP_ATTACK) // 左边
	{
		iX = 480 - iXOffset;
	}
	else
	{
		iX = 480 + iXOffset;
	}
	return iX*winsize.width/960;
}

void Fighter::setPosition(int teamAmout)
{
	m_nOriginX = countX(teamAmout, m_kInfo.group, m_kInfo.btBattleTeam, m_kInfo.btStations);
	m_nOriginY = countY(teamAmout, m_kInfo.group, m_kInfo.btBattleTeam, m_kInfo.btStations);

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
		NDUILabel* lbHover = (NDUILabel*)m_pkParent->GetChild(TAG_HOVER_MSG);
		if (lbHover) 
		{
			CCSize sizeStr = getStringSize(lbHover->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
			// 改成固定值
			//lbHover->SetFrameRect(CCRectMake(x - sizeStr.width / 2, y - m_role->GetHeight(), sizeStr.width, sizeStr.height));
			lbHover->SetFrameRect(CCRectMake(m_nX - sizeStr.width / 2, m_nY - m_nRoleInitialHeight, sizeStr.width, sizeStr.height));
		}
	}

	//NDUILabel* lbName = (NDUILabel*)this->m_parent->GetChild(TAG_FIGHTER_NAME);
	if (m_pkFighterNameLabel) 
	{
		CCSize sizeStr = getStringSize(m_pkFighterNameLabel->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);

		// 所有怪物武将的姓名位置改成固定值
		//--this->lb_FighterName->SetFrameRect(CCRectMake(x - sizeStr.width / 2, y - m_role->GetHeight() - sizeStr.height, sizeStr.width, sizeStr.height));
		m_pkFighterNameLabel->SetFrameRect(
			CCRectMake(m_nX - sizeStr.width / 2, 
				m_nY - m_nRoleInitialHeight - sizeStr.height - HP_BAR_HEIGHT - 2, 
					sizeStr.width*FONT_SCALE, sizeStr.height ));
	}

	if (m_pkSkillNameLabel)
	{
		//CCPoint pt = m_pkRole->GetPosition();
		CCSize sizeStr =getStringSize(m_pkSkillNameLabel->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);

		//++Guosen 2012.6.28//设置技能名的显示位置
		//if(this->m_kInfo.group == BATTLE_GROUP_ATTACK)
		//{
		//	lb_skillName->SetFrameRect(CCRectMake(pt.x +(FIGHTER_WIDTH/2), pt.y - (FIGHTER_HEIGHT/2) - sizeStr.height, sizeStr.width, sizeStr.height));
		//}else{
		//	lb_skillName->SetFrameRect(CCRectMake(pt.x -(FIGHTER_WIDTH/2)-sizeStr.width, pt.y - (FIGHTER_HEIGHT/2) - sizeStr.height, sizeStr.width, sizeStr.height));
		//}
		// 所有怪物武将的技能名位置改成固定值
		//--lb_skillName->SetFrameRect(CCRectMake(pt.x-sizeStr.width/2 , pt.y-FIGHTER_HEIGHT-sizeStr.height*2, sizeStr.width, sizeStr.height));

		m_pkSkillNameLabel->SetFrameRect(
			CCRectMake(m_nX-sizeStr.width/2 , 
				m_nY - m_nRoleInitialHeight - HP_BAR_HEIGHT - 2 - sizeStr.height*2, 
					sizeStr.width*FONT_SCALE, sizeStr.height ));
		//++
	}

	UpdateStatusIconsPosition();
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

	m_bIsDodge = false;
	m_bIsCriticalHurt = false;
	m_bIsAtkDritical = false;
	m_bIsBlock = false;

	m_kInfo.nLife = m_kInfo.original_life;
	m_kInfo.nMana = m_kInfo.original_mana;
	GetRole()->m_nLife = m_kInfo.nLife;
	GetRole()->m_nMaxLife = m_kInfo.nLifeMax;
	GetRole()->m_nMana = m_kInfo.nMana;
	GetRole()->m_nMaxMana = m_kInfo.nManaMax;

	mana_full_ani = NULL;
	dritical_ani = NULL;
	dodge_ani = NULL;
	block_ani = NULL;
	//--Guosen 2012.11.22 外部销已毁掉下述控件的父节点，so以下控件指针置空
	m_pkSkillNameLabel		= NULL;
	m_pkFighterNameLabel	= NULL;
	m_pkImgHurtNum			= NULL;
	m_pHPBar				= NULL;
	m_pMPBar				= NULL;
}

void Fighter::LoadEudemon()
{
//	int idLookFace = 0;
//	std::string strName = "";
//	PetInfo* petInfo = PetMgrObj.GetPet(m_kInfo.idPet);
//	if (!petInfo) 
//	{
//		// 其它玩家的
//		Item item(m_kInfo.idType);
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
	role->SetCurrentAnimation(MANUELROLE_BATTLE_STAND, role->m_bFaceRight);
	m_pkRole = role;
	m_pkRole->SetName( name );
	m_pkRole->m_nLevel = lev;
	role->SetNonRole(false);
	m_nRoleInitialHeight = m_pkRole->GetHeight()*RESOURCE_SCALE_960;
	if( this->m_kInfo.group == BATTLE_GROUP_ATTACK )
	{
		m_iIconsXOffset = -HP_BAR_WIDTH/2 - STATUS_ICON_WIDTH;//-m_role->GetWidth()/2 - STATUS_ICON_WIDTH;
	}
	else
	{
		m_iIconsXOffset = HP_BAR_WIDTH/2;//m_role->GetWidth()/2;
	}
}

void Fighter::LoadMonster(int nLookFace, int lev, const string& name)
{
	m_bRoleShouldDelete = true;
	NDManualRole *role = new NDManualRole;
	role->Initialization(nLookFace, true);
	role->SetCurrentAnimation(MANUELROLE_BATTLE_STAND, role->m_bFaceRight);
	role->m_nLookface = nLookFace;
	m_pkRole = role;
	m_eLookfaceType = LOOKFACE_MANUAL;

	m_strFighterName = name;
	m_pkRole->SetName( name );
	m_pkRole->m_nLevel = lev;

	//this->m_kInfo.bRoleMonster = role->m_bRoleMonster;
	m_nRoleInitialHeight = m_pkRole->GetHeight()*RESOURCE_SCALE_960;
	if( this->m_kInfo.group == BATTLE_GROUP_ATTACK )
	{
		m_iIconsXOffset = -HP_BAR_WIDTH/2 - STATUS_ICON_WIDTH;//-m_role->GetWidth()/2 - STATUS_ICON_WIDTH;
	}
	else
	{
		m_iIconsXOffset = HP_BAR_WIDTH/2;//m_role->GetWidth()/2;
	}
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
	m_pkRole->RunBattleSubAnimation(this);
	drawStatusAniGroup();
}

void Fighter::drawStatusAniGroup()
{
	for (VEC_FIGHTER_STATUS_IT it = m_vBattleStatusList.begin(); it != m_vBattleStatusList.end(); it++)
	{
		if ((*it)->m_pkAniGroup)
		{
			NDSprite* role = (*it)->m_pkAniGroup->role;
			if (!role)
			{
				continue;
			}
			role->DrawSubAnimation(*((*it)->m_pkAniGroup));
		}
	}

	if ( m_kInfo.nMana >= m_kInfo.nManaMax )
	{
		if( !mana_full_ani )
		{//气条满，爆气动画
			mana_full_ani = new NDSprite;
			stringstream ss;
			ss << "sm_effect_20.spr";
			mana_full_ani->Initialization((NDPath::GetAniPath(ss.str().c_str())).c_str());
			mana_full_ani->SetCurrentAnimation(0, false);
			m_pkRole->GetParent()->AddChild(mana_full_ani);
            
            //爆气音效
            ScriptMgrObj.excuteLuaFunc("PlayEffectSound", "Music",1018);
            
			NDLog(@"add mana full ani");
		}
		mana_full_ani->SetPosition(ccp(m_nX, m_nY));
		mana_full_ani->RunAnimation(true);
	}
	else if (mana_full_ani)
	{
		NDLog(@"delete mana_full_ani");
		SAFE_DELETE(mana_full_ani);
		mana_full_ani = NULL;
	}
	
	if (m_bIsAtkDritical)
	{
		/*if(!dritical_ani)
		{
			dritical_ani = new NDSprite;
			stringstream ss;
			ss << "sm_effect_" << EFFECT_DRITICAL << ".spr";
			dritical_ani->Initialization(NDPath::GetAniPath(ss.str().c_str()));
			dritical_ani->SetCurrentAnimation(0, false);
			m_role->GetParent()->AddChild(dritical_ani);
			NDLog(@"add dritical ani");
		}
		dritical_ani->SetPosition(ccp(x,y-FIGHTER_HEIGHT));
		dritical_ani->RunAnimation(true);
		if (dritical_ani->IsAnimationComplete())
		{
			isAtkDritical=false;
			NDLog(@"delete dritical_ani");
			SAFE_DELETE(dritical_ani);
			dritical_ani=NULL;
		}*/
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
//		ret = m_kInfo.catchFlag > 0 ? true : false;
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

//	if (m_kInfo.fighterType == FIGHTER_TYPE_PET) {
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
		ScriptMgrObj.excuteLuaFunc("UpdateHp","FighterInfo",m_kInfo.nLife,m_kInfo.nLifeMax);
	}
}

void Fighter::setCurrentMP(int mp)
{
	if (mp <= 0)
	{
		m_kInfo.nMana = 0;
	}
	else
	{
		m_kInfo.nMana = mp;
	}

	int currentId = BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if (currentId == m_kInfo.idObj)
	{
		ScriptMgrObj.excuteLuaFunc("UpdateMp","FighterInfo",m_kInfo.nMana,m_kInfo.nManaMax);
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
			CCPoint pt = m_pkRole->GetPosition();
			m_pkFighterNameLabel = new NDUILabel;
			m_pkFighterNameLabel->Initialization();
			//lb_FighterName->SetTag(TAG_FIGHTER_NAME);

			//** chh 2012-09-05 **//
			//m_pkFighterNameLabel->SetFontColor(ccc4(255, 255, 255, 255));
			ccColor4B cColor4 = ScriptMgrObj.excuteLuaFuncRetColor4("GetColor", "Item", m_kInfo.nQuality);
			m_pkFighterNameLabel->SetFontColor(cColor4);

			m_pkFighterNameLabel->SetText(GetRole()->GetName().c_str());
			m_pkFighterNameLabel->SetFontSize(DEFAULT_FONT_SIZE);
			CCSize sizefighterName = getStringSize(GetRole()->GetName().c_str(), DEFAULT_FONT_SIZE*FONT_SCALE);

			//fighterName->SetTag(TAG_FIGHTER_NAME);
			m_pkFighterNameLabel->SetFrameRect(
					CCRectMake(pt.x - sizefighterName.width / 2,
							pt.y - FIGHTER_HEIGHT - sizefighterName.height,
							sizefighterName.width*FONT_SCALE, sizefighterName.height));
			
			m_pkParent->AddChild(m_pkFighterNameLabel);
			
			//在此创建生命条及士气条空间++Guosen 2012.7.27
			this->m_pHPBar	= new CUIExp;
			std::string szBGImage = NDPath::GetImgPath( HPMP_BAR_BG_IMAGE );
			std::string szHPImage = NDPath::GetImgPath( HP_BAR_FRO_IMAGE );
			std::string szMPImage = NDPath::GetImgPath( MP_BAR_FRO_IMAGE );
			
			//this->m_pHPBar->Initialization( NDPath::GetImgPath( HPMP_BAR_BG_IMAGE ).c_str(), NDPath::GetImgPath( HP_BAR_FRO_IMAGE ).c_str() );
			this->m_pHPBar->Initialization( szBGImage.c_str(), szHPImage.c_str() );
			this->m_pHPBar->SetStyle( 2 );
			this->m_pMPBar	= new CUIExp;
			
			//this->m_pMPBar->Initialization( NDPath::GetImgPath( HPMP_BAR_BG_IMAGE ).c_str(), NDPath::GetImgPath( MP_BAR_FRO_IMAGE ).c_str() );
			this->m_pMPBar->Initialization( szBGImage.c_str(), szMPImage.c_str() );
			this->m_pMPBar->SetStyle( 2 );
			m_pkParent->AddChild(m_pHPBar);
			m_pkParent->AddChild(m_pMPBar);
			
			drawHPMP();
		}
	}
	else
	{
		if (m_pkFighterNameLabel)
		{
			m_pkFighterNameLabel->RemoveFromParent(true);
			m_pkFighterNameLabel = NULL;
		}
		if ( m_pHPBar )
		{
			this->m_pHPBar->RemoveFromParent(true);
			this->m_pHPBar	= NULL;
		}
		if ( m_pMPBar )
		{
			this->m_pMPBar->RemoveFromParent(true);
			this->m_pMPBar	= NULL;
		}
		ClearAllStatusIcons();

	}
	m_bShowName = b;
}

void Fighter::showSkillName(bool b)
{
	if (b)
	{
		CCPoint pt = m_pkRole->GetPosition();
		
		m_pkSkillNameLabel = new NDUILabel;
		m_pkSkillNameLabel->Initialization();
		m_pkSkillNameLabel->SetFontColor(ccc4(0xff, 0xd7, 0, 255));//(ccc4(254, 3, 9, 255));//++Guosen 2012.6.28//设置技能名字体颜色
		m_pkSkillNameLabel->SetText(m_strSkillName.c_str());
		m_pkSkillNameLabel->SetFontSize(DEFAULT_FONT_SIZE);
		
		CCSize sizeSkillName = getStringSize(m_strSkillName.c_str(), DEFAULT_FONT_SIZE*FONT_SCALE);
		
		//++Guosen 2012.6.28//设置技能名的显示位置
		//lb_skillName->SetTag(TAG_SKILL_NAME);
		m_pkSkillNameLabel->SetFrameRect(CCRectMake(pt.x-sizeSkillName.width/2 , pt.y-FIGHTER_HEIGHT-sizeSkillName.height*2, sizeSkillName.width*FONT_SCALE, sizeSkillName.height));
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

//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
// void Fighter::showActionWord(ACTION_WORD index)
// {
// 	if (m_pkActionWordImage)
// 	{
// 		return;
// 	}
// 
// 	NDPicture* pic = NULL;
// 	switch (index)
// 	{
// 	case AW_DEF:
// 		pic = (m_pkParent->getActionWord(AW_DEF));
// 		break;
// 	case AW_FLEE:
// 		pic = (m_pkParent->getActionWord(AW_FLEE));
// 		break;
// 	case AW_DODGE:
// 		pic = (m_pkParent->getActionWord(AW_DODGE));
// 		break;
// 	default:
// 		break;
// 	}
// 
// 	if (!pic)
// 	{
// 		return;
// 	}
// 
// 	CCSize size = pic->GetSize();
// 
// 	m_pkActionWordImage = new NDUIImage;
// 	m_pkActionWordImage->Initialization();
// 	m_pkActionWordImage->SetPicture(pic);
// 	m_pkActionWordImage->SetFrameRect(
// 			CCRectMake(m_nX - size.width / 2, m_nY - m_pkRole->GetHeight(),
// 					size.width, size.height));
// 	m_pkParent->AddChild(m_pkActionWordImage);
// }

//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
// void Fighter::drawActionWord()
// {
// 	//if (!m_role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
// //	{
// //		NDLog("dfdsfdsf");
// //	}
// 	if (isAlive())
// 	{
// 		switch (m_action)
// 		{
// 		case FLEE_FAIL:
// 		case FLEE_SUCCESS:
// 			if (isBeginAction() && !isActionOK())
// 			{
// 				showActionWord(AW_FLEE);
// 				return;
// 			}
// 			break;
// 		case DEFENCE:
// 			showActionWord(AW_DEF);
// 			return;
// 		default:
// 			break;
// 		}
// 
// 		if (m_bIsDodgeOK)		//&& isBeginAction())
// 		{
// 			showActionWord(AW_DODGE);
// 			return;
// 		}
// 
// 		if (m_bIsDefenceOK)
// 		{
// 			showActionWord(AW_DEF);
// 			return;
// 		}
// 	}
// 
// 	// 不显示
// 	if (m_pkActionWordImage)
// 	{
// 		m_pkParent->RemoveChild(m_pkActionWordImage, true);
// 		m_pkActionWordImage = NULL;
// 	}
// }

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

		//int w = GetNumBits(abs(hn.getHurtNum())) * 11;

		if (hn.isNew())
		{
			hn.beginAppear();

			// 初始化去血提示
			if (hn.getHurtNumberY() > 0)
			{
				m_pkImgHurtNum = new ImageNumber;
				m_pkImgHurtNum->Initialization();

				if (m_bHardAtk)
				{
					/*NDPicture* picBaoJi = m_pkParent->GetBaoJiPic();
					m_pkCritImage = new NDUIImage;
					m_pkCritImage->Initialization();
					m_pkCritImage->SetPicture(picBaoJi);
					m_pkParent->AddChild(m_pkCritImage);*/

					m_pkImgHurtNum->SetBigRedNumber(hn.getHurtNum(), false);

				}
				else
				{
					if (hn.getHurtNum() > 0)
					{ // 加血
						m_pkImgHurtNum->SetSmallGreenNumber(hn.getHurtNum(), false);
					}
					else
					{ // 去血
						m_pkImgHurtNum->SetSmallRedNumber(hn.getHurtNum(), false);
					}
				}

				m_pkParent->AddChild(m_pkImgHurtNum);
			}
		}

		if (hn.getHurtNumberY() > 0)
		{
			if (m_bHardAtk)
			{
				/*NDPicture* picBaoJi = m_parent->GetBaoJiPic();
				int bjW = picBaoJi->GetSize().width;
				int bjH = picBaoJi->GetSize().height;
				if (m_imgBaoJi)
				{
					m_imgBaoJi->SetFrameRect(CCRectMake(x - (bjW >> 1),
						y - m_role->GetHeight() - bjH - hn.getHurtNumberY(),
						bjW,
						bjH));
				}*/
				if (m_pkImgHurtNum)
				{
					m_pkImgHurtNum->SetFrameRect(CCRectMake(m_nX - (m_pkImgHurtNum->GetNumberSize().width /2),
						m_nY - m_nRoleInitialHeight- hn.getHurtNumberY()*20,//++Guosen 2012.6.29 固定位置起始 //this->y - m_role->GetHeight() - hn.getHurtNumberY()*20,// - bjH * 13 / 20,
						m_pkImgHurtNum->GetNumberSize().width,
						m_pkImgHurtNum->GetNumberSize().height));
				}

			}
			else
			{
				if (m_pkImgHurtNum) {
					m_pkImgHurtNum->SetFrameRect(CCRectMake(m_nX - (m_pkImgHurtNum->GetNumberSize().width /2),
						m_nY - m_nRoleInitialHeight- hn.getHurtNumberY()*10,//++Guosen 2012.6.29 固定位置起始 //this->y - m_role->GetHeight() - hn.getHurtNumberY()*20,
						m_pkImgHurtNum->GetNumberSize().width,
						m_pkImgHurtNum->GetNumberSize().height));
				}
			}

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
		if (m_pkImgHurtNum)
		{
			m_pkImgHurtNum->RemoveFromParent(false);
			CC_SAFE_DELETE(m_pkImgHurtNum);
		}
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

	drawy -= m_nRoleInitialHeight;//++Guosen 2012.6.29 固定位置//drawy -= this->m_role->GetHeight();

	//战斗时血条的宽高
	int iBarWidth	= HP_BAR_WIDTH;
	int iBarHeight	= HP_BAR_HEIGHT;
	int lifew = 0;
	int manaw = 0;

	drawx -= iBarWidth >> 1;
	if (m_kInfo.nLifeMax == 0)
	{
		lifew = 0;
	}
	else
	{
		if (m_kInfo.nLife > m_kInfo.nLifeMax)
		{
			lifew = iBarWidth;
		}
		else
		{
			lifew = m_kInfo.nLife * ( (float)iBarWidth / (float)m_kInfo.nLifeMax );
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

	if( m_kInfo.nLifeMax == 0 )
	{
		manaw = 0;
	}
	else
	{
		if( m_kInfo.nMana > m_kInfo.nManaMax )
		{
			manaw = iBarWidth;
		}
		else
		{
			manaw = m_kInfo.nMana * ( (float)iBarWidth / (float)m_kInfo.nManaMax );
		}
	}

	//DrawRecttangle( CCRectMake(drawx, drawy, iBarWidth, iBarHeight), ccc4(0xcc, 0x99, 0x33, 255));
	//DrawRecttangle( CCRectMake(drawx, drawy, manaw, iBarHeight), ccc4(0xff, 0xcc, 0, 255));
	//DrawRecttangle( CCRectMake(drawx, drawy - iBarHeight - 2, iBarWidth, iBarHeight ), ccc4(148, 65, 74, 255) );
	//DrawRecttangle( CCRectMake(drawx, drawy - iBarHeight - 2, lifew, iBarHeight ), ccc4(237, 83, 15, 255) );
	if ( m_pMPBar )
	{
		m_pMPBar->SetFrameRect( CCRectMake(drawx, drawy, iBarWidth, iBarHeight) );
		m_pMPBar->SetStart( 0 );
		m_pMPBar->SetProcess( manaw );
		m_pMPBar->SetTotal( iBarWidth );
	}
	if ( m_pHPBar )
	{
		m_pHPBar->SetFrameRect( CCRectMake(drawx, drawy - iBarHeight - 2, iBarWidth, iBarHeight) );
		m_pHPBar->SetStart( 0 );
		m_pHPBar->SetProcess( lifew );
		m_pHPBar->SetTotal( iBarWidth );
	}
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
//		bool bReverse = m_kInfo.group == BATTLE_GROUP_ATTACK;
//		pic->SetReverse(bReverse);
//		
//		CCRect rect = CCRectMake(x + m_role->GetWidth() / 2 + 5,
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
		showHoverMsg(NDCommonCString("leave").c_str());
	}
}

void Fighter::showHoverMsg(const char* str)
{
	NDUILabel* lbHover = (NDUILabel*) m_pkParent->GetChild(TAG_HOVER_MSG);
	if (!lbHover)
	{
		CCPoint pt = m_pkRole->GetPosition();
		lbHover = new NDUILabel;
		lbHover->Initialization();
		lbHover->SetFontColor(ccc4(0, 255, 100, 255));
		
		CCSize sizeStr = getStringSize(str, DEFAULT_FONT_SIZE*FONT_SCALE);
		lbHover->SetTag(TAG_HOVER_MSG);
		lbHover->SetFrameRect(CCRectMake(pt.x - sizeStr.width / 2, pt.y - m_nRoleInitialHeight, sizeStr.width, sizeStr.height));//++Guosen 2012.6.29 //lbHover->SetFrameRect(CCRectMake(pt.x - sizeStr.width / 2, pt.y - m_role->GetHeight(), sizeStr.width, sizeStr.height));

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


//++Guosen 2012.7.11
//===========================================================================
//
NDUIImage * GenerateIconImage( unsigned int nIconID )
{
	unsigned int	nRow	= nIconID % 10;
	unsigned int	nCown	= nIconID / 10 %10;
	unsigned int	nFile	= nIconID / 100;
	if ( nIconID == 0 || nCown == 0 || nFile == 0 )
	{
		return NULL;
	}
	NDPicture *		pPicture	= new NDPicture;
	if ( pPicture )
	{
		stringstream	ssFile;
		ssFile << "Res00/StatusIcons" << nFile << ".png";
		pPicture->Initialization( NDPath::GetImg00Path( ssFile.str().c_str()).c_str() );
		pPicture->Cut( CCRectMake( (nRow-1)*STATUS_ICON_WIDTH, (nCown-1)*STATUS_ICON_HEIGHT, STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT ) );
		NDUIImage *		pImage	= new NDUIImage;
		if ( pImage )
		{
			pImage->Initialization();
			pImage->SetPicture( pPicture );
			return pImage;
		}
		delete pPicture;
	}
	return NULL;
}

//===========================================================================
TFighterStatusIcon * Fighter::GetighterStatusIcon( unsigned int nIconID )
{
	for ( std::deque<TFighterStatusIcon>::iterator iter = m_queStatusIcons.begin(); iter != m_queStatusIcons.end(); iter++ )
	{
		if ( iter->nIconID == nIconID )
		{
			return &(*iter);
		}
	}
	return NULL;
}

//===========================================================================
// 添加状态图标，
bool Fighter::AppendStatusIcon( unsigned int nIconID )
{
	if ( GetighterStatusIcon( nIconID ) != NULL )
		return false;

	NDUIImage *		pIconImage = GenerateIconImage( nIconID );
	if ( pIconImage == NULL )
		return false;

	TFighterStatusIcon	tFighterStatusIcon;
	tFighterStatusIcon.nIconID		= nIconID;
	tFighterStatusIcon.pIconImage	= pIconImage;
	m_queStatusIcons.push_back( tFighterStatusIcon );
	m_pkParent->AddChild(pIconImage);
	CCPoint pt	= m_pkRole->GetPosition();
	pIconImage->SetFrameRect( CCRectMake( pt.x + m_iIconsXOffset, 
		pt.y - m_nRoleInitialHeight + STATUS_ICON_HEIGHT * (m_queStatusIcons.size()-1), 
		STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT ) );
	return true;
}

//===========================================================================
// 移除状态图标
bool Fighter::RemoveStatusIcon( unsigned int nIconID )
{
	for ( std::deque<TFighterStatusIcon>::iterator iter = m_queStatusIcons.begin(); iter != m_queStatusIcons.end(); iter++ )
	{
		if ( iter->nIconID == nIconID )
		{
			iter->pIconImage->RemoveFromParent(false);
			SAFE_DELETE(iter->pIconImage);
			m_queStatusIcons.erase(iter);
			UpdateStatusIconsPosition();
			return true;
		}
	}
	return false;
}

//===========================================================================
void Fighter::UpdateStatusIconsPosition()
{
	if ( m_queStatusIcons.empty() )
		return;
	CCPoint pt	= m_pkRole->GetPosition();
	int	iCount	= 0;
	for ( std::deque<TFighterStatusIcon>::iterator iter = m_queStatusIcons.begin(); iter != m_queStatusIcons.end(); iter++ )
	{
		iter->pIconImage->SetFrameRect( CCRectMake( pt.x + m_iIconsXOffset, 
			pt.y - m_nRoleInitialHeight + STATUS_ICON_HEIGHT * iCount, 
			STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT ) );
		iCount++;
	}
}
//===========================================================================
//清除状态小图标
void Fighter::ClearAllStatusIcons()
{
	for ( std::deque<TFighterStatusIcon>::iterator iter = m_queStatusIcons.begin(); iter != m_queStatusIcons.end(); iter++ )
	{
		iter->pIconImage->RemoveFromParent(false);
		SAFE_DELETE(iter->pIconImage);
	}
	m_queStatusIcons.clear();
}
/*
 *  Fighter.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Fighter.h"
#import "CGPointExtension.h"
#import "NDConstant.h"
#import "BattleUtil.h"
#import "NDUtility.h"
#import "NDMonster.h"
#import "Battle.h"
#import "ItemMgr.h"
#include "NDSprite.h"
#include "NDUILabel.h"
#include <sstream>
#include "CPet.h"
#include "NDDirector.h"
#include "NDPath.h"
using namespace NDEngine;

//const int LEFT_BACK_X = 120; // 左边后排 x 坐标
//const int LEFT_FRONT_X = 160; // 左边前排 x 坐标
//const int RIGHT_FRONT_X = 320; // 右边后排 x 坐标
//const int RIGHT_BACK_X = 360; // 右边前排 x 坐标
//
//const int POS_INTERVAL_Y = 53; // y 轴间隔

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
	m_bDefenceAtk=false;
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
	m_bShowName=false;
	lb_skillName=NULL;
	lb_FighterName=NULL;
	m_imgHurtNum = NULL;
	m_imgBaoJi = NULL;
	m_imgBoji = NULL;
	this->skillAtkType = ATKTYPE_NEAR;
	
	protectTarget = NULL;
	protector = NULL;
	hurtInprotect = 0;
	
	m_rareMonsterEffect = NULL;
	
	mana_full_ani=NULL;
	dritical_ani=NULL;
	dodge_ani=NULL;
	block_ani=NULL;
    isCriticalHurt=false;
	isAtkDritical=false;
	isDodge=false;
	isBlock=false;
	m_nRoleInitialHeight	= 0;
	m_iIconsXOffset			= 0;
	m_pHPBar				= NULL;
	m_pMPBar				= NULL;
}

void Fighter::releaseStatus()
{
	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin(); it != battleStatusList.end(); it++) {
		SAFE_DELETE(*it);
	}
	battleStatusList.clear();
}

Fighter::~Fighter()
{
	this->releaseStatus();
	
	if (m_role) {
		m_role->RemoveFromParent(false);
	}
	
	if (m_bRoleShouldDelete)
	{
		SAFE_DELETE(m_role);
	}
	
	if (m_role && m_roleParent) {
		m_role->SetPositionEx(m_ptRoleInParent);
		m_roleParent->AddChild(m_role);
		if (m_role->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) {
			NDManualRole* role = (NDManualRole*)m_role;
			role->SetAction(false);
		}
	}
	
	SAFE_DELETE(m_imgHurtNum);
	SAFE_DELETE(m_imgBaoJi);
	SAFE_DELETE(m_imgBoji);
	
}

//++Guosen 2012.6.29//计算交战者位置的X坐标
int countY(int teamAmount,BATTLE_GROUP group,int t,int pos ){
//	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
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
	CGSize winsize	= NDDirector::DefaultDirector()->GetWinSize();
	int iY			= g_iYOffset[pos-1];
	return iY*winsize.height/640;
}

//++Guosen 2012.6.29//计算交战者位置的Y坐标
int countX(int teamAmount,BATTLE_GROUP group,int t,int pos ){
//	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
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
	CGSize winsize	= NDDirector::DefaultDirector()->GetWinSize();
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

void Fighter::setPosition(int teamAmout) {
	this->originX	= countX( teamAmout, this->m_info.group, this->m_info.btBattleTeam, this->m_info.btStations );
	this->originY	= countY( teamAmout, this->m_info.group, this->m_info.btBattleTeam, this->m_info.btStations );
	this->x			= this->originX;
	this->y			= this->originY;
}

//void Fighter::AddCommand(FIGHTER_CMD* cmd)
//{
//	m_vCmdList.push_back(cmd);
//}

void Fighter::updatePos()
{
	this->m_role->SetPositionEx(ccp(this->x, this->y));
	if (!isVisibleStatus) {
		NDUILabel* lbHover = (NDUILabel*)this->m_parent->GetChild(TAG_HOVER_MSG);
		if (lbHover) {
			CGSize sizeStr = getStringSize(lbHover->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
			// 改成固定值
			//lbHover->SetFrameRect(CGRectMake(x - sizeStr.width / 2, y - m_role->GetHeight(), sizeStr.width, sizeStr.height));
			lbHover->SetFrameRect(CGRectMake(this->x - sizeStr.width / 2, this->y - m_nRoleInitialHeight, sizeStr.width, sizeStr.height));
		}
	}
	//NDUILabel* lbName = (NDUILabel*)this->m_parent->GetChild(TAG_FIGHTER_NAME);
	if (this->lb_FighterName) {
		CGSize sizeStr = getStringSize(lb_FighterName->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
		// 所有怪物武将的姓名位置改成固定值
		//--this->lb_FighterName->SetFrameRect(CGRectMake(x - sizeStr.width / 2, y - m_role->GetHeight() - sizeStr.height, sizeStr.width, sizeStr.height));
		this->lb_FighterName->SetFrameRect(CGRectMake(this->x - sizeStr.width / 2, this->y - m_nRoleInitialHeight - sizeStr.height - HP_BAR_HEIGHT - 2, sizeStr.width, sizeStr.height));
	}
	
	if (lb_skillName){
		//CGPoint pt = this->m_role->GetPosition();
		CGSize sizeStr =getStringSize(lb_skillName->GetText().c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
		//++Guosen 2012.6.28//设置技能名的显示位置
		//if(this->m_info.group == BATTLE_GROUP_ATTACK)
		//{
		//	lb_skillName->SetFrameRect(CGRectMake(pt.x +(FIGHTER_WIDTH/2), pt.y - (FIGHTER_HEIGHT/2) - sizeStr.height, sizeStr.width, sizeStr.height));
		//}else{
		//	lb_skillName->SetFrameRect(CGRectMake(pt.x -(FIGHTER_WIDTH/2)-sizeStr.width, pt.y - (FIGHTER_HEIGHT/2) - sizeStr.height, sizeStr.width, sizeStr.height));
		//}
		// 所有怪物武将的技能名位置改成固定值
		//--lb_skillName->SetFrameRect(CGRectMake(pt.x-sizeStr.width/2 , pt.y-FIGHTER_HEIGHT-sizeStr.height*2, sizeStr.width, sizeStr.height));
		lb_skillName->SetFrameRect(CGRectMake(this->x-sizeStr.width/2 , this->y - m_nRoleInitialHeight - HP_BAR_HEIGHT - 2 - sizeStr.height*2, sizeStr.width, sizeStr.height));
        //++
	}
	UpdateStatusIconsPosition();
}

void Fighter::reStoreAttr()
{
	
	m_bMissAtk = false;
	m_bHardAtk = false;
	m_bDefenceAtk=false;
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
	m_bShowName=false;
	
	isDodge=false;
    isCriticalHurt=false;
	isAtkDritical=false;
	isBlock=false;
	
	m_info.nLife=m_info.original_life;
	m_info.nMana=m_info.original_mana;
	GetRole()->life=m_info.nLife;
	GetRole()->maxLife=m_info.nLifeMax;
	GetRole()->mana=m_info.nMana;
	GetRole()->maxMana=m_info.nManaMax;

	mana_full_ani=NULL;
	dritical_ani=NULL;
	dodge_ani=NULL;
	block_ani=NULL;
	
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

void Fighter::LoadRole(int nLookFace,int lev,const string& name){
	m_bRoleShouldDelete=true;
	NDManualRole *role=new NDManualRole;
	role->InitRoleLookFace(nLookFace);
	role->SetCurrentAnimation(MANUELROLE_BATTLE_STAND, role->m_faceRight);
	m_role=role;
	m_role->m_name=name;
	m_role->level=lev;
	role->SetNonRole(false);
	m_nRoleInitialHeight = m_role->GetHeight();
	if( this->m_info.group == BATTLE_GROUP_ATTACK )
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
	role->SetCurrentAnimation(MANUELROLE_BATTLE_STAND, role->m_faceRight);
	role->dwLookFace = nLookFace;
	m_role = role;
	m_lookfaceType = LOOKFACE_MANUAL;
	
	fighter_name = name;
	m_role->m_name = name;
	m_role->level = lev;
	
	//this->m_info.bRoleMonster = role->m_bRoleMonster;
	m_nRoleInitialHeight = m_role->GetHeight();
	if( this->m_info.group == BATTLE_GROUP_ATTACK )
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
	drawRareMonsterEffect(isVisibleStatus);
	m_role->RunAnimation(isVisibleStatus);
	m_role->RunBattleSubAnimation(this);
	this->drawStatusAniGroup();
}

void Fighter::drawStatusAniGroup() {
	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin(); it != battleStatusList.end(); it++) 
	{
		if((*it)->m_aniGroup){
			NDSprite* role = (*it)->m_aniGroup->role;
			if (!role) {
				continue;
			}
			role->DrawSubAnimation(*((*it)->m_aniGroup));
		}
	}
	
	if ( m_info.nMana >= m_info.nManaMax )
	{
		if( !mana_full_ani )
		{//气条满，爆气动画
			mana_full_ani = new NDSprite;
			stringstream ss;
			ss << "sm_effect_20.spr";
			mana_full_ani->Initialization(NDPath::GetAniPath(ss.str().c_str()));
			mana_full_ani->SetCurrentAnimation(0, false);
			m_role->GetParent()->AddChild(mana_full_ani);
            
            //爆气音效
            ScriptMgrObj.excuteLuaFunc("PlayEffectSound", "Music",1018);
            
			NDLog(@"add mana full ani");
		}
		mana_full_ani->SetPosition(ccp(x,y));
		mana_full_ani->RunAnimation(true);
	}else if (mana_full_ani){
		NDLog(@"delete mana_full_ani");
		SAFE_DELETE(mana_full_ani);
		mana_full_ani=NULL;
	}

	
	if (isAtkDritical){
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
	
	//--Guosen 2012.6.28//不在此播放闪避特效动画和锁定特效动画
	//if (isDodge){
	//	if(!dodge_ani)
	//	{
	//		dodge_ani = new NDSprite;
	//		stringstream ss;
	//		ss << "sm_effect_" << EFFECT_DODGE << ".spr";
	//		dodge_ani->Initialization(NDPath::GetAniPath(ss.str().c_str()));
	//		dodge_ani->SetCurrentAnimation(0, false);
	//		m_role->GetParent()->AddChild(dodge_ani);
	//		NDLog(@"add dodge ani");
	//	}
	//	dodge_ani->SetPosition(ccp(x,y-FIGHTER_HEIGHT));
	//	dodge_ani->RunAnimation(true);
	//	if (dodge_ani->IsAnimationComplete())
	//	{
	//		isDodge=false;
	//		NDLog(@"delete dodge_ani");
	//		SAFE_DELETE(dodge_ani);
	//		dodge_ani=NULL;
	//	}
	//} 
	//
	//if (isBlock){
	//	if(!block_ani)
	//	{
	//		block_ani = new NDSprite;
	//		stringstream ss;
	//		ss << "sm_effect_" << EFFECT_BLOCK << ".spr";
	//		block_ani->Initialization(NDPath::GetAniPath(ss.str().c_str()));
	//		block_ani->SetCurrentAnimation(0, false);
	//		m_role->GetParent()->AddChild(block_ani);
	//		NDLog(@"add block ani");
	//	}
	//	
	//	block_ani->SetPosition(ccp(x,y-FIGHTER_HEIGHT/2));
	//	block_ani->RunAnimation(true);
	//	if (block_ani->IsAnimationComplete())
	//	{
	//		isBlock=false;
	//		NDLog(@"delete block_ani");
	//		SAFE_DELETE(block_ani);
	//		block_ani=NULL;
	//	}
	//}
}

void Fighter::SetRole(NDBaseRole* role)
{
	this->m_role = role;
	
	m_roleParent = role->GetParent();
	m_ptRoleInParent = role->GetPosition();
	
	if (m_roleParent) {
		role->RemoveFromParent(false);
	}
	
	switch(role->GetWeaponType()) {
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

void Fighter::AddAHurt(Fighter* actor, int btType, int hurtHP, int hurtMP, int dwData, HURT_TYPE ht)
{
	m_vHurt.push_back(Hurt(actor, btType, hurtHP, hurtMP, dwData, ht));
}

PAIR_GET_HURT Fighter::getHurt(Fighter* actor, int btType, int dwData, int type) {
	
	PAIR_GET_HURT hurtRet;
	hurtRet.first = false;
	
	if (type == HURT_TYPE_PASSIVE) {// 被动的，用btType去取dwData
		for (size_t i = 0; i < m_vHurt.size(); i++) {
			Hurt& hurt = m_vHurt.at(i);
			if (hurt.theActor == actor && hurt.btType == btType
			    && hurt.type == type && i == 0) {
				hurtRet.first = true;
				hurtRet.second = hurt;
				m_vHurt.erase(m_vHurt.begin() + i);
				break;
			}
		}
	} else if (type == HURT_TYPE_ACTIVE) {
		for (size_t i = 0; i < m_vHurt.size(); i++) {
			Hurt& hurt = m_vHurt.at(i);
			if (hurt.theActor == actor && hurt.dwData == dwData
			    && hurt.type == type) {
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
	if (m_imgActionWord) {
		m_imgActionWord->RemoveFromParent(true);
		m_imgActionWord = NULL;
	}
}

bool Fighter::isVisiable() {
	bool result = false;
	
//	if (this->m_info.fighterType == FIGHTER_TYPE_PET) {
//		if (escape) {
//			result = false;
//		} else {
//			result = true;
//		}
//	} else {
		if (escape || !alive) {
			result = false;
		} else {
			result = true;
		}
//	}
	
	return result;
}

bool Fighter::completeOneAction() {
	bool result = false;
	
	if (this->m_actionTime >= 20) {
		result = true;
	}
	return result;
}

bool Fighter::moveTo(int tx, int ty) {
	
	bool arrive = false;
	
	if (abs(x - tx) < STEP) {
		x = tx;
		
	} else {
		if (x > tx) {
			x -= STEP;
		} else {
			x += STEP;
		}
	}
	
	if (abs(y - ty) < STEP) {
		y = ty;
	} else {
		if (y > ty) {
			y -= STEP;
		} else {
			y += STEP;
		}
	}
	
	if (x == tx && y == ty) {
		arrive = true;
	}
	
	return arrive;
}

void Fighter::hurted(int num)
{
	if (num == 0) {
		return;
	}
	
	this->m_vHurtNum.push_back(num);
}

void Fighter::setCurrentHP(int hp) {
	if (hp <= 0) {
		m_info.nLife = 0;
	} else if (hp > m_info.nLifeMax) {
		m_info.nLife = m_info.nLifeMax;
	} else {
		m_info.nLife = hp;
	}
	
	int currentId=BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if(currentId==m_info.idObj)
	{
		ScriptMgrObj.excuteLuaFunc("UpdateHp","FighterInfo",m_info.nLife,m_info.nLifeMax);
	}
}

void Fighter::setCurrentMP(int mp) {
	if (mp <= 0) {
		m_info.nMana = 0;
	} else {
		m_info.nMana = mp;
	}
	
	int currentId=BattleMgrObj.GetBattle()->GetCurrentShowFighterId();
	if(currentId==m_info.idObj)
	{
		ScriptMgrObj.excuteLuaFunc("UpdateMp","FighterInfo",m_info.nMana,m_info.nManaMax);
	}
}

void Fighter::showFighterName(bool b)
{
	if (b) {
		if(m_bShowName){
			return;
		}
		NDBaseRole* role=GetRole();
		if(role){
			CGPoint pt = this->m_role->GetPosition();
			this->lb_FighterName = new NDUILabel;
			this->lb_FighterName->Initialization();
			//this->lb_FighterName->SetTag(TAG_FIGHTER_NAME);
			
            //** chh 2012-09-05 **//
            //this->lb_FighterName->SetFontColor(ccc4(255, 255, 255, 255));
            ccColor4B cColor4 = ScriptMgrObj.excuteLuaFuncRetColor4("GetColor", "Item",this->m_info.nQuality);
            this->lb_FighterName->SetFontColor(cColor4);
            
			this->lb_FighterName->SetText(GetRole()->m_name.c_str());
			this->lb_FighterName->SetFontSize(DEFAULT_FONT_SIZE);
			CGSize sizefighterName = getStringSize(GetRole()->m_name.c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
			//fighterName->SetTag(TAG_FIGHTER_NAME);
			lb_FighterName->SetFrameRect(CGRectMake(pt.x - sizefighterName.width / 2, pt.y - FIGHTER_HEIGHT - sizefighterName.height, sizefighterName.width, sizefighterName.height));
			this->m_parent->AddChild(this->lb_FighterName);
			//在此创建生命条及士气条空间++Guosen 2012.7.27
			this->m_pHPBar	= new CUIExp;
			this->m_pHPBar->Initialization( NDPath::GetImgPath( HPMP_BAR_BG_IMAGE ), NDPath::GetImgPath( HP_BAR_FRO_IMAGE ) );
			this->m_pHPBar->SetStyle( 2 );
			this->m_pMPBar	= new CUIExp;
			this->m_pMPBar->Initialization( NDPath::GetImgPath( HPMP_BAR_BG_IMAGE ), NDPath::GetImgPath( MP_BAR_FRO_IMAGE ) );
			this->m_pMPBar->SetStyle( 2 );
			this->m_parent->AddChild(m_pHPBar);
			this->m_parent->AddChild(m_pMPBar);
			drawHPMP();
		}
	} else {
		if(lb_FighterName)
		{
			this->lb_FighterName->RemoveFromParent(true);
			this->lb_FighterName=NULL;
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
	m_bShowName=b;
}

void Fighter::showSkillName(bool b)
{
	if (b) {
		CGPoint pt = this->m_role->GetPosition();
		lb_skillName = new NDUILabel;
		lb_skillName->Initialization();
		lb_skillName->SetFontColor(ccc4(0xff, 0xd7, 0, 255));//(ccc4(254, 3, 9, 255));//++Guosen 2012.6.28//设置技能名字体颜色
		lb_skillName->SetText(m_strSkillName.c_str());
		lb_skillName->SetFontSize(DEFAULT_FONT_SIZE);
		CGSize sizeSkillName = getStringSize(m_strSkillName.c_str(), DEFAULT_FONT_SIZE * FONT_SCALE);
		//++Guosen 2012.6.28//设置技能名的显示位置
		//lb_skillName->SetTag(TAG_SKILL_NAME);
		//if(this->m_info.group == BATTLE_GROUP_ATTACK)
		//{
		//	lb_skillName->SetFrameRect(CGRectMake(pt.x +(FIGHTER_WIDTH/2), pt.y - (FIGHTER_HEIGHT/2) - sizeSkillName.height, sizeSkillName.width, sizeSkillName.height));
		//}else{
		//	lb_skillName->SetFrameRect(CGRectMake(pt.x -(FIGHTER_WIDTH/2)-sizeSkillName.width, pt.y - (FIGHTER_HEIGHT/2) - sizeSkillName.height, sizeSkillName.width, sizeSkillName.height));
		//}
        //CGSize size = this->m_role->GetSpriteRect().size;
        lb_skillName->SetFrameRect(CGRectMake(pt.x-sizeSkillName.width/2 , pt.y-FIGHTER_HEIGHT-sizeSkillName.height*2, sizeSkillName.width, sizeSkillName.height));
        //++
		this->m_parent->AddChild(lb_skillName);
	} else {
		if (lb_skillName)
		{
			this->lb_skillName->RemoveFromParent(true);
			lb_skillName=NULL;
		}
	}
}

//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
//void Fighter::showActionWord(ACTION_WORD index)
//{
//	if (m_imgActionWord) {
//		return;
//	}
//	
//	NDPicture* pic = NULL;
//	switch (index) {
//		case AW_DEF:
//			pic = (this->m_parent->getActionWord(AW_DEF));
//			break;
//		case AW_FLEE:
//			pic = (this->m_parent->getActionWord(AW_FLEE));
//			break;
//		case AW_DODGE:
//			pic = (this->m_parent->getActionWord(AW_DODGE));
//			break;
//		default:
//			break;
//	}
//	
//	if (!pic) {
//		return;
//	}
//	
//	CGSize size = pic->GetSize();
//	
//	m_imgActionWord = new NDUIImage;
//	m_imgActionWord->Initialization();
//	m_imgActionWord->SetPicture(pic);
//	m_imgActionWord->SetFrameRect(CGRectMake(this->x - size.width / 2,
//						this->y - m_role->GetHeight(), size.width, size.height));
//	this->m_parent->AddChild(m_imgActionWord);
//}

//--Guosen 2012.6.28//不显示动作名称（防御，逃跑，闪避）
//void Fighter::drawActionWord()
//{
//	//if (!this->m_role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
////	{
////		NDLog(@"dfdsfdsf");
////	}
//	if (this->isAlive()) 
//	{
//		switch (this->m_action) 
//		{
//			case FLEE_FAIL:
//			case FLEE_SUCCESS:
//				if (isBeginAction() && !isActionOK()) 
//				{
//					this->showActionWord(AW_FLEE);
//					return;
//				}
//				break;
//			case DEFENCE:
//				this->showActionWord(AW_DEF);
//				return;
//			default:
//				break;
//		}
//		
//		if (this->dodgeOK )//&& isBeginAction()) 
//		{
//			this->showActionWord(AW_DODGE);
//			return;
//		}
//		
//		if(this->defenceOK){
//			this->showActionWord(AW_DEF);
//			return;
//		}
//	}
//	
//	// 不显示
//	if (m_imgActionWord) {
//		this->m_parent->RemoveChild(m_imgActionWord, true);
//		m_imgActionWord = NULL;
//	}
//}

void Fighter::setDieOK(bool bOK)
{
	if (m_imgActionWord && m_imgActionWord->GetParent()) {
		m_imgActionWord->RemoveFromParent(true);
		m_imgActionWord = NULL;
	}

	this->dieOK = bOK;
}

void Fighter::drawHurtNumber()
{
	
	drawHPMP();
	if (m_vHurtNum.size() <= 0) {
		return;
	}
	
	bool bEraseHurtNum = false;
	
	{
		HurtNumber& hn = m_vHurtNum.at(0);
		
		//int nWidth = GetNumBits(abs(hn.getHurtNum())) * 11;//nWidth>>1??
		
		if (hn.isNew()) {
			hn.beginAppear();
			
			// 初始化去血提示
			if (hn.getHurtNumberY() > 0) {
				
				m_imgHurtNum = new ImageNumber;
				m_imgHurtNum->Initialization();
				
				if (m_bHardAtk) {
					/*NDPicture* picBaoJi = this->m_parent->GetBaoJiPic();
					m_imgBaoJi = new NDUIImage;
					m_imgBaoJi->Initialization();
					m_imgBaoJi->SetPicture(picBaoJi);
					this->m_parent->AddChild(m_imgBaoJi);*/
					
					m_imgHurtNum->SetBigRedNumber(hn.getHurtNum(), false);
					
				} else {
					if (hn.getHurtNum() > 0) { // 加血
						m_imgHurtNum->SetSmallGreenNumber(hn.getHurtNum(), false);
					} else { // 去血
						m_imgHurtNum->SetSmallRedNumber(hn.getHurtNum(), false);
					}
				}
				
				this->m_parent->AddChild(m_imgHurtNum);
			}
		}
		
		if (hn.getHurtNumberY() > 0) {
			
			if (m_bHardAtk) {
				/*NDPicture* picBaoJi = this->m_parent->GetBaoJiPic();
				int bjW = picBaoJi->GetSize().width;
				int bjH = picBaoJi->GetSize().height;
				if (m_imgBaoJi) {
					m_imgBaoJi->SetFrameRect(CGRectMake(this->x - (bjW >> 1),
									    y - m_role->GetHeight() - bjH - hn.getHurtNumberY(),
									    bjW,
									    bjH));
				}*/
				if (m_imgHurtNum) {
					m_imgHurtNum->SetFrameRect(CGRectMake(this->x - (m_imgHurtNum->GetNumberSize().width /2),
									      this->y - m_nRoleInitialHeight- hn.getHurtNumberY()*20,//++Guosen 2012.6.29 固定位置起始 //this->y - m_role->GetHeight() - hn.getHurtNumberY()*20,// - bjH * 13 / 20,
									      m_imgHurtNum->GetNumberSize().width,
									      m_imgHurtNum->GetNumberSize().height));
				}
				
			} else {
				if (m_imgHurtNum) {
					m_imgHurtNum->SetFrameRect(CGRectMake(this->x - (m_imgHurtNum->GetNumberSize().width /2),
									      this->y - m_nRoleInitialHeight- hn.getHurtNumberY()*10,//++Guosen 2012.6.29 固定位置起始 //this->y - m_role->GetHeight() - hn.getHurtNumberY()*20,
									      m_imgHurtNum->GetNumberSize().width,
									      m_imgHurtNum->GetNumberSize().height));
				}
			}

			
			hn.timeLost();
			bEraseHurtNum = hn.isDisappear();

		}
	}

	if (bEraseHurtNum) {
		m_vHurtNum.erase(m_vHurtNum.begin());
		// 删除去血提示
		if (m_imgBaoJi) {
			m_imgBaoJi->RemoveFromParent(false);
			SAFE_DELETE(m_imgBaoJi);
		}
		if (m_imgHurtNum) {
			m_imgHurtNum->RemoveFromParent(false);
			SAFE_DELETE(m_imgHurtNum);
		}
	}
}

void Fighter::drawHPMP()
{
	if(!isAlive()){
		return;
	}
	int drawx = this->m_role->GetPosition().x;
	int drawy = this->m_role->GetPosition().y;
	
	drawy -= m_nRoleInitialHeight;//++Guosen 2012.6.29 固定位置//drawy -= this->m_role->GetHeight();
    
	//战斗时血条的宽高
	int iBarWidth	= HP_BAR_WIDTH;
	int iBarHeight	= HP_BAR_HEIGHT;
	int lifew = 0;
	int manaw = 0;
	
	drawx -= iBarWidth >> 1;
	if( this->m_info.nLifeMax == 0 )
	{
		lifew = 0;
	}
	else
	{
		if( this->m_info.nLife > this->m_info.nLifeMax )
		{
			lifew = iBarWidth;
		}
		else
		{
			lifew = this->m_info.nLife * iBarWidth / this->m_info.nLifeMax;
		}
	}


	if( this->m_info.nLifeMax == 0 )
	{
		manaw = 0;
	}
	else
	{
		if( this->m_info.nMana > this->m_info.nManaMax )
		{
			manaw = iBarWidth;
		}
		else
		{
			manaw = this->m_info.nMana * iBarWidth / this->m_info.nManaMax;
		}
	}
	
	//DrawRecttangle( CGRectMake(drawx, drawy, iBarWidth, iBarHeight), ccc4(0xcc, 0x99, 0x33, 255));
	//DrawRecttangle( CGRectMake(drawx, drawy, manaw, iBarHeight), ccc4(0xff, 0xcc, 0, 255));
	//DrawRecttangle( CGRectMake(drawx, drawy - iBarHeight - 2, iBarWidth, iBarHeight ), ccc4(148, 65, 74, 255) );
	//DrawRecttangle( CGRectMake(drawx, drawy - iBarHeight - 2, lifew, iBarHeight ), ccc4(237, 83, 15, 255) );
	if ( m_pMPBar )
	{
		m_pMPBar->SetFrameRect( CGRectMake(drawx, drawy, iBarWidth, iBarHeight) );
		m_pMPBar->SetStart( 0 );
		m_pMPBar->SetProcess( manaw );
		m_pMPBar->SetTotal( iBarWidth );
	}
	if ( m_pHPBar )
	{
		m_pHPBar->SetFrameRect( CGRectMake(drawx, drawy - iBarHeight - 2, iBarWidth, iBarHeight) );
		m_pHPBar->SetStart( 0 );
		m_pHPBar->SetProcess( lifew );
		m_pHPBar->SetTotal( iBarWidth );
	}
}

void Fighter::clearFighterStatus() {
	this->m_vPasStatus.clear();
	this->m_vTarget.clear();
	this->arrayStatusTarget.clear();
	BattleSkill bs;
	this->useSkill = bs;
}

int Fighter::getAPasStatus() {
	int result = 0;
	
	VEC_PAS_STASUS_IT it = m_vPasStatus.begin();
	
	if (it != m_vPasStatus.end()) {
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

void Fighter::removeAStatusAniGroup(FighterStatus* status){
	
	if (status->m_LastEffectID == 404) {// 隐身特殊处理
		isVisibleStatus = true;
		strMsgStatus = "";
		this->m_parent->RemoveChild(TAG_HOVER_MSG, true);
	}
	
	for (VEC_FIGHTER_STATUS_IT it = this->battleStatusList.begin(); it != this->battleStatusList.end(); it++) {
		if ((*it)->m_id == status->m_id) {
			SAFE_DELETE(*it);
			battleStatusList.erase(it);
			return;
		}
	}
}

void Fighter::setWillBeAtk(bool bSet) {
	this->willBeAtk = bSet;
	
	if (bSet) {
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

	} else {
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
	if(fs->m_LastEffectID ==404) {
			// 隐身特殊处理
			isVisibleStatus = false;
			this->strMsgStatus = NDCommonCString("YingSheng");
			this->showHoverMsg(strMsgStatus.c_str());
	}

	NDLog(@"add a status");
	this->battleStatusList.push_back(fs);
}

void Fighter::setOnline(bool bOnline)
{
	if (bOnline) {
		if (!this->strMsgStatus.empty()) {
			this->showHoverMsg(strMsgStatus.c_str());
		} else {
			this->m_parent->RemoveChild(TAG_HOVER_MSG, true);
		}
	} else {
		this->showHoverMsg(NDCommonCString("leave"));
	}
}

void Fighter::showHoverMsg(const char* str)
{
	NDUILabel* lbHover = (NDUILabel*)this->m_parent->GetChild(TAG_HOVER_MSG);
	if (!lbHover) {
		CGPoint pt = this->m_role->GetPosition();
		lbHover = new NDUILabel;
		lbHover->Initialization();
		lbHover->SetFontColor(ccc4(0, 255, 100, 255));
		CGSize sizeStr = getStringSize(str, DEFAULT_FONT_SIZE * FONT_SCALE);
		lbHover->SetTag(TAG_HOVER_MSG);
		lbHover->SetFrameRect(CGRectMake(pt.x - sizeStr.width / 2, pt.y - m_nRoleInitialHeight, sizeStr.width, sizeStr.height));//++Guosen 2012.6.29 //lbHover->SetFrameRect(CGRectMake(pt.x - sizeStr.width / 2, pt.y - m_role->GetHeight(), sizeStr.width, sizeStr.height));
		
		this->m_parent->AddChild(lbHover);
	}
	lbHover->SetText(str);
}

void Fighter::drawRareMonsterEffect(bool bVisible)
{
	// 稀有怪光环
	if (m_info.fighterType == Fighter_TYPE_RARE_MONSTER && m_role && m_role->GetParent()) 
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
		SAFE_DELETE_NODE(m_rareMonsterEffect);
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
		pPicture->Initialization( NDPath::GetImgPath( ssFile.str().c_str() ) );
		pPicture->Cut( CGRectMake( (nRow-1)*STATUS_ICON_WIDTH, (nCown-1)*STATUS_ICON_HEIGHT, STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT ) );
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
	this->m_parent->AddChild(pIconImage);
	CGPoint pt	= this->m_role->GetPosition();
	pIconImage->SetFrameRect( CGRectMake( pt.x + m_iIconsXOffset, 
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
	CGPoint pt	= this->m_role->GetPosition();
	int	iCount	= 0;
	for ( std::deque<TFighterStatusIcon>::iterator iter = m_queStatusIcons.begin(); iter != m_queStatusIcons.end(); iter++ )
	{
		 iter->pIconImage->SetFrameRect( CGRectMake( pt.x + m_iIconsXOffset, 
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

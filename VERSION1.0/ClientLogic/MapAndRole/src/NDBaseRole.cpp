/*
 *  NDBaseRole.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDBaseRole.h"
#include "NDConstant.h"
#include "NDPath.h"
#include "EnumDef.h"
#include "NDManualRole.h"
#include "NDNpc.h"
//#include "NDRidePet.h"
#include "CCPointExtension.h"
#include "AnimationList.h"
#include "NDNode.h"
#include "NDDirector.h"
#include "NDMapLayer.h"
#include "Item.h"
#include "GameScene.h"
#include "NDUtility.h"
#include "define.h"
#include "NDRidePet.h"

using namespace NDEngine;

IMPLEMENT_CLASS(NDBaseRole, NDSprite)

bool NDBaseRole::ms_bGameSceneRelease = false;

NDBaseRole::NDBaseRole()
{
	m_weaponType = WEAPON_NONE;
	m_secWeaponType = WEAPON_NONE;

	m_nSex = -1;
	m_nSkinColor = -1;
	m_nHairColor = -1;
	m_nHair = -1;

	m_nDirect = -1;
	m_nExpresstion = -1;
	m_nModel = -1;
	m_nWeapon = -1;
	m_nCap = -1;
	m_nArmor = -1;

	m_nLife = 0;
	m_nMaxLife = 0;
	m_nMana = 0;
	m_nMaxMana = 0;
	m_nLevel = 0;
	m_eCamp = CAMP_TYPE_NONE;

	m_bFaceRight = true;

	m_pkRidePet = NULL;

	m_bFocus = false;

	m_pkSubNode = NDNode::Node();
	m_pkSubNode->SetContentSize(NDDirector::DefaultDirector()->GetWinSize());

	m_posScreen = CGPointZero;
	m_picRing = NULL;
	m_pkPicShadow = NULL;
	m_pkPicShadowBig = NULL;
	m_iShadowOffsetX = 0;
	m_iShadowOffsetY = 10;
	m_bBigShadow = false;
	m_bShowShadow = true;

	m_nID = 0;

	m_pkEffectFlagAniGroup = NULL;

	//m_talkBox = NULL;

	SetDelegate(this);

	m_pkEffectRidePetAniGroup = NULL;
}

NDBaseRole::~NDBaseRole()
{
	SAFE_DELETE (m_pkSubNode);
	SAFE_DELETE (m_picRing);
	SAFE_DELETE (m_pkPicShadow);
	SAFE_DELETE (m_pkPicShadowBig);
	//if (ridepet)
//	{
//		delete ridepet;
//		ridepet = NULL;
//	}

//if (m_talkBox)
//	{
//		if (m_talkBox->GetParent()) 
//		{
//			m_talkBox->RemoveFromParent(true);
//			m_talkBox = NULL;
//		}
//		else 
//		{
//			delete m_talkBox;
//			m_talkBox = NULL;
//		}
//	}
	//if (!s_bGameSceneRelease && m_talkBox) 
	//{
	//	SAFE_DELETE_NODE(m_talkBox);
	//}
}

CGRect NDBaseRole::GetFocusRect()
{
	/*
	 if (!IsFocus())
	 {
	 return CGRectZero;
	 }
	 */

	CGPoint point;

	if (m_pkRidePet)
	{
		point = m_pkRidePet->GetPosition();
	}
	else
	{
		point = GetPosition();
	}

	if (m_picRing == NULL)
	{
		m_picRing = NDPicturePool::DefaultPool()->AddPicture(RING_IMAGE);
	}

	CGSize sizeRing = m_picRing->GetSize();

	return CGRectMake(point.x - 8 - 13, point.y - 16 - 5, sizeRing.width,
			sizeRing.height);
}

void NDBaseRole::DirectRight(bool bRight)
{
	if (bRight)
	{
		SetSpriteDir(1);
		if (m_pkRidePet)
		{
			m_pkRidePet->SetSpriteDir(1);
		}
	}
	else
	{
		SetSpriteDir(2);
		if (m_pkRidePet)
		{
			m_pkRidePet->SetSpriteDir(2);
		}
	}
}

int NDBaseRole::getFlagId(int index)
{
	int iid = -1;

	switch (index)
	{
	case CAMP_NEUTRAL:
		iid = -1;
		break;
	case CAMP_SUI:
		iid = FLAG_SUI_DYNASTY_1;
		break;
	case CAMP_TANG:
		iid = FLAG_TAN_DYNASTY_1;
		break;
	case CAMP_TUJUE:
		iid = FLAG_TUJUE_DYNASTY_1;
		break;
	case CAMP_FOR_ESCORT:
		iid = FLAG_ESCORT_1;
		break;	//镖旗
	case 5:
		iid = FLAG_TEAM_1;
		break; //队伍
	}

	return iid;
}

void NDBaseRole::DrawRingImage(bool bDraw)
{
	if (IsKindOfClass(RUNTIME_CLASS(NDNpc)))
	{
		NDNpc* npc = (NDNpc*) this;
		if (!npc->IsActionOnRing())
		{
			return;
		}
	}

	if (m_bFocus && bDraw)
	{
		if (m_picRing == NULL)
		{
			m_picRing = NDPicturePool::DefaultPool()->AddPicture(RING_IMAGE);
		}
		CGSize sizeRing = m_picRing->GetSize();

		if (GetParent())
		{
			NDLayer *layer = (NDLayer*) GetParent();
			CGSize sizemap = layer->GetContentSize();
			if (!m_pkRidePet)
			{
				//m_picRing->DrawInRect(CGRectMake(GetPosition().x-13-8, GetPosition().y-5-16+320-sizemap.height, sizeRing.width, sizeRing.height));
			}
			else
			{
				//m_picRing->DrawInRect(CGRectMake(ridepet->GetPosition().x-13-8, ridepet->GetPosition().y-5-16+320-sizemap.height, sizeRing.width, sizeRing.height));
			}
		}
	}
}

bool NDBaseRole::OnDrawBegin(bool bDraw)
{
	NDNode *node = GetParent();
	CGSize sizemap;

	if (node)
	{

		if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			//把baserole坐标转成屏幕坐标
			NDMapLayer *layer = (NDMapLayer*) node;
			CGPoint screen = layer->GetScreenCenter();
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_posScreen = ccpSub(GetPosition(),
					ccpSub(screen,
							CGPointMake(winSize.width / 2,
									winSize.height / 2)));
		}
		else
		{
			m_posScreen = GetPosition();
		}

		sizemap = node->GetContentSize();
	}
	else
	{
		return true;
	}

	m_pkSubNode->SetContentSize(sizemap);

	HandleShadow(sizemap);

	DrawRingImage(bDraw);

	if (m_pkEffectFlagAniGroup)
	{
		if (!m_pkEffectFlagAniGroup->GetParent())
		{
			m_pkSubNode->AddChild(m_pkEffectFlagAniGroup);
		}
	}

//	updateRidePetEffect(); ///<临时性注释 郭浩

	if (m_pkEffectRidePetAniGroup)
	{
		if (!m_pkEffectRidePetAniGroup->GetParent())
		{
			m_pkSubNode->AddChild(m_pkEffectRidePetAniGroup);
		}
	}

	drawEffects(bDraw);

	//if (m_talkBox) 
	//{
	//	m_talkBox->draw();
	//}

	return true;
}

///< 临时性注释 --郭浩
// void NDBaseRole::OnDrawEnd(bool bDraw)
// {
// }
// 
// void NDBaseRole::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
// {
// 	if (node == m_talkBox) 
// 	{
// 		m_talkBox = NULL;
// 	}
// 	// 其它操作.....
// }

CGPoint NDBaseRole::GetScreenPoint()
{
	return m_posScreen;
}

void NDBaseRole::SetAction(bool bMove)
{
	//if (GameScreen.getInstance().getBattle() != null) {
//		return;
//	}
	if (bMove)
	{
		if (AssuredRidePet())
		{
			setMoveActionWithRidePet();
		}
		else
		{	// 人物普通移动
			AnimationListObj.moveAction(TYPE_MANUALROLE, this, m_bFaceRight);
		}
	}
	else
	{
		if (AssuredRidePet())
		{	// 骑宠站立
			setStandActionWithRidePet();
		}
		else
		{
			AnimationListObj.standAction(TYPE_MANUALROLE, this, m_bFaceRight);
		}
	}
}

bool NDBaseRole::AssuredRidePet()
{
//	return ridepet != NULL && ridepet->canRide(); ///< 临时性注释 郭浩
	return true;
}

void NDBaseRole::setMoveActionWithRidePet()
{
	if (!m_pkRidePet)
	{
		return;
	}

	AnimationListObj.moveAction(TYPE_RIDEPET, m_pkRidePet, m_bFaceRight);// 骑宠移动
	switch (m_pkRidePet->iType)
	{
	case TYPE_RIDE:	// 人物骑在骑宠上移动
		AnimationListObj.ridePetMoveAction(TYPE_MANUALROLE, this, m_bFaceRight);
		break;
	case TYPE_STAND:	// 人物站在骑宠上移动
		AnimationListObj.standPetMoveAction(TYPE_MANUALROLE, this,
				m_bFaceRight);
		break;
	case TYPE_RIDE_BIRD:
		AnimationListObj.moveAction(TYPE_RIDEPET, m_pkRidePet,
				1 - m_bFaceRight);
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_RIDE_BIRD_WALK);
		break;
	case TYPE_RIDE_FLY:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_FLY_PET_WALK);
		break;
	case TYPE_RIDE_YFSH:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_FLY_PET_WALK);
		break;
	case TYPE_RIDE_QL:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_RIDE_QL);
		break;
	}
}

void NDBaseRole::setStandActionWithRidePet()
{
	if (!m_pkRidePet)
	{
		return;
	}

	AnimationListObj.standAction(TYPE_RIDEPET, m_pkRidePet, m_bFaceRight);

	// 装备界面、属性界面、战斗中，人要站立状态
	//if (EquipUIScreen.instance == null
//	&& Attribute.instance == null
//	&& GameScreen.getInstance().getBattle() == null
//	&& NpcStore.instance == null/*
//	* && VipStore . instance ==
//	* null
//	*/) 
//	{
	switch (m_pkRidePet->iType)
	{
	case TYPE_RIDE:
		AnimationListObj.ridePetStandAction(TYPE_MANUALROLE, this,
				m_bFaceRight);
		break;
	case TYPE_STAND:
		AnimationListObj.standPetStandAction(TYPE_MANUALROLE, this,
				m_bFaceRight);
		break;
	case TYPE_RIDE_BIRD:
		AnimationListObj.standAction(TYPE_RIDEPET, m_pkRidePet,
				1 - m_bFaceRight);
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_RIDE_BIRD_STAND);
		break;
	case TYPE_RIDE_FLY:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_FLY_PET_STAND);
		break;
	case TYPE_RIDE_YFSH:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_FLY_PET_WALK);
		break;
	case TYPE_RIDE_QL:
		AnimationListObj.setAction(TYPE_MANUALROLE, this, m_bFaceRight,
				MANUELROLE_RIDE_QL);
		break;
	}
//	} 
//	else 
//	{
//	 AnimationListObj.standAction(TYPE_MANUALROLE, this, m_faceRight);
//	}
}

///////////////////////////////////////////////////////////
void NDBaseRole::InitRoleLookFace(int lookface)
{
//	sex = lookface / 100000000 % 10;
//	
//	skinColor = lookface / 100000 % 10 - 1;				// 肤色
//	hairColor = lookface / 1000000 % 10-1;			// 发色
//	m_nHair = lookface / 10000000 % 10;					// 发型
//	
//	SetHair(m_nHair, hairColor);
//	SetHairImageWithEquipmentId(m_nHair);
//	SetFaceImageWithEquipmentId(skinColor);
}

void NDBaseRole::InitNonRoleData(std::string name, int lookface, int lev)
{
	m_name = name;
	m_nLevel = lev;
	//m_id = 0; // 用户id
//	sex = lookface / 100000000 % 10; // 人物性别，1-男性，2-女性；
//	direct = lookface % 10;
//	hairColor = lookface / 1000000 % 10;
//	int tmpsex = (sex - 1) / 2 - 1;
//	if (tmpsex < 0 || tmpsex > 2) {
//		tmpsex = 0;
//	}
//	SetHair(tmpsex+1); // 发型
//	
//	SetHairImageWithEquipmentId(m_nHair);

//	int flagOrRidePet = lookface / 10000000 % 10;
//	if (flagOrRidePet > 0) {
//		if (flagOrRidePet < 5) {
//			camp = CAMP_TYPE(flagOrRidePet);
//		}else {				
//			int id = (flagOrRidePet + 1995)*10;
//			SetEquipment(id,0);
//		}
//	}

//	weapon	= getEquipmentLookFace(lookface, 0);
//	cap			= getEquipmentLookFace(lookface, 1);
//	armor		= getEquipmentLookFace(lookface, 2);
//	SetEquipment(weapon, 0);//武器
//	SetEquipment(cap, 0);//头盔
//	SetEquipment(armor, 0);//胸甲

	//Load Animation Group
	int model_id = lookface / 1000000;
//	if (sex % 2 == SpriteSexMale) 
	//NSString* aniPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];  ///<临时性注释 郭浩
//	Initialization([[NSString stringWithFormat:@"%@model_%d.spr",aniPath,model_id] UTF8String] ); ///<临时性注释 郭浩
//	else 
//		Initialization(MANUELROLE_HUMAN_FEMALE);

	m_bFaceRight = m_nDirect == 2;
	SetFaceImageWithEquipmentId (m_bFaceRight);
	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);

	defaultDeal();
}

void NDBaseRole::SetEquipment(int equipmentId, int quality)
{
	/***
	 * 临时性注释 郭浩
	 */
//	if (equipmentId <= 0 ) 
//		return;
//	
//	NSString* imagePath = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
//	CCString* imagePath = new CCString("");
//	
//	if (equipmentId >= 200 && equipmentId < 10000) //武器
//	{
//		if ((equipmentId >= 1000 && equipmentId < 1200) || (equipmentId >= 1600 && equipmentId < 1800) || (equipmentId >= 2800 && equipmentId < 3000)) 
//		{
//			if (GetRightHandWeaponImage() == NULL) 
//			{
//				SetWeaponType(ONE_HAND_WEAPON);
//				SetRightHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//				SetWeaponQuality(quality);
//			}
//			else 
//			{				
//				SetSecWeaponType(ONE_HAND_WEAPON);
//				SetLeftHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//				SetSecWeaponQuality(quality);
//			}			
//		}
//		else if ((equipmentId >= 1200 && equipmentId < 1400) || (equipmentId >= 1800 && equipmentId < 2000))
//		{
//			SetWeaponType(TWO_HAND_WEAPON);
//			SetDoubleHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//			SetWeaponQuality(quality);
//		}
//		else if (equipmentId >= 2200 && equipmentId < 2400)
//		{
//			SetWeaponType(TWO_HAND_WAND);
//			SetDoubleHandWandImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//			SetWeaponQuality(quality);
//		}
//		else if (equipmentId >= 2400 && equipmentId < 2600)
//		{
//			SetWeaponType(TWO_HAND_BOW);
//			SetDoubleHandBowImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//			SetWeaponQuality(quality);
//		}
//		else if (equipmentId >= 2600 && equipmentId < 2800)
//		{
//			SetWeaponType(TWO_HAND_SPEAR);
//			SetDoubleHandSpearImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//			SetWeaponQuality(quality);
//		}
//		else if (equipmentId >= 5000 && equipmentId < 5200)
//		{
//			SetSecWeaponType(SEC_SHIELD);
//			SetShieldImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
//			SetSecWeaponQuality(quality);
//		}		
//	}
//	else if (equipmentId >= 10000 && equipmentId < 11800) //防具
//	{
//		if (equipmentId > 10000 && equipmentId < 10200) 
//		{
//			m_nHair = equipmentId;
//			SetHairImageWithEquipmentId(equipmentId);
//		}
//		else if (equipmentId >= 10200 && equipmentId < 10400)
//		{
//			// do nothing
//		}
//		else if (equipmentId >= 10400 && equipmentId < 10600)
//		{
//			expresstion = equipmentId;
//			SetExpressionImageWithEquipmentId(equipmentId);
//		}
//		else if (equipmentId >= 10600 && equipmentId < 11200)
//		{
//			cap = equipmentId;
//			SetCapImageWithEquipmentId(equipmentId);
//			SetCapQuality(quality);
//		}
//		else if (equipmentId >= 11200 && equipmentId < 11800)
//		{
//			armor = equipmentId;
//			SetArmorImageWithEquipmentId(equipmentId);
//			SetArmorQuality(quality);
//		}
//	}
//	else if (equipmentId >= 20000 && equipmentId < 30000 || equipmentId > 100000) //骑宠
//	{
//		SAFE_DELETE_NODE(ridepet);
//		ridepet = new NDRidePet;
//		ridepet->Initialization(equipmentId);
//		ridepet->quality = quality;
//		ridepet->SetPositionEx(GetPosition());
//		
//		if (IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
//		{
////			if (GetParent() && GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
////			{
////				SetAction(false);
////			}
//			
//			ridepet->SetOwner(this);
//		}
//		
//		/*
//		if (IsKindOfClass(RUNTIME_CLASS(NDNpc))) 
//		{
//			NDRidePet *ridepet = ((NDNpc*)this)->GetRidePet();
//			ridepet->Initialization(equipmentId);
//			ridepet->quality = quality;
//			ridepet->SetPositionEx(GetPosition());
//		}
//		*/
//	}
//	else if (equipmentId >= 30000 && equipmentId < 40000) //披风
//	{
//		cloak = equipmentId;
//		SetCloakImageWithEquipmentId(equipmentId);
//		SetCloakQuality(quality);
//	}	
}

/*
 * 从人形怪的lookface中解析出配置的武器，胸甲，头盔的lookface
 */
int NDBaseRole::getEquipmentLookFace(int lookface, int type)
{
	int nID = 0;
	switch (type)
	{
	case 0:
	{	//武器
		int index = lookface / 100000 % 100;
		if (index == 99)
		{
			return 0;
		}
		if (index < 10)
		{
			nID = 1000 + index;
		}
		else if (index < 20)
		{
			nID = 1600 + index - 10;
		}
		else if (index < 30)
		{
			nID = 2800 + index - 20;
		}
		else if (index < 40)
		{
			nID = 1200 + index - 30;
		}
		else if (index < 50)
		{
			nID = 1800 + index - 40;
		}
		else if (index < 60)
		{
			nID = 2200 + index - 50;
		}
		else if (index < 70)
		{
			nID = 2400 + index - 60;
		}
		else if (index < 80)
		{
			nID = 5000 + index - 70;
		}
		else if (index < 90)
		{
			nID = 2600 + index - 80;
		}
		break;
	}
	case 1:
	{ //头盔
		int index = lookface / 1000 % 100;
		if (index == 99)
		{
			return 0;
		}
		if (index < 5)
		{
			nID = 10600 + index;
		}
		else if (index < 21)
		{
			nID = 10650 + index - 5;
		}
		else if (index < 26)
		{
			nID = 10700 + index - 21;
		}
		else if (index < 28)
		{
			nID = 10750 + index - 26;
		}
		else
		{
			nID = 10800 + index - 28;
		};
		break;
	}
	case 2:
	{ //胸甲
		int index = lookface / 10 % 100;

		if (index == 99)
		{
			return 0;
		}
		if (index < 50)
		{
			if (index < 5)
			{
				nID = 11200 + index;
			}
			else if (index < 9)
			{
				nID = 11250 + index - 5;
			}
			else if (index < 14)
			{
				nID = 11300 + index - 9;
			}
			else
			{
				nID = 11400 + index - 14;
			}
		}
		else
		{ //披风
			nID = (index - 50) * 8 + 30000;
		}
		break;
	}
	}
	return nID;
}

void NDBaseRole::defaultDeal()
{
	if (m_nExpresstion == -1)
	{
		if (m_nSex % 2 == SpriteSexMale)
		{
			m_nExpresstion = 10400;
		}
		else
		{
			m_nExpresstion = 10401;
		}

		SetExpressionImageWithEquipmentId (m_nExpresstion);
	}
}

void NDBaseRole::SetHairImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10000 && equipmentId < 10400)
	{
		/**
		 * 临时性注释 郭浩
		 */
// 		NSString* hairImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		hairImageName = [NSString stringWithFormat:@"%@%d", hairImageName, equipmentId];
// 		if (sex % 2 == SpriteSexMale) 
// 		{
// 			hairImageName = [NSString stringWithFormat:@"%@_1", hairImageName];
// 		}
// 		else 
// 		{
// 			hairImageName = [NSString stringWithFormat:@"%@_2", hairImageName];
// 		}
// 		hairImageName = [NSString stringWithFormat:@"%@.png", hairImageName];
// 		SetHairImage([hairImageName UTF8String], hairColor);
	}
}

void NDBaseRole::SetFaceImageWithEquipmentId(int equipmentId)
{
	/**
	 * 临时性注释 郭浩
	 */

// 	NSString* faceImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 	faceImageName = [NSString stringWithFormat:@"%@skin.png", faceImageName];	
// 	//faceImageName = [NSString stringWithFormat:@"%@skin@%d.png", faceImageName, skinColor];
// 	SetFaceImage([faceImageName UTF8String]);
}

void NDBaseRole::SetExpressionImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10400 && equipmentId < 10600)
	{
		/**
		 * 临时性注释 郭浩
		 */

// 		NSString* expressionImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		expressionImageName = [NSString stringWithFormat:@"%@%d.png", expressionImageName, equipmentId];	
// 		SetExpressionImage([expressionImageName UTF8String]);
	}
}

void NDBaseRole::SetCapImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10600 && equipmentId < 11200)
	{
		/**
		 * 临时性注释 郭浩
		 * begin
		 */
// 		NSString* capImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		capImageName = [NSString stringWithFormat:@"%@%d.png", capImageName, equipmentId];	
// 		SetCapImage([capImageName UTF8String]);
		/**
		 * 临时性注释 郭浩
		 * end
		 */
	}
}

void NDBaseRole::SetArmorImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 11200 && equipmentId < 11800)
	{
		/**
		 * 临时性注释 郭浩
		 * begin
		 */
// 		NSString* armorImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		armorImageName = [NSString stringWithFormat:@"%@%d.png", armorImageName, equipmentId];	
// 		SetArmorImage([armorImageName UTF8String]);
		/**
		 * 临时性注释 郭浩
		 * end
		 */
	}
}

void NDBaseRole::SetCloakImageWithEquipmentId(int equipmentId)
{
	/*
	 if (equipmentId >= 11200 && equipmentId < 11800) 
	 {
	 NSString* cloakImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
	 cloakImageName = [NSString stringWithFormat:@"%@%d.png", cloakImageName, equipmentId];	
	 SetCloakImage([cloakImageName UTF8String]);
	 }
	 */
	if (equipmentId >= 30000 && equipmentId < 40000)
	{
		/**
		 * 临时性注释 郭浩
		 * begin
		 */

// 		NSString* cloakName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		cloakName = [NSString stringWithFormat:@"%@%d.png", cloakName, equipmentId+7];	
// 		SetCloakImage([cloakName UTF8String]);
// 		
// 		
// 		NSString* leftShoulderName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		leftShoulderName = [NSString stringWithFormat:@"%@%d.png", leftShoulderName, equipmentId+1];	
// 		SetLeftShoulderImage([leftShoulderName UTF8String]);
// 		
// 		NSString* rightShoulderName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		rightShoulderName = [NSString stringWithFormat:@"%@%d.png", rightShoulderName, equipmentId+2];	
// 		SetRightShoulderImage([rightShoulderName UTF8String]);
// 		
// 		NSString* skirtStandName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		skirtStandName = [NSString stringWithFormat:@"%@%d.png", skirtStandName, equipmentId+3];	
// 		SetSkirtStandImage([skirtStandName UTF8String]);
// 		
// 		NSString* skirtWalkName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		skirtWalkName = [NSString stringWithFormat:@"%@%d.png", skirtWalkName, equipmentId+4];	
// 		SetSkirtWalkImage([skirtWalkName UTF8String]);
// 		
// 		NSString* skirtSitName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		skirtSitName = [NSString stringWithFormat:@"%@%d.png", skirtSitName, equipmentId+5];	
// 		SetSkirtSitImage([skirtSitName UTF8String]);
// 		
// 		NSString* skirtLiftLegName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 		skirtLiftLegName = [NSString stringWithFormat:@"%@%d.png", skirtLiftLegName, equipmentId+6];	
// 		SetSkirtLiftLegImage([skirtLiftLegName UTF8String]);
		/**
		 * 临时性注释 郭浩
		 * end
		 */
	}
}

void NDBaseRole::DrawHead(const CGPoint& pos)
{
	m_pkAniGroup->setRuningSprite(this);
	m_pkAniGroup->drawHeadAt(pos);
}

void NDBaseRole::SetWeaponType(int weaponType)
{
	m_weaponType = weaponType;
}

int NDBaseRole::GetWeaponType()
{
	return m_weaponType;
}

void NDBaseRole::SetSecWeaponType(int secWeaponType)
{
	m_secWeaponType = secWeaponType;
}

int NDBaseRole::GetSecWeaponType()
{
	return m_secWeaponType;
}

void NDBaseRole::SetWeaponQuality(int quality)
{
	m_weaponQuality = quality;
}

int NDBaseRole::GetWeaponQuality()
{
	return m_weaponQuality;
}

void NDBaseRole::SetSecWeaponQuality(int quality)
{
	m_secWeaponQuality = quality;
}

int NDBaseRole::GetSecWeaponQuality()
{
	return m_secWeaponQuality;
}

void NDBaseRole::SetCapQuality(int quality)
{
	m_capQuality = quality;
}

int NDBaseRole::GetCapQuality()
{
	return m_capQuality;
}

void NDBaseRole::SetArmorQuality(int quality)
{
	m_armorQuality = quality;
}

int NDBaseRole::GetArmorQuality()
{
	return m_armorQuality;
}

void NDBaseRole::SetCloakQuality(int quality)
{
	m_cloakQuality = quality;
}

int NDBaseRole::GetCloakQuality()
{
	return m_cloakQuality;
}

void NDBaseRole::SetHair(int style, int color)
{

	switch (style)
	{
	case 1:
	case 0:
		m_nHair = 10000;
		break;
	case 2:
		m_nHair = 10001;
		break;
	case 3:
		m_nHair = 10002;
		break;
	}
	m_nHairColor = color;

	/**
	 * 临时性注释 郭浩
	 * begin
	 */
// 	NSString* hairImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
// 	hairImageName = [NSString stringWithFormat:@"%@%d", hairImageName, m_nHair];
// 	if (sex % 2 == SpriteSexMale) 
// 	{
// 		hairImageName = [NSString stringWithFormat:@"%@_1", hairImageName];
// 	}
// 	else 
// 	{
// 		hairImageName = [NSString stringWithFormat:@"%@_2", hairImageName];
// 	}
// 	hairImageName = [NSString stringWithFormat:@"%@.png", hairImageName];
// 	SetHairImage([hairImageName UTF8String], hairColor);
}

void NDBaseRole::SetMaxLife(int nMaxLife)
{
	m_nMaxLife = nMaxLife;

	if (m_nLife > nMaxLife)
	{
		m_nLife = nMaxLife;
	}
}

void NDBaseRole::SetMaxMana(int nMaxMana)
{
	m_nMaxMana = nMaxMana;
	if (m_nMaxMana > nMaxMana)
	{
		m_nMaxMana = nMaxMana;
	}
}

void NDBaseRole::SetCamp(CAMP_TYPE btCamp)
{
	m_eCamp = btCamp;
	if (btCamp == CAMP_TYPE_NONE)
	{
		m_strRank.clear();
	}
}

void NDBaseRole::SetPositionEx(CGPoint newPosition)
{
	NDSprite::SetPosition(newPosition);
}

NDRidePet* NDBaseRole::GetRidePet()
{
	if (m_pkRidePet == NULL)
	{
		m_pkRidePet = new NDRidePet;
	}
	return m_pkRidePet;
}

void NDBaseRole::unpackEquip(int iEquipPos)
{
	if (iEquipPos < Item::eEP_Begin || iEquipPos >= Item::eEP_End)
	{
		return;
	}

	switch (iEquipPos)
	{
	case Item::eEP_MainArmor:
		SetWeaponType(WEAPON_NONE);
		SetRightHandWeaponImage("");
		SetDoubleHandWeaponImage("");
		SetDoubleHandWandImage("");
		SetDoubleHandBowImage("");
		SetDoubleHandSpearImage("");
		SetWeaponQuality(0);
		break;
	case Item::eEP_FuArmor:
		SetSecWeaponType(WEAPON_NONE);
		SetLeftHandWeaponImage("");
		SetShieldImage("");
		SetSecWeaponQuality(0);
		break;
	case Item::eEP_Head:
		SetCapImage("");
		SetCapQuality(0);
		break;
	case Item::eEP_Armor:
		SetArmorImage("");
		SetArmorQuality(0);
		break;
	case Item::eEP_YaoDai:
		SetCloakImage("");
		SetLeftShoulderImage("");
		SetRightShoulderImage("");
		SetSkirtStandImage("");
		SetSkirtWalkImage("");
		SetSkirtSitImage("");
		SetSkirtLiftLegImage("");
		SetCloakQuality(0);
		m_nCloak = -1;
		break;
	case Item::eEP_Ride:
		SAFE_DELETE_NODE (m_pkRidePet);
		break;
	default:
		break;
	}
}

void NDBaseRole::unpakcAllEquip()
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		unpackEquip(i);
	}
}

void NDBaseRole::addTalkMsg(std::string msg, int timeForTalkMsg)
{
	NDScene *pkScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!pkScene || !pkScene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		return;
	}

	//if (!m_talkBox && subnode) 
	//{
	//	m_talkBox = new TalkBox;
	//	m_talkBox->Initialization();
	//	((GameScene*)scene)->AddUIChild(m_talkBox);
	//	m_talkBox->SetDelegate(this);
	//	m_talkBox->SetVisible(false);
	//}
	//
	//if (timeForTalkMsg == 0) m_talkBox->SetFix();
	//m_talkBox->addTalkMsg(msg, timeForTalkMsg);
}

void NDBaseRole::drawEffects(bool bDraw)
{
	if (m_pkEffectRidePetAniGroup != NULL
			&& m_pkEffectRidePetAniGroup->GetParent())
	{
		m_pkEffectRidePetAniGroup->SetPosition(GetPosition());
		m_pkEffectRidePetAniGroup->RunAnimation(bDraw);
	}
}

void NDBaseRole::updateRidePetEffect()
{
	if (AssuredRidePet() && m_pkRidePet->quality > 8)
	{
		SafeAddEffect(m_pkEffectRidePetAniGroup, "effect_3001.spr");
	}
	else
	{
		SafeClearEffect (m_pkEffectRidePetAniGroup);
	}
}

void NDBaseRole::SafeClearEffect(NDSprite*& sprite)
{
	if (sprite != NULL)
	{
		if (sprite->GetParent())
		{
			sprite->RemoveFromParent(true);
		}
		else
		{
			delete sprite;
		}

		sprite = NULL;
	}
}

void NDBaseRole::SafeAddEffect(NDSprite*& sprite, std::string file)
{
	if (sprite == NULL && !file.empty())
	{
		sprite = new NDSprite;
		sprite->Initialization(NDPath::GetAniPath(file.c_str()));
		sprite->SetCurrentAnimation(0, false);
	}
}

void NDBaseRole::ShowShadow(bool bShow, bool bBig /*= false*/)
{
	m_bShowShadow = bShow;
	m_bBigShadow = bBig;
}

void NDBaseRole::SetShadowOffset(int iX, int iY)
{
	m_iShadowOffsetX = iX;
	m_iShadowOffsetY = iY;
}

void NDBaseRole::HandleShadow(CGSize parentsize)
{
	if (!m_bShowShadow)
	{
		return;
	}

	NDPicture *pic = NULL;
	if (!m_bBigShadow)
	{
		if (m_pkPicShadow == NULL)
		{
			m_pkPicShadow = NDPicturePool::DefaultPool()->AddPicture(
					SHADOW_IMAGE);
		}
		pic = m_pkPicShadow;
	}
	else
	{
		if (m_pkPicShadowBig == NULL)
		{
			m_pkPicShadowBig = NDPicturePool::DefaultPool()->AddPicture(
					BIG_SHADOW_IMAGE);
		}
		pic = m_pkPicShadowBig;
	}

	CGSize sizeShadow = pic->GetSize();

	int x = m_kPosition.x - DISPLAY_POS_X_OFFSET;
	int y = m_kPosition.y - DISPLAY_POS_Y_OFFSET;

	pic->DrawInRect(
			CGRectMake(x + m_iShadowOffsetX,
					y + m_iShadowOffsetY
							+ NDDirector::DefaultDirector()->GetWinSize().height
							- parentsize.height, sizeShadow.width,
					sizeShadow.height));
}

void NDBaseRole::SetNormalAniGroup(int nLookface)
{
	if (nLookface <= 0)
	{
		return;
	}

	Initialization(
			tq::CString("%smodel_%d%s",
					NDEngine::NDPath::GetAnimationPath().c_str(),
					nLookface / 100, ".spr"));

	m_bFaceRight = true;
	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
}

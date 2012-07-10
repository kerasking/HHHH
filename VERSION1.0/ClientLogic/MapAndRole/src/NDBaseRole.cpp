/*
 *  NDBaseRole.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
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

using namespace NDEngine;

IMPLEMENT_CLASS(NDBaseRole, NDSprite)

bool NDBaseRole::s_bGameSceneRelease = false;

NDBaseRole::NDBaseRole()
{
	m_weaponType = WEAPON_NONE;
	m_secWeaponType = WEAPON_NONE;
	
	sex = -1;	
	skinColor = -1;		
	hairColor = -1;
	hair = -1;
	
	direct = -1;
	expresstion = -1;
	model = -1;
	weapon = -1;
	cap = -1;
	armor = -1;
	
	life = 0;
	maxLife = 0;
	mana = 0;
	maxMana = 0;
	level = 0;
	camp = CAMP_TYPE_NONE;
	
	m_faceRight = true;
	
	ridepet = NULL;
	
	m_bFocus = false;
	
	subnode = NDNode::Node();
	subnode->SetContentSize(NDDirector::DefaultDirector()->GetWinSize());
	
	m_posScreen = CGPointZero;	
	m_picRing = NULL; m_picShadow = NULL; m_picShadowBig = NULL;
	m_iShadowOffsetX = 0; m_iShadowOffsetY = 10;
	m_bBigShadow = false; m_bShowShadow = true;
	
	m_id = 0;
	
	effectFlagAniGroup = NULL;
	
	//m_talkBox = NULL;
	
	this->SetDelegate(this);
	
	effectRidePetAniGroup = NULL;
}

NDBaseRole::~NDBaseRole()
{
	SAFE_DELETE(subnode);
	SAFE_DELETE(m_picRing);
	SAFE_DELETE(m_picShadow);
	SAFE_DELETE(m_picShadowBig);
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
	
	if (ridepet)
	{
		point = ridepet->GetPosition();
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
	
	return CGRectMake(point.x-8-13, point.y-16-5, sizeRing.width, sizeRing.height);
}

void NDBaseRole::DirectRight(bool bRight)
{
	if (bRight) 
	{
		this->SetSpriteDir(1);
		if (ridepet) 
		{
			ridepet->SetSpriteDir(1);
		}
	}
	else 
	{
		this->SetSpriteDir(2);
		if (ridepet) 
		{
			ridepet->SetSpriteDir(2);
		}
	}
}

int NDBaseRole::getFlagId(int index)
{
	int iid = -1;
	switch (index) {
		case CAMP_NEUTRAL : iid = -1;break;
		case CAMP_SUI: iid = FLAG_SUI_DYNASTY_1;break;
		case CAMP_TANG: iid = FLAG_TAN_DYNASTY_1;break;
		case CAMP_TUJUE: iid = FLAG_TUJUE_DYNASTY_1;break;
		case CAMP_FOR_ESCORT : iid = FLAG_ESCORT_1;break;//镖旗
		case 5:iid = FLAG_TEAM_1;break; //队伍
	}
	return iid;
}

void NDBaseRole::DrawRingImage(bool bDraw)
{
	if (this->IsKindOfClass(RUNTIME_CLASS(NDNpc))) 
	{
		NDNpc* npc = (NDNpc*)this;
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
		
		if (this->GetParent()) 
		{
			NDLayer *layer = (NDLayer*)this->GetParent();
			CGSize sizemap = layer->GetContentSize();
			if (!ridepet)
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
	NDNode *node = this->GetParent();
	CGSize sizemap;
	if (node )
	{
		
		if (node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
		{
			//把baserole坐标转成屏幕坐标
			NDMapLayer *layer = (NDMapLayer*)node;
			CGPoint screen = layer->GetScreenCenter();
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_posScreen = ccpSub(this->GetPosition(), ccpSub(screen, CGPointMake(winSize.width / 2, winSize.height / 2)));
		}
		else 
		{
			m_posScreen = GetPosition();
		}
				
		sizemap = node->GetContentSize();
	}
	else	{
		return true;
	}
	
	subnode->SetContentSize(sizemap);
	
	HandleShadow(sizemap);
	
	DrawRingImage(bDraw);
	
	if (effectFlagAniGroup)
	{
		if (!effectFlagAniGroup->GetParent())
		{
			subnode->AddChild(effectFlagAniGroup);
		}
	}
	
	updateRidePetEffect();
	
	if (effectRidePetAniGroup)
	{
		if (!effectRidePetAniGroup->GetParent())
		{
			subnode->AddChild(effectRidePetAniGroup);
		}
	}
	
	drawEffects(bDraw);
	
	//if (m_talkBox) 
	//{
	//	m_talkBox->draw();
	//}
	
	return true;
}

void NDBaseRole::OnDrawEnd(bool bDraw)
{
}

void NDBaseRole::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
{
	if (node == m_talkBox) 
	{
		m_talkBox = NULL;
	}
	// 其它操作.....
}

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
		{// 人物普通移动
			AnimationListObj.moveAction(TYPE_MANUALROLE, this, m_faceRight);
		}
	} 
	else 
	{
		if (AssuredRidePet())
		{// 骑宠站立
			setStandActionWithRidePet();
		} 
		else 
		{
			AnimationListObj.standAction(TYPE_MANUALROLE, this, m_faceRight);
		}
	}
}

bool NDBaseRole::AssuredRidePet()
{
	return ridepet != NULL && ridepet->canRide();
}

void NDBaseRole::setMoveActionWithRidePet()
{
	if (!ridepet) 
	{
		return;
	}
	
	AnimationListObj.moveAction(TYPE_RIDEPET, ridepet, m_faceRight);// 骑宠移动
	switch (ridepet->iType)
	{
		case TYPE_RIDE:// 人物骑在骑宠上移动
			AnimationListObj.ridePetMoveAction(TYPE_MANUALROLE, this, m_faceRight);
			break;
		case TYPE_STAND:// 人物站在骑宠上移动
			AnimationListObj.standPetMoveAction(TYPE_MANUALROLE, this, m_faceRight);
			break;
		case TYPE_RIDE_BIRD:
			AnimationListObj.moveAction(TYPE_RIDEPET, ridepet, 1 -m_faceRight);
			AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_RIDE_BIRD_WALK);
			break;
		case TYPE_RIDE_FLY:
			AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_FLY_PET_WALK);
			break;
		case TYPE_RIDE_YFSH:
			AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_FLY_PET_WALK);
			break;
		case TYPE_RIDE_QL:
			AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_RIDE_QL);
			break;
	}
}

void NDBaseRole::setStandActionWithRidePet()
{
	if (!ridepet) 
	{
		return;
	}
	
	AnimationListObj.standAction(TYPE_RIDEPET, ridepet, m_faceRight);
	
	// 装备界面、属性界面、战斗中，人要站立状态
	//if (EquipUIScreen.instance == null
//	&& Attribute.instance == null
//	&& GameScreen.getInstance().getBattle() == null
//	&& NpcStore.instance == null/*
//	* && VipStore . instance ==
//	* null
//	*/) 
//	{
		switch (ridepet->iType)
		{
			case TYPE_RIDE:
				AnimationListObj.ridePetStandAction(TYPE_MANUALROLE, this, m_faceRight);
				break;
			case TYPE_STAND:
				AnimationListObj.standPetStandAction(TYPE_MANUALROLE, this, m_faceRight);
				break;
			case TYPE_RIDE_BIRD:
				AnimationListObj.standAction(TYPE_RIDEPET, ridepet, 1 - m_faceRight);
				AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_RIDE_BIRD_STAND);
				break;
			case TYPE_RIDE_FLY:
				AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight, MANUELROLE_FLY_PET_STAND);
				break;
			case TYPE_RIDE_YFSH:
				AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight,MANUELROLE_FLY_PET_WALK);
				break;
			case TYPE_RIDE_QL:
				AnimationListObj.setAction(TYPE_MANUALROLE, this, m_faceRight,MANUELROLE_RIDE_QL);
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
//	hair = lookface / 10000000 % 10;					// 发型
//	
//	SetHair(hair, hairColor);
//	SetHairImageWithEquipmentId(hair);
//	SetFaceImageWithEquipmentId(skinColor);
}

void NDBaseRole::InitNonRoleData(std::string name, int lookface, int lev)
{
	this->m_name = name;
	level = lev;
	//m_id = 0; // 用户id
//	sex = lookface / 100000000 % 10; // 人物性别，1-男性，2-女性；
//	direct = lookface % 10;
//	hairColor = lookface / 1000000 % 10;
//	int tmpsex = (sex - 1) / 2 - 1;
//	if (tmpsex < 0 || tmpsex > 2) {
//		tmpsex = 0;
//	}
//	this->SetHair(tmpsex+1); // 发型
//	
//	SetHairImageWithEquipmentId(hair);
	
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
	int model_id=lookface/1000000;
//	if (sex % 2 == SpriteSexMale) 
	NSString* aniPath = [NSString stringWithUTF8String:NDPath::GetAnimationPath().c_str()];
	Initialization([[NSString stringWithFormat:@"%@model_%d.spr",aniPath,model_id] UTF8String] );
//	else 
//		Initialization(MANUELROLE_HUMAN_FEMALE);
	
	m_faceRight = direct == 2;
	SetFaceImageWithEquipmentId(m_faceRight);
	SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
	
	defaultDeal();
}

void NDBaseRole::SetEquipment(int equipmentId, int quality)
{
	if (equipmentId <= 0 ) 
		return;
	
	NSString* imagePath = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
	
	if (equipmentId >= 200 && equipmentId < 10000) //武器
	{
		if ((equipmentId >= 1000 && equipmentId < 1200) || (equipmentId >= 1600 && equipmentId < 1800) || (equipmentId >= 2800 && equipmentId < 3000)) 
		{
			if (this->GetRightHandWeaponImage() == NULL) 
			{
				this->SetWeaponType(ONE_HAND_WEAPON);
				this->SetRightHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
				this->SetWeaponQuality(quality);
			}
			else 
			{				
				this->SetSecWeaponType(ONE_HAND_WEAPON);
				this->SetLeftHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
				this->SetSecWeaponQuality(quality);
			}			
		}
		else if ((equipmentId >= 1200 && equipmentId < 1400) || (equipmentId >= 1800 && equipmentId < 2000))
		{
			this->SetWeaponType(TWO_HAND_WEAPON);
			this->SetDoubleHandWeaponImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
			this->SetWeaponQuality(quality);
		}
		else if (equipmentId >= 2200 && equipmentId < 2400)
		{
			this->SetWeaponType(TWO_HAND_WAND);
			this->SetDoubleHandWandImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
			this->SetWeaponQuality(quality);
		}
		else if (equipmentId >= 2400 && equipmentId < 2600)
		{
			this->SetWeaponType(TWO_HAND_BOW);
			this->SetDoubleHandBowImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
			this->SetWeaponQuality(quality);
		}
		else if (equipmentId >= 2600 && equipmentId < 2800)
		{
			this->SetWeaponType(TWO_HAND_SPEAR);
			this->SetDoubleHandSpearImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
			this->SetWeaponQuality(quality);
		}
		else if (equipmentId >= 5000 && equipmentId < 5200)
		{
			this->SetSecWeaponType(SEC_SHIELD);
			this->SetShieldImage([[NSString stringWithFormat:@"%@%d.png", imagePath, equipmentId] UTF8String]);
			this->SetSecWeaponQuality(quality);
		}		
	}
	else if (equipmentId >= 10000 && equipmentId < 11800) //防具
	{
		if (equipmentId > 10000 && equipmentId < 10200) 
		{
			hair = equipmentId;
			this->SetHairImageWithEquipmentId(equipmentId);
		}
		else if (equipmentId >= 10200 && equipmentId < 10400)
		{
			// do nothing
		}
		else if (equipmentId >= 10400 && equipmentId < 10600)
		{
			expresstion = equipmentId;
			this->SetExpressionImageWithEquipmentId(equipmentId);
		}
		else if (equipmentId >= 10600 && equipmentId < 11200)
		{
			cap = equipmentId;
			this->SetCapImageWithEquipmentId(equipmentId);
			this->SetCapQuality(quality);
		}
		else if (equipmentId >= 11200 && equipmentId < 11800)
		{
			armor = equipmentId;
			this->SetArmorImageWithEquipmentId(equipmentId);
			this->SetArmorQuality(quality);
		}
	}
	else if (equipmentId >= 20000 && equipmentId < 30000 || equipmentId > 100000) //骑宠
	{
		SAFE_DELETE_NODE(ridepet);
		ridepet = new NDRidePet;
		ridepet->Initialization(equipmentId);
		ridepet->quality = quality;
		ridepet->SetPositionEx(this->GetPosition());
		
		if (this->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) 
		{
//			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
//			{
//				this->SetAction(false);
//			}
			
			ridepet->SetOwner(this);
		}
		
		/*
		if (this->IsKindOfClass(RUNTIME_CLASS(NDNpc))) 
		{
			NDRidePet *ridepet = ((NDNpc*)this)->GetRidePet();
			ridepet->Initialization(equipmentId);
			ridepet->quality = quality;
			ridepet->SetPositionEx(this->GetPosition());
		}
		*/
	}
	else if (equipmentId >= 30000 && equipmentId < 40000) //披风
	{
		cloak = equipmentId;
		this->SetCloakImageWithEquipmentId(equipmentId);
		this->SetCloakQuality(quality);
	}	
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
		{//武器
			int index = lookface / 100000 % 100;
			if (index == 99)
			{
				return 0;
			}
			if (index <10)
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
			int index =  lookface / 1000 % 100;
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
			else {
				nID = 10800 + index - 28;
			};
			break;
		}
		case 2: 
		{//胸甲
			int index =  lookface / 10 % 100;
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
				else if(index < 9) 
				{
					nID = 11250 + index - 5;
				}
				else if (index < 14)
				{
					nID = 11300 + index - 9;
				}
				else {
					nID = 11400 + index - 14;
				}
			}else 
			{ //披风
				nID = (index - 50)*8 + 30000;
			}
			break;
		}
	}
	return nID;
}

void NDBaseRole::defaultDeal()
{
	if (expresstion == -1) 
	{
		if (sex % 2 == SpriteSexMale) 
		{
			expresstion = 10400;
		} else 
		{
			expresstion = 10401;
		}
		SetExpressionImageWithEquipmentId(expresstion);
	}
}



void NDBaseRole::SetHairImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10000 && equipmentId < 10400) 
	{
		NSString* hairImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		hairImageName = [NSString stringWithFormat:@"%@%d", hairImageName, equipmentId];
		if (sex % 2 == SpriteSexMale) 
		{
			hairImageName = [NSString stringWithFormat:@"%@_1", hairImageName];
		}
		else 
		{
			hairImageName = [NSString stringWithFormat:@"%@_2", hairImageName];
		}
		hairImageName = [NSString stringWithFormat:@"%@.png", hairImageName];
		this->SetHairImage([hairImageName UTF8String], this->hairColor);
	}	
}

void NDBaseRole::SetFaceImageWithEquipmentId(int equipmentId)
{
	NSString* faceImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
	faceImageName = [NSString stringWithFormat:@"%@skin.png", faceImageName];	
	//faceImageName = [NSString stringWithFormat:@"%@skin@%d.png", faceImageName, skinColor];
	this->SetFaceImage([faceImageName UTF8String]);
}

void NDBaseRole::SetExpressionImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10400 && equipmentId < 10600) 
	{
		NSString* expressionImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		expressionImageName = [NSString stringWithFormat:@"%@%d.png", expressionImageName, equipmentId];	
		this->SetExpressionImage([expressionImageName UTF8String]);
	}
}

void NDBaseRole::SetCapImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 10600 && equipmentId < 11200) 
	{
		NSString* capImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		capImageName = [NSString stringWithFormat:@"%@%d.png", capImageName, equipmentId];	
		this->SetCapImage([capImageName UTF8String]);
	}
}

void NDBaseRole::SetArmorImageWithEquipmentId(int equipmentId)
{
	if (equipmentId >= 11200 && equipmentId < 11800) 
	{
		NSString* armorImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		armorImageName = [NSString stringWithFormat:@"%@%d.png", armorImageName, equipmentId];	
		this->SetArmorImage([armorImageName UTF8String]);
	}
}

void NDBaseRole::SetCloakImageWithEquipmentId(int equipmentId)
{
	/*
	 if (equipmentId >= 11200 && equipmentId < 11800) 
	 {
	 NSString* cloakImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
	 cloakImageName = [NSString stringWithFormat:@"%@%d.png", cloakImageName, equipmentId];	
	 this->SetCloakImage([cloakImageName UTF8String]);
	 }
	 */
	if (equipmentId >= 30000 && equipmentId < 40000)
	{
		NSString* cloakName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		cloakName = [NSString stringWithFormat:@"%@%d.png", cloakName, equipmentId+7];	
		this->SetCloakImage([cloakName UTF8String]);
		
		
		NSString* leftShoulderName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		leftShoulderName = [NSString stringWithFormat:@"%@%d.png", leftShoulderName, equipmentId+1];	
		this->SetLeftShoulderImage([leftShoulderName UTF8String]);
		
		NSString* rightShoulderName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		rightShoulderName = [NSString stringWithFormat:@"%@%d.png", rightShoulderName, equipmentId+2];	
		this->SetRightShoulderImage([rightShoulderName UTF8String]);
		
		NSString* skirtStandName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		skirtStandName = [NSString stringWithFormat:@"%@%d.png", skirtStandName, equipmentId+3];	
		this->SetSkirtStandImage([skirtStandName UTF8String]);
		
		NSString* skirtWalkName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		skirtWalkName = [NSString stringWithFormat:@"%@%d.png", skirtWalkName, equipmentId+4];	
		this->SetSkirtWalkImage([skirtWalkName UTF8String]);
		
		NSString* skirtSitName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		skirtSitName = [NSString stringWithFormat:@"%@%d.png", skirtSitName, equipmentId+5];	
		this->SetSkirtSitImage([skirtSitName UTF8String]);
		
		NSString* skirtLiftLegName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
		skirtLiftLegName = [NSString stringWithFormat:@"%@%d.png", skirtLiftLegName, equipmentId+6];	
		this->SetSkirtLiftLegImage([skirtLiftLegName UTF8String]);
	}
}

void NDBaseRole::DrawHead(const CGPoint& pos)
{
	[this->m_aniGroup setRuningSprite:this];
	[this->m_aniGroup drawHeadAt:pos];
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
			this->hair = 10000;
			break;
		case 2:
			this->hair = 10001;
			break;
		case 3:
			this->hair = 10002;
			break;
	}
	this->hairColor = color;
	
	NSString* hairImageName = [NSString stringWithUTF8String:NDPath::GetImagePath().c_str()];
	hairImageName = [NSString stringWithFormat:@"%@%d", hairImageName, this->hair];
	if (this->sex % 2 == SpriteSexMale) 
	{
		hairImageName = [NSString stringWithFormat:@"%@_1", hairImageName];
	}
	else 
	{
		hairImageName = [NSString stringWithFormat:@"%@_2", hairImageName];
	}
	hairImageName = [NSString stringWithFormat:@"%@.png", hairImageName];
	this->SetHairImage([hairImageName UTF8String], this->hairColor);
}

void NDBaseRole::SetMaxLife(int nMaxLife)
{
	this->maxLife = nMaxLife;
	if (this->life > nMaxLife)
	{
		this->life = nMaxLife;
	}
}

void NDBaseRole::SetMaxMana(int nMaxMana)
{
	this->maxMana = nMaxMana;
	if (this->mana > nMaxMana)
	{
		this->mana = nMaxMana;
	}
}

void NDBaseRole::SetCamp(CAMP_TYPE btCamp)
{
	this->camp = btCamp;
	if (btCamp == CAMP_TYPE_NONE)
	{
		this->rank.clear();
	}
}

void NDBaseRole::SetPositionEx(CGPoint newPosition)
{
	NDSprite::SetPosition(newPosition);
}

NDRidePet* NDBaseRole::GetRidePet()
{
	if (ridepet == NULL) 
	{
		ridepet = new NDRidePet;
	}
	return ridepet;
}

void NDBaseRole::unpackEquip(int iEquipPos)
{
	if (iEquipPos < Item::eEP_Begin || iEquipPos >= Item::eEP_End)
	{
		return;
	}
	
	switch (iEquipPos)
	{
		case Item::eEP_MainArmor :
			this->SetWeaponType(WEAPON_NONE);
			this->SetRightHandWeaponImage("");
			this->SetDoubleHandWeaponImage("");
			this->SetDoubleHandWandImage("");
			this->SetDoubleHandBowImage("");
			this->SetDoubleHandSpearImage("");
			this->SetWeaponQuality(0);
			break;
		case Item::eEP_FuArmor :
			this->SetSecWeaponType(WEAPON_NONE);
			this->SetLeftHandWeaponImage("");
			this->SetShieldImage("");
			this->SetSecWeaponQuality(0);
			break;
		case Item::eEP_Head:
			this->SetCapImage("");
			this->SetCapQuality(0);
			break;
		case Item::eEP_Armor:
			this->SetArmorImage("");
			this->SetArmorQuality(0);
			break;
		case Item::eEP_YaoDai:
			this->SetCloakImage("");
			this->SetLeftShoulderImage("");
			this->SetRightShoulderImage("");
			this->SetSkirtStandImage("");
			this->SetSkirtWalkImage("");
			this->SetSkirtSitImage("");
			this->SetSkirtLiftLegImage("");
			this->SetCloakQuality(0);
			this->cloak = -1;
			break;
		case Item::eEP_Ride:
			SAFE_DELETE_NODE(ridepet);
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

void NDBaseRole::addTalkMsg(std::string msg,int timeForTalkMsg)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
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
	if (effectRidePetAniGroup != NULL && effectRidePetAniGroup->GetParent()) 
	{
		effectRidePetAniGroup->SetPosition(GetPosition());
		effectRidePetAniGroup->RunAnimation(bDraw);
	}
}

void NDBaseRole::updateRidePetEffect()
{
	if (AssuredRidePet() && ridepet->quality > 8) {
		SafeAddEffect(effectRidePetAniGroup, "effect_3001.spr");
	} else {
		SafeClearEffect(effectRidePetAniGroup);
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
		sprite->Initialization(GetAniPath(file.c_str()));
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
		if (m_picShadow == NULL)
		{
			m_picShadow = NDPicturePool::DefaultPool()->AddPicture(SHADOW_IMAGE);
		}
		pic = m_picShadow;
	}
	else
	{
		if (m_picShadowBig == NULL)
		{
			m_picShadowBig = NDPicturePool::DefaultPool()->AddPicture(BIG_SHADOW_IMAGE);
		}
		pic = m_picShadowBig; 
	}
	
	CGSize sizeShadow = pic->GetSize();
	int x = m_position.x - DISPLAY_POS_X_OFFSET;
	int y = m_position.y - DISPLAY_POS_Y_OFFSET;
	pic->DrawInRect(CGRectMake(x + m_iShadowOffsetX, y+m_iShadowOffsetY+NDDirector::DefaultDirector()->GetWinSize().height-parentsize.height, sizeShadow.width, sizeShadow.height));
}

void NDBaseRole::SetNormalAniGroup(int lookface)
{
	if (lookface <= 0) {
		return;
	}


	Initialization( tq::CString("%smodel_%d%s", NDEngine::NDPath::GetAnimationPath().c_str(), lookface/100, ".spr") );

	m_faceRight = true;
	SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
}

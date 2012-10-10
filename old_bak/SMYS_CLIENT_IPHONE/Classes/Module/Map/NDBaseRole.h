/*
 *  NDBaseRole.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_BASE_ROLE_H
#define _ND_BASE_ROLE_H

#include "NDSprite.h"
#include "EnumDef.h"
#include "NDTip.h"

namespace NDEngine
{
	#define RING_IMAGE		([[NSString stringWithFormat:@"%s", GetImgPath("ui_ring.png")] UTF8String])
	#define SHADOW_IMAGE	([[NSString stringWithFormat:@"%s", GetImgPath("shadow.png")] UTF8String])
	#define BIG_SHADOW_IMAGE ([[NSString stringWithFormat:@"%s", GetImgPath("shadowBig.png")] UTF8String])
	
	#define CAMP_NEUTRAL	0
	#define CAMP_TANG		1
	#define CAMP_SUI		2
	#define CAMP_TUJUE		3
	#define CAMP_FOR_ESCORT 4
	#define CAMP_EUDEMON	6 
	#define CAMP_BATTLE		9
	
	class NDNode;
	class NDRidePet;
	class NDBaseRole : public NDSprite , public NDNodeDelegate
	{
		DECLARE_CLASS(NDBaseRole)
	public:
		NDBaseRole();
		~NDBaseRole();
	public:
		//以下方法供逻辑层使用－－－begin
		//......
		//－－－end
		bool OnDrawBegin(bool bDraw); override
		void OnDrawEnd(bool bDraw); override
		void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp); override
		
		CGPoint GetScreenPoint();
		void DirectRight(bool bRight);
		
	public:
		virtual void Update(unsigned long ulDiff){}
		virtual void SetAction(bool bMove);
		virtual bool AssuredRidePet();
		virtual void setMoveActionWithRidePet();
		virtual void setStandActionWithRidePet();
		
		virtual void drawEffects(bool bDraw);
		
		// 玩家的规则初始化lookface
		void InitRoleLookFace(int lookface);
		
		// NPC与怪物的初始化
		void InitNonRoleData(std::string name, int lookface, int lev);
		
		void SetHair(int style, int color = 1);
		
		void SetEquipment(int equipmentId, int quality);
		
		void defaultDeal();
		
		/** 从人形怪的lookface中解析出配置的武器，胸甲，头盔的lookface*/
		int getEquipmentLookFace(int lookface, int type);
		
		void SetHairImageWithEquipmentId(int equipmentId);
		void SetFaceImageWithEquipmentId(int equipmentId);
		void SetExpressionImageWithEquipmentId(int equipmentId);
		void SetCapImageWithEquipmentId(int equipmentId);
		void SetArmorImageWithEquipmentId(int equipmentId);
		void SetCloakImageWithEquipmentId(int equipmentId);
		
		void SetPositionEx(CGPoint newPosition);
		
		void unpackEquip(int iEquipPos);
		
		//适用于没有保存装备数据的角色
		virtual void unpakcAllEquip();
		
		void addTalkMsg(std::string msg,int timeForTalkMsg);
	public:
		void DrawHead(const CGPoint& pos);
		void SetWeaponType(int weaponType);
		int GetWeaponType();
		
		void SetSecWeaponType(int secWeaponType);
		int GetSecWeaponType();
		
		void SetWeaponQuality(int quality);
		int GetWeaponQuality();
		
		void SetSecWeaponQuality(int quality);
		int GetSecWeaponQuality();
		
		void SetCapQuality(int quality);
		int GetCapQuality();
		
		void SetArmorQuality(int quality);
		int GetArmorQuality();
		
		void SetCloakQuality(int quality);
		int GetCloakQuality();
		
		void SetMaxLife(int nMaxLife);
		int GetMaxLife() const { return this->maxLife; }
		
		void SetMaxMana(int nMaxMana);
		int GetMaxMana() const { return this->maxMana; }
		
		void SetCamp(CAMP_TYPE btCamp);
		CAMP_TYPE GetCamp() const { return this->camp; }
		
		void SetFocus(bool bFocus) { m_bFocus = bFocus; }
		bool IsFocus() { return m_bFocus; }
		virtual CGRect GetFocusRect();
		
		int getFlagId(int index);
		// 勿用,如需获取请直接访问ridePet
		NDRidePet* GetRidePet();
		
		void updateRidePetEffect();
	protected:	
		void SafeClearEffect(NDSprite*& sprite);
		void SafeAddEffect(NDSprite*& sprite, std::string file);
		
		void ShowShadow(bool bShow, bool bBig = false);
		void SetShadowOffset(int iX, int iY);
		void HandleShadow(CGSize parentsize);
		
		void DrawRingImage(bool bDraw);
	public: 
		int m_id;
		
	public:
		/**精灵的各个属性*/
		// lookface决定的5个属性
		int sex;	
		int skinColor;		
		int hairColor;
		int hair;
		
		int direct;
		int expresstion;
		int model;
		int weapon;
		int cap;
		int armor;
	
		/*基本角色信息*/
		int life;				//生命值
		int maxLife;			//最大生命值
		int mana;				//魔法
		int maxMana;			//最大魔法值
		int level;				//等级
		
		CAMP_TYPE camp;			//阵营
		std::string m_name;
		std::string rank;		// 军衔
	public:
		// 骑宠相关
		NDRidePet	*ridepet;
	private:
		bool		m_bFocus;
	public:
		NDNode		*subnode; // 角色对象的其它动画节点都挂在这个节点上
		CGPoint		m_posScreen;
	protected:
		NDPicture	*m_picRing;
		NDSprite	*effectFlagAniGroup;
		TalkBox		*m_talkBox;
		NDSprite	*effectRidePetAniGroup;
		NDPicture	*m_picShadow, *m_picShadowBig;
		int m_iShadowOffsetX, m_iShadowOffsetY;
		bool m_bShowShadow, m_bBigShadow;
	public:
		static bool s_bGameSceneRelease;
	};
	
}


#endif // _ND_BASE_ROLE_H
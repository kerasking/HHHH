/*
 *  NDBaseRole.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _ND_BASE_ROLE_H
#define _ND_BASE_ROLE_H

#include "NDSprite.h"
#include "EnumDef.h"
#include "NDPath.h"
#include "NDRidePet.h"

#define FIGHTER_HEIGHT 70 * RESOURCE_SCALE
#define FIGHTER_WIDTH  45 * RESOURCE_SCALE

NS_NDENGINE_BGN

#define RING_IMAGE			(NDPath::GetFullImagepath("ui_ring.png").c_str())
#define SHADOW_IMAGE		(NDPath::GetFullImagepath("shadow.png").c_str())
#define BIG_SHADOW_IMAGE	(NDPath::GetFullImagepath("shadowBig.png").c_str())

#define CAMP_NEUTRAL	0
#define CAMP_TANG		1
#define CAMP_SUI		2
#define CAMP_TUJUE		3
#define CAMP_FOR_ESCORT 4
#define CAMP_EUDEMON	6
#define CAMP_BATTLE		9

class NDNode;
class NDRidePet;

class NDBaseRole:
	public NDSprite,
	public NDNodeDelegate
{
	DECLARE_CLASS (NDBaseRole)
public:
	NDBaseRole();
	~NDBaseRole();
public:
	//以下方法供逻辑层使用－－－begin
	//......
	//－－－end

	bool OnDrawBegin(bool bDraw);
 	void OnDrawEnd(bool bDraw);

	CCPoint GetScreenPoint();
	void DirectRight(bool bRight);

public:

	virtual void Update(unsigned long ulDiff)
	{
	}
	virtual void SetAction(bool bMove);
	virtual bool AssuredRidePet();

	virtual void setMoveActionWithRidePet();
	virtual void setStandActionWithRidePet();

	virtual void drawEffects(bool bDraw);

	// 玩家的规则初始化lookface
	void InitRoleLookFace(int lookface);

	// NPC与怪物的初始化
	void InitNonRoleData( const std::string& name, int lookface, int lev );

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

	void SetPositionEx(CCPoint newPosition);

	void unpackEquip(int iEquipPos);

	//适用于没有保存装备数据的角色
	virtual void unpakcAllEquip();

	void addTalkMsg( const std::string& msg, int timeForTalkMsg );

public:
	void DrawHead(const CCPoint& pos);
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
	int GetMaxLife() const
	{
		return m_nMaxLife;
	}

	void SetMaxMana(int nMaxMana);
	int GetMaxMana() const
	{
		return m_nMaxMana;
	}

	void SetCamp(CAMP_TYPE btCamp);
	CAMP_TYPE GetCamp() const
	{
		return m_eCamp;
	}

	void SetFocus(bool bFocus)
	{
		m_bFocus = bFocus;
	}
	bool IsFocus()
	{
		return m_bFocus;
	}
	virtual CCRect GetFocusRect();

	int getFlagId(int index);

	void SetName( const std::string& strName );
	void SetRank( const std::string& strRank );
	
	const std::string& GetName() { return m_strName; }
	const std::string& GetRank() { return m_strRank; }

public:
	// 勿用，如需获取请直接访问ridePet
	NDRidePet* GetRidePet();

	void updateRidePetEffect();
	void SetRidePet(int lookface,int stand_action,int run_action,int acc);
	int GetPetStandAction() { return m_nPetStandAction; }
	int GetPetWalkAction() { return m_nPetRunAction; }
	int GetPetAccLevel() { return m_nAccLevel; }
	int GetPetLookface() { return m_nPetLookface; }

protected:
	void SafeClearEffect(NDSprite*& sprite);
	void SafeAddEffect(NDSprite*& sprite, const std::string& file);

	void ShowShadow(bool bShow, bool bBig = false);
	void SetShadowOffset(int iX, int iY);
	void HandleShadow(CCSize parentsize);

	void DrawRingImage(bool bDraw);

// 	virtual void RunBattleSubAnimation( Fighter* pkFighter );
// 	virtual bool DrawSubAnimation( NDSubAniGroup& kSag );

	virtual CCPoint getFootPos(); //in screen pixels.
	virtual CCPoint getHeadPos(); //in screen pixels.
	virtual void debugDraw();

public:
	static void drawCoord( const CCPoint& posScreen, bool bRightUp = true, bool blue = true, const float ofs = 10.f );
	virtual void RunAnimation(bool bDraw);

public:
	int m_nID;

public:
	/**精灵的各个属性*/
	// lookface决定的5个属性
	int m_nSex;
	int m_nSkinColor;
	int m_nHairColor;
	int m_nHair;

	int m_nDirect;
	int m_nExpresstion;
	int m_nModel;
	int m_nWeapon;
	int m_nCap;
	int m_nArmor;

	/*基本角色信息*/
	int m_nLife;				//生命值
	int m_nMaxLife;			//最大生命值
	int m_nMana;				//魔法
	int m_nMaxMana;			//最大魔法值
	int m_nLevel;				//等级

	CAMP_TYPE m_eCamp;			//阵营

protected:
	std::string m_strName; //utf8
	std::string m_strRank; //utf8 // 军衔

public:
	// 骑宠相关
	NDRidePet* m_pkRidePet;

private:
	bool m_bFocus;

public:
	NDNode* m_pkSubNode; // 角色对象的其它动画节点都挂在这个节点上
	CCPoint m_kScreenPosition;

protected:
	NDPicture* m_pkRingPic;
	NDSprite* m_pkEffectFlagAniGroup;
	//TalkBox *m_pkTalkBox;
	NDSprite* m_pkEffectRidePetAniGroup;
	NDPicture* m_pkPicShadow;
	NDPicture* m_pkPicShadowBig;
	int m_iShadowOffsetX;
	int m_iShadowOffsetY;
	bool m_bShowShadow;
	bool m_bBigShadow;
	bool m_bIsRide;
	int m_nPetStandAction;
	int m_nPetRunAction;
	int m_nAccLevel;
	int m_nPetLookface;
public:
	static bool ms_bGameSceneRelease;
};

NS_NDENGINE_END

#endif // _ND_BASE_ROLE_H

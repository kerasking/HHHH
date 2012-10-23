/*
 *  UiPetPart.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _UI_PET_PART_H_
#define _UI_PET_PART_H_

#include "UiPetDefine.h"
#include "define.h"

#include "NDScene.h"
#include "ImageNumber.h"
#include "NDUICustomView.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDSprite.h"
#include "NDCommonControl.h"
#include "GameUIAttrib.h"
#include "NewGameUIPetAttrib.h"

using namespace NDEngine;

class CUIPetPart : 
public NDUILayer, 
public NDUIEditDelegate,
public NDUICustomViewDelegate,
public NDUITableLayerDelegate
{
	friend class AttrInfo;
public:
	
	enum ePetAttrExt
	{
		ePABE_Begin = 0,
		ePABE_GrowRate = ePABE_Begin,
		ePABE_HpRate,
		ePABE_MpRate,
		ePABE_PhyAtkRate,
		ePABE_PhyDefRate,
		ePABE_MagAtkRate,
		ePABE_MagDefRate,
		ePABE_SpeedRate,
		ePABE_End,
	};
public:
	DECLARE_CLASS(CUIPetPart)
	CUIPetPart();
	~CUIPetPart();
	
public:
	void Initialization(); hide
	
	void Update(OBJID idPet, bool bEnable);
	
	void draw(); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void UpdateInfo();
	static std::string getPetType(int type);
	
	void AddProp(NDUINode* parent);

private:
	void UpdateBasicData(int eProp, int iMin, int iMax);
	void UpdateDetailData(int eProp, int value);
	void UpdateAdvanceData(int eProp, int value);
	bool UpdateDetailPetName(std::string str);
	
	void setBattlePetValueToPetAttr();
	
	void InitProp();
	
	void ResetData();
	
private:
	NDUILayer *m_layerProp;
	NDUITableLayer  *m_tableLayerDetail;
	
	OBJID m_idPet;
	bool m_bEnableOp;
	
private:
	std::string str_PET_ATTR_NAME; // 名字STRING
	
	int int_PET_ATTR_LEVEL_INIT; // 初始等级INT
	int int_PET_ATTR_STR_INIT; // 初始力量INT
	int int_PET_ATTR_STA_INIT; // 初始体质INT
	int int_PET_ATTR_AGI_INIT; // 初始敏捷INT
	int int_PET_ATTR_INI_INIT; // 初始智力INT
	int int_PET_ATTR_LOYAL; // 忠诚度INT
	int int_PET_ATTR_AGE; // 寿命INT
	int int_PET_ATTR_FREE_SP; // 剩余技能点数INT
	int int_PET_PHY_ATK_RATE;//物攻资质
	int int_PET_PHY_DEF_RATE;//物防资质
	int int_PET_MAG_ATK_RATE;//法攻资质
	int int_PET_MAG_DEF_RATE;//法防资质
	int int_PET_ATTR_HP_RATE; // 生命资质
	int int_PET_ATTR_MP_RATE; // 魔法资质
	int int_PET_MAX_SKILL_NUM;//最大可学技能数
	int int_PET_SPEED_RATE;//速度资质
	
	int int_PET_PHY_ATK_RATE_MAX;//物攻资质上限
	int int_PET_PHY_DEF_RATE_MAX;//物防资质上限
	int int_PET_MAG_ATK_RATE_MAX;//法攻资质上限
	int int_PET_MAG_DEF_RATE_MAX;//法防资质上限
	int int_PET_ATTR_HP_RATE_MAX; // 生命资质上限
	int int_PET_ATTR_MP_RATE_MAX; // 魔法资质上限
	int int_PET_SPEED_RATE_MAX;//速度资质上限
	
	int int_PET_GROW_RATE;// 成长率
	int int_PET_GROW_RATE_MAX;// 成长率
	int int_PET_HIT ;//命中
	
	int int_PET_ATTR_LEVEUP_EXP; // 升级经验
	int int_PET_ATTR_PHY_ATK; // 物理攻击力INT
	int int_PET_ATTR_PHY_DEF; // 物理防御INT
	int int_PET_ATTR_MAG_ATK; // 法术攻击力INT
	int int_PET_ATTR_MAG_DEF; // 法术抗性INT
	int int_PET_ATTR_HARD_HIT;// 暴击
	int int_PET_ATTR_DODGE;// 闪避
	int int_PET_ATTR_ATK_SPEED;// 攻击速度
	int int_PET_ATTR_TYPE;// 类型
	int bindStatus;//绑定状态

};

#endif


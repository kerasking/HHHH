/*
 *  UiPetPart.cpp
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UiPetPart.h"

#include <sstream>
#include <string>
#include "NDPlayer.h"
#import "NDPicture.h"
#import "NDManualRole.h"
#import "NDUILabel.h"
#import "NDUIButton.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUITableLayer.h"
#import "NDUIImage.h"
#import "define.h"
#import "NDConstant.h"
#import "ItemMgr.h"
#import "EnumDef.h"
#import "NDMsgDefine.h"
#import "NDDataTransThread.h"
#import "GameScene.h"
#import "NDUtility.h"
#import "PlayerInfoScene.h"
#include "NDMapMgr.h"
#include "GameUIAttrib.h"
#include "CPet.h"

/////////////////////////////////////////////////////////

#define prop_key_len (40)
#define prop_min_len (60)
#define prop_value_len (40)

/////////////////////////////////////////////////////////
enum ePetAttrDetail 
{
	ePAD_Begin = 0,
	ePAD_Bind = ePAD_Begin,
	ePAD_Quality,
	ePAD_XingGe,
	ePAD_InitLev,
	ePAD_Age,
	ePAD_Honyst,
	ePAD_SkillNum,
	ePAD_InitLiLiang,
	ePAD_InitTizhi,
	ePAD_InitMinJie,
	ePAD_InitZhiLi,
	ePAD_End,
};

string PetDetail[ePAD_End] = 
{
	NDCommonCString("BindState"), NDCommonCString("PingZhi"), NDCommonCString("XingGe"), NDCommonCString("ChuShiLvl"), 
	NDCommonCString("ShouMing"), NDCommonCString("HonestVal"), NDCommonCString("SkillCao"), 
	NDCommonCString("ChuShiLiLiang"), NDCommonCString("ChuShiTiZhi"), NDCommonCString("ChuShiMingJie"), NDCommonCString("ChuShiZhiLi")
};

enum ePetAttrAdvance 
{
	ePAA_Begin = 0,
	ePAA_PhyAtk = ePAA_Begin,
	ePAA_PhyDef,
	ePAA_MagicAtk,
	ePAA_MagicDef,
	ePAA_AtkSpeed,
	ePAA_HardHit,
	ePAA_Dodge,
	ePAA_PetHit,
	ePAA_End,
};

string PetAdvance[ePAA_End] = 
{
	NDCommonCString("PhyAtkVal"), NDCommonCString("PhyDef"), NDCommonCString("MagicAtkVal"), NDCommonCString("FaShuDef"), NDCommonCString("AtkSpeed"),
	NDCommonCString("CriticalHit"), NDCommonCString("DuoShang"), NDCommonCString("hit")
};

/////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIPetPart, NDUILayer)

CUIPetPart::CUIPetPart()
{
	m_tableLayerDetail = NULL;
	
	m_layerProp = NULL;
	
	str_PET_ATTR_NAME = ""; // 名字STRING
	
	int_PET_ATTR_LEVEL_INIT = 0; // 初始等级INT
	int_PET_ATTR_STR_INIT = 0; // 初始力量INT
	int_PET_ATTR_STA_INIT = 0; // 初始体质INT
	int_PET_ATTR_AGI_INIT = 0; // 初始敏捷INT
	int_PET_ATTR_INI_INIT = 0; // 初始智力INT
	int_PET_ATTR_LOYAL = 0; // 忠诚度INT
	int_PET_ATTR_AGE = 0; // 寿命INT
	int_PET_ATTR_FREE_SP = 0; // 剩余技能点数INT
	int_PET_PHY_ATK_RATE = 0;//物攻资质
	int_PET_PHY_DEF_RATE = 0;//物防资质
	int_PET_MAG_ATK_RATE = 0;//法攻资质
	int_PET_MAG_DEF_RATE = 0;//法防资质
	int_PET_ATTR_HP_RATE = 0; // 生命资质
	int_PET_ATTR_MP_RATE = 0; // 魔法资质
	int_PET_MAX_SKILL_NUM = 0;//最大可学技能数
	int_PET_SPEED_RATE = 0;//速度资质
	
	int_PET_PHY_ATK_RATE_MAX = 0;//物攻资质上限
	int_PET_PHY_DEF_RATE_MAX = 0;//物防资质上限
	int_PET_MAG_ATK_RATE_MAX = 0;//法攻资质上限
	int_PET_MAG_DEF_RATE_MAX = 0;//法防资质上限
	int_PET_ATTR_HP_RATE_MAX = 0; // 生命资质上限
	int_PET_ATTR_MP_RATE_MAX = 0; // 魔法资质上限
	int_PET_SPEED_RATE_MAX = 0;//速度资质上限
	
	int_PET_GROW_RATE = 0;// 成长率
	int_PET_GROW_RATE_MAX = 0;// 成长率
	int_PET_HIT  = 0;//命中
	
	int_PET_ATTR_LEVEUP_EXP = 0; // 升级经验
	int_PET_ATTR_PHY_ATK = 0; // 物理攻击力INT
	int_PET_ATTR_PHY_DEF = 0; // 物理防御INT
	int_PET_ATTR_MAG_ATK = 0; // 法术攻击力INT
	int_PET_ATTR_MAG_DEF = 0; // 法术抗性INT
	int_PET_ATTR_HARD_HIT = 0;// 暴击
	int_PET_ATTR_DODGE = 0;// 闪避
	int_PET_ATTR_ATK_SPEED = 0;// 攻击速度
	int_PET_ATTR_TYPE = 0;// 类型
	bindStatus = 0;//绑定状态
} 

CUIPetPart::~CUIPetPart()
{
}

void CUIPetPart::Initialization()
{
	NDUILayer::Initialization();
	InitProp();
	AddProp(this);
}

void CUIPetPart::Update(OBJID idPet, bool bEnable)
{
	m_idPet = idPet;
	m_bEnableOp = bEnable;
	
	setBattlePetValueToPetAttr();
	
	UpdateInfo();
}

void CUIPetPart::draw()
{	
}

bool CUIPetPart::OnCustomViewConfirm(NDUICustomView* customView)
{
	if (!m_bEnableOp)
	{
		return true;
	}
	
	std::string strName = customView->GetEditText(0);
	if (!strName.empty() && UpdateDetailPetName(strName))
	{
		NDTransData bao(_MSG_NAME);
		bao << int(m_idPet) << (unsigned char)0;
		bao.WriteUnicodeString(strName);
		SEND_DATA(bao);
	}
	return true;
}

void CUIPetPart::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table != m_tableLayerDetail) return;
	
	if (cellIndex == 0)
	{
		if (!m_bEnableOp)
		{
			return;
		}
		
		if (!cell->IsKindOfClass(RUNTIME_CLASS(NDNamePropCell))) return;
		
		stringstream ss;
		ss << NDCommonCString("InputNewPetName");
		NDUICustomView *view = new NDUICustomView;
		view->Initialization();
		view->SetDelegate(this);
		std::vector<int> vec_id; vec_id.push_back(101);
		std::vector<std::string> vec_str; vec_str.push_back(ss.str());
		view->SetEdit(1, vec_id, vec_str);
		view->Show();
		this->AddChild(view);
		return;
	}
	
	if (cell->IsKindOfClass(RUNTIME_CLASS(NDPetPropCell)))
	{
		return;
	}
	
	if (!cell->IsKindOfClass(RUNTIME_CLASS(NDPropCell))) return; 
	
	NDPropCell *prop = (NDPropCell*)cell;
	
	if (cell->GetTag() >= 200)
	{
		int eProp = cell->GetTag() - 200;
		if (eProp < ePAA_Begin || eProp >= ePAA_End) return;
		
		// eProp ->高级属性
	}
	else if (cell->GetTag() >= 100)
	{
		int eProp = cell->GetTag() - 100;
		if (eProp < ePAD_Begin || eProp >= ePAD_End) return;
		
		// eProp ->详细属性
	}
	NDUILabel *lb = prop->GetKeyText();
	
//	if (lb && m_attrInfo && m_attrInfo->GetDescLabel())
//	{
//		//m_attrInfo->GetDescLabel()->SetText(lb->GetText().c_str());
//		/*
//		 m_attrInfo->SetContentText(
//		 "1.力量 提升物理攻击力同时增加HP值" 
//		 "2.体质 提升物理防御同时增加大幅增加HP值" 
//		 "3.敏捷 提升攻击速度和少量提升物理攻击及闪避能力"
//		 "智力 提升法术攻击力和魔法防御力同时大幅增加MP值"
//		 "力量 提升物理攻击力同时增加HP值" 
//		 "体质 提升物理防御同时增加大幅增加HP值" 
//		 "4.敏捷 提升攻击速度和少量提升物理攻击及闪避能力"
//		 "5.智力 提升法术攻击力和魔法防御力同时大幅增加MP值"
//		 "6.力量 提升物理攻击力同时增加HP值" 
//		 "7.体质 提升物理防御同时增加大幅增加HP值" 
//		 "8.敏捷 提升攻击速度和少量提升物理攻击及闪避能力"
//		 "9.智力 提升法术攻击力和魔法防御力同时大幅增加MP值"
//		 "10.力量 提升物理攻击力同时增加HP值" 
//		 "11.体质 提升物理防御同时增加大幅增加HP值" 
//		 "12.敏捷 提升攻击速度和少量提升物理攻击及闪避能力"
//		 "13.智力 提升法术攻击力和魔法防御力同时大幅增加MP值2");*/
//		
//		//ShowAttrInfo(true);
//	}
}

void CUIPetPart::UpdateInfo()
{
	setBattlePetValueToPetAttr();
	
	UpdateBasicData(ePABE_GrowRate, int_PET_GROW_RATE, int_PET_GROW_RATE_MAX);
	UpdateBasicData(ePABE_HpRate, int_PET_ATTR_HP_RATE, int_PET_ATTR_HP_RATE_MAX);
	UpdateBasicData(ePABE_MpRate, int_PET_ATTR_MP_RATE, int_PET_ATTR_MP_RATE_MAX);
	UpdateBasicData(ePABE_PhyAtkRate, int_PET_PHY_ATK_RATE, int_PET_PHY_ATK_RATE_MAX);
	UpdateBasicData(ePABE_PhyDefRate, int_PET_PHY_DEF_RATE, int_PET_PHY_DEF_RATE_MAX);
	UpdateBasicData(ePABE_MagAtkRate, int_PET_MAG_ATK_RATE, int_PET_MAG_ATK_RATE_MAX);
	UpdateBasicData(ePABE_MagDefRate, int_PET_MAG_DEF_RATE, int_PET_MAG_DEF_RATE_MAX);
	UpdateBasicData(ePABE_SpeedRate, int_PET_SPEED_RATE, int_PET_SPEED_RATE_MAX);
	
	UpdateDetailPetName(str_PET_ATTR_NAME);
	
	UpdateDetailData(ePAD_Bind, bindStatus);
	UpdateDetailData(ePAD_Quality, int_PET_ATTR_TYPE);
	UpdateDetailData(ePAD_XingGe, int_PET_ATTR_TYPE);
	UpdateDetailData(ePAD_InitLev, int_PET_ATTR_LEVEL_INIT);
	UpdateDetailData(ePAD_Age, int_PET_ATTR_AGE);
	UpdateDetailData(ePAD_Honyst, int_PET_ATTR_LOYAL);
	UpdateDetailData(ePAD_SkillNum, int_PET_MAX_SKILL_NUM);
	UpdateDetailData(ePAD_InitLiLiang, int_PET_ATTR_STR_INIT);
	UpdateDetailData(ePAD_InitTizhi, int_PET_ATTR_STA_INIT);
	UpdateDetailData(ePAD_InitMinJie, int_PET_ATTR_AGI_INIT);
	UpdateDetailData(ePAD_InitZhiLi, int_PET_ATTR_INI_INIT);
	
	UpdateAdvanceData(ePAA_PhyAtk, int_PET_ATTR_PHY_ATK);
	UpdateAdvanceData(ePAA_PhyDef, int_PET_ATTR_PHY_DEF);
	UpdateAdvanceData(ePAA_MagicAtk, int_PET_ATTR_MAG_ATK);
	UpdateAdvanceData(ePAA_MagicDef, int_PET_ATTR_MAG_DEF);
	UpdateAdvanceData(ePAA_AtkSpeed, int_PET_ATTR_ATK_SPEED);
	UpdateAdvanceData(ePAA_HardHit, int_PET_ATTR_HARD_HIT);
	UpdateAdvanceData(ePAA_Dodge, int_PET_ATTR_DODGE);
	UpdateAdvanceData(ePAA_PetHit, int_PET_HIT);
}

void CUIPetPart::UpdateBasicData(int eProp, int iMin, int iMax)
{
	if (eProp < ePABE_Begin || eProp >= ePABE_End ) return;
	
	if (!m_tableLayerDetail
	    || !m_tableLayerDetail->GetDataSource()
		|| m_tableLayerDetail->GetDataSource()->Count() == 0
		|| m_tableLayerDetail->GetDataSource()->Section(0)->Count() <= (unsigned int)(eProp+1))
		return ;
	
	NDUINode* cell = m_tableLayerDetail->GetDataSource()->Section(0)->Cell(eProp+1);
	
	if(!cell || !cell->IsKindOfClass(RUNTIME_CLASS(NDPetPropCell))) return;
	
	NDPetPropCell* prop = (NDPetPropCell*)cell;
	
	prop->SetNum(iMin, iMax);
}

void CUIPetPart::UpdateDetailData(int eProp, int value)
{
	if (eProp < ePAD_Begin || eProp >= ePAD_End ) return;
	
	if (!m_tableLayerDetail
	    || !m_tableLayerDetail->GetDataSource()
		|| m_tableLayerDetail->GetDataSource()->Count() == 0
		|| m_tableLayerDetail->GetDataSource()->Section(0)->Count() <= (unsigned int)(eProp+1+ePABE_End))
		return ;
	
	NDUINode *node = m_tableLayerDetail->GetDataSource()->Section(0)->Cell(eProp+1+ePABE_End);								
	
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDPropCell))) return;
	
	if (node->GetTag() != 100+eProp) return;
	
	NDPropCell* prop = (NDPropCell*)node;
	
	stringstream ss;  
	if (eProp == ePAD_XingGe) 
	{
		ss << getPetType(value);
	}
	else if (eProp == ePAD_Quality) 
	{
		int tempInt = value % 10;
		if (tempInt >= 5) 
		{
			ss << NDItemType::PETLEVEL(tempInt - 5);
		}
	}
	else if (eProp == ePAD_Bind)
	{
		if (value == BIND_STATE_BIND) 
		{
			ss << NDCommonCString("hadbind");
		} else {
			ss << NDCommonCString("WeiBind");
		}
	}
	else 
	{
		ss << value;
	}
	
	if (prop->GetValueText())
		prop->GetValueText()->SetText(ss.str().c_str());	
}

void CUIPetPart::UpdateAdvanceData(int eProp, int value)
{
	if (eProp < ePAA_Begin || eProp >= ePAA_End ) return;
	
	if (!m_tableLayerDetail
	    || !m_tableLayerDetail->GetDataSource()
		|| m_tableLayerDetail->GetDataSource()->Count() == 0
		|| m_tableLayerDetail->GetDataSource()->Section(0)->Count() <= (unsigned int)(eProp+1+ePABE_End+ePAD_End))
		return ;
	
	NDUINode *node = m_tableLayerDetail->GetDataSource()->Section(0)->Cell(eProp+1+ePABE_End+ePAD_End);								
	
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDPropCell))) return;
	
	if (node->GetTag() != 200+eProp) return;
	
	NDPropCell* prop = (NDPropCell*)node;
	
	stringstream ss; ss << value;
	
	if (prop->GetValueText())
		prop->GetValueText()->SetText(ss.str().c_str());
}

bool CUIPetPart::UpdateDetailPetName(std::string str)
{
	if (!m_tableLayerDetail 
		|| !m_tableLayerDetail->GetDataSource() 
		|| m_tableLayerDetail->GetDataSource()->Count() == 0
		|| m_tableLayerDetail->GetDataSource()->Section(0)->Count() == 0) 
	{
		return false;
	}
	
	NDUINode* node = m_tableLayerDetail->GetDataSource()->Section(0)->Cell(0);
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDNamePropCell))) 
	{
		NDNamePropCell* prop = (NDNamePropCell*)node;
		
		if (prop->GetKeyText())
			prop->GetKeyText()->SetText(str.c_str());
		return true;
	}
	
	return false;
}

void CUIPetPart::setBattlePetValueToPetAttr()
{
	PetInfo* petInfo = PetMgrObj.GetPet(m_idPet);
	if (!petInfo)
	{
		ResetData();
		return;
	}
	else
	{
		PetInfo::PetData& pet = petInfo->data;
		

		str_PET_ATTR_NAME = petInfo->str_PET_ATTR_NAME; // 名字STRING
		
		int_PET_ATTR_LEVEL_INIT = pet.int_PET_ATTR_LEVEL_INIT; // 初始等级INT
		int_PET_ATTR_STR_INIT = pet.int_PET_ATTR_STR_INIT; // 初始力量INT
		int_PET_ATTR_STA_INIT = pet.int_PET_ATTR_STA_INIT; // 初始体质INT
		int_PET_ATTR_AGI_INIT = pet.int_PET_ATTR_AGI_INIT; // 初始敏捷INT
		int_PET_ATTR_INI_INIT = pet.int_PET_ATTR_INI_INIT; // 初始智力INT
		int_PET_ATTR_LOYAL = pet.int_PET_ATTR_LOYAL; // 忠诚度INT
		int_PET_ATTR_AGE = pet.int_PET_ATTR_AGE; // 寿命INT
		int_PET_ATTR_FREE_SP = pet.int_PET_ATTR_FREE_SP; // 剩余技能点数INT
		int_PET_PHY_ATK_RATE = pet.int_PET_PHY_ATK_RATE;// 物攻资质
		int_PET_PHY_DEF_RATE = pet.int_PET_PHY_DEF_RATE;// 物防资质
		int_PET_MAG_ATK_RATE = pet.int_PET_MAG_ATK_RATE;// 法攻资质
		int_PET_MAG_DEF_RATE = pet.int_PET_MAG_DEF_RATE;// 法防资质
		int_PET_ATTR_HP_RATE = pet.int_PET_ATTR_HP_RATE; // 生命资质
		int_PET_ATTR_MP_RATE = pet.int_PET_ATTR_MP_RATE; // 魔法资质
		int_PET_MAX_SKILL_NUM = pet.int_PET_MAX_SKILL_NUM;// 最大可学技能数
		int_PET_SPEED_RATE = pet.int_PET_SPEED_RATE;// 速度资质

		int_PET_ATTR_LEVEUP_EXP = pet.int_PET_ATTR_LEVEUP_EXP; // 升级经验
		int_PET_ATTR_PHY_ATK = pet.int_PET_ATTR_PHY_ATK; // 物理攻击力INT
		int_PET_ATTR_PHY_DEF = pet.int_PET_ATTR_PHY_DEF; // 物理防御INT
		int_PET_ATTR_MAG_ATK = pet.int_PET_ATTR_MAG_ATK; // 法术攻击力INT
		int_PET_ATTR_MAG_DEF = pet.int_PET_ATTR_MAG_DEF; // 法术抗性INT
		int_PET_ATTR_HARD_HIT = pet.int_PET_ATTR_HARD_HIT;// 暴击
		int_PET_ATTR_DODGE = pet.int_PET_ATTR_DODGE;// 闪避
		int_PET_ATTR_ATK_SPEED = pet.int_PET_ATTR_ATK_SPEED;// 攻击速度
		
		int_PET_GROW_RATE_MAX=pet.int_PET_GROW_RATE_MAX;// 成长资质上限
		int_PET_PHY_ATK_RATE_MAX=pet.int_PET_PHY_ATK_RATE_MAX;// 物攻资质上限
		int_PET_PHY_DEF_RATE_MAX=pet.int_PET_PHY_DEF_RATE_MAX;// 物防资质上限
		int_PET_MAG_ATK_RATE_MAX=pet.int_PET_MAG_ATK_RATE_MAX;// 法攻资质上限
		int_PET_MAG_DEF_RATE_MAX=pet.int_PET_MAG_DEF_RATE_MAX;// 法防资质上限
		int_PET_ATTR_HP_RATE_MAX=pet.int_PET_ATTR_HP_RATE_MAX; // 生命资质上限
		int_PET_ATTR_MP_RATE_MAX=pet.int_PET_ATTR_MP_RATE_MAX; // 魔法资质上限
		int_PET_SPEED_RATE_MAX=pet.int_PET_SPEED_RATE_MAX;// 速度资质上限
		int_PET_GROW_RATE=pet.int_PET_GROW_RATE;//成长资质
		bindStatus = pet.bindStatus;
	}
}

std::string CUIPetPart::getPetType(int type) {
	std::string s = "";
	switch (type / 10 % 10) {
		case 1:
			s = NDCommonCString("LuMang");
			break;
		case 2:
			s = NDCommonCString("LengJing");
			break;
		case 3:
			s = NDCommonCString("TaoQi");
			break;
		case 4:
			s = NDCommonCString("HangHou");
			break;
		case 5:
			s = NDCommonCString("DangXiao");
			break;
	}
	return s;
}



#pragma mark 新加的

void CUIPetPart::AddProp(NDUINode* parent)
{
	if (!parent || !m_layerProp) return;
	
	CGSize size = parent->GetFrameRect().size;
	m_layerProp->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerProp);
}

void CUIPetPart::InitProp()
{
	m_layerProp = new NDUILayer;
	
	m_layerProp->Initialization();
	
	int width = 252;//, height = 274;
	
	m_tableLayerDetail = new NDUITableLayer;
	m_tableLayerDetail->Initialization();
	m_tableLayerDetail->SetSelectEvent(false);
	m_tableLayerDetail->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tableLayerDetail->VisibleSectionTitles(false);
	m_tableLayerDetail->SetFrameRect(CGRectMake(8, 17, width-10, 226));
	m_tableLayerDetail->VisibleScrollBar(false);
	m_tableLayerDetail->SetCellsInterval(2);
	m_tableLayerDetail->SetCellsRightDistance(0);
	m_tableLayerDetail->SetCellsLeftDistance(0);
	m_tableLayerDetail->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	NDNamePropCell *nameCell = new NDNamePropCell;
	nameCell->Initialization();
	if (nameCell->GetKeyText())
		nameCell->GetKeyText()->SetText(str_PET_ATTR_NAME.c_str());
	if (nameCell->GetValueText())
		nameCell->GetValueText()->SetText(NDCommonCString("modify"));
	nameCell->SetFocusTextColor(ccc4(255, 0, 0, 255));
	section->AddCell(nameCell);
	
#define fastinit(str, min, max) \
do \
{ \
NDPetPropCell* prop = new NDPetPropCell; \
prop->Initialization(str, min, max); \
section->AddCell(prop); \
} while (0)
	
	fastinit(NDCommonCString("ChengZhangZiZhi"), int_PET_GROW_RATE, int_PET_GROW_RATE_MAX);
	fastinit(NDCommonCString("QiXueZiZhi"), int_PET_ATTR_HP_RATE, int_PET_ATTR_HP_RATE_MAX);
	fastinit(NDCommonCString("FaLiZiZhi"), int_PET_ATTR_MP_RATE, int_PET_ATTR_MP_RATE_MAX);
	fastinit(NDCommonCString("WuGongZiZhi"), int_PET_PHY_ATK_RATE, int_PET_PHY_ATK_RATE_MAX);
	fastinit(NDCommonCString("WuFangZiZhi"), int_PET_PHY_DEF_RATE, int_PET_PHY_DEF_RATE_MAX);
	fastinit(NDCommonCString("FaGongZiZhi"), int_PET_MAG_ATK_RATE, int_PET_MAG_ATK_RATE_MAX);
	fastinit(NDCommonCString("FaFangZiZhi"), int_PET_MAG_DEF_RATE, int_PET_MAG_DEF_RATE_MAX);
	fastinit(NDCommonCString("SpeedZiZhi"), int_PET_SPEED_RATE, int_PET_SPEED_RATE_MAX);
	
#undef	fastinit
	
	for ( int i=ePAD_Begin; i<ePAD_End; i++) 
	{
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(true);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(PetDetail[i].c_str());
		propDetail->SetTag(100+i);
		section->AddCell(propDetail);
	}
	
	for(int i=ePAA_Begin; i<ePAA_End; i++)
	{
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(true);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(PetAdvance[i].c_str());
		propDetail->SetTag(200+i);
		section->AddCell(propDetail);
	}
	
	dataSource->AddSection(section);
	m_tableLayerDetail->SetDataSource(dataSource);
	m_layerProp->AddChild(m_tableLayerDetail);
}

void CUIPetPart::ResetData()
{
	str_PET_ATTR_NAME = ""; // 名字STRING
	
	int_PET_ATTR_LEVEL_INIT = 0; // 初始等级INT
	int_PET_ATTR_STR_INIT = 0; // 初始力量INT
	int_PET_ATTR_STA_INIT = 0; // 初始体质INT
	int_PET_ATTR_AGI_INIT = 0; // 初始敏捷INT
	int_PET_ATTR_INI_INIT = 0; // 初始智力INT
	int_PET_ATTR_LOYAL = 0; // 忠诚度INT
	int_PET_ATTR_AGE = 0; // 寿命INT
	int_PET_ATTR_FREE_SP = 0; // 剩余技能点数INT
	int_PET_PHY_ATK_RATE = 0;// 物攻资质
	int_PET_PHY_DEF_RATE = 0;// 物防资质
	int_PET_MAG_ATK_RATE = 0;// 法攻资质
	int_PET_MAG_DEF_RATE = 0;// 法防资质
	int_PET_ATTR_HP_RATE = 0; // 生命资质
	int_PET_ATTR_MP_RATE = 0; // 魔法资质
	int_PET_MAX_SKILL_NUM = 0;// 最大可学技能数
	int_PET_SPEED_RATE = 0;// 速度资质
	
	int_PET_ATTR_LEVEUP_EXP = 0; // 升级经验
	int_PET_ATTR_PHY_ATK = 0; // 物理攻击力INT
	int_PET_ATTR_PHY_DEF = 0; // 物理防御INT
	int_PET_ATTR_MAG_ATK = 0; // 法术攻击力INT
	int_PET_ATTR_MAG_DEF = 0; // 法术抗性INT
	int_PET_ATTR_HARD_HIT = 0;// 暴击
	int_PET_ATTR_DODGE = 0;// 闪避
	int_PET_ATTR_ATK_SPEED = 0;// 攻击速度
	
	int_PET_GROW_RATE_MAX=0;// 成长资质上限
	int_PET_PHY_ATK_RATE_MAX=0;// 物攻资质上限
	int_PET_PHY_DEF_RATE_MAX=0;// 物防资质上限
	int_PET_MAG_ATK_RATE_MAX=0;// 法攻资质上限
	int_PET_MAG_DEF_RATE_MAX=0;// 法防资质上限
	int_PET_ATTR_HP_RATE_MAX=0; // 生命资质上限
	int_PET_ATTR_MP_RATE_MAX=0; // 魔法资质上限
	int_PET_SPEED_RATE_MAX=0;// 速度资质上限
	int_PET_GROW_RATE=0;//成长资质
	bindStatus = 0;
}
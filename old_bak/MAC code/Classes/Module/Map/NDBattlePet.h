/*
 *  NDBattlePet.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_BATTLE_PET_H_
#define _ND_BATTLE_PET_H_

#include "NDMonster.h"
#include <string>
#include "BattleUtil.h"

namespace NDEngine
{
	typedef enum
	{
		OrderStateUp,
		OrderStateDown
	}OrderState;
	
	class NDBattlePet : public NDMonster 
	{
		DECLARE_CLASS(NDBattlePet)
	public:
		NDBattlePet();
		~NDBattlePet();
		virtual void OnMoving(bool bLastPos);
	public:
		//以下方法供逻辑层使用－－－begin
		//......	
		void Initialization(int lookface); hide
		
		bool OnDrawBegin(bool bDraw); override
		
		void WalkToPosition(CGPoint toPos);
		
		void OnMoveEnd(); override
		
		void SetPosition(CGPoint newPosition); override
		
		int GetOrder(); override
		
		void SetOrderState(OrderState state);
		//－－－end
		
		void AddSkill(OBJID idSkill);
		
		void DelSkill(OBJID idSkill);
		
		//SET_BATTLE_SKILL_LIST& GetSkillList(SKILL_TYPE type) {
//			if (type == SKILL_TYPE_ATTACK) {
//				return this->m_setActSkill;
//			} else {
//				return this->m_setPasSkill;
//			}
//		}
//		
//		int SkillSize() { return m_setActSkill.size()+m_setPasSkill.size(); }
		
		void SetOwnerID(int ownerID) { m_idOwner = ownerID; }
		
		void SetQuality(int quality) { this->m_iQuality = quality; }
		
		int GetQuality() { return m_iQuality; }
		
	public:
		//std::string str_PET_ATTR_NAME; // 名字STRING
//		int int_PET_ATTR_LEVEL; // 等级INT
//		int int_PET_ATTR_EXP; // 经验INT
//		int int_PET_ATTR_LIFE; // 生命值INT
//		int int_PET_ATTR_MAX_LIFE; // 最大生命值INT
//		int int_PET_ATTR_MANA; // 魔法值INT
//		int int_PET_ATTR_MAX_MANA; // 最大魔法值INT
//		int int_PET_ATTR_STR; // 力量INT
//		int int_PET_ATTR_STA; // 体质INT
//		int int_PET_ATTR_AGI; // 敏捷INT
//		int int_PET_ATTR_INI; // 智力INT
//		int int_PET_ATTR_LEVEL_INIT; // 初始等级INT
//		int int_PET_ATTR_STR_INIT; // 初始力量INT
//		int int_PET_ATTR_STA_INIT; // 初始体质INT
//		int int_PET_ATTR_AGI_INIT; // 初始敏捷INT
//		int int_PET_ATTR_INI_INIT; // 初始智力INT
//		int  int_PET_ATTR_LOYAL; // 忠诚度INT
//		int int_PET_ATTR_AGE; // 寿命INT
//		int int_PET_ATTR_FREE_SP; // 剩余技能点数INT
//		int int_PET_PHY_ATK_RATE;//物攻资质
//		int int_PET_PHY_DEF_RATE;//物防资质
//		int int_PET_MAG_ATK_RATE;//法攻资质
//		int int_PET_MAG_DEF_RATE;//法防资质
//		int int_PET_ATTR_HP_RATE; // 生命资质
//		int int_PET_ATTR_MP_RATE; // 魔法资质
//		int int_PET_MAX_SKILL_NUM;//最大可学技能数
//		int int_PET_SPEED_RATE;//速度资质
//		
//		int int_PET_PHY_ATK_RATE_MAX;//物攻资质上限
//		int int_PET_PHY_DEF_RATE_MAX;//物防资质上限
//		int int_PET_MAG_ATK_RATE_MAX;//法攻资质上限
//		int int_PET_MAG_DEF_RATE_MAX;//法防资质上限
//		int int_PET_ATTR_HP_RATE_MAX; // 生命资质上限
//		int int_PET_ATTR_MP_RATE_MAX; // 魔法资质上限
//		int int_PET_SPEED_RATE_MAX;//速度资质上限
//		
//		int int_PET_GROW_RATE;// 成长率
//		int int_PET_GROW_RATE_MAX;// 成长率
//		int int_PET_HIT ;//命中
//		
//		int int_ATTR_FREE_POINT; //自由点数
//		int int_PET_ATTR_LEVEUP_EXP; // 升级经验
//		int int_PET_ATTR_PHY_ATK; // 物理攻击力INT
//		int int_PET_ATTR_PHY_DEF; // 物理防御INT
//		int int_PET_ATTR_MAG_ATK; // 法术攻击力INT
//		int int_PET_ATTR_MAG_DEF; // 法术抗性INT
//		int int_PET_ATTR_HARD_HIT;// 暴击
//		int int_PET_ATTR_DODGE;// 闪避
//		int int_PET_ATTR_ATK_SPEED;// 攻击速度
//		int int_PET_ATTR_TYPE;// 类型
//		int int_PET_ATTR_LOOKFACE;//外观
		
		OrderState m_orderState;
		
		static int tmpRestPoint,tmpStrPoint,tmpStaPoint,tmpAgiPoint,tmpIniPoint;// 加减点完前临时的宠物属性
	private:
		CGPoint m_preSetPos;
		SET_BATTLE_SKILL_LIST m_setActSkill;
		SET_BATTLE_SKILL_LIST m_setPasSkill;
		
		int m_idOwner;
		
		int m_iQuality;
		
		DECLARE_AUTOLINK(NDBattlePet)
		INTERFACE_AUTOLINK(NDBattlePet)
	};
}

#endif // _ND_BATTLE_PET_H_
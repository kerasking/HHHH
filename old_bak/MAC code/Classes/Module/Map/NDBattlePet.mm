/*
 *  NDBattlePet.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDBattlePet.h"
#include "NDConstant.h"
#include "CGPointExtension.h"
#include "BattleMgr.h"
#include "NDMapMgr.h"
#include "NDManualRole.h"
#include "NDPlayer.h"
#include "NDDataPersist.h"

namespace NDEngine
{	

	int NDBattlePet::tmpRestPoint = 0; 
	int NDBattlePet::tmpStrPoint = 0; 
	int NDBattlePet::tmpStaPoint = 0; 
	int NDBattlePet::tmpAgiPoint = 0; 
	int NDBattlePet::tmpIniPoint = 0;
	
	IMPLEMENT_CLASS(NDBattlePet, NDMonster)
	NDBattlePet::NDBattlePet()
	{
		INIT_AUTOLINK(NDBattlePet);
		m_iQuality = 0;
		//int_PET_ATTR_LEVEL = 0; // 等级INT
//		int_PET_ATTR_EXP = 0; // 经验INT
//		int_PET_ATTR_LIFE = 0; // 生命值INT
//		int_PET_ATTR_MAX_LIFE = 0; // 最大生命值INT
//		int_PET_ATTR_MANA = 0; // 魔法值INT
//		int_PET_ATTR_MAX_MANA = 0; // 最大魔法值INT
//		int_PET_ATTR_STR = 0; // 力量INT
//		int_PET_ATTR_STA = 0; // 体质INT
//		int_PET_ATTR_AGI = 0; // 敏捷INT
//		int_PET_ATTR_INI = 0; // 智力INT
//		int_PET_ATTR_LEVEL_INIT = 0; // 初始等级INT
//		int_PET_ATTR_STR_INIT = 0; // 初始力量INT
//		int_PET_ATTR_STA_INIT = 0; // 初始体质INT
//		int_PET_ATTR_AGI_INIT = 0; // 初始敏捷INT
//		int_PET_ATTR_INI_INIT = 0; // 初始智力INT
//		int_PET_ATTR_LOYAL = 0; // 忠诚度INT
//		int_PET_ATTR_AGE = 0; // 寿命INT
//		int_PET_ATTR_FREE_SP = 0; // 剩余技能点数INT
//		int_PET_PHY_ATK_RATE = 0;//物攻资质
//		int_PET_PHY_DEF_RATE = 0;//物防资质
//		int_PET_MAG_ATK_RATE = 0;//法攻资质
//		int_PET_MAG_DEF_RATE = 0;//法防资质
//		int_PET_ATTR_HP_RATE = 0; // 生命资质
//		int_PET_ATTR_MP_RATE = 0; // 魔法资质
//		int_PET_MAX_SKILL_NUM = 0;//最大可学技能数
//		int_PET_SPEED_RATE = 0;//速度资质
//		
//		int_PET_PHY_ATK_RATE_MAX = 0;//物攻资质上限
//		int_PET_PHY_DEF_RATE_MAX = 0;//物防资质上限
//		int_PET_MAG_ATK_RATE_MAX = 0;//法攻资质上限
//		int_PET_MAG_DEF_RATE_MAX = 0;//法防资质上限
//		int_PET_ATTR_HP_RATE_MAX = 0; // 生命资质上限
//		int_PET_ATTR_MP_RATE_MAX = 0; // 魔法资质上限
//		int_PET_SPEED_RATE_MAX = 0;//速度资质上限
//		
//		int_PET_GROW_RATE = 0;// 成长率
//		int_PET_GROW_RATE_MAX = 0;// 成长率
//		int_PET_HIT  = 0;//命中
//		
//		int_ATTR_FREE_POINT = 0; //自由点数
//		int_PET_ATTR_LEVEUP_EXP = 0; // 升级经验
//		int_PET_ATTR_PHY_ATK = 0; // 物理攻击力INT
//		int_PET_ATTR_PHY_DEF = 0; // 物理防御INT
//		int_PET_ATTR_MAG_ATK = 0; // 法术攻击力INT
//		int_PET_ATTR_MAG_DEF = 0; // 法术抗性INT
//		int_PET_ATTR_HARD_HIT = 0;// 暴击
//		int_PET_ATTR_DODGE = 0;// 闪避
//		int_PET_ATTR_ATK_SPEED = 0;// 攻击速度
//		int_PET_ATTR_TYPE = 0;// 类型
//		int_PET_ATTR_LOOKFACE = 0;//外观
		
		m_orderState = OrderStateUp;
		
		m_idOwner = 0;
	}
	
	NDBattlePet::~NDBattlePet()
	{
	}
	
	void NDBattlePet::OnMoving(bool bLastPos)
	{
	}
	
	void NDBattlePet::Initialization(int lookface)
	{
		NDBaseRole::SetNormalAniGroup(lookface);
	}
	
	bool NDBattlePet::OnDrawBegin(bool bDraw)
	{
		
		if (m_idOwner != 0) 
		{
			NDMapMgr& mgr = NDMapMgrObj;
			
			NDManualRole *role = mgr.GetManualRole(m_idOwner);
			
			if (role && role->IsInState(USERSTATE_FLY) && mgr.canFly())
			{
				return false;			
			}
		}
		
		if (m_idOwner != NDPlayer::defaultHero().m_id 
			&& !NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)
			&& (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))) 
		{
			return false;
		}
		
		return NDMonster::OnDrawBegin(bDraw);
	}
	
	void NDBattlePet::WalkToPosition(CGPoint toPos)
	{
		this->SetCurrentAnimation(MONSTER_MAP_MOVE, !m_faceRight);
	}
	
	void NDBattlePet::OnMoveEnd()
	{
		this->SetCurrentAnimation(MONSTER_MAP_STAND, m_faceRight);
	}
	
	void NDBattlePet::SetPosition(CGPoint newPosition)
	{
		
	//	if(!m_faceRight)
//		{
//			NDSprite::SetPosition(ccp(newPosition.x-16,newPosition.y));
//		}
//		else
//		{
//			NDSprite::SetPosition(ccp(newPosition.x+16,newPosition.y));
//		}
		
		static bool bFirst = true;
		if (bFirst) 
		{
			if(!m_faceRight)
			{
				NDSprite::SetPosition(ccp(newPosition.x+12,newPosition.y));
			}
			else 
			{
				NDSprite::SetPosition(ccp(newPosition.x-12,newPosition.y));
			}
			bFirst = false;
			m_preSetPos = newPosition;
		}
		else 
		{
			//if (newPosition.x/16 == GetPosition().x/16)
//			{
//				if (newPosition.y/16 > GetPosition().y/16)
//				{ // down
//					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-16));
//				}
//				else if (newPosition.y/16 < GetPosition().y/16)
//				{ // up
//					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+16));
//				}
//				return;
//			}
			
			if (m_preSetPos.x == newPosition.x && m_preSetPos.y == newPosition.y)
			{
				if(!m_faceRight)
				{
					NDSprite::SetPosition(ccp(newPosition.x-12,newPosition.y));
				}
				else
				{
					NDSprite::SetPosition(ccp(newPosition.x+12,newPosition.y));
				}
			}
			else if (m_preSetPos.x == newPosition.x)
			{
				if (m_preSetPos.y <= newPosition.y)
				{ //down
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-12));
				}
				else 
				{
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+12));
				}
			}
			else if (m_preSetPos.y == newPosition.y)
			{
				if(!m_faceRight)
				{
					NDSprite::SetPosition(ccp(newPosition.x-12,newPosition.y));
				}
				else
				{
					NDSprite::SetPosition(ccp(newPosition.x+12,newPosition.y));
				}
			}
			else
			{
				if(!m_faceRight)
				{
					NDSprite::SetPosition(ccp(newPosition.x-12,newPosition.y));
				}
				else
				{
					NDSprite::SetPosition(ccp(newPosition.x+12,newPosition.y));
				}
			}
			m_preSetPos = newPosition;
			return;
			
			int nNewCol = newPosition.x/MAP_UNITSIZE;
			int nNewRow = newPosition.y/MAP_UNITSIZE;
			int nOldCol = GetPosition().x/MAP_UNITSIZE;
			int nOldRow = GetPosition().y/MAP_UNITSIZE;
			
			
			if (abs(long(newPosition.x-GetPosition().x)) > abs(long(newPosition.y-GetPosition().y)))
			{
				if(!m_faceRight)
				{
					NDSprite::SetPosition(ccp(newPosition.x-16,newPosition.y));
				}
				else
				{
					NDSprite::SetPosition(ccp(newPosition.x+16,newPosition.y));
				}
				return;
			}
			else 
			{
				if (newPosition.y > GetPosition().y)
				{ //down
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-16));
					return;
				}
				
				if (nNewRow < nOldRow)
				{
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+16));
					return;
				}
			}

			
			if (nNewCol != nOldCol)
			{
				if(!m_faceRight)
				{
					NDSprite::SetPosition(ccp(newPosition.x-16,newPosition.y));
				}
				else
				{
					NDSprite::SetPosition(ccp(newPosition.x+16,newPosition.y));
				}
				return;
			}
			
			if (nNewRow > nOldRow)
			{ //down
				NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-16));
				return;
			}
			
			if (nNewRow < nOldRow)
			{
				NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+16));
				return;
			}
			
			
			
			//if (m_orderState == OrderStateUp) 
//			{
//				NDSprite::SetPosition(ccp(GetPosition().x,newPosition.y+16));
//			}
//			else if (m_orderState == OrderStateDown)
//			{
//				NDSprite::SetPosition(ccp(GetPosition().x,newPosition.y-16));
//			}
		
		}
	}
	
	void NDBattlePet::SetOrderState(OrderState state)
	{
		m_orderState = state;
	}
	
	int NDBattlePet::GetOrder()
	{
		if (m_orderState == OrderStateUp) 
		{
			return m_position.y + 17;
		}
		else if (m_orderState == OrderStateDown)
		{
			return m_position.y + 15;
		}
		
		return NDMonster::GetOrder();
		
	}
	
	void NDBattlePet::AddSkill(OBJID idSkill)
	{
		BattleMgr& bm = BattleMgrObj;
		BattleSkill* skill = bm.GetBattleSkill(idSkill);
		if (!skill) {
			return;
		}
		
		if (skill->getType() == SKILL_TYPE_ATTACK) {
			this->m_setActSkill.insert(idSkill);
		} else if (skill->getType() == SKILL_TYPE_PASSIVE) {
			this->m_setPasSkill.insert(idSkill);
		}
	}
	
	void NDBattlePet::DelSkill(OBJID idSkill)
	{
		BattleMgr& bm = BattleMgrObj;
		BattleSkill* skill = bm.GetBattleSkill(idSkill);
		if (!skill) {
			return;
		}
		
		if (skill->getType() == SKILL_TYPE_ATTACK) {
			this->m_setActSkill.erase(idSkill);
		} else if (skill->getType() == SKILL_TYPE_PASSIVE) {
			this->m_setPasSkill.erase(idSkill);
		}
	}
}
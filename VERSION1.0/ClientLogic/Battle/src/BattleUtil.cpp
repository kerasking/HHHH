/*
 *  BattleUtil.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-20.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "BattleUtil.h"
#include "Fighter.h"
#include "NDConstant.h"
#include "TaskListener.h"

using namespace NDEngine;

void defenceAction(Fighter& f)
{
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_DEFENCE;
	f.m_bDefenceAtk=true;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	
//	if (f.m_lookfaceType==LOOKFACE_MANUAL) {
//		switch (role->GetWeaponType()) {
//			case ONE_HAND_WEAPON:
//				if (role->GetSecWeaponType() == ONE_HAND_WEAPON) {
//					action = MANUELROLE_DEFENCE_DUAL_WEAPON;
//				} else {
//					action = MANUELROLE_DEFENCE_ONE_HAND_WEAPON;
//				}
//				break;
//			case WEAPON_NONE:
//				if (role->GetSecWeaponType() == ONE_HAND_WEAPON) {
//					action = MANUELROLE_DEFENCE_ONE_HAND_WEAPON;
//				} else {
//					action = MANUELROLE_DEFENCE_FREEHAND;
//				}
//				break;
//				
//			case TWO_HAND_WEAPON:
//				action = MANUELROLE_DEFENCE_TWO_HAND_WEAPON;
//				break;
//				
//			case TWO_HAND_BOW:
//				action = MANUELROLE_DEFENCE_TWO_HAND_BOW;
//				break;
//			case TWO_HAND_WAND:
//				action = MANUELROLE_DEFENCE_TWO_HAND_WAND;
//				break;
//			default:
//				action = MANUELROLE_DEFENCE_FREEHAND;
//				break;
//		}
//	} else {
//		action = MONSTER_DEFENCE;
//		bFaceRight = !bFaceRight;
//	}
	
	role->SetCurrentAnimation(action, bFaceRight);
}

void assasinSkillAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	int skill = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	
	if (f.m_eLookfaceType==LOOKFACE_MANUAL) {
		skill = f.getUseSkill()->getSkillTypeID();
		action = MANUELROLE_SKILL_ASSASIN_BOW_SINGLE;
		switch (skill) {
			case 131401:// Ãé×¼Éä»÷
			case 131402:// Ò»¼ý·âºí
			case 131403:
			case 131405:
			case 131406:
			case 131407:
			case 131409:
				action = MANUELROLE_SKILL_ASSASIN_BOW_SINGLE;
				break;
			case 131404:
			case 131408:
				action = MANUELROLE_SKILL_ASSASIN_BOW_AREA;
				break;
			case 131201:// ÇÐ¸î
			case 131202:// ¶Û»¯
			case 131203:
				action = MANUELROLE_SKILL_ASSASIN_SWORD_SINGLE;
				break;
			case 131001:// Òþ¶Ý
				action = MANUELROLE_SKILL_ASSASIN_SWORD_SINGLE;
				break;
			case 131303:// ÒôËÙÅ×»÷
			case 131307:// ÁúÓù·Éµ¶
			case 131304:// ¼±ËÙÁÆÉË
				action = MANUELROLE_SKILL_WARRIOR_SWORD_AREA;
				break;
			case 131301:// ×·ÐÄ´Ì
			case 131302:// º®¹âÉÁÏÖ
			case 131305:// Ò»ÈÐÆÆ·¨
			case 131306:// ³éµ¶¶øÖÁ
			case 131308:// ÖÂÃüÒ»»÷
				action = MANUELROLE_SKILL_ASSASIN_PONIARD_SINGLE;
				break;
		}
	} else {
		action = MONSTER_ATTACK;
		bFaceRight = !bFaceRight;
	}
	
	role->SetCurrentAnimation(action, bFaceRight);
}

void wizzardSkillAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	switch (f.m_kInfo.fighterType) {
		case FIGHTER_TYPE_PET:
			action = MANUELROLE_SKILL_WIZZARD;
			break;
		case FIGHTER_TYPE_EUDEMON:
		case FIGHTER_TYPE_ELITE_MONSTER:
		case FIGHTER_TYPE_MONSTER:
		case Fighter_TYPE_RARE_MONSTER:
			//			if (f.m_info.bRoleMonster) {
			//				action = MANUELROLE_SKILL_WIZZARD;
			//			} else {
			action = MONSTER_ATTACK;
			bFaceRight = !bFaceRight;
			//}
			break;
		default:
			break;
	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void warriorSkillAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	int skill = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	
	if (f.m_kInfo.fighterType == FIGHTER_TYPE_PET) {
		skill = f.getUseSkill()->getSkillTypeID();
		action = MANUELROLE_SKILL_WARRIOR_SWORD_SINGLE;
		switch (skill) {
			case 111201:// ´©ÐÄ½£
			case 111202:// ÆÆ¼×½£
			case 111205:
			case 111204:// ÆÆ¼×½£
			case 111206:
			case 111208:
				action = MANUELROLE_SKILL_WARRIOR_SWORD_SINGLE;
				break;
			case 111203:
			case 111207:
				action = MANUELROLE_SKILL_WARRIOR_SWORD_AREA;
				break;
			case 111101:// Á÷ÔÆÕ¶
			case 111102:// »ðÔÆµ¶
			case 111104:
				action = MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE;
				break;
			case 111103:// ºáÉ¨Ç§¾ü
			case 111105:
			case 111106:
				action = MANUELROLE_SKILL_WARRIOR_KNIFE_AREA;
				break;
			case 111001:
				action = MANUELROLE_SKILL_WIZZARD;
				break;
			case 111002:
				action = MANUELROLE_SKILL_WIZZARD;
				break;
			case 141501:
			case 141502:
			case 141503:
			case 141504:
				action = MANUELROLE_QIANG_SKILL_ATTACK;
				break;
		}
	} else {
		action = MONSTER_SKILL_ATTACK;
		bFaceRight = !bFaceRight;
	}
	
	role->SetCurrentAnimation(action, bFaceRight);
}

void attackAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_ATTACK;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		switch (role->GetWeaponType()) {
//			case TWO_HAND_SPEAR:
//				action = MANUELROLE_QIANG_NORMAL_ATTACK;
//				break;
//			case ONE_HAND_WEAPON:
//				if (role->GetSecWeaponType() == ONE_HAND_WEAPON) {
//					action = MANUELROLE_ATTACK_DUAL_WEAPON;
//				} else {
//					action = MANUELROLE_ATTACK_ONE_HAND_WEAPON;
//				}
//				break;
//			case WEAPON_NONE:
//				if (role->GetSecWeaponType() == ONE_HAND_WEAPON) {
//					action = MANUELROLE_ATTACK_ONE_HAND_WEAPON;
//				} else {
//					action = MANUELROLE_ATTACK_FREEHAND;
//				}
//				break;
//			case TWO_HAND_WEAPON:
//				action = MANUELROLE_ATTACK_TWO_HAND_WEAPON;
//				break;
//				
//			case TWO_HAND_BOW:
//				action = MANUELROLE_ATTACK_TWO_HAND_BOW;
//				break;
//			case TWO_HAND_WAND:
//				action = MANUELROLE_ATTACK_TWO_HAND_WAND;
//				break;
//			default:
//				action = MANUELROLE_ATTACK_FREEHAND;
//				break;
//		}
//	} else {
//		action = MONSTER_ATTACK;
//		bFaceRight = !bFaceRight;
//	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void moveToTargetAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_BATTLE_STAND;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		action = MANUELROLE_MOVE_TO_TARGET;
//	}else{
////		if (role->bRoleMonster) {
////			action = MANUELROLE_MOVE_TO_TARGET;
////		} else {
//			action = MONSTER_MOVE_TO_TARGET;
//			bFaceRight=!bFaceRight;
////		}
//	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void dodgeAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	if(f.m_eLookfaceType==LOOKFACE_MANUAL){
		action = MANUELROLE_DODGE;
	}else{
//		if (role->bRoleMonster) {
//			action = MANUELROLE_DODGE;
//		} else {
			action = MONSTER_DODGE;
			bFaceRight=!bFaceRight;
//		}
	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void moveBackAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_BATTLE_STAND;
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		action = MANUELROLE_MOVE_BACK;
//	}else{
////		if (role->bRoleMonster) {
////			action = MANUELROLE_MOVE_BACK;
////		} else {
//			action = MONSTER_MOVE_TO_TARGET;
////		}
//	}
	//	switch (f.m_info.fighterType) {
	//		case FIGHTER_TYPE_PET:
	//			action = MANUELROLE_MOVE_BACK;
	//			break;
	//		case FIGHTER_TYPE_EUDEMON:
	//		case FIGHTER_TYPE_ELITE_MONSTER:
	//		case FIGHTER_TYPE_MONSTER:
	//		case Fighter_TYPE_RARE_MONSTER:
	////			if (f.m_info.bRoleMonster) {
	////				action = MANUELROLE_MOVE_BACK;
	////			} else {
	//				action = MONSTER_MOVE_TO_TARGET;
	////			}
	//			break;
	//		default:
	//			break;
	//	}
	role->SetCurrentAnimation(action, role->m_bFaceRight);
}

void hurtAction(Fighter& f) {
	if(f.m_bDefenceAtk){//Èç¹ûÒÑ¾­ÉèÎª¸ñµ²¶¯×÷£¬ÔòºöÂÔÕâ´Î¶¯×÷ÉèÖÃ
		return;
	}
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_HURT;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		action = MANUELROLE_HURT;
//	}else{
////		if(role->bRoleMonster){
////			action = MANUELROLE_HURT;
////		}else {
//			action = MONSTER_HURT;
//			bFaceRight = !bFaceRight;
////		}
//	}
	//	switch (f.m_info.fighterType) {
	//		case FIGHTER_TYPE_PET:
	//			action = MANUELROLE_HURT;
	//			break;
	//		case FIGHTER_TYPE_EUDEMON:
	//		case FIGHTER_TYPE_ELITE_MONSTER:
	//		case FIGHTER_TYPE_MONSTER:
	//		case Fighter_TYPE_RARE_MONSTER:
	////			if (f.m_info.bRoleMonster) {
	////				action = MANUELROLE_HURT;
	////			} else {
	//				action = MONSTER_HURT;
	//				bFaceRight = !bFaceRight;
	////			}
	//			break;
	//		default:
	//			break;
	//	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void dieAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_HURT;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		action = MANUELROLE_DIE;
//	}else{
////		if(role->bRoleMonster){
////			action = MANUELROLE_DIE;
////		}else {
//			action = MONSTER_DIE;
//			bFaceRight = !bFaceRight;
////		}
//	}
	role->SetCurrentAnimation(action, bFaceRight);

}

void battleStandAction(Fighter& f) {
	f.showSkillName(false);

	NDBaseRole *role = f.GetRole();
	int action = MANUELROLE_BATTLE_STAND;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
//	if(f.m_lookfaceType==LOOKFACE_MANUAL){
//		action = MANUELROLE_BATTLE_STAND;
//	}else{
////		if(role->bRoleMonster){
////			action = MANUELROLE_BATTLE_STAND;
////		}else {
//			action = MONSTER_STAND;
//			bFaceRight = !bFaceRight;
////		}
//		
//		
//	}
	//	switch (f.m_info.fighterType) {
	//		case FIGHTER_TYPE_PET:
	//			action = MANUELROLE_BATTLE_STAND;
	//			break;
	//		case FIGHTER_TYPE_EUDEMON:
	//		case FIGHTER_TYPE_ELITE_MONSTER:
	//		case Fighter_TYPE_RARE_MONSTER:
	//		case FIGHTER_TYPE_MONSTER:
	////			if (f.m_info.bRoleMonster) {
	////				action = MANUELROLE_BATTLE_STAND;
	////			} else {
	//				action = MONSTER_STAND;
	//				bFaceRight = !bFaceRight;
	////			}
	//			break;
	//		default:
	//			break;
	//	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void useItemAction(Fighter& f) {
	
	NDBaseRole *role = f.GetRole();
	int action = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	switch (f.m_kInfo.fighterType) {
		case FIGHTER_TYPE_PET:
			action = MANUELROLE_ITEM_USE;
			break;
		case FIGHTER_TYPE_EUDEMON:
		case FIGHTER_TYPE_ELITE_MONSTER:
		case FIGHTER_TYPE_MONSTER:
		case Fighter_TYPE_RARE_MONSTER:
			//			if (f.m_info.bRoleMonster) {
			//				action = MANUELROLE_ITEM_USE;
			//			} else {
			action = MANUELROLE_ITEM_USE;
			bFaceRight = !bFaceRight;
			//			}
			break;
		default:
			break;
	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void catchPetAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	
	if (f.m_kInfo.fighterType == FIGHTER_TYPE_PET) {
		role->SetCurrentAnimation(MANUELROLE_CATCH_PET, role->m_bFaceRight);
	}
}

void fleeFailAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	switch (f.m_kInfo.fighterType) {
		case FIGHTER_TYPE_PET:
			action = MANUELROLE_FLEE_FAIL;
			break;
		case FIGHTER_TYPE_EUDEMON:
		case FIGHTER_TYPE_ELITE_MONSTER:
		case FIGHTER_TYPE_MONSTER:
		case Fighter_TYPE_RARE_MONSTER:
			//			if (f.m_info.bRoleMonster) {
			//				action = MANUELROLE_FLEE_FAIL;
			//			} else {
			action = MONSTER_FLEE_FAIL;
			bFaceRight = !bFaceRight;
			//			}
			break;
		default:
			break;
	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void fleeSuccessAction(Fighter& f) {
	NDBaseRole *role = f.GetRole();
	int action = 0;
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	switch (f.m_kInfo.fighterType) {
		case FIGHTER_TYPE_PET:
			action = MANUELROLE_FLEE_SUCCESS;
			break;
		case FIGHTER_TYPE_EUDEMON:
		case FIGHTER_TYPE_ELITE_MONSTER:
		case FIGHTER_TYPE_MONSTER:
		case Fighter_TYPE_RARE_MONSTER:
			//			if (f.m_info.bRoleMonster) {
			//				action = MANUELROLE_FLEE_SUCCESS;
			//			} else {
			action = MONSTER_FLEE_SUCCESS;
			bFaceRight = !bFaceRight;
			//			}
			
			break;
		default:
			break;
	}
	role->SetCurrentAnimation(action, bFaceRight);
}

void monsterResult(VEC_FIGHTER& monsterList)
{
	for (size_t i = 0; i < monsterList.size(); i++) {
		Fighter& obj = *monsterList.at(i);
		//if(obj.m_info.fighterType==FIGHTER_TYPE_MONSTER){
			int idMonType = obj.m_kInfo.idType;
			if (0 != idMonType) {
				// ´ò¹ÖÈÎÎñ½áËã
				updateTaskMonsterData(idMonType, true);
			}
		//}
	}
}

void petAction(Fighter& f, int act) {
	NDBaseRole *role = f.GetRole();
	
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	
	switch (f.m_kInfo.fighterType) {
		case FIGHTER_TYPE_EUDEMON:
		case FIGHTER_TYPE_ELITE_MONSTER:
		case FIGHTER_TYPE_MONSTER:
		case Fighter_TYPE_RARE_MONSTER:
			//			if (!f.m_info.bRoleMonster) {
			bFaceRight = !bFaceRight;
			//			}
			break;
		default:
			break;
	}
	role->SetCurrentAnimation(act, bFaceRight);
}

void roleAction(Fighter& f, int act) {
	NDBaseRole *role = f.GetRole();
	bool bFaceRight = f.m_kInfo.group == BATTLE_GROUP_DEFENCE ? false : true;
	if (role)
		role->SetCurrentAnimation(act, bFaceRight);
}
//
//  NDConstant.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-11.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//


#ifndef __NDConstant_H
#define __NDConstant_H

#define REPLACEABLE_NONE					0//不可替换部位
#define REPLACEABLE_CAP						1//头盔
#define REPLACEABLE_ARMOR					2//胸甲
#define REPLACEABLE_SHIELD					3//盾牌
#define REPLACEABLE_FAQI					4//法器
#define REPLACEABLE_FACE					5//脸型
#define REPLACEABLE_HAIR					6//发型
#define REPLACEABLE_EXPRESSION				7//表情
#define REPLACEABLE_ONE_HAND_WEAPON_1		8//单手剑
#define REPLACEABLE_ONE_HAND_WEAPON_2		9//单手刀
#define REPLACEABLE_TWO_HAND_WEAPON			10//双手剑
#define REPLACEABLE_TWO_HAND_KNIFE			11//双手刀
#define REPLACEABLE_DUAL_SWORD				12//双持剑
#define REPLACEABLE_DUAL_KNIFE				13//双持刀
#define REPLACEABLE_TWO_HAND_WAND			14//双手杖
#define REPLACEABLE_TWO_HAND_BOW			15//双手弓
#define REPLACEABLE_ONE_HAND_DAGGER			16//匕首
#define REPLACEABLE_LEFT_SHOULDER			17//左肩
#define REPLACEABLE_RIGHT_SHOULDER			18//左肩
#define REPLACEABLE_SKIRT_STAND				19//
#define REPLACEABLE_SKIRT_WALK				20//
#define REPLACEABLE_SKIRT_SIT				21//
#define REPLACEABLE_SKIRT_LIFT_LEG			22//抬腿
#define REPLACEABLE_TWO_HAND_SPEAR			23//双手矛

// 玩家的外形
#define MANUELROLE_HUMAN_MALE					(NDPath::GetAniPath("fist_man.spr").c_str())
#define MANUELROLE_HUMAN_FEMALE					(NDPath::GetAniPath("fist_man.spr").c_str())

#define MANUELROLE_FIST_MALE					GetAniPath("tang_man.spr")
#define MANUELROLE_FIST_FEMALE					GetAniPath("tang_woman.spr")
#define MANUELROLE_SWORD_MALE					GetAniPath("tang_man.spr")
#define MANUELROLE_SWORD_FEMALE					GetAniPath("tang_woman.spr")
#define MANUELROLE_CHIVALROUS_MALE				GetAniPath("tang_man.spr")
#define MANUELROLE_CHIVALROUS_FEMALE			GetAniPath("tang_woman.spr")

// 切屏点动画
// 切屏点动画
#define TRANSPORT							99
#define UPLEV_EFFECT						900
#define TASKDONE_EFFECT						901
#define ROLE_SEAT_EFFECT					902
#define DRITICAL_EFFECT						903
#define SKILL_ATKED_EFFECT					904
#define PHY_ATKED_EFFECT					905
#define ATKBACK_EFFECT						906
#define ACTIVITY_OPEN_EFFECT				907
#define MANAFULL_EFFECT						908

// 玩家的动作。原型是面朝左边的
#define MANUELROLE_STAND					0
#define MANUELROLE_WALK						1
#define MANUELROLE_BATTLE_STAND				2
#define MANUELROLE_DEFENCE					3
#define MANUELROLE_DODGE					4
#define MANUELROLE_HURT						5
#define MANUELROLE_ATTACK					6
#define MANUELROLE_RELAX					7
#define MANUELROLE_SEAT						8
#define MANUELROLE_SKILL					9
#define MANUELROLE_RIDE_STAND				10
#define MANUELROLE_RIDE_WALK				11
//以下人物动作与怪物动作将不再使用

#define MANUELROLE_RIDE_PET_STAND			6
#define MANUELROLE_RIDE_PET_MOVE			3
#define MANUELROLE_STAND_PET_STAND			4
#define MANUELROLE_STAND_PET_MOVE			11

#define MANUELROLE_WEAK						7
#define MANUELROLE_MOVE_TO_TARGET			8
#define MANUELROLE_MOVE_BACK				9

#define MANUELROLE_DIE						12
#define MANUELROLE_FLEE_SUCCESS				13
#define MANUELROLE_FLEE_FAIL				14

#define MANUELROLE_ATTACK_FREEHAND			15
#define MANUELROLE_DEFENCE_FREEHAND			16

#define MANUELROLE_SKILL_WARRIOR_DISTANCE	17
#define MANUELROLE_SKILL_WIZZARD_DISTANCE	18
#define MANUELROLE_SKILL_HUNTER_DISTANCE	19

#define MANUELROLE_ATTACK_ONE_HAND_WEAPON	20
#define MANUELROLE_DEFENCE_ONE_HAND_WEAPON	21

#define MANUELROLE_ATTACK_DUAL_WEAPON		22
#define MANUELROLE_DEFENCE_DUAL_WEAPON		23

#define MANUELROLE_ATTACK_TWO_HAND_WEAPON	24
#define MANUELROLE_DEFENCE_TWO_HAND_WEAPON	25

#define MANUELROLE_ATTACK_TWO_HAND_WAND		26
#define MANUELROLE_DEFENCE_TWO_HAND_WAND	27

#define MANUELROLE_ATTACK_TWO_HAND_BOW		28
#define MANUELROLE_DEFENCE_TWO_HAND_BOW		29

#define MANUELROLE_SKILL_WARRIOR_SWORD_SINGLE	30
#define MANUELROLE_SKILL_WARRIOR_KNIFE_SINGLE	31
#define MANUELROLE_SKILL_WARRIOR_SWORD_AREA		32
#define MANUELROLE_SKILL_WARRIOR_KNIFE_AREA		33
#define MANUELROLE_SKILL_WARRIOR_LION_SOAR		34
#define MANUELROLE_SKILL_WIZZARD				35
#define MANUELROLE_SKILL_ASSASIN_BOW_SINGLE		36
#define MANUELROLE_SKILL_ASSASIN_BOW_AREA		37
#define MANUELROLE_SKILL_ASSASIN_SWORD_SINGLE	38
#define MANUELROLE_ITEM_USE						39
#define MANUELROLE_SKILL_ASSASIN_PONIARD_SINGLE	40
#define MANUELROLE_SITE							42
#define MANUELROLE_CATCH_PET					43 // 捕捉动作动画序号
#define MANUELROLE_FLY_PET_STAND				44
#define MANUELROLE_FLY_PET_WALK					45
#define MANUELROLE_RIDE_BIRD_STAND				46
#define MANUELROLE_RIDE_BIRD_WALK				47
#define MANUELROLE_QIANG_NORMAL_ATTACK			48
#define MANUELROLE_QIANG_SKILL_ATTACK			49
#define MANUELROLE_RIDE_QL						50


#define SYSTEM_BG_MUSIC_KEY						"SYSTEM_BG_MUSIC"
#define SYSTEM_EF_SOUND_KEY						"SYSTEM_EF_SOUND"
#define SYSTEM_SHOW_OTHER_KEY					"SYSTEM_SHOW_OTHER"
#define SYSTEM_SHOW_NAME_KEY					"SYSTEM_SHOW_NAME"
// monster的动作，原型是面朝右边的。
#define MONSTER_MAP_STAND						0
#define MONSTER_MAP_MOVE						1
#define MONSTER_STAND							2
#define MONSTER_DEFENCE							3
#define MONSTER_DODGE							4
#define MONSTER_HURT							5
#define MONSTER_DIE								6
#define MONSTER_ATTACK							7
#define MONSTER_SKILL_ATTACK					8
#define MONSTER_FLEE_SUCCESS					9
#define MONSTER_FLEE_FAIL						10
#define MONSTER_MOVE_TO_TARGET					11
// private static final byte MONSTER_MOVE_BACK = 12;

//旗子的动画
#define FLAG_ESCORT_1							0//镖局
#define FLAG_TEAM_1								1
#define FLAG_SUI_DYNASTY_1						2//隋军旗
#define FLAG_TAN_DYNASTY_1						3
#define FLAG_TUJUE_DYNASTY_1					4//突厥
#define FLAG_ESCORT_2							5//镖局
#define FLAG_TEAM_2								6
#define FLAG_SUI_DYNASTY_2						7//隋军旗
#define FLAG_TAN_DYNASTY_2						8
#define FLAG_TUJUE_DYNASTY_2					9//突厥


// 骑宠的动作
#define RIDEPET_STAND							0
#define RIDEPET_MOVE							1

// 动作对象的类型
#define TYPE_MANUALROLE							1
#define TYPE_ENEMYROLE							2
#define TYPE_EUDEMON							3
#define TYPE_RIDEPET							4

// 朝向
#define FACE_LEFT								0
#define FACE_RIGHT								1

// layer z
#define MAPLAYER_Z								0
#define MAP_MASKLAYER_Z							0
#define MAP_UILAYER_Z							1
#define DIRECT_KEY_TOP_Z						2
#define UILAYER_Z								3
#define TRADE_LAYER_Z							4
//聊天提示信息z轴
#define CHAT_Z									90
#define CHAT_RECORD_MANAGER_Z					91
#define CHAT_INPUT_Z							92
//对话框 TOP
#define UIDIALOG_Z								99
#define UISYNLAYER_Z							100
//快捷栏蒙板z轴
#define SPEEDBAR_MASK_Z							101

// layer tag
#define MAPLAYER_TAG							1

#define BATTLEMAPLAYER_TAG							3001

#define UILAYER_TAG								2
// 以下是游戏场景中的UItag
//人物属性
#define UILAYER_ATTRIB_TAG						3	
//宠物属性
#define UILAYER_PET_ATTRIB_TAG					4
//任务列表
#define UILAYER_TASK_LIST_TAG						5
//玩家列表
#define UILAYER_PLAYER_LIST_TAG					6
//请求列表
#define UILAYER_REQUEST_LIST_TAG					7
//排行榜
#define	UILAYER_PAIHANG_TAG					8			
//好友列表
#define UILAYER_GOOD_FRIEND_LIST_TAG				9
//商店
#define UILAYER_NPCSHOP_TAG					10
//战斗技能
#define UILAYER_BATTLE_SKILL_TAG			11
//角色显示时相对于Cell的偏移
#define DISPLAY_POS_X_OFFSET					(MAP_UNITSIZE / 2)
#define DISPLAY_POS_Y_OFFSET					(MAP_UNITSIZE)
//地图单元格尺寸
#define MAP_UNITSIZE		32
//神魔主场景tag
#define SMGAMESCENE_TAG							3000
//神魔战斗场景tag
#define SMBATTLESCENE_TAG							3002
//神魔登陆场景tag
#define SMLOGINSCENE_TAG                        3003

// 阵营
#define CAMP_NAME_WU		NDCommonCString("wu")
#define CAMP_NAME_TANG		NDCommonCString("CampTang")
#define CAMP_NAME_SUI		NDCommonCString("CampSui")
#define CAMP_NAME_TU		NDCommonCString("CampTuJue")

#endif
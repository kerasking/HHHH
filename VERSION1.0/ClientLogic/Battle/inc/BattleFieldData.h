/*
 *  BattleFieldData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-3.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BATTLE_FIELD_DATA_H_
#define _BATTLE_FIELD_DATA_H_

#include "Singleton.h"
#include <map>
#include <vector>
#include <string>
#include <string>

enum BATTLE_GOODS_TYPE
{
	BATTLE_GOODS_TYPE_NONE = 0,
	BATTLE_GOODS_TYPE_XINLUO,		// 兴洛争夺战
	BATTLE_GOODS_TYPE_LUOYANG,		// 洛阳攻防战
};

typedef struct _tagBFItemInfo
{
	int goodType;					// 战场类型
	int itemType;
	int medalItemType;
	int medalReq;
	int honourReq;
	
	_tagBFItemInfo() {
		memset(this, 0, sizeof(*this));
	}
	
	_tagBFItemInfo(int goodType, 
				   int itemType, 
				   int medalItemType, 
				   int medalReq,
				   int honourReq) {
		this->goodType		= goodType;
		this->itemType		= itemType;
		this->medalItemType = medalItemType;
		this->medalReq		= medalReq;
		this->honourReq		= honourReq;
	}
	
}BFItemInfo;

typedef struct _tagBFPlayerInfo
{
	std::string name;
	int			lvl;
	std::string rank;
	_tagBFPlayerInfo(std::string name, int lvl, std::string rank)
	{
		this->name = name;
		this->lvl = lvl;
		this->rank = rank;
	}
	_tagBFPlayerInfo()
	{
		this->lvl = 0;
	}
}BFPlayerInfo;

typedef std::vector<BFItemInfo>			vec_bf_item;
typedef vec_bf_item::iterator			vec_bf_item_it;

// key  goodType;
typedef std::map<int, vec_bf_item>		map_bf_iteminfo;
typedef map_bf_iteminfo::iterator		map_bf_iteminfo_it;
typedef std::pair<int, vec_bf_item>		pair_bf_iteminfo;

// key  goodType/bfType;
typedef std::map<int, std::string>		map_bf_desc;
typedef map_bf_desc::iterator			map_bf_desc_it;
typedef std::pair<int, std::string>		pair_bf_desc;

// key  playername;
typedef std::map<std::string, BFPlayerInfo>			map_bf_apply;
typedef map_bf_apply::iterator						map_bf_apply_it;
typedef std::pair<std::string, BFPlayerInfo>		pair_bf_apply;

typedef struct _tagBFApplyInfo
{
	uint typeId;
	uint seqId;
	uint timeLeft;
	uint playerLimit;
	uint applyCount;
	std::string rule;
	map_bf_apply applyInfo;
	_tagBFApplyInfo(uint typeId,
							 uint seqId,
							 uint timeLeft,
							 uint playerLimit,
							 uint applyCount )
	{
		Init(typeId, seqId, timeLeft, playerLimit, applyCount);
	}
	
	void Init(uint typeId,
			 uint seqId,
			 uint timeLeft,
			 uint playerLimit,
			 uint applyCount )
	{
		this->typeId		= typeId;
		this->seqId			= seqId;
		this->timeLeft		= timeLeft;
		this->playerLimit	= playerLimit;
		this->applyCount	= applyCount;
	} 
	
	_tagBFApplyInfo()
	{
		Init(0, 0, 0, 0, 0);
	}
	
	void SetRule(std::string rule)
	{
		this->rule = rule;
	}
	
	bool IsRuleEmpty()
	{
		return rule.empty();
	}
	
	void reset()
	{
		Init(0, 0, 0, 0, 0);
		applyInfo.clear();
	}
}BFApplyInfo;


// ket bfType
typedef std::map<uint , BFApplyInfo>		map_bf_apply_info;
typedef map_bf_apply_info::iterator			map_bf_apply_info_it;
typedef std::pair<uint , BFApplyInfo>		map_bf_apply_info_pair;


class BattleField
{
public:
	static void quitGame();
	
public:
	static map_bf_iteminfo				mapItemInfo;
	static map_bf_desc					mapDesc;
	static map_bf_desc					mapApplyDesc;
	static map_bf_apply_info			mapApplyInfo;
	static map_bf_desc					mapApplyBackStory;
};

#endif // _BATTLE_FIELD_DATA_H_
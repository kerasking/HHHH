/*
 *  GameUIBattleSkill.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_BATTLE_SKILL_H_
#define _GAME_UI_BATTLE_SKILL_H_

#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
#include "NDUILabel.h"

using namespace NDEngine;

class SocialElement;


class GameUIBattleSkill : 
public NDUIMenuLayer,
//public NDUITableLayerDelegate, ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
public NDUIButtonDelegate
{
	DECLARE_CLASS(GameUIBattleSkill)
public:
	GameUIBattleSkill();
	~GameUIBattleSkill();
	void Initialization(); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnButtonClick(NDUIButton* button); override
private:
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlOperate;
	
	std::vector<SocialElement*> m_vecSocial;
};

#endif // _GAME_UI_BATTLE_SKILL_H_
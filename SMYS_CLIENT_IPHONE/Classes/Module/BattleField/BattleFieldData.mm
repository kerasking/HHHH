/*
 *  BattleFieldData.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-3.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "BattleFieldData.h"

map_bf_iteminfo				BattleField::mapItemInfo;
map_bf_desc					BattleField::mapDesc;
map_bf_desc					BattleField::mapApplyDesc;
map_bf_apply_info			BattleField::mapApplyInfo;
map_bf_desc					BattleField::mapApplyBackStory;

void BattleField::quitGame()
{
	BattleField::mapItemInfo.clear();
	
	BattleField::mapDesc.clear();
	
	BattleField::mapApplyDesc.clear();
	
	BattleField::mapApplyInfo.clear();
	
	BattleField::mapApplyBackStory.clear();
}
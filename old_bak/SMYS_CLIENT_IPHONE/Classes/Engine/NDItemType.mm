/*
 *  NDItemType.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#include "NDItemType.h"
#include "Item.h"

using namespace NDEngine;

std::string NDItemType::PROFESSION[PROFESSION_LEN] = 
{
	NDCString("fashi"),
	NDCString("chike"),
	NDCommonCString("wu"),
	NDCString("zhangshi"),
};

std::string NDItemType::MONOPOLY[MONOPOLY_LEN] = 
{
	NDCString("nottrade"),
	NDCString("notstorge"), 
};

int NDItemType::getItemColor(int i)
{
	std::vector<int> ids = Item::getItemType(i);
	int result = -1;
	if (ids[0] > 1) {
		return result;
	}
	if (ids[7] == 5) {
		result = 0x9d9d9d;
	} else if (ids[7] == 6) {
		result = 0x1eff00;
	} else if (ids[7] == 7) {
		result = 0x0088ff;
	} else if (ids[7] == 8) {
		result = 0xbb00ff;
	} else if (ids[7] == 9) {
		result = 0xffff00;
	}
	return result;
}

std::string NDItemType::getItemStrColor(int i)
{
	std::string s="9d9d9d";
	switch(i){
		case 6:
			s="1eff00";
			break;
		case 7:
			s="0088ff";
			break;
		case 8:
			s="bb00ff";
			break;
		case 9:
			s="ffff00";
			break;
	}
	return s;
}
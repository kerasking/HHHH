/*
 *  SuitTypeObj.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SUIT_TYPE_OBJ_H_
#define _SUIT_TYPE_OBJ_H_

#include <string>
#include <map>

class SuitTypeObj 
{
public:
	SuitTypeObj() {}
		
	
public:
	static void LoadSuitTypeIndex();
	static SuitTypeObj* findSuitType(int suittypeID);
	static std::map<int, SuitTypeObj> SuitTypeObjs;
	static std::map<int, int> SuitTypeObjIndex;
public:
	int iID;
	std::string name;
	int equip_id_1;
	std::string equip_name_1;
	int equip_id_2;
	std::string equip_name_2;
	int equip_id_3;
	std::string equip_name_3;
	int equip_id_4;
	std::string equip_name_4;
	int equip_id_5;
	std::string equip_name_5;
	int equip_id_6;
	std::string equip_name_6;
	int equip_id_7;
	std::string equip_name_7;
	unsigned char equip_set_1_num;
	std::string equip_set_1_des;
	unsigned char equip_set_2_num;
	std::string equip_set_2_des;
	unsigned char equip_set_3_num;
	std::string equip_set_3_des;
	
	bool isUpData;
};

#endif // _SUIT_TYPE_OBJ_H_
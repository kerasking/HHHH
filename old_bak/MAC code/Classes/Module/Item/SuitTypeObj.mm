/*
 *  SuitTypeObj.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SuitTypeObj.h"
#include "NDPath.h"
#include "JavaMethod.h"
#include "NDUtility.h"

using namespace NDEngine;

const int MAXAMOUNT=120;

std::map<int, SuitTypeObj> SuitTypeObj::SuitTypeObjs;
std::map<int, int> SuitTypeObj::SuitTypeObjIndex;

SuitTypeObj* SuitTypeObj::findSuitType(int suittypeID)
{
	std::map<int, SuitTypeObj>::iterator it = SuitTypeObjs.find(suittypeID);
	if (it != SuitTypeObjs.end()) 
	{
		return &(it->second);
	}
	
	// 从ini文件中读
	std::map<int, int>::iterator itIndex = SuitTypeObjIndex.find(suittypeID);
	if (itIndex == SuitTypeObjIndex.end()) 
	{
		return NULL;
	}
	
	std::string res = "";
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *suittypeTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("suittype.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:suittypeTable];
	
	if (!stream) //|| ![stream hasBytesAvailable]) 
	{
		return NULL;
	}
	
	[stream open];
	
	SuitTypeObj suit;
	
	[stream setProperty:[NSNumber numberWithInt:itIndex->second] forKey:NSStreamFileCurrentOffsetKey];
	
	suit.iID = [stream readInt];
	suit.name = [[stream readUTF8String] UTF8String];		
	suit.equip_id_1=[stream readInt];
	suit.equip_name_1=[[stream readUTF8String] UTF8String];
	suit.equip_id_2=[stream readInt];
	suit.equip_name_2=[[stream readUTF8String] UTF8String];
	suit.equip_id_3=[stream readInt];
	suit.equip_name_3=[[stream readUTF8String] UTF8String];
	suit.equip_id_4=[stream readInt];
	suit.equip_name_4=[[stream readUTF8String] UTF8String];
	suit.equip_id_5=[stream readInt];
	suit.equip_name_5=[[stream readUTF8String] UTF8String];
	suit.equip_id_6=[stream readInt];
	suit.equip_name_6=[[stream readUTF8String] UTF8String];
	suit.equip_id_7=[stream readInt];
	suit.equip_name_7=[[stream readUTF8String] UTF8String];
	suit.equip_set_1_num=[stream readByte];
	suit.equip_set_1_des=[[stream readUTF8String] UTF8String];
	suit.equip_set_2_num=[stream readByte];
	suit.equip_set_2_des=[[stream readUTF8String] UTF8String];
	suit.equip_set_3_num=[stream readByte];
	suit.equip_set_3_des=[[stream readUTF8String] UTF8String];
	
	[stream close];
	
	if (int(SuitTypeObjs.size()) > MAXAMOUNT) 
	{
		bool bFind = false;
		std::map<int, SuitTypeObj>::iterator it = SuitTypeObjs.begin();
		for (; it != SuitTypeObjs.end(); it++) 
		{
			SuitTypeObj& obj = it->second;
			if (!obj.isUpData) 
			{
				SuitTypeObjs.erase(it);
				bFind = true;
				break;
			}
		}
		
		if (!bFind) 
		{
			SuitTypeObjs.erase(SuitTypeObjs.begin());
		}
	}
	
	std::pair< std::map<int, SuitTypeObj>::iterator, bool> respair;
	respair = SuitTypeObjs.insert(std::map<int, SuitTypeObj>::value_type(suittypeID, suit));
	if (!respair.second) 
	{
		return NULL;
	}
	
	return &(respair.first->second);
}

void SuitTypeObj::LoadSuitTypeIndex()
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *suittypeTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("suittypeTable.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:suittypeTable];
	
	if (stream)
	{
		[stream open];
		
		int size = [stream readInt];
		
		for (int i = 0; i < size; i++)
		{
			int idSuit = [stream readInt];
			int index = [stream readInt];
			SuitTypeObjIndex.insert(std::map<int, int>::value_type(idSuit, index));
		}
		
		[stream close];
	}
}
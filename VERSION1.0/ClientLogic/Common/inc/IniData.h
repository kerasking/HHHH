/*
 *  IniData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _INI_DATA_H_
#define _INI_DATA_H_

#include "JavaMethod.h"
#include "NDPath.h"
#include "define.h"

struct EnhanceObj 
{
	UInt32 ID; 
	UInt16 addPoint;
	UInt8 percent; 
	UInt32 reqItem; 
	UInt8 reqNum;
	
	UInt32 reqMoney; UInt8 success; UInt8 rehabilitation;
	
	EnhanceObj(){ memset(this, 0, sizeof(*this)); }
	
// 	EnhanceObj& operator <<(NSInputStream* stream)
// 	{
// 		if (!stream) return *this;
// 		
// 		this->ID = [stream readInt];
// 		
// 		this->addPoint = [stream readShort];
// 		
// 		this->percent = [stream readByte];
// 		
// 		this->reqItem = [stream readInt];
// 		
// 		this->reqNum = [stream readByte];
// 		
// 		this->reqMoney = [stream readInt];
// 		
// 		this->success = [stream readByte];
// 		
// 		this->rehabilitation = [stream readByte];
// 		
// 		return *this;
// 	}
};

#endif // _INI_DATA_H_
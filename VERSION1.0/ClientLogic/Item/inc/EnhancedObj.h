/*
 *  EnhancedObj.h
 *  DragonDrive
 *
 *  Created by wq on 11-9-5.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __ENHANCED_OBJ_H__
#define __ENHANCED_OBJ_H__

#include "BaseType.h"

struct EnhancedObj
{
	EnhancedObj();
	~EnhancedObj();
	
	int idType;
	unsigned short addpoint;
	unsigned char percent;
	int req_item;
	int req_num;
	int req_money;
};

#endif
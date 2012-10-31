/*
 *  ScriptNetMsg.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#pragma once

#include "NDMsgDefine.h"
#include "NDTransData.h"

class ScriptNetMsg
{
public:
	static void Load();
	static bool Process(MSGID msgID, NDEngine::NDTransData* data);
};
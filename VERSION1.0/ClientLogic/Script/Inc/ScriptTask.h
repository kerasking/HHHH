/*
 *  ScriptTask.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#pragma once

class ScriptObjectTask : public NDEngine::ScriptObject
{
public:
	virtual void OnLoad();
};
	
int ScriptGetTaskState(int nTaskId);

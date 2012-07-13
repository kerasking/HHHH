/*
 *  TaskInfoScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _TASK_INFO_SCENE_H_
#define _TASK_INFO_SCENE_H_

#include "NDCommonScene.h"

class DailyTask;

class TaskInfoScene :
public NDCommonScene
{
	DECLARE_CLASS(TaskInfoScene)
	
	TaskInfoScene();
	
	~TaskInfoScene();
	
public:
	
	static void refreshTask();
	
	static TaskInfoScene* Scene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
private:

	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
private:

	void InitTask(NDUIClientLayer* client);
	
	void InitDailyTask(NDUIClientLayer* client, int taskType);
	
	void refresh();

private:
	
	bool m_hasGetCanAcceptTask;
	
	std::vector<DailyTask*> m_vDailyTask;
	
private:
	static TaskInfoScene * s_instance;
};

#endif // _TASK_INFO_SCENE_H_
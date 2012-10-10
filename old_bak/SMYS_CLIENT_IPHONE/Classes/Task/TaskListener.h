/*
 *  TaskListener.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _TASK_LISTENER_H_
#define _TASK_LISTENER_H_

#include "NDMsgDefine.h"
#include "NDTransData.h"
#include "Task.h"
#include "Item.h"

void processTask(MSGID msgID, NDEngine::NDTransData* data);
void updateTaskItemData(Item& item, bool isShow);
void updateTaskMonsterData(int monId, bool isShow);
void dealWithFreshmanTask(Task* task);
void sendTaskFinishMsg(int taskId);

void updateTaskPrData(int nData, bool isShow);		// 爵位
void updateTaskRankData(int nData, bool isShow);	// 军衔
void updateTaskMoneyData(int nData, bool isShow);	// 银两
void updateTaskRepData(int nData, bool isShow);		// 声望
void updateTaskHrData(int nData, bool isShow);		// 荣誉

#endif // _TASK_LISTENER_H_
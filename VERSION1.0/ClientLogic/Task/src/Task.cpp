/*
 *  Task.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Task.h"
#include <sstream>
#include "NDLocalization.h"

std::string Task::START_STR = NDCommonCString("TaskNpc");
std::string Task::FINISH_STR = NDCommonCString("TaskDest");
bool Task::BEGIN_FRESHMAN_TASK = false;

Task::Task() 
{
	taskId = 0;
	taskTitle = NDCommonCString("empty");
	Init();
}

Task::Task(int id, std::string title)
{
	
	taskId = id;
	taskTitle = title;
	Init();
}

void Task::Init()
{
	startNpc_X = 0; startNpc_Y = 0; startNpcId = 0;
	
	finishNpc_X = 0; finishNpc_Y = 0; finishNpcId = 0;
	
	startMapId = 0; finishMapId = 0;
	
	isFinish = false;
	
	m_bIsGatherTask = false;
	
	m_bIsStartEqualFinish = false;
	
	lvMin = 0; lvMax = 0;
	
	prequestId = 0;
	
	type = 0; // 1为不可重复,9为每日任务
	
	award_exp = 0; award_money = 0; // 任务经验和银两奖励
	
	award_itemflag = 0; // 任奖励务物品类型 0表不奖励,1表不选择直接奖励,2表多选1
	
	award_item1 = 0; award_item2 = 0; award_item3 = 0; // 任务奖励物品
	
	award_num1 = 0; award_num2 = 0; award_num3 = 0; // 任务奖励物品个数
	
	/** 任务奖励的声望 */
	award_repute = 0;
	
	/** 任务奖励的荣誉值 */
	award_honour = 0;
	
}

void Task::setStartWhereNpc(std::string startNpcName) 
{
	this->startNpcName = startNpcName;
	this->startWhereNpc = START_STR + startNpcName;
}

void Task::setStartWhere(std::string startMapName, int startNpc_X, int startNpc_Y)
{
	this->startMapName = startMapName;
	this->startNpc_X = startNpc_X;
	this->startNpc_Y = startNpc_Y;
	std::stringstream ss; ss << startMapName << "(" << startNpc_X << "," << startNpc_Y << ")";
	this->startWhere = ss.str();
}

void Task::setFinishWhereNpc(std::string finishNpcName) 
{
	this->finishNpcName = finishNpcName;
	this->finishWhereNpc = FINISH_STR + finishNpcName;
}

void Task::setFinishWhere(std::string finishMapName, int finishNpc_X, int finishNpc_Y)
{
	this->finishMapName = finishMapName;
	this->finishNpc_X = finishNpc_X;
	this->finishNpc_Y = finishNpc_Y;
	std::stringstream ss; ss << finishMapName << "(" << finishNpc_X << "," << finishNpc_Y << ")";
	this->finishWhere = ss.str();
}

bool Task::isGatherTask()
{
	return m_bIsGatherTask;
}

void Task::setGatherTask(bool isGather)
{
	this->m_bIsGatherTask = isGather;
}

bool Task::isStartEqualFinish()
{
	return m_bIsStartEqualFinish;
}

void Task::setStartEqualFinish(bool isStartEqualFinish)
{
	this->m_bIsStartEqualFinish = isStartEqualFinish;
}

bool Task::checkIsFinished() 
{
	std::vector<TaskData*>::iterator it = taskDataArray.begin();
	for (; it != taskDataArray.end(); it++)
	{
		TaskData *data = *it;
		if (data)
		{
			if (data->getMSumCount() <= data->getMCurCount())
			{
				continue;
			}
			else
			{
				return false;
			}
			
		}		
	}
	
	return true;
}

std::string Task::getTaskTitle()
{
	return taskTitle;
}

bool Task::isDailyTask()
{
	return !(getTaskType() == TASK_STORY);
}

int  Task::getTaskType()
{
	int res = TASK_STORY;
	
	if ( taskId >= 6000000 && taskId <= 9999999  )
	{
		res = taskId / 1000000;
	}
	
	return res;
}

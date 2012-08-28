/*
 *  Task.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _TASK_H_
#define _TASK_H_
#include "TaskData.h"
#include <string>
#include <vector>

typedef std::vector<TaskData*> vec_taskdata;
typedef vec_taskdata::iterator vec_taskdata_it;

class Task 
{
public:
	static bool BEGIN_FRESHMAN_TASK;
	
	enum {
		startId = 8000,
		endId = 8050,
		TASK_TEAM = 8006,
		TASK_CHAT = 8015,
	};
	
	enum  
	{
		TASK_EXIST = 0,
		TASK_ADD = 1,
		TASK_DEL = 2,
		TASK_COMPLETE = 3,
		TASK_DONE = 4,
		TASK_STATE_COMPLETE = 5,
		REFRESH_REGULAR_TASK = 8,
	};
	
	enum
	{
		TASK_GROW			= 6,					// 成长
		TASK_SISHI			= 7,					// 史诗
		TASK_DAILY			= 8,					// 日常
		TASK_ACTIVITY		= 9,					// 活动
		
		TASK_STORY,									// 剧情
	};
	
	Task();
	
	Task(int id, std::string title);
	
	void setStartWhereNpc(std::string startNpcName);
	
	void setStartWhere(std::string startMapName, int startNpc_X, int startNpc_Y);
	
	void setFinishWhereNpc(std::string finishNpcName);
	
	void setFinishWhere(std::string finishMapName, int finishNpc_X, int finishNpc_Y);
	
	bool isGatherTask();
	
	void setGatherTask(bool isGather);
	
	bool isStartEqualFinish();
	
	void setStartEqualFinish(bool isStartEqualFinish);
	
	bool checkIsFinished();
	
	std::string getTaskTitle();
	
	bool isDailyTask();
	
	int  getTaskType();
		
private:
	void Init();
	
public:
	int taskId;
	
	std::string m_strTaskTitle;
	
	std::string startNpcName, startMapName;
	
	std::string finishNpcName, finishMapName;
	
	std::string startWhereNpc, startWhere, finishWhereNpc, finishWhere;
	
	int startNpc_X, startNpc_Y, startNpcId;
	
	int finishNpc_X, finishNpc_Y, finishNpcId;
	
	int startMapId, finishMapId;
	
	std::string originalTaskCorn;
	
	std::vector<TaskData*> taskDataArray;
	//TaskData *taskDataArray[6];
	
	bool isFinish;
	
	bool m_bIsGatherTask;
	
	bool m_bIsStartEqualFinish;
	
	int lvMin, lvMax;
	
	int prequestId;
	
	int type; // 1为不可重复,9为每日任务
	
	int award_exp, award_money; // 任务经验和银两奖励
	
	int award_itemflag; // 任奖励务物品类型 0表不奖励,1表不选择直接奖励,2表多选1
	
	int award_item1, award_item2, award_item3; // 任务奖励物品
	
	int award_num1, award_num2, award_num3; // 任务奖励物品个数
	
	/** 任务奖励的声望 */
	int award_repute;
	
	/** 任务奖励的荣誉值 */
	int award_honour;
	
	static std::string START_STR;
	static std::string FINISH_STR;
};


#endif // _TASK_H_
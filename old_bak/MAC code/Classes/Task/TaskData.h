/*
 *  TaskData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _TASK_DATA_H_
#define _TASK_DATA_H_

#include <string>

class TaskData // 表所需怪物或所需物品
{ 
public:
	enum
	{
		TASK_NONE = -1, //-1表未知
		
		TASK_MONSTER = 0, //0表怪物
		
		TASK_ITEM = 1, // 1表任务物品
		
		TASK_NPC = 2, // 1表任务NPC
		
		TASK_PR,	// 爵位
		TASK_RANK,	// 军衔
		TASK_GOLD,	// 银币
		TASK_REP,	// 声望
		TASK_HR,	// 荣誉
	};
public:
	TaskData();
	
    int getMId();
	
    void setMId(int id);
	
    int getMSumCount();
	
    void setMSumCount(int count);
	
    int getMCurCount();
	
    void setMCurCount(int curCount);
	
    int getMType();
	
    void setMType(int type);
	
    int getMapId();
	
    void setMapId(int mapId);
	
    int getMapX();
	
    void setMapX(int mapX);
	
    int getMapY();
	
    void setMapY(int mapY);
	
	std::string getMapName();
	
    void setMapName(std::string mapName);
	
	std::string getElementName();
	
    void setElementName(std::string elementName);
	
	std::string getTargetName();
	
	std::string getWhereName();
	
    int getShowType();
	
    void setMShowType(int showType);
	
	std::string getMAction();
	
    void setMAction(std::string action);
	
private:
	int mId; // 表itemType或者怪物id
	
    int mSumCount; // 表总数量
	
    int mCurCount; // 表当前数量
	
public:
	
	
private:
	int mType;
    
    int mShowType;  // 表示是否要显示在功能区,暂全部显示
	
    int mapId, mapX, mapY;
	
	std::string mapName, elementName;
    
	std::string mAction;
};

#endif // _TASK_DATA_H_
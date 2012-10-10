/*
 *  TaskData.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "TaskData.h"
#include <sstream>

TaskData::TaskData()
{
	mId = 0; // 表itemType或者怪物id
    mSumCount = 0; // 表总数量
    mCurCount = 0; // 表当前数量
	mType = TASK_NONE;
	mShowType = 1;  // 表示是否要显示在功能区,暂全部显示
	mapId = 0;
	mapX = 0;
	mapY = 0;
}

int TaskData::getMId() { return mId; }

void TaskData::setMId(int id) { mId = id; }

int TaskData::getMSumCount() { return mSumCount; }

void TaskData::setMSumCount(int count) { mSumCount = count; }

int TaskData::getMCurCount() { return mCurCount; }

void TaskData::setMCurCount(int curCount) {
	if(curCount<0){
		curCount = 0;
	}
	mCurCount = curCount;
}

int TaskData::getMType() {
	return mType;
}

void TaskData::setMType(int type) {
	this->mType = type;
}

int TaskData::getMapId() { return mapId; }

void TaskData::setMapId(int mapId) {
	this->mapId = mapId;
}

int TaskData::getMapX() { return mapX; }

void TaskData::setMapX(int mapX) {
	this->mapX = mapX;
}

int TaskData::getMapY() {
	return mapY;
}

void TaskData::setMapY(int mapY) {
	this->mapY = mapY;
}

std::string TaskData::getMapName() {
	return mapName;
}

void TaskData::setMapName(std::string mapName) {
	this->mapName = mapName;
}

std::string TaskData::getElementName() {
	return elementName;
}

void TaskData::setElementName(std::string elementName) {
	this->elementName = elementName;
}

std::string TaskData::getTargetName() {
	std::string res;// = "任务目标: ";
	res += elementName;
	return res;
}

std::string TaskData::getWhereName() {
	std::stringstream ss;
	ss << mapName << "(" << int(mapX) << "," << int(mapY) << ")";
	return ss.str();
	
}

int TaskData::getShowType() {
	return mShowType;
}

void TaskData::setMShowType(int showType) {
	this->mShowType = showType;
}

std::string TaskData::getMAction() {
	return mAction;
}

void TaskData::setMAction(std::string action) {
	mAction = action;
}
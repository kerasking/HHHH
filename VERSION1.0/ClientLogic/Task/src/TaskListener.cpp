/*
 *  TaskListener.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-1.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "TaskListener.h"
#include "NDTransData.h"
#include "define.h"
#include "ItemMgr.h"
#include "WorldMapScene.h"
#include "NDUISynLayer.h"
#include "NDPlayer.h"
#include "Task.h"
#include "GameUITaskList.h"
#include "GameScene.h"
#include "GlobalDialog.h"
#include <sstream>
#include <vector>
#include <string>
#include "NDDirector.h"
#include "Chat.h"
#include "NpcTaskList.h"
//#include "GameUIRequest.h"
///< #include "NDMapMgr.h" 临时性注释 郭浩
#include "ChatRecordManager.h"
#include "NDWorldMapData.h"
#include "NewPlayerTask.h"
#include "PlayerNpcListLayers.h"
#include "TaskInfoScene.h"
#include "NDPath.h"

#include "ScriptGlobalEvent.h"

#include <sstream>

using namespace NDEngine;

void showPrizeDialog(Task& task) {
	std::stringstream sbPrize;
	NDPlayer& player = NDPlayer::defaultHero();
	if (task.award_exp > 0) {
		sbPrize << NDCommonCString("exp") << " " << task.award_exp << NDCommonCString("dian") << "\n";
	}
	if (task.award_money > 0) {
		sbPrize << NDCommonCString("money") << " " << task.award_money << "\n";
	}
	if (task.award_repute > 0) {
		if (task.type == 0) { // 任务类型为0,奖励国家声望
			sbPrize << NDCommonCString("CountryRepute") << " " << task.award_repute << "\n";
		} else { // 奖励阵营声望
			if (player.GetCamp() != 0) { // 有阵营给提示
				sbPrize << NDCommonCString("CampRepute") << " " << task.award_repute << "\n";
			}
		}
	}
	if (task.award_honour > 0) {
		sbPrize << NDCommonCString("CampRepute") << "  " << task.award_honour << "\n";
	}
	
	if (task.award_itemflag == 1) { // 不选择直接奖励
		VEC_ITEM itemArray;
		if (task.award_item1 != 0) {
			Item *item = new Item(task.award_item1);
			item->iAmount = task.award_num1;
			itemArray.push_back(item);
		}
		if (task.award_item2 != 0) {
			Item *item = new Item(task.award_item2);
			item->iAmount = task.award_num2;
			itemArray.push_back(item);
		}
		if (task.award_item3 != 0) {
			Item *item = new Item(task.award_item3);
			item->iAmount = task.award_num3;
			itemArray.push_back(item);
		}
		
		for_vec(itemArray, VEC_ITEM_IT)
		{
			Item *tempItem = (*it);
			sbPrize << (tempItem->getItemName());
			sbPrize << " x" << tempItem->iAmount;
			sbPrize << "\n";
			delete tempItem;
		}
		
		itemArray.clear();
	}
	
	//String prize = sbPrize.toString();
//	if (prize.length() > 0) {
//		Dialog dialog = new Dialog("任务奖励", sbPrize.toString(), Dialog.PRIV_NORMAL);
//		T.addDialog(dialog);
//	}
	if (!sbPrize.str().empty())
	{
		GlobalDialogObj.Show(NULL, NDCommonCString("TaskAward"), sbPrize.str().c_str(), NULL, NULL);
		//showDialog("任务奖励", sbPrize.str().c_str());
	}
}

void completeTask(int taskId) {
	//		if (!T.dealOverMsgAndCheckTimeout()) {
	//			return;
	//		}
	NDPlayer& player = NDPlayer::defaultHero();
	
	vec_task& tasks = player.m_vPlayerTask;
	for_vec(tasks, vec_task_it)
	{
		Task* t = (*it);
		if (taskId == (*it)->taskId)
		{
			//deleteGatherPointByTask(temp);
			showPrizeDialog(*t);
			delete t;
			tasks.erase(it);
			break;
		}
	}
	
	//Task task = Task.getTaskDetailByTaskId(taskId); // 主要是读出奖励
	
	//		if (!canRepeat) {
	//			T.doneTaskId.addElement(new Integer(taskId));
	//		}
	
	//		Scene scene = GameScreen.getInstance().getScene();
	//		if (scene != null) { // 重新将该任务的结束npc设置为无状态
	//			Npc npc = scene.getNpcById(task.finishNpcId);
	//			if (npc != null) {
	//				npc.setNpcTaskState(Npc.QUEST_NONE);
	//			}
	//		}
	//		Npc.refreshNpcStateInMap(); // 完成时要重新刷新整个地图npc的状态
}

std::string setTaskInfo(std::string taskStr, Task& task, int index, std::vector<int> datas, int monCornIndex) {
	if (index > 100) {	// 防止无限递归
		return "";
	}
	//StringBuffer sBuffer = new StringBuffer(taskStr);
	
	std::string sBuffer = taskStr;
	int startIndex = sBuffer.find("[", 0);
	int endIndex = sBuffer.find("]", 0);
	
	if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
		std::string taskStart = sBuffer.substr(startIndex + 1, endIndex-startIndex-1);
		
		std::vector<std::string> task_array;
		
		int fromIndex = 0, toIndex = 0;
		while (int(std::string::npos) != (toIndex = taskStart.find(" ", fromIndex)))
		{
			task_array.push_back(taskStart.substr(fromIndex, toIndex-fromIndex));
			fromIndex = toIndex+1;
		}
		//补上最后一个
		task_array.push_back(taskStart.substr(fromIndex, sBuffer.size()-fromIndex));
		
		if (!task_array.empty()) {
			if (task_array[0] == "mon" && task_array.size() >= 6 ) { // 表示怪物信息
				
				// [mon ID name 格式 data 数量 mapid mapname X Y XXXX]
				
				//Array dataArray = task.taskDataArray;
				TaskData *taskElement = new TaskData();
				taskElement->setMId(atoi(task_array[1].c_str())); // 怪物id
				taskElement->setElementName(task_array[2]); // 怪物名字
				int nType = atoi(task_array[3].c_str());
				taskElement->setMShowType(nType); // 表示要不要显示在功能区
				taskElement->setMSumCount(atoi(task_array[5].c_str())); // 怪物总数量
				
				if (monCornIndex < int(datas.size())) { // monCornIndex记录的是按顺序接收的怪物data
					taskElement->setMCurCount(datas[monCornIndex]); // 怪物目前data
				}
				monCornIndex++;
				
				if (nType && task_array.size() >= 10) {
					taskElement->setMapId(atoi(task_array[6].c_str())); // mapId
					taskElement->setMapName(task_array[7]); // map 名字
					taskElement->setMapX(atoi(task_array[8].c_str())); // map
					// x
					taskElement->setMapY(atoi(task_array[9].c_str())); // map
					// Y
					
				}
				if (10 < task_array.size()) {
					taskElement->setMAction(task_array[10]); // action
				} else {
					taskElement->setMAction(""); // action
				}
				
				taskElement->setMType(TaskData::TASK_MONSTER); // 表示类型
				
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			} else if (task_array[0] == "item" && task_array.size() >= 6) {
				
				// [item id name 格式 data 数量 mapid mapname X Y XXXX]
				
				// 格式1表示要传送
				//Array dataArray = task.taskDataArray;
				TaskData *taskElement = new TaskData();
				taskElement->setMId(atoi(task_array[1].c_str())); // itemType
				taskElement->setElementName(task_array[2]); // 物品名字
				int nType = atoi(task_array[3].c_str());
				taskElement->setMShowType(nType); // 显示格式					
				// ,
				// 表示要不要显示在功能去
				taskElement->setMSumCount(atoi(task_array[5].c_str())); // 物品总数量
				// ,
				// 要先赋值最大值
				int tempIndex = atoi(task_array[4].c_str()) - 1;
				if (tempIndex >= 0 && tempIndex < int(datas.size())) {
					taskElement->setMCurCount(datas[tempIndex]); // 物品目前data
				}
				if (nType && task_array.size() >= 10) {
					taskElement->setMapId(atoi(task_array[6].c_str())); // mapId
					taskElement->setMapName(task_array[7]); // map 名字
					taskElement->setMapX(atoi(task_array[8].c_str())); // mapx
					taskElement->setMapY(atoi(task_array[9].c_str())); // mapY
				}
				
				if (10 < task_array.size()) {// 有可能没有Action描述
					taskElement->setMAction(task_array[10]); // action
				} else {
					taskElement->setMAction(""); // action
				}
				taskElement->setMType(TaskData::TASK_ITEM); // 表示类型
				
				//sBuffer.delete(startIndex, endIndex + 1);
				//sBuffer.insert(startIndex, taskElement.getElementName());
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
				
			} else if (task_array[0] == "npc" && task_array.size() >= 7) {
				// [npc npcid name mapid mapname x y XXXXX ]
				
				//Array dataArray = task.taskDataArray;
				TaskData *taskElement = new TaskData();
				taskElement->setMId(atoi(task_array[1].c_str())); // id
				taskElement->setElementName(task_array[2]); // 物品名字
				taskElement->setMShowType(1); // 显示格式
				taskElement->setMapId(atoi(task_array[3].c_str())); // mapId
				taskElement->setMapName(task_array[4]); // map 名字
				taskElement->setMapX(atoi(task_array[5].c_str())); // mapx
				
				if (task_array.size() > 6)
					taskElement->setMapY(atoi(task_array[6].c_str())); // mapY
				
				if (7 < task_array.size()) { // 有可能没有Action描述
					taskElement->setMAction(task_array[7]); // action
				} else {
					taskElement->setMAction(""); // action
				}
				taskElement->setMType(TaskData::TASK_NPC); // 表示类型
				
				//sBuffer.delete(startIndex, endIndex + 1);
				//sBuffer.insert(startIndex, taskElement.getElementName());
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
				
			}
			else if (task_array[0] == "pr" && task_array.size() >= 3) {
				TaskData *taskElement = new TaskData();
				taskElement->setMSumCount(atoi(task_array[1].c_str()));
				taskElement->setMCurCount(NDPlayer::defaultHero().m_nPeerage);
				taskElement->setElementName(task_array[2]);
				taskElement->setMShowType(0);
				taskElement->setMType(TaskData::TASK_PR);
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			}
			else if (task_array[0] == "rank" && task_array.size() >= 3) {
				TaskData *taskElement = new TaskData();
				taskElement->setMSumCount(atoi(task_array[1].c_str()));
				taskElement->setMCurCount(NDPlayer::defaultHero().m_nRank);
				taskElement->setElementName(task_array[2]);
				taskElement->setMShowType(0);
				taskElement->setMType(TaskData::TASK_RANK);
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			}
			else if (task_array[0] == "gold" && task_array.size() >= 2) {
				TaskData *taskElement = new TaskData();
				taskElement->setMSumCount(atoi(task_array[1].c_str()));
				taskElement->setMCurCount(NDPlayer::defaultHero().money);
				taskElement->setElementName(NDCommonCString("money"));
				taskElement->setMShowType(0);
				taskElement->setMType(TaskData::TASK_GOLD);
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			}
			else if (task_array[0] == "rep" && task_array.size() >= 2) {
				TaskData *taskElement = new TaskData();
				taskElement->setMSumCount(atoi(task_array[1].c_str()));
				taskElement->setMCurCount(NDPlayer::defaultHero().swCamp + NDPlayer::defaultHero().swGuojia);
				taskElement->setElementName(NDCommonCString("repute"));
				taskElement->setMShowType(0);
				taskElement->setMType(TaskData::TASK_REP);
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			}
			else if (task_array[0] == "hr" && task_array.size() >= 2) {
				TaskData *taskElement = new TaskData();
				taskElement->setMSumCount(atoi(task_array[1].c_str()));
				taskElement->setMCurCount(NDPlayer::defaultHero().honour);
				taskElement->setElementName(NDCommonCString("honur"));
				taskElement->setMShowType(0);
				taskElement->setMType(TaskData::TASK_HR);
				sBuffer.replace(startIndex, endIndex -startIndex+ 1, taskElement->getElementName());
				task.taskDataArray.push_back(taskElement);
			}else {
				NDLog("解析任务出错...");
			}
		}
		
		index++;
		return setTaskInfo(sBuffer, task, index, datas, monCornIndex);

	} else {
		return sBuffer;
	}
	return "";
}

int getTaskItemCount(int taskItemType) {
	int count = 0;
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item->iItemType == taskItemType) {
			if (item->isEquip()) {
				count++;
			} else {
				count += item->iAmount;
			}
		}
		
	}
	
	return count;
}

void showChatForTask(Task& task, TaskData& taskElement) {
	if (task.isFinish) {
		return;
	}
	std::stringstream sb;
	sb << (task.taskTitle);
	sb << " " << taskElement.getElementName();
	sb << "(" << taskElement.getMCurCount() << "/" << taskElement.getMSumCount() << ")";
	
	std::stringstream chat; chat << sb.str();
//	Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str()); ///< 临时性注释 郭浩
	//Chat::DefaultChat()->AddMessage(chat.str().c_str());
	//if (GameScreen.getInstance() != null) {
//		GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", sb.toString()));
//	}
}
//
//void updateTaskItemData(Item& item, bool isShow)
//{ // 得到或丢弃物品时调用
//	int curCount = getTaskItemCount(item.iItemType); //物品数量
//	vec_task& tasks = NDPlayer::defaultHero().m_vPlayerTask;
//	for_vec(tasks, vec_task_it)
//	{
//		Task *task = (*it);
//		if (task)
//		{
//			vec_taskdata& taskdatas = task->taskDataArray;
//			for_vec(taskdatas, vec_taskdata_it)
//			{
//				TaskData *taskElement = (*it);
//				if (taskElement->getMType() == TaskData::TASK_ITEM) {
//					if (taskElement->getMId() == item.iItemType) {
//						taskElement->setMCurCount(curCount);
//						if (isShow) {
//							showChatForTask(*task, *taskElement);
//							if (taskElement->getMSumCount() == taskElement->getMCurCount()) {
//								task->isFinish = task->checkIsFinished();
//								
//								// 整个任务完成提示
//								if (task->isFinish) {
//									std::stringstream sb;
//									sb << (task->taskTitle);
//									sb << "(" << NDCommonCString("finish") << ")";
//									NDLog("@", [NSString stringWithUTF8String:sb.str().c_str()]);
//									std::stringstream chat; chat << sb.str();
//									Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str());
//									//Chat::DefaultChat()->AddMessage(chat.str().c_str());
//									//if (GameScreen.getInstance() != null) { 
////										GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", sb.toString()));
////									}
//								}								
//							}
//						}
//						//return;
//					}
//				}
//			}
//			
//
//			if (task->isFinish && task->isDailyTask())
//			{
//				std::stringstream tip;
//				tip << task->taskTitle << NDCommonCString("finish") << NDCommonCString("le");
//				GameScene* scene = GameScene::GetCurGameScene();
//				if (scene) scene->ShowTaskFinish(true, tip.str());
//			}
//		}
//	}
//	
//	TaskInfoScene::refreshTask();
//}
//	

void dealBackData_MSG_TASKINFO(NDTransData *data)
{
	unsigned char btAction = 0; (*data) >> btAction;
	
	int taskId = 0; (*data) >> taskId;
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	switch (btAction) {
			//		case ServiceCode.TASK_ADD: { // 收到任务刷一次
			////			if (!T.dealOverMsgAndCheckTimeout()) {
			////				break;
			////			}
			//			Task task = addTaskByTaskId(taskId, new int[6]);
			//			if (task != null) {
			//				for (int i = 0; i < T.itemList.size(); i++) {
			//					Item tempItem = (Item) T.itemList.elementAt(i);
			//					updateTaskItemData(tempItem, false);// 更新任务物品
			//				}
			//				// 这里也要重新刷一遍,不能简单的设置起始跟结束npc状态,防止状态的重新覆盖
			//				//Npc.refreshNpcStateInMap();
			//				
			//			}else { //添加失败
			//				
			//				Dialog dialog = new Dialog();
			//				dialog.setContent("系统提示", "获取任务失败！");
			//				T.addDialog(dialog);				
			//			}
			//			break;
			//		}
		case Task::TASK_DEL: {
			vec_task& task = player.m_vPlayerTask;
			for_vec(task, vec_task_it)
			{
				Task* t = (*it);
				if (taskId == t->taskId)
				{
					//deleteGatherPointByTask(temp);
					delete t;
					task.erase(it);
					//if (TaskListScreen.instance != null) {
//						TaskListScreen.instance.refreshTaskList();
//					}
					//GameUIRefreshTask();
					NewPlayerTask::refreshTaskYiJie();
					break;
				}
			}
			
			//Npc.refreshNpcStateInMap();
			break;
		}
		case Task::TASK_COMPLETE: { // 任务完成
			completeTask(taskId);
			break;
		}
			//		case ServiceCode.TASK_DONE: { // 任务完成但是不可以继续做
			//			completeTask(taskId, false);
			//			break;
			//		}
		case Task::TASK_STATE_COMPLETE: { // 单纯设置任务状态,一定是完成状态
			vec_task& task = player.m_vPlayerTask;
			for_vec(task, vec_task_it)
			{
				Task* t = (*it);
				if (taskId == t->taskId)
				{
					t->isFinish = true;
					//Npc.setNpcTaskStateById(task.startNpcId, Npc.QUEST_NONE);
					//Npc.setNpcTaskStateById(task.finishNpcId, Npc.QUEST_FINISH);
					//return;
					if (t->isDailyTask())
					{
						std::stringstream tip;
						tip << t->taskTitle << NDCommonCString("finish") << NDCommonCString("le");
						GameScene* scene = GameScene::GetCurGameScene();
						if (scene) scene->ShowTaskFinish(true, tip.str());
					}
					break;
				}
			}
			
			break;
		}
		case 6: // 查看任务
			Task *task = NULL;
			vec_task& tasks = player.m_vPlayerTask;
			for_vec(tasks, vec_task_it)
			{
				if (taskId == (*it)->taskId)
				{
					task = (*it);
					break;
				}
			}
			
			if (task == NULL) {
				return;
			}
			
			// 任务配置信息
			unsigned char uctype = 0;
			int ucstartNpcId = 0, ucfinishNpcId = 0;
			(*data) >> uctype >> ucstartNpcId >> ucfinishNpcId;
			task->type = uctype;
			task->startNpcId = ucstartNpcId;
			task->finishNpcId = ucfinishNpcId;
			
			int finishMapId = 0;
			(*data) >> finishMapId;
			task->finishMapId = finishMapId;
			
			task->setFinishWhereNpc(data->ReadUnicodeString());
			/***
			* 临时性注释 郭浩
			* bein
			*/	
			//std::string strMapInfo;
			//PlaceNode *placeNode = [[NDWorldMapData SharedData] getPlaceNodeWithMapId:task->finishMapId];
			//if (placeNode) 
			//{
			//	strMapInfo = [placeNode.name UTF8String];
			//}
			//
			//if (task->finishMapId == 21005) 
			//{
			//	strMapInfo = NDCommonCString("MingYueCun");
			//}
			//
			//if (strMapInfo.empty()) 
			//{

// 				NSInputStream *stream  = 
// 					[NSInputStream inputStreamWithFileAtPath:
// 					 [NSString stringWithUTF8String:
// 					  NDPath::GetMapPath([[NSString stringWithFormat:@"map_%d.map", task->finishMapId] UTF8String])
// 					 ]];
// 				
// 				if (stream) 
// 				{
// 					[stream open];
// 					
// 					strMapInfo = [[stream readUTF8String] UTF8String];
// 					
// 					[stream close];
// 				}

			//}
			//
			//if (!strMapInfo.empty() )
			//{
			//	unsigned short finishNpc_X = 0, finishNpc_Y = 0;
			//	(*data) >> finishNpc_X >> finishNpc_Y;
			//	task->setFinishWhere(strMapInfo, finishNpc_X, finishNpc_Y);
			//}
			//
			//
			////task.startMapId = startNpc.mapId;
			////task.setStartWhereNpc(startNpc.name);
			////task.setStartWhere(startNpc.mapName, startNpc.getCol(), startNpc.getRow());
			//
			////			String   strMapName = strMapInfo[0];
			////			task.setFinishWhere(strMapName, in.readShort(), in.readShort());
			//
			////			if (TaskListScreen.instance != null) {
			////				TaskListScreen.instance.setTempTask(task);
			////			}
			//NewPlayerTask::ShowTaskYiJieDetail(task);
			////GameUIShowTaskDialog(task);
			//return;

			/***
			* 临时性注释 郭浩
			* end
			*/
	}
	
	//GameUIRefreshTask(); ///< 临时性注释 郭浩
	
	TaskInfoScene::refreshTask();
	
	CloseProgressBar;
}

void dealBackData_MSG_DOING_TASK_LIST(NDTransData *data)
{
	NDPlayer& player = NDPlayer::defaultHero();
	unsigned char btTaskCount = 0; (*data) >> btTaskCount;
	for (int i = 0; i < btTaskCount; i++) {
		
		Task *task = new Task();
		
		int taskId = 0;
		unsigned char isFinish = 0; 
		(*data) >> taskId >> isFinish;
		
		task->taskId = taskId; task->isFinish = isFinish == 2;
	
		std::vector<int> datas;
		for (int j = 0; j < 6; j++) {
			datas.push_back(data->ReadShort());
		}
		
		int award_exp = 0, award_money = 0, award_item1 = 0, award_item2 = 0, award_item3 = 0;
		unsigned char award_itemflag = 0, award_num1 = 0, award_num2 = 0, award_num3 = 0;
		unsigned short award_repute = 0, award_honour = 0;
		
		(*data) >> award_exp >> award_money >> award_itemflag >> award_item1 >> award_num1
		>> award_item2 >> award_num2 >> award_item3 >> award_num3 >> award_repute >> award_honour;
		
		task->award_exp = award_exp;
		task->award_money = award_money;
		task->award_itemflag = award_itemflag;
		task->award_item1 = award_item1;
		task->award_num1 = award_num1;
		task->award_item2 = award_item2;
		task->award_num2 = award_num2;
		task->award_item3 = award_item3;
		task->award_num3 = award_num3;
		task->award_repute = award_repute;
		task->award_honour = award_honour;
		
		task->taskTitle = data->ReadUnicodeString();
		task->originalTaskCorn = data->ReadUnicodeString();
		
		setTaskInfo(task->originalTaskCorn, *task, 0, datas, 0);
		player.m_vPlayerTask.push_back(task);
		
		if (task->isDailyTask() && task->isFinish)
		{
			std::stringstream tip;
			tip << task->taskTitle << NDCommonCString("finish") << NDCommonCString("le");
			GameScene* scene = GameScene::GetCurGameScene();
			if (scene) scene->ShowTaskFinish(true, tip.str());
		}
		
		//dealWithFreshmanTask(task);
		CloseProgressBar;
	}
		
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item) {
			//updateTaskItemData(*item, false);
		}
		
	}
	
	TaskInfoScene::refreshTask();
}

void dealWithFreshmanTask(Task* task) {
	if (task->taskId >= Task::startId
	    && task->taskId <= Task::endId) {
		Task::BEGIN_FRESHMAN_TASK = true;
	}
	if (!task->isFinish) {
		switch (task->taskId) {
			case Task::TASK_TEAM:
			{
				//RequsetInfo info;
				//info.set(-1, "NPC", RequsetInfo::ACTION_TEAM);
				//NDMapMgrObj.addRequst(info);
				//
				//NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
				//if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
				//	GameScene* gs = (GameScene*)scene;
				//	gs->OnClickNDUIAniLayer(gs->GetRequestAniLayer());
				//}
			}
				break;
			case Task::TASK_CHAT:
				ChatRecordManager::DefaultManager()->Show();
				break;
		}
	}
}

void sendTaskFinishMsg(int taskId) {
	NDTransData bao(_MSG_COMPLETE_TASK);
	bao << taskId;
	// SEND_DATA(bao);
}

void dealBackData_MSG_TASK_ITEM_OPT(NDTransData *data)
{
	int taskId = 0; (*data) >> taskId;
	Task *temp = NULL;
	vec_task& task = NDPlayer::defaultHero().m_vPlayerTask;
	for_vec(task, vec_task_it)
	{
		Task* t = (*it);
		if (taskId == t->taskId)
		{
			temp = t;
			break;
		}
	}
	
	if (temp == NULL) {
		CloseProgressBar;
		return;
	}
	
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		GameScene *gamescene = (GameScene*)scene;
		gamescene->ShowTaskAwardItemOpt(temp);
	}
}

void updateTaskMonsterData(int monId, bool isShow) { // 打怪完调用
	ScriptGlobalEvent::OnEvent(GE_KILL_MONSTER, monId);
	vec_task& tasks = NDPlayer::defaultHero().m_vPlayerTask;
	for_vec(tasks, vec_task_it)
	{
		Task *task = (*it);
		if (task)
		{
			vec_taskdata& taskdatas = task->taskDataArray;
			for_vec(taskdatas, vec_taskdata_it)
			{
				TaskData *taskElement = (*it);
				if (taskElement->getMType() == TaskData::TASK_MONSTER)
				{
					if (taskElement->getMId() == monId) 
					{
						int curCount = taskElement->getMCurCount();
						taskElement->setMCurCount(curCount + 1);
						// 同一个任务中不会打同一种怪故break,多个任务间可能打同种怪
						if (isShow) 
						{
							showChatForTask(*task, *taskElement);
							if (taskElement->getMSumCount() == taskElement->getMCurCount())
							{
								task->isFinish = task->checkIsFinished();
								
								// 整个任务完成提示
								if (task->isFinish)
								{
									stringstream sb;
									sb << task->taskTitle;
									sb << "(" << NDCommonCString("finish") << ")";
									std::stringstream chat; chat << sb.str();
//									Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str()); ///< 临时性注释 郭浩
									//Chat::DefaultChat()->AddMessage(chat.str().c_str());
									//if (GameScreen.getInstance() != null) { 
//										GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", sb.toString()));
//									}
								}								
							}
						}
						break;
					}
				}
			}
			
			if (task->isFinish && task->isDailyTask())
			{
				std::stringstream tip;
				tip << task->taskTitle << NDCommonCString("finish") << NDCommonCString("le");
				GameScene* scene = GameScene::GetCurGameScene();
				if (scene) scene->ShowTaskFinish(true, tip.str());
			}
		}
	}
	
	TaskInfoScene::refreshTask();
}

void processTask(MSGID msgID, NDTransData* data)
{
	CloseProgressBar;
	switch (msgID) {
		case _MSG_TASKINFO:
			dealBackData_MSG_TASKINFO(data);
			break;
		case _MSG_DOING_TASK_LIST:
			dealBackData_MSG_DOING_TASK_LIST(data);
			break;
		case _MSG_QUERY_TASK_LIST:
			//NpcTaskList::refreshScroll(*data);
			NpcListLayer::processTaskList(*data);
			break;
		case _MSG_TASK_ITEM_OPT:
			dealBackData_MSG_TASK_ITEM_OPT(data);
		case _MSG_QUERY_TASK_LIST_EX:
			//GameUITaskList::processQueryAcceptTask(*data);
			NewPlayerTask::processTaskAcceptalbe(*data);
			break;
	}
}

void updateTaskDataByType(int nType, int nData, bool isShow)
{
	if (!(TaskData::TASK_PR == nType 
		  || TaskData::TASK_RANK == nType 
		  || TaskData::TASK_GOLD == nType 
		  || TaskData::TASK_REP == nType 
		  || TaskData::TASK_HR == nType)) {
		return;
	}
	
	vec_task& tasks = NDPlayer::defaultHero().m_vPlayerTask;
	for_vec(tasks, vec_task_it)
	{
		Task *task = (*it);
		if (task)
		{
			vec_taskdata& taskdatas = task->taskDataArray;
			for_vec(taskdatas, vec_taskdata_it)
			{
				TaskData *taskElement = (*it);
				if (taskElement->getMType() == nType)
				{
					taskElement->setMCurCount(nData);
					if (isShow) 
					{
						showChatForTask(*task, *taskElement);
						if (taskElement->getMSumCount() == taskElement->getMCurCount())
						{
							task->isFinish = task->checkIsFinished();
							
							// 整个任务完成提示
							if (task->isFinish)
							{
								stringstream sb;
								sb << task->taskTitle;
								sb << "(" << NDCommonCString("finish") << ")";
								std::stringstream chat; chat << sb.str();
	//							Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str()); ///< 临时性注释 郭浩
							}								
						}
					}
					break;
				}
			}
			
			if (task->isFinish && task->isDailyTask())
			{
				std::stringstream tip;
				tip << task->taskTitle << NDCommonCString("finish") << NDCommonCString("le");
				GameScene* scene = GameScene::GetCurGameScene();
				if (scene) scene->ShowTaskFinish(true, tip.str());
			}
		}
	}
	
	TaskInfoScene::refreshTask();
}

void updateTaskPrData(int nData, bool isShow)
{
	updateTaskDataByType(TaskData::TASK_PR, nData, isShow);
}

void updateTaskRankData(int nData, bool isShow)
{
	updateTaskDataByType(TaskData::TASK_RANK, nData, isShow);
}

void updateTaskMoneyData(int nData, bool isShow)
{
	updateTaskDataByType(TaskData::TASK_GOLD, nData, isShow);
}

void updateTaskRepData(int nData, bool isShow)
{
	updateTaskDataByType(TaskData::TASK_REP, nData, isShow);
}

void updateTaskHrData(int nData, bool isShow)
{
	updateTaskDataByType(TaskData::TASK_HR, nData, isShow);
}
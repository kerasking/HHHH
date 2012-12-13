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
///< #include "NDMapMgr.h" 临时性注釄1�7 郭浩
#include "ChatRecordManager.h"
#include "NDWorldMapData.h"
#include "NewPlayerTask.h"
#include "PlayerNpcListLayers.h"
#include "TaskInfoScene.h"
#include "NDPath.h"

#include "ScriptGlobalEvent.h"

#include <sstream>

using namespace NDEngine;

void showPrizeDialog(Task& task)
{
	std::stringstream sbPrize;
	NDPlayer& player = NDPlayer::defaultHero();

	if (task.award_exp > 0)
	{
		sbPrize << NDCommonCString("exp") << " " << task.award_exp
				<< NDCommonCString("dian") << "\n";
	}
	if (task.award_money > 0)
	{
		sbPrize << NDCommonCString("money") << " " << task.award_money << "\n";
	}
	if (task.award_repute > 0)
	{
		if (task.type == 0)
		{ // 任务类型丄1�7奖励国家声望
			sbPrize << NDCommonCString("CountryRepute") << " "
					<< task.award_repute << "\n";
		}
		else
		{ // 奖励阵营声望
			if (player.GetCamp() != 0)
			{ // 有阵营给提示
				sbPrize << NDCommonCString("CampRepute") << " "
						<< task.award_repute << "\n";
			}
		}
	}
	if (task.award_honour > 0)
	{
		sbPrize << NDCommonCString("CampRepute") << "  " << task.award_honour
				<< "\n";
	}

	if (task.award_itemflag == 1)
	{ // 不1鄤7�择直接奖励
		VEC_ITEM itemArray;
		if (task.award_item1 != 0)
		{
			Item *item = new Item(task.award_item1);
			item->m_nAmount = task.award_num1;
			itemArray.push_back(item);
		}
		if (task.award_item2 != 0)
		{
			Item *item = new Item(task.award_item2);
			item->m_nAmount = task.award_num2;
			itemArray.push_back(item);
		}
		if (task.award_item3 != 0)
		{
			Item *item = new Item(task.award_item3);
			item->m_nAmount = task.award_num3;
			itemArray.push_back(item);
		}

		for_vec(itemArray, VEC_ITEM_IT)
		{
			Item *tempItem = (*it);
			sbPrize << (tempItem->getItemName());
			sbPrize << " x" << tempItem->m_nAmount;
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
		GlobalDialogObj.Show(NULL, NDCommonCString("TaskAward").c_str(),
				sbPrize.str().c_str(), NULL, NULL);
		//showDialog("任务奖励", sbPrize.str().c_str());
	}
}

void completeTask(int taskId)
{
	//		if (!T.dealOverMsgAndCheckTimeout()) {
	//			return;
	//		}
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	vec_task& kTasks = kPlayer.m_vPlayerTask;

	for_vec(kTasks, vec_task_it)
	{
		Task* pkTask = (*it);
		if (taskId == (*it)->m_nTaskID)
		{
			//deleteGatherPointByTask(temp);
			showPrizeDialog(*pkTask);
			SAFE_DELETE(pkTask);
			kTasks.erase(it);
			break;
		}
	}

	//Task task = Task.getTaskDetailByTaskId(taskId); // 主要是读出奖劄1�7

	//		if (!canRepeat) {
	//			T.doneTaskId.addElement(new Integer(taskId));
	//		}

	//		Scene scene = GameScreen.getInstance().getScene();
	//		if (scene != null) { // 重新将该任务的结束npc设置为无状1愤7�1�7
	//			Npc npc = scene.getNpcById(task.finishNpcId);
	//			if (npc != null) {
	//				npc.setNpcTaskState(Npc.QUEST_NONE);
	//			}
	//		}
	//		Npc.refreshNpcStateInMap(); // 完成时要重新刷新整个地图npc的状怄1�7
}

std::string setTaskInfo(std::string strTask, Task& kTask, int nIndex,
		std::vector<int> kDatas, int nMonCornIndex)
{
	if (nIndex > 100)
	{	// 防止无限递归
		return "";
	}
	//StringBuffer sBuffer = new StringBuffer(taskStr);

	std::string sBuffer = strTask;
	int startIndex = sBuffer.find("[", 0);
	int endIndex = sBuffer.find("]", 0);

	if (startIndex != -1 && endIndex != -1 && startIndex < endIndex)
	{
		std::string strTaskStart = sBuffer.substr(startIndex + 1,
				endIndex - startIndex - 1);

		std::vector < std::string > kTaskArray;

		int nFromIndex = 0;
		int nToIndex = 0;

		while (int(std::string::npos)
				!= (nToIndex = strTaskStart.find(" ", nFromIndex)))
		{
			kTaskArray.push_back(
					strTaskStart.substr(nFromIndex, nToIndex - nFromIndex));
			nFromIndex = nToIndex + 1;
		}

		//补上朄1�7后一丄1�7
		kTaskArray.push_back(
				strTaskStart.substr(nFromIndex, sBuffer.size() - nFromIndex));

		if (!kTaskArray.empty())
		{
			if (kTaskArray[0] == "mon" && kTaskArray.size() >= 6)
			{ // 表示怪物信息

				// [mon ID name 格式 data 数量 mapid mapname X Y XXXX]

				//Array dataArray = task.taskDataArray;
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMId(atoi(kTaskArray[1].c_str())); // 怪物id
				pkTaskElement->setElementName(kTaskArray[2]); // 怪物名字
				int nType = atoi(kTaskArray[3].c_str());
				pkTaskElement->setMShowType(nType); // 表示要不要显示在功能匄1�7
				pkTaskElement->setMSumCount(atoi(kTaskArray[5].c_str())); // 怪物总数釄1�7

				if (nMonCornIndex < int(kDatas.size()))
				{ // monCornIndex记录的是按顺序接收的怪物data
					pkTaskElement->setMCurCount(kDatas[nMonCornIndex]); // 怪物目前data
				}

				nMonCornIndex++;

				if (nType && kTaskArray.size() >= 10)
				{
					pkTaskElement->setMapId(atoi(kTaskArray[6].c_str())); // mapId
					pkTaskElement->setMapName(kTaskArray[7]); // map 名字
					pkTaskElement->setMapX(atoi(kTaskArray[8].c_str())); // map
					// x
					pkTaskElement->setMapY(atoi(kTaskArray[9].c_str())); // map
					// Y

				}

				if (10 < kTaskArray.size())
				{
					pkTaskElement->setMAction(kTaskArray[10]); // action
				}
				else
				{
					pkTaskElement->setMAction(""); // action
				}

				pkTaskElement->setMType(TaskData::TASK_MONSTER); // 表示类型

				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else if (kTaskArray[0] == "item" && kTaskArray.size() >= 6)
			{

				// [item id name 格式 data 数量 mapid mapname X Y XXXX]

				// 格式1表示要传逄1�7
				//Array dataArray = task.taskDataArray;
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMId(atoi(kTaskArray[1].c_str())); // itemType
				pkTaskElement->setElementName(kTaskArray[2]); // 物品名字
				int nType = atoi(kTaskArray[3].c_str());
				pkTaskElement->setMShowType(nType); // 显示格式					
				// ,
				// 表示要不要显示在功能厄1�7
				pkTaskElement->setMSumCount(atoi(kTaskArray[5].c_str())); // 物品总数釄1�7
				// ,
				// 要先赋1儤7�最大1儤7�1�7
				int nTempIndex = atoi(kTaskArray[4].c_str()) - 1;

				if (nTempIndex >= 0 && nTempIndex < int(kDatas.size()))
				{
					pkTaskElement->setMCurCount(kDatas[nTempIndex]); // 物品目前data
				}

				if (nType && kTaskArray.size() >= 10)
				{
					pkTaskElement->setMapId(atoi(kTaskArray[6].c_str())); // mapId
					pkTaskElement->setMapName(kTaskArray[7]); // map 名字
					pkTaskElement->setMapX(atoi(kTaskArray[8].c_str())); // mapx
					pkTaskElement->setMapY(atoi(kTaskArray[9].c_str())); // mapY
				}

				if (10 < kTaskArray.size())
				{ // 有可能没有Action描述
					pkTaskElement->setMAction(kTaskArray[10]); // action
				}
				else
				{
					pkTaskElement->setMAction(""); // action
				}

				pkTaskElement->setMType(TaskData::TASK_ITEM); // 表示类型

				//sBuffer.delete(startIndex, endIndex + 1);
				//sBuffer.insert(startIndex, pkTaskElement.getElementName());
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);

			}
			else if (kTaskArray[0] == "npc" && kTaskArray.size() >= 7)
			{
				// [npc npcid name mapid mapname x y XXXXX ]

				//Array dataArray = task.taskDataArray;
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMId(atoi(kTaskArray[1].c_str())); // id
				pkTaskElement->setElementName(kTaskArray[2]); // 物品名字
				pkTaskElement->setMShowType(1); // 显示格式
				pkTaskElement->setMapId(atoi(kTaskArray[3].c_str())); // mapId
				pkTaskElement->setMapName(kTaskArray[4]); // map 名字
				pkTaskElement->setMapX(atoi(kTaskArray[5].c_str())); // mapx

				if (kTaskArray.size() > 6)
				{
					pkTaskElement->setMapY(atoi(kTaskArray[6].c_str())); // mapY
				}

				if (7 < kTaskArray.size())
				{ // 有可能没有Action描述
					pkTaskElement->setMAction(kTaskArray[7]); // action
				}
				else
				{
					pkTaskElement->setMAction(""); // action
				}

				pkTaskElement->setMType(TaskData::TASK_NPC); // 表示类型

				//sBuffer.delete(startIndex, endIndex + 1);
				//sBuffer.insert(startIndex, pkTaskElement.getElementName());
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);

			}
			else if (kTaskArray[0] == "pr" && kTaskArray.size() >= 3)
			{
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMSumCount(atoi(kTaskArray[1].c_str()));
				pkTaskElement->setMCurCount(NDPlayer::defaultHero().m_nPeerage);
				pkTaskElement->setElementName(kTaskArray[2]);
				pkTaskElement->setMShowType(0);
				pkTaskElement->setMType(TaskData::TASK_PR);
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else if (kTaskArray[0] == "rank" && kTaskArray.size() >= 3)
			{
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMSumCount(atoi(kTaskArray[1].c_str()));
				pkTaskElement->setMCurCount(NDPlayer::defaultHero().m_nRank);
				pkTaskElement->setElementName(kTaskArray[2]);
				pkTaskElement->setMShowType(0);
				pkTaskElement->setMType(TaskData::TASK_RANK);
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else if (kTaskArray[0] == "gold" && kTaskArray.size() >= 2)
			{
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMSumCount(atoi(kTaskArray[1].c_str()));
				pkTaskElement->setMCurCount(NDPlayer::defaultHero().m_nMoney);
				pkTaskElement->setElementName(NDCommonCString("money"));
				pkTaskElement->setMShowType(0);
				pkTaskElement->setMType(TaskData::TASK_GOLD);
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else if (kTaskArray[0] == "rep" && kTaskArray.size() >= 2)
			{
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMSumCount(atoi(kTaskArray[1].c_str()));
				pkTaskElement->setMCurCount(
						NDPlayer::defaultHero().m_nSWCamp
								+ NDPlayer::defaultHero().m_nSWCountry);
				pkTaskElement->setElementName(NDCommonCString("repute"));
				pkTaskElement->setMShowType(0);
				pkTaskElement->setMType(TaskData::TASK_REP);
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else if (kTaskArray[0] == "hr" && kTaskArray.size() >= 2)
			{
				TaskData* pkTaskElement = new TaskData();
				pkTaskElement->setMSumCount(atoi(kTaskArray[1].c_str()));
				pkTaskElement->setMCurCount(NDPlayer::defaultHero().m_nHonour);
				pkTaskElement->setElementName(NDCommonCString("honur"));
				pkTaskElement->setMShowType(0);
				pkTaskElement->setMType(TaskData::TASK_HR);
				sBuffer.replace(startIndex, endIndex - startIndex + 1,
						pkTaskElement->getElementName());
				kTask.taskDataArray.push_back(pkTaskElement);
			}
			else
			{
				NDLog("解析任务出错...");
			}
		}

		nIndex++;
		return setTaskInfo(sBuffer, kTask, nIndex, kDatas, nMonCornIndex);

	}
	else
	{
		return sBuffer;
	}
	return "";
}

int getTaskItemCount(int taskItemType)
{
	int nCount = 0;
	VEC_ITEM& kItemVector = ItemMgrObj.GetPlayerBagItems();

	for_vec(kItemVector, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item->m_nItemType == taskItemType)
		{
			if (item->isEquip())
			{
				nCount++;
			}
			else
			{
				nCount += item->m_nAmount;
			}
		}

	}

	return nCount;
}

void showChatForTask(Task& task, TaskData& pkTaskElement)
{
	if (task.isFinish)
	{
		return;
	}

// 	std::stringstream kStringStream;
// 	kStringStream << (task.m_strTaskTitle);
// 	kStringStream << " " << pkTaskElement.getElementName();
// 	kStringStream << "(" << pkTaskElement.getMCurCount() << "/"
// 			<< pkTaskElement.getMSumCount() << ")";
// 
// 	std::stringstream chat;
// 	chat << kStringStream.str();
// 	Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str());
	//Chat::DefaultChat()->AddMessage(chat.str().c_str());
	//if (GameScreen.getInstance() != null) {
//		GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", sb.toString()));
//	}
}

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
//				TaskData* pkTaskElement = (*it);
//				if (pkTaskElement->getMType() == TaskData::TASK_ITEM) {
//					if (pkTaskElement->getMId() == item.iItemType) {
//						pkTaskElement->setMCurCount(curCount);
//						if (isShow) {
//							showChatForTask(*task,* pkTaskElement);
//							if (pkTaskElement->getMSumCount() == pkTaskElement->getMCurCount()) {
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

void dealBackData_MSG_TASKINFO(NDTransData* pkData)
{
	unsigned char ucAction = 0;
	(*pkData) >> ucAction;

	int nTaskID = 0;
	(*pkData) >> nTaskID;

	NDPlayer& kPlayer = NDPlayer::defaultHero();

	switch (ucAction)
	{
	//		case ServiceCode.TASK_ADD: { // 收到任务刷一欄1�7
	////			if (!T.dealOverMsgAndCheckTimeout()) {
	////				break;
	////			}
	//			Task task = addTaskByTaskId(taskId, new int[6]);
	//			if (task != null) {
	//				for (int i = 0; i < T.itemList.size(); i++) {
	//					Item tempItem = (Item) T.itemList.elementAt(i);
	//					updateTaskItemData(tempItem, false);// 更新任务物品
	//				}
	//				// 这里也要重新刷一遄1�7,不能箄1�7单的设置起始跟结束npc状1愤7�1�7,防止状1愤7�的重新覆盖
	//				//Npc.refreshNpcStateInMap();
	//
	//			}else { //添加失败
	//
	//				Dialog dialog = new Dialog();
	//				dialog.setContent("系统提示", "获取任务失败＄1�7");
	//				T.addDialog(dialog);
	//			}
	//			break;
	//		}
	case Task::TASK_DEL:
	{
		vec_task& kTask = kPlayer.m_vPlayerTask;
		for_vec(kTask, vec_task_it)
		{
			Task* pkTask = (*it);
			if (nTaskID == pkTask->m_nTaskID)
			{
				//deleteGatherPointByTask(temp);
				delete pkTask;
				kTask.erase(it);
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
	case Task::TASK_COMPLETE:
	{ // 任务完成
		completeTask(nTaskID);
		break;
	}
		//		case ServiceCode.TASK_DONE: { // 任务完成但是不可以继续做
		//			completeTask(taskId, false);
		//			break;
		//		}
	case Task::TASK_STATE_COMPLETE:
	{ // 单纯设置任务状1愤7�1�7,丄1�7定是完成状1愤7�1�7
		vec_task& task = kPlayer.m_vPlayerTask;
		for_vec(task, vec_task_it)
		{
			Task* pkTask = (*it);

			if (nTaskID == pkTask->m_nTaskID)
			{
				pkTask->isFinish = true;
				//Npc.setNpcTaskStateById(task.startNpcId, Npc.QUEST_NONE);
				//Npc.setNpcTaskStateById(task.finishNpcId, Npc.QUEST_FINISH);
				//return;
				if (pkTask->isDailyTask())
				{
					std::stringstream kTip;
					kTip << pkTask->m_strTaskTitle << NDCommonCString("finish")
							<< NDCommonCString("le");
					GameScene* pkScene = GameScene::GetCurGameScene();

					if (pkScene)
					{
						pkScene->ShowTaskFinish(true, kTip.str());
					}
				}

				break;
			}
		}

		break;
	}
	case 6: // 查看任务
		Task *pkTask = NULL;

		vec_task& kTasks = kPlayer.m_vPlayerTask;
		for_vec(kTasks, vec_task_it)
		{
			if (nTaskID == (*it)->m_nTaskID)
			{
				pkTask = (*it);
				break;
			}
		}

		if (pkTask == NULL)
		{
			return;
		}

		// 任务配置信息
		unsigned char uctype = 0;
		int ucstartNpcId = 0, ucfinishNpcId = 0;
		(*pkData) >> uctype >> ucstartNpcId >> ucfinishNpcId;
		pkTask->type = uctype;
		pkTask->startNpcId = ucstartNpcId;
		pkTask->finishNpcId = ucfinishNpcId;

		int finishMapId = 0;
		(*pkData) >> finishMapId;
		pkTask->finishMapId = finishMapId;

		pkTask->setFinishWhereNpc(pkData->ReadUnicodeString());
		/***
		 * 临时性注釄1�7 郭浩
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
		 * 临时性注釄1�7 郭浩
		 * end
		 */
	}

	//GameUIRefreshTask(); ///< 临时性注釄1�7 郭浩

	TaskInfoScene::refreshTask();

	CloseProgressBar;
}

void dealBackData_MSG_DOING_TASK_LIST(NDTransData *data)
{
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	unsigned char btTaskCount = 0;
	(*data) >> btTaskCount;

	for (int i = 0; i < btTaskCount; i++)
	{
		Task* pkTask = new Task();

		int nTaskID = 0;
		unsigned char cIsFinish = 0;
		(*data) >> nTaskID >> cIsFinish;

		pkTask->m_nTaskID = nTaskID;
		pkTask->isFinish = cIsFinish == 2;

		std::vector<int> datas;
		for (int j = 0; j < 6; j++)
		{
			datas.push_back(data->ReadShort());
		}

		int award_exp = 0, award_money = 0, award_item1 = 0, award_item2 = 0,
				award_item3 = 0;
		unsigned char award_itemflag = 0, award_num1 = 0, award_num2 = 0,
				award_num3 = 0;
		unsigned short award_repute = 0, award_honour = 0;

		(*data) >> award_exp >> award_money >> award_itemflag >> award_item1
				>> award_num1 >> award_item2 >> award_num2 >> award_item3
				>> award_num3 >> award_repute >> award_honour;

		pkTask->award_exp = award_exp;
		pkTask->award_money = award_money;
		pkTask->award_itemflag = award_itemflag;
		pkTask->award_item1 = award_item1;
		pkTask->award_num1 = award_num1;
		pkTask->award_item2 = award_item2;
		pkTask->award_num2 = award_num2;
		pkTask->award_item3 = award_item3;
		pkTask->award_num3 = award_num3;
		pkTask->award_repute = award_repute;
		pkTask->award_honour = award_honour;

		pkTask->m_strTaskTitle = data->ReadUnicodeString();
		pkTask->originalTaskCorn = data->ReadUnicodeString();

		setTaskInfo(pkTask->originalTaskCorn, *pkTask, 0, datas, 0);
		kPlayer.m_vPlayerTask.push_back(pkTask);

		if (pkTask->isDailyTask() && pkTask->isFinish)
		{
			std::stringstream tip;
			tip << pkTask->m_strTaskTitle << NDCommonCString("finish")
					<< NDCommonCString("le");
			GameScene* pkScene = GameScene::GetCurGameScene();

			if (pkScene)
			{
				pkScene->ShowTaskFinish(true, tip.str());
			}
		}

		//dealWithFreshmanTask(task);
		CloseProgressBar;
	}

	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();

	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item)
		{
			//updateTaskItemData(*item, false);
		}

	}

	TaskInfoScene::refreshTask();
}

void dealWithFreshmanTask(Task* task)
{
	if (task->m_nTaskID >= Task::startId && task->m_nTaskID <= Task::endId)
	{
		Task::BEGIN_FRESHMAN_TASK = true;
	}

	if (!task->isFinish)
	{
		switch (task->m_nTaskID)
		{
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

void sendTaskFinishMsg(int taskId)
{
	NDTransData bao(_MSG_COMPLETE_TASK);
	bao << taskId;
	// SEND_DATA(bao);
}

void dealBackData_MSG_TASK_ITEM_OPT(NDTransData *data)
{
	int taskId = 0;
	(*data) >> taskId;
	Task *temp = NULL;
	vec_task& task = NDPlayer::defaultHero().m_vPlayerTask;

	for_vec(task, vec_task_it)
	{
		Task* t = (*it);
		if (taskId == t->m_nTaskID)
		{
			temp = t;
			break;
		}
	}

	if (temp == NULL)
	{
		CloseProgressBar;
		return;
	}

	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();

	if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		GameScene *gamescene = (GameScene*) scene;
		gamescene->ShowTaskAwardItemOpt(temp);
	}
}

void updateTaskMonsterData(int nMonId, bool bIsShow)
{ // 打1愤7�完调用
	ScriptGlobalEvent::OnEvent(GE_KILL_MONSTER, nMonId);
	vec_task& tasks = NDPlayer::defaultHero().m_vPlayerTask;
	for_vec(tasks, vec_task_it)
	{
		Task* pkTask = (*it);
		if (pkTask)
		{
			vec_taskdata& taskdatas = pkTask->taskDataArray;
			for_vec(taskdatas, vec_taskdata_it)
			{
				TaskData* pkTaskElement = (*it);
				if (pkTaskElement->getMType() == TaskData::TASK_MONSTER)
				{
					if (pkTaskElement->getMId() == nMonId)
					{
						int curCount = pkTaskElement->getMCurCount();
						pkTaskElement->setMCurCount(curCount + 1);
						// 同一个任务中不会打同丄1�7种1愤7�故break,多个任务间可能打同种怄1�7
						if (bIsShow)
						{
							showChatForTask(*pkTask, *pkTaskElement);
							if (pkTaskElement->getMSumCount()
									== pkTaskElement->getMCurCount())
							{
								pkTask->isFinish = pkTask->checkIsFinished();

								// 整个任务完成提示
								if (pkTask->isFinish)
								{
// 									stringstream kStreamData;
// 									kStreamData << pkTask->m_strTaskTitle;
// 									kStreamData << "(" <<
// 										NDCommonCString("finish") << ")";
// 									std::stringstream chat;
// 									chat << kStreamData.str();
// 									Chat::DefaultChat()->AddMessage(ChatTypeSystem, chat.str().c_str());
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

			if (pkTask->isFinish && pkTask->isDailyTask())
			{
				std::stringstream tip;
				tip << pkTask->m_strTaskTitle << NDCommonCString("finish")
						<< NDCommonCString("le");
				GameScene* scene = GameScene::GetCurGameScene();
				if (scene)
					scene->ShowTaskFinish(true, tip.str());
			}
		}
	}

	TaskInfoScene::refreshTask();
}

void processTask(MSGID msgID, NDTransData* data)
{
	CloseProgressBar;
	switch (msgID)
	{
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
	if (!(TaskData::TASK_PR == nType || TaskData::TASK_RANK == nType
			|| TaskData::TASK_GOLD == nType || TaskData::TASK_REP == nType
			|| TaskData::TASK_HR == nType))
	{
		return;
	}

	vec_task& kTasks = NDPlayer::defaultHero().m_vPlayerTask;

	for_vec(kTasks, vec_task_it)
	{
		Task* pkTask = (*it);

		if (pkTask)
		{
			vec_taskdata& taskdatas = pkTask->taskDataArray;
			for_vec(taskdatas, vec_taskdata_it)
			{
				TaskData* pkTaskElement = (*it);
				if (pkTaskElement->getMType() == nType)
				{
					pkTaskElement->setMCurCount(nData);
					if (isShow)
					{
						showChatForTask(*pkTask, *pkTaskElement);
						if (pkTaskElement->getMSumCount()
								== pkTaskElement->getMCurCount())
						{
							pkTask->isFinish = pkTask->checkIsFinished();

							// 整个任务完成提示
							if (pkTask->isFinish)
							{
// 								stringstream kStringStream;
// 								kStringStream << pkTask->m_strTaskTitle;
// 								kStringStream << "(" << NDCommonCString("finish") << ")";
// 								std::stringstream kStingStreamChat;
// 								kStingStreamChat << kStringStream.str();
// 								Chat::DefaultChat()->AddMessage(ChatTypeSystem, kStingStreamChat.str().c_str());
							}
						}
					}
					break;
				}
			}

			if (pkTask->isFinish && pkTask->isDailyTask())
			{
				std::stringstream kTip;
				kTip << pkTask->m_strTaskTitle << NDCommonCString("finish")
						<< NDCommonCString("le");
				GameScene* pkScene = GameScene::GetCurGameScene();

				if (pkScene)
				{
					pkScene->ShowTaskFinish(true, kTip.str());
				}
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

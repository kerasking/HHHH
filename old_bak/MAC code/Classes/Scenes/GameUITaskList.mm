/*
 *  GameUITaskList.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUITaskList.h"
#include "NDDirector.h"
#include "Task.h"
#include "NDPlayer.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDMapMgr.h"
#include "define.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"
#include "ItemMgr.h"
#include "NDConstant.h"
#include "CGPointExtension.h"
#include "NDConstant.h"
#include "GameScene.h"
#include "NDString.h"
#include "AutoPathTip.h"
#include "NDNpc.h"
#include <sstream>


////////////////////////////////////////

IMPLEMENT_CLASS(NDUITBCellLayer, NDUILayer)

void NDUITBCellLayer::draw()
{
	NDUILayer::draw();
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer	*uiLayer = (NDUILayer*)parentNode;
		CGRect scrRect = this->GetScreenRect();	
		
		//draw focus 
		if (uiLayer->GetFocus() == this) 
		{
			DrawRecttangle(scrRect, ccc4(255, 206, 70, 255));					
		}
		
		//this->DrawRecttangle(scrRect, ccc4(185, 189, 171,255));
		if (m_bBorder) 
		{
			DrawLine(scrRect.origin, 
					 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(scrRect.origin, 
					 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y), 
					 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
			DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
					 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
					 ccc4(20, 59, 64,255),
					 1);
		}
	}
}
////////////////////////////////////////


#define title_height (35)
#define bottom_height (42)

GameUITaskList* GetThis();

void GameUIRefreshTask()
{
	GameUITaskList *tasklist = GetThis();
	if (tasklist) 
	{
		tasklist->refreshTLMain();
	}
}

void GameUIRefreshAcceptTask()
{
	GameUITaskList *tasklist = GetThis();
	if (tasklist) 
	{
		tasklist->refreshTLMain(true);
	}
}

void GameUIShowTaskDialog(Task* task)
{
	if (!task)
	{
		return;
	}
	
	GameUITaskList *tasklist = GetThis();
	if (tasklist) 
	{
		tasklist->showTaskDialog(*task);
	}
}

GameUITaskList* GetThis()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		return NULL;
	}
	
	if (!scene->GetChild(UILAYER_TASK_LIST_TAG)) 
	{
		return NULL;
	}
	
	GameUITaskList *tasklist = (GameUITaskList*)(scene->GetChild(UILAYER_TASK_LIST_TAG));
	if (tasklist && tasklist->IsVisibled())
	{
		return tasklist;
	}
	
	return NULL;
}

////////////////////////////////////////////////////

IMPLEMENT_CLASS(GameUITaskList, NDUIMenuLayer)

std::vector<Task*> GameUITaskList::s_AcceptTaskList;

GameUITaskList::GameUITaskList()
{
	m_tlMain = NULL;
	m_tlOpertate = NULL;
	m_lbTitle = NULL;
	m_curTask = NULL;
	
	resetDlgParam();
	
	memset(m_taskTab, 0, sizeof(m_taskTab));
}

GameUITaskList::~GameUITaskList()
{
	ClearAccpetTaskList();
}

void GameUITaskList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
//	m_lbTitle = new NDUILabel; 
//	m_lbTitle->Initialization(); 
//	m_lbTitle->SetText("任务列表"); 
//	m_lbTitle->SetFontSize(15); 
//	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter); 
//	m_lbTitle->SetFrameRect(CGRectMake(0, (title_height-15)/2, winsize.width, 15));
//	m_lbTitle->SetFontColor(ccc4(255, 240, 0,255));
//	this->AddChild(m_lbTitle);
	
	int tabstart = 15, tabx = tabstart, tabinteraval = 4;
	for (int i = 0; i < 2; i++) 
	{
		m_taskTab[i] = new StoreTabLayer;
		m_taskTab[i]->Initialization();
		
		m_taskTab[i]->SetFrameRect(CGRectMake(tabx, 5, (winsize.width-2*tabstart-tabinteraval)/2, title_height-5));
		m_taskTab[i]->SetDelegate(this);
		this->AddChild(m_taskTab[i]);
		tabx += (winsize.width-2*tabstart)/2+tabinteraval;
	}
	
	m_taskTab[0]->SetText("已接任务");
	m_taskTab[1]->SetText("可接任务");
	
	m_taskTab[0]->SetTabFocus(true);
	
	initMain(m_tlMain);
	
	initMain(m_tlMainAccept);
	
	m_tlOpertate = new NDUITableLayer;
	m_tlOpertate->Initialization();
	m_tlOpertate->VisibleSectionTitles(false);
	m_tlOpertate->SetDelegate(this);
	m_tlOpertate->SetVisible(false);
	this->AddChild(m_tlOpertate);
	
	refreshTLMain();
}

void GameUITaskList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain)
	{
		if (m_tlOpertate && m_tlOpertate->IsVisibled())
		{
			m_tlOpertate->SetVisible(false);
			return;
		}
		
		vec_task& task = NDPlayer::defaultHero().m_vPlayerTask;
		if (cellIndex < task.size())
		{
			m_curTask = task[cellIndex];
			std::vector<std::string> vec_str;
			std::vector<int> vec_id;
			vec_str.push_back("查看任务"); vec_id.push_back(eTLQueryTask);
			vec_str.push_back("删除任务"); vec_id.push_back(eTLDelTask);
			InitTLContent(m_tlOpertate, vec_str, vec_id);
		}
	}
	
	if (table == m_tlOpertate)
	{
		if (m_curTask == NULL || !cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			return;
		}
		
		NDUIButton *lb = (NDUIButton*)cell;
		Task& task = *m_curTask;
		if (lb->GetTag() == eTLQueryTask)
		{
			if (!task.finishWhere.empty()) {
				showTaskDialog(task);
			} else {
				NDTransData bao(_MSG_TASKINFO);
				bao << (unsigned char)6 << int(task.taskId);
				SEND_DATA(bao);
				ShowProgressBar;
			}
		}
		else if (lb->GetTag() == eTLDelTask)
		{
			NDTransData bao(_MSG_TASKINFO);
			bao << (unsigned char)Task::TASK_DEL << int(task.taskId);
			SEND_DATA(bao);
			m_tlOpertate->SetVisible(false);
			resetDlgParam();
			ShowProgressBar;
		}
		else if (lb->GetTag() != kCCNodeTagInvalid )
		{
			int iItemID = lb->GetTag();
			Item *item = new Item(iItemID);
			std::string strname = item->getItemName();
			std::string strdes = item->makeItemDes(true, true);
			showDialog(strname.c_str(), strdes.c_str());
			delete item;
		}
	}
	
	if (table == m_tlMainAccept && cellIndex < s_AcceptTaskList.size()) 
	{
		m_curTask = s_AcceptTaskList[cellIndex];
		
		showAvailableTaskDialog(*m_curTask);
	}
}

void GameUITaskList::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain || table == m_tlMainAccept)
	{
		resetDlgParam();
		if (m_tlOpertate)
		{
			m_tlOpertate->SetVisible(false);
			m_curTask = NULL;
		}
	}
}

void GameUITaskList::OnDialogClose(NDUIDialog* dialog)
{
	if (!m_curDlgParam.empty())
	{
		
		m_curDlgParam.reset();
	}
	else 
	{
		if (!m_vecDlgParam.empty())
		{
			m_vecDlgParam.clear();
			if (!m_tlOpertate || !m_tlOpertate->IsVisibled() )
			{
				m_curTask = NULL;
			}
		}
	}
}

void GameUITaskList::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (!m_curDlgParam.empty() && m_curTask)
	{
		if (m_curDlgParam.getOP() == eTaskDialog_Trans_Des)
		{
			if (m_curTask->finishMapId == NDMapMgrObj.GetMapID())
			{
				
				NDPlayer::defaultHero().Walk( 
											 ccp(m_curTask->finishNpc_X*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, m_curTask->finishNpc_Y*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET),
											 SpriteSpeedStep4);
				AutoPathTipObj.work(m_curTask->finishWhere);
			}
			else
			{
				dialog->Close();
				if (m_dlgTask)
				{
					m_dlgTask->Close();
				}
				useTransfromItem(m_curTask->finishNpc_X, m_curTask->finishNpc_Y, m_curTask->finishMapId);
				return;
			}
		}
		else if (m_curDlgParam.getOP() == eTaskDialog_Trans_Target)
		{
			vec_taskdata& taskdatas = m_curTask->taskDataArray;
			
			if (m_curDlgParam.getPara() >= int(taskdatas.size()))
			{
				return;
			}
			
			TaskData *taskElement = taskdatas[m_curDlgParam.getPara()];
			
			if (taskElement->getMapId() == NDMapMgrObj.GetMapID())
			{
				NDPlayer::defaultHero().Walk( 
											 ccp(taskElement->getMapX()*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, taskElement->getMapY()*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET),
											 SpriteSpeedStep4);
				
				AutoPathTipObj.work(taskElement->getElementName());
			}
			else
			{
				if (m_dlgTask)
				{
					m_dlgTask->Close();
				}
				dialog->Close();
				useTransfromItem(taskElement->getMapX(), taskElement->getMapY(), taskElement->getMapId());
				return;
			}
		}
		else if (m_curDlgParam.getOP() == eTaskDialog_AccpetPlace)
		{
			if (m_curTask->startMapId == NDMapMgrObj.GetMapID())
			{
				
				NDPlayer::defaultHero().Walk( 
											 ccp(m_curTask->startNpc_X*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, m_curTask->startNpc_Y*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET),
											 SpriteSpeedStep4);
				AutoPathTipObj.work(m_curTask->startNpcName);
			}
		}

		
		dialog->Close();
		
		if (m_dlgTask)
		{
			m_dlgTask->Close();
		}
		
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
			this->RemoveFromParent(true);
		}
		
		return;
	}
	
	
	if (buttonIndex >= m_vecDlgParam.size() || !m_curTask)
	{
		return;
	}
	
	st_dlg_para para = m_vecDlgParam[buttonIndex];
	
	if (para.empty())
	{
		return;
	}
	
	if (para.getOP() == eTaskDialog_DesPlace)
	{
		std::string title;
		std::stringstream ss; ss << m_curTask->finishWhereNpc << " " << m_curTask->finishWhere;
		if (m_curTask->finishMapId == NDMapMgrObj.GetMapID()) 
		{
			title = "导航";
			ss << "\n导航说明:该NPC在本地图范围内，点击确认直接导航到该地点";
		}
		else 
		{
			title = "传送";
			ss << "\n传送说明:点击确认直接传送到该地点,此操作将消耗一个传送卷轴";
		}
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show(title.c_str(), ss.str().c_str(), "取消", "确认", NULL);
		m_curDlgParam = st_dlg_para(eTaskDialog_Trans_Des);;
	}
	else if (para.getOP() == eTaskDialog_QueryItem)
	{
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		
		if (m_curTask->award_item1 > 0) {
			Item *item1 = new Item(m_curTask->award_item1);
			vec_str.push_back(item1->getItemName()); vec_id.push_back(m_curTask->award_item1);
			delete item1;
		}
		if (m_curTask->award_item2 > 0) {
			Item *item2 = new Item(m_curTask->award_item2); vec_id.push_back(m_curTask->award_item2);
			vec_str.push_back(item2->getItemName());
			delete item2;
		}
		if (m_curTask->award_item3 > 0) {
			Item *item3 = new Item(m_curTask->award_item3); vec_id.push_back(m_curTask->award_item3);
			vec_str.push_back(item3->getItemName());
			delete item3;
		}
		
		InitTLContent(m_tlOpertate, vec_str, vec_id);
		dialog->Close();
		resetDlgParam();
	}
	else if (para.getOP() == eTaskDialog_Target)
	{
		vec_taskdata& taskdatas = m_curTask->taskDataArray;
		if (para.getPara() >= int(taskdatas.size()))
		{
			return;
		}
		
		TaskData *taskElement = taskdatas[para.getPara()];
		std::string title;
		std::stringstream ss; ss << taskElement->getTargetName() << " " << taskElement->getWhereName();
		if (taskElement->getMapId() == NDMapMgrObj.GetMapID()) 
		{
			title = "导航";
			ss << "\n导航说明:该NPC在本地图范围内，点击确认直接导航到该地点";
		}
		else 
		{
			title = "传送";
			ss << "\n传送说明:点击确认直接传送到该地点,此操作将消耗一个传送卷轴";
		}
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show(title.c_str(), ss.str().c_str(), "取消", "确认", NULL);
		m_curDlgParam = st_dlg_para(eTaskDialog_Trans_Target, para.getPara());
	}
	if (para.getOP() == eTaskDialog_AccpetPlace)
	{
		std::stringstream ss; ss << m_curTask->startWhereNpc << "\n" << m_curTask->startWhere;
		ss << "\n导航说明:该NPC在本地图范围内，点击确认直接导航到该地点";
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show("导航", ss.str().c_str(), "取消", "确认", NULL);
		m_curDlgParam = st_dlg_para(eTaskDialog_AccpetPlace);
	}
}

void GameUITaskList::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (m_tlOpertate && m_tlOpertate->IsVisibled())
		{
			if (!m_tlOpertate->GetDataSource() || !m_tlOpertate->GetDataSource()->Section(0))
			{
				return;
			}
			
			NDSection *section = m_tlOpertate->GetDataSource()->Section(0);
			if (!section)
			{
				return;
			}
			
			if (section->Count() <= 0 || !section->Cell(0) || !section->Cell(0)->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				return;
			}
			
			NDUIButton *lb = (NDUIButton*)(section->Cell(0));
			if (lb->GetTitle() == "查看任务")
			{
				if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
				{
					((GameScene*)(this->GetParent()))->SetUIShow(false);
					this->RemoveFromParent(true);
				}
			}
			else
			{
				m_tlOpertate->SetVisible(false);
				m_curTask = NULL;
			}
		}
		else 
		{
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				this->RemoveFromParent(true);
			}
		}

	}
}

void GameUITaskList::OnFocusTablayer(StoreTabLayer* tablayer)
{
	if (s_AcceptTaskList.empty()) 
	{
		SendQueryAcceptTask();
	}
	else 
	{
		m_tlMain->SetVisible(tablayer == m_taskTab[0]);
		
		m_tlMainAccept->SetVisible(tablayer == m_taskTab[1]);
	}
	
	m_taskTab[0]->SetTabFocus(tablayer == m_taskTab[0]);
	
	m_taskTab[1]->SetTabFocus(tablayer == m_taskTab[1]);
}

void GameUITaskList::refreshTLMain(bool bAcceptList/*=false*/)
{
	NDUITableLayer *tablelayer = bAcceptList ? m_tlMainAccept : m_tlMain;
	
	if (!tablelayer || !tablelayer->GetDataSource())
	{
		return;
	}
	
	m_tlMain->SetVisible(!bAcceptList);
	
	m_tlMainAccept->SetVisible(bAcceptList);
	
	NDSection *section = tablelayer->GetDataSource()->Section(0);
	if (!section)
	{
		return;
	}
	
	if (section->Count() != task_desplay_num)
	{
		return;
	}
	
	
	
	vec_task& task = bAcceptList ? s_AcceptTaskList : NDPlayer::defaultHero().m_vPlayerTask;
	int iTaskNum = task.size();
	
	for (int i = 0; i < task_desplay_num; i++)
	{
		std::stringstream ss;
		ss << "   " << (i+1) << ": ";
		if (i < iTaskNum && task[i])
		{
			ss << task[i]->taskTitle;
			if (task[i]->isFinish)
			{
				ss << "(完成)";
			}
		}
		else
		{
			ss << "空";
		}
		NDUINode* node = section->Cell(i);
		if (node->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
		{
			if (node->GetChildren().size() == 1)
			{
				NDNode *nodechild = node->GetChildren()[0];
				if ( nodechild && nodechild->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
				{
					NDUILabel *lb = (NDUILabel*)nodechild;
					lb->SetText(ss.str().c_str());
				}
			}
		}
	}
	
	section->SetFocusOnCell(0);
}

void GameUITaskList::resetDlgParam()
{
	m_curDlgParam.reset();
	m_vecDlgParam.clear();
}

void GameUITaskList::InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text,tag) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetTag(tag); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);
	
	if (!tl || vec_str.empty() || vec_str.size() != vec_id.size())
	{
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::iterator it = vec_str.begin();
	for (int iIDIndex = 0; it != vec_str.end(); it++, iIDIndex++)
	{
		fastinit(((*it).c_str()), vec_id[iIDIndex])
	}
	
	section->SetFocusOnCell(0);
	
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit
}

void GameUITaskList::showTaskDialog(Task& task)
{
	std::string tempTaskContent = getTaskInfo(task.originalTaskCorn, task, 0);
	std::string finalTaskContent = getDestination(tempTaskContent, task);
	std::string strContent = NDMapMgrObj.changeNpcString(finalTaskContent);
	//taskDialog.setContent("任务详细信息", ChatRecordManager.parserChat(T
//														  .changeNpcString(finalTaskContent), -1));
	
	m_dlgTask = new NDUIDialog;
	m_dlgTask->Initialization();
	m_dlgTask->SetDelegate(this);
	
	std::vector<std::string> stroption;
	
	std::stringstream ss; ss << task.finishWhereNpc << "\n" << task.finishWhere;
	stroption.push_back(ss.str().c_str());
	m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_DesPlace));
	
	if (task.award_itemflag > 0) 
	{
		stroption.push_back("查看物品");
		m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_QueryItem));
	}
	
	vec_taskdata& taskdatas = task.taskDataArray;
	int iIndex = 0;
	for_vec(taskdatas, vec_taskdata_it)
	{
		TaskData *taskElement = *it;
		if (taskElement->getShowType() == 1)
		{
			std::stringstream ss; ss << taskElement->getTargetName() << taskElement->getWhereName();
			stroption.push_back(ss.str().c_str());
			m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_Target, iIndex));
		}
		iIndex++;
	}
	m_dlgTask->Show("任务详细信息", strContent.c_str(), "返回", stroption);
}

std::string GameUITaskList::getTaskInfo(std::string taskStr, Task& task, int index)
{
	std::string sBuffer = taskStr;
	int startIndex = sBuffer.find("[", 0);
	int endIndex = sBuffer.find("]", 0);
	
	std::vector<std::string> task_array;
	if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
		std::string taskCorn = sBuffer.substr(startIndex + 1, endIndex-startIndex-1);
		
		int fromIndex = 0, toIndex = 0;
		while (int(std::string::npos) != (toIndex = taskCorn.find(" ", fromIndex)))
		{
			task_array.push_back(taskCorn.substr(fromIndex, toIndex-fromIndex));
			fromIndex = toIndex+1;
		}
		//补上最后一个
		task_array.push_back(taskCorn.substr(fromIndex, sBuffer.size()-fromIndex));
		
		if (!task_array.empty()) {
			if (task_array[0] == "mon" || task_array[0] == "item" || task_array[0] == "npc") { // 表示怪物信息
				vec_taskdata& dataArray = task.taskDataArray;
				if (index < int(dataArray.size()) && dataArray[index])
				{
					std::stringstream ss; ss << "<cff0000" << dataArray[index]->getElementName() << "/e";
					sBuffer.replace(startIndex, endIndex-startIndex+1, ss.str().c_str());
									}
			}
		}

		index++;
		if (index < 6) {
			return getTaskInfo(sBuffer, task, index);
		} else {
			return sBuffer;
		}
		
	} else {
		return sBuffer;
	}
	return "";
}

std::string GameUITaskList::getDestination(std::string str, Task& task)
{
	std::stringstream sb;
	sb << str << "\n";
	vec_taskdata& dataArray = task.taskDataArray;
	if (dataArray.size() > 0) {
		sb << ("目标:");
	}
	for (size_t i = 0; i < dataArray.size(); i++) {
		TaskData& taskElement = (*(dataArray[i]));
		std::string action = taskElement.getMAction();
		std::string elementName = taskElement.getElementName();
		sb << action << " " << elementName << " ";
		if (taskElement.getMSumCount() > 0) {
			sb << "<cff0000" << taskElement.getMCurCount() << "/"
					  << taskElement.getMSumCount() << "/e";
		}
		sb << ("\n");
	}
	
	std::stringstream awardExp;
	std::stringstream awardMoney;
	std::stringstream awardRepute;
	std::stringstream awardHonor;
	bool bAward = false;
	
	if (task.award_exp > 0) {
		bAward = true;
		awardExp  << "经验<cff0000" << task.award_exp << "/e";
	}
	if (task.award_money > 0) {
		bAward = true;
		awardMoney  << "，银币<cff0000" << task.award_money << "/e";
	}
	if (task.award_repute > 0) {
		bAward = true;
		if (task.type == 0) { // 任务类型为0,奖励国家声望
			awardRepute << "，国家声望 <cff0000" << task.award_repute << "/e";
		} else { // 奖励阵营声望
			if (NDPlayer::defaultHero().GetCamp() != 0) { // 有阵营给提示
				awardRepute  << "，阵营声望 <cff0000" << task.award_repute << "/e";
			}
		}
	}
	if (task.award_honour > 0) {
		bAward = true;
		awardHonor  << "，荣誉值 <cff0000 " << task.award_honour << "/e";
	}
	if (bAward) {
		sb << ("任务奖励:\n");
		if (!awardExp.str().empty()) {
			sb << (awardExp.str());
		}
		if (!awardMoney.str().empty()) {
			sb << (awardMoney.str());
		}
		if (!awardRepute.str().empty()) {
			sb << (awardRepute.str());
		}
		if (!awardHonor.str().empty()) {
			sb << (awardHonor.str());
		}
		sb << ("。\n");
	}
	
	if (task.award_itemflag == 0) { // 不奖励物品
		return sb.str();
	} else if (task.award_itemflag == 1) {
		sb << "奖励以下所有物品: " << "\n ";
	} else {
		sb << "奖励以下物品的其中一件: " << "\n ";
	}
	sb << ("<cff0000");
	if (task.award_item1 > 0) {
		Item *item = new Item(task.award_item1);
		sb << item->getItemName() << " x" << task.award_num1 << "\n";
		delete item;
	}
	if (task.award_item2 > 0) {
		Item *item = new Item(task.award_item2);
		sb << item->getItemName() << " x" << task.award_num2 << "\n";
	}
	if (task.award_item3 > 0) {
		Item *item = new Item(task.award_item3);
		sb << item->getItemName() << " x" << task.award_num3 << "\n";
	}
	sb << ("/e");
	return sb.str();
}

void GameUITaskList::useTransfromItem(int mapX, int mapY, int mapId)
{
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		((GameScene*)(this->GetParent()))->SetUIShow(false);
		this->RemoveFromParent(true);
	}
	NDMapMgrObj.throughMap(mapX, mapY, mapId);
}

void GameUITaskList::initMain(NDUITableLayer*& tablelayer)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	tablelayer = new NDUITableLayer;
	tablelayer->Initialization();
	tablelayer->VisibleSectionTitles(false);
	tablelayer->VisibleScrollBar(true);
	tablelayer->SetFrameRect(CGRectMake(0, title_height-5, winsize.width, winsize.height-title_height-bottom_height));
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	
	for (int i = 0; i < task_desplay_num; i++)
	{
		NDUITBCellLayer *layer = new NDUITBCellLayer;
		layer->Initialization();
		layer->SetBackgroundColor(i%2 == 0 ? ccc4(227, 229, 218, 255) : ccc4(195, 210, 213, 255));
		layer->SetFrameRect(CGRectMake(0, (25-15)/2, winsize.width, 25));
		
		NDUILabel *lbTxt = new NDUILabel();
		lbTxt->Initialization();
		lbTxt->SetTextAlignment(LabelTextAlignmentLeft);
		lbTxt->SetText("");
		lbTxt->SetFrameRect(CGRectMake(0, (25-15)/2, winsize.width, 25));
		lbTxt->SetFontSize(15);
		lbTxt->SetFontColor(ccc4(20, 59, 64, 255));
		layer->AddChild(lbTxt);
		section->AddCell(layer);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	tablelayer->SetDataSource(dataSource);
	tablelayer->SetDelegate(this);
	this->AddChild(tablelayer);
}

void GameUITaskList::processQueryAcceptTask(NDTransData& data)
{
	int flag = data.ReadByte();
	
	int count = data.ReadInt();
	
	if (flag == 1 || flag == 3) 
	{
		ClearAccpetTaskList();
	}
	
	NDMapMgr& mapmgr = NDMapMgrObj;
	
	for (int i = 0; i < count; i++) 
	{
		int idTask = data.ReadInt();
		
		int idNpc = data.ReadInt();
		
		std::string taskName = data.ReadUnicodeString();
		
		int awardExp = data.ReadInt();
		
		int awardMoney = data.ReadInt();
		
		int itemflag = data.ReadByte();
		
		int item1 = data.ReadInt();
		
		int item1Num = data.ReadByte();
		
		int item2 = data.ReadInt();
		
		int item2Num = data.ReadByte();
	
		int item3 = data.ReadInt();
		
		int item3Num = data.ReadByte();
		
		int repute = data.ReadShort();
		
		int honour = data.ReadShort();
		
		NDNpc* npc = mapmgr.GetNpcByID(idNpc);
		
		if (!npc) continue;
		
		Task *task = new Task(idTask, taskName);
		
		task->award_itemflag = itemflag;
		
		task->award_exp = awardExp;
		
		task->award_money = awardMoney;
		
		task->award_honour = honour;
		
		task->award_repute = repute;
		
		task->award_item1 = item1;
		
		task->award_item2 = item2;
		
		task->award_item3 = item3;
		
		task->award_num1 = item1Num;
		
		task->award_num2 = item2Num;
		
		task->award_num3 = item3Num;
		
		task->startMapId = mapmgr.GetMapID();
		
		task->startNpc_X  = npc->col;
		
		task->startNpc_Y = npc->row;
		
		task->startNpcId = idNpc;
		
		task->startNpcName = npc->m_name;
		
		task->startMapName = mapmgr.mapName;
		
		task->setStartWhere(task->startMapName, task->startNpc_X, task->startNpc_Y);
		
		task->setStartWhereNpc(task->startNpcName);
		
		s_AcceptTaskList.push_back(task);
	}
	
	CloseProgressBar;
	
	GameUIRefreshAcceptTask();
}

void GameUITaskList::SendQueryAcceptTask()
{
	NDTransData bao(_MSG_QUERY_TASK_LIST_EX);
	
	bao << (unsigned char)0 << int(0);
	
	SEND_DATA(bao);
	
	ShowProgressBar;
}

void GameUITaskList::ClearAccpetTaskList()
{
	for_vec(s_AcceptTaskList, std::vector<Task*>::iterator)
	{
		delete *it;
	}
	
	s_AcceptTaskList.clear();
}

void GameUITaskList::showAvailableTaskDialog(Task& task) 
{
	std::string finalTaskContent = getDestination("", task);
	m_dlgTask = new NDUIDialog;
	m_dlgTask->Initialization();
	m_dlgTask->SetDelegate(this);
	
	std::vector<std::string> stroption;
	
	std::stringstream ss; ss << task.startWhereNpc << "\n" << task.startWhere;
	stroption.push_back(ss.str().c_str());
	m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_AccpetPlace));
	
	if (task.award_itemflag > 0) 
	{
		stroption.push_back("查看物品");
		m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_QueryItem));
	}
	
	vec_taskdata& taskdatas = task.taskDataArray;
	int iIndex = 0;
	for_vec(taskdatas, vec_taskdata_it)
	{
		TaskData *taskElement = *it;
		if (taskElement->getShowType() == 1)
		{
			std::stringstream ss; ss << taskElement->getTargetName() << taskElement->getWhereName();
			stroption.push_back(ss.str().c_str());
			m_vecDlgParam.push_back(st_dlg_para(eTaskDialog_Target, iIndex));
		}
		iIndex++;
	}
	
	std::string content = NDMapMgrObj.changeNpcString(finalTaskContent).c_str();
	
	if (content.empty() || content == "\n") 
	{
		content = "任务奖励: 无";
	}
	
	m_dlgTask->Show("任务详细信息", content.c_str(), "返回", stroption);
}



/*
 *  NewPlayerTask.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewPlayerTask.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDCommonControl.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "NDMsgDefine.h"
#include "NDMapMgr.h"
#include "NDNpc.h"
#include <sstream>
#include "ItemImage.h"
#include "NDItemType.h"
#include "ItemMgr.h"
#include "CGPointExtension.h"
#include "AutoPathTip.h"
#include "PlayerNpcListLayers.h"
#include "NDUILoad.h"

IMPLEMENT_CLASS(TaskAwardItem, NDUINode)

TaskAwardItem::TaskAwardItem()
{
	m_imgItem = NULL;
	m_lbNum = NULL;
	m_lbName = NULL;
	m_picItem = NULL;
}

TaskAwardItem::~TaskAwardItem()
{
	SAFE_DELETE(m_picItem);
}

void TaskAwardItem::Initialization()
{
	NDUINode::Initialization();
	
	m_imgItem = new NDUIImage;
	m_imgItem->Initialization();
	m_imgItem->SetFrameRect(CGRectMake(0, 0, 23, 23));
	this->AddChild(m_imgItem);
	
	m_lbNum = new NDUILabel;
	m_lbNum->Initialization();
	m_lbNum->SetFrameRect(CGRectMake(23, 3, 30, 20));
	m_lbNum->SetFontColor(ccc4(255, 0, 0, 255));
	m_lbNum->SetFontSize(12);
	this->AddChild(m_lbNum);
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetFrameRect(CGRectMake(0, 23, 64, 20));
	m_lbName->SetFontColor(ccc4(255, 0, 0, 255));
	m_lbName->SetFontSize(9);
	this->AddChild(m_lbName);
}

void TaskAwardItem::RefreshAwardItem(int idItemType, uint num)
{
	NDItemType* itemType = ItemMgrObj.QueryItemType(idItemType);
	
	if (!itemType) {
		return;
	}
	
	SAFE_DELETE(m_picItem);
	
	m_picItem = ItemImage::GetItemPicByType(itemType->m_data.m_id, false, true);
	CGSize size = m_picItem->GetSize();
	m_imgItem->SetPicture(m_picItem, false);
	
	stringstream ss; ss << " x " << num;
	m_lbNum->SetText(ss.str().c_str());
	
	m_lbName->SetText(itemType->m_name.c_str());
}

#pragma mark 任务处理

const GLfloat TASK_INFO_WIDTH = 194;

IMPLEMENT_CLASS(TaskDeal, NDObject)

TaskDeal::TaskDeal()
{
	m_task = NULL;
}

TaskDeal::~TaskDeal()
{
	
}

void TaskDeal::SetScrollLayer(NDUIContainerScrollLayer* scroll)
{
	if (!scroll) 
	{
		m_scroll.Clear();
		
		return;
	}
	
	m_scroll = scroll->QueryLink();
}

void TaskDeal::SetVisible(bool visible)
{
	if (!m_scroll) return;
	
	m_scroll->SetVisible(visible);
}

string TaskDeal::getAwardStr(Task& task)
{
	std::stringstream sb;
	
	std::stringstream awardExp;
	std::stringstream awardMoney;
	std::stringstream awardRepute;
	std::stringstream awardHonor;
	bool bAward = false;
	
	if (task.award_exp > 0) {
		bAward = true;
		awardExp  << NDCommonCString("exp") << " " << task.award_exp;
	}
	if (task.award_money > 0) {
		bAward = true;
		awardMoney  << "，" << NDCommonCString("money") << " " << task.award_money;
	}
	if (task.award_repute > 0) {
		bAward = true;
		if (task.type == 0) { // 任务类型为0,奖励国家声望
			awardRepute << "，" << NDCommonCString("CountryRepute") << " " << task.award_repute;
		} else { // 奖励阵营声望
			if (NDPlayer::defaultHero().GetCamp() != 0) { // 有阵营给提示
				awardRepute  << "，" << NDCommonCString("CampRepute") << " " << task.award_repute;
			}
		}
	}
	if (task.award_honour > 0) {
		bAward = true;
		awardHonor  << "，" << NDCommonCString("HonurVal") << " " << task.award_honour;
	}
	if (bAward) {
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
		sb << ("。");
	}
	
	return sb.str();
}

std::string TaskDeal::getDestination(std::string str, Task& task)
{
	std::stringstream sb;
	sb << str << "\n";
	vec_taskdata& dataArray = task.taskDataArray;
	if (dataArray.size() > 0) {
		sb << NDCommonCString("target") << ":";
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
	return sb.str();
}

std::string TaskDeal::getTaskInfo(std::string taskStr, Task& task, int index)
{
	if (index > 100) {	// 防止无限递归
		return "";
	}
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
			if (task_array[0] == "mon" || task_array[0] == "item" || task_array[0] == "npc"
				|| task_array[0] == "pr"
				|| task_array[0] == "rank"
				|| task_array[0] == "gold"
				|| task_array[0] == "rep"
				|| task_array[0] == "hr") {
				vec_taskdata& dataArray = task.taskDataArray;
				if (index < int(dataArray.size()) && dataArray[index])
				{
					std::stringstream ss; ss << "<cff0000" << dataArray[index]->getElementName() << "/e";
					sBuffer.replace(startIndex, endIndex-startIndex+1, ss.str().c_str());
				}
			}
		}
		
		index++;
		return getTaskInfo(sBuffer, task, index);
	} else {
		return sBuffer;
	}
	return "";
}

void TaskDeal::useTransfromItem(int mapX, int mapY, int mapId)
{
	NDMapMgrObj.throughMap(mapX, mapY, mapId);
}

void TaskDeal::DaoHang(std::string tip, CGPoint pos)
{
	NDPlayer& player = NDPlayer::defaultHero();
	
	CGPoint disPos = ccpSub(pos, player.GetPosition());
	
	if (abs(int(disPos.x)) <= 16 && abs(int(disPos.y)) <= 16)
	{
		AutoPathTipObj.work(tip);
		AutoPathTipObj.Arrive();
	}
	else
	{
		AutoPathTipObj.work(tip);
		player.Walk(pos, SpriteSpeedStep4, true);
	}
}

void TaskDeal::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (!m_task) return;
	
	uint uHyperLinkIndex = dialog->GetTag();
	if (uHyperLinkIndex < m_vLinkParam.size()) {
		HYPER_LINK_PARAM& param = m_vLinkParam.at(uHyperLinkIndex);
		
		switch (param.linkType) {
			case LINK_START_NPC:
			{
				if (m_task->startMapId == NDMapMgrObj.GetMapID())
				{
					float startNpc_X = m_task->startNpc_X,
					startNpc_Y = m_task->startNpc_Y;
					std::string startNpcName = m_task->startNpcName;
					
					CGPoint pos = ccp(startNpc_X*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, startNpc_Y*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
					
					DaoHang(startNpcName, pos);
					
					NDDirector::DefaultDirector()->PopScene();
				}
			}
				break;
			case LINK_FINISH_NPC:
			{
				if (m_task->finishMapId == NDMapMgrObj.GetMapID())
				{
					float finishNpc_X = m_task->finishNpc_X,
					finishNpc_Y = m_task->finishNpc_Y;
					std::string finishWhere = m_task->finishWhere;
					
					CGPoint pos = ccp(finishNpc_X*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, finishNpc_Y*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
					
					DaoHang(finishWhere, pos);
					
					NDDirector::DefaultDirector()->PopScene();
				}
				else
				{
					dialog->Close();
					useTransfromItem(m_task->finishNpc_X, m_task->finishNpc_Y, m_task->finishMapId);
					return;
				}
			}
				break;
			case LINK_TARGET:
			{
				vec_taskdata& taskdatas = m_task->taskDataArray;
				
				if (param.nParam >= int(taskdatas.size()))
				{
					return;
				}
				
				TaskData *taskElement = taskdatas[param.nParam];
				
				if (taskElement->getMapId() == NDMapMgrObj.GetMapID())
				{
					float mapX = taskElement->getMapX(),
					maxY = taskElement->getMapY();
					std::string elementName = taskElement->getElementName();
					
					CGPoint pos = ccp(mapX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, maxY*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET);
					
					DaoHang(elementName, pos);
					
					NDDirector::DefaultDirector()->PopScene();
				}
				else
				{
					dialog->Close();
					useTransfromItem(taskElement->getMapX(), taskElement->getMapY(), taskElement->getMapId());
					return;
				}
			}
				break;
			default:
				break;
		}
		
		//NDDirector::DefaultDirector()->PopScene();
	}
}

void TaskDeal::OnButtonClick(NDUIButton* button)
{
	if (!m_task) return;
	
	uint uHyperLinkIndex = button->GetTag();
	if (uHyperLinkIndex < m_vLinkParam.size()) {
		HYPER_LINK_PARAM& param = m_vLinkParam.at(uHyperLinkIndex);
		
		switch (param.linkType) {
			case LINK_START_NPC:
			{
				std::stringstream ss; ss << m_task->startWhereNpc << "\n" << m_task->startWhere;
				ss << "\n" << NDCommonCString("DaoHangTip");
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(NDCommonCString("DaoHang"), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case LINK_FINISH_NPC:
			{
				std::string title;
				std::stringstream ss; ss << m_task->finishWhereNpc << " " << m_task->finishWhere;
				if (m_task->finishMapId == NDMapMgrObj.GetMapID()) 
				{
					title = NDCommonCString("DaoHang");
					ss << "\n" << NDCommonCString("DaoHangTip");
				}
				else 
				{
					title = NDCommonCString("ChuanSong");
					ss << "\n" << NDCommonCString("ChuanSongTip");
				}
				
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(title.c_str(), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case LINK_TARGET:
			{
				vec_taskdata& taskdatas = m_task->taskDataArray;
				if (param.nParam >= int(taskdatas.size()))
				{
					return;
				}
				
				TaskData *taskElement = taskdatas[param.nParam];
				std::string title;
				std::stringstream ss; ss << taskElement->getTargetName() << " " << taskElement->getWhereName();
				if (taskElement->getMapId() == NDMapMgrObj.GetMapID()) 
				{
					title = NDCommonCString("DaoHang");
					ss << "\n" << NDCommonCString("DaoHangTip");
				}
				else 
				{
					title = NDCommonCString("ChuanSong");
					ss << "\n" << NDCommonCString("ChuanSongTip");
				}
				
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(title.c_str(), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			default:
				break;
		}
	}
}

void TaskDeal::RefreshTaskInfo(Task* pTask, bool bAcceptable)
{
	m_task = pTask;
	
	if (!m_scroll) return;
	
	m_scroll->RemoveAllChildren(true);
	
	m_vLinkParam.clear();
	
	if (!m_task) {
		return;
	}
	
	Task& task = *m_task;
	
	GLfloat fStartY = 0;
	
	int nHyperLinkIndex =0;
	
	if (bAcceptable) {
		// [任务奖励]
		// 数值类
		bool bAward = false;
		string strAwardData = this->getAwardStr(task);
		if (strAwardData.size() > 0) {
			bAward = true;
			
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardTitle);
			fStartY += 14;
			
			CGSize szAward = getStringSizeMutiLine(strAwardData.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szAward.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(strAwardData.c_str(), 
																	  12, 
																	  szAward, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szAward.width, szAward.height));
			m_scroll->AddChild(memo);
			fStartY += szAward.height;
		}
		
		// 物品类
		string strAwardItem;
		if (task.award_itemflag == 0) { // 不奖励物品
			
		} else if (task.award_itemflag == 1) {
			strAwardItem += NDCommonCString("AwardAllItem"); strAwardItem += ": ";
		} else {
			strAwardItem += NDCommonCString("AwardOneItem"); strAwardItem += ": ";
		}
		
		if (!bAward && strAwardItem.size() > 0) {
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardTitle);
			fStartY += 14;
		}
		
		if (strAwardItem.size() > 0) {
			NDUILabel* lbAwardItem = new NDUILabel;
			lbAwardItem->Initialization();
			lbAwardItem->SetText(strAwardItem.c_str());
			lbAwardItem->SetFontSize(12);
			lbAwardItem->SetFontColor(ccc4(255, 0, 0, 255));
			lbAwardItem->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardItem);
			fStartY += 14;
			
			GLfloat fItemStartX = 0;
			if (task.award_item1 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item1, task.award_num1);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item2 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item2, task.award_num2);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item3 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item3, task.award_num3);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			fStartY += 45;
		}
		
		// [接受任务]
		NDUILabel* lbAcceptNpcTitle = new NDUILabel;
		lbAcceptNpcTitle->Initialization();
		lbAcceptNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
		lbAcceptNpcTitle->SetText(NDCommonCString("AcceptTaskKuo"));
		lbAcceptNpcTitle->SetFontSize(12);
		lbAcceptNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		m_scroll->AddChild(lbAcceptNpcTitle);
		fStartY += 14;
		
		std::stringstream ss; ss << task.startNpcName << "  " << task.startWhere;
		HyperLinkButton* hlAcceptNpc = new HyperLinkButton;
		hlAcceptNpc->Initialization();
		hlAcceptNpc->SetTag(nHyperLinkIndex);
		nHyperLinkIndex++;
		m_vLinkParam.push_back((HYPER_LINK_PARAM(LINK_START_NPC, 0)));
		hlAcceptNpc->SetFontColor(ccc4(255, 0, 0, 255));
		hlAcceptNpc->SetFontSize(12);
		hlAcceptNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		hlAcceptNpc->SetDelegate(this);
		hlAcceptNpc->SetHyperText(ss.str().c_str());
		m_scroll->AddChild(hlAcceptNpc);
		fStartY += 14;
		
		// [任务目标]
		vec_taskdata& taskdatas = task.taskDataArray;
		int iIndex = 0;
		bool bTargetTitle = false;
		for_vec(taskdatas, vec_taskdata_it)
		{
			TaskData *taskElement = *it;
			if (taskElement->getShowType() == 1)
			{
				if (!bTargetTitle) {
					bTargetTitle = true;
					NDUILabel* lbTargetTitle = new NDUILabel;
					lbTargetTitle->Initialization();
					lbTargetTitle->SetFontColor(ccc4(80, 80, 82, 255));
					lbTargetTitle->SetText(NDCommonCString("TaskTargetKuo"));
					lbTargetTitle->SetFontSize(12);
					lbTargetTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
					m_scroll->AddChild(lbTargetTitle);
					fStartY += 14;
				}
				
				std::stringstream ss; ss << taskElement->getTargetName() << "  "  << taskElement->getWhereName();
				HyperLinkButton* hlTarget = new HyperLinkButton;
				hlTarget->Initialization();
				hlTarget->SetTag(nHyperLinkIndex);
				nHyperLinkIndex++;
				m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_TARGET, iIndex));
				hlTarget->SetFontColor(ccc4(255, 0, 0, 255));
				hlTarget->SetFontSize(12);
				hlTarget->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
				hlTarget->SetDelegate(this);
				hlTarget->SetHyperText(ss.str().c_str());
				m_scroll->AddChild(hlTarget);
				fStartY += 14;
			}
			iIndex++;
		}
		
		// [详细信息]
		std::string finalTaskContent = this->getDestination("", task);
		std::string content = NDMapMgrObj.changeNpcString(finalTaskContent).c_str();
		if (!(content.empty() || content == "\n")) 
		{
			NDUILabel* lbDetailTitle = new NDUILabel;
			lbDetailTitle->Initialization();
			lbDetailTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbDetailTitle->SetText(NDCommonCString("DetailInfoKuo"));
			lbDetailTitle->SetFontSize(12);
			lbDetailTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbDetailTitle);
			fStartY += 14;
			
			CGSize szContent = getStringSizeMutiLine(content.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szContent.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
																	  12, 
																	  szContent, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szContent.width, szContent.height));
			m_scroll->AddChild(memo);
			fStartY += szContent.height;
		}
	} else {
		// [任务奖励]
		// 数值类
		bool bAward = false;
		string strAwardData = this->getAwardStr(task);
		if (strAwardData.size() > 0) {
			bAward = true;
			
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardTitle);
			fStartY += 14;
			
			CGSize szAward = getStringSizeMutiLine(strAwardData.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szAward.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(strAwardData.c_str(), 
																	  12, 
																	  szAward, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szAward.width, szAward.height));
			m_scroll->AddChild(memo);
			fStartY += szAward.height;
		}
		
		// 物品类
		string strAwardItem;
		if (task.award_itemflag == 0) { // 不奖励物品
			
		} else if (task.award_itemflag == 1) {
			strAwardItem += NDCommonCString("AwardAllItem"); strAwardItem += ": ";
		} else {
			strAwardItem += NDCommonCString("AwardOneItem"); strAwardItem += ": ";
		}
		
		if (!bAward && strAwardItem.size() > 0) {
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardTitle);
			fStartY += 14;
		}
		
		if (strAwardItem.size() > 0) {
			NDUILabel* lbAwardItem = new NDUILabel;
			lbAwardItem->Initialization();
			lbAwardItem->SetText(strAwardItem.c_str());
			lbAwardItem->SetFontSize(12);
			lbAwardItem->SetFontColor(ccc4(255, 0, 0, 255));
			lbAwardItem->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAwardItem);
			fStartY += 14;
			
			GLfloat fItemStartX = 0;
			if (task.award_item1 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item1, task.award_num1);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item2 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item2, task.award_num2);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item3 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item3, task.award_num3);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				m_scroll->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			fStartY += 45;
		}
		
		// [接受任务]
		if (task.startNpcName.size() > 0 && task.startWhere.size() > 0) {
			NDUILabel* lbAcceptNpcTitle = new NDUILabel;
			lbAcceptNpcTitle->Initialization();
			lbAcceptNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAcceptNpcTitle->SetText(NDCommonCString("AcceptTaskKuo"));
			lbAcceptNpcTitle->SetFontSize(12);
			lbAcceptNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbAcceptNpcTitle);
			fStartY += 14;
			
			std::stringstream ss; ss << task.startNpcName << "  " << task.startWhere;
			HyperLinkButton* hlAcceptNpc = new HyperLinkButton;
			hlAcceptNpc->Initialization();
			hlAcceptNpc->SetTag(nHyperLinkIndex);
			nHyperLinkIndex++;
			m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_START_NPC, 0));
			hlAcceptNpc->SetFontColor(ccc4(255, 0, 0, 255));
			hlAcceptNpc->SetFontSize(12);
			hlAcceptNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			hlAcceptNpc->SetDelegate(this);
			hlAcceptNpc->SetHyperText(ss.str().c_str());
			m_scroll->AddChild(hlAcceptNpc);
			fStartY += 14;
		}
		
		if (!task.isDailyTask())
		{
			// [任务结束npc]
			NDUILabel* lbFinishNpcTitle = new NDUILabel;
			lbFinishNpcTitle->Initialization();
			lbFinishNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbFinishNpcTitle->SetText(NDCommonCString("JiaoTaskKuo"));
			lbFinishNpcTitle->SetFontSize(12);
			lbFinishNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbFinishNpcTitle);
			fStartY += 14;
			
			std::stringstream ss; ss << task.finishNpcName << "  " << task.finishWhere;
			HyperLinkButton* hlFinishNpc = new HyperLinkButton;
			hlFinishNpc->Initialization();
			hlFinishNpc->SetTag(nHyperLinkIndex);
			nHyperLinkIndex++;
			m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_FINISH_NPC, 0));
			hlFinishNpc->SetFontColor(ccc4(255, 0, 0, 255));
			hlFinishNpc->SetFontSize(12);
			hlFinishNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			hlFinishNpc->SetDelegate(this);
			hlFinishNpc->SetHyperText(ss.str().c_str());
			m_scroll->AddChild(hlFinishNpc);
			fStartY += 14;
		}
		// [任务目标]
		vec_taskdata& taskdatas = task.taskDataArray;
		int iIndex = 0;
		bool bTargetTitle = false;
		for_vec(taskdatas, vec_taskdata_it)
		{
			TaskData *taskElement = *it;
			if (taskElement->getShowType() == 1)
			{
				if (!bTargetTitle) {
					bTargetTitle = true;
					NDUILabel* lbTargetTitle = new NDUILabel;
					lbTargetTitle->Initialization();
					lbTargetTitle->SetFontColor(ccc4(80, 80, 82, 255));
					lbTargetTitle->SetText(NDCommonCString("TaskTargetKuo"));
					lbTargetTitle->SetFontSize(12);
					lbTargetTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
					m_scroll->AddChild(lbTargetTitle);
					fStartY += 14;
				}
				
				std::stringstream ss; ss << taskElement->getTargetName() << "  " << taskElement->getWhereName();
				HyperLinkButton* hlTarget = new HyperLinkButton;
				hlTarget->Initialization();
				hlTarget->SetTag(nHyperLinkIndex);
				nHyperLinkIndex++;
				m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_TARGET, iIndex));
				hlTarget->SetFontColor(ccc4(255, 0, 0, 255));
				hlTarget->SetFontSize(12);
				hlTarget->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
				hlTarget->SetDelegate(this);
				hlTarget->SetHyperText(ss.str().c_str());
				m_scroll->AddChild(hlTarget);
				fStartY += 14;
			}
			iIndex++;
		}
		
		// [详细信息]
		std::string tempTaskContent = getTaskInfo(task.originalTaskCorn, task, 0);
		std::string finalTaskContent = this->getDestination(tempTaskContent, task);
		std::string content = NDMapMgrObj.changeNpcString(finalTaskContent).c_str();
		if (!(content.empty() || content == "\n")) 
		{
			NDUILabel* lbDetailTitle = new NDUILabel;
			lbDetailTitle->Initialization();
			lbDetailTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbDetailTitle->SetText(NDCommonCString("DetailInfoKuo"));
			lbDetailTitle->SetFontSize(12);
			lbDetailTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			m_scroll->AddChild(lbDetailTitle);
			fStartY += 14;
			
			CGSize szContent = getStringSizeMutiLine(content.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szContent.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
																	  12, 
																	  szContent, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szContent.width, szContent.height));
			m_scroll->AddChild(memo);
			fStartY += szContent.height;
		}
	}
	
	m_scroll->refreshContainer();
	
	if (m_scroll->GetParent() && m_scroll->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		NDUINode* node = (NDUINode*)(m_scroll->GetParent());
		if (!node->IsVisibled())
			m_scroll->SetVisible(false);
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////
/*
IMPLEMENT_CLASS(TaskInfoLayer, NDUILayer)

TaskInfoLayer::TaskInfoLayer()
{
	m_task = NULL;
}

TaskInfoLayer::~TaskInfoLayer()
{
	
}

const GLfloat TASK_INFO_WIDTH = 194;

void TaskInfoLayer::Initialization()
{
	NDUIContainerScrollLayer::Initialization();
}

string TaskInfoLayer::getAwardStr(Task& task)
{
	std::stringstream sb;
	
	std::stringstream awardExp;
	std::stringstream awardMoney;
	std::stringstream awardRepute;
	std::stringstream awardHonor;
	bool bAward = false;
	
	if (task.award_exp > 0) {
		bAward = true;
		awardExp  << NDCommonCString("exp") << " " << task.award_exp;
	}
	if (task.award_money > 0) {
		bAward = true;
		awardMoney  << "，" << NDCommonCString("money") << " " << task.award_money;
	}
	if (task.award_repute > 0) {
		bAward = true;
		if (task.type == 0) { // 任务类型为0,奖励国家声望
			awardRepute << "，" << NDCommonCString("CountryRepute") << " " << task.award_repute;
		} else { // 奖励阵营声望
			if (NDPlayer::defaultHero().GetCamp() != 0) { // 有阵营给提示
				awardRepute  << "，" << NDCommonCString("CampRepute") << " " << task.award_repute;
			}
		}
	}
	if (task.award_honour > 0) {
		bAward = true;
		awardHonor  << "，" << NDCommonCString("HonurVal") << " " << task.award_honour;
	}
	if (bAward) {
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
		sb << ("。");
	}
	
	return sb.str();
}

std::string TaskInfoLayer::getDestination(std::string str, Task& task)
{
	std::stringstream sb;
	sb << str << "\n";
	vec_taskdata& dataArray = task.taskDataArray;
	if (dataArray.size() > 0) {
		sb << NDCommonCString("target") << ":";
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
	return sb.str();
}

std::string TaskInfoLayer::getTaskInfo(std::string taskStr, Task& task, int index)
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

void TaskInfoLayer::useTransfromItem(int mapX, int mapY, int mapId)
{
	NDMapMgrObj.throughMap(mapX, mapY, mapId);
}

void TaskInfoLayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	uint uHyperLinkIndex = dialog->GetTag();
	if (uHyperLinkIndex < m_vLinkParam.size()) {
		HYPER_LINK_PARAM& param = m_vLinkParam.at(uHyperLinkIndex);
		
		switch (param.linkType) {
			case LINK_START_NPC:
			{
				if (m_task->startMapId == NDMapMgrObj.GetMapID())
				{
					float startNpc_X = m_task->startNpc_X,
						  startNpc_Y = m_task->startNpc_Y;
					std::string startNpcName = m_task->startNpcName;
					
					NDDirector::DefaultDirector()->PopScene();
					
					NDPlayer::defaultHero().Walk(ccp(startNpc_X*16+DISPLAY_POS_X_OFFSET, startNpc_Y*16+DISPLAY_POS_Y_OFFSET),
												 SpriteSpeedStep4, true);
					AutoPathTipObj.work(startNpcName);
				}
			}
				break;
			case LINK_FINISH_NPC:
			{
				if (m_task->finishMapId == NDMapMgrObj.GetMapID())
				{
					float finishNpc_X = m_task->finishNpc_X,
					finishNpc_Y = m_task->finishNpc_Y;
					std::string finishWhere = m_task->finishWhere;
					
					NDDirector::DefaultDirector()->PopScene();
					
					NDPlayer::defaultHero().Walk(ccp(finishNpc_X*16+DISPLAY_POS_X_OFFSET, finishNpc_Y*16+DISPLAY_POS_Y_OFFSET),
												 SpriteSpeedStep4, true);
					AutoPathTipObj.work(finishWhere);
				}
				else
				{
					dialog->Close();
					useTransfromItem(m_task->finishNpc_X, m_task->finishNpc_Y, m_task->finishMapId);
					return;
				}
			}
				break;
			case LINK_TARGET:
			{
				vec_taskdata& taskdatas = m_task->taskDataArray;
				
				if (param.nParam >= int(taskdatas.size()))
				{
					return;
				}
				
				TaskData *taskElement = taskdatas[param.nParam];
				
				if (taskElement->getMapId() == NDMapMgrObj.GetMapID())
				{
					float mapX = taskElement->getMapX(),
						  maxY = taskElement->getMapY();
					std::string elementName = taskElement->getElementName();
					
					NDDirector::DefaultDirector()->PopScene();
					
					NDPlayer::defaultHero().Walk(ccp(mapX*16+DISPLAY_POS_X_OFFSET, maxY*16+DISPLAY_POS_Y_OFFSET),
												 SpriteSpeedStep4, true);
					
					AutoPathTipObj.work(elementName);
				}
				else
				{
					dialog->Close();
					useTransfromItem(taskElement->getMapX(), taskElement->getMapY(), taskElement->getMapId());
					return;
				}
			}
				break;
			default:
				break;
		}
		
		//NDDirector::DefaultDirector()->PopScene();
	}
}

void TaskInfoLayer::OnButtonClick(NDUIButton* button)
{
	uint uHyperLinkIndex = button->GetTag();
	if (uHyperLinkIndex < m_vLinkParam.size()) {
		HYPER_LINK_PARAM& param = m_vLinkParam.at(uHyperLinkIndex);
		
		switch (param.linkType) {
			case LINK_START_NPC:
			{
				std::stringstream ss; ss << m_task->startWhereNpc << "\n" << m_task->startWhere;
				ss << "\n" << NDCommonCString("DaoHangTip");
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(NDCommonCString("DaoHang"), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case LINK_FINISH_NPC:
			{
				std::string title;
				std::stringstream ss; ss << m_task->finishWhereNpc << " " << m_task->finishWhere;
				if (m_task->finishMapId == NDMapMgrObj.GetMapID()) 
				{
					title = NDCommonCString("DaoHang");
					ss << "\n" << NDCommonCString("DaoHangTip");
				}
				else 
				{
					title = NDCommonCString("ChuanSong");
					ss << "\n" << NDCommonCString("ChuanSongTip");
				}
				
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(title.c_str(), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case LINK_TARGET:
			{
				vec_taskdata& taskdatas = m_task->taskDataArray;
				if (param.nParam >= int(taskdatas.size()))
				{
					return;
				}
				
				TaskData *taskElement = taskdatas[param.nParam];
				std::string title;
				std::stringstream ss; ss << taskElement->getTargetName() << " " << taskElement->getWhereName();
				if (taskElement->getMapId() == NDMapMgrObj.GetMapID()) 
				{
					title = NDCommonCString("DaoHang");
					ss << "\n" << NDCommonCString("DaoHangTip");
				}
				else 
				{
					title = NDCommonCString("ChuanSong");
					ss << "\n" << NDCommonCString("ChuanSongTip");
				}
				
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(uHyperLinkIndex);
				dlg->SetDelegate(this);
				dlg->Show(title.c_str(), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			default:
				break;
		}
	}
}

void TaskInfoLayer::RefreshTaskInfo(Task* pTask, bool bAcceptable)
{
	m_task = pTask;
	
	this->RemoveAllChildren(true);
	
	m_vLinkParam.clear();
	
	if (!m_task) {
		return;
	}
	
	Task& task = *m_task;
	
	GLfloat fStartY = 0;
	
	int nHyperLinkIndex =0;
	
	if (bAcceptable) {
		// [任务奖励]
		// 数值类
		bool bAward = false;
		string strAwardData = this->getAwardStr(task);
		if (strAwardData.size() > 0) {
			bAward = true;
			
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardTitle);
			fStartY += 14;
			
			CGSize szAward = getStringSizeMutiLine(strAwardData.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szAward.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(strAwardData.c_str(), 
																	  12, 
																	  szAward, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szAward.width, szAward.height));
			this->AddChild(memo);
			fStartY += szAward.height;
		}
		
		// 物品类
		string strAwardItem;
		if (task.award_itemflag == 0) { // 不奖励物品
			
		} else if (task.award_itemflag == 1) {
			strAwardItem += NDCommonCString("AwardAllItem"); strAwardItem += ": ";
		} else {
			strAwardItem += NDCommonCString("AwardOneItem"); strAwardItem += ": ";
		}
		
		if (!bAward && strAwardItem.size() > 0) {
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardTitle);
			fStartY += 14;
		}
		
		if (strAwardItem.size() > 0) {
			NDUILabel* lbAwardItem = new NDUILabel;
			lbAwardItem->Initialization();
			lbAwardItem->SetText(strAwardItem.c_str());
			lbAwardItem->SetFontSize(12);
			lbAwardItem->SetFontColor(ccc4(255, 0, 0, 255));
			lbAwardItem->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardItem);
			fStartY += 14;
			
			GLfloat fItemStartX = 0;
			if (task.award_item1 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item1, task.award_num1);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item2 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item2, task.award_num2);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item3 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item3, task.award_num3);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			fStartY += 45;
		}
		
		// [接受任务]
		NDUILabel* lbAcceptNpcTitle = new NDUILabel;
		lbAcceptNpcTitle->Initialization();
		lbAcceptNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
		lbAcceptNpcTitle->SetText(NDCommonCString("AcceptTaskKuo"));
		lbAcceptNpcTitle->SetFontSize(12);
		lbAcceptNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		this->AddChild(lbAcceptNpcTitle);
		fStartY += 14;
		
		std::stringstream ss; ss << task.startNpcName << "  " << task.startWhere;
		HyperLinkButton* hlAcceptNpc = new HyperLinkButton;
		hlAcceptNpc->Initialization();
		hlAcceptNpc->SetTag(nHyperLinkIndex);
		nHyperLinkIndex++;
		m_vLinkParam.push_back((HYPER_LINK_PARAM(LINK_START_NPC, 0)));
		hlAcceptNpc->SetFontColor(ccc4(255, 0, 0, 255));
		hlAcceptNpc->SetFontSize(12);
		hlAcceptNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		hlAcceptNpc->SetDelegate(this);
		hlAcceptNpc->SetHyperText(ss.str().c_str());
		this->AddChild(hlAcceptNpc);
		fStartY += 14;
		
		// [任务目标]
		vec_taskdata& taskdatas = task.taskDataArray;
		int iIndex = 0;
		bool bTargetTitle = false;
		for_vec(taskdatas, vec_taskdata_it)
		{
			TaskData *taskElement = *it;
			if (taskElement->getShowType() == 1)
			{
				if (!bTargetTitle) {
					bTargetTitle = true;
					NDUILabel* lbTargetTitle = new NDUILabel;
					lbTargetTitle->Initialization();
					lbTargetTitle->SetFontColor(ccc4(80, 80, 82, 255));
					lbTargetTitle->SetText(NDCommonCString("TaskTargetKuo"));
					lbTargetTitle->SetFontSize(12);
					lbTargetTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
					this->AddChild(lbTargetTitle);
					fStartY += 14;
				}
				
				std::stringstream ss; ss << taskElement->getTargetName() << "  "  << taskElement->getWhereName();
				HyperLinkButton* hlTarget = new HyperLinkButton;
				hlTarget->Initialization();
				hlTarget->SetTag(nHyperLinkIndex);
				nHyperLinkIndex++;
				m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_TARGET, iIndex));
				hlTarget->SetFontColor(ccc4(255, 0, 0, 255));
				hlTarget->SetFontSize(12);
				hlTarget->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
				hlTarget->SetDelegate(this);
				hlTarget->SetHyperText(ss.str().c_str());
				this->AddChild(hlTarget);
				fStartY += 14;
			}
			iIndex++;
		}
		
		// [详细信息]
		std::string finalTaskContent = this->getDestination("", task);
		std::string content = NDMapMgrObj.changeNpcString(finalTaskContent).c_str();
		if (!(content.empty() || content == "\n")) 
		{
			NDUILabel* lbDetailTitle = new NDUILabel;
			lbDetailTitle->Initialization();
			lbDetailTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbDetailTitle->SetText(NDCommonCString("DetailInfoKuo"));
			lbDetailTitle->SetFontSize(12);
			lbDetailTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbDetailTitle);
			fStartY += 14;
			
			CGSize szContent = getStringSizeMutiLine(content.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szContent.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
															  12, 
															  szContent, 
															  ccc4(255, 0, 0, 255),
															  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szContent.width, szContent.height));
			this->AddChild(memo);
			fStartY += szContent.height;
		}
	} else {
		// [任务奖励]
		// 数值类
		bool bAward = false;
		string strAwardData = this->getAwardStr(task);
		if (strAwardData.size() > 0) {
			bAward = true;
			
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardTitle);
			fStartY += 14;
			
			CGSize szAward = getStringSizeMutiLine(strAwardData.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szAward.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(strAwardData.c_str(), 
																	  12, 
																	  szAward, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szAward.width, szAward.height));
			this->AddChild(memo);
			fStartY += szAward.height;
		}
		
		// 物品类
		string strAwardItem;
		if (task.award_itemflag == 0) { // 不奖励物品
			
		} else if (task.award_itemflag == 1) {
			strAwardItem += NDCommonCString("AwardAllItem"); strAwardItem += ": ";
		} else {
			strAwardItem += NDCommonCString("AwardOneItem"); strAwardItem += ": ";
		}
		
		if (!bAward && strAwardItem.size() > 0) {
			NDUILabel* lbAwardTitle = new NDUILabel;
			lbAwardTitle->Initialization();
			lbAwardTitle->SetText(NDCommonCString("TaskAwardKuo"));
			lbAwardTitle->SetFontSize(12);
			lbAwardTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAwardTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardTitle);
			fStartY += 14;
		}
		
		if (strAwardItem.size() > 0) {
			NDUILabel* lbAwardItem = new NDUILabel;
			lbAwardItem->Initialization();
			lbAwardItem->SetText(strAwardItem.c_str());
			lbAwardItem->SetFontSize(12);
			lbAwardItem->SetFontColor(ccc4(255, 0, 0, 255));
			lbAwardItem->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAwardItem);
			fStartY += 14;
			
			GLfloat fItemStartX = 0;
			if (task.award_item1 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item1, task.award_num1);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item2 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item2, task.award_num2);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			if (task.award_item3 > 0) {
				TaskAwardItem* awardItem = new TaskAwardItem;
				awardItem->Initialization();
				awardItem->RefreshAwardItem(task.award_item3, task.award_num3);
				awardItem->SetFrameRect(CGRectMake(fItemStartX, fStartY, TASK_INFO_WIDTH / 3, 43));
				this->AddChild(awardItem);
				fItemStartX += TASK_INFO_WIDTH / 3;
			}
			fStartY += 45;
		}
		
		// [接受任务]
		if (task.startNpcName.size() > 0 && task.startWhere.size() > 0) {
			NDUILabel* lbAcceptNpcTitle = new NDUILabel;
			lbAcceptNpcTitle->Initialization();
			lbAcceptNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbAcceptNpcTitle->SetText(NDCommonCString("AcceptTaskKuo"));
			lbAcceptNpcTitle->SetFontSize(12);
			lbAcceptNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbAcceptNpcTitle);
			fStartY += 14;
			
			std::stringstream ss; ss << task.startNpcName << "  " << task.startWhere;
			HyperLinkButton* hlAcceptNpc = new HyperLinkButton;
			hlAcceptNpc->Initialization();
			hlAcceptNpc->SetTag(nHyperLinkIndex);
			nHyperLinkIndex++;
			m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_START_NPC, 0));
			hlAcceptNpc->SetFontColor(ccc4(255, 0, 0, 255));
			hlAcceptNpc->SetFontSize(12);
			hlAcceptNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			hlAcceptNpc->SetDelegate(this);
			hlAcceptNpc->SetHyperText(ss.str().c_str());
			this->AddChild(hlAcceptNpc);
			fStartY += 14;
		}
		
		// [任务结束npc]
		NDUILabel* lbFinishNpcTitle = new NDUILabel;
		lbFinishNpcTitle->Initialization();
		lbFinishNpcTitle->SetFontColor(ccc4(80, 80, 82, 255));
		lbFinishNpcTitle->SetText(NDCommonCString("JiaoTaskKuo"));
		lbFinishNpcTitle->SetFontSize(12);
		lbFinishNpcTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		this->AddChild(lbFinishNpcTitle);
		fStartY += 14;
		
		std::stringstream ss; ss << task.finishNpcName << "  " << task.finishWhere;
		HyperLinkButton* hlFinishNpc = new HyperLinkButton;
		hlFinishNpc->Initialization();
		hlFinishNpc->SetTag(nHyperLinkIndex);
		nHyperLinkIndex++;
		m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_FINISH_NPC, 0));
		hlFinishNpc->SetFontColor(ccc4(255, 0, 0, 255));
		hlFinishNpc->SetFontSize(12);
		hlFinishNpc->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
		hlFinishNpc->SetDelegate(this);
		hlFinishNpc->SetHyperText(ss.str().c_str());
		this->AddChild(hlFinishNpc);
		fStartY += 14;
		
		// [任务目标]
		vec_taskdata& taskdatas = task.taskDataArray;
		int iIndex = 0;
		bool bTargetTitle = false;
		for_vec(taskdatas, vec_taskdata_it)
		{
			TaskData *taskElement = *it;
			if (taskElement->getShowType() == 1)
			{
				if (!bTargetTitle) {
					bTargetTitle = true;
					NDUILabel* lbTargetTitle = new NDUILabel;
					lbTargetTitle->Initialization();
					lbTargetTitle->SetFontColor(ccc4(80, 80, 82, 255));
					lbTargetTitle->SetText(NDCommonCString("TaskTargetKuo"));
					lbTargetTitle->SetFontSize(12);
					lbTargetTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
					this->AddChild(lbTargetTitle);
					fStartY += 14;
				}
				
				std::stringstream ss; ss << taskElement->getTargetName() << "  " << taskElement->getWhereName();
				HyperLinkButton* hlTarget = new HyperLinkButton;
				hlTarget->Initialization();
				hlTarget->SetTag(nHyperLinkIndex);
				nHyperLinkIndex++;
				m_vLinkParam.push_back(HYPER_LINK_PARAM(LINK_TARGET, iIndex));
				hlTarget->SetFontColor(ccc4(255, 0, 0, 255));
				hlTarget->SetFontSize(12);
				hlTarget->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
				hlTarget->SetDelegate(this);
				hlTarget->SetHyperText(ss.str().c_str());
				this->AddChild(hlTarget);
				fStartY += 14;
			}
			iIndex++;
		}
		
		// [详细信息]
		std::string tempTaskContent = getTaskInfo(task.originalTaskCorn, task, 0);
		std::string finalTaskContent = this->getDestination(tempTaskContent, task);
		std::string content = NDMapMgrObj.changeNpcString(finalTaskContent).c_str();
		if (!(content.empty() || content == "\n")) 
		{
			NDUILabel* lbDetailTitle = new NDUILabel;
			lbDetailTitle->Initialization();
			lbDetailTitle->SetFontColor(ccc4(80, 80, 82, 255));
			lbDetailTitle->SetText(NDCommonCString("DetailInfoKuo"));
			lbDetailTitle->SetFontSize(12);
			lbDetailTitle->SetFrameRect(CGRectMake(0, fStartY, TASK_INFO_WIDTH, 14));
			this->AddChild(lbDetailTitle);
			fStartY += 14;
			
			CGSize szContent = getStringSizeMutiLine(content.c_str(), 12, CGSizeMake(TASK_INFO_WIDTH, 320));
			szContent.width = TASK_INFO_WIDTH;
			NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
																	  12, 
																	  szContent, 
																	  ccc4(255, 0, 0, 255),
																	  true);
			memo->SetFrameRect(CGRectMake(0, fStartY, szContent.width, szContent.height));
			this->AddChild(memo);
			fStartY += szContent.height;
		}
	}

	this->refreshContainer();
	
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
	{
		NDUINode* node = (NDUINode*)(this->GetParent());
		if (!node->IsVisibled())
			this->SetVisible(false);
	}
}
*/
/////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NewPlayerTask, NDUILayer)

NewPlayerTask* NewPlayerTask::s_instance = NULL;
vec_task NewPlayerTask::s_AcceptTaskList;

void NewPlayerTask::ClearAccpetTaskList()
{
	for_vec(s_AcceptTaskList, std::vector<Task*>::iterator)
	{
		delete *it;
	}
	
	s_AcceptTaskList.clear();
}

Task* NewPlayerTask::QueryAcceptableTask(int idTask)
{
	for_vec(s_AcceptTaskList, std::vector<Task*>::iterator)
	{
		if (idTask == (*it)->taskId) {
			return *it;
		}
	}
	return NULL;
}

void NewPlayerTask::processTaskAcceptalbe(NDTransData& data)
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
	
	if (s_instance) {
		s_instance->refreshTaskList(true);
	}
	
	NpcListLayer::refreshNpcTaskInfo();
}

void NewPlayerTask::refreshTaskYiJie()
{
	if (s_instance) {
		s_instance->refreshTaskList(false);
	}
}

void NewPlayerTask::refreshTaskDetailYiJie(Task* task)
{
	m_taskInfo.RefreshTaskInfo(task, false);
	
	if (!this->IsVisibled())
		m_taskInfo.SetVisible(false);
}

void NewPlayerTask::refreshTaskDetailKeJie(Task* task)
{
	m_taskInfo.RefreshTaskInfo(task, true);
	
	if (!this->IsVisibled())
		m_taskInfo.SetVisible(false);
}

void NewPlayerTask::ShowTaskYiJieDetail(Task* task)
{
	if (s_instance) {
		s_instance->refreshTaskDetailYiJie(task);
	}
}

void NewPlayerTask::refreshTaskList(bool bAcceptable)
{
	NDUITableLayer *tablelayer = bAcceptable ? m_tlKeJie : m_tlYiJie;
	
	if (!tablelayer || !tablelayer->GetDataSource())
	{
		return;
	}
	
	NDSection *section = tablelayer->GetDataSource()->Section(0);
	if (!section)
	{
		return;
	}
	
	section->Clear();
	
	vec_task& task = bAcceptable ? s_AcceptTaskList : NDPlayer::defaultHero().m_vPlayerTask;
	int iTaskNum = task.size();

	Task* pTask = NULL;
	int index = 0;
	bool hasTask = false;
	for (int i = 0; i < iTaskNum; i++)
	{
		pTask = task[i];
		
		if (!bAcceptable && pTask->isDailyTask()) continue;

		std::stringstream ss;
		ss << (index+1) << ".";
		ss << pTask->taskTitle;
		
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(false);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(ss.str().c_str());
		
		propDetail->SetFocusTextColor(ccc4(187, 19, 19, 255));
		if (pTask->isFinish) {
			propDetail->SetPicAfterKey(m_picTaskDone);
		}
		propDetail->SetTag(pTask->taskId);
		section->AddCell(propDetail);
		index++;
		hasTask = true;
	}
	
	section->SetFocusOnCell(0);
	
	bool isTableShow = tablelayer->IsVisibled();
	
	tablelayer->ReflashData();
	
	if (!isTableShow || !this->IsVisibled()) 
	{
		tablelayer->SetVisible(isTableShow);
		
		return;
	}
	
	//m_lbTaskTitle->SetText("");
//	m_btnClose->RemoveFromParent(false);
//	
//	if (!hasTask)
//	{
//		m_taskInfo.RefreshTaskInfo(NULL, bAcceptable);
//		return;
//	}
	
	if (this->IsVisibled())
	{
		OnTaskTabSel(bAcceptable);
	}
	
	//if (!this->IsVisibled())
//		tablelayer->SetVisible(false);
//	
//	NDNode* pNode = tablelayer->GetParent();
//	
//	if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
//	{
//		if (!((NDUINode*)pNode)->IsVisibled())
//		{
//			tablelayer->SetVisible(false);
//			m_lbTaskTitle->SetText("");
//			m_taskInfo.RefreshTaskInfo(NULL, bAcceptable);
//		}
//	}
}

NewPlayerTask::NewPlayerTask()
{
	s_instance = this;
	
	m_layerLeft = NULL;
	m_layerKeJie = NULL;
	m_layerYiJie = NULL;	
	m_tlKeJie = NULL;
	m_tlYiJie = NULL;
	m_picTaskDone = NULL;
	m_btnClose = NULL;
	m_lbTaskTitle = NULL;
}

NewPlayerTask::~NewPlayerTask()
{
	s_instance = NULL;
	ClearAccpetTaskList();
	
	SAFE_DELETE(m_picTaskDone);
	
	if (m_btnClose && m_btnClose->GetParent() == NULL) {
		SAFE_DELETE(m_btnClose);
	}
	
}

void NewPlayerTask::OnTaskTabSel(bool bAcceptable)
{
	if (bAcceptable) {
		m_btnClose->RemoveFromParent(false);
		
		NDSection* sec = m_tlKeJie->GetDataSource()->Section(0);
		if (sec->Count() == 0) {
			m_lbTaskTitle->SetText("");
			m_taskInfo.RefreshTaskInfo(NULL, true);
		}
		
		uint focusCellIndex = sec->GetFocusCellIndex();
		if (focusCellIndex < sec->Count()) {
			this->OnTableLayerCellFocused(m_tlKeJie, sec->Cell(focusCellIndex), focusCellIndex, sec);
		}
		
	} else {
		NDSection* sec = m_tlYiJie->GetDataSource()->Section(0);
		
		if (sec->Count() > 0) {
			uint focusCellIndex = sec->GetFocusCellIndex();
			this->OnTableLayerCellFocused(m_tlYiJie, sec->Cell(focusCellIndex), focusCellIndex, sec);
		} else {
			m_lbTaskTitle->SetText("");
			m_taskInfo.RefreshTaskInfo(NULL, false);
		}
		
	}
}

void NewPlayerTask::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	OnTaskTabSel(1 == curIndex);
	//if (1 == curIndex) {
//		m_btnClose->RemoveFromParent(false);
//		
//		NDSection* sec = m_tlKeJie->GetDataSource()->Section(0);
//		if (sec->Count() == 0) {
//			m_lbTaskTitle->SetText("");
//			m_taskInfo.RefreshTaskInfo(NULL, true);
//		}
//		
//		uint focusCellIndex = sec->GetFocusCellIndex();
//		if (focusCellIndex < sec->Count()) {
//			this->OnTableLayerCellFocused(m_tlKeJie, sec->Cell(focusCellIndex), focusCellIndex, sec);
//		}
//		
//	} else if (0 == curIndex) {
//		NDSection* sec = m_tlYiJie->GetDataSource()->Section(0);
//		
//		if (sec->Count() > 0) {
//			uint focusCellIndex = sec->GetFocusCellIndex();
//			this->OnTableLayerCellFocused(m_tlYiJie, sec->Cell(focusCellIndex), focusCellIndex, sec);
//		} else {
//			m_lbTaskTitle->SetText("");
//			m_taskInfo.RefreshTaskInfo(NULL, false);
//		}
//
//	}
}

void NewPlayerTask::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (!table->IsVisibled())
	{
		return;
	}
	
	Task* pTask = NULL;
	
	if (table == m_tlYiJie) {
		/*
		vec_task& task = NDPlayer::defaultHero().m_vPlayerTask;
		if (cellIndex < task.size()) {
			pTask = task[cellIndex];
		}
		*/
		pTask = NDPlayer::defaultHero().GetPlayerTask(cell->GetTag());
	} else if (table == m_tlKeJie) {
		if (cellIndex < s_AcceptTaskList.size()) {
			pTask = s_AcceptTaskList[cellIndex];
		}
	}
	
	if (!pTask) {
		return;
	}
	
	// 刷新左侧任务信息
	m_lbTaskTitle->SetText(((NDPropCell*)cell)->GetKeyText()->GetText().c_str());
	
	if (table == m_tlKeJie) {
		this->refreshTaskDetailKeJie(pTask);
	} else if (table == m_tlYiJie) {
		if (m_btnClose->GetParent() == NULL) {
			m_layerLeft->AddChild(m_btnClose);
		}
		if (!pTask->finishWhere.empty()) {
			this->refreshTaskDetailYiJie(pTask);
		} else {
			NDTransData bao(_MSG_TASKINFO);
			bao << (unsigned char)6 << int(pTask->taskId);
			SEND_DATA(bao);
			ShowProgressBar;
		}
	}
}

void NewPlayerTask::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	m_layerLeft = new NDUILayer;
	m_layerLeft->Initialization();
	m_layerLeft->SetFrameRect(CGRectMake(0,12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	m_layerLeft->SetBackgroundImage(picBagLeftBg, true);
	this->AddChild(m_layerLeft);
	
	int width = 252, height = 241;
	
	NDPicture *picClose = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("task_delete.png"));
	CGSize sizeClose = picClose->GetSize();
	m_btnClose = new NDUIButton;
	m_btnClose->Initialization();
	m_btnClose->SetFrameRect(CGRectMake(155, height-sizeClose.height + 14, sizeClose.width, sizeClose.height));
	m_btnClose->SetImage(picClose, false, CGRectZero, true);
	m_btnClose->SetDelegate(this);
	
	m_lbTaskTitle = new NDUILabel;
	m_lbTaskTitle->Initialization();
	m_lbTaskTitle->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbTaskTitle->SetFrameRect(CGRectMake(3, 3, 100, 20));
	m_layerLeft->AddChild(m_lbTaskTitle);
	
	
	NDUIContainerScrollLayer *scrollLayer = new NDUIContainerScrollLayer;
	scrollLayer->Initialization();
	scrollLayer->SetBackgroundImage( pool.AddPicture(GetImgPathNew("attr_role_bg.png"), 194, 184), true);
	//m_taskInfo.SetBackgroundColor(ccc4(0, 255, 0, 255));
	scrollLayer->SetFrameRect(CGRectMake(0, 26, 194, 184));
	m_layerLeft->AddChild(scrollLayer);
	
	m_taskInfo.SetScrollLayer(scrollLayer);
	
	
	m_layerYiJie = new NDUILayer;
	
	m_layerYiJie->Initialization();
	
	do 
	{
		m_tlYiJie = new NDUITableLayer;
		m_tlYiJie->Initialization();
		m_tlYiJie->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tlYiJie->VisibleSectionTitles(false);
		m_tlYiJie->SetFrameRect(CGRectMake(6, 17, width-10, height));
		m_tlYiJie->VisibleScrollBar(false);
		m_tlYiJie->SetCellsInterval(2);
		m_tlYiJie->SetCellsRightDistance(0);
		m_tlYiJie->SetCellsLeftDistance(0);
		m_tlYiJie->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		
		dataSource->AddSection(section);
		m_tlYiJie->SetDataSource(dataSource);
		m_layerYiJie->AddChild(m_tlYiJie);
		
		this->refreshTaskList(false);
	} while (0);
	
	m_layerKeJie = new NDUILayer;
	
	m_layerKeJie->Initialization();
	
	m_picTaskDone = pool.AddPicture(GetImgPathBattleUI("TaskDone.png"), false);
	
	do 
	{
		m_tlKeJie = new NDUITableLayer;
		m_tlKeJie->Initialization();
		m_tlKeJie->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tlKeJie->VisibleSectionTitles(false);
		m_tlKeJie->SetFrameRect(CGRectMake(6, 17, width-10, height));
		m_tlKeJie->VisibleScrollBar(false);
		m_tlKeJie->SetCellsInterval(2);
		m_tlKeJie->SetCellsRightDistance(0);
		m_tlKeJie->SetCellsLeftDistance(0);
		m_tlKeJie->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		
		dataSource->AddSection(section);
		m_tlKeJie->SetDataSource(dataSource);
		m_layerKeJie->AddChild(m_tlKeJie);
	} while (0);
	
	if (s_AcceptTaskList.empty()) {
//		NDTransData bao(_MSG_QUERY_TASK_LIST_EX);
//		bao << (unsigned char)0 << int(0);
//		SEND_DATA(bao);
//		ShowProgressBar;
	} else {
		//this->refreshTaskList(true);
	}
	
	this->refreshTaskList(false);
}

void NewPlayerTask::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnClose) {
		// 删除任务
		if (m_tlYiJie->IsVisibled()) {
			NDSection* sec = m_tlYiJie->GetDataSource()->Section(0);
			uint uFocusIdx = sec->GetFocusCellIndex();
			if (uFocusIdx >= sec->Count()) 
			{
				return;
			}
			
			NDUINode* uiNode = sec->Cell(uFocusIdx);
			if (!uiNode)
			{
				return;
			}
			
			Task* pTask = NDPlayer::defaultHero().GetPlayerTask(uiNode->GetTag());
			if (pTask)
			{
				NDTransData bao(_MSG_TASKINFO);
				bao << (unsigned char)Task::TASK_DEL << int(pTask->taskId);
				SEND_DATA(bao);
				ShowProgressBar;
			}
		}
		return;
	}
}

void NewPlayerTask::AddKeJie(NDUINode* parent)
{
	if (!parent || !m_layerKeJie) return;
	
	CGSize size = parent->GetFrameRect().size;
	//m_layerKeJie->SetBackgroundColor(ccc4(255, 0, 0, 255));
	m_layerKeJie->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerKeJie);
}

void NewPlayerTask::AddYiJie(NDUINode* parent)
{
	if (!parent || !m_layerYiJie) return;
	
	CGSize size = parent->GetFrameRect().size;
	//m_layerYiJie->SetBackgroundColor(ccc4(0, 255, 0, 255));
	m_layerYiJie->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerYiJie);
}

#pragma mark  日常任务

const unsigned long ID_DAILYTASK_CTRL_TABLE_TASKLIST			= 9;
const unsigned long ID_DAILYTASK_CTRL_BUTTON_REFRESH			= 6;
const unsigned long ID_DAILYTASK_CTRL_BUTTON_FINISH				= 3;
const unsigned long ID_DAILYTASK_CTRL_PICTURE_4					= 4;
const unsigned long ID_DAILYTASK_CTRL_TEXT_TASKNAME				= 7;
const unsigned long ID_DAILYTASK_CTRL_LIST_TASKINFO				= 2;
const unsigned long ID_DAILYTASK_CTRL_PICTURE_1					= 1;

IMPLEMENT_CLASS(DailyTask, NDUILayer)

DailyTask::DailyTask()
{
	m_picTaskDone = NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("TaskDone.png"), false);
	
	m_iType = 0;
}

DailyTask::~DailyTask()
{
	SAFE_DELETE(m_picTaskDone);
}

void DailyTask::Initialization(int iType)
{
	m_iType = iType;
	
	NDUILayer::Initialization();
	
	NDUILoad ui;
	ui.Load("DailyTask.ini", this, this, CGSizeMake(0, 37));
	
	m_taskInfo.SetScrollLayer(GetTaskInfoList());
	
	refresh();
}

void DailyTask::SetType(int iType)
{
	m_iType = iType;
}

int DailyTask::GetType()
{
	return m_iType;
}

void DailyTask::refresh()
{
	NDUITableLayer *tablelayer = GetTaskList();
	
	NDUILabel* lbTitle = GetTaskTitle();
	
	if (lbTitle)
	{
		lbTitle->SetText("");
	}
	
	if (!tablelayer)
	{
		return;
	}
	
	if (!tablelayer->GetDataSource())
	{
		NDDataSource *source = new NDDataSource;
		tablelayer->SetDataSource(source);
		
		NDSection *sec = new NDSection;
		source->AddSection(sec);
	}
	
	NDSection *section = tablelayer->GetDataSource()->Section(0);
	if (!section)
	{
		return;
	}
	
	section->Clear();
	
	vec_task& task = NDPlayer::defaultHero().m_vPlayerTask;
	int iTaskNum = task.size();
	
	if (iTaskNum == 0) {
		m_taskInfo.RefreshTaskInfo(NULL, false);
	}
	
	Task* pTask = NULL;
	int index = 0;
	bool hasTask = false;
	for (int i = 0; i < iTaskNum; i++)
	{
		pTask = task[i];
		
		if (!pTask->isDailyTask()) continue;
		
		if (pTask->getTaskType() != m_iType) continue;
		
		std::stringstream ss;
		ss << (index+1) << ".";
		ss << pTask->taskTitle;
		
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(false);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(ss.str().c_str());
		
		propDetail->SetFocusTextColor(ccc4(187, 19, 19, 255));
		if (pTask->isFinish) {
			propDetail->SetPicAfterKey(m_picTaskDone);
		}
		propDetail->SetTag(pTask->taskId);
		section->AddCell(propDetail);
		
		index++;
		hasTask = true;
	}
	
	if (!hasTask && iTaskNum > 0)
	{
		m_taskInfo.RefreshTaskInfo(NULL, false);
	}
	
	section->SetFocusOnCell(0);
	
	tablelayer->ReflashData();
	
	if (!this->IsVisibled())
		tablelayer->SetVisible(false);
}


NDUIContainerScrollLayer* DailyTask::GetTaskInfoList()
{
	return (NDUIContainerScrollLayer*)this->GetChild(ID_DAILYTASK_CTRL_LIST_TASKINFO);
}

NDUITableLayer*	DailyTask::GetTaskList()
{
	return (NDUITableLayer*)this->GetChild(ID_DAILYTASK_CTRL_TABLE_TASKLIST);
}

NDUIButton*	DailyTask::GetRefreshBtn()
{
	return (NDUIButton*)this->GetChild(ID_DAILYTASK_CTRL_BUTTON_REFRESH);
}

NDUIButton*	DailyTask::GetFinishBtn()
{
	return (NDUIButton*)this->GetChild(ID_DAILYTASK_CTRL_BUTTON_FINISH);
}

NDUILabel* DailyTask::GetTaskTitle()
{
	return (NDUILabel*)this->GetChild(ID_DAILYTASK_CTRL_TEXT_TASKNAME);
}

Task* DailyTask::GetCurSelTask()
{
	NDUITableLayer *tasklist = GetTaskList();
	
	if (!tasklist) return false;
	
	if ( !tasklist->GetDataSource() ||
		tasklist->GetDataSource()->Count() != 1 )
		return false;
	
	NDSection* section = tasklist->GetDataSource()->Section(0);
	
	if (!section || section->GetFocusCellIndex() >= section->Count())
		return false;
	
	NDUINode* cell = section->Cell(section->GetFocusCellIndex());
	
	if (!cell) return false;
	
	return NDPlayer::defaultHero().GetPlayerTask(cell->GetTag());
}

bool DailyTask::IsCurTaskFinish()
{	
	Task* task = GetCurSelTask();
	
	if (!task) return false;
	
	return task->isFinish;
}

void DailyTask::ShowFinishBtn(bool show)
{
	NDUIButton *btn = GetFinishBtn();
	
	if (!btn) return;
	
	btn->SetVisible(show);
}

void DailyTask::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
	
	if (visible)
	{
		ShowFinishBtn(IsCurTaskFinish());
	}
}

void DailyTask::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	Task* pTask = NULL;
	
	if (table != GetTaskList()) return;
	

	pTask = NDPlayer::defaultHero().GetPlayerTask(cell->GetTag());
	
	if (!pTask || pTask->getTaskType() != m_iType) {
		return;
	}
	
	// 刷新左侧任务信息
	NDUILabel* lbTitle = GetTaskTitle();
	
	if (lbTitle)
	{
		lbTitle->SetText(((NDPropCell*)cell)->GetKeyText()->GetText().c_str());
	}
	
	m_taskInfo.RefreshTaskInfo(pTask, false);
	
	if (!this->IsVisibled())
		m_taskInfo.SetVisible(false);
		
	ShowFinishBtn(pTask->isFinish && this->IsVisibled());
}

void DailyTask::OnButtonClick(NDUIButton* button)
{
	if (button == GetRefreshBtn())
	{ // 刷新
	
//		NDPlayer& player = NDPlayer::defaultHero();
//		if (player.eMoney < 10) {
//			showDialog(NDCommonCString("tip"), "");
//			return;
//		}
		
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show(NDCommonCString("tip"), NDCommonCString("DailyTaskRefreshTip"), "", NDCommonCString("Ok"), NULL);
		
		return;
	}
	else if (button == GetFinishBtn())
	{
		Task *task = GetCurSelTask();
		
		if (!task) return;
		
		ShowProgressBar;
		
		NDTransData bao(_MSG_TASKINFO);
		bao << (unsigned char)Task::TASK_COMPLETE << int(task->taskId);
		SEND_DATA(bao);
	}
}

void DailyTask::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	ShowProgressBar;
	
	NDTransData bao(_MSG_TASKINFO);
	bao << (unsigned char)Task::REFRESH_REGULAR_TASK;
	SEND_DATA(bao);
	
	dialog->Close();
}

bool DailyTask::OnTargetBtnEvent(NDUINode* uinode, int targetEvent)
{
	if (uinode != GetRefreshBtn() && uinode != GetFinishBtn())
		return false;
		
	OnButtonClick((NDUIButton*)uinode);
		
	return true;
}

bool DailyTask::OnTargetTableEvent(NDUINode* uinode, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (uinode != GetTaskList()) return false;
	
	OnTableLayerCellFocused((NDUITableLayer*)uinode, cell, cellIndex, section);
	
	return true;
}
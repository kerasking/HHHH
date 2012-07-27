/*
 *  NewPlayerTask.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __NEW_PLAYER_TASK_H__
#define __NEW_PLAYER_TASK_H__

#include "define.h"
#include "NDUILayer.h"
#include "NDUITableLayer.h"
#include "NDPlayer.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"
#include "NDCommonScene.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

class TaskAwardItem : public NDUINode {
	DECLARE_CLASS(TaskAwardItem)
public:
	TaskAwardItem();
	~TaskAwardItem();
	
	void Initialization();
	
	void RefreshAwardItem(int idItemType, uint num);
	
private:
	NDPicture* m_picItem;
	
	NDUIImage* m_imgItem;
	NDUILabel* m_lbNum;
	NDUILabel* m_lbName;
};

#pragma mark 任务处理

class TaskDeal :
public NDObject,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(TaskDeal)
public:
	TaskDeal();
	~TaskDeal();
	
	void SetScrollLayer(NDUIContainerScrollLayer* scroll);
	
	void RefreshTaskInfo(Task* task, bool bAcceptable);
	
	void SetVisible(bool visible);
private:	
	std::string getTaskInfo(std::string taskStr, Task& task, int index);
	std::string getDestination(std::string str, Task& task);
	void useTransfromItem(int mapX, int mapY, int mapId);
	string getAwardStr(Task& task);
	
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void DaoHang(std::string tip, CGPoint pos);
private:
	Task* m_task;
	
	CAutoLink<NDUIContainerScrollLayer> m_scroll;
	
	enum LINK_TYPE {
		LINK_BEGIN,
		LINK_START_NPC,
		LINK_TARGET,
		LINK_FINISH_NPC,
	};
	
	struct HYPER_LINK_PARAM {
		HYPER_LINK_PARAM(LINK_TYPE eLinkType, int param)
		{
			linkType = eLinkType;
			nParam = param;
		}
		
		LINK_TYPE linkType;
		int nParam;
	};
	
	typedef vector<HYPER_LINK_PARAM> VEC_HYPER_LINK_PARAM;
	VEC_HYPER_LINK_PARAM m_vLinkParam;
};

/*
class TaskInfoLayer :
public NDUIContainerScrollLayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(TaskInfoLayer)
public:
	TaskInfoLayer();
	~TaskInfoLayer();
	
	void Initialization();
	
	void RefreshTaskInfo(Task* task, bool bAcceptable);
	
	std::string getTaskInfo(std::string taskStr, Task& task, int index);
	std::string getDestination(std::string str, Task& task);
	void useTransfromItem(int mapX, int mapY, int mapId);
	string getAwardStr(Task& task);
	
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
private:
	Task* m_task;
	
	enum LINK_TYPE {
		LINK_BEGIN,
		LINK_START_NPC,
		LINK_TARGET,
		LINK_FINISH_NPC,
	};
	
	struct HYPER_LINK_PARAM {
		HYPER_LINK_PARAM(LINK_TYPE eLinkType, int param)
		{
			linkType = eLinkType;
			nParam = param;
		}
		
		LINK_TYPE linkType;
		int nParam;
	};
	
	typedef vector<HYPER_LINK_PARAM> VEC_HYPER_LINK_PARAM;
	VEC_HYPER_LINK_PARAM m_vLinkParam;
};
*/

class NewPlayerTask : 
public NDUILayer,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUIButtonDelegate,
public TabLayerDelegate
{
	DECLARE_CLASS(NewPlayerTask)
public:
	static void processTaskAcceptalbe(NDTransData& data);
	static void refreshTaskYiJie();
	static void ShowTaskYiJieDetail(Task* task);
	static Task* QueryAcceptableTask(int idTask);
	
	NewPlayerTask();
	~NewPlayerTask();
	
	void Initialization();
	
	void AddKeJie(NDUINode* parent);
	void AddYiJie(NDUINode* parent);
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void OnButtonClick(NDUIButton* button);
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex);
private:
	NDUILayer* m_layerLeft;
	NDUILayer* m_layerKeJie;
	NDUILayer* m_layerYiJie;
	
	NDUITableLayer* m_tlKeJie;
	NDUITableLayer* m_tlYiJie;
	
	NDPicture* m_picTaskDone;
	
	NDUIButton* m_btnClose;
	
	NDUILabel* m_lbTaskTitle;
	
	TaskDeal m_taskInfo;
	
	static NewPlayerTask* s_instance;
	
	static vec_task s_AcceptTaskList;
	
private:
	void refreshTaskList(bool bAcceptable);
	
	void refreshTaskDetailYiJie(Task* task);
	
	void refreshTaskDetailKeJie(Task* task);
	
	void OnTaskTabSel(bool bAcceptable);
	
	static void ClearAccpetTaskList();
};

class DailyTask :
public NDUILayer,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUIButtonDelegate,
public NDUITargetDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(DailyTask)
	
	DailyTask();
	~DailyTask();

public:
	void Initialization(int iType);
	
	void SetType(int iType);
	int  GetType();
	
	void refresh();
	
private:
	int					m_iType;
	NDPicture*			m_picTaskDone;
	TaskDeal			m_taskInfo;
private:
	NDUIContainerScrollLayer* GetTaskInfoList();
	
	NDUITableLayer*		GetTaskList();
	NDUIButton*			GetRefreshBtn();
	NDUIButton*			GetFinishBtn();
	NDUILabel*			GetTaskTitle();
	
	Task*				GetCurSelTask();
	bool				IsCurTaskFinish();
	void				ShowFinishBtn(bool show);
	
	
	void				SetVisible(bool visible);
	void				OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void				OnButtonClick(NDUIButton* button);
	void				OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	bool OnTargetBtnEvent(NDUINode* uinode, int targetEvent);
	bool OnTargetTableEvent(NDUINode* uinode, NDUINode* cell, unsigned int cellIndex, NDSection* section);
};

#endif
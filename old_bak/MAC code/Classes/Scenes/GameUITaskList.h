/*
 *  GameUITaskList.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *	旧界面，无须理会
 */

#ifndef _GAME_UI_TASK_LIST_H_
#define _GAME_UI_TASK_LIST_H_

#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "VipStoreScene.h"

#define task_desplay_num	(20)

using namespace NDEngine;

class NDUITBCellLayer : public NDUILayer
{
	DECLARE_CLASS(NDUITBCellLayer)
public:
	NDUITBCellLayer(){ m_bBorder = true; }
	~NDUITBCellLayer(){}
	void draw(); override
	void SetBorder(bool bSet) { m_bBorder = bSet; }
private:
	bool m_bBorder; //默认为开
};

////////////////////////////////////////

class Task;

void GameUIRefreshTask();
void GameUIRefreshAcceptTask();
void GameUIShowTaskDialog(Task* task); 

class GameUITaskList : 
public NDUIMenuLayer,
public NDUITableLayerDelegate, 
public NDUIDialogDelegate,
public NDUIButtonDelegate,
public StoreTabLayerDelegate
{
	enum
	{
		eTLQueryTask = 100,
		eTLDelTask,
	};
	
	enum
	{
		eTaskDialog_Begin = 0,
		eTaskDialog_DesPlace = eTaskDialog_Begin,
		eTaskDialog_QueryItem,
		eTaskDialog_Target,
		eTaskDialog_Trans_Des,
		eTaskDialog_Trans_Target,
		eTaskDialog_AccpetPlace,
		eTaskDialog_End,
	};
	
	struct st_dlg_para
	{
		int iOperate;
		int iParam;
		st_dlg_para(int op, int para=0){ iOperate = op; iParam = para; }
		st_dlg_para(){ reset(); }
		bool empty(){ return iOperate == -1;}
		int getOP(){ return iOperate; }
		int getPara(){ return iParam; }
		st_dlg_para& operator=(const st_dlg_para& p){ iOperate = p.iOperate; iParam = p.iParam; return *this;}
		void reset(){ iOperate = -1; iParam = 0; }
	};
	
	DECLARE_CLASS(GameUITaskList)
public:
	GameUITaskList();
	~GameUITaskList();
	
	void Initialization(); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDialogClose(NDUIDialog* dialog); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnButtonClick(NDUIButton* button); override
	void OnFocusTablayer(StoreTabLayer* tablayer); override

	void refreshTLMain(bool bAcceptList=false);
	void showTaskDialog(Task& task);
	
	static void processQueryAcceptTask(NDTransData& data);
private:
	void resetDlgParam();
	void InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);

	std::string getDestination(std::string str, Task& task);
	std::string getTaskInfo(std::string taskStr, Task& task, int index);
	void useTransfromItem(int mapX, int mapY, int mapId);
	
	void initMain(NDUITableLayer*& tablelayer);
	
	void SendQueryAcceptTask();
	
	void showAvailableTaskDialog(Task& task);
	
	static void ClearAccpetTaskList();
private:
	std::vector<st_dlg_para> m_vecDlgParam;
	st_dlg_para m_curDlgParam;
	Task		   *m_curTask;
	NDUITableLayer *m_tlMain, *m_tlMainAccept;
	NDUITableLayer *m_tlOpertate;
	NDUILabel	   *m_lbTitle;
	NDUIDialog	   *m_dlgTask;
	StoreTabLayer  *m_taskTab[2];
	
	static std::vector<Task*> s_AcceptTaskList;
};

#endif // _GAME_UI_TASK_LIST_H_
/*
 *  ServerListScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SERVER_LIST_SCENE_H
#define _SERVER_LIST_SCENE_H

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDDlgBackGround.h"
#include "NDUIDefaultTableLayer.h"
#include "NDUIDefaultButton.h"
#include "NDTimer.h"
#include <vector>

using namespace NDEngine;

enum 
{
	SERVER_STATUS_LOAD_LOW  = 0,				//通畅===》绿色
	SERVER_STATUS_LOAD_COMMON = 1,				//火爆 ====》金黄色
	SERVER_STATUS_LOAD_HIGH = 2,				//拥挤   ====》红色
	SERVER_STATUS_LOAD_OVER = 3,				//超负荷 ====》深红色
	SERVER_STATUS_LOAD_FULL = 4,				//满员   ====》紫红色
	SERVER_STATUS_STOP = 5,						//原色
	SERVER_STATUS_END,
};

class ServerListRecord : public NDUINode
{
	DECLARE_CLASS(ServerListRecord)
public:
	ServerListRecord();
	
	~ServerListRecord();
	
	void Initialization(std::string text, int state); hide
	
	void SetFrameRect(CGRect rect); override
	
	void draw();
private:
	NDPicture *m_picState, *m_picSel;
	NDUILabel *m_lbText;
};

class ServerListScene : 
public NDScene, 
public NDUIButtonDelegate, 
public NDUIDefaultTableLayerDelegate,
public NDDlgBackGroundDelegate,
public ITimerCallback
{
	DECLARE_CLASS(ServerListScene)
public:
	ServerListScene();
	~ServerListScene();
public:
	static ServerListScene* Scene();
	void Initialization(); override 
	void OnTimer(OBJID tag);
	void OnButtonClick(NDUIButton* button); override
	void OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDlgBackGroundBtnClick(NDDlgBackGround* dlgBG, std::string text, int iTag, unsigned int btnIndex); override
private:
	void ShowDialog(std::string title, std::string content);
	void OnClickOk();
private:
	NDUILayer	*m_menuLayer;
	NDUIDefaultTableLayer  *m_tableLayer;
	NDUIOkCancleButton *m_btnOk, *m_btnCancel;
	NDSection *m_curSection;
	unsigned int m_curCellIndex;
	NDTimer *m_timer;
	unsigned int m_timeCallCount;
};

#endif // _SERVER_LIST_SCENE_H
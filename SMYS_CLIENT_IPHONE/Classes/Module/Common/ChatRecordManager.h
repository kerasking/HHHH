//
//  ChatRecordManager.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 聊天记录查看功能实现
 外部只需要调用ChatRecordManager的以下几个方法，便可实现所有的管理功能
 ChatRecordManager::DefaultManager()->Show();	//显示聊天记录界面
 ChatRecordManager::DefaultManager()->Close();	//关闭聊天记录界面
 ChatRecordManager::DefaultManager()->Hide();	//隐藏聊天记录界面
 //往聊天记录界面里插入一条记录
 //其实此方法外部也无须调用，因为在调用Chat的AddMessage(ChatType type, const char* msg)方法时
 //方法内部已经处理了往聊天记录界面插入一条数据了
 ChatRecordManager::DefaultManager()->AddMessage(ChatType type, const char* msg);	
 */

#ifndef __ChatRecordManager_H
#define __ChatRecordManager_H

#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDPicture.h"
#include "NDUITableLayer.h"
#include "NDDataSource.h"
#include "Chat.h"
#include "NDUICustomView.h"
#include "GameItemBag.h"
#include <vector>
#include <deque>
#include "NDScene.h"
#include "HyperLinkLabel.h"

using namespace NDEngine;

//单条记录控件
class ChatRecord : public NDUINode
{
	DECLARE_CLASS(ChatRecord)
	ChatRecord();
	~ChatRecord();
public:
	void SetTextFontColor(ccColor4B color);
	void SetTitle(const char* title);
	void SetText(const char* text);
	std::string GetText();
	string GetTitle();
	string GetSpeaker();
	ChatRecord* Copy();
	void SetChatType(ChatType type);
	ChatType GetChatType();
	void Initialization(); override;
	void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
	void draw(); override
	CGRect GetTitleRect();
	bool OnClick(CGPoint touchPoint);
private:
	void ReCreateLabelText();
private:
	HyperLinkLabel *m_lblTitle;
	NDUIText* m_lblText;
	std::string m_text;
	ChatType m_chatType;
};

//记录集合控件，记录表
class ChatTable : public NDUITableLayer
{
	DECLARE_CLASS(ChatTable)
	ChatTable();
	~ChatTable();
public:
	void AddOneRecord(ChatRecord* record, bool bRefresh = true);
	void SetMaxRecordCount(unsigned int count){ m_maxRecordCount = count; } 
private:
	void RemoveOneRecord();
	void RemoveAllRecord();
	
public:
	void Initialization(); override	
private:
	unsigned int m_maxRecordCount;
	//std::deque<ChatRecord*> m_records;
	unsigned int m_recordCount;
	NDDataSource* m_dataSource;
	NDSection* m_section;
	
	void SetDataSource(NDDataSource* dataSource){} hide	
};

typedef enum {
	TitleButtonTagAll = 1001,
	TitleButtonTagWorld = 1002,
	TitleButtonTagSection = 1003,
	TitleButtonTagQueue = 1004,
	TitleButtonTagArmy = 1005,
	TitleButtonTagSecret = 1006,
	TitleButtonTagSystem = 1007
}TitleButtonTag;

typedef struct {
	NDPicture* RedPicture;
	NDPicture* GoldPicture;
	TitleButtonTag Tag;
	ChatTable* table;
}TitleButtonInfo;

//对于所有的记录进行管理
class ChatRecordManager : public NDScene, 
	public NDUIButtonDelegate, 
//	public NDUITableLayerDelegate,  ///< 临时性注释 郭浩
	public NDUIDialogDelegate,
	public ITimerCallback
{
	DECLARE_CLASS(ChatRecordManager)
	ChatRecordManager();
	~ChatRecordManager();
public:
	static ChatRecordManager* DefaultManager();
	void Show();
	void Close();
	void Hide();
	
	void AddMessage(ChatType type, const char* msg);
	
	void SetErrorMessage(const char* msg);
public:
	void Initialization(); override
	void OnButtonClick(NDUIButton* button);override
	//bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnTimer(OBJID tag); override
private:
	NDUIButton *m_btnAll, *m_btnWorld, *m_btnSection, *m_btnQueue, *m_btnArmy, *m_btnSecret, *m_btnSystem;
	NDPicture *m_picAllGold, *m_picWorldGold, *m_picSectionGold, *m_picQueueGold, *m_picArmyGold, *m_picSecretGold, *m_picSystemGold;
	NDPicture *m_picAllRed, *m_picWorldRed, *m_picSectionRed, *m_picQueueRed, *m_picArmyRed, *m_picSecretRed, *m_picSystemRed;	
	ChatTable *m_tbAll, *m_tbWorld, *m_tbSection, *m_tbQueue, *m_tbArmy, *m_tbSecret, *m_tbSystem;
	NDUIButton* m_btnChat;
	NDPicture* m_picChatGold, *m_picChatRed;
	std::vector<TitleButtonInfo*> m_titleButtonInfos;
	ChatType m_curChatType;
	NDUIMenuLayer *m_menuLayer;
	NDUILabel* m_errMsg;
	NDTimer* m_timer;
private:
	void CreateMenuLayer();
	void CreatePictures();
	void ClearPictures();
	
	void CreateButtons();
	
	void CreateErrorMessage();
	
	void CreateTables();
	void ActiveTable(ChatTable* table);
	
	void CreateChatTypeBackground();
	
	void CreateTitleButtonInfos();
	void ActiveTitleButton(NDUIButton* btn);
	bool ButtonIsTitleButton(NDUIButton* btn);
	TitleButtonInfo* GetTitleButtonInfoWithTag(int tag);
	void ClearTitleButtonInfos();	
};

#endif

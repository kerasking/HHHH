/*
 *  NewChatScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-9-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __NEW_CHAT_SCNEN_H__
#define __NEW_CHAT_SCNEN_H__

#include "NDScene.h"
#include "NDUIButton.h"
#include "ChatRecordManager.h"
#include "NDCommonControl.h"
#include "GameNewItemBag.h"

using namespace NDEngine;

enum ShowType {
	eShowFace,
	eShowItem,
};

typedef struct _TagSendItemInfo
{
	OBJID			idItem;
	int				iColor;
	std::string		strName;
	_TagSendItemInfo() 
	{
		idItem			= 0; 
		iColor			= 0;
	}
	_TagSendItemInfo(OBJID idItem, int iColor, std::string strName) 
	{
		this->idItem	= idItem; 
		this->iColor	= iColor;
		this->strName	= strName;
	}
}SendItemInfo;

class ChatFaceOrItemLayer :
public NDUILayer,
public NDUIButtonDelegate,
public NewGameItemBagDelegate
{
	DECLARE_CLASS(ChatFaceOrItemLayer)
public:
	ChatFaceOrItemLayer();
	~ChatFaceOrItemLayer();
	
	bool TouchEnd(NDTouch* touch);
	
	void Show(ShowType eType);
	
	void draw();
	
	void OnButtonClick(NDUIButton* button);
	
	bool OnClickCell(NewGameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused);
	
	bool		GetSendItemInfo(int index, SendItemInfo& ret);
	void		ClearSendItemInfo();
	int			GetNextItemIndex();
	bool		AddChatItem(OBJID idItem);
	bool		AppendItem(OBJID idItem, int color, std::string name);
	
private:
	bool m_bMoving;
	ShowType m_eCurType;
	NDUILayer* m_layerFace;
	NewGameItemBag* m_bag;
	std::map<int, SendItemInfo> m_mapSendItemInfo;
};

class NewChatScene
: public NDScene,
public NDUIButtonDelegate,
//public NDUITableLayerDelegate, ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
public NDUIDialogDelegate,
public CommonTextInputDelegate
{
	DECLARE_CLASS(NewChatScene)
public:
	static NewChatScene* DefaultManager();
	
	NewChatScene();
	~NewChatScene();
	
	void Show();
	
	void OnButtonClick(NDUIButton* button);
	
	void AddMessage(ChatType type, const char* msg, const char* speaker);
	
	bool AppendItem(OBJID idItem);
	
	bool AppendItem(OBJID idObject, int color, std::string name);
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	bool IsFilterBySpeaker(const char* speaker);
	
	bool SetTextContent(CommonTextInput* input, const char* text);
	
	void AppendTalkText(const char* text);
	
	string FilterMessage(const string& msg);
	
private:
	NDUILayer* m_layerBg;
	ChatTable *m_tbAll, *m_tbSection, *m_tbQueue, *m_tbArmy, *m_tbSecret, *m_tbSystem;
	NDUIButton* m_btnCurChannel;
	int m_eCurTalkChannel;
	bool m_bInputChatName;
	bool m_bRefresh;
	CommonTextInput* m_input;
	
	ChatFaceOrItemLayer* m_layerChooseFaceOrItem;
	
private:
	void ActiveTable(ChatTable* table);
	void ActiveChannel(NDUIButton* btnChannel);
	void ShowSelectChannel();
	void FilterByName(const string& name);
	void RemoveRecordBySpeaker(ChatTable* table, const string& speaker);
	void SwitchRefresh();
	void InputTalk();
	void SendTalk();
};

#endif
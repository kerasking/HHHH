/*
 *  GameUIRequest.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
 
 #ifndef _GAME_UI_REQUEST_H_
 #define _GAME_UI_REQUEST_H_
 
 #include "GameUIPlayerList.h"
 #include "NDUIMenuLayer.h"
 #include "NDUIButton.h"
 #include "NDUITableLayer.h"
 #include "NDUIDialog.h"
 
 using namespace NDEngine;
 
 struct RequsetInfo : public SocialInfo
 {
	 enum { REQUEST_LIST_MAX = 20, };
	 enum  
	 {
		 ACTION_BEGIN = 0,
		 ACTION_FRIEND = ACTION_BEGIN,
		 ACTION_TEAM,
		 ACTION_BIWU,
		 ACTION_BAISHI,
		 ACTION_SOUTU,
		 // new
		 ACTION_SYNDICATE,
		 ACTION_NEWMAIL,
		 ACTION_NEWCHAT,
		 ACTION_END,
	 };
	 int iID;
	 static std::string	text[ACTION_END];
	 int iAction;
	 
	 void set(int iID, std::string name, int action)
	 {
		 iRoleID = iID;
		 this->name = name;
		 setMAction(action);
		 this->nTime = ::time(NULL);
	 }
	 int getMAction(){ return iAction; }
	 void setMAction(int action){ 
			if( action < ACTION_BEGIN || action >= ACTION_END )
			 info = NDCommonCString("RequestErr"); 
			else
			 info = text[action]; 
			iAction = action;
		 }
		 
	bool isValid()
	{
		return !( iAction < ACTION_BEGIN || iAction >= ACTION_END );
	}
 };
	 
 ///////////////////////////////////
 
class GameUIRequest : 
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(GameUIRequest)
public:
	GameUIRequest();
	~GameUIRequest();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void draw(); override
	void UpdateMainUI();
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	bool checkTeamAndSend(int senderID, int action);
	
private:
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlMain;
	NDUIDialog *m_dlgDeal;
};

#pragma mark 新的请求列表

class NDRequestCell : public NDUINode
{
	DECLARE_CLASS(NDRequestCell)
	
	NDRequestCell();
	
	~NDRequestCell();
	
public:
	void Initialization(); override
	
	void Change(RequsetInfo* requestInfo);

	RequsetInfo* GetRequest();
	
	void draw(); override
	
	static NDPicture* GetPicture(int iRequestType);
	
	CGRect GetOkScreenRect();
	
	CGRect GetCancelScreenRect();

private:
	void reset();

private:
	NDPicture	*m_picBg, *m_picQuestType, *m_picOk, *m_picCancel;
	
	RequsetInfo *m_request;
	
	NDUILabel	*m_lbKey, *m_lbValue;
};

class NewGameUIRequest : 
public NDUILayer,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(NewGameUIRequest)
	
	static void refreshQuestList();
	
private:
	static NewGameUIRequest* s_instance;
public:
	NewGameUIRequest();
	~NewGameUIRequest();
	void Initialization(); override
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void DealRequest(RequsetInfo& info, int operate ); // 0 同意, 1 拒绝, 2清除
	void refresh();
	void clearRequest();
private:
	bool checkTeamAndSend(int senderID, int action);
	
private:
	NDUITableLayer *m_tlMain;
};
 
 
 #endif // _GAME_UI_REQUEST_H_



/*
 *  UserStateUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __USER_STATE_UI_LAYER_H__
#define __USER_STATE_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"

using namespace NDEngine;

typedef struct _UserState {
	_UserState() {
		idState = 0;
		nData = 0;
		endTime = 0;
		iconIndex = 0;
	}
	
	string stateName;
	string iconName;
	string shortTip;
	string descript;
	
	int idState;
	int nData;
	int endTime;
	int iconIndex;
}UserState;

typedef map<int, UserState*> MAP_USER_STATE;

//typedef map<int, SocialElement*> MAP_USER_STATE;
typedef MAP_USER_STATE::iterator MAP_USER_STATE_IT;

class UserStateUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate
//public NDUITableLayerDelegate ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
{
	DECLARE_CLASS(UserStateUILayer)
public:
	static void processMsgUserState(NDTransData& data);
	static void processMsgUserStateChg(NDTransData& data);
	static void reset();
	static UserState* getUserStateByID(int idState);
	//static string getStateNameByID(int idState);
	//static string getStateDetail(SocialElement& state);
	//static string getStateShowStr(SocialElement& state);
	static void chgUserAttr(UserState& state, bool bSet);
	static void delUserStateByID(int idState);
	static void delUserStealth();
	static MAP_USER_STATE& getAllUserState();
	
private:
	static UserStateUILayer* s_instance;
	static MAP_USER_STATE s_mapUserState;
	
public:
	UserStateUILayer();
	~UserStateUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	void Initialization();
	
private:
	NDUITableLayer* m_tlUserState;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	
private:
	void refreshMainList();
};

#endif
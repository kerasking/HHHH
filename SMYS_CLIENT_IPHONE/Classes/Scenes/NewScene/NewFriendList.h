/*
 *  NewFriendList.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_FRIEND_LIST_H_
#define _NEW_FRIEND_LIST_H_

#include "define.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDUICustomView.h"
#include "FriendElement.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class FriendInfo : 
public NDUILayer,
public NDUIButtonDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(FriendInfo)
	
	FriendInfo();
	
	~FriendInfo();
	
public:
	
	void Initialization(CGPoint pos); override
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnCustomViewConfirm(NDUICustomView* customView); override

	void ChangeFriend(SocialElement* se);
	
	void refreshSocialData();
	
	SocialElement* GetFriendEle() { return m_socialEle; }
	
private:
	void showCustomeView();
	
	void sendDeleteFriend();
	
private:	
	SocialFigure *m_figure;
	
	SocialEleInfo *m_info;
	
	std::vector<NDUIButton*> m_vOpBtn;
	
	SocialElement* m_socialEle;
};

class NewGoodFriendUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(NewGoodFriendUILayer)
public:
	static void refreshScroll();
	static void processSocialData(/*SocialData& data*/);
	static void processSeeEquip(int targetId, int lookface);
	static void processUserPos(NDTransData& data);
	static map_social_data s_mapFriendData;
	static NewGoodFriendUILayer* s_instance;
public:
	NewGoodFriendUILayer();
	~NewGoodFriendUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void Initialization();
	void SetVisible(bool visible); override
	void ShowEquipInfo(bool show, int lookface=0, int targetId=0);
private:
	NDUITableLayer* m_tlMain;
	FriendInfo* m_infoFriend;
	SocialPlayerEquip* m_infoEquip;
	
	// 传送位置
	int m_idDestMap;
	int m_destX;
	int m_destY;
private:
	void refreshMainList();
	void showCustomeView();
	void refreshSocialData();
};


#endif // _NEW_FRIEND_LIST_H_
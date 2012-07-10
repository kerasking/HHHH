/*
 *  GameUIPlayerList.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_PLAYER_LIST_H__
#define _GAME_UI_PLAYER_LIST_H__

#include "NDUILayer.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUISpecialLayer.h"

using namespace NDEngine;
////////////////////////////////////////////////
struct SocialInfo
{
	enum { STATE_OFFLINE = 0, STATE_ONLINE = 1, STATE_SELF_FOCUS = 2, };
	
	int iRoleID;
	int iState;
	std::string name;
	std::string info;
	int nTime;
};

////////////////////////////////////////////////
class NDUIPlayerInfo : public NDUILayer
{
#define focuscolor (ccc4(255,218,36,255))
#define defocuscolor (ccc4(227,229,218,255)) 	
	DECLARE_CLASS(NDUIPlayerInfo)
public:
	enum 
	{ 
		ePlayerNameDisX = 10, 
		ePlayerNameInfoDisX = 260, 
		eFontSize = 15,
	};

	NDUIPlayerInfo();
	~NDUIPlayerInfo();
	void Initialization(); override
	void draw(); override
	void SetPlayerName(std::string text);
	void SetPlayerNameColor(ccColor4B color);
	void SetPlayerInfo(std::string text);
	void SetPlayerInfoColor(ccColor4B color);
	
private:
	NDUILabel *m_lbName, *m_lbInfo;
	NDUICircleRect *m_crBG;
};

////////////////////////////////////////////////

////////////////////////////////////////////////
class GameUIPlayerList : 
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(GameUIPlayerList)
public:
	GameUIPlayerList();
	~GameUIPlayerList();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void draw(); override
	void refresh(bool bUpGUI = true);
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	void UpdateMainUI();
	
	int GetPageNum();
	
private:
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlMain, *m_tlOperate;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	NDUITopLayerEx *m_topLayerEx;
	std::vector<SocialInfo> m_vecSocialInfo;
	int m_iCurPage;
};

#endif // _GAME_UI_PLAYER_LIST_H__
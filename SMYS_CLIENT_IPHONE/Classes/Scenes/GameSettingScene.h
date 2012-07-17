/*
 *  GameSettingScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-2-16.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __GAME_SETTING_SCENE_H__
#define __GAME_SETTING_SCENE_H__

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDDataPersist.h"
#include "NDUIOptionButton.h"
#include "..\..\..\VERSION1.0\ClientEngine\UI\inc\NDUILayer.h"

using namespace NDEngine;

class GameSettingScene : public NDScene, public NDUIButtonDelegate, public NDUIOptionButtonDelegate
{
	DECLARE_CLASS(GameSettingScene)
	GameSettingScene();
	~GameSettingScene();
public:
	static GameSettingScene* Scene();
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	virtual void OnOptionChange(NDUIOptionButton* option); override
	
private:
	NDUIMenuLayer *m_menuLayer;
	//NDDataPersist m_gameSettingData;
	//NDUIOptionButton* m_headPicOpt;		// 头像显示
	//NDUIOptionButton* m_miniMapOpt;	    // 缩略地图
	NDUIOptionButton* m_showObjLevel;	// 显示品质
	NDUIOptionButton* m_worldChatOpt;	// 世界聊天
	NDUIOptionButton* m_synChatOpt;	    // 军团聊天
	NDUIOptionButton* m_teamChatOpt;	// 队伍聊天
	NDUIOptionButton* m_areaChatOpt;	// 区域聊天
	NDUIOptionButton* m_directKeyOpt;   // 方向键

	NDUILayer* m_page1, /**m_page2*/;
	
	//NDUIButton		*m_btnPrevPage, *m_btnNextPage;	
	//NDUILayer		*m_pageControl;
	//unsigned int m_curPage;
	//NDUILabel		*m_lbPage;
};

#endif
/*
 *  SMGameScene.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _SM_GAME_SCENE_H_ZJH_
#define _SM_GAME_SCENE_H_ZJH_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDMapLayerLogic.h"

//class NDMiniMap; ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
class CSMGameScene:
	public NDScene,
	public NDUIButtonDelegate
{
	DECLARE_CLASS(CSMGameScene)
	
	CSMGameScene();
	~CSMGameScene();
	
	static CSMGameScene* Scene();
	
public:

	void Initialization(int mapID); override
	void ShowMiniMap(bool bShow);
	CCSize GetSize();
	
	cocos2d::CCArray* GetSwitchs();
private:
	//NDMiniMap *m_miniMap; ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	NDMapLayerLogic* m_pkMapLayerLogic;
	
public:
	void OnButtonClick(NDUIButton* button); override
};

#endif // _SM_GAME_SCENE_H_ZJH_
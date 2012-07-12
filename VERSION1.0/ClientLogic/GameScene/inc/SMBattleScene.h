//
//  SMBattleScene.h
//  SMYS
//
//  Created by cl on 12-2-29.
//  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _SM_BATTLE_SCENE_H_ZJH_
#define _SM_BATTLE_SCENE_H_ZJH_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDMapLayerLogic.h"
//#include	<Foundation/Foundation.h>

using namespace NDEngine;

class NDMiniMap;
class CSMBattleScene :
public NDScene
{
	DECLARE_CLASS(CSMBattleScene)
	
	CSMBattleScene();
	~CSMBattleScene();
	
	static CSMBattleScene* Scene();
	
public:
	void Initialization(int mapID); override
	void ShowMiniMap(bool bShow){}
	CGSize GetSize();
	
	cocos2d::CCArray* GetSwitchs();
private:
	NDMapLayerLogic *m_mapLayer;
};

#endif

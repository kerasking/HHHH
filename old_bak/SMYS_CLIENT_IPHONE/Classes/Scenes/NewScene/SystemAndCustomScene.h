/*
 *  SystemAndCustomScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SYSTEM_AND_CUSTOM_SCENE_H_
#define _SYSTEM_AND_CUSTOM_SCENE_H_

#include "NDCommonScene.h"

using namespace NDEngine;

class SystemAndCustomScene :
public NDCommonSocialScene,
public HFuncTabDelegate
{
	DECLARE_CLASS(SystemAndCustomScene)
	
	SystemAndCustomScene();
	
	~SystemAndCustomScene();
	
public:
	
	static SystemAndCustomScene* Scene(bool onlySetting=false);
	
	void Initialization(bool onlySetting=false); override
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	void OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex); override
	void InitSystem(NDUIClientLayer* client);
	void InitCustom(NDUIClientLayer* client);
	
	NDHFuncTab *m_tabSystem, *m_tabCustom;
	
};

#endif // _SYSTEM_AND_CUSTOM_SCENE_H_
/*
 *  ActivityListScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ACTIVITY_LIST_SCENE_H_
#define _ACTIVITY_LIST_SCENE_H_

#include "NDScene.h"
#include "NDUIMemo.h"
#include "VipStoreScene.h"

using namespace NDEngine;

class ActivityListScene:
public NDScene,
public StoreTabLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(ActivityListScene)
public:
	ActivityListScene();
	~ActivityListScene();
	
	static ActivityListScene * Scene();
	static void AddData(std::string str);
	static void ClearData();
	
	void Initialization(); override
	void OnFocusTablayer(StoreTabLayer* tablayer); override
	void OnButtonClick(NDUIButton* button); override
	void UpdateGui();
private:
	NDUIMenuLayer		*m_menulayerBG;
	enum { eMaxTab = 7, };
	StoreTabLayer		*m_tabLayer[eMaxTab];
	NDUIPolygon			*m_nodePolygon;
	
	int					m_iCurTabFocus;
	
	NDUILabel			*m_lbTitle;
	NDUIMemo			*m_memoContent;
	
	static std::string tab_titles[eMaxTab];
	static std::string s_data[eMaxTab];
	static unsigned int s_index;
};


#endif // _ACTIVITY_LIST_SCENE_H_
/*
 *  DramaTransitionScene.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-20.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _DRAMA_TRANSITION_SCENE_H_ZJH_
#define _DRAMA_TRANSITION_SCENE_H_ZJH_

#include "NDScene.h"
#include "NDUILabel.h"
#include "NDUILayer.h"
#include "NDTimer.h"

using namespace NDEngine;

class DramaTransitionScene :
public NDScene,
public ITimerCallback
{
	DECLARE_CLASS(DramaTransitionScene)
	
	DramaTransitionScene();
	~DramaTransitionScene();
	
public:
	void Init();
	
	void SetText(std::string text, int nFontSize, int nFontColor);
	
	void SetCloseTime(float fTime);
	
private:
	NDTimer					m_timer;
	NDUILabel*				m_lbText;
	NDUILayer*				m_layerBack;
	
public:
	virtual void OnTimer(OBJID tag);
	
	DECLARE_AUTOLINK(DramaTransitionScene)
	INTERFACE_AUTOLINK(DramaTransitionScene)
};

#endif // _DRAMA_TRANSITION_SCENE_H_ZJH_
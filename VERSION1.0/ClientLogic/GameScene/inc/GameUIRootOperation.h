/*
 *  GameUIRootOperation.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_ROOT_OPERATION_H_
#define _GAME_UI_ROOT_OPERATION_H_

#include "NDUILayer.h"
#include "NDUIButton.h"
#include <vector>

using namespace NDEngine;
using namespace std;

/**
 * 功能栏卷动状态: 0 = 展开, 1 = 收起中, 2 = 展开中, 3 = 收起
 */
enum  
{
	e_ZhangKai = 0,
	e_ShouQiIng,
	e_ZhangKaiIng,
	e_ShouQi,
};

class NDUIHControlLayer;	
class NDUIHControlLayerDelegate
{
public:
	virtual void OnInStatus(NDUIHControlLayer* hcontrollayer, int status){}
};

class NDUIHControlLayer : public NDUILayer
{
public:
	DECLARE_CLASS(NDUIHControlLayer)
	NDUIHControlLayer();
	~NDUIHControlLayer();
	
	void Initialization(); override
	void draw(); override
	void SetRectInit(CCRect rect);
	void SetControls(int controls);
	void ChangeStatus();
	int GetStatus();
private:
	int m_iStatus;
	int m_iVarLen;
	CCRect m_rectInit;
};

///////////////////////////////////////////////////////////
class NDUIHControlContainer;
class NDUIHControlContainerDelegate
{
public:
	virtual bool OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer){ return false; }
};

class NDUIHControlContainer : public NDUILayer, public NDUIButtonDelegate, public NDUIHControlLayerDelegate
{
public:
	DECLARE_CLASS(NDUIHControlContainer)
	NDUIHControlContainer();
	~NDUIHControlContainer();
	
	void Initialization(); override
	bool TouchBegin(NDTouch* touch); override
	void OnButtonClick(NDUIButton* button); override
	void OnInStatus(NDUIHControlLayer* hcontrollayer, int status); override
	void SetRectInit(CCRect rect);
	void SetUINodeInterval(int interval);
	void AddUINode(NDUINode* uinode);
	void SetButtonName(const char* name);
	void SetBGImage(const char* name);
	void InitFinish();
	void ZhangKai();
	
	bool IsZhangKai();
private:
	void Adjust();
private:
	vector<NDUINode*>	m_vecUINodes;
	NDPicture			*m_picBasic;
	NDUIButton			*m_btnBasic;
	NDUIHControlLayer	*m_hclBasic;
	int					m_iUINodeInterval;
	CCRect				m_InitRect;
	CCRect				m_ButtonRect;
};

///////////////////////////////////////////////////////////
class NDUIAniLayer;
class NDUIAniLayerDelegate
{
public:
	virtual void OnClickNDUIAniLayer(NDUIAniLayer* anilayer){}
};

#include "NDSprite.h"
class NDUIAniLayer : public NDUILayer
{
public:
	DECLARE_CLASS(NDUIAniLayer)
	NDUIAniLayer();
	~NDUIAniLayer();
	void Initialization(const char * aniname); override
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	void TouchCancelled(NDTouch* touch); override
	void draw(); override
	
	void SetAniRectXYSize(CCRect rect, CCSize size);
	void SetCurrentAnimation(int aniID, int faceright=false);
private:
	NDSprite *sprite;
	CCRect	 m_rectSprite;
	bool	 m_bTouchBegin;
	NDPicture *m_picBg;
};

#endif // _GAME_UI_ROOT_OPERATION_H_
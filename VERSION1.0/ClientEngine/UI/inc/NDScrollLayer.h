/*
 *  NDScrollLayer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-15.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _ND_SCROLL_LAYER_H_
#define _ND_SCROLL_LAYER_H_

#include "NDUILayer.h"
#include "NDTextNode.h"
#include "NDUIButton.h"

using namespace NDEngine;

class NDScrollLayer;

class NDScrollLayerDelegate
{
public:
	virtual void OnClickNDScrollLayer(NDScrollLayer* layer) {}
};

class NDScrollLayer :
public NDUILayer,
public NDUILayerDelegate
{
	DECLARE_CLASS(NDScrollLayer)
	
	NDScrollLayer();
	
	~NDScrollLayer();
	
public:
	void Initialization(); override
	void draw(); override
	//void SetScrollHorizontal(bool bHorizontal);
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
protected:
	virtual bool refresh(float distance) { return true;}
	virtual bool refreshHorizonal(float distance) { return true; }

protected:
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override
	
private:
	typedef struct tagMoveInfo
	{
		CGPoint pos;
		clock_t  time;
		tagMoveInfo()
		{
			pos		= CGPointZero;
			time	= 0.0f; 
		}
		tagMoveInfo(CGPoint pos, clock_t time)
		{
			this->pos		= pos;
			this->time		= time; 
		}
	}MoveInfo;
	
	void ResetMoveData();
	void ResetMove();
	void SwitchStateTo(int nToState);
	void PushMove(MoveInfo& move, bool bHorizontal);
	void SetMoveV();
	void SetHMoveSpeed();
	void SetVMoveSpeed();
	float GetHMoveDistance();
	float GetVMoveDistance();
	clock_t ClockTimeMinus(clock_t sec, clock_t fir);
private:
	enum { MAX_MOVES = 3, };
	enum { 
		STATE_BEGIN = 100, 
		STATE_STOP = STATE_BEGIN, 
		STATE_FIRST, 
		STATE_SECOND, 
		STATE_THREE, 
		STATE_END, };
	MoveInfo	m_HMoves[MAX_MOVES];
	MoveInfo	m_VMoves[MAX_MOVES];
	unsigned int m_uiHCurMoveIndex;
	unsigned int m_uiHFirstMoveIndex;
	unsigned int m_uiVCurMoveIndex;
	unsigned int m_uiVFirstMoveIndex;
	clock_t m_clockHt0, m_clockVt0;
	float m_fHv0, m_fVv0;
	float m_fHOldS, m_fVOldS;
	bool m_bHEmpty, m_bVEmpty, m_bUp;
	int m_nState;
};

class NDUILabelScrollLayer :
public NDScrollLayer
{
	DECLARE_CLASS(NDUILabelScrollLayer)
	
	NDUILabelScrollLayer();
	
	~NDUILabelScrollLayer();
	
public:
	void Initialization(); override
	
	//NDUILabel* GetScrollLabel();

	bool refresh(float distance); override
	
	void SetFrameRect(CGRect rect); override
	
	void draw(); override
	
	void SetTextLeftInterval(unsigned int interval);
	
	void SetTextRightInterval(unsigned int interval);
	
	void SetText(const char* text, unsigned int leftInterval=0, unsigned int rightInterval=0, unsigned int height=0, cocos2d::ccColor4B fontColor = ccc4(58, 58, 58, 255));
	
private:
	
	NDUIText *m_lbText;
	
	unsigned int m_uiTextHeight;
	unsigned int m_uiViewHeight;
};

#pragma mark 
// ???
class NDUIContainerScrollLayer :
public NDScrollLayer,
public NDNodeDelegate
{
	DECLARE_CLASS(NDUIContainerScrollLayer)
	
	NDUIContainerScrollLayer();
	
	~NDUIContainerScrollLayer();
	
public:
	void Initialization(); override
	
	bool refresh(float distance); override
	
	// ??????(?????????¦Ë)
	void refreshContainer(float defaultChangeRange=0.0f);
	
	void VisibleScroll(bool visible);
	
	float GetScrollBarWidth();
	
	void ScrollNodeToTop(NDUINode* node);
	
	bool SetContent(const char *text, cocos2d::ccColor4B color=ccc4(0, 0, 0, 255), unsigned int fontsize=12);
private:
	float m_fMaxChange, m_fMinY;
	float m_fChange;
	bool m_bVisibleScroll;
	NDUIImage *m_imageScroll;
	
	DECLARE_AUTOLINK(NDUIContainerScrollLayer)
	INTERFACE_AUTOLINK(NDUIContainerScrollLayer)
};

// ???
class NDUIContainerHScrollLayer :
public NDScrollLayer
{
	DECLARE_CLASS(NDUIContainerHScrollLayer)
	
	NDUIContainerHScrollLayer();
	
	~NDUIContainerHScrollLayer();
	
public:
	void Initialization(); override
	
	bool refreshHorizonal(float distance); override
	
	// ??????(?????????¦Ë)
	void refreshContainer();
	
private:
	float m_fMaxChange;
	float m_fChange;
};

#endif // _ND_SCROLL_LAYER_H_
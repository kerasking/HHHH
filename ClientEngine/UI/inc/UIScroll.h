/*
 *  UIScroll.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_SCROLL_H_ZJH_
#define _UI_SCROLL_H_ZJH_

#include "UIMovableLayer.h"

using namespace NDEngine;

typedef enum 
{
	UIScrollStyleBegin = 0,
	UIScrollStyleHorzontal = UIScrollStyleBegin,
	UIScrollStyleVerical,
	UIScrollStyleEnd,
}UIScrollStyle;

typedef struct tagUIMoveInfo
{
	CGPoint pos;
	double  time;
	tagUIMoveInfo()
	{
		pos		= CGPointZero;
		time	= 0.0f; 
	}
	tagUIMoveInfo(CGPoint pos, double time)
	{
		this->pos		= pos;
		this->time		= time; 
	}
}UIMoveInfo;

class CUIScroll :
public CUIMovableLayer
{
	DECLARE_CLASS(CUIScroll)
	
	CUIScroll();
	~CUIScroll();
	
public:
	void Initialization(bool bAccerate=false); override
	void SetScrollStyle(int style);
	bool IsCanAccerate();
	bool IsInAccceratState();
	void StopAccerate();
	UIScrollStyle GetScrollStyle();
	void SetContainer(NDUILayer* layer);
protected:
	void draw(); override
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	bool CanHorizontalMove(float& hDistance); override
	bool CanVerticalMove(float& vDistance); override
	bool OnLayerMoveOfDistance(NDUILayer* uiLayer, float hDistance, float vDistance); override
private:
	enum { MAX_MOVES = 12, };
	enum { 
		STATE_BEGIN = 100, 
		STATE_STOP = STATE_BEGIN, 
		STATE_FIRST, 
		STATE_SECOND, 
		STATE_THREE, 
		STATE_END, };
	
	UIMoveInfo				m_moveInfos[MAX_MOVES];
	unsigned int			m_uiCurMoveIndex;
	unsigned int			m_uiFirstMoveIndex;
	double					m_clockT0;
	float					m_fV0;
	float					m_fOldS;
	bool					m_bMoveInfoEmpty;
	bool					m_bUp;
	bool					m_bAccerate;
	int						m_nState;
	UIScrollStyle			m_style;
	CAutoLink<NDUILayer>	m_linkContainer;
private:
	void ResetMoveData();
	void ResetMove();
	void SwitchStateTo(int nToState);
	void PushMove(UIMoveInfo& move);
	void SetMoveParam();
	void SetMoveSpeed();
	float GetMoveDistance();
	double ClockTimeMinus(double sec, double fir);
	void OnMove();
};

#endif // _UI_SCROLL_H_ZJH_
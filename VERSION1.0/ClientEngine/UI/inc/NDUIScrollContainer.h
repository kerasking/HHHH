/*
 *  UIScrollContainer.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _UI_SCROLL_CONTAINER_H_ZJH_
#define _UI_SCROLL_CONTAINER_H_ZJH_

#include "NDUIScroll.h"

using namespace NDEngine;

class NDUIScrollContainer : public NDUILayer
{
	DECLARE_CLASS(NDUIScrollContainer)
	
	NDUIScrollContainer();
	~NDUIScrollContainer();
	
public:
	void Initialization(); override
	void SetLeftReserveDistance(unsigned int distance);
	void SetRightReserveDistance(unsigned int distance);
	void SetTopReserveDistance(unsigned int distance);
	void SetBottomReserveDistance(unsigned int distance);
	void ScrollToTop();
	void ScrollToBottom();
	
	void EnableScrollBar(bool bEnable);
protected:
	unsigned int				m_uiLeftDistance;
	unsigned int				m_uiRightDistance;
	unsigned int				m_uiTopDistance;
	unsigned int				m_uiBottomDistance;
	
	NDPicture*					m_picScroll;
    NDPicture*					m_picScrollBg;
	bool						m_bOpenScrollBar;
protected:
	bool TouchBegin(NDTouch* touch); override
	void draw(); override
	// CommonProtol
	bool CanHorizontalMove(NDObject* object, float& hDistance); override
	bool CanVerticalMove(NDObject* object, float& vDistance); override
	virtual void DrawScrollBar();
};

#endif // _UI_SCROLL_CONTAINER_H_ZJH_
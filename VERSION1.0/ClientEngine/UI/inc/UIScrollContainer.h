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

#include "UIScroll.h"

using namespace NDEngine;

class CUIScrollContainer :
public NDUILayer
{
	DECLARE_CLASS(CUIScrollContainer)
	
	CUIScrollContainer();
	~CUIScrollContainer();
	
public:
	void Initialization(); override
	void SetLeftReserveDistance(unsigned int distance);
	void SetRightReserveDistance(unsigned int distance);
	void SetTopReserveDistance(unsigned int distance);
	void SetBottomReserveDistance(unsigned int distance);
	
protected:
	unsigned int				m_uiLeftDistance;
	unsigned int				m_uiRightDistance;
	unsigned int				m_uiTopDistance;
	unsigned int				m_uiBottomDistance;
	
protected:
	bool TouchBegin(NDTouch* touch); override
	void draw(); override
	// CommonProtol
	bool CanHorizontalMove(NDObject* object, float& hDistance); override
	bool CanVerticalMove(NDObject* object, float& vDistance); override
};

#endif // _UI_SCROLL_CONTAINER_H_ZJH_
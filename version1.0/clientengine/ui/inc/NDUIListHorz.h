/*--------------------------------------------------------------------------
*  NDUIListHorz.h
*
*	水平列表框
*
*  Created by zhangwq on 2013.01.29
*  Copyright 2012 (网龙)DeNA. All rights reserved.
*--------------------------------------------------------------------------
*/

#pragma once

#include "NDUIScrollViewContainer.h"

using namespace NDEngine;


//水平列表框
class NDUIListHorz : public NDUIScrollViewContainer
{
	DECLARE_CLASS(NDUIListHorz)

public:
	NDUIListHorz();
	~NDUIListHorz();

public:
	void Initialization()
	{
		NDUIScrollViewContainer::Initialization();
	}

	void SetFrameRect(CCRect rect)
	{
		NDUIScrollViewContainer::SetFrameRect(rect);
	}

	void draw();

private:
	void debugDraw();

public:
	//list控件中添加view
	void AddView(CUIScrollView* view)
	{
		NDUIScrollViewContainer::AddView(view);
	}

	//删除索引为uiIndex的view
	void RemoveView(unsigned int uiIndex)
	{
		NDUIScrollViewContainer::RemoveView(uiIndex);
	}

	//删除id为uiViewId的view
	void RemoveViewById(unsigned int uiViewId)
	{
		NDUIScrollViewContainer::RemoveViewById(uiViewId);
	}

	//删除所有的view
	void RemoveAllView()
	{
		NDUIScrollViewContainer::RemoveAllView();
	}

	CUIScrollView* GetView(unsigned int uiIndex)
	{
		return NDUIScrollViewContainer::GetView(uiIndex);
	}

	CUIScrollView* GetViewById(unsigned int uiViewId)
	{
		return NDUIScrollViewContainer::GetViewById(uiViewId);
	}
};
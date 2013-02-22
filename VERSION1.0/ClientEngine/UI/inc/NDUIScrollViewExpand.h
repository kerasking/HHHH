/*
 *  NDUIScrollViewExpand.h
 *  DeNA
 *
 *  Created by chh on 2012-07-21.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_SCROLL_VIEW_EXPAND_CHH_
#define _UI_SCROLL_VIEW_EXPAND_CHH_

#include "NDUINode.h"

using namespace NDEngine;

class UIScrollViewExpand : public NDUINode
{
public:
    DECLARE_CLASS(UIScrollViewExpand)
    UIScrollViewExpand();
    ~UIScrollViewExpand();
    
public:
    void Initialization(); override
    
    int GetViewId() {return m_nViewId;};
    void SetViewId(int nViewId) {m_nViewId = nViewId;};
    
protected:
    int m_nViewId;
};

#endif // _UI_SCROLL_VIEW_ZJH_
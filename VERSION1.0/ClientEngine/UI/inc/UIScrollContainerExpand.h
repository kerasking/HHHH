/*
 *  UIScrollContainerExpand.h
 *  DeNA
 *
 *  Created by chh on 2012-07-21.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_SCROLL_CONTAINER_EXPAND_CHH_
#define _UI_SCROLL_CONTAINER_EXPAND_CHH_

#include "NDUILayer.h"
#include "UIScrollViewExpand.h"

using namespace NDEngine;

class CUIScrollContainerExpand : public NDUILayer
{
public:
    DECLARE_CLASS(CUIScrollContainerExpand)
    CUIScrollContainerExpand();
    ~CUIScrollContainerExpand();
 public:
    void Initialization(); override
    
    void AddView(UIScrollViewExpand* pScrollViewCurrent);
    void SetSizeView(CCSize size);
    
    UIScrollViewExpand* GetViewById(unsigned int nViewId);
    UIScrollViewExpand* GetViewByIndex(unsigned int nViewIndex);
    
    unsigned int    GetCurrentIndex();
    unsigned int    GetPreIndex();
    unsigned int	GetViewCount();
    
    void SetCurrentIndex(unsigned int unIndex);
    
    
protected:
    CCSize                  m_sizeView;
    
    float                   m_fTranValue;
    float                   m_fScrollDistance;
    float					m_fScrollToCenterSpeed;
    
    int                        m_unPreIndex;
    int                        m_unBeginIndex;
    std::vector<UIScrollViewExpand*>    m_pScrollViewUINodes;
    UIScrollViewExpand*                 m_pScrollViewCurrent;
private:
    bool bIsMoveing;
protected:
    void MovePosition(int nDistance);
    void AdjustToCenter();
    void CalculateSlideDistance();
    void CalculatePosition();
    void SetViewScale();
    void ResetCurrViewBg();
    
public:
    
    virtual bool TouchMoved(NDTouch* touch);
    
public:
    virtual void draw(); override
};

#endif // _UI_SCROLL_VIEW_ZJH_
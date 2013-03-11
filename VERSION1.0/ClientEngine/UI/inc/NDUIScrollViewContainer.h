/*
 *  NDUIScrollViewContainer.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#pragma once

#include "NDUIScroll.h"
#include "NDUIScrollContainer.h"

using namespace NDEngine;

class CUIScrollView : public CUIScroll //don't scroll, only listen
{
	DECLARE_CLASS(CUIScrollView)
	
	CUIScrollView();
	~CUIScrollView();
	
public:
	void Initialization(bool bAccerate=false); override
	void SetScrollViewer(NDCommonProtocol* viewer);
	void SetViewId(unsigned int uiId);
	unsigned int GetViewId();
	
private:
	unsigned int				m_uiViewId;
	
protected:
	virtual bool OnHorizontalMove(float fDistance);
	virtual bool OnVerticalMove(float fDistance);
	virtual void OnMoveStop();
	DECLARE_AUTOLINK(CUIScrollView)
	INTERFACE_AUTOLINK(CUIScrollView)
};

/////////////////////////////////////////////////////////
class ContainerClientLayer;
class NDUIScrollViewContainer : public NDUIScrollContainer
{
	DECLARE_CLASS(NDUIScrollViewContainer)
	
	NDUIScrollViewContainer();
	~NDUIScrollViewContainer();
	
public:
	virtual void Initialization();

    //设置list控件的样式 水平或者垂直
	void SetStyle(int style);

    //获取list控件的样式 水平或者垂直 
	UIScrollStyle GetScrollStyle();
	
	void SetCenterAdjust(bool bSet);
	bool IsCenterAdjust();
	
    //获取list控件 view个数
	int	GetViewCount();
    
    //设置每个view的大小
	void SetViewSize(CCSize size);
	void SetBottomSpeedBar(bool bBar);

    //获取每个view的大小 
	CCSize GetViewSize();
    
    //list控件中添加view
	virtual void AddView(CUIScrollView* view);
    
    //删除索引为uiIndex的view
    virtual void RemoveView(unsigned int uiIndex);
    
    //删除id为uiViewId的view
    virtual void RemoveViewById(unsigned int uiViewId);
    
	//virtual void ReplaceView(unsigned int uiIndex, CUIScrollView* view);
	//virtual void ReplaceViewById(unsigned int uiViewId, CUIScrollView* view);

    //删除所有的view
	virtual void RemoveAllView();
	//virtual void InsertView(unsigned int uiIndex, CUIScrollView* view);
	virtual void ShowViewByIndex(unsigned int uiIndex);
	virtual void ShowViewById(unsigned int uiViewId);
	virtual void ScrollViewByIndex(unsigned int uiIndex);
	virtual void ScrollViewById(unsigned int uiViewId);
	
	virtual CUIScrollView* GetView(unsigned int uiIndex);
	virtual CUIScrollView* GetViewById(unsigned int uiViewId);
	virtual CUIScrollView* GetBeginView();
	virtual unsigned int GetBeginIndex();

    void EnableScrollBar(bool bEnable)
    {
        NDUIScrollContainer::EnableScrollBar(bEnable);
    }
	
private:
	float					m_fScrollDistance;
	float					m_fScrollToCenterSpeed;
	bool					m_bIsViewScrolling;
	UIScrollStyle			m_style;
	ContainerClientLayer*	m_pClientUINode; // all view's parent
	CCSize					m_sizeView;
	unsigned int			m_unBeginIndex;
	bool					m_bCenterAdjust;
	bool					m_bIsBottomSpeedBar;
	bool					m_bRecaclClientEventRect;
	CAutoLink<CUIScrollView> m_linkCurView;
	
private:
	bool CheckView(CUIScrollView* view);
	unsigned int ViewIndex(unsigned int uiViewId);
	
	void AdjustView();
	unsigned int WhichViewToScroll();
	void ScrollView(unsigned int uiIndex, bool bImmediatelySet=false);
	bool CaclViewCenter(CUIScrollView* view, float& fCenter, bool bJudeOver=false);
	CCRect GetClientRect(bool judgeOver);
	float GetContainerCenter();
	float GetViewLen();
	void StopAdjust();
	void MoveClient(float fMove);
	void refrehClientSize();
	bool IsViewScrolling();
	void EnableViewToScroll(bool bEnable);
	void SetBeginViewIndex(unsigned int nIndex);
	unsigned int GetPerPageViews();
	//bool IsViewCanCenter();
	void SetBeginIndex(unsigned int nIndex);
	
	float GetAdjustCenter();
	float GetOverDistance();
	
	void DrawScrollBar();
	
public:
	virtual void draw();
	virtual void SetFrameRect(CCRect rect);
	// CommonProtol
	void OnScrollViewMove(NDObject* object, float fVertical, float fHorizontal); override
	void OnScrollViewScrollMoveStop(NDObject* object); override
	bool CanHorizontalMove(NDObject* object, float& hDistance); override
	bool CanVerticalMove(NDObject* object, float& vDistance); override
	
protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override
};
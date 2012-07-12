/*
 *  UIScrollView.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _UI_SCROLL_VIEW_ZJH_
#define _UI_SCROLL_VIEW_ZJH_

#include "UIScroll.h"
#include "UIScrollContainer.h"

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
};

/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
class ContainerClientLayer;
class CUIScrollViewContainer : 
public CUIScrollContainer
{
	DECLARE_CLASS(CUIScrollViewContainer)
	
	CUIScrollViewContainer();
	~CUIScrollViewContainer();
	
public:
	void Initialization(); override
	void SetStyle(int style);
	UIScrollStyle GetScrollStyle();
	
	void SetCenterAdjust(bool bSet);
	bool IsCenterAdjust();
	
	int	GetViewCount();
	void SetViewSize(CGSize size);
	CGSize GetViewSize();
	void AddView(CUIScrollView* view);
	//void ReplaceView(unsigned int uiIndex, CUIScrollView* view);
	//void ReplaceViewById(unsigned int uiViewId, CUIScrollView* view);
	void RemoveView(unsigned int uiIndex);
	void RemoveViewById(unsigned int uiViewId);
	void RemoveAllView();
	//void InsertView(unsigned int uiIndex, CUIScrollView* view);
	void ShowViewByIndex(unsigned int uiIndex);
	void ShowViewById(unsigned int uiViewId);
	void ScrollViewByIndex(unsigned int uiIndex);
	void ScrollViewById(unsigned int uiViewId);
	CUIScrollView* GetView(unsigned int uiIndex);
	CUIScrollView* GetViewById(unsigned int uiViewId);
	CUIScrollView* GetBeginView();
	unsigned int GetBeginIndex();
	
	void EnableScrollBar(bool bEnable);
	
private:
	float					m_fScrollDistance;
	float					m_fScrollToCenterSpeed;
	bool					m_bIsViewScrolling;
	UIScrollStyle			m_style;
	ContainerClientLayer*	m_pClientUINode; // all view's parent
	CGSize					m_sizeView;
	unsigned int			m_unBeginIndex;
	bool					m_bCenterAdjust;
	bool					m_bRecaclClientEventRect;
	
	
	NDPicture*				m_picScroll;
	bool					m_bOpenScrollBar;
	
private:
	bool CheckView(CUIScrollView* view);
	unsigned int ViewIndex(unsigned int uiViewId);
	
	void AdjustView();
	unsigned int WhichViewToScroll();
	void ScrollView(unsigned int uiIndex, bool bImmediatelySet=false);
	bool CaclViewCenter(CUIScrollView* view, float& fCenter, bool bJudeOver=false);
	CGRect GetClientRect(bool judgeOver);
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
	void draw(); override
	void SetFrameRect(CGRect rect); override
	// CommonProtol
	void OnScrollViewMove(NDObject* object, float fVertical, float fHorizontal); override
	void OnScrollViewScrollMoveStop(NDObject* object); override
	bool CanHorizontalMove(NDObject* object, float& hDistance); override
	bool CanVerticalMove(NDObject* object, float& vDistance); override
	
private:
};

#endif // _UI_SCROLL_VIEW_ZJH_
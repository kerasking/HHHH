/*
 *  UIScrollView.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "UIScrollView.h"
#include "ScriptUI.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "ScriptGameLogic.h"

IMPLEMENT_CLASS(CUIScrollView, CUIScroll)

CUIScrollView::CUIScrollView()
{
	INIT_AUTOLINK(CUIScrollView);
	m_uiViewId					= 0;
}

CUIScrollView::~CUIScrollView()
{
}

void CUIScrollView::Initialization(bool bAccerate/*=false*/)
{
	CUIScroll::Initialization(bAccerate);
}

void CUIScrollView::SetScrollViewer(NDCommonProtocol* viewer)
{
	this->AddViewer(viewer);
}

void CUIScrollView::SetViewId(unsigned int uiId)
{
	m_uiViewId		= uiId;
}

unsigned int CUIScrollView::GetViewId()
{
	return m_uiViewId;
}

bool CUIScrollView::OnHorizontalMove(float fDistance)
{
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++) 
	{
		if ( !(*it).IsValid() )
		{
			continue;
		}
		
		(*it)->OnScrollViewMove(this, 0.0f, fDistance);
	}
	return false;
}

bool CUIScrollView::OnVerticalMove(float fDistance)
{ 
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++) 
	{
		if ( !(*it).IsValid() )
		{
			continue;
		}
		
		(*it)->OnScrollViewMove(this, fDistance, 0.0f);
	}
	return false; 
}

void CUIScrollView::OnMoveStop() 
{
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++) 
	{
		if ( !(*it).IsValid() )
		{
			continue;
		}
		
		(*it)->OnScrollViewScrollMoveStop(this);	
	}
}

/////////////////////////////////////////////////////////


class ContainerClientLayer : public NDUILayer
{
	DECLARE_CLASS(ContainerClientLayer)
	
	ContainerClientLayer()
	{
		m_rectEvent	= CGRectZero;
	}
	
public:
	void SetEventRect(CGRect rect)
	{
		m_rectEvent	= rect;
	}
	
private:
	CGRect m_rectEvent;
	
private:
	bool CanDealEvent(CGPoint pos)
	{
		return CGRectContainsPoint(m_rectEvent, pos);
	}
	
protected:
	virtual bool TouchBegin(NDTouch* touch)
	{
		if (CanDealEvent(touch->GetLocation()))
		{
			return NDUILayer::TouchBegin(touch);
		}
		return false;
	}
	virtual bool DispatchLongTouchClickEvent(CGPoint beginTouch, CGPoint endTouch)
	{
		if (CanDealEvent(endTouch))
		{
			return NDUILayer::DispatchLongTouchClickEvent(beginTouch, endTouch);
		}
		return false;
	}
	
	virtual bool DispatchLongTouchEvent(CGPoint beginTouch, bool touch)
	{
		if (CanDealEvent(beginTouch))
		{
			return NDUILayer::DispatchLongTouchEvent(beginTouch, touch);
		}
		return false;
	}
	
	virtual bool DispatchDragOutEvent(CGPoint beginTouch, CGPoint moveTouch, bool longTouch=false)
	{
		if (CanDealEvent(moveTouch))
		{
			return NDUILayer::DispatchDragOutEvent(beginTouch, moveTouch, longTouch);
		}
		return false;
	}
	
	virtual bool DispatchDragInEvent(NDUINode* dragOutNode, CGPoint beginTouch, CGPoint endTouch, bool longTouch, bool dealByDefault=false)
	{
		if (CanDealEvent(endTouch))
		{
			return NDUILayer::DispatchDragInEvent(dragOutNode, beginTouch, endTouch, longTouch, dealByDefault);
		}
		return false;
	}
};

IMPLEMENT_CLASS(ContainerClientLayer, NDUILayer)

/////////////////////////////////////////////////////////

IMPLEMENT_CLASS(CUIScrollViewContainer, CUIScrollContainer)

CUIScrollViewContainer::CUIScrollViewContainer()
{
	m_fScrollDistance				= 0.0f;
	m_fScrollToCenterSpeed			= 100.0f;
	m_bIsViewScrolling				= false;
	m_style							= UIScrollStyleHorzontal;
	m_pClientUINode					= NULL;
	m_sizeView						= CGSizeMake(0, 0);
	m_unBeginIndex					= 0;
	m_bCenterAdjust					= false;
	m_bRecaclClientEventRect		= false;
}

CUIScrollViewContainer::~CUIScrollViewContainer()
{
	SAFE_DELETE_NODE(m_pClientUINode);
}

void CUIScrollViewContainer::Initialization()
{
	CUIScrollContainer::Initialization();
	
	m_pClientUINode = new ContainerClientLayer;
	m_pClientUINode->Initialization();
	//m_pClientUINode->EnableEvent(false);
	this->AddChild(m_pClientUINode);
	
}

void CUIScrollViewContainer::SetStyle(int style)
{
	if (style < UIScrollStyleBegin || style >= UIScrollStyleEnd )
	{
		return;
	}
	m_style = (UIScrollStyle)style;
}

UIScrollStyle CUIScrollViewContainer::GetScrollStyle()
{
	return m_style;
}

void CUIScrollViewContainer::SetCenterAdjust(bool bSet)
{
	m_bCenterAdjust	= bSet;
}

bool CUIScrollViewContainer::IsCenterAdjust()
{
	return m_bCenterAdjust;
}

void  CUIScrollViewContainer::SetViewSize(CGSize size)
{
	m_sizeView	= size;
}

int	CUIScrollViewContainer::GetViewCount()
{
	if (!m_pClientUINode)
	{
		return 0;
	}
	return m_pClientUINode->GetChildren().size();
}

CGSize  CUIScrollViewContainer::GetViewSize()
{
	return m_sizeView;
}

void CUIScrollViewContainer::AddView(CUIScrollView* view)
{
	if (!CheckView(view))
	{
		return;
	}
	
	if (!m_pClientUINode)
	{
		return;
	}
	
	size_t childsize		= m_pClientUINode->GetChildren().size();	
	CGRect rect				= view->GetFrameRect();
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		rect.origin.x		= childsize * GetViewLen();
		rect.origin.y		= 0;
	}
	else
	{
		rect.origin.y		= childsize * GetViewLen();
		rect.origin.x		= 0;
	}
	rect.size				= m_sizeView;
	view->SetFrameRect(rect);
	view->SetScrollStyle(GetScrollStyle());
	view->SetMovableViewer(this);
	view->SetScrollViewer(this);
	view->SetContainer(this);
	m_pClientUINode->AddChild(view);
	
	refrehClientSize();
}

void CUIScrollViewContainer::RemoveView(unsigned int uiIndex)
{	
	if (!m_pClientUINode)
	{
		return;
	}
	
	size_t childsize					= m_pClientUINode->GetChildren().size();
	if (uiIndex >= childsize)
	{
		return;
	}
	
	unsigned int nBeginIndex	= 0;
	if (uiIndex >=  childsize - 1)
	{
		//最后一个view
		nBeginIndex = childsize <= 1 ? 0 : childsize - 2;
	}
	else
	{
		nBeginIndex	= uiIndex;
	}
	
	m_pClientUINode->RemoveChild(m_pClientUINode->GetChildren()[uiIndex], true);
	
	/*
	CGRect rect	= m_pClientUINode->GetFrameRect();
	
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		rect.origin.x		= nBeginIndex * GetViewLen() + GetViewLen() * 0.3;
		rect.origin.y		= 0;
		
		if (0 == m_pClientUINode->GetChildren().size())
		{
			rect.origin.x	= 0;
			m_pClientUINode->SetFrameRect(rect);
		}
	}
	else
	{
		rect.origin.y		= nBeginIndex * GetViewLen() + GetViewLen() * 0.3;
		rect.origin.x		= 0;
		
		if (0 == m_pClientUINode->GetChildren().size())
		{
			rect.origin.y	= 0;
			m_pClientUINode->SetFrameRect(rect);
		}
	}
	*/
	
	const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	childsize								= m_pClientUINode->GetChildren().size();
	
	if (uiIndex < childsize)
	{
		for (size_t i = uiIndex; i < childsize; i++) 
		{
			NDNode *child			= children[i];
			if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
			{
				continue;
			}
			CUIScrollView* view		= (CUIScrollView*)child;
			CGRect rect				= view->GetFrameRect();
			if (UIScrollStyleHorzontal == GetScrollStyle())
			{
				rect.origin.x		= i * GetViewLen();
			}
			else
			{
				rect.origin.y		= i * GetViewLen();
			}
			view->SetFrameRect(rect);
		}
	}
	
	refrehClientSize();
	
	if (0 != childsize)
	{
		this->ScrollView(nBeginIndex);
	}
}

void CUIScrollViewContainer::RemoveViewById(unsigned int uiViewId)
{	
	size_t findIndex = ViewIndex(uiViewId);
	
	if ((size_t)-1 == findIndex)
	{
		return;
	}
	
	RemoveView(findIndex);
}

void CUIScrollViewContainer::RemoveAllView()
{
	while (m_pClientUINode && m_pClientUINode->GetChildren().size() > size_t(0))
	{
		RemoveView(m_pClientUINode->GetChildren().size() - 1);
	}
	
	if (m_pClientUINode)
	{
		m_pClientUINode->SetFrameRect(CGRectZero);
	}
	EnableViewToScroll(false);
	m_fScrollDistance		= 0.0f;
}

void CUIScrollViewContainer::ShowViewByIndex(unsigned int uiIndex)
{
	CUIScrollView* view = GetView(uiIndex);
	if (!view)
	{
		return;
	}
	
	float fCenter = 0.0f;
	if (!CaclViewCenter(view, fCenter))
	{
		return;
	}
	
	if (!m_pClientUINode)
	{
		return;
	}
	
	StopAdjust();
	
	ScrollView(uiIndex, true);
}

void CUIScrollViewContainer::ShowViewById(unsigned int uiViewId)
{
	size_t findIndex = ViewIndex(uiViewId);
	if ((size_t)-1 != findIndex)
	{
		ShowViewByIndex(findIndex);
	}
}

void CUIScrollViewContainer::ScrollViewByIndex(unsigned int uiIndex)
{
	CUIScrollView* view = GetView(uiIndex);
	if (!view)
	{
		return;
	}
	if (view == m_linkCurView)
	{
		return;
	}
	
	float fCenter = 0.0f;
	if (!CaclViewCenter(view, fCenter))
	{
		return;
	}
	
	if (!m_pClientUINode)
	{
		return;
	}
	
	StopAdjust();
	
	ScrollView(uiIndex);
}

void CUIScrollViewContainer::ScrollViewById(unsigned int uiViewId)
{
	size_t findIndex = ViewIndex(uiViewId);
	if ((size_t)-1 != findIndex)
	{
		ScrollViewByIndex(findIndex);
	}
}

CUIScrollView* CUIScrollViewContainer::GetView(unsigned int uiIndex)
{
	if ((size_t)-1 == uiIndex)
	{
		return NULL;
	}
	
	if (!m_pClientUINode)
	{
		return NULL;
	}
	
	const std::vector<NDNode*>& children		= m_pClientUINode->GetChildren();
	size_t childsize							= children.size();
	
	if (uiIndex >= childsize)
	{
		return NULL;
	}
	
	NDNode *child			= children[uiIndex];
	if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return NULL;
	}
	
	return (CUIScrollView*)child;
}

CUIScrollView* CUIScrollViewContainer::GetViewById(unsigned int uiViewId)
{
	size_t findIndex = ViewIndex(uiViewId);
	return GetView(findIndex);
}

bool CUIScrollViewContainer::CheckView(CUIScrollView* view)
{
	if (!view)
	{
		return false;
	}
	return true;
}

unsigned int CUIScrollViewContainer::ViewIndex(unsigned int uiViewId)
{
	size_t findIndex					= -1;
	if (!m_pClientUINode)
	{
		return findIndex;
	}
	
	const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	size_t childsize						= children.size();
	
	for (size_t i = 0; i < childsize ; i++) 
	{
		NDNode *child			= children[i];
		if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
		{
			continue;
		}
		CUIScrollView* view		= (CUIScrollView*)child;
		
		if (view->GetViewId() == uiViewId)
		{
			findIndex			= i;
			break;
		}
	}
	
	return findIndex;
}

void CUIScrollViewContainer::AdjustView()
{
	StopAdjust();
	
	if (!m_pClientUINode)
	{
		return;
	}
	
	unsigned int uiFindInex		= this->WhichViewToScroll();
	if ((size_t)-1 == uiFindInex)
	{
		return;
	}
	
	this->ScrollView(uiFindInex);
}

unsigned int CUIScrollViewContainer::WhichViewToScroll()
{
	unsigned int uiIndexFind = -1;
	
	if (!m_pClientUINode)
	{
		return uiIndexFind;
	}
	
	float fCenter							= 0.0f;
//	if (IsViewCanCenter())
//	{
//		fCenter		= GetContainerCenter();
//	}
//	else
//	{
		fCenter		= GetAdjustCenter();
//	}
	
	const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	size_t size								= children.size();
	float fMin								= 1000.0f;
	
	for (size_t i = 0; i < size; i++) 
	{
		NDNode *child			= children[i];
		if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
		{
			continue;
		}
		
		CUIScrollView* view		= (CUIScrollView*)child;
		float viewCenter		= 0.0f;
		if (!CaclViewCenter(view, viewCenter, true))
		{
			continue;
		}
		
		float tmpViewCenter		= viewCenter - fCenter;
		if (tmpViewCenter < 0.0f)
		{
			tmpViewCenter		= -tmpViewCenter;
		}
		
		if (tmpViewCenter < fMin)
		{
			fMin				= tmpViewCenter;
			uiIndexFind			= i;	
		}
	}
	
	return uiIndexFind;
}

// cacl view center and container center dis; m_fScrollDistance = dis; m_bIsViewScrolling = true;
void CUIScrollViewContainer::ScrollView(unsigned int uiIndex, bool bImmediatelySet/*=false*/)
{
	if ( (size_t)-1 == uiIndex || !m_pClientUINode)
	{
		return;
	}
	
	const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	if (uiIndex >= children.size())
	{
		return;
	}
	
	NDNode *child			= children[uiIndex];
	if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return;
	}
	
	CUIScrollView* view		= (CUIScrollView*)child;
	float viewCenter		= 0.0f;
	if (!CaclViewCenter(view, viewCenter))
	{
		return;
	}
	
	float fCenter			= 0.0f;
//	bool bIsViewCanCenter	= IsViewCanCenter();
//	if (bIsViewCanCenter)
//	{
//		fCenter		= GetContainerCenter();
//	}
//	else
//	{
		fCenter		= GetAdjustCenter();
//	}
	
	float fDistance = fCenter - viewCenter;

	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		if (!CanHorizontalMove(view, fDistance))
		{
			SetBeginIndex(uiIndex);
			SetBeginViewIndex(uiIndex);
			return;
		}
	}
	else
	{
		if (!CanVerticalMove(view, fDistance))
		{
			SetBeginIndex(uiIndex);
			SetBeginViewIndex(uiIndex);
			return;
		}
	}

//	if (IsViewCanCenter())
//	{
//		m_unBeginIndex		= uiIndex - (GetPerPageViews() - 1) / 2; 
//	}
//	else
//	{
		//m_unBeginIndex		= uiIndex;
//	}
	
	SetBeginIndex(uiIndex);
	
	if (bImmediatelySet)
	{
		MoveClient(fDistance);
		
		SetBeginViewIndex(uiIndex);
	}
	else
	{
		m_fScrollDistance		= fDistance;
		
		EnableViewToScroll(true);
	}
	
	return;
}

bool CUIScrollViewContainer::CaclViewCenter(CUIScrollView* view, float& fCenter, bool bJudeOver/*=false*/)
{
	if (!view || !m_pClientUINode)
	{
		return false;
	}
	
	CGRect rectClient		= GetClientRect(bJudeOver);
	CGRect viewrect			= view->GetFrameRect();
	fCenter					= 0.0f;
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		fCenter				=	rectClient.origin.x + 
		viewrect.origin.x +
		viewrect.size.width / 2;
	}
	else
	{
		fCenter				=	rectClient.origin.y +
		viewrect.origin.y +
		viewrect.size.height / 2;
	}
	
	return true;
}

CGRect CUIScrollViewContainer::GetClientRect(bool judgeOver)
{
	if (!m_pClientUINode)
	{
		return CGRectZero;
	}
	
	CGRect rectClient	= m_pClientUINode->GetFrameRect();
	
	if (!judgeOver)
	{
		return rectClient;
	}
	
	if (IsCenterAdjust())
	{
		return rectClient;
	}
	
	CGRect selfRect		= this->GetFrameRect();
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		if (rectClient.origin.x > 0.0f)
		{
			rectClient.origin.x		= 0.0f;
		}
		else if (rectClient.origin.x + rectClient.size.width < selfRect.size.width)
		{
			rectClient.origin.x		= selfRect.size.width - rectClient.size.width;
		}
	}
	else
	{
		if (rectClient.origin.y > 0.0f)
		{
			rectClient.origin.y		= 0.0f;
		}
		else if (rectClient.origin.y + rectClient.size.height < selfRect.size.height)
		{
			rectClient.origin.y		= selfRect.size.height - rectClient.size.height;
		}
	}
	
	return rectClient;
}

float CUIScrollViewContainer::GetViewLen()
{
	float fres	= 0.0f;
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		//fres		= this->GetFrameRect().size.width;
		fres		= m_sizeView.width;
	}
	else
	{
		//fres		= this->GetFrameRect().size.height;
		fres		= m_sizeView.height;
	}
	
	return fres;
}

float CUIScrollViewContainer::GetContainerCenter()
{
	CGRect rect		= this->GetFrameRect();
	float fCenter	= 0.0f;
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		fCenter		= rect.size.width / 2;
	}
	else
	{
		fCenter		= rect.size.height / 2;
	}
	
	return fCenter;
}

void CUIScrollViewContainer::StopAdjust()
{
	EnableViewToScroll(false);
	//m_bIsViewScrolling		= false;
	m_fScrollDistance			= 0.0f;
}

void CUIScrollViewContainer::MoveClient(float fMove)
{
	if (!m_pClientUINode)
	{
		return;
	}
	
	CGRect rect	= m_pClientUINode->GetFrameRect();
	
	if (m_style == UIScrollStyleHorzontal)
	{
		rect.origin.x	+= fMove;
	}
	else 
	{
		rect.origin.y	+= fMove;
	}
	
	m_pClientUINode->SetFrameRect(rect);
}

void CUIScrollViewContainer::refrehClientSize()
{
	if (!m_pClientUINode)
	{
		return;
	}
	
	CGRect rect	= m_pClientUINode->GetFrameRect();
	
	if (m_style == UIScrollStyleHorzontal)
	{
		rect.size.width		= m_pClientUINode->GetChildren().size() *
		GetViewLen();
		rect.size.height	= this->GetFrameRect().size.height;
	}
	else 
	{
		rect.size.height	= m_pClientUINode->GetChildren().size() *
		GetViewLen();
		rect.size.width		= this->GetFrameRect().size.width;
	}
	
	if (0 == m_pClientUINode->GetChildren().size())
	{
		rect.origin			= ccp(0, 0);
	}
	
	m_pClientUINode->SetFrameRect(rect);
}

void CUIScrollViewContainer::draw() //  m_fScrollDistance += speed; only to zero;  clientnode speed;
{
	if (m_bRecaclClientEventRect)
	{
		if (m_pClientUINode)
		{
			m_pClientUINode->SetEventRect(this->GetScreenRect());
		}
		m_bRecaclClientEventRect	= false;
	}
	
	if (!this->IsVisibled())
	{
		return;
	}
	
	if (!IsViewScrolling() || !m_pClientUINode)
	{
		CUIScrollContainer::draw();
		DrawScrollBar();
		return;
	}
	
	float fMove = 0.0f;
	
	if	(m_fScrollDistance > 0.0f)
	{
		if (m_fScrollDistance < m_fScrollToCenterSpeed)
		{
			fMove					= m_fScrollDistance;
			m_fScrollDistance		= 0.0f;
			//m_bIsViewScrolling	= false;
			EnableViewToScroll(false);
			//SetBeginViewIndex(GetBeginIndex());
		}
		else
		{
			fMove					= m_fScrollToCenterSpeed;
			m_fScrollDistance		= m_fScrollDistance - fMove;
		}
	}
	else if	(m_fScrollDistance < 0.0f)
	{
		if (m_fScrollDistance > -m_fScrollToCenterSpeed)
		{
			fMove					= m_fScrollDistance;
			m_fScrollDistance		= 0.0f;
			//m_bIsViewScrolling	= false;
			EnableViewToScroll(false);
			//SetBeginViewIndex(GetBeginIndex());
		}
		else
		{
			fMove					= -m_fScrollToCenterSpeed;
			m_fScrollDistance		= m_fScrollDistance - fMove;
		}
	}
	else
	{
		EnableViewToScroll(false);
		//SetBeginViewIndex(GetBeginIndex());
		//m_bIsViewScrolling	= false;
	}
	
	MoveClient(fMove);
	
	CUIScrollContainer::draw();
	
	DrawScrollBar();
	
	if (!IsViewScrolling())
	{
		SetBeginViewIndex(GetBeginIndex());
	}
}

void CUIScrollViewContainer::SetFrameRect(CGRect rect)
{
	CUIScrollContainer::SetFrameRect(rect);
	
	m_bRecaclClientEventRect	= true;
}

// clientnode  can move.if can then, move clientnode. m_bIsViewScrolling = false;
void CUIScrollViewContainer::OnScrollViewMove(NDObject* object, float fVertical, float fHorizontal)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return;
	}
	
	if (!m_pClientUINode)
	{
		return;
	}
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		MoveClient(fHorizontal);
	}
	else
	{
		MoveClient(fVertical);
	}
	
	EnableViewToScroll(false);
	//m_bIsViewScrolling	= false;
	m_fScrollDistance		= 0.0f;
	
	return;
}

// when call back, just call AdjustView
void CUIScrollViewContainer::OnScrollViewScrollMoveStop(NDObject* object)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
	{
		return;
	}
	
	if (m_pClientUINode)
	{
		const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
		size_t size								= children.size();
		for (size_t i = 0; i < size; i++) 
		{
			NDNode *child			= children[i];
			if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
			{
				continue;
			}
			
			CUIScrollView* view		= (CUIScrollView*)child;
			view->StopAccerate();
		}
	}
	
    ScriptMgrObj.excuteLuaFunc("PlayEffectSound", "Music",15);
    
	AdjustView();
}

bool CUIScrollViewContainer::CanHorizontalMove(NDObject* object, float& hDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	if (!layer || !m_pClientUINode)
	{
		return false;
	}
	
	CGRect rectself = this->GetFrameRect();
	CGRect rectmove = m_pClientUINode->GetFrameRect();
	
	CGFloat fOver	= GetOverDistance();
	
	if (hDistance > 0.0f)
	{ // 向右
		if ( (rectself.size.width - m_uiRightDistance + fOver) <
			(rectmove.origin.x + hDistance) )
		{
			return false;
		}
	}
	else if (hDistance < 0.0f)
	{ // 向左
		if ( (m_uiLeftDistance - fOver) >
			(rectmove.origin.x + rectmove.size.width + hDistance))
		{
			if (rectmove.origin.x + hDistance > -0.01f)
			{
				return true;
			}
			
			return false;
		}
	}
	else
	{
		return false;
	}
	
	return true;
}

bool CUIScrollViewContainer::CanVerticalMove(NDObject* object, float& vDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	if (!layer || !m_pClientUINode)
	{
		return false;
	}
	
	CGRect rectself = this->GetFrameRect();
	CGRect rectmove = m_pClientUINode->GetFrameRect();
	
	CGFloat fOver	= GetOverDistance();

	
	if (vDistance > 0.0f)
	{ // 向下
		if ( (rectself.size.height - m_uiBottomDistance + fOver) <
			(rectmove.origin.y + vDistance) )
		{
			return false;
		}
	}
	else if (vDistance < 0.0f)
	{ // 向上
		if ( (m_uiTopDistance - fOver) >
			(rectmove.origin.y + rectmove.size.height + vDistance))
		{
			if ((rectmove.origin.y + vDistance > -0.01f))
			{
				return true;
			}
			
			return false;
		}
	}
	else
	{
		return false;
	}
	
	return true;
}

bool CUIScrollViewContainer::IsViewScrolling()
{
	return m_bIsViewScrolling;
}

void CUIScrollViewContainer::EnableViewToScroll(bool bEnable)
{
	m_bIsViewScrolling	= bEnable;
}

void CUIScrollViewContainer::SetBeginViewIndex(unsigned int nIndex)
{
	CUIScrollView* view = GetView(nIndex);
	if (view && view != m_linkCurView)
	{
		m_linkCurView	= view->QueryLink();
		OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_BEGIN, nIndex);
	}
	
	SetBeginIndex(nIndex);
}

void CUIScrollViewContainer::SetBeginIndex(unsigned int nIndex)
{
	m_unBeginIndex	= nIndex;
}

CUIScrollView* CUIScrollViewContainer::GetBeginView()
{
	return GetView(GetBeginIndex());
}

unsigned int CUIScrollViewContainer::GetBeginIndex()
{
	return m_unBeginIndex;
}

float CUIScrollViewContainer::GetAdjustCenter()
{
	if (!IsCenterAdjust())
	{
		return GetViewLen() / 2;
	}
	
	return this->GetContainerCenter();
}

float CUIScrollViewContainer::GetOverDistance()
{
	if (!m_pClientUINode)
	{
		return 0.0f;
	}
	
	CGRect rectself = this->GetFrameRect();
	CGRect rectmove = m_pClientUINode->GetFrameRect();
	
	CGFloat fOver	= 0.0f;
	if (IsCenterAdjust())
	{
		if (rectself.size.height / 2 < rectmove.size.height)
		{
			fOver		= rectself.size.height * 0.333;
		}
	}
	else 
	{
		fOver	= GetViewLen() * 0.333;
	}
	
	return fOver;
}


void CUIScrollViewContainer::DrawScrollBar()
{
	if (m_bOpenScrollBar && m_picScroll && m_pClientUINode && 
		GetScrollStyle() == UIScrollStyleVerical /*&& 
		m_pClientUINode->GetFrameRect().size.height > this->GetFrameRect().size.height*/)
	{
		bool bTouchDown							= false;
		if (m_pClientUINode)
		{
			const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
			size_t size								= children.size();
			for (size_t i = 0; i < size; i++) 
			{
				NDNode *child			= children[i];
				if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollView)))
				{
					continue;
				}
				CUIScrollView* view		= (CUIScrollView*)child;
				if (view->IsTouchDown())
				{
					bTouchDown			= true;
					break;
				}
			}
		}
		if (!bTouchDown)
		{
			//return;
		}
		CGRect rectself;/*	= m_scrRect;*/
		CGRect rectClient	= m_pClientUINode->GetFrameRect();
		CGRect rect			= CGRectZero;
		CGSize sizePic		= m_picScroll->GetSize();
		
        //** chh 2012-07-24 **//
        //rect.size.width		= sizePic.width * fScale;
		//rect.size.height	= rectself.size.height / rectClient.size.height * rectself.size.height;//sizePic.height * fScale;
		rect.size.width		= sizePic.width;
		rect.size.height	= sizePic.height;
        
        //rect.origin			= ccp(rectself.size.width - rect.size.width, -rectClient.origin.y / rectClient.size.height * rectself.size.height);
        
    
        
        
        /*
        rect.origin			= ccp(rectself.size.width - rect.size.width,
								  -rectClient.origin.y / (rectClient.size.height-rectself.size.height+rect.size.height) * rectself.size.height);
        */
        
        /*rect.origin			= ccp(rectself.size.width - rect.size.width,   (-rectClient.origin.y/(rectClient.size.height -rectself.size.height))*(rectself.size.height - rectself.origin.y -rect.size.height));*/
        
        
        if(GetViewCount()*GetViewSize().height<=rectself.size.height){
            return;
        }
        
        
        rect.origin			= ccp(rectself.size.width - rect.size.width,(-rectClient.origin.y/(rectClient.size.height-rectself.size.height))*(rectself.size.height-rect.size.height));
        
        
        if(rect.origin.y<0){
            rect.origin.y = 0;
        }
        
		rect.origin			= ccpAdd(rect.origin, this->GetScreenRect().origin);
        
        
        
        
		if (m_picScroll->GetSize().height != rect.size.height)
		{
            //** chh 2012-07-24 **//
			//delete	m_picScroll;
			//m_picScroll = NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("General/texture/texture5.png"),rect.size.width, rect.size.height);
		}
		
        
        if(m_picScrollBg) {
            CGSize sizePic		= m_picScrollBg->GetSize();
            CGRect rt;
            rt.origin.x = rect.origin.x;
            rt.origin.y = rectself.origin.y;
            rt.size.width = sizePic.width;
            rt.size.height = rectself.size.height;
            m_picScrollBg->DrawInRect(rt);
        }
        
        m_picScroll->DrawInRect(rect);
	}	
}
bool CUIScrollViewContainer::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_pClientUINode)
	{
		return false;
	}
	return true;
}

/*
unsigned int CUIScrollViewContainer::GetPerPageViews()
{
	unsigned int nViews		= 0;
	
	CGSize sizeContainer	= this->GetFrameRect().size;
	
	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		
		nViews	= (sizeContainer.width / m_sizeView.width + 0.5);
	}
	else
	{
		nViews	= (sizeContainer.height / m_sizeView.height + 0.5);
	}
	
	return nViews;
}

bool CUIScrollViewContainer::IsViewCanCenter()
{
	CGSize sizeContainer	= this->GetFrameRect().size;

	if (UIScrollStyleHorzontal == GetScrollStyle())
	{
		int nContainterW	= int(sizeContainer.width);
		int nViewW			= int(m_sizeView.width);
		if (0 == nViewW)
		{
			return false;
		}
		
		if (nViewW == nContainterW || (GetPerPageViews() % 2) != 0)
		{
			return true;
		}
	}
	else
	{
		int nContainterH	= int(sizeContainer.height);
		int nViewH			= int(m_sizeView.height);
		if (0 == nViewH)
		{
			return false;
		}
		
		if (nViewH == nContainterH || (GetPerPageViews() % 2) != 0)
		{
			return true;
		}
	}
	
	return false;
}
*/

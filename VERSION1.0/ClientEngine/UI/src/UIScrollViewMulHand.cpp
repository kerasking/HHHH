/*
 *  UIScrollView.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIScrollViewMulHand.h"
#include "ScriptUI.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "NDUtil.h"
#include "ScriptGameLogic.h"
#include "NDUINode.h"
#include "CCGeometry.h"
#include "platform.h"

IMPLEMENT_CLASS(CUIScrollViewM, CUIScroll)

CUIScrollViewM::CUIScrollViewM()
{
	INIT_AUTOLINK(CUIScrollViewM);
	m_uiViewId					= 0;
    m_bIsHVContainer            = true;
}

CUIScrollViewM::~CUIScrollViewM()
{
}

void CUIScrollViewM::Initialization(bool bAccerate/*=false*/)
{
	CUIScroll::Initialization(bAccerate);
}

void CUIScrollViewM::SetScrollViewer(NDCommonProtocol* viewer)
{
	this->AddViewer(viewer);
}

void CUIScrollViewM::SetViewId(unsigned int uiId)
{
	m_uiViewId		= uiId;
}

unsigned int CUIScrollViewM::GetViewId()
{
	return m_uiViewId;
}
void CUIScrollViewM::SetViewPos(CCPoint uiPos){
    m_uiPos = uiPos;
}
CCPoint CUIScrollViewM::GetViewPos(){
    return m_uiPos;
}

bool CUIScrollViewM::OnHorizontalMove(float fDistance)
{
    /*
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++) 
	{
		if ( !(*it).IsValid() )
		{
			continue;
		}
		printf("fDistance:[%f]",fDistance);
		(*it)->OnScrollViewMove(this, 0.0f, fDistance);
	}
    */
	return false;
}

bool CUIScrollViewM::OnVerticalMove(float fDistance)
{ 
    /*
	LIST_COMMON_VIEWER_IT it = m_listCommonViewer.begin();
	for (; it != m_listCommonViewer.end(); it++) 
	{
		if ( !(*it).IsValid() )
		{
			continue;
		}
		
		(*it)->OnScrollViewMove(this, fDistance, 0.0f);
	}
    */
	return false; 
}

void CUIScrollViewM::OnMoveStop() 
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

IMPLEMENT_CLASS(ContainerClientLayerM, NDUILayer)
void ContainerClientLayerM::Initialization()
{
	NDUILayer::Initialization();
    m_fScrollToCenterSpeed			= 100.0f;
    m_fScrollDistance = 0;
}

void ContainerClientLayerM::SetEventRect(CCRect rect)
{
    m_rectEvent	= rect;
}
void ContainerClientLayerM::SetFrameRect(CCRect rect){
    NDUILayer::SetFrameRect(rect);
    
    NDNode* parent = this->GetParent();
    if (parent && parent->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM))){
        
        CUIScrollViewContainerM *svcm = (CUIScrollViewContainerM*)parent;
        
        
        /*
        if(svcm->GetBeginIndex() != this->GetIndex()){
            this->SetTouchEnabled(false);
            
            std::vector<NDNode*> childs = svcm->GetChildren();
            for(int i=0;i<childs.size();i++){
                NDNode *nd = childs[i];
                if (nd && nd->IsKindOfClass(RUNTIME_CLASS(NDUILayer))){
                    NDUILayer *layer = (NDUILayer*)nd;
                    
                    
                    
                    layer->SetTouchEnabled(false);
                }
            }
            
        }else{
            this->SetTouchEnabled(true);
            
            std::vector<NDNode*> childs = svcm->GetChildren();
            for(int i=0;i<childs.size();i++){
                NDNode *nd = childs[i];
                if (nd && nd->IsKindOfClass(RUNTIME_CLASS(NDUILayer))){
                    NDUILayer *layer = (NDUILayer*)nd;
                    layer->SetTouchEnabled(true);
                }
            }
        }
        */
        
        rect.origin.y = svcm->GetFrameRect().origin.y;
        SetEventRect(rect);
    }
    
    /*
    CUIScrollViewContainerM *svm = (CUIScrollViewContainerM*)this->GetParent();
    SetEventRect(svm->GetFrameRect());*/
}

CCSize ContainerClientLayerM::GetViewSize(){
    return m_sizeView;
}
void ContainerClientLayerM::SetViewSize(CCSize size){
    m_sizeView = size;
}

void ContainerClientLayerM::AddView(CUIScrollViewM* view)
{
    CUIScrollViewContainerM *container = NULL;
    NDNode* parent = this->GetParent();
    if (!parent || !parent->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM))){
        return;
    }
    container = (CUIScrollViewContainerM*)parent;
    
	size_t childsize		= this->GetChildren().size();	
	CCRect rect;
    rect.origin.x = 0;
    rect.origin.y = m_sizeView.height * childsize;
    rect.size.width = m_sizeView.width;
    rect.size.height = m_sizeView.height;
    
	view->SetFrameRect(rect);
	view->SetScrollStyle(UIScrollStyleVerical);
	view->SetMovableViewer(container);
	view->SetScrollViewer(container);
	view->SetContainer(container);
	this->AddChild(view);
	
    
    m_pScrollViewUINodes.push_back(view);
	//refrehClientSize();
}
CUIScrollViewM* ContainerClientLayerM::GetView(unsigned int uiIndex){
    if(m_pScrollViewUINodes.size()>uiIndex){
        return m_pScrollViewUINodes[uiIndex];
    }
    return NULL;
}
int	ContainerClientLayerM::GetViewCount(){
    return this->m_pScrollViewUINodes.size();
}

void ContainerClientLayerM::MoveClient(float fMove){
    
    unsigned int size = m_pScrollViewUINodes.size();
    
    CCRect rect     =   this->GetFrameRect();
    rect.origin.y += fMove;
    
    float fOverDistanceMin = 0.333 * m_sizeView.height;
    
    float ftemp = size*m_sizeView.height - rect.size.height;
    if(ftemp <0) {
        ftemp = 0;
    }
    
    float fOverDistanceMax = -((0.333 * m_sizeView.height) + ftemp);
    
    if(rect.origin.y>fOverDistanceMin){
        rect.origin.y = fOverDistanceMin;
    }else if(rect.origin.y<fOverDistanceMax){
        rect.origin.y = fOverDistanceMax;
    }
    
    this->SetFrameRect(rect);
}
void ContainerClientLayerM::AdjustView(){
    if (!m_pScrollViewUINodes.size()) {
        return;
    }
    
    StopAdjust();
	
	int uiFindInex		= this->WhichViewToScroll();
	if (-1 == uiFindInex)
	{
		return;
	}
	
    printf("uiFindInex:[%d]",uiFindInex);
    
    
	this->ScrollView(uiFindInex);
}
void ContainerClientLayerM::ScrollView(unsigned int uiIndex, bool bImmediatelySet/*=false*/)
{   
    SetBeginIndex(uiIndex);
    //SetBeginViewIndex(uiIndex);
    
    float n1 = -(uiIndex*m_sizeView.height);
    float n2 = this->GetFrameRect().origin.y;
    
    float target_pos = n2 - n1;
    
    m_fScrollDistance = target_pos;
    /*
    m_fScrollDistance = (int)this->GetFrameRect().origin.y%(int)m_sizeView.height;
    if(m_fScrollDistance>m_sizeView.height/2){
        m_fScrollDistance = m_sizeView.height - m_fScrollDistance;
    }
    */
    
	return;
}
void ContainerClientLayerM::SetBeginIndex(unsigned int nIndex)
{
	m_unBeginIndex	= nIndex;
}
void ContainerClientLayerM::SetBeginViewIndex(unsigned int nIndex)
{
    /*
	CUIScrollViewM* view = GetView(nIndex);
	if (view && view != m_linkCurView)
	{
		m_linkCurView	= view->QueryLink();
		OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_BEGIN, nIndex);
	}
	*/
	SetBeginIndex(nIndex);
}
void ContainerClientLayerM::StopAdjust(){
    m_fScrollDistance			= 0.0f;
}
int ContainerClientLayerM::WhichViewToScroll()
{
    int uiIndexFind = -1;
	
    std::vector<NDNode*> nodes = this->GetChildren();   
    float fCenter = m_sizeView.height/2;
    
    uiIndexFind = fabs(this->GetFrameRect().origin.y/m_sizeView.height);
    int dis = abs((int)this->GetFrameRect().origin.y%(int)m_sizeView.height);
    
    if(dis>fCenter){
        uiIndexFind+=1;
    }
    return uiIndexFind;
}

bool ContainerClientLayerM::TouchMoved(NDTouch* touch){
    CCPoint prePos = touch->GetPreviousLocation();
    CCPoint curPos = touch->GetLocation();
    
    float horizontal = curPos.x - prePos.x;
    
    NDNode *parent = this->GetParent();
    if(!parent->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM))){
        return false;
    }
    
    CUIScrollViewContainerM *svc = (CUIScrollViewContainerM*)parent;
    svc->OnScrollViewMove(NULL, 0, horizontal);
    
    return true;
}
bool ContainerClientLayerM::TouchEnd(NDTouch* touch){
    
    NDNode *parent = this->GetParent();
    if(!parent->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM))){
        return false;
    }
    
    CUIScrollViewContainerM *svc = (CUIScrollViewContainerM*)parent;
    svc->OnScrollViewScrollMoveStop(NULL);
    
    return true;
}

void ContainerClientLayerM::draw() //  m_fScrollDistance += speed; only to zero;  clientnode speed;
{
    NDUILayer::draw();
    
    
    if(m_fScrollDistance==0){
        return;
    }
    
    //小于最小移动距离时
    if(fabs(m_fScrollDistance)<=m_fScrollToCenterSpeed){
        MoveClient(-m_fScrollDistance);
        m_fScrollDistance = 0;
        return;
    }
    
    //上下滑动
    if(m_fScrollDistance>0){
        MoveClient(-m_fScrollToCenterSpeed);
        m_fScrollDistance -= m_fScrollToCenterSpeed;
    }else{
        MoveClient(m_fScrollToCenterSpeed);
        m_fScrollDistance += m_fScrollToCenterSpeed;
    }
}


/////////////////////////////////////////////////////////

IMPLEMENT_CLASS(CUIScrollViewContainerM, NDUIScrollContainer)

CUIScrollViewContainerM::CUIScrollViewContainerM()
{
	m_fScrollDistance				= 0.0f;
	m_fScrollToCenterSpeed			= 100.0f;
	m_bIsViewScrolling				= false;
	m_style							= UIScrollStyleHorzontal;
	//m_pClientUINode					= NULL;
	m_sizeView						= CCSizeMake(0, 0);
	m_unBeginIndex					= 0;
	m_bCenterAdjust					= false;
	m_bRecaclClientEventRect		= false;
}

CUIScrollViewContainerM::~CUIScrollViewContainerM()
{
	//SAFE_DELETE_NODE(m_pClientUINode);
    
    unsigned int childsize					= m_pClientUINodes.size();
    for (size_t i = 0; i < childsize; i++) {
        SAFE_DELETE_NODE(m_pClientUINodes[i]);
    }
}

void CUIScrollViewContainerM::Initialization()
{
	NDUIScrollContainer::Initialization();
}

void CUIScrollViewContainerM::SetStyle(int style)
{
	if (style < UIScrollStyleBegin || style >= UIScrollStyleEnd )
	{
		return;
	}
	m_style = (UIScrollStyle)style;
}

UIScrollStyle CUIScrollViewContainerM::GetScrollStyle()
{
	return m_style;
}

void CUIScrollViewContainerM::SetCenterAdjust(bool bSet)
{
	m_bCenterAdjust	= bSet;
}

bool CUIScrollViewContainerM::IsCenterAdjust()
{
	return m_bCenterAdjust;
}

void  CUIScrollViewContainerM::SetViewSize(CCSize size)
{
	m_sizeView	= size;
}

int	CUIScrollViewContainerM::GetViewCount()
{
    return m_pClientUINodes.size();
    
    /*
	if (!m_pClientUINode)
	{
		return 0;
	}
	return m_pClientUINode->GetChildren().size();
     */
}

CCSize  CUIScrollViewContainerM::GetViewSize()
{
	return m_sizeView;
}
CCPoint CUIScrollViewContainerM::GetMaxRowAndCol(ContainerClientLayerM* m_pClientUINode){
    
    const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	unsigned int childsize					= m_pClientUINode->GetChildren().size();
    CCPoint pos = CCPointMake(0, 0);
    for (size_t i = 0; i < childsize; i++) 
    {
        NDNode *child			= children[i];
        if(child->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM))){
            CUIScrollViewM *view = (CUIScrollViewM*)child;
            CCPoint temp = view->GetViewPos();
            if(pos.x<temp.x){
                pos.x=temp.x;
            }
            if(pos.y<temp.y){
                pos.y=temp.y;
            }
        }
    }
    return pos;
    
}

void CUIScrollViewContainerM::AddView(ContainerClientLayerM* container)
{
	container->EnableEvent(false);
    
    //设置每组节点的大小
    unsigned int count = m_pClientUINodes.size();
    CCRect rect;
    rect.origin.x = m_sizeView.width*count;
    rect.origin.y = 0;
    rect.size = m_sizeView;
    if(count>0){//设置偏移
        rect.origin.x += m_pClientUINodes[0]->GetFrameRect().origin.x;
    }
	this->AddChild(container);
    container->SetIndex(count);
    rect.size = m_sizeView;
    container->SetFrameRect(rect);
    m_pClientUINodes.push_back(container);
    refrehClientSize();
    this->SetDShowYPos(false);
}

void CUIScrollViewContainerM::RemoveView(unsigned int uiIndex)
{	
    
    /*
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
	*/
     
     
     
     
	/*
	CCRect rect	= m_pClientUINode->GetFrameRect();
	
	
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
	
    
    
    
    
    
    
    /*
	const std::vector<NDNode*>& children	= m_pClientUINode->GetChildren();
	childsize								= m_pClientUINode->GetChildren().size();
	
	if (uiIndex < childsize)
	{
		for (size_t i = uiIndex; i < childsize; i++) 
		{
			NDNode *child			= children[i];
			if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM)))
			{
				continue;
			}
			CUIScrollViewM* view		= (CUIScrollViewM*)child;
			CCRect rect				= view->GetFrameRect();
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
     */
}

void CUIScrollViewContainerM::RemoveViewById(unsigned int uiViewId)
{	
	size_t findIndex = ViewIndex(uiViewId);
	
	if ((size_t)-1 == findIndex)
	{
		return;
	}
	
	RemoveView(findIndex);
}

void CUIScrollViewContainerM::RemoveAllView()
{
    for(int i=0;i<m_pClientUINodes.size();i++){
        ContainerClientLayerM *layer = m_pClientUINodes[i];
        layer->RemoveFromParent(true);
    }
    m_pClientUINodes.clear();
    
    
    
    /*
	while (m_pClientUINode && m_pClientUINode->GetChildren().size() > size_t(0))
	{
		RemoveView(m_pClientUINode->GetChildren().size() - 1);
	}
	
	if (m_pClientUINode)
	{
		m_pClientUINode->SetFrameRect(CCRectZero);
	}
	EnableViewToScroll(false);
	m_fScrollDistance		= 0.0f;
     
     */
}

void CUIScrollViewContainerM::ShowViewByIndex(unsigned int uiIndex)
{
    SetBeginIndex(uiIndex);
    
    for ( int i = 0; i < m_pClientUINodes.size(); i++ ){
        ContainerClientLayerM *ccl = m_pClientUINodes[i];
        CCRect rect = ccl->GetFrameRect();
        int ind = i-((int)uiIndex);
        rect.origin.x = ind*m_sizeView.width;
        ccl->SetFrameRect(rect);
    }
    this->SetDShowYPos(true);
    /*
	CUIScrollViewM* view = GetView(uiIndex);
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
     */
}

void CUIScrollViewContainerM::ShowViewById(unsigned int uiViewId)
{
	size_t findIndex = ViewIndex(uiViewId);
	if ((size_t)-1 != findIndex)
	{
		ShowViewByIndex(findIndex);
	}
}

void CUIScrollViewContainerM::ScrollViewByIndex(unsigned int uiIndex)
{
    
    
    
    /*
	CUIScrollViewM* view = GetView(uiIndex);
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
     */
}

void CUIScrollViewContainerM::ScrollViewById(unsigned int uiViewId)
{
	size_t findIndex = ViewIndex(uiViewId);
	if ((size_t)-1 != findIndex)
	{
		ScrollViewByIndex(findIndex);
	}
}

ContainerClientLayerM* CUIScrollViewContainerM::GetView(unsigned int uiIndex) 
{
    if(uiIndex < this->m_pClientUINodes.size()){
        return m_pClientUINodes[uiIndex];
    }
    return NULL;
}

CUIScrollViewM* CUIScrollViewContainerM::GetViewById(unsigned int uiViewId)
{
    /*
	size_t findIndex = ViewIndex(uiViewId);
	return GetView(findIndex);
     */
    return NULL;
}

bool CUIScrollViewContainerM::CheckView(CUIScrollViewM* view)
{
	if (!view)
	{
		return false;
	}
	
//	if (view->GetScrollStyle() != m_style)
//	{
//		return false;
//	}
	
	return true;
}

unsigned int CUIScrollViewContainerM::ViewIndex(unsigned int uiViewId)
{
    /*
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
		if (!child || !child->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewM)))
		{
			continue;
		}
		CUIScrollViewM* view		= (CUIScrollViewM*)child;
		
		if (view->GetViewId() == uiViewId)
		{
			findIndex			= i;
			break;
		}
	}
	
     
	return findIndex;
     
     */
    return 0;
}

void CUIScrollViewContainerM::AdjustView()
{
	StopAdjust();
	
	int uiFindInex		= this->WhichViewToScroll();
	if (-1 == uiFindInex)
	{
		return;
	}
	
    printf("uiFindInex:[%d]",uiFindInex);
    
    
	this->ScrollView(uiFindInex);
}
void CUIScrollViewContainerM::SetDShowYPos(bool bIsAllShow){
    
    for (int i=0; i<m_pClientUINodes.size(); i++) {
        ContainerClientLayerM *cclm = m_pClientUINodes[i];
        
        if(bIsAllShow) {
            cclm->SetVisible(true);
        }else{
            if(m_unBeginIndex == i){
                cclm->SetVisible(true);
            }
            else
            {
                cclm->SetVisible(false);
            }
        }
    }
}

int CUIScrollViewContainerM::WhichViewToScroll()
{
    int uiIndexFind = -1;
	
	if (!m_pClientUINodes.size())
	{
		return uiIndexFind;
	}
    
    size_t size = m_pClientUINodes.size();
    float fCenter = m_sizeView.width/2;
    for (unsigned int i=0; i<size; i++) {
        ContainerClientLayerM *m_pClientUINode = m_pClientUINodes[i];
        if(fabs(m_pClientUINode->GetFrameRect().origin.x)<=fCenter){
            uiIndexFind = i;
            break;
        }
    }
    return uiIndexFind;
}

// cacl view center and container center dis; m_fScrollDistance = dis; m_bIsViewScrolling = true;
void CUIScrollViewContainerM::ScrollView(unsigned int uiIndex, bool bImmediatelySet/*=false*/)
{
    if (uiIndex>=m_pClientUINodes.size()) {
        return;
    }
    
    SetBeginIndex(uiIndex);
    //SetBeginViewIndex(uiIndex);
    
    if (!m_pClientUINodes.size())
	{
		return;
	}
    
    m_fScrollDistance = m_pClientUINodes[uiIndex]->GetFrameRect().origin.x;
    
	return;
}

bool CUIScrollViewContainerM::CaclViewCenter(CUIScrollViewM* view, float& fCenter, bool bJudeOver/*=false*/)
{
    /*
	if (!view || !m_pClientUINode)
	{
		return false;
	}
	
	CCRect rectClient		= GetClientRect(bJudeOver);
	CCRect viewrect			= view->GetFrameRect();
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
     */
    return false;
}

CCRect CUIScrollViewContainerM::GetClientRect(bool judgeOver)
{
    /*
	if (!m_pClientUINode)
	{
		return CCRectZero;
	}
	
	CCRect rectClient	= m_pClientUINode->GetFrameRect();
	
	if (!judgeOver)
	{
		return rectClient;
	}
	
	if (IsCenterAdjust())
	{
		return rectClient;
	}
	
	CCRect selfRect		= this->GetFrameRect();
	
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
     */
    return CCRect();
}

float CUIScrollViewContainerM::GetViewLen()
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

float CUIScrollViewContainerM::GetContainerCenter()
{
	CCRect rect		= this->GetFrameRect();
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

void CUIScrollViewContainerM::StopAdjust()
{
	EnableViewToScroll(false);
	//m_bIsViewScrolling		= false;
	m_fScrollDistance			= 0.0f;
}

void CUIScrollViewContainerM::MoveClient(float fMove)
{
    if (!m_pClientUINodes.size())
	{
		return;
	}
    this->SetDShowYPos(true);
    unsigned int childsize	= m_pClientUINodes.size();
    for (size_t i = 0; i < childsize; i++) 
	{
		ContainerClientLayerM *m_pClientUINode = m_pClientUINodes[i];
		CCRect rect     =   m_pClientUINode->GetFrameRect();
		rect.origin.x	+=  fMove;
		rect.origin.y   = 0;
 
		float fOverDistanceMin = 0.333 * m_sizeView.width + i*m_sizeView.width;
		float fOverDistanceMax = -(0.333 * m_sizeView.width + (childsize-i-1)*m_sizeView.width);

		if(rect.origin.x > fOverDistanceMin)
		{
			rect.origin.x = fOverDistanceMin;
		}
		else if(rect.origin.x<fOverDistanceMax)
		{
			rect.origin.x = fOverDistanceMax;
		}

		m_pClientUINode->SetFrameRect(rect);
    }
}    
    
void CUIScrollViewContainerM::refrehClientSize()
{
    /*
	if (!m_pClientUINode)
	{
		return;
	}
	
	CCRect rect	= m_pClientUINode->GetFrameRect();
	
    CCPoint pos = GetMaxRowAndCol();
    rect.size.width		= (pos.x+1) * m_sizeView.width;
    rect.size.height	= (pos.y+1) * m_sizeView.height;
    
	
	if (0 == m_pClientUINode->GetChildren().size())
	{
		rect.origin			= ccp(0, 0);
	}
	
	m_pClientUINode->SetFrameRect(rect);
     */
}

void CUIScrollViewContainerM::draw() //  m_fScrollDistance += speed; only to zero;  clientnode speed;
{
    NDUIScrollContainer::draw();
  
    this->DrawScrollBar(m_pClientUINodes[m_unBeginIndex]);
    
    if(m_fScrollDistance==0){
        return;
    }
    
    //小于最小移动距离时
    if(fabs(m_fScrollDistance)<=m_fScrollToCenterSpeed){
        MoveClient(-m_fScrollDistance);
        m_fScrollDistance = 0;
        this->SetDShowYPos(false);
        return;
    }
    
    //左右滑动
    if(m_fScrollDistance>0){
        MoveClient(-m_fScrollToCenterSpeed);
        m_fScrollDistance -= m_fScrollToCenterSpeed;
    }else{
        MoveClient(m_fScrollToCenterSpeed);
        m_fScrollDistance += m_fScrollToCenterSpeed;
    }
    
}

void CUIScrollViewContainerM::SetFrameRect(CCRect rect)
{
	NDUIScrollContainer::SetFrameRect(rect);
	
	m_bRecaclClientEventRect	= true;
}

// clientnode  can move.if can then, move clientnode. m_bIsViewScrolling = false;
void CUIScrollViewContainerM::OnScrollViewMove(NDObject* object, float fVertical, float fHorizontal)
{
	if (!m_pClientUINodes.size())
	{
		return;
	}
    
	if (fHorizontal!=0)
	{
		MoveClient(fHorizontal);
	}
	else if(fVertical!=0)
	{
        int uiIndex = this->WhichViewToScroll();
        ContainerClientLayerM *m_pClientUINode = m_pClientUINodes[uiIndex];
		m_pClientUINode->MoveClient(fVertical);
	}
	
	EnableViewToScroll(false);
	//m_bIsViewScrolling	= false;
	m_fScrollDistance		= 0.0f;
	
	return;
    
} 

// when call back, just call AdjustView
void CUIScrollViewContainerM::OnScrollViewScrollMoveStop(NDObject* object)
{
    //调整水平位置
	AdjustView();
    
    
    //调整垂直位置
    int uiIndex = this->WhichViewToScroll();
    ContainerClientLayerM *m_pClientUINode = m_pClientUINodes[uiIndex];
    m_pClientUINode->AdjustView();
    
}
//** 删除这两方法 **//
bool CUIScrollViewContainerM::CanHorizontalMove(NDObject* object, float& hDistance)
{
    return false;
}

bool CUIScrollViewContainerM::CanVerticalMove(NDObject* object, float& vDistance)
{
    return false;
}
//***************//

bool CUIScrollViewContainerM::IsViewScrolling()
{
	return m_bIsViewScrolling;
}

void CUIScrollViewContainerM::EnableViewToScroll(bool bEnable)
{
	m_bIsViewScrolling	= bEnable;
}

void CUIScrollViewContainerM::SetBeginViewIndex(unsigned int nIndex)
{
    /*
	CUIScrollViewM* view = GetView(nIndex);
	if (view && view != m_linkCurView)
	{
		m_linkCurView	= view->QueryLink();
		OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_BEGIN, nIndex);
	}
	
	SetBeginIndex(nIndex);
    */
}

void CUIScrollViewContainerM::SetBeginIndex(unsigned int nIndex)
{
    unsigned int size = this->m_pClientUINodes.size();
    if(nIndex <= size){
        m_unPreIndex = m_unBeginIndex;
        m_unBeginIndex	= nIndex;
        OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_BEGIN, nIndex);
    }
}

CUIScrollViewM* CUIScrollViewContainerM::GetBeginView()
{
	//return GetView(GetBeginIndex());
    return NULL;
}

unsigned int CUIScrollViewContainerM::GetBeginIndex()
{
	return m_unBeginIndex;
}

float CUIScrollViewContainerM::GetAdjustCenter()
{
	if (!IsCenterAdjust())
	{
		return GetViewLen() / 2;
	}
	
	return this->GetContainerCenter();
}

float CUIScrollViewContainerM::GetOverDistance()
{
    /*
	if (!m_pClientUINode)
	{
		return 0.0f;
	}
	
	CCRect rectself = this->GetFrameRect();
	CCRect rectmove = m_pClientUINode->GetFrameRect();
	
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
     */
    return 0;
    
}


void CUIScrollViewContainerM::DrawScrollBar(ContainerClientLayerM *layer)
{
    if (!(m_bOpenScrollBar && m_picScroll))
	{
		return;
	}
	
	if (0 == int(m_kChildrenList.size()))
	{
		return;
	}
	NDNode *pNode		= layer->GetView(0);
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
	{
		return;
	}
    
    CUIScroll* itemView	= (CUIScroll*)pNode;
    
    CCSize sizePic		= m_picScroll->GetSize();       //滚动条图片大小
    CCRect itemRect     = itemView->GetFrameRect();     //每一项的区域
    CCRect itemBoxRect  = layer->GetFrameRect();     //每一项的区域
    CCRect boxRext     = GetSrcRectCache(); //m_scrRect;         //框的区域
	
    
    
    
    int nViewHeight = m_pClientUINodes[m_unBeginIndex]->GetViewSize().height;
    int nCount = m_pClientUINodes[m_unBeginIndex]->GetChildren().size();
    //判断一页的大小
    if(nCount*nViewHeight<=boxRext.size.height){
        return;
    }
    
    
    CCRect rect			= CCRectZero;               //要显示滚动条的区域
    rect.size           = sizePic;
    
    float itemTotalHeight = layer->GetViewCount() * itemRect.size.height - itemBoxRect.size.height;
    
    rect.origin.x       = boxRext.origin.x + boxRext.size.width - sizePic.width;
    rect.origin.y       = boxRext.origin.y - (itemBoxRect.size.height-sizePic.height) * (itemBoxRect.origin.y/itemTotalHeight);
    
    
    if(rect.origin.y < boxRext.origin.y){
        rect.origin.y = boxRext.origin.y;
    }
    
    float tempNum = boxRext.origin.y - (itemBoxRect.size.height-sizePic.height)*(-1);
    if(rect.origin.y > tempNum){
        rect.origin.y = tempNum;
    }
    
    if(m_picScrollBg) {
        CCSize sizePic		= m_picScrollBg->GetSize();
        CCRect rt;
        rt.origin.x = rect.origin.x;
        rt.origin.y = boxRext.origin.y;
        rt.size.width = sizePic.width;
        rt.size.height = boxRext.size.height;
        m_picScrollBg->DrawInRect(rt);
    }
    
    m_picScroll->DrawInRect(rect);
}
bool CUIScrollViewContainerM::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
    /*
	if (pNode == m_pClientUINode)
	{
		return false;
	}*/
	return true;
     
}
bool CUIScrollViewContainerM::TouchMoved(NDTouch* touch){

    if(m_pClientUINodes.size()>0){
        m_pClientUINodes[0]->TouchMoved(touch);
    }
    return true;
}
bool CUIScrollViewContainerM::TouchEnd(NDTouch* touch){
    if(m_pClientUINodes.size()>0){
        m_pClientUINodes[0]->TouchEnd(touch);
    }
    return true;
}
/*
unsigned int CUIScrollViewContainerM::GetPerPageViews()
{
	unsigned int nViews		= 0;
	
	CCSize sizeContainer	= this->GetFrameRect().size;
	
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

bool CUIScrollViewContainerM::IsViewCanCenter()
{
	CCSize sizeContainer	= this->GetFrameRect().size;

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

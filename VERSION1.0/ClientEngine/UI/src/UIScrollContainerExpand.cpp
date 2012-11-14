/*
 *  UIScrollContainerExpand.mm
 *  DeNA
 *
 *  Created by chh on 12-07-21.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIScrollContainerExpand.h"
#include "NDDirector.h"
#include "NDUIImage.h"
#include "UISpriteNode.h"
#include "ScriptUI.h"
#define ANIMATE_ZOOM_MIN    0.7     //缩放比例下线
#define ANIMATE_ZOOM_MAX    1.0     //缩放比例上线
#define ANIMATE_POSITION    140*NDDirector::DefaultDirector()->GetScaleFactor()
#define ANIMATE_YOFFSET     50*NDDirector::DefaultDirector()->GetScaleFactor()

IMPLEMENT_CLASS(CUIScrollContainerExpand, NDUILayer)

CUIScrollContainerExpand::CUIScrollContainerExpand()
{
	m_sizeView      = CCSizeMake(0, 0);
    m_unBeginIndex  = 0 ;
    m_unPreIndex    = 0;
    bIsMoveing      = false;
    m_fTranValue    = 0;
    m_fScrollDistance       = 0;
    m_fScrollToCenterSpeed  = 15*NDDirector::DefaultDirector()->GetScaleFactor();
    m_pScrollViewCurrent    = NULL;
}

CUIScrollContainerExpand::~CUIScrollContainerExpand()
{
    
}
void CUIScrollContainerExpand::Initialization(){
    NDUILayer::Initialization();
}
void CUIScrollContainerExpand::AddView(UIScrollViewExpand* pScrollViewCurrent){
    this->AddChild(pScrollViewCurrent);
    m_pScrollViewUINodes.push_back(pScrollViewCurrent);
    CalculatePosition();
    ResetCurrViewBg();
}
void CUIScrollContainerExpand::SetSizeView(CCSize size){
    m_sizeView = size;
    m_fTranValue = m_fScrollToCenterSpeed/size.width;
}
UIScrollViewExpand* CUIScrollContainerExpand::GetViewById(unsigned int nViewId){
    //计算出viewid的index
    int uViewIndex = -1;
    unsigned int nViewSize = GetViewCount();
    for (unsigned int i=0; i<nViewSize; i++) {
        UIScrollViewExpand* sve = m_pScrollViewUINodes[i];
        if(sve->GetViewId() == nViewId){
            uViewIndex = i;
            break;
        }
    }
    
    if(uViewIndex<0){
        return NULL;
    }
    return GetViewByIndex(uViewIndex);
}
UIScrollViewExpand* CUIScrollContainerExpand::GetViewByIndex(unsigned int nViewIndex){
    if(nViewIndex<GetViewCount()){
        return m_pScrollViewUINodes[nViewIndex];
    }
    return NULL;
}
unsigned int CUIScrollContainerExpand::GetCurrentIndex(){
    return m_unBeginIndex;
}
unsigned int CUIScrollContainerExpand::GetPreIndex(){
    return m_unPreIndex;
}

unsigned int CUIScrollContainerExpand::GetViewCount(){
    return m_pScrollViewUINodes.size();
}
void CUIScrollContainerExpand::SetCurrentIndex(unsigned int unIndex){
    m_unPreIndex = m_unBeginIndex;
    m_unBeginIndex = unIndex;
    
    if(m_unBeginIndex>=m_pScrollViewUINodes.size()){
        m_unBeginIndex = 0;
    }
    OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_BEGIN, m_unBeginIndex);
}
void CUIScrollContainerExpand::MovePosition(int nDistance){
    unsigned int nViewSize = GetViewCount();
    for (unsigned int i=0; i<nViewSize; i++) {
        UIScrollViewExpand* sve = m_pScrollViewUINodes[i];
        CCRect rect = sve->GetFrameRect();
        rect.origin.x += nDistance;
        sve->SetFrameRect(rect);
    }
    SetViewScale();
}
void CUIScrollContainerExpand::SetViewScale(){
    
    UIScrollViewExpand *psve = m_pScrollViewUINodes[m_unPreIndex];
    vector<NDNode*> pnodes = psve->GetChildren();
    for (unsigned int i=0; i<pnodes.size(); i++) {
        float m_fScale = fabs(m_fScrollDistance)/m_sizeView.width;
        
        NDNode *node = pnodes[i];
        if(node && node->IsKindOfClass(RUNTIME_CLASS(NDUIImage))){
            NDUIImage *img = (NDUIImage*)node;
            if(img->GetPicture()){
                img->GetPicture()->SetColor(ccc4(255, 255, 255, 255*m_fScale));
            }
        }
        
        if(node && node->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode))){
            CUISpriteNode *nSpriteNode = (CUISpriteNode*)node;
            nSpriteNode->SetScale(ANIMATE_ZOOM_MIN + (ANIMATE_ZOOM_MAX-ANIMATE_ZOOM_MIN)*m_fScale); 
            
            
            CCRect rect = nSpriteNode->GetFrameRect();
            rect.origin.y = (ANIMATE_POSITION-ANIMATE_YOFFSET) + ANIMATE_YOFFSET*m_fScale;
            nSpriteNode->SetFrameRect(rect);
            
        }
    }
    
    UIScrollViewExpand *csve = m_pScrollViewUINodes[m_unBeginIndex];
    vector<NDNode*> cnodes = csve->GetChildren();
    for (unsigned int j=0; j<cnodes.size(); j++) {
        float m_fScale = 1-fabs(m_fScrollDistance)/m_sizeView.width;
        NDNode *node = cnodes[j];
        if(node && node->IsKindOfClass(RUNTIME_CLASS(NDUIImage))){
            NDUIImage *img = (NDUIImage*)node;
            if(img->GetPicture()){
                img->GetPicture()->SetColor(ccc4(255, 255, 255, 255*m_fScale));
            }
        }
        
        if(node && node->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode))){
            CUISpriteNode *nSpriteNode = (CUISpriteNode*)node;
            nSpriteNode->SetScale(ANIMATE_ZOOM_MIN + (ANIMATE_ZOOM_MAX-ANIMATE_ZOOM_MIN)*m_fScale);   
            
            
            CCRect rect = nSpriteNode->GetFrameRect();
            rect.origin.y = (ANIMATE_POSITION-ANIMATE_YOFFSET) + ANIMATE_YOFFSET*m_fScale;
            nSpriteNode->SetFrameRect(rect);
        }
    }

}
void CUIScrollContainerExpand::ResetCurrViewBg(){
    
    for (unsigned int i=0; i<m_pScrollViewUINodes.size(); i++) {
        UIScrollViewExpand *sve = m_pScrollViewUINodes[i];
        vector<NDNode*> nodes = sve->GetChildren();
        for (unsigned int j=0; j<nodes.size(); j++) {
            NDNode *node = nodes[j];
            if(node && node->IsKindOfClass(RUNTIME_CLASS(NDUIImage))){
                NDUIImage *img = (NDUIImage*)node;
                if(img->GetPicture()) {
                    if(i==m_unBeginIndex){
                        img->GetPicture()->SetColor(ccc4(255, 255, 255, 255));
                    }else{
                        img->GetPicture()->SetColor(ccc4(255, 255, 255, 0));
                    }
                }
            }
            
            if(node && node->IsKindOfClass(RUNTIME_CLASS(CUISpriteNode))){
                CUISpriteNode *nSpriteNode = (CUISpriteNode*)node;
                
                if(i==m_unBeginIndex){
                    nSpriteNode->SetScale(ANIMATE_ZOOM_MAX);
                    
                    
                    CCRect rect = nSpriteNode->GetFrameRect();
                    rect.origin.y = ANIMATE_POSITION;
                    nSpriteNode->SetFrameRect(rect);
                    
                    
                }else{
                    nSpriteNode->SetScale(ANIMATE_ZOOM_MIN);
                    
                    
                    CCRect rect = nSpriteNode->GetFrameRect();
                    rect.origin.y = ANIMATE_POSITION - ANIMATE_YOFFSET;
                    nSpriteNode->SetFrameRect(rect);
                     
                }            
            }
        }
    }
}

void CUIScrollContainerExpand::AdjustToCenter(){
    
}
void CUIScrollContainerExpand::CalculateSlideDistance(){
    
}
void CUIScrollContainerExpand::CalculatePosition(){
    int size = m_pScrollViewUINodes.size();
    int sizeb = size/2;
    int k=0;
    for (int i=m_unBeginIndex; i<size+m_unBeginIndex; i++,k++) {
        
        int index = i%size;
        
        CCRect rect;
        UIScrollViewExpand* sve = m_pScrollViewUINodes[index];
        
        rect = sve->GetFrameRect();
        if(i<sizeb || k<=2){
            rect = sve->GetFrameRect();
            rect.origin.x = (k+1)*m_sizeView.width;
        }else{
            int tempK = size-k-1;
            rect = sve->GetFrameRect();
            rect.origin.x = -tempK*m_sizeView.width;
        }
        
        sve->SetFrameRect(rect);
    }
}
bool CUIScrollContainerExpand::TouchMoved(NDTouch* touch)
{
    NDUILayer::TouchMoved(touch);
    
    if(!bIsMoveing){
        int offset = 0;
        if(touch->GetPreviousLocation().x<touch->GetLocation().x){
            offset = -1;
        }else{
            offset = 1;
        }
        m_fScrollDistance = offset*m_sizeView.width;
        
        int cur = m_unBeginIndex+offset;
        if(cur<0){
            cur = this->m_pScrollViewUINodes.size()+cur;
        }
        
        SetCurrentIndex(cur);
        
        
        if(m_unBeginIndex<0){
            m_unBeginIndex = m_pScrollViewUINodes.size()-1;
        }
        
        if(m_unBeginIndex>m_pScrollViewUINodes.size()-1){
            m_unBeginIndex = 0;
        }
        
        
        bIsMoveing = true;
    }
    
    return true;
}
void CUIScrollContainerExpand::draw(){
    NDUILayer::draw();
    
    NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
    
    if(m_fScrollDistance==0){
        return;
    }
    
    //小于最小移动距离时
    if(fabs(m_fScrollDistance)<=m_fScrollToCenterSpeed){
        MovePosition(-m_fScrollDistance);
        m_fScrollDistance   = 0;
        bIsMoveing          = false;
        CalculatePosition();
        ResetCurrViewBg();
        //OnScriptUiEvent(this, TE_TOUCH_SC_VIEW_IN_END, m_unBeginIndex);
        return;
    }
    
    //上下滑动
    if(m_fScrollDistance>0){
        MovePosition(-m_fScrollToCenterSpeed);
        m_fScrollDistance -= m_fScrollToCenterSpeed;
    }else{
        MovePosition(m_fScrollToCenterSpeed);
        m_fScrollDistance += m_fScrollToCenterSpeed;
    }
    
}
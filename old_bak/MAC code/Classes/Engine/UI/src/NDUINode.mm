//
//  NDUINode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDUINode.h"
#import "NDUILayer.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDDirector.h"
#import "ccMacros.h"
#import "CCDrawingPrimitives.h"
#import "NDDataSource.h"
#include "I_Analyst.h"

namespace NDEngine
{

#pragma mark 加载ui统一回调
	
	NDUITargetDelegate::NDUITargetDelegate()
	{
		INIT_AUTOLINK(NDUITargetDelegate);
	}
	
	NDUITargetDelegate::~NDUITargetDelegate()
	{
	}
	
	bool NDUITargetDelegate::OnTargetBtnEvent(NDUINode* uinode, int targetEvent)
	{
		return false;
	}
	
	bool NDUITargetDelegate::OnTargetTableEvent(NDUINode* uinode, NDUINode* cell, unsigned int cellIndex, NDSection *section)
	{
		return false;
	}
	
	IMPLEMENT_CLASS(NDUINode, NDNode)
	
	NDUINode::NDUINode()
    :m_nStepNum(0),m_fStep(0.00)
	{
		m_frameRect = CGRectZero;		
		m_visibled = true;
		m_eventEnabled = true;
		m_scrRect = CGRectZero;
        m_fBoundScale = 1;
	}

	////////////////////////////////////////////////////////////
	NDUINode::~NDUINode()
	{
		NDUILayer* layer = (NDUILayer*)this->GetParent();
		if (layer) 
		{
			if (layer->GetFocus() == this) 
			{
				layer->SetFocus(NULL);
			}
		}
	}
	
	
	////////////////////// register lua event
	
	void NDUINode::registerLuaClickFunction(const char* szFunc)
	{
		m_strLuaFunc = szFunc;
	
	}
	
	
	void NDUINode::unregisterLuaClickFunction()
	{
		
		m_strLuaFunc.clear();
		
	}
	
	
	void NDUINode::callLuaFunction()
	{
		     
	//	CLuaEngine::sharedLuaScriptModule()->executeUIFunction(m_strLuaFunc,this);
		
		
	}


	//////////////////////////////
	
	void NDUINode::Initialization()
	{
		NDNode::Initialization();
	}
	
	void NDUINode::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
	}
	
	void NDUINode::SetFrameRect(CGRect rect)
	{			
		this->SetContentSize(CGSizeMake(rect.size.width, rect.size.height));	
		m_frameRect = rect;
	}
	void NDUINode::ScriptSetFrameRect(CGRect rect)
	{			
        //rect.size.width *= CC_CONTENT_SCALE_FACTOR();
        //rect.size.height *= CC_CONTENT_SCALE_FACTOR();
		this->SetContentSize(CGSizeMake(rect.size.width, rect.size.height));	
		m_frameRect = rect;
	}
	
	CGRect NDUINode::GetFrameRect()
	{
		return m_frameRect;
	}	
	
	void NDUINode::SetVisible(bool visible)
	{
		m_visibled = visible;
		if (nil != m_ccNode)
		{
			[m_ccNode setVisible:visible];
		}
		/*
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			NDNode *node = this->GetChildren().at(i);
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* uiNode = (NDUINode*)node;
				uiNode->SetVisible(m_visibled);
			}
		}
		*/
	}
	
	bool NDUINode::IsVisibled()
	{
		return m_visibled;
	}
	
	void  NDUINode::EnableEvent(bool enabled)
	{
		m_eventEnabled = enabled;
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			NDNode *node = this->GetChildren().at(i);
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* uiNode = (NDUINode*)node;
				uiNode->EnableEvent(m_eventEnabled);
			}
		}
	}
	
	bool NDUINode::EventEnabled()
	{
		return m_eventEnabled;
	}
	
	CGRect NDUINode::GetScreenRect()
	{
		NDNode* node = this->GetParent();
		
		if (node) 
		{
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* node = (NDUINode*)this->GetParent();
				
				CGRect nodeRect = node->GetScreenRect();
				
				return CGRectMake(nodeRect.origin.x + m_frameRect.origin.x, 
								  nodeRect.origin.y + m_frameRect.origin.y, 
								  m_frameRect.size.width, m_frameRect.size.height);
			}
			return m_frameRect;
		}	
		return m_frameRect;
	}
	
    
    
    CGRect NDUINode::GetBoundRect()
    {
		NDNode* node = this->GetParent();
		
		if (node) 
		{
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* node = (NDUINode*)this->GetParent();
				
				CGRect nodeRect = node->GetScreenRect();
				
				return CGRectMake(nodeRect.origin.x + m_frameRect.origin.x - (m_fBoundScale-1)* m_frameRect.size.width *0.5, 
								  nodeRect.origin.y + m_frameRect.origin.y - (m_fBoundScale-1)* m_frameRect.size.height *0.5, 
								  m_frameRect.size.width*m_fBoundScale, m_frameRect.size.height*m_fBoundScale);
			}
			return m_frameRect;
		}	
		return m_frameRect;        
        
    }
    
    void NDUINode::SetBoundScale(int nScale)
    {
        m_fBoundScale = (float)nScale/100;
        
    }
    
	void NDUINode::draw()
	{	
        TICK_ANALYST(ANALYST_NDUINode);	
		NDNode::draw();
		if (m_nStepNum) {
            switch (m_nDirect) {
                case 1:
                    m_frameRect.origin.x += m_fStep;
                    break;
                case 2:
                    m_frameRect.origin.x -= m_fStep;
                    break;
                case 3:
                    m_frameRect.origin.y += m_fStep;
                    break;
                case 4:
                    m_frameRect.origin.y -= m_fStep;
                    break;
                default:
                    break;
            }
            m_nStepNum--;
        }
		CGRect scrRect = this->GetScreenRect();
		if (scrRect.origin.x != m_scrRect.origin.x || scrRect.origin.y != m_scrRect.origin.y ||
			scrRect.size.width != m_scrRect.size.width || scrRect.size.height != m_scrRect.size.height) 
		{
			this->OnFrameRectChange(m_scrRect, scrRect);
			m_scrRect = scrRect;
		}
	}
	
	void NDUINode::SetTargetDelegate(NDUITargetDelegate* targetDelegate)
	{
		if (!targetDelegate)
		{
			m_delegateTarget.Clear();
			
			return;
		}
		
		m_delegateTarget = targetDelegate->QueryLink();
	}
	
	NDUITargetDelegate* NDUINode::GetTargetDelegate()
	{
		return m_delegateTarget.Pointer();
	}
	
	void NDUINode::SetLuaDelegate(LuaObject func)
	{
		m_delegateLua = func;
	}
	
	bool NDUINode::GetLuaDelegate(LuaObject& func)
	{
		if (!m_delegateLua.IsFunction())
		{
			return false;
		}
		
		func = m_delegateLua;
		
		return true;
	}
    // 1-从左边飞入 2-从右边飞入 3-从上飞入 4-从下飞入
    void NDUINode::FlyToRect(CGRect rect, int nFrameNum, int nDirect)
    {
        if (nFrameNum <= 0) {
            this->SetFrameRect(rect);
            return;
        }
        //根据方向计算起始位置和步长
        m_nStepNum = nFrameNum;
        m_nDirect = nDirect;
        switch (nDirect) {
            case 1:
                //if (m_frameRect.origin.x == 0) {
                //    m_fStep = rect.size.width/nFrameNum;
                //    m_frameRect.origin.x -= rect.size.width;
                //}else{
                    m_fStep = (rect.origin.x-m_frameRect.origin.x)/nFrameNum;
                //}
                break;
            case 2:
                //if (m_frameRect.origin.x == 0) {
                //    m_fStep = rect.size.width/nFrameNum;
               //     m_frameRect.origin.x += rect.size.width;
                //}else{
                    m_fStep = (m_frameRect.origin.x+rect.origin.x)/nFrameNum;
               // }
                break;
            case 3:
                //if (m_frameRect.origin.y == 0) {
                //    m_fStep = rect.size.height/nFrameNum;
               //     m_frameRect.origin.y += rect.size.height;
               // }else{
                    m_fStep = (rect.origin.y-m_frameRect.origin.y)/nFrameNum;
              //  }
                break;
            case 4:
                //if (m_frameRect.origin.y == 0) {
                //    m_fStep = rect.size.height/nFrameNum;
                //    m_frameRect.origin.y -= rect.size.height;
               // }else{
                    m_fStep = (m_frameRect.origin.y+rect.origin.y)/nFrameNum;
                //}
                break;
            default:
                break;
        }
        printf("Change From[%f][%f] To [%f][%f] Step[%f]",m_frameRect.origin.x,m_frameRect.origin.y,rect.origin.x,rect.origin.y, m_fStep);
    }
}

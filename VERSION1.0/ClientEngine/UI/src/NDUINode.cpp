//
//  NDUINode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-28.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDUINode.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "ccMacros.h"
#include "CCDrawingPrimitives.h"

namespace NDEngine
{	
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
	
	bool NDUITargetDelegate::OnTargetTableEvent(NDUINode* uinode, NDUINode* cell, 
		unsigned int cellIndex, NDSection *section)
	{
		return false;
	}
	
	IMPLEMENT_CLASS(NDUINode, NDNode)
	
	NDUINode::NDUINode()
	{
		m_fStep = 0.0f;
		m_nStepNum = 0;
		m_kFrameRect = CGRectZero;		
		m_bVisibled = true;
		m_bEventEnabled = true;
		m_kScrRect = CGRectZero;
	}

	////////////////////////////////////////////////////////////
	NDUINode::~NDUINode()
	{
		//todo(zjh)
		/*
		NDUILayer* layer = (NDUILayer*)this->GetParent();
		if (layer) 
		{
			if (layer->GetFocus() == this) 
			{
				layer->SetFocus(NULL);
			}
		}
		*/
	}
	
	
	////////////////////// register lua event
	/*
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
	*/

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
		m_kFrameRect = rect;
	}
	
	CGRect NDUINode::GetFrameRect()
	{
		return m_kFrameRect;
	}	
	
	void NDUINode::SetVisible(bool visible)
	{
		m_bVisibled = visible;
		if (NULL != m_ccNode)
		{
			m_ccNode->setIsVisible(visible);
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

	void NDUINode::SetBoundScale(int nScale)
	{
		m_fBoundScale = (float)nScale/100;
	}
	
	bool NDUINode::IsVisibled()
	{
		return m_bVisibled;
	}
	
	void  NDUINode::EnableEvent(bool enabled)
	{
		m_bEventEnabled = enabled;
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			NDNode *node = this->GetChildren().at(i);
			
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* uiNode = (NDUINode*)node;
				uiNode->EnableEvent(m_bEventEnabled);
			}
		}
	}
	
	bool NDUINode::EventEnabled()
	{
		return m_bEventEnabled;
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
				
				return CGRectMake(nodeRect.origin.x + m_kFrameRect.origin.x, 
								  nodeRect.origin.y + m_kFrameRect.origin.y, 
								  m_kFrameRect.size.width, m_kFrameRect.size.height);
			}
			return m_kFrameRect;
		}	
		return m_kFrameRect;
	}
	
	void NDUINode::draw()
	{	
		NDNode::draw();

		if (m_nStepNum)
		{
			switch (m_nDirect)
			{
			case 1:
				m_kFrameRect.origin.x += m_fStep;
				break;
			case 2:
				m_kFrameRect.origin.x -= m_fStep;
				break;
			case 3:
				m_kFrameRect.origin.y += m_fStep;
				break;
			case 4:
				m_kFrameRect.origin.y -= m_fStep;
				break;
			default:
				break;
			}
			m_nStepNum--;
		}
		
		CGRect scrRect = this->GetScreenRect();
		if (scrRect.origin.x != m_kScrRect.origin.x || scrRect.origin.y != m_kScrRect.origin.y ||
			scrRect.size.width != m_kScrRect.size.width || scrRect.size.height != m_kScrRect.size.height) 
		{
			this->OnFrameRectChange(m_kScrRect, scrRect);
			m_kScrRect = scrRect;
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

	bool NDUINode::OnScriptUiEvent(NDUINode* uinode, int targetEvent)
	{
		if (!uinode)
		{
			return false;
		}

		LuaObject funcObj;

		if (!uinode->GetLuaDelegate(funcObj)
			|| !funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<bool> luaUiEventCallBack = funcObj;

		bool bRet = luaUiEventCallBack(uinode, targetEvent);

		return bRet;
	}

	void NDUINode::FlyToRect( CGRect rect, int nFrameNum, int nDirect )
	{
		if (nFrameNum <= 0)
		{
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
				m_fStep = (rect.origin.x-m_kFrameRect.origin.x)/nFrameNum;
				//}
				break;
			case 2:
				//if (m_frameRect.origin.x == 0) {
				//    m_fStep = rect.size.width/nFrameNum;
				//     m_frameRect.origin.x += rect.size.width;
				//}else{
				m_fStep = (m_kFrameRect.origin.x+rect.origin.x)/nFrameNum;
				// }
				break;
			case 3:
				//if (m_frameRect.origin.y == 0) {
				//    m_fStep = rect.size.height/nFrameNum;
				//     m_frameRect.origin.y += rect.size.height;
				// }else{
				m_fStep = (rect.origin.y-m_kFrameRect.origin.y)/nFrameNum;
				//  }
				break;
			case 4:
				//if (m_frameRect.origin.y == 0) {
				//    m_fStep = rect.size.height/nFrameNum;
				//    m_frameRect.origin.y -= rect.size.height;
				// }else{
				m_fStep = (m_kFrameRect.origin.y+rect.origin.y)/nFrameNum;
				//}
				break;
			default:
				break;
		}
		printf("Change From[%f][%f] To [%f][%f] Step[%f]",m_kFrameRect.origin.x,m_kFrameRect.origin.y,rect.origin.x,rect.origin.y, m_fStep);
	}

}
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
#include "NDDebugOpt.h"
#include "UsePointPls.h"
#include "ObjectTracker.h"
#include "UICheckBox.h"

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
		INC_NDOBJ_RTCLS

		m_fStep = 0.0f;
		m_nStepNum = 0;
		m_kFrameRect = CCRectZero;		
		m_bVisibled = true;
		m_bEventEnabled = true;
		m_kScrRectCache = CCRectZero;
		m_fBoundScale = 1.0f;
	}

	////////////////////////////////////////////////////////////
	NDUINode::~NDUINode()
	{
		DEC_NDOBJ_RTCLS

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
	
	void NDUINode::OnFrameRectChange(CCRect srcRect, CCRect dstRect)
	{
	}
	
	void NDUINode::SetFrameRect(CCRect rect) //in pixels
	{	
		// 备注：m_kFrameRect的取值在各种平台和分辨率的情况（目前暂未考虑iPhone3）：
		//
		//	1)	ios和window平台下，传入的参数总是基于960*640
		//		底层GL基于480*320
		//		上层m_kFrameRect基于960*640
		//
		//	2)	在android平台下，传入的参数是实际分辨率如：800*480,1280*800等.
		//		这个值直接公用于底层GL和上层，不需要转换.
		//		底层GL基于实际分辨率.
		//		上层m_kFrameRect也是基于实际分辨率.
		//
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//	这块机制比较晕,请不要随意修改！！！
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
		CCRect androidRect = rect;
		this->SetContentSize(CCSizeMake(androidRect.size.width, androidRect.size.height));
		m_kFrameRect = androidRect;

#else //ios & mac & win &...
		CCRect pointRect = rect;
		ConvertUtil::convertToPointCoord( pointRect );
		this->SetContentSize(CCSizeMake(pointRect.size.width, pointRect.size.height)); //in points
		m_kFrameRect = rect; //in pixels
#endif
	}
	
	CCRect NDUINode::GetFrameRect() //in pixels
	{
		return m_kFrameRect;
	}	
	
	void NDUINode::SetVisible(bool visible)
	{
		m_bVisibled = visible;
		if (NULL != m_ccNode)
		{
			m_ccNode->setVisible(visible);
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
	
	CCRect NDUINode::GetScreenRect()
	{
		NDNode* node = this->GetParent();
		
		if (node) 
		{
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode* node = (NDUINode*)this->GetParent();
				
				CCRect nodeRect = node->GetScreenRect();
				
				return CCRectMake(nodeRect.origin.x + m_kFrameRect.origin.x, 
								  nodeRect.origin.y + m_kFrameRect.origin.y, 
								  m_kFrameRect.size.width, m_kFrameRect.size.height);
			}
			return m_kFrameRect;
		}	
		return m_kFrameRect;
	}

	//获取屏幕响应点击区域
	CCRect NDUINode::GetBoundRect()
	{
		NDNode* node = this->GetParent();

		if (node) 
		{


			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
			{
				NDUINode* node = (NDUINode*)this->GetParent();

				CCRect nodeRect = node->GetScreenRect();
				CCRect CRectret = CCRectMake(
					nodeRect.origin.x + m_kFrameRect.origin.x - (m_fBoundScale - 1)*m_kFrameRect.size.width*0.5, 
					nodeRect.origin.y + m_kFrameRect.origin.y - (m_fBoundScale - 1)*m_kFrameRect.size.height*0.5, 
					m_kFrameRect.size.width*m_fBoundScale, 
					m_kFrameRect.size.height*m_fBoundScale);

				if(this->IsKindOfClass(RUNTIME_CLASS(CUICheckBox)))
				{
					return CCRectMake(
						CRectret.origin.x - 30*COORD_SCALE_X_960, 
						CRectret.origin.y - 15*COORD_SCALE_Y_960, 
						CRectret.size.width + 60*COORD_SCALE_X_960, 
						CRectret.size.height + 30*COORD_SCALE_Y_960);
				}

				return CRectret;
			}
	
			return m_kFrameRect;
		}	
		return m_kFrameRect;
	}
	
	void NDUINode::draw()
	{	
		if (!isDrawEnabled()) return;

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

		// check screen rect changed.
		CCRect scrRect = this->GetScreenRect();
		if (scrRect.origin.x != m_kScrRectCache.origin.x 
			|| scrRect.origin.y != m_kScrRectCache.origin.y 
			|| scrRect.size.width != m_kScrRectCache.size.width 
			|| scrRect.size.height != m_kScrRectCache.size.height) 
		{
			this->OnFrameRectChange(m_kScrRectCache, scrRect);
			m_kScrRectCache = scrRect;
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

	void NDUINode::FlyToRect( CCRect rect, int nFrameNum, int nDirect )
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

	bool NDUINode::isDrawEnabled()
	{
		return NDDebugOpt::getDrawUIEnabled();
	}

	CCRect NDUINode::GetSrcRectCache(void)
	{
		return m_kScrRectCache;
	}
}
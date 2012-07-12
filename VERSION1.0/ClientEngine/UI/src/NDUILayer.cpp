//
//  NDUILayer.mm
//  DragonDrive
//
//  Created by jhzheng on 10-12-21.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDUILayer.h"
#include "NDUINode.h"
#include "CCPointExtension.h"
#include <GLES/gl.h>
//#include "NDIphoneEdit.h"
#include "NDUIButton.h"
#include "cocos2dExt.h"
//#include "NDUIOptionButton.h"
//#include "NDUICheckBox.h"
//#include "NDUITableLayer.h"
#include "NDBaseLayer.h"
//#include "NDUIMemo.h"
//#include "NDUtility.h"
//#include "cpLog.h"
//#include "NDTextNode.h"
//#include "NDUtility.h"
//#include "NDUIOptionButtonEx.h"
//#include "NDUIDefaultTableLayer.h"
#include "NDTargetEvent.h"
#include "CCImage.h"
#include "NDUIBaseGraphics.h"
#include "Utility.h"

using namespace cocos2d;

#define LONG_TOUCH_TIME (0.5f)

#define LONG_TOUCH_TIMER_TAG (6951)

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUILayer, NDUINode)
	
	NDUILayer::NDUILayer()
	{
		INIT_AUTOLINK(NDUILayer);
		m_touchedNode = NULL;
		m_focusNode = NULL;
		m_backgroudTexture = NULL;
		m_backgroudColor = ccc4(0, 0, 0, 0);
		m_pic = NULL; m_picFocus = NULL;
		m_bClearOnFree = false; m_bFocusClearOnFree = false;
		
		m_longTouchTimer = new NDTimer;
		m_touchMoved = false;
		m_dragOutFlag = false;
		m_longTouch = false;
		m_layerMoved = false;
		m_enableMove = false;
		m_swallowDragIn = false;
		
		m_swallowDragOver = false;
		
		m_enableDragOver = false;
		
		m_dragOverNode = NULL;
		
		m_moveTouch = CGPointZero;
		
		m_bHorizontal = false;
		
		m_bMoveOutListener = false;
	}
	
	NDUILayer::~NDUILayer()
	{
		CC_SAFE_RELEASE(m_backgroudTexture);
		
		if (m_bClearOnFree) 
		{
			CC_SAFE_DELETE(m_pic);
		}
		
		if (m_bFocusClearOnFree) 
		{
			CC_SAFE_DELETE(m_picFocus);
		}
		
		if (m_longTouchTimer) 
		{
			m_longTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);
			
			delete m_longTouchTimer;
			
			m_longTouchTimer = NULL;
		}
	}
	
	void NDUILayer::Initialization()
	{
		m_ccNode = new NDBaseLayer;
		
		NDBaseLayer *layer = (NDBaseLayer *)m_ccNode;
		layer->SetUILayer(this);
		layer->setIsTouchEnabled(true);
		
		this->SetFrameRect(CGRectZero);
	}	
	void NDUILayer::SetTouchEnabled(bool bEnabled)
	{
		NDAsssert(m_ccNode != NULL);
		
		NDBaseLayer *layer = (NDBaseLayer *)m_ccNode;
		layer->setIsTouchEnabled(bEnabled);
	}
	
	void NDUILayer::SwallowDragInEvent(bool swallow)
	{
		m_swallowDragIn = swallow;
	}
	
	void NDUILayer::SwallowDragOverEvent(bool swallow)
	{
		m_swallowDragOver = swallow;
	}
	
	void NDUILayer::SetDragOverEnabled(bool bEnabled)
	{
		m_enableDragOver = bEnabled;
	}
	
	void NDUILayer::OnCanceledTouch()
	{
// 		if (this == m_layerPress && !canDispatchEvent()) 
// 		{
// 			EndDispatchEvent();
// 		}
	}
	
	void NDUILayer::SetBackgroundImage(const char* imageFile)
	{
		CC_SAFE_RELEASE_NULL(m_backgroudTexture);
		if (!imageFile)
		{
			return;
		}

		CCImage image;
		image.initWithImageFile(imageFile);
		m_backgroudTexture	= new CCTexture2D;
		m_backgroudTexture->initWithImage(&image);
	}
	
	void NDUILayer::SetBackgroundImageLua(NDPicture *pic)
	{
		this->SetBackgroundImage(pic, true);
	}
	
	void NDUILayer::SetBackgroundImage(NDPicture *pic, bool bClearOnFree /*= fasle*/)
	{
		if (m_bClearOnFree) 
		{
			delete m_pic;
		}
		
		m_pic = pic;
		
		m_bClearOnFree = bClearOnFree;
	}
	
	void NDUILayer::SetBackgroundFocusImageLua(NDPicture *pic)
	{
		this->SetBackgroundFocusImage(pic, true);
	}
	
	void NDUILayer::SetBackgroundFocusImage(NDPicture *pic, bool bClearOnFree /*= fasle*/)
	{
		if (m_bFocusClearOnFree) 
		{
			delete m_picFocus;
		}
		
		m_picFocus = pic;
		
		m_bFocusClearOnFree = bClearOnFree;
	}
	
	void NDUILayer::SetBackgroundColor(ccColor4B color)
	{
		m_backgroudColor = ccc4(color.r, color.g, color.b, color.a);
	}
	
	void NDUILayer::SetFocus(NDUINode* node)
	{
		m_focusNode = node;
	}
	
	NDUINode* NDUILayer::GetFocus()
	{
		return m_focusNode;
	}
	
	void NDUILayer::draw()
	{	

		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
//			if (m_focusNode == NULL) 
//				if (this->GetChildren().size() > 0) 
//					m_focusNode = (NDUINode*)this->GetChildren().at(0);

			bool focus = false;
			
			if (m_picFocus
				&& this->GetParent() 
				&& this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer))
				) 
			{	
				NDUILayer  *layer = ((NDUILayer*)(this->GetParent()));
				if (layer->GetFocus() == this)
					focus = true;
			}
			
			CGRect scrRect = this->GetScreenRect();
			
			NDPicture* pic = focus ? (m_picFocus == NULL ? m_pic : m_picFocus) : m_pic;
			
			if (pic) 
			{
				DrawRecttangle(scrRect, m_backgroudColor);
				
				pic->DrawInRect(scrRect);
			}
			else
			{
				DrawRecttangle(scrRect, m_backgroudColor);
				
				if (m_backgroudTexture) 
				{
					//glDisableClientState(GL_COLOR_ARRAY);
					
					m_backgroudTexture->drawInRect(scrRect);	
					
					//glEnableClientState(GL_COLOR_ARRAY);
				}
			}
		}		
	}
	
	bool NDUILayer::IsVisibled()
	{
		bool bVisible = NDUINode::IsVisibled();
		if (!bVisible)
		{
			return bVisible;
		}
		
		NDNode* pNode		= this->GetParent();
		
		if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
		{
			bVisible	= ((NDUILayer*)pNode)->IsVisibled();
		}
		
		return bVisible;
	}
	
	bool NDUILayer::UITouchBegin(NDTouch* touch)
	{
//		if (!canDispatchEvent()) 
//		{
//			return false;
//		}
		
		ResetEventParam();
		
		if	(!TouchBegin(touch))
		{
			//EndDispatchEvent();
			
			return false;
		}
		
		return true; 
	}
	
	void NDUILayer::UITouchEnd(NDTouch* touch)
	{
		if (m_longTouchTimer) 
			m_longTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);

		if (TouchEnd(touch))
		{
			//EndDispatchEvent();
			
			return;
		}
			
		//if (m_pressing)
		//{
			if (m_enableMove && m_touchMoved && m_layerMoved) 
			{
				DispatchLayerMoveEvent(m_beginTouch, touch);
			}
		//	}
		//}
		
		//EndDispatchEvent();
	} 
	
	void NDUILayer::UITouchCancelled(NDTouch* touch)
	{
		TouchCancelled(touch);
	}
	
	void NDUILayer::UITouchMoved(NDTouch* touch)
	{
		if (TouchMoved(touch))
		{
		}
		//	m_layerMoved = false; 
	}
	
	bool NDUILayer::UITouchDoubleClick(NDTouch* touch)
	{
		return TouchDoubleClick(touch);
	}
	
	bool NDUILayer::TouchBegin(NDTouch* touch)
	{
		if (!this->IsVisibled())
		{
			return false;
		}
		
		m_dispatchTouchEndEvent = true;
		m_beginTouch = touch->GetLocation();		
		
		if (CGRectContainsPoint(this->GetScreenRect(), m_beginTouch) && this->IsVisibled() && this->EventEnabled()) 
		{
			this->DispatchTouchBeginEvent(m_beginTouch);
			printf("\nbegin x[%.1f]y[%.1f]", m_beginTouch.x, m_beginTouch.y);
			//this->DispatchTouchEndEvent(m_beginTouch, m_beginTouch);
			
			// 长按开始
			if (m_touchedNode && m_longTouchTimer) 
			{
				m_longTouchTimer->SetTimer(this, LONG_TOUCH_TIMER_TAG, LONG_TOUCH_TIME);
			}
			
			return true;
		}
		return false;		
	}
	
	bool NDUILayer::TouchEnd(NDTouch* touch)
	{	
		m_endTouch = touch->GetLocation();
		
		
		if (m_dragOverNode)
		{
			if (m_dragOverNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (m_dragOverNode->GetDelegate());
				
				if (delegate)
					delegate->OnButtonDragOver((NDUIButton*)m_dragOverNode, false);	
			}
		}
		
		if (m_bDispatchLongTouchEvent)
		{
			DispatchLongTouchEvent(m_beginTouch, false);
			m_bDispatchLongTouchEvent = false;
		}
		
		
		// 长按
		if (m_longTouch && !m_dragOutFlag && !m_layerMoved) 
		{
			// 都取超始点是由于用户抬起点容易超出作用范围
			if ( DispatchLongTouchClickEvent(m_beginTouch, m_beginTouch) )
			{
				return true;
			}
		}
	
		
		if (m_dispatchTouchEndEvent && !m_layerMoved) 
		{			
			if ( this->DispatchTouchEndEvent(m_beginTouch, m_beginTouch) )
			{
				return true;
			}
		}
		
		// 拖出结束
		if (m_dragOutFlag && !m_layerMoved) 
		{
			DispatchDragOutCompleteEvent(m_beginTouch, m_endTouch, m_longTouch);
		}
		
		// 拖入
		if (m_dragOutFlag && !m_layerMoved) 
		{
			if (!DispatchDragInEvent(m_touchedNode, m_beginTouch, m_endTouch, m_longTouch, true)) 
			{
				NDNode *node = this;
				
				while ( (node = node->GetParent()) && node->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
					if (((NDUILayer*)node)->DispatchDragInEvent(m_touchedNode, m_beginTouch, m_endTouch, m_longTouch, true))
					{
						return true;
					}
			}
			else 
			{
				return true;
			}
			//return DispatchDragInEvent(m_beginTouch, m_endTouch, m_longTouch, true);
		}
		
		return false;
	}
	
	void NDUILayer::TouchCancelled(NDTouch* touch)
	{
	}
	
	bool NDUILayer::TouchMoved(NDTouch* touch)
	{	
		CGPoint moveTouch = touch->GetLocation();
		
		printf("\nmove x[%.1f]y[%.1f]", moveTouch.x, moveTouch.y);
		
		if (m_touchedNode && m_dispatchTouchEndEvent) 
		{
			DealTouchNodeState(false);
			m_dispatchTouchEndEvent = false;
		}
		
		if (m_bDispatchLongTouchEvent)
		{
			DispatchLongTouchEvent(m_beginTouch, false);
			m_bDispatchLongTouchEvent = false;
		}
		
		m_touchMoved = true;
		
		// 长按
		if (m_touchedNode) 
		{
			DispatchDragOverEvent(m_beginTouch, moveTouch);
			
			CGRect nodeFrame = m_touchedNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);	
			
			if ( !m_layerMoved && (CGRectContainsPoint(nodeFrame, moveTouch) || m_dragOutFlag) ) 
			{
				if (m_longTouchTimer)
					m_longTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);
					
				if ( m_longTouch && DispatchDragOutEvent(m_beginTouch, moveTouch, m_longTouch)) 
				{ //拖出
					m_dragOutFlag = true;
					return true;
				}
			}
		}
		
		if (m_enableMove && !m_dragOutFlag) 
		{
			bool bRet = DispatchLayerMoveEvent(m_beginTouch, touch);
			
			if (bRet)
			{
				m_layerMoved	= true;
			}
		}
		
		return false;
	}
	
	bool NDUILayer::TouchDoubleClick(NDTouch* touch)
	{
		if (!this->IsVisibled())
		{
			return false;
		}
		
		m_dispatchTouchEndEvent = true;
		m_beginTouch = touch->GetLocation();		
		
		if (CGRectContainsPoint(this->GetScreenRect(), m_beginTouch) && this->IsVisibled() && this->EventEnabled()) 
		{
			this->DispatchTouchDoubleClickEvent(m_beginTouch);
	
			return true;
		}
		return false;
	}
	
	bool NDUILayer::DispatchTouchBeginEvent(CGPoint beginTouch)
	{	
		m_touchedNode = NULL;
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
						
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}			
			
			//NDUILayer need dispatch event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)uiNode;
				if (uiLayer->DispatchTouchBeginEvent(beginTouch))
					return true;
				else 
					continue;
			}
			
			//touch event deal.....
			CGRect nodeFrame = uiNode->GetScreenRect();
			
			if (CGRectContainsPoint(nodeFrame, beginTouch)) 
			{
				m_touchedNode = uiNode;
				DealTouchNodeState(true);
				return true;
			}
		}
		return false;
	}
	
	bool NDUILayer::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
	{	
		if (m_touchedNode) 
		{
			DealTouchNodeState(false);
		}
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}				

			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, endTouch)) 
			{
				if (CGRectContainsPoint(nodeFrame, beginTouch)) 
				{
					//set focus 
					m_focusNode = uiNode;	
					
					//NDUILayer need dispatch event
					if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
					{
						NDUILayer* uiLayer = (NDUILayer*)uiNode;
						if (uiLayer->DispatchTouchEndEvent(beginTouch, endTouch))
							return true;
						else 
							continue;
					}
					
					//onclick event......
					/*if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIEdit))) 
					{
						NDUIEditDelegate* delegate = dynamic_cast<NDUIEditDelegate*> (uiNode->GetDelegate());						
						if (delegate) 
						{
							if (delegate->OnEditClick((NDUIEdit*)uiNode))
								this->AfterEditClickEvent((NDUIEdit*)uiNode);
						}
						else 
							this->AfterEditClickEvent((NDUIEdit*)uiNode);	
						return true;
					}
					else*/ if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
					{
						if (((NDUIButton*)uiNode)->IsGray())
						{
							return true;
						}
						
						NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
						if (delegate) 
						{
							delegate->OnButtonClick((NDUIButton*)uiNode);
							return true;
						}
						NDUITargetDelegate* targetDelegate = uiNode->GetTargetDelegate();
						if (targetDelegate)
						{
							targetDelegate->OnTargetBtnEvent(uiNode, TE_TOUCH_BTN_CLICK);
							
							return true;
						}
						
						if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_CLICK))
						{
							return true;
						}
					}					
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIOptionButton)))
// 					{
// 						NDUIOptionButton* opt = (NDUIOptionButton*)uiNode;
// 						// 下一个选项
// 						if (m_endTouch.x > (nodeFrame.origin.x + nodeFrame.size.width / 2))
// 						{
// 							opt->NextOpt();
// 						}
// 						else // 前一个选项
// 						{
// 							opt->PreOpt();
// 						}
// 						
// 						NDUIOptionButtonDelegate* delegate = dynamic_cast<NDUIOptionButtonDelegate*> (opt->GetDelegate());
// 						if (delegate) 
// 						{
// 							delegate->OnOptionChange(opt);
// 							return true;
// 						}
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIOptionButtonEx)))
// 					{
// 						NDUIOptionButtonEx* opt = (NDUIOptionButtonEx*)uiNode;
// 						
// 						NDUIOptionButtonExDelegate* delegate = dynamic_cast<NDUIOptionButtonExDelegate*> (opt->GetDelegate());
// 						if (delegate) 
// 						{
// 							bool bFilter = delegate->OnClickOptionEx(opt);
// 							
// 							if (bFilter) return true;
// 						}
// 						
// 						// 下一个选项
// 						if (m_endTouch.x > (nodeFrame.origin.x + nodeFrame.size.width / 2))
// 						{
// 							opt->NextOpt();
// 						}
// 						else // 前一个选项
// 						{
// 							opt->PreOpt();
// 						}
// 						
// 						if (delegate) 
// 						{
// 							delegate->OnOptionChangeEx(opt);
// 							return true;
// 						}
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUICheckBox)))
// 					{
// 						NDUICheckBoxDelegate* delegate = dynamic_cast<NDUICheckBoxDelegate*> (uiNode->GetDelegate());
// 						NDUICheckBox* uiCB = (NDUICheckBox*)uiNode;
// 						uiCB->ChangeCBState();
// 						if (delegate) 
// 						{
// 							delegate->OnCBClick(uiCB);
// 							return true;
// 						}
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUISectionTitle)))
// 					{
// 						NDUISectionTitleDelegate* delegate = dynamic_cast<NDUISectionTitleDelegate*> (uiNode->GetDelegate());
// 						if (delegate) 
// 						{						
// 							delegate->OnSectionTitleClick((NDUISectionTitle*)uiNode);
// 							return true;
// 						}
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultSectionTitle)))
// 					{
// 						NDUIDefaultSectionTitleDelegate* delegate = dynamic_cast<NDUIDefaultSectionTitleDelegate*> (uiNode->GetDelegate());
// 						if (delegate) 
// 						{						
// 							delegate->OnDefaultSectionTitleClick((NDUIDefaultSectionTitle*)uiNode);
// 							return true;
// 						}
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIMemo)))
// 					{
// 						NDUIMemo* uiMemo = (NDUIMemo*)uiNode;
// 						uiMemo->OnTextClick(endTouch);
// 						return false;
//					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIText)))
// 					{
// 						NDUIText* uiText = (NDUIText*)uiNode;
// 						uiText->OnTextClick(endTouch);
// 						return false;
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIVerticalScrollBar)))
// 					{
// 						NDUIVerticalScrollBar* scrollBar = (NDUIVerticalScrollBar*)uiNode;
// 						scrollBar->OnClick(endTouch);
// 						return true;
// 					}
// 					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultVerticalScrollBar)))
// 					{
// 						NDUIDefaultVerticalScrollBar* scrollBar = (NDUIDefaultVerticalScrollBar*)uiNode;
// 						scrollBar->OnClick(endTouch);
// 						return true;
// 					}
					else if (uiNode->OnClick(uiNode))
					{
						return true;
					}
				}		
				
			}
		}		
		return false;
	}
	
	bool NDUILayer::DispatchTouchDoubleClickEvent(CGPoint beginTouch)
	{
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}				
			
			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, beginTouch)) 
			{
				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					if (uiLayer->DispatchTouchDoubleClickEvent(beginTouch))
						return true;
					else 
						continue;
				}
				
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					if (((NDUIButton*)uiNode)->IsGray())
					{
						return true;
					}
					
					NDUITargetDelegate* targetDelegate = uiNode->GetTargetDelegate();
					if (targetDelegate)
					{
						targetDelegate->OnTargetBtnEvent(uiNode, TE_TOUCH_BTN_DOUBLE_CLICK);
						
						return true;
					}
					
					if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_DOUBLE_CLICK))
					{
						return true;
					}
				}					
			}
		}		
		return false;
	}
	
	void NDUILayer::DealTouchNodeState(bool down)
	{
		if (m_touchedNode && m_dispatchTouchEndEvent) 
		{
			//NDUIButton must clear touch down event on touch up 
			if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton))) 
			{
				NDUIButton* uiButton = (NDUIButton*)m_touchedNode;
				uiButton->OnTouchDown(down);
			}
			//NDUISectionTitle must clear touch down event on touch up 
// 			else if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUISectionTitle)))
// 			{
// 				NDUISectionTitle* sectionTitle = (NDUISectionTitle*)m_touchedNode; 
// 				sectionTitle->OnTouchDown(down);
// 			}
// 			else if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultSectionTitle)))
// 			{
// 				NDUIDefaultSectionTitle* sectionTitle = (NDUIDefaultSectionTitle*)m_touchedNode; 
// 				sectionTitle->OnTouchDown(down);
// 			}
// 			//NDUIVercitalScollBar must clear touch down event on touch up 
// 			else if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIVerticalScrollBar)))
// 			{
// 				NDUIVerticalScrollBar* scrollBar = (NDUIVerticalScrollBar*)m_touchedNode; 
// 				scrollBar->OnTouchDown(down, m_beginTouch);
// 			}
// 			else if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIDefaultVerticalScrollBar)))
// 			{
// 				NDUIDefaultVerticalScrollBar* scrollBar = (NDUIDefaultVerticalScrollBar*)m_touchedNode; 
// 				scrollBar->OnTouchDown(down, m_beginTouch);
// 			}
		}
	}
	
	void NDUILayer::DealLongTouchNodeState(bool down)
	{
		if (m_touchedNode) 
		{
			//NDUIButton must clear touch down event on touch up 
			if (m_touchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton))) 
			{
				NDUIButton* uiButton = (NDUIButton*)m_touchedNode;
				uiButton->OnLongTouchDown(down);
			}
		}
	}
	
	void NDUILayer::SetScrollEnabled(bool bEnabled)
	{
		m_enableMove = bEnabled;
	}
	
	void NDUILayer::OnTimer(OBJID tag)
	{
		if (m_longTouchTimer && tag == LONG_TOUCH_TIMER_TAG)
		{
			m_longTouchTimer->KillTimer(this, tag);
			
			m_longTouch = true;
			
			DispatchLongTouchEvent(m_beginTouch, true);
			
			m_bDispatchLongTouchEvent = true; 
		}
	}
	
	bool NDUILayer::DispatchLongTouchClickEvent(CGPoint beginTouch, CGPoint endTouch)
	{
		if (m_touchedNode) 
		{
			DealTouchNodeState(false);
		}
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}				
			
			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, endTouch)) 
			{
				if (CGRectContainsPoint(nodeFrame, beginTouch)) 
				{
					//set focus 
					m_focusNode = uiNode;	
					
					//NDUILayer need dispatch event
					if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
					{
						NDUILayer* uiLayer = (NDUILayer*)uiNode;
						if (uiLayer->DispatchLongTouchClickEvent(beginTouch, endTouch))
							return true;
						else 
							continue;
					}
					
					//onclick event......
					if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
					{
						NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
						if (delegate && delegate->OnButtonLongClick((NDUIButton*)uiNode)) 
						{
							return true;
						}
					}					
				}
			}
		}		
		return false;
	}
	
	bool NDUILayer::DispatchLongTouchEvent(CGPoint beginTouch, bool touch)
	{
		if (!m_touchedNode || m_touchMoved) return false;
		
		DealLongTouchNodeState(touch);
		
		NDUINode* uiNode = m_touchedNode;
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		//un visibled node dont accept event
		if (!uiNode->IsVisibled()) 
		{
			return false;
		}
		
		//un receive event node dont accept event
		if (!uiNode->EventEnabled()) 
		{
			return false;
		}
		
		//un darwed dont accept event
		if (!uiNode->DrawEnabled()) 
		{
			return false;
		}
		
		//NDUILabel do not deal any event
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
		{
			return false;
		}				
		
		//touch event deal
		CGRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);			
		
		if (CGRectContainsPoint(nodeFrame, beginTouch)) 
		{
			//NDUILayer need dispatch event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)uiNode;
				if (uiLayer->DispatchLongTouchEvent(beginTouch, touch))
					return true;
				else 
					return false;
			}
			
			//onclick event......
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
				if (touch && delegate && delegate->OnButtonLongTouch((NDUIButton*)uiNode)) 
				{
					return true;
				}
				
				if (!touch && delegate && delegate->OnButtonLongTouchCancel((NDUIButton*)uiNode)) 
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	bool NDUILayer::DispatchDragOutEvent(CGPoint beginTouch, CGPoint moveTouch, bool longTouch/*=false*/)
	{
		if (!m_touchedNode) return false;
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		//m_focusNode = m_touchedNode;
	
		NDUINode* uiNode = m_touchedNode;
		
		//un visibled node dont accept event
		if (!uiNode->IsVisibled()) 
		{
			return false;
		}
		
		//un receive event node dont accept event
		if (!uiNode->EventEnabled()) 
		{
			return false;
		}
		
		//un darwed dont accept event
		if (!uiNode->DrawEnabled()) 
		{
			return false;
		}
		
		//NDUILabel do not deal any event
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
		{
			return false;
		}				
		
		//touch event deal
		CGRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);			
		
//		if (CGRectContainsPoint(nodeFrame, beginTouch)) 
//		{
			if ( CGRectContainsPoint(nodeFrame, moveTouch) || m_dragOutFlag) 
			{
//				//NDUILayer need dispatch event
//				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
//				{
//					NDUILayer* uiLayer = (NDUILayer*)uiNode;
//					if (uiLayer->DispatchDragOutEvent(beginTouch, moveTouch))
//						return true;
//				}
				
				//onclick event......
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					if (((NDUIButton*)uiNode)->IsGray())
					{
						return false;
					}
					
					NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
					if (delegate && delegate->OnButtonDragOut((NDUIButton*)uiNode, beginTouch, moveTouch, longTouch))
					{
						return true;
					}
					
					if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_DRAG_OUT, moveTouch))
					{
						return true;
					}
				}					
			}
//		}
			
		return false;
	}
	
	bool NDUILayer::DispatchDragOutCompleteEvent(CGPoint beginTouch, CGPoint endTouch, bool longTouch/*=false*/)
	{
		if (!m_touchedNode) return false;
		
		NDUINode* uiNode = m_touchedNode;
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		//un visibled node dont accept event
		if (!uiNode->IsVisibled()) 
		{
			return false;
		}
		
		//un receive event node dont accept event
		if (!uiNode->EventEnabled()) 
		{
			return false;
		}
		
		//un darwed dont accept event
		if (!uiNode->DrawEnabled()) 
		{
			return false;
		}
		
		//NDUILabel do not deal any event
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
		{
			return false;
		}				
		
		//touch event deal
		CGRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);			
		
		//onclick event......
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
			if (delegate && delegate->OnButtonDragOutComplete((NDUIButton*)uiNode, endTouch, !CGRectContainsPoint(nodeFrame, endTouch))) 
			{
				return true;
			}
			
			if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_DRAG_OUT_COMPLETE))
			{
				return true;
			}
		}
		
		return false;
	}
	
	bool NDUILayer::DispatchDragInEvent(NDUINode* dragOutNode, CGPoint beginTouch, CGPoint endTouch, bool longTouch, bool dealByDefault/*=false*/)
	{
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}				
			
			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, endTouch)) 
			{
				//set focus 
				//m_focusNode = uiNode;	
				
				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					if (uiLayer->DispatchDragInEvent(dragOutNode, beginTouch, endTouch, longTouch))
						return true;
					else 
						continue;
				}
				
				//onclick event......
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
					if (delegate && delegate->OnButtonDragIn((NDUIButton*)uiNode, dragOutNode, longTouch)) 
					{
						// 清除粘在用户手上的图标 todo
						return true;
					}
					
					if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_DRAG_IN, dragOutNode))
					{
						return true;
					}
				}					
			}
		}
		
		if (dealByDefault) 
		{ 
			// 清除粘在用户手上的图标 todo
		}
		
		if (m_swallowDragIn) return true;
		
		return false;
	}
	
	bool NDUILayer::DispatchDragOverEvent(CGPoint beginTouch, CGPoint moveTouch, bool longTouch/*=false*/)
	{	
		if (!m_enableDragOver) return false;
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		if (m_dragOverNode)
		{
			CGRect nodeFrame = m_dragOverNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);	
			
			bool isInRange = CGRectContainsPoint(nodeFrame, moveTouch);
			if (m_dragOverNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (m_dragOverNode->GetDelegate());
				
				if (!delegate) return false;
				
				if (isInRange) return true;
				
				delegate->OnButtonDragOver((NDUIButton*)m_dragOverNode, false);	
			}
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//NDUILabel do not deal any event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
			{
				continue;
			}				
			
			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, moveTouch)) 
			{
				//set focus 
				//m_focusNode = uiNode;	
				
				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					if (uiLayer->DispatchDragOverEvent(beginTouch, moveTouch, longTouch))
						return true;
					else 
						continue;
				}
				
				//onclick event......
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					NDUIButtonDelegate* delegate = dynamic_cast<NDUIButtonDelegate*> (uiNode->GetDelegate());
					if (delegate && delegate->OnButtonDragOver((NDUIButton*)uiNode, true))
					{
						m_dragOverNode = uiNode;
						return true;
					}
				}					
			}
		}
		
		if (m_swallowDragOver) return true;
		
//		NDNode *pNode = this->GetParent();
//		
//		if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
//		{
//			return ((NDUILayer*)pNode)->DispatchDragOverEvent(beginTouch, moveTouch, longTouch);
//		}
		
		return false;
	}
	
	bool NDUILayer::DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch)
	{
		if (!m_bMoveOutListener &&
			!CGRectContainsPoint(this->GetScreenRect(), moveTouch->GetLocation()))
		{
			return false;
		}
		
		if (!this->IsVisibled())
		{
			return false;
		}
		
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			
			//un visibled node dont accept event
			if (!uiNode->IsVisibled()) 
			{
				continue;
			}
			
			//un receive event node dont accept event
			if (!uiNode->EventEnabled()) 
			{
				continue;
			}
			
			//un darwed dont accept event
			if (!uiNode->DrawEnabled()) 
			{
				continue;
			}
			
			//Only NDUILayer can deal
			/*
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
			{
				NDUILayer* uiLayer = (NDUILayer*)uiNode;
				if (uiLayer->DispatchTouchBeginEvent(m_beginTouch))
					return true;
				else 
					continue;
			}
			*/
			
			//touch event deal
			CGRect nodeFrame = uiNode->GetScreenRect();
			nodeFrame = RectAdd(nodeFrame, 2);			
			
			if (CGRectContainsPoint(nodeFrame, beginPoint) && CGRectContainsPoint(nodeFrame, moveTouch->GetLocation())) 
			{
				//set focus 
				//m_focusNode = uiNode;	
				
				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
				{
					NDUILayer* uiLayer = (NDUILayer*)uiNode;
					if (uiLayer->DispatchLayerMoveEvent(beginPoint, moveTouch))
						return true;
					else 
						continue;
				}					
			}
		}
		
		// slef deal
		NDUILayerDelegate* delegate = dynamic_cast<NDUILayerDelegate*> (this->GetDelegate());
		if (!delegate) 
		{
			return false;			
		}
		
		CGPoint prePos = moveTouch->GetPreviousLocation();
		CGPoint curPos = moveTouch->GetLocation();
		
		m_moveTouch = curPos;
		
		float horizontal = curPos.x - prePos.x,
			  vertical = curPos.y - prePos.y;
			  //tmpHorizontal = curPos.x - beginPoint.x,
			  //tmpVertical = curPos.y - beginPoint.y;
		
		bool bReturn = false;
		
		//tmpHorizontal = tmpHorizontal > 0.0f ? tmpHorizontal : -tmpHorizontal;
		
		//tmpVertical = tmpVertical > 0.0f ? tmpVertical : -tmpVertical;
		
		if (m_bHorizontal) 
		{ // 水平滚动
			if (horizontal > 0.0f)
				bReturn = delegate->OnLayerMove(this, UILayerMoveRight, horizontal);
			else
				bReturn = delegate->OnLayerMove(this, UILayerMoveLeft, -horizontal); 
		}
		else
		{ // 垂直滚动
			if (vertical > 0.0f)
				bReturn = delegate->OnLayerMove(this, UILayerMoveDown, vertical);
			else
				bReturn = delegate->OnLayerMove(this, UILayerMoveUp, -vertical); 
			
		}
		
		if (!bReturn)
		{
			bReturn = delegate->OnLayerMoveOfDistance(this, horizontal, vertical); 
		}
		
		return bReturn;
	}
	
	void NDUILayer::SetScrollHorizontal(bool bSet)
	{
		m_bHorizontal = bSet;
	}
	
	bool NDUILayer::IsScrollHorizontal()
	{
		return m_bHorizontal;
	}
	
	void NDUILayer::SetMoveOutListener(bool bSet)
	{
		m_bMoveOutListener = bSet;
	}
	
	void NDUILayer::ResetEventParam()
	{
		m_longTouch = false;
		
		m_touchMoved = false;
		
		m_dragOutFlag = false;
		
		m_layerMoved = false;
		
		m_dragOverNode = NULL;
	}
	
	CGRect NDUILayer::RectAdd(CGRect rect, int value)
	{
		return CGRectMake(rect.origin.x - value, rect.origin.y - value, rect.size.width + 2 * value, rect.size.height + 2 * value);
	}
	/*
	void NDUILayer::AfterEditClickEvent(NDUIEdit* edit)
	{		
		UIWindow *win = [UIApplication sharedApplication].keyWindow; 

		NDIphoneEdit *iphoneEdit = [NDIphoneEdit defaultEdit];		
		iphoneEdit.textField.text = [NSString stringWithUTF8String:edit->GetText().c_str()];
		[iphoneEdit.textField becomeFirstResponder];
		iphoneEdit.textField.secureTextEntry = edit->IsPasswordChar();
		iphoneEdit.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		iphoneEdit.maxLength = edit->GetMaxLength();
		iphoneEdit.minLength = edit->GetMinLength();
		iphoneEdit.nduiLayer = this;
		iphoneEdit.nduiEdit  = edit;		

		[win addSubview:iphoneEdit];	
	}

	void NDUILayer::IphoneEditInputFinish(NDUIEdit* edit)
	{
		NDIphoneEdit *iphoneEdit = [NDIphoneEdit defaultEdit];
		NSString *str = iphoneEdit.textField.text;		
		edit->SetText([str UTF8String]);

		NDUIEditDelegate* delegate = dynamic_cast<NDUIEditDelegate*> (edit->GetDelegate());
		if (delegate) 
			delegate->OnEditInputFinish(edit);		
	}

	void NDUILayer::IphoneEditInputCancle(NDUIEdit* edit)
	{
		NDUIEditDelegate* delegate = dynamic_cast<NDUIEditDelegate*> (edit->GetDelegate());
		if (delegate) 
			delegate->OnEditInputCancle(edit);
	}
	*/
// 	bool NDUILayer::canDispatchEvent()
// 	{
// 		return !m_pressing;
// 	}
	
// 	void NDUILayer::StartDispatchEvent()
// 	{
// 		m_pressing  = true;
// 		
// 		m_layerPress = this;
// 	}
// 	
// 	void NDUILayer::EndDispatchEvent()
// 	{
// 		m_pressing = false;
// 		
// 		m_layerPress = NULL;
// 	}
	
// 	bool NDUILayer::m_pressing = false;
// 	NDUILayer* NDUILayer::m_layerPress = NULL;

}
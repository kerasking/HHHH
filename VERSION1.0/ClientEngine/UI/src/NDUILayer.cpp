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
//#include <GLES/gl.h>
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
#include "NDDirector.h"
#include "NDUIImage.h"
#include "NDDebugOpt.h"

using namespace cocos2d;

#define LONG_TOUCH_TIME (0.1f)

#define LONG_TOUCH_TIMER_TAG (6951)

namespace NDEngine
{
IMPLEMENT_CLASS(NDUILayer, NDUINode)

bool NDUILayer::ms_bPressing = false;
NDUILayer* NDUILayer::m_pkLayerPress = 0;

NDUILayer::NDUILayer()
{
	INIT_AUTOLINK (NDUILayer);
	m_pkTouchedNode = NULL;
	m_pkFocusNode = NULL;
	m_pkBackgroudTexture = NULL;
	m_kBackgroudColor = ccc4(0, 0, 0, 0);
	m_pkPic = NULL;
	m_pkPicFocus = NULL;
	m_bClearOnFree = false;
	m_bFocusClearOnFree = false;

	m_pkLongTouchTimer = new NDTimer;
	m_bTouchMoved = false;
	m_bDragOutFlag = false;
	m_bLongTouch = false;
	m_bLayerMoved = false;
	m_bEnableMove = false;
	m_bSwallowDragIn = false;

	m_bSwallowDragOver = false;

	m_bEnableDragOver = false;

	m_pkDragOverNode = NULL;

	m_kMoveTouch = CGPointZero;

	m_bHorizontal = false;

	m_bMoveOutListener = false;
	m_bTouchDwon = false;

	m_nIsHVFirestTemp = 0;
	m_bIsHVContainer = false;
}

NDUILayer::~NDUILayer()
{
	CC_SAFE_RELEASE (m_pkBackgroudTexture);

	if (m_bClearOnFree)
	{
		CC_SAFE_DELETE (m_pkPic);
	}

	if (m_bFocusClearOnFree)
	{
		CC_SAFE_DELETE (m_pkPicFocus);
	}

	if (m_pkLongTouchTimer)
	{
		m_pkLongTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);

		delete m_pkLongTouchTimer;

		m_pkLongTouchTimer = NULL;
	}

	if(this == m_pkLayerPress && !CanDispatchEvent())
	{
		EndDispatchEvent();
	}
}

void NDUILayer::Initialization()
{
	m_ccNode = new NDBaseLayer;

	NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
	layer->SetUILayer(this);
	layer->setTouchEnabled(true);

	this->SetFrameRect(CGRectZero);
}
void NDUILayer::SetTouchEnabled(bool bEnabled)
{
	NDAsssert(m_ccNode != NULL);

	NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
	layer->setTouchEnabled(bEnabled);
}

void NDUILayer::SwallowDragInEvent(bool swallow)
{
	m_bSwallowDragIn = swallow;
}

void NDUILayer::SwallowDragOverEvent(bool swallow)
{
	m_bSwallowDragOver = swallow;
}

void NDUILayer::SetDragOverEnabled(bool bEnabled)
{
	m_bEnableDragOver = bEnabled;
}

void NDUILayer::OnCanceledTouch()
{
	if (this == m_pkLayerPress && !CanDispatchEvent()) 
	{
		EndDispatchEvent();
	}
}

void NDUILayer::SetBackgroundImage(const char* imageFile)
{
	CC_SAFE_RELEASE_NULL (m_pkBackgroudTexture);
	if (!imageFile)
	{
		return;
	}

	CCImage image;
	image.initWithImageFile(imageFile);
	m_pkBackgroudTexture = new CCTexture2D;
	m_pkBackgroudTexture->initWithImage(&image);
}

void NDUILayer::SetBackgroundImageLua(NDPicture *pic)
{
	this->SetBackgroundImage(pic, true);
}

void NDUILayer::SetBackgroundImage(NDPicture *pic,
		bool bClearOnFree /*= fasle*/)
{
	if (m_bClearOnFree)
	{
		delete m_pkPic;
	}

	m_pkPic = pic;

	m_bClearOnFree = bClearOnFree;
}

void NDUILayer::SetBackgroundFocusImageLua(NDPicture *pic)
{
	this->SetBackgroundFocusImage(pic, true);
}

void NDUILayer::SetBackgroundFocusImage(NDPicture *pic,
		bool bClearOnFree /*= fasle*/)
{
	if (m_bFocusClearOnFree)
	{
		delete m_pkPicFocus;
	}

	m_pkPicFocus = pic;

	m_bFocusClearOnFree = bClearOnFree;
}

void NDUILayer::SetBackgroundColor(ccColor4B color)
{
	m_kBackgroudColor = ccc4(color.r, color.g, color.b, color.a);
}

void NDUILayer::SetFocus(NDUINode* node)
{
	m_pkFocusNode = node;
}

NDUINode* NDUILayer::GetFocus()
{
	return m_pkFocusNode;
}

void NDUILayer::draw()
{
	if (!NDDebugOpt::getDrawUIEnabled()) return;

	NDUINode::draw();

	if (this->IsVisibled())
	{
//			if (m_focusNode == NULL)
//				if (this->GetChildren().size() > 0)
//					m_focusNode = (NDUINode*)this->GetChildren().at(0);

		bool focus = false;

		if (m_pkPicFocus && this->GetParent()
				&& this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
		{
			NDUILayer *layer = ((NDUILayer*) (this->GetParent()));
			if (layer->GetFocus() == this)
				focus = true;
		}

		CGRect scrRect = this->GetScreenRect();

		NDPicture* pic =
				focus ? (m_pkPicFocus == NULL ? m_pkPic : m_pkPicFocus) : m_pkPic;

		if (pic)
		{
			DrawSetup( kCCShader_PositionColor );
			DrawRecttangle(scrRect, m_kBackgroudColor);

			pic->DrawInRect(scrRect);
		}
		else
		{
// 			ccColor4B kColor =
// 			{ 0 };
// 
// 			m_kBackgroudColor = kColor;
			DrawSetup( kCCShader_PositionColor );
			DrawRecttangle(scrRect, m_kBackgroudColor);
			
			if (m_pkBackgroudTexture)
			{
				//glDisableClientState(GL_COLOR_ARRAY);

				m_pkBackgroudTexture->drawInRect(scrRect);

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

	NDNode* pNode = this->GetParent();

	if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
	{
		bVisible = ((NDUILayer*) pNode)->IsVisibled();
	}

	return bVisible;
}

bool NDUILayer::UITouchBegin(NDTouch* touch)
{
//		if (!canDispatchEvent()) 
//		{
//			return false;
//		}

	StartDispatchEvent();

	ResetEventParam();

	if (!TouchBegin(touch))
	{
		EndDispatchEvent();

		return false;
	}

	return true;
}

void NDUILayer::UITouchEnd(NDTouch* touch)
{
	if (m_pkLongTouchTimer)
		m_pkLongTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);

	if (TouchEnd(touch))
	{
		EndDispatchEvent();

		return;
	}

	if (ms_bPressing)
	{
		if (m_bEnableMove && m_bTouchMoved && m_bLayerMoved)
		{
			DispatchLayerMoveEvent(m_kBeginTouch, touch);
		}
	}

	EndDispatchEvent();
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

	m_bDispatchTouchEndEvent = true;
	m_kBeginTouch = touch->GetLocation();

	//add by zhangdi 20120828
// 	float fScale = NDDirector::DefaultDirector()->GetScaleFactor();
// 	CGPoint tmpTouch = CGPointMake(m_kBeginTouch.x * fScale, m_kBeginTouch.y * fScale);//@todo
	CGPoint tmpTouch = CGPointMake(m_kBeginTouch.x, m_kBeginTouch.y);
	m_kBeginTouch = tmpTouch;

	//	if (CGRectContainsPoint(this->GetScreenRect(), m_beginTouch) && this->IsVisibled() && this->EventEnabled())
	//if (CGRectContainsPoint(CGRectMake(0, 0, 960, 640), m_beginTouch) && this->IsVisibled() && this->EventEnabled())
	if (CGRectContainsPoint(this->GetScreenRect(), m_kBeginTouch)
			&& this->IsVisibled() && this->EventEnabled())
	{
		bool bRet = this->DispatchTouchBeginEvent(m_kBeginTouch);
		//this->DispatchTouchEndEvent(m_beginTouch, m_beginTouch);

		// 长按开始
		if (bRet && m_pkTouchedNode && m_pkLongTouchTimer)
		{
			m_pkLongTouchTimer->SetTimer(this, LONG_TOUCH_TIMER_TAG, LONG_TOUCH_TIME);
		}

		return bRet;
	}
	return false;
}

bool NDUILayer::TouchEnd(NDTouch* touch)
{
	m_kEndTouch = touch->GetLocation();


	//add by zhangdi 20120828
//	float fScale = NDDirector::DefaultDirector()->GetScaleFactor();
//	CGPoint tmpTouch = CGPointMake(m_kEndTouch.x * fScale, m_kEndTouch.y * fScale);//@todo
	CGPoint tmpTouch = CGPointMake(m_kEndTouch.x, m_kEndTouch.y);//@todo
	m_kEndTouch = tmpTouch;

	if (m_pkDragOverNode)
	{
		if (m_pkDragOverNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButtonDelegate* delegate =
					dynamic_cast<NDUIButtonDelegate*>(m_pkDragOverNode->GetDelegate());

			if (delegate)
			{
				delegate->OnButtonDragOver((NDUIButton*) m_pkDragOverNode,
						false);
			}
		}
	}

	if (m_bDispatchLongTouchEvent)
	{
		DispatchLongTouchEvent(m_kBeginTouch, false);
		m_bDispatchLongTouchEvent = false;
	}

	// 长按
	if (m_bLongTouch && !m_bDragOutFlag && !m_bLayerMoved)
	{
		// 都取超始点是由于用户抬起点容易超出作用范围
		if (DispatchLongTouchClickEvent(m_kBeginTouch, m_kBeginTouch))
		{
			return true;
		}
	}

	if (m_bDispatchTouchEndEvent && !m_bLayerMoved)
	{
		//add by zhangdi 20120828
// 			float scale = NDDirector::DefaultDirector()->GetScaleFactor();
// 			CGPoint beginTouch = CGPointMake(m_beginTouch.x*scale, m_beginTouch.y*scale);
//			if ( this->DispatchTouchEndEvent(beginTouch, beginTouch) )
		if (this->DispatchTouchEndEvent(m_kBeginTouch, m_kBeginTouch))
		{
			return true;
		}
	}

	// 拖出结束
	if (m_bDragOutFlag && !m_bLayerMoved)
	{
		DispatchDragOutCompleteEvent(m_kBeginTouch, m_kEndTouch, m_bLongTouch);
	}

	// 拖入
	if (m_bDragOutFlag && !m_bLayerMoved)
	{
		if (!DispatchDragInEvent(m_pkTouchedNode, m_kBeginTouch, m_kEndTouch,
				m_bLongTouch, true))
		{
			NDNode *node = this;

			while ((node = node->GetParent())
					&& node->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
			{
				if (((NDUILayer*) node)->DispatchDragInEvent(m_pkTouchedNode,
						m_kBeginTouch, m_kEndTouch, m_bLongTouch, true))
				{
					return true;
				}
			}

			if(node && node->IsKindOfClass(RUNTIME_CLASS(NDScene)))
			{
				const std::vector<NDNode *>& childs = node->GetChildren();
				std::vector<NDNode *>::const_iterator it = childs.begin();
				for(; it != childs.end(); it++)
				{
					NDNode* node = *it;
					if(node && node->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
					{
						if(((NDUILayer *)node)->DispatchDragInEvent(m_pkTouchedNode, m_kBeginTouch, m_kEndTouch, m_bLongTouch, true))
						{
							return true;
						}
					}
				}
			}
		}
		else
		{
			return true;
		}
		//return DispatchDragInEvent(m_beginTouch, m_endTouch, m_longTouch, true);
	}

	m_nIsHVFirestTemp = 0;

	return false;
}

void NDUILayer::TouchCancelled(NDTouch* touch)
{
	m_nIsHVFirestTemp = 0;
}

bool NDUILayer::TouchMoved(NDTouch* touch)
{
	CGPoint kMoveTouch = touch->GetLocation();

	if (m_pkTouchedNode && m_bDispatchTouchEndEvent)
	{
		DealTouchNodeState(false);
		m_bDispatchTouchEndEvent = false;
	}

	if (m_bDispatchLongTouchEvent)
	{
		DispatchLongTouchEvent(m_kBeginTouch, false);
		m_bDispatchLongTouchEvent = false;
	}

	m_bTouchMoved = true;

	// 长按
	if (m_pkTouchedNode)
	{
		DispatchDragOverEvent(m_kBeginTouch, kMoveTouch);

		CGRect nodeFrame = m_pkTouchedNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (!m_bLayerMoved
				&& (CGRectContainsPoint(nodeFrame, kMoveTouch) || m_bDragOutFlag))
		{
			if (m_pkLongTouchTimer)
				m_pkLongTouchTimer->KillTimer(this, LONG_TOUCH_TIMER_TAG);

			if (m_bLongTouch
					&& DispatchDragOutEvent(m_kBeginTouch, kMoveTouch,
							m_bLongTouch))
			{ //拖出
				m_bDragOutFlag = true;
				return true;
			}
		}
	}

	if (m_bEnableMove && !m_bDragOutFlag)
	{
		bool bRet = DispatchLayerMoveEvent(m_kBeginTouch, touch);

		if (bRet)
		{
			m_bLayerMoved = true;
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

	m_bDispatchTouchEndEvent = true;
	m_kBeginTouch = touch->GetLocation();

	if (CGRectContainsPoint(this->GetScreenRect(), m_kBeginTouch)
			&& this->IsVisibled() && this->EventEnabled())
	{
		this->DispatchTouchDoubleClickEvent(m_kBeginTouch);

		return true;
	}
	return false;
}

bool NDUILayer::DispatchTouchBeginEvent(CGPoint beginTouch)
{
	m_pkTouchedNode = NULL;

	if (!this->IsVisibled())
	{
		return false;
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{
		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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

		//** chh 2012-07-21 **//
		if(uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
		{
			continue;
		}

		//touch event deal.....
		CGRect nodeFrame = uiNode->GetScreenRect();

		if (CGRectContainsPoint(nodeFrame, beginTouch))
		{
			//NDUILayer need dispatch event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
			{
				NDUILayer* uiLayer = (NDUILayer*) uiNode;
				if (uiLayer->DispatchTouchBeginEvent(beginTouch))
					return true;
				else
					continue;
			}

			//按钮播放音效
			if(uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				//
			}

			m_pkTouchedNode = uiNode;
			DealTouchNodeState(true);
			return true;
		}
	}
	return false;
}

bool NDUILayer::DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch)
{
	if (m_pkTouchedNode)
	{
		DealTouchNodeState(false);
	}

	if (!this->IsVisibled())
	{
		return false;
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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
		CGRect pkNodeFrame = uiNode->GetScreenRect();
		//pkNodeFrame = RectAdd(pkNodeFrame, 2);

		if (CGRectContainsPoint(pkNodeFrame, endTouch))
		{
			if (CGRectContainsPoint(pkNodeFrame, beginTouch))
			{
				//set focus
				m_pkFocusNode = uiNode;

				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
				{
					NDUILayer* uiLayer = (NDUILayer*) uiNode;

					if (uiLayer->DispatchTouchEndEvent(beginTouch, endTouch))
					{
						return true;
					}
					else
					{
						continue;
					}
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
				 else*/if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					if (((NDUIButton*) uiNode)->IsGray())
					{
						return true;
					}
					uiNode->DispatchClickOfViewr(uiNode);

					NDUIButtonDelegate* delegate =
							dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());

					if (delegate)
					{
						delegate->OnButtonClick((NDUIButton*) uiNode);
						return true;
					}
					NDUITargetDelegate* targetDelegate =
							uiNode->GetTargetDelegate();
					if (targetDelegate)
					{
						targetDelegate->OnTargetBtnEvent(uiNode,
								TE_TOUCH_BTN_CLICK);

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

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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
				NDUILayer* uiLayer = (NDUILayer*) uiNode;
				if (uiLayer->DispatchTouchDoubleClickEvent(beginTouch))
					return true;
				else
					continue;
			}

			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				if (((NDUIButton*) uiNode)->IsGray())
				{
					return true;
				}

				NDUITargetDelegate* targetDelegate =
						uiNode->GetTargetDelegate();
				if (targetDelegate)
				{
					targetDelegate->OnTargetBtnEvent(uiNode,
							TE_TOUCH_BTN_DOUBLE_CLICK);

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
	if (m_pkTouchedNode && m_bDispatchTouchEndEvent)
	{
		//NDUIButton must clear touch down event on touch up
		if (m_pkTouchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButton* uiButton = (NDUIButton*)m_pkTouchedNode;
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
	if (m_pkTouchedNode)
	{
		//NDUIButton must clear touch down event on touch up
		if (m_pkTouchedNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButton* uiButton = (NDUIButton*) m_pkTouchedNode;
			uiButton->OnLongTouchDown(down);
		}
	}
}

void NDUILayer::SetScrollEnabled(bool bEnabled)
{
	m_bEnableMove = bEnabled;
}

void NDUILayer::OnTimer(OBJID tag)
{
	if (m_pkLongTouchTimer && tag == LONG_TOUCH_TIMER_TAG)
	{
		m_pkLongTouchTimer->KillTimer(this, tag);

		m_bLongTouch = true;

		DispatchLongTouchEvent(m_kBeginTouch, true);

		m_bDispatchLongTouchEvent = true;
	}
}

bool NDUILayer::DispatchLongTouchClickEvent(CGPoint beginTouch,
		CGPoint endTouch)
{
	if (m_pkTouchedNode)
	{
		DealTouchNodeState(false);
	}

	if (!this->IsVisibled())
	{
		return false;
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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
				m_pkFocusNode = uiNode;

				//NDUILayer need dispatch event
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
				{
					NDUILayer* uiLayer = (NDUILayer*) uiNode;
					if (uiLayer->DispatchLongTouchClickEvent(beginTouch,
							endTouch))
						return true;
					else
						continue;
				}

				//onclick event......
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
				{
					NDUIButtonDelegate* delegate =
							dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
					if (delegate
							&& delegate->OnButtonLongClick(
									(NDUIButton*) uiNode))
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
	if (!m_pkTouchedNode || m_bTouchMoved)
		return false;

	DealLongTouchNodeState(touch);

	NDUINode* uiNode = m_pkTouchedNode;

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
			NDUILayer* uiLayer = (NDUILayer*) uiNode;
			if (uiLayer->DispatchLongTouchEvent(beginTouch, touch))
				return true;
			else
				return false;
		}

		//onclick event......
		if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButtonDelegate* delegate =
					dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
			if (touch && delegate
					&& delegate->OnButtonLongTouch((NDUIButton*) uiNode))
			{
				return true;
			}

			if (!touch && delegate
					&& delegate->OnButtonLongTouchCancel((NDUIButton*) uiNode))
			{
				return true;
			}
		}
	}

	return false;
}

bool NDUILayer::DispatchDragOutEvent(CGPoint beginTouch, CGPoint moveTouch,
		bool longTouch/*=false*/)
{
	if (!m_pkTouchedNode)
		return false;

	if (!this->IsVisibled())
	{
		return false;
	}

	//m_focusNode = m_touchedNode;

	NDUINode* uiNode = m_pkTouchedNode;

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
	if (CGRectContainsPoint(nodeFrame, moveTouch) || m_bDragOutFlag)
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
			if (((NDUIButton*) uiNode)->IsGray())
			{
				return false;
			}

			NDUIButtonDelegate* delegate =
					dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
			if (delegate
					&& delegate->OnButtonDragOut((NDUIButton*) uiNode,
							beginTouch, moveTouch, longTouch))
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

bool NDUILayer::DispatchDragOutCompleteEvent(CGPoint beginTouch,
		CGPoint endTouch, bool longTouch/*=false*/)
{
	if (!m_pkTouchedNode)
		return false;

	NDUINode* uiNode = m_pkTouchedNode;

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
		NDUIButtonDelegate* delegate =
				dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
		if (delegate
				&& delegate->OnButtonDragOutComplete((NDUIButton*) uiNode,
						endTouch, !CGRectContainsPoint(nodeFrame, endTouch)))
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

bool NDUILayer::DispatchDragInEvent(NDUINode* dragOutNode, CGPoint beginTouch,
		CGPoint endTouch, bool longTouch, bool dealByDefault/*=false*/)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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
				NDUILayer* uiLayer = (NDUILayer*) uiNode;
				if (uiLayer->DispatchDragInEvent(dragOutNode, beginTouch,
						endTouch, longTouch))
					return true;
				else
					continue;
			}

			//onclick event......
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				NDUIButtonDelegate* delegate =
						dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
				if (delegate
						&& delegate->OnButtonDragIn((NDUIButton*) uiNode,
								dragOutNode, longTouch))
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

	if (m_bSwallowDragIn)
		return true;

	return false;
}

bool NDUILayer::DispatchDragOverEvent(CGPoint beginTouch, CGPoint moveTouch,
		bool longTouch/*=false*/)
{
	if (!m_bEnableDragOver)
		return false;

	if (!this->IsVisibled())
	{
		return false;
	}

	if (m_pkDragOverNode)
	{
		CGRect nodeFrame = m_pkDragOverNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		bool isInRange = CGRectContainsPoint(nodeFrame, moveTouch);
		if (m_pkDragOverNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			NDUIButtonDelegate* delegate =
					dynamic_cast<NDUIButtonDelegate*>(m_pkDragOverNode->GetDelegate());

			if (!delegate)
				return false;

			if (isInRange)
				return true;

			delegate->OnButtonDragOver((NDUIButton*) m_pkDragOverNode, false);
		}
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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
				NDUILayer* uiLayer = (NDUILayer*) uiNode;
				if (uiLayer->DispatchDragOverEvent(beginTouch, moveTouch,
						longTouch))
					return true;
				else
					continue;
			}

			//onclick event......
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
			{
				NDUIButtonDelegate* delegate =
						dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
				if (delegate
						&& delegate->OnButtonDragOver((NDUIButton*) uiNode,
								true))
				{
					m_pkDragOverNode = uiNode;
					return true;
				}
			}
		}
	}

	if (m_bSwallowDragOver)
		return true;

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
	if (!m_bMoveOutListener
			&& !CGRectContainsPoint(this->GetScreenRect(),
					moveTouch->GetLocation()))
	{
		return false;
	}

	if (!this->IsVisibled())
	{
		return false;
	}

	for (int i = this->GetChildren().size() - 1; i >= 0; i--)
	{

		NDUINode* uiNode = (NDUINode*) this->GetChildren().at(i);

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

		if (CGRectContainsPoint(nodeFrame, beginPoint)
				&& CGRectContainsPoint(nodeFrame, moveTouch->GetLocation()))
		{
			//set focus
			//m_focusNode = uiNode;

			//NDUILayer need dispatch event
			if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
			{
				NDUILayer* uiLayer = (NDUILayer*) uiNode;
				if (uiLayer->DispatchLayerMoveEvent(beginPoint, moveTouch))
					return true;
				else
					continue;
			}
		}
	}

	// slef deal
	NDUILayerDelegate* delegate =
			dynamic_cast<NDUILayerDelegate*>(this->GetDelegate());
	if (!delegate)
	{
		return false;
	}

	CGPoint prePos = moveTouch->GetPreviousLocation();
	CGPoint curPos = moveTouch->GetLocation();

	m_kMoveTouch = curPos;

	float horizontal = curPos.x - prePos.x, vertical = curPos.y - prePos.y;
	//tmpHorizontal = curPos.x - beginPoint.x,
	//tmpVertical = curPos.y - beginPoint.y;

	bool bReturn = false;

	//tmpHorizontal = tmpHorizontal > 0.0f ? tmpHorizontal : -tmpHorizontal;

	//tmpVertical = tmpVertical > 0.0f ? tmpVertical : -tmpVertical;

// 	if(m_nIsHVFirestTemp)
// 	{
// 		NDNode *pNode = this->GetParent()->GetParent();
// 		if(pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
// 		{
// 			//
// 		}
// 	}

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
	m_bLongTouch = false;

	m_bTouchMoved = false;

	m_bDragOutFlag = false;

	m_bLayerMoved = false;

	m_pkDragOverNode = NULL;
}

CGRect NDUILayer::RectAdd(CGRect rect, int value)
{
	return CGRectMake(rect.origin.x - value, rect.origin.y - value,
			rect.size.width + 2 * value, rect.size.height + 2 * value);
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
	bool NDUILayer::CanDispatchEvent()
	{
		return !ms_bPressing;
	}
	void NDUILayer::StartDispatchEvent()
	{
		ms_bPressing  = true;
		
		m_pkLayerPress = this;
	}
	
	void NDUILayer::EndDispatchEvent()
	{
		ms_bPressing = false;
		
		m_pkLayerPress = NULL;
	}

	bool NDUILayer::IsTouchDown()
	{
		return m_bTouchDwon;
	}
}
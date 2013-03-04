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
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#else
//#include <GLES/gl.h>
#endif
//#include "NDIphoneEdit.h"
#include "NDUIButton.h"
#include "cocos2dExt.h"
//#include "NDUIOptionButton.h"
//#include "NDUICheckBox.h"
//#include "NDUITableLayer.h"
#include "NDBaseLayer.h"
//#include "NDUIMemo.h"
//#include "NDUtil.h"
//#include "cpLog.h"
//#include "NDTextNode.h"
//#include "NDUtil.h"
//#include "NDUIOptionButtonEx.h"
//#include "NDUIDefaultTableLayer.h"
#include "NDTargetEvent.h"
#include "CCImage.h"
#include "NDUIBaseGraphics.h"
#include "UtilityInc.h"
#include "NDDirector.h"
#include "NDUIImage.h"
#include "NDDebugOpt.h"
#include "BaseType.h"
#include "NDUIScrollViewMulHand.h"
#include "ObjectTracker.h"
#include "NDUIChatText.h"
#include "UIEdit.h"
#include "UICheckBox.h"
#include "NDUICheckBox.h"
#include "NDUIHyperLink.h"

using namespace cocos2d;

//抖动容错
#define MOVE_ERROR (64*RESOURCE_SCALE)

//按下按钮等同点击
#define PRESSDOWN_BTN_EQ_CLICK 0

//长按的时间判定太短会导致单击判定无效.
#define LONG_TOUCH_TIME (0.4f)

#define LONG_TOUCH_TIMER_TAG (6951)

#define LAZY_DELETE_TIMER_TAG (99)

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDUILayer, NDUINode)

bool NDUILayer::ms_bPressing = false;
NDUILayer* NDUILayer::m_pkLayerPress = 0;

NDUILayer::NDUILayer()
{
	INC_NDOBJ_RTCLS

	m_strDebugName = "NDUILayer";

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

	m_kMoveTouch = CCPointZero;

	m_bHorizontal = false;

	m_bMoveOutListener = false;
	m_bTouchDwon = false;

	m_nIsHVFirstTemp = 0;
	m_bIsHVContainer = false;
	m_bPopupDlg = false;

	m_bDispatchBtnClickByPressDown = false;

	m_pLazyDeleteTimer = new NDTimer;
}

NDUILayer::~NDUILayer()
{
	DEC_NDOBJ_RTCLS

	CC_SAFE_RELEASE_NULL (m_pkBackgroudTexture);

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
	layer->setDebugName( m_strDebugName.c_str() );

	SetFrameRect(CCRectZero);
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
    
	//m_pkBackgroudTexture = new CCTexture2D;
	m_pkBackgroudTexture = CCTexture2D::create();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || !ENABLE_PAL_MODE)
	CCImage image;
	image.initWithImageFile(imageFile);
	m_pkBackgroudTexture->initWithImage(&image);
#else
    m_pkBackgroudTexture->initWithPalettePNG(imageFile);
#endif
}

void NDUILayer::SetBackgroundImageLua(NDPicture *pic)
{
	SetBackgroundImage(pic, true);
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
	SetBackgroundFocusImage(pic, true);
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
	if (!isDrawEnabled()) return;

	NDUINode::draw();

	if (IsVisibled())
	{
//			if (m_focusNode == NULL)
//				if (GetChildren().size() > 0)
//					m_focusNode = (NDUINode*)GetChildren().at(0);

		bool focus = false;

		if (m_pkPicFocus && GetParent()
				&& GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
		{
			NDUILayer *layer = ((NDUILayer*) (GetParent()));
			if (layer->GetFocus() == this)
				focus = true;
		}

		CCRect scrRect = GetScreenRect();

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
			//DrawRecttangle(scrRect, m_kBackgroudColor);
			//++修正坐标和尺寸，Guosen 2012.12.4
			ConvertUtil::convertToPointCoord( scrRect );
			CCRect tRect = CCRectMake(scrRect.origin.x,SCREEN2GL_Y(scrRect.origin.y)-scrRect.size.height,scrRect.size.width,scrRect.size.height);
			DrawRecttangle(tRect, m_kBackgroudColor);
			
			if (m_pkBackgroudTexture)
			{
				//glDisableClientState(GL_COLOR_ARRAY);

				m_pkBackgroudTexture->drawInRect(scrRect);

				//glEnableClientState(GL_COLOR_ARRAY);
			}
		}
	}

	debugDraw();
}

bool NDUILayer::IsVisibled()
{
	bool bVisible = NDUINode::IsVisibled();
	if (!bVisible)
	{
		return bVisible;
	}

	NDNode* pNode = GetParent();

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

	if(ms_bPressing)
		return false;

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
	if (!IsVisibled())
	{
		return false;
	}

	m_bDispatchTouchEndEvent = true;
	m_kBeginTouch = touch->GetLocation();

// 	CCRect kRect(m_kBeginTouch.x - 20,m_kBeginTouch.y - 20,40,40);
// 	ccColor4B kColor = {100,100,100,255};
// 	DrawRecttangle(kRect,kColor);

	if (cocos2d::CCRect::CCRectContainsPoint(GetScreenRect(), m_kBeginTouch)
			&& IsVisibled() && EventEnabled())
	{
		m_bTouchDwon = true;
		DispatchTouchBeginEvent(m_kBeginTouch);

		if (m_bDispatchBtnClickByPressDown)
		{
			m_bDispatchBtnClickByPressDown = false;
		}

		// 开始定时器判定长按
		else if (m_pkTouchedNode && m_pkLongTouchTimer)
		{
			m_pkLongTouchTimer->SetTimer(this, LONG_TOUCH_TIMER_TAG, LONG_TOUCH_TIME);
		}

		return true;
	}
	return false;
}

bool NDUILayer::TouchEnd(NDTouch* touch)
{
	if (!IsVisibled())
	{
		return false;
	}

	m_kEndTouch = touch->GetLocation();

	m_bTouchDwon = false;

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
	//if (m_bLongTouch && !m_bDragOutFlag && !isTouchMoved(MOVE_ERROR))
	{
		// 都取超始点是由于用户抬起点容易超出作用范围
		if (DispatchLongTouchClickEvent(m_kBeginTouch, m_kBeginTouch))
		{
			// 长按会抢了单击事件，导致手机操作感比较差，先兼容一下.
			if (m_bDispatchTouchEndEvent && !m_bLayerMoved)
			{
				DispatchTouchEndEvent(m_kBeginTouch, m_kBeginTouch);
			}
			return true;
		}
	}

	// 单击
	if (m_bDispatchTouchEndEvent && !m_bLayerMoved)
	//if (m_bDispatchTouchEndEvent && !isTouchMoved(MOVE_ERROR))
	{
		if (DispatchTouchEndEvent(m_kBeginTouch, m_kBeginTouch))
		{
			return true;
		}
	}

	// 拖出结束
	if (m_bDragOutFlag && !m_bLayerMoved)
	//if (m_bDragOutFlag && !isTouchMoved(MOVE_ERROR))
	{
		DispatchDragOutCompleteEvent(m_kBeginTouch, m_kEndTouch, m_bLongTouch);
	}

	// 拖入
	if (m_bDragOutFlag && !m_bLayerMoved)
	//if (m_bDragOutFlag && !isTouchMoved(MOVE_ERROR))
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

	m_nIsHVFirstTemp = 0;

	return false;
}

void NDUILayer::TouchCancelled(NDTouch* touch)
{
	m_nIsHVFirstTemp = 0;
}

bool NDUILayer::TouchMoved(NDTouch* touch)
{
	if (!IsVisibled())
	{
		return false;
	}

	CCPoint kMoveTouch = touch->GetLocation();

	// if really moved, android like to send move event even when not moved.
	if (m_bDispatchTouchEndEvent)
	{
		//如果点在按钮上则允许抖动容错，否则不容错（任何微小移动都视为拖动）
		if ((!m_bLongTouch)
			&& this->IsTouchOnButton( kMoveTouch )
			&& ccpDistanceSQ( m_kBeginTouch, kMoveTouch ) < MOVE_ERROR*MOVE_ERROR )
		{
			return true; //consume it.
		}
	}

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

		CCRect nodeFrame = m_pkTouchedNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (!m_bLayerMoved
				&& (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, kMoveTouch) || m_bDragOutFlag))
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
	if (!IsVisibled())
	{
		return false;
	}

	m_bDispatchTouchEndEvent = true;
	m_kBeginTouch = touch->GetLocation();

	if (cocos2d::CCRect::CCRectContainsPoint(GetScreenRect(), m_kBeginTouch)
			&& IsVisibled() && EventEnabled())
	{
		DispatchTouchDoubleClickEvent(m_kBeginTouch);

		return true;
	}
	return false;
}

bool NDUILayer::DispatchTouchBeginEvent(CCPoint beginTouch)
{
	m_pkTouchedNode = NULL;

	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetBoundRect();//uiNode->GetScreenRect();

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginTouch))
		{
			//按钮点击优化：按下时直接响应单击事件
			if (TryDispatchToButton(uiNode)) return false; //discard.

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

bool NDUILayer::DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch)
{
	if (m_pkTouchedNode)
	{
		DealTouchNodeState(false);
	}

	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect pkNodeFrame = uiNode->GetBoundRect();
		//pkNodeFrame = RectAdd(pkNodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(pkNodeFrame, endTouch))
		{
			if (cocos2d::CCRect::CCRectContainsPoint(pkNodeFrame, beginTouch))
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
				 AfterEditClickEvent((NDUIEdit*)uiNode);
				 }
				 else
				 AfterEditClickEvent((NDUIEdit*)uiNode);
				 return true;
				 }
				 else*/
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
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
					else if (uiNode->IsKindOfClass(RUNTIME_CLASS(CUIChatText)))
					{
						CUIChatText *uiText = (CUIChatText *)uiNode;
						uiText->OnTextClick(endTouch);
						return false;
					}
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

bool NDUILayer::DispatchTouchDoubleClickEvent(CCPoint beginTouch)
{
	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginTouch))
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
	else if (m_pLazyDeleteTimer && tag == LAZY_DELETE_TIMER_TAG) //@lazydel
	{
		m_pLazyDeleteTimer->KillTimer( this, tag );
		this->RemoveFromParent( true );
	}
}

void NDUILayer::lazyDelete() //@lazydel
{
	if (m_pLazyDeleteTimer)
		m_pLazyDeleteTimer->SetTimer(this, LAZY_DELETE_TIMER_TAG, 0.1f); 
}

bool NDUILayer::DispatchLongTouchClickEvent(CCPoint beginTouch,
		CCPoint endTouch)
{
	if (m_pkTouchedNode)
	{
		DealTouchNodeState(false);
	}

	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, endTouch))
		{
			if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginTouch))
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

bool NDUILayer::DispatchLongTouchEvent(CCPoint beginTouch, bool touch)
{
	if (!m_pkTouchedNode || m_bTouchMoved)
		return false;

	DealLongTouchNodeState(touch);

	NDUINode* uiNode = m_pkTouchedNode;

	if (!IsVisibled())
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
	CCRect nodeFrame = uiNode->GetScreenRect();
	nodeFrame = RectAdd(nodeFrame, 2);

	if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginTouch))
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

bool NDUILayer::DispatchDragOutEvent(CCPoint beginTouch, CCPoint moveTouch,
		bool longTouch/*=false*/)
{
	if (!m_pkTouchedNode)
		return false;

	if (!IsVisibled())
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
	CCRect nodeFrame = uiNode->GetScreenRect();
	nodeFrame = RectAdd(nodeFrame, 2);

//		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginTouch)) 
//		{
	if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, moveTouch) || m_bDragOutFlag)
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

bool NDUILayer::DispatchDragOutCompleteEvent(CCPoint beginTouch,
		CCPoint endTouch, bool longTouch/*=false*/)
{
	if (!m_pkTouchedNode)
		return false;

	NDUINode* uiNode = m_pkTouchedNode;

	if (!IsVisibled())
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
	CCRect nodeFrame = uiNode->GetScreenRect();
	nodeFrame = RectAdd(nodeFrame, 2);

	//onclick event......
	if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		NDUIButtonDelegate* delegate =
				dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());
		if (delegate
				&& delegate->OnButtonDragOutComplete((NDUIButton*) uiNode,
						endTouch, !cocos2d::CCRect::CCRectContainsPoint(nodeFrame, endTouch)))
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

bool NDUILayer::DispatchDragInEvent(NDUINode* dragOutNode, CCPoint beginTouch,
		CCPoint endTouch, bool longTouch, bool dealByDefault/*=false*/)
{
	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, endTouch))
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

bool NDUILayer::DispatchDragOverEvent(CCPoint beginTouch, CCPoint moveTouch,
		bool longTouch/*=false*/)
{
	if (!m_bEnableDragOver)
		return false;

	if (!IsVisibled())
	{
		return false;
	}

	if (m_pkDragOverNode)
	{
		CCRect nodeFrame = m_pkDragOverNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		bool isInRange = cocos2d::CCRect::CCRectContainsPoint(nodeFrame, moveTouch);
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

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, moveTouch))
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

//		NDNode *pNode = GetParent();
//		
//		if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer)))
//		{
//			return ((NDUILayer*)pNode)->DispatchDragOverEvent(beginTouch, moveTouch, longTouch);
//		}

	return false;
}

bool NDUILayer::DispatchLayerMoveEvent(CCPoint beginPoint, NDTouch *moveTouch)
{
	if (!m_bMoveOutListener
			&& !cocos2d::CCRect::CCRectContainsPoint(GetScreenRect(),
					moveTouch->GetLocation()))
	{
		return false;
	}

	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{

		//NDUINode* uiNode = (NDUINode*) GetChildren().at(i);//--Guosen 2012.11.21
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode) ) )
		{
			continue;
		}
		NDUINode* uiNode = (NDUINode*)pNode;

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
		CCRect nodeFrame = uiNode->GetScreenRect();
		nodeFrame = RectAdd(nodeFrame, 2);

		if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, beginPoint)
				&& cocos2d::CCRect::CCRectContainsPoint(nodeFrame, moveTouch->GetLocation()))
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
			dynamic_cast<NDUILayerDelegate*>(GetDelegate());
	if (!delegate)
	{
		return false;
	}

	CCPoint prePos = moveTouch->GetPreviousLocation();
	CCPoint curPos = moveTouch->GetLocation();

	m_kMoveTouch = curPos;

	float horizontal = curPos.x - prePos.x, vertical = curPos.y - prePos.y;
	//tmpHorizontal = curPos.x - beginPoint.x,
	//tmpVertical = curPos.y - beginPoint.y;

	bool bReturn = false;

	//tmpHorizontal = tmpHorizontal > 0.0f ? tmpHorizontal : -tmpHorizontal;

	//tmpVertical = tmpVertical > 0.0f ? tmpVertical : -tmpVertical;

 	if(m_bIsHVContainer)
 	{
 		NDNode *pNode = GetParent()->GetParent();
 		if(pNode->IsKindOfClass(RUNTIME_CLASS(CUIScrollViewContainerM)))
 		{
 			CUIScrollViewContainerM *svc = (CUIScrollViewContainerM*)pNode;

// 			if(0 == m_nIsHVFirstTemp)
// 			{
				if(fabs(horizontal) > fabs((vertical)))
				{
					m_nIsHVFirstTemp = 1;
				}
				else
				{
					m_nIsHVFirstTemp = 2;
				}
/*			}*/

			if(m_nIsHVFirstTemp == 1)
			{
				svc->OnScrollViewMove(this, 0, horizontal);
			}
			else if(m_nIsHVFirstTemp == 2)
			{
				svc->OnScrollViewMove(this, vertical, 0);
			}
			return true;
		}
	}

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

CCRect NDUILayer::RectAdd(CCRect rect, int value)
{
	return CCRectMake(rect.origin.x - value, rect.origin.y - value,
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

void NDUILayer::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	CCRect rc = GetFrameRect();
	float l = rc.origin.x;
	float r = l + rc.size.width;
	float t = rc.origin.y;
	float b = t + rc.size.height;

	const float pad = 0.25f;
	l += pad; r -= pad;
	t += pad; b -= pad;

	if (m_bPopupDlg) 
	{
		ccDrawColor4F(0,0,0,1); //black for popup
	}
	else
	{
		NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
		if (layer)
		{
			if (layer->getSubPriority() == 0)
				ccDrawColor4F(1,1,1,1); //white for bringToTop
			else
				ccDrawColor4F(0.5,0.5,0.5,1);//gray for default
		}
	}

	glLineWidth(2);
	ccDrawRect( ccp(l,t), ccp(r,b));

#if 0
	glLineWidth(1);
	ccDrawLine( ccp(l,b), ccp(r,t));
	ccDrawLine( ccp(l,t), ccp(r,b));
#endif
}

//@priority
ND_LAYER_PRIORITY NDUILayer::getPriority()
{
	return m_bPopupDlg
		? E_LAYER_PRIORITY_POPUPDLG
		: E_LAYER_PRIORITY_UILAYER;
}

//@priority
void NDUILayer::bringToTop()
{
	if (m_ccNode)
	{
		NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
		layer->bringToTop();
	}
}

//@priority
void NDUILayer::bringToBottom()
{
	if (m_ccNode)
	{
		NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
		layer->bringToBottom();
	}
}

const char* NDUILayer::getDebugName()
{
	if (m_ccNode)
	{
		NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
		return layer->getDebugName();
	}
	else
	{
		return m_strDebugName.c_str();
	}
}

void NDUILayer::setDebugName( const char* inName )
{
	if (!inName) return;

	m_strDebugName = inName;

	if (m_ccNode)
	{
		NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
		layer->setDebugName( m_strDebugName.c_str() );
	}
}

//防手抖（触摸屏很难准确单击，一般都会有像素移动）
bool NDUILayer::isTouchMoved( const int errorPixels )
{
	if (m_bTouchMoved)
	{
		if (ccpDistanceSQ( m_kBeginTouch, m_kEndTouch ) >= errorPixels*errorPixels)
			return true;
	}
	return false;
}

//按下按钮等同点击
bool NDUILayer::TryDispatchToButton( NDUINode* uiNode )
{
	if( uiNode && PRESSDOWN_BTN_EQ_CLICK 
		&& uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton))
		&& stricmp( uiNode->GetRuntimeClass()->className, "NDUIButton") == 0)
	{
		do {
			if (((NDUIButton*) uiNode)->IsGray())
			{
				break;
			}
			uiNode->DispatchClickOfViewr(uiNode);

			NDUIButtonDelegate* delegate =
				dynamic_cast<NDUIButtonDelegate*>(uiNode->GetDelegate());

			if (delegate)
			{
				delegate->OnButtonClick((NDUIButton*) uiNode);
				break;
			}

			NDUITargetDelegate* targetDelegate = uiNode->GetTargetDelegate();
			if (targetDelegate)
			{
				targetDelegate->OnTargetBtnEvent(uiNode, TE_TOUCH_BTN_CLICK);
				break;
			}

			if (OnScriptUiEvent(uiNode, TE_TOUCH_BTN_CLICK))
			{
				break;
			}
		} while (0);

		// reset flags
		m_bLongTouch = false;
		m_bTouchMoved = false;
		m_bDragOutFlag = false;
		m_bLayerMoved = false;
		m_kMoveTouch = ccp(0,0);
		m_bTouchDwon = false;
		ms_bPressing = false;

		//标记：通过press down派发了一个click事件
		m_bDispatchBtnClickByPressDown = true;
		return true;
	}

	return false;
}

//是否触摸在按钮上（或者编辑框）
bool NDUILayer::IsTouchOnButton( const CCPoint& touch )
{
	if (!IsVisibled())
	{
		return false;
	}

	for (int i = GetChildren().size() - 1; i >= 0; i--)
	{
		NDNode * pNode = GetChildren().at(i);
		if ( !pNode ) continue;

		if (pNode->IsKindOfClass( RUNTIME_CLASS(NDUINode)))
		{
			NDUINode* uiNode = (NDUINode*)pNode;

			if (uiNode->IsVisibled() && uiNode->EventEnabled())
			{
				if (uiNode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)) 
					|| pNode->IsKindOfClass( RUNTIME_CLASS(CUIEdit))
					|| pNode->IsKindOfClass( RUNTIME_CLASS(NDUICheckBox))
					|| pNode->IsKindOfClass( RUNTIME_CLASS(CUICheckBox))
					|| pNode->IsKindOfClass( RUNTIME_CLASS(CUIHyperlinkButton))
					|| pNode->IsKindOfClass( RUNTIME_CLASS(CUIHyperlinkText))
					|| pNode->IsKindOfClass( RUNTIME_CLASS(CUIChatText))
					)
				{
					CCRect nodeFrame = uiNode->GetBoundRect();

					if (cocos2d::CCRect::CCRectContainsPoint(nodeFrame, touch))
					{
						return true;
					}
				}
			}
		}
	}
	return false;
}

NS_NDENGINE_END

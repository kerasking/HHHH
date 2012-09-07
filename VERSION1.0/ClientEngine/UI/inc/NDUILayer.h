//
//  NDUILayer.h
//  DragonDrive
//
//  Created by jhzheng on 10-12-21.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

//	介绍
//	控件容器

// 容器规则简单描述
/*
 原先规则
 1.  touch begin 分发 touch down(true) 事件 产生 touchNode
 2.  touch moved 分发 touch down(false) 事件 且不分发touchEndEvent事件
 3.  touch end（在产生touch move的前提下）分发  touch down(false) 事件  遍历子控件的各种响应事件

 增加规则
 1. 长按事件
 touch begin 开始时设置定时器
 touch end 定时已结束 (先分发长按事件,若未处理则分发响应事件)
 具体实现:
 a.定时器规则 出现touch move取消定时器规则
 2. 拖进与拖出事件(限于层内部子结点)
 拖进 touch end 响应
 拖出  touch begin 响应 touch move 在自己区域以外
 具体实现:
 a.层内部必需出现 touch move(不在自己区域内时)同时分发拖出回调 置存在拖出标志
 b.拖进时必需要有拖出标志
 c.信息传递
 3. 层滚动事件(左或右,上或下)
 触摸过程,所有的控件都没有被处理, 且产生了touch move事件,左右上下判断(touch begin 与 touch end x与y变化大小)
 具体实现:
 */

#ifndef _ND_UI_LAYER_H
#define _ND_UI_LAYER_H

//#include "NDLayer.h"
#include "NDTouch.h"
#include "NDUINode.h"
#include "NDPicture.h"
#include "NDTimer.h"
#include "CCTexture2D.h"

namespace NDEngine
{
typedef enum
{
	UILayerMoveBegin = 0,
	UILayerMoveRight = UILayerMoveBegin,
	UILayerMoveLeft,
	UILayerMoveUp,
	UILayerMoveDown,
	UILayerMoveEnd,
} UILayerMove;

class NDUILayer;

class NDUILayerDelegate
{
public:
	virtual bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move,
			float distance)
	{
		return false;
	}
	virtual bool OnLayerMoveOfDistance(NDUILayer* uiLayer, float hDistance,
			float vDistance)
	{
		return false;
	}
};

class NDUILayer: public NDUINode, public ITimerCallback
{
	DECLARE_CLASS (NDUILayer)
public:
	NDUILayer();
	~NDUILayer();
public:
	void Initialization();override

	void SetBackgroundImage(const char* imageFile);

	void SetBackgroundImage(NDPicture *pic, bool bClearOnFree = false);

	void SetBackgroundImageLua(NDPicture *pic);

	void SetBackgroundFocusImage(NDPicture *pic, bool bClearOnFree = false);

	void SetBackgroundFocusImageLua(NDPicture *pic);

	void SetBackgroundColor(cocos2d::ccColor4B color);

	void SetFocus(NDUINode* node);

	NDUINode* GetFocus();

	bool UITouchBegin(NDTouch* touch);

	virtual void UITouchEnd(NDTouch* touch);

	void UITouchCancelled(NDTouch* touch);

	void UITouchMoved(NDTouch* touch);

	bool UITouchDoubleClick(NDTouch* touch);

	virtual bool TouchBegin(NDTouch* touch);

	virtual bool TouchEnd(NDTouch* touch);

	virtual void TouchCancelled(NDTouch* touch);

	virtual bool TouchMoved(NDTouch* touch);

	virtual bool TouchDoubleClick(NDTouch* touch);

	void SetTouchEnabled(bool bEnabled);

	void SwallowDragInEvent(bool swallow);

	void SwallowDragOverEvent(bool swallow);

	void SetDragOverEnabled(bool bEnabled);

	virtual void OnCanceledTouch();

	void SetScrollHorizontal(bool bSet);
	bool IsScrollHorizontal();

	void SetMoveOutListener(bool bSet);
public:
	void draw();override
	bool IsVisibled();override

public:
	CGPoint m_kBeginTouch;
	CGPoint m_kEndTouch;
	//touch event center
	virtual bool DispatchTouchBeginEvent(CGPoint beginTouch);
	virtual bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch);
	virtual bool DispatchTouchDoubleClickEvent(CGPoint beginTouch);
	// touch node down or up
	void DealTouchNodeState(bool down);
	void DealLongTouchNodeState(bool down);
private:
	NDUINode* m_pkFocusNode;
	NDUINode* m_pkTouchedNode;
	NDUINode* m_pkDragOverNode;

	NDPicture* m_pkPic;
	NDPicture* m_pkPicFocus;
	bool m_bClearOnFree, m_bFocusClearOnFree;
	cocos2d::CCTexture2D* m_pkBackgroudTexture;
	cocos2d::ccColor4B m_kBackgroudColor;

	bool m_bDispatchTouchEndEvent;

	CGRect RectAdd(CGRect rect, int value);
	//NDUIEdit deals
	//void AfterEditClickEvent(NDUIEdit* edit);
public:
	//void IphoneEditInputFinish(NDUIEdit* edit);
	//void IphoneEditInputCancle(NDUIEdit* edit);

	// add new rule by jhzheng 2011.7.30
public:
	void SetScrollEnabled(bool bEnabled);

	void OnTimer(OBJID tag);

	void StartDispatchEvent();
	void EndDispatchEvent();

	virtual bool DispatchLongTouchClickEvent(CGPoint beginTouch,
			CGPoint endTouch);
	virtual bool DispatchLongTouchEvent(CGPoint beginTouch, bool touch);
	virtual bool DispatchDragOutEvent(CGPoint beginTouch, CGPoint moveTouch,
			bool longTouch = false);
	virtual bool DispatchDragOutCompleteEvent(CGPoint beginTouch,
			CGPoint endTouch, bool longTouch = false);
	virtual bool DispatchDragInEvent(NDUINode* dragOutNode, CGPoint beginTouch,
			CGPoint endTouch, bool longTouch, bool dealByDefault = false);
	virtual bool DispatchLayerMoveEvent(CGPoint beginPoint, NDTouch *moveTouch);
	virtual bool DispatchDragOverEvent(CGPoint beginTouch, CGPoint moveTouch,
			bool longTouch = false);

private:

	void ResetEventParam();

protected:

	NDTimer* m_pkLongTouchTimer;

	bool m_bLongTouch;
	bool m_bTouchMoved;
	bool m_bDragOutFlag;
	bool m_bLayerMoved;
	bool m_bEnableMove;
	bool m_bSwallowDragIn;
	bool m_bSwallowDragOver;
	bool m_bEnableDragOver;
	bool m_bHorizontal;
	bool m_bMoveOutListener;
	bool m_bDispatchLongTouchEvent;

	CGPoint m_kMoveTouch;

private:

	static bool ms_bPressing;
	static NDUILayer* m_pkLayerPress;
// 		bool canDispatchEvent();
// 		void StartDispatchEvent();
// 		void EndDispatchEvent();

	DECLARE_AUTOLINK (NDUILayer)
	INTERFACE_AUTOLINK (NDUILayer)
};

}
#endif // _ND_UI_LAYER_H

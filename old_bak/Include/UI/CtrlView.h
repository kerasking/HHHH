/*
 *  CtrlView.h
 *  Created by ndtq on 11-2-15.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __CTRL_VIEW_H__
#define __CTRL_VIEW_H__

#include "wndobject.h"

class CtrlPositionAction;
class IActionCtrl; 

/**
  控件位置监听器
**/
class ICtrlPositionListenner
{
public:
	virtual void CtrlActionCallback(CtrlPositionAction* Sender, CPoint& opInfo, bool bFinished) = 0;
	virtual void CtrlMoveCallback(CPoint& opInfo) = 0;
};

//动作的属性
struct OBJ_ACTIONPOS_INFO
{
	C3DPos posCur;//坐标位置
	float fScaleCur;//缩放

	OBJ_ACTIONPOS_INFO()
	{
		memset(&posCur, 0, sizeof(posCur));
		fScaleCur = 1.0;
	};			
};

/**
  动作监听器
**/
class IActionListenner {
public:
	
	virtual void ActionCallBack(IActionCtrl* Sender, OBJ_ACTIONPOS_INFO& opInfo, bool bFinished) = 0;
};

/**
  控制视图
**/
class CCtrlView : public CWndObject, public IActionListenner,public ICtrlPositionListenner
{
public:
	CCtrlView();
	virtual ~CCtrlView();

public:
	//是否有垂直滚动条
	bool IsSlider()const;

	//设置有垂直滚动条
	void SetSlider(bool slider);

	//获得垂直滚动条的背景图片
	const char* GetSliderAni();

	//设置垂直滚动条的背景图
	void SetSliderAni(const char* lpAni);
	
	//是否有水平滚动条
	bool IsHerSlider()const;
	
	//设置有水平滚动条
	void SetHerSlider(bool slider);

	//获得水平滚动条的背景图片
	const char* GetHerSliderAni();

	//设置水平滚动条的背景图片
	void SetHerSliderAni(const char* lpAni);
	
	//获得滚动条的宽度
	int GetSliderSize()const;
	
	//设置滚动条的宽度
	void SetSliderSize(int size);
	
	//是否允许改变视图原点
//	bool IsChangeViewPos()const;

	//设置是否允许改变视图原点
	//void SetChangeViewPos(bool isAllow=true);

	//处理本窗口和子窗口事件(SendMessage后处理的事件;自定义事件消息名的值不能取系统事件,取MSG_USEREVENT以上的事件)
	virtual bool WndProc(CWndObject* pObj/*触发消息的窗口*/,UINT message,WPARAM wParam, LPARAM lParam);

public:
	
	virtual bool MouseDragHandler(CWndObject* obj,int relateX,int relateY,const void* lpParam=NULL);
	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
	virtual bool MouseDragOverHandler(CWndObject* obj,int relateX,int relateY,const void* lpParam=NULL);

	//执行视图动作时的回调函数
	virtual void ActionCallBack(IActionCtrl* Sender, OBJ_ACTIONPOS_INFO& opInfo, bool bFinished);

	//执行视图位置动作结束的回调函数(改变位置的动作后,判断是否要结束该动作)
	virtual void CtrlActionCallback(CtrlPositionAction* Sender/*执行的动作*/, CPoint& opInfo/*动作执行中当前的坐标*/, bool bFinished/*动作是否执行结束*/) ;

	//鼠标拖动时改变视图的位置的事件
	virtual void CtrlMoveCallback(CPoint& opInfo);

	//bool GoBackPosition();

	//列表类型(2:横向滚动条(在x方向滑动且窗口在X方向可移动;
//	1:纵向向滚动条(在Y方向滑动且窗口在Y方向可移动,在CCtrlList里默认1)
	void SetListType(int listType);

	//设置是否子窗口固定,在父窗口中不能拖动
	void SetFixed(bool bfixed=true);

	//设置子窗口是否固定,在父窗口中不能拖动
	bool IsFixed() const;

protected:	
	//绘制滚动条
	virtual void DoPaintSlider(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	
	
	virtual bool CaluViewPos(int relateX,int relateY,const void* lpParam=NULL);
	
	//virtual void RefWndPro(int iType,CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	int CaluViewX(int relateX,CRect& viewRect);
	int CaluViewY(int relateY,CRect& viewRect);	
	bool IsPress()const;
	void SetPress(bool isPress);
	virtual void DrawVerSlider(CRect& viewSize,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

	//画水平滚动条
	virtual void DrawHerSlider(CRect& viewSize,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);
	
private:
	bool m_bFixed;//是否子窗口固定,在父窗口中不能拖动(默认false)
	int m_listType;//列表类型(2:横向滚动条(在x方向滑动且窗口在X方向可移动)
					//1:纵向向滚动条(在Y方向滑动且窗口在Y方向可移动,在CCtrlList里默认1)
	bool m_bPress;
	bool m_bSlider;//是否有垂直滚动条
	bool m_bHerSlider;//是否有水平滚动条(有背景图片则画出)
	char* m_lpSliderAni;//垂直滚动条的背景图片
	char* m_lpHerSliderAni;//水平滚动条的背景图片
	int m_sliderSize;//滚动条的宽度,对应ini里的"sliderSize"
	//bool m_isChangeViewPos;//是否允许改变视图原点(删去:用m_bFixed代替)
	//CRect m_viewSize;
	//CRect m_cntRect;
	CtrlPositionAction* m_ctrlAction;//动作
	//bool m_bMoving;
// 	int m_distance;
// 	int m_speed;
// 	int m_speedType;
// 	int m_dex;
// 	int m_dey;
// 	bool m_OutRangeMoving;
};

#endif

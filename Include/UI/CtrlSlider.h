/*
 *  CtrlSlider.h
 *	滑块控件
 *  Created by ndtq on 11-2-14.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __CTRL_SLIDER_H__
#define __CTRL_SLIDER_H__

#include "wndobject.h"
/*
滑块控件
*/
class CCtrlSlider:public CWndObject
{
public:
	enum //状态
	{
		enNormal,
		enDown,
		enDisable,
		enActive
	};
	CCtrlSlider();
	virtual ~CCtrlSlider();

	//设置宽度
	void SetSliderSize(int sliderSize);

	//获取宽度
	int GetSliderSize() const;

	//设置范围
	void SetRange(int min,int max);

	//获得最大值
	int GetMax()const;

	//获得最小值
	int GetMin()const;

	//获得当前值
	int GetValue() const;

	//设置滑块的值
	void SetValue(int value);	
	
	//获得是否可用
	bool IsEnabled() const;

	//设置可用
	bool SetEnabled(bool isEnable);

	//设置调节按钮背景图片
	void SetSliderAni(const char* lpAni);

	//获得调节按钮背景图片
	const char* GetSliderAni();

	//获得控件类型 CTRL_SLIDER
	virtual int GetType()const;
	
	//设置滑块背景图片可缩放
	void SetSliderAniStretch(bool Stretch);
	
	//拖动事件或点击后滑块值大小改变的事件(绑定的函数参数是资源ID号,当前滑块值)
	CommonEvent EventSlider;
public:	
	//拖动窗口
	virtual bool MouseDragHandler(CWndObject* obj,int relateX,int relateY,const void* lpParam=NULL);	

	//鼠标移入
	virtual void MouseEnterHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	virtual void MouseLeaveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	virtual void MouseMoveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);

	virtual void MouseClickedHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
protected:

	//绘制控件的前景
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	

	//控件创建后触发
	virtual void DoCreated();

	//改变窗口大小(SetClientRect后触发)
	virtual void DoSized(CRect& rect);
	
	//滑块移动大小值
	void OffSetSlider(int size/*改变的大小(X或Y坐标上)*/);

	//获得当前值
	int CaluValue();
	
	//获取状态
	int GetStatus()const;

	//设置状态
	void SetStatus(int status);

private:
	CRect m_sliderRect;//滑块的背景区域
	bool m_bVertical;//是否垂直
	int m_iSliderSize;//调节按钮的宽度
	int m_status;//状态
	int m_iMin;//最小值
	int m_iMax;//最大值
	int m_iValue;//当前滑块值
	int m_iFrameIndex;//调节按钮的图片帧号
	char* m_lpSliderAni;//调节按钮背景图片(即滑块的背景图片)
	bool m_bSliderAniStretch;//调节按钮背景图片可缩放
};
//int GetSliderValueEx() const
//{
//	return GetValue();
//}

//void SetSliderValue( int value )
//{
//	SetValue(value);
//}

#endif
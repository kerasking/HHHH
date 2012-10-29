//
//  NDLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	－－介绍－－
//	层是游戏的重点，游戏中大多的时间花在层上。
//	层的显示：
//		后添加的层将会覆盖先前添加的层，
//		如果层时透明、或者半透明，则底部的层将会显示或者部分显示。
//	层的事件响应：
//		最上面的层最先接收到系统事件(如：手指点击屏幕事件)，
//		如果事件被处理了则屏蔽事件的分发，否则将往下面的层进行分发事件，直到事件被屏蔽为止。


#ifndef __NDLayer_H
#define __NDLayer_H

#include "NDNode.h"
#include "NDTouch.h"
#include <string>
#include "NDTransData.h"

namespace NDEngine
{
	class NDLayer : public NDNode
	{
		DECLARE_CLASS(NDLayer)
	public:
		NDLayer();
		~NDLayer();
		
	public:
//		
//		函数：Layer
//		作用：静态方法，通过该方法调用无需显示调用Initialization方法
//		参数：无
//		返回值：本对象指针
		static NDLayer* Layer();
//		
//		函数：Initialization
//		作用：初始化层，必须被显示或者隐式调用
//		参数：无
//		返回值：无
		void Initialization(); override
//		
//		函数：draw
//		作用：游戏的循环体，游戏每一帧调用该方法，框架内部调用
//		参数：无
//		返回值：无
		void draw(); override
//		
//		函数：SetTouchEnabled
//		作用：设置层是否可响应触摸事件
//		参数：bEnabled如果true则响应触摸事件，否则不响应，默认不响应
//		返回值：无
		void SetTouchEnabled(bool bEnabled);
//		
//		函数：TouchBegin
//		作用：如果层响应事件，该方法响应触摸开始事件
//		参数：touch触摸点
//		返回值：true表示该层拦截了点击事件不往底下的层分发触摸事件了，否则往底下的层分发触摸事件，直至被某一个层拦截；默认返回true
		virtual bool TouchBegin(NDTouch* touch);
//		
//		函数：TouchEnd
//		作用：响应触摸结束事件；只有在TouchBegin返回true时该事件才会被触发
//		参数：touch触摸点
//		返回值：无
		virtual void TouchEnd(NDTouch* touch);
//		
//		函数：TouchCancelled
//		作用：响应触摸取消事件；只有在TouchBegin返回true时该事件才会被触发
//		参数：touch触摸点
//		返回值：无
		virtual void TouchCancelled(NDTouch* touch);
//		
//		函数：TouchMoved
//		作用：响应触摸移动事件；只有在TouchBegin返回true时该事件才会被触发
//		参数：touch触摸点
//		返回值：无
		virtual void TouchMoved(NDTouch* touch);
		
		virtual bool TouchDoubleClick(NDTouch* touch);
		
		DECLARE_AUTOLINK(NDLayer)
		INTERFACE_AUTOLINK(NDLayer)
	};	
}
#endif
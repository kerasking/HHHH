//
//  NDUINode.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//
//	－－介绍－－
//	NDUINode是所有ui控件的基类，继承自该类也必须显示或者隐式调用Initialization方法
//  modify by yay 12-1-12
//  add lua event callback


#ifndef __NDUINode_H
#define __NDUINode_H

#include "NDNode.h"

namespace NDEngine
{	

#pragma mark 加载ui统一回调
	
	class NDUINode;
	
	class NDSection;
	
	class NDUITargetDelegate
	{
		DECLARE_AUTOLINK(NDUITargetDelegate)
		INTERFACE_AUTOLINK(NDUITargetDelegate)
		
	public:	
		
		NDUITargetDelegate();
		virtual ~NDUITargetDelegate();
		
		virtual bool OnTargetBtnEvent(NDUINode* uinode, int targetEvent);
		virtual bool OnTargetTableEvent(NDUINode* uinode, NDUINode* cell, unsigned int cellIndex, NDSection *section);
	};
	
	////////////////////////////////////////////////////////////
	class NDUINode : public NDNode
	{
		DECLARE_CLASS(NDUINode)
	public:
		NDUINode();
		~NDUINode();
	public:
//		
//		函数：Initialization
//		作用：初始化ui节点，必须被显示或隐式调用
//		参数：无
//		返回值：无
		void Initialization(); override
//		
//		函数：SetFrameRect
//		作用：设置ui相对于父亲节点的矩形显示范围，默认值为（0， 0， 0， 0）
//		参数：rect矩形显示范围
//		返回值：无
		virtual void SetFrameRect(CGRect rect);
//		
//		函数：GetFrameRect
//		作用：获取ui节点相对于父亲节点的矩形范围，
//		参数：无
//		返回值：矩形范围
		virtual CGRect GetFrameRect();		
//		
//		函数：SetVisible
//		作用：设置该节点是否可视，所有子节点也同时被设置
//		参数：visible如果true可视，否则不可视
//		返回值：无
		virtual void SetVisible(bool visible);
//		
//		函数：IsVisibled
//		作用：判断该节点是否可视
//		参数：无
//		返回值：true可视，否则不可视
		virtual bool IsVisibled();
//		
//		函数：EnableEvent
//		作用：设置节点事件是否响应
//		参数：enabled如果true响应，否则不响应
//		返回值：无
		void EnableEvent(bool enabled);
//		
//		函数：EventEnabled
//		作用：判断节点是否响应事件
//		参数：无
//		返回值：true响应，否则不响应
		bool EventEnabled();
//		
//		函数：GetScreenRect
//		作用：获取节点相对于屏幕的矩形范围
//		参数：无
//		返回值：矩形范围		
		CGRect GetScreenRect();	
//		
//		函数：OnFrameRectChange
//		作用：当节点的矩形范围改变时被框架内部调用
//		参数：srcRect改变前的矩形范围，dstRect改变后的矩形范围，相对于屏幕
//		返回值：无		
		virtual void OnFrameRectChange(CGRect srcRect, CGRect dstRect);
	public:		
		void draw(); override
		
	private:		
		bool m_visibled;
		CGRect m_frameRect;
		bool m_eventEnabled;
		CGRect m_scrRect;
		
	public:
		void SetTargetDelegate(NDUITargetDelegate* targetDelegate);
		NDUITargetDelegate* GetTargetDelegate();
		
		void SetLuaDelegate(LuaObject func);
		bool GetLuaDelegate(LuaObject& func);
		
		
		void registerLuaClickFunction(const char* szFunc);
		void unregisterLuaClickFunction();
		void callLuaFunction();
		bool isHaveLuaFunc()
		{
			return m_strLuaFunc.size();
		}
		
		
	private:
		CAutoLink<NDUITargetDelegate> m_delegateTarget;
		std::string		m_strLuaFunc;
		
		LuaObject		m_delegateLua;
	};
}
#endif

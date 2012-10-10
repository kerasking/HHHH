/*
 *  CtrlButton.h
 *
 *  Created by ndtq on 11-2-12.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __CTRL_BUTTON_H__
#define __CTRL_BUTTON_H__

#include "wndobject.h"
//按钮风格
typedef enum BUTTON_STYLE//  
{
	STYLE_NOMAL,//默认风格
	STYLE_PUSHLIKE,//按压式风格
	STYLE_CUSTOM  //状态由用户自己通过SetStatus进行设置status	
}BUTTONSTYLE;
	enum //按钮状态
	{
		enNormal,
		enDown,
		enDisable,
		enActive
	};
class CCtrlButton : public CWndObject
{
public:

	//测试用，用户不可用。
	static void SetClickSound(const char* pSound);

	CCtrlButton();

	virtual ~CCtrlButton();
   
	//设置按钮风格
	void SetStyle(BUTTONSTYLE eButtonStyle);
    
	//获取按钮风格
	int GetStyle() const;

	//设置是否可见
	void ShowWindow(int show);

	//是否可用
	bool IsEnabled() const;

	//设置是否可用
	void SetEnabled(bool isEnable=true);
	
	//获得显示文本
	const char* GetWindowText();

	//设置显示文本
	void SetWindowText(const char* lpText);
	
	//用UTF8编码设置显示文本
	void SetWindowTextWithUTF8(const char* str);

	//得到字体颜色
	unsigned int GetFontColor() const;

	//设置字体颜色
	void SetFontColor(unsigned int iColor);

	//得到控件类型:CTRL_BUTTON
	virtual int GetType()const;

	//获取按钮状态
	int GetStatus()const;

	//设置按钮状态
	virtual void SetStatus(int status);

public:	
	virtual void MouseEnterHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseLeaveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseMoveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
	virtual void MouseClickedHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
public:

	//绘制控件的前景
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

protected:
	char* m_lpText;//显示的文本
	int m_status; //按钮状态
	unsigned int m_fontColor;//字体的颜色
	int m_iWidth;//文字长度
	BUTTON_STYLE m_enStyle;//按钮风格
};

#endif
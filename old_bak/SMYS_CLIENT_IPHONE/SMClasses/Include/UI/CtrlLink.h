/*
 *  CtrlLink.h
 *
 *  Created by ndtq on 11-3-18.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */
#ifndef __CTRL_LINK_H__
#define __CTRL_LINK_H__

#include "wndobject.h"

//超链接控件(用在CCtrlEdit上)
class CCtrlLink:public CWndObject
{
public:
	CCtrlLink();
	virtual ~CCtrlLink();

	//设置超链接文本
	void SetHref(const char* lpAtt);

	//获取超链接文本 
	const char* GetHref();

	//获取控件类型 CTRL_LINK
	virtual int GetType()const;

	//获取字体颜色
	unsigned int GetFontColor() const;

	//设置字体颜色
	void SetFontColor(unsigned int iColor);
	
	//获取窗口文本
	const char* GetWindowText();

	//设置窗口文本
	void SetWindowText(const char* lpText);

	//用UTF8编码设置窗口文本
	void SetWindowTextWithUTF8(const char* str);	

protected:

	//重建大小
	void ResetSize();

	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	

	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);

private:
	char* m_lpAtt;//超链接文本
	char* m_lpText;	//窗口文本
	unsigned int m_fontColor;	//字体颜色
	bool m_isPress;//是否按下过
	int m_iWidth;//窗口文本的宽度
};


#endif

/*
 *  CtrlCheckBox.h

 *
 *  Created by ndtq on 11-2-15.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __CTRL_CHECKBOX_H__
#define __CTRL_CHECKBOX_H__

#include "wndobject.h"
/**
  多选框
**/
class CCtrlCheckBox:public CWndObject
{
public:
	enum 
	{
		enNormal,
		enDown,
		enDisable,
		enActive
	};
	CCtrlCheckBox();
	virtual ~CCtrlCheckBox();

	//是否可用
	bool IsEnabled() const;

	//设置是否可用
	void SetEnabled(bool isEnable);

	//是否选中
	bool IsChecked() const;
	
	//设置选中
	void SetChecked(bool isChecked);
	
	//设置文本
	void SetWindowText(const char* lpStr);
	
	//用UTF8编码设置文本
	void SetWindowTextWithUTF8(const char* str);

	//获得文本
	const char* GetWindowText();

	//文本是否可换行
	bool IsMultiLine()const;

	//设置文本是否可换行
	void SetMultiLine(bool multiLine);
	
	//设置文本显示位置的X坐标偏移量
	void SetLeftOffSet(int offset);

	//获取文本显示位置的X坐标偏移量
	int GetLeftOffSet()const;
	
	//获得未选中时的字体颜色
	unsigned int GetFontColor()const;

	//设置未选中时的字体颜色
	void SetFontColor(unsigned int fontColor);

	//获得选中时的字体颜色
	unsigned int GetCheckColor()const;

	//设置选中时的字体颜色
	void SetCheckColor(unsigned int checkColor);
	
	//得到控件类型 CTRL_CHECKBOX
	virtual int GetType()const;

	//获取状态
	int GetStatus()const;

	//设置状态
	void SetStatus(int status);	

public:	
	virtual void MouseEnterHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseLeaveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseMoveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
	virtual void MouseClickedHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
protected:

	//绘制控件的前景
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);
private:
	int m_status;//状态
	bool m_isCheck;//选中
	char* m_lpText;//显示的文本
	bool m_isMultiLine;//可换行
	int m_iLeftOffSet;//文本显示位置的X坐标偏移量(默认值16)
	int m_iWidth;//文本显示的宽度
	unsigned int m_fontColor;//未选中的字体颜色
	unsigned int m_checkColor;//选中的字体颜色
};

#endif
/*
 *  CtrlStatic.h
 *  Created by ndtq on 11-2-14.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __CTRL_STATIC_H__
#define __CTRL_STATIC_H__

#include "WndObject.h"
#include "DataConvert.h"

/**
  静态文本控件
**/
class CCtrlStatic:public CWndObject
{
public:
	CCtrlStatic();
	virtual ~CCtrlStatic();
	
	//得到文本
	virtual const char* GetWindowText();

	//设置文本
	void SetWindowText(const char* lpText);
	
	//设置UTF文本(会自动将UTF-8转成GB18030)
	void SetWindowTextWithUTF8(const char* str);
	
	//得到字体颜色
	unsigned int GetFontColor() const;

	//设置字体颜色
	void SetFontColor(unsigned int iColor);
	
	//获取水平对齐方式
	int GetVerAlign() const;
	
	//设置垂直对齐方式
	void SetVerAlign(int align);
	
	//获取垂直对齐方式
	int GetHerAlign() const;
	
	//设置水平对齐方式
	void SetHerAlign(int align);
	
	//设置是否自动换行
	void SetBreak(bool isBreak=true);	
	
	//是否自动换行
	bool GetBreak()const;

	//得到控件类型CTRL_STATIC
	virtual int GetType()const;

	//设置字体样式
	void SetFontStyle(DWORD dwFontStyle);

protected:
	//绘制控件的前景
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	

	char* m_lpText;//显示文本
private:
	unsigned int m_fontColor;//颜色
	int m_verAlign;//垂直对齐方式
	int m_herAlign;//水平对齐方式
	int m_iWidth;//文本显示的宽度
	bool m_isMuliLine;//是否自动换行
	DWORD m_dwFontStyle;//文本字体样式(CFM_BOLD|CFM_UNDERLINE)
	CDataConvert m_dataConvert;
};

#endif

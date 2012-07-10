/*
 *  CtrlImage.h
 *	图片控件
 *  Created by ndtq on 11-2-14.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __CTRL_IMAGE_H__
#define __CTRL_IMAGE_H__

#include "wndobject.h"
/**
  图片控件
**/
class CCtrlImage:public CWndObject
{
	enum //状态
	{
		enNormal,
		enDown,
		enDisable,
		enActive
	};
public:
	CCtrlImage();
	virtual ~CCtrlImage();
	
	//是否可用
	bool IsEnabled() const;

	//设置是否可用
	void SetEnabled(bool isEnable);

	//重新设置图片(要放大到的大小在ini里配置)
	void SetImage(IImageObj* lpImg/*图片*/,CRect& frameRect/*图片的原大小 或 在原图片中要显示的区域*/,bool isStretch=false/*是否缩放*/);	

	//获取重新设置的背景图片
	IImageObj* GetImage();

	//获得控件类型 CTRL_IMG
	virtual int GetType()const;

public:	
	virtual void MouseEnterHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseLeaveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseMoveHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	virtual void MouseUpHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
	virtual void MouseClickedHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);
	
protected:
	//获取状态
	int GetStatus()const;

	//设置状态
	void SetStatus(int status);

	//绘制控件的背景
	virtual void DoPaintBackground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);
protected:
	CRect m_recOuterImg;//重新设置的背景图片的
	int m_status;//状态
	bool m_isStretchOut;//是否缩放
	IImageObj* m_lpOuterImg;//重新设置的背景图片
};

#endif
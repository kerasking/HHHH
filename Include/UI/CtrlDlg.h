/*
 *  CtrlDlg.h
 *	
 *  Created by ndtq on 11-2-16.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __CTRL_DLG_H__
#define __CTRL_DLG_H__

#include "CtrlView.h"
/**
  对话框内部管理
**/
class CCtrlDlg:public CCtrlView
{
public:
	CCtrlDlg();
	virtual ~CCtrlDlg();

	//获得控件类型 CTRL_DLG
	virtual int GetType()const;
	
	//拖动窗口
	virtual bool MouseDragHandler(CWndObject* obj,int relateX,int relateY,const void* lpParam=NULL);
	
	//鼠标按下事件
	virtual bool MouseDownHandler(CWndObject* obj,CPoint& pos,const void* lpParam=NULL);	
	
	//设置允许拖动
	void SetAllowDrag(bool allowDrag=true);
	
	//获得是否允许拖动
	bool IsAllowDrag() const;
	
	//设置是否透明
	void SetTransparent(bool isTransparent=true);

	//获得是否透明
	bool IsTransparent() const;
	
protected:	

	//自动绑定控件和事件
	virtual void BindEvent();

	//自动绑定控件ID和控件名字
	virtual void DoDataExchange(void* pDX);    // DDX/DDV support	

	//创建窗口(内部执行控件ID和控件名字,自动绑定控件和事件)
	virtual void DoCreated();

	//改变窗口是否显示触发的事件
	virtual void DoShow(bool isShow);

	//创建窗口后执行的事件
	virtual void OnCreated();
	
private:
	bool m_isTransparent;//是否透明,默认false
	bool m_isAllowDrag;//是否允许拖动窗口,按下鼠标在该窗口内都可拖动,默认false
};

#endif
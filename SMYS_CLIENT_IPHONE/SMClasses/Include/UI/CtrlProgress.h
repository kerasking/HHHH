/*
 *  CtrlProgress.h
 *  进度条控件类
 *  Created by ndtq on 11-2-15.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __CTRL_PROGRESS_H__
#define __CTRL_PROGRESS_H__

#include "wndobject.h"
/**
  进度条(CCtrlProgress控件不提供显示百分之几值,要用CCtrlStatic再画出来)
**/
class CCtrlProgress:public CWndObject
{
public:
	CCtrlProgress();
	virtual ~CCtrlProgress();
	
	//设置范围
	void SetRange(int iMin,int iMax);

	//获取最小值
	int GetMin()const;

	//获取最大值
	int GetMax()const;

	//设置进度值
	void SetPos(int pos);

	//获取进度值
	int GetPos()const;

	//获取边框宽度
	int GetBorderSize()const;

	//设置边框宽度
	void SetBorderSize(int borderSize/*宽度值(不能小于1)*/);

	//设置前景图片
	void SetProgressAni(const char* lpAni);

	//获取前景图片
	const char* GetProgressAni();

	//获取前景图片帧号
	int GetAniFrame()const;

	//设置前景图片帧号
	void SetAniFrame(int index);

	//获取控件类型CTRL_PROGRESS
	virtual int GetType()const;

	//获取前景图片是否自动缩放
	bool IsForeStrenth() const;

	//设置前景图片是否自动缩放
	void SetForeStrenth(bool bForeStrenth=true);

protected:
	//画前景(根据前景图片的区域m_foreRect,不缩放图片显示当前进度)
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

	//控件创建后触发
	virtual void DoCreated();

	//改变窗口大小后(SetClientRect后触发)
	virtual void DoSized(CRect& rect);

	//根据进度值计算出当前前景区域
	void CaluForeRect();

	bool m_bForeStrenth;//前景图片是否自动缩放(默认true)

private:
	char* m_lpProgreeAni;//前景图片
	int m_iForeFrame;//前景图片帧号
	int m_iPos;//进度值
	int m_iMin;//最小值(默认0)
	int m_iMax;//最大值(默认100)
	int m_iBorderSize;//边框宽度(默认1)
	bool m_bVercitial;//是否是垂直(默认false)
	CRect m_foreRect;//前景图片的区域
};
#endif

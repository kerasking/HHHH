/*
 *  INumPad.h
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */
#ifndef __CTRL_NUMPAD_H__
#define __CTRL_NUMPAD_H__

class CCtrlEdit;
class CCtrlSlider;
/**
  输入数字的组合控件接口(含CCtrlEdit,CCtrlSlider)
**/
class INumPad
{
public:	

	virtual void Hide() = 0;

	virtual void Show() = 0;

	//设置关联的编辑框
	virtual void SetBindEdit(CCtrlEdit* pEdit) = 0;

#ifdef WIN32
	//检查值是否越界,并设置关联的滑块控件的值
	virtual int CheckValue(int nCurVal) = 0;
#endif
};

#define NumPadType 1004

extern INumPad* GetNumPad();

#endif
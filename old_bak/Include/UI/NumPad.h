#ifndef _NUMPAD_H
#define _NUMPAD_H
#include "INumPad.h"
class CCtrlEdit;
class CCtrlSlider;
/**
  输入数字的组合控件(含CCtrlEdit,CCtrlSlider)
**/
class CNumPad : public INumPad
{
public:
	CNumPad();
    virtual ~CNumPad();

	virtual void Hide();
	virtual void Show();

	//设置关联的编辑框
	virtual void SetBindEdit(CCtrlEdit* pEdit);

	//检查值是否越界,并设置关联的滑块控件的值
	virtual int CheckValue(int nCurVal);

protected:
	CCtrlEdit* m_pBindEdit;//关联的编辑框控件
	CCtrlSlider* m_pBindSlider;//关联的滑块控件

	int m_nMinValue;//最小值
	int m_nMaxValue;//最大值

protected:

	//设置关联控件和默认属性
	void Reset();	
};

#endif
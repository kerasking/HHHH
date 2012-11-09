/*
 *  IphoneInput.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
#ifndef _IPHONE_INPUT_H_ZJH_
#define _IPHONE_INPUT_H_ZJH_

#include "CommonInput.h"
//#import <Foundation/Foundation.h>

//@class NSIphoneInput;

NS_NDENGINE_BGN

class CIphoneInput :
	public IPlatformInput
{
public:
	CIphoneInput();
	~CIphoneInput();

	virtual void Init();
	virtual void Show();
	virtual void Hide();
	virtual bool IsShow();
	virtual void SetFrame(float fX, float fY, float fW, float fH);
	virtual void SetInputDelegate(CInputBase* input);
	virtual CInputBase* GetInputDelegate();
	virtual void SetText(const char* text);
	virtual const char* GetText();
	virtual void EnableSafe(bool bEnable);
	virtual void EnableAutoAdjust(bool bEnable);
	virtual bool IsInputState();
	virtual void SetLengthLimit(unsigned int nLengthLimit);
	virtual unsigned int GetLengthLimit(void);
	virtual void SetStyleNone();
	virtual void SetTextColor(float fR, float fG, float fB, float fA);
	virtual void SetFontSize(int nFontSize);

private:
	CInputBase*			m_inputCommon;
	//NSIphoneInput*		m_inputIphone;
	bool				m_bAutoAdjust;
	bool				m_bInputState;
	unsigned int        m_usLengthLimit;
	bool				m_bShow;
public:
	void SetInputState(bool bSet);
};

NS_NDENGINE_END

#endif // _IPHONE_INPUT_H_ZJH_
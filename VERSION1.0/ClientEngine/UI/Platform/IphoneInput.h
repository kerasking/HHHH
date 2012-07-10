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
#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#import <Foundation/Foundation.h>

@class NSIphoneInput;

class CIphoneInput :
public IPlatformInput
{
public:
	CIphoneInput();
	~CIphoneInput();
	
	virtual void Init();
	virtual void Show();
	virtual void Hide();
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
    
private:
	CInputBase*			m_inputCommon;
	NSIphoneInput*		m_inputIphone;
	bool				m_bAutoAdjust;
	bool				m_bInputState;
	unsigned int        m_usLengthLimit;
public:
	void SetInputState(bool bSet);
};
#endif

#endif // _IPHONE_INPUT_H_ZJH_
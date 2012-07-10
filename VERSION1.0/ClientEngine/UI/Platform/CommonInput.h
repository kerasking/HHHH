/*
 *  CommonInput.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-26.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
#ifndef _COMMON_INPUT_H_ZJH_
#define _COMMON_INPUT_H_ZJH_
 
class CInputBase
{
public:
	CInputBase() {}
	virtual~CInputBase(){}
	
	virtual bool OnInputReturn(CInputBase* base) { return true; };
    virtual void OnInputFinish(CInputBase* base) {}
	virtual bool OnInputTextChange(CInputBase* base, const char* inputString){ return true; }
};

class IPlatformInput
{
public:
	IPlatformInput(){}
	virtual ~IPlatformInput(){}
	
	virtual void Init()															{};
	virtual void Show()															{};
	virtual void Hide()															{};
	virtual void SetFrame(float fX, float fY, float fH, float fW)				{};
	virtual void SetInputDelegate(CInputBase* input)							{};
	virtual CInputBase* GetInputDelegate()										{return 0;};
	virtual void SetText(const char* text)										{};
	virtual const char* GetText()												{return 0;};
	virtual void EnableSafe(bool bEnable)										{};
	virtual void EnableAutoAdjust(bool bEnable)									{};
	virtual	bool IsInputState()													{return false;};
    virtual void SetLengthLimit(unsigned int nLengthLimit)                      {};
    virtual unsigned int GetLengthLimit(void)                                   {return 0;};
};

#endif // _COMMON_INPUT_H_ZJH_
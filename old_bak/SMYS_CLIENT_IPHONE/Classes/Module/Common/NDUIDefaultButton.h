/*
 *  NDUIDefaultButton.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-8.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_UI_DEFAULT_BUTTON_H_
#define _ND_UI_DEFAULT_BUTTON_H_

#include "NDUIButton.h"
#include "NDUIEdit.h"

using namespace NDEngine;

class NDUIOkCancleButton : public NDUIButton
{
	DECLARE_CLASS(NDUIOkCancleButton)
	
public:
	
	NDUIOkCancleButton();
	
	~NDUIOkCancleButton();
	
	void Initialization(CGRect rectFrame, bool bOk); hide
};

class NDUIImageButton : public NDUIButton
{
	DECLARE_CLASS(NDUIImageButton)
	
public:
	
	NDUIImageButton();
	
	~NDUIImageButton();
	
	void Initialization(CGRect rectFrame, NDPicture* picText); hide
};

//////////////////////////////////////////
class NDUICustomEdit : public NDUIEdit
{
	DECLARE_CLASS(NDUICustomEdit)
	
public:

	NDUICustomEdit();
	
	~NDUICustomEdit();
	
	
	void Initialization(CGPoint origin, int width, int height=31, std::string normalfile="", std::string selfile=""); hide
};

//////////////////////////////////////////
class NDUIMutexStateButton : public NDUIButton
{
	DECLARE_CLASS(NDUIMutexStateButton)

public:
	NDUIMutexStateButton();
	
	~NDUIMutexStateButton();
	
	void SetNormalImage(NDPicture* pic, bool useCustomRect = false, CGRect customRect = CGRectZero);
	void SetFocusImage(NDPicture* pic, bool useCustomRect = false, CGRect customRect = CGRectZero);
	
	void draw(); override
private:
	NDPicture *m_pic; bool m_useCustomRect; CGRect m_rectCustomRect;
	NDPicture *m_picFocus; bool m_useCustomRectFocus; CGRect m_rectCustomRectFocus;
};


#endif // _ND_UI_DEFAULT_BUTTON_H_
/*
 *  NDUIDefaultButton.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-8.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIDefaultButton.h"
#include "NDPicture.h"
#include "NDUtility.h"

IMPLEMENT_CLASS(NDUIOkCancleButton, NDUIButton)

NDUIOkCancleButton::NDUIOkCancleButton()
{
}

NDUIOkCancleButton::~NDUIOkCancleButton()
{
}

void NDUIOkCancleButton::Initialization(CGRect rectFrame, bool bOk)
{
	NDUIButton::Initialization();
	
	int width = rectFrame.size.width, height = rectFrame.size.height;
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	SetBackgroundPicture(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_normal.png"), width),
						 picpool.AddPicture(GetImgPathNew("btn_ok&cancel_hightlight.png"), width));
	NDPicture *picTextOk = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	picTextOk->Cut(CGRectMake(48, (bOk ? 72 : 48), 48, 24));
	SetImage(picTextOk, true, CGRectMake((width-picTextOk->GetSize().width)/2, (height-picTextOk->GetSize().height)/2, picTextOk->GetSize().width, picTextOk->GetSize().height), true);
	SetFrameRect(rectFrame);
	SetTouchDownColor(ccc4(255, 255, 255, 255));
}

//////////////////////////////////////////
IMPLEMENT_CLASS(NDUIImageButton, NDUIButton)

NDUIImageButton::NDUIImageButton()
{
}

NDUIImageButton::~NDUIImageButton()
{
}

void NDUIImageButton::Initialization(CGRect rectFrame, NDPicture* picText)
{
	NDUIButton::Initialization();
	
	int width = rectFrame.size.width, height = rectFrame.size.height;
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	SetBackgroundPicture(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_normal.png"), width),
						 picpool.AddPicture(GetImgPathNew("btn_ok&cancel_hightlight.png"), width));
	
	if (picText)
		SetImage(picText, true, CGRectMake((width-picText->GetSize().width)/2, (height-picText->GetSize().height)/2, picText->GetSize().width, picText->GetSize().height), true);
	SetFrameRect(rectFrame);
	SetTouchDownColor(ccc4(255, 255, 255, 255));
}
//////////////////////////////////////////
IMPLEMENT_CLASS(NDUICustomEdit, NDUIEdit)

NDUICustomEdit::NDUICustomEdit()
{
}

NDUICustomEdit::~NDUICustomEdit()
{
}

void NDUICustomEdit::Initialization(CGPoint origin, int width, int height/*=31*/, std::string normalfile/*=""*/, std::string selfile/*=""*/)
{
	NDUIEdit::Initialization();
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	NDPicture *pic = picpool.AddPicture(GetImgPathNew(normalfile.empty() ? "edit_normal.png" : normalfile.c_str()), width, height);
	NDPicture *picSel = picpool.AddPicture(GetImgPathNew(selfile.empty() ? "edit_sel.png" : selfile.c_str()), width, height);
	
	SetImage(pic, picSel, true);
	
	ShowFrame(false);
	
	SetFrameRect(CGRectMake(origin.x, origin.y, width, height));
}

//////////////////////////////////////////
IMPLEMENT_CLASS(NDUIMutexStateButton, NDUIButton)

NDUIMutexStateButton::NDUIMutexStateButton()
{
	m_pic = NULL; m_useCustomRect = false; m_rectCustomRect = CGRectZero;
	
	m_picFocus = NULL; m_useCustomRectFocus = false; m_rectCustomRectFocus = CGRectZero;
}

NDUIMutexStateButton::~NDUIMutexStateButton()
{
	SAFE_DELETE(m_pic);
	
	SAFE_DELETE(m_picFocus);
}

void NDUIMutexStateButton::SetNormalImage(NDPicture* pic, bool useCustomRect /*= false*/, CGRect customRect /*= CGRectZero*/)
{
	m_pic = pic; m_useCustomRect = useCustomRect; m_rectCustomRect = customRect;
	
	SetImage(m_pic, m_useCustomRect, customRect, false);
}

void NDUIMutexStateButton::SetFocusImage(NDPicture* pic, bool useCustomRect /*= false*/, CGRect customRect /*= CGRectZero*/)
{
	m_picFocus = pic; m_useCustomRectFocus = useCustomRect; m_rectCustomRectFocus = customRect;
}

void NDUIMutexStateButton::draw()
{
	if (!this->IsVisibled()) return;
	
	if (!this->GetParent() || !this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUIButton::draw();
		
		return;
	}
	
	NDUILayer *parent = (NDUILayer*)this->GetParent();
	
	if (parent->GetFocus() == this)
	{
		SetImage(m_picFocus, m_useCustomRectFocus, m_rectCustomRectFocus, false);
	}
	else
	{
		SetImage(m_pic, m_useCustomRect, m_customRect, false);
	}
	
	NDUIButton::draw();
}

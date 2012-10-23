/*
 *  NDUIOptionButtonEx.mmNDUIOptionButtonEx
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIOptionButtonEx.h"
#import "NDUILayer.h"
#import "CGPointExtension.h"
#import "NDDirector.h"
#import "NDPath.h"
#import "NDUtility.h"
#include "I_Analyst.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIOptionButtonEx, NDUINode)
	
#define FONT_SIZE 15
	
	NDUIOptionButtonEx::NDUIOptionButtonEx()
	{		
		m_picSelOptPic = m_picUnSelOptPic = m_picSelOptPicReverse = m_picUnSelOptPicReverse = NULL;
		
		m_focusImage = NULL;
		
		m_title = NULL;
		
		m_bFocusImageCustomRect = m_bReadyDispatchEvent = false;
		
		m_bDefaultOptOffset = true;
		
		m_uiLeftOffset = m_uiRightOffset = m_optIndex = 0;
		
		m_clrBg = ccc4(255, 255, 255, 255);
		
		m_bClearOnFree = false;
		
		m_picCurShow = NULL;
		
		m_picCurShowFocus = NULL;
		
		m_bSelClearOnFree = false;
		
		m_bSelImgClearOnFree = false;
	}
	
	NDUIOptionButtonEx::~NDUIOptionButtonEx()
	{
		SAFE_DELETE(m_picSelOptPicReverse);
		
		SAFE_DELETE(m_picUnSelOptPicReverse);
		
		if (m_bClearOnFree) 
		{
			for_vec(m_vPicOptions, VEC_OPTIONS_PIC::iterator)
			{
				delete *it;
			}
		}
		
		if (m_bFocusClearOnFree) 
		{
			for_vec(m_vFocusPicOptions, VEC_OPTIONS_PIC::iterator)
			{
				delete *it;
			}
		}
		
		if (m_bSelClearOnFree) 
		{
			delete m_picSelOptPic;
			delete m_picUnSelOptPic;
			delete m_picSelOptPicReverse;
			delete m_picUnSelOptPicReverse;
		}
		
		if (m_bSelImgClearOnFree) delete m_focusImage;
	}
	
	void NDUIOptionButtonEx::Initialization()
	{
		NDUINode::Initialization();
		
		m_title = new NDUILabel();
		
		m_title->Initialization();
		
		m_title->SetFontSize(FONT_SIZE);
		
		m_title->SetTextAlignment(LabelTextAlignmentCenter);
		
		this->AddChild(m_title);
	}
	
	void NDUIOptionButtonEx::SetOptionImage(NDPicture *selOptPic, NDPicture *unSelOptPic, bool bDefaultOffect/*=true*/,  bool bClearOnFree /*= true*/, unsigned int leftOffset/*=0*/, unsigned int rightOffset/*=0*/)
	{
		m_picSelOptPic			= selOptPic;
		
		m_picUnSelOptPic		= unSelOptPic;
		
		m_picSelOptPicReverse	= selOptPic ? selOptPic->Copy() : NULL;
		
		m_picSelOptPicReverse->SetReverse(true);
		
		m_picUnSelOptPicReverse	= unSelOptPic? unSelOptPic->Copy() : NULL;
		
		m_picUnSelOptPicReverse->SetReverse(true);
		
		m_bDefaultOptOffset		= bDefaultOffect;
		
		m_uiLeftOffset			= leftOffset;
		
		m_uiRightOffset			= rightOffset;
		
		m_bSelClearOnFree		= bClearOnFree;
	}

	void NDUIOptionButtonEx::SetFontColor(ccColor4B fontColor)
	{
		m_title->SetFontColor(fontColor);
	}
	
	void NDUIOptionButtonEx::SetFontSize(unsigned int fontSize)
	{
		m_title->SetFontSize(fontSize);
	}
	
	void NDUIOptionButtonEx::SetOptIndex(uint index)
	{
		if (index >= m_vOptions.size() || index >= m_vPicOptions.size()) {
			return;
		}
		
		m_optIndex = index;
		
		if (m_vOptions.size() && index < m_vOptions.size())
			m_title->SetText(m_vOptions.at(m_optIndex).c_str()); 
		
		if (m_vPicOptions.size() && index < m_vPicOptions.size())
			m_picCurShow = m_vPicOptions[index];
		
		if (m_vFocusPicOptions.size() && index < m_vFocusPicOptions.size())
			m_picCurShowFocus = m_vFocusPicOptions[index];
	}
	
	void NDUIOptionButtonEx::SetOptions(const VEC_OPTIONS_EX& ops)
	{
		m_vOptions = ops;
		
		if (m_vOptions.size() > 0)
		{
			m_title->SetVisible(true);
			
			m_optIndex = 0;
			m_title->SetText(m_vOptions.at(m_optIndex).c_str());
		}
		else 
			m_title->SetVisible(false);
	}
	
	void NDUIOptionButtonEx::SetPicOptions(const VEC_OPTIONS_PIC& vec_pic, bool bClearOnFree/*=false*/)
	{
		m_vPicOptions = vec_pic;
		
		m_bClearOnFree = bClearOnFree;
		
		if (!m_vPicOptions.empty())
		{
			m_optIndex = 0;
			m_picCurShow = m_vPicOptions[m_optIndex];
		}
	}
	
	void NDUIOptionButtonEx::SetFocusPicOptions(const VEC_OPTIONS_PIC& vec_pic, bool bClearOnFree/*=false*/)
	{
		m_vFocusPicOptions = vec_pic;
		
		m_bFocusClearOnFree = bClearOnFree;
		
		if (!m_vFocusPicOptions.empty() && m_optIndex < m_vFocusPicOptions.size())
		{
			m_picCurShowFocus = m_vFocusPicOptions[m_optIndex];
		}	
	}
	
	
	
	int NDUIOptionButtonEx::GetOptionIndex()
	{
		return m_optIndex;
	}
	
	void NDUIOptionButtonEx::SetBgClr(ccColor4B clr)
	{
		m_clrBg = clr;
	}
	
	void NDUIOptionButtonEx::SetFrameRect(CGRect rect)
	{
		NDUINode::SetFrameRect(rect);
		
		m_title->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));		
	}
	
	void NDUIOptionButtonEx::SetFocusImage(NDPicture *focusImage, bool bCustomRect/*=false*/, CGRect customRect/*=CGRectZero*/, bool bClearOnFree/*=true*/)
	{
		if (m_bSelImgClearOnFree) 
		{
			delete m_focusImage;
		}
		
		m_focusImage				= focusImage;
		
		m_bFocusImageCustomRect		= bCustomRect;
		
		m_focusImageCustomRect		= customRect;
		
		m_bSelImgClearOnFree		= bClearOnFree;
	}
	
	void NDUIOptionButtonEx::SetReadyDispatchEvent(bool bReady)
	{
		m_bReadyDispatchEvent = bReady;
	}
	
	bool NDUIOptionButtonEx::IsReadyDispatchEvent()
	{
		return m_bReadyDispatchEvent;
	}
	
	void NDUIOptionButtonEx::draw()
	{		
		if (!IsVisibled()) return;
		
        TICK_ANALYST(ANALYST_NDUIOptionButtonEx);	
		NDUINode::draw();
		
		CGRect scrRect = this->GetScreenRect();
		
		if (!(m_picCurShow || m_picCurShowFocus))
		{
			DrawRecttangle(scrRect, m_clrBg);
		}
		
		if (IsReadyDispatchEvent() && m_focusImage) 
		{
			CGRect drawRect = scrRect;
			
			if (m_bFocusImageCustomRect) 
			{
				drawRect.origin	= ccpAdd(drawRect.origin, m_focusImageCustomRect.origin);
				
				drawRect.size	= m_focusImageCustomRect.size;
			}
			
			m_focusImage->DrawInRect(drawRect);
		}
		
		NDPicture *pic = NULL, *picReverse = NULL;
		NDCombinePicture *picShow = NULL; 
		
		if (m_bReadyDispatchEvent) 
		{
			if (m_picSelOptPic) pic = m_picSelOptPic;
			
			if (m_picSelOptPicReverse) picReverse = m_picSelOptPicReverse;
			
			picShow = m_picCurShowFocus;
		}
		else if (!m_bReadyDispatchEvent && m_picUnSelOptPic)
		{
			if (m_picUnSelOptPic)	pic = m_picUnSelOptPic;
			
			if (m_picUnSelOptPicReverse) picReverse = m_picUnSelOptPicReverse;
			
			picShow = m_picCurShow;
		}
		
		if (!pic || !picReverse) return;
		
		CGRect rect = CGRectZero, rectReverse = CGRectZero;
		
		rect.size			= pic->GetSize();
		
		rectReverse.size	= picReverse->GetSize();
		
		if (m_bDefaultOptOffset)
		{
			rect.origin				= ccpAdd(scrRect.origin, 
											 ccp(0, 
												(scrRect.size.height-rect.size.height)/2)
											);
			
			rectReverse.origin		= ccpAdd(scrRect.origin, 
											 ccp(scrRect.size.width-rect.size.width, 
												(scrRect.size.height-rectReverse.size.height)/2)
											);
		}
		else 
		{
			rect.origin				= ccpAdd(scrRect.origin, 
											 ccp(m_uiLeftOffset, (scrRect.size.height-rect.size.height)/2)
											 );
			
			rectReverse.origin		= ccpAdd(scrRect.origin, 
											 ccp(scrRect.size.width-m_uiRightOffset, (scrRect.size.height-rectReverse.size.height)/2)
											 );
		}
		
		pic->DrawInRect(rect);
		
		picReverse->DrawInRect(rectReverse);
		
		if (picShow) 
		{
			CGSize parentsize = scrRect.size;
			
			CGSize size = picShow->GetSize();
			
			picShow->DrawInRect(CGRectMake((scrRect.origin.x+(parentsize.width-size.width)/2),
												 scrRect.origin.y+(parentsize.height-size.height)/2,
												 size.width,
												 size.height));
		}
	}
	
	void NDUIOptionButtonEx::NextOpt()
	{
		uint nSize = m_vOptions.size();
		if (nSize > 0)
		{
			this->m_optIndex = m_optIndex >= nSize - 1 ? 0 : m_optIndex + 1;
			if (m_optIndex < nSize)
			{
				m_title->SetText(m_vOptions.at(m_optIndex).c_str());
			}
		}
		
		uint nPicSize = m_vPicOptions.size();
		if (nPicSize > 0) 
		{
			this->m_optIndex = m_optIndex >= nPicSize - 1 ? 0 : m_optIndex + 1;
			if (m_optIndex < nPicSize)
			{
				m_picCurShow = m_vPicOptions[m_optIndex];
			}
			
			if (m_vFocusPicOptions.size() && m_optIndex < m_vFocusPicOptions.size())
				m_picCurShowFocus = m_vFocusPicOptions[m_optIndex];
		}
	}
	
	void NDUIOptionButtonEx::PreOpt()
	{
		int nSize = m_vOptions.size();
		if (nSize > 0)
		{
			this->m_optIndex = m_optIndex <= 0 ? nSize - 1 : m_optIndex - 1;
			m_title->SetText(m_vOptions.at(m_optIndex).c_str());
		}
		
		uint nPicSize = m_vPicOptions.size();
		if (nPicSize > 0)
		{
			this->m_optIndex = m_optIndex <= 0 ? nPicSize - 1 : m_optIndex - 1;
			if (m_optIndex < nPicSize)
			{
				m_picCurShow = m_vPicOptions[m_optIndex];
			}
			
			if (m_vFocusPicOptions.size() && m_optIndex < m_vFocusPicOptions.size())
				m_picCurShowFocus = m_vFocusPicOptions[m_optIndex];
		}
	}
	
	void NDUIOptionButtonExDelegate::OnOptionChangeEx(NDUIOptionButtonEx* option)
	{
		
	}
	
	bool NDUIOptionButtonExDelegate::OnClickOptionEx(NDUIOptionButtonEx* option)
	{
		return false;
	}
}


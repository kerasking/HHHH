/*
 *  NDUIOptionButtonEx.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_UI_OPTION_BUTTON_EX_H__
#define __ND_UI_OPTION_BUTTON_EX_H__

#include "NDUINode.h"
#include "NDPicture.h"
#include "NDUILabel.h"
#include "NDCombinePicture.h"
#include <string>
#include <vector>

namespace NDEngine
{
	using namespace std;
	
	class NDUIOptionButtonEx;
	
	typedef vector<string> VEC_OPTIONS_EX;
	
	typedef vector<NDCombinePicture*> VEC_OPTIONS_PIC;
	
	class NDUIOptionButtonExDelegate
	{
	public:
		virtual void OnOptionChangeEx(NDUIOptionButtonEx* option);
		virtual bool OnClickOptionEx(NDUIOptionButtonEx* option);
	};
	
	class NDUIOptionButtonEx : public NDUINode
	{
		DECLARE_CLASS(NDUIOptionButtonEx)
		
	public:
		NDUIOptionButtonEx();
		
		~NDUIOptionButtonEx();
		
	public:
		void Initialization(); override
		
		void SetOptionImage(NDPicture *selOptPic, NDPicture *unSelOptPic, bool bDefaultOffect = true, bool bClearOnFree = true, unsigned int leftOffset = 0, unsigned int rightOffset = 0);
		
		void SetFontColor(ccColor4B fontColor);
		
		void SetFontSize(unsigned int fontSize);
		
		void SetOptions(const VEC_OPTIONS_EX& ops);	
		
		void SetPicOptions(const VEC_OPTIONS_PIC& vec_pic, bool bClearOnFree=false);
		
		void SetFocusPicOptions(const VEC_OPTIONS_PIC& vec_pic, bool bClearOnFree=false);
		
		int GetOptionIndex();
		
		void SetBgClr(ccColor4B clr);
		
		void SetFrameRect(CGRect rect); override
		
		void SetFocusImage(NDPicture *focusImage, bool bCustomRect = false, CGRect customRect = CGRectZero,bool bClearOnFree=true);
		
		void SetReadyDispatchEvent(bool bReady);
		
		bool IsReadyDispatchEvent();
		
	public:	
		void draw(); override	
		
		void NextOpt();
		
		void PreOpt();
		
		void SetOptIndex(uint index);
		
	private:
	
		NDPicture		*m_picSelOptPic, 
						*m_picUnSelOptPic, 
						*m_picSelOptPicReverse, 
						*m_picUnSelOptPicReverse,
						*m_focusImage;
		
		NDUILabel		*m_title;
		
		VEC_OPTIONS_EX	m_vOptions;
		
		VEC_OPTIONS_PIC m_vPicOptions, m_vFocusPicOptions;
		
		unsigned int	m_optIndex;
		
		ccColor4B		m_clrBg;
		
		bool			m_bFocusImageCustomRect;
		
		CGRect			m_focusImageCustomRect;
		
		bool			m_bReadyDispatchEvent;
		
		bool			m_bDefaultOptOffset;
		
		unsigned int	m_uiLeftOffset, m_uiRightOffset;
		
		bool			m_bClearOnFree, 
						m_bFocusClearOnFree, 
						m_bSelClearOnFree,
						m_bSelImgClearOnFree;
		
		NDCombinePicture	*m_picCurShow, *m_picCurShowFocus;
	};
}

#endif // __ND_UI_OPTION_BUTTON_EX_H__
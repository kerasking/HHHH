/*
 *  NDOptionButton.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_UI_OPTION_BUTTON_H__
#define __ND_UI_OPTION_BUTTON_H__

#include "NDUINode.h"
#include <string>
#include <vector>

#import "CCTexture2D.h"
#include "NDUILabel.h"
#import "NDTile.h"

namespace NDEngine
{
	using namespace std;
	
	class NDUIOptionButton;
	
	typedef vector<string> VEC_OPTIONS;
	
	class NDUIOptionButtonDelegate
	{
	public:
		virtual void OnOptionChange(NDUIOptionButton* option);
	};
	
	class NDUIOptionButton : public NDUINode
	{
		DECLARE_CLASS(NDUIOptionButton)
	public:
		NDUIOptionButton();
		~NDUIOptionButton();
		
	public:
		void Initialization(); override
		
		void SetFontColor(ccColor4B fontColor);		
		void SetFontSize(unsigned int fontSize);
		void SetOptions(const VEC_OPTIONS& ops);		
		int GetOptionIndex();
		void SetBgClr(ccColor4B clr);
		
		void SetFrameRect(CGRect rect); override
		
		void ShowFrame(bool show){ m_frameOpened = show; }
		
	public:		
		void draw(); override	
		void NextOpt();
		void PreOpt();
		void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
		void SetOptIndex(uint index);
		
	protected:
		NDTile *m_leftArrow;
		NDTile *m_rightArrow;
		NDUILabel *m_title;
		VEC_OPTIONS m_vOptions;
		
		int m_optIndex;
		
		ccColor4B m_clrBg;
		bool m_frameOpened;
	};
}

#endif
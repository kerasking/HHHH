//
//  NDUIScrollText.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUIScrollText_H
#define __NDUIScrollText_H

#include "NDUILayer.h"
#include "NDUILabel.h"
#include <string>

namespace NDEngine
{
	typedef enum {
		ScrollTextFromRightToLeft,
		ScrollTextFromLeftToRight,
		ScrollTextFromDownToUp,
		ScrollTextFromUpToDown
	}ScrollTextType;
	
	class NDUIScrollText : public NDUILayer
	{
		DECLARE_CLASS(NDUIScrollText)
		NDUIScrollText();
		~NDUIScrollText();
	public:
		void Initialization(); override		
		void SetScrollType(ScrollTextType scrollTextType);
		//speed must between 0 ~ 60
		void SetScrollTextSpeed(unsigned int speed);
		void SetText(const char* text);
		void SetFontSize(unsigned int fontSize);
		void SetFontColor(ccColor4B color);
		std::string GetText();	
		
		void SetStartPos(CCPoint pos);
		void Run();
		void Stop();
		bool isRunning();
		
		void SetTextPos(CCPoint pos);
		
	public:
		void draw(); override
		void OnFrameRectChange(CCSize srcRect, CCSize dstRect); override
		
	private:
		unsigned int m_speed;
		NDUILabel* m_lblText;
		ScrollTextType m_scrollType;
		bool m_resetSize;
		bool m_setStartPos;
		bool m_run;
		CCSize m_textSize;
		
		CCSize GetTextSize();
		
		CCPoint m_startPos;
	};	
}
#endif

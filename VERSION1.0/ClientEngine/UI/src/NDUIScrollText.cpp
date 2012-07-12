//
//  NDUIScrollText.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-10.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDUIScrollText.h"
#include "NDDirector.h"

using namespace cocos2d;


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUIScrollText, NDUILayer)
	
	NDUIScrollText::NDUIScrollText()
	{
		m_speed = 5;
		m_scrollType = ScrollTextFromRightToLeft;
		m_resetSize = false;
		m_textSize = CGSizeZero;
		m_startPos = CGPointZero;
		m_lblText = NULL;
		m_setStartPos = false;
		m_run = true;
	}
	
	NDUIScrollText::~NDUIScrollText()
	{
	}
	
	void NDUIScrollText::Initialization()
	{
		NDUILayer::Initialization();
		
		m_lblText = new NDUILabel();
		m_lblText->Initialization();
		this->AddChild(m_lblText);
	}
	
	void NDUIScrollText::SetScrollType(ScrollTextType scrollTextType)
	{
		m_scrollType = scrollTextType;
		m_resetSize = true;
	}
	
	void NDUIScrollText::SetScrollTextSpeed(unsigned int speed)
	{
		if (speed <= 60) 
		{
			m_speed = speed;
		}
	}
	
	void NDUIScrollText::SetText(const char* text)
	{
		m_resetSize = true;
		
		if (text) 
		{
			m_lblText->SetText(text);
		}
		else 
		{
			m_lblText->SetText("");
		}		
	}
	
	std::string NDUIScrollText::GetText()
	{
		return m_lblText->GetText();
	}
	
	void NDUIScrollText::SetFontSize(unsigned int fontSize)
	{
		m_resetSize = true;
		
		m_lblText->SetFontSize(fontSize);
	}
	
	void NDUIScrollText::SetFontColor(ccColor4B color)
	{
		m_lblText->SetFontColor(color);
	}
	
	void NDUIScrollText::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
		if (srcRect.size.width != dstRect.size.width || srcRect.size.height != dstRect.size.height) 
		{
			m_resetSize = true;
		}
	}
	
	CGSize NDUIScrollText::GetTextSize()
	{
		CGSize size = CGSizeZero;		
		switch (m_scrollType) 
		{
			case ScrollTextFromRightToLeft:
			{
				//NSString* text = [NSString stringWithUTF8String:m_lblText->GetText().c_str()];
				//size = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_lblText->GetFontSize()]];
				size	= getStringSize(m_lblText->GetText().c_str(), m_lblText->GetFontSize());
			}
				break;
			default:
				break;
		}
		return size;
	}
	
	void NDUIScrollText::SetStartPos(CGPoint pos)
	{
		m_setStartPos = true;
		m_startPos = pos;
	}
	
	void NDUIScrollText::SetTextPos(CGPoint pos)
	{
		m_lblText->SetFrameRect(CGRectMake(pos.x, pos.y, m_lblText->GetFrameRect().size.width, m_lblText->GetFrameRect().size.height));
	}
	
	void NDUIScrollText::Run()
	{
		m_run = true;
	}
	
	void NDUIScrollText::Stop()
	{
		m_run = false;
	}
	
	bool NDUIScrollText::isRunning()
	{
		return m_run;
	}
	
	void NDUIScrollText::draw()
	{	
		NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
		
		NDUILayer::draw();
		
		if (this->IsVisibled()) 
		{
			CGRect thisRect = this->GetFrameRect();	
			static unsigned runCount = 0;			
			if (runCount >= 60 - m_speed) 
			{
				switch (m_scrollType) 
				{
					case ScrollTextFromRightToLeft:
					{			
						if (m_resetSize)
						{
							m_textSize = this->GetTextSize();
							m_resetSize = false;
							if (m_setStartPos) 
								m_lblText->SetFrameRect(CGRectMake(m_startPos.x, m_startPos.y, m_textSize.width, m_textSize.height));
							else 
								m_lblText->SetFrameRect(CGRectMake(thisRect.size.width, 0, m_textSize.width, m_textSize.height));
						}
						
						if (m_run) 
						{
							CGRect labelRect = m_lblText->GetFrameRect();
							labelRect.origin.x -= 2;
							m_lblText->SetFrameRect(CGRectMake(labelRect.origin.x, 0, m_textSize.width, m_textSize.height));
							if (labelRect.origin.x + m_textSize.width < 0) 
							{
								m_lblText->SetFrameRect(CGRectMake(thisRect.size.width, 0, m_textSize.width, m_textSize.height));
							}
						}
						
					}
						break;
					default:
						break;
				}
				runCount = 0;
			}
			else 
			{
				runCount ++;
			}			
		}		
	}
}

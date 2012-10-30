//
//  NDUILabel.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDUILabel.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "ccMacros.h"
#include "basedefine.h"
#include "NDUIBaseGraphics.h"
#include "CCString.h"
#include "NDDebugOpt.h"

using namespace cocos2d;


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUILabel, NDUINode)
	
	NDUILabel::NDUILabel()
	{
		m_bNeedMakeTex = false;
		m_bNeedMakeCoo = false;
		m_bNeedMakeVer = false;
		m_uiFontSize = 15;
		m_kColor = ccc4(0, 0, 0, 255);
		m_eTextAlignment = LabelTextAlignmentLeft;
		m_texture = NULL;
		m_kCutRect = CGRectZero;
		m_uiRenderTimes = 2;
		this->SetFontColor(m_kColor);
		
		m_bHasFontBoderColor = false;
		m_kColorFontBoder = ccc4(0, 0, 0, 0);
	
		memset(m_pfVerticesBoder, 0, sizeof(m_pfVerticesBoder));
		memset(m_pbColorsBorder, 0, sizeof(m_pbColorsBorder));
	}
	
	NDUILabel::~NDUILabel()
	{
		CC_SAFE_RELEASE(m_texture);
	}
	
	void NDUILabel::SetText(const char* text)
	{
		if (0 == strcmp(text, m_strText.c_str())) 
		{
			return;
		}
		
		m_bNeedMakeTex = true;
		m_bNeedMakeCoo = true;
		m_bNeedMakeVer = true;

		CCString *pstrString = CCString::stringWithUTF8String(text);
		m_strText = pstrString->toStdString();
	}
	
	void NDUILabel::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
		CGRect thisRect = this->GetFrameRect();

		if (srcRect.size.width != dstRect.size.width ||
			srcRect.size.height != dstRect.size.height)
		{
			m_bNeedMakeTex = true;
			m_bNeedMakeCoo = true;
			m_bNeedMakeVer = true;
		}
		else if (srcRect.origin.x != dstRect.origin.x ||
			srcRect.origin.y != dstRect.origin.y)
		{
			//@zwq: 不需要重新生成贴图
			m_bNeedMakeVer = false;
			m_bNeedMakeCoo = true;
			m_bNeedMakeVer = true;
		}
	}
	
	void NDUILabel::SetFontColor(ccColor4B fontColor)
	{
		m_kColor = fontColor;
		
		m_pbColors[0] = fontColor.r; 
		m_pbColors[1] = fontColor.g;
		m_pbColors[2] = fontColor.b;
		m_pbColors[3] = fontColor.a;
		
		m_pbColors[4] = fontColor.r; 
		m_pbColors[5] = fontColor.g;
		m_pbColors[6] = fontColor.b;
		m_pbColors[7] = fontColor.a;
		
		m_pbColors[8] = fontColor.r; 
		m_pbColors[9] = fontColor.g;
		m_pbColors[10] = fontColor.b;
		m_pbColors[11] = fontColor.a;
		
		m_pbColors[12] = fontColor.r; 
		m_pbColors[13] = fontColor.g;
		m_pbColors[14] = fontColor.b;
		m_pbColors[15] = fontColor.a;
	}
	
	void NDUILabel::SetFontSize(unsigned int fontSize)
	{
		fontSize = fontSize * NDDirector::DefaultDirector()->
			GetScaleFactor();

		if (m_uiFontSize != fontSize)
		{
			m_bNeedMakeTex = true;
			m_bNeedMakeCoo = true;
			m_bNeedMakeVer = true;
		}
		
		m_uiFontSize = fontSize;
	}
	
	void NDUILabel::SetTextAlignment(int alignment)
	{
		if (m_eTextAlignment != alignment) 
		{
			m_bNeedMakeVer = true;
		}
		
		m_eTextAlignment = (LabelTextAlignment)alignment;
	}
	
	void NDUILabel::MakeTexture()
	{
#ifdef _DEBUG
		CCLog( "@NDUILabel::MakeTexture(): %s", m_strText.c_str());
#endif

		CGRect thisRect = this->GetFrameRect();	
		/*
		CGSize dim = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_fontSize] 
					  constrainedToSize:CGSizeMake(thisRect.size.width, thisRect.size.height)];		
		
		//--test
		dim.width = dim.width;
		dim.height = dim.height;
		*/
		CC_SAFE_RELEASE(m_texture);

		if ("" == m_strText)
		{
			return;
		}

		CCString* strString = new CCString(m_strText.c_str());

		m_texture = new CCTexture2D;
		m_texture->initWithString(strString->UTF8String(),
					CGSizeMake(thisRect.size.width, thisRect.size.height),
					CCTextAlignmentLeft,
					FONT_NAME,
					m_uiFontSize
					);
// 			[[CCTexture2D alloc] initWithString:text 
// 											 dimensions:dim 
// 											  alignment:UITextAlignmentLeft
// 											   fontName:FONT_NAME 
// 											   fontSize:m_fontSize];

		delete strString;
	}
	
	void NDUILabel::MakeCoordinates()
	{
		if (m_texture) 
		{
			CGRect thisRect = this->GetFrameRect();	
			
			m_kCutRect = CGRectZero;
			m_kCutRect.size.width = m_texture->getContentSizeInPixels().width;
			m_kCutRect.size.height = thisRect.size.height <
				m_texture->getContentSizeInPixels().height ?
				thisRect.size.height: m_texture->getContentSizeInPixels().height;
			
			m_pfCoordinates[0] = m_kCutRect.origin.x / m_texture->getPixelsWide();
			m_pfCoordinates[1] = (m_kCutRect.origin.y + m_kCutRect.size.height) / m_texture->getPixelsHigh();
			m_pfCoordinates[2] = (m_kCutRect.origin.x + m_kCutRect.size.width) / m_texture->getPixelsWide();
			m_pfCoordinates[3] = m_pfCoordinates[1];
			m_pfCoordinates[4] = m_pfCoordinates[0];
			m_pfCoordinates[5] = m_kCutRect.origin.y / m_texture->getPixelsHigh();
			m_pfCoordinates[6] = m_pfCoordinates[2];
			m_pfCoordinates[7] = m_pfCoordinates[5];
		}
	}

	void NDUILabel::MakeVertices()
	{
		if (m_texture) 
		{
			CGRect scrRect = this->GetScreenRect();
			
			CGRect drawRect = CGRectZero;
			drawRect.origin.y = scrRect.origin.y;
			drawRect.size.width = m_kCutRect.size.width;
			drawRect.size.height = m_kCutRect.size.height;
			
			if (m_eTextAlignment == LabelTextAlignmentLeft) 
			{
				drawRect.origin.x = scrRect.origin.x;
			}
			else if (m_eTextAlignment == LabelTextAlignmentCenter)
			{
				drawRect.origin.x = scrRect.origin.x +
					(scrRect.size.width - m_kCutRect.size.width) / 2;
				drawRect.origin.y = scrRect.origin.y +
					(scrRect.size.height - m_kCutRect.size.height) / 2;
			}
			else
			{
				drawRect.origin.x = scrRect.origin.x + scrRect.size.width - m_kCutRect.size.width;	
				//drawRect.origin.y = scrRect.origin.y + scrRect.size.height - m_cutRect.size.height;
			}
			
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_pfVertices[0] = drawRect.origin.x;
			m_pfVertices[1] = winSize.height - drawRect.origin.y - drawRect.size.height;
			m_pfVertices[2] = 0;
			m_pfVertices[3] = drawRect.origin.x + drawRect.size.width;
			m_pfVertices[4] = m_pfVertices[1];
			m_pfVertices[5] = 0;
			m_pfVertices[6] = m_pfVertices[0];
			m_pfVertices[7] = winSize.height - drawRect.origin.y;
			m_pfVertices[8] = 0;
			m_pfVertices[9] = m_pfVertices[3];
			m_pfVertices[10] = m_pfVertices[7];
			m_pfVertices[11] = 0;	
			
			if (m_bHasFontBoderColor) 
			{
				int sf = 0.5f*NDDirector::DefaultDirector()->GetScaleFactor();

				m_pfVerticesBoder[0] = drawRect.origin.x + sf;
				m_pfVerticesBoder[1] = winSize.height - drawRect.origin.y - drawRect.size.height - sf;
				m_pfVerticesBoder[2] = 0;
				m_pfVerticesBoder[3] = drawRect.origin.x + drawRect.size.width + sf;
				m_pfVerticesBoder[4] = m_pfVerticesBoder[1];
				m_pfVerticesBoder[5] = 0;
				m_pfVerticesBoder[6] = m_pfVerticesBoder[0];
				m_pfVerticesBoder[7] = winSize.height - drawRect.origin.y - sf;
				m_pfVerticesBoder[8] = 0;
				m_pfVerticesBoder[9] = m_pfVerticesBoder[3];
				m_pfVerticesBoder[10] = m_pfVerticesBoder[7];
				m_pfVerticesBoder[11] = 0;	



				for (int i = 0; i < 12; i++) {
					//m_pfVerticesBoder[i] = m_vertices[i]+((i%3 == 2) ? 0.0f : 1.0f*NDDirector::DefaultDirector()->GetScaleFactor());
					//m_pfVerticesBoder[i] = m_vertices[i]-1.0f*NDDirector::DefaultDirector()->GetScaleFactor();
				}
			}
		}
	}
	
	void NDUILabel::draw()
	{
		if (!NDDebugOpt::getDrawUILabelEnabled()) return;

		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			if (m_bNeedMakeTex) 
			{
				this->MakeTexture();
				m_bNeedMakeTex = false;
			}
			
			if (m_bNeedMakeCoo) 
			{
				this->MakeCoordinates();
				m_bNeedMakeCoo = false;
			}
			
			if (m_bNeedMakeVer) 
			{
				this->MakeVertices();
				m_bNeedMakeVer = false;
			}
			
			if (m_texture) 
			{
				//** chh 2012-08-08 文字透明功能 **//
				if(m_kColor.a <255)
				{
					glBlendFunc(GL_SRC_ALPHA, GL_ONE);
				}
				else
				{
					glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				}


				glBindTexture(GL_TEXTURE_2D, m_texture->getName());

				glTexCoordPointer(2, GL_FLOAT, 0, m_pfCoordinates);
				if (m_bHasFontBoderColor) 
				{
					glVertexPointer(3, GL_FLOAT, 0, m_pfVerticesBoder);
					glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_pbColorsBorder);
					glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				}

				glVertexPointer(3, GL_FLOAT, 0, m_pfVertices);
				glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_pbColors);

				for (uint i = 0; i < m_uiRenderTimes; i++) 
				{
					glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				}

				glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST);
			}
			
			// use to debug
			
			CGRect scrRect = this->GetScreenRect();
			
// 			DrawLine(scrRect.origin, 
// 					 ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
// 					 ccc4(255, 0, 0, 255), 1);
// 					
// 			DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
// 					 ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
// 					 ccc4(255, 0, 0, 255), 1);
// 
// 			DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
// 					 ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
// 					 ccc4(255, 0, 0, 255), 1);
// 					 
// 			DrawLine(ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
// 					 scrRect.origin,
// 					 ccc4(255, 0, 0, 255), 1);
			
		}
	}
	
	void NDUILabel::SetFontBoderColer(ccColor4B fontColor)
	{
		m_bHasFontBoderColor = true;
		
		m_kColorFontBoder = fontColor;
		
		m_bNeedMakeVer = true;
		
		m_pbColorsBorder[0] = fontColor.r;
		m_pbColorsBorder[1] = fontColor.g;
		m_pbColorsBorder[2] = fontColor.b;
		m_pbColorsBorder[3] = fontColor.a;
		
		m_pbColorsBorder[4] = fontColor.r;
		m_pbColorsBorder[5] = fontColor.g;
		m_pbColorsBorder[6] = fontColor.b;
		m_pbColorsBorder[7] = fontColor.a;
		
		m_pbColorsBorder[8] = fontColor.r;
		m_pbColorsBorder[9] = fontColor.g;
		m_pbColorsBorder[10] = fontColor.b;
		m_pbColorsBorder[11] = fontColor.a;
		
		m_pbColorsBorder[12] = fontColor.r;
		m_pbColorsBorder[13] = fontColor.g;
		m_pbColorsBorder[14] = fontColor.b;
		m_pbColorsBorder[15] = fontColor.a;
	}
}
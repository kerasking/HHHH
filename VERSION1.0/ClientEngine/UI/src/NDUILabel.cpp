//
//  NDUILabel.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-29.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDUILabel.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "ccMacros.h"
#include "basedefine.h"
#include "NDUIBaseGraphics.h"
#include "CCString.h"

using namespace cocos2d;


namespace NDEngine
{
	IMPLEMENT_CLASS(NDUILabel, NDUINode)
	
	NDUILabel::NDUILabel()
	{
		m_needMakeTex = false;
		m_needMakeCoo = false;
		m_needMakeVer = false;
		m_fontSize = 15;
		m_color = ccc4(0, 0, 0, 255);
		m_textAlignment = LabelTextAlignmentLeft;
		m_texture = NULL;
		m_cutRect = CGRectZero;
		m_renderTimes = 2;
		this->SetFontColor(m_color);
		
		m_hasFontBoderColor = false;
		m_colorFontBoder = ccc4(0, 0, 0, 0);
	
		memset(m_verticesBoder, 0, sizeof(m_verticesBoder));
		memset(m_colorsBorder, 0, sizeof(m_colorsBorder));
	}
	
	NDUILabel::~NDUILabel()
	{
		CC_SAFE_RELEASE(m_texture);
	}
	
	void NDUILabel::SetText(const char* text)
	{
		if (0 == strcmp(text, m_text.c_str())) 
		{
			return;
		}
		
		m_needMakeTex = true;
		m_needMakeCoo = true;
		m_needMakeVer = true;

		m_text = text;
	}
	
	void NDUILabel::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
	{
		CGRect thisRect = this->GetFrameRect();

		if (srcRect.size.width != dstRect.size.width ||
			srcRect.size.height != dstRect.size.height)
		{
			m_needMakeTex = true;
			m_needMakeCoo = true;
			m_needMakeVer = true;
		}
		else if (srcRect.origin.x != dstRect.origin.x ||
			srcRect.origin.y != dstRect.origin.y)
		{
			m_needMakeVer = true;
		}
	}
	
	void NDUILabel::SetFontColor(ccColor4B fontColor)
	{
		m_color = fontColor;
		
		m_colors[0] = fontColor.r; 
		m_colors[1] = fontColor.g;
		m_colors[2] = fontColor.b;
		m_colors[3] = fontColor.a;
		
		m_colors[4] = fontColor.r; 
		m_colors[5] = fontColor.g;
		m_colors[6] = fontColor.b;
		m_colors[7] = fontColor.a;
		
		m_colors[8] = fontColor.r; 
		m_colors[9] = fontColor.g;
		m_colors[10] = fontColor.b;
		m_colors[11] = fontColor.a;
		
		m_colors[12] = fontColor.r; 
		m_colors[13] = fontColor.g;
		m_colors[14] = fontColor.b;
		m_colors[15] = fontColor.a;
	}
	
	void NDUILabel::SetFontSize(unsigned int fontSize)
	{
		fontSize = fontSize * NDDirector::DefaultDirector()->
			GetScaleFactor();

		if (m_fontSize != fontSize)
		{
			m_needMakeTex = true;
			m_needMakeCoo = true;
			m_needMakeVer = true;
		}
		
		m_fontSize = fontSize;
	}
	
	void NDUILabel::SetTextAlignment(int alignment)
	{
		if (m_textAlignment != alignment) 
		{
			m_needMakeVer = true;
		}
		
		m_textAlignment = (LabelTextAlignment)alignment;
	}
	
	void NDUILabel::MakeTexture()
	{
		CGRect thisRect = this->GetFrameRect();	
		/*
		CGSize dim = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_fontSize] 
					  constrainedToSize:CGSizeMake(thisRect.size.width, thisRect.size.height)];		
		
		//--test
		dim.width = dim.width;
		dim.height = dim.height;
		*/
		CC_SAFE_RELEASE(m_texture);

		if ("" == m_text)
		{
			return;
		}

		CCString* strString = new CCString(m_text.c_str());

		m_texture = new CCTexture2D;
		m_texture->initWithString(strString->UTF8String(),
					CGSizeMake(thisRect.size.width, thisRect.size.height),
					CCTextAlignmentLeft,
					FONT_NAME,
					m_fontSize
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
			
			m_cutRect = CGRectZero;
			m_cutRect.size.width = m_texture->getContentSizeInPixels().width;
			m_cutRect.size.height = thisRect.size.height <
				m_texture->getContentSizeInPixels().height ?
				thisRect.size.height: m_texture->getContentSizeInPixels().height;
			
			m_coordinates[0] = m_cutRect.origin.x / m_texture->getPixelsWide();
			m_coordinates[1] = (m_cutRect.origin.y + m_cutRect.size.height) / m_texture->getPixelsHigh();
			m_coordinates[2] = (m_cutRect.origin.x + m_cutRect.size.width) / m_texture->getPixelsWide();
			m_coordinates[3] = m_coordinates[1];
			m_coordinates[4] = m_coordinates[0];
			m_coordinates[5] = m_cutRect.origin.y / m_texture->getPixelsHigh();
			m_coordinates[6] = m_coordinates[2];
			m_coordinates[7] = m_coordinates[5];
		}
	}

	void NDUILabel::MakeVertices()
	{
		if (m_texture) 
		{
			CGRect scrRect = this->GetScreenRect();
			
			CGRect drawRect = CGRectZero;
			drawRect.origin.y = scrRect.origin.y;
			drawRect.size.width = m_cutRect.size.width;
			drawRect.size.height = m_cutRect.size.height;
			
			if (m_textAlignment == LabelTextAlignmentLeft) 
			{
				drawRect.origin.x = scrRect.origin.x;
			}
			else if (m_textAlignment == LabelTextAlignmentCenter)
			{
				drawRect.origin.x = scrRect.origin.x +
					(scrRect.size.width - m_cutRect.size.width) / 2;
				drawRect.origin.y = scrRect.origin.y +
					(scrRect.size.height - m_cutRect.size.height) / 2;
			}
			else
			{
				drawRect.origin.x = scrRect.origin.x + scrRect.size.width - m_cutRect.size.width;	
				//drawRect.origin.y = scrRect.origin.y + scrRect.size.height - m_cutRect.size.height;
			}
			
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			m_vertices[0] = drawRect.origin.x;
			m_vertices[1] = winSize.height - drawRect.origin.y - drawRect.size.height;
			m_vertices[2] = 0;
			m_vertices[3] = drawRect.origin.x + drawRect.size.width;
			m_vertices[4] = m_vertices[1];
			m_vertices[5] = 0;
			m_vertices[6] = m_vertices[0];
			m_vertices[7] = winSize.height - drawRect.origin.y;
			m_vertices[8] = 0;
			m_vertices[9] = m_vertices[3];
			m_vertices[10] = m_vertices[7];
			m_vertices[11] = 0;	
			
			if (m_hasFontBoderColor) 
			{
				for (int i = 0; i < 12; i++) 
				{
					m_verticesBoder[i] = m_vertices[i] + ((i % 3 == 2) ? 0.0f : 1.0f);
				}
			}
		}
	}
	
	void NDUILabel::draw()
	{
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{
			if (m_needMakeTex) 
			{
				this->MakeTexture();
				m_needMakeTex = false;
			}
			
			if (m_needMakeCoo) 
			{
				this->MakeCoordinates();
				m_needMakeCoo = false;
			}
			
			if (m_needMakeVer) 
			{
				this->MakeVertices();
				m_needMakeVer = false;
			}
			
			if (m_texture) 
			{
				const char* pszTemp = m_texture->GetName();
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				glBindTexture(GL_TEXTURE_2D, m_texture->getName());
				glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);

				if (m_hasFontBoderColor) 
				{
					glVertexPointer(3, GL_FLOAT, 0, m_verticesBoder);
					glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colorsBorder);
					glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
				}

				glVertexPointer(3, GL_FLOAT, 0, m_vertices);
				glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_colors);

				for (uint i = 0; i < m_renderTimes; i++) 
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
		m_hasFontBoderColor = true;
		
		m_colorFontBoder = fontColor;
		
		m_needMakeVer = true;
		
		m_colorsBorder[0] = fontColor.r;
		m_colorsBorder[1] = fontColor.g;
		m_colorsBorder[2] = fontColor.b;
		m_colorsBorder[3] = fontColor.a;
		
		m_colorsBorder[4] = fontColor.r;
		m_colorsBorder[5] = fontColor.g;
		m_colorsBorder[6] = fontColor.b;
		m_colorsBorder[7] = fontColor.a;
		
		m_colorsBorder[8] = fontColor.r;
		m_colorsBorder[9] = fontColor.g;
		m_colorsBorder[10] = fontColor.b;
		m_colorsBorder[11] = fontColor.a;
		
		m_colorsBorder[12] = fontColor.r;
		m_colorsBorder[13] = fontColor.g;
		m_colorsBorder[14] = fontColor.b;
		m_colorsBorder[15] = fontColor.a;
	}
}
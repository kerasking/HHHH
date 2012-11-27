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
#include "ccTypes.h"
#include "NDDebugOpt.h"
#include "define.h"
#include "NDSharedPtr.h"
#include "CCDrawingPrimitives.h"
#include "UsePointPls.h"

using namespace cocos2d;


NS_NDENGINE_BGN

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
	m_kCutRect = CCRectZero;
	m_uiRenderTimes = 1;
	SetFontColor(m_kColor);
		
	m_bHasFontBoderColor = false;
	m_kColorFontBoder = ccc4(0, 0, 0, 0);
	
	memset(m_pfVerticesBoder, 0, sizeof(m_pfVerticesBoder));
	memset(m_pbColorsBorder, 0, sizeof(m_pbColorsBorder));
}
	
NDUILabel::~NDUILabel()
{
	CC_SAFE_DELETE(m_texture);
}
	
void NDUILabel::SetText(const char* text)
{
	if (0 == strcmp(text, m_strText.c_str())) 
	{
		return;
	}

	// convert to utf8 and compare again.
	CCStringRef pstrString = 0;
	pstrString = CCString::stringWithUTF8String(text);
	if (pstrString->toStdString() == m_strText)
	{
		return;
	}

	m_strText = pstrString->toStdString();

	// dirty.
	m_bNeedMakeTex = true;
	m_bNeedMakeCoo = true;
	m_bNeedMakeVer = true;
}
	
void NDUILabel::OnFrameRectChange(CCRect srcRect, CCRect dstRect)
{
	CCRect thisRect = GetFrameRect();

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
	fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();

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

	CCRect thisRect = GetFrameRect();	
	/*
	CCSize dim = [text sizeWithFont:[UIFont fontWithName:FONT_NAME size:m_fontSize] 
				  constrainedToSize:CCSizeMake(thisRect.size.width, thisRect.size.height)];		
		
	//--test
	dim.width = dim.width;
	dim.height = dim.height;
	*/
	CC_SAFE_DELETE(m_texture);

	if ("" == m_strText)
	{
		return;
	}

	// get horz text alignment
	CCTextAlignment eTextAlign = kCCTextAlignmentLeft;
	if (m_eTextAlignment == LabelTextAlignmentLeft)
	{
		eTextAlign = kCCTextAlignmentLeft;
	}
	else if (m_eTextAlignment == LabelTextAlignmentCenter 
				|| m_eTextAlignment == LabelTextAlignmentHorzCenter)
	{
		eTextAlign = kCCTextAlignmentCenter;
	}
	else if (m_eTextAlignment == LabelTextAlignmentRight)
	{
		eTextAlign = kCCTextAlignmentRight;
	}

	// init texture with string
	CCStringRef strString = new CCString(m_strText.c_str());

	m_texture = new CCTexture2D;
	m_texture->initWithString(strString->UTF8String(),
				CCSizeMake(thisRect.size.width, thisRect.size.height),
				eTextAlign,
				kCCVerticalTextAlignmentCenter,
				FONT_NAME,
				m_uiFontSize
				);
}
	
void NDUILabel::MakeCoordinates()
{
	if (m_texture) 
	{
		CCRect thisRect = GetFrameRect();	
			
		m_kCutRect = CCRectZero;

#if 0 //@todo
		m_kCutRect.size.width = m_texture->getContentSizeInPixels().width;
		m_kCutRect.size.height = min( thisRect.size.height, m_texture->getContentSizeInPixels().height );
#else
		m_kCutRect.size = m_texture->getContentSizeInPixels();
#endif
			
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
	if (!m_texture) return;
	
	CCRect scrRect = this->GetScreenRect();
	CCRect drawRect = scrRect;

#if 1 //@todo
	//CCRect drawRect = CCRectZero;
	//drawRect.origin.y = scrRect.origin.y;
	//drawRect.size.width = m_kCutRect.size.width;
	//drawRect.size.height = m_kCutRect.size.height;
	
	if (m_eTextAlignment == LabelTextAlignmentLeft) 
	{
		//drawRect.origin.x = scrRect.origin.x;
	}
	else if (m_eTextAlignment == LabelTextAlignmentCenter)
	{
		drawRect.origin.x = scrRect.origin.x +
			(scrRect.size.width - m_kCutRect.size.width) / 2;

		drawRect.origin.y = scrRect.origin.y +
			(scrRect.size.height - m_kCutRect.size.height) / 2;
	}
	else //align right
	{
		drawRect.origin.x = scrRect.origin.x + (scrRect.size.width - m_kCutRect.size.width);	
		//drawRect.origin.y = scrRect.origin.y + scrRect.size.height - m_cutRect.size.height;
	}
#endif

	//像素->点
	ConvertUtil::convertToPointCoord( drawRect );

	float l,r,t,b;
	SCREEN2GL_RECT(drawRect,l,r,t,b);
	{
		m_pfVertices[0] = l;
		m_pfVertices[1] = b;
		m_pfVertices[2] = 0;

		m_pfVertices[3] = r;
		m_pfVertices[4] = b;
		m_pfVertices[5] = 0;

		m_pfVertices[6] = l;
		m_pfVertices[7] = t;
		m_pfVertices[8] = 0;

		m_pfVertices[9] = r;
		m_pfVertices[10] = t;
		m_pfVertices[11] = 0;
	}

	if (m_bHasFontBoderColor) 
	{
		const float offset = 0.5f;
		float l,r,t,b;
		SCREEN2GL_RECT(drawRect,l,r,t,b);
		{
			l -= offset; r -= offset;
			t -= offset; b -= offset;

			m_pfVerticesBoder[0] = l;
			m_pfVerticesBoder[1] = b;
			m_pfVerticesBoder[2] = 0;

			m_pfVerticesBoder[3] = r;
			m_pfVerticesBoder[4] = b;
			m_pfVerticesBoder[5] = 0;

			m_pfVerticesBoder[6] = l;
			m_pfVerticesBoder[7] = t;
			m_pfVerticesBoder[8] = 0;

			m_pfVerticesBoder[9] = r;
			m_pfVerticesBoder[10] = t;
			m_pfVerticesBoder[11] = 0;
		}
	}
}

void NDUILabel::preDraw()
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
}

void NDUILabel::draw()
{
	if (!isDrawEnabled()
		|| !NDDebugOpt::getDrawUILabelEnabled()
		|| !this->IsVisibled()) return;

	this->preDraw();

	if (!m_texture) return;
	
	NDUINode::draw();
	
	DrawSetup( kCCShader_PositionTextureColor );


	//** chh 2012-08-08 文字透明功能 **//
	if(m_kColor.a <255)
	{
		ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE);
	}
	else
	{
		//ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		ccGLBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	}

	ccGLBindTexture2D(m_texture->getName());

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

#if 0
	glTexCoordPointer(2, GL_FLOAT, 0, m_pfCoordinates);
	if (m_bHasFontBoderColor) 
	{
		glVertexPointer(3, GL_FLOAT, 0, m_pfVerticesBoder);
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_pbColorsBorder);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}

	glVertexPointer(3, GL_FLOAT, 0, m_pfVertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_pbColors);

	for (unsigned int i = 0; i < m_uiRenderTimes; i++) 
	{
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
#else
	//
	// Attributes
	//
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_pfCoordinates);

	if (m_bHasFontBoderColor) 
	{
		// vertex
		glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pfVerticesBoder);

		// color
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, m_pbColorsBorder);

		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}

	// vertex
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pfVertices);

	// color
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, m_pbColors);

	for (int i = 0; i < m_uiRenderTimes; i++)
	{
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}

	CHECK_GL_ERROR_DEBUG();
#endif
}

void NDUILabel::postDraw()
{
	debugDraw();
}

void NDUILabel::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	glLineWidth(1);
	ccDrawColor4F(1,0,0,1);
	CCPoint lb = ccp(m_pfVertices[0],m_pfVertices[1]);
	CCPoint rt = ccp(m_pfVertices[9],m_pfVertices[10]);
	ccDrawRect( lb, rt );
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

NS_NDENGINE_END
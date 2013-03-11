/*
 *  NDUIButton.mm
 *  DragonDrive
 *
 *  Created by wq on 10-12-29.
 *  Copyright 2010 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDUIButton.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "cocos2dExt.h"
#include "CCTextureCache.h"
#include "NDUIBaseGraphics.h"
#include "define.h"
#include "basedefine.h"
#include "NDPath.h"
#include "ccMacros.h"
#include "TQPlatform.h"
#include "CCCommon.h"
#include "ObjectTracker.h"

using namespace cocos2d;

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDUIButton, NDUIBaseItemButton)

#define FONT_SIZE 15
#define FONT_COLOR (ccc4(255, 255, 255, 255))
#define FONT_FOCUSCOLOR (INTCOLORTOCCC4(0x862700))

NDUIButton::NDUIButton()
{
	INC_NDOBJ_RTCLS

	m_bTabSel = false;
	m_image = NULL;
	m_touchDownImage = NULL;
	m_bFocusEnable = false;
	m_bChecked = false;
	m_disImage = 0;
	m_rimImageLT = NULL;
	m_rimImageRT = NULL;
	m_rimImageLB = NULL;
	m_rimImageRB = NULL;
	m_focusImage = NULL;

	m_pSprite = 0;

	m_SoundEffectId = 1;
	m_bCustomDisImageRect = false;
	m_ClearDisImageOnFree = false;

	m_touchDownStatus = TouchDownNone,
	m_focusStatus = FocusNone;

	//m_touchDownColor = ccc4(125, 125, 125, 125);
	m_touchDownColor = ccc4(255, 255, 255, 255);
	m_focusColor = ccc4(253, 253, 253, 0);
	m_touched = false;
	m_longTouched = false;
	m_framed = true;
	m_backgroundColor = ccc4(0, 0, 0, 0);

	m_normalImageColor = ccc4(255, 255, 255, 255);

	m_useCustomRect = false;
	m_customRect = CCRectZero;
	m_touchDownImgUseCustomRect = false;
	m_touchDownImgCustomRect = CCRectZero;

	m_bCustomFocusImageRect = false;
	m_customFocusImageRect = CCRectZero;

	m_clearUpPicOnFree = false;
	m_clearDownPicOnFree = false;

	m_title = NULL;

	m_scrtTitle = NULL;
	m_bAutoScroll = true;
	m_bForce = false;
	m_uiTitleFontSize = FONT_SIZE;
	m_colorTitle = FONT_COLOR;
	m_bNeedSetTitle = true;

	m_bScrollTitle = false;

	m_lbTitle1 = NULL;
	m_lbTitle2 = NULL;
	m_bNeedSetTwoTitle = false;
	m_uiTwoTitleInter = 0;

	m_combinepicImg = NULL;

	m_combinepicTouchDownImg = NULL;

	m_combinePicBG = m_combinePicTouchBG = NULL;

	m_picBG = m_picTouchBG = NULL;

	m_bClearBgOnFree = false;

	m_bArrow = false;

	//m_spriteArrow = NULL;

	m_ClearFocusImageOnFree = false;

	m_backgroundCustomRect = CCRectZero;

	m_useBackgroundCustomRect = false;

	m_uiTitleLeftWidth = m_uiTitleRightWidth = 0;

	m_bGray = false;

	m_colorFocusTitle = FONT_FOCUSCOLOR;

	bEnableHighlight = false;
}

NDUIButton::~NDUIButton()
{
	DEC_NDOBJ_RTCLS

	SAFE_DELETE( m_rimImageLT );
	SAFE_DELETE( m_rimImageRT );
	SAFE_DELETE( m_rimImageRB );
	SAFE_DELETE( m_rimImageLB );

	if (m_ClearDisImageOnFree)
	{
		SAFE_DELETE( m_disImage );
	}

	if (m_clearUpPicOnFree)
	{
		SAFE_DELETE( m_image );
		SAFE_DELETE( m_combinepicImg );
	}

	if (m_clearDownPicOnFree)
	{
		SAFE_DELETE( m_touchDownImage );
		SAFE_DELETE( m_combinepicTouchDownImg );
	}

	//if (m_spriteArrow) delete m_spriteArrow;

	if (m_ClearFocusImageOnFree && m_focusImage)
	{
		SAFE_DELETE( m_focusImage );
	}

	if (m_bClearBgOnFree)
	{
		SAFE_DELETE( m_picBG );

		SAFE_DELETE( m_picTouchBG );
	}

	SAFE_DELETE(m_pSprite);
	SAFE_DELETE_NODE(m_scrtTitle);
	SAFE_DELETE_NODE(m_title);
	SAFE_DELETE_NODE(m_lbTitle1);
	SAFE_DELETE_NODE(m_lbTitle2);
}

void NDUIButton::Initialization()
{
	NDUINode::Initialization();

// 		m_title = new NDUILabel();
// 		m_title->Initialization();
// 		m_title->SetFontSize(FONT_SIZE);
// 		m_title->SetTextAlignment(LabelTextAlignmentCenter);
	//this->AddChild(m_title,500);
}

void NDUIButton::SetImageLua(NDPicture* pic)
{
	this->SetImage(pic, false, CCRectZero, true);
}

void NDUIButton::SetImage(NDPicture* pic, bool useCustomRect, CCRect customRect,
		bool clearPicOnFree)
{
	if (m_clearUpPicOnFree)
	{
		CC_SAFE_DELETE (m_image);
		CC_SAFE_DELETE (m_combinepicImg);
	}

	m_combinepicImg = NULL;

	m_image = pic;
	m_useCustomRect = useCustomRect;
	m_customRect = customRect;
	m_clearUpPicOnFree = clearPicOnFree;
}

void NDUIButton::SetCombineImage(NDCombinePicture* combinepic,
		bool useCustomRect, CCRect customRect, bool clearPicOnFree)
{
	if (m_clearUpPicOnFree)
	{
		CC_SAFE_DELETE (m_image);
		CC_SAFE_DELETE (m_combinepicImg);
	}

	m_image = NULL;

	m_combinepicImg = combinepic;
	m_useCustomRect = useCustomRect;
	m_customRect = customRect;
	m_clearUpPicOnFree = clearPicOnFree;
}

void NDUIButton::SetTouchDownImageLua(NDPicture* pic)
{
	this->SetTouchDownImage(pic, false, CCRectZero, true);
}

void NDUIButton::SetTouchDownImage(NDPicture* pic, bool useCustomRect,
		CCRect customRect, bool clearPicOnFree)
{
	if (m_clearDownPicOnFree)
	{
		CC_SAFE_DELETE (m_touchDownImage);
		CC_SAFE_DELETE (m_combinepicTouchDownImg);
	}

	m_combinepicTouchDownImg = NULL;

	m_touchDownImage = pic;
	m_touchDownImgUseCustomRect = useCustomRect;
	m_touchDownImgCustomRect = customRect;
	m_touchDownStatus = TouchDownImage;
	m_clearDownPicOnFree = clearPicOnFree;
}

void NDUIButton::SetTouchDownCombineImage(NDCombinePicture* combinepic,
		bool useCustomRect, CCRect customRect, bool clearPicOnFree)
{
	if (m_clearDownPicOnFree)
	{
		CC_SAFE_DELETE (m_touchDownImage);
		CC_SAFE_DELETE (m_combinepicTouchDownImg);
	}

	m_touchDownImage = NULL;

	m_combinepicTouchDownImg = combinepic;
	m_touchDownImgUseCustomRect = useCustomRect;
	m_touchDownImgCustomRect = customRect;
	m_touchDownStatus = TouchDownImage;
	m_clearDownPicOnFree = clearPicOnFree;
}

void NDUIButton::SetTouchDownColor(ccColor4B touchDownColor)
{
	m_touchDownColor = touchDownColor;
	m_touchDownStatus = TouchDownColor;
}

void NDUIButton::SetFocusColor(ccColor4B focusColor)
{
	m_focusColor = focusColor;
	m_focusStatus = FocusColor;
}

void NDUIButton::SetFocusRimImage()
{
	m_rimImageLT = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("rim.png"));
	m_rimImageLT->SetReverse(true);
	m_rimImageLT->Rotation(PictureRotation270);

	m_rimImageRT = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("rim.png"));
	m_rimImageRT->Rotation(PictureRotation90);

	m_rimImageLB= NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("rim.png"));
	m_rimImageLB->Rotation(PictureRotation270);

	m_rimImageRB = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("rim.png"));
	m_rimImageRB->SetReverse(true);
	m_rimImageRB->Rotation(PictureRotation90);

	m_focusStatus = FocusRimImage;
}

void NDUIButton::SetFocusNormal()
{
	m_focusStatus = FocusNone;
}

void NDUIButton::SetFocusImageLua(NDPicture *pic)
{
	this->SetFocusImage(pic, false, CCRectZero, true);
}

void NDUIButton::SetFocusImage(NDPicture *pic, bool useCustomRect/*= false*/,
		CCRect customRect/*= CCRectZero*/, bool clearPicOnFree/* = false*/)
{
	if (m_ClearFocusImageOnFree && m_focusImage)
	delete m_focusImage;
	m_focusImage = pic;
	m_bCustomFocusImageRect = useCustomRect;
	m_customFocusImageRect = customRect;
	m_focusStatus = FocusImage;
	m_ClearFocusImageOnFree = clearPicOnFree;
}

void NDUIButton::SetTitle(const char* title, bool bAutoScroll/*=true*/,
		bool bForce/*=false*/, unsigned int leftWidth/*=0*/,
		unsigned int rightWidth/*=0*/)
{
	//m_title->SetText(title);
	m_strTitle = title;

	std::string::size_type pos;
	while ((pos = m_strTitle.find("\n")) != std::string::npos)
		m_strTitle.replace(pos, strlen("\n"), " ");

	m_bAutoScroll = bAutoScroll;
	m_bForce = bForce;
	m_bNeedSetTitle = true;

	m_uiTitleLeftWidth = leftWidth;

	m_uiTitleRightWidth = rightWidth;

}

void NDUIButton::SetTitleLua(const char* title)
{
	//NSString *str = [NSString stringWithCString:title];
	SetTitle(title);
}

std::string NDUIButton::GetTitle()
{
	//return m_title->GetText();
	return m_strTitle;
}

void NDUIButton::SetFontSize(unsigned int fontSize)
{
	//m_title->SetFontSize(fontSize);
	m_uiTitleFontSize = fontSize;
	m_bNeedSetTitle = true;
}

unsigned int NDUIButton::GetFontSize()
{
	//return m_title->GetFontSize();
	return m_uiTitleFontSize;
}

void NDUIButton::SetFrameRect(CCRect rect)
{
	NDUINode::SetFrameRect(rect);
	//m_title->SetFrameRect(CCRectMake(0, 0, rect.size.width, rect.size.height));
}

bool NDUIButton::isHighlight() const
{
	return bEnableHighlight && (m_touched || m_longTouched);
}

void NDUIButton::draw()
{
	//cocos2d::CCLog("Entry NDUIButton::draw()");

	if (!isDrawEnabled()) return;

	NDUINode::draw();

	if (!this->IsVisibled()) return;
	
	if (m_bNeedSetTitle)
	{
		SetTitle();
		m_bNeedSetTitle = false;
	}

	if (m_bNeedSetTwoTitle)
	{
		SetTwoTitle();
		m_bNeedSetTwoTitle = false;
	}

	// check parent as uiLayer
	NDNode* parentNode = this->GetParent();
	if (!parentNode) return;
	if (!parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) return;
	NDUILayer* uiLayer = (NDUILayer*) parentNode;

	// draw gray image
	CCRect scrRect = this->GetScreenRect();
	if(m_bGray && m_disImage)
	{
		m_disImage->DrawInRect(scrRect);
		return;
	}

	//draw back ground
	if (m_picBG && !m_longTouched)
	{
		if (m_useBackgroundCustomRect)
		{
			m_picBG->DrawInRect(
					CCRectMake(
							scrRect.origin.x
									+ m_backgroundCustomRect.origin.x,
							scrRect.origin.y
									+ m_backgroundCustomRect.origin.y,
							m_backgroundCustomRect.size.width,
							m_backgroundCustomRect.size.height),
							isHighlight());
		}
		else
		{
			m_picBG->DrawInRect(scrRect, isHighlight());
		}
	}
	else if (m_combinePicBG)
	{
		m_combinePicBG->DrawInRect(scrRect);
	}
	else
	{
		DrawRecttangle(scrRect, m_backgroundColor);
	}

	// scroll title
	if (m_bScrollTitle && m_scrtTitle
			&& m_scrtTitle->GetParent() == this)
	{
		if (uiLayer->GetFocus() == this)
		{
			// !run -> start
			if (!m_scrtTitle->isRunning())
			{
				m_scrtTitle->Run();
			}

			m_scrtTitle->SetFontColor(m_colorFocusTitle);
		}
		else
		{
			// run -> stop -> resetpos
			if (m_scrtTitle->isRunning())
			{
				m_scrtTitle->Stop();
				m_scrtTitle->SetTextPos(CCPointMake(5.0f, 0.0f));
			}

			m_scrtTitle->SetFontColor(m_colorTitle);
		}
	}

	//draw focus 
	if (uiLayer->GetFocus() == this || IsTabSel())
	{
		drawFocus();
	}
	else
	{
		if (m_title)
		{
			m_title->SetFontColor(m_colorTitle);
		}
	}

	//draw touch down status
	if (m_bChecked || (m_touched && !m_longTouched))
	{
		drawTouchDown();
	}

	//button image
	if (m_image || m_combinepicImg)
	{
		drawButtonImage();
	}
	else
	{
		if (m_framed)
		{
			drawButtonFrame();
		}
	}

	if (m_pSprite)
	{
		m_pSprite->SetPosition(ccpAdd(scrRect.origin, m_posSprite));
		m_pSprite->Run( CCDirector::sharedDirector()->getWinSizeInPixels() );
	}

	if (m_longTouched)
	{
		drawLongTouch();
	}
}

void NDUIButton::drawLongTouch()
{
	NDPicture *pic = NULL;

	if (m_touchDownImage != NULL)
	{
		pic = m_touchDownImage;
	}
	else
	{
		pic = m_image ? m_image : m_picBG;
	}

	if (pic)
	{
		pic->SetColor(ccc4(255, 255, 255, 255));

		//** chh 2012-07-31 修改button放大效果 **//
		/*
		 CCRect rect = CCRectMake(scrRect.origin.x - 5 * fScale, 
		 scrRect.origin.y - 5 * fScale, 
		 scrRect.size.width + 10 * fScale, 
		 scrRect.size.height + 10 * fScale);
		 
		 */

		CCRect scrRect = this->GetScreenRect();
		pic->DrawInRect(scrRect, isHighlight());
		pic->SetColor(m_normalImageColor);
	}
}

void NDUIButton::drawButtonFrame()
{
	CCRect scrRect = this->GetScreenRect();

	DrawPolygon(scrRect, ccc4(16, 56, 66, 255), 2);
	
	DrawPolygon(
		CCRectMake(scrRect.origin.x + 3,
		scrRect.origin.y + 3,
		scrRect.size.width - 6,
		scrRect.size.height - 6),
		ccc4(134, 39, 0, 255), 1);

	//左上角
	DrawLine(
		ccp(scrRect.origin.x + 3, scrRect.origin.y + 8),
		ccp(scrRect.origin.x + 8, scrRect.origin.y + 3),
		ccc4(134, 39, 0, 255), 1);

	//右上角
	DrawLine(
		ccp(scrRect.origin.x + scrRect.size.width - 3,
		scrRect.origin.y + 8),
		ccp(scrRect.origin.x + scrRect.size.width - 8,
		scrRect.origin.y + 3),
		ccc4(134, 39, 0, 255), 1);

	//左下角
	DrawLine(
		ccp(scrRect.origin.x + 3,
		scrRect.origin.y + scrRect.size.height
		- 8),
		ccp(scrRect.origin.x + 8,
		scrRect.origin.y + scrRect.size.height
		- 3), ccc4(134, 39, 0, 255), 1);

	//右下角
	DrawLine(
		ccp(scrRect.origin.x + scrRect.size.width - 3,
		scrRect.origin.y + scrRect.size.height
		- 8),
		ccp(scrRect.origin.x + scrRect.size.width - 8,
		scrRect.origin.y + scrRect.size.height
		- 3), ccc4(134, 39, 0, 255), 1);
}

void NDUIButton::drawButtonImage()
{
	CCRect scrRect = this->GetScreenRect();
	NDUILayer* uiLayer = (NDUILayer*) this->GetParent();
	CCAssert(uiLayer, "drawButtonImage");

	if (!m_touched
		|| NULL == m_touchDownImage && false == m_bChecked)
	{
		if (m_image)
			m_image->SetColor(m_normalImageColor);
		else if (m_combinepicImg)
			m_combinepicImg->SetColor(ccc4(255, 255, 255, 255));
	}

	if (!IsTabSel() && (m_touchDownStatus != TouchDownImage || !m_touched
		|| NULL == m_touchDownImage))
	{
		if (m_useCustomRect)
		{
			CCRect rect = CCRectMake(
				scrRect.origin.x + m_customRect.origin.x,
				scrRect.origin.y + m_customRect.origin.y,
				m_customRect.size.width,
				m_customRect.size.height);

			if (m_touched && NULL == m_touchDownImage
				&& m_touchDownStatus == TouchDownImage)
			{
				//float fScale = RESOURCE_SCALE;

				//** chh 2012-07-31 修改button放大效果 **//
				/*
				rect.origin.x		-= 5* fScale;
				rect.origin.y		-= 5 * fScale;
				rect.size.width		+= 10* fScale;
				rect.size.height	+= 10* fScale;
			 */
			}

			if (uiLayer->GetFocus() == this || IsTabSel())
			{
				if (m_focusStatus == FocusImage && m_focusImage
					&& m_bFocusEnable)
				{
					if (m_image)
						m_image->SetColor(m_backgroundColor);
				}
				else
				{
					if (m_image)
						m_image->SetColor(m_normalImageColor);
				}
			}

			if (m_image)
			{
				cocos2d::CCLog("entry m_image->DrawInRect(rect);");
				m_image->DrawInRect(rect, isHighlight());
			}
			else if (m_combinepicImg)
				m_combinepicImg->DrawInRect(rect);
		}
		else
		{
			CCRect rect = scrRect;
			if (m_touched && NULL == m_touchDownImage
				&& m_touchDownStatus == TouchDownImage)
			{
				//float fScale = RESOURCE_SCALE;
				//** chh 2012-07-31 修改button放大效果 **//
				/*
				rect.origin.x		-= 5* fScale;
				rect.origin.y		-= 5 * fScale;
				rect.size.width		+= 10* fScale;
				rect.size.height	+= 10* fScale;
			 */
			}

			if (uiLayer->GetFocus() == this || IsTabSel())
			{
				if(m_focusStatus == FocusImage &&
					m_focusImage && m_bFocusEnable)
				{
					if (m_image) m_image->SetColor(m_backgroundColor);
				}
				else
				{
					if (m_image) m_image->SetColor(m_normalImageColor);
				}
			}

			if (m_image)
			{
				m_image->DrawInRect(rect, isHighlight());
			}
// 			if (m_title 
// 				&& m_title->GetText().length() > 0)
// 			{
// 				m_title->draw();
// 			}
// 			else 
				if (m_combinepicImg)
			{
				m_combinepicImg->DrawInRect(rect);
			}
		}
	}
}

void NDUIButton::drawTouchDown()
{
	CCRect scrRect = this->GetScreenRect();

	if (m_picTouchBG)
	{
		m_picTouchBG->DrawInRect(scrRect, isHighlight());
	}

	if (m_combinePicTouchBG)
	{
		m_combinePicTouchBG->DrawInRect(scrRect);
	}

	if (m_touchDownStatus == TouchDownImage)
	{
		if (m_touchDownImage)
		{
			if (m_touchDownImgUseCustomRect)
			{
				m_touchDownImage->DrawInRect(
					CCRectMake(
					scrRect.origin.x
					+ m_touchDownImgCustomRect.origin.x,
					scrRect.origin.y
					+ m_touchDownImgCustomRect.origin.y,
					m_touchDownImgCustomRect.size.width,
					m_touchDownImgCustomRect.size.height),
					isHighlight());
			}
			else
			{
				m_touchDownImage->DrawInRect(scrRect,isHighlight());
			}
		}
		else if (m_combinepicTouchDownImg)
		{
			if (m_touchDownImgUseCustomRect)
			{
				m_combinepicTouchDownImg->DrawInRect(
					CCRectMake(
					scrRect.origin.x
					+ m_touchDownImgCustomRect.origin.x,
					scrRect.origin.y
					+ m_touchDownImgCustomRect.origin.y,
					m_touchDownImgCustomRect.size.width,
					m_touchDownImgCustomRect.size.height));
			}
			else
			{
				m_combinepicTouchDownImg->DrawInRect(scrRect);
			}
		}
	}
	else if (m_touchDownStatus == TouchDownColor)
	{
		if (m_image)
			m_image->SetColor(m_touchDownColor);
		else if (m_combinepicImg)
			m_combinepicImg->SetColor(m_touchDownColor);
		else
			DrawRecttangle(scrRect, m_touchDownColor);
	}
}

void NDUIButton::drawFocus()
{
	CCRect scrRect = this->GetScreenRect();

	if (m_focusStatus == FocusColor && m_bFocusEnable)
	{
		DrawRecttangle(scrRect, m_focusColor);
		if (m_title)
		{
			m_title->SetFontColor(m_colorFocusTitle);
		}
	}
	else if (m_focusStatus == FocusRimImage && m_bFocusEnable)
	{
		DrawRecttangle(scrRect, ccc4(138, 8, 8, 255));

		m_rimImageLT->DrawInRect(
			CCRectMake(scrRect.origin.x - 2,
			scrRect.origin.y - 3,
			m_rimImageLT->GetSize().width,
			m_rimImageLT->GetSize().height));

		m_rimImageRT->DrawInRect(
			CCRectMake(
			scrRect.origin.x + scrRect.size.width - m_rimImageRT->GetSize().width + 2, 
			scrRect.origin.y - 3,
			m_rimImageRT->GetSize().width,
			m_rimImageRT->GetSize().height));

		m_rimImageLB->DrawInRect(
			CCRectMake(scrRect.origin.x - 2,
			scrRect.origin.y + scrRect.size.height - m_rimImageLB->GetSize().height + 3,
			m_rimImageLB->GetSize().width,
			m_rimImageLB->GetSize().height));

		m_rimImageRB->DrawInRect(
			CCRectMake(
			scrRect.origin.x + scrRect.size.width - m_rimImageRT->GetSize().width + 2,
			scrRect.origin.y + scrRect.size.height - m_rimImageLB->GetSize().height + 3,
			m_rimImageRB->GetSize().width,
			m_rimImageRB->GetSize().height));

		int d = 0;
		if (scrRect.origin.x < CCDirector::sharedDirector()->getWinSizeInPixels().width / 2)
		{
			d = 1;
		}
		//left frame
		DrawLine(
			ccp(scrRect.origin.x + d,
				scrRect.origin.y + m_rimImageLT->GetSize().height - 8),
			ccp(scrRect.origin.x + d,
				scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
			ccc4(172, 159, 71, 255),
			1);
		DrawLine(
			ccp(scrRect.origin.x + d + 1,
				scrRect.origin.y + m_rimImageLT->GetSize().height - 8),
			ccp(scrRect.origin.x + d + 1,
				scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
			ccc4(255, 233, 86, 255),
			1);
		DrawLine(
			ccp(scrRect.origin.x + d + 2,
				scrRect.origin.y + m_rimImageLT->GetSize().height - 8),
			ccp(scrRect.origin.x + d + 2,
				scrRect.origin.y + scrRect.size.height - m_rimImageLT->GetSize().height + 8), 
			ccc4(172, 159, 71, 255),
			1);

		//right frame
		DrawLine(
			ccp(
				scrRect.origin.x + scrRect.size.width + d - 1,
				scrRect.origin.y + m_rimImageRT->GetSize().height - 8),
			ccp(
				scrRect.origin.x + scrRect.size.width + d - 1,
				scrRect.origin.y + scrRect.size.height
			- m_rimImageRT->GetSize().height + 8), 
			ccc4(172, 159, 71, 255),
			1);
		DrawLine(
			ccp(
				scrRect.origin.x + scrRect.size.width + d - 2,
				scrRect.origin.y + m_rimImageRT->GetSize().height - 8),
			ccp(scrRect.origin.x + scrRect.size.width + d - 2,
				scrRect.origin.y + scrRect.size.height - m_rimImageRT->GetSize().height + 8), 
			ccc4(255, 233, 86, 255),
			1);
		DrawLine(
			ccp(
				scrRect.origin.x + scrRect.size.width+ d - 3,
				scrRect.origin.y+ m_rimImageRT->GetSize().height- 8),
			ccp(
				scrRect.origin.x + scrRect.size.width+ d - 3,
				scrRect.origin.y + scrRect.size.height- m_rimImageRT->GetSize().height+ 8), 
			ccc4(172, 159, 71, 255),
			1);

		//top frame
		DrawLine(
			ccp(scrRect.origin.x+ m_rimImageLT->GetSize().width- 8, scrRect.origin.y),
			ccp(scrRect.origin.x + scrRect.size.width- m_rimImageLT->GetSize().width+ 8, scrRect.origin.y),
			ccc4(172, 159, 71, 255), 1);
		DrawLine(
			ccp(
				scrRect.origin.x+ m_rimImageLT->GetSize().width- 8, 
				scrRect.origin.y + 1),
			ccp(
				scrRect.origin.x + scrRect.size.width- m_rimImageLT->GetSize().width+ 8, 
				scrRect.origin.y + 1),
			ccc4(255, 233, 86, 255), 1);
		DrawLine(
			ccp(
			scrRect.origin.x
			+ m_rimImageLT->GetSize().width
			- 8, scrRect.origin.y + 2),
			ccp(
			scrRect.origin.x + scrRect.size.width
			- m_rimImageLT->GetSize().width
			+ 8, scrRect.origin.y + 2),
			ccc4(172, 159, 71, 255), 1);

		//bottom frame
		DrawLine(
			ccp(
			scrRect.origin.x
			+ m_rimImageLT->GetSize().width
			- 8,
			scrRect.origin.y + scrRect.size.height
			- 1),
			ccp(
			scrRect.origin.x + scrRect.size.width
			- m_rimImageLT->GetSize().width
			+ 8,
			scrRect.origin.y + scrRect.size.height
			- 1), ccc4(172, 159, 71, 255),
			1);
		DrawLine(
			ccp(
			scrRect.origin.x
			+ m_rimImageLT->GetSize().width
			- 8,
			scrRect.origin.y + scrRect.size.height
			- 2),
			ccp(
			scrRect.origin.x + scrRect.size.width
			- m_rimImageLT->GetSize().width
			+ 8,
			scrRect.origin.y + scrRect.size.height
			- 2), ccc4(255, 233, 86, 255),
			1);
		DrawLine(
			ccp(
			scrRect.origin.x
			+ m_rimImageLT->GetSize().width
			- 8,
			scrRect.origin.y + scrRect.size.height
			- 3),
			ccp(
			scrRect.origin.x + scrRect.size.width
			- m_rimImageLT->GetSize().width
			+ 8,
			scrRect.origin.y + scrRect.size.height
			- 3), ccc4(172, 159, 71, 255),
			1);

	}
	else if (m_focusStatus == FocusImage && m_focusImage && m_bFocusEnable)
	{
		if (m_bCustomFocusImageRect)
		{
			m_focusImage->DrawInRect(
				CCRectMake(
				scrRect.origin.x
				+ m_customFocusImageRect.origin.x,
				scrRect.origin.y
				+ m_customFocusImageRect.origin.y,
				m_customFocusImageRect.size.width,
				m_customFocusImageRect.size.height),
				isHighlight());
		}
		else
		{
			m_focusImage->DrawInRect(scrRect,isHighlight());
		}
	}
}

void NDUIButton::SetFontColor(ccColor4B fontColor)
{
	//m_title->SetFontColor(fontColor);
	m_colorTitle = fontColor;
	m_bNeedSetTitle = true;
}

void NDUIButton::SetFocusFontColor(ccColor4B focusFontColor)
{
	m_colorFocusTitle = focusFontColor;
	m_bNeedSetTitle = true;
}

ccColor4B NDUIButton::GetFontColor()
{
	//return m_title->GetFontColor();
	return m_colorTitle;
}

void NDUIButton::OnTouchDown(bool touched)
{
	m_touched = touched;
	NDUIButtonDelegate* delegate =
			dynamic_cast<NDUIButtonDelegate*>(this->GetDelegate());
	if (delegate)
	{
		if (m_touched)
		{
			delegate->OnButtonDown(this);
		}
		else
		{
			delegate->OnButtonUp(this);
		}
	}
}

void NDUIButton::OnLongTouchDown(bool touched)
{
	m_longTouched = touched;
}

void NDUIButtonDelegate::OnButtonClick(NDUIButton* button)
{
}

void NDUIButtonDelegate::OnButtonDown(NDUIButton* button)
{
}

void NDUIButtonDelegate::OnButtonUp(NDUIButton* button)
{
}

bool NDUIButtonDelegate::OnButtonLongClick(NDUIButton* button)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonDragOut(NDUIButton* button, CCPoint beginTouch,
		CCPoint moveTouch, bool longTouch)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonDragOutComplete(NDUIButton* button,
		CCPoint endTouch, bool outOfRange)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonDragIn(NDUIButton* desButton,
		NDUINode *uiSrcNode, bool longTouch)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonDragOver(NDUIButton* overButton, bool inRange)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonLongTouch(NDUIButton* button)
{
	return false;
}

bool NDUIButtonDelegate::OnButtonLongTouchCancel(NDUIButton* button)
{
	return false;
}

void NDUIButton::SetBackgroundColor(ccColor4B color)
{
	m_backgroundColor = color;
}

void NDUIButton::SetBackgroundPictureLua(NDPicture *pic,
		NDPicture *touchPic/*= NULL*/)
{
	this->SetBackgroundPicture(pic, touchPic, false, CCRectZero, true);
}

void NDUIButton::SetBackgroundPicture(NDPicture *pic,
		NDPicture *touchPic /*= NULL*/, bool useCustomRect/* = false*/,
		CCRect customRect/* = CCRectZero*/, bool clearPicOnFree/* = false*/)
{
	if (m_bClearBgOnFree)
	{
		delete m_picBG;

		delete m_picTouchBG;
	}

	m_useBackgroundCustomRect = useCustomRect;

	m_backgroundCustomRect = customRect;

	m_picBG = pic;

	m_picTouchBG = touchPic;

	m_bClearBgOnFree = clearPicOnFree;
}

void NDUIButton::SetBackgroundCombinePic(NDCombinePicture *combinepic,
		NDCombinePicture *touchCombinePic/* = NULL*/,
		bool clearPicOnFree/* = false*/)
{
	/*
	 if (m_bClearBgOnFree)
	 {
	 delete m_picBG;
	 
	 delete m_picTouchBG;
	 }
	 
	 m_picBG = NULL;
	 
	 m_picTouchBG = NULL;
	 
	 m_combinePicBG = combinepic;
	 
	 m_combinePicTouchBG = touchCombinePic;
	 
	 m_bClearBgOnFree = clearPicOnFree;
	 */
}

void NDUIButton::SetTitle()
{
//		if (m_strTitle.empty()) 
//		{
//			return;
//		}

	CCRect rect = this->GetFrameRect();

	CCSize sizetext = getStringSize(m_strTitle.c_str(), m_uiTitleFontSize);

	//sizetext.width += 10;

	bool bOverRange = sizetext.width > rect.size.width ? true : false;

	if ((m_bAutoScroll && bOverRange) || m_bForce)
	{
		SAFE_DELETE_NODE (m_title);
		SAFE_DELETE_NODE (m_scrtTitle);
		m_scrtTitle = new NDUIScrollText;
		m_scrtTitle->Initialization();
		m_scrtTitle->SetText(m_strTitle.c_str());
		m_scrtTitle->SetFontSize(m_uiTitleFontSize);
		m_scrtTitle->SetFontColor(m_colorTitle);
		m_scrtTitle->SetScrollType(ScrollTextFromRightToLeft);
		m_scrtTitle->SetScrollTextSpeed(60);
		m_scrtTitle->SetFrameRect(
				CCRectMake(5, (rect.size.height - m_uiTitleFontSize) / 2,
						rect.size.width, rect.size.height));
		m_scrtTitle->SetTouchEnabled(false);
		// start pos
		m_scrtTitle->SetStartPos(CCPointMake(5.0f, 0.0f));
		m_scrtTitle->Stop();
		this->AddChild(m_scrtTitle);

		m_bScrollTitle = true;
	}
	else
	{
		SAFE_DELETE_NODE (m_scrtTitle);
		SAFE_DELETE_NODE (m_title);
		m_title = new NDUILabel();
		m_title->Initialization();
		m_title->SetFontSize(m_uiTitleFontSize);
		m_title->SetText(m_strTitle.c_str());
		m_title->SetFontColor(m_colorTitle);
		m_title->SetTextAlignment(LabelTextAlignmentCenter);
		m_title->SetFrameRect(
				CCRectMake(0 + m_uiTitleLeftWidth, 0,
						rect.size.width - m_uiTitleLeftWidth
								- m_uiTitleRightWidth, rect.size.height));
		this->AddChild(m_title);
		m_bScrollTitle = false;

#if 0 //for debug //@del
		if (m_strTitle.length() > 0) 
		{
			m_title->MakeTexture();
			m_title->MakeCoordinates();
			m_title->MakeVertices();
		}
#endif
	}
}

void NDUIButton::SetText(const char* text1, const char* text2,
		unsigned int interaval/* = 0*/,
		ccColor4B color1/* = ccc4(0, 0, 0, 255)*/,
		ccColor4B color2/* = ccc4(0, 0, 0, 255)*/,
		unsigned int fontSize1/* = 13*/, unsigned int fontSize2/* = 13*/)
{
	if (!text1 || !text2)
	{
		return;
	}

	if (!m_lbTitle1)
	{
		m_lbTitle1 = new NDUILabel;
		m_lbTitle1->Initialization();
	}

	m_lbTitle1->SetText(text1);
	m_lbTitle1->SetFontColor(color1);
	m_lbTitle1->SetFontSize(fontSize1);
	m_lbTitle1->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTitle1->SetFrameRect(CCRectZero);
	this->AddChild(m_lbTitle1);

	if (!m_lbTitle2)
	{
		m_lbTitle2 = new NDUILabel;
		m_lbTitle2->Initialization();
	}

	m_lbTitle2->SetText(text2);
	m_lbTitle2->SetFontColor(color2);
	m_lbTitle2->SetFontSize(fontSize2);
	m_lbTitle2->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTitle2->SetFrameRect(CCRectZero);
	this->AddChild(m_lbTitle2);

	m_uiTwoTitleInter = interaval;

	m_bNeedSetTwoTitle = true;
}

void NDUIButton::SetArrow(bool bSet)
{
	m_bArrow = bSet;
}

void NDUIButton::SetTwoTitle()
{
	if (!m_lbTitle1 || !m_lbTitle2)
	{
		return;
	}

	CCRect rect = this->GetFrameRect();

	CCSize size1 = getStringSize(m_lbTitle1->GetText().c_str(),
			m_lbTitle1->GetFontSize());

	CCSize size2 = getStringSize(
			m_lbTitle2->GetText().c_str(), m_lbTitle2->GetFontSize());

	int iStartX = (rect.size.width - size1.width - size2.width
			- m_uiTwoTitleInter) / 2;
	if (iStartX < 0)
	{
		iStartX = 0;
	}

	m_lbTitle1->SetFrameRect(
			CCRectMake(iStartX, (rect.size.height - size1.height) / 2,
					size1.width, size1.height));
	m_lbTitle2->SetFrameRect(
			CCRectMake(iStartX + size1.width + m_uiTwoTitleInter,
					(rect.size.height - size2.height) / 2, size2.width,
					size2.height));
}

void NDUIButton::SetDisImage(NDPicture *pic, bool useCustomRect /*= false*/,
		CCRect customRect /*= CCRectZero*/, bool clearPicOnFree /*= false*/)
{
	if (m_ClearDisImageOnFree && m_disImage)
	{
		delete m_disImage;
	}
	m_disImage = pic;
	m_bCustomDisImageRect = useCustomRect;
	m_customDisImageRect = customRect;
	m_ClearDisImageOnFree = clearPicOnFree;
}

void NDUIButton::TabSel(bool bSel)
{
	m_bTabSel = bSel;
}

bool NDUIButton::IsTabSel()
{
	return m_bTabSel;
}

void NDUIButton::ChangeSprite(const char* szSprite, CCPoint posOffset)
{
	SAFE_DELETE (m_pSprite);
	if (!szSprite || szSprite == std::string(""))
	{
		return;
	}
	m_pSprite = new NDLightEffect;
	m_pSprite->Initialization(szSprite);
	m_pSprite->SetLightId(0, false);
	m_posSprite = posOffset;
}

void NDUIButton::SetFocus(bool bFocus)
{
	m_bFocusEnable = bFocus;
}

void NDUIButton::SetSoundEffect(int nId)
{
	m_SoundEffectId = nId;
}

int NDUIButton::GetSoundEffect()
{
	return m_SoundEffectId;
}

bool NDUIButton::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_scrtTitle || pNode == m_title || pNode == m_lbTitle1
			|| pNode == m_lbTitle2)
	{
		return false;
	}

	return true;
}

NS_NDENGINE_END
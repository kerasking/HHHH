/*
 *  NDOptionButton.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-10.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDUIOptionButton.h"
//#include "NDUILayer.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "NDUIBaseGraphics.h"

using namespace cocos2d;

namespace NDEngine
{
IMPLEMENT_CLASS(NDUIOptionButton, NDUINode)

#define FONT_SIZE 15

NDUIOptionButton::NDUIOptionButton()
{
	m_clrBg = ccc4(255, 255, 255, 255);
	m_optIndex = 0;
	m_frameOpened = true;
	/*
	 NSString *imagePath = [NSString stringWithUTF8String:NDEngine::NDPath::GetImagePath().c_str()];
	 NSString *image = [NSString stringWithFormat:@"%@%@", imagePath, @"arrow.png"];
	 
	 CCTexture2D *texture = [[CCTexture2D alloc] initWithImage:[UIImage imageWithContentsOfFile:image]];
	 
	 m_leftArrow = [[NDTile alloc] init];
	 m_leftArrow.texture = texture;
	 m_leftArrow.cutRect = CGRectMake(0, 0, texture.maxS * texture.pixelsWide, texture.maxT * texture.pixelsHigh);
	 CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	 m_leftArrow.mapSize = CGSizeMake(winSize.width, winSize.height);
	 m_leftArrow.reverse = YES;
	 m_leftArrow.rotation = NDRotationEnumRotation0;
	 
	 m_rightArrow = [[NDTile alloc] init];
	 m_rightArrow.texture = texture;
	 m_rightArrow.cutRect = CGRectMake(0, 0, texture.maxS * texture.pixelsWide, texture.maxT * texture.pixelsHigh);
	 m_rightArrow.mapSize = CGSizeMake(winSize.width, winSize.height);
	 m_rightArrow.reverse = NO;
	 m_rightArrow.rotation = NDRotationEnumRotation0;		
	 
	 [texture release];*/
}

NDUIOptionButton::~NDUIOptionButton()
{
	CC_SAFE_RELEASE (m_leftArrow);
	CC_SAFE_RELEASE (m_rightArrow);
	if (m_title->GetParent())
	{
		m_title->RemoveFromParent(true);
	}
}

void NDUIOptionButton::Initialization()
{
	NDUINode::Initialization();

	m_title = new NDUILabel();
	m_title->Initialization();
	m_title->SetFontSize(FONT_SIZE);
	m_title->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_title);
}

void NDUIOptionButton::SetFontColor(ccColor4B fontColor)
{
	m_title->SetFontColor(fontColor);
}

void NDUIOptionButton::SetFontSize(unsigned int fontSize)
{
	m_title->SetFontSize(fontSize);
}

void NDUIOptionButton::SetOptIndex(uint index)
{
	if (index >= m_vOptions.size())
	{
		return;
	}

	m_optIndex = index;

	m_title->SetText(m_vOptions.at(m_optIndex).c_str());
}

void NDUIOptionButton::SetOptions(const VEC_OPTIONS& ops)
{
	m_vOptions = ops;

	if (m_vOptions.size() > 0)
	{
		m_title->EnableDraw(true);

		m_optIndex = 0;
		m_title->SetText(m_vOptions.at(m_optIndex).c_str());
	}
	else
		m_title->EnableDraw(false);
}

int NDUIOptionButton::GetOptionIndex()
{
	return m_optIndex;
}

void NDUIOptionButton::SetBgClr(ccColor4B clr)
{
	m_clrBg = clr;
}

void NDUIOptionButton::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	m_title->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
}

void NDUIOptionButton::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
{/*
 m_leftArrow.drawRect = CGRectMake(dstRect.origin.x + 3, dstRect.origin.y + 5, 5, 7);
 [m_leftArrow make];
 
 m_rightArrow.drawRect = CGRectMake(dstRect.origin.x + dstRect.size.width - 8, dstRect.origin.y + 5, 5, 7);
 [m_rightArrow make];*/
}

void NDUIOptionButton::draw()
{
	NDUINode::draw();

	NDNode* parentNode = this->GetParent();
	if (parentNode && this->IsVisibled())
	{
		CGRect scrRect = this->GetScreenRect();

		//draw context
		DrawRecttangle(scrRect, m_clrBg);

		//draw frame
		if (m_frameOpened)
			DrawPolygon(
					CGRectMake(scrRect.origin.x - 1, scrRect.origin.y - 1,
							scrRect.size.width + 2, scrRect.size.height + 2),
					ccc4(125, 125, 125, 255), 2);

		// draw arrow
		//glDisableClientState(GL_COLOR_ARRAY);
		/*[m_leftArrow draw];
		 [m_rightArrow draw];*/
		//glEnableClientState(GL_COLOR_ARRAY);
	}
}

void NDUIOptionButton::NextOpt()
{
	int nSize = m_vOptions.size();
	if (nSize > 0)
	{
		this->m_optIndex = m_optIndex >= nSize - 1 ? 0 : m_optIndex + 1;
		if (m_optIndex < nSize)
		{
			m_title->SetText(m_vOptions.at(m_optIndex).c_str());
		}
	}
}

void NDUIOptionButton::PreOpt()
{
	int nSize = m_vOptions.size();
	if (nSize > 0)
	{
		this->m_optIndex = m_optIndex <= 0 ? nSize - 1 : m_optIndex - 1;
		m_title->SetText(m_vOptions.at(m_optIndex).c_str());
	}
}

void NDUIOptionButtonDelegate::OnOptionChange(NDUIOptionButton* option)
{

}
}

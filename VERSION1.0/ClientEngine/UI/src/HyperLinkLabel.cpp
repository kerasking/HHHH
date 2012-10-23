/*
 *  HyperLinkLabel.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-23.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "HyperLinkLabel.h"
#include "NDUIBaseGraphics.h"

IMPLEMENT_CLASS(HyperLinkLabel, NDUILabel)

HyperLinkLabel::HyperLinkLabel()
{
	m_bIsLink = false;
}

HyperLinkLabel::~HyperLinkLabel()
{

}

void HyperLinkLabel::SetIsLink(bool isLink)
{
	m_bIsLink = isLink;
}

void HyperLinkLabel::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}

	NDUILabel::draw();

	if (m_bIsLink)
	{
		CGRect kRect = this->GetScreenRect();
		DrawLine(CGPointMake(kRect.origin.x, kRect.origin.y + kRect.size.height),
				CGPointMake(kRect.origin.x + kRect.size.width,
						kRect.origin.y + kRect.size.height), 
						this->GetFontColor(),1);
	}
}
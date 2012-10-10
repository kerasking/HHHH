/*
 *  NDUISearchButton.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUISearchButton.h"

IMPLEMENT_CLASS(NDUISearchButton, NDUIButton)

NDUISearchButton::NDUISearchButton()
{
	m_title1 = NULL;
	m_title2 = NULL;
}

NDUISearchButton::~NDUISearchButton()
{
	
}

void NDUISearchButton::Initialization()
{
	NDUINode::Initialization();
	
	m_title1 = new NDUILabel();
	m_title1->Initialization();
	m_title1->SetFontSize(15);
	m_title1->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_title1);
	
	m_title2 = new NDUILabel();
	m_title2->Initialization();
	m_title2->SetFontSize(15);
	m_title2->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(m_title2);
}

void NDUISearchButton::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	m_title1->SetFrameRect(CGRectMake(0, 5, rect.size.width / 2 - 2, rect.size.height));
	m_title2->SetFrameRect(CGRectMake(rect.size.width / 2 + 2, 5, rect.size.width / 2 - 2, rect.size.height));
}

void NDUISearchButton::SetTitles(const string& title1, const string& title2)
{
	m_title1->SetText(title1.c_str());
	m_title1->SetFontColor(ccc4(99, 73, 74, 255));
	m_title2->SetText(title2.c_str());
	m_title2->SetFontColor(ccc4(0, 0, 255, 255));
}
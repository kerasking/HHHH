/*
 *  NDTip.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDTip.h"
#include "CGPointExtension.h"
#include "NDDirector.h"
#include "NDUtility.h"

IMPLEMENT_CLASS(LayerTip, NDUILayer)

LayerTip::LayerTip()
{
	m_lbTip = NULL;
	m_iWidth = 0;
	m_bTalkStyle = false;
	
	memset(m_line, 0, sizeof(m_line));
	
	m_triangleNode = NULL;
	
	m_posTalk = CGPointZero;
	
	m_bNeedCacl = true;
	
	m_alignTriangle = TipTriangleAlignLeft;
}

LayerTip::~LayerTip()
{
}

void LayerTip::Initialization()
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->EnableEvent(false);
	
	m_crRect = new NDUICircleRect;
	m_crRect->Initialization();
	m_crRect->SetFillColor(ccc4(255, 245, 180, 255));
	m_crRect->SetFrameColor(ccc4(255, 153, 0, 255));
	m_crRect->SetRadius(5);
	m_crRect->SetVisible(false);
	this->AddChild(m_crRect);
	
	m_lbTip = new NDUILabel;
	m_lbTip->Initialization();
	m_lbTip->SetFontSize(13);
	m_lbTip->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbTip->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTip->SetVisible(false);
	this->AddChild(m_lbTip);
	
	m_triangleNode = new NDUITriangle;
	m_triangleNode->Initialization();
	m_triangleNode->SetColor(ccc4(255, 245, 180, 255));
	m_triangleNode->SetVisible(false);
	this->AddChild(m_triangleNode);
	
	for (int i = 0; i < 2; i++) 
	{
		m_line[i] = new NDUILine;
		m_line[i]->Initialization();
		m_line[i]->SetWidth(1);
		m_line[i]->SetColor(ccc3(255, 153, 0));
		m_line[i]->SetVisible(false);
		this->AddChild(m_line[i]);
	}
}

void LayerTip::draw()
{
	NDUILayer::draw();
	
	if (!m_lbTip ) 
	{
		this->SetFrameRect(CGRectZero);
		m_crRect->SetVisible(false);
		m_line[0]->SetVisible(false);
		m_line[1]->SetVisible(false);
		m_triangleNode->SetVisible(false);
		return;
	}
	
	std::string str = m_lbTip->GetText();
	if (str.empty()) 
	{
		this->SetFrameRect(CGRectZero);
		m_crRect->SetVisible(false);
		m_line[0]->SetVisible(false);
		m_line[1]->SetVisible(false);
		m_triangleNode->SetVisible(false);
		return;
	}
	
	if (m_bNeedCacl) 
	{
		recacl();
		m_bNeedCacl = false;
	}
}

void LayerTip::SetFrameRect(CGRect rect)
{
	NDUILayer::SetFrameRect(rect);
	
	m_bNeedCacl = true;
}

void LayerTip::Hide()
{
	this->SetVisible(false);
	this->EnableDraw(false);
}

void LayerTip::Show()
{
	this->SetVisible(true);
	this->EnableDraw(true);
}

void LayerTip::SetText(std::string str)
{
	if (m_lbTip) 
	{
		m_lbTip->SetText(str.c_str());
		m_bNeedCacl = true;
	}
}

void LayerTip::SetTextFontSize(unsigned int uisize)
{
	if (m_lbTip) 
	{
		m_lbTip->SetFontSize(uisize);
		m_bNeedCacl = true;
	}
}

void LayerTip::SetTextColor(ccColor4B color)
{
	if (m_lbTip) 
	{
		m_lbTip->SetFontColor(color);
	}
}

CGSize LayerTip::GetTipSize()
{
	if (!m_lbTip) 
	{
		return CGSizeZero;
	}
	
	std::string str = m_lbTip->GetText();
	
	if (str.empty()) 
	{
		return CGSizeZero;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if (m_iWidth != 0) 
	{
		winsize.width = m_iWidth;
	}
	
	CGSize dim;
	dim = getStringSizeMutiLine(str.c_str(), m_lbTip->GetFontSize(), winsize);
	dim.height = dim.height+6;
	dim.width = dim.width+10;
	
	if (m_bTalkStyle) 
	{
		dim.height += 12;
	}
	
	return dim;
}


void LayerTip::SetWidth(int iWidth)
{
	m_iWidth = iWidth;
	m_bNeedCacl = true;
}

void LayerTip::SetTalkStyle(bool bSet)
{
	m_bTalkStyle = bSet;
	m_bNeedCacl = true;
}

void LayerTip::SetTalkDisplayPos(CGPoint pos)
{
	m_posTalk = pos;
	m_bNeedCacl = true;
}

void LayerTip::recacl()
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	CGRect rect = this->GetFrameRect();
	
	if (m_iWidth != 0) 
	{
		winsize.width = m_iWidth;
	}
	std::string str = m_lbTip->GetText();
	
	CGSize dim;
	dim = getStringSizeMutiLine(str.c_str(), m_lbTip->GetFontSize(), winsize);
	rect.size.height = dim.height+6;
	rect.size.width = dim.width+10;
	
	CGRect rectFrame = rect;
	if (m_bTalkStyle) 
	{
		rectFrame.size.height += 12;
	}
	
	if (!(m_posTalk.x == 0 && m_posTalk.y == 0)) 
	{
		rectFrame.origin.x = m_posTalk.x;
		rectFrame.origin.y = m_posTalk.y-rectFrame.size.height;
	}
	
	this->SetFrameRect(rectFrame);
	
	m_lbTip->SetFrameRect(CGRectMake(0, 3, rect.size.width, dim.height));
	m_lbTip->SetVisible(true);
	
	if (m_crRect)
	{
		m_crRect->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
		m_crRect->SetVisible(true);
	}
	
	if (m_bTalkStyle) 
	{
		CGPoint first, second, third;
		
		switch (m_alignTriangle) {
			case TipTriangleAlignLeft:
				first	= ccp(7, rect.size.height);
				second	= ccp(14, rect.size.height);
				third	= ccp(-first.x, rectFrame.size.height-first.y);
				break;
			case TipTriangleAlignCenter:
				first	= ccp((rect.size.width-7)/2+7, rect.size.height);
				second	= ccp((rect.size.width-7)/2+14, rect.size.height);
				third	= ccp((rect.size.width-7)/2-first.x, rectFrame.size.height-first.y);
				break;
			case TipTriangleAlignRight:
				first	= ccp(rect.size.width-7, rect.size.height);
				second	= ccp(rect.size.width-14, rect.size.height);
				third	= ccp(rect.size.width-first.x, rectFrame.size.height-first.y);
				break;
			default:
				break;
		}
		
		CGRect scrRect = this->GetScreenRect();
		m_line[0]->SetFrameRect(CGRectMake(first.x, first.y, 0, 0));
		m_line[0]->SetFromPoint(ccp(0, 0));
		m_line[0]->SetToPoint(third);
		m_line[0]->SetVisible(true);
		
		m_line[1]->SetFrameRect(CGRectMake(second.x, second.y, 0, 0));
		m_line[1]->SetFromPoint(ccp(0, 0));
		m_line[1]->SetToPoint(ccpSub(third, ccpSub(second, first)));
		m_line[1]->SetVisible(true);
		
		m_triangleNode->SetFrameRect(CGRectMake(0, 0, 0, 0));
		m_triangleNode->SetPoints(first, second, ccpAdd(third, first));
		m_triangleNode->SetVisible(true);
	}
}

void LayerTip::SetTriangleAlign(TipTriangleAlign align)
{
	if (align < TipTriangleAlignBegin || align >= TipTriangleAlignEnd) 
		return;
		
	m_alignTriangle = align;
	
	m_bNeedCacl = true;
}

//////////////////////////////////////
IMPLEMENT_CLASS(TalkBox, NDUILayer)

TalkBox::TalkBox()
{
	nextShowY = 0;
	isFirstNext=true;
	timeForTalkMsg = 0;
	moveSpeed = 13 >> 3;
	m_pos = CGPointZero;
	memset(m_tip, 0, sizeof(m_tip));
	
	m_bConstant = false;
}

void TalkBox::addTalkMsg(std::string msg,int sec) 
{
	if (m_bConstant)
	{
		talkMsgs.clear();
	}
	
	talkMsgs.push_back(msg);
	
	if (!m_bConstant) {
		timeForTalkMsg= sec+int([NSDate timeIntervalSinceReferenceDate]);
	}
	SetVisible(true);
}

void TalkBox::SetDisPlayPos(CGPoint pos)
{
	if (!m_bConstant) {
		nextShowY += pos.y-m_pos.y;
	}
	m_pos = pos;
}

void TalkBox::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	this->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->SetTouchEnabled(false);
}

void TalkBox::draw() 
{
	if (!IsVisibled())
	{
		return;
	}
	
	if (!m_bConstant && timeForTalkMsg - int([NSDate timeIntervalSinceReferenceDate]) < 0) 
	{
		reset();
		return;
	}
	
	NDUINode::draw();
	
	if (talkMsgs.empty())
	{
		reset();
		return;
	}
	
	if (m_bConstant) 
	{
		if (!m_tip[0]) 
		{
			m_tip[0] = newLayerTip();
		}
		m_tip[0]->SetText(talkMsgs[0]);
		m_tip[0]->SetTalkDisplayPos(m_pos);
		
		return;
	}
	
	if (talkMsgs.size() > 1) {
		if (isFirstNext) {
			nextShowY = m_pos.y + 100;
			isFirstNext = false;
		}
		nextShowY -= moveSpeed;
		
		for (int i = 0; i < 2; i++) 
		{
			if (!m_tip[i]) 
			{
				m_tip[i] = newLayerTip();
			}
			m_tip[i]->SetText(talkMsgs[i]);
		}
		
		m_tip[1]->SetTalkDisplayPos(ccp(m_pos.x, nextShowY));
		
		CGSize size = m_tip[1]->GetTipSize();
		m_tip[0]->SetTalkDisplayPos(ccp(m_pos.x, nextShowY-size.height));
		
		
		if (nextShowY <= m_pos.y) 
		{
			talkMsgs.pop_front();
			isFirstNext = true;
		}
	} else {
		if (!m_tip[0]) 
		{
			m_tip[0] = newLayerTip();
		}
		m_tip[0]->SetText(talkMsgs[0]);
		m_tip[0]->SetTalkDisplayPos(m_pos);
	}
}

void TalkBox::reset()
{
	isFirstNext = true;
	memset(m_tip, 0, sizeof(m_tip));
	this->RemoveAllChildren(true);
	talkMsgs.clear();
	this->SetVisible(false);
}

LayerTip* TalkBox::newLayerTip()
{
	LayerTip * tip = new LayerTip;
	tip->Initialization();
	tip->SetTextFontSize(13);
	tip->SetTextColor(ccc4(199, 89, 0, 255));
	tip->SetTalkStyle(true);
	tip->SetWidth(spilitWidth);
	this->AddChild(tip);
	
	return tip;
}

void TalkBox::SetFix()
{
	m_bConstant = true;
}

void TalkBox::SetTriangleAlign(TipTriangleAlign align)
{
	if (m_tip[0]) m_tip[0]->SetTriangleAlign(align);
	
	if (m_tip[1]) m_tip[1]->SetTriangleAlign(align);
}

CGSize TalkBox::GetSize()
{
	if (m_tip[0]) return m_tip[0]->GetTipSize();
	
	return CGSizeZero;
}

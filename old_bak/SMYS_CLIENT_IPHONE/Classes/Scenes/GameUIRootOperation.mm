/*
 *  GameUIRootOperation
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUIRootOperation.h"
#include "NDUtility.h"
#include "define.h"
#include "NDPicture.h"
#include "NDSprite.h"

IMPLEMENT_CLASS(NDUIHControlLayer, NDUILayer)

NDUIHControlLayer::NDUIHControlLayer()
{
	m_iStatus = e_ShouQi;
	m_iVarLen = 0;
	m_rectInit = CGRectZero;
}

NDUIHControlLayer::~NDUIHControlLayer()
{
}

void NDUIHControlLayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetTouchEnabled(false);
}

void NDUIHControlLayer::draw()
{
	CGRect rect = GetFrameRect();
	if (m_iStatus == e_ShouQiIng) 
	{ // 收起中
		if (rect.size.height-m_iVarLen < 0) 
		{ // 收起完毕
			m_iStatus = e_ShouQi;
			SetFrameRect(m_rectInit);
			this->SetVisible(false);
			NDUIHControlLayerDelegate* delegate = dynamic_cast<NDUIHControlLayerDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnInStatus(this, e_ShouQi);
			}
		}
		else 
		{
			this->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y+m_iVarLen, 
										  rect.size.width, rect.size.height-m_iVarLen));
		}
	} 
	else if (m_iStatus == e_ZhangKaiIng)
	{ // 展开中
		if (rect.size.height+m_iVarLen > m_rectInit.origin.y)
		{ // 展开完毕
			m_iStatus = e_ZhangKai;
			NDUIHControlLayerDelegate* delegate = dynamic_cast<NDUIHControlLayerDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnInStatus(this, e_ZhangKai);
			}
		}
		else 
		{
			this->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y-m_iVarLen, 
										  rect.size.width, rect.size.height+m_iVarLen));
		}
	}
	NDUILayer::draw();
}

void NDUIHControlLayer::SetRectInit(CGRect rect)
{
	m_rectInit = rect;
}

void NDUIHControlLayer::ChangeStatus()
{
	if (m_iStatus == e_ZhangKai || m_iStatus == e_ShouQiIng)
	{
		m_iStatus++;
	} 
	else 
	{
		m_iStatus--;
	}
	
	if (m_iStatus != e_ShouQi)
	{
		this->SetVisible(true);
	}
}

int NDUIHControlLayer::GetStatus()
{
	return m_iStatus;
}

void NDUIHControlLayer::SetControls(int controls)
{
	if (controls<=0)
	{
		return;
	}
	m_iVarLen = m_rectInit.origin.y / controls;
}

///////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIHControlContainer, NDUILayer)

NDUIHControlContainer::NDUIHControlContainer()
{	
	m_picBasic = NULL;
	m_btnBasic = NULL;
	
	m_hclBasic = NULL;
	m_iUINodeInterval = 0;
	
	m_InitRect = CGRectZero;
	m_ButtonRect = CGRectZero;
}

NDUIHControlContainer::~NDUIHControlContainer()
{
	SAFE_DELETE(m_picBasic);
}

void NDUIHControlContainer::Initialization()
{
	NDUILayer::Initialization();
	
	m_btnBasic = new NDUIButton;
	m_btnBasic->Initialization();
	m_btnBasic->SetDelegate(this);
	m_btnBasic->SetFrameRect(CGRectMake(0, 0, 40, 40));
	this->AddChild(m_btnBasic,1);
	
	m_hclBasic = new NDUIHControlLayer;
	m_hclBasic->Initialization();
	m_hclBasic->SetDelegate(this);
	m_hclBasic->SetVisible(false);
	this->AddChild(m_hclBasic);
}

bool NDUIHControlContainer::TouchBegin(NDTouch* touch)
{
	m_beginTouch = touch->GetLocation();
	
	if (m_btnBasic && CGRectContainsPoint(m_btnBasic->GetScreenRect(), m_beginTouch)) 
	{
		return NDUILayer::TouchBegin(touch);
	}
	
	for_vec(m_vecUINodes, vector<NDUINode*>::iterator)
	{
		if (CGRectContainsPoint((*it)->GetScreenRect(), m_beginTouch))
			return NDUILayer::TouchBegin(touch);
	}
	
	return false;
}

void NDUIHControlContainer::SetUINodeInterval(int interval)
{
	m_iUINodeInterval = interval;
}

void NDUIHControlContainer::OnButtonClick(NDUIButton* button)
{
	
	if (button == m_btnBasic && m_hclBasic)
	{
		NDUIHControlContainerDelegate* delegate = dynamic_cast<NDUIHControlContainerDelegate*> (this->GetDelegate());
		if (delegate && delegate->OnClickHControlContainer(this)) 
		{
			return;
		}
		
		if ( m_hclBasic->GetStatus() == e_ShouQi)
		{
			this->SetFrameRect(m_InitRect);
			if (m_btnBasic)
			{
				m_btnBasic->SetFrameRect(CGRectMake(m_ButtonRect.origin.x-m_InitRect.origin.x,
													m_ButtonRect.origin.y-m_InitRect.origin.y,
													m_ButtonRect.size.width,
													m_ButtonRect.size.height));
			}
		}
	
		m_hclBasic->ChangeStatus();
	}	
}

void NDUIHControlContainer::OnInStatus(NDUIHControlLayer* hcontrollayer, int status)
{
	if (hcontrollayer && hcontrollayer == m_hclBasic)
	{
		if (status == e_ShouQi)
		{
			this->SetFrameRect(m_ButtonRect);
			if (m_btnBasic)
			{
				m_btnBasic->SetFrameRect(CGRectMake(0, 0, m_ButtonRect.size.width, m_ButtonRect.size.height));
			}
		}
	}
}

void NDUIHControlContainer::SetRectInit(CGRect rect)
{
	m_InitRect = rect;
}

void NDUIHControlContainer::AddUINode(NDUINode* uinode)
{
	if (!uinode)
	{
		return;
	}
	
	m_vecUINodes.push_back(uinode);
	Adjust();
}

void NDUIHControlContainer::SetButtonName(const char* name)
{
	if (!m_btnBasic || !name)
	{
		return;
	}
	
	m_picBasic = new NDPicture();
	m_picBasic->Initialization(GetImgPath(name));
	m_btnBasic->SetImage(m_picBasic);
	
	int iHeight = this->GetFrameRect().size.height;
	int iWidth  = this->GetFrameRect().size.width;
	if (iHeight > m_picBasic->GetSize().height)
	{
		iHeight = iHeight - m_picBasic->GetSize().height;
	}
	if (iWidth > m_picBasic->GetSize().width)
	{
		iWidth = m_picBasic->GetSize().width;
	}
	m_btnBasic->SetFrameRect(CGRectMake(0, iHeight, iWidth, m_picBasic->GetSize().height));
	m_ButtonRect = CGRectMake(m_InitRect.origin.x, m_InitRect.origin.y+iHeight, iWidth, m_picBasic->GetSize().height);
}

void NDUIHControlContainer::SetBGImage(const char* name)
{
	if (m_hclBasic || name)
	{
		CGRect rect = GetFrameRect();
		NDPicture *pic = new NDPicture();
		pic->Initialization(GetImgPath(name));
		int iPicW = pic->GetSize().width;
		int iPicH = pic->GetSize().height;
		NDUILayer *layer = new NDUILayer;
		layer->Initialization();
		layer->SetFrameRect(CGRectMake( (rect.size.width-iPicW)/2, 0, iPicW, iPicH));
		layer->SetBackgroundImage(GetImgPath(name));
		m_hclBasic->AddChild(layer);
		delete pic;
	}
}

void NDUIHControlContainer::InitFinish()
{
	if (m_hclBasic && m_hclBasic->GetStatus() == e_ShouQi)
	{
		this->SetFrameRect(m_ButtonRect);
		m_btnBasic->SetFrameRect(CGRectMake(0, 0, m_ButtonRect.size.width, m_ButtonRect.size.height));
	}
}

void NDUIHControlContainer::Adjust()
{
	if (!m_hclBasic)
	{
		return;
	}
	
	int iUINodes = m_vecUINodes.size();
	if (iUINodes == 0)
	{
		return;
	}
	
	int iWidthMax = 0, iHeightMax = 0;
	iHeightMax = this->GetFrameRect().size.height;
	iWidthMax  = this->GetFrameRect().size.width;
	
	int iBasicBtnHeight = 0;
	if (m_picBasic)
	{
		iBasicBtnHeight = m_picBasic->GetSize().height;
	}
	
	if (iBasicBtnHeight > iHeightMax)
	{
		iHeightMax = 0;
	}
	else
	{
		iHeightMax -= iBasicBtnHeight;
	}

	
	NDUINode *uinode = m_vecUINodes[iUINodes-1];
	
	CGRect rectUINode = uinode->GetFrameRect();
	CGRect rectBasic = m_hclBasic->GetFrameRect();
	
	int iBasicHeighMax = 0, iBasicWidthMax = 0;
	iBasicHeighMax	= rectBasic.origin.y;
	iBasicWidthMax	= rectBasic.size.width;
	
	int iTmpBasicHeighMax = 0;
	int iTmpUINodeHeigh = iBasicHeighMax;
	if (iUINodes == 1)
	{
		iTmpBasicHeighMax = rectUINode.size.height+iBasicHeighMax;
	}
	else 
	{
		iTmpBasicHeighMax = rectUINode.size.height+iBasicHeighMax+m_iUINodeInterval;
		iTmpUINodeHeigh += m_iUINodeInterval;
	}
	
	
	if (iTmpBasicHeighMax > iHeightMax)
	{
		if (rectUINode.size.height < iTmpBasicHeighMax-iHeightMax)
		{ //加不下了
			uinode->SetFrameRect(CGRectZero);
		}
		else
		{
			uinode->SetFrameRect(CGRectMake(0, iTmpUINodeHeigh, rectUINode.size.width, rectUINode.size.height-(iTmpBasicHeighMax-iHeightMax)));
		}
		
		iBasicHeighMax = iHeightMax;
	}
	else 
	{
		uinode->SetFrameRect(CGRectMake(0, iTmpUINodeHeigh, rectUINode.size.width, rectUINode.size.height));
		iBasicHeighMax = iTmpBasicHeighMax;
	}
	
	
	if (rectUINode.size.width > iBasicWidthMax) 
	{
		iBasicWidthMax = rectUINode.size.width;
	}
	
	if ( iBasicWidthMax > iWidthMax ) 
	{
		iBasicWidthMax = iWidthMax;
	}
	
	m_hclBasic->AddChild(uinode);
	
	m_hclBasic->SetFrameRect(CGRectMake(0, iBasicHeighMax, iBasicWidthMax, 0));
	m_hclBasic->SetRectInit(CGRectMake(0, iBasicHeighMax, iBasicWidthMax, 0));
	m_hclBasic->SetControls(4);
	m_hclBasic->SetVisible(false);
}

void NDUIHControlContainer::ZhangKai()
{
	if (m_hclBasic) {
		m_hclBasic->ChangeStatus();
	}
}

bool NDUIHControlContainer::IsZhangKai()
{
	if (m_hclBasic) 
	{
		return m_hclBasic->GetStatus() == e_ZhangKai;
	}
	
	return false;
}

///////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIAniLayer, NDUILayer)
NDUIAniLayer::NDUIAniLayer()
{
	sprite = NULL;
	m_rectSprite = CGRectZero;
	m_bTouchBegin = false;
}

NDUIAniLayer::~NDUIAniLayer()
{
	SAFE_DELETE(m_picBg);
}

void NDUIAniLayer::Initialization(const char * aniname)
{
	if (!aniname)
	{
		NDLog(@"NDUIAniLayer::Initialization !aniname");
		return;
	}
	
	NDUILayer::Initialization();
	sprite = new NDSprite;
	sprite->Initialization(GetAniPath(aniname));
	sprite->SetPosition(CGPointMake(0, 120));
	
	m_picBg = new NDPicture;
	m_picBg->Initialization(GetImgPathNew("Pic_Messagebg.png"));
	
	this->AddChild(sprite);
}

bool NDUIAniLayer::TouchBegin(NDTouch* touch)
{
	m_beginTouch = touch->GetLocation();		
	
	if (CGRectContainsPoint(m_rectSprite, m_beginTouch) && this->IsVisibled() && this->EventEnabled()) 
	{
		m_bTouchBegin = true;
		return true;
	}
	return false;
}

bool NDUIAniLayer::TouchEnd(NDTouch* touch)
{
	m_endTouch = touch->GetLocation();		
	
	if (CGRectContainsPoint(m_rectSprite, m_endTouch) && this->IsVisibled() && this->EventEnabled() && m_bTouchBegin) 
	{
		NDUIAniLayerDelegate* delegate = dynamic_cast<NDUIAniLayerDelegate*> (this->GetDelegate());
		if (delegate) 
		{
			delegate->OnClickNDUIAniLayer(this);
		}
		
		m_bTouchBegin = false;
	}
	
	return true;
}

void NDUIAniLayer::TouchCancelled(NDTouch* touch)
{
	m_bTouchBegin = false;
}

void NDUIAniLayer::draw()
{
	if (m_picBg && sprite)
	{
		//CGRect rect;
		//rect.size = m_picBg->GetSize();
		//rect.origin = ccpSub(sprite->GetPosition(), ccp(size.width, size.height));
		m_picBg->DrawInRect(m_rectSprite);
	}
	//glDisableClientState(GL_COLOR_ARRAY);
	if (sprite) sprite->RunAnimation(true);
	//glEnableClientState(GL_COLOR_ARRAY);
}

void NDUIAniLayer::SetAniRectXYSize(CGRect rect, CGSize size)
{
	sprite->SetPosition(CGPointMake(rect.origin.x+size.width, rect.origin.y+size.height));
	m_rectSprite = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

void NDUIAniLayer::SetCurrentAnimation(int aniID, int faceright/*=false*/)
{
	if (sprite)
	{
		sprite->SetCurrentAnimation(aniID, faceright);
	}
}

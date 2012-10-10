/*
 *  NDCommonControl.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDCommonControl.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "NDDirector.h"
#include "NDConstant.h"
#include <sstream>

IMPLEMENT_CLASS(NDStateBar, NDUINode)

NDStateBar::NDStateBar()
{
	m_picBg = m_picProcess = NULL;
	
	m_lbLabel = NULL;
	
	m_fPercent = 0;
	
	m_imageNum = NULL;
}

NDStateBar::~NDStateBar()
{
}

void NDStateBar::Initialization(bool useNumPic/*=true*/)
{
	NDUINode::Initialization();
	
	if (useNumPic)
	{
		m_imageNum = new ImageNumber;
		
		m_imageNum->Initialization();
		
		this->AddChild(m_imageNum);
	}
	else
	{
		m_lbLabel = new NDUILabel;
		
		m_lbLabel->Initialization();
		
		m_lbLabel->SetTextAlignment(LabelTextAlignmentLeft);
		
		this->AddChild(m_lbLabel);
	}
}

void NDStateBar::SetStatePicture(NDPicture* picBg, NDPicture* picProcess)
{
	SAFE_DELETE(m_picBg);
	
	SAFE_DELETE(m_picProcess);
	
	m_picBg = picBg;
	
	m_picProcess = picProcess;
}

void NDStateBar::SetNumber(int iCurNum, int iMaxNum)
{
	if (m_lbLabel) 
	{
		std::stringstream ss;
		
		ss << iCurNum << "/" << iMaxNum;
		
		m_lbLabel->SetText(ss.str().c_str());
	}
	
	if (m_imageNum) 
	{
		m_imageNum->SetSmallRedTwoNumber(iCurNum, iMaxNum);
	}
	
	m_fPercent = iMaxNum == 0 ? 0.0f : (float(iCurNum * 100) / (iMaxNum*100));
}

ImageNumber* NDStateBar::GetNumImage()
{
	return m_imageNum;
}

NDUILabel* NDStateBar::GetNumLable()
{
	return m_lbLabel;
}

void NDStateBar::draw()
{
	if	(!this->IsVisibled()) return ;
	
	CGRect scrRect = this->GetScreenRect();
	
	if (m_picBg)
		m_picBg->DrawInRect(scrRect);
		
	if (m_picProcess)
		m_picProcess->DrawInRect(CGRectMake(scrRect.origin.x+2, scrRect.origin.y, (scrRect.size.width-4)*m_fPercent, scrRect.size.height));
}

IMPLEMENT_CLASS(NDHPStateBar, NDStateBar)

void NDHPStateBar::Initialization(CGPoint pos)
{
	NDStateBar::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(GetImgPathNew("bar_empty.png"));
	
	CGSize size = picBg->GetSize();
	
	this->SetStatePicture(picBg,
						  pool.AddPicture(GetImgPathNew("hp_bar_fill.png")));
	
	
	ImageNumber* image = this->GetNumImage();
	/*
	label->SetFontColor(ccc4(189, 19, 19, 255));
	
	label->SetFontSize(10);
	
	label->SetTextAlignment(LabelTextAlignmentRight);
	
	label->SetFrameRect(CGRectMake(0, -4, size.width-10, 12));*/
	
	image->SetFrameRect(CGRectMake(size.width-120, -2, 80, size.height));
	
	this->SetFrameRect(CGRectMake(pos.x, pos.y, size.width, size.height));

}

IMPLEMENT_CLASS(NDMPStateBar, NDHPStateBar)

void NDMPStateBar::Initialization(CGPoint pos)
{
	NDHPStateBar::Initialization(pos);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(GetImgPathNew("bar_empty.png"));
	
	CGSize size = picBg->GetSize();
	
	this->SetStatePicture(picBg,
						  pool.AddPicture(GetImgPathNew("mp_bar_fill.png")));
}

IMPLEMENT_CLASS(NDExpStateBar, NDHPStateBar)

void NDExpStateBar::Initialization(CGPoint pos)
{
	NDHPStateBar::Initialization(pos);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(GetImgPathNew("bar_empty.png"));
	
	CGSize size = picBg->GetSize();
	
	this->SetStatePicture(picBg,
						  pool.AddPicture(GetImgPathNew("exp_bar_fill.png")));
	
}

#pragma mark 属性分配背景层

IMPLEMENT_CLASS(NDPropAllocLayer, NDUILayer)

NDPropAllocLayer::NDPropAllocLayer()
{
	m_focus = false;

	m_picBGFocus = NULL;
	
	m_picFocus = NULL;
	
	m_pic = NULL;
}

void NDPropAllocLayer::Initialization(CGRect rect)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	m_picBGFocus = pool.AddPicture(GetImgPathNew("selected_item_bg.png"), rect.size.width, rect.size.height);
	
	m_picFocus = pool.AddPicture(GetImgPathNew("selected_bg.png"));
	
	m_pic = pool.AddPicture(GetImgPathNew("unselected_bg.png"));
	
	this->SetFrameRect(rect);
}

void NDPropAllocLayer::SetLayerFocus(bool focus)
{
	m_focus = focus;
}

void NDPropAllocLayer::draw()
{
	if (!this->IsVisibled()) return;
	
	CGRect scrRect = this->GetScreenRect();
	
	if (m_focus) 
	{
		if (m_picBGFocus)
			m_picBGFocus->DrawInRect(scrRect);
			
		if (m_picFocus)
		{
			CGRect rect;
			rect.size = m_picFocus->GetSize();
			rect.origin.x = scrRect.origin.x+6;
			rect.origin.y = scrRect.origin.y+(scrRect.size.height-rect.size.height)/2;
			m_picFocus->DrawInRect(rect);
		}
	}
	else
	{
		if (m_pic)
		{
			CGRect rect;
			rect.size = m_pic->GetSize();
			rect.origin.x = scrRect.origin.x+6;
			rect.origin.y = scrRect.origin.y+(scrRect.size.height-rect.size.height)/2;
			m_pic->DrawInRect(rect);
		}
	}
}

#pragma mark 属性分配滑块

IMPLEMENT_CLASS(NDPropSlideBar, NDUILayer)

NDPropSlideBar::NDPropSlideBar()
{
	m_imageProcess = m_imageSlide = m_imageSlideBg = NULL;
	
	m_lbText = NULL;
	
	m_scrTouchRect = CGRectZero;
	
	m_uiMax = m_uiMin = m_uiCur = 0;
	
	m_fProcessWidth = m_fCur = m_fMin = 0.0f;
	
	m_slideMove = false;
	
	m_caclTouchRect = false;
}

NDPropSlideBar::~NDPropSlideBar()
{
}

void NDPropSlideBar::Initialization(CGRect rect, unsigned int slideWidth)
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(rect);
	
	this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("seekbar_bg.png"), rect.size.width, rect.size.height), true);
	
	SetSlideBar(rect.size, slideWidth);
}

void NDPropSlideBar::SetMax(unsigned int uiMax, bool update/*=false*/)
{
	m_uiMax = uiMax;

	UpdateMinValue();
	
	UpdateCurValue();
	
	if (update)
		UpdateProcess();
}

void NDPropSlideBar::SetMin(unsigned int uiMin, bool update/*=true*/)
{
	m_uiMin = uiMin;
	
	UpdateMinValue();
	
	if (update)
		UpdateProcess();
}

void NDPropSlideBar::SetCur(unsigned int uiCur, bool update/*=true*/)
{
	m_uiCur = uiCur;
	
	if (m_lbText)
	{
		std::stringstream ss; 
		
		ss << uiCur;
		
		m_lbText->SetText(ss.str().c_str());
	}
	
	UpdateCurValue();
	
	if (update)
		UpdateProcess();
}

unsigned int NDPropSlideBar::GetCur()
{
	return m_uiCur;
}

unsigned int NDPropSlideBar::GetMin()
{
	return m_uiMin;
}

unsigned int NDPropSlideBar::GetMax()
{
	return m_uiMax;
}

bool NDPropSlideBar::TouchBegin(NDTouch* touch)
{
	m_beginTouch = touch->GetLocation();	
	
	if (CGRectContainsPoint(this->GetScreenRect(), m_beginTouch) && this->IsVisibled() && this->EventEnabled()) 
	{
		if (!m_caclTouchRect)
		{
			m_caclTouchRect = true;
			
			m_scrTouchRect.origin = ccpAdd(this->GetScreenRect().origin, m_scrTouchRect.origin);
		}
		
		if (m_imageSlide && CGRectContainsPoint(m_imageSlide->GetScreenRect(), m_beginTouch))
		{
			m_slideMove = true;
		}
		
		return true;
	}
	
	return false;
}

bool NDPropSlideBar::TouchEnd(NDTouch* touch)
{
	CGPoint endTouch = touch->GetLocation();
	
	if (m_slideMove && CheckCanMove(endTouch)) 
		MoveEvent(endTouch.x-m_beginTouch.x);
	
	m_slideMove = false;
	
	return true;
}

bool NDPropSlideBar::TouchMoved(NDTouch* touch)
{
	if (!m_slideMove) return true;
	
	CGPoint moveTouch = touch->GetLocation();
	
	if (!CheckCanMove(moveTouch))
	{
		m_slideMove = false;
		
		return true;
	}
	
	MoveEvent(moveTouch.x-m_beginTouch.x);
	
	m_beginTouch.x = moveTouch.x;
	
	return true;
}

void NDPropSlideBar::draw()
{
	if (!this->IsVisibled()) return;
	
	NDUILayer::draw();
	
	UpdateProcess();
}

void NDPropSlideBar::SetSlideBar(CGSize parent, unsigned int width)
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(GetImgPathNew("seekbar_empty.png"), width, 0);
	
	NDPicture *slide = pool.AddPicture(GetImgPathNew("seekbar_thumb.png"));
	
	CGSize sizeSlide = slide->GetSize();
	
	CGSize sizeBG = picBg->GetSize();
	
	//m_scrTouchRect = CGRectMake((parent.width-width)/2, (parent.height-sizeSlide.height)/2, width, sizeSlide.height);
	m_scrTouchRect = CGRectMake(0, 0, parent.width, parent.height);
	
	m_imageSlideBg = new NDUIImage;
	
	m_imageSlideBg->Initialization();
	
	m_imageSlideBg->SetPicture(picBg, true);
	
	m_imageSlideBg->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, sizeBG.width, sizeBG.height));
	
	this->AddChild(m_imageSlideBg);
	
	NDPicture *picProcess = pool.AddPicture(GetImgPathNew("seekbar_fill.png"));
	
	m_imageProcess = new NDUIImage;
	
	m_imageProcess->Initialization();
	
	m_imageProcess->SetPicture(picProcess, true);
	
	m_imageProcess->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, picProcess->GetSize().width, picProcess->GetSize().height));
	
	this->AddChild(m_imageProcess);
	
	m_imageSlide = new NDUIImage;
	
	m_imageSlide->Initialization();
	
	m_imageSlide->SetPicture(slide, true);
	
	m_imageSlide->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeSlide.height)/2, sizeSlide.width, sizeSlide.height));
	
	this->AddChild(m_imageSlide);
	
	m_lbText = new NDUILabel;
	
	m_lbText->Initialization();
	
	m_lbText->SetFontSize(12);
	
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
	
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	
	m_lbText->SetFrameRect(CGRectMake(0, 0, sizeSlide.width, sizeSlide.height));
	
	m_imageSlide->AddChild(m_lbText);
	
	m_fProcessWidth = sizeBG.width-sizeSlide.width;
}

void NDPropSlideBar::UpdateProcess()
{
	if (m_uiMin > m_uiMax) return;
	
	if (m_uiCur < m_uiMin || m_uiCur > m_uiMax) return;
	
	if (m_fMin > m_fProcessWidth) return;
	
	if (m_fCur > m_fProcessWidth || m_fCur < m_fMin) return;
	
	
	if (m_imageProcess && m_imageSlideBg && m_imageSlide)
	{
		CGRect rect = m_imageSlideBg->GetFrameRect();
		
		//float curProcess = m_fProcessWidth == 0.0f ? 0.0f : (m_fCur/m_fProcessWidth);
		
		rect.size.width = m_fCur;
		
		if (m_fCur >= 0.0f && m_imageProcess)
			m_imageProcess->SetFrameRect(rect);
			
		CGRect rectSlide = m_imageSlide->GetFrameRect();
		
		if (m_fCur >= 0.0f) 
		{
			rectSlide.origin.x = m_imageSlideBg->GetFrameRect().origin.x + m_fCur;
			
			m_imageSlide->SetFrameRect(rectSlide);
		}
	}
}

bool NDPropSlideBar::CheckCanMove(CGPoint scrPos)
{
	if (!m_imageSlide || !CGRectContainsPoint(m_scrTouchRect, scrPos))
	{
		return false;
	}
	
	return true;
}

bool NDPropSlideBar::CheckChange(float change)
{
	if (m_uiMax == 0 || change < m_fMin || change > m_fProcessWidth) return false;
	
	return true;
}

void NDPropSlideBar::MoveEvent(float change)
{	
	if (!CheckChange(m_fCur+change) && (m_fCur >= m_fProcessWidth || m_fCur <= m_fMin)) return;
	
	if (m_fProcessWidth == 0.0f) return;
	
	m_fCur += change;
	
	if (m_fCur > m_fProcessWidth) m_fCur = m_fProcessWidth;
	
	if (m_fCur < m_fMin) m_fCur = m_fMin;
	
	if (m_fCur == m_fProcessWidth)
		m_uiCur = m_uiMax;
	else if (m_fCur == m_fMin)
		m_uiCur = m_uiMin;
	else
		m_uiCur = m_fProcessWidth == 0.0f ? 0.0f : (m_fCur/m_fProcessWidth)*float(m_uiMax);
	
	if (m_lbText)
	{
		std::stringstream ss; 
		
		ss << m_uiCur;
		
		m_lbText->SetText(ss.str().c_str());
	}
	
	NDPropSlideBarDelegate *delegate = dynamic_cast<NDPropSlideBarDelegate *> (this->GetDelegate());
	
	if (delegate)
		delegate->OnPropSlideBarChange(this, m_uiCur-m_uiMin);
		
	UpdateProcess();
}

void NDPropSlideBar::UpdateMinValue()
{
	if (m_uiMax != 0)
		m_fMin = float(m_uiMin)/m_uiMax * m_fProcessWidth;
	else
		m_fMin = 0.0f;
}

void NDPropSlideBar::UpdateCurValue()
{
	if (m_uiMax != 0)
		m_fCur = float(m_uiCur)/m_uiMax*m_fProcessWidth;
	else
		m_fCur = 0.0f;
}

#pragma mark 滑块(可附带减加按钮)

#define TAG_BTN_MINUS (466)
#define TAG_BTN_PLUS (477)

IMPLEMENT_CLASS(NDSlideBar, NDPropSlideBar)

void NDSlideBar::Initialization(CGRect rect, unsigned int slideWidth, bool hasBtn/*=true*/, NDPicture* slidePicture/*=NULL*/)
{
	int width = slideWidth;
	
	NDUILayer::Initialization();
	
	this->SetFrameRect(rect);
	
	this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("seekbar_bg.png"), rect.size.width, rect.size.height), true);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(GetImgPathNew("seekbar_empty.png"), width, 0);
	
	NDPicture *slide = slidePicture == NULL ? pool.AddPicture(GetImgPathNew("seekbar_thumb.png")) : slidePicture;
	
	CGSize sizeSlide = slide->GetSize();
	
	CGSize sizeBG = picBg->GetSize();
	
	CGSize parent = rect.size;
	
	//m_scrTouchRect = CGRectMake((parent.width-width)/2, (parent.height-sizeSlide.height)/2, width, sizeSlide.height);
	m_scrTouchRect = CGRectMake(0, 0, parent.width, parent.height);
	
	m_imageSlideBg = new NDUIImage;
	
	m_imageSlideBg->Initialization();
	
	m_imageSlideBg->SetPicture(picBg, true);
	
	m_imageSlideBg->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, sizeBG.width, sizeBG.height));
	
	this->AddChild(m_imageSlideBg);
	
	NDPicture *picProcess = pool.AddPicture(GetImgPathNew("seekbar_fill.png"));
	
	m_imageProcess = new NDUIImage;
	
	m_imageProcess->Initialization();
	
	m_imageProcess->SetPicture(picProcess, true);
	
	m_imageProcess->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, picProcess->GetSize().width, picProcess->GetSize().height));
	
	this->AddChild(m_imageProcess);
	
	m_imageSlide = new NDUIImage;
	
	m_imageSlide->Initialization();
	
	m_imageSlide->SetPicture(slide, true);
	
	m_imageSlide->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeSlide.height)/2, sizeSlide.width, sizeSlide.height));
	
	this->AddChild(m_imageSlide);
	
	m_lbText = new NDUILabel;
	
	m_lbText->Initialization();
	
	m_lbText->SetFontSize(12);
	
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
	
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	
	m_lbText->SetFrameRect(CGRectMake(0, 0, sizeSlide.width, sizeSlide.height));
	
	m_imageSlide->AddChild(m_lbText);
	
	m_fProcessWidth = sizeBG.width-sizeSlide.width;
	
	if (!hasBtn) return;
	
	CGRect rectMinus, rectPlus;
	
	NDPicture *picMinus = pool.AddPicture(GetImgPathNew("minu_selected.png"));
	
	NDPicture *picPlus = pool.AddPicture(GetImgPathNew("plus_selected.png"));
	
	CGSize sizeMinus = picMinus->GetSize(),
		   sizePlus = picPlus->GetSize();
	
	rectMinus = CGRectMake(((parent.width-sizeBG.width)/2-sizeMinus.width)/2, 
							(parent.height-sizeMinus.height)/2, 
							 sizeMinus.width, sizeMinus.height);
							  
	rectPlus = CGRectMake(((parent.width-sizeBG.width)/2-sizePlus.width)/2+(parent.width-sizeBG.width)/2+sizeBG.width, 
						   (parent.height-sizePlus.height)/2, 
						    sizePlus.width, sizePlus.height);
							
	NDUILayer *layerBtn = new NDUILayer;
	layerBtn->Initialization();
	layerBtn->SetFrameRect(rectMinus);
	this->AddChild(layerBtn);
	
	NDUIButton *btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(0, 0, sizeMinus.width, sizeMinus.height));
	btn->SetImage(picMinus, false, CGRectZero, true);
	btn->SetTag(TAG_BTN_MINUS);
	btn->SetDelegate(this);
	layerBtn->AddChild(btn);
	
	layerBtn = new NDUILayer;
	layerBtn->Initialization();
	layerBtn->SetFrameRect(rectPlus);
	this->AddChild(layerBtn);
	
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(0, 0, sizePlus.width, sizePlus.height));
	btn->SetImage(picPlus, false, CGRectZero, true);
	btn->SetTag(TAG_BTN_PLUS);
	btn->SetDelegate(this);
	layerBtn->AddChild(btn);
}

void NDSlideBar::OnButtonClick(NDUIButton* button)
{
	int tag = button->GetTag();
	
	bool deal = false;
	
	if (tag == TAG_BTN_PLUS)
	{
		uint cur = this->GetCur();
		if (cur < this->GetMax() && cur+1 <= this->GetMax())
		{
			this->SetCur(cur+1, false);
			
			deal = true;
		}
	}
	else if (tag == TAG_BTN_MINUS)
	{
		uint cur = this->GetCur();
		if (cur > this->GetMin() && cur-1 >= this->GetMin()) 
		{
			this->SetCur(cur - 1, false);
			
			deal = true;
		}
	}
	
	if (!deal) return;
	
	NDPropSlideBarDelegate *delegate = dynamic_cast<NDPropSlideBarDelegate *> (this->GetDelegate());
	
	if (delegate)
		delegate->OnPropSlideBarChange(this, m_uiCur-m_uiMin);
	
	UpdateProcess();
}

#pragma mark 属性cell

IMPLEMENT_CLASS(NDPropCell, NDUINode)

NDPropCell::NDPropCell()
{
	m_lbKey = m_lbValue = NULL;
	m_hasInfo = false;
	m_picAfterKey = m_picBg = m_picFocus = m_picInfo = NULL;
	
	m_clrNormalText = ccc4(79, 79, 79, 255);
	m_clrFocusText = ccc4(79, 79, 79, 255);
	
	m_uiKeyDis = 0;
	m_uiValueDis = 0;
}

NDPropCell::~NDPropCell()
{
	
}

void NDPropCell::Initialization(bool hasinfo, CGSize size/*=CGSizeMake(238, 23)*/)
{
	NDUINode::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	//int width = 238, height = 23;
	
	m_picBg = pool.AddPicture(GetImgPathNew("attr_listitem_bg.png"), size.width, size.height);
	
	CGSize sizeBg = m_picBg->GetSize();
	
	this->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	m_picFocus = pool.AddPicture(GetImgPathNew("selected_item_bg.png"), size.width, 0);
	
	m_hasInfo = hasinfo;
	
	if (m_hasInfo)
		m_picInfo = pool.AddPicture(GetImgPathNew("attr_detail.png"));
		
	m_lbKey = new NDUILabel;
	m_lbKey->Initialization();
	m_lbKey->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbKey->SetFontSize(14);
	m_lbKey->SetFontColor(ccc4(79, 79, 79, 255));
	this->AddChild(m_lbKey);
	
	m_lbValue = new NDUILabel;
	m_lbValue->Initialization();
	m_lbValue->SetTextAlignment(LabelTextAlignmentRight);
	m_lbValue->SetFontSize(14);
	m_lbValue->SetFontColor(ccc4(79, 79, 79, 255));
	this->AddChild(m_lbValue);
}

NDUILabel* NDPropCell::GetKeyText()
{
	return m_lbKey;
}

NDUILabel* NDPropCell::GetValueText()
{
	return m_lbValue;
}


void NDPropCell::SetFocusPicture(const char* pszPicPath)
{
	if (!pszPicPath) {
		return;
	}
	
	if (m_picFocus) {
		SAFE_DELETE(m_picInfo);
	}
	
	CGRect frame = this->GetFrameRect();
	m_picFocus = NDPicturePool::DefaultPool()->AddPicture(pszPicPath, frame.size.width, 0);
}

void NDPropCell::draw()
{
	if (!this->IsVisibled()) return;
	
	CGRect scrRect = this->GetScreenRect();
	
	NDNode *parent = this->GetParent();
	
	NDPicture * pic = NULL;
	
	if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)parent)->GetFocus() == this)
	{
		pic = m_picFocus;
		if (m_lbKey) {
			m_lbKey->SetFontColor(m_clrFocusText);
		}
		if (m_lbValue) {
			m_lbValue->SetFontColor(m_clrFocusText);
		}
	}
	else
	{
		pic = m_picBg;
		if (m_lbKey) {
			m_lbKey->SetFontColor(m_clrNormalText);
		}
		
		if (m_lbValue) {
			m_lbValue->SetFontColor(m_clrNormalText);
		}
	}
		
	if (pic)
	{
		CGSize size = pic->GetSize();
		pic->DrawInRect(CGRectMake(scrRect.origin.x+(scrRect.size.width-size.width)/2, 
								   scrRect.origin.y+(scrRect.size.height-size.height)/2, 
								   size.width, size.height));
								   
		size.height += (scrRect.size.height-size.height)/2;
		
		if (m_lbKey)
		{
			CGRect rect;
			rect.origin = ccp(m_uiKeyDis, (size.height-m_lbKey->GetFontSize())/2);
			rect.size = size;
			m_lbKey->SetFrameRect(rect);
		}
		
		if (m_lbValue)
		{
			CGRect rect;
			rect.origin = ccp(0, (size.height-m_lbValue->GetFontSize())/2);
			rect.size = size;
			rect.size.width -= m_uiValueDis;
			m_lbValue->SetFrameRect(rect);
		}
		
		CGSize sizeKey = CGSizeZero;
		
		if (m_lbKey)
			sizeKey = m_lbKey->GetTextureSize();
		
		if (pic == m_picFocus && m_picInfo)
		{
			CGSize sizeInfo = m_picInfo->GetSize();
			m_picInfo->DrawInRect(CGRectMake(scrRect.origin.x+sizeKey.width+4, 
											 scrRect.origin.y+(size.height-sizeInfo.height)/2, 
											 sizeInfo.width, sizeInfo.height));
		}
		
		if (m_picAfterKey) {
			if (!m_lbKey || sizeKey.width > 0) {
				CGSize sizeAfterKey = m_picAfterKey->GetSize();
				m_picAfterKey->DrawInRect(CGRectMake(scrRect.origin.x+sizeKey.width+4, 
													 scrRect.origin.y+(size.height-sizeAfterKey.height)/2, 
													 sizeAfterKey.width, sizeAfterKey.height));
			}
		}
	}
	
}

IMPLEMENT_CLASS(HyperLinkButton, NDUIButton)

HyperLinkButton::HyperLinkButton()
{
	m_lbHyperText = NULL;
	m_lineBottom = NULL;
}

HyperLinkButton::~HyperLinkButton()
{
	
}

void HyperLinkButton::Initialization()
{
	NDUIButton::Initialization();
	
	m_lbHyperText = new NDUILabel;
	m_lbHyperText->Initialization();
	this->AddChild(m_lbHyperText);
	
	m_lineBottom = new NDUILine;
	m_lineBottom->Initialization();
	m_lineBottom->SetWidth(1);
	this->AddChild(m_lineBottom);
}

void HyperLinkButton::SetHyperText(const char* text)
{
	m_lbHyperText->SetText(text);
	CGRect rect = this->GetFrameRect();
	m_lbHyperText->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
	m_lbHyperText->SetFontColor(m_colorTitle);
	m_lbHyperText->SetFontSize(m_uiTitleFontSize);
	
	CGSize sizetext = getStringSize(text, m_uiTitleFontSize);
	m_lineBottom->SetFrameRect(CGRectMake(0, 1, rect.size.width, rect.size.height));
	m_lineBottom->SetColor(ccc3(m_colorTitle.r, m_colorTitle.g, m_colorTitle.b));
	m_lineBottom->SetFromPoint(CGPointMake(0, sizetext.height - 3));
	m_lineBottom->SetToPoint(CGPointMake(sizetext.width, sizetext.height - 3));
}

void HyperLinkButton::draw()
{
	NDUINode::draw();
}

#pragma mark 通用输入框

bool CommonTextInputDelegate::SetTextContent(CommonTextInput* input, const char* text)
{
	return true;
}

@implementation ContentTextFieldDelegate

@synthesize tfChat;

-(void) dealloc
{
	[tfChat resignFirstResponder];
	[tfChat release];
	[super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[tfChat resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	/*
	 NSUInteger len = [string length] + [[textField text] length] - range.length;
	 if (len > MAX_CHAT_INPUT) {
	 return NO;
	 }
	 */
	return YES;
}

@end

IMPLEMENT_CLASS(CommonTextInput, NDUINode)

CommonTextInput::CommonTextInput()
{
	m_contentDelegate = nil;
	m_bShowContentTextField = false;
	m_btnContentOk = NULL;
	m_imgContent = NULL;
	m_layerBtn = NULL;
}

CommonTextInput::~CommonTextInput()
{
	if (m_imgContent) {
		m_imgContent->RemoveFromParent(false);
		SAFE_DELETE(m_imgContent);
	}
	if (m_layerBtn) {
		m_layerBtn->RemoveFromParent(false);
		SAFE_DELETE(m_btnContentOk);
	}
	
	this->CloseContentInput();
	
	[m_contentDelegate release];
}

void CommonTextInput::ShowContentTextField(bool bShow, const char* text/*=NULL*/)
{
	m_bShowContentTextField = bShow;
	
	if (m_bShowContentTextField) {
		if (m_imgContent->GetParent() == NULL)
		{
			this->AddChild(m_imgContent);
			m_imgContent->SetVisible(true);
		}
		if (m_layerBtn->GetParent() == NULL)
		{
			this->AddChild(m_layerBtn,1);
			m_layerBtn->SetVisible(true);
		}
		
		if (nil == m_contentDelegate.tfChat) {
			UITextField* tfChat = [[UITextField alloc] init];
			tfChat.transform = CGAffineTransformMakeRotation(3.141592f/2.0f);
			tfChat.frame = CGRectMake(290.0f, 54.0f, 25.0f, 326.0f);
			tfChat.textColor = [UIColor whiteColor];
			tfChat.returnKeyType = UIReturnKeyDone;
			tfChat.delegate = m_contentDelegate;
			m_contentDelegate.tfChat = tfChat;
			[tfChat release];
		}
		
		if (nil == [m_contentDelegate.tfChat superview]) {
			[[[CCDirector sharedDirector] openGLView] addSubview:m_contentDelegate.tfChat];
		}
		
		NSString *content = [NSString stringWithUTF8String:(text == NULL ? "" : text)];
		m_contentDelegate.tfChat.text = content;
		
	} else {
		if (m_imgContent->GetParent() != NULL)
			this->RemoveChild(m_imgContent, false);
		if (m_layerBtn->GetParent() != NULL)	
			this->RemoveChild(m_layerBtn, false);
		[m_contentDelegate.tfChat removeFromSuperview];
	}
}


void CommonTextInput::Initialization()
{
	NDUINode::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	this->m_contentDelegate = [[ContentTextFieldDelegate alloc] init];
	m_imgContent = new NDUIImage;
	m_imgContent->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(GetImgPathNew("common_input_back.png"));
	CGSize sizeContent = pic->GetSize();
	m_imgContent->SetPicture(pic, true);
	m_imgContent->EnableEvent(false);
	m_imgContent->SetFrameRect(CGRectMake((winsize.width-sizeContent.width)/2, 0.0f, sizeContent.width, sizeContent.height));
	//this->AddChild(m_imgChat);
	
	pic = new NDPicture;
	pic->Initialization(GetImgPathNew("common_input_ok.png"));
	
	CGSize sizeOk = pic->GetSize();
	
	CGRect rect = CGRectMake(369.0f-4.0f+(winsize.width-sizeContent.width)/2, 0, sizeOk.width+8, sizeContent.height);
	
	m_layerBtn = new NDUILayer;
	m_layerBtn->Initialization();
	m_layerBtn->SetFrameRect(rect);
	
	m_btnContentOk = new NDUIButton;
	m_btnContentOk->Initialization();
	m_btnContentOk->SetImage(pic, true, CGRectMake(4, (sizeContent.height-sizeOk.height)/2, sizeOk.width, sizeOk.height), true);
	m_btnContentOk->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
	m_btnContentOk->SetDelegate(this);
	m_layerBtn->AddChild(m_btnContentOk);
}

void CommonTextInput::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnContentOk && m_contentDelegate != nil && m_contentDelegate.tfChat != nil)
	{
		NSString* msg = this->m_contentDelegate.tfChat.text;
		
		CommonTextInputDelegate* delegate = dynamic_cast<CommonTextInputDelegate*> (this->GetDelegate());
		
		if (delegate && !delegate->SetTextContent(this, [msg UTF8String]))
			return;
		
		this->m_contentDelegate.tfChat.text = @"";
		
		this->ShowContentTextField(false);
	}
}

void CommonTextInput::CloseContentInput()
{
	if (m_contentDelegate && m_contentDelegate.tfChat && nil != m_contentDelegate.tfChat.subviews) {
		[m_contentDelegate.tfChat removeFromSuperview];
	}
}

void CommonTextInput::SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	
	if (!visible)
		ShowContentTextField(false);
}

#pragma mark  通用选项按钮

IMPLEMENT_CLASS(CommonOptionButton, NDUIOptionButton)

CommonOptionButton::CommonOptionButton()
{
	m_picBGNormal = m_picBGSel = m_picArrowLeft = m_picArrowRight = NULL;
	
	m_uiLeftInterval = m_uiRightInterval = 0; 
	
	m_colorTitle = m_colorTitleFocus = ccc4(173, 70, 25, 255);
}

CommonOptionButton::~CommonOptionButton()
{
	SAFE_DELETE(m_picBGNormal);
	
	SAFE_DELETE(m_picBGSel);
	
	SAFE_DELETE(m_picArrowLeft);
	
	SAFE_DELETE(m_picArrowRight);
}

void CommonOptionButton::Initialization()
{
	NDUIOptionButton::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	SetBackgroudImage(pool.AddPicture(GetImgPathNew("control_normal.png")),
					  pool.AddPicture(GetImgPathNew("control_sel.png")));
					  
	NDPicture *picLeft = pool.AddPicture(GetImgPathNew("option_arrow.png"));
	
	NDPicture *picRight = pool.AddPicture(GetImgPathNew("option_arrow.png"));
	
	picRight->Rotation(PictureRotation180);
	
	SetArrowImage(picLeft, picRight);
	
	SetArrowInterval(4, 4);
}

void CommonOptionButton::SetBackgroudImage(NDPicture* picNormal, NDPicture* picSel)
{
	SAFE_DELETE(m_picBGNormal);
	
	SAFE_DELETE(m_picBGSel);
	
	m_picBGNormal = picNormal;
	
	m_picBGSel = picSel;
}

void CommonOptionButton::SetArrowImage(NDPicture* picLeft, NDPicture* picRight)
{
	SAFE_DELETE(m_picArrowLeft);
	
	SAFE_DELETE(m_picArrowRight);
	
	m_picArrowLeft = picLeft;
	
	m_picArrowRight = picRight;
}

void CommonOptionButton::SetArrowInterval(unsigned int leftInterval, unsigned int rightInterval)
{
	m_uiLeftInterval = leftInterval;
	
	m_uiRightInterval = rightInterval;
}

void CommonOptionButton::draw()
{
	if (!this->IsVisibled()) return;
	
	CGRect scrRect = this->GetScreenRect();
	
	bool focus = (this->GetParent() 
				 && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) 
				 && ((NDUILayer*)(this->GetParent()))->GetFocus() == this)
				 ? true : false;
				 
	NDPicture *picBG = focus ? (m_picBGSel == NULL ? m_picBGNormal : m_picBGSel) : m_picBGNormal;
	
	if (picBG)
	{
		CGSize size = picBG->GetSize();
		
		picBG->DrawInRect(CGRectMake(scrRect.origin.x, scrRect.origin.y, size.width, size.height));
	} 
	
	if (m_picArrowLeft)
	{
		CGSize size = m_picArrowLeft->GetSize();
		
		m_picArrowLeft->DrawInRect(CGRectMake(scrRect.origin.x+m_uiLeftInterval, scrRect.origin.y+(scrRect.size.height-size.height)/2, size.width, size.height));
	}
	
	if (m_picArrowRight)
	{
		CGSize size = m_picArrowRight->GetSize();
		
		m_picArrowRight->DrawInRect(CGRectMake(scrRect.origin.x-m_uiRightInterval+scrRect.size.width-size.width, scrRect.origin.y+(scrRect.size.height-size.height)/2, size.width, size.height));
	}
	
	if (m_title)
	{
		m_title->SetFontColor(focus ? m_colorTitleFocus : m_colorTitle);
	}
}

void CommonOptionButton::SetTitleColor(ccColor4B color, ccColor4B colorfocus)
{
	m_colorTitle = color;
	
	m_colorTitleFocus = colorfocus;
}

#pragma mark 排行cell

IMPLEMENT_CLASS(PaiHangCell, NDPropCell)


PaiHangCell::PaiHangCell()
{
}

PaiHangCell::~PaiHangCell()
{
}

void PaiHangCell::Initialization(CGSize size/*=CGSizeMake(432, 23)*/)
{
	NDPropCell::Initialization(false, size);
	
	this->SetFocusTextColor(ccc4(187, 19, 19, 255));
	
	m_btnPaiHang = new NDUIButton;
	m_btnPaiHang->Initialization();
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("paihang_back.png"));
	CGSize sizePic = pic->GetSize();
	m_btnPaiHang->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	m_btnPaiHang->SetFrameRect(CGRectMake(4, (size.height-sizePic.height)/2, sizePic.width, sizePic.height));
	m_btnPaiHang->SetDelegate(this);
	m_btnPaiHang->SetFontColor(ccc4(255, 255, 255, 255));
	this->AddChild(m_btnPaiHang);
	
	SetKeyLeftDistance(4+sizePic.width+4);
}

void PaiHangCell::SetOrder(unsigned int order)
{
	if (!m_btnPaiHang) return;
	
	std::stringstream ss; ss << order;
	
	m_btnPaiHang->SetTitle(ss.str().c_str());
}

#pragma mark 非全屏对话框背景
IMPLEMENT_CLASS(NDCommonDlgBack, NDUILayer)

NDCommonDlgBack::NDCommonDlgBack()
{
	m_bYellow = false;
	
	m_btnClose = NULL;
	
	m_lbTitle = NULL;
}

NDCommonDlgBack::~NDCommonDlgBack()
{
}

void NDCommonDlgBack::Initialization(bool yellow/*=true*/)
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_bYellow = yellow;
	
	CGSize sizeDialog = CGSizeMake(367, 245);
	
	this->SetFrameRect(CGRectMake((winsize.width-sizeDialog.width)/2,
								  (winsize.height-sizeDialog.height)/2, 
								  sizeDialog.width, 
								  sizeDialog.height));
	
	this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(m_bYellow ? "dlg_bg_yellow.png" : "dlg_bg.png")), true);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(16);
	m_lbTitle->SetFontColor(ccc4(255, 233, 154, 255));
	m_lbTitle->SetFontBoderColer(ccc4(35, 89, 96, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, sizeDialog.width, 36));
	this->AddChild(m_lbTitle);
	
	m_btnClose = new NDUIButton;
	m_btnClose->Initialization();
	m_btnClose->SetFrameRect(CGRectMake(sizeDialog.width-45, 0, 45, 45));
	m_btnClose->SetDelegate(this);
	m_btnClose->CloseFrame();
	m_btnClose->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(m_bYellow ? "dlgfull_close_normal.png" : "dlg_close_normal.png")), 
						 false, CGRectZero, true);
	m_btnClose->SetTouchDownImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(m_bYellow ? "dlgfull_close_click.png" : "dlg_close_click.png")),
								  false, CGRectZero, true);
	this->AddChild(m_btnClose);
	
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene) 
	{
		scene->AddChild(this, UIDIALOG_Z);
	}
}

void NDCommonDlgBack::Close()
{
	if (this->GetParent()) 
	{
		this->RemoveFromParent(true);
	}
}

void NDCommonDlgBack::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnClose) 
	{
		this->Close();
	}
}

bool NDCommonDlgBack::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	m_beginTouch = touch->GetLocation();
	
	if (CGRectContainsPoint(this->GetScreenRect(), m_beginTouch)) 
	{
		NDUILayer::TouchBegin(touch);
		
		return true;
	}
	
	this->Close();
	
	return true;
}

void NDCommonDlgBack::SetTitle(const char * text)
{
	if (m_lbTitle) {
		m_lbTitle->SetText(text == NULL ? "" : text);
	}
}

NDPicture* NDCommonDlgBack::GetBtnNormalPic(CGSize size)
{
	const char* filename = m_bYellow ? "dlgyellow_btn_normal.png" : "dlg_btn_normal.png";
	return NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(filename),size.width, size.height);
}

NDPicture* NDCommonDlgBack::GetBtnClickPic(CGSize size)
{
	const char* filename = m_bYellow ? "dlgyellow_btn_click.png" : "dlg_btn_click.png";
	return NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew(filename),size.width, size.height);
}

#pragma mark 通用精灵UI节点

IMPLEMENT_CLASS(NDUISpriteNode, NDUINode)

NDUISpriteNode::NDUISpriteNode()
{
	m_sprite = NULL;
	
	m_sizeRun = CGSizeMake(0.0f, 0.0f);
	
	m_bShow = true;
}

NDUISpriteNode::~NDUISpriteNode()
{
}

void NDUISpriteNode::Initialization(const char* sprfile)
{
	NDUINode::Initialization();
	
	if (sprfile) 
	{
		m_sprite = new NDLightEffect;
		m_sprite->Initialization(sprfile);
		m_sprite->SetPosition(ccp(0.0f, 0.0f));
		m_sprite->SetLightId(0);
		
		m_sizeRun = NDDirector::DefaultDirector()->GetWinSize();
	}
	
	this->EnableEvent(false);
}

void NDUISpriteNode::SetSpritePosition(CGPoint pos)
{
	if (m_sprite) 
		m_sprite->SetPosition(pos);
}

void NDUISpriteNode::Show(bool show)
{
	m_bShow = show;
}

void NDUISpriteNode::draw()
{
	if (!this->IsVisibled()) return;
	
	if (m_sprite && m_bShow)
		m_sprite->Run(m_sizeRun);
}
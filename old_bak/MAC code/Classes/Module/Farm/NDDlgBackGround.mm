/*
 *  NDDlgBackGround.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDDlgBackGround.h"
#include "NDUIButton.h"
#include "NDUtility.h"
#include "define.h"
#include "CGPointExtension.h"
#include "NDPath.h"

using namespace std;

IMPLEMENT_CLASS(NDDlgBackGround, NDUILayer)

NDDlgBackGround::NDDlgBackGround()
{
	string bottomImage = NDPath::GetImgPath("bottom.png");
	
	m_picLeftTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picLeftTop->SetReverse(true);
	m_picLeftTop->Rotation(PictureRotation180);
	
	m_picRightTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightTop->Rotation(PictureRotation180);
	
	m_picLeftBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	
	m_picRightBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightBottom->SetReverse(true);
	
	m_tlOpt = NULL;
	m_bNeedInitTL = false;
}

NDDlgBackGround::~NDDlgBackGround()
{
	SAFE_DELETE(m_picLeftTop);
	SAFE_DELETE(m_picRightTop);
	SAFE_DELETE(m_picLeftBottom);
	SAFE_DELETE(m_picRightBottom);
}

bool NDDlgBackGround::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	if (this->m_vecTLStr.empty()) 
	{
		this->Close();
		return true;
	}
	
	m_beginTouch = touch->GetLocation();
	
	this->DispatchTouchBeginEvent(m_beginTouch);	
	
	return true;
}

bool NDDlgBackGround::TouchEnd(NDTouch* touch)
{
	m_endTouch = touch->GetLocation();
			
	this->DispatchTouchEndEvent(m_beginTouch, m_endTouch);
	
	return true;
}

void NDDlgBackGround::InitBtns(const std::vector<std::string>& vec_str, const std::vector<int>& vec_id)
{
	m_vecTLStr = vec_str;
	m_vecTLTag = vec_id;
	m_bNeedInitTL = true;
}

void NDDlgBackGround::draw()
{
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	CGRect scrRect = this->GetScreenRect();
	
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 2), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 2), 
			 ccc4(41, 65, 33, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 3), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 3), 
			 ccc4(57, 105, 90, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 4), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 4), 
			 ccc4(82, 125, 115, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + 5), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + 5), 
			 ccc4(82, 117, 82, 255), 1);
	
	//bottom frame
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 2), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 2), 
			 ccc4(41, 65, 33, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 3), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 3), 
			 ccc4(57, 105, 90, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 4), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 4), 
			 ccc4(82, 125, 115, 255), 1);
	DrawLine(ccp(scrRect.origin.x + 30, scrRect.origin.y + scrRect.size.height - 5), 
			 ccp(scrRect.origin.x + scrRect.size.width - 30, scrRect.origin.y + scrRect.size.height - 5), 
			 ccc4(82, 117, 82, 255), 1);
	
	//left frame
	DrawLine(ccp(scrRect.origin.x + 13, scrRect.origin.y + 16), 
			 ccp(scrRect.origin.x + 13, scrRect.origin.y + scrRect.size.height - 16), 
			 ccc4(115, 121, 90, 255), 8);
	//			this->DrawLine(ccp(scrRect.origin.x + 17, scrRect.origin.y + 16), 
	//						   ccp(scrRect.origin.x + 17, scrRect.origin.y + scrRect.size.height - 16), 
	//						   ccc4(107, 89, 74, 255), 1);
	
	//right frame
	DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + 16), 
			 ccp(scrRect.origin.x + scrRect.size.width - 13, scrRect.origin.y + scrRect.size.height - 16), 
			 ccc4(115, 121, 90, 255), 8);
	//			this->DrawLine(ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + 16), 
	//						   ccp(scrRect.origin.x + scrRect.size.width - 17, scrRect.origin.y + scrRect.size.height - 16), 
	//						   ccc4(107, 89, 74, 255), 1);
	
	//background
	DrawRecttangle(CGRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, scrRect.size.height - 10), ccc4(0, 0, 0, 188));
	
	
	m_picLeftTop->DrawInRect(CGRectMake(scrRect.origin.x+7, 
										scrRect.origin.y, 
										m_picLeftTop->GetSize().width, 
										m_picLeftTop->GetSize().height));
	m_picRightTop->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightTop->GetSize().width - 7, 
										 scrRect.origin.y, 
										 m_picRightTop->GetSize().width, 
										 m_picRightTop->GetSize().height));
	m_picLeftBottom->DrawInRect(CGRectMake(scrRect.origin.x+7, 
										   scrRect.origin.y + scrRect.size.height - m_picLeftBottom->GetSize().height,
										   m_picLeftBottom->GetSize().width, 
										   m_picLeftBottom->GetSize().height));
	m_picRightBottom->DrawInRect(CGRectMake(scrRect.origin.x + scrRect.size.width - m_picRightBottom->GetSize().width - 7,
											scrRect.origin.y + scrRect.size.height - m_picRightBottom->GetSize().height,
											m_picRightBottom->GetSize().width,
											m_picRightBottom->GetSize().height));
											
	if (m_bNeedInitTL) 
	{
		InitOpt();
		m_bNeedInitTL =false;
	}
}

void NDDlgBackGround::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cellIndex >= m_vecTLStr.size() || m_vecTLStr.size() != m_vecTLTag.size()) 
	{
		return;
	}
	
	NDDlgBackGroundDelegate* delegate = dynamic_cast<NDDlgBackGroundDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnDlgBackGroundBtnClick(this, m_vecTLStr[cellIndex], m_vecTLTag[cellIndex], cellIndex);
	}
}

void NDDlgBackGround::InitOpt()
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, tlWidth-34, 30)); \
button->SetTitle(text); \
button->SetTag(iid); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0)
	if (!m_tlOpt) 
	{
		m_tlOpt = new NDUITableLayer;
		m_tlOpt->Initialization();
		m_tlOpt->VisibleSectionTitles(false);
		m_tlOpt->SetDelegate(this);
		m_tlOpt->SetVisible(false);
		this->AddChild(m_tlOpt);
	}
	
	if (m_vecTLStr.empty() || m_vecTLStr.size() != m_vecTLTag.size()) 
	{
		m_tlOpt->SetVisible(false);
		return;
	}
	
	CGRect rect = GetFrameRect();
	
	int tlWidth = rect.size.width, tlHeight = m_vecTLStr.size()*30+15-m_vecTLStr.size()-1;
	
	if (tlWidth < 34) 
		tlWidth = 0;
	else 
		tlWidth -= 34;
	
	if (tlHeight > rect.size.height) 
		tlHeight = rect.size.height;

	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	std::vector<std::string>::iterator it = m_vecTLStr.begin();
	for (int i = 0; it != m_vecTLStr.end(); it++, i++)
	{
		fastinit(((*it).c_str()), m_vecTLTag[i]);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	
	
	m_tlOpt->SetFrameRect(CGRectMake(17, rect.size.height - tlHeight, tlWidth, tlHeight-15));
	m_tlOpt->SetVisible(true);
	
	if (m_tlOpt->GetDataSource())
	{
		m_tlOpt->SetDataSource(dataSource);
		m_tlOpt->ReflashData();
	}
	else
	{
		m_tlOpt->SetDataSource(dataSource);
	}
#undef fastinit
}

void NDDlgBackGround::Close()
{
	this->RemoveFromParent(true);
}


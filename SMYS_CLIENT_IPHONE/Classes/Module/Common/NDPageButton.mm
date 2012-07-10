/*
 *  NDPageButton.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDPageButton.h"
#include "NDPicture.h"
#include "NDUtility.h"
#include <sstream>

using namespace std;

IMPLEMENT_CLASS(NDPageButton, NDUILayer)

NDPageButton::NDPageButton()
{
	this->m_nCurPage = 1;
	this->m_nTotalPage = 1;
	
	this->m_btnPrePage = NULL;
	this->m_btnNextPage = NULL;
	m_lbPages = NULL;
}

NDPageButton::~NDPageButton()
{
	
}

void NDPageButton::Initialization(CGRect rectFrame)
{
	NDUINode::Initialization();
	
	this->SetFrameRect(rectFrame);
	
	CGRect rectPages = CGRectMake(54.0f, 4.0f, 54.0, 22.0f);
	
	m_lbPages = new NDUILabel;
	m_lbPages->Initialization();
	m_lbPages->SetFrameRect(rectPages);
	m_lbPages->SetFontColor(ccc4(0, 0, 255, 255));
	m_lbPages->SetTextAlignment(LabelTextAlignmentCenter);
	stringstream ss;
	ss << this->m_nCurPage << "/" << this->m_nTotalPage;
	m_lbPages->SetText(ss.str().c_str());
	this->AddChild(m_lbPages);
	
	CGRect rectPrePage = CGRectMake(0.0f, 0.0f, 54.0f, 22.0f);
	
	this->m_btnPrePage = new NDUIButton;
	this->m_btnPrePage->Initialization();
	this->m_btnPrePage->SetFrameRect(rectPrePage);
	m_btnPrePage->SetDelegate(this);
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	pic->Cut(CGRectMake(320.0f, 140.0f, 43.0f, 20.0f));
	m_btnPrePage->SetImage(pic, false, rectPrePage);
	this->AddChild(m_btnPrePage);
	
	CGRect rectNextPage = CGRectMake(rectFrame.size.width - 54.0f, 0.0f, 54.0f, 22.0f);
	
	this->m_btnNextPage = new NDUIButton;
	this->m_btnNextPage->Initialization();
	this->m_btnNextPage->SetFrameRect(rectNextPage);
	m_btnNextPage->SetDelegate(this);
	pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	pic->Cut(CGRectMake(320, 162, 43, 18));
	m_btnNextPage->SetImage(pic, false, rectNextPage);
	this->AddChild(m_btnNextPage);
}

void NDPageButton::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnPrePage) {
		if (this->m_nCurPage <= 1) {
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("FirstPageTip"));
			return;
		} else {
			this->m_nCurPage--;
		}
	} else if (button == m_btnNextPage) {
		if (this->m_nCurPage >= this->m_nTotalPage) {
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("LastPageTip"));
			return;
		} else {
			this->m_nCurPage++;
		}
	}
	
	this->SetPages(m_nCurPage, m_nTotalPage);
	
	if (this->m_pageDelegate) {
		m_pageDelegate->OnPageChange(this->m_nCurPage, m_nTotalPage);
	}
}

void NDPageButton::SetPages(int nCurPage, int nTotalPage)
{
	this->m_nCurPage = nCurPage;
	this->m_nTotalPage = nTotalPage;
	
	stringstream ss;
	ss << nCurPage << "/" << nTotalPage;
	
	this->m_lbPages->SetText(ss.str().c_str());
}
/*
 *  SyndicateInvite.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateInvite.h"
#include "NDUISynLayer.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "NDUIButton.h"
#include "NDMsgDefine.h"

IMPLEMENT_CLASS(SyndicateInvite, NDUILayer)

SyndicateInvite::SyndicateInvite()
{
	std::string bottomImage = GetImgPath("bottom.png");
	m_picLeftTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picLeftTop->SetReverse(true);
	m_picLeftTop->Rotation(PictureRotation180);
	
	m_picRightTop = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightTop->Rotation(PictureRotation180);
	
	m_picLeftBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	
	m_picRightBottom = NDPicturePool::DefaultPool()->AddPicture(bottomImage.c_str());
	m_picRightBottom->SetReverse(true);
	
	m_bTouchBegin = false;
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	scrRect = CGRectMake((winSize.width - 200.0f) / 2, 
			     (winSize.height - 220.0f) / 2, 
			     200.0f, 220.0f);
}

SyndicateInvite::~SyndicateInvite()
{
	delete m_picLeftTop;
	delete m_picRightTop;
	delete m_picLeftBottom;
	delete m_picRightBottom;
}

void SyndicateInvite::Show()
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene) 
	{
		SyndicateInvite* dlg = new SyndicateInvite;
		dlg->Initialization();
		dlg->SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width, NDDirector::DefaultDirector()->GetWinSize().height));
		scene->AddChild(dlg);
	}
}

void SyndicateInvite::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cellIndex == 0) {
		if (m_strInvited.empty()) {
			showDialog(NDCommonCString("NameErr"), NDCommonCString("InputPlayerName"));
			return;
		} else {
			sendInviteOther(m_strInvited);
		}
	}
	this->RemoveFromParent(true);
}

void SyndicateInvite::OnEditInputFinish(NDUIEdit* edit)
{
	m_strInvited = edit->GetText();
}

void SyndicateInvite::Initialization()
{
	NDUILayer::Initialization();
	
	float x = scrRect.origin.x;
	float y = scrRect.origin.y + 16.0f;
	NDUILabel* lbNote = new NDUILabel;
	lbNote->Initialization();
	lbNote->SetText(NDCommonCString("InputInvitePlayerName"));
	lbNote->SetTextAlignment(LabelTextAlignmentCenter);
	lbNote->SetFrameRect(CGRectMake(x, y, scrRect.size.width, 20.0f));
	this->AddChild(lbNote);
	y += 23.0f;
	x += 30.0f;
	
	NDUIEdit* edtNote = new NDUIEdit;
	edtNote->Initialization();
	edtNote->SetDelegate(this);
	edtNote->ShowCaret(false);
	edtNote->SetMaxLength(10);
	edtNote->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
	this->AddChild(edtNote);
	y += 36.0f;
	
	NDUITableLayer* opt = new NDUITableLayer;
	opt->Initialization();
	opt->VisibleSectionTitles(false);
	NDDataSource* ds = new NDDataSource;
	opt->SetDelegate(this);
	opt->SetDataSource(ds);
	NDSection* sec = new NDSection;
	sec->UseCellHeight(true);
	ds->AddSection(sec);
	
	NDUIButton* btn = NULL;
	
	int nHeight = 1;
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCommonCString("Ok"));
	btn->SetDelegate(this);
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	btn->SetFrameRect(CGRectMake(0, 0, scrRect.size.width - 60.0f, 30.0f));
	sec->AddCell(btn);
	nHeight += 31.0f;
	
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCommonCString("Cancel"));
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	btn->SetDelegate(this);
	btn->SetFrameRect(CGRectMake(0, 30.0f, scrRect.size.width - 60.0f, 30.0f));
	sec->AddCell(btn);
	nHeight += 31.0f;
	
	sec->SetFocusOnCell(0);
	
	opt->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, nHeight));
	
	this->AddChild(opt);
	
	y += nHeight + 16.0f;
	
	scrRect.size.height = y - scrRect.origin.y;
}

void SyndicateInvite::draw()
{
	NDUILayer::draw();
	
	if (this->IsVisibled())
	{
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
		DrawRecttangle(CGRectMake(scrRect.origin.x + 17, scrRect.origin.y + 5, scrRect.size.width - 34, scrRect.size.height - 10), ccc4(196, 201, 181, 255));
		
		
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
	}
}

/*
 *  CreateSynDialog.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "CreateSynDialog.h"
#include "NDUISynLayer.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDPath.h"
#include "NDUICheckBox.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "NDUIButton.h"
#include <sstream>
#include "NDMsgDefine.h"

IMPLEMENT_CLASS(CreateSynDialog, NDUILayer)

CreateSynDialog::CreateSynDialog()
{
	std::string bottomImage = NDPath::GetImgPath("bottom.png");
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
	scrRect = CGRectMake((winSize.width - 157.0f) / 2, 
				    (winSize.height - 220.0f) / 2, 
				    157.0f, 220.0f);
	
	m_tagCamp = CAMP_TYPE_NONE;
}

CreateSynDialog::~CreateSynDialog()
{
	delete m_picLeftTop;
	delete m_picRightTop;
	delete m_picLeftBottom;
	delete m_picRightBottom;
}

void CreateSynDialog::Show()
{
	CloseProgressBar;
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene) 
	{
		CreateSynDialog* dlg = new CreateSynDialog;
		dlg->Initialization();
		dlg->SetFrameRect(CGRectMake(0, 0, NDDirector::DefaultDirector()->GetWinSize().width, NDDirector::DefaultDirector()->GetWinSize().height));
		scene->AddChild(dlg);
	}
}

void CreateSynDialog::OnEditInputFinish(NDUIEdit* edit)
{
	m_synName = edit->GetText();
}

void CreateSynDialog::OnCBClick(NDUICheckBox* cb)
{
	if (cb->GetCBState()) {
		NDUICheckBox* check = (NDUICheckBox*)this->GetChild(m_tagCamp);
		if (check) {
			if (check->GetCBState()) {
				check->ChangeCBState();
			}
		}
		m_tagCamp = cb->GetTag();
	} else {
		m_tagCamp = CAMP_TYPE_NONE;
	}
}

void CreateSynDialog::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (buttonIndex == 0) {
		ShowProgressBar;
		NDTransData bao(_MSG_CREATE_SYN);
		bao.WriteUnicodeString(m_synName);
		bao << Byte(m_tagCamp);
		SEND_DATA(bao);
	}
	dialog->Close();
	this->RemoveFromParent(true);
}

void CreateSynDialog::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cellIndex == 0) { // 确定
		if (m_synName.empty()) {
			showDialog(NDCString("JunTuanNameErr"), NDCString("InputJunTuanName"));
		} else if (m_tagCamp == CAMP_TYPE_NONE) {
			showDialog(NDCString("CampErr"), NDCString("SelCamp"));
		} else {
			stringstream ss;
			ss << NDCString("ConfirmNameJunTuan") << "\n" << m_synName
			<< "\n" << NDCString("ConfirmNameJunTuan2") << "\n" << NDCommonCString("ConfirmTip");
			NDUIDialog* dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetDelegate(this);
			dlg->Show(NDCommonCString("WenXinTip"), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
	} else { // 取消
		this->RemoveFromParent(true);
	}
}

void CreateSynDialog::Initialization()
{
	NDUILayer::Initialization();
	
	float x = scrRect.origin.x;
	float y = scrRect.origin.y + 16.0f;
	NDUILabel* lbNote = new NDUILabel;
	lbNote->Initialization();
	lbNote->SetText(NDCString("InputJunTuanName"));
	lbNote->SetTextAlignment(LabelTextAlignmentCenter);
	lbNote->SetFrameRect(CGRectMake(x, y, scrRect.size.width, 20.0f));
	this->AddChild(lbNote);
	y += 23.0f;
	x += 30.0f;
	
	NDUIEdit* edtName = new NDUIEdit;
	edtName->Initialization();
	edtName->SetDelegate(this);
	edtName->SetMaxLength(6);
	edtName->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
	this->AddChild(edtName);
	y += 36.0f;
	
	NDPlayer& role = NDPlayer::defaultHero();
	if (role.camp == CAMP_TYPE_NONE) {
		NDUICheckBox* check = new NDUICheckBox;
		check->Initialization();
		check->SetText(CAMP_NAME_TANG);
		check->SetDelegate(this);
		check->SetTag(CAMP_TYPE_TANG);
		check->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
		this->AddChild(check);
		y += 30.0f;
		
		check = new NDUICheckBox;
		check->Initialization();
		check->SetText(CAMP_NAME_SUI);
		check->SetTag(CAMP_TYPE_SUI);
		check->SetDelegate(this);
		check->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
		this->AddChild(check);
		y += 30.0f;
		
		check = new NDUICheckBox;
		check->Initialization();
		check->SetText(CAMP_NAME_TU);
		check->SetTag(CAMP_TYPE_TU);
		check->SetDelegate(this);
		check->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
		this->AddChild(check);
		y += 30.0f;
	} else {
		const char* pszCheck = NULL;
		int tag = CAMP_TYPE_TANG;
		if (role.camp == CAMP_TYPE_TANG) {
			pszCheck = CAMP_NAME_TANG;
		} else if (role.camp == CAMP_TYPE_SUI) {
			pszCheck = CAMP_NAME_SUI;
			tag = CAMP_TYPE_SUI;
		} else {
			pszCheck = CAMP_NAME_TU;
			tag = CAMP_TYPE_TU;
		}

		NDUICheckBox* check = new NDUICheckBox;
		check->Initialization();
		check->SetText(pszCheck);
		check->SetDelegate(this);
		check->SetTag(tag);
		check->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 20.0f));
		this->AddChild(check);
		y += 30.0f;
	}
	
	NDUITableLayer* opt = new NDUITableLayer;
	opt->Initialization();
	opt->VisibleSectionTitles(false);
	NDDataSource* ds = new NDDataSource;
	opt->SetDelegate(this);
	opt->SetDataSource(ds);
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCommonCString("Ok"));
	btn->SetDelegate(this);
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	btn->SetFrameRect(CGRectMake(0, 0, scrRect.size.width - 60.0f, 30.0f));
	sec->AddCell(btn);
	
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCommonCString("Cancel"));
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	btn->SetDelegate(this);
	btn->SetFrameRect(CGRectMake(0, 30.0f, scrRect.size.width - 60.0f, 30.0f));
	sec->AddCell(btn);
	
	sec->SetFocusOnCell(0);
	
	opt->SetFrameRect(CGRectMake(x, y, scrRect.size.width - 60.0f, 63.0f));
	
	this->AddChild(opt);
	
	y += 76.0f;
	
	scrRect.size.height = y - scrRect.origin.y;
}

void CreateSynDialog::draw()
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
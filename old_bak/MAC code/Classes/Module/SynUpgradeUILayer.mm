/*
 *  SynUpgradeUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynUpgradeUILayer.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"
#include "NDDirector.h"
#include "NDPath.h"
#include <sstream>

SynUpgradeUILayer* SynUpgradeUILayer::s_instance = NULL;

void SynUpgradeUILayer::processSynUpgrade(NDTransData& data)
{
	CloseProgressBar;
	string title = data.ReadUnicodeString();
	string content1 = data.ReadUnicodeString();
	string content2 = data.ReadUnicodeString();
	
	if (m_memoContent1 == NULL) {
		m_memoContent1 = new NDUIMemo;
		m_memoContent1->Initialization();
		m_memoContent1->SetFontSize(15);
		m_memoContent1->SetFontColor(ccc4(187, 19, 19, 255));
		m_memoContent1->SetBackgroundColor(ccc4(107, 158, 156, 0));
		m_memoContent1->SetFrameRect(CGRectMake(10.0f, 25.0f, 320.0f, 50.0f));
		this->AddChild(m_memoContent1);
	}
	
	m_memoContent1->SetText(content1.c_str());
	
	if (m_memoContent2 == NULL) {
		m_memoContent2 = new NDUIMemo;
		m_memoContent2->Initialization();
		m_memoContent2->SetFontSize(15);
		m_memoContent2->SetFontColor(ccc4(78, 77, 82, 255));
		m_memoContent2->SetBackgroundColor(ccc4(107, 188, 156, 0));
		m_memoContent2->SetFrameRect(CGRectMake(10.0f, 88.0f, 320.0f, 170.0f));
		this->AddChild(m_memoContent2);
	}
	
	m_memoContent2->SetText(content2.c_str());
}

IMPLEMENT_CLASS(SynUpgradeUILayer, NDUILayer)

SynUpgradeUILayer::SynUpgradeUILayer()
{
	s_instance = this;
	m_bQuery = true;
	m_memoContent1 = NULL;
	m_memoContent2 = NULL;
}

SynUpgradeUILayer::~SynUpgradeUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void SynUpgradeUILayer::Query()
{
	if (m_bQuery) {
		sendQuerySynNormalInfo(ACT_QUERY_SYN_UPGRADE_INFO);
		m_bQuery = false;
	}
}

void SynUpgradeUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 451, 268), true);
	img->SetFrameRect(CGRectMake(0, 6, 457, 274));
	this->AddChild(img);
	
	NDUIImage* imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("cell_mask.png"), 457, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, 64, 440, 20));
	this->AddChild(imgBg);
	
	NDUILabel* label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(255, 255, 255, 255));
	label->SetText(NDCommonCString("UpCondition"));
	label->SetFrameRect(CGRectMake(20, 66, 80, 15));
	label->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(label);
	
	NDUIButton* btnUpgrade = new NDUIButton;
	btnUpgrade->Initialization();
	btnUpgrade->SetDelegate(this);
	btnUpgrade->SetFrameRect(CGRectMake(376, 226, 53, 38));
	btnUpgrade->SetImage(pool.AddPicture(NDPath::GetImgPathNew("syn_upgrade.png")), false, CGRectZero, true);
	this->AddChild(btnUpgrade);
	btnUpgrade->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(6, 0, 38, 38), true);
}

void SynUpgradeUILayer::OnButtonClick(NDUIButton* button)
{
	sendUpGradeSyn();
}


/*
 *  SynElectionUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynElectionUILayer.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "SyndicateCommon.h"
#include "NDUISynLayer.h"
#include "NDMapMgr.h"
#include <sstream>
#include "NDPlayer.h"

IMPLEMENT_CLASS(NDSynEleCell, NDPropCell)

NDSynEleCell::NDSynEleCell()
{
	m_se = NULL;
}

NDSynEleCell::~NDSynEleCell()
{
	
}

SynElectionUILayer* SynElectionUILayer::s_instance = NULL;

IMPLEMENT_CLASS(SynElectionUILayer, NDUILayer)

void SynElectionUILayer::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SynElectionUILayer::processQueryOfficer(NDTransData& data)
{
	CloseProgressBar;
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	NDDataSource *ds = m_tlDetail->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	this->releaseElement();
	
	int btCurPageMbrCount = data.ReadByte();
	
	for (int i = 0; i < btCurPageMbrCount; i++) {
		string strMbrName = data.ReadUnicodeString();
		int btRank = data.ReadByte();
		
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = btRank;
		se->m_text1 = strMbrName;
		se->m_text2 = getRankStr(btRank);
		
		NDSynEleCell* cell = new NDSynEleCell;
		cell->Initialization(false, CGSizeMake(230, 23));
		cell->SetSocialElement(se);
		cell->SetKeyLeftDistance(6);
		cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
		cell->GetKeyText()->SetText(se->m_text1.c_str());
		cell->GetValueText()->SetText(se->m_text2.c_str());
		sec->AddCell(cell);
		if (i == 0) {
			m_curSelEle = se;
		}
	}
	sec->SetFocusOnCell(0);
	this->m_tlDetail->ReflashData();
}

SynElectionUILayer::SynElectionUILayer()
{
	s_instance = this;
	
	m_btnElection = NULL;
	m_tlCategory = NULL;
	m_tlDetail = NULL;
	m_bQuery = true;
}

SynElectionUILayer::~SynElectionUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
	
	this->releaseElement();
}

void SynElectionUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDUIImage* imgLeft = new NDUIImage;
	imgLeft->Initialization();
	imgLeft->SetPicture(pool.AddPicture(GetImgPathNew("bag_left_bg.png")), true);
	imgLeft->SetFrameRect(CGRectMake(0, 9, 203, 262));
	this->AddChild(imgLeft);
	
	NDUIImage* imgRight = new NDUIImage;
	imgRight->Initialization();
	imgRight->SetPicture(pool.AddPicture(GetImgPathNew("bag_bag_bg.png")), true);
	imgRight->SetFrameRect(CGRectMake(203, 3, 252, 274));
	this->AddChild(imgRight);
	
	NDUIImage* infoTitle = new NDUIImage;
	infoTitle->Initialization();
	infoTitle->SetPicture(pool.AddPicture(GetImgPathNew("farmrheadtitle.png")), true);
	infoTitle->SetFrameRect(CGRectMake(6, 21, 8, 8));
	this->AddChild(infoTitle);
	
	NDUILabel* lbInfoTile = new NDUILabel;
	lbInfoTile->Initialization();
	lbInfoTile->SetFontColor(ccc4(187, 19, 19, 255));
	lbInfoTile->SetText(NDCommonCString("PostElection"));
	lbInfoTile->SetFrameRect(CGRectMake(16, 17, 80, 30));
	this->AddChild(lbInfoTile);
	
	NDUIImage* imgInfoBg = new NDUIImage;
	imgInfoBg->Initialization();
	imgInfoBg->SetPicture(pool.AddPicture(GetImgPathNew("attr_role_bg.png")), true);
	imgInfoBg->SetFrameRect(CGRectMake(0, 40, 196, 185));
	this->AddChild(imgInfoBg);
	
	m_btnElection = new NDUIButton;
	m_btnElection->Initialization();
	m_btnElection->SetDelegate(this);
	m_btnElection->SetFrameRect(CGRectMake(386, 226, 36, 45));
	m_btnElection->SetImage(pool.AddPicture(GetImgPathNew("btn_election.png")), false, CGRectZero, true);
	m_btnElection->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(0, 4, 36, 36), true);
	this->AddChild(m_btnElection);
	
	m_tlCategory = new NDUITableLayer;
	m_tlCategory->Initialization();
	m_tlCategory->SetBackgroundColor(ccc4(0, 255, 0, 0));
	m_tlCategory->VisibleSectionTitles(false);
	m_tlCategory->SetFrameRect(CGRectMake(0, 46, 182, 166));
	m_tlCategory->VisibleScrollBar(false);
	m_tlCategory->SetCellsInterval(2);
	m_tlCategory->SetCellsRightDistance(0);
	m_tlCategory->SetCellsLeftDistance(0);
	m_tlCategory->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlCategory->SetDataSource(dataSource);
	this->AddChild(m_tlCategory);
	
	NDPropCell* cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(176, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("JunTuanZhang"));
	cell->SetFocusPicture(GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(176, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("FuTuanZhang"));
	cell->SetFocusPicture(GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(176, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("YuanLao"));
	cell->SetFocusPicture(GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(176, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("TangZhu"));
	cell->SetFocusPicture(GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(176, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("MengZhu"));
	cell->SetFocusPicture(GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	section->AddCell(cell);
	section->SetFocusOnCell(0);
	
	m_tlDetail = new NDUITableLayer;
	m_tlDetail->Initialization();
	m_tlDetail->SetBackgroundColor(ccc4(255, 0, 0, 0));
	m_tlDetail->VisibleSectionTitles(false);
	m_tlDetail->SetFrameRect(CGRectMake(10+200, 17, 236, 206));
	m_tlDetail->VisibleScrollBar(false);
	m_tlDetail->SetCellsInterval(2);
	m_tlDetail->SetCellsRightDistance(0);
	m_tlDetail->SetCellsLeftDistance(0);
	m_tlDetail->SetDelegate(this);
	
	dataSource = new NDDataSource;
	section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlDetail->SetDataSource(dataSource);
	this->AddChild(m_tlDetail);
}

void SynElectionUILayer::Query()
{
	if (m_bQuery) {
		sendSynElection(ACT_QUERY_OFFICER, 12);
		m_bQuery = false;
	}
}

void SynElectionUILayer::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_tlDetail == table) {
		if (cell && cell->IsKindOfClass(RUNTIME_CLASS(NDSynEleCell))) {
			m_curSelEle = ((NDSynEleCell*)cell)->GetSocialElement();
		}
	} else if (m_tlCategory == table) {
		switch (cellIndex) {
			case 0:
				sendSynElection(ACT_QUERY_OFFICER, 12);
				break;
			case 1:
				sendSynElection(ACT_QUERY_OFFICER, 11);
				break;
			case 2:
				sendSynElection(ACT_QUERY_OFFICER, 10);
				break;
			case 3:
				sendSynElection(ACT_QUERY_OFFICER, 5);
				break;
			case 4:
				sendSynElection(ACT_QUERY_OFFICER, 1);
				break;
			default:
				break;
		}
	}
}

void SynElectionUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (m_curSelEle) {
		sendSynElection(ACT_ELECTION, m_curSelEle->m_id);
	}
	dialog->Close();
}

void SynElectionUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnElection) {
		if (m_curSelEle) {
			NDUIDialog* dlgOpt = new NDUIDialog;
			dlgOpt->Initialization();
			dlgOpt->SetDelegate(this);
			string content = NDCString("ConfirmElec") + m_curSelEle->m_text2;
			dlgOpt->Show(NDCommonCString("WenXinTip"), content.c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
	}
}


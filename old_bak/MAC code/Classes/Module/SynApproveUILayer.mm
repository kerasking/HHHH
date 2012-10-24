/*
 *  SynApproveUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynApproveUILayer.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"
#include "NDDirector.h"
#include "NDPath.h"
#include <sstream>

IMPLEMENT_CLASS(ApproveListCell, NDPropCell)

ApproveListCell::ApproveListCell()
{
	m_imgYes = NULL;
	m_imgNo = NULL;
}

ApproveListCell::~ApproveListCell()
{
	
}

CGRect ApproveListCell::GetYesRect()
{
	if (m_imgYes) {
		return m_imgYes->GetScreenRect();
	}
	return CGRectZero;
}

CGRect ApproveListCell::GetNoRect()
{
	if (m_imgNo) {
		return m_imgNo->GetScreenRect();
	}
	return CGRectZero;
}

void ApproveListCell::Initialization()
{
	NDPropCell::Initialization(false, CGSizeMake(440, 27));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	m_imgYes = new NDUIImage;
	m_imgYes->Initialization();
	m_imgYes->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("request_ok.png")), true);
	m_imgYes->SetFrameRect(CGRectMake(330, 2, 23, 23));
	this->AddChild(m_imgYes);
	
	m_imgNo = new NDUIImage;
	m_imgNo->Initialization();
	m_imgNo->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("request_cancel.png")), true);
	m_imgNo->SetFrameRect(CGRectMake(370, 2, 23, 23));
	this->AddChild(m_imgNo);
}

SynApproveUILayer* SynApproveUILayer::s_instance = NULL;

IMPLEMENT_CLASS(SynApproveUILayer, NDUILayer)

void SynApproveUILayer::delCurSelCell()
{
	if (!m_tlApproveList) {
		return;
	}
	
	NDDataSource* ds = m_tlApproveList->GetDataSource();
	if (ds) {
		NDSection* sec = ds->Section(0);
		if (sec) {
			sec->RemoveCell(sec->GetFocusCellIndex());
		}
	}
	m_tlApproveList->ReflashData();
}

void SynApproveUILayer::processApproveList(NDTransData& data)
{
	CloseProgressBar;
	NDDataSource *ds = m_tlApproveList->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	int approveCount = data.ReadShort();
	m_nCurPage = data.ReadByte(); // 当前页数
	int btCurPageApproveCount = data.ReadByte(); // 当前需审批人数
	
	int t_totalPage = 1;
	if (approveCount % ONE_PAGE_COUNT == 0) {
		t_totalPage = approveCount / ONE_PAGE_COUNT;
	} else {
		t_totalPage = approveCount / ONE_PAGE_COUNT + 1;
	}
	m_nMaxPage = max(1, t_totalPage);
	
	stringstream ss;
	ss << (m_nCurPage+1) << " / " << m_nMaxPage;
	m_lbPages->SetText(ss.str().c_str());
	
	for (int i = 0; i < btCurPageApproveCount; i++) {
		int idRole = data.ReadInt();
		string strName = data.ReadUnicodeString();
		
		ApproveListCell *cell = new ApproveListCell;
		cell->Initialization();
		cell->SetTag(idRole);
		cell->SetKeyLeftDistance(16);
		cell->GetKeyText()->SetText(strName.c_str());
		cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
		sec->AddCell(cell);
	}
	sec->SetFocusOnCell(0);
	this->m_tlApproveList->ReflashData();
}

SynApproveUILayer::SynApproveUILayer()
{
	s_instance = this;
	m_tlApproveList = NULL;
	m_bQuery = true;
	m_lbPages = NULL;
	m_btnPrePage = NULL;
	m_btnNextPage = NULL;
	m_nCurPage = 0;
	m_nMaxPage = 0;
}

SynApproveUILayer::~SynApproveUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void SynApproveUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 451, 268), true);
	img->SetFrameRect(CGRectMake(0, 6, 457, 274));
	this->AddChild(img);
	
	m_tlApproveList = new NDUITableLayer;
	m_tlApproveList->Initialization();
	m_tlApproveList->SetBackgroundColor(ccc4(0, 255, 0, 0));
	m_tlApproveList->VisibleSectionTitles(false);
	m_tlApproveList->SetFrameRect(CGRectMake(0, 14, 450, 221));
	m_tlApproveList->VisibleScrollBar(false);
	m_tlApproveList->SetCellsInterval(7);
	m_tlApproveList->SetCellsRightDistance(0);
	m_tlApproveList->SetCellsLeftDistance(0);
	m_tlApproveList->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlApproveList->SetDataSource(dataSource);
	this->AddChild(m_tlApproveList);
	
	m_lbPages = new NDUILabel;
	m_lbPages->Initialization();
	m_lbPages->SetFrameRect(CGRectMake(110, 240, 242, 30));
	m_lbPages->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbPages->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_lbPages);
	
	m_btnPrePage = new NDUIButton;
	m_btnPrePage->Initialization();
	m_btnPrePage->SetFrameRect(CGRectMake(20, 236, 36, 36));
	m_btnPrePage->SetDelegate(this);
	m_btnPrePage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnPrePage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnPrePage);
	
	m_btnNextPage = new NDUIButton;
	m_btnNextPage->Initialization();
	m_btnNextPage->SetFrameRect(CGRectMake(400, 236, 36, 36));
	m_btnNextPage->SetDelegate(this);
	m_btnNextPage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnNextPage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnNextPage);
}

void SynApproveUILayer::Query()
{
	if (m_bQuery) {
		sendQueryApprove(0);
		m_bQuery = false;
	}
}

void SynApproveUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnPrePage) {
		if (m_nCurPage > 0) {
			sendQueryApprove(m_nCurPage - 1);
		}
	} else if (button == m_btnNextPage) {
		if (m_nCurPage < m_nMaxPage - 1) {
			sendQueryApprove(m_nCurPage + 1);
		}
	}
}

void SynApproveUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cell && cell->IsKindOfClass(RUNTIME_CLASS(ApproveListCell))) {
		ApproveListCell* approveCell = (ApproveListCell*)cell;
		if (CGRectContainsPoint(approveCell->GetYesRect(), table->m_beginTouch))
		{ // yes
			sendApproveAccept(approveCell->GetTag(), approveCell->GetKeyText()->GetText());
		}
		else if (CGRectContainsPoint(approveCell->GetNoRect(), table->m_beginTouch))
		{ // no
			sendApproveRefuse(approveCell->GetTag());
		}
	}
}

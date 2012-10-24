/*
 *  SynVoteUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynVoteUILayer.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"
#include "NDPath.h"
#include "NDDirector.h"

IMPLEMENT_CLASS(VoteListCell, NDPropCell)

VoteListCell::VoteListCell()
{
	m_idSponsor = 0;
	m_imgYes = NULL;
	m_imgNo = NULL;
}

VoteListCell::~VoteListCell()
{
	
}

CGRect VoteListCell::GetYesRect()
{
	if (m_imgYes) {
		return m_imgYes->GetScreenRect();
	}
	return CGRectZero;
}

CGRect VoteListCell::GetNoRect()
{
	if (m_imgNo) {
		return m_imgNo->GetScreenRect();
	}
	return CGRectZero;
}

void VoteListCell::Initialization()
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


SynVoteUILayer* SynVoteUILayer::s_instance = NULL;

IMPLEMENT_CLASS(SynVoteUILayer, NDUILayer)

SynVoteUILayer::SynVoteUILayer()
{
	s_instance = this;
	m_tlVoteList = NULL;
	m_btnView = NULL;
	m_bQuery = true;
	m_btnCancelVote = NULL;
}

SynVoteUILayer::~SynVoteUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
	
	if (m_btnCancelVote && m_btnCancelVote->GetParent() == NULL) {
		SAFE_DELETE(m_btnCancelVote);
	}
	
	if (m_btnView && m_btnView->GetParent() == NULL) {
		SAFE_DELETE(m_btnView);
	}
}

void SynVoteUILayer::processVoteList(NDTransData& data)
{
	CloseProgressBar;
	NDDataSource *ds = m_tlVoteList->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	int count = data.ReadByte();
	
	for (int i = 0; i < count; i++) {
		int idVote = data.ReadInt();//投票id
		int idSponsor = data.ReadInt();//发起人id
		string t_detail = data.ReadUnicodeString();//投票原因
		int nEndTime = data.ReadInt();//到期时间
		
		VoteListCell *cell = new VoteListCell;
		cell->Initialization();
		cell->SetTag(idVote);
		cell->m_idSponsor = idSponsor;
		cell->SetKeyLeftDistance(16);
		cell->SetValueRightDistance(200);
		cell->GetKeyText()->SetText(t_detail.c_str());
		cell->GetValueText()->SetText(getStringTime(nEndTime).c_str());
		cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
		sec->AddCell(cell);
	}
	
	sec->SetFocusOnCell(0);
	if (count > 0) {
		this->OnTableLayerCellFocused(m_tlVoteList, sec->Cell(0), 0, sec);
	}
	
	this->m_tlVoteList->ReflashData();
}

void SynVoteUILayer::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_btnView && m_btnView->GetParent() == NULL) {
		this->AddChild(m_btnView);
	}
	
	if (cell && cell->IsKindOfClass(RUNTIME_CLASS(VoteListCell))) {
		if (NDPlayer::defaultHero().m_id == ((VoteListCell*)cell)->m_idSponsor) {
			if (m_btnCancelVote && m_btnCancelVote->GetParent() == NULL) {
				this->AddChild(m_btnCancelVote);
			}
		} else {
			if (m_btnCancelVote) {
				m_btnCancelVote->RemoveFromParent(false);
			}
		}
	}
}

void SynVoteUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (cell && cell->IsKindOfClass(RUNTIME_CLASS(VoteListCell))) {
		VoteListCell* voteCell = (VoteListCell*)cell;
		if (CGRectContainsPoint(voteCell->GetYesRect(), table->m_beginTouch))
		{ // yes
			sendSynVoteComm(ACT_VOTE_YES, voteCell->GetTag());
		}
		else if (CGRectContainsPoint(voteCell->GetNoRect(), table->m_beginTouch))
		{ // no
			sendSynVoteComm(ACT_VOTE_NO, voteCell->GetTag());
		}
	}
}

void SynVoteUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 451, 268), true);
	img->SetFrameRect(CGRectMake(0, 6, 457, 274));
	this->AddChild(img);
	
	m_tlVoteList = new NDUITableLayer;
	m_tlVoteList->Initialization();
	m_tlVoteList->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlVoteList->VisibleSectionTitles(false);
	m_tlVoteList->SetFrameRect(CGRectMake(0, 14, 450, 201));
	m_tlVoteList->VisibleScrollBar(false);
	m_tlVoteList->SetCellsInterval(7);
	m_tlVoteList->SetCellsRightDistance(0);
	m_tlVoteList->SetCellsLeftDistance(0);
	m_tlVoteList->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlVoteList->SetDataSource(dataSource);
	this->AddChild(m_tlVoteList);
	
	m_btnView = new NDUIButton;
	m_btnView->Initialization();
	m_btnView->SetFrameRect(CGRectMake(366, 220, 44, 44));
	m_btnView->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(3, 3, 38, 38), true);
	m_btnView->SetImage(pool.AddPicture(NDPath::GetImgPathBattleUI("view_info.png")), false, CGRectZero, true);
	m_btnView->SetDelegate(this);
	//this->AddChild(m_btnView);
	
	m_btnCancelVote = new NDUIButton;
	m_btnCancelVote->Initialization();
	m_btnCancelVote->SetFrameRect(CGRectMake(306, 220, 52, 44));
	m_btnCancelVote->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(7, 3, 38, 38), true);
	m_btnCancelVote->SetImage(pool.AddPicture(NDPath::GetImgPathNew("cancel_vote.png")), true, CGRectMake(0, 2, 52, 44), true);
	m_btnCancelVote->SetDelegate(this);
}

void SynVoteUILayer::Query()
{
	if (m_bQuery) {
		sendQuerySynNormalInfo(ACT_QUERY_VOTE_LIST);
		m_bQuery = false;
	}
}

void SynVoteUILayer::OnButtonClick(NDUIButton* button)
{
	NDUINode* focusCell = NULL;
	NDDataSource* ds = m_tlVoteList->GetDataSource();
	if (ds) {
		NDSection* sec = ds->Section(0);
		if (sec) {
			uint focus = sec->GetFocusCellIndex();
			if (focus < sec->Count()) {
				focusCell = sec->Cell(focus);
			}
		}
	}
	
	if (button == m_btnView) {
		if (focusCell) {
			sendSynVoteComm(ACT_QUERY_VOTE_INFO, focusCell->GetTag());
		}
	} else if (button == m_btnCancelVote) {
		if (focusCell) {
			sendSynVoteComm(ACT_CANCEL_VOTE, focusCell->GetTag());
		}
	}
}


/*
 *  SyndicateUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateUILayer.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"
#include "CGPointExtension.h"
#include "NDPath.h"
#include <sstream>
#include "NDMsgDefine.h"

IMPLEMENT_CLASS(SynListCell, NDUINode)

SynListCell::SynListCell()
{
	m_lbKey = m_lbValue = NULL;
	
	m_picBg = m_picFocus = NULL;
	
	m_clrNormalText = ccc4(79, 79, 79, 255);
	m_clrFocusText = ccc4(79, 79, 79, 255);
}

SynListCell::~SynListCell()
{
	
}

void SynListCell::Initialization()
{
	NDUINode::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	m_picBg = pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 430, 23);
	
	this->SetFrameRect(CGRectMake(0, 0, 430, 23));
	
	m_picFocus = pool.AddPicture(NDPath::GetImgPathNew("selected_item_bg.png"), 430, 0);
	
	m_lbKey = new NDUILabel;
	m_lbKey->Initialization();
	m_lbKey->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbKey->SetFontSize(14);
	m_lbKey->SetFontColor(m_clrNormalText);
	this->AddChild(m_lbKey);
	
	m_lbValue = new NDUILabel;
	m_lbValue->Initialization();
	m_lbValue->SetTextAlignment(LabelTextAlignmentRight);
	m_lbValue->SetFontSize(14);
	m_lbValue->SetFontColor(m_clrNormalText);
	this->AddChild(m_lbValue);
}

NDUILabel* SynListCell::GetKeyText()
{
	return m_lbKey;
}

NDUILabel* SynListCell::GetValueText()
{
	return m_lbValue;
}

void SynListCell::draw()
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
			rect.origin = ccp(16, (size.height-m_lbKey->GetFontSize())/2);
			rect.size = size;
			m_lbKey->SetFrameRect(rect);
		}
		
		if (m_lbValue)
		{
			CGRect rect;
			rect.origin = ccp(0, (size.height-m_lbValue->GetFontSize())/2);
			rect.size = size;
			m_lbValue->SetFrameRect(rect);
		}
	}
	
}


SyndicateUILayer* SyndicateUILayer::s_instance = NULL;

IMPLEMENT_CLASS(SyndicateUILayer, NDUILayer)

void SyndicateUILayer::OnAllSynList(NDTransData& data)
{
	if (s_instance) {
		s_instance->RefreshAllSynList(data);
	}
}

void SyndicateUILayer::RefreshAllSynList(NDTransData& data)
{
	CloseProgressBar;
	NDDataSource *ds = m_tlSynList->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	int nAllSynNums = data.ReadShort();
	m_nCurPage = data.ReadByte();
	int nCount = data.ReadByte();
	
	const int ONE_PAGE_COUNT = 10;
	
	int t_totalPage = 1;
	if (nAllSynNums % ONE_PAGE_COUNT == 0) {
		t_totalPage = nAllSynNums / ONE_PAGE_COUNT;
	} else {
		t_totalPage = nAllSynNums / ONE_PAGE_COUNT + 1;
	}
	m_nTotalPage = max(1, t_totalPage);
	
	stringstream ss;
	ss << (m_nCurPage+1) << " / " << m_nTotalPage;
	m_lbPages->SetText(ss.str().c_str());
	
	for (int i = 0; i < nCount; i++) {
		__int64_t lSynContribution = data.ReadLong();
		int idSyn = data.ReadInt();
		int nSynFlag = data.ReadByte();
		string strSynName = data.ReadUnicodeString();
		
		SynListCell *cell = new SynListCell;
		cell->Initialization();
		cell->m_info.idSyn = idSyn;
		cell->m_info.synFlag = nSynFlag;
		cell->GetKeyText()->SetText(strSynName.c_str());
		stringstream ss;
		ss << lSynContribution;
		cell->GetValueText()->SetText(ss.str().c_str());
		cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
		sec->AddCell(cell);
	}
	
	sec->SetFocusOnCell(0);
	
	m_tlSynList->ReflashData();
}

SyndicateUILayer::SyndicateUILayer()
{
	s_instance = this;
	m_tlSynList = NULL;
	
	m_btnViewInfo = NULL;
	m_btnApply = NULL;
	
	m_btnPrePage = NULL;
	m_btnNextPage = NULL;
	m_lbPages = NULL;
	
	m_nCurPage = 0;
	m_nTotalPage = 0;
}

SyndicateUILayer::~SyndicateUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void SyndicateUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	//this->SetBackgroundColor(ccc4(0, 255, 100, 255));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 451, 268), true);
	img->SetFrameRect(CGRectMake(0, 6, 457, 274));
	this->AddChild(img);
	
	m_tlSynList = new NDUITableLayer;
	m_tlSynList->Initialization();
	m_tlSynList->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlSynList->VisibleSectionTitles(false);
	m_tlSynList->SetFrameRect(CGRectMake(0, 14, 450, 201));
	m_tlSynList->VisibleScrollBar(false);
	m_tlSynList->SetCellsInterval(7);
	m_tlSynList->SetCellsRightDistance(0);
	m_tlSynList->SetCellsLeftDistance(0);
	m_tlSynList->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlSynList->SetDataSource(dataSource);
	this->AddChild(m_tlSynList);
	
	m_btnViewInfo = new NDUIButton;
	m_btnViewInfo->Initialization();
	m_btnViewInfo->SetFrameRect(CGRectMake(326, 220, 44, 44));
	m_btnViewInfo->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(3, 3, 38, 38), true);
	m_btnViewInfo->SetImage(pool.AddPicture(NDPath::GetImgPathBattleUI("view_info.png")), false, CGRectZero, true);
	m_btnViewInfo->SetDelegate(this);
	this->AddChild(m_btnViewInfo);
	
	m_btnApply = new NDUIButton;
	m_btnApply->Initialization();
	m_btnApply->SetFrameRect(CGRectMake(376, 220, 44, 44));
	m_btnApply->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(3, 3, 38, 38), true);
	m_btnApply->SetImage(pool.AddPicture(NDPath::GetImgPathNew("icn_apply.png")), false, CGRectZero, true);
	m_btnApply->SetDelegate(this);
	this->AddChild(m_btnApply);
	
	m_lbPages = new NDUILabel;
	m_lbPages->Initialization();
	m_lbPages->SetFrameRect(CGRectMake(150, 236, 80, 30));
	m_lbPages->SetFontColor(ccc4(187, 19, 19, 255));
	this->AddChild(m_lbPages);
	
	m_btnPrePage = new NDUIButton;
	m_btnPrePage->Initialization();
	m_btnPrePage->SetFrameRect(CGRectMake(20, 225, 36, 36));
	m_btnPrePage->SetDelegate(this);
	m_btnPrePage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnPrePage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnPrePage);
	
	m_btnNextPage = new NDUIButton;
	m_btnNextPage->Initialization();
	m_btnNextPage->SetFrameRect(CGRectMake(260, 225, 36, 36));
	m_btnNextPage->SetDelegate(this);
	m_btnNextPage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnNextPage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnNextPage);
	
	// 发起请求
	sendQueryAllSynList(0);
}

void SyndicateUILayer::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	
}

void SyndicateUILayer::OnButtonClick(NDUIButton* button)
{
	SynListCell* synCell = NULL;
	
	NDDataSource* ds = m_tlSynList->GetDataSource();
	NDSection* sec = NULL;
	if (ds) {
		sec = ds->Section(0);
	}
	if (sec) {
		uint focus = sec->GetFocusCellIndex();
		if (focus < sec->Count()) {
			NDUINode* cell = sec->Cell(focus);
			if (cell && cell->IsKindOfClass(RUNTIME_CLASS(SynListCell))) {
				synCell = (SynListCell*)cell;
			}
		}
	}
	
	if (!synCell) {
		return;
	}
	
	if (button == m_btnViewInfo) {
		if (synCell->m_info.synFlag == 0) {
			sendQueryTaxisDetail(synCell->m_info.idSyn);
		} else {
			ShowProgressBar;
			NDTransData bao(_MSG_SYNDICATE);
			bao << Byte(ACT_QUERY_REG_SYN_INFO) << synCell->m_info.idSyn;
			SEND_DATA(bao);
		}

	} else if (button == m_btnApply) {
		if (synCell->m_info.synFlag == 0) {
			sendApply(synCell->m_info.idSyn);
		} else {
			NDTransData bao(_MSG_SYNDICATE);
			bao << Byte(ACT_APPLY_REG_SYN) << synCell->m_info.idSyn;
			SEND_DATA(bao);
		}
	} else if (button == m_btnPrePage) {
		if (m_nCurPage > 0) {
			sendQueryAllSynList(m_nCurPage - 1);
		}
	} else if (button == m_btnNextPage) {
		if (m_nCurPage < m_nTotalPage - 1) {
			sendQueryAllSynList(m_nCurPage + 1);
		}
	}
}

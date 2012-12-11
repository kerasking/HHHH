/*
 *  CUIList.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-5-3.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#if 0
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDUtil.h"
#include "NDTargetEvent.h"
#include "ScriptUI.h"
#include "ScriptGameLogic.h"
#include "UIList.h"
#include "NDPicture.h"
IMPLEMENT_CLASS(CUIListCell, NDUINode)
using namespace NDEngine;

CUIListCell::CUIListCell()
{
	m_lbText		= NULL;
	m_bFocus		= false;
	m_picNormal		= NULL;
	m_picFocus		= NULL;
	m_nIdentify		= 0;
}

CUIListCell::~CUIListCell()
{
	SAFE_DELETE(m_picNormal);
	SAFE_DELETE(m_picFocus);
	SAFE_DELETE_NODE(m_lbText);
}

void CUIListCell::Initialization()
{
	NDUINode::Initialization();
	
	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbText->SetFontSize(12);
	this->AddChild(m_lbText);
}

void CUIListCell::SetText(const char* title)
{
	if (m_lbText)
	{
		m_lbText->SetText(title);
	}
}

std::string CUIListCell::GetText()
{
	if (m_lbText)
	{
		return m_lbText->GetText();
	}
	
	return "";
}

void CUIListCell::SetFontSize(int nFontSize)
{
	if (m_lbText)
	{
		m_lbText->SetFontSize(nFontSize);
	}
}

void CUIListCell::SetFontColor(ccColor4B fontColor)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(fontColor);
	}
}

void CUIListCell::SetBGPicture(NDPicture *picNormal, NDPicture *picFocus)
{
	if (m_picNormal)
	{
		delete m_picNormal;
	}
	
	if (m_picFocus)
	{
		delete m_picFocus;
	}
	
	m_picNormal		= picNormal;
	m_picFocus		= picFocus;
}

void CUIListCell::SetCellId(int nId)
{
	m_nIdentify		= nId;
}

int	CUIListCell::GetCellId()
{
	return m_nIdentify;
}

void CUIListCell::SetFocus(bool bFocus)
{
	m_bFocus		= bFocus;
}

void CUIListCell::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	CCRect scrRect	= this->GetScreenRect();
	
	bool bVisible	= true;
	
	if (0 == int(scrRect.size.width) || 0 == int(scrRect.size.height))
	{
		bVisible	= false;
	}
	
	m_lbText->SetVisible(bVisible);
	
	if (!bVisible)
	{
		return;
	}
	
	NDPicture* picBack	= m_bFocus ? m_picFocus : m_picNormal;
	
	if (picBack)
	{
		picBack->DrawInRect(scrRect);
	}
}

void CUIListCell::SetFrameRect(CCRect rect)
{
	NDUINode::SetFrameRect(rect);
	if (m_lbText)
	{
		m_lbText->SetFrameRect(CCRectMake(0, 0, rect.size.width, rect.size.height));
	}
}

bool CUIListCell::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_lbText)
	{
		return false;
	}
	
	return true;
}

////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIListSection, NDUINode)
CUIListSection::CUIListSection()
{
	m_nFocusIndex			= -1;
	m_nIdentify				= 0;
	m_bExpand				= false;
	m_lbText				= NULL;
	m_picBg					= NULL;
	m_picInner				= NULL;
	m_picStateOpen			= NULL;
	m_picStateClose			= NULL;
}

CUIListSection::~CUIListSection()
{
	SAFE_DELETE(m_picBg);
	SAFE_DELETE(m_picInner);
	SAFE_DELETE(m_picStateOpen);
	SAFE_DELETE(m_picStateClose);
	SAFE_DELETE_NODE(m_lbText);
	
	for(VEC_CELL_IT it = m_vecCell.begin(); it != m_vecCell.end(); it++)
	{
		(*it)->RemoveFromParent(true);
	}
	m_vecCell.clear();
}

void CUIListSection::Initialization()
{
	NDUINode::Initialization();
	
	m_lbText			= new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbText->SetFontSize(12);
	this->AddChild(m_lbText);
}

void CUIListSection::SetAttr(LIST_ATTR_SEC attr)
{
	m_attrSec	= attr;
	
	if (m_lbText)
	{
		if (m_picStateClose)
		{
			CCSize sizeClose = m_picStateClose->GetSize();
			m_lbText->SetFrameRect(CCRectMake(sizeClose.width, 0, 
											  m_attrSec.unSectionWidth - sizeClose.width, m_attrSec.unSectionHeight));
		}
		else
		{
			m_lbText->SetFrameRect(CCRectMake(0, 0, attr.unSectionWidth, attr.unSectionHeight));
		}
	}
}

void CUIListSection::SetText(const char* title)
{
	if (m_lbText)
	{
		m_lbText->SetText(title);
	}
}

std::string CUIListSection::GetText()
{
	if (m_lbText)
	{
		return m_lbText->GetText();
	}
	
	return "";
}

void CUIListSection::SetFontSize(int nFontSize)
{
	if (m_lbText)
	{
		m_lbText->SetFontSize(nFontSize);
	}
}

void CUIListSection::SetFontColor(ccColor4B fontColor)
{
	if (m_lbText)
	{
		m_lbText->SetFontColor(fontColor);
	}
}

void CUIListSection::SetStatePicture(NDPicture *picOpen, NDPicture *picClose)
{
	if (m_picStateOpen)
	{
		delete m_picStateOpen;
	}
	
	if (m_picStateClose)
	{
		delete m_picStateClose;
	}
	
	m_picStateOpen			= picOpen;
	m_picStateClose			= picClose;
	
	if (m_lbText)
	{
		if (m_picStateClose)
		{
			CCSize sizeClose = m_picStateClose->GetSize();
			m_lbText->SetFrameRect(CCRectMake(sizeClose.width, 0, 
			m_attrSec.unSectionWidth - sizeClose.width, m_attrSec.unSectionHeight));
		}
	}
}

void CUIListSection::SetBGPicture(NDPicture *pic)
{
	if (m_picBg)
	{
		delete m_picBg;
	}
	
	m_picBg				= pic;
}

void CUIListSection::SetInnerPicture(NDPicture *pic)
{
	if (m_picInner)
	{
		delete m_picInner;
	}
	
	m_picInner			= pic;
}

void CUIListSection::SetSectionId(int nId)
{
	m_nIdentify			= nId;
}

int CUIListSection::GetSectionId()
{
	return m_nIdentify;
}

int CUIListSection::GetFocusIndex()
{
	return m_nFocusIndex;
}

int CUIListSection::GetFocusId()
{
	if (m_nFocusIndex >= 0 && m_nFocusIndex < int(m_vecCell.size()))
	{
		return m_vecCell[m_nFocusIndex]->GetCellId();
	}
	
	return -1;
}

int CUIListSection::CellCount()
{
	return m_vecCell.size();
}

bool CUIListSection::IsExpand()
{
	return m_bExpand;
}

void CUIListSection::AddCell(CUIListCell* cell)
{
	if (!cell)
	{
		return;
	}
	
	m_vecCell.push_back(cell);
	
	cell->SetFrameRect(CCRectZero);
	
	this->AddChild(cell);
}

void CUIListSection::RemoveCell(int nCellId)
{
	this->RemoveCellByIndex(this->GetIndexById(nCellId));
}

void CUIListSection::RemoveCellByIndex(int nIndex)
{
	if (int(m_vecCell.size()) <= nIndex)
	{
		return;
	}
	
	CUIListCell* cell		= m_vecCell[nIndex];
	m_vecCell.erase(m_vecCell.begin() + nIndex);
	cell->RemoveFromParent(true);
}

void CUIListSection::RemoveAllCell()
{
	VEC_CELL_IT it			= m_vecCell.begin();
	
	for (; it != m_vecCell.end(); it++) 
	{
		(*it)->RemoveFromParent(true);
	}
	
	m_vecCell.clear();
}

int CUIListSection::GetIndexById(int nCellId)
{
	VEC_CELL_IT it			= m_vecCell.begin();
	
	for (int nIndex = 0; it != m_vecCell.end(); it++, nIndex++) 
	{
		if (nCellId == (*it)->GetCellId())
		{
			return nIndex;
		}
	}
	
	return -1;
}

void CUIListSection::SetFocusIndex(int nIndex)
{
	m_nFocusIndex	= nIndex;
	
	VEC_CELL_IT it			= m_vecCell.begin();
	
	for (int i = 0; it != m_vecCell.end(); it++, i++) 
	{
		CUIListCell* cell	= *it;

		cell->SetFocus(i == nIndex);
	}
}

void CUIListSection::expand()
{
	m_bExpand			= true;
	
	int nCellCount	= m_vecCell.size();
	CCRect rect			= this->GetFrameRect();
	rect.size.width		= m_attrSec.unSectionWidth;
	rect.size.height	= m_attrSec.unSectionHeight;
	if (nCellCount > 0)
	{
		 rect.size.height	+= m_attrSec.unContentTInner + 
								m_attrSec.unContentBInner +
								m_attrSec.unCellInner * (nCellCount - 1) +
								m_attrSec.unCellHeight * nCellCount;
	}
	
	this->SetFrameRect(rect);
	
	int nCellStart		= (m_attrSec.unSectionWidth - m_attrSec.unContentLInner - 
						   m_attrSec.unContentRInner - m_attrSec.unCellWidth) / 2;
	rect.origin.x		= m_attrSec.unContentLInner + nCellStart;
	rect.size.width		= m_attrSec.unCellWidth;
	rect.size.height	= m_attrSec.unCellHeight;
	
	for (int i = 0; i < nCellCount; i++) 
	{
		rect.origin.y	= m_attrSec.unSectionHeight +
							m_attrSec.unContentTInner +
							(m_attrSec.unCellInner + m_attrSec.unCellHeight) * i;
		m_vecCell[i]->SetFrameRect(rect);
	}
}

void CUIListSection::shrink()
{
	m_bExpand			= false;
	
	m_nFocusIndex		= -1;
	
	int nCellCount	= m_vecCell.size();
	CCRect rect			= this->GetFrameRect();
	rect.size.width		= m_attrSec.unSectionWidth;
	rect.size.height	= m_attrSec.unSectionHeight;
	
	this->SetFrameRect(rect);
	
	for (int i = 0; i < nCellCount; i++) 
	{
		m_vecCell[i]->SetFrameRect(CCRectZero);
		m_vecCell[i]->SetFocus(false);
	}
}

bool CUIListSection::OnClickInSide(CCPoint posBegin, CCPoint posEnd, bool& bClickOnSec, bool& bClickOnCell, int& nCell)
{
	CCRect scrRect	= this->GetScreenRect();
	
	{
		CCRect rectSec;
		rectSec.origin		= scrRect.origin;
		rectSec.size		= CCSizeMake(m_attrSec.unSectionWidth, m_attrSec.unSectionHeight);
		if (cocos2d::CCRect::CCRectContainsPoint(rectSec, posBegin) && cocos2d::CCRect::CCRectContainsPoint(rectSec, posEnd))
		{
			bClickOnSec		= true;
			return true;
		}
	}
	
	if (this->IsExpand())
	{
		int nIndex = 0;
		for (VEC_CELL_IT it = m_vecCell.begin(); 
			 it != m_vecCell.end(); 
			 it++, nIndex++) 
		{
			CCRect rectCell		= (*it)->GetScreenRect();
			if (cocos2d::CCRect::CCRectContainsPoint(rectCell, posBegin) && cocos2d::CCRect::CCRectContainsPoint(rectCell, posEnd))
			{
				bClickOnCell	= true;
				nCell			= nIndex;
				return true;
			}
		}
	}
	
	return false;
}

void CUIListSection::draw()
{	
	int nCellCount = m_vecCell.size();
	if (!this->IsVisibled())
	{
		return;
	}
	
	CCRect scrRect			= this->GetScreenRect();
	
	//背景
	if (m_picBg)
	{
		CCRect rect;
		rect.origin			= scrRect.origin;
		rect.size			= CCSizeMake(m_attrSec.unSectionWidth, m_attrSec.unSectionHeight);
		m_picBg->DrawInRect(rect);
	}
	
#if 0         
	tangziqin 暂时注释依赖zd ndpicture
	//状态
	NDPicture* picState		= m_bExpand ? m_picStateOpen : m_picStateClose;
	if (picState)
	{
		CCRect rect;
		rect.size			= picState->GetSize();
		rect.origin			= ccpAdd(scrRect.origin, 
									 ccp(5 * NDDirector::DefaultDirector()->GetScaleFactor(),
										 (m_attrSec.unSectionHeight - rect.size.height) / 2) );
		picState->DrawInRect(rect);
	}
#endif 
	
	//分割线

	//int nCellCount	= m_vecCell.size();
	if (m_picInner && m_bExpand && nCellCount > 0)
	{
		CCRect rect;
		rect.size		= m_picInner->GetSize();
		rect.size.width	= m_attrSec.unSectionWidth - 
							m_attrSec.unContentLInner - 
							m_attrSec.unContentRInner;

		for (int i = 0; i < nCellCount; i++) 
		{
			if (i == nCellCount - 1)
			{
				continue;
			}
			
			
			rect.origin.x	= m_attrSec.unContentLInner + scrRect.origin.x;
			rect.origin.y	= scrRect.origin.y +
								m_attrSec.unSectionHeight + 
								m_attrSec.unContentTInner +
								(m_attrSec.unCellInner + m_attrSec.unCellHeight) * (i + 1) -
								m_attrSec.unCellInner +
								(m_attrSec.unCellInner - rect.size.height) / 2;
			m_picInner->DrawInRect(rect);
		}
	}
}

bool CUIListSection::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	if (pNode == m_lbText)
	{
		return false;
	}
	
	for(VEC_CELL_IT it = m_vecCell.begin(); it != m_vecCell.end(); it++)
	{
		if (pNode == *it)
		{
			return false;
		}
	}
	
	return true;
}

////////////////////////////////////////////////
IMPLEMENT_CLASS(CUIList, NDUILayer)

CUIList::CUIList()
{
	m_nInner				= 0;
	m_picScroll				= NULL;
}

CUIList::~CUIList()
{
	for(VEC_SECTION_IT it = m_vecSection.begin(); it != m_vecSection.end(); it++)
	{
		(*it)->RemoveFromParent(true);
	}
	m_vecSection.clear();
}

void CUIList::Initialization()
{
	NDUILayer::Initialization();
	
	m_picScroll = NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("General/texture/texture5.png"));
	
	this->SetDelegate(this);
	
	this->SetScrollEnabled(true);
	
	this->SetMoveOutListener(true);
	
	m_nScrollBarWidth	= m_picScroll->GetSize().width;
}

void CUIList::SetSectionInner(int nInner)
{
	m_nInner	= nInner;
}

void CUIList::SetScrollBarWidth(int nWidth)
{
	m_nScrollBarWidth	= nWidth;
}

int CUIList::GetScrollBarWidth()
{
	return m_nScrollBarWidth;
}

void CUIList::AddSection(CUIListSection* sec)
{
	if (!sec)
	{
		return;
	}
	
	sec->shrink();
	
	this->AddChild(sec);

	m_vecSection.push_back(sec);
	
	CCRect rectNew		= sec->GetFrameRect();
	
	if (m_vecSection.size() > 1)
	{
		CCRect rect		= m_vecSection[m_vecSection.size() - 2]->GetFrameRect();
		rectNew.origin	= ccpAdd(rect.origin, ccp(0, rect.size.height + m_nInner));
		sec->SetFrameRect(rectNew);
	}
	
	CaclAllSecPosition(m_vecSection.size() - 1);
}

void CUIList::RemoveSection(int nId)
{
	this->Remove(this->GetSectionById(nId));
}

void CUIList::RemoveSectionByIndex(int nIndex)
{
	if (int(m_vecSection.size()) <= nIndex)
	{
		return;
	}
	
	this->Remove(m_vecSection[nIndex]);
}

void CUIList::RemoveAllSection()
{
	m_vecSection.clear();
	this->RemoveAllChildren(true);
}

void CUIList::AddCell(int nSectionId, CUIListCell* cell)
{
	CUIListSection* sec	= this->GetSectionById(nSectionId);
	
	if (!sec)
	{
		return;
	}
	
	sec->AddCell(cell);
	
	if (sec->IsExpand())
	{
		int nSectionIndex = this->GetSectionIndex(sec);
		if (1 == sec->CellCount())
		{
			this->ExpandWithIndex(nSectionIndex, 0);
		}
		else
		{
			ExpandSection(nSectionIndex);
		}
		
		CaclAllSecPosition(nSectionIndex);
		
		Adjust();
	}
}

void CUIList::RemoveCell(int nSectionId, int nCellId)
{
	CUIListSection* sec	= this->GetSectionById(nSectionId);
	if (!sec)
	{
		return;
	}
	
	int nSecIndex			= GetSectionIndex(sec);
	int nDelCellIndex		= sec->GetIndexById(nCellId);
	
	RemoveCellByIndex(nSecIndex, nDelCellIndex);
}

void CUIList::RemoveCellByIndex(int nSectionIndex, int nCellIndex)
{
	CUIListSection* sec	= this->GetSectionByIndex(nSectionIndex);
	
	if (!sec)
	{
		return;
	}
	
	int nDelCellIndex		= nCellIndex;
	
	if ( !(nDelCellIndex >= 0 && nDelCellIndex <= sec->CellCount()) )
	{
		return;
	}
	
	bool bResetFocus		= false;
	int nFocusCellIndex		= sec->GetFocusIndex();
	
	if (sec->IsExpand() && nFocusCellIndex >= nDelCellIndex)
	{
		bResetFocus			= true;
		nFocusCellIndex		= nFocusCellIndex - 1;
		nFocusCellIndex		= nFocusCellIndex < 0 ? 0 : nFocusCellIndex;
	}
	
	sec->RemoveCellByIndex(nCellIndex);
	
	if (sec->IsExpand())
	{
		if (bResetFocus)
		{
			// 该操作会传出事件
			this->ExpandWithIndex(nSectionIndex, nFocusCellIndex);
		}
		else
		{
			sec->expand();
			CaclAllSecPosition(nSectionIndex);
			Adjust();
		}
	}
}

void CUIList::RemoveAllCell(int nSectionId)
{
	CUIListSection* sec	= this->GetSectionById(nSectionId);
	
	if (!sec)
	{
		return;
	}
	
	sec->RemoveAllCell();
	
	if (sec->IsExpand())
	{
		this->AllShrink();
	}
}

CUIListSection* CUIList::GetSectionById(int nId)
{
	int nIndex = 0;
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++, nIndex++) 
	{
		CUIListSection* sec	= *it;
		if (nId == sec->GetSectionId())
		{
			return sec;
		}
	}
	
	return NULL;
}

CUIListSection* CUIList::GetSectionByIndex(int nIndex)
{
	if (int(m_vecSection.size()) <= nIndex)
	{
		return NULL;
	}
	
	return m_vecSection[nIndex];
}

void CUIList::Remove(CUIListSection* sec)
{
	if (!sec)
	{
		return;
	}
	
	CUIListSection* section	= NULL;
	VEC_SECTION_IT it = m_vecSection.begin();
	for (; it != m_vecSection.end(); it++) 
	{
		if (*it == sec)
		{
			section = sec;
			break;
		}
	}
	
	if (!section)
	{
		return;
	}
	
	bool bExpand	= section->IsExpand();
	
	m_vecSection.erase(it);
	
	this->RemoveChild(section, true);
	
	if (bExpand)
	{
		ExpandWithIndex(0, 0);
	}
	else
	{
		CaclAllSecPosition(0);
		Adjust();
	}
}

void CUIList::Expand(int nSectionId, int nCellId)
{
	CUIListSection* sec =  GetSectionById(nSectionId);
	if (!sec)
	{
		return;
	}
	
	this->ExpandWithIndex(this->GetSectionIndex(sec), sec->GetIndexById(nCellId));
}

//展开某个section,并设置焦点于某个cell(包括位置更新,并传出事件)
void CUIList::ExpandWithIndex(int nSectionIndex, int nCellIndex)
{
	if (int(m_vecSection.size()) <= nSectionIndex)
	{
		return;
	}
	
	//展开某个section(包括位置更新）
	ExpandSection(nSectionIndex);
	
	Adjust();
	
	m_vecSection[nSectionIndex]->SetFocusIndex(nCellIndex);
	
	this->OnClick(nSectionIndex, nCellIndex);
}

//收缩所有sectionk(包括位置更新,并传出事件)
//void CUIList::AllShrink()
void CUIList::AllShrink()
{
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++) 
	{
		CUIListSection*sec	= *it;
		sec->shrink();
	}
	
	//位置更新
	CaclAllSecPosition(0);
	
	Adjust();
	
	this->OnShrink();
}

//void CUIList::FocusOnCell(int nSectionIndex, int nCellIndex )
void CUIList::FocusOnCell(int nSectionIndex, int nCellIndex)
{
	CUIListSection* sec			= GetSectionByIndex(nSectionIndex);
	
	if (!sec)
	{	
		return;
	}
	
	if (sec->GetFocusIndex() == nCellIndex || nCellIndex > sec->CellCount())
	{
		return;
	}
	
	sec->SetFocusIndex(nCellIndex);
	
	this->OnClick(nSectionIndex, nCellIndex);
}

//展开某个section(包括位置更新）
void CUIList::ExpandSection(int nSectionIndex)
{
	int nSize			= m_vecSection.size();
	
	if (int(nSize) <= nSectionIndex)
	{
		return;
	}
	
	int nIndex = 0;
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++, nIndex++) 
	{
		CUIListSection*sec	= *it;
		if (nIndex == nSectionIndex)
		{
			sec->expand();
		}
		else
		{
			sec->shrink();
		}
	}
	
	CaclAllSecPosition(nSectionIndex);
}

int CUIList::GetSectionIndex(CUIListSection* sec)
{
	int nIndex = 0;
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++, nIndex++) 
	{
		if (*it == sec)
		{
			return nIndex;
		}
	}
	
	return -1;
}

void CUIList::CaclAllSecPosition(int nStartAdjustIndex)
{
	int nSize			= m_vecSection.size();
	
	if (nStartAdjustIndex < 0 || nSize == 0 || nSize <= int(nStartAdjustIndex))
	{
		return;
	}

	CCRect	rect			= m_vecSection[nStartAdjustIndex]->GetFrameRect();
	
	CCRect	rectList		= this->GetFrameRect();
	
	if (rect.origin.y + rect.size.height > rectList.size.height && 
		m_vecSection[nStartAdjustIndex]->IsExpand())
	{
		rect.origin.y		= rectList.size.height - rect.size.height;
		
		rect.origin.y		= rect.origin.y < 1.0f ? 0.0 : rect.origin.y;
	}
	
	m_vecSection[nStartAdjustIndex]->SetFrameRect(rect);
	
	//刷新之前的位置
	if (nStartAdjustIndex > 0)
	{
		CCPoint posStart = rect.origin;
		
		for (int i = nStartAdjustIndex - 1; i >= 0; i--)
		{
			CUIListSection* sec		= m_vecSection[i];
			CCRect rect				= sec->GetFrameRect();
			rect.origin				= ccpSub(posStart, ccp(0, rect.size.height + m_nInner));
			posStart				= rect.origin;
			
			sec->SetFrameRect(rect);
		}
	}
	
	//刷新之后的位置
	if (nStartAdjustIndex < int(nSize - 1))
	{
		CCPoint posStart = ccpAdd(rect.origin, ccp(0, rect.size.height + m_nInner));
		
		for (int i = nStartAdjustIndex + 1; i < nSize; i++) 
		{
			CUIListSection* sec		= m_vecSection[i];
			CCRect rect				= sec->GetFrameRect();
			rect.origin				= posStart;
			posStart				= ccpAdd(posStart, ccp(0, rect.size.height + m_nInner));
			
			sec->SetFrameRect(rect);
		}
	}
}

void CUIList::Move(float fDistance)
{
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++) 
	{
		CUIListSection* sec		= *it;
		CCRect rect				= sec->GetFrameRect();
		rect.origin.y			+= fDistance;
		sec->SetFrameRect(rect);
	}
}

void CUIList::Adjust()
{
	if (m_vecSection.size() > 0)
	{
		//往上移
		CUIListSection* sec		= GetSectionByIndex(0);
		float fStart			= sec->GetFrameRect().origin.y;
		if (fStart > 0)
		{
			Move(-fStart);
			
			return;
		}
		
		//往下移
		sec						= GetSectionByIndex(m_vecSection.size() - 1);
		CCRect rect				= sec->GetFrameRect();
		float fEnd				= rect.origin.y + rect.size.height;
		float fHeight			= this->GetFrameRect().size.height;
		float fDistance			= fHeight - fEnd;
		if (fDistance > 0 && fStart + fDistance < 0)
		{
			Move(fDistance);
		}
		else if (fDistance > 0 && -fStart < fDistance)
		{
			Move(-fStart);
		}
	}
}

bool CUIList::OnLayerMoveOfDistance(NDUILayer* uiLayer, float hDistance, float vDistance)
{
	if (m_vecSection.size() == 0)
	{
		return true;
	}
	
	CCRect rectList				= this->GetFrameRect();

	if (vDistance > 0.0f)
	{
		//往下移
		CUIListSection* sec		= GetSectionByIndex(0);
		CCRect rect				= sec->GetFrameRect();
		int nHeight				= rect.origin.y + vDistance;
		if (nHeight > rectList.size.height * 0.2)
		{
			return true;
		}
	}
	else
	{
		//往上移
		CUIListSection* sec		= GetSectionByIndex(m_vecSection.size() - 1);
		CCRect rect				= sec->GetFrameRect();
		int nHeight				= rect.origin.y + rect.size.height + vDistance;
		if (nHeight < rectList.size.height * 0.8)
		{
			return true;
		}
	}
	
	Move(vDistance);
	
	return true;
}

bool CUIList::DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch)
{
	int nIndex = 0;
	for (VEC_SECTION_IT it = m_vecSection.begin(); 
		 it != m_vecSection.end(); 
		 it++, nIndex++) 
	{
		bool bClickOnSec	= false;
		bool bClickOnCell	= false; 
		int nCell			= 0;
		CUIListSection*sec	= *it;
		
		if (!sec->OnClickInSide(beginTouch, endTouch, bClickOnSec, bClickOnCell, nCell))
		{
			continue;
		}
		
		if (bClickOnSec)
		{
			if (sec->IsExpand())
			{
				this->AllShrink();
			}
			else
			{
				ExpandWithIndex(nIndex, 0);
			}
		}
		
		if (bClickOnCell)
		{
			NDAsssert(sec->IsExpand() && sec->CellCount() > 0 && nCell >= 0);
			if (sec->CellCount() > 0 && nCell >= 0)
			{
				FocusOnCell(nIndex, nCell);
			}
		}
		
		break;
	}
	
	return true;
}

bool CUIList::TouchEnd(NDTouch* touch)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	NDUILayer::TouchEnd(touch);
	
	if (m_touchMoved && m_vecSection.size() > 0)
	{
		Adjust();
	}
	
	return true;
}

void CUIList::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
	
	NDUILayer::draw();
	
	DrawScrollBar();
}

void CUIList::DrawScrollBar()
{
	if (m_picScroll && m_vecSection.size() > 0)
	{
		float fHeight			= 0;
		float fY				= m_vecSection[0]->GetFrameRect().origin.y;
		CCRect rectself			= this->GetFrameRect();
		
		for (VEC_SECTION_IT it = m_vecSection.begin(); 
			 it != m_vecSection.end(); 
			 it++) 
		{
			CUIListSection*sec	= *it;
			fHeight				+= sec->GetFrameRect().size.height;
		}
		
		fHeight					+= (m_vecSection.size() - 1) * m_nInner;
		
		if (fHeight > rectself.size.height)
		{
			CCRect rect			= CCRectZero;
			CCSize sizePic		= m_picScroll->GetSize();
			rect.size.width		= m_nScrollBarWidth;
			rect.size.height	= rectself.size.height / fHeight * rectself.size.height;
			rect.origin			= ccp(rectself.size.width - m_nScrollBarWidth,
									  -fY / fHeight * rectself.size.height);
			rect.origin			= ccpAdd(rect.origin, this->GetScreenRect().origin);
			
			if (m_picScroll->GetSize().height != rect.size.height)
			{
				delete	m_picScroll;
				
				m_picScroll = NDPicturePool::DefaultPool()->AddPicture(
								GetSMImgPath("UI/SM_LINE_SLIDE.png"), 
								rect.size.width, rect.size.height);
			}
			
			m_picScroll->DrawInRect(rect);
		}
	}
}

bool CUIList::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	for(VEC_SECTION_IT it = m_vecSection.begin(); it != m_vecSection.end(); it++)
	{
		if (pNode == *it)
		{
			return false;
		}
	}
	
	return true;
}

void CUIList::OnClick(int nSectionIndex, int nCellIndex)
{
	OnScriptUiEvent(this, TE_TOUCH_LIST_CLICK, GetSectionByIndex(nSectionIndex));
}

void CUIList::OnShrink()
{
	OnScriptUiEvent(this, TE_TOUCH_LIST_SHINK);
}
#endif 
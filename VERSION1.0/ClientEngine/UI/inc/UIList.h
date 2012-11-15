/*
 *  CUIList.h
 *  SMYS
 *
 *  Created by jhzheng on 12-5-3.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#if 0
#ifndef _UI_LIST_H_ZJH_
#define _UI_LIST_H_ZJH_

#include <vector>
#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDPicture.h"

using namespace NDEngine;

struct LIST_ATTR_SEC 
{
	unsigned int		unSectionWidth;
	unsigned int		unSectionHeight;
	unsigned int		unContentLInner;
	unsigned int		unContentRInner;
	unsigned int		unContentTInner;
	unsigned int		unContentBInner;
	unsigned int		unCellInner;
	unsigned int		unCellWidth;
	unsigned int		unCellHeight;
};

////////////////////////////////////////////////
class CUIListSection;
class CUIListCell : public NDUINode
{
	friend class CUIListSection;
	
	DECLARE_CLASS(CUIListCell)
	CUIListCell();
	~CUIListCell();
	
public:
	void Initialization(); override
	
	void SetText(const char* title);
	std::string GetText();
	
	void SetFontSize(int nFontSize);
	
	void SetFontColor(ccColor4B fontColor);		
	
	void SetBGPicture(NDPicture *picNormal, NDPicture *picFocus);
	
	void SetCellId(int nId);
	int	GetCellId();
	
private:
	NDUILabel*					m_lbText;
	bool						m_bFocus;
	NDPicture*					m_picNormal;
	NDPicture*					m_picFocus;
	int							m_nIdentify;
	
private:
	void SetFocus(bool bFocus);
	
public:
	void draw(); override
	void SetFrameRect(CCRect rect); override
	
protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override	
};

////////////////////////////////////////////////
class CUIList;
class CUIListSection : NDUINode
{
	friend class CUIList;
	
	DECLARE_CLASS(CUIListSection)
	CUIListSection();
	~CUIListSection();
	
public:
	void Initialization(); override
	 
	void SetAttr(LIST_ATTR_SEC attr);

	void SetText(const char* title);
	std::string GetText();
	
	void SetFontColor(ccColor4B fontColor);		
	void SetFontSize(int nFontSize);
	
	void SetStatePicture(NDPicture *picOpen, NDPicture *picClose);
	void SetBGPicture(NDPicture *pic);
	void SetInnerPicture(NDPicture *pic);
	
	void SetSectionId(int nId);
	int GetSectionId();
	
	int GetFocusIndex();
	int GetFocusId();
	
	int CellCount();
	
	bool IsExpand();
	
private:
	typedef	std::vector<CUIListCell*>				VEC_CELL;
	typedef VEC_CELL::iterator						VEC_CELL_IT;
	
	VEC_CELL										m_vecCell;
	int												m_nFocusIndex;
	int												m_nIdentify;
	bool											m_bExpand;
	LIST_ATTR_SEC									m_attrSec;
	NDUILabel*										m_lbText;
	NDPicture*										m_picBg;
	NDPicture*										m_picInner;
	NDPicture*										m_picStateOpen;
	NDPicture*										m_picStateClose;
	
private:
	void AddCell(CUIListCell* cell);
	void RemoveCell(int nCellId);
	void RemoveCellByIndex(int nIndex);
	void RemoveAllCell();
	int GetIndexById(int nCellId);
	void SetFocusIndex(int nIndex);
	void expand(); // 需要计算出自己的w,h
	void shrink(); // 需要计算出自己的w,h
	bool OnClickInSide(CCPoint posBegin, CCPoint posEnd, bool& bClickOnSec, bool& bClickOnCell, int& nCell);
	
public:
	void draw(); override
	
protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override	
};

////////////////////////////////////////////////
class CUIList : public NDUILayer , public NDUILayerDelegate
{
	DECLARE_CLASS(CUIList)
	CUIList();
	~CUIList();
	
public:
	void Initialization(); override
public:
	void SetSectionInner(int nInner);
	void SetScrollBarWidth(int nWidth);
	int GetScrollBarWidth();
	
	void AddSection(CUIListSection* sec);
	void RemoveSection(int nId);
	void RemoveSectionByIndex(int nIndex);
	void RemoveAllSection();
	
	void AddCell(int nSectionId, CUIListCell* cell);
	void RemoveCell(int nSectionId, int nCellId);
	void RemoveCellByIndex(int nSectionIndex, int nCellIndex);
	void RemoveAllCell(int nSectionId);

	void Expand(int nSectionId, int nCellId);
	void ExpandWithIndex(int nSectionIndex, int nCellIndex);
	
private:
	typedef	std::vector<CUIListSection*>			VEC_SECTION;
	typedef VEC_SECTION::iterator					VEC_SECTION_IT;
	
	VEC_SECTION										m_vecSection;
	int												m_nInner;
	int												m_nScrollBarWidth;
	NDPicture*										m_picScroll;
	
private:
	CUIListSection* GetSectionById(int nId);
	CUIListSection* GetSectionByIndex(int nIndex);
	int GetSectionIndex(CUIListSection* sec);
	
	void Remove(CUIListSection* sec);
	void AllShrink();
	void FocusOnCell(int nSectionIndex, int nCellIndex);
	void ExpandSection(int nSectionIndex);
	void CaclAllSecPosition(int nStartAdjustIndex);
	void Move(float fDistance);
	void Adjust();	
	
private:
	//事件传出
	void OnClick(int nSectionIndex, int nCellIndex);
	void OnShrink();
	
protected:
	bool OnLayerMoveOfDistance(NDUILayer* uiLayer, float hDistance, float vDistance); override
	bool DispatchTouchEndEvent(CCPoint beginTouch, CCPoint endTouch); override
	bool TouchEnd(NDTouch* touch); override
	void draw(); override
	void DrawScrollBar();

protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override
};

#endif // _UI_LIST_H_ZJH_
#endif 
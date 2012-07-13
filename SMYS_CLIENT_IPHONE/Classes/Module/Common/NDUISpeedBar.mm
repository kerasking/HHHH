/*
 *  NDUISpeedBar.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUISpeedBar.h"

IMPLEMENT_CLASS(NDUISpeedBar, NDUILayer)

NDUISpeedBar::NDUISpeedBar()
{
	m_sizeBtn = CGSizeZero;
	
	m_pointBorder = CGPointZero;
	
	m_uiInterval = 0;

	m_align = SpeedBarAlignmentLeft;
	
	m_uiFuncNum = m_uiTotalPage = m_uiCurPage = 0;
	
	m_btnSetOption = m_btnRefresh = m_btnShrink = NULL;
	
	m_focus = NULL;
	
	m_uiShrinkdis = 0;
	
	m_stateShrink = false;
	
	m_keyAnimation = -1;
	
	m_uiNodeFocus = NULL;
	
	m_picShrink = NULL;
	
	m_picBackGround = NULL;
	
	m_picBackGroundShrink = NULL;
	
	m_imageFocus = NULL;
}

NDUISpeedBar::~NDUISpeedBar()
{
	std::vector<CellInfo> m_vecInfo;
	for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
	{
		if ((*it).info.background) 
			delete (*it).info.background;
		
		if ((*it).info.foreground) 
			delete (*it).info.foreground;
	}
	
	if (m_picShrink) 
	{
		delete m_picShrink;
		m_picShrink = NULL;
	}
	
	if (m_picBackGround) 
	{
		delete m_picBackGround;
		m_picBackGround = NULL;
	}
	
	if (m_picBackGroundShrink) {
		delete m_picBackGroundShrink;
		m_picBackGroundShrink = NULL;
	}
}

void NDUISpeedBar::Initialization
				 (unsigned int funcNum,						// 功能项数
				  unsigned int totalpage					// 总共几页
				  )
{
	NDUILayer::Initialization();
	
	m_uiFuncNum = funcNum;
	
	m_uiTotalPage = totalpage;
	
	for (unsigned int i = 0; i < totalpage; i++) 
		for (unsigned int j = 0; j < funcNum; j++) {
			m_vecInfo.push_back(CellInfo());
			
			CellInfo& cell = m_vecInfo.back();
			
			cell.key = m_idFactory.GetID();
			
			cell.info.index = i*funcNum+j;
			
			cell.bUse = false;
			
			NDUIButton *btn = new NDUIButton;
			
			btn->Initialization();
			
			btn->SetTag(cell.key);
			
			btn->CloseFrame();
			
			btn->SetBackgroundColor(ccc4(255, 255, 255, 0));
			
			int x, y;
			
			x = m_align == SpeedBarAlignmentBottom ? m_pointBorder.x+(m_sizeBtn.width+m_uiInterval)*j : m_pointBorder.x;
			
			y = m_align != SpeedBarAlignmentBottom ? m_pointBorder.y+(m_sizeBtn.height+m_uiInterval)*j : m_pointBorder.y;
			
			btn->SetFrameRect(CGRectMake(x, y, m_sizeBtn.width, m_sizeBtn.height));
			
			btn->SetDelegate(this);
			
			this->AddChild(btn);
		}
	
	m_focus = new ItemFocus;
	m_focus->Initialization();
	m_focus->SetVisible(false);
	this->AddChild(m_focus);
	
	m_imageFocus = new NDUIImage;
	m_imageFocus->Initialization();
	m_imageFocus->SetVisible(false);
	this->AddChild(m_imageFocus, 1);
		
	Layout();
	
	UpdatePage();
}

// intereface begin ..
void NDUISpeedBar::refresh(SpeedBarInfo& info)
{
	unsigned int i = 0;
	
	std::vector<unsigned int> vec_index;
	
	for_vec(info, SpeedBarInfo::iterator)
	{
		SpeedBarCellInfo& info = *it;
		
		unsigned int index = 0;
		
		if (info.index == SpeedBarCellInfo::invalid_index)
			index = i++;
		else
			index = info.index;
			
		vec_index.push_back(index);
		
		if (index < m_vecInfo.size()) 
		{
			CellInfo& cellinfo = m_vecInfo[index];
			
			cellinfo.info = info;
			
			cellinfo.info.index = index;
			
			cellinfo.bUse = cellinfo.info.foreground != NULL;
			
			UpdateCellData(index);
		}
	}
	
	i = 0;
	
	for(size_t i = 0; i < m_vecInfo.size(); i++)
	{
		bool bfind = false;
		
		for_vec(vec_index, std::vector<unsigned int>::iterator)
		{
			if(i == *it) bfind = true;
		}
		
		if (!bfind) ClearCellData(i);
	}
	unsigned int resPage = 0;
	if (FindPage(m_uiCurPage%m_uiTotalPage, resPage)) 
	{
		m_uiCurPage = resPage;
		
		UpdatePage();
	}
}

void NDUISpeedBar::refresh(SpeedBarCellInfo& info)
{
	if (info.index == SpeedBarCellInfo::invalid_index) return;
	
	if ((unsigned int)(info.index) < m_vecInfo.size()) 
	{
		CellInfo& cellinfo = m_vecInfo[info.index];
		
		cellinfo.info = info;
		
		cellinfo.bUse = true;
		
		UpdateCellData(info.index);
	}
}

void NDUISpeedBar::defocus()
{
	this->SetFocus(NULL);
	
	m_uiNodeFocus = NULL;
}

void NDUISpeedBar::SetGray(bool bGray)
{
	for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
	{
		(*it).info.grayEnable(bGray);
	}
	
	this->defocus();
}

void NDUISpeedBar::SetGray(bool bGray, unsigned int index)
{
	for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
	{
		if ((unsigned int)((*it).info.index) == index)
		{
			(*it).info.grayEnable(bGray);
			
			NDUIButton *btn = (NDUIButton *)(this->GetChild((*it).key));
			
			if (btn == m_uiNodeFocus) 
			{
				this->defocus();
			}
			
			break;
		}
	}
}

void NDUISpeedBar::SetFoucusByIndex(unsigned int index)
{
	for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
	{
		if ((unsigned int)((*it).info.index) == index && !(*it).info.isGray())
		{
			NDUIButton *btn = (NDUIButton *)(this->GetChild((*it).key));
			
			if (btn) 
			{
				this->SetFocus(btn);
				
				m_uiNodeFocus = btn;
				
				unsigned int resPage = 0;
				
				if (FindPage(index / m_uiFuncNum, resPage)) 
					m_uiCurPage = resPage;
				else
					m_uiCurPage = 0;
					
				UpdatePage();
			}
			
			return;
		}
	}
}

// interface end ..

bool NDUISpeedBar::TouchBegin(NDTouch* touch)
{
	if (CGRectContainsPoint(this->GetScreenRect(), touch->GetLocation()) && this->IsVisibled() && this->EventEnabled())
	{
		for (int i = this->GetChildren().size() - 1; i >= 0; i--) 
		{
			NDUINode* uiNode = (NDUINode*)this->GetChildren().at(i);
			CGRect nodeFrame = uiNode->GetScreenRect();
			
			if (CGRectContainsPoint(nodeFrame, touch->GetLocation())) 
			{
				return NDUILayer::TouchBegin(touch);
			}
		}
	}
	
	return false;
}

void NDUISpeedBar::OnButtonClick(NDUIButton* button)
{
	NDUISpeedBarDelegate* delegate = dynamic_cast<NDUISpeedBarDelegate*> (this->GetDelegate());
	
	if (button == m_btnSetOption) 
	{
		if (delegate) 
			delegate->OnNDUISpeedBarSet(this);
		
		this->SetFocus(m_uiNodeFocus);
	}
	else if (button == m_btnRefresh)
	{
		unsigned int resPage = 0;
		if (FindPage((++m_uiCurPage)%m_uiTotalPage, resPage)) 
		{
			m_uiCurPage = resPage;
			
			UpdatePage();
		}
		else
		{
			m_uiCurPage--;
		}
		
		this->SetFocus(m_uiNodeFocus);
		
		if (delegate) 
			delegate->OnRefreshFinish(this, m_uiCurPage);
	}
	else if (button == m_btnShrink)
	{
		if (delegate)
			delegate->OnNDUISpeedBarShrinkClick(this, m_stateShrink);
		
		DealShrink(0.3f);
		
		this->SetFocus(m_uiNodeFocus);
	}
	else
	{
		unsigned int tag = button->GetTag();
		
		for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
		{
			CellInfo& cellinfo = *it;
			
			if (cellinfo.key == tag && (cellinfo.info.background != NULL || cellinfo.info.foreground != NULL ))
			{
				if (delegate && !cellinfo.info.isGray())
					delegate->OnNDUISpeedBarEvent(this, cellinfo.info, m_uiNodeFocus == button);
				
				if (cellinfo.info.isGray())
					this->SetFocus(m_uiNodeFocus);
				else
					m_uiNodeFocus = button;
					
				break;
			}
		}
	}
}

bool NDUISpeedBar::OnButtonLongClick(NDUIButton* button)
{
	NDUISpeedBarDelegate* delegate = dynamic_cast<NDUISpeedBarDelegate*> (this->GetDelegate());
	
	if (button == m_btnSetOption) 
	{
		if (delegate) 
			delegate->OnNDUISpeedBarSet(this);
			
		this->SetFocus(m_uiNodeFocus);
		
		return true;
	}
	else if (button == m_btnRefresh)
	{
	}
	else if (button == m_btnShrink)
	{
	}
	else
	{
		unsigned int tag = button->GetTag();
		
		for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
		{
			CellInfo& cellinfo = *it;
			
			if (cellinfo.key == tag)
			{
				if (delegate)
					delegate->OnNDUISpeedBarEventLongTouch(this, cellinfo.info);
				
				this->SetFocus(m_uiNodeFocus);
				
				return true;
			}
		}
	}
	
	this->SetFocus(m_uiNodeFocus);
	
	return false;
}

void NDUISpeedBar::draw()
{
	if (!this->IsVisibled()) return;
	
	DrawBackground();
	
	if (m_focus && this->GetFocus() && this->GetFocus()->IsVisibled())
		m_focus->SetFrameRect(this->GetFocus()->GetFrameRect());
	if (m_focus) 
		m_focus->SetVisible(this->GetFocus() != NULL && this->GetFocus()->IsVisibled());
		
	if (m_imageFocus && this->GetFocus() && this->GetFocus()->IsVisibled())
	{
		CGRect rect = this->GetFocus()->GetFrameRect();
		rect.size = m_imageFocus->GetFrameRect().size;
		m_imageFocus->SetFrameRect(rect);
	}
	if (m_imageFocus) 
		m_imageFocus->SetVisible(this->GetFocus() != NULL && this->GetFocus()->IsVisibled());
		
	OnDrawAjustUI();
}

void NDUISpeedBar:: SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	
	if (visible) UpdatePage();
}

void NDUISpeedBar::Layout()
{
}

void NDUISpeedBar::DrawBackground()
{
}

void NDUISpeedBar::SetShrink(bool bShrink, bool animation/*=true*/)
{
	if (m_stateShrink == bShrink) {
		return;
	}
	m_stateShrink = !bShrink;
	
	DealShrink(animation ?  0.3f : 0.0f);
}

void NDUISpeedBar::ReverseShrink()
{
	DealShrink(0.3f);
}

void NDUISpeedBar::SetShrinkDis(unsigned int dis)
{
	m_uiShrinkdis = dis;
}

void NDUISpeedBar::SetFocusImage(const char* filename)
{
	if (!filename) return;
	
	if (m_imageFocus) 
	{
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(filename);
		m_imageFocus->SetPicture(pic, true);
		m_imageFocus->SetFrameRect(CGRectMake(0, 0, pic->GetSize().width, pic->GetSize().height));
	}
		
	if (m_focus) 
	{
		m_focus->RemoveFromParent(true);
		
		m_focus = NULL;
	}
}

void NDUISpeedBar::ClearCellData(unsigned cellIndex)
{
	if (cellIndex >= m_vecInfo.size()) return;
	
	CellInfo& cellinfo = m_vecInfo[cellIndex];
	
	SpeedBarCellInfo tmpInfo;
	
	tmpInfo.index = cellinfo.info.index;
	
	cellinfo.bUse = false;
	
	cellinfo.info = tmpInfo;
	
	NDUIButton *btn = (NDUIButton *)(this->GetChild(cellinfo.key));
	
	if (!btn) return;
	
	btn->SetImage(tmpInfo.foreground);
	
	btn->SetBackgroundPicture(tmpInfo.background);
}

void NDUISpeedBar::UpdateCellData(unsigned int cellIndex)
{
	if (cellIndex < m_vecInfo.size()) 
	{
		CellInfo& cellinfo = m_vecInfo[cellIndex];
		
		SpeedBarCellInfo& info = cellinfo.info;
		
		NDUIButton *btn = (NDUIButton *)(this->GetChild(cellinfo.key));
		
		if (!btn) return;
		
		if (info.foreground) 
		{
			CGSize size = info.foreground->GetSize();
			
			btn->SetImage(info.foreground, true, CGRectMake((m_sizeBtn.width-size.width)/2, (m_sizeBtn.height-size.height)/2, size.width, size.height));
		}
		else
		{
			btn->SetImage(NULL);
		}
		
		btn->SetBackgroundPicture(info.background);
	}
}

bool NDUISpeedBar::FindPage(unsigned int curPage, unsigned int& resPage, bool judgeGray/*=false*/, bool judgeGaryReturnFront/*=true*/)
{
	if (curPage > m_uiTotalPage) return false;
	
	size_t size = m_vecInfo.size();
	
	unsigned int pages = size / m_uiFuncNum + (size % m_uiFuncNum != 0 ? 1 : 0);
	
	std::vector<unsigned int> vec_use;
	
	for (unsigned int i = 0; i < pages; i++) 
	{
		unsigned int start = i * m_uiFuncNum;
		
		unsigned int end = (i+1)*m_uiFuncNum;
		
		if (end > size) end = size;
		
		for (unsigned int j = start; j < end; j++) 
		{
			if (j >= size) continue;
			
			if (m_vecInfo[j].bUse && (!judgeGray || (judgeGray && !m_vecInfo[j].info.isGray()))) 
			{
				vec_use.push_back(i);
				break;
			}
		}
	}
	
	if (vec_use.empty()) return false;
	
	unsigned int positiveDis = m_uiFuncNum;
	
	unsigned int negatvieDis = 0;
	
	for_vec(vec_use, std::vector<unsigned int>::iterator)
	{
		unsigned int pageIndex = *it;
		
		if (pageIndex >= curPage) 
		{
			if (pageIndex-curPage < positiveDis) 
			{
				resPage = pageIndex;
				positiveDis = pageIndex-curPage;
			}
		}
		else
		{
			if (curPage-pageIndex > negatvieDis) 
			{
				resPage = pageIndex;
				
				negatvieDis = curPage-pageIndex;
			}
		}
	}
	
	if (judgeGray && curPage != resPage && judgeGaryReturnFront) 
	{
		resPage = 0;
	}
	
	return true;
}

void NDUISpeedBar::UpdatePage()
{
	for_vec(m_vecInfo, std::vector<CellInfo>::iterator)
	{
		CellInfo& cellinfo = *it;
		
		SpeedBarCellInfo& info = cellinfo.info;
		
		NDUIButton *btn = (NDUIButton *)(this->GetChild(cellinfo.key));
		
		if (!btn) continue;
		
		if (info.index/m_uiFuncNum == m_uiCurPage && cellinfo.bUse) 
		{
			btn->SetVisible(true);
		}
		else
		{
			btn->SetVisible(false);
		}
	}
}

void NDUISpeedBar::DealShrink(float time)
{
	if (m_keyAnimation == (unsigned int)-1 ) 
	{
		CGRect frame = this->GetFrameRect();
		CGSize size = CGSizeZero;
		if (m_align == SpeedBarAlignmentBottom)
			size.height = m_uiShrinkdis == 0 ? frame.size.height : m_uiShrinkdis;
		else
			size.width = m_uiShrinkdis == 0 ? frame.size.width : m_uiShrinkdis;
		
		m_keyAnimation = m_curUiAnimation.GetAnimationKey(this, size);
	}
	
	UIAnimationMove move = UIAnimationMoveNone;
	
	switch (m_align) {
		case SpeedBarAlignmentBottom:
			move = m_stateShrink ? UIAnimationMoveTopToBottomReverse : UIAnimationMoveTopToBottom;
			break;
		case SpeedBarAlignmentLeft:
			move = m_stateShrink ? UIAnimationMoveRightToLeftReverse : UIAnimationMoveRightToLeft;
			break;
		case SpeedBarAlignmentRight:
			move = m_stateShrink ? UIAnimationMoveLeftToRightReverse : UIAnimationMoveLeftToRight;
			break;
		default:
			break;
	}
	
	if (move != UIAnimationMoveNone)
	{
		m_curUiAnimation.AddAnimation(m_keyAnimation, move, time);
		m_curUiAnimation.playerAnimation(m_keyAnimation);
		
		m_stateShrink = !m_stateShrink;
		
		//OnShrink(m_stateShrink);
	}
}
/*
 *  GameItemBag.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameItemBag.h"
#include "ImageNumber.h"
#include "define.h"
#include "NDUtility.h"
#include "ItemImage.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDUISynLayer.h"
#include "NDMsgDefine.h"
#include <sstream>

const float poly[4*2] = 
{
	0,0,
	ITEM_BAG_W-4, 0,
	0, ITEM_BAG_H-4,
	ITEM_BAG_W-4, ITEM_BAG_H-4
};

const float line[26] =
{
	1,(4+2),  //point
	6,(4+2),
	6,1,
	ITEM_BAG_W-6-1,1,
	ITEM_BAG_W-6-1,4+2,
	ITEM_BAG_W-1-1,4+2,
	ITEM_BAG_W-1-1,ITEM_BAG_H-(4+2)-1,
	ITEM_BAG_W-6-1,ITEM_BAG_H-(4+2)-1,
	ITEM_BAG_W-6-1,ITEM_BAG_H-1-1,
	6,ITEM_BAG_H-1-1,
	6,ITEM_BAG_H-6-1,
	1,ITEM_BAG_H-6-1,
	1,6,
};

IMPLEMENT_CLASS(GameItemBag, NDUILayer)

int GameItemBag::m_iTotalPage = 0;

GameItemBag::GameItemBag()
{
	m_backlayer = NULL;
	memset(m_arrCellInfo, 0, sizeof(CellInfo*)*MAX_CELL_PER_PAGE*MAX_PAGE_COUNT);
	m_lbTitle = NULL;
	memset(m_btnPages, 0, sizeof(NDUIButton*)*MAX_PAGE_COUNT);
	memset(m_picPages, 0, sizeof(NDPicture*)*MAX_PAGE_COUNT);
	m_iCurpage = 0;
	m_iFocusIndex = 0;
	m_iTotalPage = 0; 
	memset(m_imagePages, 0, sizeof(NDUIImage*)*MAX_PAGE_COUNT);
	m_itemfocus = NULL;
}

GameItemBag::~GameItemBag()
{
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		for (int j = 0; j < MAX_CELL_PER_PAGE; j++)
		{
			CellInfo* cellinfo = m_arrCellInfo[i*MAX_CELL_PER_PAGE+j];
			if (cellinfo)
			{
				SAFE_DELETE(cellinfo->m_picBack);
				SAFE_DELETE(cellinfo->m_picItem);
				m_arrCellInfo[i*MAX_CELL_PER_PAGE+j] = NULL;
			}
		}
	}
	
	//for (int i = 0; i < MAX_PAGE_COUNT; i++)
//	{
//		SAFE_DELETE(m_picPages[i]);
//	}
	
	SAFE_DELETE(m_itemfocus);
}

void GameItemBag::Initialization(vector<Item*>& itemlist)
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(BKCOLOR4);
	
	m_backlayer = new NDUILayer;
	m_backlayer->Initialization();
	m_backlayer->SetBackgroundColor(ccc4(99, 116, 98, 255));
	m_backlayer->SetFrameRect(CGRectMake(4, 4, ITEM_BAG_W-8, 25));
	this->AddChild(m_backlayer);
	
	m_lbTitle = new NDUILabel; 
	m_lbTitle->Initialization(); 
	m_lbTitle->SetText(""); 
	m_lbTitle->SetFontSize(13); 
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbTitle->SetFrameRect(CGRectMake(4, 4, ITEM_BAG_W-8, 25));
	m_lbTitle->SetFontColor(ccc4(253, 253, 253, 255));//ccc4(16, 56, 66,255));
	m_backlayer->AddChild(m_lbTitle);
	
	int iPageX = 4;
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		m_picPages[i] = PictureNumber::SharedInstance()->TitleGoldNumber(i+1);
		m_btnPages[i] = new NDUIButton;
		m_btnPages[i]->Initialization();
		m_btnPages[i]->SetDelegate(this);
		int w = 0;
		if (i == MAX_PAGE_COUNT-1)
		{
			w = ITEM_BAG_W-10-((ITEM_BAG_W-10)/4*3);
		}
		else
		{
			w = (ITEM_BAG_W-10)/4;
		}

		m_btnPages[i]->SetFrameRect(CGRectMake(iPageX+i*((ITEM_BAG_W-10)/4), ITEM_BAG_H-25-6, w, 25));
		//m_btnPages[i]->SetFocusColor(ccc4(20, 59, 64, 255));
		m_btnPages[i]->SetBackgroundColor(ccc4(56, 110, 110, 255));
		m_btnPages[i]->CloseFrame();
		this->AddChild(m_btnPages[i]);
	}
	
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		m_imagePages[i] = new NDUIImage;
		m_imagePages[i]->Initialization();
		m_imagePages[i]->SetPicture(m_picPages[i]);
		CGSize size = m_picPages[i]->GetSize();
		CGRect rect = m_btnPages[i]->GetFrameRect();
		m_imagePages[i]->SetFrameRect(CGRectMake( rect.origin.x+(rect.size.width-size.width)/2,
												 rect.origin.y+(rect.size.height-size.height)/2, 
												 size.width, size.height));
		this->AddChild(m_imagePages[i]);
	}
	
	//this->SetFocus(m_btnPages[0]);
	
	// 设置数据
	vector<Item*>::iterator it = itemlist.begin();
	int iIndex = 0;
	for (; it != itemlist.end(); it++, iIndex++)
	{
		if (iIndex >= MAX_CELL_PER_PAGE*MAX_PAGE_COUNT)
		{
			break;
		}
		
		if (iIndex == 0)
		{
			m_lbTitle->SetText((*it)->getItemDesc().c_str());
		}
		
		InitCellItem(iIndex, *it, true);
	}
	
	// 初始化第一页
	if (iIndex < MAX_CELL_PER_PAGE)
	{
		InitCellItem(iIndex, NULL, true);
	}
	
	ShowPage(0);
	
	for (int i=0; i<4; i++)
	{
		m_polygonCorner[i] = new NDUIPolygon;
		m_polygonCorner[i]->Initialization();
		m_polygonCorner[i]->SetLineWidth(1);
		m_polygonCorner[i]->SetColor(ccc3(46, 67, 50));
		m_polygonCorner[i]->SetFrameRect(CGRectMake(poly[i*2], poly[i*2+1], 4, 4));
		this->AddChild(m_polygonCorner[i]);
	}
	
	for (int i=0; i<12; i++)
	{
		m_line[i] =  new NDUILine;
		m_line[i]->Initialization();
		m_line[i]->SetWidth(1);
		m_line[i]->SetColor(ccc3(46, 67, 50));
		m_line[i]->SetFromPoint(CGPointMake(line[i*2], line[i*2+1]));
		m_line[i]->SetToPoint(CGPointMake(line[i*2+2], line[i*2+1+2]));
		m_line[i]->SetFrameRect(CGRectMake(1, 1, 1, 1));
		this->AddChild(m_line[i]);
	}
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	this->AddChild(m_itemfocus,1);
	if (m_arrCellInfo[0] && m_arrCellInfo[0]->button)
	{
		m_itemfocus->SetFrameRect(m_arrCellInfo[0]->button->GetFrameRect());
	}
	
	//GameItemBagDelegate* delegate = dynamic_cast<GameItemBagDelegate*> (this->GetDelegate());
//	bool bDelegateRet = true;
//	if (delegate && m_arrCellInfo[0]->item) 
//	{
//		bDelegateRet = delegate->OnClickCell(this, m_iCurpage, iIndex, m_arrCellInfo[iIndex]->item, false );
//	}
	
}
void GameItemBag::draw()
{
	NDUILayer::draw();
	//if (m_iFocusIndex != -1)
//	{
//		m_itemfocus->Update();
//	}
}

void GameItemBag::OnButtonClick(NDUIButton* button)
{
	if (m_iTotalPage < 1)
	{
		return;
	}
	
	for (int i=0; i < MAX_PAGE_COUNT; i++)
	{
		if ( button == m_btnPages[i])
		{
			if ( i <= m_iTotalPage-1 )
			{
				//切换页
				ShowPage( i+1 > m_iTotalPage ? 0 : i);
				
				int iStartIndex = i == 0 ? 0 : (i)*MAX_CELL_PER_PAGE;
				int iEndIndex = (i+1)*MAX_CELL_PER_PAGE;
				if (m_iFocusIndex >= iStartIndex && m_iFocusIndex < iEndIndex)
				{}
				else
				{
					m_iFocusIndex = -1;
					m_itemfocus->SetFrameRect(CGRectZero);
					m_lbTitle->SetText("");
				}
				
				m_iCurpage = i;
			}

			GameItemBagDelegate* delegate = dynamic_cast<GameItemBagDelegate*> (this->GetDelegate());
			if (delegate) 
			{
				delegate->OnClickPage(this, i);
			}
			
			if (i >= m_iTotalPage)
			{
				stringstream ss; ss << NDCommonCString("KaiTongBag") << (i+1) << NDCommonCString("NeedSpend");
				if (i == 1) {
					ss << 200;
				} else if (i == 2) {
					ss << 500;
				} else if (i == 3) {
					ss << 1000;
				}
				
				ss << NDCommonCString("ge") << NDCommonCString("emoney");
				
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetDelegate(this);
				dlg->Show("", ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
			
			return;
		}
		
		
	}
	
	if (m_iCurpage >= MAX_PAGE_COUNT)
	{
		NDLog(@"物品包当前页出错!!!");
		return;
	}
	
	int iIndex = m_iCurpage*MAX_CELL_PER_PAGE;
	
	for (; iIndex < (m_iCurpage+1)*MAX_CELL_PER_PAGE; iIndex++)
	{
		if (m_arrCellInfo[iIndex] && m_arrCellInfo[iIndex]->button && button == m_arrCellInfo[iIndex]->button)
		{
			GameItemBagDelegate* delegate = dynamic_cast<GameItemBagDelegate*> (this->GetDelegate());
			bool bDelegateRet = true;
			bool bFocus = m_iFocusIndex == iIndex;
			if (delegate) 
			{
				bDelegateRet = delegate->OnClickCell(this, m_iCurpage, iIndex, m_arrCellInfo[iIndex]->item, bFocus );
			}
				
			if (m_arrCellInfo[iIndex]->item)
			{
				if (( !delegate || !bDelegateRet ))
				{
					m_lbTitle->SetText(m_arrCellInfo[iIndex]->item->getItemDesc().c_str());
				}
			}
			else 
			{
				m_lbTitle->SetText("");
			}
			
			if (m_iFocusIndex != iIndex)
			{
				m_itemfocus->SetFrameRect(m_arrCellInfo[iIndex]->button->GetFrameRect());
			}
			
			m_iFocusIndex = iIndex;
			
			
			if (delegate) 
			{
				delegate->AfterClickCell(this, m_iCurpage, iIndex, m_arrCellInfo[iIndex]->item, bFocus );
			}
			
			return;
		}
	}
	
}

void GameItemBag::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	// 开通背包
	ShowProgressBar;
	NDTransData bao(_MSG_LIMIT);
	bao << (unsigned char)(1);
	SEND_DATA(bao);
	dialog->Close();
}

void GameItemBag::UpdateItemBag(vector<Item*>& itemlist)
{
	if (m_iTotalPage <= 0)
	{
		return;
	}
	
	int iSize = int(itemlist.size());
	
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		for (int j = 0; j < MAX_CELL_PER_PAGE; j++)
		{
			int iIndex = i*MAX_CELL_PER_PAGE+j;
			if (iIndex < iSize)
			{
				InitCellItem(iIndex, itemlist[iIndex], iIndex%MAX_CELL_PER_PAGE == m_iCurpage);
			}
			else
			{
				if (iIndex >= m_iTotalPage*MAX_CELL_PER_PAGE)
				{
					break;
				}
				InitCellItem(iIndex, NULL, iIndex%MAX_CELL_PER_PAGE == m_iCurpage);
			}
		}
	}
	
	ShowPage(m_iCurpage+1 > m_iTotalPage ? 0 : m_iCurpage);
}

void GameItemBag::UpdateItemBag(vector<Item*>& itemlist, vector<int> filter)
{
	vector<Item*> vec_item;
	vector<Item*>::iterator it = itemlist.begin();
	for (; it != itemlist.end(); it++) 
	{
		vector<int> vec_type = Item::getItemType((*it)->iItemType);
		int typesize = vec_type.size();
		int filtersize = filter.size();
		for (int i = 0; i < filtersize; i++) 
		{
			if (i > (typesize-1) || filter[i] != vec_type[i]) 
			{
				break;
			}
			
			if (i == filtersize-1) 
			{
				vec_item.push_back(*it);
			}
		}
	}
	
	UpdateItemBag(vec_item);
}

bool GameItemBag::AddItem(Item* item)
{
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		for (int j = 0; j < MAX_CELL_PER_PAGE; j++)
		{
			int iIndex = i*MAX_CELL_PER_PAGE+j;
			
			if (iIndex >= m_iTotalPage*MAX_CELL_PER_PAGE)
			{
				break;
			}
			
			if (!m_arrCellInfo[iIndex] || m_arrCellInfo[iIndex]->item == NULL)
			{
				InitCellItem(iIndex, item, iIndex/MAX_CELL_PER_PAGE == m_iCurpage);
				return true;
			}
		}
	}
	return false;
}

bool GameItemBag::DelItem(int iItemID)
{
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		for (int j = 0; j < MAX_CELL_PER_PAGE; j++)
		{
			int iIndex = i*MAX_CELL_PER_PAGE+j;
			
			if (iIndex >= m_iTotalPage*MAX_CELL_PER_PAGE)
			{
				break;
			}
			
			if (m_arrCellInfo[iIndex])
			{
				NDUIButton*& btn	= m_arrCellInfo[iIndex]->button;
				NDPicture*& picBack = m_arrCellInfo[iIndex]->m_picBack;
				NDPicture*& picItem = m_arrCellInfo[iIndex]->m_picItem;
				NDUIImage*& imgBack = m_arrCellInfo[iIndex]->m_imgBack;
				Item*& item = m_arrCellInfo[iIndex]->item;
	
				if (item && item->iID == iItemID && btn)
				{
					if (picBack) 
					{
						btn->SetImage(picBack);
					}
					
					btn->RemoveChild(imgBack, true);
					
					SAFE_DELETE(picItem);
					item = NULL;
					
					if (m_iFocusIndex == iIndex)
					{
						m_lbTitle->SetText("");
					}
					return true;
				}
			}
		}
	}
		
	return false;
}

bool GameItemBag::AddItemByIndex(int iCellIndex, Item* item)
{
	if (!m_arrCellInfo[iCellIndex])
	{
		InitCellItem(iCellIndex, item, iCellIndex%MAX_CELL_PER_PAGE == m_iCurpage);
		return true;
	}
	return false;
}

bool GameItemBag::DelItemByIndex(int iCellIndex)
{
	if (m_arrCellInfo[iCellIndex])
	{
		NDUIButton*& btn	= m_arrCellInfo[iCellIndex]->button;
		NDPicture*& picBack = m_arrCellInfo[iCellIndex]->m_picBack;
		NDPicture*& picItem = m_arrCellInfo[iCellIndex]->m_picItem;
		NDUIImage*& imgBack = m_arrCellInfo[iCellIndex]->m_imgBack;
		Item*& item = m_arrCellInfo[iCellIndex]->item;
		if (item && btn)
		{
			if (picBack) 
			{
				btn->SetImage(picBack);
			}
			
			btn->RemoveChild(imgBack, true);
			
			SAFE_DELETE(picItem);
			item = NULL;
			return true;
		}
	}
	return false;
}

bool GameItemBag::IsFocus()
{
	return m_iFocusIndex != -1;
}

void GameItemBag::DeFocus()
{
	m_iFocusIndex = -1;
	m_itemfocus->SetFrameRect(CGRectZero);
}

void GameItemBag::SetTitle(string title)
{
	if (m_lbTitle)
	{
		m_lbTitle->SetText(title.c_str());
	}
}

void GameItemBag::SetTitleColor(ccColor4B color)
{
	if (m_lbTitle)
	{
		m_lbTitle->SetFontColor(color);
	}
}

Item* GameItemBag::GetFocusItem()
{
	if (m_iFocusIndex > -1 && m_arrCellInfo[m_iFocusIndex])
	{
		return m_arrCellInfo[m_iFocusIndex]->item;
	}
	
	return NULL;
}

void GameItemBag::UpdateTitle()
{
	if (m_iFocusIndex != -1 && m_arrCellInfo[m_iFocusIndex] && m_arrCellInfo[m_iFocusIndex]->item)
	{
		GameItemBagDelegate* delegate = dynamic_cast<GameItemBagDelegate*> (this->GetDelegate());
		bool bDelegateRet = false;
		if (delegate) 
		{
			bDelegateRet = delegate->OnClickCell(this, m_iCurpage, m_iFocusIndex, m_arrCellInfo[m_iFocusIndex]->item, false );
		}
		
		if (m_arrCellInfo[m_iFocusIndex]->item)
		{
			if (( !delegate || !bDelegateRet ))
			{
				m_lbTitle->SetText(m_arrCellInfo[m_iFocusIndex]->item->getItemDesc().c_str());
			}
		}
	}
}

Item* GameItemBag::GetItem(int iPage, int iIndex)
{
	if (iPage >= m_iTotalPage || !(iIndex >= 0 && iIndex < MAX_CELL_PER_PAGE)) 
	{
		return NULL;
	}
	
	if (m_arrCellInfo[iPage*MAX_CELL_PER_PAGE+iIndex]) 
	{
		return m_arrCellInfo[iPage*MAX_CELL_PER_PAGE+iIndex]->item;
	}
	
	return NULL;
}

void GameItemBag::ShowPage(int iPage)
{
	if (iPage >= MAX_PAGE_COUNT && iPage+1 <= m_iTotalPage)
	{
		return;
	}
	
	int iIndex = iPage*MAX_CELL_PER_PAGE;

	for (; iIndex < (iPage+1)*MAX_CELL_PER_PAGE; iIndex++)
	{
		if (!m_arrCellInfo[iIndex])
		{
			InitCellItem(iIndex, NULL, true);
		}
		
		if (m_arrCellInfo[iIndex] && m_arrCellInfo[iIndex]->button && m_arrCellInfo[iIndex]->m_imgBack)
		{
			m_arrCellInfo[iIndex]->button->SetVisible(true);
			m_arrCellInfo[iIndex]->m_imgBack->SetVisible(true);
		}
	}
		
	HidePage(iPage);
	
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		if (!m_btnPages[i]) 
		{
			continue;
		}
		if (i == iPage) 
		{
			m_btnPages[i]->SetBackgroundColor(ccc4(20, 59, 64, 255));
		}
		else 
		{
			m_btnPages[i]->SetBackgroundColor(ccc4(56, 110, 110, 255));
		}

	}
}

void GameItemBag::HidePage(int iExceptPage)
{
	if (iExceptPage >= MAX_PAGE_COUNT || iExceptPage < 0)
	{
		return;
	}
	
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		if (i == iExceptPage)
		{
			continue;
		}
		
		int iIndex = i*MAX_CELL_PER_PAGE;
		
		for (; iIndex < (i+1)*MAX_CELL_PER_PAGE; iIndex++)
		{
			if (m_arrCellInfo[iIndex] && m_arrCellInfo[iIndex]->button && m_arrCellInfo[iIndex]->m_imgBack)
			{
				m_arrCellInfo[iIndex]->button->SetVisible(false);
				m_arrCellInfo[iIndex]->m_imgBack->SetVisible(false);
			}
		}
	}
}

void GameItemBag::InitCellItem(int iIndex, Item* item, bool bShow)
{
	if (iIndex<0 || iIndex>=MAX_CELL_PER_PAGE*MAX_PAGE_COUNT)
	{
		NDLog(@"初始化物品格子参数有误!!!");
		return;
	}
	if (!m_arrCellInfo[iIndex])
	{
		m_arrCellInfo[iIndex] = new CellInfo;
	}
	
	if (!item)
	{
		if (m_arrCellInfo[iIndex]->m_picItem)
		{
			delete m_arrCellInfo[iIndex]->m_picItem;
			m_arrCellInfo[iIndex]->m_picItem = NULL;
		}
	}
	
	m_arrCellInfo[iIndex]->item = item;
	
	NDUIButton*& btn	= m_arrCellInfo[iIndex]->button;
	NDPicture*& picBack = m_arrCellInfo[iIndex]->m_picBack;
	NDPicture*& picItem = m_arrCellInfo[iIndex]->m_picItem;
	NDUILayer*& backDack = m_arrCellInfo[iIndex]->backDackLayer;
	NDUIImage*& imgBack = m_arrCellInfo[iIndex]->m_imgBack;
	
	if (item)
	{
		int iIconIndex = item->getIconIndex();
		
		if (iIconIndex > 0)
		{
			//imageRowIndex = (byte) (iconIndex / 100 - 1);
			//imageColIndex = (byte) (iconIndex % 100 - 1);
			
			iIconIndex = (iIconIndex % 100 - 1) + (iIconIndex / 100 - 1) * 6;
		}
		
		if (iIconIndex != -1)
		{
			if (picItem)
			{
				delete m_arrCellInfo[iIndex]->m_picItem;
				m_arrCellInfo[iIndex]->m_picItem = NULL;
			}
			picItem = ItemImage::GetItem(iIconIndex);
		}
	}
	
	if (!btn)
	{
		picBack = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("ui_item.png"));
		
		if (!imgBack) 
		{
			imgBack = new NDUIImage;
			imgBack->Initialization();
			imgBack->SetPicture(picBack);
			imgBack->SetFrameRect(CGRectMake(8+(ITEM_CELL_INTERVAL_W+ITEM_CELL_W)*(iIndex%MAX_CELL_PER_PAGE%ITEM_BAG_C),
										 30+(ITEM_CELL_INTERVAL_H+ITEM_CELL_H)*(iIndex%MAX_CELL_PER_PAGE/ITEM_BAG_C), 
										 ITEM_CELL_W, ITEM_CELL_H));
			this->AddChild(imgBack);
		}
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->CloseFrame();
		btn->SetDelegate(this);
		btn->SetFrameRect(CGRectMake(8+(ITEM_CELL_INTERVAL_W+ITEM_CELL_W)*(iIndex%MAX_CELL_PER_PAGE%ITEM_BAG_C)+1,
									 30+(ITEM_CELL_INTERVAL_H+ITEM_CELL_H)*(iIndex%MAX_CELL_PER_PAGE/ITEM_BAG_C)+1, 
									 ITEM_CELL_W-2, ITEM_CELL_H-2));
		this->AddChild(btn);
	}
	
	if (!backDack) 
	{
		backDack = new NDUILayer;
		backDack->Initialization();
		backDack->SetTouchEnabled(false);
		backDack->SetBackgroundColor(ccc4(255, 0, 0, 85));
		backDack->EnableDraw(false);
		backDack->SetFrameRect(CGRectMake(0, 0, ITEM_CELL_W-2, ITEM_CELL_H-2));
		btn->AddChild(backDack);
	}
	
	if (picItem)
	{
		btn->SetImage(picItem);
		int iColor = item->getItemColor();
		btn->SetBackgroundColor(INTCOLORTOCCC4(iColor));
		btn->SetBackgroundPicture(ItemImage::GetPinZhiPic(item->iItemType), NULL, true);
	}
	else 
	{
		btn->SetImage(NULL);
		btn->SetBackgroundColor(ccc4(0, 0, 0, 0));
		btn->SetBackgroundPicture(NULL, NULL, true);
	}
	
	btn->SetVisible(picItem != NULL && bShow);
	if (imgBack) imgBack->SetVisible(picItem != NULL && bShow);
}

void GameItemBag::UpdateBagNum(int iNum)
{
	if(iNum<=0) return; m_iTotalPage = iNum > MAX_PAGE_COUNT ? MAX_PAGE_COUNT : iNum;
}

////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ItemFocus, NDUINode)
ItemFocus::ItemFocus()
{
	m_picFocus = NULL;
	m_picFocusMirror = NULL;
	m_sizeFocus = CGSizeZero;
	m_imageFocus = NULL;
	m_imageFocusMirror = NULL;
}

ItemFocus::~ItemFocus()
{
	SAFE_DELETE(m_picFocus);
	SAFE_DELETE(m_picFocusMirror);
}

void ItemFocus::draw()
{
	NDUINode::draw();
	Update();
}

void ItemFocus::Initialization()
{
	NDUINode::Initialization();
	
	m_picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("chosekuang.png"));
	m_picFocusMirror = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("chosekuang.png"));
	m_picFocusMirror->SetReverse(true);
	m_sizeFocus = m_picFocus->GetSize();
	
	m_imageFocus = new NDUIImage;
	m_imageFocus->Initialization();
	m_imageFocus->SetPicture(m_picFocus);
	this->AddChild(m_imageFocus);
	
	m_imageFocusMirror = new NDUIImage;
	m_imageFocusMirror->Initialization();
	m_imageFocusMirror->SetPicture(m_picFocusMirror);
	this->AddChild(m_imageFocusMirror);
	
	ResetFocus();
}

void ItemFocus::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	ResetFocus();
}

void ItemFocus::Update()
{	
	if (m_iFocusUpdateDif < FOCUS_DURATION_TIME)
	{
		m_iFocusUpdateDif++;
		return;
	}
	else 
	{
		m_iFocusUpdateDif = 0;
	}
	
	CGRect rect = this->GetFrameRect();
	int iIndex = m_iFocusCurFrame++ % 3;
	
	m_picFocus->Cut(CGRectMake(iIndex*(m_sizeFocus.width/4), 0, m_sizeFocus.width/4-1, m_sizeFocus.height));
	m_picFocusMirror->Cut(CGRectMake((iIndex)*(m_sizeFocus.width/4), 0, m_sizeFocus.width/4-1, m_sizeFocus.height));
	
	m_imageFocus->SetFrameRect(CGRectMake(0, 0, rect.size.width/2, rect.size.height));
	m_imageFocusMirror->SetFrameRect(CGRectMake(rect.size.width/2, 0, rect.size.width/2, rect.size.height));
}

void ItemFocus::ResetFocus()
{
	m_iFocusUpdateDif = FOCUS_DURATION_TIME;
	m_iFocusCurFrame = 0;
}
///////////////////////////////////////////////////////////

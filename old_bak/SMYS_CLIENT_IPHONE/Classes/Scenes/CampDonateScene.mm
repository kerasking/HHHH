/*
 *  CampDonateScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "CampDonateScene.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "ItemMgr.h"
#include "SocialTextLayer.h"
#include "NDUIDialog.h"
#include "GameUIPlayerList.h"
#include "GamePlayerBagScene.h"
#include "NDUISynLayer.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDUtility.h"
#include "define.h"
#include "NDMsgDefine.h"
#include <sstream>

void CampDonateUpdate(int iCamp, std::string title, VEC_SOCIAL_ELEMENT& elements)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(CampDonateScene))) 
	{
		scene = new CampDonateScene;
		scene->Initialization();
		NDDirector::DefaultDirector()->PushScene(scene);
	}
	
	((CampDonateScene*)scene)->refresh(iCamp, title, elements);
}

////////////////////////////////////////////////
#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

#define ONE_PAGE_COUNT (20)

enum  
{
	eOP_Donate = 155,
	eOP_Return,
};

enum
{
	eViewOP_Money = 2,
	eViewOP_EMoney,
	eViewOP_Weapon,
	eViewOP_Armor,
	eViewOP_Remedy,
};

IMPLEMENT_CLASS(CampDonateScene, NDScene)

int CampDonateScene::s_iCamp = 0;

CampDonateScene::CampDonateScene()
{
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	m_lbPage = NULL;
	m_tlOperate = NULL;
	m_iCurPage = 0;
	m_iTotalPage = 0;
	
	m_menulayerBG = NULL;
	m_iFocusIndex = -1;
}

CampDonateScene::~CampDonateScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
	
	ClearSocialElements();
}

void CampDonateScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, title_height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	//m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menulayerBG->AddChild(m_tlMain);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	m_menulayerBG->AddChild(m_lbPage);
	
	NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menulayerBG->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
	
	//refresh(true);
}

void CampDonateScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage <= 0) 
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("FirstPageTip"));
		} 
		else
		{
			m_iCurPage--;
			ShowPage(m_iCurPage);
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage >= GetPageNum()-1)
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("LastPageTip"));
		} 
		else
		{
			m_iCurPage++;
			ShowPage(m_iCurPage);
		}
	}
}

void CampDonateScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain && cell->IsKindOfClass(RUNTIME_CLASS(SocialTextLayer)))
	{
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		vec_str.push_back(NDCommonCString("donate")); vec_id.push_back(eOP_Donate);
		vec_str.push_back(NDCommonCString("leave")); vec_id.push_back(eOP_Return);
		
		if (!vec_str.empty()) 
		{
			InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		}
		
		m_iFocusIndex = cellIndex;
	}
	else if (table == m_tlOperate)
	{
		m_tlOperate->SetVisible(false);
		int iTag = cell->GetTag();
		if (m_iFocusIndex != -1 && iTag == eOP_Donate
			&& m_iFocusIndex >= 0 && m_iFocusIndex <= 4) 
		{
			if (m_iFocusIndex >=2 && m_iFocusIndex <= 4) 
			{
				int iType = 0;
				switch (m_iFocusIndex) 
				{
					case 2:
						iType = eItemDonateType_DONATE_WEAPON;
						break;
					case 3:
						iType = eItemDonateType_DONATE_ARMOR;
						break;
					case 4:
						iType = eItemDonateType_DONATE_REMEDY;
						break;
					default:
						break;
				}
				ItemDonateScene *scene = new ItemDonateScene;
				scene->Initialization(iType);
				NDDirector::DefaultDirector()->PushScene(scene);
				m_iFocusIndex = -1;
				return;
			}
			
			NDUICustomView *view = new NDUICustomView;
			view->Initialization();
			view->SetDelegate(this);
			std::vector<int> vec_id; vec_id.push_back(1);
			std::vector<std::string> vec_str;
		
			switch (m_iFocusIndex) {
				case 0: {
					
					view->SetTag(eViewOP_Money);
					vec_str.push_back(NDCommonCString("InputDonateMoney"));
					break;
				}
				case 1: {
					view->SetTag(eViewOP_EMoney);
					vec_str.push_back(NDCommonCString("InputDonateEMoney"));
					break;
				}
				//case 2:
//					//T.addToTop(new DonateDialog(DonateDialog.DONATE_WEAPON, this
////												.getParma()));
//		
//					break;
//				case 3:
//					T.addToTop(new DonateDialog(DonateDialog.DONATE_ARMOR, this
//												.getParma()));
//					break;
//				case 4:
//					T.addToTop(new DonateDialog(DonateDialog.DONATE_REMEDY, this
//												.getParma()));
					//break;
			}
			view->SetEdit(1, vec_id, vec_str);
			view->Show();
			
			this->AddChild(view);
		}
		
		m_iFocusIndex = -1;
	}
	
}

bool CampDonateScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string stramount =	customView->GetEditText(0);
	if (!stramount.empty())
	{
		VerifyViewNum(*customView);
		
		int amount = atoi(stramount.c_str());
		if (amount <= 0)
		{
			customView->ShowAlert(NDCommonCString("InputInvalid"));
			return false;
		}
		
		int iTag = customView->GetTag();
		
		if (iTag == eViewOP_Money) 
		{
			if (amount < 100 || amount % 100 > 0) 
			{
				customView->ShowAlert(NDCommonCString("Mutiply100"));
				return false;
			}
			if (amount > NDPlayer::defaultHero().money) 
			{	
				std::stringstream ss; ss << NDCommonCString("RestMoneyNotEnough") << amount << "!";
				customView->ShowAlert(ss.str().c_str());
				return false;
			}
			
			NDTransData bao(_MSG_CONTRIBUTE);
			bao << (unsigned char)0 << (unsigned char)s_iCamp << int(amount);
			SEND_DATA(bao);
		}
		else if (iTag == eViewOP_EMoney)
		{
			if (amount > NDPlayer::defaultHero().eMoney) 
			{	
				std::stringstream ss; ss << NDCommonCString("RestEMoneyNotEnough") << amount << "!";
				customView->ShowAlert(ss.str().c_str());
				return false;
			}
			
			NDTransData bao(_MSG_CONTRIBUTE);
			bao << (unsigned char)1 << (unsigned char)s_iCamp << int(amount);
			SEND_DATA(bao);
		}
	}
	else
	{
		customView->ShowAlert(NDCommonCString("DonotEmpty"));
		return false;
	}
	
	return true;
}

void CampDonateScene::refresh(int iCamp, std::string title, VEC_SOCIAL_ELEMENT& elements)
{
	s_iCamp =  iCamp;
	
	//if (m_lbTitle) m_lbTitle->SetText(title.c_str());
	m_strTitle = title;
	
	if (!elements.empty()) 
	{
		m_iTotalPage = (elements.size() - 1) / ONE_PAGE_COUNT + 1;
	}
	//m_iTotalPage++;
	m_iCurPage = 0;
	
	
	UpdatePage();
	UpdateMainUI(elements);
	UpdateTitle();
	
	ClearSocialElements();
	m_vecElement = elements;
}

void CampDonateScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFontColor(ccc4(0, 0, 0, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
btn->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"CampDonateScene::InitTLContentWithVec初始化失败");
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++)
	{
		fastinit(vec_str[i].c_str(), vec_id[i]);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit	
}

void CampDonateScene::UpdateMainUI(VEC_SOCIAL_ELEMENT& elements)
{
	if (!m_tlMain)
	{
		return;
	}
	
	if ( elements.empty() )
	{
		if (m_tlMain->GetDataSource()) 
		{
			NDDataSource *source = m_tlMain->GetDataSource();
			source->Clear();
			m_tlMain->ReflashData();
		}
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	//section->UseCellHeight(true);
	bool bChangeClr = false;
	for_vec(elements, VEC_SOCIAL_ELEMENT_IT)
	{
		SocialTextLayer* st = new SocialTextLayer;
		
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
						   CGRectMake(5.0f, 0.0f, 330.0f, 27.0f), *it);
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		section->AddCell(st);
	}
	
	if (section->Count() > 0) 
	{
		section->SetFocusOnCell(0);
	}
	dataSource->AddSection(section);
	
	int iHeigh = elements.size()*30;//+elements.size()+1;
	int iHeighMax = winsize.height-title_height-bottom_height-BTN_H-2*2;
	iHeigh = iHeigh < iHeighMax ? iHeigh : iHeighMax;
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeigh));
	
	m_tlMain->SetVisible(true);
	
	if (m_tlMain->GetDataSource())
	{
		m_tlMain->SetDataSource(dataSource);
		m_tlMain->ReflashData();
	}
	else
	{
		m_tlMain->SetDataSource(dataSource);
	}
}

int CampDonateScene::GetPageNum()
{
	return m_iTotalPage;
}

void CampDonateScene::ClearSocialElements()
{
	for_vec(m_vecElement, VEC_SOCIAL_ELEMENT_IT)
	{
		delete *it;
	}
	m_vecElement.clear();
}

void CampDonateScene::UpdatePage()
{
	std::stringstream ss;
	ss << (m_iCurPage+1) << "/" << m_iTotalPage;
	if (m_lbPage) 
	{
		m_lbPage->SetText(ss.str().c_str());
	}
}

void CampDonateScene::UpdateTitle()
{
	if (!m_tlMain || !m_tlMain->GetDataSource() || !m_tlMain->GetDataSource()->Section(0)) 
	{
		return;
	}
	NDSection* sec = m_tlMain->GetDataSource()->Section(0);
	
	std::stringstream temp;
	int curCount = m_iCurPage* ONE_PAGE_COUNT;
	int curPageCount = sec->Count();
	if(curCount + curPageCount>0){
		temp << m_strTitle << "[" << (curCount + 1) << " ~ " << (curCount + curPageCount) << "]";
	}
	else
	{
		temp << m_strTitle;
	}
	
	if (m_lbTitle) 
	{
		m_lbTitle->SetText(temp.str().c_str());
	}
}

void CampDonateScene::ShowPage(int iPage)
{
	int start = m_iCurPage * ONE_PAGE_COUNT;
	int end = start + ONE_PAGE_COUNT;
	int iSize = m_vecElement.size();
	if (start >= iSize) 
	{
		return;
	}
	
	if (end > iSize)
	{
		end = iSize;
	}
	
	VEC_SOCIAL_ELEMENT elements;
	for (int i = start; i < end; i++) 
	{
		if (i >= iSize || i < 0) 
		{
			break;
		}
		elements.push_back(m_vecElement[i]);
	}
	
	UpdateMainUI(elements);
}
////////////////////////////////////////////////

enum  
{
	eItemDonate_Donate = 33,
	eItemDonate_GetBack,
};

IMPLEMENT_CLASS(ItemDonateScene, NDScene)

ItemDonateScene::ItemDonateScene()
{
	m_menulayerBG = NULL;
	m_itemBag = NULL;
	m_picTitle = NULL;
	m_itemfocus = NULL;
	m_tlOperate = NULL;
	
	m_iFocusIndex = -1;
	
	memset(m_btns, 0, sizeof(m_btns));
	
	m_iType = eItemDonateType_Begin;
}

ItemDonateScene::~ItemDonateScene()
{
}

void ItemDonateScene::Initialization(int iType)
{
	NDAsssert(iType >= eItemDonateType_Begin && iType < eItemDonateType_End);
	
	VEC_ITEM itemlist;
	
	VEC_ITEM& itemBag = ItemMgrObj.GetPlayerBagItems();
	for_vec(itemBag, VEC_ITEM_IT)
	{
		Item *item = *it;
		if (!item) 
		{
			continue;
		}
		
		switch (iType) 
		{
			case eItemDonateType_DONATE_WEAPON:
			{
				if (Item::isWeapon(item->iItemType)) 
				{
					itemlist.push_back(item);
				}
			}
				break;
			case eItemDonateType_DONATE_ARMOR:
			{
				if (Item::isDefEquip(item->iItemType)) 
				{
					itemlist.push_back(item);
				}
			}
				break;
			case eItemDonateType_DONATE_REMEDY:
			{
				if ( item->isRemedy()) 
				{
					itemlist.push_back(item);
				}
			}
				break;
			default:
				break;
		}
	}
	
	m_iType = iType;
	
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	if (m_menulayerBG->GetOkBtn()) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picTitle->Cut(CGRectMake(40, 140, 39, 20));
	CGSize sizeTitle = m_picTitle->GetSize();
	
	NDUIImage *imageTitle =  new NDUIImage;
	imageTitle->Initialization();
	imageTitle->SetPicture(m_picTitle);
	imageTitle->SetFrameRect(CGRectMake((winsize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_menulayerBG->AddChild(imageTitle);
	
	int iIntervalW = 3, iIntervalH = 5;
	int iX = (winsize.width-ITEM_BAG_W-ITEM_CELL_W*eCol-iIntervalW*(eCol-1))/2;
	int iY = (winsize.height-title_height-bottom_height-ITEM_CELL_H*eRow-iIntervalH*(eRow-1))/2+title_height;
	
	for (int i = 0; i < eRow; i++) 
	{
		for (int j = 0; j < eCol; j++) 
		{
			m_btns[i*eCol+j] = new NDUIItemButton;
			NDUIItemButton *& btn = m_btns[i*eCol+j];
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(iX+j*(ITEM_CELL_W+iIntervalW), iY+i*(ITEM_CELL_H+iIntervalH), ITEM_CELL_W, ITEM_CELL_H));
			btn->ChangeItem(NULL);
			m_menulayerBG->AddChild(btn);
		}
	}
	
	
	m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menulayerBG->AddChild(m_itemBag);
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	m_itemfocus->SetFrameRect(CGRectZero);
	m_menulayerBG->AddChild(m_itemfocus, 1);
	
	NDUITopLayer *toplayer = new NDUITopLayer;
	toplayer->Initialization();
	toplayer->SetFrameRect(CGRectMake(0,0, winsize.width, winsize.height-48));
	m_menulayerBG->AddChild(toplayer, 2);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	toplayer->AddChild(m_tlOperate);
}

void ItemDonateScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetOkBtn()) 
	{
		showConfirmDlg();
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		if (m_tlOperate->IsVisibled()) 
		{
			m_tlOperate->SetVisible(false);
		}
		else 
		{
			NDDirector::DefaultDirector()->PopScene();
		}
	}
	else 
	{
		for (int i = 0; i < eRow*eCol; i++) 
		{
			if (m_btns[i] && button == m_btns[i]) 
			{
				if (m_iFocusIndex == i)
				{
					// 前一状态已获得焦点
					std::vector<std::string> vec_str;
					std::vector<int> vec_id;
					vec_str.push_back(NDCommonCString("QuHui")); vec_id.push_back(eItemDonate_GetBack);
					InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
				}
				else 
				{
					m_iFocusIndex = i;
				}
				
				UpdateFocus();
				break;
			}
		}
	}
}

void ItemDonateScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate) 
	{
		m_tlOperate->SetVisible(false);
		int iTag = cell->GetTag();
		switch (iTag) 
		{
			case eItemDonate_Donate:
			{
				Item *focusItem = NULL;
				if (m_itemBag) focusItem = m_itemBag->GetFocusItem();
				
				if (!focusItem) 
				{
					return;
				}
				
				for (int i = 0; i < eRow*eCol; i++) 
				{
					if (m_btns[i] && m_btns[i]->GetItem() == NULL) 
					{
						m_btns[i]->ChangeItem(focusItem);
						m_itemBag->DelItem(focusItem->iID);
						break;
					}
				}
			}
				break;
			case eItemDonate_GetBack:
			{
				if (m_iFocusIndex == -1 || m_iFocusIndex < 0 || m_iFocusIndex >= eRow*eCol
					|| !m_btns[m_iFocusIndex] || !m_btns[m_iFocusIndex]->GetItem()) 
				{
					return;
				}
				
				m_itemBag->AddItem(m_btns[m_iFocusIndex]->GetItem());
				m_itemBag->UpdateTitle();
				m_btns[m_iFocusIndex]->ChangeItem(NULL);
			}
				break;
			default:
				break;
		}
	}
}

bool ItemDonateScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (m_iFocusIndex != -1)
	{
		m_iFocusIndex = -1;
		UpdateFocus();
	}
	
	if (itembag == m_itemBag && item && bFocused) 
	{
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		vec_str.push_back(NDCommonCString("donate")); vec_id.push_back(eItemDonate_Donate);
		InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
	}
	
	return false;
}

void ItemDonateScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	std::vector<int> vec_id;
	for (int i = 0; i < eRow*eCol; i++) 
	{
		if (m_btns[i] && m_btns[i]->GetItem()) 
		{
			vec_id.push_back(m_btns[i]->GetItem()->iID);
		}
	}
	
	if (!vec_id.empty()) 
	{
		NDTransData bao(_MSG_CONTRIBUTE);
		bao << (unsigned char)2 << (unsigned char)CampDonateScene::s_iCamp << int(vec_id.size());
		for_vec(vec_id, std::vector<int>::iterator)
		{
			bao << int(*it);
		}
		SEND_DATA(bao);
	}
	
	dialog->Close();
	NDDirector::DefaultDirector()->PopScene();
}

void ItemDonateScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text,tag) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
button->SetFontColor(ccc4(38,59,28,255)); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
button->SetTag(tag); \
section->AddCell(button); \
} while (0);
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"ItemDonateScene::InitTLContentWithVec初始化失败");
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++)
	{
		fastinit(vec_str[i].c_str(), vec_id[i]);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit	
}

void ItemDonateScene::UpdateFocus()
{
	if (m_iFocusIndex == -1) 
	{
		m_itemfocus->SetFrameRect(CGRectZero);
	}
	else 
	{
		if (m_iFocusIndex >= 0 && m_iFocusIndex < eRow*eCol && m_btns[m_iFocusIndex]) 
		{
			m_itemfocus->SetFrameRect(m_btns[m_iFocusIndex]->GetScreenRect());
			if (m_itemBag) 
			{
				m_itemBag->DeFocus();
			}
		}
	}
}

void ItemDonateScene::showConfirmDlg()
{
	std::stringstream sb;
	
	for (int i = 0; i < eRow*eCol; i++) 
	{
		if (m_btns[i] && m_btns[i]->GetItem()) 
		{
			Item& item = *(m_btns[i]->GetItem());
			sb << (item.getItemName());
			sb << (" x ");
			if (eItemDonateType_DONATE_REMEDY == m_iType) 
			{
				sb << (item.iAmount);
			} 
			else 
			{
				sb << ("1");
			}
			sb << ("\n");
		}
	}
	
	if (sb.str() == "" ) 
	{
		return;
	}
	
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show(NDCommonCString("DonateList"), sb.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
}

/*
 *  VipStoreScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "VipStoreScene.h"
#include "define.h"
#include "NDUtility.h"
#include "ItemMgr.h"
#include "NDDirector.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDUIItemButton.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include <sstream>

void VipStoreUpdateEmoney()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(VipStoreScene)))
	{
		return;
	}
	
	((VipStoreScene*)scene)->UpdateMoney();
}

/////////////////////////////////////////////
IMPLEMENT_CLASS(StoreTabLayer, NDUILayer)

StoreTabLayer::StoreTabLayer()
{
	m_lbText = NULL;
	memset(m_picLeft, 0, sizeof(m_picLeft));
	memset(m_picRight, 0, sizeof(m_picRight));
	memset(m_picMid, 0, sizeof(m_picMid));
	
	m_bTabFocus = false;
	m_bCacl = false;
}

StoreTabLayer::~StoreTabLayer()
{
	for (int i = eBegin; i < eEnd; i++) 
	{
		SAFE_DELETE(m_picLeft[i]);
		SAFE_DELETE(m_picRight[i]);
		SAFE_DELETE(m_picMid[i]);
	}
}

void StoreTabLayer::Initialization()
{
	NDUILayer::Initialization();
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(15);
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbText->SetVisible(false);
	this->AddChild(m_lbText);
	
	m_picLeft[eSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_left_selected.png"));
	m_picLeft[eUnSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_left_unselected.png"));
	
	m_picRight[eSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_right_selected.png"));
	m_picRight[eUnSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_right_unselected.png"));
	
	m_picMid[eSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_middle_selected.png"));
	m_picMid[eUnSel] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("tab_middle_unselected.png"));
}

void StoreTabLayer::draw()
{
	NDUILayer::draw();
	
	CGRect rect = GetFrameRect();
	if (!m_bCacl) 
	{
		if (m_lbText) 
		{
//			CGSize dim = CGSizeZero;
//			std::string str = m_lbText->GetText();
//			if (!str.empty()) 
//			{
//				dim = getStringSizeMutiLine(str.c_str(), m_lbText->GetFontSize(), CGSizeMake(480,320));
//			}
			m_lbText->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
			m_lbText->SetVisible(true);
		}
	}
	
	m_bCacl = true;
	
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		CGRect scrRect = this->GetScreenRect();	
		
		//draw focus 
		int iIndex = eUnSel;
		if (m_bTabFocus) 
		{
			iIndex = eSel;
		}
		
		int iStart = scrRect.origin.x, iY = scrRect.origin.y;
		int iEnd = 0;
		if (m_picLeft[iIndex]) 
		{
			CGSize size = m_picLeft[iIndex]->GetSize();
			m_picLeft[iIndex]->DrawInRect(CGRectMake(iStart, iY, size.width, size.height));
			iStart += size.width;
		}
		
		if (m_picRight[iIndex]) 
		{
			CGSize size = m_picRight[iIndex]->GetSize();
			iEnd = scrRect.origin.x + rect.size.width-size.width;
			m_picRight[iIndex]->DrawInRect(CGRectMake(iEnd, iY, size.width, size.height));
		}
		
		if (m_picMid[iIndex]) 
		{
			CGSize size = m_picMid[iIndex]->GetSize();
			int iW = iEnd-iStart > 0 ? iEnd-iStart : 0;
			m_picMid[iIndex]->DrawInRect(CGRectMake(iStart, iY, iW, size.height));
		}
		
		if (m_lbText) 
		{
			if (iIndex == eSel) 
			{
				m_lbText->SetFontColor(INTCOLORTOCCC4(0x133b40));
			}
			else
			{
				m_lbText->SetFontColor(INTCOLORTOCCC4(0xffffff));
			}
		}
	}
}

bool StoreTabLayer::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	m_beginTouch = touch->GetLocation();
	
	if (!CGRectContainsPoint(this->GetScreenRect(), m_beginTouch)) 
	{
		return false;
	}

	if (m_bTabFocus) 
	{
		return true;
	}
	
	StoreTabLayerDelegate* delegate = dynamic_cast<StoreTabLayerDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFocusTablayer(this);
	}	

	return true;
}

bool StoreTabLayer::TouchEnd(NDTouch* touch)
{
	return true;
}

void StoreTabLayer::SetText(std::string text)
{
	if (m_lbText) 
	{
		m_lbText->SetText(text.c_str());
	}
}

void StoreTabLayer::SetTabFocus(bool bTabFocus)
{
	m_bTabFocus = bTabFocus;
}
//////////////////////////////////////////
class NDUIScrollLayer : public NDUILayer
{
	DECLARE_CLASS(NDUIScrollLayer)
public:
	void Initialization() override
	{
		NDUILayer::Initialization();
		
		this->SetBackgroundColor(ccc4(255, 255, 255, 0));
		
		CGSize winsize =NDDirector::DefaultDirector()->GetWinSize();
		
		this->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	}
	
	bool TouchBegin(NDTouch* touch) override
	{
		if ( !(this->IsVisibled() && this->EventEnabled()) )
		{
			return false;
		}
		
		std::vector<NDNode*> tmplist = GetChildren();
		
		if (tmplist.empty())
		{
			return false;
		}
		
		m_beginTouch = touch->GetLocation();
		
		std::vector<NDNode*>::iterator it = tmplist.begin();
		for (; it != tmplist.end(); it++) 
		{
			NDNode *node = (*it);
			if (node->IsKindOfClass(RUNTIME_CLASS(NDUINode))) 
			{
				NDUINode *uinode = (NDUINode*)node;
				if (uinode->IsVisibled() && this->IsVisibled() && this->EventEnabled() && CGRectContainsPoint(uinode->GetScreenRect(), m_beginTouch)) 
				{
					this->DispatchTouchBeginEvent(m_beginTouch);
					return true;
				}
			}
			
		}
		
		return false;
	}
	
	bool TouchEnd(NDTouch* touch) override
	{
		m_endTouch = touch->GetLocation();		
		
		if (CGRectContainsPoint(this->GetScreenRect(), m_endTouch) && this->IsVisibled() && this->EventEnabled()) 
		{
			this->DispatchTouchEndEvent(m_beginTouch, m_endTouch);
		}
		
		return true;
	}
	
};

IMPLEMENT_CLASS(NDUIScrollLayer, NDUILayer)
//////////////////////////////////////////

#define vip_item_w (42)
#define vip_item_h (42)

#define title_height (28)
#define bottom_height (42)

#define vip_item_layer_w (227)
#define vip_item_layer_h (50)
#define vip_item_layer_inter_h (2)
#define vip_item_layer_inter_w (3)

std::string tab_titles[vipstore_tab_count] = { "特价热卖", "坐骑", "特殊道具", "材料", "庄园道具"};

class StoreItemLayer : public NDUILayer
{
	DECLARE_CLASS(StoreItemLayer)
public:
	StoreItemLayer();
	~StoreItemLayer();
	
	void Initialization(VipItem* vipitem); hide
	void draw(); override
	
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	VipItem* GetVipItem();
	
	void ChangeVipItem(VipItem* vipitem);
	
	void SetStoreItemFocus(bool bFocus);
private:
	NDUIItemButton		*m_btnItem;
	NDUILabel			*m_lbText;
	NDUILabel			*m_lbPrice;
	NDUIImage			*m_imageMoney; NDPicture *m_picMoney;
	
	bool m_bCacl;
	VipItem *m_vipItem;
	bool				m_bFocus;
};

IMPLEMENT_CLASS(StoreItemLayer, NDUILayer)

StoreItemLayer::StoreItemLayer()
{
	m_btnItem = NULL;
	m_lbText = NULL;
	m_lbPrice = NULL;
	m_imageMoney = NULL;
	m_picMoney = NULL;
	m_vipItem = NULL;
	m_bCacl = false;
}

StoreItemLayer::~StoreItemLayer()
{
}

void StoreItemLayer::Initialization(VipItem* vipitem)
{
	if (!vipitem) 
	{
		return;
	}
	
	NDUILayer::Initialization();
	
	m_btnItem = new NDUIItemButton;
	m_btnItem->Initialization();
	m_btnItem->ChangeItem(NULL);
	m_btnItem->SetVisible(false);
	this->AddChild(m_btnItem);
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(15);
	m_lbText->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbText->SetVisible(false);
	this->AddChild(m_lbText);
	
	m_lbPrice = new NDUILabel;
	m_lbPrice->Initialization();
	m_lbPrice->SetFontSize(15);
	m_lbPrice->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbPrice->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbPrice->SetVisible(false);
	this->AddChild(m_lbPrice);
	
	m_picMoney = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("emoney.png"));
	m_imageMoney =  new NDUIImage;
	m_imageMoney->Initialization();
	m_imageMoney->SetPicture(m_picMoney);
	m_imageMoney->SetVisible(false);
	this->AddChild(m_imageMoney);
	
	ChangeVipItem(vipitem);
}

void StoreItemLayer::draw()
{
	NDUILayer::draw();
	
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	if (!m_bCacl) 
	{
		CGRect rect = GetFrameRect();
		
		int iX = 5;
		if (m_btnItem) 
		{
			m_btnItem->SetFrameRect(CGRectMake(iX, (rect.size.height-vip_item_h)/2, vip_item_w, vip_item_h));
			m_btnItem->ChangeItem(m_btnItem->GetItem());
			m_btnItem->SetVisible(true);
			
			iX += vip_item_w;
		}
		
		iX += 6;
		int iY = 7;
		if (m_lbText) 
		{
			CGSize dim = CGSizeZero;
			std::string str = m_lbText->GetText();
			if (!str.empty()) 
			{
				dim = getStringSizeMutiLine(str.c_str(), m_lbText->GetFontSize(), CGSizeMake(480,320));
			}
			m_lbText->SetFrameRect(CGRectMake(iX, iY, rect.size.width, dim.height));
			m_lbText->SetVisible(true);
			iY += dim.height;
		}
		
		iY += 4;
		
		if (m_imageMoney && m_picMoney) 
		{
			CGSize size = m_picMoney->GetSize();
			m_imageMoney->SetFrameRect(CGRectMake(iX, iY, size.width, size.height));
			m_imageMoney->SetVisible(true);
			iX += size.width + 6;
		}
		
		if (m_lbPrice) 
		{
			CGSize dim = CGSizeZero;
			std::string str = m_lbPrice->GetText();
			if (!str.empty()) 
			{
				dim = getStringSizeMutiLine(str.c_str(), m_lbPrice->GetFontSize(), CGSizeMake(480,320));
			}
			m_lbPrice->SetFrameRect(CGRectMake(iX, iY, rect.size.width, dim.height));
			m_lbPrice->SetVisible(true);
		}
	}
	
	m_bCacl = true;
	
	CGRect scrRect = this->GetScreenRect();	
	
	//draw focus 
	ccColor4B linecolor, bgcolor;
	if (m_bFocus) 
	{
		linecolor = INTCOLORTOCCC4(0xffb402);
		bgcolor = INTCOLORTOCCC4(0xffdc78);				
	}
	else 
	{
		linecolor = INTCOLORTOCCC4(0x6b9e9c);
		bgcolor = INTCOLORTOCCC4(0xc6cbb5);
	}
	
	this->SetBackgroundColor(bgcolor);

	DrawPolygon(CGRectMake(scrRect.origin.x, scrRect.origin.y, scrRect.size.width, scrRect.size.height-1),linecolor, 1);
	DrawPolygon(CGRectMake(scrRect.origin.x+1, scrRect.origin.y+1, scrRect.size.width-2, scrRect.size.height-3), linecolor, 1);
}

bool StoreItemLayer::TouchBegin(NDTouch* touch)
{
	if ( !(this->IsVisibled() && this->EventEnabled()) )
	{
		return false;
	}
	
	m_beginTouch = touch->GetLocation();
	
	if (!CGRectContainsPoint(this->GetScreenRect(), m_beginTouch)) 
	{
		return false;
	}
	
	m_bFocus = true;
	
	StoreItemLayerDelegate* delegate = dynamic_cast<StoreItemLayerDelegate*> (this->GetDelegate());
	if (delegate) 
	{
		delegate->OnFocusStoreItemLayer(this);
	}
	
	return true;
}

bool StoreItemLayer::TouchEnd(NDTouch* touch)
{
	return true;
}

void StoreItemLayer::ChangeVipItem(VipItem* vipitem)
{
	if (!vipitem || !vipitem->item) 
	{
		m_btnItem->ChangeItem(NULL);
		return;
	}
	
	if (m_btnItem) 
	{
		m_btnItem->ChangeItem(vipitem->item);
	}
	
	if (m_lbText) 
	{
		m_lbText->SetText(vipitem->item->getItemName().c_str());
	}
	
	if (m_lbPrice) 
	{
		std::stringstream ss; ss << vipitem->price;
		m_lbPrice->SetText(ss.str().c_str());
	}
	
	m_vipItem = vipitem;
}

VipItem* StoreItemLayer::GetVipItem()
{
	return m_vipItem;
}

void StoreItemLayer::SetStoreItemFocus(bool bFocus)
{
	m_bFocus = bFocus;
}

//////////////////////////////////////////

IMPLEMENT_CLASS(VipStoreScene, NDScene)

VipStoreScene::VipStoreScene()
{
	m_menulayerBG = NULL;
	m_imageTitle = NULL;
	m_picTitle = NULL;
	memset(m_tabLayer, 0, sizeof(m_tabLayer));
	memset(m_storeitemLayer, 0, sizeof(m_storeitemLayer));
	m_imageMoney = NULL; m_picMoney = NULL;
	m_imageNumMoney = NULL;
	m_nodePolygon = NULL;
	m_Scroll = NULL;
	m_iCurTabFocus = 0;
	m_iCurVipItemFocusRow = 0;
	m_iFocusLayerIndex = 0;
}

VipStoreScene::~VipStoreScene()
{
	SAFE_DELETE(m_picMoney);
}

VipStoreScene* VipStoreScene::Scene()
{
	VipStoreScene* scene = new VipStoreScene;
	scene->Initialization();
	return scene;
}

void VipStoreScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->SetBackgroundColor(INTCOLORTOCCC4(0xc6cbb5));
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUIRecttangle* bkg = new NDUIRecttangle();
	bkg->Initialization();
	bkg->SetColor(ccc4(99, 117, 99, 255));
	bkg->SetFrameRect(CGRectMake(4, m_menulayerBG->GetTitleHeight() + 2, 472, m_menulayerBG->GetTextHeight() - 4));
	m_menulayerBG->AddChild(bkg);
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("vip_store.png"));
	CGSize sizeTitle = m_picTitle->GetSize();
	
	m_imageTitle =  new NDUIImage;
	m_imageTitle->Initialization();
	m_imageTitle->SetPicture(m_picTitle);
	m_imageTitle->SetFrameRect(CGRectMake((winsize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_menulayerBG->AddChild(m_imageTitle);
	
	
	m_picMoney = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("emoney.png"));
	m_picMoney->Cut(CGRectMake(0, 0, 16, 16));
	
	m_imageMoney =  new NDUIImage;
	m_imageMoney->Initialization();
	m_imageMoney->SetPicture(m_picMoney);
	m_imageMoney->SetFrameRect(CGRectMake(209, 293, 16, 16));
	m_menulayerBG->AddChild(m_imageMoney);
	
	m_imageNumMoney = new ImageNumber;
	m_imageNumMoney->Initialization();
	m_imageNumMoney->SetTitleRedNumber(100);
	m_imageNumMoney->SetFrameRect(CGRectMake(209+m_picMoney->GetSize().width+8, 293, 100, 11));
	m_menulayerBG->AddChild(m_imageNumMoney);
	
	int width = (winsize.width - 30) / eMaxTab;
	int x = 5;
	int y = title_height+3;
	int iTabHeight = 30;
	
	m_nodePolygon = new NDUIPolygon;
	m_nodePolygon->Initialization();
	m_nodePolygon->SetFrameRect(CGRectMake(7, y+28, winsize.width-15,  (vip_item_layer_h+vip_item_layer_inter_h)*eRow+4));
	m_nodePolygon->SetLineWidth(1);
	m_nodePolygon->SetColor(ccc3(19, 59, 64));
	//m_nodePolygon->SetVisible(true);
	m_menulayerBG->AddChild(m_nodePolygon);
	
	NDUIPolygon *polygon = new NDUIPolygon;
	polygon->Initialization();
	polygon->SetFrameRect(CGRectMake(8, y+29, winsize.width-17,  (vip_item_layer_h+vip_item_layer_inter_h)*eRow+2));
	polygon->SetLineWidth(1);
	polygon->SetColor(ccc3(255, 225, 120));
	//polygon->SetVisible(true);
	m_menulayerBG->AddChild(polygon);
	
	for (int i = 0; i < eMaxTab; i++) 
	{
		m_tabLayer[i] = new StoreTabLayer;
		m_tabLayer[i]->Initialization();
		m_tabLayer[i]->SetText(tab_titles[i]);
		m_tabLayer[i]->SetFrameRect(CGRectMake(x, y, width, iTabHeight));
		m_tabLayer[i]->SetDelegate(this);
		m_menulayerBG->AddChild(m_tabLayer[i]);
		x += width+5;
	}
	
	m_tabLayer[m_iCurTabFocus]->SetTabFocus(true);
	
	
	NDUIScrollLayer *layer = new NDUIScrollLayer;
	layer->Initialization();
	m_menulayerBG->AddChild(layer, 1);
	m_Scroll = new NDUIVerticalScrollBar;
	m_Scroll->Initialization();
	m_Scroll->SetDelegate(this);
	m_Scroll->SetFrameRect(CGRectMake(winsize.width-38, title_height+33, 28, (vip_item_layer_h+vip_item_layer_inter_h)*eRow));
	m_Scroll->SetVisible(false);
	layer->AddChild(m_Scroll);
	
	Reset();
	UpdateGui();
	UpdateMoney();
}

void VipStoreScene::UpdateGui()
{
	ItemMgr& mgr = ItemMgrObj;
	map_vip_item& itemstore = mgr.GetVipStore();
	map_vip_item_it it = itemstore.find(m_iCurTabFocus+1);
	if (it == itemstore.end()) 
	{
		for (int i = 0; i < eRow; i++) 
		{
			for (int j = 0; j < eCol; j++) 
			{
				int iIndex = i*eCol+j;
				if (m_storeitemLayer[iIndex])
				{
					m_storeitemLayer[iIndex]->SetVisible(false);
				}
			}
		}
		
		if (m_Scroll) 
		{
			m_Scroll->SetVisible(false);
		}
		
		//if (m_nodePolygon) 
//		{
//			m_nodePolygon->SetVisible(false);
//		}
		return;
	}
	
	int iStart = m_iCurVipItemFocusRow*eCol;
	int iEnd   = iStart + eCol*eRow;
	vec_vip_item& itemlist = it->second;
	int iSize = itemlist.size();
	
	for (int i = iStart, iIndex = 0; i < iEnd; i++, iIndex++) 
	{
		if (i >= iSize) 
		{
			if (m_storeitemLayer[iIndex]) 
			{
				m_storeitemLayer[iIndex]->SetVisible(false);
			}
			continue;
		}
		
		VipItem *vipitem = itemlist[i];
		
		if (!m_storeitemLayer[iIndex]) 
		{
			int iX = 11 , iY = title_height+35;
			iX += (iIndex % eCol == 0 ? 0 : (vip_item_layer_w+vip_item_layer_inter_w));
			iY += iIndex/eCol * (vip_item_layer_h+vip_item_layer_inter_h);
			StoreItemLayer *&itemlayer = m_storeitemLayer[iIndex];
			itemlayer = new StoreItemLayer;
			itemlayer->Initialization(vipitem);
			itemlayer->SetFrameRect(CGRectMake(iX, iY, vip_item_layer_w, vip_item_layer_h));
			itemlayer->SetDelegate(this);
			m_menulayerBG->AddChild(itemlayer);
		}
		else 
		{
			m_storeitemLayer[iIndex]->ChangeVipItem(vipitem);
			m_storeitemLayer[iIndex]->SetVisible(true);
		}
		
		m_storeitemLayer[iIndex]->SetStoreItemFocus(false);
	}
	
	if (iSize < eRow*eCol) 
	{
		if (m_Scroll) 
		{
			m_Scroll->SetVisible(false);
		}
	}
	else 
	{
		if (m_Scroll) 
		{
			int iRowSum = iSize / eCol + (iSize % eCol == 0 ? 0 : 1);
			m_Scroll->SetVisible(true);
			int vh = (vip_item_layer_h+vip_item_layer_inter_h)*eRow;
			m_Scroll->SetContentHeight((iRowSum)*vh);
			m_Scroll->SetCurrentContentY((m_iCurVipItemFocusRow+m_iFocusLayerIndex/2)*vh);
		}
	}
	
	if (m_storeitemLayer[m_iFocusLayerIndex]) 
	{
		m_storeitemLayer[m_iFocusLayerIndex]->SetStoreItemFocus(true);
	}
	
	//if (m_nodePolygon) 
//	{
//		m_nodePolygon->SetVisible(true);
//	}
}

void VipStoreScene::Adust(bool bUp)
{
	ItemMgr& mgr = ItemMgrObj;
	map_vip_item& itemstore = mgr.GetVipStore();
	map_vip_item_it it = itemstore.find(m_iCurTabFocus+1);
	
	if (it == itemstore.end()) 
	{
		return;
	}
	
	vec_vip_item& itemlist = it->second;
	int iSize = itemlist.size();
	int iRowSum = iSize / eCol + (iSize % eCol == 0 ? 0 : 1);
	
	if (bUp) 
	{
		if (m_iFocusLayerIndex / eCol == 0) 
		{
			if (iRowSum <= eRow ) 
			{
				m_iCurVipItemFocusRow = 0;
				m_iFocusLayerIndex = (iRowSum-1)*eCol;
			}
			else 
			{
				m_iFocusLayerIndex = m_iCurVipItemFocusRow == 0 ? (eRow-1)*eCol : 0;
				m_iCurVipItemFocusRow =  m_iCurVipItemFocusRow == 0 ? iRowSum-eRow : m_iCurVipItemFocusRow - 1;
			}
		}
		else 
		{
			m_iFocusLayerIndex = (m_iFocusLayerIndex/eCol-1)*eCol;
		}
	}
	else 
	{
		if (iRowSum <= eRow) 
		{
			if (m_iFocusLayerIndex / eCol == iRowSum -1 )
			{
				m_iFocusLayerIndex = 0;
			}
			else 
			{
				m_iFocusLayerIndex = (m_iFocusLayerIndex / eCol + 1)*eCol;
			}
			m_iCurVipItemFocusRow = 0;
		}
		else 
		{
			if (m_iFocusLayerIndex / eCol == eRow-1)
			{
				if (m_iCurVipItemFocusRow+eRow >= iRowSum) 
				{
					m_iFocusLayerIndex = 0;
					m_iCurVipItemFocusRow = 0;
				}
				else 
				{
					m_iCurVipItemFocusRow += 1;
				}

			}
			else 
			{
				m_iFocusLayerIndex = (m_iFocusLayerIndex / eCol + 1)*eCol;
			}
		}
	}
	
	UpdateGui();
}

void VipStoreScene::Reset()
{
	m_iCurVipItemFocusRow = 0;
	m_iFocusLayerIndex = 0;
}

void VipStoreScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	NDUICustomView *view = new NDUICustomView;
	view->Initialization();
	view->SetDelegate(this);
	std::vector<int> vec_id; vec_id.push_back(1);
	std::vector<std::string> vec_str; vec_str.push_back("请输入个数:");
	view->SetEdit(1, vec_id, vec_str);
	view->SetTag(dialog->GetTag());
	view->Show();
	this->AddChild(view);
	dialog->Close();
}

void VipStoreScene::OnFocusTablayer(StoreTabLayer* tablayer)
{
	for (int i = 0; i < eMaxTab; i++) 
	{
		if (!m_tabLayer[i]) 
		{
			continue;
		}
		
		if (tablayer == m_tabLayer[i]) 
		{
			m_iCurTabFocus = i;
			m_tabLayer[i]->SetTabFocus(true);
		}
		else 
		{
			m_tabLayer[i]->SetTabFocus(false);
		}
	}
	
	Reset();
	UpdateGui();
}

void VipStoreScene::OnFocusStoreItemLayer(StoreItemLayer* storeitemlayer)
{
	for (int i = 0; i < eRow*eCol; i++) 
	{
		if (m_storeitemLayer[i] == storeitemlayer) 
		{
			if (m_iFocusLayerIndex != i) 
			{
				m_storeitemLayer[m_iFocusLayerIndex]->SetStoreItemFocus(false);
				m_iFocusLayerIndex = i;
				UpdateGui();
			}
			else 
			{
				//点击产生对话框
				//NDLog(@"点击产生对话框%d", i);
				VipItem * vipitem = storeitemlayer->GetVipItem();
				if (!vipitem || !vipitem->item) 
				{
					return;
				}
				Item& item = *(vipitem->item);
				//int	iType = Item::getIdRule(item.iItemType, Item::ITEM_TYPE);
				std::vector<std::string> vec_str; vec_str.push_back("购买");
				NDUIDialog *dialog = item.makeItemDialog(vec_str);
				dialog->SetTag(item.iItemType);
				dialog->SetDelegate(this);
			}

			break;
		}
	}
}

void VipStoreScene::OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll) 
	{
		Adust(true);
	}
}

void VipStoreScene::OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll) 
	{
		Adust(false);
	}
}

void VipStoreScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

bool VipStoreScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string stramount =	customView->GetEditText(0);
	if (!stramount.empty())
	{
		VerifyViewNum(*customView);
		
		int iBuyCount = atoi(stramount.c_str());
		if(iBuyCount>100 || iBuyCount <= 0){
			customView->ShowAlert("一次最多购买100个,请重新输入");
			return false;
		}
		else
		{
			ShowProgressBar;
			NDTransData bao(_MSG_SHOP);
			bao << int(customView->GetTag()) << int(0) << (unsigned char)Item::_SHOPACT_BUY << (unsigned char)iBuyCount;
			SEND_DATA(bao);
		}
	}
	
	return true;
	
}

void VipStoreScene::UpdateMoney()
{
	if (m_imageNumMoney) 
	{
		m_imageNumMoney->SetTitleRedNumber(NDPlayer::defaultHero().eMoney);
	}
}

void VipStoreScene::SetTab(int iIndex)
{
	if (iIndex < eMaxTab && iIndex >= 0) 
	{
		Reset();
		m_iCurTabFocus = iIndex;
		m_tabLayer[m_iCurTabFocus]->SetTabFocus(true);
		UpdateGui();
	}
}





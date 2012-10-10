/*
 *  QuickItem.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "QuickItem.h"
#include "NDUIImage.h"
#include "NDUtility.h"
#include "ItemMgr.h"
#include "ItemImage.h"
#include "NDDataPersist.h"
#include "NDPlayer.h"
#include "GameScene.h"
#include "GameUIItemConfig.h"
#include <sstream>

#pragma mark 物品类型按钮

#define BKCOLOR4 (ccc4(227, 229, 218, 255))

IMPLEMENT_CLASS(NDUIItemTypeButton, NDUIButton)

NDUIItemTypeButton::NDUIItemTypeButton()
{
	m_itemType = 0;
	this->m_picItem = NULL;
	this->m_picBackGround = NULL;
}

NDUIItemTypeButton::~NDUIItemTypeButton()
{
	SAFE_DELETE(this->m_picItem);
	SAFE_DELETE(this->m_picBackGround);
}

void NDUIItemTypeButton::Initialization()
{
	NDUIButton::Initialization();
	
	this->SetTouchDownColor(ccc4(255, 255, 255, 0));
	
	this->CloseFrame();
}

void NDUIItemTypeButton::draw()
{
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	NDUIButton::draw();
	
	CGRect scrRect = this->GetScreenRect();
	
	if (m_picBackGround)
	{
		CGSize size = m_picBackGround->GetSize();
		
		m_picBackGround->DrawInRect(CGRectMake(scrRect.origin.x+(scrRect.size.width-size.width)/2,
									scrRect.origin.y+(scrRect.size.height-size.height)/2,
									size.width, size.height));
	}
	
	if (m_picItem)
	{
		CGSize size = m_picItem->GetSize();
		
		m_picItem->DrawInRect(CGRectMake(scrRect.origin.x+(scrRect.size.width-size.width)/2,
							  scrRect.origin.y+(scrRect.size.height-size.height)/2,
							  size.width, size.height));
	}
	
}

void NDUIItemTypeButton::ChangeItemType(int itemtype)
{
	if (itemtype != this->m_itemType)
	{
		this->m_itemType = itemtype;
		
		SAFE_DELETE(this->m_picItem);
		
		if (this->m_itemType > 0)
		{
			this->m_picItem = ItemImage::GetItemPicByType(this->m_itemType, true, true);
		}
	}
	
	refresh();
}

void NDUIItemTypeButton::SetBackgroundPicture(NDPicture *pic)
{
	SAFE_DELETE(m_picBackGround);
	
	m_picBackGround = pic;
}

void NDUIItemTypeButton::refresh()
{
	if (m_itemType <= 0)
	{
		if (m_picBackGround)
			m_picBackGround->SetGrayState(false);
		
		SAFE_DELETE(m_picItem);
		
		return;
	}
	
	bool gray = true;
	
	if (ItemMgrObj.GetBagItemByType(m_itemType))
	{
		gray = false;
	}
	
	if (m_picBackGround)
		m_picBackGround->SetGrayState(gray);
		
	if (m_picItem)
		m_picItem->SetGrayState(gray);
}

#pragma mark 物品类型UIImage

IMPLEMENT_CLASS(NDUIItemTypeImage, NDUIImage)

NDUIItemTypeImage::NDUIItemTypeImage()
{
	m_itemType = 0;
}

NDUIItemTypeImage::~NDUIItemTypeImage()
{
}

int NDUIItemTypeImage::GetItemType()
{
	return m_itemType;
}

void NDUIItemTypeImage::SetItemType(int itemType)
{
	m_itemType = itemType;
}


#pragma mark 快捷物品

IMPLEMENT_CLASS(QuickItem, NDUIChildrenEventLayer)

QuickItem::QuickItem()
{

	m_btnShrink = NULL;
	
	m_picShrink = NULL;
	
	m_btnConfig = m_btnSwitch = NULL;
	
	memset(m_btns, 0, sizeof(m_btns));
	
	m_layerBtnParent = NULL;
	
	m_stateShrink = false;
	
	m_keyAnimation = -1;
	
	m_uiCurPage = 2;
	
	m_imgSecondBg = NULL;
}

QuickItem::~QuickItem()
{
	SAFE_DELETE(m_picShrink);
}

void QuickItem::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	float width = 347.0f, height = 78.0f;
	
	//this->SetBackgroundColor(ccc4(125, 125, 125, 125));
		
	m_layerBtnParent = new NDUIChildrenEventLayer;
	m_layerBtnParent->Initialization();
	m_layerBtnParent->SetFrameRect(CGRectMake(0, 0, width, height));
	m_layerBtnParent->SetDragOverEnabled(true);
	m_layerBtnParent->SwallowDragOverEvent(true);
	
	this->AddChild(m_layerBtnParent);
	
	m_imgSecondBg = new NDUIImage;
	m_imgSecondBg->Initialization();
	m_imgSecondBg->EnableEvent(false);
	m_imgSecondBg->SetPicture(pool.AddPicture(GetImgPathBattleUI("quick_bar_bg2.png"), false), true);
	m_imgSecondBg->SetFrameRect(CGRectMake((width-329)/2, height-75, 329, 75));
	m_layerBtnParent->AddChild(m_imgSecondBg);
	
	NDPicture* picBack = pool.AddPicture(GetImgPathBattleUI("quick_bar_bg.png"));
	CGSize sizeBack = picBack->GetSize();
	NDUIImage *imgBack = new NDUIImage;
	imgBack->Initialization();
	imgBack->SetPicture(picBack, true);
	imgBack->EnableEvent(false);
	imgBack->SetFrameRect(CGRectMake(0, height-sizeBack.height, sizeBack.width, sizeBack.height));
	m_layerBtnParent->AddChild(imgBack);
										  
	NDUIImage* imgShrink = new NDUIImage; 
	imgShrink->Initialization();
	imgShrink->SetPicture(pool.AddPicture(GetImgPathBattleUI("bottom_shrink.png"), false), true);
	imgShrink->SetFrameRect(CGRectMake(400.0f-70, 14+height/2, 34, 22));
	imgShrink->EnableEvent(false);
	this->AddChild(imgShrink);
	
	NDUILayer* layerBtn = new NDUILayer;
	layerBtn->Initialization();
	layerBtn->SetFrameRect(CGRectMake(400.0f-72, height-34, 40, 34));
	this->AddChild(layerBtn);
	
	m_btnShrink = new NDUIButton;
	m_btnShrink->Initialization();
	m_picShrink = pool.AddPicture(GetImgPathBattleUI("handlearraw.png"), false);
	m_picShrink->Rotation(PictureRotation90);
	m_btnShrink->SetImage(m_picShrink, true, CGRectMake(12, 16, 16, 9), false);
	m_btnShrink->SetFrameRect(CGRectMake(0, 0, 40, 34));
	m_btnShrink->SetDelegate(this);
	layerBtn->AddChild(m_btnShrink);
	
	InitItemCell();
	
	float x = 23.0f;
	
	m_btnSwitch = new NDUIButton;
	m_btnSwitch->Initialization();
	m_btnSwitch->SetFrameRect(CGRectMake(x + 6 * 43+9.0f, 8.5f, 31.0f, 31.0f));
	m_btnSwitch->SetImage(pool.AddPicture(GetImgPathBattleUI("refresh_new.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnSwitch->SetFontColor(ccc4(255, 100, 0, 255));
	m_btnSwitch->SetTitle("2", false, false);
	m_btnSwitch->SetDelegate(this);
	m_layerBtnParent->AddChild(m_btnSwitch);
	
	m_btnConfig = new NDUIButton;
	m_btnConfig->Initialization();
	m_btnConfig->SetFrameRect(CGRectMake(x + 6 * 43.0f-4.0f, 39.0f, 47.0f, 39.0f));
	m_btnConfig->SetImage(pool.AddPicture(GetImgPathBattleUI("quick_item_config.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnConfig->SetFontColor(ccc4(255, 100, 0, 255));
	m_btnConfig->SetDelegate(this);
	m_layerBtnParent->AddChild(m_btnConfig);
}

void QuickItem::OnBattleBegin()
{

}

void QuickItem::InitItemCell()
{
	for (int i = 0; i < max_btn; i++) 
	{
		NDUIItemTypeButton*& btn = m_btns[i];
		btn = new NDUIItemTypeButton;
		btn->Initialization();
		btn->SetFrameRect(GetCellRect(i));
		btn->SetBackgroundPicture(GetCellBackGround(i));
		btn->SetDelegate(this);
		m_layerBtnParent->AddChild(btn);
	}
}

CGRect QuickItem::GetCellRect(unsigned int index)
{
	float x = 23.0f;
	float y = 78.0f-36.0f;
	float w = 39.0f, h = 35.0f;
	
	if (index > max_btn) return CGRectZero;
	
	if (index >= 6)
	{ 
		x += ((index-6)%6)*43;
		y = 2.0f;
		w = 40.0f;
		h = 40.0f;
	}
	else
	{
		x += (index%6)*43;
	}
	
	return CGRectMake(x, y, w, h);
}

NDPicture* QuickItem::GetCellBackGround(unsigned int index)
{
	if (index > max_btn) return NULL;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
			
	if (index < 6) 
		return pool.AddPicture(GetImgPathBattleUI("itemchildback.png"), true);
		
	return pool.AddPicture(GetImgPathBattleUI("btn_icon.png"), true);
}

void QuickItem::SetShrink(bool bShrink, bool animation/*=true*/)
{
	if (m_stateShrink == bShrink) {
		return;
	}
	
	DealShrink(animation ?  0.3f : 0.0f);
}

void QuickItem::ReverseShrink()
{
	DealShrink(0.3f);
}

bool QuickItem::IsShrink()
{
	return m_stateShrink;
}

void QuickItem::DealShrink(float time)
{
	if (!m_layerBtnParent) return;
	
	if (m_keyAnimation == (unsigned int)-1 ) 
	{
		CGRect frame = m_layerBtnParent->GetFrameRect();
		CGSize size = CGSizeZero;
		
		size.height = frame.size.height;
		
		m_keyAnimation = m_curUiAnimation.GetAnimationKey(m_layerBtnParent, size);
	}
	
	UIAnimationMove move = m_stateShrink ? UIAnimationMoveTopToBottomReverse : UIAnimationMoveTopToBottom;
		
	m_curUiAnimation.AddAnimation(m_keyAnimation, move, time);
	
	m_curUiAnimation.playerAnimation(m_keyAnimation);
	
	m_stateShrink = !m_stateShrink;
	
	if (m_picShrink)
		m_picShrink->Rotation(!m_stateShrink ? PictureRotation90 : PictureRotation270);
}

void QuickItem::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnShrink)
	{
		DealShrink(0.3f);
		
		if (m_stateShrink)
			return;
		
		GameScene* scene = (GameScene*)(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
		
		if (scene)
			scene->ShrinkQuickInteraction();
	}
	else if (button == m_btnSwitch)
	{
		if (!( (m_btns[6] && m_btns[6]->IsVisibled() && m_uiCurPage == 2) 
			    ||(m_btns[13] && m_btns[13]->IsVisibled() && m_uiCurPage == 3)
			   ) )
		{
			return;
		}
		
		int tmp = m_uiCurPage == 2 ? 3 : 2;
		
		//NDUIItemTypeButton*& btn = m_btns[tmp == 2 ? 6 : 13];
		
		//if (!btn || !btn->IsVisibled()) return;
		
		for (int i = 6; i < max_btn; i++) 
		{	
			bool visible;
			if ((i-6)/6 == 0)
				visible = tmp == 2;
			else if ((i-6)/6 == 1)
				visible = tmp == 3;
			if (m_btns[i])
				m_btns[i]->SetVisible(visible);
		}
		
		m_uiCurPage = tmp;
		
		std::stringstream ss; ss << m_uiCurPage;
		
		m_btnSwitch->SetTitle(ss.str().c_str());
		
		if (m_imgSecondBg)
			m_imgSecondBg->SetVisible(true);
	}
	else if(button == m_btnConfig)
	{
		NDDirector::DefaultDirector()->PushScene(GameMainUIItemConfigScene::Scene());
	}
	else if(button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton)))
	{
		NDUIItemTypeButton* btn = (NDUIItemTypeButton*)button;
		if (btn->GetItemType() > 0) 
		{
			Item* item = ItemMgrObj.GetBagItemByType(btn->GetItemType());
			
			if (item)
				sendItemUse(*item);
		}
	}
	
}

/*
bool QuickItem::OnButtonLongClick(NDUIButton* button)
{
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return false;
	
	int iItemType = ((NDUIItemTypeButton*)button)->GetItemType();

	NDItemType* itemtype = ItemMgrObj.QueryItemType(iItemType);
	
	if (!itemtype) return false;
	
	Item item(iItemType);
	
	showDialog(item.getItemNameWithAdd().c_str(), item.makeItemDes(false, true).c_str());
	
	return true;
}
*/

void QuickItem::Refresh()
{
	RefreshData();
	
	RefreshUI();
}

void QuickItem::RefreshData()
{
	ShowMask(false);
	
	// 已经在物品栏中的物品类型
	set<int> itemSet;
	
	// 战斗内可用物品集合
	ItemMgr& rItemMgr = ItemMgrObj;
	VEC_ITEM vBagItems;
	rItemMgr.GetCanUsableItem(vBagItems);
	
	// 战斗内物品栏设置
	NDItemBarDataPersist& itemBarSetting = NDItemBarDataPersist::DefaultInstance();
	VEC_ITEM_BAR_CELL vItemSetting;
	itemBarSetting.GetItemBarConfigOutBattle(NDPlayer::defaultHero().m_id, vItemSetting);
	
	for (int i  = 0; i < max_btn; i++) 
	{
		if (m_btns[i])
			m_btns[i]->ChangeItemType(0);
	}
	
	VEC_ITEM_BAR_CELL::iterator itItemSetting = vItemSetting.begin();
	for(; itItemSetting != vItemSetting.end(); itItemSetting++)
	{
		ItemBarCellInfo& info = *itItemSetting;
		
		if (info.nPos > max_btn) continue;
		
		if (info.idItemType > 0 && m_btns[info.nPos])
		{
			m_btns[info.nPos]->ChangeItemType(info.idItemType);
			
			itemSet.insert(info.idItemType);
		}
	}
	
	// 遍历战斗内可使用物品
	int pos = 0;
	for (VEC_ITEM::iterator itItem = vBagItems.begin(); itItem != vBagItems.end(); itItem++) 
	{
		Item* pItem = *itItem;
		if (!pItem) {
			continue;
		}
		
		if (itemSet.count(pItem->iItemType) == 0) 
		{
			// 查找空白栏位
			for (; pos < max_btn; pos++) {
				if (m_btns[pos] && m_btns[pos]->GetItemType() <= 0)
				{
					m_btns[pos]->ChangeItemType(pItem->iItemType);
					pos++;
					break;
				}
			}
		}
	}
}

void QuickItem::RefreshUI()
{
	bool second = false, third = false;
	for (int i = 6; i < max_btn; i++) 
	{		if (!(m_btns[i] && m_btns[i]->GetItemType() > 0)) continue;
			
		if ((i-6)/6 == 0)
			second = true;
		else if ((i-6)/6 == 1)
			third = true;
	}
	
	if (third == true) second = true;
	
	if (third == false && second) m_uiCurPage = 2;
	
	for (int i = 6; i < max_btn; i++) 
	{
		bool bVisible;
		if ((i-6)/6 == 0)
			bVisible = second && m_uiCurPage == 2;
		else if ((i-6)/6 == 1)
			bVisible = third && m_uiCurPage == 3;
		if (m_btns[i])
			m_btns[i]->SetVisible(bVisible);
	}
	
	if (m_btnSwitch) 
	{
		m_btnSwitch->SetVisible(third);
		
		if (third)
		{
			std::stringstream ss; ss << m_uiCurPage;
			
			m_btnSwitch->SetTitle(ss.str().c_str());
		}
	}
	
	if (m_imgSecondBg)
		m_imgSecondBg->SetVisible(second);
}

void QuickItem::ShowMask(bool show, NDPicture* pic/*=NULL*/, int itemType/*=0*/)
{
	
#define QUICK_FUNC_MASK_IMAGE_TAG (100)

#define QUICK_FUNC_MASK_LABEL_TAG (101)
	
	if (!show || itemType == 0)
	{
		if (m_layerMask)
		{
			NDUIMaskLayer *layerMask = m_layerMask.Pointer();
			SAFE_DELETE_NODE(layerMask);
		}
		
		return;
	}
	
	if (show && !pic) return;
	
	if (!m_layerMask)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (!scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
			return;
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		CGSize picsize = pic->GetSize();
		
		CGRect rectMask = CGRectMake(0, 0, winsize.width, winsize.height);
		
		NDUIMaskLayer *layerMask = new NDUIMaskLayer;
		layerMask->Initialization();
		layerMask->SetFrameRect(rectMask);
		scene->AddChild(layerMask, MAP_MASKLAYER_Z);
		
		m_layerMask = layerMask->QueryLink();
		
		CGRect rectImage = CGRectMake((rectMask.size.width-picsize.width)/2, 
									  (rectMask.size.height-picsize.height)/2, 
									  picsize.width, picsize.height);
		
		NDUIItemTypeImage *image = new NDUIItemTypeImage;
		image->Initialization();
		image->SetFrameRect(rectImage);
		image->SetTag(QUICK_FUNC_MASK_IMAGE_TAG);
		layerMask->AddChild(image);
		
		CGRect rectLabel = CGRectMake(rectImage.origin.x, 
									  rectImage.origin.y + rectImage.size.height + 20, 
									  winsize.width, winsize.height);
		
		NDUILabel *lb = new NDUILabel;
		lb->Initialization();
		lb->SetTag(QUICK_FUNC_MASK_LABEL_TAG);
		lb->SetFontSize(16);
		lb->SetTextAlignment(LabelTextAlignmentLeft);
		lb->SetFontColor(ccc4(0,0,0,255));
		lb->SetFrameRect(rectLabel);
		layerMask->AddChild(lb);
		
	}
	
	if (!m_layerMask) return;
	
	NDUIItemTypeImage *image = (NDUIItemTypeImage *)m_layerMask->GetChild(QUICK_FUNC_MASK_IMAGE_TAG);
	
	if (image && image->GetItemType() != itemType)
	{
		image->SetPicture(pic);
		
		NDUILabel *lb = (NDUILabel *)m_layerMask->GetChild(QUICK_FUNC_MASK_LABEL_TAG);
		
		NDItemType* pItemInfo = ItemMgrObj.QueryItemType(itemType);
		
		if (pItemInfo && lb)
		{
			lb->SetText(pItemInfo->m_name.c_str());
		}
		else if (!pItemInfo && lb)
		{
			lb->SetText("");
		}
	}
}

//  点击功能需要清除蒙板
bool QuickItem::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	// 不做任何处理
	return true;
}

bool QuickItem::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	// 清除蒙板
	
	ShowMask(false);
	
	return true;
}

bool QuickItem::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (!desButton->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return false;
	
	// 同点击功能
	
	ShowMask(false);
	
	OnButtonClick(desButton);
	
	return true;
}

bool QuickItem::OnButtonDragOver(NDUIButton* overButton, bool inRange)
{
	if (!overButton->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return false;
	
	NDUIItemTypeButton *itemTypeBtn = ((NDUIItemTypeButton*)overButton);
	
	// 显示蒙板
	
	ShowMask(inRange, itemTypeBtn->GetItemPicture(), itemTypeBtn->GetItemType());
	
	return true;
}

bool QuickItem::OnButtonLongClick(NDUIButton* button)
{
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return false;
	
	// 同点击功能
	ShowMask(false);
	
	OnButtonClick(button);
	
	return true;
}

bool QuickItem::OnButtonLongTouch(NDUIButton* button)
{
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return false;
	
	NDUIItemTypeButton *itemTypeBtn = ((NDUIItemTypeButton*)button);
	
	// 显示蒙板

	ShowMask(true, itemTypeBtn->GetItemPicture(), itemTypeBtn->GetItemType());
	
	return true;
}

void QuickItem::OnButtonDown(NDUIButton* button)
{
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return;
	
	NDUIItemTypeButton *itemTypeBtn = ((NDUIItemTypeButton*)button);
	
	ShowMask(true, itemTypeBtn->GetItemPicture(), itemTypeBtn->GetItemType());
}

void QuickItem::OnButtonUp(NDUIButton* button)
{
	if (!button->IsKindOfClass(RUNTIME_CLASS(NDUIItemTypeButton))) return;
	
	ShowMask(false);
}
/*
 *  ManualRoleEquipScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ManualRoleEquipScene.h"
#include "NDUIItemButton.h"
#include "NDUIMemo.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "GamePlayerBagScene.h"
#include "NDItemType.h"
#include "Item.h"
#include "ItemMgr.h"
#include "NDUtility.h"
#include "CGPointExtension.h"

IMPLEMENT_CLASS(ManualRoleNode, NDUILayer)

ManualRoleNode::ManualRoleNode()
{
	m_role = NULL;
}

ManualRoleNode::~ManualRoleNode()
{
}

void ManualRoleNode::Initialization(int lookface, int iID)
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	NDUILayer::SetFrameRect(CGRectMake(0, 0,winsize.width, winsize.height));
	
	this->SetTouchEnabled(false);
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	
	m_role = new NDManualRole;
	m_role->m_id = iID;
	m_role->Initialization(lookface);
	m_role->SetPositionEx(CGPointZero);
	this->AddChild(m_role);
}

void ManualRoleNode::draw()
{
	NDUILayer::draw();
	if (m_role) 
	{
		m_role->RunAnimation(true);
	}
}

void ManualRoleNode::packEquip(Item* equip)
{
	if (!equip || !m_role) 
	{
		return;
	}
	
	NDItemType* item = ItemMgrObj.QueryItemType(equip->iItemType);
	
	if (!item) 
	{
		return;
	}
	
	int nID = item->m_data.m_lookface;
	int quality = equip->iItemType % 10;
	
	int aniId = 0;
	if (nID > 100000) 
	{
		aniId = (nID % 100000) / 10;
	}
	if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000) 
	{// 战宠
	}
	else if (nID >= 20000 && nID < 30000 || nID > 100000)
	{// 骑宠
	}
	else 
	{
		m_role->SetEquipment(nID, quality);
	}
}

void ManualRoleNode::uppackEquip(int iPos)
{
	if (m_role) 
	{
		m_role->unpackEquip(iPos);
	}
}

void ManualRoleNode::unpackAllEquip()
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		if (i == Item::eEP_Ride) 
		{
			continue;
		}
		uppackEquip(i);
	}
}



void ManualRoleNode::setPosition(CGPoint pos)
{
	if (m_role) 
	{
		m_role->SetPositionEx(pos);
	}
}

void ManualRoleNode::setFace(bool bRight)
{
	if (m_role) 
	{
		m_role->SetSpriteDir(!bRight ? 2 : 1);
	}
}

int ManualRoleNode::getID()
{
	if (m_role) 
	{
		return m_role->m_id;
	}
	
	return 0;
}

void ManualRoleNode::Hide()
{
	this->EnableDraw(false);
}

void ManualRoleNode::Show()
{
	this->EnableDraw(true);
}

////////////////////////////////////////
class TextBGLayer : public NDUILayer
{
	DECLARE_CLASS(TextBGLayer)
public:	
	TextBGLayer();
	~TextBGLayer();
	
	void Initialization(); override
	
	void draw(); override
	
	void SetFontSize(unsigned int uisize);
	
	void SetFontColor(ccColor4B color);
	
	void SetText(std::string text);
private:
	NDUIPolygon *m_polygonCorner[4];
	NDUILine	*m_line[12];
	NDUIMemo	*m_memoText;
};

IMPLEMENT_CLASS(TextBGLayer, NDUILayer)

TextBGLayer::TextBGLayer()
{
	memset(m_polygonCorner, 0, sizeof(m_polygonCorner));
	memset(m_line, 0, sizeof(m_line));
	m_memoText = NULL;
}

TextBGLayer::~TextBGLayer()
{
}

void TextBGLayer::Initialization()
{
	NDUILayer::Initialization();
	
	SetBackgroundColor(ccc4(160, 177, 155, 255));	
	
	for (int i=0; i<4; i++)
	{
		m_polygonCorner[i] = new NDUIPolygon;
		m_polygonCorner[i]->Initialization();
		m_polygonCorner[i]->SetLineWidth(1);
		m_polygonCorner[i]->SetColor(ccc3(46, 67, 50));
		m_polygonCorner[i]->SetVisible(false);
		this->AddChild(m_polygonCorner[i],1);
	}
	
	for (int i=0; i<12; i++)
	{
		m_line[i] =  new NDUILine;
		m_line[i]->Initialization();
		m_line[i]->SetWidth(1);
		m_line[i]->SetColor(ccc3(46, 67, 50));
		m_line[i]->SetVisible(false);
		this->AddChild(m_line[i],1);
	}
	
	m_memoText = new NDUIMemo();
	m_memoText->Initialization();
	m_memoText->SetBackgroundColor(ccc4(160, 177, 155, 255));
	this->AddChild(m_memoText);
}

void TextBGLayer::draw()
{
	NDUILayer::draw();

	CGRect rect = this->GetFrameRect();
	
	int w = rect.size.width, h = rect.size.height;
	
	m_memoText->SetFrameRect(CGRectMake(8, 8, w-16, h-16));
	
	float poly[4*2] = 
	{
		0,0,
		w-4, 0,
		0, h-4,
		w-4, h-4
	};
	
	float line[26] =
	{
		1,(4+2),  //point
		6,(4+2),
		6,1,
		w-6-1,1,
		w-6-1,4+2,
		w-1-1,4+2,
		w-1-1,h-(4+2)-1,
		w-6-1,h-(4+2)-1,
		w-6-1,h-1-1,
		6,h-1-1,
		6,h-6-1,
		1,h-6-1,
		1,6,
	};
	
	for (int i=0; i<4; i++)
	{
		m_polygonCorner[i]->SetVisible(true);
		m_polygonCorner[i]->SetFrameRect(CGRectMake(poly[i*2], poly[i*2+1], 4, 4));
	}
	
	for (int i=0; i<12; i++)
	{
		m_line[i]->SetFromPoint(CGPointMake(line[i*2], line[i*2+1]));
		m_line[i]->SetToPoint(CGPointMake(line[i*2+2], line[i*2+1+2]));
		m_line[i]->SetFrameRect(CGRectMake(1, 1, 1, 1));
		m_line[i]->SetVisible(true);
	}
	
}

void TextBGLayer::SetFontSize(unsigned int uisize)
{
	if (m_memoText) 
	{
		m_memoText->SetFontSize(uisize);
	}
}

void TextBGLayer::SetFontColor(ccColor4B color)
{
	if (m_memoText) 
	{
		m_memoText->SetFontColor(color);
	}
}

void TextBGLayer::SetText(std::string text)
{
	if (m_memoText) 
	{
		m_memoText->SetText(text.c_str());
	}
}


////////////////////////////////////////

#define title_height (28)

#define text_info_x (22)
#define text_info_y (49-9)
#define text_info_w (169)
#define text_info_h (228)

#define title_x (213)
#define title_w (236)
#define title_h (23)

#define title_btn_interval (6)
#define btn_inter_w	(5)
#define btn_inter_h (5)

#define btn_w (42)
#define btn_h (42)



IMPLEMENT_CLASS(ManualRoleEquipScene, NDScene)

ManualRoleEquipScene::ManualRoleEquipScene()
{
	m_layerBG = NULL; m_layerTitleBG = NULL; m_lbTitle = NULL;
	m_imageTitle = NULL; m_picTitle = NULL; 
	memset(m_btns, 0, sizeof(m_btns));
	m_nodeManualRole = NULL; m_layerText = NULL;
	
	m_iFocusIndex = 0;
	m_itemfocus = NULL;
}

ManualRoleEquipScene::~ManualRoleEquipScene()
{
	if (m_picTitle) 
	{
		delete m_picTitle;
		m_picTitle = NULL;
	}
	
	SAFE_DELETE(m_itemfocus);
	
	ItemMgrObj.RemoveOtherItems();
}

void ManualRoleEquipScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_layerBG = new NDUIMenuLayer;
	m_layerBG->Initialization();
	this->AddChild(m_layerBG);
	
	if (m_layerBG->GetCancelBtn()) 
	{
		m_layerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUIRecttangle* bkg = new NDUIRecttangle();
	bkg->Initialization();
	bkg->SetColor(ccc4(253, 253, 253, 255));
	bkg->SetFrameRect(CGRectMake(0, m_layerBG->GetTitleHeight(), 480, m_layerBG->GetTextHeight()));
	m_layerBG->AddChild(bkg);
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picTitle->Cut(CGRectMake(0, 100, 115, 21));
	CGSize sizeTitle = m_picTitle->GetSize();
	
	m_imageTitle =  new NDUIImage;
	m_imageTitle->Initialization();
	m_imageTitle->SetPicture(m_picTitle);
	m_imageTitle->SetFrameRect(CGRectMake((winSize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_layerBG->AddChild(m_imageTitle);
	
	m_layerText = new TextBGLayer;
	m_layerText->Initialization();
	m_layerText->SetFontSize(15);
	m_layerText->SetFontColor(ccc4(0, 0, 0, 255));
	m_layerText->SetFrameRect(CGRectMake(text_info_x, text_info_y, text_info_w, text_info_h));
	m_layerBG->AddChild(m_layerText);
	
	m_layerTitleBG = new NDUILayer;
	m_layerTitleBG->Initialization();
	m_layerTitleBG->SetBackgroundColor(ccc4(64, 47, 40, 255));
	m_layerTitleBG->SetFrameRect(CGRectMake(title_x, text_info_y, title_w, title_h));
	m_layerBG->AddChild(m_layerTitleBG);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText(""); 
	m_lbTitle->SetFontSize(15); 
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbTitle->SetFrameRect(CGRectMake(0, (title_h-15)/2, title_w, 15));
	m_lbTitle->SetFontColor(ccc4(220, 216, 145,255));
	m_layerTitleBG->AddChild(m_lbTitle);

	for (int i = eMR_Begin; i < eMR_End; i++) 
	{
		int iX = 0 , iY = 0;
		iX = title_x; iY = text_info_y+title_h+title_btn_interval;
		if (i >= 0 && i <= 4) 
		{
			iX += (btn_inter_w+btn_w)*i;
		}
		if (i == 5 || i == 6) 
		{
			iX += (btn_inter_w+btn_w)*(i%5);
			iY += (btn_inter_h+btn_h);
		}
		if (i == 7 || i == 8) 
		{
			iX += (btn_inter_w+btn_w)*(i%5+1);
			iY += (btn_inter_h+btn_h);
		}
		if (i == 9 || i == 10) 
		{
			iX += (btn_inter_w+btn_w)*(i-9);
			iY += (btn_inter_h+btn_h)*2;
		}
		if (i == 11 || i == 12) 
		{
			iX += (btn_inter_w+btn_w)*(i-8);
			iY += (btn_inter_h+btn_h)*2;
		}
		if (i >= 13 && i <= 15) 
		{
			iX += (btn_inter_w+btn_w)*(i-12);
			iY += (btn_inter_h+btn_h)*3;
		}
		
		m_btns[i] = new NDUIItemButton;
		NDUIItemButton*& btn = m_btns[i];
		btn->Initialization();
		btn->SetDelegate(this);
		btn->SetFrameRect(CGRectMake(iX, iY, btn_w, btn_h));
		m_layerBG->AddChild(btn);
		btn->ChangeItem(NULL);
	}
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	m_layerBG->AddChild(m_itemfocus,1);
	if (m_btns[m_iFocusIndex])
	{
		m_itemfocus->SetFrameRect(m_btns[m_iFocusIndex]->GetFrameRect());
	}
}

void ManualRoleEquipScene::OnButtonClick(NDUIButton* button)
{
	if (m_layerBG && button == m_layerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
		return;
	}
	 
	for (int i = eMR_Begin; i < eMR_End; i++) 
	{
		if (button == m_btns[i]) 
		{
			if (m_iFocusIndex == i) 
			{
				OnSelItem(m_iFocusIndex, true);
			}
			else 
			{
				OnSelItem(i, false);
				m_iFocusIndex = i;
			}
			break;
		}
	}
}

void ManualRoleEquipScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (m_btns[m_iFocusIndex]) 
	{
		Item *item = m_btns[m_iFocusIndex]->GetItem();
		if (item) 
		{
			int comparePosition = GamePlayerBagScene::getComparePosition(item);
			Item *tempItem = ItemMgrObj.GetEquipItem(comparePosition);
			std::string tempStr = Item::makeCompareItemDes(tempItem, item, 2);
			showDialog("", tempStr.c_str());
			//dialog.setContent(null, ChatRecord.parserChat(tempStr,7)); tod
		}
	}
	
	dialog->Close();
}

void ManualRoleEquipScene::SetRole(int lookface, int iID)
{
	if (m_nodeManualRole) 
	{
		if (m_nodeManualRole->GetParent()) 
		{
			m_nodeManualRole->RemoveFromParent(true);
		}
		else
		{
			delete m_nodeManualRole;
			m_nodeManualRole = NULL;
		}
	}
	
	m_nodeManualRole = new ManualRoleNode;
	m_nodeManualRole->Initialization(lookface, iID);
	m_nodeManualRole->setPosition(ccp(329,192));
	m_nodeManualRole->Show();
	
	if (m_layerBG) 
	{
		m_layerBG->AddChild(m_nodeManualRole);
	}
}

void ManualRoleEquipScene::LoadRoleEquip(std::vector<Item*>& vec_item)
{
	if (!m_nodeManualRole) 
	{
		return;
	}
	
	m_nodeManualRole->unpackAllEquip();
	
	int iRoleID = m_nodeManualRole->getID();
	
	std::vector<Item*>::iterator it = vec_item.begin();
	for (; it != vec_item.end(); it++) 
	{
		Item *item = *it;
		if (!item || item->iOwnerID != iRoleID) 
		{
			continue;
		}
		
		m_nodeManualRole->packEquip(item);
	
		// 设置按钮
		int iPos = GetItemPos(*item);
		if (iPos != eMR_End && m_btns[iPos]) 
		{
			m_btns[iPos]->ChangeItem(item);
		}
	}
	
	OnSelItem(m_iFocusIndex, false);
}

int ManualRoleEquipScene::GetItemPos(Item& item)
{
	int iRes = eMR_End;
	switch (item.iPosition) {
		case 1: { // 头盔
			iRes = eMR_TouKui;
			break;
		}
		case 2: { // 肩膀
			iRes = eMR_HuJian;
			break;
		}
		case 3: {// 胸甲
			iRes = eMR_YiFu;
			break;
		}
		case 4: {// 护腕
			iRes = eMR_FuWang;
			break;
		}
		case 5: {// 腰带--披风
			iRes = eMR_PiFeng;
			break;
		}
		case 6: {// 护腿
			iRes = eMR_HuTui;
			break;
		}
		case 7: {// 鞋子
			iRes = eMR_XieZhi;
			break;
		}
		case 8: {// 项链
			iRes = eMR_XianLiang;
			break;
		}
		case 9: {// 耳环
			iRes = eMR_ErHuan;
			break;
		}
		case 10: {// 护符 徽记
			iRes = eMR_HuiJi;
			break;
		}
		case 11: {// 左戒指
			iRes = eMR_LRing;
			break;
		}
		case 12: {// 右戒指
			iRes = eMR_RRing;
			break;
		}
		case 13: {// 左武器
			iRes = eMR_WuQi;
			break;
		}
		case 14: {// 右武器
			iRes = eMR_FuShou;
			break;
		}
		case 80: { // 坐骑
			iRes = eMR_Ride;
			break;
		}
		case 81: { // 观赏宠物
			iRes = eMR_Pet;
			break;
		}
	}
	
	return iRes;
}

void ManualRoleEquipScene::OnSelItem(int iIndex, bool bHasFocus)
{
	if( iIndex < eMR_Begin || iIndex >= eMR_End || !m_btns[iIndex])
		return;
	
	Item *item = m_btns[iIndex]->GetItem();
	
	m_itemfocus->SetFrameRect(m_btns[iIndex]->GetFrameRect());
	
	if (!bHasFocus) 
	{
		std::string tempStr = "";
		std::string showTextStr = "";
		
		if (item != NULL) 
		{
			showTextStr = item->getItemNameWithAdd();
			tempStr = item->makeItemDes(true);
		} 
		else 
		{
			showTextStr = getEquipPositionInfo(iIndex);
		}
		
		if (m_layerText) 
		{
			m_layerText->SetText(tempStr);
		}
		
		if (m_lbTitle) {
			m_lbTitle->SetText(showTextStr.c_str());
			m_lbTitle->SetFontColor(INTCOLORTOCCC4(getItemColor(item)));
		}
	}
	else
	{
		if (item) 
		{
			std::vector<std::string> vec_str;
			int comparePosition = GamePlayerBagScene::getComparePosition(item);
			
			if (comparePosition >= 0 && ItemMgrObj.HasEquip(comparePosition)) 
			{
				vec_str.push_back("与身上装备比较");
			}
			
			NDUIDialog *dlg = item->makeItemDialog(vec_str);
			dlg->SetDelegate(this);
		}
	}
	
}

std::string ManualRoleEquipScene::getEquipPositionInfo(int index)
{
	std::string res = "";
	
	switch (index) 
	{
		case eMR_HuJian:
			res = "--护肩";
			break;
		case eMR_TouKui:
			res = "--头盔";
			break;
		case eMR_YiFu:
			res = "--衣服";
			break;
		case eMR_XianLiang:
			res = "--项链";
			break;
		case eMR_ErHuan:
			res = "--耳环";
			break;
		case eMR_PiFeng:
			res = "--披风";
			break;
		case eMR_WuQi:
			res = "--武器";
			break;
		case eMR_FuShou:
			res = "--副手";
			break;
		case eMR_HuiJi:
			res = "--徽记";
			break;
		case eMR_FuWang:
			res = "--护腕";
			break;
		case eMR_Pet:
			res = "--宠物";
			break;
		case eMR_HuTui:
			res = "--护腿";
			break;
		case eMR_XieZhi:
			res = "--鞋子";
			break;
		case eMR_LRing:
			res = "--戒指";
			break;
		case eMR_RRing:
			res = "--戒指";
			break;
		case eMR_Ride:
			res = "--坐骑";
			break;
		default:
			break;
	}
	return res;
}

Item* ManualRoleEquipScene::GetSuitItem(int idItem)
{
	for (int i = eMR_Begin; i < eMR_End; i++) 
	{
		if (m_btns[i] && m_btns[i]->GetItem()) 
		{
			Item *item = m_btns[i]->GetItem();
			if (item->iItemType/10 == idItem) 
			{
				return item;
			}
		}
	}
	
	return NULL;
}


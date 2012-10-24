/*
 *  OtherPlayerInfoScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "OtherPlayerInfoScene.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDUIItemButton.h"
#include "GameItemBag.h"
#include "ItemImage.h"
#include "ItemMgr.h"
#include "NewGamePlayerBag.h"
#include "GamePlayerBagScene.h"
#include "NDMapMgr.h"
#include "NewPetScene.h"
#include "NDPath.h"
#include "CPet.h"

enum 
{
	eBegin = 0,
	eOtherPlayerInfo = eBegin,
	eOtherPetInfo,
	eEnd,
};

OtherPlayerInfoScene* OtherPlayerInfoScene::s_instance = NULL;

IMPLEMENT_CLASS(OtherPlayerInfoScene, NDCommonScene)

OtherPlayerInfoScene::OtherPlayerInfoScene()
{
	m_tabNodeSize.width = 150;
	m_layerInfo = NULL;
	s_instance = this;
	m_layerEquip = NULL;
	m_role = NULL;
	m_lbTitle = NULL;
	m_focusCell = NULL;
	m_pUiPet = NULL;
	memset(m_cellinfoEquip, 0L, sizeof(m_cellinfoEquip));
}

OtherPlayerInfoScene::~OtherPlayerInfoScene()
{
	ItemMgrObj.RemoveOtherItems();
	s_instance = NULL;
	m_role->RemoveFromParent(false);
}

OtherPlayerInfoScene* OtherPlayerInfoScene::Scene(NDManualRole* role)
{
	OtherPlayerInfoScene *scene = new OtherPlayerInfoScene;
	
	scene->Initialization(role);
	
	sendQueryPlayer(role->m_id, SEE_PET_INFO);
	sendQueryPlayer(role->m_id, SEE_EQUIP_INFO);
	sendQueryPlayer(role->m_id, _SEE_USER_INFO);
	
	return scene;
}

void OtherPlayerInfoScene::showPlayerInfo(std::deque<string>& deqInfo)
{
	if (s_instance) {
		s_instance->ShowPlayerInfo(deqInfo);
	}
}

void OtherPlayerInfoScene::showPlayerEquip()
{
	if (s_instance) {
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			s_instance->InitEquipItemList(i, NULL);
		}
		
		VEC_ITEM& vOtherItem = ItemMgrObj.GetOtherItem();
		
		for (VEC_ITEM::iterator it = vOtherItem.begin(); it != vOtherItem.end(); it++) {
			Item* item = *it;
			s_instance->InitEquipItemList(GetItemPos(*item), item);
		}
	}
}

void OtherPlayerInfoScene::ShowPlayerInfo(std::deque<string>& deqInfo)
{
	if (m_layerInfo) {
		m_layerInfo->RemoveAllChildren(true);
		
		GLfloat fStartY = 0;
		for (std::deque<string>::iterator it = deqInfo.begin(); it != deqInfo.end(); it++) {
			const string& strInfo = *it;
			
			NDUILabel* lbInfo = new NDUILabel;
			lbInfo->Initialization();
			lbInfo->SetFontColor(ccc4(187, 19, 19, 255));
			lbInfo->SetText(strInfo.c_str());
			lbInfo->SetFrameRect(CGRectMake(0, fStartY, 190, 20));
			m_layerInfo->AddChild(lbInfo);
			fStartY += 23;
		}
		
		m_layerInfo->refreshContainer();
	}
}

void OtherPlayerInfoScene::ShowPlayerPet(OBJID idRole)
{
	if (!s_instance) return;
	
	NDUIClientLayer *client = s_instance->GetClientLayer(eOtherPetInfo);
	
	if (client)
		s_instance->InitPet(client, idRole);
}

void OtherPlayerInfoScene::Initialization(NDManualRole* role)
{
	NDCommonScene::Initialization();
	
	const char * tabtext[eEnd] = 
	{
		NDCommonCString("ViewPlayerInfo"),
		NDCommonCString("ViewPetInfo"),
	};
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	for (int i = eBegin; i < eEnd; i++) 
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(NDPath::GetImgPathNew("newui_tab_unsel.png"), 150, 31), 
						  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_sel.png"), 150, 34),
						  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = eBegin; i < eEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == eOtherPlayerInfo) 
		{
			this->InitOtherPlayerInfo(client);
			
			NDUIImage* imgLeft = new NDUIImage;
			imgLeft->Initialization();
			imgLeft->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_bg.png")), true);
			imgLeft->SetFrameRect(CGRectMake(0, 10, 203, 262));
			client->AddChild(imgLeft);
			
			NDUIImage* imgTitle = new NDUIImage;
			imgTitle->Initialization();
			imgTitle->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("title.png")), true);
			imgTitle->SetFrameRect(CGRectMake(10, 26, 8, 8));
			client->AddChild(imgTitle);
			
			m_lbTitle = new NDUILabel;
			m_lbTitle->Initialization();
			m_lbTitle->SetText(NDCommonCString("PlayerInfo"));
			m_lbTitle->SetFontSize(14);
			m_lbTitle->SetFontColor(ccc4(187, 19, 19, 255));
			m_lbTitle->SetFrameRect(CGRectMake(23, 20, 100, 20));
			client->AddChild(m_lbTitle);
			
			m_layerInfo = new NDUIContainerScrollLayer;
			m_layerInfo->Initialization();
			m_layerInfo->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("attr_role_bg.png")), true);
			m_layerInfo->SetFrameRect(CGRectMake(0, 40, 196, 220));
			client->AddChild(m_layerInfo);
			
			if (role) {
				m_layerEquip = new NDUILayer;
				m_layerEquip->Initialization();
				m_layerEquip->SetFrameRect(CGRectMake(230, 10, 210, 230));
				//m_layerEquip->SetBackgroundColor(ccc4(255, 255, 0, 255));
				client->AddChild(m_layerEquip);
				
				NDUIImage* imgRoleBg = new NDUIImage;
				imgRoleBg->Initialization();
				imgRoleBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("role_bg.png")), true);
				imgRoleBg->SetFrameRect(CGRectMake(50, 50, 91, 91));
				m_layerEquip->AddChild(imgRoleBg);
				
				m_role = new ManualRole;
				m_role->Initialization(role);
				m_role->SetOffset(CGPointMake(97, 126));
				m_layerEquip->AddChild(m_role);
			}
		}
		else if (i == eOtherPetInfo)
		{
		}
	}
	
	this->SetTabFocusOnIndex(eOtherPlayerInfo, true);
}

void OtherPlayerInfoScene::InitOtherPlayerInfo(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab* tab = new NDFuncTab;
	tab->Initialization(1, CGPointMake(202, 5));
	
	for(int j =0; j<1; j++)
	{
		TabNode* tabnode = tab->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("newui_text.png"));
		
		int startX = (j == 0 ? 18*8 : 18*9);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	client->AddChild(tab);
}

void OtherPlayerInfoScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button))
	{
		return;
	}
	
	if (button->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton))) {
		Item *item = ((NDUIItemButton*)button)->GetItem();
		if (button != m_focusCell) {
			m_focusCell = (NDUIItemButton*)button;
			std::string tempStr = "";
			std::string showTextStr = "";
			
			ccColor4B clrTitle = ccc4(187, 19, 19, 255);
			
			if (item) 
			{
				showTextStr = item->getItemNameWithAdd();
				tempStr = item->makeItemDes(true);
				clrTitle = INTCOLORTOCCC4(getItemColor(item));
				
				if (item->isItemPet())
				{
					sendQueryDesc(item->iID);
				}
			} 
			else 
			{
				showTextStr = NewPlayerBagLayer::getEquipPositionInfo(button->GetTag());
			}
			
			if (m_lbTitle) {
				m_lbTitle->SetText(showTextStr.c_str());
				m_lbTitle->SetFontColor(clrTitle);
			}
			
			if (m_layerInfo) {
				m_layerInfo->RemoveAllChildren(true);
				
				CGSize textSize;
				textSize.width = 193;
				textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(tempStr.c_str(), textSize.width, 14);
				
				NDUIText* text = NDUITextBuilder::DefaultBuilder()->Build(tempStr.c_str(), 14, textSize, ccc4(187, 19, 19, 255), false);
				
				m_layerInfo->AddChild(text);
				m_layerInfo->refreshContainer();
			}
		} else {
			if (item) 
			{
				std::vector<std::string> vec_str;
				int comparePosition = GamePlayerBagScene::getComparePosition(item);
				
				if (comparePosition >= 0 && ItemMgrObj.HasEquip(comparePosition)) 
				{
					vec_str.push_back(NDCommonCString("CompareEquipWithSelf"));
					NDUIDialog *dlg = item->makeItemDialog(vec_str);
					dlg->SetDelegate(this);
				}
			}
		}
	}
}

void OtherPlayerInfoScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (m_focusCell) 
	{
		Item *item = m_focusCell->GetItem();
		if (item) 
		{
			int comparePosition = GamePlayerBagScene::getComparePosition(item);
			Item *tempItem = ItemMgrObj.GetEquipItem(comparePosition);
			std::string tempStr = Item::makeCompareItemDes(tempItem, item, 2);
			showDialog("", tempStr.c_str());
		}
	}
	
	dialog->Close();
}

int OtherPlayerInfoScene::GetIconIndexByEquipPos(int pos)
{
	int index = -1;
	switch (pos) {
		case Item::eEP_Shoulder:
			index = 2+5*6;
			break;
		case Item::eEP_Head:
			index = 5*6;
			break;
		case Item::eEP_XianLian:
			index = 3+6;
			break;
		case Item::eEP_ErHuan:
			index = 6;
			break;
		case Item::eEP_Armor:
			index = 1+5*6;
			break;
		case Item::eEP_YaoDai:
			index = 5+5*6;
			break;
		case Item::eEP_MainArmor:
			index = 0;
			break;
		case Item::eEP_FuArmor:
			index = 5;
			break;
		case Item::eEP_Shou:
			index = 3+5*6;
			break;
		case Item::eEP_HuTui:
			index = 4+5*6;
			break;
		case Item::eEP_LeftRing:
			index = 2+6;
			break;
		case Item::eEP_RightRing:
			index = 2+6;
			break;
		case Item::eEP_HuiJi:
			index = 1+6;
			break;
		case Item::eEP_Shoes:
			index = 6*6;
			break;
		case Item::eEP_Decoration:
			index = 1+1*6;
			break;
		case Item::eEP_Ride:
			index = 1+3*6;
			break;
		default:
			break;
	}
	
	return index;
}

void OtherPlayerInfoScene::InitEquipItemList(int iEquipPos, Item* item)
{
	if (iEquipPos < Item::eEP_Begin || iEquipPos >= Item::eEP_End)
	{
		return;
	}
	
	if (!m_cellinfoEquip[iEquipPos])
	{
		int iCellX = 5, iCellY = 5 , iXInterval = 4, iYInterval = 4;
		
		if(iEquipPos >= 0 && iEquipPos <= 3)
		{
			iCellX += (ITEM_CELL_W+iXInterval)*iEquipPos;
		}
		
		if(iEquipPos == 4 )
		{
			iCellY += (ITEM_CELL_H+iYInterval)*1;
		}
		
		if(iEquipPos == 5 )
		{
			iCellX += (ITEM_CELL_W+iXInterval)*3;
			iCellY += (ITEM_CELL_H+iYInterval)*1;
		}
		
		if(iEquipPos == 6 )
		{
			iCellY += (ITEM_CELL_H+iYInterval)*2;
		}
		
		if(iEquipPos == 7 )
		{
			iCellX += (ITEM_CELL_W+iXInterval)*3;
			iCellY += (ITEM_CELL_H+iYInterval)*2;
		}
		
		if (iEquipPos >= 8 && iEquipPos <= 15) 
		{
			iCellY += (ITEM_CELL_H+iYInterval)*3;
			
			iCellX += (ITEM_CELL_W+iXInterval)*((iEquipPos-8)%4);
			iCellY += (ITEM_CELL_H+iYInterval)*((iEquipPos-8)/4);
		}
		
		NDPicture *picDefaultItem = ItemImage::GetItem(GetIconIndexByEquipPos(iEquipPos), true);
		if (picDefaultItem)
		{
			picDefaultItem->SetColor(ccc4(215, 171, 108, 150));
			picDefaultItem->SetGrayState(true);
		}
		
		m_cellinfoEquip[iEquipPos] = new NDUIItemButton;
		m_cellinfoEquip[iEquipPos]->Initialization();
		m_cellinfoEquip[iEquipPos]->SetTag(iEquipPos);
		m_cellinfoEquip[iEquipPos]->SetFrameRect(CGRectMake( iCellX+1, iCellY+1,ITEM_CELL_W-2, ITEM_CELL_H-2));
		m_cellinfoEquip[iEquipPos]->SetDelegate(this);
		m_cellinfoEquip[iEquipPos]->SetDefaultItemPicture(picDefaultItem);
		m_layerEquip->AddChild(m_cellinfoEquip[iEquipPos]);
	}
	
	m_cellinfoEquip[iEquipPos]->ChangeItem(item);
	m_cellinfoEquip[iEquipPos]->setBackDack(false);
}

void OtherPlayerInfoScene::InitPet(NDUIClientLayer* client, OBJID idRole)
{
	CGSize clientSize = client->GetFrameRect().size;
	
	m_pUiPet = new CUIPet;
	if (!m_pUiPet) {
		return;
	}

	if (!m_pUiPet->Init(idRole, 0, false)) {
		SAFE_DELETE(m_pUiPet);
		return;
	}
	
	m_pUiPet->SetFrameRect(CGRectMake(0, 0, clientSize.width, clientSize.height));
	
	client->AddChild(m_pUiPet);
	
	m_pUiPet->SetVisible(this->GetCurTabIndex() == eOtherPetInfo);
}

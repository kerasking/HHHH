/*
 *  GamePlayerBagScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GamePlayerBagScene.h"
#include "NDDirector.h"
#include "ItemMgr.h"
#include "ImageNumber.h"
#include "GameRoleNode.h"
#include "CGPointExtension.h"
#include "ItemImage.h"
#include "NDUtility.h"
#include "NDUIDialog.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDBattlePet.h"
#include "NDPlayer.h"
#include "define.h"
#include "NDString.h"
#include "EnumDef.h"
#include "NDUISynLayer.h"
#include "NDMapMgr.h"
#include "NDUISpecialLayer.h"
#include <sstream>


using namespace NDEngine;

#define PlayerBagDialog_Reapir (-2)

//////////////////////////////////////////////////////////

class NDEquipDisplayLabel : public NDUILabel
{
	DECLARE_CLASS(NDEquipDisplayLabel)
public:
	NDEquipDisplayLabel(){ m_id = -1; };
	~NDEquipDisplayLabel(){};
	void Initialization(int iID) { m_id = iID; NDUILabel::Initialization(); }  override
	int GetID(){ return m_id; }
private:
	int m_id;
};

IMPLEMENT_CLASS(NDEquipDisplayLabel, NDUILabel)

//////////////////////////////////////////////////////////

class NDPlayerBagDialog : public NDUIDialog
{
	DECLARE_CLASS(NDPlayerBagDialog)
public:
	NDPlayerBagDialog(){ m_id = -1; };
	~NDPlayerBagDialog(){};
	void Initialization(int iID) { m_id = iID; NDUIDialog::Initialization(); }  override
	int GetID(){ return m_id; }
private:
	int m_id;
};

IMPLEMENT_CLASS(NDPlayerBagDialog, NDUIDialog)

//////////////////////////////////////////////////////////

void GamePlayerBagUpdateMoney()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GamePlayerBagScene));
	
	if (scene) 
	{
		((GamePlayerBagScene*)scene)->UpdateMoney();
	}
}

#define money_image ([[NSString stringWithFormat:@"%s", GetImgPath("money.png")] UTF8String])
#define emoney_image ([[NSString stringWithFormat:@"%s", GetImgPath("emoney.png")] UTF8String])
#define bag_image ([[NSString stringWithFormat:@"%s", GetImgPath("titles.png")] UTF8String])

IMPLEMENT_CLASS(GamePlayerBagScene, NDScene)

GamePlayerBagScene::GamePlayerBagScene()
{
	m_menuLayer = NULL;
	m_itembagPlayer = NULL;
	
	m_imageNumMoney = NULL; m_imageNumEMoney = NULL;
	
	m_picMoney = NULL; m_picEMoney = NULL;
	m_imageMoney = NULL; m_imageEMoney = NULL;
	
	m_picBag = NULL; m_imageBag = NULL;
	
	m_GameRoleNode = NULL;
	m_layerRole = NULL;
	
	memset(m_cellinfoEquip, 0, sizeof(CellInfo*)*Item::eEP_End);
	
	m_iFocusIndex = -1;
	m_itemfocus = NULL;
	
	m_layerEquip = NULL;
	
	m_tlPickEquip = NULL;
	
	m_tlShare = NULL;
	
	m_toplayer = NULL;
	
	m_iShowType = SHOW_EQUIP_NORMAL;
}

GamePlayerBagScene::~GamePlayerBagScene()
{
	SAFE_DELETE(m_picMoney);
	SAFE_DELETE(m_picEMoney);
	SAFE_DELETE(m_picBag);
	
	for(int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		CellInfo* cellinfo = m_cellinfoEquip[i];
		
		if (cellinfo)
		{
			SAFE_DELETE(cellinfo->m_picBack);
			SAFE_DELETE(cellinfo->m_picItem);
			m_cellinfoEquip[i] = NULL;
		}
	}
}

GamePlayerBagScene* GamePlayerBagScene::Scene()
{
	GamePlayerBagScene* scene = new GamePlayerBagScene();	
	scene->Initialization();
	return scene;
}

void GamePlayerBagScene::Initialization(int iShowType /*= SHOW_EQUIP_NORMAL*/)
{
	if (iShowType < SHOW_EQUIP_BEGIN || iShowType >= SHOW_EQUIP_END)
	{
		NDLog(@"设置玩家背包类型出错了!!!");
		iShowType = SHOW_EQUIP_NORMAL;
	}
	
	m_iShowType = iShowType;
	
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetDelegate(this);
	m_menuLayer->SetBackgroundColor(BKCOLOR4);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUIRecttangle* bkg = new NDUIRecttangle();
	bkg->Initialization();
	bkg->SetColor(ccc4(253, 253, 253, 255));
	bkg->SetFrameRect(CGRectMake(0, m_menuLayer->GetTitleHeight(), 480, m_menuLayer->GetTextHeight()));
	m_menuLayer->AddChild(bkg);
	
	m_layerEquip = new NDUILayer;
	m_layerEquip->Initialization();
	m_layerEquip->SetFrameRect(CGRectMake(0,0, winSize.width, winSize.height-48));
	m_layerEquip->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menuLayer->AddChild(m_layerEquip);
	
	m_picMoney = NDPicturePool::DefaultPool()->AddPicture(money_image);
	m_picMoney->Cut(CGRectMake(0, 0, 16, 16)); 
	m_picEMoney = NDPicturePool::DefaultPool()->AddPicture(emoney_image);
	m_picEMoney->Cut(CGRectMake(0, 0, 16, 16));
	
	m_imageEMoney =  new NDUIImage;
	m_imageEMoney->Initialization();
	m_imageEMoney->SetPicture(m_picMoney);
	m_imageEMoney->SetFrameRect(CGRectMake(320, 8, 16, 16));
	m_menuLayer->AddChild(m_imageEMoney);
	
	m_imageMoney =  new NDUIImage;
	m_imageMoney->Initialization();
	m_imageMoney->SetPicture(m_picEMoney);
	m_imageMoney->SetFrameRect(CGRectMake(80, 8, 16, 16));
	m_menuLayer->AddChild(m_imageMoney);

	NDPlayer& player = NDPlayer::defaultHero();
	m_imageNumEMoney = new ImageNumber;
	m_imageNumEMoney->Initialization();
	m_imageNumEMoney->SetTitleRedNumber(player.eMoney);
	m_imageNumEMoney->SetFrameRect(CGRectMake(108, 8, 60, 11));
	m_menuLayer->AddChild(m_imageNumEMoney);
	
	m_imageNumMoney = new ImageNumber;
	m_imageNumMoney->Initialization();
	m_imageNumMoney->SetTitleRedNumber(player.money);
	m_imageNumMoney->SetFrameRect(CGRectMake(348, 8, 60, 11));
	m_menuLayer->AddChild(m_imageNumMoney);
	
	m_picBag = NDPicturePool::DefaultPool()->AddPicture(bag_image);
	m_picBag->Cut(CGRectMake(240, 160, 36, 19));
	CGSize sizeBag = m_picBag->GetSize();
	
	m_imageBag =  new NDUIImage;
	m_imageBag->Initialization();
	m_imageBag->SetPicture(m_picBag);
	m_imageBag->SetFrameRect(CGRectMake((winSize.width-sizeBag.width)/2, 6, sizeBag.width, sizeBag.height));
	m_menuLayer->AddChild(m_imageBag);
	
	
	m_layerRole = new NDUILayer;
	m_layerRole->Initialization();
	m_layerRole->SetFrameRect(CGRectMake(58, 84, 89, 89));
	m_layerRole->SetBackgroundColor(BKCOLOR4);
	m_menuLayer->AddChild(m_layerRole);
	
	m_GameRoleNode = new GameRoleNode;
	m_GameRoleNode->Initialization();
	//以下两行固定用法
	m_GameRoleNode->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	m_GameRoleNode->SetDisplayPos(ccp(92+8,136+16));
	m_layerRole->AddChild(m_GameRoleNode);
	
	UpdateEquipList();

	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	m_itembagPlayer = new GameItemBag;
	m_itembagPlayer->Initialization(itemlist);
	m_itembagPlayer->SetDelegate(this);
	m_itembagPlayer->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itembagPlayer->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menuLayer->AddChild(m_itembagPlayer);
	
	if (m_iShowType == SHOW_EQUIP_REPAIR && itemlist.size() >=1 )
	{
		m_itembagPlayer->SetTitle(getRepairDesc(itemlist[0]));
	}
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	m_itemfocus->SetFrameRect(CGRectZero);
	this->AddChild(m_itemfocus,1);
	
	m_toplayer = new NDUITopLayer;
	m_toplayer->Initialization();
	m_toplayer->SetFrameRect(CGRectMake(0,0, winSize.width, winSize.height-48));
	this->AddChild(m_toplayer, 2);
	
	do
	{
		m_tlShare = new NDUITableLayer;
		m_tlShare->Initialization();
		m_tlShare->VisibleSectionTitles(false);
		m_tlShare->SetDelegate(this);
		m_tlShare->SetVisible(false);
		m_toplayer->AddChild(m_tlShare);
	} while (0);
	
	do
	{
		m_tlPickEquip = new NDUITableLayer;
		m_tlPickEquip->Initialization();
		m_tlPickEquip->VisibleSectionTitles(false);
		m_tlPickEquip->SetDelegate(this);
		m_tlPickEquip->SetVisible(false);
		m_toplayer->AddChild(m_tlPickEquip);
	} while (0);
}

void GamePlayerBagScene::OnClickPage(GameItemBag* itembag, int iPage)
{
	if (itembag == m_itembagPlayer)
	{
		//if (iPage >= ItemMgrObj.GetPlayerBagNum())
//		{
//			stringstream ss; ss << "要开通背包" << (iPage+1) << "需要花费";
//			if (iPage == 1) {
//				ss << 200;
//			} else if (iPage == 2) {
//				ss << 500;
//			} else if (iPage == 3) {
//				ss << 1000;
//			}
//			
//			ss << "个元宝";
//			
//			m_bagOPInfo.operate = bag_cell_info::e_op_kaitong;
//			m_bagOPInfo.iIndex = iPage;
//			NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
//			dlg->Initialization(0);
//			dlg->SetDelegate(this);
//			dlg->Show("", ss.str().c_str(), "取消", "确定", NULL);
//		}
	}
}
/**bFocus,表示该事件发生前该Cell是否处于Focus状态*/
bool GamePlayerBagScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (m_iFocusIndex != -1)
	{
		m_iFocusIndex = -1;
		m_itemfocus->SetFrameRect(CGRectZero);
	}
	
	if (itembag == m_itembagPlayer && item && bFocused) 
	{
		m_bagOPInfo.set(iCellIndex, item);
//		m_tlShare->SetVisible(true);
		// 根据物品的类型组合操作选项
		
		if( m_iShowType == SHOW_EQUIP_REPAIR)
		{
			std::vector<std::string> vec_str;
			if (item->isEquip())
			{
				vec_str.push_back(std::string("修理当前装备"));
			}
			vec_str.push_back(std::string("修理全部已装备物品"));
			InitTLContentWithVec(m_tlShare, vec_str);
			if (m_itembagPlayer)
			{
				m_itembagPlayer->SetTitle(getRepairDesc(item));
			}
			return true;
		}
	
		std::vector<std::string> vec_str;
		std::string temp;
		
		if (!item->isEquip() && item->isItemCanUse()) {
			temp = "使用";
		}
		// 技能书或配方
		if (item->isSkillBook()
			|| (item->isFormulaExt() && temp == "使用")) {
			temp = "学习";
		}
		
		vec_str.push_back(std::string("查看"));
		
		if (item->canInlay()) {
			vec_str.push_back(std::string("镶嵌"));
		}
		if (item->iItemType == Item::REVERT && item->active == false) {
			vec_str.push_back(std::string("激活"));
		}
		if (!temp.empty()) {
			vec_str.push_back(temp);
		}
		// 装备
		//if (isCampMark(item.itemType)) {
//			opsA.addElement(zhuangBei);
//		} else
		{
			if (item->isEquip()) { // 装备
				vec_str.push_back(std::string("装备"));
				if (HasCompareEquipPosition(item))
				{
					vec_str.push_back(std::string("与身上装备比较"));
				}
			}
		}
		
		if(item->byBindState != BIND_STATE_BIND && 
		   (item->isEquip()
		   || item->isRidePet()
		   ||item->isItemPet())
		   )
		{
			vec_str.push_back(std::string("永久绑定"));
		}
		
		//opsA.addElement(yidongT);
		vec_str.push_back(std::string("丢弃"));
		
		// 可叠加物品
		if (item->canChaiFen() && !item->isRidePet())
		{
			vec_str.push_back(std::string("拆分"));
		}
		
		vec_str.push_back(std::string("整理背包"));
		
		InitTLContentWithVec(m_tlShare, vec_str);
	}
	
	
	if (item)
	{
		if (m_iShowType == SHOW_EQUIP_REPAIR)
		{
			m_itembagPlayer->SetTitle(getRepairDesc(item));
		}
		else
		{
			m_itembagPlayer->SetTitle(item->getItemDesc());
		}
	}
	else 
	{
		m_itembagPlayer->SetTitle("");
	}

	
	
	
	return true;
}

void GamePlayerBagScene::OnButtonClick(NDUIButton* button)
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		if (!m_cellinfoEquip[i])
		{
			InitEquipItemList(i, NULL);
		}
		
		if (!m_cellinfoEquip[i]->button)
		{
			continue;
		}
		
		if ( button == m_cellinfoEquip[i]->button )
		{
			if (m_iFocusIndex == i)
			{
				// 前一状态已获得焦点
				if (m_cellinfoEquip[i]->item)
				{
					hasEquipItem(m_cellinfoEquip[i]->item, i);
				}
				else
				{
					notHasEquipItem(i);
				}
			}
			else 
			{
				// 前一状态未获得焦点
				if( m_cellinfoEquip[i]->item )
				{
					if (m_iShowType == SHOW_EQUIP_REPAIR)
					{
						m_itembagPlayer->SetTitle(getRepairDesc(m_cellinfoEquip[i]->item));
					}
					else
					{
						m_itembagPlayer->SetTitle(m_cellinfoEquip[i]->item->getItemDesc());
					}
				}
				else 
				{
					m_itembagPlayer->SetTitle(getEquipPositionInfo(i));
				}
			}
				
			m_iFocusIndex = i;
			
			if (m_itemfocus && m_cellinfoEquip[i] && m_cellinfoEquip[i]->button)
			{
				m_itemfocus->SetFrameRect(m_cellinfoEquip[i]->button->GetFrameRect());
			}
			
			if (m_itembagPlayer)
			{
				m_itembagPlayer->DeFocus();
			}
			
			return;
		}
	}
	
	if (m_menuLayer)
	{
		if (m_menuLayer->GetCancelBtn() == button) 
		{
			if (m_tlShare->IsVisibled() || m_tlPickEquip->IsVisibled())
			{
				ResetTopTLLayer(true);
				return;
			}
			NDDirector::DefaultDirector()->PopScene();
		}
	}
}

void GamePlayerBagScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	bool bResetInfo = true;
	if (table == m_tlShare)
	{
		if (m_bagOPInfo.empty() && m_equipOPInfo.empty()) return;
		
		if (!cell || !cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			return;
		}
		
		NDUIButton *btn = (NDUIButton*)cell;
		std::string strlabel = btn->GetTitle();
		
		if (strlabel == "查看")
		{
			if (m_bagOPInfo.item->isFormula() || m_bagOPInfo.item->isItemPet() || m_bagOPInfo.item->isSkillBook())
			{
				sendQueryDesc(m_bagOPInfo.item->iID);
			} 
			else
			{
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				std::string strtmp = m_bagOPInfo.item->makeItemDes(false, true);
				// ChatRecordManager.parserChat(strtmp, -1)
				dlg->Show(m_bagOPInfo.item->getItemNameWithAdd().c_str(), strtmp.c_str(), NULL, NULL);
			}
		}
		
		if (strlabel == "使用")
		{
			m_bagOPInfo.operate = bag_cell_info::e_op_use;
			bResetInfo = false;
			NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
			dlg->Initialization(m_bagOPInfo.item->iID);
			dlg->SetDelegate(this);
			stringstream ss;
			ss << "确定要使用'" << m_bagOPInfo.item->getItemName() << "'吗";
			dlg->Show("提示", ss.str().c_str(), "取消", "确定", NULL);
		}
		
		if (strlabel == "学习")
		{
			if (m_bagOPInfo.item->iAmount > 0)
			{
				if (m_bagOPInfo.item->isItemUseReminder())
				{
					m_bagOPInfo.operate = bag_cell_info::e_op_xuexi;
					bResetInfo = false;
					
					NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
					dlg->Initialization(m_bagOPInfo.item->iID);
					dlg->SetDelegate(this);
					stringstream ss;
					ss << "确定要学习'" << m_bagOPInfo.item->getItemName() << "'吗";
					dlg->Show("提示", ss.str().c_str(), "取消", "确定", NULL);
				}
				else 
				{
					ItemMgrObj.UseItem(m_bagOPInfo.item);
				}

			}
		}
		
		if (strlabel == "镶嵌")
		{
			int itemType = m_bagOPInfo.item->iItemType;
			bool stone = itemType / 100000 == 290;
			
			int equipType = (itemType / 100000) % 100;
			
			std::vector<Item*> vec_item_res;
			std::vector<Item*> vec_item = ItemMgrObj.GetPlayerBagItems();
			std::vector<Item*>::iterator it = vec_item.begin();
			for (; it != vec_item.end(); it++)
			{
				Item *item = (*it);
				if (item == NULL)
				{
					continue;
				}
				if (stone) {
					if (item->canInlay()) {
						vec_item_res.push_back(item);
					}
				} else if (item->iItemType / 100000 == 290) {
					bool bAdd = false;
					int stoneType = (item->iItemType / 1000) % 100;
					if (equipType < 40 && stoneType == 1) { // 武器
						bAdd = true;
					} else if (equipType == stoneType) { // 其他装备位
						bAdd = true;
					}
					if (bAdd) {
						vec_item_res.push_back(item);
					}
				}
			}
			
			if ( vec_item_res.size() == 0 )
			{
				//stone ? "没有可镶嵌的装备" : "没有可镶嵌的宝石"
			}
			 
			GameInlayScene* scene = new GameInlayScene();	
			scene->Initialization(m_bagOPInfo.item->iID, m_bagOPInfo.item->iItemType);
			NDDirector::DefaultDirector()->PushScene(scene);
		}

		if (strlabel == "激活")
		{
			m_bagOPInfo.item->active = true;
		}
		
		if (strlabel == "装备")
		{
			if (checkItemLimit(m_bagOPInfo.item, true))
			{
				ItemMgrObj.UseItem(m_bagOPInfo.item);
			}
		}
		
		if (strlabel == "与身上装备比较")
		{
			int comparePosition = getComparePosition(m_bagOPInfo.item);
			Item *tempItem = m_cellinfoEquip[comparePosition]->item;
			std::string tempStr = Item::makeCompareItemDes(tempItem, m_bagOPInfo.item, -1);
			// ChatRecordManager.parserChat(tempStr, -1)
			NDUIDialog *dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->Show("比较", tempStr.c_str(), NULL, NULL);
		}
		
		if (strlabel == "永久绑定") 
		{
			m_bagOPInfo.operate = bag_cell_info::e_op_bind;
			bResetInfo = false;
			
			NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
			dlg->Initialization(m_bagOPInfo.item->iID);
			dlg->SetDelegate(this);
			dlg->Show("提示", "物品将被永久绑定，只可以自己使用、丢弃或者向商店出售。请确认是否绑定？", "取消", "确定", NULL);
		}
		
		if (strlabel == "丢弃")
		{
			// 不允许丢弃
			//if (FreshmanTaskManager.BEGIN_FRESHMAN_TASK) {任务相关
//				GameScreen.getInstance().initNewChat(
//													 new ChatRecordManager(5, "系统",
//																	FreshmanTaskManager.NOT_ALLOWED_DISCARD));
//				break;
//			}
			
			if (m_bagOPInfo.item->isItemDropReminder())
			{
				m_bagOPInfo.operate = bag_cell_info::e_op_drop;
				bResetInfo = false;
				
				NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
				dlg->Initialization(m_bagOPInfo.item->iID);
				dlg->SetDelegate(this);
				dlg->Show("丢弃", "丢弃的物品将无法取回，确认丢弃？", "取消", "确定", NULL);
			}
			else 
			{
				sendDropItem(*(m_bagOPInfo.item));
			}
		}
		
		if (strlabel == "拆分")
		{
			m_bagOPInfo.operate = bag_cell_info::e_op_caifeng;
			bResetInfo = false;
			
			stringstream ss;
			ss << "当前数量:" << m_bagOPInfo.item->iAmount << ", " << "请输入要拆分的数量:";
			NDUICustomView *view = new NDUICustomView;
			view->Initialization();
			view->SetDelegate(this);
			std::vector<int> vec_id; vec_id.push_back(1);
			std::vector<std::string> vec_str; vec_str.push_back(ss.str());
			view->SetEdit(1, vec_id, vec_str);
			view->Show();
			this->AddChild(view);
		}
		
		if (strlabel == "整理背包")
		{
			if (NDPlayer::defaultHero().IsInState(USERSTATE_BOOTH))
			{
				showDialog("提示", "摆摊时不能整理背包");
			}else
			{
				ShowProgressBar;
				NDTransData bao(_MSG_TIDY_UP_BAG);
				SEND_DATA(bao);
			}
		}
		
		if (strlabel == "修理当前装备")
		{
			//背包与装备都有可能跑到这
			if (!m_bagOPInfo.empty())
			{
				repairItem(m_bagOPInfo.item);
			}
			
			if (!m_equipOPInfo.empty())
			{
				repairItem(m_equipOPInfo.item);
			}
		}
		
		if (strlabel == "修理全部已装备物品")
		{
			//背包与装备都有可能跑到这
			if (!m_bagOPInfo.empty())
			{
				repairAllItem();
			}
			
			if (!m_equipOPInfo.empty())
			{
				repairAllItem();
			}
		}
	}
	
	if (table == m_tlPickEquip)
	{
		if (cell && cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
		{
			int iItemID = cell->GetTag();
			if (iItemID == -1)
			{
				m_tlPickEquip->SetVisible(false);
				return;
			}
			
			std::vector<Item*> vec_item = ItemMgrObj.GetPlayerBagItems();
			std::vector<Item*>::iterator it = vec_item.begin();
			for (; it != vec_item.end(); it++)
			{
				if ((*it) && (*it)->iID == iItemID)
				{
					ItemMgrObj.UseItem(*it);
					break;
				}
			}
		}
	}
	
	ResetTopTLLayer(bResetInfo);
}

void GamePlayerBagScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog && dialog->IsKindOfClass(RUNTIME_CLASS(NDPlayerBagDialog)))
	{ //卸下装备
		NDPlayerBagDialog *dlg = (NDPlayerBagDialog*)dialog;
		if (dlg->GetID() == PlayerBagDialog_Reapir)
		{
			//修理所有装备
			sendItemRepair(0, Item::_ITEMACT_REPAIR_ALL);
			dialog->Close();
			return;
		}
		
		if (m_bagOPInfo.operate == bag_cell_info::e_op_kaitong) 
		{
			ShowProgressBar;
			NDTransData bao(_MSG_LIMIT);
			bao << (unsigned char)(1);
			SEND_DATA(bao);
		}
		else if (!m_equipOPInfo.empty())
		{
			ShowProgressBar;
			NDTransData bao(_MSG_ITEM);
			bao << int(m_equipOPInfo.item->iID) << (unsigned char)(Item::ITEM_UNEQUIP);
			SEND_DATA(bao);
		}
		else if (!m_bagOPInfo.empty())
		{
			if (m_bagOPInfo.operate == bag_cell_info::e_op_use)
			{ //使用物品
				ItemMgrObj.UseItem(m_bagOPInfo.item);
			}
			else if (m_bagOPInfo.operate == bag_cell_info::e_op_drop)
			{ // 丢弃物品
				sendDropItem(*(m_bagOPInfo.item));
			}
			else if (m_bagOPInfo.operate == bag_cell_info::e_op_xuexi)
			{ // 学习物品
				ItemMgrObj.UseItem(m_bagOPInfo.item);
			}
			else if (m_bagOPInfo.operate == bag_cell_info::e_op_bind)
			{ // 绑定物品
				NDTransData bao(_MSG_EQUIP_BIND);
				bao << (unsigned char)0 << int(m_bagOPInfo.item->iID);
				SEND_DATA(bao);
			}
		}
	}
	dialog->Close();
}
void GamePlayerBagScene::OnDialogClose(NDUIDialog* dialog)
{
	ResetTopTLLayer(true);
}

bool GamePlayerBagScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	if(!m_bagOPInfo.empty() && customView)
	{
		if (m_bagOPInfo.operate == bag_cell_info::e_op_caifeng)
		{
			VerifyViewNum(*customView);
			
			std::string stramount =	customView->GetEditText(0);
			if (!stramount.empty())
			{
				int chaiFenNum = atoi(stramount.c_str());
				if (chaiFenNum <= 0 || chaiFenNum >= m_bagOPInfo.item->iAmount) {
					//T.gotoAlert("物品数量不合法", "请重新输入", 2000);
					customView->ShowAlert("物品数量不合法, 请重新输入");
					return false;
				}
				
				ShowProgressBar;
				NDTransData bao(_MSG_SPLIT_ITEM);
				bao << int(m_bagOPInfo.item->iID) << (unsigned short)(chaiFenNum);
				SEND_DATA(bao);
			}
		}
	}
	ResetTopTLLayer(true);
	return true;
}

void GamePlayerBagScene::OnCustomViewCancle(NDUICustomView* customView)
{
	ResetTopTLLayer(true);
}

void GamePlayerBagScene::UpdateEquipList()
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
	{
		InitEquipItemList(i, ItemMgrObj.GetEquipItemByPos(Item::eEquip_Pos(i)));
	}
	//if (m_itembagPlayer)
//	{
//		m_itembagPlayer->UpdateItemBag(ItemMgrObj.GetPlayerBagItems());
//	}
}

void GamePlayerBagScene::UpdateBag()
{ 
	if (!m_itembagPlayer) return;
	m_itembagPlayer->UpdateItemBag(ItemMgrObj.GetPlayerBagItems());
}

void GamePlayerBagScene::UpdateMoney()
{	
	NDPlayer& player = NDPlayer::defaultHero();
	if (m_imageNumMoney)
		m_imageNumMoney->SetTitleRedNumber(player.money);
	if (m_imageNumEMoney)
		m_imageNumEMoney->SetTitleRedNumber(player.eMoney);
}

void GamePlayerBagScene::updateCurItem()
{
	if (m_iFocusIndex != -1 && m_itembagPlayer && m_itembagPlayer->IsFocus())
	{
		NDLog(@"updateCurItem出错,出现背包与装备同时处于焦点状态!!!");
	}
	
	if (!m_itembagPlayer)
	{
		NDLog(@"updateCurItem出错,背包指针为空!!!");
	}
	
	if (m_iFocusIndex != -1
		&& m_cellinfoEquip[m_iFocusIndex])
	{
		
		if( m_cellinfoEquip[m_iFocusIndex]->item )
		{
			if (m_iShowType == SHOW_EQUIP_REPAIR)
			{
				m_itembagPlayer->SetTitle(getRepairDesc(m_cellinfoEquip[m_iFocusIndex]->item));
			}
			else
			{
				m_itembagPlayer->SetTitle(m_cellinfoEquip[m_iFocusIndex]->item->getItemDesc());
			}
		}
		else 
		{
			m_itembagPlayer->SetTitle(getEquipPositionInfo(m_iFocusIndex));
		}

	}
	
	if (m_itembagPlayer && m_itembagPlayer->IsFocus())
	{
		m_itembagPlayer->UpdateTitle();
	}
}
		
std::string GamePlayerBagScene::getEquipPositionInfo(int index)
{
	// //0肩 1头 2胸 3项链 4耳环 5腰带--披风 6主武器 7无 8副武 9徽记 10手 11宠物 12护腿 13无 14鞋子
	// 15左戒指
	// 16右戒指
	// 17坐骑
	switch (index) {
		case Item::eEP_Shoulder: {
			return "--护肩";
		}
		case Item::eEP_Head: {
			return "--头盔";
		}
		case Item::eEP_Armor: {
			return "--衣服";
		}
			
		case Item::eEP_XianLian: {
			return "--项链";
		}
		case Item::eEP_ErHuan: {
			return "--耳环";
		}
		case Item::eEP_YaoDai: {
			return "--披风";// 腰带
		}
			
		case Item::eEP_MainArmor: {
			return "--武器";
		}
		case Item::eEP_FuArmor: {
			return "--副手";
		}
		case Item::eEP_HuiJi: {
			return "--徽记";
		}
		case Item::eEP_Shou: {
			return "--护腕";
		}
		case Item::eEP_Decoration: {
			return "--勋章";
		}
		case Item::eEP_HuTui: {
			return "--护腿";
		}
		case Item::eEP_Shoes: {
			return "--鞋子";
		}
		case Item::eEP_LeftRing: {
			return "--戒指";
		}
		case Item::eEP_RightRing: {
			return "--戒指";
		}
		case Item::eEP_Ride: {
			return "--坐骑";
		}
	}
	return "";
}

void GamePlayerBagScene::ResetTopTLLayer(bool bResetInfo)
{
	if (m_tlShare) m_tlShare->SetVisible(false);
	if (m_tlPickEquip) m_tlPickEquip->SetVisible(false);
	
	if (bResetInfo)
	{
		m_equipOPInfo.reset();
		m_bagOPInfo.reset();
	}
}

void GamePlayerBagScene::InitEquipItemList(int iEquipPos, Item* item)
{
	if (iEquipPos < Item::eEP_Begin || iEquipPos >= Item::eEP_End)
	{
		NDLog(@"玩家背包,装备列表初始化失败,装备位[%d]!!!", iEquipPos);
		return;
	}
	
	if (!m_cellinfoEquip[iEquipPos])
	{
		m_cellinfoEquip[iEquipPos] = new CellInfo;
	}
	
	m_cellinfoEquip[iEquipPos]->item = item;
	
	if (!item)
	{
		if (m_cellinfoEquip[iEquipPos]->m_picItem)
		{
			delete m_cellinfoEquip[iEquipPos]->m_picItem;
			m_cellinfoEquip[iEquipPos]->m_picItem = NULL;
		}
	}
	
	NDUIButton*& btn	= m_cellinfoEquip[iEquipPos]->button;
	NDPicture*& picBack = m_cellinfoEquip[iEquipPos]->m_picBack;
	NDPicture*& picItem = m_cellinfoEquip[iEquipPos]->m_picItem;
	NDUILayer*& backDack = m_cellinfoEquip[iEquipPos]->backDackLayer;
	NDUIImage*& imgBack = m_cellinfoEquip[iEquipPos]->m_imgBack;
	
	if (btn) 
	{
		m_cellinfoEquip[iEquipPos]->setBackDack(false);
	}
	
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
			picItem = ItemImage::GetItem(iIconIndex);
		}
	}
	
	if (!btn)
	{
		int iCellX = 11, iCellY = 35 , iXInterval = 5, iYInterval = 6;
		
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
		
		picBack = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("ui_item.png"));
		
		if (!imgBack) 
		{
			imgBack = new NDUIImage;
			imgBack->Initialization();
			imgBack->SetPicture(picBack);
			imgBack->SetFrameRect(CGRectMake(iCellX, iCellY,ITEM_CELL_W, ITEM_CELL_H));
			m_layerEquip->AddChild(imgBack);
		}
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetDelegate(this);
		btn->SetFrameRect(CGRectMake( iCellX+1, iCellY+1,ITEM_CELL_W-2, ITEM_CELL_H-2));
		if (m_layerEquip)
		{
			m_layerEquip->AddChild(btn);
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
//		btn->SetImage(picBack);
//		btn->SetBackgroundColor(BKCOLOR4);
		btn->SetBackgroundPicture(NULL, NULL, true);
	}	
	btn->SetVisible(picItem != NULL);
	
	if (item) 
	{
		//roleequipok
		if (item->iAmount == 0) 
		{
			ItemMgrObj.SetRoleEuiptItemsOK(true, iEquipPos);
			m_cellinfoEquip[iEquipPos]->setBackDack(true);
			//T.roleEuiptItemsOK[i] = 1;
		}
		if (iEquipPos == Item::eEP_Ride) 
		{
			if (item->sAge == 0) 
			{
				//T.roleEuiptItemsOK[i] = 1;
				ItemMgrObj.SetRoleEuiptItemsOK(true, iEquipPos);
				m_cellinfoEquip[iEquipPos]->setBackDack(true);
			}
		}
	}
}

void GamePlayerBagScene::InitTLContent(NDUITableLayer* tl, const char* text, ...)
{
	if (!tl)
	{
		return;
	}
	
	va_list argumentList;
	char *eachObject;
	std::vector<std::string> vectext; 
	if (text)
	{
		vectext.push_back(std::string(text));
		va_start(argumentList, text);
		while ((eachObject = va_arg(argumentList, char*))) 
		{
			vectext.push_back(std::string(eachObject));
		}
		va_end(argumentList);
	}
	if (vectext.empty())
	{
		return;
	}

	InitTLContentWithVec(tl, vectext);
}

void GamePlayerBagScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str)
{
#define fastinit(text) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
button->SetFontColor(ccc4(38,59,28,255)); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);
		
	if (!tl || vec_str.empty())
	{
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::iterator it = vec_str.begin();
	for (; it != vec_str.end(); it++)
	{
		fastinit(((*it).c_str()))
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

void GamePlayerBagScene::InitTLContentWithVecEquip(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
		NDLog(@"GamePlayerBagScene::InitTLContentWithVecEquip初始化失败");
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

bool GamePlayerBagScene::HasCompareEquipPosition(Item* otheritem)
{
	if (!otheritem) 
	{
		return false;
	}
	
	int comparePosition = getComparePosition(otheritem);
	if (   (comparePosition >= 0)
		&& (m_cellinfoEquip[comparePosition])
		&& (m_cellinfoEquip[comparePosition]->item) 
		) 
	{
		return true;
	}
	
	return false;
}

int GamePlayerBagScene::getComparePosition(Item* item)
{
	if (!item)
	{
		return -1;
	}
	
	int type = Item::getIdRule(item->iItemType, Item::ITEM_TYPE);
	if (type != 0) { // 0装备,1宠物
		return -1;
	}
	
	int item_equip = Item::getIdRule(item->iItemType, Item::ITEM_EQUIP);
	int item_class = Item::getIdRule(item->iItemType, Item::ITEM_CLASS);
	
	// 0肩
	if ((type == 0) && (item_equip == 4) && (item_class == 2)) {
		return Item::eEP_Shoulder;
	}
	// 1头
	if ((type == 0) && (item_equip == 4) && (item_class == 1)) {
		return Item::eEP_Head;
	}
	// 2胸
	if ((type == 0) && (item_equip == 4) && (item_class == 3)) {
		return Item::eEP_Armor;
	}
	// 3项链
	if ((type == 0) && (item_equip == 5) && (item_class == 1)) {
		return Item::eEP_XianLian;
	}
	// 4耳环
	if ((type == 0) && (item_equip == 5) && (item_class == 2)) {
		return Item::eEP_ErHuan;
	}
	// 5腰带--披风
	if ((type == 0) && (item_equip == 4) && (item_class == 5)) {
		return Item::eEP_YaoDai;
	}
	// 6主武器
	if ((type == 0) && (item_equip == 1)) { // 双手
		return Item::eEP_MainArmor;
	}
	// 8副武
	if ((type == 0) && (item_equip == 3)) { // 盾牌或法器
		return Item::eEP_FuArmor;
	}
	
	if ((type == 0) && (item_equip == 2)) { // 特殊, 单手武器,可能在主手也可能在副手
		//if ((T.roleEuiptItems[6] != null)
//			&& (T.roleEuiptItems[6].getItem() != null)) { // 主手优先比较
//			return 6;
//		} else if ((T.roleEuiptItems[8] != null)
//				   && (T.roleEuiptItems[8].getItem() != null)) {// 副手有单手武器
//			return 8;
//		} else {
//			return 6;
//		}
		
		Item*  mainarmor = ItemMgrObj.GetEquipItemByPos(Item::eEP_MainArmor);
		Item*  fuarmor = ItemMgrObj.GetEquipItemByPos(Item::eEP_FuArmor);
		
		if (mainarmor) { // 主手优先比较
			return Item::eEP_MainArmor;
		} else if (fuarmor) {// 副手有单手武器
			return Item::eEP_FuArmor;
		} else {
			return Item::eEP_MainArmor;
		}
	}
	
	// 9徽记
	if ((type == 0) && (item_equip == 5) && (item_class == 3)) {
		return Item::eEP_HuiJi;
	}
	// 10手
	if ((type == 0) && (item_equip == 4) && (item_class == 4)) {
		return Item::eEP_Shou;
	}
	// 11勋章
	if ((type == 1) && (item_equip == 1)) {
		return Item::eEP_Decoration;
	}
	// 12护腿
	if ((type == 0) && (item_equip == 4) && (item_class == 6)) {
		return Item::eEP_HuTui;
	}
	// 14鞋子
	if ((type == 0) && (item_equip == 4) && (item_class == 7)) {
		return Item::eEP_Shoes;
	}
	// 15左戒指 16右戒指
	if ((type == 0) && (item_equip == 5) && (item_class == 4)) {
		return Item::eEP_LeftRing;
	}
	// 17坐骑
	if ((type == 1) && (item_equip == 2)) {
		return Item::eEP_RightRing;
	}
	
	return -1;
}

void GamePlayerBagScene::notHasEquipItem(int iPos)
{
	if (iPos < Item::eEP_Begin || iPos >= Item::eEP_End)
	{
		return;
	}
	
	if (m_iShowType == SHOW_EQUIP_NORMAL)
	{
		if (m_tlPickEquip)
		{
			std::vector<std::string> vec_str;
			std::vector<int> vec_id;
			vec_str.push_back(std::string("无"));
			vec_id.push_back(-1);
			
			std::vector<Item*>bag = ItemMgrObj.GetPlayerBagItems();
			std::vector<Item*>::iterator it = bag.begin();
			for (; it != bag.end(); it++)
			{
				bool bOK = false;
				Item* item = *it;
				
				do 
				{
					int type = Item::getIdRule(item->iItemType, Item::ITEM_TYPE);
					if ((type != 0) && (type != 1)) { // 0装备,1宠物
						break;
					}
					int item_equip = Item::getIdRule(item->iItemType, Item::ITEM_EQUIP);
					int item_class = Item::getIdRule(item->iItemType, Item::ITEM_CLASS);
					
					switch (iPos) {
						case Item::eEP_Shoulder: {// 0肩
							if ((type == 0) && (item_equip == 4) && (item_class == 2)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Head: {// 1头
							if ((type == 0) && (item_equip == 4) && (item_class == 1)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Armor: {// 2胸
							if ((type == 0) && (item_equip == 4) && (item_class == 3)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_XianLian: {// 3项链
							if ((type == 0) && (item_equip == 5) && (item_class == 1)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_ErHuan: {// 4耳环
							if ((type == 0) && (item_equip == 5) && (item_class == 2)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_YaoDai: {// 5腰带--披风
							if ((type == 0) && (item_equip == 4) && (item_class == 5)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_MainArmor: {// 6主武器
							if ((type == 0) && ((item_equip == 1) || (item_equip == 2))) { // 单手或者双手
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_FuArmor: {// 8副武
							if ((type == 0) && ((item_equip == 2) || (item_equip == 3))) {// 副手或者单手
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_HuiJi: {// 9徽记
							if ((type == 0) && (item_equip == 5) && (item_class == 3)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Shou: {// 10手
							if ((type == 0) && (item_equip == 4) && (item_class == 4)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Decoration: {// 11勋章
							if ((type == 1) && (item_equip == 1)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_HuTui: {// 12护腿
							if ((type == 0) && (item_equip == 4) && (item_class == 6)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Shoes: {// 14鞋子
							if ((type == 0) && (item_equip == 4) && (item_class == 7)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_LeftRing:
						case Item::eEP_RightRing: {// 15左戒指 16右戒指
							if ((type == 0) && (item_equip == 5) && (item_class == 4)) {
								bOK = checkItemLimit(item, false);
							}
							break;
						}
						case Item::eEP_Ride: {// 17坐骑
							if ((type == 1) && (item_equip == 4)) {
								bOK = true;
							}
							break;
						}
					}
				} while (0);
				
				if (bOK)
				{
					vec_str.push_back(item->getItemNameWithAdd());
					vec_id.push_back(item->iID);
				}
			}
			
			InitTLContentWithVecEquip(m_tlPickEquip, vec_str, vec_id);
		}
	}
}

void GamePlayerBagScene::hasEquipItem(Item* item, int iPos)
{
	if (!item || (iPos < Item::eEP_Begin || iPos >= Item::eEP_End) )
	{
		return;
	}
	
	if (m_iShowType == SHOW_EQUIP_NORMAL)
	{
		std::stringstream sb;
		std::stringstream sb2;
		std::string title;
		std::string content;
		//NDBattlePet *petptr = NDPlayer::defaultHero().battlepet;
		//HeroPetInfo::PetData& pet = NDMapMgrObj.petInfo.m_data;
		if (item->isItemPet())
		{
			//NDBattlePet& pet = *petptr;
			/*
			sb << (NDMapMgrObj.petInfo.str_PET_ATTR_NAME);
			sb << ("(");
			sb << (pet.int_PET_ATTR_LEVEL);
			sb << (")");
			sb << ('\n');
			title = sb.str();

			sb2 << ("品质：");
			int tempInt = pet.int_PET_ATTR_TYPE % 10;
			sb2 << NDItemType::PETPINZHI(tempInt) << '\n';
			sb2 << "寿命：" << pet.int_PET_ATTR_AGE << '\n';
			sb2 << "忠诚度：" << pet.int_PET_ATTR_LOYAL << '\n';
			if (pet.int_PET_ATTR_STR > 0) {
				sb2 << "力量：" << pet.int_PET_ATTR_STR << '\n';
			}
			if (pet.int_PET_ATTR_STA > 0) {
				sb2 << "体质：" << pet.int_PET_ATTR_STA << '\n';
			}
			if (pet.int_PET_ATTR_AGI > 0) {
				sb2 << "敏捷：" << pet.int_PET_ATTR_AGI << '\n';
			}
			if (pet.int_PET_ATTR_INI > 0) {
				sb2 << "智力：" << pet.int_PET_ATTR_INI << '\n';
			}
			if (pet.int_PET_ATTR_PHY_ATK > 0) {
				sb2 << "物理攻击力：" << pet.int_PET_ATTR_PHY_ATK << '\n';
			}
			if (pet.int_PET_ATTR_MAG_ATK > 0) {
				sb2 << "法术攻击力：" << pet.int_PET_ATTR_MAG_ATK;
			}
			content = sb2.str();
			*/
		}
		else
		{
			title = item->getItemNameWithAdd();
			content = item->makeItemDes(false, true);
			// ChatRecordManager.parserChat(content, -1)
		}
		
		m_equipOPInfo.set(iPos, item);
		NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
		dlg->Initialization(item->iID);
		dlg->SetDelegate(this);
		dlg->Show(title.c_str(), content.c_str(), "离开", "卸载", NULL);
	}
	else if (m_iShowType == SHOW_EQUIP_REPAIR)
	{
		m_equipOPInfo.set(iPos, item);
		
		std::vector<std::string> vec_str;
		if (item->isEquip())
		{
			vec_str.push_back(std::string("修理当前装备"));
		}
		vec_str.push_back(std::string("修理全部已装备物品"));
		InitTLContentWithVec(m_tlShare, vec_str);	
	}
}

std::string GamePlayerBagScene::getRepairDesc(Item* item)
{
	if (!item)
	{
		return std::string("");
	}
	
	stringstream sb;
	
	int type = Item::getIdRule(item->iItemType,Item::ITEM_TYPE); // 物品类型
	if (type == 0) {// 装备
		int equipAllAmount = item->getAmount_limit();
		sb << (item->getItemNameWithAdd());
		if ((item->iAmount < equipAllAmount)
			&& (equipAllAmount > 1)) {
			int repairCharge = getEquipRepairCharge(item, 0);
			sb	<< " 耐久度: "
				<< Item::getdwAmountShow(item->iAmount)
				<< "/" << Item::getdwAmountShow(equipAllAmount)
					  << " 修理费:" << repairCharge;
		} else if (equipAllAmount == 0) {
			sb << ("(不需要修理)");
		} else {
			sb	<< " 耐久度: "
				<< Item::getdwAmountShow(item->iAmount)
				<< "/" << Item::getdwAmountShow(equipAllAmount)
				<< " (不需要修理)";
		}
	} else {
		sb << (item->getItemName());
		if (item->iAmount > 1) {
			sb << (item->iAmount);
		}
		sb << ("(不可修理)");
	}
	return std::string(sb.str());
}


int GamePlayerBagScene::getEquipRepairCharge(Item* item, int type)
{
	switch (type) {
		case 0: {
			
			if (!item ) {
				return 0;
			}
			
			int equipAllAmount = item->getAmount_limit();
			int equipPrice = item->getPrice();
			if ((item->iAmount < equipAllAmount) && (equipAllAmount > 1)) {
				return repairEveryMoney(equipPrice, item->iAmount,
										equipAllAmount);
			}
			return 0;
		}
		case 1: {
			int sumRepair = 0;
			for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
			{
				if (!m_cellinfoEquip[i] || !m_cellinfoEquip[i]->item)
				{
					continue;
				}
				
				Item *tempItem = m_cellinfoEquip[i]->item;
				if (tempItem && tempItem->isEquip() && !tempItem->isRidePet() && i != Item::eEP_Ride) {// 装备
					int equipAllAmount = tempItem->getAmount_limit();
					int equipPrice = tempItem->getPrice();
					
					if ((tempItem->iAmount < equipAllAmount)
						&& (equipAllAmount > 1)) {
						sumRepair += repairEveryMoney(equipPrice,
													  tempItem->iAmount, equipAllAmount);
					}
				}
			}
			
			return sumRepair;
		}
	}
	return 0;
}

int GamePlayerBagScene::repairEveryMoney(int equipPrice, int dwAmount,int equipAllAmount)
{
	double repairMoney = double(equipPrice
	* ((double)3333333333.0 - (double)dwAmount * (double)10000000000.0 / (equipAllAmount * 3))
	/ (double)10000000000.0);
	return (int) (repairMoney) + 1; // 取整+1
}

bool GamePlayerBagScene::checkItemLimit(Item* item, bool isShow)
{
	if (!item)
	{
		return false;
	}
	
	stringstream sb;
	NDPlayer &player = NDPlayer::defaultHero();
	int levelLimit = item->getReq_level(); // 等级限制
	int selfLimit = player.level;
	if (selfLimit < levelLimit) {
		sb << "等级需求" << levelLimit << "(目前" << selfLimit << ")\n";
	}
	
	int req_phy = item->getReq_phy(); // 力量限制
	int self_phy = player.phyPoint;
	if (self_phy < req_phy) {
		sb <<  "力量需求" << req_phy << "(目前" << self_phy << ")\n";
	}
	int req_dex = item->getReq_dex(); // 敏捷限制
	int self_dex = player.dexPoint;
	if (self_dex < req_dex) {
		sb << "敏捷需求" << req_dex << "(目前" << self_dex << ")\n";
	}
	
	int req_mag = item->getReq_mag(); // 智力限制
	int self_mag = player.magPoint;
	if (self_mag < req_mag) {
		sb << "智力需求" << req_mag << "(目前" << self_mag << ")\n";
	}
	
	int req_def = item->getReq_def(); // 体质限制
	int self_def = player.defPoint;
	if (self_def < req_def) {
		sb << "体质需求" << req_def << "(目前" << self_def << ")";
	}
	
	std::string str = sb.str();
	if (!str.empty()) {
		if (isShow) {
			NDUIDialog *dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->Show("未满足装备需求条件", str.c_str(), NULL, NULL);
		}
		return false;
	}
	
	return true;
}

void GamePlayerBagScene::repairItem(Item* item)
{
	if (!item)
	{
		return;
	}
	
	if (item->isRidePet())
	{
		showDialog("温馨提示", "骑宠不能修理");
	} else {
		int sumRepair = getEquipRepairCharge(item, 0);
		if (sumRepair == 0) {
			showDialog("温馨提示", "该装备无需修理");
		} else {
			if (sumRepair > NDPlayer::defaultHero().money) {
				stringstream ss; ss << "修理该装备的费用是" << sumRepair << ",你身上的银两不够,无法修理该装备";
				showDialog("温馨提示", ss.str().c_str());
			} else {
				sendItemRepair(item->iID, Item::_ITEMACT_REPAIR);
			}
		}
	}
}

void GamePlayerBagScene::repairAllItem()
{
	int sumRepair = getEquipRepairCharge(NULL, 1);
	
	if (sumRepair == 0) {
		showDialog("温馨提示", "你身上的所有装备都无需修理");
	} else {
		if (sumRepair > NDPlayer::defaultHero().money) {
			stringstream ss; ss << "修理所有装备的费用是" << sumRepair << "你身上的银两不够,无法修理全部";
			showDialog("温馨提示", ss.str().c_str());
		} else {
			stringstream ss; ss << "修理身上所有装备物品需要 " << sumRepair << " 银两，是否修理全部？";
			NDPlayerBagDialog *dlg = new NDPlayerBagDialog;
			dlg->Initialization(PlayerBagDialog_Reapir);
			dlg->SetDelegate(this);
			dlg->Show("温馨提示", ss.str().c_str(), "取消", "确定", NULL);
		}
	}
}




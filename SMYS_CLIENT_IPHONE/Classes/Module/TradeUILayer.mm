/*
 *  TradeUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "TradeUILayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "ItemMgr.h"
#include "NDUtility.h"
#include "GlobalDialog.h"
#include "NDPlayer.h"
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "NDUICustomView.h"
#include "NDConstant.h"
#include "SynDonateUILayer.h"
#include "NDCommonControl.h"
#include <sstream>


enum {
	START_X = 10,
	START_OTHER_Y = 36,
	START_OUR_Y = 156,
	
	ITEM_SIZE_WH = 42,
	
	TAG_OUR_OPT = 1,
	TAG_OTHER_OPT = 2,
	
	TAG_OUR_ACCEPT = 3,
	
	TAG_INPUT_YINLIANG = 4,
	TAG_INPUT_YUANBAO = 5,
};
//
//TradeUILayer* TradeUILayer::s_instance = NULL;
//
//IMPLEMENT_CLASS(TradeUILayer, NDUIMenuLayer)
//
//void TradeUILayer::SendTrade(int data, Byte action)
//{
//	NDTransData bao(_MSG_TRADE);
//	bao << data << action;
//	SEND_DATA(bao);
//}
//
//bool TradeUILayer::isUILayerShown()
//{
//	return s_instance != NULL;
//}
//
//#pragma mark 处理交易消息逻辑
//void TradeUILayer::processTrade(NDManualRole* tradeRole, int nData, int action)
//{
//	if (!s_instance && action != 9) {
//		return;
//	}
//	
//	if (action == 9) { // 开始交易
//		NDUISynLayer::Close();
//		if (tradeRole) {
//			NDScene* curScene = NDDirector::DefaultDirector()->GetRunningScene();
//			if (curScene) {
//				if (!s_instance) {
//					s_instance = new TradeUILayer();
//					s_instance->Initialization();
//					s_instance->m_idTradeRole = nData;
//					curScene->AddChild(s_instance, TRADE_LAYER_Z);
//				}
//			}
//		}
//	} else if (action == 4) { // 交易成功
//		//  交易成功提示
//		/*if (GameScreen.getInstance() != null) {
//		 GameScreen.getInstance().initNewChat(
//		 new ChatRecord(5, "系统", "交易成功"));
//		 }*/
//		Chat::DefaultChat()->AddMessage(ChatTypeSystem, "交易成功");
//		TradeUILayer::Close();
//	} else if (action == 5) { // 交易失败
//		TradeUILayer::Close();
//		// // 交易提示
//		/*if (GameScreen.getInstance() != null) {
//		 GameScreen.getInstance().initNewChat(
//		 new ChatRecord(5, "系统", "交易失败"));
//		 }*/
//		 Chat::DefaultChat()->AddMessage(ChatTypeSystem, "交易失败");
//	} else if (action == 7) { // 对方加物品
//		s_instance->AddItem(nData);
//	} else if (action == 8) { // 加钱
//		s_instance->AddMoney(nData);
//	} else if (action == 11) { // 加元宝
//		s_instance->AddEMoney(nData);
//	} else if (action == 3) { // 同意交易
//		s_instance->AcceptTrade(nData);
//	}
//}
//
//void TradeUILayer::Close()
//{
//	NDScene* curScene = NDDirector::DefaultDirector()->GetRunningScene();
//	if (curScene && curScene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
//		GameScene* gameScene = (GameScene*)curScene;
//		gameScene->SetUIShow(false);
//	}
//	
//	if (s_instance) {
//		s_instance->RemoveFromParent(true);
//		s_instance = NULL;
//	}
//}
//
//#pragma mark 添加对方物品
//void TradeUILayer::AddItem(OBJID idItem)
//{
//	Item* item = ItemMgrObj.QueryOtherItem(idItem);
//	if (item) {
//		for (uint r = 0; r < ITEM_ROW; r++) {
//			for (uint c = 0; c < ITEM_COL; c++) {
//				if (!this->m_btnOtherItem[r][c]->GetItem()) {
//					this->m_btnOtherItem[r][c]->ChangeItem(item);
//					return;
//				}
//			}
//		}
//	}
//}
//
//void TradeUILayer::AddMoney(int nMoney)
//{
//	this->m_otherMoney->SetSmallWhiteNumber(nMoney, false);
//}
//
//void TradeUILayer::AddEMoney(int nEMoney)
//{
//	this->m_otherEMoney->SetSmallWhiteNumber(nEMoney, false);
//}
//
//void TradeUILayer::AcceptTrade(int idTrade)
//{
//	NDUILayer* layerAccept = new NDUILayer;
//	layerAccept->Initialization();
//	layerAccept->SetBackgroundColor(ccc4(252, 66, 66, 150));
//	layerAccept->SetFrameRect(CGRectMake(START_X - 2, START_OTHER_Y - 2, 180.0f, 110.0f));
//	
//	this->AddChild(layerAccept);
//}
//
//TradeUILayer::TradeUILayer()
//{
//	this->m_optLayer = NULL;
//	this->m_opt = NULL;
//	m_idTradeRole = ID_NONE;
//	m_bagItem = NULL;
//	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
//		for (NSUInteger c = 0; c < ITEM_COL; c++) {
//			this->m_btnOurItem[r][c] = NULL;
//			this->m_btnOtherItem[r][c] = NULL;
//		}
//	}
//	
//	this->m_ourMoney = NULL;
//	
//	this->m_ourEMoney = NULL;
//	this->m_otherMoney = NULL;
//	this->m_otherEMoney = NULL;
//	
//	this->m_bagMoney = NULL;
//	this->m_bagEMoney = NULL;
//	
//	this->m_picMoney = NULL;
//	this->m_picEMoney = NULL;
//	
//	this->m_btnOurMoney = NULL;
//	this->m_btnOurEMoney = NULL;
//	
//	this->m_curFocusBtn = NULL;
//}
//
//TradeUILayer::~TradeUILayer()
//{
//	SAFE_DELETE(m_picMoney);
//	SAFE_DELETE(m_picEMoney);
//	
//	ItemMgrObj.RemoveOtherItems();
//}
//
//void TradeUILayer::Initialization()
//{
//	NDUIMenuLayer::Initialization();
//	this->ShowOkBtn();
//	
//	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
//	
//	if ( this->GetOkBtn() ) 
//	{
//		this->GetOkBtn()->SetDelegate(this);
//	}
//	
//	if ( this->GetCancelBtn() ) 
//	{
//		this->GetCancelBtn()->SetDelegate(this);
//	}
//	
//	NDUILabel* title = new NDUILabel; 
//	title->Initialization(); 
//	title->SetText("交易"); 
//	title->SetFontSize(15); 
//	title->SetTextAlignment(LabelTextAlignmentCenter); 
//	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
//	title->SetFontColor(ccc4(255, 240, 0,255));
//	this->AddChild(title);
//	
//	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
//	this->m_bagItem = new GameItemBag;
//	m_bagItem->Initialization(itemlist);
//	m_bagItem->SetDelegate(this);
//	m_bagItem->SetPageCount(ItemMgrObj.GetPlayerBagNum());
//	m_bagItem->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
//	this->AddChild(m_bagItem);
//	
//	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
//		for (NSUInteger c = 0; c < ITEM_COL; c++) {
//			NDUIItemButton* btn = new NDUIItemButton;
//			btn->Initialization();
//			btn->SetDelegate(this);
//			btn->SetFrameRect(CGRectMake(START_X + c * (ITEM_SIZE_WH + 2),
//						     START_OTHER_Y + r * (ITEM_SIZE_WH + 4),
//						     ITEM_SIZE_WH, ITEM_SIZE_WH));
//			this->AddChild(btn);
//			this->m_btnOtherItem[r][c] = btn;
//			
//			btn = new NDUIItemButton;
//			btn->Initialization();
//			btn->SetDelegate(this);
//			btn->SetFrameRect(CGRectMake(START_X + c * (ITEM_SIZE_WH + 2),
//						     START_OUR_Y + r * (ITEM_SIZE_WH + 4),
//						     ITEM_SIZE_WH, ITEM_SIZE_WH));
//			this->AddChild(btn);
//			this->m_btnOurItem[r][c] = btn;
//		}
//	}
//	
//	this->m_ourMoney = new ImageNumber;
//	m_ourMoney->Initialization();
//	m_ourMoney->SetSmallWhiteNumber(0, false);
//	m_ourMoney->SetFrameRect(CGRectMake(25, 253, 62, 20));
//	m_ourMoney->SetTouchEnabled(false);
//	this->AddChild(m_ourMoney);
//	
//	this->m_ourEMoney = new ImageNumber;
//	m_ourEMoney->Initialization();
//	m_ourEMoney->SetSmallWhiteNumber(0, false);
//	m_ourEMoney->SetFrameRect(CGRectMake(111, 253, 62, 20));
//	m_ourEMoney->SetTouchEnabled(false);
//	this->AddChild(m_ourEMoney);
//	
//	this->m_otherMoney = new ImageNumber;
//	m_otherMoney->Initialization();
//	m_otherMoney->SetSmallWhiteNumber(0, false);
//	m_otherMoney->SetFrameRect(CGRectMake(25, 131, 62, 20));
//	m_otherMoney->SetTouchEnabled(false);
//	this->AddChild(m_otherMoney);
//	
//	this->m_otherEMoney = new ImageNumber;
//	m_otherEMoney->Initialization();
//	m_otherEMoney->SetSmallWhiteNumber(0, false);
//	m_otherEMoney->SetFrameRect(CGRectMake(111, 131, 62, 20));
//	m_otherEMoney->SetTouchEnabled(false);
//	this->AddChild(m_otherEMoney);
//	
//	NDPlayer& role = NDPlayer::defaultHero();
//	this->m_bagMoney = new ImageNumber;
//	m_bagMoney->Initialization();
//	m_bagMoney->SetSmallWhiteNumber(role.money, false);
//	m_bagMoney->SetFrameRect(CGRectMake(221, 293, 62, 20));
//	m_bagMoney->SetTouchEnabled(false);
//	this->AddChild(m_bagMoney);
//	
//	this->m_bagEMoney = new ImageNumber;
//	m_bagEMoney->Initialization();
//	m_bagEMoney->SetSmallWhiteNumber(role.eMoney, false);
//	m_bagEMoney->SetFrameRect(CGRectMake(338, 293, 62, 20));
//	m_bagEMoney->SetTouchEnabled(false);
//	this->AddChild(m_bagEMoney);
//	
//	this->m_picMoney = new NDPicture;
//	m_picMoney->Initialization(GetImgPath("money.png"));
//	
//	this->m_picEMoney = new NDPicture;
//	m_picEMoney->Initialization(GetImgPath("emoney.png"));
//	
//	this->m_btnOurMoney = new NDUIButton;
//	m_btnOurMoney->Initialization();
//	m_btnOurMoney->SetDelegate(this);
//	m_btnOurMoney->SetBackgroundColor(ccc4(0, 0, 0, 0));
//	m_btnOurMoney->SetTouchDownImage(m_picMoney, true, CGRectMake(0.0f, 2.0f, 16.0f, 16.0f));
//	m_btnOurMoney->SetImage(m_picMoney, true, CGRectMake(0.0f, 2.0f, 16.0f, 16.0f));
//	m_btnOurMoney->SetFrameRect(CGRectMake(9.0f, 248.0f, 76.0f, 20.0f));
//	this->AddChild(m_btnOurMoney);
//	
//	this->m_btnOurEMoney = new NDUIButton;
//	m_btnOurEMoney->Initialization();
//	m_btnOurEMoney->SetDelegate(this);
//	m_btnOurEMoney->SetTouchDownImage(m_picEMoney, true, CGRectMake(0.0f, 2.0f, 16.0f, 16.0f));
//	m_btnOurEMoney->SetImage(m_picEMoney, true, CGRectMake(0.0f, 2.0f, 16.0f, 16.0f));
//	m_btnOurEMoney->SetFrameRect(CGRectMake(93.0f, 248.0f, 76.0f, 20.0f));
//	this->AddChild(m_btnOurEMoney);
//}
//
//#pragma mark 输入银两或元宝
//bool TradeUILayer::OnCustomViewConfirm(NDUICustomView* customView)
//{
//	VerifyViewNum(*customView);
//	NDPlayer& role = NDPlayer::defaultHero();
//	OBJID idTag = customView->GetTag();
//	if (idTag == TAG_INPUT_YINLIANG) {
//		string strYinliang = customView->GetEditText(0);
//		int yinliang = atoi(strYinliang.c_str());
//		if (yinliang <= 0 || yinliang > role.money) {
//			customView->ShowAlert("您的输入有误,请重新输入");
//			return false;
//		}
//		this->m_ourMoney->SetSmallWhiteNumber(yinliang, false);
//		SendTrade(yinliang, 8);
//		
//	} else if (idTag == TAG_INPUT_YUANBAO) {
//		string strYuanBao = customView->GetEditText(0);
//		int yuanbao = atoi(strYuanBao.c_str());
//		if (yuanbao <= 0 || yuanbao > role.eMoney) {
//			customView->ShowAlert("您的输入有误,请重新输入");
//			return false;
//		}
//		this->m_ourEMoney->SetSmallWhiteNumber(yuanbao, false);
//		SendTrade(yuanbao, 11);
//		
//	}
//	return true;
//}
//
//void TradeUILayer::OnButtonClick(NDUIButton* button)
//{
//	if (button == this->GetCancelBtn()) {
//		if (this->m_opt) {
//			this->RemoveChild(this->m_optLayer, true);
//			this->m_optLayer = NULL;
//			this->m_opt = NULL;
//		} else {
//			SendTrade(this->m_idTradeRole, 2);
//			Close();
//		}
//		return;
//	} else if (button == this->GetOkBtn()) { // 发送交易确认
//		if (!this->GetChild(TAG_OUR_ACCEPT)) {
//			NDUILayer* layerAccept = new NDUILayer;
//			layerAccept->Initialization();
//			layerAccept->SetBackgroundColor(ccc4(252, 66, 66, 150));
//			layerAccept->SetFrameRect(CGRectMake(START_X - 3, START_OUR_Y - 2, 180.0f, 120.0f));
//			layerAccept->SetTag(TAG_OUR_ACCEPT);
//			this->AddChild(layerAccept);
//			SendTrade(m_idTradeRole, 3);
//		}
//		return;
//	}
//	
//	if (this->m_curFocusBtn != button) {
//		this->m_curFocusBtn = button;
//		return;
//	}
//	
//	if (button == this->m_btnOurMoney) { // 输入金钱
//		NDUICustomView *view = new NDUICustomView;
//		view->Initialization();
//		view->SetTag(TAG_INPUT_YINLIANG);
//		view->SetDelegate(this);
//		std::vector<int> vec_id; vec_id.push_back(1);
//		std::vector<std::string> vec_str; vec_str.push_back("请输入银两");
//		view->SetEdit(1, vec_id, vec_str);
//		view->Show();
//	} else if (button == this->m_btnOurEMoney) { // 输入元宝
//		NDUICustomView *view = new NDUICustomView;
//		view->Initialization();
//		view->SetTag(TAG_INPUT_YUANBAO);
//		view->SetDelegate(this);
//		std::vector<int> vec_id; vec_id.push_back(1);
//		std::vector<std::string> vec_str; vec_str.push_back("请输入元宝");
//		view->SetEdit(1, vec_id, vec_str);
//		view->Show();
//	} else {
//		for (uint r = 0; r < ITEM_ROW; r++) {
//			for (uint c = 0; c < ITEM_COL; c++) {
//				if (button == this->m_btnOtherItem[r][c] || button == this->m_btnOurItem[r][c]) { // 显示详细
//					NDUIItemButton* itemBtn = (NDUIItemButton*)button;
//					if (itemBtn->GetItem() && !this->m_opt) {
//						
//						if (!m_optLayer) {
//							this->m_optLayer = new NDUILayer;
//							m_optLayer->Initialization();
//							m_optLayer->SetFrameRect(CGRectMake(0.0f, 0.0f, 480.0f, 280.0f));
//							this->AddChild(m_optLayer);
//						}
//						
//						m_opt = new NDUITableLayer;
//						m_opt->Initialization();
//						m_opt->VisibleSectionTitles(false);
//						m_opt->SetTag(TAG_OTHER_OPT);
//						
//						NDDataSource *ds = new NDDataSource;
//						NDSection *sec = new NDSection;
//						
//						NDUIButton* btn = new NDUIButton;
//						btn->Initialization();
//						btn->SetTitle("详细");
//						btn->SetFocusColor(ccc4(253, 253, 253, 255));
//						sec->AddCell(btn);
//						
//						ds->AddSection(sec);
//						m_opt->SetDelegate(this);
//						m_opt->SetDataSource(ds);
//						
//						sec->SetFocusOnCell(0);
//						
//						CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
//						m_opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 60) / 2, 94, 30));
//						m_optLayer->AddChild(m_opt);
//					}
//				}
//			}
//		}
//	}
//}
//
//void TradeUILayer::draw()
//{
//	NDUIMenuLayer::draw();
//	
//	DrawLine(CGPointMake(6, 146), CGPointMake(186, 146), ccc4(82, 93, 90, 255), 2);
//	DrawLine(CGPointMake(6, 148), CGPointMake(186, 148), ccc4(156, 178, 148, 255), 2);
//	DrawLine(CGPointMake(6, 150), CGPointMake(186, 150), ccc4(82, 93, 90, 255), 2);
//	
//	// 对方金钱
//	this->m_picMoney->DrawInRect(CGRectMake(9.0f, 128.0f, 16.0f, 16.0f));
//	this->m_picEMoney->DrawInRect(CGRectMake(93.0f, 128.0f, 16.0f, 16.0f));
//	
//	// 我方金钱
//	//this->m_picMoney->DrawInRect(CGRectMake(9.0f, 250.0f, 16.0f, 16.0f));
//	//this->m_picEMoney->DrawInRect(CGRectMake(93.0f, 250.0f, 16.0f, 16.0f));
//	
//	// 背包金钱
//	this->m_picMoney->DrawInRect(CGRectMake(202.0f, 291.0f, 16.0f, 16.0f));
//	this->m_picEMoney->DrawInRect(CGRectMake(320.0f, 291.0f, 16.0f, 16.0f));
//	
//	if (this->m_curFocusBtn) {
//		CGRect rectCurFocus = this->m_curFocusBtn->GetScreenRect();
//		rectCurFocus.origin.x -= 1;
//		rectCurFocus.origin.y -= 1;
//		rectCurFocus.size.width += 2;
//		rectCurFocus.size.height += 2;
//		DrawPolygon(rectCurFocus, ccc4(189, 56, 0, 255), 1);
//	}
//}
//
//void TradeUILayer::OnClickPage(GameItemBag* itembag, int iPage)
//{
//	this->m_curFocusBtn = NULL;
//}
//
//void TradeUILayer::AddTradeItem()
//{
//	Item* item = this->m_bagItem->GetFocusItem();
//	if (item) {
//		if (item->isItemCanTrade()) {
//			for (uint r = 0; r < ITEM_ROW; r++) {
//				for (uint c = 0; c < ITEM_COL; c++) {
//					if (!this->m_btnOurItem[r][c]->GetItem()) {
//						this->m_btnOurItem[r][c]->ChangeItem(item);
//						this->m_bagItem->DelItem(item->iID);
//						SendTrade(item->iID, 7);
//						return;
//					}
//				}
//			}
//		} else {
//			GlobalShowDlg("提示", "该物品不能交易");
//		}
//	}
//}
//
//void TradeUILayer::ShowItemDetail(Item* item)
//{
//	if (item) {
//		if (item->isFormula() || item->isItemPet() || item->isSkillBook()) {
//			sendQueryDesc(item->iID);
//		} else {
//			GlobalShowDlg(item->getItemName(), item->makeItemDes(false, false));
//		}
//	}
//}
//
//void TradeUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
//{
//	OBJID idTableTag = table->GetTag();
//	switch (idTableTag) {
//		case TAG_OUR_OPT:
//		{
//			switch (cellIndex) {
//				case 0: // 上架
//					this->AddTradeItem();
//					this->RemoveChild(this->m_optLayer, true);
//					this->m_optLayer = NULL;
//					this->m_opt = NULL;
//					break;
//				case 1: // 详细
//					this->ShowItemDetail(this->m_bagItem->GetFocusItem());
//					break;
//				default:
//					break;
//			}
//		}
//			break;
//		case TAG_OTHER_OPT:
//			if (this->m_curFocusBtn && m_curFocusBtn->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton))) {
//				this->ShowItemDetail(((NDUIItemButton*)m_curFocusBtn)->GetItem());
//			}
//			this->RemoveChild(this->m_optLayer, true);
//			this->m_optLayer = NULL;
//			this->m_opt = NULL;
//			break;
//		default:
//			break;
//	}
//}
//
//bool TradeUILayer::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
//{
//	this->m_curFocusBtn = NULL;
//	
//	if (this->GetChild(TAG_OUR_ACCEPT)) { // 已经确认,不能在上架
//		return false;
//	}
//	
//	// 显示操作选项
//	if (bFocused) {
//		if (!m_opt) {
//			this->m_opt = new NDUITableLayer;
//			m_opt->Initialization();
//			m_opt->VisibleSectionTitles(false);
//			m_opt->SetTag(TAG_OUR_OPT);
//			
//			NDDataSource *ds = new NDDataSource;
//			NDSection *sec = new NDSection;
//			
//			NDUIButton *btn = new NDUIButton;
//			btn->Initialization();
//			btn->SetTitle("上架");
//			btn->SetFocusColor(ccc4(253, 253, 253, 255));
//			sec->AddCell(btn);
//			
//			btn = new NDUIButton;
//			btn->Initialization();
//			btn->SetTitle("详细");
//			btn->SetFocusColor(ccc4(253, 253, 253, 255));
//			sec->AddCell(btn);
//			
//			sec->SetFocusOnCell(0);
//			ds->AddSection(sec);
//			m_opt->SetDelegate(this);
//			m_opt->SetDataSource(ds);
//			
//			if (!m_optLayer) {
//				this->m_optLayer = new NDUILayer;
//				m_optLayer->Initialization();
//				m_optLayer->SetFrameRect(CGRectMake(0.0f, 0.0f, 480.0f, 280.0f));
//				this->AddChild(m_optLayer);
//			}
//			
//			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
//			m_opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 60) / 2, 94, 60));
//			m_optLayer->AddChild(m_opt);
//		}
//	}
//	return false;
//}


#pragma mark 新交易界面


#pragma mark 交易金钱
class DlgTradeMoney : 
public NDCommonDlgBack
{
	DECLARE_CLASS(DlgTradeMoney)
public:
	enum { eBtnMoneyPlus = 100, eBtnMoneyMinus, eBtnEmoneyPlus, eBtnEmoneyMinus, eBtnConfim, eBtnCancel, };

	DlgTradeMoney()
	{
		memset(m_drag, 0, sizeof(m_drag));
	}
	
	~DlgTradeMoney()
	{
	}
	
	void Initialization() override
	{
		NDCommonDlgBack::Initialization(true);
		
		SetTitle(NDCommonCString("TradeMoney"));
		
		NDPicturePool& pool = *(NDPicturePool::DefaultPool());
		
		for(int i = 0; i < 2; i++)
		{
			float x = 46, y = i == 0 ? 68 : 124;
			vector<const char*> vImgFile;
			vector<CGRect> vImgCustomRect; 
			vector<CGPoint> vOffsetPoint;
			vImgFile.push_back(GetImgPathNew("btn_bg1.png"));
			vImgCustomRect.push_back(CGRectMake(0, 0, 38, 38));
			vOffsetPoint.push_back(CGPointMake(0, 0));
			vImgFile.push_back(GetImgPathNew(i==0 ? "bag_bagemoney.png" : "bag_bagmoney.png"));
			vImgCustomRect.push_back(CGRectMake(0, 0, 15, 15));
			vOffsetPoint.push_back(CGPointMake(11.5f, 11.5f));
			NDPicture *pic = new NDPicture;
			pic->Initialization(vImgFile, vImgCustomRect, vOffsetPoint);
			NDUIImage *img = new NDUIImage;
			img->Initialization();
			img->SetPicture(pic, true);
			img->SetFrameRect(CGRectMake(x-2, y-4, 38, 38));
			this->AddChild(img);
			
			x = 88, y = i == 0 ? 74 : 130;
			
			NDUIButton *btn = new NDUIButton;
			btn->Initialization();
			btn->SetImage(pool.AddPicture(GetImgPathNew("minu_selected.png")), false, CGRectZero, true);
			btn->SetFrameRect(CGRectMake(x, y, 20, 20));
			btn->SetDelegate(this);
			btn->SetTag(i==0 ? eBtnEmoneyMinus : eBtnMoneyMinus);
			this->AddChild(btn);
			
			x = 111;
			
			m_drag[i] = new DragBar;
			m_drag[i]->Initialization(CGRectMake(x, y, 192, 20), 192);
			m_drag[i]->SetDelegate(this);
			this->AddChild(m_drag[i]);
			
			x = 305;
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetImage(pool.AddPicture(GetImgPathNew("plus_selected.png")), false, CGRectZero, true);
			btn->SetFrameRect(CGRectMake(x, y, 20, 20));
			btn->SetDelegate(this);
			btn->SetTag(i==0 ? eBtnEmoneyPlus : eBtnMoneyPlus);
			this->AddChild(btn);
			
			x = i == 0 ? 35 : 196, y = 193;
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetImage(GetBtnNormalPic(CGSizeMake(140, 30)), 
						  false, CGRectZero, true);
			btn->SetTouchDownImage(GetBtnClickPic(CGSizeMake(140, 30)),
								   false, CGRectZero, true);
			btn->SetFrameRect(CGRectMake(x, y, 140, 30));
			btn->SetDelegate(this);
			btn->SetTag(i==0 ? eBtnConfim : eBtnCancel);
			btn->SetTitle(i==0 ? NDCommonCString("confirm") : NDCommonCString("Cancel"));
			btn->SetFontColor(ccc4(255, 255, 255, 255));
			this->AddChild(btn);
		}
	}
	
	void OnButtonClick(NDUIButton* button) override
	{
		if (button == m_btnClose) 
		{
			this->Close();
			return;
		}
		
		switch (button->GetTag()) 
		{
			case eBtnMoneyMinus:
			case eBtnEmoneyMinus:
			{
				DragBar *& drag = m_drag[button->GetTag() == eBtnMoneyMinus ? 1 : 0];
				uint cur = drag->GetCur();
				if (cur > drag->GetMin()) 
				{
					drag->SetCur(cur - 1, true);
				}
			}
				break;
			case eBtnMoneyPlus:
			case eBtnEmoneyPlus:
			{
				DragBar *& drag = m_drag[button->GetTag() == eBtnMoneyPlus ? 1 : 0];
				uint cur = drag->GetCur();
				if (cur < drag->GetMax()) {
					drag->SetCur(cur + 1, true);
				}
			}
				break;
			case eBtnConfim:
			{
				DlgTradeDelegate *delegate = dynamic_cast<DlgTradeDelegate *> (this->GetDelegate());
				if (delegate && m_drag[0] && m_drag[1]) {
					delegate->OnDlgTradeConfirm(this, m_drag[0]->GetCur(), m_drag[1]->GetCur());
				}
				this->Close();
			}
				break;
			case eBtnCancel:
			{
				this->Close();
			}
				break;
			default:
				break;
		}
	}
	
	void SetEMoney(unsigned int minEMoney, unsigned int maxEMoney, unsigned int curEMoney)
	{
		if (m_drag[0]) 
		{
			m_drag[0]->SetMin(minEMoney, false);
			m_drag[0]->SetMax(maxEMoney, false);
			m_drag[0]->SetCur(curEMoney, true);
		}
	}
	
	void SetMoney(unsigned int minMoney, unsigned int maxMoney, unsigned int curMoney)
	{
		if (m_drag[1]) 
		{
			m_drag[1]->SetMin(minMoney, false);
			m_drag[1]->SetMax(maxMoney, false);
			m_drag[1]->SetCur(curMoney, true);
		}
	}
	
private:
	DragBar *m_drag[2];
};

IMPLEMENT_CLASS(DlgTradeMoney, NDCommonDlgBack)

#pragma mark 交易数量

class DlgTradeAmount : 
public NDCommonDlgBack
{
	DECLARE_CLASS(DlgTradeAmount)
public:
	enum { eBtnAmountPlus=100, eBtnAmountMinus, eBtnConfim, eBtnCancel, };
	
	DlgTradeAmount()
	{
		m_lbAmount = NULL;
		m_drag = NULL;
	}

	~DlgTradeAmount()
	{
	}

	void Initialization() override
	{
		NDCommonDlgBack::Initialization(true);
		
		SetTitle(NDCommonCString("TradeAmount"));
		
		NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
		float w = this->GetFrameRect().size.width-28, h = 145;
		NDPicture *pic = pool.AddPicture(GetImgPathNew("tradedlg_textback.png"), w, h);
		NDUIImage *img = new NDUIImage;
		img->Initialization();
		img->SetPicture(pic, true);
		img->SetFrameRect(CGRectMake(14, 41, w, h));
		this->AddChild(img);
		
		pic = pool.AddPicture(GetImgPathNew("trade_amount.png"));
		CGSize sizeAmount = pic->GetSize();
		img = new NDUIImage;
		img->Initialization();
		img->SetPicture(pic, true);
		img->SetFrameRect(CGRectMake(134, 56, sizeAmount.width, sizeAmount.height));
		this->AddChild(img);
		
		m_lbAmount = new NDUILabel;
		m_lbAmount->Initialization();
		m_lbAmount->SetFontSize(40);
		m_lbAmount->SetTextAlignment(LabelTextAlignmentCenter);
		m_lbAmount->SetFontColor(ccc4(255, 255, 255, 255));
		m_lbAmount->SetFrameRect(CGRectMake(0, 0, sizeAmount.width, sizeAmount.height));
		m_lbAmount->SetText("100");
		img->AddChild(m_lbAmount);
		
		float x = 65, y = 142;
		NDUIButton *btn = new NDUIButton;
		btn->Initialization();
		btn->SetImage(pool.AddPicture(GetImgPathNew("minu_selected.png")), false, CGRectZero, true);
		btn->SetFrameRect(CGRectMake(x, y, 20, 20));
		btn->SetDelegate(this);
		btn->SetTag(eBtnAmountMinus);
		this->AddChild(btn);
		
		x = 88;
		
		m_drag = new DragBar;
		m_drag->Initialization(CGRectMake(x, y, 192, 20), 192);
		m_drag->SetDelegate(this);
		this->AddChild(m_drag);
		
		x = 283;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetImage(pool.AddPicture(GetImgPathNew("plus_selected.png")), false, CGRectZero, true);
		btn->SetFrameRect(CGRectMake(x, y, 20, 20));
		btn->SetDelegate(this);
		btn->SetTag(eBtnAmountPlus);
		this->AddChild(btn);
		
		
		for (int i = 0; i < 2; i++) 
		{
			x = i == 0 ? 35 : 196, y = 193;
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetImage(GetBtnNormalPic(CGSizeMake(140, 30)), 
						  false, CGRectZero, true);
			btn->SetTouchDownImage(GetBtnClickPic(CGSizeMake(140, 30)),
								   false, CGRectZero, true);
			btn->SetFrameRect(CGRectMake(x, y, 140, 30));
			btn->SetDelegate(this);
			btn->SetTag(i==0 ? eBtnConfim : eBtnCancel);
			btn->SetTitle(i==0 ? NDCommonCString("confirm") : NDCommonCString("Cancel"));
			btn->SetFontColor(ccc4(255, 255, 255, 255));
			this->AddChild(btn);
			
		}
	}
	
	void OnButtonClick(NDUIButton* button)
	{
		if (button == m_btnClose) 
		{
			this->Close();
			return;
		}
		
		switch (button->GetTag()) {
			case eBtnAmountMinus:
			{
				uint cur = m_drag->GetCur();
				if (cur > m_drag->GetMin()) 
				{
					m_drag->SetCur(cur - 1, true);
				}
			}
				break;
			case eBtnAmountPlus:
			{
				uint cur = m_drag->GetCur();
				if (cur < m_drag->GetMax()) {
					m_drag->SetCur(cur + 1, true);
				}
			}
				break;
		case eBtnConfim:
		{
			DlgTradeDelegate *delegate = dynamic_cast<DlgTradeDelegate *> (this->GetDelegate());
			if (delegate && m_drag) {
				delegate->OnDlgTradeConfirm(this, m_drag->GetCur(), 0);
			}
			this->Close();
		}
				break;
		case eBtnCancel:
		{
			this->Close();
		}
				break;
		default:
				break;
		} 
	}
	
	void SetAmount(unsigned int minAmount, unsigned int maxAmount)
	{
		if (m_drag) 
		{
			m_drag->SetMin(minAmount, false);
			m_drag->SetMax(maxAmount, true);
		}
	}
	
private:
	NDUILabel *m_lbAmount;
	DragBar *m_drag;
};

IMPLEMENT_CLASS(DlgTradeAmount, NDCommonDlgBack)

#define TRADE_LABEL_COLOR (ccc4(255, 255, 255, 255))

NewTradeLayer* NewTradeLayer::s_instance = NULL;

IMPLEMENT_CLASS(NewTradeLayer, NDUILayer)

NewTradeLayer::NewTradeLayer()
{
	s_instance = this;
	
	m_itembagPlayer = NULL;
	
	memset(m_btnOtherItem, 0, sizeof(m_btnOtherItem));
	
	memset(m_btnOurItem, 0, sizeof(m_btnOurItem));
	
	m_lbRoleName = m_lbEMoneyOther = m_lbMoneyOther = m_lbEMoneySelf = m_lbMoneySelf = NULL;
	
	m_layerCommitOther = m_layerCommitSelf = NULL;
	
	m_btnMoney = NULL;
	
	m_idTradeRole = 0;
	
	m_dlgMoney = NULL;
	
	m_dlgAmount = NULL;
	
	m_uiTradeMoney = m_uiTradeEmoney = 0;
	
	m_isInAcceptState = false;
}

NewTradeLayer::~NewTradeLayer()
{
	s_instance = NULL;
}

void NewTradeLayer::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	NDUILayer *frame = new NDUILayer;
	frame->Initialization();
	frame->SetFrameRect(CGRectMake(0,12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	frame->SetBackgroundImage(picBagLeftBg, true);
	this->AddChild(frame);
	
	NDPicture *pic = pool.AddPicture(GetImgPathNew("trade_money_bg.png"), 192, 20);
	
	NDUIImage *img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pic, true);
	img->SetFrameRect(CGRectMake(0, 7, 192, 20));
	frame->AddChild(img);
	
	m_lbRoleName = new NDUILabel();
	m_lbRoleName->Initialization();
	m_lbRoleName->SetFontSize(14);
	m_lbRoleName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbRoleName->SetFontColor(TRADE_LABEL_COLOR);
	m_lbRoleName->SetFrameRect(CGRectMake(40, 3, sizeBagLeftBg.width, 20));
	img->AddChild(m_lbRoleName);
	
	float fx = 0, fy = 27+10, fw = sizeBagLeftBg.width-2, fh = 95;
	
	InitItem(false, CGRectMake(fx, fy-10, fw, fh), frame);
	
	NDUILayer *layer = new NDUILayer;
	layer->Initialization();
	layer->SetBackgroundColor(ccc4(128, 98, 55, 255));
	layer->SetFrameRect(CGRectMake(fx, fy+fh, 196, 18));
	layer->SetTouchEnabled(false);
	this->AddChild(layer);
	
	NDPicture *picEMoney = pool.AddPicture(GetImgPathNew("bag_bagemoney.png"));
	
	NDPicture *picMoney = pool.AddPicture(GetImgPathNew("bag_bagmoney.png"));
	
	CGSize sizeMoney = picEMoney->GetSize();
	
	for (int i = 0; i < 2; i++) 
	{
		NDPicture *pic = i == 0 ? picEMoney : picMoney;
		NDUILabel *&lb = i == 0 ? m_lbEMoneyOther : m_lbMoneyOther;
		
		float fStartX = i == 0 ? 15 : 108;
		
		img = new NDUIImage;
		img->Initialization();
		img->SetPicture(pic, true);
		img->SetFrameRect(CGRectMake(fStartX, (18-sizeMoney.height), sizeMoney.width, sizeMoney.height));
		layer->AddChild(img);
		
		lb = new NDUILabel();
		lb->Initialization();
		lb->SetFontSize(12);
		lb->SetTextAlignment(LabelTextAlignmentLeft);
		lb->SetFontColor(TRADE_LABEL_COLOR);
		lb->SetFrameRect(CGRectMake(fStartX+sizeMoney.width+4, (18-sizeMoney.height), sizeBagLeftBg.width, 20));
		lb->SetText("0");
		layer->AddChild(lb);
	}
	
	InitItem(true, CGRectMake(fx, fy+fh+18-10, fw, fh), frame);
	
	float startX = 11, startY = fy+fh+18+fh+13-15;
	NDPicture *picMoneys = pool.AddPicture(GetImgPathNew("trade_moneys.png"));
	CGSize sizeMoneys = picMoneys->GetSize();
	
	for (int i = 0; i < 2; i++) 
	{
		NDPicture *pic = i == 0 ? picEMoney->Copy() : picMoney->Copy();
		NDUILabel *&lb = i == 0 ? m_lbEMoneySelf : m_lbMoneySelf;
		
		float fw= i == 0 ? 130 : 150;
		float fh = 14;
		float fy = startY + 5 + (fh+4)*i;
		float moneyX = i == 0 ? 70 : 80;
		
		img = new NDUIImage;
		img->Initialization();
		img->SetPicture(pool.AddPicture(GetImgPathNew("trade_money_bg.png"), fw, fh), true);
		img->SetFrameRect(CGRectMake(startX+sizeMoneys.width/2, fy, fw, fh));
		this->AddChild(img);
		
		lb = new NDUILabel();
		lb->Initialization();
		lb->SetFontSize(12);
		lb->SetTextAlignment(LabelTextAlignmentLeft);
		lb->SetFontColor(TRADE_LABEL_COLOR);
		lb->SetFrameRect(CGRectMake(45+i*10, 1, sizeBagLeftBg.width, 20));
		lb->SetText("0");
		img->AddChild(lb);
		
		img = new NDUIImage;
		img->Initialization();
		img->SetPicture(pic, true);
		img->SetFrameRect(CGRectMake(moneyX, (fy+(fh-sizeMoney.height)/2), sizeMoney.width, sizeMoney.height));
		this->AddChild(img);
	}
	
	img = new NDUIImage;
	img->Initialization();
	img->SetPicture(picMoneys, true);
	img->SetFrameRect(CGRectMake(startX, startY, sizeMoneys.width, sizeMoneys.height));
	this->AddChild(img);
	
	
	layer = new NDUILayer;
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(50, startY, 125, 45));
	this->AddChild(layer);
	m_btnMoney = new NDUIButton;
	m_btnMoney->Initialization();
	m_btnMoney->SetFrameRect(CGRectMake(0, 0, 125, 45));
	m_btnMoney->CloseFrame();
	m_btnMoney->SetTouchDownColor(ccc4(0, 0, 0, 0));
	m_btnMoney->SetDelegate(this);
	layer->AddChild(m_btnMoney);
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	m_itembagPlayer = new NewGameItemBag;
	m_itembagPlayer->Initialization(itemlist, true, false);
	m_itembagPlayer->SetDelegate(this);
	m_itembagPlayer->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itembagPlayer->SetFrameRect(CGRectMake(203, 5, NEW_ITEM_BAG_W, NEW_ITEM_BAG_H));
	this->AddChild(m_itembagPlayer);
}

void NewTradeLayer::InitItem(bool isSelf, CGRect rect, NDUINode *parent)
{
	if (!parent) return;
	
	for (int i = 0; i < ITEM_ROW; i++) 
		for (int j = 0; j < ITEM_COL; j++) 
		{
			NDUIItemButton*& btn = isSelf ? m_btnOurItem[i][j] : m_btnOtherItem[i][j];
			btn = new NDUIItemButton;
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(rect.origin.x + 7 + j * (ITEM_SIZE_WH + 5),
										 rect.origin.y + 4 + i * (ITEM_SIZE_WH + 3),
										 ITEM_SIZE_WH, ITEM_SIZE_WH));
			parent->AddChild(btn);
			
		}
	
	rect.origin.y += 8;
	
	if (isSelf)
		ShowSelfCommitLayer(false, rect);
	else
		ShowOtherCommitLayer(false, rect);
}

void NewTradeLayer::ShowSelfCommitLayer(bool show, CGRect rect/*=CGRectZero*/)
{
	static CGRect rectFrame = rect;
	
	if (!show) {
		SAFE_DELETE_NODE(m_layerCommitSelf);
		return;
	}
	
	m_layerCommitSelf = new NDUILayer;
	m_layerCommitSelf->Initialization();
	m_layerCommitSelf->SetFrameRect(rectFrame);
	m_layerCommitSelf->SetBackgroundColor(ccc4(165, 29, 29, 125));
	m_layerCommitSelf->SetTouchEnabled(false);
	this->AddChild(m_layerCommitSelf);
	
	m_isInAcceptState = true;
}

void NewTradeLayer::ShowOtherCommitLayer(bool show, CGRect rect/*=CGRectZero*/)
{
	static CGRect rectFrame = rect;
	
	if (!show) {
		SAFE_DELETE_NODE(m_layerCommitOther);
		return;
	}
	
	m_layerCommitOther = new NDUILayer;
	m_layerCommitOther->Initialization();
	m_layerCommitOther->SetFrameRect(rectFrame);
	m_layerCommitOther->SetBackgroundColor(ccc4(165, 29, 29, 125));
	m_layerCommitOther->SetTouchEnabled(false);
	this->AddChild(m_layerCommitOther);
}

void NewTradeLayer::ShowDialog(bool money, int itemID/*=0*/)
{
	if (money) 
	{
		NDPlayer& player = NDPlayer::defaultHero();
		m_dlgMoney = new DlgTradeMoney;
		m_dlgMoney->Initialization();
		m_dlgMoney->SetDelegate(this);
		m_dlgMoney->SetMoney(0, player.money, m_uiTradeMoney);
		m_dlgMoney->SetEMoney(0, player.eMoney, m_uiTradeEmoney);
	}
	else
	{
		m_dlgAmount = new DlgTradeAmount;
		m_dlgAmount->Initialization();
		m_dlgAmount->SetDelegate(this);
		m_dlgAmount->SetTag(itemID);
	}
}

void NewTradeLayer::commitTrade()
{
	if (!m_layerCommitSelf && !m_isInAcceptState) {
		ShowSelfCommitLayer(true);
		SendTrade(m_idTradeRole, 3);
	}
}

void NewTradeLayer::cancelTrade()
{
	SendTrade(this->m_idTradeRole, 2);
	NDDirector::DefaultDirector()->PopScene();
}

bool NewTradeLayer::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (uiSrcNode && uiSrcNode->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton)) 
		&& desButton != uiSrcNode && uiSrcNode->GetParent() == m_itembagPlayer) 
	{
		if (m_isInAcceptState) {
			return false;
		}
		
		Item* item = ((NDUIItemButton*)uiSrcNode)->GetItem();
		
		if (!item) 
			return false;
		
		if (!item->isItemCanTrade())
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("TradeItemTip"));
			
			return true;
		}
		
		if (!IsSelfBtnDragIn(desButton))
			return false;
			
		int emptyIndex = findEmptyIndex();
		
		if (emptyIndex == -1) return -1;
		
		int col = emptyIndex%ITEM_COL, row = emptyIndex/ITEM_COL;
		
		if (col >= ITEM_COL || col < 0
			|| row >= ITEM_ROW || row < 0) 
			return false;
		
		if (this->m_btnOurItem[row][col])
		{
			this->m_btnOurItem[row][col]->ChangeItem(item);
			
			if (this->m_itembagPlayer)
				this->m_itembagPlayer->DelItem(item->iID);
			
			SendTrade(item->iID, 7);
		}
	}
	
	return false;
}

bool NewTradeLayer::IsSelfBtnDragIn(NDUIButton* button)
{
	for (int i = 0; i < ITEM_ROW; i++)
		for (int j = 0; j < ITEM_COL; j++) 
		{
			if (m_btnOurItem[i][j] == button) 
				return true;
		}
		
	return false;
}

int	 NewTradeLayer::findEmptyIndex()
{
	for (int i = 0; i < ITEM_ROW; i++)
		for (int j = 0; j < ITEM_COL; j++) 
		{
			if (!m_btnOurItem[i][j]->GetItem()) 
				return i*ITEM_COL+j;
		}
	
	return -1;
}

bool NewTradeLayer::OnButtonLongClick(NDUIButton* button)
{
	for (int i = 0; i < ITEM_ROW; i++)
		for (int j = 0; j < ITEM_COL; i++) 
		{
			if (m_btnOurItem[i][j] == button) {
				ShowItemDetail(m_btnOurItem[i][j]->GetItem());
				return true;
			}
			
			if (m_btnOtherItem[i][j] == button) {
				ShowItemDetail(m_btnOtherItem[i][j]->GetItem());
				return true;
			}
		}
		
	return false;
}

void NewTradeLayer::OnDlgTradeConfirm(NDUILayer *dlg, unsigned int value1, unsigned int value2)
{
	if (dlg == m_dlgMoney) 
	{
		NDPlayer& role = NDPlayer::defaultHero();
		
		if (int(value1) > role.eMoney || int(value2) > role.money) 
		{
			return;
		}
		
		if (m_lbMoneySelf) 
		{
			std::stringstream ss; ss << value2;
			m_lbMoneySelf->SetText(ss.str().c_str());
		}
		
		if (m_lbEMoneySelf) 
		{
			std::stringstream ss; ss << value1;
			m_lbEMoneySelf->SetText(ss.str().c_str());
		}
		
		SendTrade(value2, 8);
		
		SendTrade(value1, 11);
		
		m_dlgMoney = NULL;
		
		m_uiTradeMoney = value2;
		
		m_uiTradeEmoney = value1;
	}
	else if (dlg == m_dlgAmount) 
	{
		/*
		int itemID = dlg->GetTag();
		int amount = value1;
		
		for (uint r = 0; r < ITEM_ROW; r++)
			for (uint c = 0; c < ITEM_COL; c++) 
			{
				Item* item = this->m_btnOurItem[r][c]->GetItem();
				if (item && item->iID == itemID) 
				{
					this->m_btnOurItem[r][c]->ChangeItem(item);
					return;
				}
			}
		
		m_dlgAmount = NULL;
		*/
	}
}

void NewTradeLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnMoney && !m_isInAcceptState) {
		ShowDialog(true);
	}
}

void NewTradeLayer::SendTrade(int data, Byte action)
{
	NDTransData bao(_MSG_TRADE);
	bao << data << action;
	SEND_DATA(bao);
}

void NewTradeLayer::processTrade(NDManualRole* tradeRole, int nData, int action)
{
	if (!s_instance && action != 9) {
		return;
	}
	
	if (action == 9) { // 开始交易
		NDUISynLayer::Close();
		if (tradeRole) {
			if (!s_instance)
			{
				NDDirector::DefaultDirector()->PushScene(NewTradeScene::Scene());
				if (s_instance)
				{
					s_instance->m_idTradeRole = nData;
					if (s_instance->m_lbRoleName) 
					{
						s_instance->m_lbRoleName->SetText(tradeRole->m_name.c_str());
					}
				}
			}
		}
	} else if (action == 4) { // 交易成功
		//  交易成功提示
		/*if (GameScreen.getInstance() != null) {
		 GameScreen.getInstance().initNewChat(
		 new ChatRecord(5, "系统", "交易成功"));
		 }*/
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("TradeSucess"));
		NDDirector::DefaultDirector()->PopScene();
	} else if (action == 5) { // 交易失败
		NDDirector::DefaultDirector()->PopScene();
		// // 交易提示
		/*if (GameScreen.getInstance() != null) {
		 GameScreen.getInstance().initNewChat(
		 new ChatRecord(5, "系统", "交易失败"));
		 }*/
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("TradeFail"));
	} else if (action == 7) { // 对方加物品
		s_instance->AddItem(nData);
	} else if (action == 8) { // 加钱
		s_instance->AddMoney(nData);
	} else if (action == 11) { // 加元宝
		s_instance->AddEMoney(nData);
	} else if (action == 3) { // 同意交易
		s_instance->AcceptTrade(nData);
	}
}

bool NewTradeLayer::isUILayerShown()
{
	return s_instance != NULL;
}

void NewTradeLayer::ShowItemDetail(Item* item)
{
	if (item) {
		if (item->isFormula() || item->isItemPet() || item->isSkillBook()) {
			sendQueryDesc(item->iID);
		} else {
			GlobalShowDlg(item->getItemName(), item->makeItemDes(false, false));
		}
	}
}

void NewTradeLayer::AddItem(OBJID idItem)
{
	Item* item = ItemMgrObj.QueryOtherItem(idItem);
	if (item) {
		for (uint r = 0; r < ITEM_ROW; r++) {
			for (uint c = 0; c < ITEM_COL; c++) {
				if (!this->m_btnOtherItem[r][c]->GetItem()) {
					this->m_btnOtherItem[r][c]->ChangeItem(item);
					return;
				}
			}
		}
	}	
}

void NewTradeLayer::AddMoney(int nMoney)
{
	if (m_lbMoneyOther) {
		std::stringstream ss; ss << nMoney;
		m_lbMoneyOther->SetText(ss.str().c_str());
	}
}

void NewTradeLayer::AddEMoney(int nEMoney)
{
	if (m_lbEMoneyOther) {
		std::stringstream ss; ss << nEMoney;
		m_lbEMoneyOther->SetText(ss.str().c_str());
	}
}

void NewTradeLayer::AcceptTrade(int idTrade)
{
	ShowOtherCommitLayer(true);
}

#pragma mark 新交易场景
	
enum 
{
	eListBegin = 0,
	eListTrade = eListBegin,
	eListEnd,
};

IMPLEMENT_CLASS(NewTradeScene, NDCommonScene)

NewTradeScene* NewTradeScene::Scene()
{
	NewTradeScene *scene = new NewTradeScene;
	
	scene->Initialization();
	
	return scene;
}

NewTradeScene::NewTradeScene()
{
	m_tabNodeSize.width = 150;
	m_btnCommit = NULL;
}

NewTradeScene::~NewTradeScene()
{
}

void NewTradeScene::Initialization()
{
	NDCommonScene::Initialization();
	
	SAFE_DELETE_NODE(m_btnNext);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *pic = pool.AddPicture(GetImgPathNew("newui_btn.png"));
	
	NDPicture *picCommit = pool.AddPicture(GetImgPathNew("trade_commit.png"));
	
	CGSize size = pic->GetSize();
	
	CGSize sizeCommit = picCommit->GetSize();
	
	m_btnCommit = new NDUIButton;
	
	m_btnCommit->Initialization();
	
	m_btnCommit->SetFrameRect(CGRectMake(7, 37-size.height, size.width, size.height));
	
	m_btnCommit->SetBackgroundPicture(pic, NULL, false, CGRectZero, true);
	
	m_btnCommit->SetImage(picCommit, true, CGRectMake((size.width-sizeCommit.width)/2, (size.height-sizeCommit.height)/2, sizeCommit.width, sizeCommit.height), true);
	
	m_btnCommit->SetDelegate(this);
	
	m_layerBackground->AddChild(m_btnCommit);
	
	const char * tabtext[eListEnd] = 
	{
		NDCommonCString("trade"),
	};
	
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 150, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 150, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == eListTrade) 
		{
			this->InitTrade(client);
		}
	}
	
	//this->SetTabFocusOnIndex(eListTrade, true);
}

void NewTradeScene::InitTrade(NDUIClientLayer* client)
{
	if (!client) return;
	
	m_layerTrade = new NewTradeLayer;
	m_layerTrade->Initialization();
	m_layerTrade->SetFrameRect(CGRectMake(0, 0, client->GetFrameRect().size.width, client->GetFrameRect().size.height));
	client->AddChild(m_layerTrade);
}

void NewTradeScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnCommit)
	{
		if (m_layerTrade)
			m_layerTrade->commitTrade();
	}
	else if (button == m_btnClose)
	{
		if (m_layerTrade)
			m_layerTrade->cancelTrade();
	}
}
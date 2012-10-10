/*
 *  AuctionSearchLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "AuctionSearchLayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDUISearchButton.h"
#include "NDUISynLayer.h"
#include "AuctionDef.h"
#include "AuctionUILayer.h"

const char* OPT_ALL = NDCommonCString("all");
const char* OPT_TYPES_STR[27] = {
    NDCommonCString("ShuanShouDao"), NDCommonCString("ShuanShouJian"), NDCommonCString("ShuanShouZhang"), NDCommonCString("ShuanShouGong"),
	NDCommonCString("DangShouDao"), NDCommonCString("DangShouJian"), NDCommonCString("BiShou"), NDCommonCString("TouKui"),
	NDCommonCString("JianJia"), NDCommonCString("XiongJia"), NDCommonCString("HuWang"), NDCommonCString("PiFeng"),
	NDCommonCString("HuTui"), NDCommonCString("XieZhi"), NDCommonCString("XiangLiang"), NDCommonCString("ErHuan"),
	NDCommonCString("HuiJi"), NDCommonCString("JieZhi"), NDCommonCString("ZhangChong"), NDCommonCString("QiChong"),
	NDCommonCString("HuiHuLei"), NDCommonCString("KuangShi"), NDCommonCString("JuangZhou"), NDCommonCString("TeShuXiaoHaoPing"),
	NDCommonCString("BaoShi"), NDCommonCString("PeiFang"), NDCommonCString("QuestItem"),
};

enum eOptTypes {
	TYPE_SHUANG_SHOU_DAO,
	TYPE_SHUANG_SHOU_JIAN,
	TYPE_SHUANG_SHOU_ZHANG,
	TYPE_SHUANG_SHOU_GONG,
	TYPE_DAN_SHOU_DAO,
	TYPE_DAN_SHOU_JIAN,
	TYPE_BI_SHOU,
	TYPE_TOU_KUI,
	TYPE_JIAN_JIA,
	TYPE_XIONG_JIA,
	TYPE_HU_WANG,
	TYPE_PI_FENG,
	TYPE_HU_TUI,
	TYPE_XIE_ZI,
	TYPE_XIANG_LIAN,
	TYPE_ER_HUAN,
	TYPE_HUI_JI,
	TYPE_JIE_ZHI,
	TYPE_ZHAN_CONG,
	TYPE_QI_CONG,
	TYPE_HUI_FU_LEI,
	TYPE_KUANG_SHI,
	TYPE_JUAN_ZHOU,
	TYPE_TE_SHU_XIAO_HAO_PIN,
	TYPE_BAO_SHI,
	TYPE_PEI_FANG,
	TYPE_REN_WU_WU_PIN,
};

const Byte OPT_TYPES_CODE[27] = {
	11, 12, 13, 14,
	21, 22, 23, 41,
	42, 43, 44, 45,
	46, 47, 51, 52,
	53, 54, 61, 64,
	71, 72, 74, 78,
	79, 80, 91
};

const char* OPT_QUALITY_STR[5] = {
	NDCommonCString("putong"), NDCommonCString("jingzhi"), NDCommonCString("xiyou"), NDCommonCString("sishi"), NDCommonCString("chuanshuo"),
};

enum eOptQuality {
	QUALITY_PU_TONG,
	QUALITY_JIN_ZHI,
	QUALITY_XI_YOU,
	QUALITY_SHI_SHI,
	QUALITY_CHUANG_SHUO,
};

const char* OPT_LEVEL_STR[6] = {
	NDCommonCString("LvlRange1"),
	NDCommonCString("LvlRange2"),
	NDCommonCString("LvlRange3"),
	NDCommonCString("LvlRange4"),
	NDCommonCString("LvlRange5"),
	NDCommonCString("LvlRange6"),
};

enum eOptLevel {
	LEVEL_ONE_TO_TEN,
	LEVEL_TEN_TO_TWENTY,
	LEVEL_TEWNTY_TO_THIRTY,
	LEVEL_THIRTY_TO_FORTY,
	LEVEL_FORTY_TO_FIFTY,
	LEVEL_FIFTY_PLUS,
};

const char* OPT_MONEY_STR[2] = { 
	NDCommonCString("money"),
	NDCommonCString("emoney"), };

enum eOptMoney {
	MONEY,
	EMONEY,
};

const char* OPT_APPEND_STR[3] = { "0-4", "5-9", NDCString("tenup") };

enum eOptAppend {
	APPEND_0_4,
	APPEND_5_9,
	APPEND_10_PLUS,
};

const char* OPT_GROUP_STR[5] = {
	NDCommonCString("ZhongLei"), NDCommonCString("PingZhi"), NDCommonCString("level"), NDCommonCString("MoneyType"), NDCommonCString("ZhuiJia"),
};

enum TAG_TABLE_LAYER {
	TAG_OPT_TYPE = 1,
	TAG_OPT_QUALITY,
	TAG_OPT_LEVEL,
	TAG_OPT_MONEY,
	TAG_OPT_APPEND,
};

AuctionSearchLayer* AuctionSearchLayer::s_instance = NULL;

IMPLEMENT_CLASS(AuctionSearchLayer, NDUILayer)

AuctionSearchLayer::AuctionSearchLayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	m_selType = 0;
	m_selLevel = 0;
	m_selQuality = 0;
	m_selAppend = 0;
	m_selMoney = 0;
}

AuctionSearchLayer::~AuctionSearchLayer()
{
	s_instance = NULL;
}

void AuctionSearchLayer::Show()
{
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			AuctionSearchLayer *list = new AuctionSearchLayer;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		}
	}
}

void AuctionSearchLayer::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	this->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	
	int nOptWidth = 200;
	int nHeight = 0;
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(16, 56, 66, 255));	
	this->AddChild(m_tlMain);
	
	NDDataSource* ds = new NDDataSource;
	m_tlMain->SetDataSource(ds);
	
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCommonCString("confirm"));
	btn->SetBackgroundColor(ccc4(107, 158, 156, 255));
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	sec->AddCell(btn);
	nHeight += 30;
	
	NDUISearchButton* searchBtn = NULL;
	
	for (int i = 0 ; i < 5; i++) {
		searchBtn = new NDUISearchButton;
		searchBtn->Initialization();
		searchBtn->SetTitles(OPT_GROUP_STR[i], OPT_ALL);
		searchBtn->SetBackgroundColor(ccc4(107, 158, 156, 255));
		searchBtn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(searchBtn);
		nHeight += 30;
	}
	
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(NDCString("searchbyname"));
	btn->SetBackgroundColor(ccc4(107, 158, 156, 255));
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	sec->AddCell(btn);
	nHeight += 30;
	
	sec->SetFocusOnCell(0);
	
	m_tlMain->SetFrameRect(CGRectMake((winsize.width - nOptWidth) / 2, (winsize.height - nHeight) / 2, nOptWidth, nHeight - 4));
}

bool AuctionSearchLayer::OnCustomViewConfirm(NDUICustomView* customView)
{
	this->RemoveFromParent(true);
	AuctionUILayer::Show(3);
	NDTransData bao(_MSG_AUCTION_QUEST_BY_NAME);
	bao.WriteUnicodeString(customView->GetEditText(0));
	SEND_DATA(bao);
	return true;
}

void AuctionSearchLayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_tlMain == table) {
		m_tlMain->SetVisible(false);
		switch (cellIndex) {
			case 0: // 确认
			{
				if ((m_selType | m_selQuality | m_selLevel | m_selMoney | m_selAppend) == 0) {
					// 没有条件
					NDTransData bao(_MSG_AUCTION);
					bao << Byte(AUCTION_QUEST) << 0 << 1;
					SEND_DATA(bao);
					AuctionUILayer::Show(3);
				} else {
					NDTransData bao(_MSG_AUCTION_QUEST);
					if (m_selType <= 0 || m_selType >= 27)
						bao << Byte(0);
					else
						bao << Byte(OPT_TYPES_CODE[m_selType-1]);
					
					bao << m_selLevel
					<< (m_selQuality == 0 ? Byte(0) : Byte(m_selQuality + 4))
					<< m_selAppend
					<< m_selMoney;
					SEND_DATA(bao);
					AuctionUILayer::Show(2);
				}
				this->RemoveFromParent(true);
				ShowProgressBar;
			}
				break;
			case 1: // 种类
			case 2: // 品质
			case 3: // 等级
			case 4: // 货币类型
			case 5: // 追加
				this->ShowFilter(cellIndex);
				break;
			case 6: // 按名字
			{
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetDelegate(this);
				std::vector<int> vec_id;
				vec_id.push_back(1);
				std::vector<std::string> vec_str;
				vec_str.push_back(NDCString("InputQueryItemName"));
				view->SetEdit(1, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			}
				break;
			default:
				break;
		}
	} else {
		int tag = table->GetTag();
		switch (tag) {
			case TAG_OPT_TYPE:
				m_selType = cellIndex;
				break;
			case TAG_OPT_QUALITY:
				m_selQuality = cellIndex;
				break;
			case TAG_OPT_LEVEL:
				m_selLevel = cellIndex;
				break;
			case TAG_OPT_MONEY:
				m_selMoney = cellIndex;
				break;
			case TAG_OPT_APPEND:
				m_selAppend = cellIndex;
				break;
			default:
				break;
		}
		
		NDUIButton* btn = (NDUIButton*)cell;
		string strOpt = btn->GetTitle();
		
		NDDataSource* ds = m_tlMain->GetDataSource();
		NDSection* sec = ds->Section(0);
		NDUISearchButton* searchBtn = (NDUISearchButton*)sec->Cell(tag);
		searchBtn->SetTitles(OPT_GROUP_STR[tag - 1], strOpt);
		
		m_tlMain->SetVisible(true);
		table->RemoveFromParent(true);
	}
}

void AuctionSearchLayer::ShowFilter(int filterType)
{
	int nStart = 0;
	int nEnd = 0;
	const char** pOptStr;
	
	switch (filterType) {
		case 1: // 种类
			nStart = TYPE_SHUANG_SHOU_DAO;
			nEnd = TYPE_REN_WU_WU_PIN;
			pOptStr = OPT_TYPES_STR;
			break;
		case 2: // 品质
			nStart = QUALITY_PU_TONG;
			nEnd = QUALITY_CHUANG_SHUO;
			pOptStr = OPT_QUALITY_STR;
			break;
		case 3: // 等级
			nStart = LEVEL_ONE_TO_TEN;
			nEnd = LEVEL_FIFTY_PLUS;
			pOptStr = OPT_LEVEL_STR; 
			break;
		case 4: // 货币类型
			nStart = MONEY;
			nEnd = EMONEY;
			pOptStr = OPT_MONEY_STR;
			break;
		case 5: // 追加
			nStart = APPEND_0_4;
			nEnd = APPEND_10_PLUS;
			pOptStr = OPT_APPEND_STR;
			break;
		default:
			return;
	}
	
	NDUITableLayer* optType = new NDUITableLayer;
	optType->Initialization();
	optType->SetDelegate(this);
	optType->VisibleSectionTitles(false);
	optType->VisibleScrollBar(true);
	optType->SetBackgroundColor(ccc4(16, 56, 66, 255));	
	optType->SetTag(filterType);
	this->AddChild(optType);
	
	NDDataSource* ds = new NDDataSource;
	optType->SetDataSource(ds);
	
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	int nHeight = 0;
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetTitle(OPT_ALL);
	btn->SetBackgroundColor(ccc4(107, 158, 156, 255));
	btn->SetFocusColor(ccc4(253, 253, 253, 255));
	sec->AddCell(btn);
	nHeight += 30;
	
	for (int i = nStart; i <= nEnd; i++) {
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(pOptStr[i]);
		btn->SetBackgroundColor(ccc4(107, 158, 156, 255));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
	}
	
	sec->SetFocusOnCell(0);
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	nHeight = min(nHeight, 200);
	optType->SetFrameRect(CGRectMake((winsize.width - 200) / 2, (winsize.height - nHeight) / 2, 200, nHeight - 3));
}

void AuctionSearchLayer::OnCustomViewCancle(NDUICustomView* customView)
{
	m_tlMain->SetVisible(true);
}

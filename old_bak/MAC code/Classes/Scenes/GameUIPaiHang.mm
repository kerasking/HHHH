/*
 *  GameUIPaiHang.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUIPaiHang.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDUISynLayer.h"
#include "GameUIPlayerList.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "NDPath.h"
#include <sstream>


IMPLEMENT_CLASS(LabelLayer, NDUILayer)

LabelLayer::LabelLayer()
{
	m_bShowFrame = true; 
	m_uiFontSize = 15; 
	m_colorFont = ccc4(11, 34, 18, 255);
}

void LabelLayer::Initialization()
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(ccc4(173, 186, 173, 255));
}

void LabelLayer::draw()
{
	NDUILayer::draw();
	
	CGRect scrRect = this->GetScreenRect();	
	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) 
	{
		NDUILayer *uiLayer = (NDUILayer*)parentNode;
		//draw focus 
		if (uiLayer->GetFocus() == this) 
		{
			DrawRecttangle(scrRect, ccc4(255, 206, 70, 255));					
		}
	}
	
	if (m_bShowFrame) 
	{
		DrawLine(scrRect.origin, 
				 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
				 ccc4(0	, 0, 0,255),
				 1);
		DrawLine(scrRect.origin, 
				 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y),
				 ccc4(0, 0, 0,255),
				 1);
		DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y), 
				 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
				 ccc4(0, 0, 0,255),
				 1);
		DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
				 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
				 ccc4(0, 0, 0,255),
				 1);

	}
}

void LabelLayer::SetTexts(std::vector<std::string> vec_str)
{
	this->RemoveAllChildren(true);
	
	if (vec_str.empty()) 
	{
		return;
	}
	
	SetText(vec_str[0], LabelTextAlignmentLeft);
	if (vec_str.size() > 2) 
	{
		SetText(vec_str[1], LabelTextAlignmentCenter);
		SetText(vec_str[2], LabelTextAlignmentRight);
	}
	else if (vec_str.size() == 2)
	{
		SetText(vec_str[1], LabelTextAlignmentRight);
	} 
}

//　默认15
void LabelLayer::SetFontSize(unsigned int size)
{ 
	m_uiFontSize = size; 
	std::vector<NDNode*> nodes = this->GetChildren();
	std::vector<NDNode*>::iterator it = nodes.begin();
	for (; it != nodes.end(); it++) 
	{
		NDNode* node = *it;
		if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
		{
			((NDUILabel*)node)->SetFontSize(size);
		}
	}
}
// 默认墨绿色
void LabelLayer::SetFontColor(ccColor4B color) 
{ 
	m_colorFont = color; 
	std::vector<NDNode*> nodes = this->GetChildren();
	std::vector<NDNode*>::iterator it = nodes.begin();
	for (; it != nodes.end(); it++) 
	{
		NDNode* node = *it;
		if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUILabel))) 
		{
			((NDUILabel*)node)->SetFontColor(color);
		}
	}
}

void LabelLayer::ShowFrame(bool bShow)
{
	m_bShowFrame = bShow;
}

void LabelLayer::SetText(std::string str, LabelTextAlignment align)
{
	CGSize size;
	if (str.empty())
	{
		size = CGSizeZero;
	}
	else 
	{
		size = getStringSizeMutiLine(str.c_str(), m_uiFontSize);
	}

	CGRect rect = this->GetFrameRect();
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetFontSize(m_uiFontSize);
	lb->SetFontColor(m_colorFont);
	lb->SetTextAlignment(align);
	if (str.empty()) 
	{
		lb->SetText("");
	}
	else 
	{
		lb->SetText(str.c_str());
	}

	int iY;
	if (size.height > rect.size.height) 
	{
		iY = 0;
	}
	else 
	{
		iY = (rect.size.height-size.height)/2;
	}

	lb->SetFrameRect(CGRectMake(3, iY, rect.size.width-10, rect.size.height));
	
	this->AddChild(lb);
}

/////////////////////////////////////////////////////////
#define title_height 28
#define bottom_height 42

#define BTN_W (85)
#define BTN_H (23)

#define MAIN_TB_X (5)

#define SCROLL_BAR_W (28)

IMPLEMENT_CLASS(GameUIPaiHang, NDUIMenuLayer)

GameUIPaiHang::GameUIPaiHang()
{
	m_llTitle = NULL;
	m_tlMain = NULL;
	m_tlQuery = NULL;
	m_topLayerEx = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	
	m_lbPage = NULL;
	
	m_iCurPage = 1;
	
	m_iNextPage = 1;
}

GameUIPaiHang::~GameUIPaiHang()
{
}

void GameUIPaiHang::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_llTitle = new LabelLayer;
	m_llTitle->Initialization();
	m_llTitle->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_llTitle->SetFrameRect(CGRectMake(15, 8, winsize.width-30, 20));
	m_llTitle->SetFontSize(15);
	m_llTitle->ShowFrame(false);
	m_llTitle->SetVisible(false);
	this->AddChild(m_llTitle);

	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->VisibleScrollBar(true);
	this->AddChild(m_tlMain);
	
	
	m_topLayerEx = new NDUITopLayerEx;
	m_topLayerEx->Initialization();
	m_topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(m_topLayerEx);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	this->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	this->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	this->AddChild(m_lbPage);
	
	UpdateMainUI();
}

void GameUIPaiHang::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
			this->RemoveFromParent(true);
		}
	}
	else if (button == m_btnNext)
	{
		m_iNextPage = m_iCurPage + 1;
		if (m_iNextPage > totalPages) 
		{
			m_iNextPage = totalPages;
		}
		turnPage();
		
	}
	else if (button == m_btnPrev)
	{
		m_iNextPage = m_iCurPage - 1;
		if (m_iNextPage < 1) 
		{
			m_iNextPage = 1;
		}
		turnPage();
	}
}

void GameUIPaiHang::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain)
	{
		ShowQuery(true);
	}
	else if (table == m_tlQuery)
	{
		NDTransData bao(_MSG_BILLBOARD_USER);
		bao << (int)curPaiHangType;
		SEND_DATA(bao);
		ShowQuery(false);
	}
	
}

void GameUIPaiHang::draw()
{
	NDUIMenuLayer::draw();
}

void GameUIPaiHang::UpdateMainUI()
{
	if (!m_tlMain || !m_llTitle || !m_lbPage)
	{
		return;
	}
	
	if (fildTypes.empty() || fildTypes.size() != fildNames.size() || values.size() % fildTypes.size() != 0) 
	{
		return;
	}
	
	m_iCurPage = m_iNextPage;
	
	m_lbPage->SetVisible(!(totalPages == 0));
	m_btnPrev->SetVisible(!(totalPages == 0));
	m_btnNext->SetVisible(!(totalPages == 0));
	
	std::stringstream ss; ss << m_iCurPage << "/" << totalPages;
	m_lbPage->SetText(ss.str().c_str());
	
	m_llTitle->SetTexts(fildNames); m_llTitle->SetVisible(true);
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	//section->UseCellHeight(true);
	int iValueSize = values.size();
	int iFields = fildTypes.size();
	for (int i =0; i < iValueSize; i+=iFields ) 
	{
		std::vector<std::string> vec_str;
		for (int j = 0; j < iFields; j++) 
		{
			vec_str.push_back(values[i+j]);
		}
		
		for (std::vector<std::string>::iterator it = vec_str.begin(); it != vec_str.end(); it++) {
			NDLog(@"%@", [NSString stringWithUTF8String:(*it).c_str()]);
		}
		LabelLayer *ll = new LabelLayer;
		ll->Initialization();
		ll->SetFrameRect(CGRectMake(0, 0, winsize.width-2*MAIN_TB_X-SCROLL_BAR_W, 30));
		ll->SetTexts(vec_str);
		section->AddCell(ll);
	}
	
	dataSource->AddSection(section);
	
	int iHeigh = (iValueSize/iFields)*30;//+(iValueSize/iFields)+1;
	int iHeighMax = winsize.height-title_height-bottom_height-2*2-20;
	if (iHeigh > iHeighMax) 
	{
		m_tlMain->VisibleScrollBar(true);
	}
	else 
	{
		m_tlMain->VisibleScrollBar(false);
	}

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

void GameUIPaiHang::ShowQuery(bool bShow)
{
	if (!m_topLayerEx) 
	{
		return;
	}
	
	if (!m_tlQuery) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		m_tlQuery = new NDUITableLayer;
		m_tlQuery->Initialization();
		m_tlQuery->SetDelegate(this);
		m_tlQuery->SetVisible(false);
		m_tlQuery->VisibleSectionTitles(false);
		m_topLayerEx->AddChild(m_tlQuery);
		 
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		NDUIButton *btn = new NDUIButton;
		btn->Initialization();
		btn->SetFontSize(15);
		btn->SetFontColor(ccc4(11, 34, 18, 255));
		btn->SetTitle("查看自己排行");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		btn->SetFrameRect(CGRectMake(0, (30-15)/2, 120, 30));
		section->AddCell(btn);
		dataSource->AddSection(section);
		m_tlQuery->SetFrameRect(CGRectMake((winsize.width-120)/2, (winsize.height-32)/2, 120, 32));
		m_tlQuery->SetDataSource(dataSource);
	}
	m_tlQuery->SetVisible(bShow);
}

void GameUIPaiHang::turnPage()
{
	if (m_iNextPage == m_iCurPage) {
		return;
	}
	NDTransData bao(_MSG_BILLBOARD);
	bao << int(curPaiHangType) << int(m_iNextPage-1);
	SEND_DATA(bao);
	ShowProgressBar;
}


std::vector<int> GameUIPaiHang::fildTypes;
std::vector<std::string> GameUIPaiHang::fildNames;
int GameUIPaiHang::curPaiHangType = 0;
int GameUIPaiHang::itype = 0;
int GameUIPaiHang::totalPages = 0;
std::vector<std::string> GameUIPaiHang::values;

void GameUIPaiHang::DataInit()
{
	fildTypes.clear();
	fildNames.clear();
	curPaiHangType = 0;
	itype = 0;
	totalPages = 0;
	values.clear();
}
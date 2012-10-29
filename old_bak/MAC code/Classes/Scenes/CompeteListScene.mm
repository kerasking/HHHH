/*
 *  CompeteListScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "CompeteListScene.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "NDUIDialog.h"
#include "GameUIPlayerList.h"
#include "NDUISynLayer.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDUtility.h"
#include "define.h"
#include "NDMsgDefine.h"
#include "NDPath.h"
#include <sstream>

void CompetelistUpdate(int iType, int iCurpage, int iTotalPage, VEC_SOCIAL_ELEMENT& elements)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(CompetelistScene))) 
	{
		scene = new CompetelistScene;
		scene->Initialization();
		NDDirector::DefaultDirector()->PushScene(scene);
	}
	
	((CompetelistScene*)scene)->refresh(iType, iCurpage, iTotalPage, elements);
}

////////////////////////////////////////////////
#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

#define DIS_COUNT (20)

enum  
{
	eOP_LookBattle = 55,
	eOP_LookWish,
};

IMPLEMENT_CLASS(CompetelistScene, NDScene)

CompetelistScene::CompetelistScene()
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
	
	memset(m_lbSubTitle, 0, sizeof(m_lbSubTitle));
	m_menulayerBG = NULL;
	m_curOpertaeElement = NULL;
}

CompetelistScene::~CompetelistScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
	
	ClearSocialElements();
}

void CompetelistScene::Initialization()
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
	
	NDUILayer *tmpLayer = new NDUILayer;
	tmpLayer->Initialization();
	tmpLayer->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->SetBackgroundColor(ccc4(119,119,119,255));
	m_menulayerBG->AddChild(tmpLayer);
	
	m_lbSubTitle[0] = new NDUILabel;
	m_lbSubTitle[0]->Initialization();
	m_lbSubTitle[0]->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSubTitle[0]->SetFontSize(15);
	m_lbSubTitle[0]->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbSubTitle[0]->SetFrameRect(CGRectMake(10, (20-15)/2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->AddChild(m_lbSubTitle[0]);
	
	m_lbSubTitle[1] = new NDUILabel;
	m_lbSubTitle[1]->Initialization();
	m_lbSubTitle[1]->SetTextAlignment(LabelTextAlignmentRight);
	m_lbSubTitle[1]->SetFontSize(15);
	m_lbSubTitle[1]->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbSubTitle[1]->SetFrameRect(CGRectMake(0, 0, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->AddChild(m_lbSubTitle[1]);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	//m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menulayerBG->AddChild(m_tlMain);
	
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

void CompetelistScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage <= 1) 
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("FirstPageTip"));
		} 
		else
		{
			if(m_iType==Competelist_Wish)
			{
				sendWish(m_iCurPage-1);
			}
			else
			{
				sendCompetition(m_iCurPage-1);
			}
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage >= GetPageNum())
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("LastPageTip"));
		} 
		else
		{
			if(m_iType == Competelist_Wish)
			{
				sendWish(m_iCurPage+1);
			}
			else
			{
				sendCompetition(m_iCurPage+1);
			}
		}
	}
}

void CompetelistScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain && cell->IsKindOfClass(RUNTIME_CLASS(SocialTextLayer)))
	{
		SocialElement *se = ((SocialTextLayer*)cell)->GetSocialElement();
		if (!se) 
		{
			return;
		}
		m_curOpertaeElement = se;
		
		std::vector<std::string> vec_str;
		std::vector<int> vec_id;
		switch (m_iType) 
		{
			case Competelist_VS:
			{
				vec_str.push_back(NDCommonCString("GuanZhang")); vec_id.push_back(eOP_LookBattle);
			}
				break;
			case Competelist_Wish:
			{
				vec_str.push_back(NDCommonCString("ViewWish")); vec_id.push_back(eOP_LookWish);
			}
				break;
			default:
				break;
		}
		
		if (!vec_str.empty()) 
		{
			InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		}
	}
	else if (table == m_tlOperate)
	{
		m_tlOperate->SetVisible(false);
		if (!m_curOpertaeElement) 
		{
			return;
		}
		
		switch (m_iType) 
		{
			case Competelist_VS:
			{
				if (cell->GetTag() == eOP_LookBattle) 
				{
					ShowProgressBar;
					NDTransData bao(_MSG_ENTER_ARENA);
					bao << int(m_curOpertaeElement->m_id) << int(m_curOpertaeElement->m_param);
					SEND_DATA(bao);
				}
			}
				break;
			case Competelist_Wish:
			{
				if (cell->GetTag() == eOP_LookWish) 
				{
					ShowProgressBar;
					NDTransData bao(_MSG_WISH);
					bao << (unsigned char)0 << (unsigned char)0 << int(m_curOpertaeElement->m_id);
					SEND_DATA(bao);
				}
			}
				break;
			default:
				break;
		}
				
		m_curOpertaeElement = NULL;
	}
	
}

void CompetelistScene::refresh(int iType, int iCurPage, int iTotalpage, VEC_SOCIAL_ELEMENT& elements)
{
	NDAsssert(iType >= Competelist_Begin && iType < Competelist_End);
	
	m_iType = iType;
	
	std::string title, left, right;
	switch (iType) 
	{
		case Competelist_Joins:
		{
			title=NDCommonCString("CompeteList");
			left=NDCommonCString("PlayerMingZhi");
			right=""; 
		}
			break;
		case Competelist_VS:
		{
			title=NDCommonCString("CompeteBattleList");
			right=NDCommonCString("DuiZhangPlayer");
			left=NDCommonCString("DuiZhangPlayer");
		}
			break;
		case Competelist_Wish:
		{
			title=NDCommonCString("WishPool");
			left=NDCommonCString("WishPoolWish");
			right=NDCommonCString("time");
		}
			break;
		default:
			break;
	}
	
	if (m_lbTitle) m_lbTitle->SetText(title.c_str());
	if (m_lbSubTitle[0]) m_lbSubTitle[0]->SetText(left.c_str());
	if (m_lbSubTitle[1]) m_lbSubTitle[1]->SetText(right.c_str());
	
	m_iCurPage = iCurPage;
	m_iTotalPage = iTotalpage;
	
	std::stringstream strpage;
	strpage << m_iCurPage << "/" << GetPageNum();
	m_lbPage->SetText(strpage.str().c_str());

	UpdateMainUI(elements);
}

void CompetelistScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
		NDLog(@"CompetelistScene::InitTLContentWithVec初始化失败");
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

void CompetelistScene::UpdateMainUI(VEC_SOCIAL_ELEMENT& elements)
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
		
		ClearSocialElements();
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
						   CGRectMake(5.0f, 0.0f, 460.0f, 27.0f), *it);
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
	int iHeighMax = winsize.height-title_height-bottom_height-BTN_H-2*2-20;
	iHeigh = iHeigh < iHeighMax ? iHeigh : iHeighMax;
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2+20, winsize.width-2*MAIN_TB_X, iHeigh));
	
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
	
	ClearSocialElements();
	m_vecElement = elements;
}

int CompetelistScene::GetPageNum()
{
	return m_iTotalPage;
}

void CompetelistScene::ClearSocialElements()
{
	for_vec(m_vecElement, VEC_SOCIAL_ELEMENT_IT)
	{
		delete *it;
	}
	m_vecElement.clear();
}

void CompetelistScene::sendWish(int page)
{
	
	NDTransData bao(_MSG_WISH);
	bao << (unsigned char)1 << (unsigned char)0 << (unsigned short)page;
	SEND_DATA(bao);
	ShowProgressBar;
}

void CompetelistScene::sendCompetition(int page)
{
	NDTransData bao(_MSG_COMPETITION);
	bao << (unsigned char)m_iType << int(page);
	SEND_DATA(bao);
	ShowProgressBar;
}
////////////////////////////////////////////////


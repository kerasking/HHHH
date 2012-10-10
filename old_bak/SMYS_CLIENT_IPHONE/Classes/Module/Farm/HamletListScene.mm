/*
 *  HamletListScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "HamletListScene.h"
#include "FarmMgr.h"
#include "SocialTextLayer.h"
#include "GameUIPlayerList.h"
#include "NDUISynLayer.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDDirector.h"
#include "NDPicture.h"
#include "NDUtility.h"
#include "define.h"
#include <sstream>

////////////////////////////////////////////////
#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

#define DIS_COUNT (10)

enum  
{
	eMoveOP_FixMove = 787,
	eMoveOP_RandomMove,
};

IMPLEMENT_CLASS(HamletListScene, NDScene)

HamletListScene* HamletListScene::Scene()
{
	HamletListScene *scene = new HamletListScene;
	scene->Initialization();
	return scene;
}

HamletListScene::HamletListScene()
{
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	m_lbPage = NULL;
	m_iCurPage = 0;
	m_iType = HamletListScene_List;
	m_iTotalpage = 0;
	m_tlOperate = NULL;
	m_iCurOperateID = 0;
}

HamletListScene::~HamletListScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
	
	ClearSocialElements();
}

void HamletListScene::Initialization()
{
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if ( m_menulayerBG->GetOkBtn() ) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetText(NDCString("CunLuoList"));
	CGSize dim = getStringSizeMutiLine(NDCString("CunLuoList"), 15);
	m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	NDUILayer *tmpLayer = new NDUILayer;
	tmpLayer->Initialization();
	tmpLayer->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->SetBackgroundColor(ccc4(119,119,119,255));
	m_menulayerBG->AddChild(tmpLayer);
	
	NDUILabel *tmpName = new NDUILabel;
	tmpName->Initialization();
	tmpName->SetTextAlignment(LabelTextAlignmentLeft);
	tmpName->SetText(NDCString("CunLuoName"));
	tmpName->SetFontSize(15);
	tmpName->SetFontColor(ccc4(0, 0, 0, 255));
	tmpName->SetFrameRect(CGRectMake(10, (20-15)/2, winsize.width, 15));
	tmpLayer->AddChild(tmpName);
	
	NDUILabel *tmpState = new NDUILabel;
	tmpState->Initialization();
	tmpState->SetTextAlignment(LabelTextAlignmentLeft);
	tmpState->SetText(NDCString("RuZhuQingKuan"));
	tmpState->SetFontSize(15);
	tmpState->SetFontColor(ccc4(0, 0, 0, 255));
	//tmpState->SetFrameRect(CGRectMake(260, (20-15)/2, winsize.width, 15));
	tmpState->SetFrameRect(CGRectMake(400, (20-15)/2, winsize.width, 15));
	tmpLayer->AddChild(tmpState);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
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
	
	NDUITopLayerEx* topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menulayerBG->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
	
	//refresh();
}

void HamletListScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage > 0) 
		{
			m_iCurPage--;
			QueryPage(m_iCurPage);
		} 
		else
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("FirstPageTip"));
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage+1 < GetPageNum())
		{
			m_iCurPage++;
			QueryPage(m_iCurPage);
		} 
		else
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("LastPageTip"));
		}
	}
}

void HamletListScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain)
	{
		std::vector<HamletInfo>& infos = NDFarmMgrObj.m_vecHamletInfo;
		HamletInfo& info = infos[cellIndex];
		if (cellIndex >= infos.size() || cellIndex < 0)
		{
			return;
		}
		if	(m_iType == HamletListScene_List)
		{
			NDTransData bao(_MSG_ENTER_HAMLET);
			bao << (unsigned char)0 << int(info.idHamlet);
			SEND_DATA(bao);
			NDDirector::DefaultDirector()->PopScene();
		}
		else if	(m_iType == HamletListScene_Move)
		{
			m_iCurOperateID = info.idHamlet;
			
			std::vector<std::string> vec_str;
			std::vector<int> vec_id;
			vec_str.push_back(NDCString("FixMove")); vec_id.push_back(eMoveOP_FixMove);
			vec_str.push_back(NDCString("RandomMove")); vec_id.push_back(eMoveOP_RandomMove);
			vec_str.push_back(NDCommonCString("return")); vec_id.push_back(0);
			
			InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
		}
	}
	else if (table == m_tlOperate)
	{
		int iTag = cell->GetTag();
		
		if (iTag == eMoveOP_FixMove || iTag == eMoveOP_RandomMove)
		{
			NDTransData bao(_MSG_MOVE_FARMLAND);
			bao << (unsigned char)(iTag == eMoveOP_FixMove ? 0 : 2)
				<< int(m_iCurOperateID);
			SEND_DATA(bao);
		}
		
		m_tlOperate->SetVisible(false);
	}

}

void HamletListScene::refresh()
{
	VEC_SOCIAL_ELEMENT vec_element;
	
	std::vector<HamletInfo>& infos = NDFarmMgrObj.m_vecHamletInfo;
	
	int iHamletCount = infos.size();

	int iStart = m_iCurPage * DIS_COUNT;
	
	int iEnd = (m_iCurPage+1) * DIS_COUNT;
	
	for (int i = iStart; i < iEnd; i++) 
	{
		if (i >= iHamletCount) {
			continue;
		}
		
		HamletInfo& info = infos[i];
		
		std::stringstream ss; ss << info.nNum << "/23";
		
		SocialElement *element = new SocialElement;
		element->m_id = info.idHamlet;
		element->m_text1 = info.name;
		element->m_text2 = ss.str();
		
		vec_element.push_back(element);
	}

	std::stringstream strpage;
	strpage << m_iCurPage+1 << "/" << GetPageNum();
	m_lbPage->SetText(strpage.str().c_str());
	UpdateMainUI(vec_element);
}

int HamletListScene::GetPageNum()
{
	//int iHamletCount = NDFarmMgrObj.m_vecHamletInfo.size();
//	int iCount = iHamletCount/DIS_COUNT;
//	if (iHamletCount%DIS_COUNT != 0)
//	{
//		iCount += 1;
//	}
//	return iCount;
	return m_iTotalpage;
}

void HamletListScene::UpdateMainUI(VEC_SOCIAL_ELEMENT& elements)
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

void HamletListScene::ClearSocialElements()
{
	for_vec(m_vecElement, VEC_SOCIAL_ELEMENT_IT)
	{
		delete *it;
	}
	m_vecElement.clear();
}

void HamletListScene::SetType(int iType)
{
	m_iType = iType;
}

int HamletListScene::GetType()
{
	return m_iType;
}

void HamletListScene::SetPage(int iCurPage, int iTotalPage)
{
	m_iCurPage = iCurPage;
	m_iTotalpage = iTotalPage;
}

void HamletListScene::QueryPage(int iPage)
{
	if (m_iType < HamletListScene_Begin 
		|| m_iType >= HamletListScene_End
		|| iPage < 0
		|| iPage >= m_iTotalpage) 
	{
		return;
	}
	
	ShowProgressBar;
	
	NDTransData bao(_MSG_HAMLET);
	bao << (unsigned char)(m_iType == HamletListScene_List ? 0 : 1)
		<< (unsigned char)0
		<< (unsigned short)(iPage)
		<< (unsigned short)0
		<< (unsigned char)0;
	SEND_DATA(bao);
}

void HamletListScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
		NDLog(@"HamletListScene::InitTLContentWithVec初始化失败");
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
////////////////////////////////////////////////
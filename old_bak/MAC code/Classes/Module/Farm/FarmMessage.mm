/*
 *  FarmMessage.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FarmMessage.h"
#include "GameUIPlayerList.h"
#include "NDDirector.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"
#include "NDUtility.h"
#include "NDPath.h"
#include "define.h"
#include <sstream>

#define ONE_PAGE_COUNT (10)


FarmMsgListScene* QueryFarmMsgListScene(int iType)
{
	FarmMsgListScene *scene = NULL;
	switch (iType) 
	{
		case FarmMessage_Visit:
			scene = FarmMsgVisit::GetInstance();
			break;
		case FarmMessage_Steal:
			scene = FarmMsgSteal::GetInstance();
			break;
		case FarmMessage_User:
			scene = FarmMsgUser::GetInstance();
			break;
		case FarmMessage_Self:
			scene = FarmMsgSelf::GetInstance();
			break;
		default:
			break;
	}
	
	return scene;
}

FarmMsgListScene* CreateFarmMsgListScene(int iType)
{
	FarmMsgListScene *scene = NULL;
	switch (iType) 
	{
		case FarmMessage_Visit:
			scene = FarmMsgVisit::Scene();
			break;
		case FarmMessage_Steal:
			scene = FarmMsgSteal::Scene();
			break;
		case FarmMessage_User:
			scene = FarmMsgUser::Scene();
			break;
		case FarmMessage_Self:
			scene = FarmMsgSelf::Scene();
			break;
		default:
			break;
	}
	
	NDDirector::DefaultDirector()->PushScene(scene);
	
	return scene;
}

///////////////////////////////////////////////

#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

IMPLEMENT_CLASS(FarmMsgListScene, NDScene)

FarmMsgListScene::FarmMsgListScene()
{
	m_menulayerBG = NULL;
	m_tlMain = NULL;
	m_tlOperate = NULL;
	m_iFarmID = 0;
	m_btnPrev = NULL; m_picPrev = NULL;
	m_btnNext = NULL; m_picNext = NULL;
	m_lbPage = NULL;
	
	m_iCurPage = 0;
	m_iTotalPage = 0;
	m_iType = -1;
}

FarmMsgListScene::~FarmMsgListScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
}

void FarmMsgListScene::Initialization()
{
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	m_menulayerBG->ShowOkBtn();
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	if ( m_menulayerBG->GetOkBtn() ) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, title_height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_tlMain->SetVisible(false);
	//m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeigh));
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
}

void FarmMsgListScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_menulayerBG->GetOkBtn())
	{
		if	(m_tlOperate) m_tlOperate->SetVisible(true); 
	}
	else if (button == m_btnPrev) 
	{
		if (m_iCurPage > 0) 
		{
			m_iCurPage--;
			ClearList();
			queryPage(m_iCurPage);
		} 
	}
	else if (button == m_btnNext) 
	{
		if (m_iCurPage+1 < m_iTotalPage)
		{
			m_iCurPage++;
			ClearList();
			queryPage(m_iCurPage);
		}
	}
}

int FarmMsgListScene::GetCurPage()
{
	return m_iCurPage;
}

void FarmMsgListScene::setCurPage(int iPage)
{
	m_iCurPage = iPage;
}

void FarmMsgListScene::setSumPage(int iPage)
{
	m_iTotalPage = iPage;
}

void FarmMsgListScene::ClearList()
{
	if (m_tlMain && m_tlMain->GetDataSource()) 
	{
		m_tlMain->GetDataSource()->Clear();
		m_tlMain->ReflashData();
	}
	
	m_tlMain->SetVisible(false);
}

void FarmMsgListScene::AppendRecord(int iRecordID, std::string text)
{
#define fastinit(text, iid, color) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFontColor(ccc4(0, 0, 0, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, winsize.width-2*MAIN_TB_X, 30)); \
btn->SetFocusColor(ccc4(255, 207, 74, 255)); \
btn->SetBackgroundColor(color); \
section->AddCell(btn); \
} while (0)
	if (!m_tlMain) 
	{
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDDataSource *dataSource = NULL;
	if (!m_tlMain->GetDataSource()) 
	{
		dataSource = new NDDataSource;
		m_tlMain->SetDataSource(dataSource);
	}
	else 
	{
		dataSource = m_tlMain->GetDataSource();
	}
	
	NDSection *section = NULL;
	if (dataSource->Count() == 0) 
	{
		section = new NDSection;
		dataSource->AddSection(section);
		//section->UseCellHeight(true);
	}
	else 
	{
		section = dataSource->Section(0);
	}
	
	ccColor4B color = (section->Count()+1)%2 == 0 ? INTCOLORTOCCC4(0xe3e5da) : INTCOLORTOCCC4(0xc3d2d5);
	
	fastinit(text.c_str(), iRecordID, color);
	
	section->SetFocusOnCell(0);
	
	int iHeight = winsize.height-title_height-bottom_height-BTN_H-2;//+section->Count()+1;
	int iH = section->Count()*30;
//	if (iHeight > iH) {
//		iHeight = iH;
//	}
	
	m_tlMain->SetVisible(true);
	
	m_tlMain->VisibleScrollBar(iH > iHeight);
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeight));
	
	m_tlMain->ReflashData();
	
	UpdateTitle();

#undef fastinit	
}

void FarmMsgListScene::DelRecord(int iRecordID)
{
	if (!m_tlMain) 
	{
		return;
	}
	
	NDDataSource *dataSource = m_tlMain->GetDataSource();
	if (!dataSource || dataSource->Count() == 0) {
		return;
	}
	
	NDSection *section = dataSource->Section(0);
	
	int iCount = section->Count();
	
	for (int i = 0; i < iCount; i++) {
		NDUINode* node = section->Cell(i);
		if (node->GetTag() == iRecordID) {
			section->RemoveCell(i);
			m_tlMain->ReflashData();
			break;
		}
	}
	
	UpdateTitle();
}

void FarmMsgListScene::SetFarmID(int iFarmID)
{
	m_iFarmID = iFarmID;
}

void FarmMsgListScene::SetType(int iType)
{
	m_iType = iType;
}

int FarmMsgListScene::GetType()
{
	return m_iType;
}

void FarmMsgListScene::UpdateTitle()
{
	if (!m_lbTitle
		|| !m_tlMain 
		|| !m_tlMain->GetDataSource() 
		|| m_tlMain->GetDataSource()->Count() == 0) 
	{
		return;
	}
	
	std::stringstream ss; ss << m_title;
	int curCount = m_iCurPage * ONE_PAGE_COUNT;
	int curPageCount = m_tlMain->GetDataSource()->Section(0)->Count();
	if (curCount + curPageCount > 0) {
		ss<< "[" << (curCount + 1) << " ~ "
		<< (curCount + curPageCount) << "]";
	}
	
	m_lbTitle->SetText(ss.str().c_str());
}

void FarmMsgListScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
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
btn->SetFocusColor(ccc4(255, 207, 74, 255)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"FarmMsgListScene::InitTLContentWithVec初始化失败,type[%d]", m_iType);
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++)
	{
		fastinit(vec_str[i].c_str(), vec_id[i]);
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size())/2, 120, 30*vec_str.size()));
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

void FarmMsgListScene::queryPage(int page) 
{
	ShowProgressBar;
	NDTransData bao(_MSG_FARM_QUERY_MESSAGE);
	bao << (unsigned char)m_iType << (unsigned char)1 << int(m_iFarmID) << int(page);
	SEND_DATA(bao);
}

///////////////////////////////////////////////
IMPLEMENT_CLASS(FarmMsgVisit, FarmMsgListScene)

IMPLEMENT_SCENE(FarmMsgVisit)

FarmMsgVisit* FarmMsgVisit::s_instance = NULL;

FarmMsgVisit::FarmMsgVisit()
{
	s_instance = this;
}

FarmMsgVisit::~FarmMsgVisit()
{
	s_instance = NULL;
}

void FarmMsgVisit::Initialization()
{
	FarmMsgListScene::Initialization();
	m_lbTitle->SetText(NDCString("VisitRecord"));
	
	m_title = NDCString("VisitRecord");
	
	if (m_menulayerBG->GetOkBtn())
		m_menulayerBG->GetOkBtn()->SetVisible(false);
}

FarmMsgVisit* FarmMsgVisit::GetInstance()
{
	return s_instance;
}

///////////////////////////////////////////////
IMPLEMENT_CLASS(FarmMsgSteal, FarmMsgListScene)

IMPLEMENT_SCENE(FarmMsgSteal)

FarmMsgSteal* FarmMsgSteal::s_instance = NULL;

FarmMsgSteal::FarmMsgSteal()
{
	s_instance = this;
}

FarmMsgSteal::~FarmMsgSteal()
{
	s_instance = NULL;
}

void FarmMsgSteal::Initialization()
{
	FarmMsgListScene::Initialization();
	m_lbTitle->SetText(NDCString("TouQieRecord"));
	
	m_title = NDCString("TouQieRecord");
	
	if (m_menulayerBG->GetOkBtn())
		m_menulayerBG->GetOkBtn()->SetVisible(false);
}

FarmMsgSteal* FarmMsgSteal::GetInstance()
{
	return s_instance;
}

///////////////////////////////////////////////
enum
{
	eOP_LeaveMsg = 200,		//留言
	eOP_QueryMsg,			//查看
	eOP_DelMsg,				//删除
	eOP_Cancel,				//返回
};

IMPLEMENT_CLASS(FarmMsgSelf, FarmMsgListScene)

IMPLEMENT_SCENE(FarmMsgSelf)

FarmMsgSelf* FarmMsgSelf::s_instance = NULL;

FarmMsgSelf::FarmMsgSelf()
{
	s_instance = this;
}

FarmMsgSelf::~FarmMsgSelf()
{
	s_instance = NULL;
}

void FarmMsgSelf::Initialization()
{
	FarmMsgListScene::Initialization();
	std::vector<std::string> vec_str;
	std::vector<int> vec_id;
	vec_str.push_back(NDCommonCString("LiuYang")); vec_id.push_back(eOP_LeaveMsg);
	vec_str.push_back(NDCommonCString("ChaKang")); vec_id.push_back(eOP_QueryMsg);
	vec_str.push_back(NDCommonCString("del")); vec_id.push_back(eOP_DelMsg);
	vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Cancel);
	InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
	
	m_tlOperate->SetVisible(false);
	
	m_lbTitle->SetText(NDCString("FarmLiuYang"));
	
	m_title = NDCString("FarmLiuYang");
}

void FarmMsgSelf::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain) 
	{
		m_tlOperate->SetVisible(true);
	}
	else if (table == m_tlOperate) 
	{
		if (!m_tlMain || !m_tlMain->GetFocus()) 
		{
			return;
		}
		
		int iRecordID = m_tlMain->GetFocus()->GetTag();
		
		switch (cell->GetTag()) 
		{
			case eOP_LeaveMsg:
			{
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetDelegate(this);
				std::vector<int> vec_id; vec_id.push_back(1);
				std::vector<std::string> vec_str; vec_str.push_back(NDCString("FarmMax50Char"));
				view->SetEdit(1, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			}
				break;
			case eOP_QueryMsg:
			{
				NDTransData bao(_MSG_FARM_QUERY_MESSAGE);
				bao << (unsigned char)m_iType << (unsigned char)2 << int(m_iFarmID) << int(iRecordID);
				SEND_DATA(bao);
			}
				break;
			case eOP_DelMsg:
			{
				NDTransData bao(_MSG_FARM_QUERY_MESSAGE);
				bao << (unsigned char)m_iType << (unsigned char)3 << int(m_iFarmID) << int(iRecordID);
				SEND_DATA(bao);
			}
				break;
			case eOP_Cancel:
				break;
			default:
				break;
		}
		m_tlOperate->SetVisible(false);
	}
}

bool FarmMsgSelf::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string text = customView->GetEditText(0);
	if (int(text.size()) > 50) 
	{
		customView->ShowAlert(NDCString("FarmMax50CharFail"));
		return false;
	} 
	
	NDTransData bao(_MSG_FARM_LEAVE_MESSAGE);
	bao << (int)m_iFarmID;
	bao.WriteUnicodeString(text);
	SEND_DATA(bao);
	
	return true;
}

FarmMsgSelf* FarmMsgSelf::GetInstance()
{
	return s_instance;
}

///////////////////////////////////////////////
IMPLEMENT_CLASS(FarmMsgUser, FarmMsgSelf)

IMPLEMENT_SCENE(FarmMsgUser)

FarmMsgUser* FarmMsgUser::s_instance = NULL;

FarmMsgUser::FarmMsgUser()
{
	s_instance = this;
}

FarmMsgUser::~FarmMsgUser()
{
	s_instance = NULL;
}

void FarmMsgUser::Initialization()
{
	FarmMsgSelf::Initialization();
	std::vector<std::string> vec_str;
	std::vector<int> vec_id;
	vec_str.push_back(NDCommonCString("LiuYang")); vec_id.push_back(eOP_LeaveMsg);
	vec_str.push_back(NDCommonCString("ChaKang")); vec_id.push_back(eOP_QueryMsg);
	vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_Cancel);
	InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
	
	m_tlOperate->SetVisible(false);
	
	m_lbTitle->SetText(NDCString("FarmLiuYang"));
	
	m_title = NDCString("FarmLiuYang");
}

FarmMsgUser* FarmMsgUser::GetInstance()
{
	return s_instance;
}

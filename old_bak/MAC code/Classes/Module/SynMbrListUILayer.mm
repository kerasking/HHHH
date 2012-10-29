/*
 *  SynMbrListUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynMbrListUILayer.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "SyndicateCommon.h"
#include "NDUISynLayer.h"
#include "NDMapMgr.h"
#include <sstream>
#include "NDPlayer.h"
#include "ChatInput.h"
#include "SocialScene.h"
#include "NDPath.h"

enum MBR_OPT_LIST {
	eMbrOptBegin,
	eTalkTo = eMbrOptBegin,
	eAssignJob,
	eAddFriend,
	eShanRang,
	eKickOut,
	eMbrOptEnd,
};

enum {
	TAG_DLG_SHANG_RANG,
	TAG_DLG_KICK_OUT,
};

const char* MBR_OPT_TITLE[eMbrOptEnd] = {
	NDCommonCString("PrivateChat"),
	NDCommonCString("TakeOffice"),
	NDCommonCString("add"),
	NDCommonCString("ShangRang"),
	NDCommonCString("dismiss"),
};

IMPLEMENT_CLASS(AssignJobLayer, NDUILayer)

AssignJobLayer::AssignJobLayer()
{
	m_idMbr = 0;
	m_tlJobs = NULL;
}

AssignJobLayer::~AssignJobLayer()
{
	
}

void AssignJobLayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 6, 198, 200));
	this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("attr_role_bg.png")), true);
	
	NDUIImage* infoTitle = new NDUIImage;
	infoTitle->Initialization();
	infoTitle->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("farmrheadtitle.png")), true);
	infoTitle->SetFrameRect(CGRectMake(6, 13, 8, 8));
	this->AddChild(infoTitle);
	
	NDUILabel* lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontColor(ccc4(187, 19, 19, 255));
	lbTitle->SetText(NDCString("AppointPost"));
	lbTitle->SetFrameRect(CGRectMake(18, 8, 80, 30));
	this->AddChild(lbTitle);
	
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(150, 150, 38, 42));
	btn->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("btn_confirm.png")), false, CGRectZero, true);
	btn->SetDelegate(this);
	this->AddChild(btn);
	
	m_tlJobs = new NDUITableLayer;
	m_tlJobs->Initialization();
	m_tlJobs->SetBackgroundColor(ccc4(0, 255, 0, 0));
	m_tlJobs->VisibleSectionTitles(false);
	m_tlJobs->SetFrameRect(CGRectMake(0, 30, 188, 126));
	m_tlJobs->VisibleScrollBar(false);
	m_tlJobs->SetCellsInterval(2);
	m_tlJobs->SetCellsRightDistance(0);
	m_tlJobs->SetCellsLeftDistance(0);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlJobs->SetDataSource(dataSource);
	this->AddChild(m_tlJobs);
	
	Byte t_synRank[5] = {11,10,5,1,0};
	
	NDPropCell* cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(180, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("FuTuanZhang"));
	cell->SetFocusPicture(NDPath::GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	cell->SetTag(t_synRank[0]);
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(180, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("YuanLao"));
	cell->SetFocusPicture(NDPath::GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	cell->SetTag(t_synRank[1]);
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(180, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("TangZhu"));
	cell->SetFocusPicture(NDPath::GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	cell->SetTag(t_synRank[2]);
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(180, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("MengZhu"));
	cell->SetFocusPicture(NDPath::GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	cell->SetTag(t_synRank[3]);
	section->AddCell(cell);
	
	cell = new NDPropCell;
	cell->Initialization(false, CGSizeMake(180, 21));
	cell->SetKeyLeftDistance(18);
	cell->GetKeyText()->SetText(NDCommonCString("TuangYuan"));
	cell->SetFocusPicture(NDPath::GetImgPathNew("cell_mask.png"));
	cell->SetFocusTextColor(ccc4(187, 19, 19, 255));
	cell->SetTag(t_synRank[4]);
	section->AddCell(cell);
	
	section->SetFocusOnCell(0);
}

void AssignJobLayer::OnButtonClick(NDUIButton* button)
{
	if (m_tlJobs) {
		NDDataSource* ds = m_tlJobs->GetDataSource();
		if (ds) {
			NDSection* sec = ds->Section(0);
			if (sec) {
				uint uFocus = sec->GetFocusCellIndex();
				if (uFocus < sec->Count()) {
					NDUINode* focusCell = sec->Cell(uFocus);
					if (focusCell) {
						sendAssignMbrRank(m_idMbr, focusCell->GetTag(), 0);//m_btnPage->GetCurPage() - 1);
					}
				}
			}
		}
	}
}

void AssignJobLayer::SetMbrID(int idMbr)
{
	this->m_idMbr = idMbr;
}

IMPLEMENT_CLASS(SynMbrInfo, NDUILayer)

SynMbrInfo::SynMbrInfo()
{
	m_figure = NULL;
	
	m_info = NULL;
	
	m_socialEle = NULL;
	
	m_jobLayer = NULL;
}

SynMbrInfo::~SynMbrInfo()
{
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		NDUIButton*& btn = *it;
		
		if (btn && btn->GetParent() == NULL) 
		{
			delete btn;
		}
	}
	
	if (m_jobLayer && NULL == m_jobLayer->GetParent()) {
		SAFE_DELETE(m_jobLayer);
	}
}

void SynMbrInfo::Initialization(CGPoint pos)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBg = pool.AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBg = picBg->GetSize();
	
	this->SetBackgroundImage(picBg, true);
	
	this->SetFrameRect(CGRectMake(pos.x, pos.y, sizeBg.width, sizeBg.height));
	
	m_figure = new SocialFigure;
	
	m_figure->Initialization(false);
	
	m_figure->SetFrameRect(CGRectMake(11, 9, 178, 112));
	
	this->AddChild(m_figure);
	
	m_info = new SocialEleInfo;
	
	m_info->Initialization(CGRectMake(0, 123, 197, 83));
	
	this->AddChild(m_info);
	
	m_jobLayer = new AssignJobLayer;
	m_jobLayer->Initialization();
}

void SynMbrInfo::OnButtonClick(NDUIButton* button)
{
	if (!m_socialEle) return;
	
	if (m_jobLayer && m_jobLayer->GetParent()) {
		m_jobLayer->RemoveFromParent(false);
	}
	
	int op = button->GetTag();
	switch (op) {
		case eAssignJob:
		{
			if (m_jobLayer && m_jobLayer->GetParent() == NULL) {
				this->AddChild(m_jobLayer);
				m_jobLayer->SetMbrID(m_socialEle->m_id);
			}
		}
			break;
		case eTalkTo:
		{
			PrivateChatInput::DefaultInput()->SetLinkMan(m_socialEle->m_text1.c_str());
			PrivateChatInput::DefaultInput()->Show();
		}
			break;
		case eShanRang:
		{
			NDUIDialog* dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetTag(TAG_DLG_SHANG_RANG);
			dlg->SetDelegate(this);
			string content = NDCString("ConfirmShanRang");
			content += m_socialEle->m_text1;
			content += NDCString("ma");
			dlg->Show(NDCommonCString("WenXinTip"), content.c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
			break;
		case eAddFriend:
			sendAddFriend(m_socialEle->m_text1);
			break;
		case eKickOut:
		{
			NDUIDialog* dlg = new NDUIDialog;
			dlg->Initialization();
			dlg->SetTag(TAG_DLG_KICK_OUT);
			dlg->SetDelegate(this);
			string content = NDCString("ConfirmDismiss");
			content += m_socialEle->m_text1;
			content += NDCString("ConfirmDismiss2");
			dlg->Show(NDCommonCString("WenXinTip"), content.c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
			break;
		default:
			break;
	}
}

void SynMbrInfo::Change(SocialElement* se)
{
	m_socialEle = se;
	
	if (m_jobLayer && m_jobLayer->GetParent()) {
		m_jobLayer->RemoveFromParent(false);
	}
	
	if (m_figure)
		m_figure->ChangeFigure(m_socialEle);
	
		
	SocialData data;
	
	refreshSocialData();
	
	// 更新操作
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		NDUIButton*& btn = *it;
		if (btn) 
		{
			btn->RemoveFromParent(false);
			SAFE_DELETE(btn);
		}
	}
	
	if (!m_socialEle) {
		return;
	}
	
	NDPlayer& role = NDPlayer::defaultHero();
	if (m_socialEle->m_id == role.m_id) {
		return;
	}
	int t_synRank = role.getSynRank();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	NDUIButton* btn = NULL;
	
	int startx = 7, starty = 178, btnw = 43, btnh = 24, interval = 5;
	
	int nCount = 0;
	for (int i = eMbrOptBegin; i < eMbrOptEnd; i++) {
		if(i == eAssignJob || i == eShanRang){//任职 ||禅让，只有军团长有该权限
			if(t_synRank < SYNRANK_LEADER) {
				continue;
			}
		}else if(i == eKickOut){//开除成员，副团及以上有权限
			if(t_synRank < SYNRANK_VICE_LEADER) {
				continue;
			}
		} else if (i == eTalkTo || i == eAddFriend) { // 在线才允许操作
			if (m_socialEle->m_state == ES_OFFLINE) {
				continue;
			}
		}
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetFontColor(ccc4(255, 255, 255, 255));
		btn->SetFontSize(12);
		btn->CloseFrame();
		btn->SetTag(i);
		btn->SetTitle(MBR_OPT_TITLE[i]);
		btn->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png"), btnw, 0),
								  pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png"), btnw, 0),
								  false, CGRectZero, true);
		btn->SetDelegate(this);							 
		this->AddChild(btn);
		btn->SetFrameRect(CGRectMake(startx+(btnw+interval)*nCount,
									 starty+(btnh+interval), 
									 btnw, 
									 btnh));
		m_vOpBtn.push_back(btn);
		nCount++;
		if (nCount >= 4) {
			nCount = 0;
			starty = starty+btnh+interval;
		}
	}
}

void SynMbrInfo::refreshSocialData()
{
	if (m_info)
		m_info->ChaneSocialEle(m_socialEle);
	
	if (m_figure)
		m_figure->ChangeFigure(m_socialEle);
	
	if (m_figure && (!m_socialEle || !SocialScene::hasSocialData(m_socialEle->m_id)))
		m_figure->ShowLevel(false, 1);
	
	if (!m_socialEle) return;
	
	m_info->SetVisible(this->IsVisibled());
	
	m_figure->SetVisible(this->IsVisibled());
}

void SynMbrInfo::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	int tagDlg = dialog->GetTag();
	dialog->Close();
	if (!m_socialEle) {
		return;
	}
	switch (tagDlg) {
		case TAG_DLG_SHANG_RANG:
		{
			sendLeaveDemise(m_socialEle->m_id, 0);//m_btnPage->GetCurPage() - 1);
		}
			break;
		case TAG_DLG_KICK_OUT:
		{
			sendKickOut(m_socialEle->m_id, 0);//m_btnPage->GetCurPage() - 1);
		}
			break;
		default:
			break;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

SynMbrListUILayer* SynMbrListUILayer::s_instance = NULL;

map_social_data SynMbrListUILayer::s_mapSocialData;

IMPLEMENT_CLASS(SynMbrListUILayer, NDUILayer)

void SynMbrListUILayer::processSocialData(SocialData& data)
{
	bool find = false;
	
	for_vec(m_vElement, VEC_SOCIAL_ELEMENT_IT)
	{
		if ((*it)->m_id == data.iId)
		{
			find = true;
			break;
		}
	}
	
	if (!find) return;
	
	SocialData& tutor = s_mapSocialData[data.iId];
	tutor = data;
	
	if (m_infoMbr) {
		m_infoMbr->refreshSocialData();
	}
}

SynMbrListUILayer::SynMbrListUILayer()
{
	s_instance = this;
	m_bFirstQuery = true;
	m_tlMain = NULL;
	this->m_lbPages = NULL;
	m_btnPrePage = NULL;
	m_btnNextPage = NULL;
	m_nCurPage = 0;
	m_nMaxPage = 0;
}

void SynMbrListUILayer::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SynMbrListUILayer::Query()
{
	if (m_bFirstQuery) {
		sendQueryMembers(0);
		m_bFirstQuery = false;
	}
}

void SynMbrListUILayer::processMbrList(NDTransData& data)
{
	CloseProgressBar;
	// 清除相关数据
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	this->releaseElement();
	
	int usMbrCount = data.ReadShort();
	m_nCurPage = data.ReadByte();
	int btCurPageMbrCount = data.ReadByte();
	
	int t_totalPage = 1;
	if (usMbrCount % ONE_PAGE_COUNT == 0) {
		t_totalPage = usMbrCount / ONE_PAGE_COUNT;
	} else {
		t_totalPage = usMbrCount / ONE_PAGE_COUNT + 1;
	}
	m_nMaxPage = max(1, t_totalPage);
	
	stringstream ss;
	ss << (m_nCurPage+1) << " / " << t_totalPage;
	m_lbPages->SetText(ss.str().c_str());
	//this->m_btnPage->SetPages(btCurPage + 1, t_totalPage);
	
	SocialElement* focusSe = NULL;
	
	for (int i = 0; i < btCurPageMbrCount; i++) {
		Byte btOnlineFlag = data.ReadByte();
		Byte btRank = data.ReadByte();
		int memberId = data.ReadInt();
		string strMbrName = data.ReadUnicodeString();
		
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = memberId;
		se->m_text1 = strMbrName;
		se->m_text2 = getRankStr(btRank);
		se->m_state = ELEMENT_STATE(btOnlineFlag);
		
		NDSocialCell *cell = new NDSocialCell;
		cell->Initialization();
		sec->AddCell(cell);
		cell->ChangeSocialElement(se);
		
		if (i == 0) {
			focusSe = se;
		}
	}
	
	sec->SetFocusOnCell(0);
	m_infoMbr->Change(focusSe);
	this->m_tlMain->ReflashData();
}

SynMbrListUILayer::~SynMbrListUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
	this->releaseElement();
}

void SynMbrListUILayer::OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (!cell->IsKindOfClass(RUNTIME_CLASS(NDSocialCell))) return;
	
	NDSocialCell *sc = (NDSocialCell*)cell;
	
	if (m_infoMbr)
	{
		m_infoMbr->Change(sc->GetSocialElement());
	}
}

void SynMbrListUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* imgRight = new NDUIImage;
	imgRight->Initialization();
	imgRight->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png")), true);
	imgRight->SetFrameRect(CGRectMake(203, 3, 252, 274));
	this->AddChild(imgRight);
	
	m_infoMbr = new SynMbrInfo;
	m_infoMbr->Initialization(CGPointMake(0, 9));
	this->AddChild(m_infoMbr);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetFrameRect(CGRectMake(10+200, 17, 242, 216));
	m_tlMain->VisibleScrollBar(false);
	m_tlMain->SetCellsInterval(2);
	m_tlMain->SetCellsRightDistance(0);
	m_tlMain->SetCellsLeftDistance(0);
	m_tlMain->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlMain->SetDataSource(dataSource);
	this->AddChild(m_tlMain);
	
	m_lbPages = new NDUILabel;
	m_lbPages->Initialization();
	m_lbPages->SetFrameRect(CGRectMake(210, 240, 242, 30));
	m_lbPages->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbPages->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(m_lbPages);
	
	m_btnPrePage = new NDUIButton;
	m_btnPrePage->Initialization();
	m_btnPrePage->SetFrameRect(CGRectMake(220, 236, 36, 36));
	m_btnPrePage->SetDelegate(this);
	m_btnPrePage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnPrePage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnPrePage);
	
	m_btnNextPage = new NDUIButton;
	m_btnNextPage->Initialization();
	m_btnNextPage->SetFrameRect(CGRectMake(400, 236, 36, 36));
	m_btnNextPage->SetDelegate(this);
	m_btnNextPage->SetImage(pool.AddPicture(NDPath::GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnNextPage->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnNextPage);
}

void SynMbrListUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnPrePage) {
		if (m_nCurPage > 0) {
			sendQueryMembers(this->m_nCurPage - 1);
		}
	} else if (button == m_btnNextPage) {
		if (m_nCurPage < m_nMaxPage - 1) {
			sendQueryMembers(this->m_nCurPage + 1);
		}
	}
}


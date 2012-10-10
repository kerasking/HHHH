/*
 *  SyndicateMbrList.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateMbrList.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include "ChatInput.h"
#include "NDMapMgr.h"

enum MBR_OPT_LIST {
	JUMP_PAGE,
	TALK_TO,
	ASSIGN_JOB,
	VIEW_INFO,
	VIEW_EQUIP,
	VIEW_PET,
	ADD_FIREND,
	SHANG_RANG,
	KICK_OUT,
};

enum {
	TAG_TABEL_MBR_OPT,
	TAG_TABEL_ASSIGN_JOB,
	
	TAG_DLG_SHANG_RANG,
	TAG_DLG_KICK_OUT,
};

const char* MBR_OPT_STR[9] = {"跳转页数","私聊","任职","查看信息","查看装备","查看宠物","添加好友","禅让","开除成员"};

IMPLEMENT_CLASS(SyndicateMbrList, NDUIMenuLayer)

SyndicateMbrList* SyndicateMbrList::s_instance = NULL;

void SyndicateMbrList::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateMbrList *list = new SyndicateMbrList;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void SyndicateMbrList::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SyndicateMbrList::refreshMainList(NDTransData& data)
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	this->releaseElement();
	
	int usMbrCount = data.ReadShort();
	int btCurPage = data.ReadByte();
	int btCurPageMbrCount = data.ReadByte();
	
	int t_totalPage = 1;
	if (usMbrCount % ONE_PAGE_COUNT == 0) {
		t_totalPage = usMbrCount / ONE_PAGE_COUNT;
	} else {
		t_totalPage = usMbrCount / ONE_PAGE_COUNT + 1;
	}
	t_totalPage = max(1, t_totalPage);
	
	this->m_btnPage->SetPages(btCurPage + 1, t_totalPage);
	
	bool bChangeClr = false;
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
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), se);
		
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		sec->AddCell(st);
	}
	
	this->m_tlMain->ReflashData();
}

SyndicateMbrList::SyndicateMbrList()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_btnPage = NULL;
}

SyndicateMbrList::~SyndicateMbrList()
{
	s_instance = NULL;
	this->releaseElement();
}

void SyndicateMbrList::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				this->RemoveFromParent(true);
			}
		}
	}
}

void SyndicateMbrList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDPlayer& role = NDPlayer::defaultHero();
		if (role.m_id == m_curSelEle->m_id) {
			return;
		}
		
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		int nHeight = 0;
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = NULL;
		
		int t_synRank = role.getSynRank();
		
		for (int i = 0; i < 9; i++) {
			if(i == ASSIGN_JOB || i == SHANG_RANG){//任职 ||禅让，只有军团长有该权限
				if(t_synRank < SYNRANK_LEADER) {
					continue;
				}
			}else if(i == KICK_OUT){//开除成员，副团及以上有权限
				if(t_synRank < SYNRANK_VICE_LEADER) {
					continue;
				}
			} else if (i == TALK_TO || (i >= VIEW_INFO && i <= ADD_FIREND)) { // 在线才允许操作
				if (m_curSelEle->m_state == ES_OFFLINE) {
					continue;
				}
			}
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTag(i);
			btn->SetTitle(MBR_OPT_STR[i]);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 29;
		}
		opt->SetTag(TAG_TABEL_MBR_OPT);
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		int tableTag = table->GetTag();
		switch (tableTag) {
			case TAG_TABEL_MBR_OPT:
			{
				int btnTag = cell->GetTag();
				this->m_optLayer->RemoveFromParent(true);
				this->m_optLayer = NULL;
				
				switch (btnTag) {
					case JUMP_PAGE:
					{
						NDUICustomView *view = new NDUICustomView;
						view->Initialization();
						view->SetDelegate(this);
						std::vector<int> vec_id; vec_id.push_back(1);
						string strTitle = "请输入页数";
						std::vector<std::string> vec_str; vec_str.push_back(strTitle);
						view->SetEdit(1, vec_id, vec_str);
						view->Show();
						this->AddChild(view);
						break;
					}
					case TALK_TO:
					{
						PrivateChatInput::DefaultInput()->SetLinkMan(m_curSelEle->m_text1.c_str());
						PrivateChatInput::DefaultInput()->Show();
						break;
					}
					case ASSIGN_JOB:
					{
						string t_str[5] = {"副团","元老","堂主","门主","团员"};
						Byte t_synRank[5] = {11,10,5,1,0};
						
						NDUITableLayer* opt = new NDUITableLayer;
						opt->Initialization();
						opt->VisibleSectionTitles(false);
						opt->SetDelegate(this);
						
						CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
						int nHeight = 0;
						
						NDDataSource* ds = new NDDataSource;
						NDSection* sec = new NDSection;
						ds->AddSection(sec);
						opt->SetDataSource(ds);
						
						NDUIButton* btn = NULL;
						
						for (int i = 0; i < 5; i++) {
							btn = new NDUIButton;
							btn->Initialization();
							btn->SetTag(t_synRank[i]);
							btn->SetTitle(t_str[i].c_str());
							btn->SetFocusColor(ccc4(253, 253, 253, 255));
							sec->AddCell(btn);
							nHeight += 30;
						}
						opt->SetTag(TAG_TABEL_ASSIGN_JOB);
						opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
						sec->SetFocusOnCell(0);
						
						this->m_optLayer = new NDOptLayer;
						this->m_optLayer->Initialization(opt);
						this->AddChild(m_optLayer);
						break;
					}
					case VIEW_INFO:
					{
						sendQueryPlayer(m_curSelEle->m_id, _SEE_USER_INFO);
						break;
					}
					case VIEW_EQUIP:
					{
						sendQueryPlayer(m_curSelEle->m_id, SEE_EQUIP_INFO);
						break;
					}
					case VIEW_PET:
					{
						sendQueryPlayer(m_curSelEle->m_id, SEE_PET_INFO);
						break;
					}
					case ADD_FIREND:
					{
						sendAddFriend(m_curSelEle->m_text1);
						break;
					}
					case SHANG_RANG:
					{
						NDUIDialog* dlg = new NDUIDialog;
						dlg->Initialization();
						dlg->SetTag(TAG_DLG_SHANG_RANG);
						dlg->SetDelegate(this);
						string content = "您确定要禅让军团长职位给玩家 ";
						content += m_curSelEle->m_text1;
						content += " 吗?";
						dlg->Show("温馨提示", content.c_str(), "取消", "确定", NULL);
						break;
					}
					case KICK_OUT:
					{
						NDUIDialog* dlg = new NDUIDialog;
						dlg->Initialization();
						dlg->SetTag(TAG_DLG_KICK_OUT);
						dlg->SetDelegate(this);
						string content = "您确定要将玩家 ";
						content += m_curSelEle->m_text1;
						content += " 踢出军团?";
						dlg->Show("温馨提示", content.c_str(), "取消", "确定", NULL);
						break;
					}
					default:
						break;
				}
			}
				break;
			case TAG_TABEL_ASSIGN_JOB:
			{
				sendAssignMbrRank(m_curSelEle->m_id, cell->GetTag(), m_btnPage->GetCurPage() - 1);
				this->m_optLayer->RemoveFromParent(true);
				this->m_optLayer = NULL;
			}
				break;
			default:
				break;
		}
	}
}

void SyndicateMbrList::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	int tagDlg = dialog->GetTag();
	dialog->Close();
	switch (tagDlg) {
		case TAG_DLG_SHANG_RANG:
		{
			sendLeaveDemise(m_curSelEle->m_id, m_btnPage->GetCurPage() - 1);
		}
			break;
		case TAG_DLG_KICK_OUT:
		{
			sendKickOut(m_curSelEle->m_id, m_btnPage->GetCurPage() - 1);
		}
			break;
		default:
			break;
	}
}

bool SyndicateMbrList::OnCustomViewConfirm(NDUICustomView* customView)
{
	VerifyViewNum(*customView);
	string str = customView->GetEditText(0);
	if (str.empty()) {
		customView->ShowAlert("请输入页数");
		return false;
	}
	int nPage = atoi(str.c_str());
	
	if (nPage > 0 && nPage <= this->m_btnPage->GetTotalPage()) {
		sendQueryMembers(nPage - 1);
	}
	return true;
}

void SyndicateMbrList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText("成员列表");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	NDUILayer* columnTitle = new NDUILayer;
	columnTitle->Initialization();
	columnTitle->SetBackgroundColor(ccc4(115, 117, 115, 255));
	columnTitle->SetFrameRect(CGRectMake(7, 32, 466, 17));
	this->AddChild(columnTitle);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText("成员名称");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText("职位");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentRight);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 50, 476, 200));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
	
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(160.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	this->AddChild(m_btnPage);
}

void SyndicateMbrList::OnPageChange(int nCurPage, int nTotalPage)
{
	sendQueryMembers(nCurPage - 1);
}

/*
 *  GoodFriend.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GoodFriendUILayer.h"
#include "NDDirector.h"
#include "NDMapMgr.h"
#include <sstream>
#include "GameScene.h"
#include "SocialTextLayer.h"
#include "NDUISynLayer.h"
#include "EmailSendScene.h"
#include "ChatInput.h"

template<typename _Iterator, typename _Function>
_Function
for_each_map(_Iterator __first, _Iterator __last, _Function __f)
{
	for ( ; __first != __last; ++__first)
		__f(__first);
	return __f;
}

typedef MAP_FRIEND_ELEMENT_IT friend_sort_ele;

typedef std::list<friend_sort_ele> friend_sort_container;

typedef friend_sort_container::iterator friend_sort_container_it;

typedef friend_sort_container* friend_sort_container_ptr;

struct FriendSort : public std::binary_function< friend_sort_container_ptr, friend_sort_ele, bool>
{
	bool operator () (friend_sort_container_ptr container_ptr, friend_sort_ele ele) const
	{
		friend_sort_container& container = *container_ptr;
		
		if (container.empty()) 
		{
			container.push_back(ele);
			
			return true;
		}
		
		if (ele->second.m_state == ES_OFFLINE) 
		{
			container.push_back(ele);
			
			return true;
		}
		else
		{
			for_vec(container, friend_sort_container_it)
			{
				friend_sort_ele element = *it;
				
				if (element->second.m_state == ES_OFFLINE) 
				{
					container.insert(it, ele);
					
					return true;
				}
			}
		}
		
		container.push_back(ele);
		
		return true;
	}
};

#define TAG_GOOD_FRIEND_TITLE 1

const int PER_PAGE_COUNT = 10;

const string OPERATOR_NAME[6] = { 
NDCommonCString("PrivateChat"), NDCommonCString("ViewZiLiao"), NDCommonCString("ViewEquip"), NDCommonCString("DelFriend"), NDCommonCString("AddFriend"), NDCommonCString("SendMail"),
};

GoodFriendUILayer* GoodFriendUILayer::s_instance = NULL;

IMPLEMENT_CLASS(GoodFriendUILayer, NDUIMenuLayer)

void GoodFriendUILayer::refreshScroll()
{
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

GoodFriendUILayer::GoodFriendUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	
	m_iType = GoodFriendNormal;
	
	m_btnPage = NULL;
	
	m_nCurPage = 0;
}

GoodFriendUILayer::~GoodFriendUILayer()
{
	s_instance = NULL;
}

void GoodFriendUILayer::OnPageChange(int nCurPage, int nTotalPage)
{
	this->m_nCurPage = nCurPage - 1;
	this->refreshMainList();
}

void GoodFriendUILayer::refreshMainList()
{
	if (!this->m_tlMain)
	{
		return;
	}
	
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
	
	// 更新页数
	int nTotalPage = (friendList.size() + PER_PAGE_COUNT - 1) / PER_PAGE_COUNT;
	if (nTotalPage == 0) {
		nTotalPage = 1;
	}
	
	if (m_nCurPage + 1 > nTotalPage) {
		m_nCurPage--;
	}
	
	m_btnPage->SetPages(m_nCurPage + 1, nTotalPage);
	
	int nStart = PER_PAGE_COUNT * this->m_nCurPage;
	int nEnd = nStart + PER_PAGE_COUNT;
	if ((size_t)nEnd >= friendList.size()) {
		nEnd = friendList.size();
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	bool bChangeClr = false;
	
	int iIndex = 0;
	
	friend_sort_container tmpFriendList; 
	
	for_each_map(friendList.begin(), friendList.end(), std::bind1st(FriendSort(), &tmpFriendList));
	
	for(friend_sort_container_it it = tmpFriendList.begin(); it != tmpFriendList.end(); it++, iIndex++)
	{
		if (!(iIndex >= nStart && iIndex < nEnd)) continue;
		
		FriendElement& fe = (*it)->second;
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(20.0f, 0.0f, 430.0f, 27.0f), &fe);
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		bChangeClr = !bChangeClr;
		sec->AddCell(st);
	}
	
	m_tlMain->SetCellsLeftDistance(10);
	m_tlMain->SetCellsRightDistance(10);
	this->m_tlMain->ReflashData();
	if (friendList.size() > 0) 
	{
		sec->SetFocusOnCell(0);
	}	
	
	NDUILabel* lbTitle = (NDUILabel*)this->GetChild(TAG_GOOD_FRIEND_TITLE);
	if (lbTitle) {
		stringstream ss;
		ss << NDCommonCString("FriendList") << " " << NDMapMgrObj.GetFriendOnlineNum() << "/" << NDMapMgrObj.GetFriendNum();
		lbTitle->SetText(ss.str().c_str());
	}
}

void GoodFriendUILayer::Initialization(int iType /*= GoodFriendNormal*/)
{
	NDAsssert(iType == GoodFriendNormal || iType == GoodFriendEmail);
	
	m_iType = iType;
	
	NDUIMenuLayer::Initialization();
	
	NDMapMgr& mgr = NDMapMgrObj;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUIRecttangle* bkg = new NDUIRecttangle();
	bkg->Initialization();
	bkg->SetColor(ccc4(253, 253, 253, 255));
	bkg->SetFrameRect(CGRectMake(0, GetTitleHeight(), 480, GetTextHeight()));
	this->AddChild(bkg);
	
	stringstream ss;
	ss << NDCommonCString("FriendList") << " " << mgr.GetFriendOnlineNum() << "/" << mgr.GetFriendNum();
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(ss.str().c_str());
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	title->SetTag(TAG_GOOD_FRIEND_TITLE);
	this->AddChild(title);
	
	MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(160.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	int nTotalPage = (friendList.size() + PER_PAGE_COUNT - 1) / PER_PAGE_COUNT;
	if (nTotalPage == 0) {
		nTotalPage = 1;
	}
	m_btnPage->SetPages(1, nTotalPage);
	this->AddChild(m_btnPage);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 30, 476, 220));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
	this->refreshMainList();
	
	NDUILabel* lbAddFriend = new NDUILabel;
	lbAddFriend->Initialization();
	lbAddFriend->SetText(NDCommonCString("AddFriend"));
	lbAddFriend->SetTextAlignment(LabelTextAlignmentCenter);
	lbAddFriend->SetFrameRect(CGRectMake(0.0f, 282.0f, 480.0f, 35.0f));
	this->AddChild(lbAddFriend);
	
	if (m_iType == GoodFriendEmail) 
	{
		lbAddFriend->SetVisible(false);
	}
}

bool GoodFriendUILayer::TouchEnd(NDTouch* touch)
{
	CGSize size = NDDirector::DefaultDirector()->GetWinSize();
	if (IsPointInside(touch->GetLocation(), CGRectMake(size.width / 2 - 30, size.height - 40, 60, 40))) {
		if (this->m_optLayer) {
			return true;
		}
		
		if (m_iType == GoodFriendNormal) 
		{
			this->showCustomeView();
		}
	} else {
		NDUILayer::TouchEnd(touch);
	}

	return true;
}

void GoodFriendUILayer::showCustomeView()
{
	NDUICustomView *view = new NDUICustomView;
	view->Initialization();
	view->SetDelegate(this);
	std::vector<int> vec_id; vec_id.push_back(1);
	std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputFriendName"));
	view->SetEdit(1, vec_id, vec_str);
	view->Show();
	this->AddChild(view);
}

bool GoodFriendUILayer::OnCustomViewConfirm(NDUICustomView* customView)
{
	string name = customView->GetEditText(0);
	sendAddFriend(name);
	return true;
}

void sendDeleteFriend(FriendElement* fe) {
	if (!fe) {
		return;
	}
	
	NDUISynLayer::Show();
	NDTransData bao(_MSG_GOODFRIEND);
	bao << Byte(_FRIEND_BREAK)
	<< Byte(1)
	<< fe->m_id;
	SEND_DATA(bao);
}

void GoodFriendUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		this->m_curSelEle = (FriendElement*)((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		if (m_iType == GoodFriendNormal) 
		{
			opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 180) / 2, 94, 180));
		}
		else if (m_iType == GoodFriendEmail) 
		{
			opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 30) / 2, 94, 30));
		}

		
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		switch (m_iType) 
		{
			case GoodFriendNormal:
			{
				for (int i = 0; i < 6; i++) {
					NDUIButton* btn = new NDUIButton;
					btn->Initialization();
					btn->SetTitle(OPERATOR_NAME[i].c_str());
					btn->SetFocusColor(ccc4(253, 253, 253, 255));
					sec->AddCell(btn);
				}
			}
				break;
			case GoodFriendEmail:
			{
				NDUIButton* btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle(NDCommonCString("SetMailRecver"));
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				sec->AddCell(btn);
			}
				break;
			default:
				break;
		}
		
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		if (m_iType == GoodFriendNormal) 
		{
			switch (cellIndex) {
				case 0: // "私聊",
					PrivateChatInput::DefaultInput()->SetLinkMan(this->m_curSelEle->m_text1.c_str());
					PrivateChatInput::DefaultInput()->Show();
					break;
				case 1: // "查看资料",
					sendQueryPlayer(this->m_curSelEle->m_id, _SEE_USER_INFO);
					break;
				case 2: // "查看装备",
					sendQueryPlayer(this->m_curSelEle->m_id, SEE_EQUIP_INFO);
					break;
				case 3: // "删除好友",
					sendDeleteFriend(this->m_curSelEle);
					break;
				case 4: // "添加好友",
					this->showCustomeView();
					break;
				case 5: // "发送邮件"
					NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene());
					break;
				default:
					break;
			}
		}
		else if (m_iType == GoodFriendEmail)
		{
			//　设为收件人
			if (m_curSelEle) 
			{
				EmailSendScene::UpdateReciever(m_curSelEle->m_text1);
				this->RemoveFromParent(true); 
				return;
			}
		}
		
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void GoodFriendUILayer::OnButtonClick(NDUIButton* button)
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
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(EmailSendScene))) 
			{
				this->RemoveFromParent(true);
			}
		}

	}
}
/*
 *  NewFriendList.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewFriendList.h"

#include "NDDirector.h"
#include "NDMapMgr.h"
#include <sstream>
#include "GameScene.h"
#include "SocialTextLayer.h"
#include "NDUISynLayer.h"
#include "EmailSendScene.h"
#include "ChatInput.h"
#include "NDDirector.h"
#include "NewMailSend.h"
#include "SocialScene.h"

enum  
{
	eFriendOpBegin = 4561,
	eFriendOpChat,
	eFriendOpMail,
	eFriendOpAddFriend,
	eFriendOpDelFriend,
	eFriendOpXunLu,
	eFriendOpEnd,
};

IMPLEMENT_CLASS(FriendInfo, NDUILayer)

FriendInfo::FriendInfo()
{
	m_figure = NULL;
	
	m_info = NULL;
	
	m_socialEle = NULL;
}

FriendInfo::~FriendInfo()
{
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		NDUIButton*& btn = *it;
		
		if (btn && btn->GetParent() == NULL) 
		{
			delete btn;
		}
	}
}

void FriendInfo::Initialization(CGPoint pos)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
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
}

void FriendInfo::showCustomeView()
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

bool FriendInfo::OnCustomViewConfirm(NDUICustomView* customView)
{
	string name = customView->GetEditText(0);
	sendAddFriend(name);
	return true;
}

void FriendInfo::sendDeleteFriend() {
	if (!m_socialEle) {
		return;
	}
	
	NDUISynLayer::Show();
	NDTransData bao(_MSG_GOODFRIEND);
	bao << Byte(_FRIEND_BREAK)
	<< Byte(1)
	<< m_socialEle->m_id;
	SEND_DATA(bao);
}

void FriendInfo::OnButtonClick(NDUIButton* button)
{
	int op = button->GetTag();
	
	if (!m_socialEle && op != eFriendOpAddFriend) return;
	
	switch (op) 
	{
		case eFriendOpDelFriend:
		{
			sendDeleteFriend();
		}
			break;
		case eFriendOpAddFriend:
		{
			this->showCustomeView();
		}
			break;
		case eFriendOpMail:
		{
			NDDirector::DefaultDirector()->PushScene(NewMailSendScene::Scene(m_socialEle->m_text1.c_str()));
		}
			break;
		case eFriendOpChat:
		{
			PrivateChatInput::DefaultInput()->SetLinkMan(m_socialEle->m_text1.c_str());
			PrivateChatInput::DefaultInput()->Show();
		}
			break;
		case eFriendOpXunLu:
		{
			NDUISynLayer::Show();
			NDTransData bao(_MSG_SEE);
			bao << Byte(6) << this->m_socialEle->m_id;
			SEND_DATA(bao);
		}
			break;
		default:
			break;
	}
	
}

void FriendInfo::ChangeFriend(SocialElement* se)
{
	m_socialEle = se;
	
	if (m_figure)
		m_figure->ChangeFigure(m_socialEle);
	
	// 获取信息
	if (m_socialEle 
		&& !SocialScene::hasSocialData(m_socialEle->m_id)
		&& m_socialEle->m_state == ES_ONLINE)
	{
		SendSocialRequest(m_socialEle->m_id);

		if (m_figure)
			m_figure->ShowLevel(false, 1);
	}
	else
	{
		refreshSocialData();
	}
	
	// 更新操作
	std::vector<std::string> vec_str;
	std::vector<int> vec_op;
	
	vec_str.push_back(NDCommonCString("add"));
	vec_op.push_back(eFriendOpAddFriend);
	
	if (m_socialEle) 
	{
		if (this->m_socialEle->m_state == ES_ONLINE) 
		{
			vec_str.push_back(NDCommonCString("XunLu"));
			vec_op.push_back(eFriendOpXunLu);
			
			vec_str.push_back(NDCommonCString("PrivateChat"));
			vec_op.push_back(eFriendOpChat);
		}
		
		vec_str.push_back(NDCommonCString("mail"));
		vec_op.push_back(eFriendOpMail);
		
		vec_str.push_back(NDCommonCString("del"));
		vec_op.push_back(eFriendOpDelFriend);
	}
	
	size_t sizeOperate = vec_op.size();
	
	if (sizeOperate != vec_str.size()) 
	{
		return;
	}
	
	size_t sizeBtns = m_vOpBtn.size();
	
	size_t max = sizeBtns;
	
	if (sizeOperate > sizeBtns) 
	{
		m_vOpBtn.resize(sizeOperate, NULL);
		
		max = sizeOperate;
	}
	
	int startx = 7, starty = 208, btnw = 43, btnh = 24, interval = 5, col = 4;
	
	for (size_t i = 0; i < max; i++) 
	{
		NDUIButton*& btn = m_vOpBtn[i];
		if (!btn) 
		{
			NDPicturePool& pool = *(NDPicturePool::DefaultPool());
			btn = new NDUIButton;
			
			btn->Initialization();
			
			btn->SetFontColor(ccc4(255, 255, 255, 255));
			
			btn->SetFontSize(12);
			
			btn->CloseFrame();
			
			btn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), btnw, 0),
									  pool.AddPicture(GetImgPathNew("bag_btn_click.png"), btnw, 0),
									  false, CGRectZero, true);
			btn->SetDelegate(this);							 
			
			this->AddChild(btn);
		}
		
		btn->SetFrameRect(CGRectMake(startx+(btnw+interval)*(i%col),
									 starty+(btnh+interval)*(i/col), 
									 btnw, 
									 btnh));
		
		if (i >= sizeOperate) 
		{
			btn->SetTitle("");
			
			btn->SetTag(eFriendOpEnd);
			
			if (btn->GetParent() != NULL) 
			{
				btn->RemoveFromParent(false);
			}
			
			continue;
		}
		
		if (btn->GetParent() == NULL) 
		{
			this->AddChild(btn);
		}
		
		btn->SetTag(vec_op[i]);
		
		btn->SetTitle(vec_str[i].c_str());
	}
}

void FriendInfo::refreshSocialData()
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


//const string OPERATOR_NAME[6] = { "私聊", "查看资料", "查看装备", "删除好友", "添加好友", "发送邮件" };

NewGoodFriendUILayer* NewGoodFriendUILayer::s_instance = NULL;
map_social_data NewGoodFriendUILayer::s_mapFriendData;

IMPLEMENT_CLASS(NewGoodFriendUILayer, NDUILayer)

void NewGoodFriendUILayer::refreshScroll()
{
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

NewGoodFriendUILayer::NewGoodFriendUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	
	m_idDestMap = 0;
	m_destX = 0;
	m_destY = 0;

	m_infoEquip = NULL;
}

NewGoodFriendUILayer::~NewGoodFriendUILayer()
{
	s_instance = NULL;
}

void NewGoodFriendUILayer::refreshMainList()
{
	if (!m_tlMain
		|| !m_tlMain->GetDataSource()
		|| m_tlMain->GetDataSource()->Count() != 1)
		return;
		
	NDSection* section = m_tlMain->GetDataSource()->Section(0);
	
	MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
	
	friend_sort_container tmpFriendList; 
	
	for_each_map(friendList.begin(), friendList.end(), std::bind1st(FriendSort(), &tmpFriendList));
	
	std::vector<friend_sort_ele> vFriend;
	
	for(friend_sort_container_it it = tmpFriendList.begin(); it != tmpFriendList.end(); it++)
	{
		vFriend.push_back(*it);
	}
	
	size_t maxCount = section->Count() > vFriend.size() ? section->Count() : vFriend.size();
	
	SocialElement *firstse = NULL;
	
	unsigned int infoCount = 0;
	
	for (size_t i = 0; i < maxCount; i++) 
	{
		SocialElement *se = i < vFriend.size() ? &(vFriend[i]->second) : NULL;
		
		if (i == 0) firstse = se;
		
		if (se != NULL)
		{
			NDSocialCell *cell = NULL;
			if (infoCount < section->Count())
				cell = (NDSocialCell *)section->Cell(infoCount);
			else
			{
				cell = new NDSocialCell;
				cell->Initialization();
				section->AddCell(cell);
			}
			cell->ChangeSocialElement(se);
			
			infoCount++;
		}
		else
		{
			if (infoCount < section->Count() && section->Count() > 0)
			{
				section->RemoveCell(section->Count()-1);
			}
		}
	}
	
	if (!m_infoFriend)
	{
		m_tlMain->ReflashData();
		
		return;
	}
	
	SocialElement *curSe = m_infoFriend->GetFriendEle();

	if (!curSe)
		m_infoFriend->ChangeFriend(firstse);
	else
	{
		MAP_FRIEND_ELEMENT_IT it = friendList.find(curSe->m_id);
		
		if (it == friendList.end())
			m_infoFriend->ChangeFriend(firstse);
		else
		{
			m_infoFriend->ChangeFriend(&(it->second));
		}
	}
	
	curSe = m_infoFriend->GetFriendEle();
	
	for(size_t i = 0; i < section->Count(); i++)
	{
		NDSocialCell *cell = (NDSocialCell *)section->Cell(i);
		
		if (cell->GetSocialElement() == curSe) 
		{
			section->SetFocusOnCell(i);
			break;
		}
	}
	
	m_tlMain->ReflashData();
}

void NewGoodFriendUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table != m_tlMain || !cell->IsKindOfClass(RUNTIME_CLASS(NDSocialCell))) return;
	
	NDSocialCell *sc = (NDSocialCell*)cell;
	
	if (m_infoFriend)
	{
		m_infoFriend->ChangeFriend(sc->GetSocialElement());
	}
	
	return;
}

void NewGoodFriendUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_infoFriend = new FriendInfo;
	
	m_infoFriend->Initialization(CGPointMake(0, 48));
	
	this->AddChild(m_infoFriend);
	
	//m_tlMain = new NDUITableLayer;
	
	//m_tlMain->Initialization();
	
	int width = 252; //, height = 274;
	do 
	{
		m_tlMain = new NDUITableLayer;
		m_tlMain->Initialization();
		m_tlMain->SetSelectEvent(false);
		m_tlMain->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tlMain->VisibleSectionTitles(false);
		m_tlMain->SetFrameRect(CGRectMake(6+200, 17+37, width-10, 226));
		m_tlMain->VisibleScrollBar(false);
		m_tlMain->SetCellsInterval(2);
		m_tlMain->SetCellsRightDistance(0);
		m_tlMain->SetCellsLeftDistance(0);
		m_tlMain->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		
		MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
		MAP_FRIEND_ELEMENT_IT it = friendList.begin();
		for(; it != friendList.end(); it++)
		{
			NDSocialCell *cell = new NDSocialCell;
			cell->Initialization();
			cell->ChangeSocialElement(&(it->second));
			section->AddCell(cell);
		}
		
		section->SetFocusOnCell(0);
		
		dataSource->AddSection(section);
		m_tlMain->SetDataSource(dataSource);
		this->AddChild(m_tlMain);
		
		SocialElement* ele = NULL;
		if (!friendList.empty())
			ele = &((friendList.begin())->second);
		
		m_infoFriend->ChangeFriend(ele);
	} while (0);
}

void NewGoodFriendUILayer::processSocialData(/*SocialData& data*/)
{
	/*
	bool find = false;
	
	MAP_FRIEND_ELEMENT& friendList = NDMapMgrObj.GetFriendMap();
	MAP_FRIEND_ELEMENT_IT it = friendList.find(data.iId);
	if (it != friendList.end())
		find = true;
	
	if (!find) return;
	
	SocialData& tutor = s_mapFriendData[data.iId];
	tutor = data;
	*/
	if (s_instance) 
		s_instance->refreshSocialData();
}

void NewGoodFriendUILayer::processSeeEquip(int targetId, int lookface)
{
	if (s_instance) 
		s_instance->ShowEquipInfo(true, lookface, targetId);
}

void NewGoodFriendUILayer::refreshSocialData()
{
	if (m_infoFriend)
		m_infoFriend->refreshSocialData();
}

void NewGoodFriendUILayer::ShowEquipInfo(bool show, int lookface/*=0*/, int targetId/*=0*/)
{
	if (!show) 
	{
		SAFE_DELETE_NODE(m_infoEquip);
		
		return;
	}
	
	if (!this->IsVisibled()) return;
	
	bool find = false;
	
	if (m_infoFriend && m_infoFriend->GetFriendEle() && m_infoFriend->GetFriendEle()->m_id == targetId)
	{
		find = true;
	}
	
	if (!find) return;
	
	SAFE_DELETE_NODE(m_infoEquip);
	
	m_infoEquip = new SocialPlayerEquip;
	
	m_infoEquip->Initialization(lookface);
	
	m_infoEquip->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	this->AddChild(m_infoEquip);
	
	if (m_tlMain)
		m_tlMain->SetVisible(false);
}

void NewGoodFriendUILayer::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);

	ShowEquipInfo(false);
}

void NewGoodFriendUILayer::processUserPos(NDTransData& data)
{
	if (!s_instance) {
		return;
	}
	
	data.ReadInt();
	s_instance->m_idDestMap = data.ReadInt();
	s_instance->m_destX = data.ReadShort();
	s_instance->m_destY = data.ReadShort();
	
	NDUISynLayer::Close();
	
	NDPlayer& role = NDPlayer::defaultHero();
	
	if (role.idCurMap == s_instance->m_idDestMap) {
		int destX = s_instance->m_destX;
		int destY = s_instance->m_destY;
		
		NDDirector::DefaultDirector()->PopScene();
		
		role.Walk(CGPointMake(destX * 16, destY * 16), SpriteSpeedStep4);
	} else { // 不同地图的,飞过去
		NDUIDialog* dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(s_instance);
		dlg->Show(NDCommonCString("XunLu"), NDCommonCString("ConsumeJuanZhouTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}	
}

void NewGoodFriendUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	NDDirector::DefaultDirector()->PopScene();
	NDMapMgrObj.throughMap(this->m_destX, this->m_destY, this->m_idDestMap);
}

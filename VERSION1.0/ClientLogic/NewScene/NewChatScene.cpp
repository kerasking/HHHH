/*
 *  NewChatScene.cpp
 *  DragonDrive
 *
 *  Created by wq on 11-9-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#if 0
#include "NewChatScene.h"
#include "NDUIButton.h"
#include "NDUIImage.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDUILayer.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDUIBaseGraphics.h"
#include "CGPointExtension.h"
#include "NDConstant.h"
#include "ItemMgr.h"
#include "ChatInput.h"
#include "NDUIDialog.h"
#include "NDPlayer.h"
#include "NDDataPersist.h"
#include "GameSettingScene.h"
#include "NDUtility.h"
#include "NDMapMgr.h"
#include "NDString.h"
enum  {
	eBtnClose = 1,
	eBtnFilter,
	eBtnAddFriend,
	eBtnRefresh,
	eBtnSelItem,
	eBtnSelFace,
	
	eChannelAll,
	eChannelSection,
	eChannelTeam,
	eChannelSyndicate,
	eChannelPrivate,
	eChannelSystem,
	
	eSelectChannel,
	eInputTalk,
	eLbTalk,
	eSendTalk,
	
	eLbChannel,
	eTlSelChannel,
};

#define DIALOG_TAG_PLAYER	1
#define DIALOG_TAG_ORTHER	2
#define DIALOG_TAG_SYSTEM	3

#define CHANNEL_ALL NDCommonCString("world")
#define CHANNEL_SYNDICATE NDCommonCString("JunTuan")
#define CHANNEL_SECTION NDCommonCString("section")
#define CHANNEL_TEAM NDCommonCString("team")
#define CHANNEL_PRIVATE NDCommonCString("PrivateChat")

IMPLEMENT_CLASS(NewChatScene, NDScene)

static NewChatScene* _DefaultManager = NULL;

static set<string> s_filter_name;

NewChatScene* NewChatScene::DefaultManager()
{
	if (_DefaultManager == NULL) 
	{
		_DefaultManager = new NewChatScene();
	}
	return _DefaultManager;
}

NewChatScene::NewChatScene() {
	m_btnCurChannel = NULL;
	m_input = NULL;
	
	NDScene::Initialization();
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	m_layerBg = new NDUILayer;
	m_layerBg->Initialization();
	m_layerBg->SetBackgroundImage(pool.AddPicture(GetImgPathNew("chat_bg.png")), true);
	m_layerBg->SetFrameRect(CGRectMake(0, 0, 480, 320));
	this->AddChild(m_layerBg);
	
	NDUILabel* lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFrameRect(CGRectMake(0, 0, 480, 30));
	lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lbTitle->SetFontSize(20);
	lbTitle->SetText(NDCommonCString("ChatContent"));
	lbTitle->SetFontColor(ccc4(255, 233, 154, 255));
	m_layerBg->AddChild(lbTitle);
	
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(435, 0, 45, 45));
	btn->SetImage(pool.AddPicture(GetImgPathNew("dlgfull_close_normal.png")), false, CGRectZero, true);
	btn->SetTag(eBtnClose);
	btn->SetDelegate(this);
	m_layerBg->AddChild(btn);
	
	GLfloat startX = 0;
	GLfloat startY = 50;
	
	NDPicture* pic = pool.AddPicture(GetImgPathNew("chat_btn.png"), true);
	pic->SetReverse(true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 46, 42));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eBtnFilter);
	btn->SetDelegate(this);
	btn->SetTitle(NDCommonCString("PingBi"));
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	btn->EnalbeGray(true);
	m_layerBg->AddChild(btn);
	startY += 42;
	
	pic = pool.AddPicture(GetImgPathNew("chat_btn.png"), true);
	pic->SetReverse(true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 46, 42));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eBtnAddFriend);
	btn->SetDelegate(this);
	btn->SetTitle(NDCommonCString("friend"));
	btn->EnalbeGray(true);
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 42;
	
	pic = pool.AddPicture(GetImgPathNew("chat_btn.png"), true);
	pic->SetReverse(true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 46, 42));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eBtnRefresh);
	btn->SetDelegate(this);
	btn->SetTitle(NDCommonCString("stop"));
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 42;
	
	pic = pool.AddPicture(GetImgPathNew("chat_btn.png"), true);
	pic->SetReverse(true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 46, 42));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eBtnSelItem);
	btn->SetDelegate(this);
	btn->SetTitle(NDCommonCString("item"));
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 42;
	
	pic = pool.AddPicture(GetImgPathNew("chat_btn.png"), true);
	pic->SetReverse(true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 46, 42));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eBtnSelFace);
	btn->SetDelegate(this);
	btn->SetTitle(NDCommonCString("express"));
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 42;
	
	startX = 419;
	startY = 50;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelAll);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("ZhongHe")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelSection);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("QuYu")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelTeam);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("DuiWu")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelSyndicate);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("JunSpaceTuan")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelPrivate);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("PrivateSpaceChat")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	pic = pool.AddPicture(GetImgPathNew("chat_channel_normal.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(startX, startY, 61, 32));
	btn->SetImage(pic, true, CGRectMake(14, 0, 47, 32), true);
	btn->SetTag(eChannelSystem);
	btn->SetDelegate(this);
	btn->SetTitle((std::string("   ") + NDCommonCString("XiTong")).c_str());
	btn->SetFontColor(ccc4(149, 66, 49, 255));
	m_layerBg->AddChild(btn);
	startY += 35;
	
	btn = new NDUIButton;
	btn->Initialization();
	pic = pool.AddPicture(GetImgPathNew("text_back.png"), 359, 25);
	btn->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	pic = pool.AddPicture(GetImgPathNew("text_back_focus.png"), 359, 25); 
	btn->SetFocusImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	btn->SetFrameRect(CGRectMake(104, 273, 276, 32));
	btn->SetDelegate(this);
	btn->SetTag(eInputTalk);
	m_layerBg->AddChild(btn);
	
	NDUILabel* lbTalk = new NDUILabel;
	lbTalk->Initialization();
	lbTalk->SetFrameRect(CGRectMake(111, 280, 276, 32));
	lbTalk->SetTextAlignment(LabelTextAlignmentLeft);
	lbTalk->SetTag(eLbTalk);
	m_layerBg->AddChild(lbTalk);
	
	pic = pool.AddPicture(GetImgPathNew("channel_sel.png"), true);
	btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(17, 273, 96, 32));
	btn->SetImage(pic, false, CGRectZero, true);
	btn->SetTag(eSelectChannel);
	btn->SetDelegate(this);
	m_layerBg->AddChild(btn);
	
	m_eCurTalkChannel = eChannelAll;
	NDUILabel* lbChannel = new NDUILabel;
	lbChannel->Initialization();
	lbChannel->SetFontColor(ccc4(255, 233, 154, 255));
	lbChannel->SetText(CHANNEL_ALL);
	lbChannel->SetTextAlignment(LabelTextAlignmentCenter);
	lbChannel->SetFrameRect(CGRectMake(17, 273, 70, 32));
	lbChannel->SetTag(eLbChannel);
	m_layerBg->AddChild(lbChannel);
	
	btn = new NDUIButton;
	btn->Initialization();
	pic = pool.AddPicture(GetImgPathNew("send_normal.png"), 88, 32);
	btn->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	pic = pool.AddPicture(GetImgPathNew("send_touch_down.png"), 88, 32); 
	btn->SetTouchDownImage(pic, false, CGRectZero, true);
	btn->SetFrameRect(CGRectMake(379, 273, 88, 32));
	btn->SetDelegate(this);
	btn->SetTag(eSendTalk);
	m_layerBg->AddChild(btn);
	
	m_tbAll = new ChatTable();
	m_tbAll->Initialization();
	m_tbAll->SetDelegate(this);
	m_tbAll->VisibleSectionTitles(false);
	m_tbAll->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbAll->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbAll->SetMaxRecordCount(120);
	
	m_tbSection = new ChatTable();
	m_tbSection->Initialization();
	m_tbSection->SetDelegate(this);
	m_tbSection->VisibleSectionTitles(false);
	m_tbSection->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSection->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbSection->SetMaxRecordCount(60);
	
	m_tbQueue = new ChatTable();
	m_tbQueue->Initialization();
	m_tbQueue->SetDelegate(this);
	m_tbQueue->VisibleSectionTitles(false);
	m_tbQueue->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbQueue->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbQueue->SetMaxRecordCount(60);
	
	m_tbArmy = new ChatTable();
	m_tbArmy->Initialization();
	m_tbArmy->SetDelegate(this);
	m_tbArmy->VisibleSectionTitles(false);
	m_tbArmy->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbArmy->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbArmy->SetMaxRecordCount(60);
	
	m_tbSecret = new ChatTable();
	m_tbSecret->Initialization();
	m_tbSecret->SetDelegate(this);
	m_tbSecret->VisibleSectionTitles(false);
	m_tbSecret->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSecret->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbSecret->SetMaxRecordCount(60);
	
	m_tbSystem = new ChatTable();
	m_tbSystem->Initialization();
	m_tbSystem->SetDelegate(this);
	m_tbSystem->VisibleSectionTitles(false);
	m_tbSystem->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSystem->SetFrameRect(CGRectMake(50, 50, 368, 211));
	m_tbSystem->SetMaxRecordCount(60);
	
	this->ActiveChannel((NDUIButton*)m_layerBg->GetChild(eChannelAll));
	
	m_bRefresh = true;
	
	m_input = new CommonTextInput;
	m_input->Initialization();
	m_input->SetDelegate(this);
	m_layerBg->AddChild(m_input);
	
	m_layerChooseFaceOrItem = NULL;
	
	m_bInputChatName = false;
}

bool NewChatScene::SetTextContent(CommonTextInput* input, const char* text)
{
	if (m_eCurTalkChannel == eChannelPrivate && m_bInputChatName)
	{
		if (text == NULL || text == std::string("") ) return false;
		
		NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
		
		if (lbChannel)
		{
			lbChannel->SetText(text);
			
			m_bInputChatName = false;
			
			lbChannel->SetFontSize(13);
			
			NDUIButton* btnFilter = dynamic_cast<NDUIButton*> (m_layerBg->GetChild(eBtnFilter));
			
			NDUIButton* btnAddFriend = dynamic_cast<NDUIButton*> (m_layerBg->GetChild(eBtnAddFriend));
	
			if (btnFilter) {
				btnFilter->EnalbeGray(false);
			}
			if (btnAddFriend) {
				btnAddFriend->EnalbeGray(false);
			}
			
			return true;
		}
		
		return false;
	}
	
	NDUILabel* lbTalk = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbTalk));
	if (lbTalk) {
		lbTalk->SetText(text);
	}
	return true;
}

NewChatScene::~NewChatScene() {
	if (m_tbAll && m_tbAll->GetParent() == NULL) {
		SAFE_DELETE(m_tbAll);
	}
	if (m_tbSection && m_tbSection->GetParent() == NULL) {
		SAFE_DELETE(m_tbSection);
	}
	if (m_tbQueue && m_tbQueue->GetParent() == NULL) {
		SAFE_DELETE(m_tbQueue);
	}
	if (m_tbArmy && m_tbArmy->GetParent() == NULL) {
		SAFE_DELETE(m_tbArmy);
	}
	if (m_tbSecret && m_tbSecret->GetParent() == NULL) {
		SAFE_DELETE(m_tbSecret);
	}
	if (m_tbSystem && m_tbSystem->GetParent() == NULL) {
		SAFE_DELETE(m_tbSystem);
	}
	if (m_layerChooseFaceOrItem && m_layerChooseFaceOrItem->GetParent() == NULL) {
		SAFE_DELETE(m_layerChooseFaceOrItem);
	}
	
	_DefaultManager = NULL;
}

void NewChatScene::ActiveTable(ChatTable* table)
{	
	m_tbAll->RemoveFromParent(false);
	m_tbSection->RemoveFromParent(false);
	m_tbQueue->RemoveFromParent(false);
	m_tbArmy->RemoveFromParent(false);
	m_tbSecret->RemoveFromParent(false);
	m_tbSystem->RemoveFromParent(false);
	
	m_layerBg->AddChild(table);
}

void NewChatScene::ActiveChannel(NDUIButton* btnChannel)
{
	int tag = btnChannel->GetTag();
	switch (tag) {
		case eChannelAll:
			this->ActiveTable(m_tbAll);
			break;
		case eChannelSection:
			this->ActiveTable(m_tbSection);
			break;
		case eChannelTeam:
			this->ActiveTable(m_tbQueue);
			break;
		case eChannelSyndicate:
			this->ActiveTable(m_tbArmy);
			break;
		case eChannelPrivate:
			this->ActiveTable(m_tbSecret);
			break;
		case eChannelSystem:
			this->ActiveTable(m_tbSystem);
			break;
		default:
			break;
	}
	if (m_btnCurChannel) {
		m_btnCurChannel->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("chat_channel_normal.png")), true, CGRectMake(14, 0, 47, 32), true);
	}
	m_btnCurChannel = btnChannel;
	m_btnCurChannel->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("chat_channel_focus.png")), false, CGRectZero, true);
}

void NewChatScene::RemoveRecordBySpeaker(ChatTable* table, const string& speaker)
{
	NDDataSource* ds = table->GetDataSource();
	if (!ds) {
		return;
	}
	NDSection* sec = ds->Section(0);
	if (!sec) {
		return;
	}
	
	uint i = 0;
	while (i < sec->Count()) {
		ChatRecord* record = dynamic_cast<ChatRecord*> (sec->Cell(i));
		i++;
		if (record) {
			if (speaker == record->GetSpeaker()) {
				sec->RemoveCell(record);
				i--;
			}
		}
	}
	
	table->ReflashData();
}

void NewChatScene::FilterByName(const string& name)
{
	if (s_filter_name.count(name) == 0) {
		s_filter_name.insert(name);
		this->RemoveRecordBySpeaker(m_tbAll, name);
		this->RemoveRecordBySpeaker(m_tbSecret, name);
		this->RemoveRecordBySpeaker(m_tbArmy, name);
		this->RemoveRecordBySpeaker(m_tbQueue, name);
		this->RemoveRecordBySpeaker(m_tbSection, name);
	}
}

void NewChatScene::SwitchRefresh()
{
	m_bRefresh = !m_bRefresh;
	NDUIButton* btnRefresh = dynamic_cast<NDUIButton*> (m_layerBg->GetChild(eBtnRefresh));
	if (btnRefresh) {
		if (m_bRefresh) {
			m_tbAll->ReflashData();
			m_tbArmy->ReflashData();
			m_tbQueue->ReflashData();
			m_tbSecret->ReflashData();
			m_tbSection->ReflashData();
			m_tbSystem->ReflashData();
			btnRefresh->SetTitle(NDCommonCString("stop"));
		} else {
			btnRefresh->SetTitle(NDCommonCString("refresh"));
		}
	}
}

void NewChatScene::Show()
{
	if (m_layerChooseFaceOrItem == NULL) {
		m_layerChooseFaceOrItem = new ChatFaceOrItemLayer;
	}
	NDDirector::DefaultDirector()->PushScene(_DefaultManager);
}

void NewChatScene::OnButtonClick(NDUIButton* button)
{
	int tag = button->GetTag();
	switch (tag) {
		case eBtnClose:
			m_input->ShowContentTextField(false);
			NDDirector::DefaultDirector()->PopScene(false);
			if (m_layerChooseFaceOrItem) {
				m_layerChooseFaceOrItem->RemoveFromParent(false);
				SAFE_DELETE(m_layerChooseFaceOrItem);
			}
			break;
		case eBtnFilter:
		{
			if (button->IsGray()) {
				return;
			}
			NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
			if (lbChannel) {
				string name = lbChannel->GetText();
				this->FilterByName(name);
			}
		}
			break;
		case eBtnAddFriend:
		{
			if (button->IsGray()) {
				return;
			}
			NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
			if (lbChannel) {
				string name = lbChannel->GetText();
				sendAddFriend(name);
			}
		}
			break;
		case eBtnRefresh:
			this->SwitchRefresh();
			break;
		case eBtnSelItem:
		{
			m_input->ShowContentTextField(false);
			if (m_layerChooseFaceOrItem) {
				this->AddChild(m_layerChooseFaceOrItem);
				m_layerChooseFaceOrItem->Show(eShowItem);
			}
		}
			break;
		case eBtnSelFace:
		{
			m_input->ShowContentTextField(false);
			if (m_layerChooseFaceOrItem) {
				this->AddChild(m_layerChooseFaceOrItem);
				m_layerChooseFaceOrItem->Show(eShowFace);
			}
		}
			break;
		case eChannelAll:
		case eChannelSection:
		case eChannelTeam:
		case eChannelSyndicate:
		case eChannelPrivate:
		case eChannelSystem:
			this->ActiveChannel(button);
			break;
		case eSelectChannel:
			this->ShowSelectChannel();
			break;
		case eInputTalk:
		{
			this->InputTalk();
		}
			break;
		case eSendTalk:
		{
			if (!(m_eCurTalkChannel == eChannelPrivate && m_bInputChatName))
				this->SendTalk();
			else
				showDialog(NDCommonCString("tip"), NDCommonCString("InputPrivateChatName"));
		}
			break;
		default:
			break;
	}
}

string NewChatScene::FilterMessage(const string& msg)
{
	if (!m_layerChooseFaceOrItem) return "";
	
	VEC_ITEM& vItem = ItemMgrObj.GetPlayerBagItems();
	NSString result = [NSString stringWithUTF8String:msg.c_str()];
	
	NSRange range = [result rangeOfString:@"<b"];
	while (range.location != NSNotFound) 
	{
		NSString srcStr = [NSString stringWithUTF8String:"<b"]; 
		NSString dstStr = @"";
		
		if (range.location + 4 <= [result length])
		{
			uint itemIndex = [[result substringWithRange:NSMakeRange(range.location + 2, 2)] intValue];			
			SendItemInfo sendItemInfo;
			bool ret = m_layerChooseFaceOrItem->GetSendItemInfo(itemIndex, sendItemInfo);
			if (!ret) return "";
			
			srcStr = [NSString stringWithFormat:@"%@%02d", srcStr, itemIndex];
			dstStr = [NSString stringWithFormat:@">b%@/%d/%d~", [NSString stringWithUTF8String:sendItemInfo.strName.c_str()], sendItemInfo.iColor, sendItemInfo.idItem];
		}		
		
		result = [result stringByReplacingOccurrencesOfString:srcStr withString:dstStr];
		range = [result rangeOfString:@"<b"];
	}
	result = [result stringByReplacingOccurrencesOfString:@">b" withString:@"<b"];
	
	return std::string([result UTF8String]);
}



void NewChatScene::SendTalk()
{
	NDUILabel* lbTalk = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbTalk));
	if (!lbTalk) {
		return;
	}
	
	std::string msg = this->FilterMessage(lbTalk->GetText());
	if (m_layerChooseFaceOrItem) 
		m_layerChooseFaceOrItem->ClearSendItemInfo();
	if (msg.size() <= 0 || msg.size() > 400) {
		return;
	}
	lbTalk->SetText("");
	m_input->ShowContentTextField(false);
	if (m_eCurTalkChannel == eChannelPrivate) {
		NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
		if (lbChannel) {
			//std::string localMsg = lbChannel->GetText();
			std::string localMsg = NDPlayer::defaultHero().m_name;
			Chat::DefaultChat()->AddMessage(ChatTypeSecret, msg.c_str(), localMsg.c_str());
			ChatInput::SendChatDataToServer(ChatTypeSecret, msg.c_str(), lbChannel->GetText().c_str());
		}
	} else {
		std::string speaker = NDPlayer::defaultHero().m_name;
		ChatType eChatType = ChatTypeWorld;
		switch (m_eCurTalkChannel) {
			case eChannelSection:
				eChatType = ChatTypeSection;
				break;
			case eChannelSyndicate:
				if(NDPlayer::defaultHero().getSynRank() == SYNRANK_NONE)
				{
					NDString strText;
					strText.Format("【%s】:%s。", NDCommonCString("system"), NDCommonCString("YouHasnotJunTuan"));
					Chat::DefaultChat()->AddMessage(ChatTypeSystem, strText.getData());
					return;
				}
				eChatType = ChatTypeArmy;
				break;
			case eChannelAll:
				eChatType = ChatTypeWorld;
				break;
			case eChannelTeam:
				eChatType = ChatTypeQueue;
				if(!NDPlayer::defaultHero().isTeamMember())
				{
					NDString strText;
					strText.Format("【%s】:%s。", NDCommonCString("system"), NDCommonCString("YouHasnotJunTeam"));
					Chat::DefaultChat()->AddMessage(ChatTypeSystem, strText.getData());
					return;
				}
				break;
			default:
				break;
		}
		
		Chat::DefaultChat()->AddMessage(eChatType, msg.c_str(), speaker.c_str());
		ChatInput::SendChatDataToServer(eChatType, msg.c_str());
	}
}

void NewChatScene::InputTalk()
{
	NDUILabel* lbTalk = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbTalk));
	if (lbTalk) {
		m_input->ShowContentTextField(true, lbTalk->GetText().c_str());
	}
}

void NewChatScene::ShowSelectChannel()
{
	if (m_layerBg->GetChild(eTlSelChannel)) {
		m_layerBg->RemoveChild(eTlSelChannel, true);
		return;
	}
	
#define _init(channel, eTag) btnChannel = new NDUIButton; \
btnChannel->Initialization(); \
btnChannel->SetFrameRect(CGRectMake(0, 0, 72, 27)); \
btnChannel->SetTitle(channel); \
btnChannel->SetTag(eTag); \
btnChannel->CloseFrame(); \
btnChannel->SetFontColor(ccc4(211,166,99,255)); \
btnChannel->SetFocusColor(ccc4(222, 200, 151, 255)); \
section->AddCell(btnChannel)
	
	NDUITableLayer* tlChannel = new NDUITableLayer;
	tlChannel->Initialization();
	tlChannel->SetDelegate(this);
	tlChannel->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("choose_chat_channel.png")), true);
	tlChannel->VisibleSectionTitles(false);
	tlChannel->SetFrameRect(CGRectMake(20, 123, 72, 150));
	tlChannel->SetBackgroundColor(ccc4(0, 0, 0, 0));
	tlChannel->SetTag(eTlSelChannel);
	m_layerBg->AddChild(tlChannel, 1);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	NDUIButton *btnChannel = new NDUIButton;
	btnChannel->Initialization();
	btnChannel->CloseFrame();
	btnChannel->SetFrameRect(CGRectMake(0, 0, 72, 25));
	btnChannel->SetTitle(CHANNEL_ALL);
	btnChannel->SetTag(eChannelAll);
	btnChannel->SetFontColor(ccc4(211,166,99,255));
	btnChannel->SetFocusColor(ccc4(222, 200, 151, 255));
	section->AddCell(btnChannel);
	
	_init(CHANNEL_SECTION, eChannelSection);
	_init(CHANNEL_TEAM, eChannelTeam);
	_init(CHANNEL_SYNDICATE, eChannelSyndicate);
	_init(CHANNEL_PRIVATE, eChannelPrivate);
	
	dataSource->AddSection(section);
	tlChannel->SetDataSource(dataSource);
	
#undef _init(channel, eTag)
}

bool NewChatScene::IsFilterBySpeaker(const char* speaker)
{
	if (speaker) {
		string name = speaker;
		return s_filter_name.count(name)> 0;
	}
	return false;
}

void NewChatScene::AddMessage(ChatType type, const char* msg, const char* speaker)
{
	ChatRecord* record = new ChatRecord();
	record->Initialization();
	record->SetChatType(type);
	record->SetFrameRect(CGRectMake(0, 0, 211, NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(msg, 211, 15)));
	record->SetTextFontColor(GetColorWithChatType(type));
	record->SetText(msg);
	
	if (speaker) {
		record->SetTitle(speaker);
	}
	
	if (this->IsFilterBySpeaker(speaker)) {
		SAFE_DELETE(record);
		return;
	}
	
	switch (type) {
		case ChatTypeAll:
			m_tbAll->AddOneRecord(record, m_bRefresh);
			break;
		case ChatTypeTip:
			m_tbAll->AddOneRecord(record, m_bRefresh);
			break;
		case ChatTypeImportant:
			m_tbAll->AddOneRecord(record, m_bRefresh);
			break;
		case ChatTypeWorld:
			m_tbAll->AddOneRecord(record, m_bRefresh);
			break;
		case ChatTypeSection:
			m_tbSection->AddOneRecord(record, m_bRefresh);
			m_tbAll->AddOneRecord(record->Copy(), m_bRefresh);
			break;
		case ChatTypeQueue:
			m_tbQueue->AddOneRecord(record, m_bRefresh);
			m_tbAll->AddOneRecord(record->Copy(), m_bRefresh);
			break;
		case ChatTypeArmy:
			m_tbArmy->AddOneRecord(record, m_bRefresh);
			m_tbAll->AddOneRecord(record->Copy(), m_bRefresh);
			break;
		case ChatTypeSecret:
			m_tbSecret->AddOneRecord(record, m_bRefresh);
			m_tbAll->AddOneRecord(record->Copy(), m_bRefresh);
		{
		}
			break;
		case ChatTypeSystem:
			m_tbSystem->AddOneRecord(record, m_bRefresh);
			m_tbAll->AddOneRecord(record->Copy(), m_bRefresh);
			break;
		default:
			break;
	}
}

bool NewChatScene::AppendItem(OBJID idItem)
{
	if (!m_layerChooseFaceOrItem) return false;
	
	return m_layerChooseFaceOrItem->AddChatItem(idItem);
}

bool NewChatScene::AppendItem(OBJID idObject, int color, std::string name)
{
	if (!m_layerChooseFaceOrItem) return false;
	
	return m_layerChooseFaceOrItem->AppendItem(idObject, color, name);
}

void NewChatScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	int tag = table->GetTag();
	NDUIButton* btnFilter = dynamic_cast<NDUIButton*> (m_layerBg->GetChild(eBtnFilter));
	NDUIButton* btnAddFriend = dynamic_cast<NDUIButton*> (m_layerBg->GetChild(eBtnAddFriend));
	
	if (tag == eTlSelChannel) {
		if (btnFilter) {
			btnFilter->EnalbeGray(true);
		}
		if (btnAddFriend) {
			btnAddFriend->EnalbeGray(true);
		}
		NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
		if (lbChannel) {
			lbChannel->SetFontSize(15);
			m_eCurTalkChannel = cell->GetTag();
			m_bInputChatName = false;
			switch (m_eCurTalkChannel) {
				case eChannelAll:
					lbChannel->SetText(CHANNEL_ALL);
					break;
				case eChannelSection:
					lbChannel->SetText(CHANNEL_SECTION);
					break;
				case eChannelTeam:
					lbChannel->SetText(CHANNEL_TEAM);
					break;
				case eChannelSyndicate:
					lbChannel->SetText(CHANNEL_SYNDICATE);
					break;
				case eChannelPrivate:
					lbChannel->SetText(CHANNEL_PRIVATE);
					m_bInputChatName = true;
					if (m_input)
						m_input->ShowContentTextField(true, "");
				default:
					break;
			}
		}
		m_layerBg->RemoveChild(eTlSelChannel, true);
	} else {
		ChatRecord* record = (ChatRecord*)cell;
		string speaker = record->GetSpeaker();
		
		if (CGRectContainsPoint(record->GetTitleRect(), table->m_beginTouch))
		{ // 点击名字
			ChatType eChatType = record->GetChatType();
			if (eChatType == ChatTypeImportant ||
				eChatType == ChatTypeSystem ||
				eChatType == ChatTypeTip) {
				return;
			}
			
			if (speaker.size() > 0 && NDPlayer::defaultHero().m_name != speaker) {
				NDUILabel* lbChannel = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbChannel));
				if (lbChannel) {
					m_eCurTalkChannel = eChannelPrivate;
					lbChannel->SetFontSize(13);
					lbChannel->SetText(speaker.c_str());
					m_bInputChatName = false;
					if (btnFilter) {
						btnFilter->EnalbeGray(false);
					}
					if (btnAddFriend) {
						btnAddFriend->EnalbeGray(false);
					}
				}
			}
		}
		else {
			if (record->OnClick(table->m_beginTouch)) {
				return;
			}
			
			std::string recordText = record->GetText();
			NDUIDialog* dlg = new NDUIDialog();		
			dlg->Initialization();
			dlg->SetDelegate(this);
			
			//系统
			if (record->GetChatType() == ChatTypeSystem || record->GetChatType() == ChatTypeTip || record->GetChatType() == ChatTypeImportant) 
			{
				dlg->SetTag(DIALOG_TAG_SYSTEM);
				dlg->Show(speaker.c_str(), recordText.c_str(), NDCommonCString("return"), NULL);
			}
			//玩家自己
			else if (speaker == NDPlayer::defaultHero().m_name)
			{
				dlg->SetTag(DIALOG_TAG_PLAYER);
				dlg->Show(speaker.c_str(), recordText.c_str(), NDCommonCString("return"), NDCommonCString("CopyName"), NULL);
			}
			//其他玩家
			else 
			{
				dlg->SetTag(DIALOG_TAG_ORTHER);
				dlg->Show(speaker.c_str(), recordText.c_str(), NDCommonCString("return"), NDCommonCString("CopyName"), NULL);
			}
		}
	}
}

void NewChatScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	switch (dialog->GetTag()) 
	{
		case DIALOG_TAG_PLAYER:
		case DIALOG_TAG_ORTHER:
			CopyDataToCopyCache(dialog->GetTitle().c_str());
			break;
		default:
			break;
	}
	dialog->Close();
}

void NewChatScene::AppendTalkText(const char* text)
{
	NDUILabel* lbTalk = dynamic_cast<NDUILabel*> (m_layerBg->GetChild(eLbTalk));
	if (lbTalk && text) {
		string str = lbTalk->GetText();
		str += text;
		lbTalk->SetText(str.c_str());
	}
}

/////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ChatFaceOrItemLayer, NDUILayer)

const CGRect RECT_FACE = CGRectMake(128, 320, 225, 225);

ChatFaceOrItemLayer::ChatFaceOrItemLayer()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	m_layerFace = new NDUILayer;
	m_layerFace->Initialization();
	m_layerFace->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("bag_bag_bg.png"), 265, 265, false), true);
	m_layerFace->SetFrameRect(RECT_FACE);
	//this->AddChild(m_layerFace);
	
	m_bMoving = false;
	
	for (int index = 0; index < 25; index++) 
	{
		NDUIButton* btn = new NDUIButton();
		btn->Initialization();
		btn->SetTag(index);
		btn->SetDelegate(this);
		
		NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("face.png"));				
		int row = index / 5;
		int col = index % 5;
		pic->Cut(CGRectMake(15 * col, 15 * row , 15, 15));
		
		btn->SetImage(pic, true, CGRectMake(15, 15, 15, 15), true);
		btn->SetFrameRect(CGRectMake(col * 45, row * 45, 45, 45));
		m_layerFace->AddChild(btn);
	}
	
	m_bag = new NewGameItemBag;
	m_bag->Initialization(ItemMgrObj.GetPlayerBagItems(), true, false);
	m_bag->SetDelegate(this);
	m_bag->SetFrameRect(CGRectMake(480, 26, NEW_ITEM_BAG_W, NEW_ITEM_BAG_H));
	m_bag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	//this->AddChild(m_bag);
}

ChatFaceOrItemLayer::~ChatFaceOrItemLayer()
{
	if (m_layerFace->GetParent() == NULL) {
		SAFE_DELETE(m_layerFace);
	}
	if (m_bag->GetParent() == NULL) {
		SAFE_DELETE(m_bag);
	}
}

void ChatFaceOrItemLayer::Show(ShowType eType)
{
	m_bMoving = true;
	m_eCurType = eType;
	switch (eType) {
		case eShowFace:
			m_bag->RemoveFromParent(false);
			if (m_layerFace->GetParent() == NULL) {
				this->AddChild(m_layerFace);
			}
			m_layerFace->SetFrameRect(RECT_FACE);
			break;
		case eShowItem:
			m_layerFace->RemoveFromParent(false);
			if (m_bag->GetParent() == NULL) {
				this->AddChild(m_bag);
			}
			m_bag->SetFrameRect(CGRectMake(480, 26, NEW_ITEM_BAG_W, NEW_ITEM_BAG_H));
			break;
		default:
			break;
	}
}

bool ChatFaceOrItemLayer::TouchEnd(NDTouch* touch)
{
	if (!NDUILayer::TouchEnd(touch)) {
		this->RemoveFromParent(false);
	}
	return true;
}

const int STEP_Y = 80;

void ChatFaceOrItemLayer::draw()
{
	NDUILayer::draw();
	
	if (m_bMoving) {
		switch (m_eCurType) {
			case eShowFace:
			{
				CGRect rectFace = m_layerFace->GetFrameRect();
				rectFace.origin.y -= STEP_Y;
				if (rectFace.origin.y <= 48) {
					m_bMoving = false;
					rectFace.origin.y = 48;
				}
				m_layerFace->SetFrameRect(rectFace);
			}
				break;
			case eShowItem:
			{
				CGRect rect = m_bag->GetFrameRect();
				rect.origin.x -= STEP_Y;
				if (rect.origin.x <= 203) {
					m_bMoving = false;
					rect.origin.x = 203;
				}
				m_bag->SetFrameRect(rect);
			}
				break;
			default:
				break;
		}
	}
}

bool ChatFaceOrItemLayer::OnClickCell(NewGameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (item)
	{
		AddChatItem(item->iID);
	}
	this->RemoveFromParent(false);
	return false;
}

bool ChatFaceOrItemLayer::AddChatItem(OBJID idItem)
{
	Item* item = ItemMgrObj.QueryItem(idItem);
	
	if (!item) return false;
	
	return AppendItem(idItem, Item::getItemColorTag(item->iItemType), item->getItemName());
}

bool ChatFaceOrItemLayer::AppendItem(OBJID idItem, int color, std::string name)
{
	int iItemIndex = GetNextItemIndex();
	
	m_mapSendItemInfo[iItemIndex] = SendItemInfo(idItem, color, name);
	
	char strIndex[5] = { 0x00 };
	sprintf(strIndex, "<b%02d", iItemIndex);
	NewChatScene* chatScene = (NewChatScene*)NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(NewChatScene));
	if (chatScene) {
		chatScene->AppendTalkText(strIndex);
	}
	
	return true;
}

bool ChatFaceOrItemLayer::GetSendItemInfo(int index, SendItemInfo& ret)
{
	std::map<int, SendItemInfo>::iterator
	it = m_mapSendItemInfo.find(index);
	
	if (it == m_mapSendItemInfo.end())
		return false;
	
	ret = it->second;
	return true;
}

void ChatFaceOrItemLayer::ClearSendItemInfo()
{
	m_mapSendItemInfo.clear();
}

int ChatFaceOrItemLayer::GetNextItemIndex()
{
	static unsigned int s_ucCount = 0;
	s_ucCount++;
	return s_ucCount % 100;
}

void ChatFaceOrItemLayer::OnButtonClick(NDUIButton* button)
{
	switch (m_eCurType) {
		case eShowFace:
		{
			char strIndex[5] = { 0x00 };
			sprintf(strIndex, "<f%02d", button->GetTag());
			NewChatScene* chatScene = dynamic_cast<NewChatScene*> (this->GetParent());
			if (chatScene) {
				chatScene->AppendTalkText(strIndex);
			}
			this->RemoveFromParent(false);
		}
			break;
		default:
			break;
	}
}
#endif 
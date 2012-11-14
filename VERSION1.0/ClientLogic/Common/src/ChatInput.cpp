//
//  ChatInput.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ChatInput.h"
#include "ItemMgr.h"
#include "Item.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDPicture.h"
#include "NDUtility.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "NDPlayer.h"
#include "TaskListener.h"
#include "ChatRecordManager.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ChatInput, NDUICustomView)

#define tag_expression_begin 1024

ChatInput::ChatInput()
{
	m_expressionLayer = NULL;
	m_itemLayer = NULL;
	m_itemBag = NULL;
	m_friendLayer = NULL;
}

ChatInput::~ChatInput()
{
	if (m_expressionLayer) 
	{
		if (m_expressionLayer->GetParent()) 
			m_expressionLayer->RemoveFromParent(true);
		else 
			delete m_expressionLayer;
	}
	
	if (m_itemLayer) 
	{
		if (m_itemLayer->GetParent()) 
			m_itemLayer->RemoveFromParent(true);
		else 
			delete m_itemLayer;
	}
	
	if (m_friendLayer) 
	{
		if (m_friendLayer->GetParent()) 
			m_friendLayer->RemoveFromParent(true);
		else 
			delete m_friendLayer;
	}
}

void ChatInput::OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp)
{	
	if (!bCleanUp)
		return;
		
	if (node == m_expressionLayer)
	{
		m_expressionLayer = NULL;
	}
	else if (node == m_itemLayer)
	{
		m_itemLayer = NULL;
	}
	else if (node == m_friendLayer)
	{
		m_friendLayer = NULL;
	}
	else if (node == m_itemBag)
	{
		m_itemBag = NULL;
	}
}

std::string ChatInput::FilterMessage(const std::string& msg)
{
	NSString* result = [NSString stringWithUTF8String:msg.c_str()];
	
	NSRange range = [result rangeOfString:@"<b"];
	while (range.location != NSNotFound) 
	{
		NSString* srcStr = [NSString stringWithUTF8String:"<b"]; 
		NSString* dstStr = @"";
		
		if (range.location + 4 <= [result length])
		{
			int itemIndex = [[result substringWithRange:NSMakeRange(range.location + 2, 2)] intValue];			
			if (itemIndex >= 0 && itemIndex < 96 && m_itemBag) 
			{
				int iPage = itemIndex / 24;
				int iIndex = itemIndex % 24;
				Item* item = m_itemBag->GetItem(iPage, iIndex);	
				if (item) 
				{
					srcStr = [NSString stringWithFormat:@"%@%02d", srcStr, itemIndex];
					dstStr = [NSString stringWithFormat:@">b%@/%d/%d~", [NSString stringWithUTF8String:item->getItemName().c_str()], Item::getItemColorTag(item->iItemType), item->iID];
				}				
			}
		}		
		
		result = [result stringByReplacingOccurrencesOfString:srcStr withString:dstStr];
		range = [result rangeOfString:@"<b"];
	}
	result = [result stringByReplacingOccurrencesOfString:@">b" withString:@"<b"];
	
	return std::string([result UTF8String]);
}

void ChatInput::SendChatDataToServer(ChatType type, const char* msg, const char* otherName)
{
	NDTransData data(_MSG_TALK);
	
	Byte channel = GetChannelFromChatType(type);
	
	int time = (int)([[NSDate date] timeIntervalSince1970] / 1000);
	data << (Byte)0 << channel << time << (Byte)0 << (Byte)2;
	
	data.WriteUnicodeString(msg);
	data.WriteUnicodeString(otherName);
	SEND_DATA(data);
	
//	if (Task::BEGIN_FRESHMAN_TASK) {
//		Task* taskChat = NDPlayer::defaultHero().GetPlayerTask(Task::TASK_CHAT);
//		if (taskChat) {
//			sendTaskFinishMsg(Task::TASK_CHAT);
//		}
//	}
}

void ChatInput::ShowExpressions()
{
	if (!m_expressionLayer) 
	{
		m_expressionLayer = new NDUIMenuLayer();
		m_expressionLayer->Initialization();
		m_expressionLayer->GetCancelBtn()->SetDelegate(this);
		m_expressionLayer->SetDelegate(this);
		
		NDUIRecttangle* bkg = new NDUIRecttangle();
		bkg->Initialization();
		bkg->SetColor(ccc4(253, 253, 253, 255));
		bkg->SetFrameRect(CCRectMake(0, m_expressionLayer->GetTitleHeight(), 480, m_expressionLayer->GetTextHeight()));
		m_expressionLayer->AddChild(bkg);
		
		NDPicture* picExpression = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
		picExpression->Cut(CCRectMake(180, 120, 100, 19));
		
		NDUIImage* image = new NDUIImage();
		image->Initialization();
		image->SetPicture(picExpression, true);
		image->SetFrameRect(CCRectMake(190, 5, picExpression->GetSize().width, picExpression->GetSize().height));
		m_expressionLayer->AddChild(image);
		
		for (int index = 0; index < 25; index++) 
		{
			NDUIButton* btn = new NDUIButton();
			btn->Initialization();
			btn->SetTag(tag_expression_begin + index);
			btn->SetDelegate(this);
			
			NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("face.png"));				
			int row = index / 5;
			int col = index % 5;
			pic->Cut(CCRectMake(15 * col, 15 * row , 15, 15));
			
			btn->SetImage(pic, false, CCRectZero, true);
			btn->SetFrameRect(CCRectMake(80 + col * 60, 35 + row * 50, 40, 40));			
			m_expressionLayer->AddChild(btn);
		}		
	}
	NDDirector::DefaultDirector()->GetRunningScene()->AddChild(m_expressionLayer, CHAT_INPUT_Z);
	this->Hide();
}

void ChatInput::HideExpressions()
{
	if (m_expressionLayer && m_expressionLayer->GetParent())
	{
		m_expressionLayer->RemoveFromParent(false);
	}
	this->Show();
}

void ChatInput::ShowItems()
{
	if (!m_itemLayer) 
	{
		m_itemLayer = new NDUIMenuLayer();
		m_itemLayer->Initialization();
		m_itemLayer->GetCancelBtn()->SetDelegate(this);
		m_itemLayer->SetDelegate(this);
		
		NDUIRecttangle* bkg = new NDUIRecttangle();
		bkg->Initialization();
		bkg->SetColor(ccc4(253, 253, 253, 255));
		bkg->SetFrameRect(CCRectMake(0, m_itemLayer->GetTitleHeight(), 480, m_itemLayer->GetTextHeight()));
		m_itemLayer->AddChild(bkg);
		
		NDPicture* picItem = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
		picItem->Cut(CCRectMake(76, 120, 103, 19));
		
		NDUIImage* image = new NDUIImage();
		image->Initialization();
		image->SetPicture(picItem, true);
		image->SetFrameRect(CCRectMake(190, 5, picItem->GetSize().width, picItem->GetSize().height));
		m_itemLayer->AddChild(image);
		
		m_itemBag = new GameItemBag();
		m_itemBag->Initialization(ItemMgrObj.GetPlayerBagItems());
		m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
		m_itemBag->SetDelegate(this);
		m_itemBag->SetFrameRect(CCRectMake(100, 30, ITEM_BAG_W, ITEM_BAG_H));
		m_itemLayer->AddChild(m_itemBag);
	}
	NDDirector::DefaultDirector()->GetRunningScene()->AddChild(m_itemLayer, CHAT_INPUT_Z);
	this->Hide();
}

void ChatInput::HideItems()
{
	if (m_itemLayer && m_itemLayer->GetParent())
	{
		m_itemLayer->RemoveFromParent(false);
	}
	this->Show();
}

void ChatInput::ShowFriends()
{
	if (!m_friendLayer) 
	{
		m_friendLayer = new GoodFriendUILayer();
		m_friendLayer->Initialization();
		m_friendLayer->GetCancelBtn()->SetDelegate(this);
		m_friendLayer->m_tlMain->SetDelegate(this);
		m_friendLayer->SetDelegate(this);
	}
	NDDirector::DefaultDirector()->GetRunningScene()->AddChild(m_friendLayer, CHAT_INPUT_Z);
	this->Hide();
}

void ChatInput::HideFriends()
{
	if (m_friendLayer && m_friendLayer->GetParent())
	{
		m_friendLayer->RemoveFromParent(false);
	}
	this->Show();
}

void ChatInput::OnButtonClick(NDUIButton* button)
{
	if (m_expressionLayer && button == m_expressionLayer->GetCancelBtn())
	{
		HideExpressions();
	}
	else if (m_itemLayer && button == m_itemLayer->GetCancelBtn())
	{
		HideItems();
	}
	else if (m_friendLayer && button == m_friendLayer->GetCancelBtn())
	{
		HideFriends();
	}
	else if (button->GetTag() >= tag_expression_begin && button->GetTag() < tag_expression_begin + 25)
	{
		char strIndex[5] = { 0x00 };
		sprintf(strIndex, "<f%02d", button->GetTag() - tag_expression_begin);
		OnGetExpression(strIndex);
		HideExpressions();
	}		
}

bool ChatInput::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{		
	if (item)
	{
		char strIndex[5] = { 0x00 };
		sprintf(strIndex, "<b%02d", iCellIndex);	
		OnGetItem(strIndex);
		HideItems();
	}	
	return true;
	
}

void ChatInput::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (m_friendLayer->m_tlMain == table) 
	{
		FriendElement* element = (FriendElement*)((SocialTextLayer*)cell)->GetSocialElement();
		OnGetFriend(element->m_text1.c_str()); 
		HideFriends();
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PublicChatInput, NDUICustomView)

static PublicChatInput* PublicChatInput_DefaultInput = NULL;
PublicChatInput::PublicChatInput()
{
	NDAsssert(PublicChatInput_DefaultInput == NULL);
	m_curChatType = ChatTypeWorld;
}

PublicChatInput::~PublicChatInput()
{
	PublicChatInput_DefaultInput = NULL;
}

PublicChatInput* PublicChatInput::DefaultInput()
{
	if (PublicChatInput_DefaultInput == NULL) 
	{
		PublicChatInput_DefaultInput = new PublicChatInput();
		PublicChatInput_DefaultInput->Initialization();
		PublicChatInput_DefaultInput->SetDelegate(PublicChatInput_DefaultInput);
	}
	return PublicChatInput_DefaultInput;
}

void PublicChatInput::Initialization()
{
	ChatInput::Initialization();
	
	//
	std::vector<int> edtTags;
	edtTags.push_back(1);
	std::vector<std::string> edtTitles;
	edtTitles.push_back(NDCommonCString("InputContent"));
	this->SetEdit(1, edtTags, edtTitles);
	
	//
	std::vector<int> rdoTags;
	rdoTags.push_back(1);
	rdoTags.push_back(2);
	rdoTags.push_back(3);
	rdoTags.push_back(4);
	std::vector<std::string> rdoTitles;
	rdoTitles.push_back(NDCommonCString("world"));
	rdoTitles.push_back(NDCommonCString("section"));
	rdoTitles.push_back(NDCommonCString("team"));
	rdoTitles.push_back(NDCommonCString("JunTuan"));
	this->SetRadioButton(4, rdoTags, rdoTitles);
	
	//
	std::vector<int> btnTags;
	btnTags.push_back(1);
	btnTags.push_back(2);
	btnTags.push_back(3);
	std::vector<std::string> btnTitles;
	btnTitles.push_back(NDCommonCString("send"));
	btnTitles.push_back(NDCommonCString("InputExpress"));
	btnTitles.push_back(NDCommonCString("InputItem"));
	this->SetButton(3, btnTags, btnTitles);
}

void PublicChatInput::SetActiveChatType(ChatType type)
{
	switch (type) {
		case ChatTypeWorld:
			m_curChatType = ChatTypeWorld;
			this->SetActiveRadioButtonWithIndex(0);
			break;
		case ChatTypeSection:
			m_curChatType = ChatTypeSection;
			this->SetActiveRadioButtonWithIndex(1);
			break;
		case ChatTypeQueue:
			m_curChatType = ChatTypeQueue;
			this->SetActiveRadioButtonWithIndex(2);
			break;
		case ChatTypeArmy:
			m_curChatType = ChatTypeArmy;
			this->SetActiveRadioButtonWithIndex(3);
			break;
		default:
			break;
	}
}

void PublicChatInput::OnGetExpression(const char* expressionStr)
{
	std::string edtText = this->GetEditText(0);
	edtText.append(expressionStr);
	this->SetEditText(edtText.c_str(), 0);
	
}

void PublicChatInput::OnGetItem(const char* itemStr)
{
	std::string edtText = this->GetEditText(0);
	edtText.append(itemStr);
	this->SetEditText(edtText.c_str(), 0);
}

bool PublicChatInput::OnCustomViewConfirm(NDUICustomView* customView)
{
	return true;
}

void PublicChatInput::OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag)
{
	if (ortherButtonIndex == 0) 
	{
		if (m_curChatType == ChatTypeArmy && NDPlayer::defaultHero().getSynRank() == SYNRANK_NONE) 
		{
			ChatRecordManager::DefaultManager()->SetErrorMessage(NDCommonCString("YouHasnotJunTuan"));
		}		
		else if (m_curChatType == ChatTypeQueue && !NDPlayer::defaultHero().isTeamMember()) 
		{
			ChatRecordManager::DefaultManager()->SetErrorMessage(NDCommonCString("YouHasnotJunTeam"));
		}
		else 
		{
			std::string msg = FilterMessage(this->GetEditText(0));	
			std::string speaker = NDPlayer::defaultHero().m_name + ":";
			Chat::DefaultChat()->AddMessage(m_curChatType, msg.c_str(), speaker.c_str());
			SendChatDataToServer(m_curChatType, msg.c_str());				
		}
		//发送		
		Hide();
	}
	else if (ortherButtonIndex == 1)
	{
		//插入表情
		ShowExpressions();			
	}
	else if (ortherButtonIndex == 2)
	{
		//插入物品
		ShowItems();
	}
}

void PublicChatInput::OnCustomViewRadioButtonSelected(NDUICustomView* customView, unsigned int radioButtonIndex, int ortherButtonTag)
{
	switch (radioButtonIndex) {
		case 0:
			m_curChatType = ChatTypeWorld;
			break;
		case 1:
			m_curChatType = ChatTypeSection;
			break;
		case 2:
			m_curChatType = ChatTypeQueue;
			break;
		case 3:
			m_curChatType = ChatTypeArmy;
			break;
		default:
			break;
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PrivateChatInput, ChatInput)

static PrivateChatInput* PrivateChatInput_DefaultInput = NULL;
PrivateChatInput::PrivateChatInput()
{
	NDAsssert(PrivateChatInput_DefaultInput == NULL);
}

PrivateChatInput::~PrivateChatInput()
{
	PrivateChatInput_DefaultInput = NULL;
}

PrivateChatInput* PrivateChatInput::DefaultInput()
{
	if (PrivateChatInput_DefaultInput == NULL) 
	{
		PrivateChatInput_DefaultInput = new PrivateChatInput();
		PrivateChatInput_DefaultInput->Initialization();
		PrivateChatInput_DefaultInput->SetDelegate(PrivateChatInput_DefaultInput);
	}
	return PrivateChatInput_DefaultInput;
}

void PrivateChatInput::Initialization()
{
	ChatInput::Initialization();
	
	//
	std::vector<int> edtTags;
	edtTags.push_back(1);
	edtTags.push_back(2);
	std::vector<std::string> edtTitles;
	edtTitles.push_back(NDCommonCString("InputContent"));
	edtTitles.push_back(NDCommonCString("PlayerName"));
	this->SetEdit(2, edtTags, edtTitles);
	
	//
	std::vector<int> btnTags;
	btnTags.push_back(1);
	btnTags.push_back(2);
	btnTags.push_back(3);
	//btnTags.push_back(4);
	std::vector<std::string> btnTitles;
	//btnTitles.push_back(NDCommonCString("send"));
	btnTitles.push_back(NDCommonCString("InputExpress"));
	btnTitles.push_back(NDCommonCString("InputItem"));
	btnTitles.push_back(NDCommonCString("SelFriend"));
	this->SetButton(3, btnTags, btnTitles);
	
	this->SetOkTitle(NDCommonCString("send"));
	
	this->SetCancelTitle(NDCommonCString("return"));
}

void PrivateChatInput::SetLinkMan(const char* name)
{
	this->SetEditText(name, 1);
}

void PrivateChatInput::OnGetExpression(const char* expressionStr)
{
	std::string edtText = this->GetEditText(0);
	edtText.append(expressionStr);
	this->SetEditText(edtText.c_str(), 0);
	
}

void PrivateChatInput::OnGetItem(const char* itemStr)
{
	std::string edtText = this->GetEditText(0);
	edtText.append(itemStr);
	this->SetEditText(edtText.c_str(), 0);
}

void PrivateChatInput::OnGetFriend(const char* friendStr)
{
	this->SetEditText(friendStr, 1);
}

bool PrivateChatInput::OnCustomViewConfirm(NDUICustomView* customView)
{
	//发送
	std::string msg = FilterMessage(this->GetEditText(0));
	std::string localMsg;
	//localMsg.append("【To】");
	//localMsg.append(this->GetEditText(1));
	localMsg.append(NDPlayer::defaultHero().m_name);
	localMsg.append(":");
	//localMsg.append(msg);
	Chat::DefaultChat()->AddMessage(ChatTypeSecret, msg.c_str(), localMsg.c_str());
	SendChatDataToServer(ChatTypeSecret, msg.c_str(), this->GetEditText(1).c_str());
	return true;
}

void PrivateChatInput::OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag)
{
	/*
	if (ortherButtonIndex == 0) 
	{
		//发送
		std::string msg = FilterMessage(this->GetEditText(0));
		std::string localMsg;
		//localMsg.append("【To】");
		//localMsg.append(this->GetEditText(1));
		localMsg.append(NDPlayer::defaultHero().m_name);
		localMsg.append(":");
		//localMsg.append(msg);
		Chat::DefaultChat()->AddMessage(ChatTypeSecret, msg.c_str(), localMsg.c_str());
		SendChatDataToServer(ChatTypeSecret, msg.c_str(), this->GetEditText(1).c_str());				
		Hide();
	}
	else */if (ortherButtonIndex == 0)
	{
		//插入表情
		ShowExpressions();			
	}
	else if (ortherButtonIndex == 1)
	{
		//插入物品
		ShowItems();
	}
	else if (ortherButtonIndex == 2)
	{
		//从好友列表添加
		ShowFriends();		
	}
}





//
//  ChatRecordManager.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "ChatRecordManager.h"
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

#define FontHeight	20
#define FontWidth	20
#define FontInteval	68

IMPLEMENT_CLASS(ChatRecord, NDUINode)
ChatRecord::ChatRecord()
{
	m_lblText = NULL;
	m_lblTitle = NULL;
	m_chatType = ChatTypeAll;
}

ChatRecord::~ChatRecord()
{
}

void ChatRecord::Initialization()
{
	NDUINode::Initialization();
	
	m_lblTitle = new HyperLinkLabel();
	m_lblTitle->Initialization();
	m_lblTitle->SetFrameRect(CGRectMake(0, 0, 111, 19));
	m_lblTitle->SetRenderTimes(1);
	this->AddChild(m_lblTitle);
}

void ChatRecord::SetTextFontColor(ccColor4B color)
{
	m_lblTitle->SetFontColor(color);
}

void ChatRecord::SetTitle(const char* title)
{
	if (NULL == title) {
		return;
	}
	string speaker = "【";
	speaker += title;
	speaker += "】:";
	m_lblTitle->SetText(speaker.c_str());
	switch (this->GetChatType()) {
		case ChatTypeSystem:
		case ChatTypeTip:
		case ChatTypeImportant:
			m_lblTitle->SetIsLink(false);
			break;
		default:
			m_lblTitle->SetIsLink(true);
			break;
	}
	CGSize size = getStringSize(speaker.c_str(), m_lblTitle->GetFontSize());
	m_lblTitle->SetFrameRect(CGRectMake(0, 0, size.width, 19));
	
	speaker += m_text;
	unsigned int textHeight = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(speaker.c_str(), 341, m_lblTitle->GetFontSize());
	this->SetFrameRect(CGRectMake(0, 0, 341, textHeight));
}

bool ChatRecord::OnClick(CGPoint touchPoint)
{
	if (m_lblText) {
		return m_lblText->OnTextClick(touchPoint);
	}
	return false;
}

void ChatRecord::SetText(const char* text)
{
	if (text) 
	{
		if (strcmp(m_text.c_str(), text)) 
		{
			string textWithSpeaker = m_lblTitle->GetText();
			textWithSpeaker += text;
			m_text = text;			
			unsigned int textHeight = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(textWithSpeaker.c_str(), 341, m_lblTitle->GetFontSize());
			this->SetFrameRect(CGRectMake(0, 0, 341, textHeight));
		}		
	}		
}

std::string ChatRecord::GetText()
{
	return m_text;
}

CGRect ChatRecord::GetTitleRect()
{
	CGRect rect = CGRectZero;
	if (m_lblTitle) {
		rect = m_lblTitle->GetScreenRect();
	}
	return rect;
}

string ChatRecord::GetTitle()
{
	if (m_lblTitle) {
		return m_lblTitle->GetText();
	}
	return "";
}

string ChatRecord::GetSpeaker()
{
	string speaker = this->GetTitle();
	if (speaker.size() > 7) {
		speaker = speaker.substr(3, speaker.size() - 7);
	}
	return speaker;
}

void ChatRecord::SetChatType(ChatType type)
{ 
	m_chatType = type; 
}

ChatType ChatRecord::GetChatType()
{ 
	return m_chatType; 
}

void ChatRecord::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
{
	if (srcRect.size.width != dstRect.size.width || srcRect.size.height != dstRect.size.height) 
	{
		ReCreateLabelText();
	}
}

void ChatRecord::ReCreateLabelText()
{
	if (m_lblText) 
	{
		if (m_lblText->GetParent())
			m_lblText->RemoveFromParent(true);
		else 
			delete m_lblText;
	}		
	
	string textWithSpeaker = m_lblTitle->GetText();
	textWithSpeaker += m_text;
	unsigned int textHeight = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(textWithSpeaker.c_str(), 341, m_lblTitle->GetFontSize());
	m_lblText = NDUITextBuilder::DefaultBuilder()->Build(textWithSpeaker.c_str(), 
														   m_lblTitle->GetFontSize(), 
														   CGSizeMake(341, textHeight), 
														   m_lblTitle->GetFontColor());
	m_lblText->SetFrameRect(CGRectMake(0, 0, 341, textHeight));
	this->AddChild(m_lblText);
}

void ChatRecord::draw()
{
	NDUINode::draw();	
	if (this->IsVisibled()) 
	{
		NDUILayer* parentNode = (NDUILayer*)this->GetParent();
		if (parentNode->GetFocus() == this) 
		{
			CGRect scrRect = this->GetScreenRect();
			scrRect.size.width += 4;
			
			DrawRecttangle(scrRect, ccc4(66, 52, 41, 255));
			DrawLine(ccp(scrRect.origin.x, scrRect.origin.y), 
					 ccp(scrRect.origin.x + scrRect.size.width, scrRect.origin.y), 
					 ccc4(214, 154, 82, 255), 1);
			DrawLine(ccp(scrRect.origin.x, scrRect.origin.y + scrRect.size.height), 
					 ccp(scrRect.origin.x + scrRect.size.width, scrRect.origin.y + scrRect.size.height), 
					 ccc4(214, 154, 82, 255), 1);
		}
	}	
}

ChatRecord* ChatRecord::Copy()
{
	ChatRecord* ret = new ChatRecord();
	
	ret->Initialization();	
	ret->m_chatType = m_chatType;
	ret->m_lblTitle->SetFontColor(m_lblTitle->GetFontColor());
	ret->m_lblTitle->SetText(m_lblTitle->GetText().c_str());
	ret->SetText(m_text.c_str());
	ret->SetFrameRect(this->GetFrameRect());
	
	return ret;
}

/////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ChatTable, NDUITableLayer)

ChatTable::ChatTable()
{
	m_maxRecordCount = 50;
	m_dataSource =  NULL;
	m_section = NULL;
	m_recordCount = 0;
}

ChatTable::~ChatTable()
{
}

void ChatTable::Initialization()
{
	NDUITableLayer::Initialization();	
	this->VisibleSectionTitles(false);
	m_dataSource = new NDDataSource();
	m_section = new NDSection();
	m_section->UseCellHeight(true);
	m_dataSource->AddSection(m_section);
	NDUITableLayer::SetDataSource(m_dataSource);
}

void ChatTable::AddOneRecord(ChatRecord* record, bool bRefresh/*= true*/)
{
	if (m_recordCount >= m_maxRecordCount) 
	{
		RemoveOneRecord();
	}
	m_section->InsertCell(0, record);
	m_recordCount++;
	
	if (bRefresh) {
		this->ReflashData();
	}
}

void ChatTable::RemoveOneRecord()
{
	if (m_recordCount > 0) 
	{
		m_section->RemoveCell(m_recordCount - 1);
		m_recordCount--;
	}
}

void ChatTable::RemoveAllRecord()
{
	while (m_recordCount > 0) 
	{
		RemoveOneRecord();
	}
	this->ReflashData();
}

/////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(ChatRecordManager, NDUIMenuLayer)

#define DIALOG_TAG_PLAYER	1
#define DIALOG_TAG_ORTHER	2
#define DIALOG_TAG_SYSTEM	3

static ChatRecordManager* ChatRecordManager_DefaultManager = NULL;
ChatRecordManager::ChatRecordManager()
{
	NDAsssert(ChatRecordManager_DefaultManager == NULL);
	m_curChatType = ChatTypeWorld;
	m_errMsg = NULL;
	m_timer = new NDTimer();
}

ChatRecordManager::~ChatRecordManager()
{
	ChatRecordManager_DefaultManager = NULL;
	this->ClearPictures();
	this->ClearTitleButtonInfos();
	m_tbAll->RemoveFromParent(true);
	m_tbWorld->RemoveFromParent(true);
	m_tbSection->RemoveFromParent(true);
	m_tbQueue->RemoveFromParent(true);
	m_tbArmy->RemoveFromParent(true);
	m_tbSecret->RemoveFromParent(true);
	m_tbSystem->RemoveFromParent(true);
	delete m_timer;
}

ChatRecordManager* ChatRecordManager::DefaultManager()
{
	if (ChatRecordManager_DefaultManager == NULL) 
	{
		ChatRecordManager_DefaultManager = new ChatRecordManager();
		ChatRecordManager_DefaultManager->Initialization();
	}
	return ChatRecordManager_DefaultManager;
}

void ChatRecordManager::Initialization()
{
	NDScene::Initialization();	
	
	this->CreateMenuLayer();
	
	this->CreateChatTypeBackground();
	
	this->CreateTables();
	
	this->CreatePictures();
	
	this->CreateTitleButtonInfos();
			
	this->CreateButtons();	
	
	this->CreateErrorMessage();
	
	this->ActiveTitleButton(m_btnAll);
	this->ActiveTable(m_tbAll);
	
}

void ChatRecordManager::CreateMenuLayer()
{
	m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->GetCancelBtn()->SetDelegate(this);
	this->AddChild(m_menuLayer);
}

void ChatRecordManager::CreateErrorMessage()
{
	m_errMsg = new NDUILabel();
	m_errMsg->Initialization();
	m_errMsg->SetTextAlignment(LabelTextAlignmentCenter);
	m_errMsg->SetFontSize(18);
	m_errMsg->SetFontColor(ccc4(255, 0, 0, 255));
	m_errMsg->SetFrameRect(CGRectMake(0, 285, 480, 20));
	m_menuLayer->AddChild(m_errMsg);
}

void ChatRecordManager::CreateButtons()
{
	//to do create buttons
	m_btnAll = new NDUIButton();
	m_btnAll->Initialization();	
	m_btnAll->SetTag(TitleButtonTagAll);
	m_btnAll->SetFrameRect(CGRectMake(25, 5, FontWidth, FontHeight));
	m_btnAll->SetDelegate(this);
	m_menuLayer->AddChild(m_btnAll);
	
	m_btnWorld = new NDUIButton();
	m_btnWorld->Initialization();	
	m_btnWorld->SetTag(TitleButtonTagWorld);
	m_btnWorld->SetFrameRect(CGRectMake(25 + FontInteval, 5, FontWidth, FontHeight));
	m_btnWorld->SetDelegate(this);
	m_menuLayer->AddChild(m_btnWorld);
	
	m_btnSection = new NDUIButton();
	m_btnSection->Initialization();	
	m_btnSection->SetTag(TitleButtonTagSection);
	m_btnSection->SetFrameRect(CGRectMake(25 + FontInteval * 2, 5, FontWidth, FontHeight));
	m_btnSection->SetDelegate(this);
	m_menuLayer->AddChild(m_btnSection);
	
	m_btnQueue = new NDUIButton();
	m_btnQueue->Initialization();
	m_btnQueue->SetTag(TitleButtonTagQueue);
	m_btnQueue->SetFrameRect(CGRectMake(25 + FontInteval * 3, 5, FontWidth, FontHeight));
	m_btnQueue->SetDelegate(this);
	m_menuLayer->AddChild(m_btnQueue);
	
	m_btnArmy = new NDUIButton();
	m_btnArmy->Initialization();
	m_btnArmy->SetTag(TitleButtonTagArmy);
	m_btnArmy->SetFrameRect(CGRectMake(25 + FontInteval * 4, 5, FontWidth, FontHeight));
	m_btnArmy->SetDelegate(this);
	m_menuLayer->AddChild(m_btnArmy);
	
	m_btnSecret = new NDUIButton();
	m_btnSecret->Initialization();
	m_btnSecret->SetTag(TitleButtonTagSecret);
	m_btnSecret->SetFrameRect(CGRectMake(25 + FontInteval * 5, 5, FontWidth, FontHeight));
	m_btnSecret->SetDelegate(this);
	m_menuLayer->AddChild(m_btnSecret);
	
	m_btnSystem = new NDUIButton();
	m_btnSystem->Initialization();
	m_btnSystem->SetTag(TitleButtonTagSystem);
	m_btnSystem->SetFrameRect(CGRectMake(25 + FontInteval * 6, 5, FontWidth, FontHeight));
	m_btnSystem->SetDelegate(this);
	m_menuLayer->AddChild(m_btnSystem);
	
	//to do create Chat button
	m_btnChat = new NDUIButton();
	m_btnChat->Initialization();
	m_btnChat->SetFrameRect(CGRectMake(200, 285, 80, 20));
	m_btnChat->SetImage(m_picChatGold);
	m_btnChat->SetTouchDownImage(m_picChatRed);
	m_btnChat->SetDelegate(this);
	m_menuLayer->AddChild(m_btnChat);
	
}

void ChatRecordManager::CreateTables()
{
	m_tbAll = new ChatTable();
	m_tbAll->Initialization();
	m_tbAll->SetDelegate(this);
	m_tbAll->VisibleScrollBar(true);
	m_tbAll->VisibleSectionTitles(false);
	m_tbAll->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbAll->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbAll->SetMaxRecordCount(120);
	
	m_tbWorld = new ChatTable();
	m_tbWorld->Initialization();
	m_tbWorld->SetDelegate(this);
	m_tbWorld->VisibleScrollBar(true);
	m_tbWorld->VisibleSectionTitles(false);
	m_tbWorld->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbWorld->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbWorld->SetMaxRecordCount(60);
	
	m_tbSection = new ChatTable();
	m_tbSection->Initialization();
	m_tbSection->SetDelegate(this);
	m_tbSection->VisibleScrollBar(true);
	m_tbSection->VisibleSectionTitles(false);
	m_tbSection->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSection->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbSection->SetMaxRecordCount(60);
	
	m_tbQueue = new ChatTable();
	m_tbQueue->Initialization();
	m_tbQueue->SetDelegate(this);
	m_tbQueue->VisibleScrollBar(true);
	m_tbQueue->VisibleSectionTitles(false);
	m_tbQueue->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbQueue->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbQueue->SetMaxRecordCount(60);
	
	m_tbArmy = new ChatTable();
	m_tbArmy->Initialization();
	m_tbArmy->SetDelegate(this);
	m_tbArmy->VisibleScrollBar(true);
	m_tbArmy->VisibleSectionTitles(false);
	m_tbArmy->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbArmy->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbArmy->SetMaxRecordCount(60);
	
	m_tbSecret = new ChatTable();
	m_tbSecret->Initialization();
	m_tbSecret->SetDelegate(this);
	m_tbSecret->VisibleScrollBar(true);
	m_tbSecret->VisibleSectionTitles(false);
	m_tbSecret->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSecret->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbSecret->SetMaxRecordCount(60);
	
	m_tbSystem = new ChatTable();
	m_tbSystem->Initialization();
	m_tbSystem->SetDelegate(this);
	m_tbSystem->VisibleScrollBar(true);
	m_tbSystem->VisibleSectionTitles(false);
	m_tbSystem->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tbSystem->SetFrameRect(CGRectMake(1, m_menuLayer->GetTitleHeight(), 478, m_menuLayer->GetTextHeight()));
	m_tbSystem->SetMaxRecordCount(60);
}

void ChatRecordManager::ActiveTable(ChatTable* table)
{	
/* comment cancel by jhzheng(touch事件底层做了新处理,不受此约束了)	
	// modify by jhzheng 2011.7.5
	// comment 
	// 层的添加需遵守　1.确保层没有父结点 2.不要在touch事件中做如下处理:先移除自己再添加自己(这个可以通过代码避免)
	// 以上规则是由于我修改了touch事件的添加/移除集合的调用顺序

#define ActiveTableHelp(var) \
do{ if (var != table && var) var->RemoveFromParent(false); \
	else if (var == table && var) if (!var->GetParent()) m_menuLayer->AddChild(table); \
}while(0)
	
	ActiveTableHelp(m_tbAll);
	ActiveTableHelp(m_tbWorld);
	ActiveTableHelp(m_tbSection);
	ActiveTableHelp(m_tbQueue);
	ActiveTableHelp(m_tbArmy);
	ActiveTableHelp(m_tbSecret);
	ActiveTableHelp(m_tbSystem);

#undef ActiveTableHelp

*/

	 m_tbAll->RemoveFromParent(false);
	 m_tbWorld->RemoveFromParent(false);
	 m_tbSection->RemoveFromParent(false);
	 m_tbQueue->RemoveFromParent(false);
	 m_tbArmy->RemoveFromParent(false);
	 m_tbSecret->RemoveFromParent(false);
	 m_tbSystem->RemoveFromParent(false);
	 
	 m_menuLayer->AddChild(table);
}

void ChatRecordManager::CreatePictures()
{
	//to do create Gold pictures
	m_picAllGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picAllGold->Cut(CGRectMake(300, 40, FontWidth, FontHeight));
	
	m_picWorldGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picWorldGold->Cut(CGRectMake(300, 60, FontWidth, FontHeight));
	
	m_picSectionGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSectionGold->Cut(CGRectMake(300, 80, FontWidth, FontHeight));
	
	m_picQueueGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picQueueGold->Cut(CGRectMake(300, 100, FontWidth, FontHeight));
	
	m_picArmyGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picArmyGold->Cut(CGRectMake(300, 120, FontWidth, FontHeight));
	
	m_picSecretGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSecretGold->Cut(CGRectMake(300, 140, FontWidth, FontHeight));
	
	m_picSystemGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSystemGold->Cut(CGRectMake(300, 160, FontWidth, FontHeight));
	
	//to do create Red pictures
	m_picAllRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picAllRed->Cut(CGRectMake(280, 40, FontWidth, FontHeight));
	
	m_picWorldRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picWorldRed->Cut(CGRectMake(280, 60, FontWidth, FontHeight));
	
	m_picSectionRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSectionRed->Cut(CGRectMake(280, 80, FontWidth, FontHeight));
	
	m_picQueueRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picQueueRed->Cut(CGRectMake(280, 100, FontWidth, FontHeight));
	
	m_picArmyRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picArmyRed->Cut(CGRectMake(280, 120, FontWidth, FontHeight));
	
	m_picSecretRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSecretRed->Cut(CGRectMake(280, 140, FontWidth, FontHeight));
	
	m_picSystemRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picSystemRed->Cut(CGRectMake(280, 160, FontWidth, FontHeight));
	
	//to do create Chat Pictures
	m_picChatGold = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picChatGold->Cut(CGRectMake(0, 0, 80, 20));
	
	m_picChatRed = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picChatRed->Cut(CGRectMake(0, 20, 80, 20));
}

void ChatRecordManager::ClearPictures()
{
	delete m_picAllGold;
	delete m_picWorldGold;
	delete m_picSectionGold;
	delete m_picQueueGold;
	delete m_picArmyGold;
	delete m_picSecretGold;
	delete m_picSystemGold;
	delete m_picAllRed;
	delete m_picWorldRed;
	delete m_picSectionRed;
	delete m_picQueueRed;
	delete m_picArmyRed;
	delete m_picSecretRed;
	delete m_picSystemRed;
	
	delete m_picChatGold;
	delete m_picChatRed;
}

void ChatRecordManager::CreateTitleButtonInfos()
{
	TitleButtonInfo* btnInfoAll = new TitleButtonInfo;
	btnInfoAll->GoldPicture = m_picAllGold;
	btnInfoAll->RedPicture = m_picAllRed;
	btnInfoAll->Tag = TitleButtonTagAll;
	btnInfoAll->table = m_tbAll;
	m_titleButtonInfos.push_back(btnInfoAll);
	
	TitleButtonInfo* btnInfoWorld = new TitleButtonInfo;
	btnInfoWorld->GoldPicture = m_picWorldGold;
	btnInfoWorld->RedPicture = m_picWorldRed;
	btnInfoWorld->Tag = TitleButtonTagWorld;
	btnInfoWorld->table = m_tbWorld;
	m_titleButtonInfos.push_back(btnInfoWorld);
	
	TitleButtonInfo* btnInfoSection = new TitleButtonInfo;
	btnInfoSection->GoldPicture = m_picSectionGold;
	btnInfoSection->RedPicture = m_picSectionRed;
	btnInfoSection->Tag = TitleButtonTagSection;
	btnInfoSection->table = m_tbSection;
	m_titleButtonInfos.push_back(btnInfoSection);
	
	TitleButtonInfo* btnInfoQueue = new TitleButtonInfo;
	btnInfoQueue->GoldPicture = m_picQueueGold;
	btnInfoQueue->RedPicture = m_picQueueRed;
	btnInfoQueue->Tag = TitleButtonTagQueue;
	btnInfoQueue->table = m_tbQueue;
	m_titleButtonInfos.push_back(btnInfoQueue);
	
	TitleButtonInfo* btnInfoArmy = new TitleButtonInfo;
	btnInfoArmy->GoldPicture = m_picArmyGold;
	btnInfoArmy->RedPicture = m_picArmyRed;
	btnInfoArmy->Tag = TitleButtonTagArmy;
	btnInfoArmy->table = m_tbArmy;
	m_titleButtonInfos.push_back(btnInfoArmy);
	
	TitleButtonInfo* btnInfoSecret = new TitleButtonInfo;
	btnInfoSecret->GoldPicture = m_picSecretGold;
	btnInfoSecret->RedPicture = m_picSecretRed;
	btnInfoSecret->Tag = TitleButtonTagSecret;
	btnInfoSecret->table = m_tbSecret;
	m_titleButtonInfos.push_back(btnInfoSecret);
	
	TitleButtonInfo* btnInfoSystem = new TitleButtonInfo;
	btnInfoSystem->GoldPicture = m_picSystemGold;
	btnInfoSystem->RedPicture = m_picSystemRed;
	btnInfoSystem->Tag = TitleButtonTagSystem;
	btnInfoSystem->table = m_tbSystem;
	m_titleButtonInfos.push_back(btnInfoSystem);
}

void ChatRecordManager::CreateChatTypeBackground()
{
	NDUIRecttangle* bkgChatType = new NDUIRecttangle();
	bkgChatType->Initialization();
	bkgChatType->SetColor(ccc4(57, 109, 107, 255));
	bkgChatType->SetFrameRect(CGRectMake(0, m_menuLayer->GetTitleHeight(), 25, m_menuLayer->GetTextHeight()));
	m_menuLayer->AddChild(bkgChatType);
}

void ChatRecordManager::ClearTitleButtonInfos()
{
	std::vector<TitleButtonInfo*>::iterator iter;
	for (iter = m_titleButtonInfos.begin(); iter != m_titleButtonInfos.end();) 
	{
		delete *iter;
		m_titleButtonInfos.erase(iter);
	}
}

void ChatRecordManager::ActiveTitleButton(NDUIButton* btn)
{
	if (ButtonIsTitleButton(btn)) 
	{
		m_btnAll->SetImage(m_picAllGold);
		m_btnWorld->SetImage(m_picWorldGold);
		m_btnSection->SetImage(m_picSectionGold);
		m_btnQueue->SetImage(m_picQueueGold);
		m_btnArmy->SetImage(m_picArmyGold);
		m_btnSecret->SetImage(m_picSecretGold);
		m_btnSystem->SetImage(m_picSystemGold);
		
		TitleButtonInfo* buttonInfo = this->GetTitleButtonInfoWithTag(btn->GetTag());
		if (buttonInfo) 
		{
			btn->SetImage(buttonInfo->RedPicture);
			switch (buttonInfo->Tag) {
				case TitleButtonTagAll:
					m_curChatType = ChatTypeAll;
					break;
				case TitleButtonTagWorld:
					m_curChatType = ChatTypeWorld;
					break;
				case TitleButtonTagSection:
					m_curChatType = ChatTypeSection;
					break;
				case TitleButtonTagQueue:
					m_curChatType = ChatTypeQueue;
					break;
				case TitleButtonTagArmy:
					m_curChatType = ChatTypeArmy;
					break;
				case TitleButtonTagSecret:
					m_curChatType = ChatTypeSecret;
					break;
				case TitleButtonTagSystem:
					m_curChatType = ChatTypeSystem;
					break;
				default:
					break;
			}
		}		
	}	
}

bool ChatRecordManager::ButtonIsTitleButton(NDUIButton* btn)
{
	int btnTag = btn->GetTag();
	if (btnTag == TitleButtonTagAll || btnTag == TitleButtonTagWorld ||
		btnTag == TitleButtonTagSection || btnTag == TitleButtonTagQueue ||
		btnTag == TitleButtonTagArmy ||	btnTag == TitleButtonTagSecret ||
		btnTag == TitleButtonTagSystem) 
	{
		return true;
	}
	return false;
}

TitleButtonInfo* ChatRecordManager::GetTitleButtonInfoWithTag(int tag)
{
	std::vector<TitleButtonInfo*>::iterator iter;
	for (iter = m_titleButtonInfos.begin(); iter != m_titleButtonInfos.end(); iter++) 
	{
		TitleButtonInfo* buttonInfo = (TitleButtonInfo*)*iter;
		if (buttonInfo->Tag == tag) 
		{
			return buttonInfo;
		}
	}
	return NULL;
}

void ChatRecordManager::Show()
{
//	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
//	if (scene) 
//	{
//		if (this->GetParent()) 
//		{
//			this->RemoveFromParent(false);
//		}
//		scene->AddChild(this, CHAT_RECORD_MANAGER_Z);
//	}
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
	{
		NDDirector::DefaultDirector()->PushScene(ChatRecordManager::DefaultManager());
	}	
}

void ChatRecordManager::Close()
{
//	this->RemoveFromParent(true);
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void ChatRecordManager::Hide()
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
	{
		NDDirector::DefaultDirector()->PopScene(false);
	}
}

void ChatRecordManager::AddMessage(ChatType type, const char* msg)
{
	ChatRecord* record = new ChatRecord();
	record->Initialization();
	record->SetChatType(type);
	record->SetFrameRect(CGRectMake(0, 0, 450, NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(msg, 450, 15)));
	record->SetTextFontColor(GetColorWithChatType(type));
	record->SetText(msg);
	switch (type) {
		case ChatTypeAll:
			m_tbAll->AddOneRecord(record);
			break;
		case ChatTypeTip:
			m_tbAll->AddOneRecord(record);
			break;
		case ChatTypeImportant:
			m_tbAll->AddOneRecord(record);
			break;
		case ChatTypeWorld:	
			record->SetTitle(NDCString("si"));
			m_tbWorld->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			break;
		case ChatTypeSection:
			record->SetTitle(NDCString("qu"));
			m_tbSection->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			break;
		case ChatTypeQueue:
			record->SetTitle(NDCString("dui"));
			m_tbQueue->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			break;
		case ChatTypeArmy:
			record->SetTitle(NDCString("jun"));
			m_tbArmy->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			break;
		case ChatTypeSecret:
			record->SetTitle(NDCString("mi"));
			m_tbSecret->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			{
				RequsetInfo info;
				info.set(0, NDCommonCString("YouHaveNewChat"), RequsetInfo::ACTION_NEWCHAT);
				NDMapMgrObj.addRequst(info);
			}
			break;
		case ChatTypeSystem:
			record->SetTitle(NDCString("xi"));
			m_tbSystem->AddOneRecord(record);
			m_tbAll->AddOneRecord(record->Copy());
			break;
		default:
			break;
	}
}

void ChatRecordManager::SetErrorMessage(const char* msg)
{
	if (m_errMsg) 
	{
		m_errMsg->SetText(msg);
	}	
	
	m_timer->SetTimer(this, 1, 5);
}

void ChatRecordManager::OnTimer(OBJID tag)
{
	if (m_errMsg) 
	{
		m_errMsg->SetText("");
	}
	m_timer->KillTimer(this, 1);
}

void ChatRecordManager::OnButtonClick(NDUIButton* button)
{
	if (button == m_menuLayer->GetCancelBtn()) 
	{
		Hide();
	}	
	else if (button == m_btnChat)
	{
		PublicChatInput::DefaultInput()->SetActiveChatType(m_curChatType);
		PublicChatInput::DefaultInput()->Show();		
	}
	else if (ButtonIsTitleButton(button)) 
	{
		this->ActiveTitleButton(button);
		TitleButtonInfo* btnInfo = this->GetTitleButtonInfoWithTag(button->GetTag());
		this->ActiveTable(btnInfo->table);
	}	
	else 
	{
		
	}	
}

void ChatRecordManager::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	ChatRecord* record = (ChatRecord*)cell;
	std::string recordText = record->GetText();	
	
	char sender[1024] = { 0x00 };
	char text[2048] = { 0x00 };
	
	int pos = recordText.find(':', 0);
	
	if (pos == -1) 
	{
		strcpy(sender, NDCommonCString("system"));
		strcpy(text, recordText.c_str());
	}
	else if (record->GetChatType() == ChatTypeSecret)
	{
		/*int prefixLen = strlen("【To】");
		int prefixPos = recordText.find("【To】", 0);
		if (prefixPos == -1) 
		{
			prefixLen = strlen("【From】");
			prefixPos = recordText.find("【From】", 0);
		}
		
		if (prefixPos > -1) 
		{
			memcpy(sender, &recordText.c_str()[prefixLen], pos - prefixLen);
			memcpy(text, &recordText.c_str()[pos + 1], recordText.size() - pos - 1);
		}		*/
	}
	else 
	{
		memcpy(sender, recordText.c_str(), pos);
		memcpy(text, &recordText.c_str()[pos + 1], recordText.size() - pos - 1);
	}
	NDUIDialog* dlg = new NDUIDialog();		
	dlg->Initialization();
	dlg->SetDelegate(this);
	
	//系统
	if (record->GetChatType() == ChatTypeSystem || record->GetChatType() == ChatTypeTip || record->GetChatType() == ChatTypeImportant) 
	{
		dlg->SetTag(DIALOG_TAG_SYSTEM);
		dlg->Show(sender, text, NDCommonCString("return"), NDCommonCString("SendMsg"), NDCommonCString("ChatSet"), NULL);
	}
	//玩家自己
	else if (strcmp(sender, NDPlayer::defaultHero().m_name.c_str()) == 0)
	{
		dlg->SetTag(DIALOG_TAG_PLAYER);
		dlg->Show(sender, text, NDCommonCString("return"), NDCommonCString("SendMsg"), NDCommonCString("ChatSet"), NDCommonCString("CopyName"), NULL);
	}
	//其他玩家
	else 
	{
		dlg->SetTag(DIALOG_TAG_ORTHER);
		dlg->Show(sender, text, NDCommonCString("return"), NDCommonCString("SendMsg"), NDCommonCString("PrivateChat"), NDCommonCString("JiaWeiFriend"), NDCommonCString("InviteTeam"), NDCommonCString("ChatSet"), NDCommonCString("CopyName"), NULL);
	}
}

void ChatRecordManager::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	switch (dialog->GetTag()) 
	{
		case DIALOG_TAG_SYSTEM:
			if (buttonIndex == 0) 
				PublicChatInput::DefaultInput()->Show();
			else if (buttonIndex == 1)
				NDDirector::DefaultDirector()->PushScene(GameSettingScene::Scene());
			break;
		case DIALOG_TAG_PLAYER:
			if (buttonIndex == 0) 
				PublicChatInput::DefaultInput()->Show();
			else if (buttonIndex == 1)
				NDDirector::DefaultDirector()->PushScene(GameSettingScene::Scene());
			else if (buttonIndex == 2)
				CopyDataToCopyCache(dialog->GetTitle().c_str());
			break;
		case DIALOG_TAG_ORTHER:
			if (buttonIndex == 0)
			{
				PublicChatInput::DefaultInput()->Show();
			}
			else if (buttonIndex == 1)
			{
				PrivateChatInput::DefaultInput()->SetLinkMan(dialog->GetTitle().c_str());
				PrivateChatInput::DefaultInput()->Show();
			}
			else if (buttonIndex == 2)
			{
				std::string friendName = dialog->GetTitle();
				sendAddFriend(friendName);
			}
			else if (buttonIndex == 3)
			{				
				NDManualRole *role = NDMapMgrObj.GetManualRole(dialog->GetTitle().c_str());
				if (role && !role->bClear) 
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_INVITE << NDPlayer::defaultHero().m_id
					<< role->m_id;
					SEND_DATA(bao);
				}
				
			}
			else if (buttonIndex == 4)
			{
				NDDirector::DefaultDirector()->PushScene(GameSettingScene::Scene());
			}
			else if (buttonIndex == 5)
			{
				CopyDataToCopyCache(dialog->GetTitle().c_str());
			}
			break;
		default:
			break;
	}
	dialog->Close();
}




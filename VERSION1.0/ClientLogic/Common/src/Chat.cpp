//
//  Chat.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Chat.h"
#include "ChatRecordManager.h"
#include "NDConstant.h"
#include "cpLog.h"
#include "BattleMgr.h"
#include "NewChatScene.h"
#include "define.h"
#include "NDUISynLayer.h"

#define TextControl_Height 20

ccColor4B GetColorWithChatType(ChatType type)
{
	ccColor4B color;
	switch (type) 
	{
		case ChatTypeAll:
			color = INTCOLORTOCCC4(0xff0000);
			break;
		case ChatTypeTip:
			color = INTCOLORTOCCC4(0xff0000);
			break;
		case ChatTypeImportant:
			color = INTCOLORTOCCC4(0xff0000);
			break;
		case ChatTypeWorld:
			color = INTCOLORTOCCC4(0xcdcb36);
			break;
		case ChatTypeSection:
			color = INTCOLORTOCCC4(0xff934b);
			break;
		case ChatTypeQueue:
			color = INTCOLORTOCCC4(0x41c0d7);
			break;
		case ChatTypeArmy:
			color = INTCOLORTOCCC4(0x78cd2d);
			break;
		case ChatTypeSecret:
			color = INTCOLORTOCCC4(0xcd25cb);
			break;
		case ChatTypeSystem:
			color = INTCOLORTOCCC4(0xff1300);
			break;
		default:
			break;
	}
	return color;
}

ChatType GetChatTypeFromChannel(int channel)
{
	ChatType type = ChatTypeWorld;
	switch (channel) {
		case 19:
			type = ChatTypeSection;
			break;
		case 21:
			type = ChatTypeImportant;
			break;
		case 20:
			type = ChatTypeTip;
			break;
		case 14:
			type = ChatTypeWorld;
			break;
		case 9:
			type = ChatTypeSection;
			break;
		case 5:
			type = ChatTypeSystem;
			break;
		case 3:
			type = ChatTypeQueue;
			break;
		case 4:
			type = ChatTypeArmy;
			break;
		case 1:
			type = ChatTypeSecret;
			break;
		default:
			break;
	}
	return type;
}

int GetChannelFromChatType(ChatType type)
{
	int channel = 14;
	switch (type) 
	{
		case ChatTypeImportant:
			channel = 21;
			break;
		case ChatTypeTip:
			channel = 20;
			break;
		case ChatTypeWorld:
			channel = 14;
			break;
		case ChatTypeSection:
			channel = 9;
			break;
		case ChatTypeSystem:
			channel = 5;
			break;
		case ChatTypeQueue:
			channel = 3;
			break;
		case ChatTypeArmy:
			channel = 4;
			break;
		case ChatTypeSecret:
			channel = 1;
			break;
		default:
			break;
	}
	return channel;
}


////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(TextControl, NDUILayer)
TextControl::TextControl()
{
	m_textUI = NULL;
	m_color = ccc4(0, 0, 0, 255);
	m_timer = new NDTimer();
}

TextControl::~TextControl()
{
	delete m_timer;
}

void TextControl::Initialization(unsigned int displaySecond)
{
	NDUILayer::Initialization();
	
	this->SetTouchEnabled(false);
	this->SetBackgroundColor(ccc4(0, 0, 0, 100));
	m_timer->SetTimer(this, 1, displaySecond);
}

void TextControl::SetText(const char* text)
{
	if (text) 
	{
		m_text = text;
	}
	else 
	{
		m_text = "";
	}	
}

void TextControl::SetFontColor(ccColor4B color)
{
	m_color = color;
}

void TextControl::OnFrameRectChange(CGRect srcRect, CGRect dstRect)
{
	if (srcRect.size.width != dstRect.size.width || srcRect.size.height != dstRect.size.height) 
	{
		if (m_textUI) 
		{
			if (m_textUI->GetParent())
				m_textUI->RemoveFromParent(true);
			else 
				delete m_textUI;
		}
		
		m_textUI = NDUITextBuilder::DefaultBuilder()->Build(m_text.c_str(), 15, CGSizeMake(dstRect.size.width, dstRect.size.height), m_color);
		m_textUI->SetFrameRect(CGRectMake(0, -20, dstRect.size.width, dstRect.size.height));
		this->AddChild(m_textUI);
	}
}

void TextControl::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);
	
	if (tag != 1) return;
	
	if (this->GetParent()) 
	{
		if (this->GetDelegate()->IsKindOfClass(RUNTIME_CLASS(Chat))) 
		{
			Chat* chat = (Chat*)this->GetDelegate();
			chat->DeleteOneNormalText();
		}
		else 
		{
			this->RemoveFromParent(true);
		}		
	}
}


/////////////////////////////////////
IMPLEMENT_CLASS(Chat, NDObject)

#define TIMER_TAG_NORMAL_INFOMATION		0
#define TIMER_TAG_IMPORTANT_INFOMATION	1
#define TIMER_TAG_TIP_INFOMATION		2

static Chat* Chat_DefaultChar = NULL;

Chat::Chat()
{
	NDAsssert(Chat_DefaultChar == NULL);
	
	m_recordCount = 2;
	m_appearSecond = 5;
	
	m_importantScrollText = NULL;
	m_tipScrollText = NULL;
	
	m_timer = new NDTimer();	
	//m_timer->SetTimer(this, TIMER_TAG_NORMAL_INFOMATION, 5);
	m_timer->SetTimer(this, TIMER_TAG_IMPORTANT_INFOMATION, 30);
	m_timer->SetTimer(this, TIMER_TAG_TIP_INFOMATION, 30);
	
	NDDirector::DefaultDirector()->AddDelegate(this);
}

Chat::~Chat()
{
	Chat_DefaultChar = NULL;
	//m_timer->KillTimer(this, TIMER_TAG_NORMAL_INFOMATION);
	m_timer->KillTimer(this, TIMER_TAG_IMPORTANT_INFOMATION);
	m_timer->KillTimer(this, TIMER_TAG_TIP_INFOMATION);
	NDDirector::DefaultDirector()->RemoveDelegate(this);
	while (m_textControls.size() > 0) 
	{
		this->DeleteOneNormalText();
	}
}

Chat* Chat::DefaultChat()
{
	if (Chat_DefaultChar == NULL) 
	{
		Chat_DefaultChar = new Chat();
	}
	return Chat_DefaultChar;
}

void Chat::Release()
{
	if (Chat_DefaultChar != NULL) 
	{
		delete Chat_DefaultChar;
        Chat_DefaultChar = NULL;
	}
}
void Chat::SetRecordCount(unsigned int count)
{
	m_recordCount = count;
}

void Chat::SetAppearTime(float second)
{
	m_appearSecond = second;
}

void Chat::AddMessage(ChatType type, const char* message, const char* speaker/*=true*/, bool bRecord/*=true*/)
{	
	//cpLog(LOG_DEBUG, "chat message:%s", message);
	if (message && message != std::string("")) 
	{
		if (type == ChatTypeTip) 
		{
//			if (m_tipScrollText) 
//			{
//				m_tipMessages.push_back(MessageStruct(type, std::string(message)));
//			}
//			else 
//			{
			if (m_tipScrollText) 
			{
				this->DeleteScrollText(m_tipScrollText);
				m_tipScrollText = NULL;				
			}				
			m_tipScrollText = this->CreateScrollText(type, message);
			m_timer->SetTimer(this, TIMER_TAG_TIP_INFOMATION, 30);
//			}
		}
		else if (type == ChatTypeImportant)
		{
//			if (m_importantScrollText) 
//			{
//				m_importantMessages.push_back(MessageStruct(type, std::string(message)));
//			}
//			else 
//			{
			if (m_importantScrollText) 
			{
				this->DeleteScrollText(m_importantScrollText);
				m_importantScrollText = NULL;
			}
			m_importantScrollText = this->CreateScrollText(type, message);
			m_timer->SetTimer(this, TIMER_TAG_IMPORTANT_INFOMATION, 30);
//			}
		}
		else 
		{
			if (m_textControls.size() >= m_recordCount)
			{
				this->DeleteOneNormalText();
			}
            printf("msg:%s",message);
			this->CreateOneNormalText(type, message, speaker);
			this->ReflashNormalData();
		}		
		
		if (bRecord) {
			//ChatRecordManager::DefaultManager()->AddMessage(type, message);
			NewChatScene::DefaultManager()->AddMessage(type, message, speaker);
		}
	}	
}

void Chat::CreateOneNormalText(ChatType type, const char* text, const char* speaker)
{
	string msg;
	if (speaker) {
		msg = "【";
		msg += speaker;
		msg += "】:";
	}
	msg += text;
	TextControl* textControl = new TextControl();
	textControl->Initialization(m_appearSecond);
	textControl->SetDelegate(this);
	textControl->SetText(msg.c_str());
	textControl->SetFontColor(GetColorWithChatType(type));
    //textControl->SetFrameRect(CGRectMake(0,20,300 ,30));
    
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && !scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
	{
        CloseProgressBar; 
		scene->AddChild(textControl, CHAT_Z);
	}
	
	m_textControls.push_back(textControl);
}

void Chat::DeleteOneNormalText()
{
	if (m_textControls.size() > 0) 
	{
		TextControl* textControl = m_textControls.front();
		if (textControl->GetParent()) 
			textControl->RemoveFromParent(true);
		else 
			delete textControl;
		m_textControls.pop_front();
	}
}

void Chat::ReflashNormalData()
{
	if (m_recordCount > 0) 
	{	
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		
		int i = m_textControls.size();
		std::deque<TextControl*>::iterator iter;
		bool bInBattle = BattleMgrObj.GetBattle() != NULL;
		for (iter = m_textControls.begin(); iter != m_textControls.end(); iter++, i--) 
		{			
			TextControl* textControl = (TextControl*)*iter;
			
			CGFloat y = 0.0f;
			if (bInBattle) {
				y = 26 + i * TextControl_Height;
			} else {
				y = winSize.height - i * TextControl_Height;
			}

			textControl->SetFrameRect(CGRectMake(0, y, winSize.width, TextControl_Height - 1));
		}
	}
}

NDUIScrollText* Chat::CreateScrollText(ChatType type, const char* text)
{
	NDUIScrollText* scrollText = NULL;
	if (type == ChatTypeTip || type == ChatTypeImportant) 
	{
		scrollText = new NDUIScrollText();
		scrollText->Initialization();
		scrollText->SetTouchEnabled(false);
		scrollText->SetBackgroundColor(ccc4(0, 0, 0, 100));
		scrollText->SetScrollTextSpeed(60);
		scrollText->SetText(text);
		scrollText->SetFontColor(GetColorWithChatType(type));
		if (type == ChatTypeTip) 
		{
			scrollText->SetFrameRect(CGRectMake(0, 100, 480, TextControl_Height));
		}
		else 
		{
			scrollText->SetFrameRect(CGRectMake(0, 200, 480, TextControl_Height));
		}
		
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && !scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
		{
			scene->AddChild(scrollText, CHAT_Z);
		}
	}	
	return scrollText;
}

void Chat::DeleteScrollText(NDUIScrollText* scrollText)
{
	if (scrollText) 
	{
		if (scrollText->GetParent()) 
		{
			scrollText->RemoveFromParent(true);
		}
		else 
			delete scrollText;
	}
}

void Chat::OnTimer(OBJID tag)
{
//	if (tag == TIMER_TAG_NORMAL_INFOMATION) 
//	{
//		if (m_normalMessages.size() > 0) 
//		{
//			MessageStruct msg = m_normalMessages.front();
//			
//			if (m_recordCount <= m_textControls.size()) 
//				this->DeleteOneNormalText();
//			this->CreateOneNormalText(msg.chatType, msg.message.c_str());		
//			this->ReflashNormalData();
//			
//			m_normalMessages.pop_front();
//		}
//		else 
//		{
//			this->DeleteOneNormalText();
//			this->ReflashNormalData();
//		}
//	}
	if (tag == TIMER_TAG_TIP_INFOMATION)
	{
//		if (m_tipMessages.size() > 0) 
//		{
//			MessageStruct msg = m_tipMessages.front();				
//			if (m_tipScrollText) 				
//				m_tipScrollText->SetText(msg.message.c_str());				
//			else 
//				m_tipScrollText = this->CreateScrollText(msg.chatType, msg.message.c_str());
//			m_tipMessages.pop_front();
//		}
//		else 
//		{
			this->DeleteScrollText(m_tipScrollText);
			m_tipScrollText = NULL;
			m_timer->KillTimer(this, TIMER_TAG_TIP_INFOMATION);
//		}
	}
	else if (tag == TIMER_TAG_IMPORTANT_INFOMATION)
	{
//		if (m_importantMessages.size() > 0) 
//		{
//			MessageStruct msg = m_importantMessages.front();				
//			if (m_importantScrollText) 				
//				m_importantScrollText->SetText(msg.message.c_str());				
//			else 
//				m_importantScrollText = this->CreateScrollText(msg.chatType, msg.message.c_str());
//			m_importantMessages.pop_front();
//		}
//		else 
//		{
			this->DeleteScrollText(m_importantScrollText);
			m_importantScrollText = NULL;
			m_timer->KillTimer(this, TIMER_TAG_IMPORTANT_INFOMATION);
//		}
	}
	
}

void Chat::BeforeDirectorPopScene(NDDirector* director, NDScene* scene, bool cleanScene)
{
	this->RemoveControlsFromScene();
}

void Chat::AfterDirectorPopScene(NDDirector* director, bool cleanScene)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene) 
	{
		if (!scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
		{
			this->AddControlsToScene(scene);
		}		
	}	
}

void Chat::AfterDirectorPushScene(NDDirector* director, NDScene* scene)
{	
	if (!scene->IsKindOfClass(RUNTIME_CLASS(ChatRecordManager))) 
	{
		this->AddControlsToScene(scene);
	}
}

void Chat::AddControlsToScene(NDScene* scene)
{
	std::deque<TextControl*>::iterator iter;
	for (iter = m_textControls.begin(); iter != m_textControls.end(); iter++) 
	{			
		TextControl* textControl = (TextControl*)*iter;
		if (textControl->GetParent()) 
			textControl->RemoveFromParent(false);
		scene->AddChild(textControl, CHAT_Z);
	}
	
	if (m_tipScrollText) 
	{
		if (m_tipScrollText->GetParent()) 
		{
			m_tipScrollText->RemoveFromParent(false);
		}		
		scene->AddChild(m_tipScrollText, CHAT_Z);
	}
	
	if (m_importantScrollText) 
	{
		if (m_importantScrollText->GetParent()) 
		{
			m_importantScrollText->RemoveFromParent(false);
		}
		scene->AddChild(m_importantScrollText, CHAT_Z);
	}
}

void Chat::RemoveControlsFromScene()
{
	std::deque<TextControl*>::iterator iter;
	for (iter = m_textControls.begin(); iter != m_textControls.end(); iter++) 
	{			
		TextControl* textControl = (TextControl*)*iter;
		if (textControl->GetParent()) 
			textControl->RemoveFromParent(false);
	}
	
	if (m_tipScrollText && m_tipScrollText->GetParent()) 
	{
		m_tipScrollText->RemoveFromParent(false);
	}
	
	if (m_importantScrollText && m_importantScrollText->GetParent()) 
	{
		m_importantScrollText->RemoveFromParent(false);
	}
}



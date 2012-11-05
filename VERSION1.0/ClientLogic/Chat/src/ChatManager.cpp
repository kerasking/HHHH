/*
 *  ChatManager.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "ChatManager.h"
#include "NDUISynLayer.h"
#include "NDLocalization.h"
#include "NDUtility.h"

using namespace NDEngine;

ChatInfoRecord::ChatInfoRecord()
{
	m_channelType = CHAT_CHANNEL_ALL;
	content_id = 0;
}
ChatInfoRecord::~ChatInfoRecord()
{

}

void ChatInfoRecord::SetSpeaker(std::string speaker)
{
	m_speaker = speaker;
}

void ChatInfoRecord::SetText(std::string text)
{
	m_text = text;
}

std::string ChatInfoRecord::GetSpeaker()
{
	return m_speaker;
}

std::string ChatInfoRecord::GetText()
{
	return m_text;
}

CHAT_CHANNEL_TYPE ChatInfoRecord::GetChatType()
{
	return m_channelType;
}

void ChatInfoRecord::SetChatType(CHAT_CHANNEL_TYPE type)
{
	m_channelType = type;
}

void ChatInfoRecord::SetContentID(int id)
{
	content_id = id;
}

ChatManager::ChatManager()
{
	//NDNetMsgPool& pool = NDNetMsgPoolObj;
	//pool.RegMsg(_MSG_TALK, this);
	maxRecordCount = 100;
	currentRecordCount = 0;
	currentChannel = CHAT_CHANNEL_ALL;
}

ChatManager::~ChatManager()
{

}

bool ChatManager::process(MSGID msgID, NDEngine::NDTransData* bao, int len)
{
	switch (msgID)
	{
	case _MSG_TALK:
		processChatTalk(*bao);
		break;
	default:
		break;
	}
	return true;
}

CHAT_CHANNEL_TYPE ChatManager::GetChatTypeFromChannel(int channel)
{
	CHAT_CHANNEL_TYPE type = CHAT_CHANNEL_WORLD;
	switch (channel)
	{
	case 19:
		type = CHAT_CHANNEL_WORLD;
		break;
	case 21:
		type = CHAT_CHANNEL_WORLD;
		break;
	case 20:
		type = CHAT_CHANNEL_SYS;
		break;
	case 14:
		type = CHAT_CHANNEL_WORLD;
		break;
	case 9:
		type = CHAT_CHANNEL_WORLD;
		break;
	case 5:
		type = CHAT_CHANNEL_SYS;
		break;
	case 3:
		type = CHAT_CHANNEL_WORLD;
		break;
	case 4:
		type = CHAT_CHANNEL_FACTION;
		break;
	case 1:
		type = CHAT_CHANNEL_PRIVATE;
		break;
	default:
		break;
	}
	return type;
}

void ChatManager::processChatTalk(NDEngine::NDTransData& data)
{
	unsigned char _ucUnuse = 0;
	data >> _ucUnuse;
	unsigned char pindao = 0;
	data >> pindao;
	int _iUnuse = 0;
	data >> _iUnuse;
	data >> _ucUnuse;
	unsigned char amount = 0;
	data >> amount;
	// msg.append("字段数" + amount);
	std::string speaker;
	std::string text;
	for (int i = 0; i < amount; i++)
	{
		std::string c = data.ReadUnicodeString(); //data.ReadUnicodeString2(false);			
		if (i == 0)
		{
			text = c;
		}
		else if (i == 1)
		{
			speaker = c;
		}
		// msg.append("内容" + c);

	}
//	showDialog("聊天回复", msg.toString());

	CloseProgressBar;

	if (speaker.empty())
	{ // 字段数为0，导致没有Speaker，不处理
		return;
	}

//	if (NewChatScene::DefaultManager()->IsFilterBySpeaker(speaker.c_str())) {
//		return;
//	}

	//std::stringstream ss;
	if (speaker == "SYSTEM")
	{
		speaker = NDCommonCString("system");
	}
	//std::string msg = ss.str();

	CHAT_CHANNEL_TYPE chatType = GetChatTypeFromChannel(pindao);

//	if (chatType == ChatTypeSecret) 
//	{
//		//speaker.insert(0, "【From】");
//		std::string text(speaker);
//		if (text != (NDPlayer::defaultHero().m_name)) 
//		{
//			RequsetInfo info;
//			info.set(0, NDCommonCString("YouHaveNewChat"), RequsetInfo::ACTION_NEWCHAT);
//			NDMapMgrObj.addRequst(info);
//		}
//		
//	}
	AddChatInfoRecord(speaker.c_str(), text.c_str(), 0, chatType);
}

void ChatManager::AddChatInfoRecord(std::string speaker, std::string text,
		int content_id, CHAT_CHANNEL_TYPE type)
{
	if (currentRecordCount >= maxRecordCount)
	{
		VEC_CHAT_RECORD_IT iter = m_records.begin();
		ChatInfoRecord* record = (ChatInfoRecord*) *iter;
		if (record)
		{
			delete record;
		}
		m_records.erase(iter);
		currentRecordCount--;
	}
	ChatInfoRecord* record = new ChatInfoRecord;
	record->SetSpeaker(speaker);
	record->SetText(text);
	record->SetChatType(type);
	record->SetContentID(content_id);
	m_records.push_back(record);
	currentRecordCount++;
	if (currentChannel == CHAT_CHANNEL_ALL || type == currentChannel)
	{
		//	ScriptMgrObj.excuteLuaFunc<bool>("AddChatText","ChatMainUI",content_id,speaker,text);
	}
}

void ChatManager::AddAllRecord()
{
	VEC_CHAT_RECORD_IT iter = m_records.begin();

	for (; iter != m_records.end(); iter++)
	{
		ChatInfoRecord* record = (ChatInfoRecord*) *iter;
		if (record)
		{
			if (currentChannel == CHAT_CHANNEL_ALL
					|| record->GetChatType() == currentChannel)
			{
				//	ScriptMgrObj.excuteLuaFunc<bool>("AddChatText","ChatMainUI",record->GetContentID(),record->GetSpeaker(),record->GetText());
			}
		}
	}
}
void ChatManager::SetMaxRecoudCount(int maxCount)
{
	maxRecordCount = maxCount;
}
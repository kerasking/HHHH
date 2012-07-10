/*
 *  chatManager.h
 *  DragonDrive
 *
 *  Created by cl on 12-4-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __CHAT_MGR_H__
#define __CHAT_MGR_H__

#include "Singleton.h"
#include "define.h"
#include "EnumDef.h"
#include "NDNetMsg.h"
#include "NDTransData.h"
#include "UIChatText.h"

using namespace NDEngine;

#define ChatManagerObj ChatManager::GetSingleton()


//µ¥Ìõ¼ÇÂ¼
class ChatInfoRecord
{
	
public:
	ChatInfoRecord();
	~ChatInfoRecord();


	void SetSpeaker(std::string speaker);
	void SetText(std::string text);
	void SetContentID(int id);
	int	 GetContentID(){return content_id;}
	std::string GetText();
	string GetSpeaker();
	ChatInfoRecord* Copy();
	void SetChatType(CHAT_CHANNEL_TYPE type);
	CHAT_CHANNEL_TYPE GetChatType();
private:
	int content_id;
	std::string m_text;
	std::string m_speaker;
	CHAT_CHANNEL_TYPE m_channelType;
};

typedef vector<ChatInfoRecord*> VEC_CHAT_RECORD;
typedef VEC_CHAT_RECORD::iterator VEC_CHAT_RECORD_IT;

class ChatManager : public TSingleton<ChatManager>, public NDMsgObject
{
public:
	ChatManager();
	~ChatManager();
	virtual bool process(MSGID msgID, NDEngine::NDTransData* bao, int len);
	void AddChatInfoRecord(std::string speaker,std::string text,int content_id,CHAT_CHANNEL_TYPE type);
	void AddAllRecord();
	void SetCurrentChannel(CHAT_CHANNEL_TYPE channel){currentChannel=channel;}
	void SetMaxRecoudCount(int maxCount);
	void processChatTalk(NDEngine::NDTransData& bao);

	CHAT_CHANNEL_TYPE GetChatTypeFromChannel(int channel);
private:
	int maxRecordCount;
	int currentRecordCount;
	VEC_CHAT_RECORD m_records;
	CHAT_CHANNEL_TYPE currentChannel;
};

#endif
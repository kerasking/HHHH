//
//  Chat.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __CHAT_H
#define __CHAT_H

#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDUIScrollText.h"
#include <vector>
#include <deque>
#include "NDTimer.h"
#include "NDDirector.h"
#include "NDTextNode.h"

using namespace NDEngine;
using namespace cocos2d;

typedef enum{
	ChatTypeAll,
	ChatTypeTip,
	ChatTypeImportant,
	ChatTypeWorld,
	ChatTypeSection,
	ChatTypeQueue,
	ChatTypeArmy,
	ChatTypeSecret,
	ChatTypeSystem
}ChatType;

/*
 以下三个方法内部调用，外部可无须关心，了解具体使用，可参考该方法被调用的地方
 */
ChatType GetChatTypeFromChannel(int channel);
int GetChannelFromChatType(ChatType type);
ccColor4B GetColorWithChatType(ChatType type);

//聊天信息提示控件
class TextControl : public NDUILayer//, public ITimerCallback
{
	DECLARE_CLASS(TextControl)
	TextControl();
	~TextControl();
public:
	void Initialization(unsigned int displaySecond); hide
	//内容
	void SetText(const char* text);
	//颜色
	void SetFontColor(ccColor4B color);
	
	void OnFrameRectChange(CGRect srcRect, CGRect dstRect); override
	void OnTimer(OBJID tag); override
private:
	NDUIText* m_textUI;
	std::string m_text;
	ccColor4B m_color;
	NDTimer* m_timer;
};

//聊天类型和聊天内容组合的结构体，内部使用
typedef struct MESSAGE_STRUCT{
	ChatType chatType;
	std::string message;
	MESSAGE_STRUCT(ChatType type, std::string msg)
	{
		chatType = type;
		message = msg;
	}
}MessageStruct;

//聊天的功能类，
//单例
class Chat : public NDObject, public ITimerCallback, public NDDirectorDelegate
{
	DECLARE_CLASS(Chat)
	Chat();
	~Chat();
public:
	//单例对象指针
	//static Chat* DefaultChat(); ///< 临时性注释 郭浩
	//设置最多同时显示聊天记录数
	void SetRecordCount(unsigned int count);
	//设置每条记录的显示时长，单位：秒
	void SetAppearTime(float second);
	//如果从服务器接收到一条聊天记录，可调用此接口，剩余的事情内部都帮你处理了，所以外部基本只要使用此接口就可以
	void AddMessage(ChatType type, const char* message, const char* speaker=NULL, bool bRecord=true);
	
	/*
	 以下方法内部调用，外部无须关心
	 */
	void OnTimer(OBJID tag); override
	void BeforeDirectorPopScene(NDDirector* director, NDScene* scene, bool cleanScene); override
	void AfterDirectorPopScene(NDDirector* director, bool cleanScene); override
	void AfterDirectorPushScene(NDDirector* director, NDScene* scene); override
	
	void DeleteOneNormalText();
private:
	unsigned int m_recordCount;
	unsigned int m_appearSecond;
	std::deque<TextControl*> m_textControls;
	std::deque<MessageStruct> m_normalMessages;
	
	NDUIScrollText* m_importantScrollText;
	std::deque<MessageStruct> m_importantMessages;
	
	NDUIScrollText* m_tipScrollText;
	std::deque<MessageStruct> m_tipMessages;
	
	NDTimer* m_timer;
	
	void ReflashNormalData();	
	void CreateOneNormalText(ChatType type, const char* text, const char* speaker);
	
	
	NDUIScrollText* CreateScrollText(ChatType type, const char* text);		
	void DeleteScrollText(NDUIScrollText* scrollText);
	
	void AddControlsToScene(NDScene* scene);
	void RemoveControlsFromScene();
};

#endif

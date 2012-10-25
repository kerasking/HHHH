//
//  ChatInput.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 聊天输入界面相关类 
 */

#ifndef __ChatInput_H
#define __ChatInput_H

#include "NDUICustomView.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "Chat.h"
#include "NDUIButton.h"
#include "GoodFriendUILayer.h"
#include <string>

//基础输入类，从普通聊天和私人聊天抽象出的基础类
class ChatInput : public NDUICustomView, 
	public NDUIButtonDelegate, 
	public GameItemBagDelegate,
	public NDUITableLayerDelegate,
	public NDNodeDelegate
{
	DECLARE_CLASS(ChatInput)
	ChatInput();
	~ChatInput();
	
	void OnBeforeNodeRemoveFromParent(NDNode* node, bool bCleanUp);
public:
	//以下三个方法分别是其他控件的委托，理解作用过程，请参考代码内部实现过程
	void OnButtonClick(NDUIButton* button); override
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
	//		
	//	函数：SendChatDataToServer
	//	作用：发送聊天信息到服务器，让服务器去选择传播该消息
	//	参数：type聊天类型，参考chat.h文件定义， msg过滤后的消息内容,  otherName默认向世界广播，否则必须填写接收对象
	//	返回值：新字符串
	static void SendChatDataToServer(ChatType type, const char* msg, const char* otherName = "word");
	
protected:
//		
//	函数：FilterMessage
//	作用：过滤字符串，将源字符串中格式为：<b%02d(%02d表示两位的整数)  转化为格式：>b%@/%d~(%@表示背包物品名称  %d背包物品id)
//		 用户输入的输入框内容在发送之前都需要经过过滤，保证格式是特殊的规格格式
//	参数：源字符串
//	返回值：新字符串
	std::string FilterMessage(const std::string& msg);
	
//		
//	函数：ShowExpressions
//	作用：显示表情选择界面
//	参数：无
//	返回值：无
	void ShowExpressions();
//		
//	函数：HideExpressions
//	作用：隐藏表情选择界面
//	参数：无
//	返回值：无
	void HideExpressions();
//		
//	函数：OnGetExpression
//	作用：当某一表情被选择后，该虚方法被触发，由派生类处理
//	参数：expressionStr表情字符串， 格式为<f%02d(%02d表示两位的整数)
//	返回值：无
	virtual void OnGetExpression(const char* expressionStr){}
//		
//	函数：ShowItems
//	作用：显示背包物品选择界面
//	参数：无
//	返回值：无	
	void ShowItems();
//		
//	函数：HideItems
//	作用：隐藏背包物品选择界面
//	参数：无
//	返回值：无
	void HideItems();
//		
//	函数：OnGetItem
//	作用：当某一表情被选择后，该虚方法被触发，由派生类处理
//	参数：itemStr背包物品字符串， 格式为<b%02d(%02d表示两位的整数)， 很明显该字符串在发送之前需要被过滤
//	返回值：无
	virtual void OnGetItem(const char* itemStr){}
//		
//	函数：ShowFriends
//	作用：显示好友选择界面
//	参数：无
//	返回值：无
	void ShowFriends();
//		
//	函数：HideFriends
//	作用：隐藏好友选择界面
//	参数：无
//	返回值：无
	void HideFriends();
//		
//	函数：OnGetFriend
//	作用：friendStr好友名字
//	参数：无
//	返回值：无
	virtual void OnGetFriend(const char* friendStr){}
private:
	NDUIMenuLayer* m_expressionLayer;
	NDUIMenuLayer* m_itemLayer;
	GameItemBag* m_itemBag;
	GoodFriendUILayer* m_friendLayer;
};

//普通聊天输入界面,
//单例类，
class PublicChatInput : public ChatInput, public NDUICustomViewDelegate
{
	DECLARE_CLASS(PublicChatInput)
	PublicChatInput();
	~PublicChatInput();
public:
	//单例对象指针
	static PublicChatInput* DefaultInput();
	//设置当前聊天类型，类型可参考chat.h
	void SetActiveChatType(ChatType type);
	//ui框架必须实现方法，外部无需关心
	void Initialization(); override		
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag); override
	void OnCustomViewRadioButtonSelected(NDUICustomView* customView, unsigned int radioButtonIndex, int ortherButtonTag); override	
protected:
	virtual void OnGetExpression(const char* expressionStr);
	virtual void OnGetItem(const char* itemStr);
private:
	ChatType m_curChatType;
	
};

//私人聊天输入界面,
//单例类，
class PrivateChatInput : public ChatInput, public NDUICustomViewDelegate
{
	DECLARE_CLASS(PrivateChatInput)
	PrivateChatInput();
	~PrivateChatInput();
public:
	//单例对象指针
	static PrivateChatInput* DefaultInput();
	//设置当前联系人
	void SetLinkMan(const char* name);
	void Initialization(); override	
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnCustomViewOrtherButtonClick(NDUICustomView* customView, unsigned int ortherButtonIndex, int ortherButtonTag); override	
protected:
	virtual void OnGetExpression(const char* expressionStr);
	virtual void OnGetItem(const char* itemStr);
	virtual void OnGetFriend(const char* friendStr);
};


#endif

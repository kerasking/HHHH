//
//  NDUIChatText.h
//  DragonDrive
//
//  Created by cl on 12-4-20.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDUILayer.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "AutoLink.h"
#include <list>

#define SMALL_CHAT_FONTSIZE	(9)

#define CHAT_FONTSIZE	(9)

enum CHAT_TEXT_STYLE{
	SMALL_STYLE=0,
	NORMAL_STYLE,
};

enum CHAT_CHANNEL_TYPE {
	CHAT_CHANNEL_ALL=0,
	CHAT_CHANNEL_SYS,
	CHAT_CHANNEL_WORLD,
	CHAT_CHANNEL_FACTION,
	CHAT_CHANNEL_PRIVATE,
};

enum ColorTag{
	QUALITY_WHITE= 1,
	QUALITY_GREEN,
	QUALITY_BLUE,
	QUALITY_PURPLE,
	QUALITY_GOLDEN,
};

namespace NDEngine
{

	typedef enum
	{
		ChatNone,			//无规则，默认
		ChatSpeaker,		//发言者
		ChatFace,			//表情规则
		ChatItem,			//物品规则
		ChatColor,			//颜色规则
		ChatRole,			//玩家
	}ChatTextType;

	typedef struct CHAT_NODE
	{
		bool hasBreak;
		NDUINode* uiNode;
		ChatTextType textType;
		int content_id;
		std::string content_str;

		CHAT_NODE(bool brk, NDUINode* node, ChatTextType type,int cid,std::string text)
		{
			hasBreak = brk;
			uiNode = node;
			textType=type;
			content_id=cid;
			content_str=text;
		}
	}ChatNode;


class CUIChatText: public NDUINode
{
	DECLARE_CLASS (CUIChatText)

	CUIChatText();
	~CUIChatText();
private:
	int contentWidth;
	int m_idItem;
	int m_idRole;
	int contentHeight;
	int text_style;
	std::vector<ChatNode> textNodeList;	
	std::string speakerName;
	std::string m_roleName;
public:
	void Initialization(); override
	void SetContentWidth(int width)
	{
		this->contentWidth=width;
	}

	void SetContent_WithNDBitmap(int speakerID, int channel, const char* speaker,
								const char* text, int style, int fontSizelua, ccColor4B color);

	void SetContent(int speakerID, int channel, const char* speaker, 
								const char* text, int style, int fontSizelua, ccColor4B color);

	int GetContentHeight()
	{
		return contentHeight;
	}
	bool OnTextClick(CCPoint touchPos);
protected:
//		bool TouchEnd(NDTouch* touch); override

private:
	NDUILabel* CreateLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem/* = 0*/);
	//解析规则尾部
	bool AnalysisRuleEnd(const char*& text, ChatTextType type);
	//解析规则头部
	bool AnalysisRuleHead(const char*& text, ChatTextType &type, ccColor4B &textColor);

	//获取表情纹理
	NDPicture* CreateFacePicture(unsigned int index);
	//获取表情图片 格式如f00
	NDUIImage* CreateFaceImage(const char* strIndex);	
	void Combiner(std::vector<ChatNode>& textNodeList);
	unsigned char unsignedCharToHex(const char* usChar);
	std::string GetChannelStr(CHAT_CHANNEL_TYPE channel);
	ccColor4B GetColorByTag(int tag);
protected:
	bool CanDestroyOnRemoveAllChildren(NDNode* pNode);override

};
}
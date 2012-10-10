//
//  NDStyledNode.h
//  DragonDrive
//
//  Created by cl on 12-4-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#include "NDUILayer.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "AutoLink.h"
#include <list>
#include "ChatManager.h"

#define CHAT_FONTSIZE	(13)

namespace NDEngine
{
	//节点
	typedef struct CHAT_NODE{
		bool hasBreak;
		bool bItem;
		NDUINode* uiNode;
		CHAT_NODE(bool brk, NDUINode* node, bool bItm = false)
		{
			bItem = bItm;
			hasBreak = brk;
			uiNode = node;
		}
	}ChatNode;
	
	typedef enum
	{
		ChatNone,			//无规则，默认
		ChatRole,			//玩家
		ChatFace,			//表情规则
		ChatItem,			//物品规则
		ChatColor			//颜色规则
	}ChatTextType;
	
	class CUIChatText :
	public NDUINode
	{
		DECLARE_CLASS(CUIChatText)
		
		CUIChatText();
		~CUIChatText();
	private:
		int contentWidth;
		int m_idItem;
		int contentHeight;
	public:
		void Initialization(); override
		void SetContentWidth(int width){this->contentWidth=width;}
		void SetContent(int speakerID,int channel,const char* speaker,const char* text);
		int GetContentHeight(){return contentHeight;}
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
	};
}
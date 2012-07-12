/*
 *  UIChatText.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-4-22.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIChatText.h"
#include "NDLocalization.h"
#include "NDPath.h"

using namespace cocos2d;


IMPLEMENT_CLASS(CUIChatText, NDUINode)

CUIChatText::CUIChatText()
{
}

CUIChatText::~CUIChatText()
{
}

void CUIChatText::Initialization()
{
	NDUINode::Initialization();
	contentHeight=0;
	this->SetDelegate(this);
}

//bool CUIChatText::TouchEnd(NDTouch* touch)
//{
//	bool bRet = NDUINode::TouchEnd(touch);
//	return bRet;
//}



std::string CUIChatText::GetChannelStr(CHAT_CHANNEL_TYPE channel)
{
	switch (channel) {
		case CHAT_CHANNEL_ALL:
			return "";
		case CHAT_CHANNEL_SYS:
			return NDCommonCString("system");
		case CHAT_CHANNEL_WORLD:
			return NDCommonCString("world");
		case CHAT_CHANNEL_FACTION:
			return NDCommonCString("faction");
		case CHAT_CHANNEL_PRIVATE:
			return NDCommonCString("PrivateChat");
		default:
			return "";
	}
}

void CUIChatText::SetContent(int speakerID,int channel,const char* speaker,const char* text)
{
	std::vector<ChatNode> textNodeList;		
	ChatTextType type = ChatNone;
	ccColor4B clr= ccc4(255,255,255,255);
	std::string channel_str=GetChannelStr(CHAT_CHANNEL_TYPE(channel));
	if (!channel_str.empty())
	{
		textNodeList.push_back(ChatNode(false, CreateLabel("[", CHAT_FONTSIZE, ccc4(255,0,0,255),0)));
		textNodeList.push_back(ChatNode(false, CreateLabel(channel_str.c_str(), CHAT_FONTSIZE, ccc4(255,0,0,255),0)));
		textNodeList.push_back(ChatNode(false, CreateLabel("]", CHAT_FONTSIZE, ccc4(255,0,0,255),0)));
	}
	
	if (CHAT_CHANNEL_TYPE(channel)!=CHAT_CHANNEL_SYS)
	{
		textNodeList.push_back(ChatNode(false, CreateLabel(speaker, CHAT_FONTSIZE, ccc4(255,0,0,255),speakerID)));
		textNodeList.push_back(ChatNode(false, CreateLabel(":", CHAT_FONTSIZE, ccc4(255,0,0,255),speakerID)));
	}
	if (!text) 
	{
		return;
	}
	
	bool brk = false;
	
	while (*text != '\0') 
	{				
		
		bool retAnalysis = false;
		
		retAnalysis = AnalysisRuleEnd(text, type);
		if (retAnalysis) 
		{
			if (type == ChatItem) 
			{
				textNodeList.push_back(ChatNode(brk, CreateLabel("]", CHAT_FONTSIZE, clr, m_idItem), true));
			}
			type = ChatNone;
			clr = ccc4(255,255,255,255);
			continue;
		}
		
		retAnalysis = AnalysisRuleHead(text, type, clr);
		if (type == ChatFace) 
		{
			char imgIdx[3] = { 0x00 };
			memcpy(imgIdx, text, 2);
			
			NDUIImage* image = CreateFaceImage(imgIdx);
			if (image) 
			{
				textNodeList.push_back(ChatNode(brk, image));
				brk = false;
				
				text += 2;
				continue;
			}				
		}
		
		if (retAnalysis) 
		{
			if (type == ChatItem) 
			{
				textNodeList.push_back(ChatNode(brk, CreateLabel("[", CHAT_FONTSIZE, clr, m_idItem), true));
			}
			continue;
		}	
		char word[4] = { 0x00 };
		if ((unsigned char)*text < 0x80) 
		{
			memcpy(word, text, 1);
			text++;
		}
		else 
		{
			memcpy(word, text, 3);
			text += 3;
		}
		
		if (type == ChatItem) {
				textNodeList.push_back(ChatNode(brk, CreateLabel(word, CHAT_FONTSIZE, clr, m_idItem), true));
		} else 
		{
				textNodeList.push_back(ChatNode(brk, CreateLabel(word, CHAT_FONTSIZE, clr,0)));
		}
		
		brk = false;
	}
	Combiner(textNodeList);
}

void CUIChatText::Combiner(std::vector<ChatNode>& textNodeList)
{
	
	
	float x = 0.0f, y = 0.0f;
	std::vector<ChatNode>::iterator iter;		
	for (iter = textNodeList.begin(); iter != textNodeList.end(); iter++) 
	{
		ChatNode node = *iter;
		CGRect uiNodeRect = node.uiNode->GetFrameRect();			
		
		
		if(contentHeight==0){
			contentHeight+=uiNodeRect.size.height;
		}
		
		if (node.hasBreak || x + uiNodeRect.size.width > contentWidth) 
		{
			x = 0.0f; 
			y += uiNodeRect.size.height;
			contentHeight+=uiNodeRect.size.height;
				
		}
		
		node.uiNode->SetFrameRect(CGRectMake(x, y, uiNodeRect.size.width, uiNodeRect.size.height));
		AddChild(node.uiNode);
		
		x += uiNodeRect.size.width;			
	}
}

NDPicture* CUIChatText::CreateFacePicture(unsigned int index)
{
	NDPicture* result = NULL;
	if (index < 25) 
	{
		int row = index / 5;
		int col = index % 5;
		result = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("face.png"));	
		result->Cut(CGRectMake(15 * col, 15 * row , 15, 15));
	}
	return result;
}

NDUIImage* CUIChatText::CreateFaceImage(const char* strIndex)
{
	NDUIImage* result = NULL;
	if (strlen(strIndex) >= 2) 
	{
		unsigned int intIndex = atoi(strIndex);
		
		if (intIndex >=0 && intIndex < 25) 
		{
			NDPicture* pic = CreateFacePicture(intIndex);
			result = new NDUIImage();
			result->Initialization();
			result->SetPicture(pic, true);
			result->SetFrameRect(CGRectMake(0, 0, pic->GetSize().width, pic->GetSize().height));
		}			
	}
	return result;
}

NDUILabel* CUIChatText::CreateLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem/* = 0*/)
{
	NDUILabel* result = NULL;
	if (text) 
	{
		CGSize textSize = getStringSize(text, fontSize);
		result = new NDUILabel();
		result->Initialization();
		result->SetRenderTimes(1);
		result->SetText(text);
		result->SetTag(idItem);
		result->SetFontSize(fontSize);
		result->SetFontColor(color);
		result->SetFrameRect(CGRectMake(0, 0, textSize.width, textSize.height));
	}
	return result;
}

unsigned char CUIChatText::unsignedCharToHex(const char* usChar)
{
	if (!usChar || strlen(usChar) < 2) 
	{
		return 0;
	}
	
	unsigned char result = 0;
	
	for (int i = 0; i < 2; i++) 
	{
		if (*usChar <= '9' && *usChar >= '0') 
		{			
			if (0 == i) 
				result += (*usChar - '0') << 4;
			else 
				result += *usChar - '0';
		}
		else if (*usChar <= 'f' && *usChar >= 'a')
		{
			if (0 == i)
				result += (*usChar - 'a' + 10) << 4;
			else 
				result += *usChar - 'a' + 10;
		}
		else if (*usChar <= 'F' && *usChar >= 'A')
		{
			if (0 == i)
				result += (*usChar - 'A' + 10) << 4;
			else 
				result += *usChar - 'A' + 10;
		}
		
		usChar++;
	}
	
	return result;
}


bool CUIChatText::AnalysisRuleEnd(const char*& text, ChatTextType type)
{
	bool result = false;		
	if (type == ChatFace) 
	{
		result = true;
	}	
	else if (*text == '/') 
	{
		if (*(++text) == 'e') 
		{				
			text++;
			result = true;
		}
		else if (type == ChatItem)
		{
			while (*text != '~') 
				text++;				
			text++;
			result = true;				
		}
		else 
			text--;
	}
	return result;
}

bool CUIChatText::AnalysisRuleHead(const char*& text, ChatTextType &type, ccColor4B &textColor)
{
	bool result = false;
	if (*text == '<')
	{
		if (*(++text) == 'c') 
		{
			char rValue[3] = { 0x00 };
			memcpy(rValue, &text[1], 2);
			textColor.r = unsignedCharToHex(rValue);
			
			char gValue[3] = { 0x00 };
			memcpy(gValue, &text[3], 2);
			textColor.g = unsignedCharToHex(gValue);
			
			char bValue[3] = { 0x00 };
			memcpy(bValue, &text[5], 2);
			textColor.b = unsignedCharToHex(bValue);				
			
			type = ChatColor;
			
			text += 7; 
			result = true;
		}
		else if (*text == 'f')
		{			
			type = ChatFace;
			
			text++;
			result = true;
		}
		else if (*text == 'b')
		{		
			type = ChatItem;
			textColor = ccc4(255, 0, 0, 255);
			{
				string str = text;
				int nEnd = str.find_first_of('~');
				str = str.substr(0, nEnd);
				int nStart = str.find_last_of('/');
				str = str.substr(nStart + 1, str.size() - nStart - 1);
				m_idItem = atoi(str.c_str());
			}
			text++;	
			result = true;
		}
		else 
			text--;
	}
	return result;
}
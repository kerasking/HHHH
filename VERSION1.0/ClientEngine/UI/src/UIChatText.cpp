/*
 *  UIChatText.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-4-22.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIChatText.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "NDPath.h"
#include "TQPlatform.h"

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
	speakerName="";
	m_idRole=0;
}


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




//void CUIChatText::SetContent(int speakerID,int channel,const char* speaker,const char* text)

void CUIChatText::SetContent(int speakerID, int channel, const char* speaker, 
							 const char* text, int style, int fontSizelua, ccColor4B color)
{

	this->RemoveAllChildren(true);
	textNodeList.clear();
	this->speakerName=speaker;
	float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
    int fontSize=fontSizelua*fScaleFactor;
	text_style=style;
	
	ChatTextType type = ChatNone;
	ccColor4B clr= color;
	std::string channel_str=GetChannelStr(CHAT_CHANNEL_TYPE(channel));
	if (!channel_str.empty())
	{
       textNodeList.push_back(ChatNode(false, CreateLabel("¡¾", fontSize, clr,0),ChatNone,0,""));
		textNodeList.push_back(ChatNode(false, CreateLabel(channel_str.c_str(), fontSize, clr,0),ChatNone,0,""));
		textNodeList.push_back(ChatNode(false, CreateLabel("¡¿", fontSize, clr,0),ChatNone,0,""));
        
	}
	
	if (CHAT_CHANNEL_TYPE(channel)!=CHAT_CHANNEL_SYS)
	{
		textNodeList.push_back(ChatNode(false, CreateLabel(speaker, fontSize, clr,0),ChatSpeaker,speakerID,""));
		textNodeList.push_back(ChatNode(false, CreateLabel(":", fontSize, clr,0),ChatSpeaker,speakerID,""));
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
				textNodeList.push_back(ChatNode(brk, CreateLabel("]", fontSize, clr, m_idItem), ChatItem,m_idItem,""));
			}
			
			if (type == ChatRole) 
			{
				textNodeList.push_back(ChatNode(brk, CreateLabel("]", fontSize, clr, m_idRole),ChatRole,m_idRole,this->m_roleName));
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
				textNodeList.push_back(ChatNode(brk, image,ChatFace,0,""));
				brk = false;
				
				text += 2;
				continue;
			}				
		}
		
		if (retAnalysis) 
		{
			if (type == ChatItem) 
			{
				textNodeList.push_back(ChatNode(brk, CreateLabel("[", fontSize, clr, m_idItem),ChatItem,m_idItem,""));
			}
			
			if (type == ChatRole) 
			{
				textNodeList.push_back(ChatNode(brk, CreateLabel("[", fontSize, clr, m_idRole),ChatRole,m_idRole,this->m_roleName));
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
				textNodeList.push_back(ChatNode(brk, CreateLabel(word, fontSize,clr, m_idItem),ChatItem,m_idItem,""));
		} else if (type == ChatRole){
				textNodeList.push_back(ChatNode(brk, CreateLabel(word, fontSize,clr, m_idRole),ChatRole,m_idRole,this->m_roleName));
		}else 
		{
				textNodeList.push_back(ChatNode(brk, CreateLabel(word, fontSize, clr,0),ChatNone,0,""));
		}
		
		brk = false;
	}
	Combiner(textNodeList);
}

bool CUIChatText::OnTextClick(CCPoint touchPos)
{
	int index=0;
	bool isfound=false;
	std::vector<NDNode*> vChildren = this->GetChildren();
	for (std::vector<NDNode*>::iterator it = vChildren.begin(); it != vChildren.end(); it++) {
		NDUINode* uinode = dynamic_cast<NDUINode*> (*it);
		if (uinode && IsPointInside(touchPos, uinode->GetScreenRect())) {
			//NDLog(@"click on chat ui node");
			isfound=true;
			break;
		}
		index++;
	}
	if(!isfound){
		return false;
	}
	ChatNode cnode=this->textNodeList.at(index);
	if (cnode.textType==ChatSpeaker){
		//NDLog(@"click on chat speaker:%d",cnode.content_id);
		ScriptMgrObj.excuteLuaFunc<bool>("OnChatNodeClick", "ChatDataFunc",(int)cnode.textType,cnode.content_id,this->speakerName);
	}else if(cnode.textType==ChatItem)
	{
		//NDLog(@"click on chat item:%d",cnode.content_id);
		ScriptMgrObj.excuteLuaFunc<bool>("OnChatNodeClick", "ChatDataFunc",(int)cnode.textType,cnode.content_id,"");
	}else if (cnode.textType==ChatRole)
	{
		//NDLog(@"click on chat Role:%d",cnode.content_id);
		ScriptMgrObj.excuteLuaFunc<bool>("OnChatNodeClick", "ChatDataFunc",(int)cnode.textType,cnode.content_id,cnode.content_str);
	}else{
		//NDLog(@"click nothing");
	}
	return true;
}

void CUIChatText::Combiner(std::vector<ChatNode>& textNodeList)
{
	int nScale = NDDirector::DefaultDirector()->GetScaleFactor();
    
	int height_max=0;
	float x = 0.0f, y = 0.0f;
	std::vector<ChatNode>::iterator iter;
	int current_line=0;
	for (iter = textNodeList.begin(); iter != textNodeList.end(); iter++) 
	{
		ChatNode node = *iter;
		CCRect uiNodeRect = node.uiNode->GetFrameRect();	
		
		if (node.hasBreak || x + uiNodeRect.size.width > contentWidth) 
		{
			std::vector<ChatNode>::iterator line_iter;
			if(iter != textNodeList.begin())
			{
				line_iter = iter - 1;
				ChatNode line_node = *line_iter;
				CCRect beforeRect = line_node.uiNode->GetFrameRect();
				line_node.uiNode->SetFrameRect(CCRectMake(beforeRect.origin.x, beforeRect.origin.y+(height_max-beforeRect.size.height), beforeRect.size.width, beforeRect.size.height));
			}
// 			for (line_iter = textNodeList.begin(); line_iter != iter; line_iter++)
// 			{
// 				ChatNode line_node = *line_iter;
// 				CCRect beforeRect = line_node.uiNode->GetFrameRect();
// 				line_node.uiNode->SetFrameRect(CCRectMake(beforeRect.origin.x, beforeRect.origin.y+(height_max-beforeRect.size.height), beforeRect.size.width, beforeRect.size.height));
// 			}
			
			x = 0.0f; 
			y += height_max;
			contentHeight+=height_max;
			height_max=0;
		}
		
		if (height_max<uiNodeRect.size.height*nScale)
		{
			height_max=uiNodeRect.size.height*nScale;
		}
		//node->line_index=current_line;
        node.uiNode->SetFrameRect(CCRectMake(x, y,uiNodeRect.size.width*nScale, uiNodeRect.size.height*nScale));
		AddChild(node.uiNode);
		
		x += uiNodeRect.size.width*nScale;			
	}
	
	std::vector<ChatNode>::iterator line_iter;
	for (line_iter = textNodeList.begin(); line_iter != textNodeList.end(); line_iter++)
	{
		ChatNode line_node = *line_iter;
		CCRect beforeRect = line_node.uiNode->GetFrameRect();
		line_node.uiNode->SetFrameRect(CCRectMake(beforeRect.origin.x, beforeRect.origin.y+(height_max-beforeRect.size.height), beforeRect.size.width, beforeRect.size.height));
	}
	contentHeight+=height_max;
}

NDPicture* CUIChatText::CreateFacePicture(unsigned int index)
{
	NDPicture* result = NULL;
	if (index < 36) 
	{
		int row = index / 6;
		int col = index % 6;
		result = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("Res00/sm_face.png"));	
		result->Cut(CCRectMake(80 * col, 80 * row , 80, 80));
	}
	return result;
}

NDUIImage* CUIChatText::CreateFaceImage(const char* strIndex)
{
	NDUIImage* result = NULL;
	if (strlen(strIndex) >= 2) 
	{
		unsigned int intIndex = atoi(strIndex);
		
		if (intIndex >=0 && intIndex < 36) 
		{
			NDPicture* pic = CreateFacePicture(intIndex);
			result = new NDUIImage();
			result->Initialization();
			result->SetPicture(pic, true);
			result->SetFrameRect(CCRectMake(0, 0, 30*NDDirector::DefaultDirector()->GetScaleFactor(), 30*NDDirector::DefaultDirector()->GetScaleFactor()));
		}			
	}
	return result;
}

NDUILabel* CUIChatText::CreateLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem/* = 0*/)
{
	NDUILabel* result = NULL;
	if (text) 
	{
		CCSize textSize = getStringSize(text, fontSize);
		result = new NDUILabel();
		result->Initialization();
		result->SetRenderTimes(1);
		result->SetText(text);
		result->SetTag(idItem);
		result->SetFontSize(fontSize);
		result->SetFontColor(color);
		result->SetFrameRect(CCRectMake(0, 0, textSize.width, textSize.height));
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
		else if (type == ChatItem || type == ChatRole)
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
			//textColor = ccc4(255, 0, 0, 255);
			{
				string str = text;
				int nEnd = str.find_first_of('~');
				str = str.substr(0, nEnd);
				int c_index=str.find_first_of('/');
				
				int nStart = str.find_last_of('/');
				int colorTag=atoi(str.substr(c_index+1,1).c_str());
				str = str.substr(nStart + 1, str.size() - nStart - 1);
				m_idItem = atoi(str.c_str());
				textColor=GetColorByTag(colorTag);
			}
			text++;	
			result = true;
		}
		else if (*text == 'p')
		{
			type = ChatRole;
			{
				string str = text;
				int nEnd = str.find_first_of('~');
				str = str.substr(0, nEnd);

				int nStart = str.find_last_of('/');
				this->m_roleName=str.substr(1,nStart-1);
				str = str.substr(nStart + 1, str.size() - nStart - 1);
				m_idRole = atoi(str.c_str());
				textColor=ccc4(255,186,0,255);
			}
			text++;
			result = true;
		}
		else 
			text--;
	}
	return result;
}

ccColor4B CUIChatText::GetColorByTag(int tag)
{
	switch(tag){
		case QUALITY_WHITE:
			return ccc4(255,255,255,255);
		case QUALITY_GREEN:
			return ccc4(0,255,0,255);
		case QUALITY_BLUE:
			return ccc4(0,0,255,255);
		case QUALITY_PURPLE:
			return ccc4(167,87,168,255);
		case QUALITY_GOLDEN:
			return ccc4(255,215,0,255);
		default:
			return ccc4(255,255,255,255);
	}
}

bool CUIChatText::CanDestroyOnRemoveAllChildren(NDNode* pNode)
{
	textNodeList.clear();
	return true;
}

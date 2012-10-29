//
//  NDStyledNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDTextNode.h"
#import "NDUtility.h"
#import "NDPicture.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"
#include "ItemMgr.h"
#include "NDPath.h"
#include "NDDirector.h"
#include "I_Analyst.h"

namespace NDEngine
{	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	IMPLEMENT_CLASS(NDUIText, NDUINode)
	
	#define PAGE_ARROW_SIZE CGSizeMake(60, 15)
	
	NDUIText::NDUIText()
	{
		m_pageCount = 0;
		m_currentPageIndex = 1;
		m_backgroundColor = ccc4(0, 0, 0, 0);
		m_usePageArrowControl = true;
		
		m_colorFont = ccc4(255, 255, 0, 255);
		m_uiFontSize = 0; 
	}
	
	NDUIText::~NDUIText()
	{
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_pages.begin(); iter != m_pages.end(); iter++) 
		{
			NDUINode* uiNode = *iter;
			if (uiNode->GetParent()) 
				uiNode->RemoveFromParent(true);
			else 
				delete uiNode;
		}
	}
	
	void NDUIText::Initialization(bool usePageArrowControl)
	{
		NDUINode::Initialization();
		
		if (usePageArrowControl) 
		{
			m_pageArrow = new NDUIOptionButton();
			m_pageArrow->Initialization();
			m_pageArrow->SetDelegate(this);
			m_pageArrow->SetFontColor(ccc4(24, 85, 82, 255));
			m_pageArrow->SetBgClr(ccc4(0, 0, 0, 0));
			m_pageArrow->ShowFrame(false);
			m_pageArrow->SetFontSize(10);
			m_pageArrow->EnableDraw(false);
			this->AddChild(m_pageArrow, 10);
		}		
		
		m_usePageArrowControl = usePageArrowControl;
	}
	
	void NDUIText::SetBackgroundColor(ccColor4B color)
	{
		m_backgroundColor = color;
	}
	
	unsigned int NDUIText::GetCurrentPageIndex()
	{
		return m_currentPageIndex;
	}
	
	void NDUIText::SetFontSize(unsigned int uiFontSize)
	{
		m_uiFontSize	= uiFontSize;
	}
	
	void NDUIText::SetFontColor(ccColor4B color)
	{
		m_colorFont		= color;
	}
	
	unsigned int NDUIText::GetFontSize()
	{
		return m_uiFontSize;
	}
	
	ccColor4B NDUIText::GetFontColor()
	{
		return m_colorFont;
	}
	
	NDUINode* NDUIText::AddNewPage()
	{
		NDUINode* uiNode = new NDUINode();
		uiNode->Initialization();
		this->AddChild(uiNode);
		m_pages.push_back(uiNode);
		
		m_pageCount++;
		
		if (m_usePageArrowControl) 
		{
			if (m_pageCount > 1) 
			{
				m_pageArrow->EnableDraw(true);
				
				VEC_OPTIONS options;
				for (unsigned int i = 1; i <= m_pageCount; i++) 
				{
					NSString *str = [NSString stringWithFormat:@"%d / %d", i, m_pageCount];
					options.push_back(std::string([str UTF8String]));
				}
				
				m_pageArrow->SetOptions(options);
			}
			else 
				m_pageArrow->EnableDraw(false);
		}		
		
		return uiNode;
	}
	
	void NDUIText::SetFrameRect(CGRect rect)
	{		
		NDUINode::SetFrameRect(rect);
		if (m_usePageArrowControl) 
		{
			m_pageArrow->SetFrameRect(CGRectMake((rect.size.width - PAGE_ARROW_SIZE.width) / 2, 
												 rect.size.height - PAGE_ARROW_SIZE.height, 
												 PAGE_ARROW_SIZE.width, 
												 PAGE_ARROW_SIZE.height));
		}
		
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_pages.begin(); iter != m_pages.end(); iter++) 
		{
			NDUINode* uiNode = *iter;
			uiNode->SetFrameRect(CGRectMake(0, 0, rect.size.width, rect.size.height));
		}
	}
	
	void NDUIText::SetVisible(bool visible)
	{
		NDUINode::SetVisible(visible);
		if (m_usePageArrowControl) 
		{
			m_pageArrow->SetVisible(visible);
		}		
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_pages.begin(); iter != m_pages.end(); iter++) 
		{
			NDUINode* uiNode = *iter;
			uiNode->SetVisible(visible);
		}
	}
	
	void NDUIText::OnOptionChange(NDUIOptionButton* option)
	{
		m_currentPageIndex = option->GetOptionIndex() + 1;
		ActivePage(m_currentPageIndex);
	}
	
	void NDUIText::ActivePage(unsigned int pageIndex)
	{
		if (pageIndex >= 1 && pageIndex <= m_pageCount) 
		{
			std::vector<NDUINode*>::iterator iter;
			for (iter = m_pages.begin(); iter != m_pages.end(); iter++) 
			{
				NDUINode* uiNode = *iter;
				uiNode->RemoveFromParent(false);
			}
			
			this->AddChild(m_pages.at(pageIndex - 1));
		}
	}
	
	bool NDUIText::OnTextClick(CGPoint touchPos)
	{
		if (this->m_currentPageIndex - 1 >= 0 && m_currentPageIndex - 1 < this->m_pages.size()) {
			NDUINode* curPage = m_pages.at(m_currentPageIndex - 1);
			if (curPage) 
			{
				std::vector<NDNode*> vChildren = curPage->GetChildren();
				for (std::vector<NDNode*>::iterator it = vChildren.begin(); it != vChildren.end(); it++) {
					NDUILabel* lbItem = dynamic_cast<NDUILabel*> (*it);
					if (lbItem && lbItem->GetTag() > 0 && IsPointInside(touchPos, lbItem->GetScreenRect())) {
						NDTransData bao(_MSG_ITEM);
						bao << lbItem->GetTag() << Byte(16);
						ItemMgrObj.RemoveOtherItems();
						ShowProgressBar;
						SEND_DATA(bao);
						return true;
					}
				}
			}
		}
		
		if (m_usePageArrowControl) 
		{
			if (m_pageCount > 1) 
			{
				CGRect scrRect = this->GetScreenRect();
				if (touchPos.x < scrRect.origin.x + scrRect.size.width / 2) 
				{
					m_pageArrow->PreOpt();				
				}
				else 
				{
					m_pageArrow->NextOpt();
				}
				
				this->OnOptionChange(m_pageArrow);
			}
		}
		return false;
	}
	
	void NDUIText::draw()
	{
        TICK_ANALYST(ANALYST_NDUIText);	
		NDUINode::draw();
		
		if (this->IsVisibled()) 
		{			
			DrawRecttangle(this->GetScreenRect(), m_backgroundColor);
		}			
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	IMPLEMENT_CLASS(NDUITextBuilder, NDObject)
	
	static NDUITextBuilder* NDUITextBuilder_DefaultBuilder = NULL;
	NDUITextBuilder::NDUITextBuilder()
	{
		NDAsssert(NDUITextBuilder_DefaultBuilder == NULL);
	}
	
	NDUITextBuilder::~NDUITextBuilder()
	{
		NDUITextBuilder_DefaultBuilder = NULL;	
	}
	
	NDUITextBuilder* NDUITextBuilder::DefaultBuilder()
	{
		if (NDUITextBuilder_DefaultBuilder == NULL) 
		{
			NDUITextBuilder_DefaultBuilder = new NDUITextBuilder();
		}
		return NDUITextBuilder_DefaultBuilder;
	}
	
	NDUIText* NDUITextBuilder::Build(const char* text, unsigned int fontSize, CGSize containerSize, ccColor4B defaultColor, bool withPageArrow, bool bHpyerLink)
	{			
		if (!text) 
		{
			return NULL;
		}
		
		std::vector<TextNode> textNodeList;		
		BuildRule rule = BuildRuleNone;
		ccColor4B clr= defaultColor;	
		bool brk = false;
		
		bool bDrawLine	= bHpyerLink;
		while (*text != '\0') 
		{				
			if (*text == '\n') 
			{
				brk = true;
				text++;
				continue;
			}
			
			bool retAnalysis = false;
			
			retAnalysis = AnalysisRuleEnd(text, rule);
			if (retAnalysis && BuildRuleLine == rule && !bHpyerLink)
			{
				bDrawLine = false;
			}
			if (retAnalysis) 
			{
				if (rule == BuildRuleItem) 
				{
					if (bDrawLine)
					{
						textNodeList.push_back(TextNode(brk, CreateLinkLabel("]", fontSize, clr, m_idItem), true));
					}
					else
					{
						textNodeList.push_back(TextNode(brk, CreateLabel("]", fontSize, clr, m_idItem), true));
					}
				}
				rule = BuildRuleNone;
				clr = defaultColor;
				continue;
			}			
			
			retAnalysis = AnalysisRuleHead(text, rule, clr);
			if (retAnalysis && BuildRuleLine == rule && !bHpyerLink)
			{
				bDrawLine = true;
			}
			if (rule == BuildRuleExpression) 
			{
				char imgIdx[3] = { 0x00 };
				memcpy(imgIdx, text, 2);
				
				NDUIImage* image = CreateFaceImage(imgIdx);
				if (image) 
				{
					textNodeList.push_back(TextNode(brk, image));
					brk = false;
					
					text += 2;
					continue;
				}				
			}
			if (retAnalysis) 
			{
				if (rule == BuildRuleItem) 
				{
					if (bDrawLine)
					{
						textNodeList.push_back(TextNode(brk, CreateLinkLabel("[", fontSize, clr, m_idItem), true));
					}
					else
					{
						textNodeList.push_back(TextNode(brk, CreateLabel("[", fontSize, clr, m_idItem), true));
					}
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
			
			if (rule == BuildRuleItem) {
				if (bDrawLine)
				{
					textNodeList.push_back(TextNode(brk, CreateLinkLabel(word, fontSize, clr, m_idItem), true));
				}
				else
				{
					textNodeList.push_back(TextNode(brk, CreateLabel(word, fontSize, clr, m_idItem), true));
				}
			} else 
			{
				if (bDrawLine)
				{
					textNodeList.push_back(TextNode(brk, CreateLinkLabel(word, fontSize, clr)));
				}
				else
				{
					textNodeList.push_back(TextNode(brk, CreateLabel(word, fontSize, clr)));
				}
				
			}

			brk = false;
		}
		
		return Combiner(textNodeList, containerSize, withPageArrow);
	}
	
	unsigned int NDUITextBuilder::StringWidthAfterFilter(const char* text, unsigned int textWidth, unsigned int fontSize)
	{
		float fMaxWidth = 0.0f;
		unsigned int result = 0;
		if (text) 
		{
			unsigned int fontHeight = getStringSize("a", fontSize*NDDirector::DefaultDirector()->GetScaleFactor()).height;
			result += fontHeight;
			unsigned int curWidth = 0;
			BuildRule rule = BuildRuleNone;
			ccColor4B clr= ccc4(0, 0, 0, 255);
			while (*text != '\0') 
			{
				if (*text == '\n') 
				{
					if (fMaxWidth < curWidth) 
						fMaxWidth = curWidth;
					
					result += fontHeight;
					curWidth = 0;
					text++;
				}
				if (AnalysisRuleEnd(text, rule))
				{
					rule = BuildRuleNone;
					continue;
				}
				if (AnalysisRuleHead(text, rule, clr))
					continue;
				if (rule == BuildRuleExpression) 
				{				
					text += 2;
					
					if (curWidth + 15 > textWidth) 
					{
						if (fMaxWidth < curWidth) 
							fMaxWidth = curWidth;
							
						curWidth = 0;
						result += fontHeight;
					}
					curWidth += 15;
					
					if (fMaxWidth < curWidth) 
						fMaxWidth = curWidth;
						
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
				unsigned int temp = getStringSize(word, fontSize*NDDirector::DefaultDirector()->GetScaleFactor()).width;
				if (curWidth + temp > textWidth) 
				{
					if (fMaxWidth < curWidth) 
						fMaxWidth = curWidth;
						
					curWidth = 0;
					result += fontHeight;
				}
				curWidth += temp;
				
				if (fMaxWidth < curWidth) 
					fMaxWidth = curWidth;
			}			
		}
		return fMaxWidth;
	}
	
	unsigned int NDUITextBuilder::StringHeightAfterFilter(const char* text, unsigned int textWidth, unsigned int fontSize)
	{
		unsigned int result = 0;
		if (text) 
		{
			unsigned int fontHeight = getStringSize("a", fontSize*NDDirector::DefaultDirector()->GetScaleFactor()).height;
			result += fontHeight;
			unsigned int curWidth = 0;
			BuildRule rule = BuildRuleNone;
			ccColor4B clr= ccc4(0, 0, 0, 255);
			while (*text != '\0') 
			{
				if (*text == '\n') 
				{
					result += fontHeight;
					curWidth = 0;
					text++;
				}
				if (AnalysisRuleEnd(text, rule))
				{
					rule = BuildRuleNone;
					continue;
				}
				if (AnalysisRuleHead(text, rule, clr))
					continue;
				if (rule == BuildRuleExpression) 
				{				
					text += 2;
					
					if (curWidth + 15 > textWidth) 
					{
						curWidth = 0;
						result += fontHeight;
					}
					curWidth += 15;
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
				unsigned int temp = getStringSize(word, fontSize*NDDirector::DefaultDirector()->GetScaleFactor()).width;
				if (curWidth + temp > textWidth) 
				{
					curWidth = 0;
					result += fontHeight;
				}
				curWidth += temp;
			}			
		}
		return result;
	}
	
	unsigned char NDUITextBuilder::unsignedCharToHex(const char* usChar)
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
	
	bool NDUITextBuilder::AnalysisRuleEnd(const char*& text, BuildRule& rule)
	{
		bool result = false;		
		if (rule == BuildRuleExpression) 
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
			else if (*(text) == 'l') 
			{
				rule = BuildRuleLine;
				text++;
				result = true;
			}
			else if (rule == BuildRuleItem)
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
	
	bool NDUITextBuilder::AnalysisRuleHead(const char*& text, BuildRule &rule, ccColor4B &textColor)
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
				
				rule = BuildRuleColor;
				
				text += 7; 
				result = true;
			}
			else if (*text == 'f')
			{			
				rule = BuildRuleExpression;
				
				text++;
				result = true;
			}
			else if (*text == 'b')
			{		
				rule = BuildRuleItem;
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
			else if (*text == 'l')
			{
				rule = BuildRuleLine;
				text++;	
				result = true;
			}
			else 
				text--;
		}
		return result;
	}
	
	NDUIText* NDUITextBuilder::Combiner(std::vector<TextNode>& textNodeList, CGSize containerSize, bool withPageArrow)
	{
		NDUIText* result = new NDUIText();
		if (withPageArrow) 
			result->Initialization(true);
		else 
			result->Initialization(false);
		
		NDUINode* curPage = result->AddNewPage();
		
		float x = 0.0f, y = 0.0f;
		std::vector<TextNode>::iterator iter;		
		for (iter = textNodeList.begin(); iter != textNodeList.end(); iter++) 
		{
			TextNode node = *iter;
			CGRect uiNodeRect = node.uiNode->GetFrameRect();			
			
			if (node.hasBreak || x + uiNodeRect.size.width > containerSize.width) 
			{
				x = 0.0f; 
				y += uiNodeRect.size.height;
				
				float textHeight;
				if (withPageArrow) 
					textHeight = containerSize.height - PAGE_ARROW_SIZE.height;
				else 
					textHeight = containerSize.height;
				
				if (y > textHeight) 
				{
					curPage = result->AddNewPage();
					y = 0.0f;
				}									
			}
			
			node.uiNode->SetFrameRect(CGRectMake(x, y, uiNodeRect.size.width, uiNodeRect.size.height));
			curPage->AddChild(node.uiNode);
			
			x += uiNodeRect.size.width;			
		}
		
		result->ActivePage(result->GetCurrentPageIndex());
		return result;
	}
	
	NDPicture* NDUITextBuilder::CreateFacePicture(unsigned int index)
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
	
	NDUIImage* NDUITextBuilder::CreateFaceImage(const char* strIndex)
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
	
	NDUILabel* NDUITextBuilder::CreateLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem/* = 0*/)
	{
		NDUILabel* result = NULL;
		if (text) 
		{
			CGSize textSize = getStringSize(text, fontSize*NDDirector::DefaultDirector()->GetScaleFactor());
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
	
	HyperLinkLabel* NDUITextBuilder::CreateLinkLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem/* = 0*/)
	{
		HyperLinkLabel* result = NULL;
		if (text) 
		{
			CGSize textSize = getStringSize(text, fontSize*NDDirector::DefaultDirector()->GetScaleFactor());
			result = new HyperLinkLabel();
			result->Initialization();
			result->SetRenderTimes(1);
			result->SetText(text);
			result->SetTag(idItem);
			result->SetFontSize(fontSize);
			result->SetFontColor(color);
			result->SetFrameRect(CGRectMake(0, 0, textSize.width, textSize.height));
			result->SetIsLink(true);
		}
		return result;
	}
}
	


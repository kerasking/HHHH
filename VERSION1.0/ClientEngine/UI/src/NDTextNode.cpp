//
//  NDStyledNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-22.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "NDTextNode.h"
#include "NDPicture.h"
#include "NDUIOptionButton.h"
//#include "NDUISynLayer.h"
#include "NDUIBaseGraphics.h"
#include "NDPath.h"
#include "NDDirector.h"
#include "TQString.h"
#include "TQPlatform.h"
#include "NDSharedPtr.h"
#include "ObjectTracker.h"
#include "StringConvert.h"
#include "ScriptGameDataLua.h"

using namespace cocos2d;

namespace NDEngine
{
////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIText, NDUINode)

#define PAGE_ARROW_SIZE CCSizeMake(60, 15)

NDUIText::NDUIText()
{
	INC_NDOBJ_RTCLS

	m_uiPageCount = 0;
	m_uiCurrentPageIndex = 1;
	m_kBackgroundColor = ccc4(0, 0, 0, 0);
	m_bUsePageArrowControl = true;

	m_kColorFont = ccc4(255, 255, 0, 255);
	m_uiFontSize = 0;
}

NDUIText::~NDUIText()
{
	DEC_NDOBJ_RTCLS

	std::vector<NDUINode*>::iterator iter;
	for (iter = m_pkPages.begin(); iter != m_pkPages.end(); iter++)
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
		m_pkPageArrow = new NDUIOptionButton();
		m_pkPageArrow->Initialization();
		m_pkPageArrow->SetDelegate(this);
		m_pkPageArrow->SetFontColor(ccc4(24, 85, 82, 255));
		m_pkPageArrow->SetBgClr(ccc4(0, 0, 0, 0));
		m_pkPageArrow->ShowFrame(false);
		m_pkPageArrow->SetFontSize(10);
		m_pkPageArrow->EnableDraw(false);
		this->AddChild(m_pkPageArrow, 10);
	}

	m_bUsePageArrowControl = usePageArrowControl;
}

void NDUIText::SetBackgroundColor(ccColor4B color)
{
	m_kBackgroundColor = color;
}

unsigned int NDUIText::GetCurrentPageIndex()
{
	return m_uiCurrentPageIndex;
}

void NDUIText::SetFontSize(unsigned int uiFontSize)
{
	m_uiFontSize = uiFontSize;
}

void NDUIText::SetFontColor(ccColor4B color)
{
	m_kColorFont = color;
}

unsigned int NDUIText::GetFontSize()
{
	return m_uiFontSize;
}

ccColor4B NDUIText::GetFontColor()
{
	return m_kColorFont;
}

NDUINode* NDUIText::AddNewPage()
{
	NDUINode* uiNode = new NDUINode();
	uiNode->Initialization();
	AddChild(uiNode);
	m_pkPages.push_back(uiNode);

	m_uiPageCount++;

	if (m_bUsePageArrowControl)
	{
		if (m_uiPageCount > 1)
		{
			m_pkPageArrow->EnableDraw(true);

			VEC_OPTIONS options;
			for (unsigned int i = 1; i <= m_uiPageCount; i++)
			{
				tq::CString str("%d / %d", i, m_uiPageCount);
				options.push_back(str);
			}

			m_pkPageArrow->SetOptions(options);
		}
		else
		{
			m_pkPageArrow->EnableDraw(false);
		}
	}

	return uiNode;
}

void NDUIText::SetFrameRect(CCRect rect)
{
	NDUINode::SetFrameRect(rect);
	if (m_bUsePageArrowControl)
	{
		m_pkPageArrow->SetFrameRect(
				CCRectMake((rect.size.width - PAGE_ARROW_SIZE.width) / 2,
						rect.size.height - PAGE_ARROW_SIZE.height,
						PAGE_ARROW_SIZE.width, PAGE_ARROW_SIZE.height));
	}

// 	std::vector<NDUINode*>::iterator iter;
// 	for (iter = m_pkPages.begin(); iter != m_pkPages.end(); iter++)
// 	{
// 		NDUINode* uiNode = *iter;
// 		uiNode->SetFrameRect(
// 				CCRectMake(0, 0, rect.size.width, rect.size.height));
// 	}
}

void NDUIText::SetVisible(bool visible)
{
	NDUINode::SetVisible(visible);
	if (m_bUsePageArrowControl)
	{
		m_pkPageArrow->SetVisible(visible);
	}
	std::vector<NDUINode*>::iterator iter;
	for (iter = m_pkPages.begin(); iter != m_pkPages.end(); iter++)
	{
		NDUINode* uiNode = *iter;
		uiNode->SetVisible(visible);
	}
}

void NDUIText::OnOptionChange(NDUIOptionButton* option)
{
	m_uiCurrentPageIndex = option->GetOptionIndex() + 1;
	ActivePage (m_uiCurrentPageIndex);
}

void NDUIText::ActivePage(unsigned int pageIndex)
{
	if (pageIndex >= 1 && pageIndex <= m_uiPageCount)
	{
		std::vector<NDUINode*>::iterator iter;
		for (iter = m_pkPages.begin(); iter != m_pkPages.end(); iter++)
		{
			NDUINode* uiNode = *iter;
			uiNode->RemoveFromParent(false);
		}

		this->AddChild(m_pkPages.at(pageIndex - 1));
	}
}

bool NDUIText::OnTextClick(CCPoint touchPos)
{
	if (this->m_uiCurrentPageIndex - 1 >= 0
			&& m_uiCurrentPageIndex - 1 < this->m_pkPages.size())
	{
		NDUINode* curPage = m_pkPages.at(m_uiCurrentPageIndex - 1);
		if (curPage)
		{
			std::vector<NDNode*> vChildren = curPage->GetChildren();
			for (std::vector<NDNode*>::iterator it = vChildren.begin();
					it != vChildren.end(); it++)
			{
				NDUILabel* lbItem = dynamic_cast<NDUILabel*>(*it);
				//if (lbItem && lbItem->GetTag() > 0 && IsPointInside(touchPos, lbItem->GetScreenRect())) {
				/* todo don't call direct
				 NDTransData bao(_MSG_ITEM);
				 bao << lbItem->GetTag() << Byte(16);
				 ItemMgrObj.RemoveOtherItems();
				 ShowProgressBar;
				 SEND_DATA(bao);*/
				return true;
				//}
			}
		}
	}

	if (m_bUsePageArrowControl)
	{
		if (m_uiPageCount > 1)
		{
			CCRect scrRect = this->GetScreenRect();
			if (touchPos.x < scrRect.origin.x + scrRect.size.width / 2)
			{
				m_pkPageArrow->PreOpt();
			}
			else
			{
				m_pkPageArrow->NextOpt();
			}

			this->OnOptionChange(m_pkPageArrow);
		}
	}
	return false;
}

void NDUIText::draw()
{
	NDUINode::draw();

	if (this->IsVisibled())
	{
		DrawRecttangle(this->GetScreenRect(), m_kBackgroundColor);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUITextBuilder, NDObject)

static NDUITextBuilder* NDUITextBuilder_DefaultBuilder = NULL;
NDUITextBuilder::NDUITextBuilder()
{
	INC_NDOBJ_RTCLS
	NDAsssert(NDUITextBuilder_DefaultBuilder == NULL);
}

NDUITextBuilder::~NDUITextBuilder()
{
	DEC_NDOBJ_RTCLS
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

NDUIText* NDUITextBuilder::Build(const char* pszText, unsigned int uiFontSize,
		CCSize kContainerSize, ccColor4B kDefaultColor, bool bWithPageArrow,
		bool bHpyerLink)
{
	if (!pszText)
	{
		return 0;
	}

	uiFontSize = (uiFontSize == 6 ? 12 : uiFontSize);

	std::vector < TextNode > kTextNodeList;
	BuildRule eRule = BuildRuleNone;
	ccColor4B kColor = kDefaultColor;
	bool bHasBreak = false;
	bool bDrawLine = bHpyerLink;

	while (*pszText != '\0')
	{
		if (*pszText == '\n')
		{
			bHasBreak = true;
			pszText++;
			continue;
		}

		bool bRetAnalysis = false;

		bRetAnalysis = AnalysisRuleEnd(pszText, eRule);

		if (bRetAnalysis && BuildRuleLine == eRule
				&& !bHpyerLink)
		{
			bDrawLine = false;
		}

		if (bRetAnalysis)
		{
			if (eRule == BuildRuleItem)
			{
				if (bDrawLine)
				{
					kTextNodeList.push_back(
							TextNode(bHasBreak,
									CreateLinkLabel(GetTxtPri("]").c_str(), uiFontSize, kColor,
											m_nItemID), true));
                    
				}
				else
				{
					kTextNodeList.push_back(
							TextNode(bHasBreak,
									CreateLabel(GetTxtPri("]").c_str(), uiFontSize, kColor,
											m_nItemID), true));
				}
			}

			eRule = BuildRuleNone;
			kColor = kDefaultColor;
			continue;
		}

		bRetAnalysis = AnalysisRuleHead(pszText, eRule, kColor);
		if (bRetAnalysis && BuildRuleLine == eRule && !bHpyerLink)
		{
			bDrawLine = true;
		}
		if (eRule == BuildRuleExpression)
		{
			char szImageIndex[3] =
			{ 0x00 };
			memcpy(szImageIndex, pszText, 2);

			NDUIImage* pkImage = CreateFaceImage(szImageIndex);
			if (pkImage)
			{
				kTextNodeList.push_back(TextNode(bHasBreak, pkImage));
				bHasBreak = false;

				pszText += 2;
				continue;
			}
		}

		if (bRetAnalysis)
		{
			if (eRule == BuildRuleItem)
			{
				if (bDrawLine)
				{
					kTextNodeList.push_back(
							TextNode(bHasBreak,
									CreateLinkLabel( GetTxtPri("[").c_str(), uiFontSize, kColor,
											m_nItemID), true));
				}
				else
				{
					kTextNodeList.push_back(
							TextNode(bHasBreak,
									CreateLabel(GetTxtPri("[").c_str(), uiFontSize, kColor,
											m_nItemID), true));
				}
			}
			continue;
		}

		char szWord[4] =
		{ 0x00 };
		if ((unsigned char) *pszText < 0x80)
		{
			memcpy(szWord, pszText, 1);
			pszText++;
		}
		else
		{
			memcpy(szWord, pszText, 3);
			pszText += 3;
		}

		if (eRule == BuildRuleItem)
		{
			if (bDrawLine)
			{
				kTextNodeList.push_back(
						TextNode(bHasBreak,
								CreateLinkLabel(szWord, uiFontSize, kColor,
										m_nItemID), true));
			}
			else
			{
				kTextNodeList.push_back(
						TextNode(bHasBreak,
								CreateLabel(szWord, uiFontSize, kColor,
										m_nItemID), true));
			}
		}
		else
		{
			if (bDrawLine)
			{
				kTextNodeList.push_back(
						TextNode(bHasBreak,
								CreateLinkLabel(szWord, uiFontSize, kColor)));
			}
			else
			{
				kTextNodeList.push_back(
						TextNode(bHasBreak,
								CreateLabel(szWord, uiFontSize, kColor)));
			}

		}

		bHasBreak = false;
	}

	return Combiner(kTextNodeList, kContainerSize, bWithPageArrow);
}

unsigned int NDUITextBuilder::StringWidthAfterFilter(const char* text,
		unsigned int textWidth, unsigned int fontSize)
{
	float fMaxWidth = 0.0f;
	unsigned int result = 0;
	if (text)
	{
		unsigned int fontHeight = getStringSize(GetTxtPri("a").c_str(), fontSize * FONT_SCALE).height;
		result += fontHeight;
		unsigned int curWidth = 0;
		BuildRule rule = BuildRuleNone;
		ccColor4B clr = ccc4(0, 0, 0, 255);
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

			char word[4] =
			{ 0x00 };
			if ((unsigned char) *text < 0x80)
			{
				memcpy(word, text, 1);
				text++;
			}
			else
			{
				memcpy(word, text, 3);
				text += 3;
			}
			unsigned int temp = getStringSize(word, fontSize*FONT_SCALE).width;
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

unsigned int NDUITextBuilder::StringHeightAfterFilter(const char* text,
		unsigned int textWidth, unsigned int fontSize)
{
	unsigned int result = 0;
	if (text)
	{
		unsigned int fontHeight = getStringSize(GetTxtPri("a").c_str(), fontSize*FONT_SCALE).height;
		result += fontHeight;
		unsigned int curWidth = 0;
		BuildRule rule = BuildRuleNone;
		ccColor4B clr = ccc4(0, 0, 0, 255);
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

			char word[4] =
			{ 0x00 };
			if ((unsigned char) *text < 0x80)
			{
				memcpy(word, text, 1);
				text++;
			}
			else
			{
				memcpy(word, text, 3);
				text += 3;
			}
			unsigned int temp = getStringSize(word, fontSize*FONT_SCALE).width;
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

	unsigned char ucResult = 0;

	for (int i = 0; i < 2; i++)
	{
		if (*usChar <= '9' && *usChar >= '0')
		{
			if (0 == i)
				ucResult += (*usChar - '0') << 4;
			else
				ucResult += *usChar - '0';
		}
		else if (*usChar <= 'f' && *usChar >= 'a')
		{
			if (0 == i)
				ucResult += (*usChar - 'a' + 10) << 4;
			else
				ucResult += *usChar - 'a' + 10;
		}
		else if (*usChar <= 'F' && *usChar >= 'A')
		{
			if (0 == i)
				ucResult += (*usChar - 'A' + 10) << 4;
			else
				ucResult += *usChar - 'A' + 10;
		}

		usChar++;
	}

	return ucResult;
}

bool NDUITextBuilder::AnalysisRuleEnd(const char*& text, BuildRule rule)
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

bool NDUITextBuilder::AnalysisRuleHead(const char*& pszText, BuildRule &eRole,
		ccColor4B &kTextColor)
{
	bool result = false;
	if (*pszText == '<')
	{
		if (*(++pszText) == 'c')
		{
			char rValue[3] =
			{ 0x00 };
			memcpy(rValue, &pszText[1], 2);
			kTextColor.r = unsignedCharToHex(rValue);

			char gValue[3] =
			{ 0x00 };
			memcpy(gValue, &pszText[3], 2);
			kTextColor.g = unsignedCharToHex(gValue);

			char bValue[3] =
			{ 0x00 };
			memcpy(bValue, &pszText[5], 2);
			kTextColor.b = unsignedCharToHex(bValue);

			eRole = BuildRuleColor;

			pszText += 7;
			result = true;
		}
		else if (*pszText == 'f')
		{
			eRole = BuildRuleExpression;

			pszText++;
			result = true;
		}
		else if (*pszText == 'b')
		{
			eRole = BuildRuleItem;
			kTextColor = ccc4(255, 0, 0, 255);
			{
				string str = pszText;
				int nEnd = str.find_first_of('~');
				str = str.substr(0, nEnd);
				int nStart = str.find_last_of('/');
				str = str.substr(nStart + 1, str.size() - nStart - 1);
				m_nItemID = atoi(str.c_str());
			}
			pszText++;
			result = true;
		}
		else if (*pszText == 'l')
		{
			eRole = BuildRuleLine;
			pszText++;	
			result = true;
		}
		else
			pszText--;
	}
	return result;
}

NDUIText* NDUITextBuilder::Combiner(std::vector<TextNode>& textNodeList,
		CCSize containerSize, bool withPageArrow)
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
		CCRect uiNodeRect = node.uiNode->GetFrameRect();

		if (node.hasBreak || x + uiNodeRect.size.width > containerSize.width)
		{
			x = 0.0f;
			y += uiNodeRect.size.height;

			float fTextHeight;
			if (withPageArrow)
				fTextHeight = containerSize.height - PAGE_ARROW_SIZE.height;
			else
				fTextHeight = containerSize.height;

			if (y > fTextHeight)
			{
				curPage = result->AddNewPage();
				y = 0.0f;
			}
		}

		node.uiNode->SetFrameRect(
				CCRectMake(x, y, uiNodeRect.size.width,
						uiNodeRect.size.height));
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
		 result->Cut(CCRectMake(15 * col, 15 * row , 15, 15));
	}
	return result;
}

NDUIImage* NDUITextBuilder::CreateFaceImage(const char* strIndex)
{
	NDUIImage* pkResult = NULL;
	if (strlen(strIndex) >= 2)
	{
		unsigned int intIndex = atoi(strIndex);

		if (intIndex >= 0 && intIndex < 25)
		{
			NDPicture* pkPic = CreateFacePicture(intIndex);
			pkResult = new NDUIImage();
			pkResult->Initialization();
			pkResult->SetPicture(pkPic, true);
			pkResult->SetFrameRect(
					CCRectMake(0, 0, pkPic->GetSize().width,
							pkPic->GetSize().height));
		}
	}
	return pkResult;
}

NDUILabel* NDUITextBuilder::CreateLabel(const char* utf8_text,
		unsigned int fontSize, ccColor4B color, int idItem/* = 0*/)
{
	//注意：utf8_text传进来的格式是utf8的，计算string size之前要转成ansi，否则计算尺寸出错.
	if (!utf8_text || !utf8_text[0]) return NULL;

	NDUILabel* label = NULL;
	if (utf8_text)
	{
		CCSize kTextSize = getStringSize(utf8_text, fontSize*FONT_SCALE);

		label = new NDUILabel();
		label->Initialization();
		label->SetRenderTimes(1);
		label->SetText(utf8_text);
		label->SetTag(idItem);
		label->SetFontSize(fontSize);
		label->SetFontColor(color);
		label->SetFrameRect(CCRectMake(0, 0, kTextSize.width, kTextSize.height));
	}
	return label;
}

HyperLinkLabel* NDUITextBuilder::CreateLinkLabel(const char* in_utf8,
		unsigned int uiFontSize, ccColor4B kColor, int nItemID)
{
	HyperLinkLabel* pkResultLabel = NULL;

	if (in_utf8)
	{
		CCSize kTextSize = getStringSize(in_utf8, uiFontSize*FONT_SCALE);
		pkResultLabel = new HyperLinkLabel();
		pkResultLabel->Initialization();
		pkResultLabel->SetRenderTimes(1);
		pkResultLabel->SetText(in_utf8);
		pkResultLabel->SetTag(nItemID);
		pkResultLabel->SetFontSize(uiFontSize);
		pkResultLabel->SetFontColor(kColor);
		pkResultLabel->SetFrameRect(CCRectMake(0, 0, kTextSize.width, kTextSize.height));
		pkResultLabel->SetIsLink(true);
	}

	return pkResultLabel;
}

}
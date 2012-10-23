//
//  NDStyledNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDTextNode_H
#define __NDTextNode_H

#include "NDUINode.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "NDUIOptionButton.h"
#include <vector>
#include <map>
#include "HyperLinkLabel.h"

namespace NDEngine
{	
	//节点
	typedef struct TEXT_NODE{
		bool hasBreak;
		bool bItem;
		NDUINode* uiNode;
		TEXT_NODE(bool brk, NDUINode* node, bool bItm = false)
		{
			bItem = bItm;
			hasBreak = brk;
			uiNode = node;
		}
	}TextNode;
	
	typedef enum
	{
		BuildRuleNone,			//无规则，默认
		BuildRuleExpression,	//表情规则
		BuildRuleItem,			//物品规则
		BuildRuleColor,			//颜色规则
		BuildRuleLine,			//带下划线规则 <l /l
	}BuildRule;
	
	class NDUIText : public NDUINode
	{
		DECLARE_CLASS(NDUIText)
		NDUIText();
		~NDUIText();
	public:
		void Initialization(bool usePageArrowControl = true); override
		unsigned int GetPageCount(){ return m_pageCount; }
		unsigned int GetCurrentPageIndex();
		void SetBackgroundColor(ccColor4B color);
		bool OnTextClick(CGPoint touchPos);
		NDUINode* AddNewPage();	
		void SetFontSize(unsigned int uiFontSize);
		void SetFontColor(ccColor4B color);
		unsigned int GetFontSize();
		ccColor4B GetFontColor();
	public:
		void draw(); override
		void OnOptionChange(NDUIOptionButton* option); override
		void SetVisible(bool visible); override	
		void SetFrameRect(CGRect rect); override
		void ActivePage(unsigned int pageIndex);
	private:
		unsigned int m_pageCount, m_currentPageIndex;
		ccColor4B m_backgroundColor;
		NDUIOptionButton* m_pageArrow;
		std::vector<NDUINode*> m_pages;
		bool m_usePageArrowControl;
		unsigned int m_uiFontSize;
		ccColor4B	 m_colorFont;
	};
	
	//节点生成器
	class NDUITextBuilder : public NDObject
	{
		DECLARE_CLASS(NDUITextBuilder)
		NDUITextBuilder();
		~NDUITextBuilder();
	public:
		//单例
		static NDUITextBuilder* DefaultBuilder();
		//解析字符串
		NDUIText* Build(const char* text, unsigned int fontSize, CGSize containerSize, ccColor4B defaultColor = ccc4(0, 0, 0, 255), bool withPageArrow = false, bool bHpyerLink = false);
		unsigned int StringHeightAfterFilter(const char* text, unsigned int textWidth, unsigned int fontSize);
		unsigned int StringWidthAfterFilter(const char* text, unsigned int textWidth, unsigned int fontSize);
	private:	
		//两位16进制字符串转16进制值
		unsigned char unsignedCharToHex(const char* usChar);
		//解析规则尾部
		bool AnalysisRuleEnd(const char*& text, BuildRule& rule);
		//解析规则头部
		bool AnalysisRuleHead(const char*& text, BuildRule &rule, ccColor4B &textColor);
		//组合节点
		NDUIText* Combiner(std::vector<TextNode>& textNodeList, CGSize containerSize, bool withPageArrow);
		//获取表情纹理
		NDPicture* CreateFacePicture(unsigned int index);
		//获取表情图片 格式如f00
		NDUIImage* CreateFaceImage(const char* strIndex);		
		//获取标签
		NDUILabel* CreateLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem = 0);
		HyperLinkLabel* CreateLinkLabel(const char* text, unsigned int fontSize, ccColor4B color, int idItem = 0);
	private:
		int m_idItem;
	};	
}


#endif

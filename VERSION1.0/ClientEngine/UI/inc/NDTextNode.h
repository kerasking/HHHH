//
//  NDStyledNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-3-22.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
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
typedef struct TEXT_NODE
{
	bool hasBreak;
	bool bItem;
	NDUINode* uiNode;
	TEXT_NODE(bool brk, NDUINode* node, bool bItm = false)
	{
		bItem = bItm;
		hasBreak = brk;
		uiNode = node;
	}
} TextNode;

typedef enum
{
	BuildRuleNone,			//无规则，默认
	BuildRuleExpression,	//表情规则
	BuildRuleItem,			//物品规则
	BuildRuleColor,			//颜色规则
	BuildRuleLine			//带下划线规则
} BuildRule;

class NDUIText: public NDUINode
{
	DECLARE_CLASS (NDUIText)
	NDUIText();
	~NDUIText();
public:
	void Initialization(bool usePageArrowControl = true);
	unsigned int GetPageCount()
	{
		return m_uiPageCount;
	}
	unsigned int GetCurrentPageIndex();
	void SetBackgroundColor(cocos2d::ccColor4B color);
	bool OnTextClick(CCPoint touchPos);
	NDUINode* AddNewPage();
	void SetFontSize(unsigned int uiFontSize);
	void SetFontColor(cocos2d::ccColor4B color);
	unsigned int GetFontSize();
	cocos2d::ccColor4B GetFontColor();
public:
	void draw();
	void OnOptionChange(NDUIOptionButton* option);
	void SetVisible(bool visible);
	void SetFrameRect(CCRect rect);
	void ActivePage(unsigned int pageIndex);
private:
	unsigned int m_uiPageCount;
	unsigned int m_uiCurrentPageIndex;
	cocos2d::ccColor4B m_kBackgroundColor;
	NDUIOptionButton* m_pkPageArrow;
	std::vector<NDUINode*> m_pkPages;
	bool m_bUsePageArrowControl;
	unsigned int m_uiFontSize;
	cocos2d::ccColor4B m_kColorFont;
};

//节点生成器
class NDUITextBuilder: public NDObject
{
	DECLARE_CLASS (NDUITextBuilder)
	NDUITextBuilder();
	~NDUITextBuilder();
public:
	//单例
	static NDUITextBuilder* DefaultBuilder();
	//解析字符串
	NDUIText* Build(const char* pszText, unsigned int uiFontSize,
			CCSize kContainerSize,
			cocos2d::ccColor4B kDefaultColor = ccc4(0, 0, 0, 255),
			bool bWithPageArrow = false, bool bHpyerLink = false);
	unsigned int StringHeightAfterFilter(const char* text,
			unsigned int textWidth, unsigned int fontSize);
	unsigned int StringWidthAfterFilter(const char* text,
			unsigned int textWidth, unsigned int fontSize);

private:
	NDUIText* Build_WithNDBitmap(const char* pszText, unsigned int uiFontSize,
		CCSize kContainerSize,
		cocos2d::ccColor4B kDefaultColor = ccc4(0, 0, 0, 255),
		bool bWithPageArrow = false, bool bHpyerLink = false);

private:
	//两位16进制字符串转16进制值
	unsigned char unsignedCharToHex(const char* usChar);
	//解析规则尾部
	bool AnalysisRuleEnd(const char*& text, BuildRule rule);
	//解析规则头部
	bool AnalysisRuleHead(const char*& pszText, BuildRule &eRole,
			cocos2d::ccColor4B &kTextColor);
	//组合节点
	NDUIText* Combiner(std::vector<TextNode>& textNodeList,
			CCSize containerSize, bool withPageArrow);
	//获取表情纹理
	NDPicture* CreateFacePicture(unsigned int index);
	//获取表情图片 格式如f00
	NDUIImage* CreateFaceImage(const char* strIndex);
	//获取标签
	NDUILabel* CreateLabel(const char* pszText, unsigned int fontSize,
			cocos2d::ccColor4B color, int idItem = 0);
	HyperLinkLabel* CreateLinkLabel(const char* pszText,
			unsigned int uiFontSize, ccColor4B kColor, int nItemID = 0);
private:
	int m_nItemID;
};
}

#endif

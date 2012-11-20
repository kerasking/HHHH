/*
 *  NDControlHelp.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#pragma once

#include "UIData.h"
#include "NDUILabel.h"
#include "NDUIButton.h"
#include "NDUIImage.h"
//#include "NDScrollLayer.h"
//#include "NDUITableLayer.h"
#include "NDPicture.h"
#include "NDUIScrollContainer.h"
#include "NDUIScrollView.h"
#include "NDTextNode.h"
#include "UIHyperlink.h"
#include "UIItemButton.h"
//#include "UIEquipItem.h"
#include "UICheckBox.h"
#include "UIRadioButton.h"
#include "UIExp.h"
#include "UIEdit.h"
#include "UISpriteNode.h"
#include "NDPath.h"
#include "NDWideString.h"
#include "UIScrollViewMulHand.h"
#include "UIScrollContainerExpand.h"

using namespace NDEngine;

// 控件类型
enum MY_CONTROL_TYPE
{
	MY_CONTROL_TYPE_UNKNOWN,
	MY_CONTROL_TYPE_PICTURE,						// 图片
	MY_CONTROL_TYPE_BUTTON,							// 按钮
	MY_CONTROL_TYPE_CHECK_BUTTON,					// 选择按钮
	MY_CONTROL_TYPE_TEXT,							// 文本
	MY_CONTROL_TYPE_UITEXT,							// UI文本(文本可显示不同颜色)
	MY_CONTROL_TYPE_HYPER_TEXT,						// 链接文本
	MY_CONTROL_TYPE_HYPER_TEXT_BUTTON,				// 链接按钮
	MY_CONTROL_TYPE_LIST,							// 列表(水平型)
	MY_CONTROL_TYPE_EXP,							// 经验条
	MY_CONTROL_TYPE_PROGRESS,						// 进度条
	MY_CONTROL_TYPE_SLIDER,							// 滑动条
	MY_CONTROL_TYPE_BACK,							// 背景
	MY_CONTROL_TYPE_TABLE,							// 表格
	MY_CONTROL_TYPE_LIST_M,							// 垂直型列表
	MY_CONTROL_TYPE_RADIO_BUTTON,					// 点选按钮
	MY_CONTROL_TYPE_ITEM_BUTTON,					// 物品按钮
	MY_CONTROL_TYPE_EQUIP_BUTTON,					// 装备按钮
	MY_CONTROL_TYPE_EDIT,							// 输入框
	MY_CONTROL_TYPE_SPRITE,							// 动画
	MY_CONTROL_TYPE_LIST_HV,                        // 水平+垂直型列表20
	MY_CONTROL_TYPE_LIST_LOOP,                      // 循环水平列表21
};

class CtrolBase
{
protected:
	void Init(UIINFO& info, CCSize& sizeOffset)
	{
		m_info = info;
		
		m_sizeOffset = sizeOffset;
	}
	
	CCRect GetFrameRect()
	{
		CCRect rect = CCRectZero;
		
		rect.origin = ccpAdd(
							 m_info.CtrlPos, 
							 ccp(m_sizeOffset.width, m_sizeOffset.height));
		
		if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
		{
			rect.size = CCSizeMake(m_info.nCtrlWidth, m_info.nCtrlHeight);
			return rect;
		}
		
		if (m_info.strNormalFile.empty()) 
		{
			NDAsssert(0);
			
			return rect;
		}
		
		NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
							NDPath::GetUIImgPath(m_info.strNormalFile.c_str()) );
		
		rect.size = pic->GetSize();
		
		delete pic;
		
		return rect;
	}
	
	NDPicture* GetNormalPicture()
	{
		return GetPicture(m_info.strNormalFile, m_info.rectNormal);
	}
	
	NDPicture* GetSelectedPicture()
	{
		return GetPicture(m_info.strSelectedFile, m_info.rectSelected);
	}
	
	NDPicture* GetDisablePicture()
	{
		return GetPicture(m_info.strDisableFile, m_info.rectDisable);
	}
	
	NDPicture* GetFocusPicture()
	{
		return GetPicture(m_info.strFocusFile, m_info.rectFocus);
	}
	
	NDPicture* GetBackPicture()
	{
		return GetPicture(m_info.strBackFile, m_info.rectBack);
	}
	
	LabelTextAlignment GetTextAlign()
	{
		/*
		 "左对齐";
		 "右对齐";
		 "水平居中"
		 "竖直居中"
		 "居中"
		 */
		
		LabelTextAlignment align = LabelTextAlignmentLeft;
		
		if (NDWideString::IsEqual_UTF8_Ansi( m_info.strTextAlign.c_str(), "左对齐" ))
			align = LabelTextAlignmentLeft;

		else if (NDWideString::IsEqual_UTF8_Ansi( m_info.strTextAlign.c_str(), "右对齐" ))
			align = LabelTextAlignmentRight;

		else if (NDWideString::IsEqual_UTF8_Ansi( m_info.strTextAlign.c_str(), "居中" ))
			align = LabelTextAlignmentCenter;

		else if (NDWideString::IsEqual_UTF8_Ansi( m_info.strTextAlign.c_str(), "水平居中" ))
			align = LabelTextAlignmentHorzCenter;

		else if (NDWideString::IsEqual_UTF8_Ansi( m_info.strTextAlign.c_str(), "竖直居中" ))
			align = LabelTextAlignmentVertCenter;

		return align;
	}
private:	
	NDPicture*	GetPicture(std::string& filename, CTRL_UV& uv)
	{
		NDPicture* res = NULL;
		
		if (filename.empty())
		{
			return res;
		}
		
		if (m_info.nCtrlWidth != 0 && m_info.nCtrlHeight != 0)
		{ // 拉伸 (拉伸后不进行u,v处理)
			// 获取图片大小并与u,v比较,大小不一样说明是抠图,则不做拉伸,这一步以后可以放到UI编辑器(直接导出该信息)
			NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetUIImgPath(filename.c_str()));
			if (pic)
			{
				CCSize size = pic->GetSize();
				if (uv.w <= int(size.width) && uv.h <= int(size.height))
				{
					pic->Cut(CCRectMake(uv.x, uv.y, uv.w, uv.h ) );
					
					return pic;
				}
			}
			
			res  = NDPicturePool::DefaultPool()->AddPicture(
															NDPath::GetUIImgPath(filename.c_str()),
															m_info.nCtrlWidth, m_info.nCtrlHeight );
			delete pic;
		}
		else
		{ // 不拉伸 (扣出来的图不做拉伸处理)
			res  = NDPicturePool::DefaultPool()->AddPicture(
															NDPath::GetUIImgPath(filename.c_str()) );
			
			if (uv.w != 0 && uv.h != 0)
			{
				res->Cut(CCRectMake(
									uv.x, uv.y, uv.w, uv.h ) );
			}
		}
		
		return res;
	}
	
protected:
	UIINFO m_info;
	CCSize m_sizeOffset;
};

template<typename CTROL>
class CtrolTrait : public CtrolBase
{
public:
	CTROL* Create(UIINFO& info, CCSize& sizeOffset) 
	{ 
		Init(info, sizeOffset);
		
		return NULL; 
	}
};

template<>
class CtrolTrait<NDUIImage> : public CtrolBase
{
public:
	NDUIImage* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetFrameRect(this->GetFrameRect());
		image->SetPicture(GetNormalPicture(), true);
		return image;
	}
};

template<>
class CtrolTrait<NDUIButton> : public CtrolBase
{
public:
	NDUIButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIButton *btn = new NDUIButton;
		btn->Initialization();
		btn->CloseFrame();
		btn->SetFrameRect(this->GetFrameRect());
		btn->SetImage(GetNormalPicture(), false, CCRectZero, true);
		btn->SetBackgroundPicture(GetBackPicture(), NULL, false, CCRectZero, true);
		btn->SetTouchDownImage(GetSelectedPicture(), false, CCRectZero, true);
		btn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		btn->SetTitle(info.strText.c_str());
		btn->SetFontSize(info.nTextFontSize);
		btn->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return btn;
	}
};

template<>
class CtrolTrait<CUICheckBox> : public CtrolBase
{
public:
	CUICheckBox* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		CUICheckBox *checkBox = new CUICheckBox;
		NDPicture* fileUnCheck	= NULL;
		NDPicture* fileCheck	= NULL;
		if (!m_info.strNormalFile.empty())
		{
			//fileUnCheck	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str();
			fileUnCheck = GetNormalPicture();
		}
		if (!m_info.strSelectedFile.empty())
		{
			fileCheck = GetSelectedPicture();
		}
		checkBox->Initialization(fileUnCheck, fileCheck);
		checkBox->SetFrameRect(this->GetFrameRect());
		checkBox->SetText(info.strText.c_str());
		checkBox->SetTextFontSize(info.nTextFontSize);
		checkBox->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return checkBox;
	}
};

template<>
class CtrolTrait<NDUILabel> : public CtrolBase
{
public:
	NDUILabel* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUILabel *lb = new NDUILabel;
		lb->Initialization();
		lb->SetFrameRect(this->GetFrameRect());
		lb->SetText(info.strText.c_str());
		lb->SetTextAlignment(GetTextAlign());
		lb->SetFontSize(info.nTextFontSize);
		lb->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return lb;
	}
};

template<>
class CtrolTrait<NDUIScrollViewContainer> : public CtrolBase
{
public:
	NDUIScrollViewContainer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// 水平型
		CCRect rect = this->GetFrameRect();
		NDUIScrollViewContainer *container = new NDUIScrollViewContainer;
		container->Initialization();
		container->SetStyle(UIScrollStyleHorzontal);
		container->SetFrameRect(rect);
		container->SetLeftReserveDistance(rect.size.width);
		container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

template<>
class CtrolTrait<CUIScrollViewContainerM> : public CtrolBase
{
public:
	CUIScrollViewContainerM* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// 水平型
		CCRect rect = this->GetFrameRect();
		CUIScrollViewContainerM *container = new CUIScrollViewContainerM;
		container->Initialization();
		container->SetFrameRect(rect);
		container->SetLeftReserveDistance(rect.size.width);
		container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

template<>
class CtrolTrait<CUIScrollContainerExpand> : public CtrolBase
{
public:
	CUIScrollContainerExpand* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// 水平型
		CCRect rect = this->GetFrameRect();
		CUIScrollContainerExpand *container = new CUIScrollContainerExpand;
		container->Initialization();
		container->SetFrameRect(rect);
		//container->SetLeftReserveDistance(rect.size.width);
		//container->SetRightReserveDistance(rect.size.width);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};

/*
template<>
class CtrolTrait<NDUITableLayer> : public CtrolBase
{
public:
	NDUITableLayer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		NDUITableLayer *table = new NDUITableLayer;
		table->Initialization();
		table->SetFrameRect(this->GetFrameRect());
		table->SetBackgroundColor(ccc4(0, 0, 0, 0));
		table->VisibleSectionTitles(false);
		table->VisibleScrollBar(false);
		table->SetCellsInterval(2);
		table->SetCellsRightDistance(0);
		table->SetCellsLeftDistance(0);
		return table;
	}
};
*/
template<>
class CtrolTrait<NDUIText> : public CtrolBase
{
public:
	NDUIText* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		
		NDUIText *uitext = new NDUIText;
		uitext->Initialization(false);
		uitext->SetFontSize(info.nTextFontSize);
		uitext->SetFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		uitext->SetFrameRect(this->GetFrameRect());
		return uitext;
	}
};

template<>
class CtrolTrait<CUIHyperlinkText> : public CtrolBase
{
public:
	CUIHyperlinkText* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIHyperlinkText *linktext = new CUIHyperlinkText;
		linktext->Initialization();
		linktext->SetFrameRect(rect);
		linktext->SetLinkBoundRect(rect);
		linktext->SetLinkTextAlignment(GetTextAlign());
		linktext->SetLinkTextFontSize(info.nTextFontSize);
		linktext->SetLinkTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		linktext->SetLinkText(info.strText.c_str());
		return linktext;
	}
};

template<>
class CtrolTrait<CUIHyperlinkButton> : public CtrolBase
{
public:
	CUIHyperlinkButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIHyperlinkButton *linkbtn = new CUIHyperlinkButton;
		linkbtn->Initialization();
		linkbtn->SetFrameRect(rect);
		linkbtn->SetLinkTextAlignment(GetTextAlign());
		linkbtn->SetLinkBoundRect(rect);
		linkbtn->SetLinkTextFontSize(info.nTextFontSize);
		linkbtn->SetLinkTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		linkbtn->SetLinkText(info.strText.c_str());
		return linkbtn;
	}
};

template<>
class CtrolTrait<CUIItemButton> : public CtrolBase
{
public:
	CUIItemButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIItemButton *itemBtn = new CUIItemButton;
		itemBtn->Initialization();
		itemBtn->SetFrameRect(rect);
		itemBtn->CloseFrame();
		itemBtn->SetBackgroundPicture(GetNormalPicture(), NULL, false, CCRectZero, true);
		itemBtn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		return itemBtn;
	}
};

template<>
class CtrolTrait<CUIEdit> : public CtrolBase
{
public:
	CUIEdit* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIEdit *edit = new CUIEdit;
		edit->Initialization();
		edit->SetFrameRect(rect);
		edit->SetTextSize(info.nTextFontSize);
		edit->SetTextColor(INTCOLORTOCCC4(info.nTextFontColor));
		edit->SetImage(GetNormalPicture());
		if(!info.strSelectedFile.empty())
		{
			edit->SetFocusImage(GetSelectedPicture());
		}
		return edit;
	}
};

template<>
class CtrolTrait<CUIExp> : public CtrolBase
{
public:
	CUIExp* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIExp *exp = new CUIExp;
		const char* bgfile	= NULL;
		const char* processfile	= NULL;
		if (!m_info.strNormalFile.empty())
		{
			bgfile	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str();
		}
		if (!m_info.strSelectedFile.empty())
		{
			processfile	= NDPath::GetUIImgPath(m_info.strSelectedFile.c_str()).c_str();
		}
		exp->Initialization(bgfile, processfile);		
		exp->SetFrameRect(this->GetFrameRect());
		exp->SetText(info.strText.c_str());
		exp->SetTextFontSize(info.nTextFontSize);
		exp->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return exp;
	}
};

template<>
class CtrolTrait<CUISpriteNode> : public CtrolBase
{
public:
	CUISpriteNode* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUISpriteNode *sprite = new CUISpriteNode;
		sprite->Initialization();		
		sprite->SetFrameRect(this->GetFrameRect());
		if (!m_info.strNormalFile.empty())
		{
			sprite->ChangeSprite(NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str());
		}
		return sprite;
	}
};

template<int CtrolType>
class ControlHelp : public CtrolTrait<void>
{
};
					
template<>															
class ControlHelp<MY_CONTROL_TYPE_LIST_M> : public CtrolTrait<NDUIScrollViewContainer>		
{	
public:
	NDUIScrollViewContainer* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);

		// 水平型
		CCRect rect = this->GetFrameRect();
		NDUIScrollViewContainer *container = new NDUIScrollViewContainer;
		container->Initialization();
		container->SetStyle(UIScrollStyleVerical);
		container->SetFrameRect(rect);
		container->SetTopReserveDistance(rect.size.height);
		container->SetBottomReserveDistance(rect.size.height);
		container->SetBackgroundImage(GetNormalPicture(), true);
		return container;
	}
};
/*
template<>															
class ControlHelp<MY_CONTROL_TYPE_EQUIP_BUTTON> : public CtrolTrait<CUIItemButton>		
{	
public:
	CUIEquipItem* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIEquipItem *equipBtn = new CUIEquipItem;
		equipBtn->Initialization();
		equipBtn->SetFrameRect(rect);
		equipBtn->CloseFrame();
		equipBtn->SetBackgroundPicture(GetNormalPicture(), NULL, false, CCRectZero, true);
		equipBtn->SetFocusImage(GetFocusPicture(), false, CCRectZero, true);
		return equipBtn;
	}
};
*/
template<>															
class ControlHelp<MY_CONTROL_TYPE_RADIO_BUTTON> : public CtrolTrait<CUICheckBox>		
{	
public:
	CUIRadioButton* Create(UIINFO& info, CCSize& sizeOffset)
	{
		Init(info, sizeOffset);
		CCRect rect = this->GetFrameRect();
		CUIRadioButton *radio = new CUIRadioButton;
		const char* fileUnCheck	= NULL;
		const char* fileCheck	= NULL;
		if (!m_info.strNormalFile.empty())
		{
			fileUnCheck	= NDPath::GetUIImgPath(m_info.strNormalFile.c_str()).c_str();
		}
		if (!m_info.strSelectedFile.empty())
		{
			fileCheck	= NDPath::GetUIImgPath(m_info.strSelectedFile.c_str()).c_str();
		}
		radio->Initialization(fileUnCheck, fileCheck);
		radio->SetFrameRect(rect);
		radio->SetText(info.strText.c_str());
		radio->SetTextFontSize(info.nTextFontSize);
		radio->SetTextFontColor(INTCOLORTOCCC4(info.nTextFontColor));
		return radio;
	}
};

#pragma mark 控件声明

#define CtrolHelpDeclare(CONTROL_TYPE, CONTROL)						\
template<>															\
class ControlHelp<CONTROL_TYPE> : public CtrolTrait<CONTROL>		\
{																	\
};

CtrolHelpDeclare(MY_CONTROL_TYPE_UNKNOWN, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_PICTURE, NDUIImage)
CtrolHelpDeclare(MY_CONTROL_TYPE_BUTTON, NDUIButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_CHECK_BUTTON, CUICheckBox)
CtrolHelpDeclare(MY_CONTROL_TYPE_TEXT, NDUILabel)
CtrolHelpDeclare(MY_CONTROL_TYPE_LIST, NDUIScrollViewContainer)

CtrolHelpDeclare(MY_CONTROL_TYPE_LIST_HV, CUIScrollViewContainerM)
CtrolHelpDeclare(MY_CONTROL_TYPE_LIST_LOOP, CUIScrollContainerExpand)

CtrolHelpDeclare(MY_CONTROL_TYPE_PROGRESS, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_SLIDER, NDUINode)
CtrolHelpDeclare(MY_CONTROL_TYPE_BACK, NDUIImage)
//CtrolHelpDeclare(MY_CONTROL_TYPE_TABLE, NDUITableLayer)
CtrolHelpDeclare(MY_CONTROL_TYPE_UITEXT, NDUIText)
CtrolHelpDeclare(MY_CONTROL_TYPE_HYPER_TEXT, CUIHyperlinkText)
CtrolHelpDeclare(MY_CONTROL_TYPE_HYPER_TEXT_BUTTON, CUIHyperlinkButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_ITEM_BUTTON, CUIItemButton)
CtrolHelpDeclare(MY_CONTROL_TYPE_EXP, CUIExp)
CtrolHelpDeclare(MY_CONTROL_TYPE_EDIT, CUIEdit)
CtrolHelpDeclare(MY_CONTROL_TYPE_SPRITE, CUISpriteNode)

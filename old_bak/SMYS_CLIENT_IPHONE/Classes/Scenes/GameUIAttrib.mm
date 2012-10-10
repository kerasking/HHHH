/*
 *  GameUIAttrib.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "GameUIAttrib.h"
#import "NDUIFrame.h"
#import "NDUIMenuLayer.h"
#import "NDPicture.h"
#import "NDManualRole.h"
#import "NDUILabel.h"
#import "NDUIButton.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUIBaseGraphics.h"
#import "NDUITableLayer.h"
#import "NDUIImage.h"
#import "define.h"
#import "NDPlayer.h"
#import "NDConstant.h"
#import "ItemMgr.h"
#import "EnumDef.h"
#import "NDMsgDefine.h"
#import "NDDataTransThread.h"
#import "GameScene.h"
#import "NDUtility.h"
#import "PlayerInfoScene.h"
#import <sstream>
#import "NDString.h"
/*
 详细：
 出手速度 物理攻击 法术攻击 物理防御 法术抗性 物理命中 闪避 暴击 灵气值 
 
 高级：
 阵营 军团 军衔 荣誉 国家声望 阵营声望 PK值 伴侣
 */

using namespace NDEngine;

enum e_prop_detail
{
	ePD_Begin = 0,
	ePD_speed = ePD_Begin,		// 出手速度
	ePD_PhycialAttack,			// 物理攻击
	ePD_MagicAttack,			// 法术攻击
	ePD_PhycialDef,				// 物理防御
	ePD_MagicDef,				// 法术抗性
	ePD_MagicHit,				// 物理命中
	ePD_Dodge,					// 闪避
	ePD_SuperHit,				// 暴击
	ePD_LinQi,					// 灵气值
	ePD_End,
};

static std::string strPropDetail[ePD_End] = 
{
	NDCommonCString("ChuShouSpeed"), 
	NDCommonCString("PhyAtk"), 
	NDCommonCString("FaShuAtk"), 
	NDCommonCString("PhyDef"), 
	NDCommonCString("FaShuKangXing"), 
	NDCommonCString("PhyHit"), 
	NDCommonCString("Dodge"), 
	NDCommonCString("CriticalHit"), 
	NDCommonCString("LingQiVal")
};

static std::string strPropDetailInfo[ePD_End] =
{
	NDCommonCString("ChuShouShunXun"),
	NDCommonCString("WuLiShangHaiTip"),
	NDCommonCString("FaShuAtkTip"),
	NDCommonCString("DeHurtPhyAtk"),
	NDCommonCString("DeHurtMagicAtk"),
	NDCommonCString("PhyAtkHitRate"),
	NDCommonCString("AddDodgeRate"),
	NDCommonCString("RateHurt175"),
	NDCommonCString("BattleGetSkillDot"),
};

enum e_prop_Advance 
{
	ePA_Begin = 0,
	ePa_JiFeng = ePA_Begin,		// 积分
	ePA_Camp,					// 阵营
	ePA_JunTuan,				// 军团
	ePA_JunXian,				// 军衔
	ePA_Honer,					// 荣誉
	ePA_CountryReputation,		// 国家声望
	ePA_CampReputation,			// 阵营声望
	ePA_PK,						// PK值
	ePA_Lover,					// 伴侣
	ePA_Activity,				// 活力
	ePA_Vip,					// VIP
	ePA_End,
};

static std::string strPorpAdvance[ePA_End] = 
{
	NDCommonCString("JiFeng"), 
	NDCommonCString("camp"), 
	NDCommonCString("JunTuan"), 
	NDCommonCString("JunXian"), 
	NDCommonCString("honur"), 
	NDCommonCString("CountryRepute"), 
	NDCommonCString("CampRepute"), 
	NDCommonCString("PKVal"), 
	NDCommonCString("lover"), 
	NDCommonCString("activity"),
	"VIP",
};

static std::string strPorpAdvanceInfo[ePA_End] = 
{
	NDCommonCString("ChangeAnJiFengAution"),
	NDCommonCString("RoleCamp"),
	NDCommonCString("RoleJunTuan"),
	NDCommonCString("RoleJunTuanBank"),
	NDCommonCString("RoleHonurVal"),
	NDCommonCString("CountryReputeTip"),
	NDCommonCString("PersonalReputeTip"),
	NDCommonCString("KillPlayerTip"),
	"",
	"",
	"",	// VIP
};

static std::string strBtnPoint[GameUIAttrib::_stru_point::ps_end][2] =
{
	{NDCommonCString("Liliang"), NDCommonCString("LiLiangTip")}, 
	{NDCommonCString("TiZhi"), NDCommonCString("TiZhiTip")}, 
	{NDCommonCString("MingJie"), NDCommonCString("MingJieTip")},
	{NDCommonCString("ZhiLi"), NDCommonCString("ZhiLiTip")},
};

#define title_image ([[NSString stringWithFormat:@"%s", GetImgPath("titles.png")] UTF8String])
#define plusminus_image ([[NSString stringWithFormat:@"%s", GetImgPath("plusMinus.png")] UTF8String])
#define money_image ([[NSString stringWithFormat:@"%s", GetImgPath("money.png")] UTF8String])
#define emoney_image ([[NSString stringWithFormat:@"%s", GetImgPath("emoney.png")] UTF8String])
#define point_focus_color (ccc4(255, 206, 75, 255))
#define point_normal_color (ccc4(0, 0, 0, 0))
#define point_layer_h (25)

IMPLEMENT_CLASS(NDUIStateBar, NDUILayer)

NDUIStateBar::NDUIStateBar()
{
	m_stateNum = NULL;
	m_iCurNum = 0; m_iMaxNum = 0;
	m_colorState = ccc4(206, 64, 52, 255);
	m_bShowNum = true;
	
	m_bShowPic = true;
	
	m_lbNumMin = NULL;
	
	m_lbNumMax = NULL;
	
	m_lbText = NULL;
	
	m_bShowLabel = false;
	
	m_iPercent = -1;
	
	m_rectSlide = NULL;
	
	m_bSlide = true;
	
	m_rectSlideBG = NULL;
}

NDUIStateBar::~NDUIStateBar()
{
}

void NDUIStateBar::Initialization(bool bSlide/*=true*/)
{
	NDUILayer::Initialization();
	//this->SetBackgroundColor(ccc4(76,79,76, 255));
	this->SetBackgroundColor(INTCOLORTOCCC4(0x666666));
	
	m_stateNum = new ImageNumber;
	m_stateNum->Initialization();
	m_stateNum->SetTitleRedTwoNumber(0,0);
	m_stateNum->SetFrameRect(CGRectMake(5,0,90,11));
	this->AddChild(m_stateNum,1);
	
	m_lbNumMin = new NDUILabel;
	m_lbNumMin->Initialization();
	m_lbNumMin->SetFontSize(15);
	m_lbNumMin->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbNumMin->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbNumMin->SetFrameRect(CGRectZero);
	this->AddChild(m_lbNumMin,1);
	
	m_lbNumMax = new NDUILabel;
	m_lbNumMax->Initialization();
	m_lbNumMax->SetFontSize(15);
	m_lbNumMax->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbNumMax->SetFrameRect(CGRectZero);
	m_lbNumMax->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(m_lbNumMax,1);
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(15);
	m_lbText->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbText->SetFrameRect(CGRectZero);
	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(m_lbText,1);
	
	for (int i=0; i<4; i++) 
	{
		m_line[i] = new NDUILine;
		m_line[i]->Initialization();
		m_line[i]->SetColor(ccc3(42,52,27));
		m_line[i]->SetWidth(1);
		this->AddChild(m_line[i]);
	}	
	
	m_rectState = new NDUIRecttangle;
	m_rectState->Initialization();
	m_rectState->SetColor(ccc4(m_colorState.r, m_colorState.g, m_colorState.b, 255));
	this->AddChild(m_rectState);
	
	m_bSlide = bSlide;
	
	if (m_bSlide) 
	{
		m_rectSlideBG = new NDUIRecttangle;
		m_rectSlideBG->Initialization();
		m_rectSlideBG->SetColor(INTCOLORTOCCC4(0x4f4f4f));
		//m_rectSlide->SetColor(ccc4(m_colorState.r, m_colorState.g, m_colorState.b, 100));
		this->AddChild(m_rectSlideBG);
		
		m_rectSlide = new NDUIRecttangle;
		m_rectSlide->Initialization();
		m_rectSlide->SetColor(ccc4(88, 101, 99, 100));
		//m_rectSlide->SetColor(ccc4(m_colorState.r, m_colorState.g, m_colorState.b, 100));
		this->AddChild(m_rectSlide);
	}
}

void NDUIStateBar::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDUILayer::draw();

	
	CGRect scrRect = this->GetScreenRect();
	
	m_line[0]->SetFromPoint(ccp(scrRect.origin.x, scrRect.origin.y));
	m_line[0]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y));
	
	m_line[1]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y));
	m_line[1]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height));
	
	m_line[2]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height));
	m_line[2]->SetToPoint(ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height));
	
	m_line[3]->SetFromPoint(ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height));
	m_line[3]->SetToPoint(ccp(scrRect.origin.x, scrRect.origin.y));
	
	//画状态
	int iPercent = 0;
	if (m_iMaxNum != 0) 
	{
		iPercent = m_iCurNum * 100 / m_iMaxNum;
	}
	if (iPercent > 100) 
	{
		iPercent = 100;
	}
	if (iPercent < 0) 
	{
		iPercent = 0;
	}
	
	if (m_iPercent != (unsigned int)-1) 
	{
		if (m_iPercent >0 && m_iPercent <= 100) 
		{
			iPercent = m_iPercent;
		}
	}
	
	if ( iPercent >= 0 ) 
	{
		m_rectState->SetColor(ccc4(m_colorState.r, m_colorState.g, m_colorState.b, 255));
		m_rectState->SetFrameRect(CGRectMake(1, 1, (scrRect.size.width-2)*iPercent/100, scrRect.size.height-2));
	}
	
	if (m_bSlide && m_rectSlide) 
	{
		m_rectSlideBG->SetFrameRect(CGRectMake(1, (scrRect.size.height-2)*1/3, (scrRect.size.width-2), (scrRect.size.height-2)*1/3));
		m_rectSlide->SetFrameRect(CGRectMake(1, (scrRect.size.height-2)*1/3, (scrRect.size.width-2)*iPercent/100, (scrRect.size.height-2)*1/3));
	}
	
	if (m_stateNum) 
	{
		CGRect rectParent = GetFrameRect();
		CGRect rect = m_stateNum->GetFrameRect();
		m_stateNum->SetFrameRect(CGRectMake((rectParent.size.width-rect.size.width)/2, (rectParent.size.height-rect.size.height)/2, rect.size.width, rect.size.height));
		m_stateNum->SetVisible(m_bShowNum && this->IsVisibled());
		m_stateNum->EnableDraw(m_bShowNum && this->IsVisibled());
	}
	
	if (!m_bShowPic) 
	{
		m_stateNum->SetVisible(false);
		m_stateNum->EnableDraw(false);
		m_lbText->SetVisible(false);
		if (m_bShowNum) 
		{
			CGRect rectParent = GetFrameRect();
			
			int iWidth = rectParent.size.width, iHeight = rectParent.size.height;
			
			m_lbNumMin->SetVisible(true);
			m_lbNumMax->SetVisible(true);
			
			CGSize sizemin = getStringSize(m_lbNumMin->GetText().c_str(), m_lbNumMin->GetFontSize());
			CGSize sizemax = getStringSize(m_lbNumMax->GetText().c_str(), m_lbNumMax->GetFontSize());
			
			int iStartX = (iWidth - sizemin.width - sizemax.width)/2,
				iStartY = (iHeight -sizemin.height)/2;
			if (iStartX < 0) 
			{
				iStartX = 0;
			}
			if (iStartY < 0) 
			{
				iStartY = 0;
			}
			
			m_lbNumMin->SetFrameRect(CGRectMake(iStartX, iStartY, sizemin.width, iHeight));
			
			iStartY = (iHeight -sizemax.height)/2;
			if (iStartY < 0) 
			{
				iStartY = 0;
			}
			
			m_lbNumMax->SetFrameRect(CGRectMake(iStartX+sizemin.width, iStartY, iWidth, iHeight));
		}
		
		return;
	}
	else 
	{
		m_lbNumMin->SetVisible(false);
		m_lbNumMax->SetVisible(false);
		m_lbText->SetVisible(false);
	}
	
	if (m_bShowLabel && m_lbText) 
	{
		m_lbNumMin->SetVisible(false);
		m_lbNumMax->SetVisible(false);
		m_stateNum->SetVisible(false);
		m_stateNum->EnableDraw(false);
		
		CGSize size = getStringSize(m_lbText->GetText().c_str(), m_lbText->GetFontSize());
		
		CGRect rectParent = GetFrameRect();
		
		int iStartX = (rectParent.size.width - size.width)/2,
		iStartY = (rectParent.size.height -size.height)/2;
		if (iStartX < 0) 
		{
			iStartX = 0;
		}
		if (iStartY < 0) 
		{
			iStartY = 0;
		}
		
		m_lbText->SetFrameRect(CGRectMake(iStartX, iStartY, size.width, size.height));
		m_lbText->SetVisible(true);
	}

}

void NDUIStateBar::SetStateColor(ccColor4B color)
{
	m_colorState = color;
	m_rectState->SetColor(color);
}

void NDUIStateBar::SetNumber(int iCurNum, int iMaxNum, bool bNumPic/*=true*/)
{
	if ( iCurNum < 0 || iCurNum > 65536 ||
		 iMaxNum < 0 || iMaxNum > 65536 ) 
	{
		return;
	}
	
	if (bNumPic) 
	{
		m_stateNum->SetTitleRedTwoNumber(iCurNum, iMaxNum);
	}
	else 
	{
		std::stringstream ssCurNum; ssCurNum << iCurNum << "/";
		m_lbNumMin->SetText(ssCurNum.str().c_str());
		
		std::stringstream ssMaxNum; ssMaxNum << iMaxNum;
		m_lbNumMax->SetText(ssMaxNum.str().c_str());
	}

	m_bShowPic = bNumPic;
	
	m_iCurNum = iCurNum;
	m_iMaxNum = iMaxNum;
}

void NDUIStateBar::ShowNum(bool bShow)
{
	m_bShowNum = bShow;
}

void NDUIStateBar::SetLabelMinNum(ccColor4B color, int num, unsigned int uiFontSize/* = 15*/)
{
	if (m_lbNumMin) 
	{
		m_lbNumMin->SetFontColor(color);
		m_lbNumMin->SetFontSize(uiFontSize);
		std::stringstream ss; ss << num << "/";
		m_lbNumMin->SetText(ss.str().c_str());
		
		m_iCurNum = num;
	}
}

void NDUIStateBar::SetLabelMaxNum(ccColor4B color, int num, unsigned int uiFontSize/* = 15*/)
{
	if (m_lbNumMax) 
	{
		m_lbNumMax->SetFontColor(color);
		m_lbNumMax->SetFontSize(uiFontSize);
		std::stringstream ss; ss << num;
		m_lbNumMax->SetText(ss.str().c_str());
		m_iMaxNum = num;
	}
}

void NDUIStateBar::SetLabel(std::string text, ccColor4B color, unsigned int uiFontSize/*= 15*/)
{
	if (m_lbText) 
	{
		m_lbText->SetText(text.c_str());
		m_lbText->SetFontColor(color);
		m_lbText->SetFontSize(uiFontSize);
		
		m_bShowLabel = true;
	}
}

void NDUIStateBar::SetPercent(unsigned int percent)
{
	m_iPercent = percent;
}

void NDUIStateBar::SetSlideColor(ccColor4B color)
{
	if (m_rectSlide) 
	{
		m_rectSlide->SetColor(color);
	}
}

/////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(NDUIProp, NDUILayer)

NDUIProp::NDUIProp()
{
	
	for (int i = 0; i<4; i++) 
	{
		m_line[i] = NULL;
	}
	
	m_lbKey = NULL;
	m_lbValue = NULL;
	m_lbValueCenter = NULL;
	
	m_bChangeBGColor = true;
}

NDUIProp::~NDUIProp()
{
}

void NDUIProp::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetBackgroundColor(ccc4(226, 229, 218,255));

	for (int i=0; i<4; i++) 
	{
		m_line[i] = new NDUILine;
		m_line[i]->Initialization();
		m_line[i]->SetColor(ccc3(108, 130, 108));
		m_line[i]->SetWidth(1);
		this->AddChild(m_line[i]);
	}

	
	
	m_lbKey = new NDUILabel();
	m_lbKey->Initialization();
	m_lbKey->SetText("");
	m_lbKey->SetFontSize(15);
	m_lbKey->SetFontColor(ccc4(2,2,0,255));
	this->AddChild(m_lbKey);
	
	m_lbValue = new NDUILabel();
	m_lbValue->Initialization();
	m_lbValue->SetText("");
	m_lbValue->SetFontSize(15);
	m_lbValue->SetFontColor(ccc4(2,2,0,255));
	this->AddChild(m_lbValue);
	
	m_lbValueCenter = new NDUILabel();
	m_lbValueCenter->Initialization();
	m_lbValueCenter->SetText("");
	m_lbValueCenter->SetFontSize(15);
	m_lbValueCenter->SetFontColor(ccc4(2,2,0,255));
	this->AddChild(m_lbValueCenter);
}


void NDUIProp::draw()
{
	NDUILayer::draw();
	if (this->IsVisibled()) 
	{
		CGRect scrRect = this->GetScreenRect();
	
		m_line[0]->SetFromPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+1));
		m_line[0]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+1));
		
		m_line[1]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+1));
		m_line[1]->SetToPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+scrRect.size.height-1));
		
		m_line[2]->SetFromPoint(ccp(scrRect.origin.x+scrRect.size.width-1, scrRect.origin.y+scrRect.size.height-1));
		m_line[2]->SetToPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+scrRect.size.height-1));
		
		m_line[3]->SetFromPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+scrRect.size.height-1));
		m_line[3]->SetToPoint(ccp(scrRect.origin.x+1, scrRect.origin.y+1));
		
		if (m_lbKey) 
		{
			m_lbKey->SetTextAlignment(LabelTextAlignmentLeft);
			m_lbKey->SetFrameRect(CGRectMake(10, scrRect.size.height/2-m_lbKey->GetFontSize()/2, 480, scrRect.size.height));
		}
		
		if (m_lbValue) 
		{
			m_lbValue->SetTextAlignment(LabelTextAlignmentRight);
			m_lbValue->SetFrameRect(CGRectMake(0, scrRect.size.height/2-m_lbKey->GetFontSize()/2, scrRect.size.width-5, scrRect.size.height));
		}
		
		if (m_lbValueCenter) 
		{
			m_lbValueCenter->SetTextAlignment(LabelTextAlignmentLeft);
			m_lbValueCenter->SetFrameRect(CGRectMake(scrRect.size.width/2-m_lbKey->GetFontSize()/2, scrRect.size.height/2-m_lbKey->GetFontSize()/2, 480, scrRect.size.height));
		}
		
		ccColor4B color;
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)(this->GetParent()))->GetFocus() == this && m_bChangeBGColor) 
		{
			color = ccc4(255, 255, 0, 255);
		}
		else 
		{
			color = ccc4(231, 231, 222, 255);
		}
		
		this->SetBackgroundColor(color);
		
	}
		
}

void NDUIProp::SetKeyText(std::string text)
{
	if (m_lbKey && !text.empty()) 
	{
		m_lbKey->SetText(text.c_str());
	}
}
void NDUIProp::SetKeyColor(ccColor3B color)
{
	if (m_lbKey) 
	{
		m_lbKey->SetFontColor(ccc4(color.r, color.g, color.b, 255));
	}
}
void NDUIProp::SetValueText(std::string text)
{
	if (m_lbValue && !text.empty()) 
	{
		m_lbValue->SetText(text.c_str());
	}
}
void NDUIProp::SetValueColor(ccColor3B color)
{
	if (m_lbValue) 
	{
		m_lbValue->SetFontColor(ccc4(color.r, color.g, color.b, 255));
	}
}

void NDUIProp::SetCenterValueText(std::string text)
{
	if (m_lbValueCenter && !text.empty()) 
	{
		m_lbValueCenter->SetText(text.c_str());
	}
}
void NDUIProp::SetCenterValueColor(ccColor3B color)
{
	if (m_lbValueCenter) 
	{
		m_lbValueCenter->SetFontColor(ccc4(color.r, color.g, color.b, 255));
	}
}

IMPLEMENT_CLASS(AttrInfo, NDUILayer)

AttrInfo::AttrInfo()
{
	m_btnClose = NULL;
	
	m_lbDesc = NULL;
	
	m_lslText = NULL;
}

AttrInfo::~AttrInfo()
{
}

void AttrInfo::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicture* picBagLeftBg = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	int width = sizeBagLeftBg.width, height = sizeBagLeftBg.height;
	
	this->SetBackgroundImage(picBagLeftBg, true);
	
	m_lbDesc = new NDUILabel;
	m_lbDesc->Initialization();
	m_lbDesc->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbDesc->SetFontSize(14);
	m_lbDesc->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbDesc->SetFrameRect(CGRectMake(17, 10, width-17, 20));
	this->AddChild(m_lbDesc);
	
	m_lslText = new NDUILabelScrollLayer;
	m_lslText->Initialization();
	m_lslText->SetFrameRect(CGRectMake(0, 34, width, height-34));
	m_lslText->SetDelegate(this);
	this->AddChild(m_lslText);
	
	NDPicture *picClose = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("bag_left_close.png"));
	
	CGSize sizeClose = picClose->GetSize();
	
	m_btnClose = new NDUIButton;
	
	m_btnClose->Initialization();
	
	m_btnClose->SetFrameRect(CGRectMake(0, height-sizeClose.height-8, sizeClose.width, sizeClose.height));
	
	m_btnClose->SetImage(picClose, false, CGRectZero, true);
	
	m_btnClose->SetDelegate(this);
	
	this->AddChild(m_btnClose);
}

void AttrInfo::OnClickNDScrollLayer(NDScrollLayer* layer)
{
	if (layer != m_lslText) return;
	
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameUIAttrib))) 
	{ 
		GameUIAttrib *parent = (GameUIAttrib*)(this->GetParent());
		parent->ShowAttrInfo(false);
	}
}

void AttrInfo::OnButtonClick(NDUIButton* button)
{
	if (button != m_btnClose) return ;
	
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameUIAttrib))) 
	{ 
		GameUIAttrib *parent = (GameUIAttrib*)(this->GetParent());
		parent->ShowAttrInfo(false);
	}
	
}

bool AttrInfo::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_lslText) 
	{
		return m_lslText->OnLayerMove(uiLayer, move, distance);
	}
	
	return false;
}

NDUILabel* AttrInfo::GetDescLabel()
{
	return m_lbDesc;
}

void AttrInfo::SetContentText(const char* text)
{
	if (m_lslText)
		m_lslText->SetText(text, 17, 17, 170);
}

/////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(GameUIAttrib, NDUILayer)

GameUIAttrib* GameUIAttrib::s_intance = NULL;

GameUIAttrib::GameUIAttrib()
{
	m_picBasic = NULL; m_picBasicDown = NULL; m_btnBasic = NULL;
	m_picDetail = NULL; m_picDetailDown = NULL; m_btnDetail = NULL;
	m_picAdvance = NULL; m_picAdvanceDown = NULL; m_btnAdvance = NULL;
	
	m_frameRole  = NULL;
	m_lbName = NULL; m_lbLevel = NULL; m_lbNone = NULL;
	m_lbHP = NULL; m_lbMP = NULL; m_lbExp = NULL;
	m_layerRole = NULL;
	m_stateBarHP = NULL; m_stateBarMP = NULL; m_stateBarExp = NULL;

	m_picPropDot =  NULL; m_imagePropDot = NULL;
	m_picMinus = NULL; m_imageMinus = NULL;
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_pointFrame[ePointState] = NULL;
		
		m_btnPointTxt[ePointState] = NULL;
		
		m_btnPointMinus[ePointState] = NULL;
		
		m_btnPointPlus[ePointState] = NULL;
		
		m_btnPointCur[ePointState] = NULL;
		
		m_btnPointTotal[ePointState] = NULL;
		
		m_picPointMinus[ePointState][0] = NULL;
		m_picPointMinus[ePointState][1] = NULL;
		
		m_picPointPlus[ePointState][0] = NULL;
		m_picPointPlus[ePointState][1] = NULL;
	}
	
	m_imageMoney = NULL;
	m_imageEMoney = NULL;
	m_lbMoney = NULL, m_lbEMoney = NULL;
	
	m_enumTBS = eTBS_Basic;
	
	m_tableLayerDetail = NULL;
	m_tableLayerAdvance = NULL;
	
	m_imageNumTotalPoint = NULL; m_imageNUmAllocPoint = NULL;
	m_imageNumMoney = NULL; m_imageNumEMoney = NULL;
	
	m_dlgTip = NULL;
	
	m_iFocusPointType = _stru_point::ps_end;
	
	m_iFocusTitle = eTBS_Basic;
	
	m_lbJunXian = NULL;
	
	//memset(m_imageNumInfo, 0, sizeof(m_imageNumInfo));
	
	memset(m_lbMoneyInfo, 0, sizeof(m_lbMoneyInfo));
	
	m_layerPropAlloc = NULL;
	
	m_layerProp = NULL;
	
	m_lbTotal = NULL;
	
	m_lbAlloc = NULL;
	
	m_btnCommit = NULL;
	
	m_attrInfo = NULL;
	
	m_attrInfoShow = false;
	
	s_intance = this;
} 

GameUIAttrib* GameUIAttrib::GetInstance()
{
	return s_intance;
}

GameUIAttrib::~GameUIAttrib()
{
	SAFE_DELETE(m_picBasic);
	SAFE_DELETE(m_picBasicDown);
	SAFE_DELETE(m_picDetail);
	SAFE_DELETE(m_picDetailDown);
	SAFE_DELETE(m_picAdvance);
	SAFE_DELETE(m_picAdvanceDown);
	SAFE_DELETE(m_picPropDot);
	SAFE_DELETE(m_picMinus);
	//SAFE_DELETE(m_picMoney);
	//SAFE_DELETE(m_picEMoney);
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		SAFE_DELETE(m_picPointMinus[ePointState][0]);
		SAFE_DELETE(m_picPointMinus[ePointState][1]);
		SAFE_DELETE(m_picPointPlus[ePointState][0]);
		SAFE_DELETE(m_picPointPlus[ePointState][1]);
	}
	
	s_intance = NULL;
}

void GameUIAttrib::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	
	m_frameRole = new NDUILayer;
	m_frameRole->Initialization();
	m_frameRole->SetFrameRect(CGRectMake(0,12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	m_frameRole->SetBackgroundImage(picBagLeftBg, true);
	this->AddChild(m_frameRole);
	
	m_lbName = new NDUILabel();
	m_lbName->Initialization();
	m_lbName->SetFontSize(14);
	m_lbName->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbName->SetFontColor(ccc4(187,19,19,255));
	m_lbName->SetFrameRect(CGRectMake(0, 0, sizeBagLeftBg.width, 28));
	m_frameRole->AddChild(m_lbName);
	
	NDPicture* picRoleBg = pool.AddPicture(GetImgPathNew("attr_role_bg.png"));
	
	CGSize sizeRoleBg = picRoleBg->GetSize();
	
	m_layerRole = new NDUILayer;
	m_layerRole->Initialization();
	m_layerRole->SetFrameRect(CGRectMake(0,26, sizeRoleBg.width, sizeRoleBg.height));
	m_layerRole->SetBackgroundImage(picRoleBg, true);
	m_frameRole->AddChild(m_layerRole);

	m_lbLevel = new NDUILabel();
	m_lbLevel->Initialization();
	m_lbLevel->SetText(NDCommonCString("level"));
	m_lbLevel->SetFontSize(13);
	m_lbLevel->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbLevel->SetFontColor(ccc4(187,19,19,255));
	m_lbLevel->SetFrameRect(CGRectMake(4, 5, sizeRoleBg.width, 15));
	m_layerRole->AddChild(m_lbLevel);
	
	int nVipLev = NDPlayer::defaultHero().m_nVipLev;
	m_pLabelVip = new NDUILabel();
	m_pLabelVip->Initialization();
	NDEngine::NDString strText;
	strText.Format("VIP%d", nVipLev);
	m_pLabelVip->SetText(strText.getData());
	m_pLabelVip->SetFontSize(13);
	m_pLabelVip->SetTextAlignment(LabelTextAlignmentRight);
	m_pLabelVip->SetFontColor(ccc4(187,19,19,255));
	m_pLabelVip->SetFrameRect(CGRectMake(50, sizeRoleBg.height-20, sizeRoleBg.width-55, 15));
	m_layerRole->AddChild(m_pLabelVip);
	
	m_lbNone = new NDUILabel();
	m_lbNone->Initialization();
	//m_lbNone->SetText(NDCommonCString("wu"));
	m_lbNone->SetFontSize(13);
	m_lbNone->SetTextAlignment(LabelTextAlignmentRight);
	m_lbNone->SetFontColor(ccc4(187,19,19,255));
	m_lbNone->SetFrameRect(CGRectMake(95, 5, 90, 15));
	m_layerRole->AddChild(m_lbNone);

	
	m_lbJunXian = new NDUILabel();
	m_lbJunXian->Initialization();
	m_lbJunXian->SetFontSize(13);
	m_lbJunXian->SetTextAlignment(LabelTextAlignmentRight);
	m_lbJunXian->SetFontColor(ccc4(187,19,19,255));
	m_lbJunXian->SetFrameRect(CGRectMake(95, 25, 90, 15));
	m_layerRole->AddChild(m_lbJunXian);
	
	NDPlayer& player = NDPlayer::defaultHero();
	NDPicture *picCamp = NULL;
	switch (player.swCamp) 
	{
		case CAMP_TYPE_TANG:
			picCamp = pool.AddPicture(GetImgPathNew("tang.png"));
			break;
		case CAMP_TYPE_SUI:
			picCamp = pool.AddPicture(GetImgPathNew("sui.png"));
			break;
		case CAMP_TYPE_TU:
			picCamp = pool.AddPicture(GetImgPathNew("tu.png"));
			break;
		default:
			break;
	}
	
	if (picCamp) 
	{
		CGSize size = picCamp->GetSize();
		NDUIImage *img = new NDUIImage;
		img->Initialization();
		img->SetPicture(picCamp, true);
		img->SetFrameRect(CGRectMake(0, sizeRoleBg.width-size.width, size.width, size.height));
		m_layerRole->AddChild(img);
	}
	
	/* todo
	m_GameRoleNode = new GameRoleNode;
	m_GameRoleNode->Initialization();
	//以下两行固定用法
	m_GameRoleNode->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	m_GameRoleNode->SetDisplayPos(ccp(108,173));
	m_layerRole->AddChild(m_GameRoleNode);
	*/
	
	m_lbHP = new NDUILabel();
	m_lbHP->Initialization();
	m_lbHP->SetText("HP");
	m_lbHP->SetFontSize(13);
	m_lbHP->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbHP->SetFontColor(ccc4(187,19,19,255));
	m_lbHP->SetFrameRect(CGRectMake(8, 146, 480, 15));
	m_frameRole->AddChild(m_lbHP);
	
	m_lbMP = new NDUILabel();
	m_lbMP->Initialization();
	m_lbMP->SetText("MP");
	m_lbMP->SetFontSize(13);
	m_lbMP->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbMP->SetFontColor(ccc4(187,19,19,255));
	m_lbMP->SetFrameRect(CGRectMake(8, 164, 480, 15));
	m_frameRole->AddChild(m_lbMP);
	
	m_lbExp = new NDUILabel();
	m_lbExp->Initialization();
	m_lbExp->SetText("Exp");
	m_lbExp->SetFontSize(13);
	m_lbExp->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbExp->SetFontColor(ccc4(187,19,19,255));
	m_lbExp->SetFrameRect(CGRectMake(8, 183, 480, 15));
	m_frameRole->AddChild(m_lbExp);
	
	NDHPStateBar* stateBarHP = new NDHPStateBar();
	stateBarHP->Initialization(ccp(33, 149));
	m_frameRole->AddChild(stateBarHP);
	m_stateBarHP = stateBarHP;
	
	NDMPStateBar* stateBarMP = new NDMPStateBar();
	stateBarMP->Initialization(ccp(33, 167));
	m_frameRole->AddChild(stateBarMP);
	m_stateBarMP = stateBarMP;
	
	NDExpStateBar* stateBarExp = new NDExpStateBar();
	stateBarExp->Initialization(ccp(33, 187));
	m_frameRole->AddChild(stateBarExp);
	m_stateBarExp = stateBarExp;
	
	NDPicture *picFrameMoney = pool.AddPicture(GetImgPathNew("money_bg.png"), 197, 45);
	NDUIImage *frameMoney = new NDUIImage;
	frameMoney->Initialization();
	frameMoney->SetFrameRect(CGRectMake(0, 205, 197, 45));
	frameMoney->SetPicture(picFrameMoney, true);
	m_frameRole->AddChild(frameMoney);
	
	/*
	m_imageNumMoney = new ImageNumber;
	m_imageNumMoney->Initialization();
	m_imageNumMoney->SetTitleRedNumber(100);
	m_imageNumMoney->SetFrameRect(CGRectMake(57, 138, 60, 11));
	m_frameRole->AddChild(m_imageNumMoney);
	
	m_imageNumEMoney = new ImageNumber;
	m_imageNumEMoney->Initialization();
	m_imageNumEMoney->SetTitleRedNumber(100);
	m_imageNumEMoney->SetFrameRect(CGRectMake(57, 159, 60, 11));
	m_frameRole->AddChild(m_imageNumEMoney);
	*/
	
	NDPicture *picEMoney = pool.AddPicture(GetImgPathNew("bag_bagemoney.png"));
	
	NDPicture *picMoney = pool.AddPicture(GetImgPathNew("bag_bagmoney.png"));
	
	NDPicture *picJiFeng = pool.AddPicture(GetImgPathNew("bag_jifeng.png"));
	
	//unsigned int interval = 8;
	
	NDPicture* tmpPics[3];
	
	tmpPics[0] = picEMoney;
	
	tmpPics[1] = picMoney;
	
	tmpPics[2] = picJiFeng;
	
	for (int i = 0; i < 3; i++) 
	{
		CGSize sizePic = tmpPics[i]->GetSize();
		int startX = i != 1 ? 7 : 102,
			startY = i != 2 ? 8 : 26;
		//int height = PictureNumber::SharedInstance()->GetSmallGoldSize().height;
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetPicture(tmpPics[i], true);
		image->SetFrameRect(CGRectMake(startX, startY, sizePic.width,sizePic.height));
		frameMoney->AddChild(image);
		
		//m_imageNumInfo[i] = new ImageNumber;
		//m_imageNumInfo[i]->Initialization();
		//m_imageNumInfo[i]->SetFrameRect(CGRectMake(startX+sizePic.width+2, startY, 75, height));
		//frameMoney->AddChild(m_imageNumInfo[i]);
		m_lbMoneyInfo[i] = new NDUILabel;
		m_lbMoneyInfo[i]->Initialization();
		m_lbMoneyInfo[i]->SetText("Exp");
		m_lbMoneyInfo[i]->SetFontSize(13);
		m_lbMoneyInfo[i]->SetTextAlignment(LabelTextAlignmentLeft);
		m_lbMoneyInfo[i]->SetFontColor(ccc4(255,255,255,255));
		m_lbMoneyInfo[i]->SetFrameRect(CGRectMake(startX+sizePic.width+2, startY, 480, 15));
		frameMoney->AddChild(m_lbMoneyInfo[i]);
	}
	
	InitPropAlloc();
	/*
	m_picMoney = NDPicturePool::DefaultPool()->AddPicture(money_image);
	m_picMoney->Cut(CGRectMake(0, 0, 16, 16)); 
	m_picEMoney = NDPicturePool::DefaultPool()->AddPicture(emoney_image);
	m_picEMoney->Cut(CGRectMake(0, 0, 16, 16));
	
	m_imageMoney =  new NDUIImage;
	m_imageMoney->Initialization();
	m_imageMoney->SetPicture(m_picMoney);
	m_imageMoney->SetFrameRect(CGRectMake(6, 138, 16, 16));
	m_frameRole->AddChild(m_imageMoney);
	m_imageEMoney =  new NDUIImage;
	m_imageEMoney->Initialization();
	m_imageEMoney->SetPicture(m_picEMoney);
	m_imageEMoney->SetFrameRect(CGRectMake(6, 160, 16, 16));
	m_frameRole->AddChild(m_imageEMoney);
	
	m_lbMoney = new NDUILabel();
	m_lbMoney->Initialization();
	m_lbMoney->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbMoney->SetText("银两");
	m_lbMoney->SetFrameRect(CGRectMake(24, 138, 480, 13));
	m_lbMoney->SetFontSize(13);
	m_lbMoney->SetFontColor(ccc4(107, 44, 0, 255));
	m_frameRole->AddChild(m_lbMoney);
	
	m_lbEMoney = new NDUILabel();
	m_lbEMoney->Initialization();
	m_lbEMoney->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbEMoney->SetText("元宝");
	m_lbEMoney->SetFrameRect(CGRectMake(24, 159, 480, 13));
	m_lbEMoney->SetFontSize(13);
	m_lbEMoney->SetFontColor(ccc4(107, 44, 0, 255));	
	m_frameRole->AddChild(m_lbEMoney);
	*/
	
	InitProp();
	
	UpdateGameUIAttrib();
	UpdateMoney();
	
	m_attrInfo = new AttrInfo;
	m_attrInfo->Initialization();
	m_attrInfo->SetFrameRect(CGRectMake(0,12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	this->AddChild(m_attrInfo);
	
	NDString strV1, strV2, strV3, strV4, strV5, strV6, strV7, strV8, strV9, strV10;
	strV1.Format(NDCommonCString("VipExplain1"), "\n", "\n");
	strV2.Format(NDCommonCString("VipExplain2"), "\n", "\n", "\n");
	strV3.Format(NDCommonCString("VipExplain3"), "\n", "\n");
	strV4.Format(NDCommonCString("VipExplain4"), "\n", "\n");
	strV5.Format(NDCommonCString("VipExplain5"), "\n", "\n");
	strV6.Format(NDCommonCString("VipExplain6"), "\n", "\n");
	strV7.Format(NDCommonCString("VipExplain7"), "\n", "\n");
	strV8.Format(NDCommonCString("VipExplain8"), "\n", "\n", "\n");
	strV9.Format(NDCommonCString("VipExplain9"), "\n", "\n");
	strV10.Format(NDCommonCString("VipExplain10"), "\n", "\n");
	
	NDString strVip;
	strVip.Format("%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", 
				  strV1.getData(),
				  strV2.getData(),
				  strV3.getData(),
				  strV4.getData(),
				  strV5.getData(),
				  strV6.getData(),
				  strV7.getData(),
				  strV8.getData(),
				  strV9.getData(),
				  strV10.getData());
	strPorpAdvanceInfo[ePA_Vip] = strVip.getData();
}

void GameUIAttrib::draw()
{	
	if (m_enumTBS == eTBS_Detail) 
	{
		ShowDetail();
	}
	else if (m_enumTBS == eTBS_Advance)
	{
		ShowAdvance();
	}
	else 
	{
		ShowBasic();
	}
	
	//NDUIMenuLayer::draw();
	
	//DrawRecttangle(CGRectMake(0, GetTitleHeight(), 480, GetTextHeight()), ccc4(255, 255, 255, 255));
}

void GameUIAttrib::OnButtonClick(NDUIButton* button)
{
	/*else if ( button == this->GetCancelBtn() )
	{
		NDDirector::DefaultDirector()->PopScene();
	}*/
	if (!button) {
		return;
	}
	if ( button == m_btnCommit)
	{
		if (m_struPoint.iAlloc > 0 && m_struPoint.VerifyAllocPoint() ) 
		{
			m_dlgTip = new NDUIDialog;
			m_dlgTip->Initialization();
			m_dlgTip->SetDelegate(this);
			std::stringstream str;
			str << NDCommonCString("ModifyAttrTip") << m_struPoint.iTotal - m_struPoint.iAlloc;
			m_dlgTip->Show(NDCommonCString("tip"), str.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"),NULL);
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (button->GetParent() && button->GetParent() == m_pointFrame[ePointState]) 
		{
			if (m_pointFrame[ePointState] && !m_pointFrame[ePointState]->IsFocus())
			{
				changePointFocus(ePointState);
				UpdateSlideBar(ePointState);
				return;
			}
			break;
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointMinus[ePointState] == button) 
		{
			if (m_struPoint.iAlloc > 0 && m_struPoint.m_psProperty[ePointState].iPoint >0) 
			{
				m_struPoint.iAlloc -= 1; m_struPoint.m_psProperty[ePointState].iPoint -= 1;
				
				UpdatePorpText(ePointState);
				
				UpdateSlideBar(ePointState);
				
				UpdatePorpAlloc();
			}
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointPlus[ePointState] == button) 
		{
			if (m_struPoint.iTotal >= 1 && m_struPoint.iTotal >= m_struPoint.iAlloc+1) 
			{
				m_struPoint.m_psProperty[ePointState].iPoint += 1;
				m_struPoint.iAlloc += 1;
				
				UpdatePorpText(ePointState);
				
				UpdateSlideBar(ePointState);
				
				UpdatePorpAlloc();
			}
		}
	}
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		if (m_btnPointTxt[ePointState] == button
			|| m_btnPointCur[ePointState] == button
			|| m_btnPointTotal[ePointState] == button) 
		{
			showDialog(strBtnPoint[ePointState][0].c_str(), strBtnPoint[ePointState][1].c_str());
			return;
		}
	}
}

void GameUIAttrib::OnPropSlideBarChange(NDPropSlideBar* bar, int change)
{
	if (bar == m_slideBar)
	{
		m_struPoint.SetAllocPoint(_stru_point::enumPointState(m_iFocusPointType), change);
		
		UpdatePorpText(m_iFocusPointType);
		
		UpdatePorpAlloc();
	}
}

void GameUIAttrib::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
	
	if (visible && m_attrInfo)
		m_attrInfo->SetVisible(m_attrInfoShow);
		
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene)))
	{
		((PlayerInfoScene*)scene)->DrawRole(visible && !m_attrInfoShow, ccp(56, 172));
	}
}

void GameUIAttrib::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tableLayerDetail && m_tableLayerDetail->GetDataSource())
	{
		
		NDSection *section = m_tableLayerDetail->GetDataSource()->Section(0);
		if ( section && section->Count() ==  ePA_End + ePD_End && cellIndex < ePA_End + ePD_End) 
		{
			if (cell && cell->IsKindOfClass(RUNTIME_CLASS(NDPropCell)))					
			{	
				if (ePA_Lover == cellIndex - ePD_End) 
				{
					ShowAttrInfo(false);
					
					return;
				}
				
				std::string str = "";
				if (cellIndex >= ePD_End && cellIndex - ePD_End < ePA_End) 
				{
					str = strPorpAdvanceInfo[cellIndex - ePD_End];
				}
				else if (cellIndex < ePD_End)
				{
					str = strPropDetailInfo[cellIndex];
				}

				NDPropCell *prop = (NDPropCell*)cell;								
				NDUILabel *lb = prop->GetKeyText();
				if (lb && m_attrInfo && m_attrInfo->GetDescLabel())
				{
					m_attrInfo->GetDescLabel()->SetText(lb->GetText().c_str());
					m_attrInfo->SetContentText(str.c_str());
					
					ShowAttrInfo(true);
				}
			}	
		}
	}
}

void GameUIAttrib::UpdateGameUIAttrib()
{
	NDPlayer& player = NDPlayer::defaultHero();
	//注释,现在计算全由服务器下发
	
	//EquipPropAddtions equipAdds = ItemMgrObj.GetEquipAddtionProp();
	m_lbName->SetText(player.m_name.c_str());
	stringstream ssLevel; ssLevel << NDCommonCString("level") << (int)(player.level);
	m_lbLevel->SetText(ssLevel.str().c_str());
	m_stateBarHP->SetNumber(player.life, player.maxLife);
	m_stateBarMP->SetNumber(player.mana, player.maxMana);
	m_stateBarExp->SetNumber(player.exp, player.lvUpExp);
	
	if (!this->IsVisibled())
	{
		m_stateBarHP->SetVisible(false);
		m_stateBarExp->SetVisible(false);
		m_stateBarMP->SetVisible(false);
	}
	
	m_struPoint.iTotal = player.restPoint;
	m_struPoint.iAlloc = 0;
	m_struPoint.m_psProperty[_stru_point::ps_liliang].iPoint = 0;
	m_struPoint.m_psProperty[_stru_point::ps_liliang].iFix = player.phyPoint;
	m_struPoint.m_psProperty[_stru_point::ps_liliang].iAdd = player.m_caclData.extra_phyPoint;//equipAdds.iPowerAdd;
	
	m_struPoint.m_psProperty[_stru_point::ps_tizhi].iPoint = 0;
	m_struPoint.m_psProperty[_stru_point::ps_tizhi].iFix = player.defPoint;
	m_struPoint.m_psProperty[_stru_point::ps_tizhi].iAdd = player.m_caclData.extra_defPoint;//equipAdds.iTiZhiAdd;
	
	m_struPoint.m_psProperty[_stru_point::ps_minjie].iPoint = 0;
	m_struPoint.m_psProperty[_stru_point::ps_minjie].iFix = player.dexPoint;
	m_struPoint.m_psProperty[_stru_point::ps_minjie].iAdd = player.m_caclData.extra_dexPoint;//equipAdds.iMinJieAdd;
	
	m_struPoint.m_psProperty[_stru_point::ps_zhili].iPoint = 0;
	m_struPoint.m_psProperty[_stru_point::ps_zhili].iFix = player.magPoint;
	m_struPoint.m_psProperty[_stru_point::ps_zhili].iAdd = player.m_caclData.extra_magPoint;//equipAdds.iZhiLiAdd;
	
	/*
	m_imageNumTotalPoint->SetTitleRedNumber(m_struPoint.iTotal);
	m_imageMinus->SetVisible(false);
	m_imageNUmAllocPoint->SetTitleRedNumber(m_struPoint.iAlloc);
	*/
	
	for (int i =_stru_point::ps_begin; i<_stru_point::ps_end; i++) 
	{
		UpdatePorpText(i);
		
		SetPropTextFocus(i, i == m_iFocusPointType);
	}
	
	if (m_lbTotal)
	{
		std::stringstream ss; ss << m_struPoint.iTotal;
		m_lbTotal->SetText(ss.str().c_str());
	}
	
	if (m_lbAlloc)
	{
		std::stringstream ss; ss << m_struPoint.iAlloc;
		m_lbAlloc->SetText(ss.str().c_str());
	}
	
	if (m_lbNone)
	{
		m_lbNone->SetText(player.synName.c_str());
	}
	
	if (m_lbJunXian) 
	{
		m_lbJunXian->SetText(player.synRankStr.c_str());
	}
	
	UpdateSlideBar(m_iFocusPointType);
	
	/*
	m_imageNumMoney->SetTitleRedNumber(player.money);
	m_imageNumEMoney->SetTitleRedNumber(player.eMoney);
	*/
	 
	CaclAndUpdateDetail();
	CaclAndUpdateAdvance();
}

void GameUIAttrib::ShowBasic()
{
	return;
	//隐藏银两与元宝
	m_lbMoney->SetVisible(false); m_lbEMoney->SetVisible(false);
	m_imageMoney->SetVisible(false); m_imageEMoney->SetVisible(false);
	m_imageNumMoney->SetVisible(false); m_imageNumEMoney->SetVisible(false);
	
	//隐藏tablelayer
	m_tableLayerDetail->SetVisible(false);
	m_tableLayerAdvance->SetVisible(false);
	
	//显示血条相关
	m_lbHP->SetVisible(true); m_lbMP->SetVisible(true); m_lbExp->SetVisible(true);
	m_stateBarHP->SetVisible(true); m_stateBarMP->SetVisible(true); m_stateBarExp->SetVisible(true);
	
	
	//显示属性
	m_imagePropDot->SetVisible(true);
	m_imageNUmAllocPoint->SetVisible(true); m_imageNUmAllocPoint->SetVisible(true);
	
	if ( m_struPoint.iAlloc != 0 ) 
	{
		m_imageMinus->SetVisible(true);
	}
	else 
	{
		m_imageMinus->SetVisible(false);
	}
	
	m_imageNUmAllocPoint->SetTitleRedNumber(m_struPoint.iAlloc);

	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_pointFrame[ePointState]->SetVisible(true);
	}
}
void GameUIAttrib::ShowDetail()
{	
	return;
	//隐藏银两与元宝
	m_lbMoney->SetVisible(false); m_lbEMoney->SetVisible(false);
	m_imageMoney->SetVisible(false); m_imageEMoney->SetVisible(false);
	m_imageNumMoney->SetVisible(false); m_imageNumEMoney->SetVisible(false);
	
	
	//隐藏属性
	m_imagePropDot->SetVisible(false);m_imageMinus->SetVisible(false);m_imageNUmAllocPoint->SetVisible(false);
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_pointFrame[ePointState]->SetVisible(false);
	}
	//隐藏tablelayer
	m_tableLayerAdvance->SetVisible(false);
	
	//显示血条相关
	m_lbHP->SetVisible(true); m_lbMP->SetVisible(true); m_lbExp->SetVisible(true);
	m_stateBarHP->SetVisible(true); m_stateBarMP->SetVisible(true); m_stateBarExp->SetVisible(true);
	
	//显示tablelayer
	m_tableLayerDetail->SetVisible(true);
	
}
void GameUIAttrib::ShowAdvance()
{
	return;
	//先隐藏血条相关
	m_lbHP->SetVisible(false); m_lbMP->SetVisible(false); m_lbExp->SetVisible(false);
	m_stateBarHP->SetVisible(false); m_stateBarMP->SetVisible(false); m_stateBarExp->SetVisible(false);
	//隐藏属性
	m_imagePropDot->SetVisible(false);m_imageMinus->SetVisible(false);m_imageNUmAllocPoint->SetVisible(false);
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_pointFrame[ePointState]->SetVisible(false);
	}
	//隐藏tablelayer
	m_tableLayerDetail->SetVisible(false);
	//显示银两与元宝
	m_lbMoney->SetVisible(true); m_lbEMoney->SetVisible(true);
	m_imageMoney->SetVisible(true); m_imageEMoney->SetVisible(true);
	m_imageNumMoney->SetVisible(true); m_imageNumEMoney->SetVisible(true);
	
	//显示tablelayer
	m_tableLayerAdvance->SetVisible(true);
}

void GameUIAttrib::CaclAndUpdateDetail()
{
	/*
	int curLiliang = liliang + liliangAdd + liliangAdd2; // liliangAdd表额外所有力量属性
	int curTizhi = tizhi + tizhiAdd + tizhiAdd2;// tizhiAdd表额外所有体质属性
	int curMinjie = minjie + minjieAdd + minjieAdd2;// minjieAdd表额外所有敏捷属性
	int curFashu = fashu + fashuAdd + fashuAdd2;// fashuAdd表额外所有法术属性
	*/
/* 由服务端计算,所以注释
	NDPlayer::defaultHero().CaclEquipEffect();
	int curLiliang = m_struPoint.GetPoint(_stru_point::ps_liliang);
	int curTizhi = m_struPoint.GetPoint(_stru_point::ps_tizhi);
	int curMinjie = m_struPoint.GetPoint(_stru_point::ps_minjie);
	int curFashu = m_struPoint.GetPoint(_stru_point::ps_zhili);
	int speed = curMinjie + (curLiliang + curTizhi) / 10 + NDPlayer::defaultHero().eAtkSpd;
	int phyAtkMax = curLiliang * 3 + curMinjie * 2 + NDPlayer::defaultHero().eAtk;
	//+ ManualRole.wuGongAdd; :状态功能做了，再完善这吧
	int phyDef = curTizhi * 6 + curMinjie * 0 + curLiliang * 0 + NDPlayer::defaultHero().eDef;
	//+ ManualRole.wuFangAdd; :状态功能做了，再完善这吧
	int magAtk = curFashu * 4 + NDPlayer::defaultHero().eSkillAtk; 
	//+ ManualRole.faGongAdd;  :状态功能做了，再完善这吧
	int magDef = curFashu * 4 / 10 + NDPlayer::defaultHero().eSkillDef;
	//+ ManualRole.faFangAdd; :状态功能做了，再完善这吧
	int phyHitRate = NDPlayer::defaultHero().ePhyHit;
	//+ ManualRole.wuLiMingZhongAdd;// 物理命中
	int dodge = curMinjie * 5 / 10 + NDPlayer::defaultHero().eDodge;
	// + ManualRole.sanBiAdd; // 闪避 :状态功能做了，再完善这吧
	int hardAtk = NDPlayer::defaultHero().eHardAtk;
	// + ManualRole.baoJiAdd; // 暴击 :状态功能做了，再完善这吧
*/
	NDPlayer& player = NDPlayer::defaultHero();
	
#define FASTASSIGN(enum,value) \
	do \
	{ \
		stringstream ss; \
		ss << value; \
		UpdateDetailData(enum, ss.str().c_str()); \
	} while (0);
	
	FASTASSIGN(ePD_speed, player.m_caclData.atk_speed)
	FASTASSIGN(ePD_PhycialAttack, player.m_caclData.phy_atk)
	FASTASSIGN(ePD_MagicAttack, player.m_caclData.mag_atk)
	FASTASSIGN(ePD_PhycialDef, player.m_caclData.phy_def)
	FASTASSIGN(ePD_MagicDef, player.m_caclData.mag_def)
	FASTASSIGN(ePD_MagicHit, player.m_caclData.hitrate)
	FASTASSIGN(ePD_Dodge, player.m_caclData.dodge)
	FASTASSIGN(ePD_SuperHit, player.m_caclData.hardhit)
	FASTASSIGN(ePD_LinQi, player.iSkillPoint)
#undef FASTASSIGN
}

void GameUIAttrib::CaclAndUpdateAdvance()
{
	static std::string strCamp[CAMP_TYPE_END]=
	{
		NDCommonCString("ZhongLi"), 
		NDCommonCString("tang"), 
		NDCommonCString("campJiang"), 
		NDCommonCString("TuJue"), 
		NDCommonCString("WaJun"), 
		NDCommonCString("WangJun")
	};
	
	NDPlayer& player = NDPlayer::defaultHero();
	int camp = player.camp;
	if (camp < CAMP_TYPE_NONE || camp >= CAMP_TYPE_END)
	{
		camp = CAMP_TYPE_NONE;
	}
	
	
#define FASTASSIGN(enum,value) \
	do \
	{ \
		stringstream ss; \
		ss << value; \
		UpdateAdvanceData(enum, ss.str().c_str()); \
	} while (0);
	
	FASTASSIGN(ePa_JiFeng, NDPlayer::defaultHero().jifeng);
	UpdateAdvanceData(ePA_Camp, strCamp[camp]);
	if (NDPlayer::defaultHero().synName != "")
		UpdateAdvanceData(ePA_JunTuan, NDPlayer::defaultHero().synName);
	else
		UpdateAdvanceData(ePA_JunTuan, NDCommonCString("wu"));
	UpdateAdvanceData(ePA_JunXian, NDPlayer::defaultHero().rank);
	FASTASSIGN(ePA_Honer, NDPlayer::defaultHero().honour)
	FASTASSIGN(ePA_CountryReputation, NDPlayer::defaultHero().swGuojia)
	FASTASSIGN(ePA_CampReputation, NDPlayer::defaultHero().swCamp)
	FASTASSIGN(ePA_PK, NDPlayer::defaultHero().pkPoint)
	if (NDPlayer::defaultHero().loverName != "")
		FASTASSIGN(ePA_Lover, NDPlayer::defaultHero().loverName)
	else
		FASTASSIGN(ePA_Lover, NDCommonCString("wu"))

	std::stringstream ss;
	ss << NDPlayer::defaultHero().activityValue << "/" << NDPlayer::defaultHero().activityValueMax;
	UpdateAdvanceData(ePA_Activity, ss.str());
	
	FASTASSIGN(ePA_Vip, NDPlayer::defaultHero().m_nVipLev);
	
	//FASTASSIGN(ePA_Lover, NDPlayer::defaultHero().) // 等待伴侣系统完善后再做
#undef FASTASSIGN
}

void GameUIAttrib::UpdateDetailData(int eProp, std::string value)
{
	if (!m_tableLayerDetail) return;
	NDSection *section = m_tableLayerDetail->GetDataSource()->Section(0);
	if ( section->Count() !=  ePD_End + ePA_End) 
	{
		NDLog(@"GameAttribUI:UpdateDetailData 界面更新出错!!!");
	}
	else 
	{
		NDUINode *node = section->Cell(eProp);								
		if (node && node->IsKindOfClass(RUNTIME_CLASS(NDPropCell)))					
		{																	
			NDPropCell *prop = (NDPropCell*)node;								
			NDUILabel *lb = prop->GetValueText();
			if (lb)
				lb->SetText(value.c_str());
		}																	
		else																
		{																	
			NDLog(@"GameAttribUI:UpdateDetailData 界面更新出错,枚举值[%d]!!!", eProp);	
		}
	}
}

void GameUIAttrib::UpdateAdvanceData(int eProp, std::string value)
{
	if (!m_tableLayerDetail) return;
	
	NDSection *section = m_tableLayerDetail->GetDataSource()->Section(0);
	if ( section->Count() !=  ePA_End + ePD_End) 
	{
		NDLog(@"GameAttribUI:UpdateAdvanceData 界面更新出错!!!");
	}
	else 
	{
		eProp += ePD_End;
		NDUINode *node = section->Cell(eProp);								
		if (node && node->IsKindOfClass(RUNTIME_CLASS(NDPropCell)))					
		{																	
			NDPropCell *prop = (NDPropCell*)node;								
			NDUILabel *lb = prop->GetValueText();
			if (lb)
				lb->SetText(value.c_str());										
		}																	
		else																
		{																	
			NDLog(@"GameAttribUI:UpdateAdvanceData 界面更新出错,枚举值[%d]!!!", eProp);	
		}
	}
}

void GameUIAttrib::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (m_dlgTip) 
	{
		m_dlgTip->Close();
		m_dlgTip = NULL;
	}
	
	// 发送加属性点消息
	NDTransData bao(_MSG_CHGPOINT);
	/*
	 char PHY_POINT = 0x01;
	 char DEF_POINT = 0x02;
	 char DEX_POINT = 0x04;
	 char MAG_POINT = 0x08;*/
	static char upArray[_stru_point::ps_end] =
	{ 0x01, 0x02, 0x04, 0x08 };
	unsigned char upfiled = 0;
	for (int i = _stru_point::ps_begin; i<_stru_point::ps_end; i++) 
	{
		if (m_struPoint.m_psProperty[i].iPoint!=0) 
		{
			upfiled |= upArray[i];
		}
	}
	
	bao << upfiled;
	
	for (int i = _stru_point::ps_begin; i<_stru_point::ps_end; i++) 
	{
		if (m_struPoint.m_psProperty[i].iPoint!=0) 
		{
			bao << (unsigned short)(m_struPoint.m_psProperty[i].iPoint);
		}
	}
	
	// 属性更改缓存赶来
	NDPlayer::defaultHero().iTmpPhyPoint = m_struPoint.m_psProperty[_stru_point::ps_liliang].iPoint; 
	NDPlayer::defaultHero().iTmpDexPoint = m_struPoint.m_psProperty[_stru_point::ps_minjie].iPoint;
	NDPlayer::defaultHero().iTmpMagPoint = m_struPoint.m_psProperty[_stru_point::ps_zhili].iPoint;
	NDPlayer::defaultHero().iTmpDefPoint = m_struPoint.m_psProperty[_stru_point::ps_tizhi].iPoint;
	NDPlayer::defaultHero().iTmpRestPoint = m_struPoint.iTotal - m_struPoint.iAlloc;
	
	// 属性改吧,按ME的做法
	NDPlayer::defaultHero().phyPoint += NDPlayer::defaultHero().iTmpPhyPoint;
	NDPlayer::defaultHero().dexPoint += NDPlayer::defaultHero().iTmpDexPoint;
	NDPlayer::defaultHero().magPoint += NDPlayer::defaultHero().iTmpMagPoint;
	NDPlayer::defaultHero().defPoint += NDPlayer::defaultHero().iTmpDefPoint;
	NDPlayer::defaultHero().restPoint = NDPlayer::defaultHero().iTmpRestPoint;
	
	NDDataTransThread::DefaultThread()->GetSocket()->Send(&bao);
	
	if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		((GameScene*)(this->GetParent()))->SetUIShow(false);
		this->RemoveFromParent(true);
	}
	
}

bool GameUIAttrib::changePointFocus(int iPointType)
{
	if (iPointType < _stru_point::ps_begin || iPointType >= _stru_point::ps_end )
	{
		return false;
	}
	
	if (m_iFocusPointType == iPointType)
	{
		return false;
	}
	
	if (m_pointFrame[iPointType])
		m_pointFrame[iPointType]->SetLayerFocus(true);
	if (m_pointFrame[m_iFocusPointType])
		m_pointFrame[m_iFocusPointType]->SetLayerFocus(false);
	
	SetPlusOrMinusPicture(iPointType, true, true);
	SetPlusOrMinusPicture(iPointType, false, true);
	
	SetPlusOrMinusPicture(m_iFocusPointType, true, false);
	SetPlusOrMinusPicture(m_iFocusPointType, false, false);
	
	SetPropTextFocus(iPointType, true);
	SetPropTextFocus(m_iFocusPointType, false);
	
		
	m_iFocusPointType = iPointType;
	
	return true;
}

void GameUIAttrib::changeTitleFocus(int iTitleType)
{
	if (iTitleType < eTBS_Begin || iTitleType >= eTBS_End)
		return;
	
	if ( m_enumTBS == iTitleType ) return;
	
	changeTitleImage(m_enumTBS,false);
	changeTitleImage(iTitleType, true);
}

void GameUIAttrib::changeTitleImage(int iTitleType, bool bFocus)
{
	if (iTitleType == eTBS_Basic && m_btnBasic)
	{
		if (bFocus && m_picBasicDown)
		{
			m_btnBasic->SetImage(m_picBasicDown);
		}
		else if (m_picBasic)
		{
			m_btnBasic->SetImage(m_picBasic);
		}

	}
	else if (iTitleType == eTBS_Detail && m_btnDetail)
	{
		if (bFocus && m_picDetailDown)
		{
			m_btnDetail->SetImage(m_picDetailDown);
		}
		else if (m_picDetail)
		{
			m_btnDetail->SetImage(m_picDetail);
		}
	}
	else if (iTitleType == eTBS_Advance && m_btnAdvance)
	{
		if (bFocus && m_picAdvanceDown)
		{
			m_btnAdvance->SetImage(m_picAdvanceDown);
		}
		else if (m_picAdvance)
		{
			m_btnAdvance->SetImage(m_picAdvance);
		}
	}

}

void GameUIAttrib::InitPropAlloc()
{
	m_layerPropAlloc = new NDUILayer;
	
	m_layerPropAlloc->Initialization();
	
	int width = 252;//, height = 274;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	/*m_picPropDot = NDPicturePool::DefaultPool()->AddPicture(title_image);
	m_picPropDot->Cut(CGRectMake(160, 5, 108, 15));
	
	m_imagePropDot = new NDUIImage;
	m_imagePropDot->Initialization();
	m_imagePropDot->SetPicture(m_picPropDot);
	m_imagePropDot->SetFrameRect(CGRectMake(219, 62, 108, 15));
	this->AddChild(m_imagePropDot);*/
	
	NDUILayer *layer = new NDUILayer;
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(6, 17, width-10, 18));
	layer->SetBackgroundColor(ccc4(127, 98, 56, 255));
	layer->SetTouchEnabled(false);
	m_layerPropAlloc->AddChild(layer);
	
	NDUILabel *text = new NDUILabel;
	text->Initialization();
	text->SetFontSize(14);
	text->SetFontColor(ccc4(255, 237, 46, 255));
	text->SetTextAlignment(LabelTextAlignmentLeft);
	text->SetText(NDCommonCString("CanAllocAttr"));
	text->SetFrameRect(CGRectMake(7, 2,  width-10, 14));
	layer->AddChild(text);
	/*
	m_imageNumTotalPoint = new ImageNumber;
	m_imageNumTotalPoint->Initialization();
	m_imageNumTotalPoint->SetTitleRedNumber(0);
	m_imageNumTotalPoint->SetFrameRect(CGRectMake(334, 62, 16, 8));
	this->AddChild(m_imageNumTotalPoint);
	
	m_imageNUmAllocPoint = new ImageNumber;
	m_imageNUmAllocPoint->Initialization();
	m_imageNUmAllocPoint->SetTitleRedNumber(0);
	m_imageNUmAllocPoint->SetFrameRect(CGRectMake(374, 62, 16, 8));
	this->AddChild(m_imageNUmAllocPoint);*/
	
	m_lbTotal = new NDUILabel;
	m_lbTotal->Initialization();
	m_lbTotal->SetFontSize(14);
	m_lbTotal->SetFontColor(ccc4(255, 237, 46, 255));
	m_lbTotal->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTotal->SetFrameRect(CGRectMake(120, 2, width-10, 14));
	std::stringstream ss; ss << NDPlayer::defaultHero().restPoint;
	m_lbTotal->SetText(ss.str().c_str());
	layer->AddChild(m_lbTotal);
	
	m_lbAlloc = new NDUILabel;
	m_lbAlloc->Initialization();
	m_lbAlloc->SetFontSize(14);
	m_lbAlloc->SetFontColor(ccc4(255, 237, 46, 255));
	m_lbAlloc->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbAlloc->SetFrameRect(CGRectMake(120+69, 2, width-10, 14));
	m_lbAlloc->SetText("0");
	layer->AddChild(m_lbAlloc);
	
	/*
	m_picMinus = NDPicturePool::DefaultPool()->AddPicture(plusminus_image);
	m_picMinus->Cut(CGRectMake(8, 0, 9, 8));
	
	m_imageMinus = new NDUIImage;
	m_imageMinus->Initialization();
	m_imageMinus->SetPicture(m_picMinus);
	m_imageMinus->SetFrameRect(CGRectMake(120+80, 5, 8, 8));
	layer->AddChild(m_imageMinus);*/
	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_picPointMinus[ePointState][0] = pool.AddPicture(GetImgPathNew("minu_normal.png"));
		m_picPointMinus[ePointState][1] = pool.AddPicture(GetImgPathNew("minu_selected.png"));
		m_picPointPlus[ePointState][0] = pool.AddPicture(GetImgPathNew("plus_normal.png"));
		m_picPointPlus[ePointState][1] = pool.AddPicture(GetImgPathNew("plus_selected.png"));
		
		m_pointFrame[ePointState] = new NDPropAllocLayer;
		m_pointFrame[ePointState]->Initialization(CGRectMake(5,52+(5+27)*ePointState,238,27));
		//m_pointFrame[ePointState]->SetLayerFocus(ePointState == m_iFocusPointType);
		
		m_layerPropAlloc->AddChild(m_pointFrame[ePointState]);
	}

	
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointTxt[ePointState] = new NDUIButton();
		m_btnPointTxt[ePointState]->Initialization();
		m_btnPointTxt[ePointState]->SetFrameRect(CGRectMake(4, 4, 48, 19));
		m_btnPointTxt[ePointState]->SetFontColor(ccc4(255, 255, 255, 255));
		m_btnPointTxt[ePointState]->SetFontSize(13);
		m_btnPointTxt[ePointState]->SetTitle(strBtnPoint[ePointState][0].c_str());
		m_btnPointTxt[ePointState]->CloseFrame();
		m_btnPointTxt[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointTxt[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointMinus[ePointState] = new NDUIButton();
		m_btnPointMinus[ePointState]->Initialization();
		CGSize size = m_picPointMinus[ePointState][1]->GetSize();
		m_btnPointMinus[ePointState]->SetFrameRect(CGRectMake(62, 3, size.width, size.height));
		SetPlusOrMinusPicture(ePointState, false, (ePointState==_stru_point::ps_begin));
		m_btnPointMinus[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointMinus[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		m_btnPointPlus[ePointState] = new NDUIButton();
		m_btnPointPlus[ePointState]->Initialization();
		CGSize size = m_picPointPlus[ePointState][1]->GetSize();
		m_btnPointPlus[ePointState]->SetFrameRect(CGRectMake(170, 3, size.width, size.height));
		SetPlusOrMinusPicture(ePointState, true, (ePointState==_stru_point::ps_begin));
		m_btnPointPlus[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointPlus[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		std::stringstream strDisplay; 
		strDisplay << m_struPoint.m_psProperty[ePointState].iPoint 
		<< "(+" << m_struPoint.m_psProperty[ePointState].iFix << ")";
		
		m_btnPointCur[ePointState] = new NDUIButton();
		m_btnPointCur[ePointState]->Initialization();
		m_btnPointCur[ePointState]->SetFontColor(ccc4(22, 87, 81, 255));
		m_btnPointCur[ePointState]->SetFontSize(13);
		m_btnPointCur[ePointState]->SetTitle(strDisplay.str().c_str());
		m_btnPointCur[ePointState]->CloseFrame();
		m_btnPointCur[ePointState]->SetFrameRect(CGRectMake(82, 0, 88, 27));
		m_btnPointCur[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointCur[ePointState]);
	}
	for( int ePointState = _stru_point::ps_begin; ePointState < _stru_point::ps_end; ePointState++ )
	{
		std::stringstream strDisplay; 
		strDisplay << m_struPoint.m_psProperty[ePointState].iPoint + m_struPoint.m_psProperty[ePointState].iFix;
		
		m_btnPointTotal[ePointState] = new NDUIButton();
		m_btnPointTotal[ePointState]->Initialization();
		m_btnPointTotal[ePointState]->SetFontColor(ccc4(22, 87, 81, 255));
		m_btnPointTotal[ePointState]->SetFontSize(13);
		m_btnPointTotal[ePointState]->SetTitle(strDisplay.str().c_str());
		m_btnPointTotal[ePointState]->CloseFrame();
		m_btnPointTotal[ePointState]->SetFrameRect(CGRectMake(190, 0, 238-190+3, 27));
		m_btnPointTotal[ePointState]->SetDelegate(this);
		m_pointFrame[ePointState]->AddChild(m_btnPointTotal[ePointState]);
	}
	
	m_slideBar = new NDPropSlideBar();
	m_slideBar->Initialization(CGRectMake(6, 182, width-12, 45),205);
	m_slideBar->SetMax(NDPlayer::defaultHero().restPoint);
	m_slideBar->SetDelegate(this);
	m_layerPropAlloc->AddChild(m_slideBar);
	
	NDUILayer *layerBtn = new NDUILayer;
	layerBtn->Initialization();
	layerBtn->SetFrameRect(CGRectMake(195, 234, 48,24));	
	m_layerPropAlloc->AddChild(layerBtn);
	
	m_btnCommit = new NDUIButton;
	m_btnCommit->Initialization();
	m_btnCommit->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png")),
							  pool.AddPicture(GetImgPathNew("bag_btn_click.png")),
							  false, CGRectZero, true);
	m_btnCommit->SetFrameRect(CGRectMake(0, 0, 48,24));							 
	m_btnCommit->SetFontSize(12);
	m_btnCommit->SetTitle(NDCommonCString("commit"));
	m_btnCommit->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnCommit->CloseFrame();
	m_btnCommit->SetDelegate(this);
	layerBtn->AddChild(m_btnCommit);
	
	changePointFocus(_stru_point::ps_begin);
}

void GameUIAttrib::InitProp()
{
	m_layerProp = new NDUILayer;
	
	m_layerProp->Initialization();
	
	int width = 252;//, height = 274;
	do 
	{
		m_tableLayerDetail = new NDUITableLayer;
		m_tableLayerDetail->Initialization();
		m_tableLayerDetail->SetSelectEvent(false);
		m_tableLayerDetail->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tableLayerDetail->VisibleSectionTitles(false);
		m_tableLayerDetail->SetFrameRect(CGRectMake(6, 17, width-10, 226));
		m_tableLayerDetail->VisibleScrollBar(false);
		m_tableLayerDetail->SetCellsInterval(2);
		m_tableLayerDetail->SetCellsRightDistance(0);
		m_tableLayerDetail->SetCellsLeftDistance(0);
		m_tableLayerDetail->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		for ( int i=ePD_Begin; i<ePD_End; i++) 
		{
			NDPropCell  *propDetail = new NDPropCell;
			propDetail->Initialization(true);
			if (propDetail->GetKeyText())
				propDetail->GetKeyText()->SetText(strPropDetail[i].c_str());
			section->AddCell(propDetail);
		}
		
		for ( int i=ePA_Begin; i<ePA_End; i++) 
		{
			NDPropCell  *propDetail = new NDPropCell;
			propDetail->Initialization(i != ePA_Lover);
			if (propDetail->GetKeyText())
				propDetail->GetKeyText()->SetText(strPorpAdvance[i].c_str());
			section->AddCell(propDetail);
		}
		
		dataSource->AddSection(section);
		m_tableLayerDetail->SetDataSource(dataSource);
		m_layerProp->AddChild(m_tableLayerDetail);
	} while (0);
}

void GameUIAttrib::SetPropTextFocus(int eProp, bool focus)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	ccColor4B color = focus ? ccc4(255, 0, 0, 255) : 
					  (m_struPoint.IsAlloc(_stru_point::enumPointState(eProp)) ? 
					  ccc4(255, 255, 255, 255) : ccc4(22, 87, 81, 255));
	
	if (m_btnPointCur[eProp])
		m_btnPointCur[eProp]->SetFontColor(color);
	
	if (m_btnPointTotal[eProp])
		m_btnPointTotal[eProp]->SetFontColor(color);
}

void GameUIAttrib::SetPlusOrMinusPicture(int eProp, bool plus, bool focus)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	int iFocus = focus ? 1 : 0;
	
	NDUIButton *btn = plus ? m_btnPointPlus[eProp] : m_btnPointMinus[eProp];
	
	NDPicture  *pic = plus ? m_picPointPlus[eProp][iFocus] : m_picPointMinus[eProp][iFocus];
	
	if (!btn || !pic) return;
	
	CGSize size = btn->GetFrameRect().size,
		   sizePic = pic->GetSize();
	
	btn->SetImage(pic, true, CGRectMake((size.width-sizePic.width)/2, (size.height-sizePic.height)/2, sizePic.width, sizePic.height));
}

void GameUIAttrib::AddPropAlloc(NDUINode* parent)
{
	if (!parent || !m_layerPropAlloc) return;
	
	CGSize size = parent->GetFrameRect().size;
	m_layerPropAlloc->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerPropAlloc);
}

void GameUIAttrib::AddProp(NDUINode* parent)
{
	if (!parent || !m_layerProp) return;
	
	CGSize size = parent->GetFrameRect().size;
	m_layerProp->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	
	parent->AddChild(m_layerProp);
}

void GameUIAttrib::UpdateMoney()
{
	NDPlayer& player = NDPlayer::defaultHero();
	int valueInfo[3];
	valueInfo[0] = player.eMoney;
	valueInfo[1] = player.money;
	valueInfo[2] = player.jifeng;
	
	for (int i = 0; i < 3; i++) 
	{
		//if (m_imageNumInfo[i])
		//	m_imageNumInfo[i]->SetSmallGoldNumber(valueInfo[0]);
		if (m_lbMoneyInfo[i])
		{
			std::stringstream ss; ss << valueInfo[i];
			m_lbMoneyInfo[i]->SetText(ss.str().c_str());
		}
	}
}

void GameUIAttrib::UpdateSlideBar(int eProp)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	if (m_slideBar)
	{
		m_slideBar->SetMax(m_struPoint.iTotal, false);
		m_slideBar->SetMin(m_struPoint.GetMinPoint(_stru_point::enumPointState(eProp)),false);
		m_slideBar->SetCur(m_struPoint.iAlloc, true);
	}
}

void GameUIAttrib::UpdatePorpText(int eProp)
{
	if (eProp < _stru_point::ps_begin || eProp >= _stru_point::ps_end) return;
	
	stringstream ss; ss << (m_struPoint.m_psProperty[eProp].iFix + m_struPoint.m_psProperty[eProp].iPoint)
	<< "(+" << m_struPoint.m_psProperty[eProp].iAdd 
	<< ")";
	
	if (m_btnPointCur[eProp])
		m_btnPointCur[eProp]->SetTitle(ss.str().c_str());
	
	stringstream ss2; ss2 << (m_struPoint.m_psProperty[eProp].iFix 
							  + m_struPoint.m_psProperty[eProp].iPoint
							  + m_struPoint.m_psProperty[eProp].iAdd);
	
	if (m_btnPointTotal[eProp])
		m_btnPointTotal[eProp]->SetTitle(ss2.str().c_str());
}

void GameUIAttrib::UpdatePorpAlloc()
{
	stringstream ss;
	ss << m_struPoint.iAlloc;
	
	if (m_lbAlloc)
		m_lbAlloc->SetText(ss.str().c_str());
}

void GameUIAttrib::ShowAttrInfo(bool show)
{
	if (m_attrInfo) 
	{
		m_attrInfo->SetVisible(show);
		m_attrInfoShow = show;
	}
	
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene)))
	{
		((PlayerInfoScene*)scene)->DrawRole(!show, ccp(97, 172));
	}
}

//////////////////////////////////////////
IMPLEMENT_CLASS(GameAttribScene, NDScene)

GameAttribScene::GameAttribScene()
{
}

GameAttribScene::~GameAttribScene()
{
}

GameAttribScene* GameAttribScene::Scene()
{
	GameAttribScene *scene = new GameAttribScene;
	scene->Initialization();
	return scene;
}

void GameAttribScene::Initialization()
{
	NDScene::Initialization();
	
	GameUIAttrib *attrib = new GameUIAttrib;
	attrib->Initialization();
	this->AddChild(attrib, UILAYER_Z, UILAYER_ATTRIB_TAG);
}
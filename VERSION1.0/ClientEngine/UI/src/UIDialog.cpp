/*
 *  UIDialog.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-2-22.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "UIDialog.h"
#include "NDTextNode.h"
#include "NDDirector.h"
#include "UtilityInc.h"
#include "NDUILoadEngine.h"
#include "CCPointExtension.h"
#include "NDPath.h"
#include "NDAnimationGroup.h"
#include "NDSharedPtr.h"
#include "ObjectTracker.h"

using namespace cocos2d;


IMPLEMENT_CLASS(CUIDlgOptBtn, NDUIButton)

CUIDlgOptBtn::CUIDlgOptBtn()
{
	INC_NDOBJ_RTCLS

	m_textHpyerlink		= NULL;
	m_sprTip			= NULL;
}

CUIDlgOptBtn::~CUIDlgOptBtn()
{
	DEC_NDOBJ_RTCLS
}

void CUIDlgOptBtn::Initialization()
{
	NDUIButton::Initialization();
	this->CloseFrame();
	
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	CCRect rect		= CCRectMake(0, 0, winsize.width * 0.15, winsize.height * 0.15);
	
	m_sprTip = new CUISpriteNode;
	m_sprTip->Initialization();
	m_sprTip->SetFrameRect(rect);
	//m_sprTip->ChangeSprite(NDPath::GetAniPath("button.spr").c_str());//modified by ZhangDi 这个控件不需要做显示，但是其他地方有依赖到控件的框体大小，所以把显示的动画给屏蔽掉

	//新增提示图片
	NDPicture *test =  NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("General/arrows/icon_arrows4.png"));
	test->Cut(CCRectMake(0.0f, 0.0f, 72.0f, 32.0f));
	NDUIImage *testimg = new NDUIImage;
	testimg->Initialization();
	testimg->SetPicture(test);
	testimg->SetFrameRect(CCRectMake(0.0f, winsize.height*0.015, 72.0f*ANDROID_SCALE, 32.0f*ANDROID_SCALE));

	this->AddChild(testimg, 1000);

	this->AddChild(m_sprTip);
	
	m_textHpyerlink = new CUIHyperlinkText;
	m_textHpyerlink->Initialization();
	m_textHpyerlink->SetFrameRect(CCRectMake(winsize.width*0.8f, 0, 0, 0));
	m_textHpyerlink->EnableLine(NO);// EnableLine
	this->AddChild(m_textHpyerlink);
}

void CUIDlgOptBtn::SetFrameRect(CCRect rect)
{
	if (m_sprTip)
	{
		CCRect rectSprite			= m_sprTip->GetFrameRect();
		rectSprite.size.height		= rect.size.height;
		m_sprTip->SetFrameRect(rectSprite);
	}
	
	NDUIButton::SetFrameRect(rect);
}

void CUIDlgOptBtn::SetBoundRect(CCRect rect)
{
	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();

	if (!m_textHpyerlink)
	{
		return;
	}
	
	if (m_sprTip)
	{
		CCRect rectTip	= m_sprTip->GetFrameRect();
		rect.origin.x	= winsize.width*0.08;
		rect.origin.y	= 0;
		rect.size.width	= rect.size.width - rectTip.size.width;
	}
	
	m_textHpyerlink->SetLinkBoundRect(rect);
}

void CUIDlgOptBtn::SetLinkText(const char* text)
{	
	if (!m_textHpyerlink)
	{
		return;
	}
	
	std::string strText = text ? text : "";
	m_textHpyerlink->SetLinkText(strText.c_str());
	
	CCRect rect = this->GetFrameRect();
	rect.size.width = 0;
	if (m_sprTip)
	{
		rect.size.width += m_sprTip->GetFrameRect().size.width;
	}
	
	if (m_textHpyerlink)
	{
		rect.size.width += m_textHpyerlink->GetFrameRect().size.width;
	}
	
	this->SetFrameRect(rect);
}

void CUIDlgOptBtn::SetLinkTextFontSize(unsigned int uiFontSize)
{
	if (!m_textHpyerlink)
	{
		return;
	}
	
	m_textHpyerlink->SetLinkTextFontSize(uiFontSize);
}

void CUIDlgOptBtn::SetLinkTextColor(ccColor4B color)
{
	if (!m_textHpyerlink)
	{
		return;
	}
	
	m_textHpyerlink->SetLinkTextColor(color);
}

//////////////////////////////////////////////////////////////////////
const unsigned long ID_TASKCHAT_CTRL_UI_TEXT_NPC_INFO			= 8;
const unsigned long ID_TASKCHAT_CTRL_PICTURE_7					= 7;
const unsigned long ID_TASKCHAT_CTRL_BUTTON_CLOSE				= 6;
const unsigned long ID_TASKCHAT_CTRL_UI_TEXT_INFO				= 5;
const unsigned long ID_TASKCHAT_CTRL_PICTURE_NPC				= 3;
const unsigned long ID_TASKCHAT_CTRL_TEXT_NPC_NAME				= 2;
const unsigned long ID_TASKCHAT_CTRL_PICTURE_9					= 9;

IMPLEMENT_CLASS(CUIDialog, NDUILayer)

CUIDialog::CUIDialog()
{
	INC_NDOBJ_RTCLS

	m_uiOptHeight	= 24 * RESOURCE_SCALE;
}

CUIDialog::~CUIDialog()
{
	DEC_NDOBJ_RTCLS
}

void CUIDialog::Initialization()
{
	NDUILayer::Initialization();
	
	NDSharedPtr<NDUILoadEngine> spLoadEngine = CREATE_CLASS(NDUILoadEngine,"NDUILoad");
    if(!spLoadEngine)
        return;
	spLoadEngine->Load("TaskChat.ini", this, this, CCSizeMake(0, 0));

	CCSize winsize	= CCDirector::sharedDirector()->getWinSizeInPixels();
	CCRect rectNode = CCRectMake(0, 0, winsize.width, winsize.height);
//	CCRect rectNode = node->GetFrameRect();
	this->SetFrameRect(CCRectMake((winsize.width - rectNode.size.width) / 2,
					   (winsize.height - rectNode.size.height) / 2,
					   rectNode.size.width, rectNode.size.height));
	
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene)
	{
		scene->AddChild(this, UI_TAG_DIALOG, UI_ZORDER_DIALOG);
	}
	
	NDUIButton *node = (NDUIButton *)this->GetChild(ID_TASKCHAT_CTRL_BUTTON_CLOSE);
	node->SetSoundEffect(0);
	node->SetBoundScale(2);
}

void CUIDialog::SetTitle(const char* title)
{
	NDUINode* node = (NDUINode*)this->GetChild(ID_TASKCHAT_CTRL_TEXT_NPC_NAME);
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		return;
	}
	((NDUILabel*)node)->SetText(title);
}

void CUIDialog::SetContent(const char* content)
{
	this->SetUIText(content, ID_TASKCHAT_CTRL_UI_TEXT_NPC_INFO);
}

void CUIDialog::SetInfo(const char* info)
{
	this->SetUIText(info, ID_TASKCHAT_CTRL_UI_TEXT_INFO);
}

void CUIDialog::SetPicture(NDPicture* pic)
{
	NDUINode* node = (NDUINode*)this->GetChild(ID_TASKCHAT_CTRL_PICTURE_NPC);
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return;
	}
	
	((NDUIImage*)node)->SetPicture(pic, true);
}

void CUIDialog::SetOptions(VEC_DLG_OPTION& vOpt)
{
	ClrOption();
	
	for (VEC_DLG_OPTION_IT it = vOpt.begin(); 
		 it != vOpt.end(); 
		 it++) 
	{
		AddOption(*it);
	}
}

void CUIDialog::AddOption(DLGOPION& dlgOpt)
{
	this->AddOpt(dlgOpt.strOption.c_str(), dlgOpt.nAction);
}

void CUIDialog::AddOption(const char* opt, int nAction)
{
	this->AddOpt(opt, nAction);
}

unsigned int CUIDialog::GetOptionCount()
{
	return m_vUiOpt.size();
}

void CUIDialog::ClearOptions()
{
	ClrOption();
}

void CUIDialog::Close()
{
	this->RemoveFromParent(true);
}

void CUIDialog::OnClickOpt(int nOptIndex)
{
	//NDLog("\nDialog click [%d]", nOptIndex);
}

bool CUIDialog::OnClose()
{
	return true;
}

void CUIDialog::ClrOption()
{
	for (VEC_UI_OPT_IT it = m_vUiOpt.begin(); 
		 it != m_vUiOpt.end(); 
		 it++) 
	{
		(*it)->RemoveFromParent(true);
	}
	
	m_vUiOpt.clear();
	m_vId.clear();
}

void CUIDialog::AddOpt(const char* text, int nAction)
{
	if (!text)
	{
		return;
	}
	
	NDUINode* node = (NDUINode*)this->GetChild(ID_TASKCHAT_CTRL_PICTURE_7);
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		return;
	}
	
	CCRect rectNode		= node->GetFrameRect();
	//CCSize winsize		= CCDirector::sharedDirector()->getWinSizeInPixels();
	float fScale = ANDROID_SCALE;
	CCRect rect;
	cocos2d::CCLog("fScale = %05f, x = %05f, y = %05f, w = %05f, h = %05f, m_uiOptHeight = %u", 
		              fScale, rectNode.origin.x, rectNode.origin.y, rectNode.size.width, rectNode.size.height, m_uiOptHeight);
	rect.origin			= ccpAdd(rectNode.origin, ccp(0, m_vUiOpt.size() * m_uiOptHeight));
	rect.size			= CCSizeMake(rectNode.size.width*1.1, m_uiOptHeight);
	
	CUIDlgOptBtn *uiOpt	= new CUIDlgOptBtn;
	uiOpt->Initialization();  
	uiOpt->SetFrameRect(rect);
	uiOpt->SetBoundRect(rect);
	//uiOpt->SetLinkTextFontSize(13*fScale);
	uiOpt->SetLinkTextFontSize(12);
	uiOpt->SetLinkTextColor(ccc4(255, 255, 0, 255));
	uiOpt->SetLinkText(text);
	uiOpt->SetDelegate(this);
	this->AddChild(uiOpt);
	
	m_vUiOpt.push_back(uiOpt);
	m_vId.push_back(nAction);
}

void CUIDialog::SetUIText(const char* text, int nTag)
{
	NDUINode* node = (NDUINode*)this->GetChild(nTag);
	if (!node || !node->IsKindOfClass(RUNTIME_CLASS(NDUIText)))
	{
		return;
	}
	
	CCRect rect					= node->GetFrameRect();
	unsigned int uiFontSize		= ((NDUIText*)node)->GetFontSize();
	ccColor4B color				= ((NDUIText*)node)->GetFontColor();
	
	this->RemoveChild(nTag, true);
	
	if (!text || 0 == strlen(text))
	{
		NDUIText *uitext = new NDUIText;
		uitext->Initialization(false);
		uitext->SetFrameRect(rect);
		uitext->SetFontSize(uiFontSize);
		uitext->SetFontColor(color);
		uitext->SetTag(nTag);
		this->AddChild(uitext);
		uitext->SetVisible(this->IsVisibled());
		return;
	}
	
	NDUIText* uitext = NDUITextBuilder::DefaultBuilder()->Build(
						text, uiFontSize, rect.size, color, false, false);
	uitext->SetFrameRect(rect);	
	uitext->SetTag(nTag);
	uitext->SetFontSize(uiFontSize);
	uitext->SetFontColor(color);
	this->AddChild(uitext);
	uitext->SetVisible(this->IsVisibled());
}


void CUIDialog::OnButtonClick(NDUIButton* button)
{
	size_t size		= m_vUiOpt.size();
	for (size_t i = 0; i < size; i++) 
	{
		if ( m_vUiOpt[i] == button )
		{
			OnClickOpt(i);
			break;
		}
	}
}

bool CUIDialog::OnTargetBtnEvent(NDUINode* uinode, int targetEvent)
{
	NDUINode* node = (NDUINode*)this->GetChild(ID_TASKCHAT_CTRL_BUTTON_CLOSE);
	if (node == uinode)
	{
		if (OnClose())
		{
			Close();
		}
		return true;
	}
	
	return false;
}
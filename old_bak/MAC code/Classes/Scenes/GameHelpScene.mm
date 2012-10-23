/*
 *  GameHelpScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "GameHelpScene.h"
#import "CGPointExtension.h"
#import "NDDirector.h"
#import "InitMenuScene.h"
#import "NDPath.h"
#import <sstream>
#include "NDUtility.h"
#include "NDUtility.h"

IMPLEMENT_CLASS(HelpOperateItem, NDUINode)

HelpOperateItem::HelpOperateItem()
{
	m_image = NULL;
	m_memo = NULL;
}

HelpOperateItem::~HelpOperateItem()
{
}

void HelpOperateItem::SetOperateImage(const char* imageName)
{	
	if (imageName) 
	{
		NDPicture* pic = new NDPicture();
		pic->Initialization(imageName);
		
		if (!m_image) 
		{
			m_image = new NDUIImage();
			m_image->Initialization();
			this->AddChild(m_image);			
		}		
		m_image->SetFrameRect(CGRectMake(20, 0, pic->GetSize().width, pic->GetSize().height));
		m_image->SetPicture(pic, true);		
	}
	
}

void HelpOperateItem::SetOperateText(const char* text)
{
	if (m_memo) 
	{
		m_memo->RemoveFromParent(true);
	}
	
	m_memo = NDUITextBuilder::DefaultBuilder()->Build(text, 13, CGSizeMake(370, 60), ccc4(0, 0, 0, 255));
	m_memo->SetFrameRect(CGRectMake(100, 0, 370, 60));
	this->AddChild(m_memo);
}


////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(GameHelpScene, NDScene)

GameHelpScene* GameHelpScene::Scene()
{	
	GameHelpScene* scene = new GameHelpScene();	
	scene->Initialization();	
	return scene;
}

GameHelpScene::GameHelpScene()
{
	m_menuLayer		= NULL;
	m_lbGameHelp	= NULL;
	m_btnIntroduce	= NULL;
	m_btnOperate	= NULL;
	m_memoTxt		= NULL;
	m_layerOperateItems = NULL;
	
	LoadText();
}

GameHelpScene::~GameHelpScene()
{	
}

void GameHelpScene::Initialization()
{
	NDScene::Initialization();
	
	m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetDelegate(this);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	m_lbGameHelp = new NDUILabel();
	m_lbGameHelp->Initialization();
	m_lbGameHelp->SetText(NDCommonCString("GameHelp"));
	m_lbGameHelp->SetFontSize(15);
	m_lbGameHelp->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbGameHelp->SetFontColor(ccc4(255, 231, 0,255));
	m_lbGameHelp->SetFrameRect(CGRectMake(0, 8, 480, 15));
	m_menuLayer->AddChild(m_lbGameHelp);
	
	
	m_btnIntroduce = new NDUIButton();
	m_btnIntroduce->Initialization();
	m_btnIntroduce->SetFrameRect(CGRectMake(15, 32, 450, 32));
	m_btnIntroduce->SetTitle(NDCommonCString("GameIntroduce"));
	m_btnIntroduce->SetDelegate(this);
	m_menuLayer->AddChild(m_btnIntroduce);
	
	
	m_btnMenuIntroduce = new NDUIButton();
	m_btnMenuIntroduce->Initialization();
	m_btnMenuIntroduce->SetFrameRect(CGRectMake(15, 67, 450, 32));
	m_btnMenuIntroduce->SetTitle(NDCommonCString("MenuShuoMing"));
	m_btnMenuIntroduce->SetDelegate(this);
	m_menuLayer->AddChild(m_btnMenuIntroduce);
	
	m_btnOperate = new NDUIButton();
	m_btnOperate->Initialization();
	m_btnOperate->SetFrameRect(CGRectMake(15, 102, 450, 32));
	m_btnOperate->SetTitle(NDCommonCString("OperateShuoMing"));
	m_btnOperate->SetDelegate(this);
	m_menuLayer->AddChild(m_btnOperate);
	
	m_btnGameSetting = new NDUIButton();
	m_btnGameSetting->Initialization();
	m_btnGameSetting->SetFrameRect(CGRectMake(15, 137, 450, 32));
	m_btnGameSetting->SetTitle(NDCommonCString("GameSetting"));
	m_btnGameSetting->SetDelegate(this);
	m_menuLayer->AddChild(m_btnGameSetting);
	
	m_memoTxt = new NDUIMemo();
	m_memoTxt->Initialization();
	m_memoTxt->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_memoTxt->SetText("");
	m_memoTxt->SetFrameRect(CGRectMake(10, 32, 480-10*2, 320-32-48));
	m_memoTxt->SetVisible(false);
	m_menuLayer->AddChild(m_memoTxt);
	
	m_menuLayer->SetFocus((NDUINode*)m_btnIntroduce);
	
	m_layerPageControl = new NDUILayer();
	m_layerPageControl->Initialization();
	m_layerPageControl->SetFrameRect(CGRectMake(150, 290, 180, 30));
	m_menuLayer->AddChild(m_layerPageControl);
	
	m_btnPrevPage = new NDUIButton();
	m_btnPrevPage->Initialization();
	m_btnPrevPage->SetTitle(NDCommonCString("PrevPage"));
	m_btnPrevPage->CloseFrame();
	m_btnPrevPage->SetFrameRect(CGRectMake(0, 0, 60, 20));
	m_btnPrevPage->SetDelegate(this);
	m_layerPageControl->AddChild(m_btnPrevPage);
	
	
	m_lbPage = new NDUILabel();
	m_lbPage->Initialization();
	m_lbPage->SetText("1 / 5");
	m_lbPage->SetFrameRect(CGRectMake(60, 0, 60, 20));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter);
	m_layerPageControl->AddChild(m_lbPage);
	
	m_curPage = 1;
	
	m_btnNextPage = new NDUIButton();
	m_btnNextPage->Initialization();
	m_btnNextPage->SetTitle(NDCommonCString("NextPage"));
	m_btnNextPage->CloseFrame();
	m_btnNextPage->SetFrameRect(CGRectMake(120, 0, 60, 20));
	m_btnNextPage->SetDelegate(this);
	m_layerPageControl->AddChild(m_btnNextPage);
	m_layerPageControl->SetVisible(false);
	
	
	MakeOperateItems(0, 3);
	m_layerOperateItems->SetVisible(false);
	
}

void GameHelpScene::VisibleButtons(bool bVisible)
{
	m_btnOperate->SetVisible(bVisible);
	m_btnMenuIntroduce->SetVisible(bVisible);
	m_btnIntroduce->SetVisible(bVisible);
	m_btnGameSetting->SetVisible(bVisible);
}

void GameHelpScene::OnButtonClick(NDUIButton* button)
{
	if ( button == m_btnIntroduce ) 
	{
		VisibleButtons(false);
		m_layerPageControl->SetVisible(false);
		m_layerOperateItems->SetVisible(false);
		m_memoTxt->SetVisible(true);
		m_memoTxt->SetText(m_strIntroduce.c_str());
		m_lbGameHelp->SetText(button->GetTitle().c_str());
	}
	else if (button == m_btnMenuIntroduce)
	{
		VisibleButtons(false);
		m_memoTxt->SetVisible(true);
		m_layerPageControl->SetVisible(false);
		m_layerOperateItems->SetVisible(false);
		m_memoTxt->SetText(m_strMenuIntroduce.c_str());
		m_lbGameHelp->SetText(button->GetTitle().c_str());
	}
	else if ( button == m_btnOperate ) 
	{
		VisibleButtons(false);
		m_memoTxt->SetVisible(false);
		m_layerPageControl->SetVisible(true);
		m_layerOperateItems->SetVisible(true);
		m_lbGameHelp->SetText(button->GetTitle().c_str());
	}
	else if (button == m_btnGameSetting)
	{
		VisibleButtons(false);
		m_layerPageControl->SetVisible(false);
		m_layerOperateItems->SetVisible(false);
		m_memoTxt->SetVisible(true);
		m_memoTxt->SetText(m_strGameSetting.c_str());
		m_lbGameHelp->SetText(button->GetTitle().c_str());
	}
	else if (button == m_btnPrevPage)
	{
		if (m_curPage == 1) 
		{
			NDUIDialog* dlg = new NDUIDialog();
			dlg->Initialization();
			dlg->Show("", NDCommonCString("FirstPageTip"), NULL, NULL);
		}
		else 
		{
			m_curPage--;
			char buf[100] = {0x00};
			sprintf(buf, "%d / 5", m_curPage);
			m_lbPage->SetText(buf);
			
			MakeOperateItems((m_curPage - 1) * 4, (m_curPage - 1) * 4 + 3);
		}
	}
	else if (button == m_btnNextPage)
	{
		if (m_curPage == 5) 
		{
			NDUIDialog* dlg = new NDUIDialog();
			dlg->Initialization();
			dlg->Show("", NDCommonCString("LastPageTip"), NULL, NULL);
		}
		else 
		{
			m_curPage++;
			char buf[100] = {0x00};
			sprintf(buf, "%d / 5", m_curPage);
			m_lbPage->SetText(buf);
			
			MakeOperateItems((m_curPage - 1) * 4, (m_curPage - 1) * 4 + 3);
		}
	}	
	else if ( m_menuLayer && (button == m_menuLayer->GetCancelBtn()) )
	{
		if (m_btnGameSetting->IsVisibled())
		{
			NDDirector::DefaultDirector()->PopScene(NULL, true);			
		}
		else 
		{
			VisibleButtons(true);
			m_layerPageControl->SetVisible(false);
			m_layerOperateItems->SetVisible(false);
			m_memoTxt->SetVisible(false);
			m_lbGameHelp->SetText(NDCommonCString("GameHelp"));
		}	
	}
}

std::string GameHelpScene::LoadTextWithParam(int index)
{
	std::string result = "";
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *helpiniTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("help.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:helpiniTable];
	
	if (stream)
	{
		[stream open];		
		result	= cutBytesToString(stream, index);		
		[stream close];
	}
	return result;
}

void GameHelpScene::LoadText()
{
	m_strIntroduce	= LoadTextWithParam(1);
	m_strMenuIntroduce = LoadTextWithParam(2);
	m_strGameSetting = LoadTextWithParam(7);
}

void GameHelpScene::MakeOperateItems(unsigned int beginIndex, unsigned int endIndex)
{
	if (!m_layerOperateItems) 
	{
		m_layerOperateItems = new NDUILayer();
		m_layerOperateItems->Initialization();
		m_layerOperateItems->SetTouchEnabled(false);
		m_layerOperateItems->SetFrameRect(CGRectMake(0, m_menuLayer->GetTitleHeight(), 480, m_menuLayer->GetTextHeight()));
		m_menuLayer->AddChild(m_layerOperateItems);
		
		m_imageNames.push_back("ui_team.png");
		m_imageNames.push_back("ui_social.png");
		m_imageNames.push_back("ui_talk.png");
		m_imageNames.push_back("ui_task.png");
		m_imageNames.push_back("ui_bag.png");
		m_imageNames.push_back("ui_store.png");
		m_imageNames.push_back("ui_menu.png");
		m_imageNames.push_back("ui_item_scroll.png");
		m_imageNames.push_back("ui_map.png");
		m_imageNames.push_back("ui_target.png");
		m_imageNames.push_back("ui_interective.png");
		m_imageNames.push_back("ui_menu_scroll.png");
		m_imageNames.push_back("minimap.png");
		m_imageNames.push_back("playerState.png");
		m_imageNames.push_back("ui_request.png");
		m_imageNames.push_back("ui_mail.png");
		m_imageNames.push_back("nav_btn_sel.png");	
		
		for (unsigned int i = 8; i < 8 + m_imageNames.size(); i++) 
		{
			m_operateTexts.push_back(LoadTextWithParam(i));
		}
		
	}
	
	m_layerOperateItems->RemoveAllChildren(true);
	
	for (unsigned int i = beginIndex; i <= endIndex; i++) 
	{
		if (i >= m_imageNames.size()) 
		{
			return;
		}
		
		HelpOperateItem* item = new HelpOperateItem();
		item->Initialization();
		item->SetOperateImage(NDPath::GetImgPath(m_imageNames.at(i).c_str()));
		item->SetOperateText(m_operateTexts.at(i).c_str());
		item->SetFrameRect(CGRectMake(0, (i - beginIndex) * 60, 480, 60));
		
		m_layerOperateItems->AddChild(item);
	}
}

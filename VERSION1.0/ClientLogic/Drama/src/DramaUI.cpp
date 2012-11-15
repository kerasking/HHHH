/*
 *  DramaUI.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "DramaUI.h"
#include "NDTargetEvent.h"
#include "NDDirector.h"
#include "NDUILoad.h"
#include "NDUILabel.h"
#include "NDUIImage.h"
#include "define.h"

///////////////////////////////////////////////
IMPLEMENT_CLASS(ClickLayer, NDUILayer)

bool ClickLayer::TouchBegin(NDTouch* touch)
{
	return true;
}

bool ClickLayer::TouchEnd(NDTouch* touch)
{
	NDUITargetDelegate* delegate = GetTargetDelegate();

	if (delegate)
	{
		return delegate->OnTargetBtnEvent(this, TE_TOUCH_BTN_CLICK);
	}

	return false;
}

///////////////////////////////////////////////
const unsigned long ID_UNTITLED_CTRL_BUTTON_5 = 5;
const unsigned long ID_UNTITLED_CTRL_TEXT_WORDS = 4;
const unsigned long ID_UNTITLED_CTRL_PICTURE_3 = 3;
const unsigned long ID_UNTITLED_CTRL_PICTURE_2 = 2;
const unsigned long ID_UNTITLED_CTRL_PICTURE_1 = 1;
IMPLEMENT_CLASS(DramaConfirmdlg, ClickLayer)

void DramaConfirmdlg::Initialization()
{
	ClickLayer::Initialization();

	CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));

	NDUILoad uiload;
	uiload.Load("dramaini/SM_MSG.ini", this, NULL);
}

void DramaConfirmdlg::SetContent(std::string content)
{
	NDNode* node = GetChild(ID_UNTITLED_CTRL_TEXT_WORDS);

	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		((NDUILabel*) node)->SetText(content.c_str());
	}
}

///////////////////////////////////////////////
IMPLEMENT_CLASS(DramaChatLayer, ClickLayer)

DramaChatLayer::DramaChatLayer()
{
	m_nTagFigure = 0;
	m_nTagTitle = 0;
	m_nTagContent = 0;
}

DramaChatLayer::~DramaChatLayer()
{

}

void DramaChatLayer::SetFigure(std::string filename, bool bReverse, int nCol, int nRow)
{
	NDNode* node = GetChild(m_nTagFigure);

	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUIImage)))
	{
		NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
				filename);
		pic->SetReverse(bReverse);

		int nCutX= nCol * 256;
		int nCutY= nRow * 256;
		pic->Cut(CCRectMake(nCutX+1, nCutY+1, 255, 255));

		((NDUIImage*) node)->SetPicture(pic);
	}
}

void DramaChatLayer::SetTitle(std::string title, int nFontSize, int nFontColor)
{
	NDNode* node = GetChild(m_nTagTitle);

	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		NDUILabel* lb = ((NDUILabel*) node);
		lb->SetText(title.c_str());
		lb->SetFontSize(nFontSize);
		lb->SetFontColor(INTCOLORTOCCC4(nFontColor));
	}
}

void DramaChatLayer::SetContent(std::string content, int nFontSize,
		int nFontColor)
{
	NDNode* pkNode = GetChild(m_nTagContent);

	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		NDUILabel* lb = ((NDUILabel*) pkNode);
		lb->SetText(content.c_str());
		lb->SetFontSize(nFontSize);
		lb->SetFontColor(INTCOLORTOCCC4(nFontColor));
	}
}

void DramaChatLayer::SetFigureTag(int nTag)
{
	m_nTagFigure = nTag;
}

void DramaChatLayer::SetTitleTag(int nTag)
{
	m_nTagTitle = nTag;
}

void DramaChatLayer::SetContentTag(int nTag)
{
	m_nTagContent = nTag;
}

///////////////////////////////////////////////
const unsigned long ID_DLG_CTRL_TEXT_DLG = 4;
const unsigned long ID_DLG_CTRL_TEXT_TITAL = 3;
const unsigned long ID_DLG_CTRL_PICTURE_PLAYER = 2;
const unsigned long ID_DLG_CTRL_PICTURE_BG = 1;

IMPLEMENT_CLASS(DramaLeftChat, DramaChatLayer)

void DramaLeftChat::Initialization()
{
	DramaChatLayer::Initialization();

	CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));

	//ÉèÖÃ±³¾°
	NDUILayer *backlayer = new NDUILayer;
	backlayer->Initialization();
	backlayer->SetFrameRect(CCRectMake(winsize.width*0.1, winsize.height*0.7, winsize.width*0.9, winsize.height*0.3));
	backlayer->SetBackgroundColor(ccc4(0,0,0,60));
	AddChild(backlayer, -1);

	NDUILoad uiload;
	uiload.Load("dramaini/DLG_L.ini", this, NULL);

	SetFigureTag(ID_DLG_CTRL_PICTURE_PLAYER);
	SetTitleTag(ID_DLG_CTRL_TEXT_TITAL);
	SetContentTag(ID_DLG_CTRL_TEXT_DLG);
}

///////////////////////////////////////////////
const unsigned long ID_DLG_R_CTRL_TEXT_DLG = 4;
const unsigned long ID_DLG_R_CTRL_TEXT_TITAL = 3;
const unsigned long ID_DLG_R_CTRL_PICTURE_PLAYER = 2;
const unsigned long ID_DLG_R_CTRL_PICTURE_BG = 1;
IMPLEMENT_CLASS(DramaRightChat, DramaChatLayer)

void DramaRightChat::Initialization()
{
	DramaChatLayer::Initialization();

	CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));
	
	//ÉèÖÃ±³¾°
	NDUILayer *backlayer = new NDUILayer;
	backlayer->Initialization();
	backlayer->SetFrameRect(CCRectMake(0, 0, winsize.width*0.9, winsize.height*0.3));
	backlayer->SetBackgroundColor(ccc4(0,0,0,60));
	AddChild(backlayer, -1);

	NDUILoad uiload;
	uiload.Load("dramaini/DLG_R.ini", this, NULL);

	SetFigureTag(ID_DLG_R_CTRL_PICTURE_PLAYER);
	SetTitleTag(ID_DLG_R_CTRL_TEXT_TITAL);
	SetContentTag(ID_DLG_R_CTRL_TEXT_DLG);
}
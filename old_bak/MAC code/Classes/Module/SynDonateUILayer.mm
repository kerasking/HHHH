/*
 *  SynDonateUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynDonateUILayer.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"
#include "NDPath.h"
#include "NDDirector.h"
#include <sstream>
#include "ItemMgr.h"

IMPLEMENT_CLASS(DragBar, NDPropSlideBar)

DragBar::DragBar()
{
	m_lbNumHint = NULL;
	m_scale = 0;
}

DragBar::~DragBar()
{
	
}

void DragBar::draw()
{
	if (m_lbNumHint) {
		stringstream ss;
		ss << (m_scale > 0 ? m_uiCur * m_scale : m_uiCur);
		m_lbNumHint->SetText(ss.str().c_str());
	}
	
	NDPropSlideBar::draw();
}

void DragBar::Initialization(CGRect rect, unsigned int slideWidth)
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(rect);
	
	//this->SetBackgroundImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("slider.png"), rect.size.width, rect.size.height), true);
	
	int width = slideWidth;
	CGSize parent = rect.size;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBg = pool.AddPicture(NDPath::GetImgPathNew("slider.png"), width, 0);
	
	NDPicture *slide = pool.AddPicture(NDPath::GetImgPathNew("slider_block.png"));
	
	CGSize sizeSlide = slide->GetSize();
	
	CGSize sizeBG = picBg->GetSize();
	
	m_scrTouchRect = CGRectMake(0, 0, parent.width, parent.height);
	
	m_imageSlideBg = new NDUIImage;
	
	m_imageSlideBg->Initialization();
	
	m_imageSlideBg->SetPicture(picBg, true);
	
	m_imageSlideBg->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, sizeBG.width, sizeBG.height));
	
	this->AddChild(m_imageSlideBg);
	
	NDPicture *picProcess = pool.AddPicture(NDPath::GetImgPathNew("seekbar_fill.png"));
	
	m_imageProcess = new NDUIImage;
	
	m_imageProcess->Initialization();
	
	m_imageProcess->SetPicture(picProcess, true);
	
	m_imageProcess->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeBG.height)/2, picProcess->GetSize().width, picProcess->GetSize().height));
	
	this->AddChild(m_imageProcess);
	
	m_imageSlide = new NDUIImage;
	
	m_imageSlide->Initialization();
	
	m_imageSlide->SetPicture(slide, true);
	
	m_imageSlide->SetFrameRect(CGRectMake((parent.width-width)/2, (parent.height-sizeSlide.height)/2, sizeSlide.width, sizeSlide.height));
	
	this->AddChild(m_imageSlide);
	
	m_lbNumHint = new NDUILabel;
	m_lbNumHint->Initialization();
	m_lbNumHint->SetFontSize(12);
	m_lbNumHint->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbNumHint->SetText("");
	m_lbNumHint->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbNumHint->SetFrameRect(CGRectMake(0, 1, rect.size.width, rect.size.height));
	this->AddChild(m_lbNumHint);
	
	m_fProcessWidth = sizeBG.width-sizeSlide.width;
}


enum {
	eBtnAddBegin,
	eBtnAddMoney = eBtnAddBegin,
	eBtnAddWood,
	eBtnAddStone,
	eBtnAddPaint,
	eBtnAddCoal,
	eBtnAddEmoney,
	eBtnAddEnd,
	
	eBtnMinusBegin,
	eBtnMinusMoney = eBtnMinusBegin,
	eBtnMinusWood,
	eBtnMinusStone,
	eBtnMinusPaint,
	eBtnMinusCoal,
	eBtnMinusEmoney,
	eBtnMinusEnd,
	
	eBtnConfirm,
};

const int ID_ITEMTYPE_WOOD = 81020001;
const int ID_ITEMTYPE_STONE = 59000010;
const int ID_ITEMTYPE_PAINT = 59000020;
const int ID_ITEMTYPE_COAL = 59000030;

//////////////////////////////////////////////////////////////////////////////////////////
SynDonateUILayer* SynDonateUILayer::s_instance = NULL;

void SynDonateUILayer::processSynDonate(NDTransData& data)
{
	CloseProgressBar;
	
	stringstream ss;
	long long t_contriTotal = data.ReadLong();//总贡献值
	{
		ss << t_contriTotal;
		m_lbTotalCon->SetText(ss.str().c_str());
	}
	
	for(int i = 0; i < 6; i++){
		ss.str("");
		if(i == 0 || i == 5){
			long long lVal = data.ReadLong();
			ss << lVal;
		}else {
			int nVal = data.ReadInt();
			ss << nVal;
		}
		
		switch (i) {
			case 0:
				m_lbSynMoney->SetText(ss.str().c_str());
				break;
			case 1:
				m_lbSynWood->SetText(ss.str().c_str());
				break;
			case 2:
				m_lbSynStone->SetText(ss.str().c_str());
				break;
			case 3:
				m_lbSynPaint->SetText(ss.str().c_str());
				break;
			case 4:
				m_lbSynCoal->SetText(ss.str().c_str());
				break;
			case 5:
				m_lbSynEmoney->SetText(ss.str().c_str());
				break;
			default:
				break;
		}
	}
	
	// 刷玩家背包数据 + 滑动条
	NDPlayer& player = NDPlayer::defaultHero();
	ss.str(""); ss << player.money;
	m_lbUserMoney->SetText(ss.str().c_str());
	m_dragMoney->SetMax(player.money / 100, false);
	m_dragMoney->SetMin(0, false);
	m_dragMoney->SetCur(0, true);
	m_dragMoney->SetScale(100);
	
	ss.str(""); ss << player.eMoney;
	m_lbUserEmoney->SetText(ss.str().c_str());
	m_dragEmoney->SetMax(player.eMoney, false);
	m_dragEmoney->SetMin(0, false);
	m_dragEmoney->SetCur(0, true);
	
	ItemMgr& mgr = ItemMgrObj;
	VEC_ITEM& vItems = mgr.GetPlayerBagItems();
	
	int numWood = 0;
	int numStone = 0;
	int numPaint = 0;
	int numCoal = 0;
	
	Item* pItem = NULL;
	for (VEC_ITEM_IT it = vItems.begin(); it != vItems.end(); it++) {
		pItem = *it;
		if (pItem) {
			switch (pItem->iItemType) {
				case ID_ITEMTYPE_WOOD:
					numWood += pItem->iAmount;
					break;
				case ID_ITEMTYPE_STONE:
					numStone += pItem->iAmount;
					break;
				case ID_ITEMTYPE_PAINT:
					numPaint += pItem->iAmount;
					break;
				case ID_ITEMTYPE_COAL:
					numCoal += pItem->iAmount;
					break;
				default:
					break;
			}
		}
	}
	
	ss.str(""); ss << numWood;
	m_lbUserWood->SetText(ss.str().c_str());
	m_dragWood->SetMax(numWood, false);
	m_dragWood->SetMin(0, false);
	m_dragWood->SetCur(0, true);
	
	ss.str(""); ss << numStone;
	m_lbUserStone->SetText(ss.str().c_str());
	m_dragStone->SetMax(numStone, false);
	m_dragStone->SetMin(0, false);
	m_dragStone->SetCur(0, true);
	
	ss.str(""); ss << numPaint;
	m_lbUserPaint->SetText(ss.str().c_str());
	m_dragPaint->SetMax(numPaint, false);
	m_dragPaint->SetMin(0, false);
	m_dragPaint->SetCur(0, true);
	
	ss.str(""); ss << numCoal;
	m_lbUserCoal->SetText(ss.str().c_str());
	m_dragCoal->SetMax(numCoal, false);
	m_dragCoal->SetMin(0, false);
	m_dragCoal->SetCur(0, true);
}

IMPLEMENT_CLASS(SynDonateUILayer, NDUILayer)

SynDonateUILayer::SynDonateUILayer()
{
	s_instance = this;
	m_lbTotalCon = NULL;
	m_lbSynMoney = NULL;
	m_lbSynWood = NULL;
	m_lbSynStone = NULL;
	m_lbSynPaint = NULL;
	m_lbSynCoal = NULL;
	m_lbSynEmoney = NULL;
	
	m_lbUserMoney = NULL;
	m_lbUserWood = NULL;
	m_lbUserStone = NULL;
	m_lbUserPaint = NULL;
	m_lbUserCoal = NULL;
	m_lbUserEmoney = NULL;
	
	m_dragMoney = NULL;
	m_dragWood = NULL;
	m_dragStone = NULL;
	m_dragPaint = NULL;
	m_dragCoal = NULL;
	m_dragEmoney = NULL;
}

SynDonateUILayer::~SynDonateUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void SynDonateUILayer::Query()
{
	sendQuerySynNormalInfo(ACT_QUERY_SYN_STORAGE);
}

void SynDonateUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* img = new NDUIImage;
	img->Initialization();
	img->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png"), 451, 268), true);
	img->SetFrameRect(CGRectMake(0, 6, 457, 274));
	this->AddChild(img);
	
	NDUIButton* btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(400, 230, 38, 42));
	btn->SetImage(pool.AddPicture(NDPath::GetImgPathNew("btn_confirm.png")), false, CGRectZero, true);
	btn->SetDelegate(this);
	btn->SetTag(eBtnConfirm);
	this->AddChild(btn);
	
	GLfloat fStartX = 0;
	GLfloat fStartY = 20;
	
	NDUIImage* imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("cell_mask.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	NDUILabel* label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(255, 255, 255, 255));
	label->SetText(NDCommonCString("TotalContribute"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbTotalCon = new NDUILabel;
	m_lbTotalCon->Initialization();
	m_lbTotalCon->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbTotalCon->SetText("");
	m_lbTotalCon->SetFrameRect(CGRectMake(fStartX + 70, fStartY + 1, 200, 16));
	m_lbTotalCon->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(m_lbTotalCon);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("money"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynMoney = new NDUILabel;
	m_lbSynMoney->Initialization();
	m_lbSynMoney->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynMoney->SetText("");
	m_lbSynMoney->SetFontSize(13);
	m_lbSynMoney->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynMoney->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynMoney);
	
	m_lbUserMoney = new NDUILabel;
	m_lbUserMoney->Initialization();
	m_lbUserMoney->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserMoney->SetText("");
	m_lbUserMoney->SetFontSize(13);
	m_lbUserMoney->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserMoney->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserMoney);
	
	m_dragMoney = new DragBar;
	m_dragMoney->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragMoney->SetDelegate(this);
	//m_dragMoney->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 220, 20));
	this->AddChild(m_dragMoney);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("timber"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynWood = new NDUILabel;
	m_lbSynWood->Initialization();
	m_lbSynWood->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynWood->SetText("");
	m_lbSynWood->SetFontSize(13);
	m_lbSynWood->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynWood->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynWood);
	
	m_lbUserWood = new NDUILabel;
	m_lbUserWood->Initialization();
	m_lbUserWood->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserWood->SetText("");
	m_lbUserWood->SetFontSize(13);
	m_lbUserWood->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserWood->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserWood);
	
	m_dragWood = new DragBar;
	m_dragWood->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragWood->SetDelegate(this);
	//m_dragWood->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 220, 20));
	this->AddChild(m_dragWood);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("StoneTimber"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynStone = new NDUILabel;
	m_lbSynStone->Initialization();
	m_lbSynStone->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynStone->SetText("");
	m_lbSynStone->SetFontSize(13);
	m_lbSynStone->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynStone->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynStone);
	
	m_lbUserStone = new NDUILabel;
	m_lbUserStone->Initialization();
	m_lbUserStone->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserStone->SetText("");
	m_lbUserStone->SetFontSize(13);
	m_lbUserStone->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserStone->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserStone);
	
	m_dragStone = new DragBar;
	m_dragStone->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragStone->SetDelegate(this);
	//m_dragStone->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 220, 20));
	this->AddChild(m_dragStone);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("paint"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynPaint = new NDUILabel;
	m_lbSynPaint->Initialization();
	m_lbSynPaint->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynPaint->SetText("");
	m_lbSynPaint->SetFontSize(13);
	m_lbSynPaint->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynPaint->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynPaint);
	
	m_lbUserPaint = new NDUILabel;
	m_lbUserPaint->Initialization();
	m_lbUserPaint->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserPaint->SetText("");
	m_lbUserPaint->SetFontSize(13);
	m_lbUserPaint->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserPaint->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserPaint);
	
	m_dragPaint = new DragBar;
	m_dragPaint->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragPaint->SetDelegate(this);
	//m_dragPaint->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 220, 20));
	this->AddChild(m_dragPaint);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("WuJing"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynCoal = new NDUILabel;
	m_lbSynCoal->Initialization();
	m_lbSynCoal->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynCoal->SetText("");
	m_lbSynCoal->SetFontSize(13);
	m_lbSynCoal->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynCoal->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynCoal);
	
	m_lbUserCoal = new NDUILabel;
	m_lbUserCoal->Initialization();
	m_lbUserCoal->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserCoal->SetText("");
	m_lbUserCoal->SetFontSize(13);
	m_lbUserCoal->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserCoal->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserCoal);
	
	m_dragCoal = new DragBar;
	m_dragCoal->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragCoal->SetDelegate(this);
	//m_dragCoal->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 220, 20));
	this->AddChild(m_dragCoal);
	
	fStartY += 30;
	imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_listitem_bg.png"), 440, 20), true);
	imgBg->SetFrameRect(CGRectMake(6, fStartY, 440, 20));
	this->AddChild(imgBg);
	
	label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(79, 79, 79, 255));
	label->SetText(NDCommonCString("emoney"));
	label->SetFrameRect(CGRectMake(fStartX, fStartY + 1, 56, 16));
	label->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(label);
	
	m_lbSynEmoney = new NDUILabel;
	m_lbSynEmoney->Initialization();
	m_lbSynEmoney->SetFontColor(ccc4(79, 79, 79, 255));
	m_lbSynEmoney->SetText("");
	m_lbSynEmoney->SetFontSize(13);
	m_lbSynEmoney->SetFrameRect(CGRectMake(fStartX + 50, fStartY + 3, 86, 14));
	m_lbSynEmoney->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbSynEmoney);
	
	m_lbUserEmoney = new NDUILabel;
	m_lbUserEmoney->Initialization();
	m_lbUserEmoney->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbUserEmoney->SetText("");
	m_lbUserEmoney->SetFontSize(13);
	m_lbUserEmoney->SetFrameRect(CGRectMake(fStartX + 356, fStartY + 3, 86, 14));
	m_lbUserEmoney->SetTextAlignment(LabelTextAlignmentRight);
	this->AddChild(m_lbUserEmoney);
	
	m_dragEmoney = new DragBar;
	m_dragEmoney->Initialization(CGRectMake(fStartX + 165, fStartY, 176, 20), 176);
	m_dragEmoney->SetDelegate(this);
	//m_dragEmoney->SetFrameRect();
	this->AddChild(m_dragEmoney);
	
	// 加减按钮
	btn = NULL;
	fStartY = 50;
	for (int i = eBtnAddBegin; i < eBtnAddEnd; i++) {
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetImage(pool.AddPicture(NDPath::GetImgPathNew("plus_selected.png")), false, CGRectZero, true);
		btn->SetFrameRect(CGRectMake(fStartX + 345, fStartY, 20, 20));
		btn->SetDelegate(this);
		btn->SetTag(i);
		this->AddChild(btn);
		fStartY += 30;
	}
	
	fStartY = 50;
	for (int i = eBtnMinusBegin; i < eBtnMinusEnd; i++) {
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetImage(pool.AddPicture(NDPath::GetImgPathNew("minu_selected.png")), false, CGRectZero, true);
		btn->SetFrameRect(CGRectMake(fStartX + 143, fStartY, 20, 20));
		btn->SetDelegate(this);
		btn->SetTag(i);
		this->AddChild(btn);
		fStartY += 30;
	}
}

void SynDonateUILayer::OnButtonClick(NDUIButton* button)
{
	int tag = button->GetTag();
	switch (tag) {
		case eBtnConfirm:
		{
			sendSynDonate(m_dragMoney->GetCur() * m_dragMoney->GetScale(),
						  m_dragEmoney->GetCur(),
						  m_dragWood->GetCur(),
						  m_dragStone->GetCur(),
						  m_dragCoal->GetCur(),
						  m_dragPaint->GetCur());
		}
			break;
		case eBtnAddMoney:
		{
			uint cur = m_dragMoney->GetCur();
			if (cur < m_dragMoney->GetMax()) {
				m_dragMoney->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusMoney:
		{
			uint cur = m_dragMoney->GetCur();
			if (cur > m_dragMoney->GetMin()) {
				m_dragMoney->SetCur(cur - 1, true);
			}
		}
			break;
		case eBtnAddEmoney:
		{
			uint cur = m_dragEmoney->GetCur();
			if (cur < m_dragEmoney->GetMax()) {
				m_dragEmoney->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusEmoney:
		{
			uint cur = m_dragEmoney->GetCur();
			if (cur > m_dragEmoney->GetMin()) {
				m_dragEmoney->SetCur(cur - 1, true);
			}
		}
			break;
		case eBtnAddWood:
		{
			uint cur = m_dragWood->GetCur();
			if (cur < m_dragWood->GetMax()) {
				m_dragWood->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusWood:
		{
			uint cur = m_dragWood->GetCur();
			if (cur > m_dragWood->GetMin()) {
				m_dragWood->SetCur(cur - 1, true);
			}
		}
			break;
		case eBtnAddStone:
		{
			uint cur = m_dragStone->GetCur();
			if (cur < m_dragStone->GetMax()) {
				m_dragStone->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusStone:
		{
			uint cur = m_dragStone->GetCur();
			if (cur > m_dragStone->GetMin()) {
				m_dragStone->SetCur(cur - 1, true);
			}
		}
			break;
		case eBtnAddPaint:
		{
			uint cur = m_dragPaint->GetCur();
			if (cur < m_dragPaint->GetMax()) {
				m_dragPaint->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusPaint:
		{
			uint cur = m_dragPaint->GetCur();
			if (cur > m_dragPaint->GetMin()) {
				m_dragPaint->SetCur(cur - 1, true);
			}
		}
			break;
		case eBtnAddCoal:
		{
			uint cur = m_dragCoal->GetCur();
			if (cur < m_dragCoal->GetMax()) {
				m_dragCoal->SetCur(cur + 1, true);
			}
		}
			break;
		case eBtnMinusCoal:
		{
			uint cur = m_dragCoal->GetCur();
			if (cur < m_dragCoal->GetMin()) {
				m_dragCoal->SetCur(cur - 1, true);
			}
		}
			break;
		default:
			break;
	}
}



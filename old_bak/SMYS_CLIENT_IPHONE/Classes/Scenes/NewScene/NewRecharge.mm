/*
 *  NewRecharge.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewRecharge.h"
#include "NDDirector.h"
#include "NDUISynLayer.h"
#include "NDDataTransThread.h"
#include "NDUIDefaultButton.h"
#include "NDMsgDefine.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#include <sstream>

#pragma mark 充值信息基类

IMPLEMENT_CLASS(RechargeInfoBase, NDUILayer)

RechargeInfoBase::RechargeInfoBase()
{
	m_lbTitle = NULL;
	
	m_contentScroll = NULL;
}

RechargeInfoBase::~RechargeInfoBase()
{
}

void RechargeInfoBase::Initialization(CGPoint point)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	this->SetBackgroundImage(picBagLeftBg, true);
	this->SetFrameRect(CGRectMake(point.x, point.y, sizeBagLeftBg.width, sizeBagLeftBg.height));
	
	NDUIImage *imageRes = new NDUIImage;
	imageRes->Initialization();
	imageRes->SetPicture(pool.AddPicture(GetImgPathNew("farmrheadtitle.png")), true);
	imageRes->SetFrameRect(CGRectMake(20, 14, 8, 8));
	this->AddChild(imageRes);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(16);
	m_lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, sizeBagLeftBg.width-4, 38));
	this->AddChild(m_lbTitle);
	
	NDPicture *picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	CGSize sizeCut = picCut->GetSize();
	
	NDUIImage* imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, 33, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, 250, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	int startX = 20 , endX = 194;
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetFrameRect(CGRectMake(startX, 35, endX-startX, 250-35-2));
	m_contentScroll->VisibleScroll(true);
	this->AddChild(m_contentScroll);
}

void RechargeInfoBase::SetTitle(const char* title)
{
	if (!title || !m_lbTitle) return;
	
	m_lbTitle->SetText(title);
}

void RechargeInfoBase::SetInfo(const char* info)
{
	if (m_contentScroll)
	{
		m_contentScroll->SetContent(info);
		m_contentScroll->SetVisible(this->IsVisibled());
	}
		
	if (!info)
		m_info = "";
	else
		m_info = info;
}

std::string RechargeInfoBase::GetInfo()
{
	return m_info;
}
	
#pragma mark 充值基本输入界面

IMPLEMENT_CLASS(RechargeBaseInput, NDUILayer)

RechargeBaseInput::RechargeBaseInput()
{
	m_lbTitle = NULL;
	
	m_contentScroll = NULL;
	
	m_btnCommit = NULL;
	
	m_input = NULL;
}

RechargeBaseInput::~RechargeBaseInput()
{
}

void RechargeBaseInput::Initialization(CGPoint point)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	this->SetBackgroundImage(picBagLeftBg, true);
	this->SetFrameRect(CGRectMake(point.x, point.y, sizeBagLeftBg.width, sizeBagLeftBg.height));
	
	int secondCutY = 215;
	
	CGSize sizeStart = InitInput();
	
	NDPicture *picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	CGSize sizeCut = picCut->GetSize();
	
	NDUIImage* imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, 28, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, sizeStart.height-3, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, secondCutY, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	int startX = 20 , endX = 194;
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetFrameRect(CGRectMake(startX-5, sizeStart.height-2, endX-startX, (secondCutY-sizeStart.height-4)));
	m_contentScroll->VisibleScroll(true);
	this->AddChild(m_contentScroll);
	
	NDPicture *picCommit = pool.AddPicture(GetImgPathNew("kefu_comit.png"));
	CGSize sizeCommit = picCommit->GetSize();
	m_btnCommit = new NDUIButton;
	m_btnCommit->Initialization();
	m_btnCommit->SetFrameRect(CGRectMake(9, secondCutY, sizeCommit.width, sizeCommit.height));
	m_btnCommit->SetImage(picCommit, false, CGRectZero, true);
	m_btnCommit->SetDelegate(this);
	this->AddChild(m_btnCommit);
	
	m_input = new CommonTextInput;
	m_input->Initialization();
	m_input->SetDelegate(this);
	this->AddChild(m_input);
	CGRect rect = m_input->GetFrameRect();
	rect.origin.y -= 37+12;
	m_input->SetFrameRect(rect);
}

void RechargeBaseInput::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnCommit)
	{
		OnCommit();
		
		return;
	}
	
	NDUILabel *lb = GetLabelByTag(button->GetTag());
	
	if (!lb) return;
	
	m_input->ShowContentTextField(true, lb->GetText().c_str());
	
	m_input->SetTag(button->GetTag());
}

void RechargeBaseInput::SetData(NewRechargeSubData& data)
{
	NDAsssert(data.iDataType == RechargeData_Card || data.iDataType == RechargeData_Message);
	
	SAFE_DELETE_NODE(m_lbTitle);
	
	CGSize parentsize = this->GetFrameRect().size;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	CGSize textSize;
	textSize.width = parentsize.width;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(data.text.c_str(), textSize.width, 14);
	
	m_lbTitle = NDUITextBuilder::DefaultBuilder()->Build(data.text.c_str(), 
															  14, 
															  textSize, 
															  ccc4(0, 0, 0, 255),
															  true);
	m_lbTitle->SetFrameRect(CGRectMake(25, (28-textSize.height), textSize.width, textSize.height));	
	
	this->AddChild(m_lbTitle);
	
	m_data = data;
}

void RechargeBaseInput::SetTip(const char* tip)
{
	if (m_contentScroll)
		m_contentScroll->SetContent(tip);
		
	m_tip = tip;
}

bool RechargeBaseInput::GetData(NewRechargeSubData& data)
{
	data = m_data;
	
	return true;
}

unsigned int RechargeBaseInput::GetButtonTag()
{
	return m_factoryTag.GetID();
}

std::string  RechargeBaseInput::GetTextByTag(unsigned int tag)
{	
	NDUILabel *lb = GetLabelByTag(tag);
	
	if (!lb) return "";
	
	return lb->GetText();
}

NDUILabel* RechargeBaseInput::GetLabelByTag(unsigned int tag)
{
	std::map<unsigned int, NDUILabel*>::iterator
	it = m_mapText.find(tag);
	
	if (it == m_mapText.end())
		return NULL;
	
	return it->second;
}

CGSize RechargeBaseInput::InitInput()
{
	NDAsssert(false);
	
	return CGSizeZero;
}

void RechargeBaseInput::OnCommit()
{
	NDAsssert(false);
}

void RechargeBaseInput::OnSend()
{
	NDAsssert(false);
}

bool RechargeBaseInput::SetTextContent(CommonTextInput* input, const char* text)
{
	if (m_input == input)
	{
		NDUILabel *lb = GetLabelByTag(input->GetTag());
		if (lb) lb->SetText(text);
	}
	
	return true;
}

void RechargeBaseInput::AddInput(int btnTag, const char* lbText, int startY)
{
	int startX = 8;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILabel* lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(14);
	lb->SetFrameRect(CGRectMake(startX, startY, winsize.width, winsize.height));
	lb->SetFontColor(ccc4(188, 20, 17, 255));
	lb->SetText(lbText);
	this->AddChild(lb);
	
	NDPicture* pic = NULL;
	NDUIMutexStateButton*btn = new NDUIMutexStateButton;
	btn->Initialization();
	pic = pool.AddPicture(GetImgPathNew("text_back.png"), 421, 27);
	btn->SetNormalImage(pic, false, CGRectMake(0, 0, 0, 0));
	pic = pool.AddPicture(GetImgPathNew("text_back_focus.png"), 421, 27); 
	btn->SetFocusImage(pic, false, CGRectMake(0, 0, 0, 0));
	btn->SetFrameRect(CGRectMake(startX, startY+18, 185, 27));
	btn->SetDelegate(this);
	btn->SetTag(btnTag);
	this->AddChild(btn);
	
	
	NDUILabel* lbBtn = new NDUILabel;
	lbBtn->Initialization();
	lbBtn->SetTextAlignment(LabelTextAlignmentLeft);
	lbBtn->SetFontSize(14);
	lbBtn->SetFrameRect(CGRectMake(2, 6, winsize.width, winsize.height));
	lbBtn->SetFontColor(ccc4(188, 20, 17, 255));
	btn->AddChild(lbBtn);
	
	m_mapText[btnTag] = lbBtn;
}

void RechargeBaseInput::ShowCommitTipDialog()
{
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show(NDCommonCString("ZhuYiShiXiang"), m_tip.c_str(), NDCommonCString("Cancle"), NDCommonCString("Ok"), NULL);
}

void RechargeBaseInput::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	
	OnSend();
}

#pragma mark 充值卡输入界面

IMPLEMENT_CLASS(RechargeCardInput, RechargeBaseInput)

RechargeCardInput::RechargeCardInput()
{
	m_tagCardNum = m_tagCardPassword = 0;
}

RechargeCardInput::~RechargeCardInput()
{
}

CGSize RechargeCardInput::InitInput()
{
	m_tagCardNum = this->GetButtonTag();
	
	AddInput(m_tagCardNum, NDCommonCString("InputRechargeCardNum"), 37);
	
	m_tagCardPassword = this->GetButtonTag();
	
	AddInput(m_tagCardPassword, NDCommonCString("InputRechargeCardPW"), 94);
	
	return CGSizeMake(0, 147);
}

void RechargeCardInput::OnCommit()
{
	NDAsssert(m_data.iDataType == RechargeData_Card);
	
	NDUILabel* lbCardNum = this->GetLabelByTag(m_tagCardNum);
	NDUILabel* lbCardPW = this->GetLabelByTag(m_tagCardPassword);
	
	NDAsssert(lbCardNum != NULL && lbCardPW != NULL);
	
	if (!lbCardNum || !lbCardPW) return;
	
	std::string strCardNum = lbCardNum->GetText();
	std::string strCardPW = lbCardPW->GetText();
	
	if (!(strCardNum.size() > 0 && strCardPW.size() > 0))
	{
		showDialog(NDCommonCString("tip"), NDCommonCString("CardOrPWNotEmpty"));
		
		return;
	}
	
	this->ShowCommitTipDialog();
}

void RechargeCardInput::OnSend()
{
	NDAsssert(m_data.iDataType == RechargeData_Card);
	
	NDUILabel* lbCardNum = this->GetLabelByTag(m_tagCardNum);
	NDUILabel* lbCardPW = this->GetLabelByTag(m_tagCardPassword);
	
	NDAsssert(lbCardNum != NULL && lbCardPW != NULL);
	
	if (!lbCardNum || !lbCardPW) return;
	
	std::string strCardNum = lbCardNum->GetText();
	std::string strCardPW = lbCardPW->GetText();
	
	if (!(strCardNum.size() > 0 && strCardPW.size() > 0))
	{
		showDialog(NDCommonCString("tip"), NDCommonCString("CardOrPWNotEmpty"));
		
		return;
	}
	
	NDTransData bao(MB_MSG_RECHARGE);
	bao << int(m_data.iId);
	bao.WriteUnicodeString(loadPackInfo(STRPARAM));
	bao.WriteUnicodeString(strCardNum);
	bao.WriteUnicodeString(strCardPW);
	SEND_DATA(bao);
}

#pragma mark 短信充值输入界面

IMPLEMENT_CLASS(RechargeMessageInput, RechargeBaseInput)

RechargeMessageInput::RechargeMessageInput()
{
}

RechargeMessageInput::~RechargeMessageInput()
{
}

CGSize RechargeMessageInput::InitInput()
{
	m_tagPhoneNum = this->GetButtonTag();
	
	AddInput(m_tagPhoneNum, NDCommonCString("InputPhoneNum"), 37);
	
	return CGSizeMake(0, 98);
}

void RechargeMessageInput::OnCommit()
{
	NDAsssert(m_data.iDataType == RechargeData_Message);
	
	NDUILabel* lbPhoneNum = this->GetLabelByTag(m_tagPhoneNum);
	
	NDAsssert(lbPhoneNum != NULL);
	
	if (!lbPhoneNum) return;
	
	std::string strPhoneNum = lbPhoneNum->GetText();
	
	if (!(strPhoneNum.size() > 0))
	{
		showDialog(NDCommonCString("tip"), NDCommonCString("PhoneNumNotEmpty"));
		
		return;
	}
	
	this->ShowCommitTipDialog();
}

void RechargeMessageInput::OnSend()
{
	NDAsssert(m_data.iDataType == RechargeData_Message);
	
	NDUILabel* lbPhoneNum = this->GetLabelByTag(m_tagPhoneNum);
	
	NDAsssert(lbPhoneNum != NULL);
	
	if (!lbPhoneNum) return;
	
	std::string strPhoneNum = lbPhoneNum->GetText();
	
	if (!(strPhoneNum.size() > 0))
	{
		showDialog(NDCommonCString("tip"), NDCommonCString("PhoneNumNotEmpty"));
		
		return;
	}
	
	NDTransData bao(MB_MSG_RECHARGE);
	bao << int(m_data.iId);
	bao.WriteUnicodeString(loadPackInfo(STRPARAM));
	bao.WriteUnicodeString(strPhoneNum);
	bao.WriteUnicodeString(NDCommonCString("ShortMsg"));
	SEND_DATA(bao);
}
	
#pragma mark　卡类型基本UI

IMPLEMENT_CLASS(CardBaseUI, NDUIButton)

CardBaseUI::CardBaseUI()
{	
	m_text = NULL;
	
	m_textfocus = NULL;
}

CardBaseUI::~CardBaseUI()
{
}

void CardBaseUI::Initialization(CGRect rect)
{
	NDUIButton::Initialization();
	
	this->CloseFrame();
	this->SetFrameRect(rect);
}

void CardBaseUI::draw()
{
	NDUIButton::draw();
	
	if (!this->IsVisibled()) return;
	
	NDNode *pParent = this->GetParent();
	bool focus = false;
	if (pParent 
		&& pParent->IsKindOfClass(RUNTIME_CLASS(NDUILayer))
		&& ((NDUILayer*)pParent)->GetFocus() == this)
	{
		focus = true;
	}
	
	if (m_text)
		m_text->SetVisible(!focus);
		
	if (m_textfocus)
		m_textfocus->SetVisible(focus);
		
	ccColor4B color = focus ? ccc4(255, 0, 0, 255) : ccc4(0, 0, 255, 255);
	
	CGRect rect = this->GetScreenRect();
	
	float width = rect.size.width;
	float x = 0.0f;
	if (m_text)
	{
		CGRect rectText = m_text->GetFrameRect();
		width = rectText.size.width;
		x = rectText.origin.x;
	}
		
	CGPoint fromPos = ccpAdd(ccp(x, rect.size.height+1), rect.origin),
			toPos = ccpAdd(ccp(x+width, rect.size.height+1), rect.origin);
	DrawLine(fromPos,toPos,color,1);
}

void CardBaseUI::SetSubData(NewRechargeSubData& data)
{
	SAFE_DELETE_NODE(m_text);
	
	SAFE_DELETE_NODE(m_textfocus);
	
	CGSize parentsize = this->GetFrameRect().size;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	CGSize textSize;
	textSize.width = parentsize.width;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(data.text.c_str(), textSize.width, 14);
	textSize.width = NDUITextBuilder::DefaultBuilder()->StringWidthAfterFilter(data.text.c_str(), textSize.width, 14);
	m_text = NDUITextBuilder::DefaultBuilder()->Build(data.text.c_str(), 
															  14, 
															  textSize, 
															  ccc4(0, 0, 255, 255),
															  true);
	
	CGRect rect = CGRectMake((parentsize.width-textSize.width)/2, (parentsize.height-textSize.height), textSize.width, textSize.height);
	
	m_text->SetFrameRect(rect);	
	
	this->AddChild(m_text);
	
	m_textfocus = new NDUILabel;
	m_textfocus->Initialization();
	m_textfocus->SetTextAlignment(LabelTextAlignmentLeft);
	m_textfocus->SetFontSize(14);
	m_textfocus->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y, winsize.width, winsize.height));
	m_textfocus->SetFontColor(ccc4(255, 0, 0, 255));
	m_textfocus->SetText(data.text.c_str());
	this->AddChild(m_textfocus);
	
	m_textfocus->SetVisible(false);

	m_subdata = data;
}

bool CardBaseUI::GetSubData(NewRechargeSubData& data)
{
	data = m_subdata;
	
	return true;
}


#pragma mark 支付通道Cell

IMPLEMENT_CLASS(RechargeChannelCell, CardBaseUI)

RechargeChannelCell::RechargeChannelCell()
{
}

RechargeChannelCell::~RechargeChannelCell()
{
}

void RechargeChannelCell::SetData(NewRechargeData& data)
{
	m_data = data;
	
	SetSubData(data.mainData);
}

bool RechargeChannelCell::GetData(NewRechargeData& data)
{
	data = m_data;
	
	return true;
}

void RechargeChannelCell::UpdateTip(std::string tip)
{
	m_data.tip =  tip;
}

#pragma mark 支付面额Cell

IMPLEMENT_CLASS(RechargeFaceValueCell, CardBaseUI)

RechargeFaceValueCell::RechargeFaceValueCell()
{
}

RechargeFaceValueCell::~RechargeFaceValueCell()
{
}

#pragma mark 充值界面

IMPLEMENT_CLASS(RechargeUI, NDUILayer)

void RechargeUI::ProcessQueryTip(NDTransData& data)
{
	CloseProgressBar;
	
	std::string rechargeInfoTitle=data.ReadUnicodeString();
	std::string rechargeInfo=data.ReadUnicodeString();
	
	if (s_instance && s_instance->UpdateQueryTip(rechargeInfo))
		return;
	
	GlobalShowDlg(rechargeInfoTitle.c_str(), rechargeInfo.c_str());
}

void RechargeUI::ProcessGiftInfo(NDTransData& data)
{
	std::string str = data.ReadUnicodeString();
	
	if (!s_instance || !s_instance->m_infoGongGao) return;
	
	s_instance->m_infoGongGao->SetInfo(str.c_str());
}

RechargeUI *RechargeUI::s_instance = NULL;

vec_recharge_data RechargeUI::s_data;

RechargeUI::RechargeUI()
{
	m_lbTitle = NULL;
	m_scrollChannel = NULL;
	m_scrollFaceValue = NULL;
	m_lbPage = NULL;
	m_btnPrev = NULL;
	m_btnNext = NULL;
	m_btnReturn = NULL;
	m_iCurFaceValuePage = 0;
	m_infoGongGao = NULL;
	m_infoTip = NULL;
	m_inputCard = NULL;
	m_inputMessage = NULL;
	m_curDealChannelCell = NULL;
	m_iState = State_None;
	m_bCard = false;
	s_instance = this;
}

RechargeUI::~RechargeUI()
{
	s_instance = NULL;
	
	s_data.clear();
}

void RechargeUI::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int startX = 235, endX = 434 , startScrollY = 44, endScrollY = 222;
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFontSize(16);
	m_lbTitle->SetFrameRect(CGRectMake(218, 17, 443-218, 20));
	m_lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	this->AddChild(m_lbTitle);
	
	NDPicture *picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	CGSize sizeCut = picCut->GetSize();
	
	int startCutX = startX+(endX-startX-sizeCut.width)/2;
	NDUIImage* imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake(startCutX, startScrollY-2, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	imageCut = new NDUIImage;
	imageCut->Initialization();
	imageCut->SetPicture(picCut, true);
	imageCut->SetFrameRect(CGRectMake(startCutX, endScrollY+2, sizeCut.width, sizeCut.height));
	imageCut->EnableEvent(false);
	this->AddChild(imageCut);
	
	m_scrollChannel = new NDUIContainerScrollLayer;
	m_scrollChannel->Initialization();
	m_scrollChannel->SetFrameRect(CGRectMake(startX-18, startScrollY, endX-startX+30, endScrollY-startScrollY));
	m_scrollChannel->VisibleScroll(true);
	//m_scrollChannel->SetBackgroundColor(ccc4(0, 0, 0, 255));
	this->AddChild(m_scrollChannel);
	
	m_scrollFaceValue = new NDUIContainerScrollLayer;
	m_scrollFaceValue->Initialization();
	m_scrollFaceValue->SetFrameRect(CGRectMake(startX-18, startScrollY, endX-startX+30, 180));
	m_scrollFaceValue->VisibleScroll(true);
	this->AddChild(m_scrollFaceValue);
	
	int startBtn1X = 220, startBtn1Y = 231,
		startBtn2X = 303,
		startBtn3X = 400;
		
	m_btnPrev = new NDUIButton;
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake(startBtn1X, startBtn1Y, 36, 36));
	m_btnPrev->SetDelegate(this);
	m_btnPrev->SetImage(pool.AddPicture(GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnPrev->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton;
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake(startBtn2X, startBtn1Y, 36, 36));
	m_btnNext->SetDelegate(this);
	m_btnNext->SetImage(pool.AddPicture(GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnNext->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbPage->SetFontSize(16);
	m_lbPage->SetFontColor(ccc4(136, 41, 41, 255));
	m_lbPage->SetFrameRect(CGRectMake(m_btnPrev->GetFrameRect().origin.x, 
									  m_btnPrev->GetFrameRect().origin.y, 
									  m_btnNext->GetFrameRect().origin.x
									  +m_btnNext->GetFrameRect().size.width
									  -m_btnPrev->GetFrameRect().origin.x, 
									  m_btnPrev->GetFrameRect().size.height));
	m_lbPage->SetText("8888888");
	this->AddChild(m_lbPage);
	
	m_btnReturn = new NDUIButton;
	m_btnReturn->Initialization();
	m_btnReturn->SetFrameRect(CGRectMake(startBtn3X, startBtn1Y+10, 48, 24));
	m_btnReturn->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnReturn->SetFontSize(12);
	m_btnReturn->CloseFrame();
	m_btnReturn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png")),
							  pool.AddPicture(GetImgPathNew("bag_btn_click.png")),
							  false, CGRectZero, true);
	m_btnReturn->SetDelegate(this);
	m_btnReturn->SetTitle(NDCommonCString("return"));
	this->AddChild(m_btnReturn);
	
	/*
	m_btnReturn = new NDUIButton;
	m_btnReturn->Initialization();
	m_btnReturn->SetFrameRect(CGRectMake(startBtn3X, startBtn1Y, 36, 36));
	m_btnReturn->SetDelegate(this);
	m_btnReturn->SetImage(pool.AddPicture(GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);
	m_btnReturn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);
	this->AddChild(m_btnReturn);
	*/
	
	m_infoGongGao = new RechargeInfoBase;
	m_infoGongGao->Initialization(ccp(0, 12));
	m_infoGongGao->SetTitle(NDCommonCString("RechargeGongGao"));
	this->AddChild(m_infoGongGao);
	
	m_infoTip = new RechargeInfoBase;
	m_infoTip->Initialization(ccp(0, 12));
	m_infoTip->SetTitle(NDCommonCString("ZhuYiShiXiang"));
	this->AddChild(m_infoTip);
	
	m_inputCard = new RechargeCardInput;
	m_inputCard->Initialization(ccp(0, 12));
	this->AddChild(m_inputCard);
	
	m_inputMessage = new RechargeMessageInput;
	m_inputMessage->Initialization(ccp(0, 12));
	this->AddChild(m_inputMessage);
	
	// recharge channel data
	int parentWidth = m_scrollChannel->GetFrameRect().size.width;
	int i = 0;
	for_vec(s_data, vec_recharge_data_it)
	{
		NewRechargeData& rechargedata = *it;
		
		if (rechargedata.vSubData.empty()) continue;
		
		RechargeChannelCell *cell = new RechargeChannelCell;
		CGRect rect = CGRectMake(0, i*20, parentWidth-m_scrollChannel->GetScrollBarWidth(), 20);
		cell->Initialization(rect);
		cell->SetData(rechargedata);
		cell->SetDelegate(this);
		m_scrollChannel->AddChild(cell);
		i++;
	}
	m_scrollChannel->refreshContainer();
	
	ShowRechargeChannel();
}

void RechargeUI::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnPrev)
	{
		ShowPrev();
	}
	else if (button == m_btnNext)
	{
		ShowNext();
	}
	else if (button == m_btnReturn)
	{
		ShowRechargeChannel();
	}
	else if (button->IsKindOfClass(RUNTIME_CLASS(RechargeChannelCell)))
	{
		if (button->GetParent() != m_scrollChannel || !m_scrollChannel->IsVisibled()) return;
		
		RechargeChannelCell *cell = (RechargeChannelCell*)button;
		
		NewRechargeData data;
		
		if (!cell->GetData(data)) return;
		
		if (data.tip.empty())
		{
			ShowProgressBar;
			m_curDealChannelCell = cell;
			sendChargeInfo(data.tipData.iId);
			return;
		}
		
		ShowFaceValue(data);
	}
	else if (button->IsKindOfClass(RUNTIME_CLASS(RechargeFaceValueCell)))
	{
		if (button->GetParent() != m_scrollFaceValue || !m_scrollFaceValue->IsVisibled()) return;
		
		RechargeFaceValueCell *cell = (RechargeFaceValueCell*)button;
		
		NewRechargeSubData data;
		
		if (!cell->GetSubData(data)) return;
		
		ShowInput(data, m_infoTip->GetInfo().c_str());
	}
}

void RechargeUI::SetVisible(bool visible)
{	
	NDUILayer::SetVisible(visible);
	
	if (!visible) return;
	
	switch (m_iState) 
	{
		case State_ShowChannel:
		{
			m_infoGongGao->SetVisible(true);
			m_infoTip->SetVisible(false);
			
			m_scrollChannel->SetVisible(true);
			m_scrollFaceValue->SetVisible(false);
			
			m_inputCard->SetVisible(false);
			m_inputMessage->SetVisible(false);
			ShowPageUI(false);
		}
			break;
		case State_ShowFaceValue:
		{
			m_infoGongGao->SetVisible(false);
			m_infoTip->SetVisible(true);
			m_scrollChannel->SetVisible(false);
			m_scrollFaceValue->SetVisible(true);
			
			m_inputCard->SetVisible(false);
			m_inputMessage->SetVisible(false);
			ShowPageUI(true);
		}
			break;
		case State_ShowInput:
		{
			m_infoGongGao->SetVisible(false);
			
			m_infoTip->SetVisible(false);
			
			m_inputCard->SetVisible(m_bCard);
			
			m_inputMessage->SetVisible(!m_bCard);
			
			m_scrollFaceValue->SetVisible(true);
			
			m_scrollChannel->SetVisible(false);
			
			ShowPageUI(true);
		}
			break;
		default:
			break;
	}
}

void RechargeUI::ShowPageUI(bool show)
{
	m_btnReturn->SetVisible(show);
	m_btnPrev->SetVisible(show);
	m_btnNext->SetVisible(show);
	m_lbPage->SetVisible(show);
}

void RechargeUI::ShowFaceValue(NewRechargeData& data)
{
	m_vRechargeFaceValue.clear();
	
	m_iState = State_ShowFaceValue;
	
	m_infoGongGao->SetVisible(false);
	m_infoTip->SetVisible(true);
	m_infoTip->SetInfo(data.tip.c_str());
	
	m_scrollChannel->SetVisible(false);
	m_scrollFaceValue->SetVisible(true);
	
	m_inputCard->SetVisible(false);
	m_inputMessage->SetVisible(false);
	
	m_lbTitle->SetText(data.mainData.text.c_str());
	
	ShowPageUI(true);
	
	m_scrollFaceValue->RemoveAllChildren(true);
	int parentWidth = m_scrollFaceValue->GetFrameRect().size.width;
	int i = 0;
	
	for_vec(data.vSubData, vec_recharge_subdata_it)
	{
		NewRechargeSubData& rechargeSubData = *it;
		
		RechargeFaceValueCell *cell = new RechargeFaceValueCell;
		CGRect rect = CGRectMake(0, i*20, parentWidth-m_scrollFaceValue->GetScrollBarWidth(), 20);
		cell->Initialization(rect);
		cell->SetSubData(rechargeSubData);
		cell->SetDelegate(this);
		m_vRechargeFaceValue.push_back(cell);
		m_scrollFaceValue->AddChild(cell);
		i++;
	}
	m_scrollFaceValue->refreshContainer(GetPageCount()*180);
	
	UpdateCurpageFaceValue();
}

void RechargeUI::ShowRechargeChannel()
{
	m_iState = State_ShowChannel;
	
	m_infoGongGao->SetVisible(true);
	m_infoTip->SetVisible(false);
	
	m_scrollChannel->SetVisible(true);
	m_scrollFaceValue->SetVisible(false);
	
	m_inputCard->SetVisible(false);
	m_inputMessage->SetVisible(false);
	
	m_lbTitle->SetText(NDCommonCString("PayChannel"));
	
	ShowPageUI(false);
}

void RechargeUI::ShowInput(NewRechargeSubData& data, const char* tip)
{
	NDAsssert(data.iDataType == RechargeData_Card || data.iDataType == RechargeData_Message);
	
	m_iState = State_ShowInput;
	
	bool card = data.iDataType == RechargeData_Card;
	
	m_bCard = card;
	
	m_inputCard->SetVisible(card);
	
	m_inputMessage->SetVisible(!card);
	
	m_infoGongGao->SetVisible(false);
	
	m_infoTip->SetVisible(false);
	
	if (card)
	{
		m_inputCard->SetData(data);
		
		m_inputCard->SetTip(tip);
	}
	else
	{
		m_inputMessage->SetData(data);
		
		m_inputMessage->SetTip(tip);
	}
}

bool RechargeUI::UpdateQueryTip(std::string tip)
{
	if (!m_curDealChannelCell) return false;
	
	m_curDealChannelCell->UpdateTip(tip);
	
	NewRechargeData data;
	
	if (!m_curDealChannelCell->GetData(data)) return true;
	
	ShowFaceValue(data);
	
	m_curDealChannelCell = NULL;
	
	return true;
}

void RechargeUI::ShowNext()
{
	size_t pageCount = GetPageCount();
	
	m_iCurFaceValuePage = pageCount == 0 ? 0 : (m_iCurFaceValuePage+1)%pageCount;
	
	UpdateCurpageFaceValue();
}

void RechargeUI::ShowPrev()
{
	
	int pageCount = GetPageCount();
	
	if (m_iCurFaceValuePage == 0)
		m_iCurFaceValuePage = pageCount == 0 ? 0 : pageCount-1;
	else
		m_iCurFaceValuePage = pageCount == 0 ? 0 : m_iCurFaceValuePage-1;
	
	UpdateCurpageFaceValue();
	
}

void RechargeUI::UpdateCurpageFaceValue()
{
	size_t size = m_vRechargeFaceValue.size();
	
	size_t top = m_iCurFaceValuePage * 9;
	
	if (top < size && m_scrollFaceValue)
	{
		m_scrollFaceValue->ScrollNodeToTop(m_vRechargeFaceValue[top]);
	}
	
	if (!m_lbPage) return;
	
	std::stringstream ss;
	
	int pageCount = GetPageCount();
	
	int curPage = pageCount == 0 ? 0 : m_iCurFaceValuePage + 1;
	
	ss << curPage << "/" << pageCount;
	
	m_lbPage->SetText(ss.str().c_str());
}

int RechargeUI::GetPageCount()
{
	size_t size = m_vRechargeFaceValue.size();
	
	return size / 9 + (size % 9 != 0 ? 1 : 0);
	
}

#pragma mark 充值记录

IMPLEMENT_CLASS(RechargeRecordUI, NDUILayer)

RechargeRecordUI* RechargeRecordUI::s_instance = NULL;
RechargeRecord RechargeRecordUI::s_data;

void RechargeRecordUI::prcessRecord(NDTransData& data)
{
	CloseProgressBar;
	
	RechargeRecord& record = RechargeRecordUI::s_data;
	
	record.clear();
	
	int size = data.ReadByte();

	for (int i = 0; i < size; i++) 
	{
		std::string text1 = data.ReadUnicodeString();
		int iValue = data.ReadByte();
		std::stringstream ss; ss << iValue;
		record.total += iValue;
		record.vData.push_back(RechargeRecordData(text1, ss.str()));
	}
	
	if (s_instance) {
		s_instance->Update();
	}
}
	
RechargeRecordUI::RechargeRecordUI()
{
	m_lbDate = NULL;
	
	m_tlRecord = NULL;
	
	s_instance = this;
}

RechargeRecordUI::~RechargeRecordUI()
{	
	s_instance = NULL;
	
	s_data.clear();
}

void RechargeRecordUI::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDUILayer *layerleft = new NDUILayer;
	layerleft->Initialization();
	NDPicture* picBagLeftBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	CGSize sizeBagLeftBg = picBagLeftBg->GetSize();
	layerleft->SetBackgroundImage(picBagLeftBg, true);
	layerleft->SetFrameRect(CGRectMake(0, 12, sizeBagLeftBg.width, sizeBagLeftBg.height));
	this->AddChild(layerleft);
	
	NDUIImage *imageRes = new NDUIImage;
	imageRes->Initialization();
	imageRes->SetPicture(pool.AddPicture(GetImgPathNew("farmrheadtitle.png")), true);
	imageRes->SetFrameRect(CGRectMake(20, 14, 8, 8));
	layerleft->AddChild(imageRes);
	
	NDUILabel* lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(16);
	lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	lbTitle->SetTextAlignment(LabelTextAlignmentLeft);
	lbTitle->SetFrameRect(CGRectMake(32, 10, sizeBagLeftBg.width-4, 38));
	lbTitle->SetText(NDCommonCString("PersonalInfo"));
	layerleft->AddChild(lbTitle);
	
	NDPicture* picRoleBg = pool.AddPicture(GetImgPathNew("attr_role_bg.png"));
	CGSize sizeRoleBg = picRoleBg->GetSize();
	
	NDUIImage *imgTotal = new NDUIImage;
	imgTotal->Initialization();
	imgTotal->SetFrameRect(CGRectMake(0,26, sizeRoleBg.width, sizeRoleBg.height));
	imgTotal->SetPicture(picRoleBg, true);
	layerleft->AddChild(imgTotal);
	
	NDUILabel *lbTotal = new NDUILabel();
	lbTotal->Initialization();
	lbTotal->SetText(NDCommonCString("TotalPay"));
	lbTotal->SetFontSize(14);
	lbTotal->SetTextAlignment(LabelTextAlignmentLeft);
	lbTotal->SetFontColor(ccc4(126,0,0,255));
	lbTotal->SetFrameRect(CGRectMake(10, 15, sizeRoleBg.width, 15));
	imgTotal->AddChild(lbTotal);
	
	CGSize sizeTotol = getStringSize(NDCommonCString("TotalPay"), 14);
	
	m_lbDate = new NDUILabel();
	m_lbDate->Initialization();
	m_lbDate->SetFontSize(13);
	m_lbDate->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbDate->SetFontColor(ccc4(255,0,0,255));
	m_lbDate->SetFrameRect(CGRectMake(10+sizeTotol.width, 15, sizeRoleBg.width, 15));
	imgTotal->AddChild(m_lbDate);
	
	int startX = 214, endX = 451 , startScrollY = 88-37, endScrollY = 303-37;
	
	lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lbTitle->SetFontSize(16);
	lbTitle->SetFrameRect(CGRectMake(218, 17, 443-218, 20));
	lbTitle->SetText(NDCommonCString("RechargeRecord"));
	lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	this->AddChild(lbTitle);
	
	/*
	lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(16);
	lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lbTitle->SetFrameRect(CGRectMake(280, 17, winsize.width, winsize.height));
	lbTitle->SetText("充值记录");
	this->AddChild(lbTitle);
	*/
	
	NDUILayer *layerRecordTitle = new NDUILayer;
	layerRecordTitle->Initialization();
	layerRecordTitle->SetFrameRect(CGRectMake(startX, startScrollY, endX-startX, 20));
	layerRecordTitle->SetBackgroundColor(ccc4(199, 155, 25, 255));
	this->AddChild(layerRecordTitle);
	
	lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(14);
	lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	lbTitle->SetTextAlignment(LabelTextAlignmentLeft);
	lbTitle->SetFrameRect(CGRectMake(30, 3, winsize.width, winsize.height));
	lbTitle->SetText(NDCommonCString("date"));
	layerRecordTitle->AddChild(lbTitle);
	
	CGSize moneysize = getStringSize(NDCommonCString("JingEr"), 16);
	lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(14);
	lbTitle->SetFontColor(ccc4(126, 0, 0, 255));
	lbTitle->SetTextAlignment(LabelTextAlignmentLeft);
	lbTitle->SetFrameRect(CGRectMake(endX-startX-30-moneysize.width, 3, winsize.width, winsize.height));
	lbTitle->SetText(NDCommonCString("JingEr"));
	layerRecordTitle->AddChild(lbTitle);
	
	m_tlRecord = new NDUITableLayer;
	m_tlRecord->Initialization();
	m_tlRecord->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlRecord->VisibleSectionTitles(false);
	m_tlRecord->SetFrameRect(CGRectMake(startX, startScrollY+25, endX-startX, endScrollY-startScrollY-25));
	//m_tlRecord->VisibleScrollBar(true);
	m_tlRecord->SetCellsInterval(2);
	m_tlRecord->SetCellsRightDistance(0);
	m_tlRecord->SetCellsLeftDistance(0);
	//m_tlRecord->SetBackgroundColor(ccc4(0, 0, 0, 255));
	m_tlRecord->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	dataSource->AddSection(section);
	m_tlRecord->SetDataSource(dataSource);
	this->AddChild(m_tlRecord);
	
	Update();
}

void RechargeRecordUI::Update()
{
	refreshRecord();
	
	std::stringstream ss; ss << s_data.total;
	SetTotal(ss.str().c_str());
}

void RechargeRecordUI::refreshRecord()
{
	NDUITableLayer *tablelayer = m_tlRecord;
	
	if (!tablelayer || !tablelayer->GetDataSource())
	{
		return;
	}
	
	NDSection *section = tablelayer->GetDataSource()->Section(0);
	if (!section)
	{
		return;
	}
	
	section->Clear();
	
	vec_recharge_record_data& vData = s_data.vData;
	
	for_vec(vData, vec_recharge_record_data_it)
	{
		RechargeRecordData& data = *it;
		
		NDPropCell  *propDetail = new NDPropCell;
		propDetail->Initialization(false);
		if (propDetail->GetKeyText())
			propDetail->GetKeyText()->SetText(data.date.c_str());
		
		if (propDetail->GetValueText())
			propDetail->GetValueText()->SetText(data.money.c_str());
			
		propDetail->SetFocusTextColor(ccc4(187, 19, 19, 255));
		
		section->AddCell(propDetail);
	}
	
	section->SetFocusOnCell(0);
	
	tablelayer->ReflashData();
	
	if (!this->IsVisibled())
		tablelayer->SetVisible(false);
}

void RechargeRecordUI::SetTotal(const char*text)
{
	if (m_lbDate)
		m_lbDate->SetText(text);
}

#pragma mark 充值

IMPLEMENT_CLASS(Recharge, NDCommonLayer)

Recharge::Recharge()
{
}

Recharge::~Recharge()
{
}

void Recharge::Initialization()
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	const char * text[2] = 
	{
		NDCommonCString("recharge"),
		NDCommonCString("query"),
	};
	
	float maxTitleLen = getStringSize(NDCommonCString("recharge"), 16).width;
	
	maxTitleLen += 36;
	
	NDCommonLayer::Initialization(maxTitleLen);
	
	for(int i = 0; i < 2; i++)
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), maxTitleLen, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), maxTitleLen, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(text[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
		
		NDUIClientLayer *client = this->GetClientLayer(i);
		
		CGSize clientsize = this->GetClientSize();
		
		if (i == 0)
		{
			RechargeUI *info = new RechargeUI;
			info->Initialization();
			info->SetFrameRect(CGRectMake(0, 0, clientsize.width, clientsize.height));
			client->AddChild(info);
		}
		else if (i == 1)
		{
			RechargeRecordUI *info = new RechargeRecordUI;
			info->Initialization();
			info->SetFrameRect(CGRectMake(0, 0, clientsize.width, clientsize.height));
			client->AddChild(info);
			
		}
	}
	
	this->SetTabFocusOnIndex(0, true);
}

void Recharge::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{	
	NDCommonLayer::OnTabLayerSelect(tab, lastIndex, curIndex);
	
	if (curIndex == 1 && RechargeRecordUI::s_data.empty())
	{
		for_vec(RechargeUI::s_data, vec_recharge_data_it)
		{
			NewRechargeData& rechargedata = *it;
			
			if (!rechargedata.vSubData.empty()) continue;
			
			//if (rechargedata.mainData.iDataType == RechargeData_Tip)
			//{
				sendChargeInfo(rechargedata.mainData.iId);
				ShowProgressBar;
			//}
		}
		
	}
}

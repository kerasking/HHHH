/*
 *  SystemAndCustomLayer.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-30.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SystemAndCustomLayer.h"
#include "NDDirector.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDUtility.h"
#include "NDBeforeGameMgr.h"
#include "NDMapMgr.h"
#include "CGPointExtension.h"
#include "NDTextNode.h"
#include "NDPlayer.h"

#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>

#pragma mark 客服反馈

IMPLEMENT_CLASS(CustomFeedBack, NDUILayer)

CustomFeedBack::CustomFeedBack()
{
	m_contentScroll = NULL;
	
	m_lbFeedbackContent = NULL;
	
	m_input = NULL;
	
	m_btnCommit = NULL;
}

CustomFeedBack::~CustomFeedBack()
{
}

void CustomFeedBack::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int startX = 17;
	
	NDUILabel *lbQuestion = new NDUILabel;
	lbQuestion->Initialization();
	lbQuestion->SetTextAlignment(LabelTextAlignmentLeft);
	lbQuestion->SetFontSize(14);
	lbQuestion->SetFrameRect(CGRectMake(startX, 58-37, winsize.width, winsize.height));
	lbQuestion->SetFontColor(ccc4(188, 20, 17, 255));
	lbQuestion->SetText(NDCommonCString("WoYaoTiWen"));
	this->AddChild(lbQuestion);
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetBackgroundImage(pool.AddPicture(GetImgPathNew("text_back.png"), 423, 124), true);
	m_contentScroll->SetBackgroundFocusImage(pool.AddPicture(GetImgPathNew("text_back_focus.png"), 423, 124), true);
	m_contentScroll->SetFrameRect(CGRectMake(startX, 76-37, 423, 124)); // CGRectMake(2, 3, 423-4, 124-6)
	m_contentScroll->SetDelegate(this);
	this->AddChild(m_contentScroll, -5);
	
	NDUILabel *lbMaxCharacter = new NDUILabel;
	lbMaxCharacter->Initialization();
	lbMaxCharacter->SetTextAlignment(LabelTextAlignmentRight);
	lbMaxCharacter->SetFontSize(14);
	lbMaxCharacter->SetFrameRect(CGRectMake(startX, 205-37, 437-startX, winsize.height));
	lbMaxCharacter->SetFontColor(ccc4(188, 20, 17, 255));
	lbMaxCharacter->SetText((std::string("( ") + NDCommonCString("InputMax50") + ")").c_str());
	this->AddChild(lbMaxCharacter);
	
	NDPicture *picCommit = pool.AddPicture(GetImgPathNew("kefu_comit.png"));
	
	CGSize sizeCommit = picCommit->GetSize();
	
	m_btnCommit = new NDUIButton;
	
	m_btnCommit->Initialization();
	
	m_btnCommit->SetFrameRect(CGRectMake(392, 264-37, sizeCommit.width, sizeCommit.height));
	
	m_btnCommit->SetImage(picCommit, false, CGRectZero, true);
	
	m_btnCommit->SetDelegate(this);
	
	this->AddChild(m_btnCommit);
	
	m_input = new CommonTextInput;
	m_input->Initialization();
	m_input->SetDelegate(this);
	this->AddChild(m_input);
	
	CGRect rect = m_input->GetFrameRect();
	
	rect.origin.y -= 37;
	
	m_input->SetFrameRect(rect);
}

void CustomFeedBack::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnCommit) 
	{
		if (!m_lbFeedbackContent) return;
		
		string text = m_lbFeedbackContent->GetText();
		if (!text.empty()) {
			if (text.size() > 50) {
				ShowAlert(NDCommonCString("InputMax50"));
				return;
			} else {
				if (!m_dataplist.CanPlayerQuestCurrentDay(NDPlayer::defaultHero().m_id))
				{
					showDialog(NDCommonCString("tip"), NDCommonCString("FrequentOperate"));
					return;
				}
				
				NDTransData bao(_MSG_GM_MAIL);
				bao.WriteUnicodeString(text);
				SEND_DATA(bao);
				
				m_dataplist.AddPlayerQuest(NDPlayer::defaultHero().m_id);
			}
		}
	}
}

bool CustomFeedBack::SetTextContent(CommonTextInput* input, const char* text)
{
	if (m_input == input)
	{
		if (!SetFeedbackContent(text)) 
			return false;
	}
	
	return true;
}

void CustomFeedBack::OnClickNDScrollLayer(NDScrollLayer* layer)
{
	if (layer != m_contentScroll || !m_input) return;
	
	const char* text = !m_lbFeedbackContent ? NULL : m_lbFeedbackContent->GetText().c_str();
	
	m_input->ShowContentTextField(true, text);
}

bool CustomFeedBack::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);
	
	return false;
}

bool CustomFeedBack::SetFeedbackContent(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_contentScroll) return false;
	
	if (std::string(text).size() > 100) 
	{
		ShowAlert(NDCommonCString("InputMax50"));
		return false;
	}
	
	m_contentScroll->RemoveAllChildren(true);
	
	if (!text) return false;
	
	CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_contentScroll->GetFrameRect().size.width-4, 320));
	
	m_lbFeedbackContent = new NDUILabel;
	m_lbFeedbackContent->Initialization();
	m_lbFeedbackContent->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbFeedbackContent->SetFontSize(12);
	m_lbFeedbackContent->SetFrameRect(CGRectMake(2, 3, size.width, size.height));
	m_lbFeedbackContent->SetFontColor(color);
	m_lbFeedbackContent->SetText(text);
	
	if (m_lbFeedbackContent->GetParent() == NULL)
		m_contentScroll->AddChild(m_lbFeedbackContent);
	
	m_contentScroll->refreshContainer();
	
	return true;
}

#pragma mark 客服密码
IMPLEMENT_CLASS(CustomPassword, NDUILayer)

CustomPassword::CustomPassword()
{
	m_btnCurPW = m_btnNewPW = m_btnRepeatNewPW = NULL;
	
	m_lbCurPW = m_lbNewPW = m_lbRepeatNewPW = NULL;
	
	m_input = NULL;
	
	m_btnCommit = NULL;
	
	m_iCurInput = eInputNone;
}

CustomPassword::~CustomPassword()
{
}

void CustomPassword::Initialization()
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	int startY = 58-37;
	
	NDUILabel *lb = NULL;
	
	InitPW(lb, m_btnCurPW, m_lbCurPW, NDCommonCString("InputCurPW12"), startY);
	
	startY += 57;
	
	InitPW(lb, m_btnNewPW, m_lbNewPW, NDCommonCString("InputNewPW12"), startY);
	
	startY += 57;
	
	InitPW(lb, m_btnRepeatNewPW, m_lbRepeatNewPW, NDCommonCString("InputRepeatPW12"), startY);
		
	NDPicture *picCommit = pool.AddPicture(GetImgPathNew("kefu_comit.png"));
	
	CGSize sizeCommit = picCommit->GetSize();
	
	m_btnCommit = new NDUIButton;
	
	m_btnCommit->Initialization();
	
	m_btnCommit->SetFrameRect(CGRectMake(392, 264-37, sizeCommit.width, sizeCommit.height));
	
	m_btnCommit->SetImage(picCommit, false, CGRectZero, true);
	
	m_btnCommit->SetDelegate(this);
	
	this->AddChild(m_btnCommit);
	
	m_input = new CommonTextInput;
	m_input->Initialization();
	m_input->SetDelegate(this);
	this->AddChild(m_input);
	
	CGRect rect = m_input->GetFrameRect();
	
	rect.origin.y -= 37;
	
	m_input->SetFrameRect(rect);
}

void CustomPassword::OnButtonClick(NDUIButton* button)
{
	int op = eInputNone;
	
	if (button == m_btnCommit)
	{
		if (!m_lbCurPW || !m_lbNewPW || !m_lbRepeatNewPW) return;
		
		string oldPwd = m_lbCurPW->GetText();
		if (oldPwd.size() == 0 || oldPwd.size() > 12) {
			ShowAlert(NDCommonCString("InputOldPW12"));
			return;
		}
		string newPwd1 = m_lbNewPW->GetText();
		string newPwd2 = m_lbRepeatNewPW->GetText();
		if (!this->checkNewPwd(newPwd1)) {
			ShowAlert(NDCommonCString("OnlyAllowAlphaNum"));
			return;
		}
		if (newPwd1.size() < 7 || newPwd1.size() > 12) {
			ShowAlert(NDCommonCString("InputPW12"));
			return;
		}
		if (newPwd1 != newPwd2) {
			ShowAlert(NDCommonCString("TwoInputPWTip"));
			return;
		}
		
		ShowProgressBar;
		NDTransData bao(MB_MSG_CHANGE_PASS);
		NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
		bao.WriteUnicodeString(mgr.GetUserName());
		bao.WriteUnicodeString(oldPwd);
		bao.WriteUnicodeString(newPwd1);
		SEND_DATA(bao);
	}
	else if (button == m_btnCurPW)
	{
		op = eInputCurPW;
	}
	else if (button == m_btnNewPW)
	{
		op = eInputNewPW;
	}
	else if (button == m_btnRepeatNewPW)
	{
		op = eInputRepeatNewPW;
	}

	if (op <= eInputNone || op >= eInputEnd) return;
	
	if (!m_input) return;
	
	const char* text = GetTextContent(op);
	
	m_iCurInput = op;
	
	m_input->ShowContentTextField(true, text);
}

bool CustomPassword::SetTextContent(CommonTextInput* input, const char* text)
{
	if (m_input == input)
	{
		if (!SetTextContent(m_iCurInput, text)) 
			return false;
	}
	
	return true;
}

bool CustomPassword::SetTextContent(int textType , const char* text)
{
	if (textType <= eInputNone || textType >= eInputEnd) return true;
	
	switch (textType) 
	{
		case eInputCurPW:
		{
			if (std::string(text).size() > 12) 
			{
				ShowAlert(NDCommonCString("InputOldPW12"));
				return false;
			}
			
			if (!this->checkNewPwd(text)) {
				ShowAlert(NDCommonCString("OnlyAllowAlphaNum"));
				return false;
			}
			
			if (!m_lbCurPW) return true;
			
			m_lbCurPW->SetText(text);
			
		}
			break;
		case eInputNewPW:
		case eInputRepeatNewPW:
		{
			if (std::string(text).size() > 12) 
			{
				ShowAlert(NDCommonCString("InputOldPW12"));
				return false;
			}
			
			if (!this->checkNewPwd(text)) {
				ShowAlert(NDCommonCString("OnlyAllowAlphaNum"));
				return false;
			}
			
			if (std::string(text).size() < 7 )
			{
				ShowAlert(NDCommonCString("InputPW12"));
				return false;
			}
			
			NDUILabel* lb = textType == eInputNewPW ? m_lbNewPW : m_lbRepeatNewPW;
		
			if (!lb) return true;
			
			lb->SetText(text);
			
		}
			break;
	}
	
	return true;
}

void CustomPassword::InitPW(NDUILabel*& lb, NDUIMutexStateButton*& btn, NDUILabel*& lbBtn, const char* lbText, int startY)
{
	int startX = 17;
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(14);
	lb->SetFrameRect(CGRectMake(startX, startY, winsize.width, winsize.height));
	lb->SetFontColor(ccc4(188, 20, 17, 255));
	lb->SetText(lbText);
	this->AddChild(lb);
	
	NDPicture* pic = NULL;
	btn = new NDUIMutexStateButton;
	btn->Initialization();
	pic = pool.AddPicture(GetImgPathNew("text_back.png"), 421, 27);
	//btn->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	btn->SetNormalImage(pic, false, CGRectMake(0, 0, 0, 0));
	pic = pool.AddPicture(GetImgPathNew("text_back_focus.png"), 421, 27); 
	btn->SetFocusImage(pic, false, CGRectMake(0, 0, 0, 0));
	btn->SetFrameRect(CGRectMake(startX, startY+18, 421, 27));
	btn->SetDelegate(this);
	this->AddChild(btn);
	
	
	lbBtn = new NDUILabel;
	lbBtn->Initialization();
	lbBtn->SetTextAlignment(LabelTextAlignmentLeft);
	lbBtn->SetFontSize(14);
	lbBtn->SetFrameRect(CGRectMake(2, 6, winsize.width, winsize.height));
	lbBtn->SetFontColor(ccc4(188, 20, 17, 255));
	btn->AddChild(lbBtn);
}

const char* CustomPassword::GetTextContent(int textType)
{
	if (textType <= eInputNone || textType >= eInputEnd) return NULL;
	
	switch (textType) {
		case eInputCurPW:
		{
			if (!m_lbCurPW) return NULL;
			
			return m_lbCurPW->GetText().c_str();
		}
			break;
		case eInputNewPW:
		{
			if (!m_lbNewPW) return NULL;
			
			return m_lbNewPW->GetText().c_str();
		}
			break;
		case eInputRepeatNewPW:
		{
			if (!m_lbRepeatNewPW) return NULL;
			
			return m_lbRepeatNewPW->GetText().c_str();
		}
			break;
		default:
			break;
	}
	
	return NULL;
}

bool CustomPassword::checkNewPwd(const string& pwd)
{
	if (pwd.empty()) {
		return false;
	}
	
	char c;
	for (size_t i = 0; i < pwd.size(); i++) {
		c = pwd.at(i);
		if (!(((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'z')) || ((c >= 'A') && (c <= 'Z')))) {
			return false;
		}
	}
	return true;
}

#pragma mark 客服声明
IMPLEMENT_CLASS(CustomDeclaration, NDUILayer)

CustomDeclaration* CustomDeclaration::s_instance = NULL;

std::string CustomDeclaration::s_DeclareData;

CustomDeclaration::CustomDeclaration()
{
	m_contentScroll = NULL;
	
	s_instance = this;
}

CustomDeclaration::~CustomDeclaration()
{
	s_instance = NULL;
}

void CustomDeclaration::processDeclareData(const char* text)
{
	if (!s_instance || !text)
		return;
	
	s_DeclareData = text;
		
	s_instance->SetDeclareContent(text);
	
	if (!s_instance->IsVisibled() && s_instance->m_contentScroll)
		s_instance->m_contentScroll->SetVisible(false);
}

bool CustomDeclaration::HasDeclareData()
{
	return !(s_DeclareData.empty() || s_DeclareData == "");
}

void CustomDeclaration::ClearDeclareData()
{
	s_DeclareData = "";
}

void CustomDeclaration::Initialization(const char* pic/*="custom_declare.png"*/)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicture* picDeclare = pool.AddPicture(GetImgPathNew(pic));
	
	CGSize sizeDeclare = picDeclare->GetSize();
	
	NDUIImage *imgDeclare = new NDUIImage;
	
	imgDeclare->Initialization();
	
	imgDeclare->SetPicture(picDeclare, true);
	
	imgDeclare->SetFrameRect(CGRectMake((winsize.width-sizeDeclare.width)/2, 53-37, sizeDeclare.width, sizeDeclare.height));
	
	this->AddChild(imgDeclare);
	
	//NDPicture* picRoleBg = pool.AddPicture(GetImgPathNew("attr_role_bg.png"), 403, 204);
	
	CGSize sizeRoleBg = CGSizeMake(403, 204);//picRoleBg->GetSize();
	
	NDUILayer *layerEquipInfo = new NDUILayer;
	layerEquipInfo->Initialization();
	layerEquipInfo->SetFrameRect(CGRectMake(25,92-37, sizeRoleBg.width, sizeRoleBg.height));
	//layerEquipInfo->SetBackgroundImage(picRoleBg, true);
	this->AddChild(layerEquipInfo);
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetFrameRect(CGRectMake(6, 10, sizeRoleBg.width-12, sizeRoleBg.height-20));
	layerEquipInfo->AddChild(m_contentScroll);
}

bool CustomDeclaration::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);
	
	return false;
}

bool CustomDeclaration::SetDeclareContent(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_contentScroll) return false;
	
	m_contentScroll->RemoveAllChildren(true);
	
	if (!text) return false;
	
	int width = m_contentScroll->GetFrameRect().size.width;
	
	
	CGSize textSize;
	textSize.width = width;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, fontsize);
	
	NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(text, 
															  fontsize, 
															  textSize, 
															  color,
															  true);
	memo->SetFrameRect(CGRectMake(0, 0, textSize.width, textSize.height));		
	m_contentScroll->AddChild(memo);
	
	m_contentScroll->refreshContainer();
	
	return true;
}

//#include "Chat.h"
void CustomDeclaration::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
	
	/*
	if (visible)
	{
		NSArray *trace = [NSThread callStackSymbols];
		for (id sym in trace)
		{
			Chat::DefaultChat()->AddMessage(ChatTypeSystem, [(NSString*)sym UTF8String]);
		}
	}
	*/
}

#pragma mark 客服公告
IMPLEMENT_CLASS(CustomGongGao, CustomDeclaration)

void CustomGongGao::Initialization()
{
	CustomDeclaration::Initialization("kefu_gonggao.png");
	
	SetDeclareContent(NDMapMgrObj.noteContent.c_str());
}

#pragma mark 客服活动
IMPLEMENT_CLASS(CustomActivity, NDUILayer)

std::string CustomActivity::s_titles[CustomActivity::max_date] = 
{
	NDCommonCString("XinQiYi"),
	NDCommonCString("XinQiEr"),
	NDCommonCString("XinQiShang"),
	NDCommonCString("XinQiShi"),
	NDCommonCString("XinQiWu"),
	NDCommonCString("XinQiLiu"),
	NDCommonCString("XinQiTian"),
};

std::string CustomActivity::s_data[CustomActivity::max_date];

CustomActivity* CustomActivity::s_instance = NULL;

unsigned int CustomActivity::s_index = 0;

void CustomActivity::AddData(std::string str)
{
	if (s_index < max_date) {
		s_data[s_index++] = str;
	}
}

bool CustomActivity::HasData()
{
	return !(s_data[0] == "");
}

void CustomActivity::ClearData()
{
	for (int i = 0; i < max_date; i++) {
		s_data[s_index] = "";
	}
	
	s_index = 0;
}

void CustomActivity::refresh()
{
	s_index = 0;
	
	if (s_instance)
		s_instance->refreshContent();
}

CustomActivity::CustomActivity()
{
	s_instance = this;
}

CustomActivity::~CustomActivity()
{
	s_instance = NULL;
}

void CustomActivity::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	int startX = 17, startY = 57-37;
	
	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetFrameRect(CGRectMake(startX, startY, 321-startX, 278-37-startY));
	m_contentScroll->SetDelegate(this);
	this->AddChild(m_contentScroll);
	
	m_tlDate = new NDUITableLayer;
	m_tlDate->Initialization();
	m_tlDate->SetSelectEvent(false);
	m_tlDate->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_tlDate->VisibleSectionTitles(false);
	m_tlDate->SetFrameRect(CGRectMake(325, startY+16, 443-325, (23*7+4*6)+10));
	m_tlDate->VisibleScrollBar(false);
	m_tlDate->SetCellsInterval(4);
	m_tlDate->SetCellsRightDistance(0);
	m_tlDate->SetCellsLeftDistance(0);
	m_tlDate->SetDelegate(this);
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	
	const char* date[max_date] = 
	{
		NDCommonCString("XinQiYi"),
		NDCommonCString("XinQiEr"),
		NDCommonCString("XinQiShang"),
		NDCommonCString("XinQiShi"),
		NDCommonCString("XinQiWu"),
		NDCommonCString("XinQiLiu"),
		NDCommonCString("XinQiTian"),
	};
	
	for (int i = 0; i < max_date; i++) 
	{
		NDPropCell  *propDate = new NDPropCell;
		propDate->Initialization(false, CGSizeMake(443-325, 23));
		propDate->SetKeyLeftDistance(4);
		if (propDate->GetKeyText())
			propDate->GetKeyText()->SetText(date[i]);
		
		propDate->SetFocusTextColor(ccc4(187, 19, 19, 255));
		
		section->AddCell(propDate);
	}
	
	section->SetFocusOnCell(0);
	
	dataSource->AddSection(section);
	m_tlDate->SetDataSource(dataSource);
	this->AddChild(m_tlDate);
	
	refreshContent();
	
	NDUIImage *imgFengGe = new NDUIImage;
	imgFengGe->Initialization();
	imgFengGe->SetPicture(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("hudong_fengge.png")), true);
	imgFengGe->SetFrameRect(CGRectMake(322, startY, 9, 242));
	this->AddChild(imgFengGe);
}

bool CustomActivity::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);
	
	return false;
}

void CustomActivity::SetContent(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_contentScroll) return;
	
	m_contentScroll->RemoveAllChildren(true);
	
	if (!text) return;
	
	CGSize textSize;
	textSize.width = m_contentScroll->GetFrameRect().size.width-4;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, 12);
	
	NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(text, 
															  12, 
															  textSize, 
															  color,
															  true);
	memo->SetFrameRect(CGRectMake(2, 3, textSize.width, textSize.height));
	
	m_contentScroll->AddChild(memo);
	
	//CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_contentScroll->GetFrameRect().size.width-4, 320));
	
//	NDUILabel *lbContent = new NDUILabel;
//	lbContent->Initialization();
//	lbContent->SetTextAlignment(LabelTextAlignmentLeft);
//	lbContent->SetFontSize(12);
//	lbContent->SetFrameRect(CGRectMake(2, 3, size.width, size.height));
//	lbContent->SetFontColor(color);
//	lbContent->SetText(text);
	
//	if (lbContent->GetParent() == NULL)
//		m_contentScroll->AddChild(lbContent);
	
	m_contentScroll->refreshContainer();
	
	return;
}

void CustomActivity::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	refreshContent();
}

void CustomActivity::refreshContent()
{
	if (!m_tlDate || !m_tlDate->GetDataSource()
	    || m_tlDate->GetDataSource()->Count() != 1
		|| m_tlDate->GetDataSource()->Section(0)->Count() != max_date)
		return;
		
	NDSection *section = m_tlDate->GetDataSource()->Section(0);
	
	unsigned int index = section->GetFocusCellIndex();
	
	if (index >= max_date) return;
	
	SetContent(s_data[index].c_str(), ccc4(79, 79, 79, 255));
}

#pragma mark 系统设置

IMPLEMENT_CLASS(SystemSetting, NDUILayer)

SystemSetting::SystemSetting()
{
	//m_headPicOpt = NULL;
	//m_miniMapOpt = NULL;
	m_showObjLevel = NULL;
	m_worldChatOpt = NULL;
	m_synChatOpt = NULL;
	m_teamChatOpt = NULL;
	m_areaChatOpt = NULL;
	m_directKeyOpt = NULL;
	
	m_page1 = NULL;
	//m_page2 = NULL;
}

SystemSetting::~SystemSetting()
{
	this->m_gameSettingData.SaveGameSetting();
}

void SystemSetting::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	float y = 68-37, x = 21, vInterval = 38, hInterval = 220;
	
	VEC_OPT_STRING vOps;
	vOps.push_back(NDCommonCString("high")); // 0 - 同时显示名字和其他玩家
	vOps.push_back(NDCommonCString("mid")); // 1 - 不显示名字
	vOps.push_back(NDCommonCString("low")); // 2 - 不显示其他玩家
	
	InitOption(ccp(x, y), vOps, m_showObjLevel, NDCommonCString("AppearPingZhi"));
	
	vOps.clear();
	vOps.push_back(NDCommonCString("open"));
	vOps.push_back(NDCommonCString("close"));
	
	InitOption(ccp(x+hInterval, y), vOps, m_synChatOpt, NDCommonCString("JunTuanChat"));
	
	InitOption(ccp(x, y+vInterval), vOps, m_teamChatOpt, NDCommonCString("TeamChat"));
	
	InitOption(ccp(x+hInterval, y+vInterval), vOps, m_worldChatOpt, NDCommonCString("WorldChat"));
	
	InitOption(ccp(x, y+vInterval*2), vOps, m_areaChatOpt, NDCommonCString("SectionChat"));
	
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_WORLD_CHAT)) {
		m_worldChatOpt->SetOptIndex(1);
	}
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_SYN_CHAT)) {
		m_synChatOpt->SetOptIndex(1);
	}
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_TEAM_CHAT)) {
		m_teamChatOpt->SetOptIndex(1);
	}
	

	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_AREA_CHAT)) {
		m_areaChatOpt->SetOptIndex(1);
	}
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_NAME)) {
		if (NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)) {
			m_showObjLevel->SetOptIndex(1);
		} else {
			m_showObjLevel->SetOptIndex(2);
		}
	}
}

void SystemSetting::OnButtonClick(NDUIButton* button)
{	
}

void SystemSetting::OnOptionChange(NDUIOptionButton* option)
{
	 if (option == this->m_worldChatOpt) {
		 bool bOn = this->m_worldChatOpt->GetOptionIndex() == 0;
		 this->m_gameSettingData.SetGameSetting(GS_SHOW_WORLD_CHAT, bOn);
	 } else if (option == this->m_synChatOpt) {
		 bool bOn = this->m_synChatOpt->GetOptionIndex() == 0;
		 this->m_gameSettingData.SetGameSetting(GS_SHOW_SYN_CHAT, bOn);
	 } else if (option == this->m_teamChatOpt) {
		 bool bOn = this->m_teamChatOpt->GetOptionIndex() == 0;
		 this->m_gameSettingData.SetGameSetting(GS_SHOW_TEAM_CHAT, bOn);
	 } else if (option == this->m_areaChatOpt) {
		 bool bOn = this->m_areaChatOpt->GetOptionIndex() == 0;
		 this->m_gameSettingData.SetGameSetting(GS_SHOW_AREA_CHAT, bOn);
	 }else if (option == this->m_directKeyOpt) {
		 bool bOn = this->m_directKeyOpt->GetOptionIndex() == 0;
		 this->m_gameSettingData.SetGameSetting(GS_SHOW_DIRECT_KEY, bOn);
	 }	else if (option == this->m_showObjLevel) {
		 switch (this->m_showObjLevel->GetOptionIndex()) {
			 case 0: // 高
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, true);
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, true);
				 break;
			 case 1: // 中
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, false);
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, true);
				 break;
			 case 2: // 低
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, false);
				 this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, false);
				 break;
			 default:
				 break;
		 }
	 }
}

void SystemSetting::InitOption(CGPoint pos, VEC_OPT_STRING vOption, CommonOptionButton*& btn, const char* text)
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILabel* label = new NDUILabel();
	label = new NDUILabel();
	label->Initialization();
	label->SetText(text);
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(pos.x, pos.y, winsize.width, winsize.height));
	label->SetFontColor(ccc4(187, 19, 19, 255));
	this->AddChild(label);
	
	pos.x += 64;
	
	pos.y -= 4;
	
	btn = new CommonOptionButton;
	btn->Initialization();
	btn->SetOptions(vOption);
	btn->SetDelegate(this);
	btn->SetFrameRect(CGRectMake(pos.x, pos.y, 128, 22));
	btn->SetTitleColor(ccc4(173, 70, 25, 255), ccc4(255, 248, 198, 255));
	btn->SetDelegate(this);
	this->AddChild(btn);
}

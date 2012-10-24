/*
 *  RechargeScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RechargeScene.h"
#include "SocialTextLayer.h"
#include "ImageNumber.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDUISynLayer.h"
#include "GameUIPlayerList.h"
#include "NDMapMgr.h"
#include "define.h"
#include "NDUtility.h"
#include "NDPath.h"
#include <sstream>

IMPLEMENT_CLASS(RechargeButton, NDUIButton)

RechargeButton::RechargeButton()
{
	textPadding = 0;
}

RechargeButton::~RechargeButton()
{
	//ClearChildlist();
}

void RechargeButton::Initialization()
{
	NDUIButton::Initialization();
	this->SetFrameRect(CGRectMake(0, 0, 120, 30));
	this->SetFontColor(ccc4(38,59,28,255));
	this->SetFocusColor(ccc4(253, 253, 253, 255));
}

bool RechargeButton::GenTBList(NDUITableLayer* tl)
{
	if (!tl || children.empty()) 
	{
		return false;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	for_vec(children, std::vector<RechargeData>::iterator)
	{
		RechargeData& child = *it;
		RechargeButton *childbtn = new  RechargeButton;
		childbtn->Initialization();
		childbtn->textPadding = child.textPadding;
		childbtn->SetTitle(child.title.c_str());
		section->AddCell(childbtn);
	}
	
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*children.size()-children.size()-1)/2, 120, 30*children.size()+children.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
	//m_childlist.clear();
	
	return true;
}

void RechargeButton::ClearChildlist()
{
	//for_vec(m_childlist, std::vector<RechargeButton*>::iterator)
//	{
//		delete *it;
//	}
//	m_childlist.clear();
}

//////////////////////////////////////////
#define title_height 28
#define bottom_height 42
#define MAIN_TB_X (5)

#define BTN_W (85)
#define BTN_H (23)

#define page_count (5)

IMPLEMENT_CLASS(RechargeScene, NDScene)

std::vector<RechargeData> RechargeScene::datas;
std::string RechargeScene::rechargeInfoTitle;
std::string RechargeScene::rechargeInfo;

RechargeScene::RechargeScene()
{
	m_menulayerBG = NULL;
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_tlOperate = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	m_lbPage = NULL;
	//m_btnOperate = NULL;
	m_iCurPage = 0;
	m_iTotalPage = 0;
	askForRecharge = 0;
}

RechargeScene::~RechargeScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
	
	datas.clear();
}

RechargeScene* RechargeScene::Scene()
{
	RechargeScene *scene = new RechargeScene;
	scene->Initialization();
	return scene;
}

void RechargeScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	NDPicture *picMoney = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("emoney.png"));
	picMoney->Cut(CGRectMake(0, 0, 16, 16));
	
	NDUIImage *imageMoney =  new NDUIImage;
	imageMoney->Initialization();
	imageMoney->SetPicture(picMoney, true);
	imageMoney->SetFrameRect(CGRectMake(209, 293, 16, 16));
	m_menulayerBG->AddChild(imageMoney);
	
	ImageNumber* imageNumMoney = new ImageNumber;
	imageNumMoney->Initialization();
	imageNumMoney->SetTitleRedNumber(NDPlayer::defaultHero().eMoney);
	imageNumMoney->SetFrameRect(CGRectMake(209+picMoney->GetSize().width+8, 293, 100, 11));
	m_menulayerBG->AddChild(imageNumMoney);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetText("金币充值");
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, title_height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	//m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menulayerBG->AddChild(m_tlMain);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	m_menulayerBG->AddChild(m_lbPage);
	
	NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_menulayerBG->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
	
	UpdateMainUI();
	UpdatePage();
}

void RechargeScene::UpdateMainUI()
{
	if (!m_tlMain)
	{
		return;
	}
	int start = m_iCurPage*page_count;
	int end = (m_iCurPage+1)*page_count;
	int iSize = datas.size();
	
	if (iSize == 0 
		||start >= iSize || start < 0 ||  end < 0 ) 
	{
		if (m_tlMain->GetDataSource()) 
		{
			NDDataSource *source = m_tlMain->GetDataSource();
			source->Clear();
			m_tlMain->ReflashData();
		}
		return;
	}
	
	if ( end > iSize )
	{
		end = iSize;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	//section->UseCellHeight(true);
	bool bChangeClr = false;
	std::vector<RechargeButton*> btnlist;
	for(int i = start; i < end; i++)
	{
		RechargeData& chargedata = datas[i];
		RechargeButton *btn = new  RechargeButton;
		btn->Initialization();
		btn->textPadding = chargedata.textPadding;
		btn->SetTitle(chargedata.title.c_str());
		btn->CloseFrame();
		
		if (bChangeClr) {
			btn->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			btn->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		section->AddCell(btn);
		
		btn->children = chargedata.children;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if (section->Count() > 0) 
	{
		section->SetFocusOnCell(0);
	}
	dataSource->AddSection(section);
	
	int iHeigh = datas.size()*30;//+datas.size()+1;
	int iHeighMax = winsize.height-title_height-bottom_height-BTN_H-2*2;
	iHeigh = iHeigh < iHeighMax ? iHeigh : iHeighMax;
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, iHeigh));
	
	m_tlMain->SetVisible(true);
	
	if (m_tlMain->GetDataSource())
	{
		m_tlMain->SetDataSource(dataSource);
		m_tlMain->ReflashData();
	}
	else
	{
		m_tlMain->SetDataSource(dataSource);
	}
}

void RechargeScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage <= 0) 
		{
			showDialog("温馨提示", "该页已经是第一页");
		} 
		else
		{
			m_iCurPage--;
			UpdateMainUI();
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage >= GetPageNum()-1)
		{
			showDialog("温馨提示", "该页已经是最后一页");
		} 
		else
		{
			m_iCurPage++;
			UpdateMainUI();
		}
	}
}

void RechargeScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain && cell->IsKindOfClass(RUNTIME_CLASS(RechargeButton))) 
	{
		RechargeButton *btn = (RechargeButton*)cell;
		if (btn->textPadding%10 == 1) 
		{
			//m_btnOperate = btn;
			m_tlOperate->SetVisible(btn->GenTBList(m_tlOperate));
		}
		else if (btn->textPadding%10 == 2) 
		{ // 注意事项
			sendChargeInfo(btn->textPadding / 10);
		}

	}
	else if (table == m_tlOperate && cell->IsKindOfClass(RUNTIME_CLASS(RechargeButton))) 
	{
		RechargeButton *btn = (RechargeButton*)cell;
		int iMenuType = btn->textPadding%10;
		if (iMenuType == 2) 
		{ // 注意事项
			askForRecharge = 0;
			sendChargeInfo(btn->textPadding / 10);
		}
		else if (iMenuType == 4 || iMenuType == 3) 
		{ // 充值 4短信充值 3卡充值
			recharge(btn->textPadding % 10);
		}
		//m_btnOperate = btn;
	}

}

bool RechargeScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string cardNum = customView->GetEditText(0);
	switch (askForRecharge) 
	{
		case 3:
		{
			std::string cardPassWorld = customView->GetEditText(1);
			if (cardNum.size() > 0 && cardPassWorld.size() > 0) 
			{
				sendCardNum = cardNum;
				sendCardPassWord = cardPassWorld;
				openEnquire();
			} 
			else 
			{
				customView->ShowAlert("卡号或密码不能为空");
				return false;
			}
		}
			break;
		case 4:
		{
			if (cardNum.size() > 0) 
			{
				sendCardNum = cardNum;
				openEnquire();
			} 
			else 
			{
				customView->ShowAlert("手机号码不能为空");
				return false;
			}
		}
			break;
	}
	return true;
}

void RechargeScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	sendRecharge();
	askForRecharge = 0;
	dialog->Close();
}

void RechargeScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
}

int RechargeScene::GetPageNum()
{
	return m_iTotalPage;
}

void RechargeScene::UpdatePage()
{
	m_iTotalPage = datas.size() / page_count;
	if (int(datas.size()) % page_count > 0) {
		m_iTotalPage++;
	}
	
	std::stringstream ss;
	ss << (m_iCurPage+1) << "/" << m_iTotalPage;
	if (m_lbPage) 
	{
		m_lbPage->SetText(ss.str().c_str());
	}
}

void RechargeScene::recharge(int askForRecharge) 
{ // 冲值
	//if (!m_btnOperate) 
//	{
//		return;
//	}
	
	if (!m_tlMain || !m_tlMain->GetFocus() || !m_tlMain->GetFocus()->IsKindOfClass(RUNTIME_CLASS(RechargeButton))) 
	{
		return;
	}
	
	RechargeButton *btn = (RechargeButton*)(m_tlMain->GetFocus());
	
	for_vec(btn->children, std::vector<RechargeData>::iterator)
	{
		RechargeData& childdata = *it;
		if (childdata.textPadding % 10 == 2) 
		{
			sendChargeInfo(childdata.textPadding / 10);
			this->askForRecharge = askForRecharge;
			break;
		}
	}
}

void RechargeScene::dealRecharge()
{
	switch (askForRecharge) {
		case 0:
		{
			GlobalShowDlg(rechargeInfoTitle.c_str(), rechargeInfo.c_str());
			rechargeInfoTitle = "";
			rechargeInfo = "";
		}
			break;
		case 3:
			showRechargeForm();
			break;
		case 4:
			showRechargeSMS();
			break;
	}
}

void RechargeScene::showRechargeForm()
{
	//Form f = new Form(tvCatagory[catagoryFocusIndex].getText()); todo
//	f.addCommand(T.okCmd);
//	f.addCommand(T.backCmd);
//	
//	String cdNumHint = "请输入充值卡卡号";
//	String cdPwdHint = "请输入充值卡密码";
//	
//	cardNum = T.getTextField(cdNumHint, null, 20, 0);
//	cardNum.setInitialInputMode("MIDP_LOWERCASE_LATIN");
//	f.append(cardNum);
//	cardPassWorld = T.getTextField(cdPwdHint, null, 20, 0);
//	cardPassWorld.setInitialInputMode("MIDP_LOWERCASE_LATIN");
//	f.append(cardPassWorld);
//	f.append("提示：充值时，请选择与您充值卡面额相同的消费金额，否则可能导致充值失败或金额丢失");
//	if (rechargeInfo != null) {
//		f.append(rechargeInfo);
//	}
//	f.setCommandListener(this);
//	T.getDisplay().setCurrent(f);

	NDUICustomView *view = new NDUICustomView;
	view->Initialization();
	view->SetDelegate(this);
	std::vector<int> vec_id;
	std::vector<std::string> vec_str;
	vec_str.push_back("请输入充值卡卡号"); vec_id.push_back(1);
	vec_str.push_back("请输入充值卡密码"); vec_id.push_back(2);
	view->SetEdit(2, vec_id, vec_str);
	view->Show();
	this->AddChild(view);
}

void RechargeScene::showRechargeSMS()
{
//	Form f = new Form(tvCatagory[catagoryFocusIndex].getText());　todo
//	f.addCommand(T.okCmd);
//	f.addCommand(T.backCmd);
//	String cdNumHint = "请您输入收发短信的手机号码（11位）";
//	cardNum = T.getTextField(cdNumHint, null, 11, 1);
//	f.append(cardNum);
//	f.append("为了确保充值成功，请确认手机号填写正确");
//	if (rechargeInfo != null) {
//		f.append(rechargeInfo);
//	}
//	f.setCommandListener(this);
//	T.getDisplay().setCurrent(f);

	NDUICustomView *view = new NDUICustomView;
	view->Initialization();
	view->SetDelegate(this);
	std::vector<int> vec_id;
	std::vector<std::string> vec_str;
	vec_str.push_back("请您输入收发短信的手机号码（11位）"); vec_id.push_back(1);
	view->SetEdit(1, vec_id, vec_str);
	view->Show();
	this->AddChild(view);
}

void RechargeScene::openEnquire()
{
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show("注意事项", rechargeInfo.c_str(), "取消", "确认", NULL);
}

void RechargeScene::sendRecharge()
{
	if (!m_tlOperate || !m_tlOperate->GetFocus() || !m_tlOperate->GetFocus()->IsKindOfClass(RUNTIME_CLASS(RechargeButton))) 
	{
		return;
	}
	
	RechargeButton *btn = (RechargeButton*)(m_tlOperate->GetFocus());
	NDTransData bao(MB_MSG_RECHARGE);
	bao << int(btn->textPadding/10);
	bao.WriteUnicodeString(loadPackInfo(STRPARAM));
	bao.WriteUnicodeString(sendCardNum);
	switch (askForRecharge) {
		case 3:
			bao.WriteUnicodeString(sendCardPassWord);
			break;
		case 4:
			bao.WriteUnicodeString("短信");
			break;
	}
	
	SEND_DATA(bao);
	ShowProgressBar;
}
///////////////////////////////////////////////
#define ONE_PAGE_COUNT (10)

IMPLEMENT_CLASS(ReChargelistScene, NDScene)

ReChargelistScene::ReChargelistScene()
{
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_btnPrev = NULL;
	m_picPrev = NULL;
	m_btnNext = NULL;
	m_picNext = NULL;
	m_lbPage = NULL;
	m_iCurPage = 0;
	m_iTotalPage = 0;
	
	memset(m_lbSubTitle, 0, sizeof(m_lbSubTitle));
	m_menulayerBG = NULL;
}

ReChargelistScene::~ReChargelistScene()
{
	SAFE_DELETE(m_picPrev);
	SAFE_DELETE(m_picNext);
	SAFE_DELETE(m_picEMoney);
	
	ClearSocialElements();
}

void ReChargelistScene::Initialization(VEC_SOCIAL_ELEMENT& elements)
{	
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetText("充值查询");
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, title_height));
	m_menulayerBG->AddChild(m_lbTitle);
	
	NDUILayer *tmpLayer = new NDUILayer;
	tmpLayer->Initialization();
	tmpLayer->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->SetBackgroundColor(ccc4(119,119,119,255));
	m_menulayerBG->AddChild(tmpLayer);
	
	m_lbSubTitle[0] = new NDUILabel;
	m_lbSubTitle[0]->Initialization();
	m_lbSubTitle[0]->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSubTitle[0]->SetFontSize(15);
	m_lbSubTitle[0]->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbSubTitle[0]->SetText("日期");
	m_lbSubTitle[0]->SetFrameRect(CGRectMake(10, (20-15)/2, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->AddChild(m_lbSubTitle[0]);
	
	m_lbSubTitle[1] = new NDUILabel;
	m_lbSubTitle[1]->Initialization();
	m_lbSubTitle[1]->SetTextAlignment(LabelTextAlignmentRight);
	m_lbSubTitle[1]->SetFontSize(15);
	m_lbSubTitle[1]->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbSubTitle[1]->SetText("金额");
	m_lbSubTitle[1]->SetFrameRect(CGRectMake(0, 0, winsize.width-2*MAIN_TB_X, 20));
	tmpLayer->AddChild(m_lbSubTitle[1]);
	
	m_picEMoney = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("emoney.png"));
	m_picEMoney->Cut(CGRectMake(0, 0, 16, 16));
	CGSize sizeEMoney = m_picEMoney->GetSize();
	
	NDUIImage *imageEMoney =  new NDUIImage;
	imageEMoney->Initialization();
	imageEMoney->SetPicture(m_picEMoney);
	imageEMoney->SetFrameRect(CGRectMake((winsize.width-sizeEMoney.width)/2-60, winsize.height-bottom_height+(bottom_height-sizeEMoney.height)/2, sizeEMoney.width, sizeEMoney.height));
	m_menulayerBG->AddChild(imageEMoney);
	
	NDPlayer& player = NDPlayer::defaultHero();
	ImageNumber *imageNumEMoney = new ImageNumber;
	imageNumEMoney->Initialization();
	imageNumEMoney->SetTitleRedNumber(player.eMoney);
	imageNumEMoney->SetFrameRect(CGRectMake((winsize.width-sizeEMoney.width)/2-20, winsize.height-bottom_height+(bottom_height-sizeEMoney.height)/2, 60, 11));
	m_menulayerBG->AddChild(imageNumEMoney);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	//m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menulayerBG->AddChild(m_tlMain);
	
	m_picPrev = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picPrev->Cut(CGRectMake(319, 144, 48, 19));
	CGSize prevSize = m_picPrev->GetSize();
	
	m_picNext = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picNext->Cut(CGRectMake(318, 164, 47, 17));
	CGSize nextSize = m_picNext->GetSize();
	
	m_btnPrev = new NDUIButton();
	m_btnPrev->Initialization();
	m_btnPrev->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnPrev->SetImage(m_picPrev, true,CGRectMake((BTN_W-prevSize.width)/2, (BTN_H-prevSize.height)/2, prevSize.width, prevSize.height));
	m_btnPrev->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnPrev);
	
	m_btnNext = new NDUIButton();
	m_btnNext->Initialization();
	m_btnNext->SetFrameRect(CGRectMake((winsize.width-BTN_W*2)/2+BTN_W, winsize.height-bottom_height-BTN_H, BTN_W, BTN_H));
	m_btnNext->SetImage(m_picNext, true,CGRectMake((BTN_W-nextSize.width)/2, (BTN_H-nextSize.height)/2, nextSize.width, nextSize.height));
	m_btnNext->SetDelegate(this);
	m_menulayerBG->AddChild(m_btnNext);
	
	m_lbPage = new NDUILabel;
	m_lbPage->Initialization();
	m_lbPage->SetFontSize(15);
	m_lbPage->SetFontColor(ccc4(17, 9, 144, 255));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter); 
	m_lbPage->SetFrameRect(CGRectMake(0, winsize.height-bottom_height-BTN_H, winsize.width, BTN_H));
	m_lbPage->SetText("1/1");
	m_menulayerBG->AddChild(m_lbPage);
	
	m_vecElement = elements;
	UpdateMainUI();
}

void ReChargelistScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else if (button == m_btnPrev)
	{
		if (m_iCurPage <= 0) 
		{
			showDialog("温馨提示", "该页已经是第一页");
		} 
		else
		{
			m_iCurPage--;
			UpdateMainUI();
		}
	}
	else if (button == m_btnNext)
	{
		if (m_iCurPage >= m_iTotalPage-1)
		{
			showDialog("温馨提示", "该页已经是最后一页");
		} 
		else
		{
			m_iCurPage++;
			UpdateMainUI();
		}
	}
	
}

void ReChargelistScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
}

void ReChargelistScene::ClearSocialElements()
{
	for_vec(m_vecElement, VEC_SOCIAL_ELEMENT_IT)
	{
		delete *it;
	}
	m_vecElement.clear();
}

void ReChargelistScene::UpdateMainUI()
{
	if (!m_tlMain)
	{
		return;
	}
	
	int iSize = m_vecElement.size();
	int start = m_iCurPage*ONE_PAGE_COUNT;
	int end = (m_iCurPage+1)*ONE_PAGE_COUNT;

	if ( iSize == 0 || start < 0 || start >= iSize || end < 0 )
	{
		if (m_tlMain->GetDataSource()) 
		{
			NDDataSource *source = m_tlMain->GetDataSource();
			source->Clear();
			m_tlMain->ReflashData();
		}
		return;
	}
	
	if (end > iSize) 
	{
		end = iSize;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	//section->UseCellHeight(true);
	bool bChangeClr = false;
	for(int i = start; i < end; i++)
	{
		SocialTextLayer* st = new SocialTextLayer;

		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
						   CGRectMake(5.0f, 0.0f, 460.0f, 27.0f), m_vecElement[i]);
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		section->AddCell(st);
	}
	
	if (section->Count() > 0) 
	{
		section->SetFocusOnCell(0);
	}
	dataSource->AddSection(section);
	
	int iHeigh = section->Count()*30;//+section->Count()+1;
	int iHeighMax = winsize.height-title_height-bottom_height-BTN_H-2*2-20;
	iHeigh = iHeigh < iHeighMax ? iHeigh : iHeighMax;
	
	m_tlMain->SetFrameRect(CGRectMake(MAIN_TB_X, title_height+2+20, winsize.width-2*MAIN_TB_X, iHeigh));
	
	m_tlMain->SetVisible(true);
	
	if (m_tlMain->GetDataSource())
	{
		m_tlMain->SetDataSource(dataSource);
		m_tlMain->ReflashData();
	}
	else
	{
		m_tlMain->SetDataSource(dataSource);
	}
	
	std::stringstream ss; ss << m_iCurPage << "/" << m_iTotalPage;
	m_lbPage->SetText(ss.str().c_str());
}

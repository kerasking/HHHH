/*
 *  EmailRecvScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *GameMailsScene
 */

#include "EmailRecvScene.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "EmailSendScene.h"
#include "NDUIBaseGraphics.h"
#include "SocialTextLayer.h"
#include "GameUIPlayerList.h"
#include "NDString.h"
#include "NDMapMgr.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDPlayer.h"
#include "GameUIPaiHang.h"
#include <sstream>

#define title_height 28
#define bottom_height 42


enum  
{
	eMail_AddFriend = 800,
	eMail_GetAttach,
	eMail_QueryAttach,
	eMail_RejectAttach,
	eMail_Reply,
	eMail_ReturnMail,
};

IMPLEMENT_CLASS(EmailRecvScene, NDScene)

EmailRecvScene::EmailRecvScene()
{
	m_menulayerBG = NULL;
	m_tlOperate = NULL;
	m_picTitle = NULL;
	memset(m_picMoney, 0, sizeof(m_picMoney));
	memset(m_picEMoney, 0, sizeof(m_picEMoney));
	m_iMailID = -1;
}

EmailRecvScene::~EmailRecvScene()
{
	SAFE_DELETE(m_picMoney[0]); SAFE_DELETE(m_picMoney[1]);
	SAFE_DELETE(m_picEMoney[0]); SAFE_DELETE(m_picEMoney[1]);
	SAFE_DELETE(m_picTitle);
}

void EmailRecvScene::Initialization(EmailData* data)
{
	NDAsssert(data != NULL);
	
	m_iMailID = data->getId();
	
	NDScene::Initialization();

	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetOkBtn()) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picTitle->Cut(CGRectMake(0, 120, 78, 21));
	CGSize sizeTitle = m_picTitle->GetSize();
	
	NDUIImage *imageTitle =  new NDUIImage;
	imageTitle->Initialization();
	imageTitle->SetPicture(m_picTitle);
	imageTitle->SetFrameRect(CGRectMake((winsize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_menulayerBG->AddChild(imageTitle);
	
	NDUILayer *layer[4];
	for (int i = 0; i < 4; i++) 
	{
		ccColor4B color;
		if (i%2 == 0) 
		{
			color = ccc4(231, 231, 222, 255);
		}
		else 
		{
			color = ccc4(198, 211, 214, 255);
		}

		layer[i] = new NDUILayer;
		layer[i]->Initialization();
		layer[i]->SetBackgroundColor(color);
		layer[i]->SetFrameRect(CGRectMake(0, title_height+i*20, winsize.width, 20));
		m_menulayerBG->AddChild(layer[i]);
	}
	
	std::string limitTime = data->getMTimeLimit();
	switch (data->getMState()) {
		case EmailData::STATE_HAVE_ITEM: { // 未接收附件
			std::stringstream ss;
			ss << data->getMTimeLimit() << "[附件未接收]";
			limitTime = ss.str();
			break;
		}
		case EmailData::STATE_ACCEPT: {
			limitTime = "已接收";
			break;
		}
		case EmailData::STATE_REJECT: {
			limitTime = "已拒收";
			break;
		}
		case EmailData::STATE_WITHDRAWAL: {
			limitTime = "已退回";
			break;
		}
	}
	
	std::string itemname;
	if (data->isHaveItem()) { // 附件含 item
		itemname = data->getMItemStr();
	} else {
		itemname = "无";
	}
	
	InitButton(CGRectMake(0, 0, 70, 20), "发件人", layer[0]); 
	
	NDUILabel* lbSendName = InitText(CGRectMake(70, 0, winsize.width-70, 20), data->getMNameStr(), layer[0]);
	if (data->getMNameStr() == "系统" ||  data->getMNameStr() == "系统公告")
	{
		if (lbSendName) 
			lbSendName->SetFontColor(INTCOLORTOCCC4(0xff0000));
	}
	else
	{
		if (lbSendName) 
			lbSendName->SetFontColor(INTCOLORTOCCC4(0x133b40));
	}
	
	InitButton(CGRectMake(0, 0, 70, 20), "有效时间", layer[1]);
	InitText(CGRectMake(70, 0, 168, 20), limitTime, layer[1]);
	InitButton(CGRectMake(238, 0, 38, 20), "附件", layer[1]);
	InitText(CGRectMake(276, 0, winsize.width-276, 20), itemname, layer[1]);
	
	InitButton(CGRectMake(0, 0, 70, 20), "赠送", layer[2]);
	InitEdit(CGRectMake(72, 0, 140, 20), NDString(data->getMGetEMoney()).getData(), layer[2]);
	InitButton(CGRectMake(238, 0, 38, 20), "付费", layer[2]);
	InitEdit(CGRectMake(288, 0, 140, 20), NDString(data->getMPayEMoney()).getData(), layer[2]);
	
	InitEdit(CGRectMake(72, 0, 140, 20), NDString(data->getMGetMoney()).getData(), layer[3]);
	InitEdit(CGRectMake(288, 0, 140, 20), NDString(data->getMPayMoney()).getData(), layer[3]);
	
	for (int i = 0; i < 2; i++) 
	{
		m_picEMoney[i] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("emoney.png"));
		m_picMoney[i] = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("money.png"));
	}
	
	CGSize sizeEmoney = m_picEMoney[0]->GetSize();
	CGSize sizeMoney = m_picMoney[0]->GetSize();
	
	InitImage(CGRectMake(74, 2, sizeEmoney.width, sizeEmoney.height), m_picEMoney[0], layer[2]);
	InitImage(CGRectMake(290, 2, sizeEmoney.width, sizeEmoney.height), m_picEMoney[1], layer[2]);
	
	InitImage(CGRectMake(74, 2, sizeMoney.width, sizeMoney.height), m_picMoney[0], layer[3]);
	InitImage(CGRectMake(290, 2, sizeMoney.width, sizeMoney.height), m_picMoney[1], layer[3]);
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetFontSize(15);
	lb->SetFontColor(ccc4(0, 0, 0, 255));
	lb->SetFrameRect(CGRectMake(5, title_height+85, winsize.width, winsize.height));
	lb->SetText("邮件正文");
	m_menulayerBG->AddChild(lb);
	
	int iW = winsize.width-16, iH = winsize.height-bottom_height-title_height-114;
	NDUILayer *textbg = new NDUILayer;
	textbg->Initialization();
	textbg->SetBackgroundColor(ccc4(231, 215, 148, 255));
	textbg->SetFrameRect(CGRectMake(8, title_height+105, iW, iH));
	m_menulayerBG->AddChild(textbg);

	do 
	{
		CGRect rect = textbg->GetFrameRect();
		NDUIMemo *text = new NDUIMemo();
		text->Initialization();
		text->SetFrameRect(CGRectMake(8, 8, rect.size.width-16, rect.size.height-16));
		text->SetBackgroundColor(ccc4(231, 219, 173, 255));
		text->SetText(data->getMContent().c_str());
		text->SetFontColor(ccc4(16, 56, 66, 255));
		textbg->AddChild(text);
		
		
		float poly[4*2] = 
		{
			0,0,
			iW-4, 0,
			0, iH-4,
			iW-4, iH-4
		};
		
		float line[26] =
		{
			1,(4+2),  //point
			6,(4+2),
			6,1,
			iW-6-1,1,
			iW-6-1,4+2,
			iW-1-1,4+2,
			iW-1-1,iH-(4+2)-1,
			iW-6-1,iH-(4+2)-1,
			iW-6-1,iH-1-1,
			6,iH-1-1,
			6,iH-6-1,
			1,iH-6-1,
			1,6,
		};
		
		for (int i=0; i<4; i++)
		{
			NDUIPolygon *uipoly = new NDUIPolygon;
			uipoly->Initialization();
			uipoly->SetLineWidth(1);
			uipoly->SetColor(ccc3(46, 67, 50));
			uipoly->SetFrameRect(CGRectMake(poly[i*2], poly[i*2+1], 4, 4));
			textbg->AddChild(uipoly);
		}
		
		for (int i=0; i<12; i++)
		{
			NDUILine *uiline =  new NDUILine;
			uiline->Initialization();
			uiline->SetWidth(1);
			uiline->SetColor(ccc3(46, 67, 50));
			uiline->SetFromPoint(CGPointMake(line[i*2], line[i*2+1]));
			uiline->SetToPoint(CGPointMake(line[i*2+2], line[i*2+1+2]));
			uiline->SetFrameRect(CGRectMake(1, 1, 1, 1));
			textbg->AddChild(uiline);
		}
		
	} while (0);
	
	
	
	NDUILayer *masklayer = new NDUILayer;
	masklayer->Initialization();
	masklayer->SetBackgroundColor(ccc4(0, 0, 0, 0));
	masklayer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height-title_height));
	m_menulayerBG->AddChild(masklayer);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	masklayer->AddChild(m_tlOperate);
	
	
	//std::vector<std::string> vec_str; std::vector<int> vec_id;
//	vec_str.push_back("收附件"); vec_id.push_back(1);
//	vec_str.push_back("查看附件"); vec_id.push_back(2);
//	vec_str.push_back("拒收附件"); vec_id.push_back(3);
//	vec_str.push_back("回复附件"); vec_id.push_back(4);
//	vec_str.push_back("返回邮箱"); vec_id.push_back(5);
//	
//	InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
//	m_tlOperate->SetVisible(false);
}

void EmailRecvScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetOkBtn() && m_tlOperate) 
	{
		NDMapMgr& mgr = NDMapMgrObj;
		EmailData *data = mgr.GetMail(m_iMailID);
		EmailData& curEmail = *data;
		if (!data) 
		{
			return;
		}
		
		std::vector<std::string> vec_str; std::vector<int> vec_id;
		
		std::string name = curEmail.getMNameStr();
		if (name == "系统" || name == "系统公告") {
		} else { // 增加一个添加好友选项
			if (!mgr.isFriendAdded(name)) {
				vec_str.push_back("加为好友"); vec_id.push_back(eMail_AddFriend);
			}
		}
		
		switch (curEmail.getMState()) {
			case EmailData::STATE_HAVE_ITEM: { // 未接收附件
				vec_str.push_back("收附件"); vec_id.push_back(eMail_GetAttach);
				if (curEmail.isHaveItem()) { // 附件含 item
					vec_str.push_back("查看附件"); vec_id.push_back(eMail_QueryAttach);
				}
				vec_str.push_back("拒收附件"); vec_id.push_back(eMail_RejectAttach);
				break;
			}
		}
		
		if (curEmail.getMNameStr() != "系统") {
			vec_str.push_back("回复"); vec_id.push_back(eMail_Reply);
		}
		
		vec_str.push_back("返回邮箱"); vec_id.push_back(eMail_ReturnMail);
		
		InitTLContentWithVec(m_tlOperate, vec_str, vec_id);
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void EmailRecvScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate) 
	{
		m_tlOperate->SetVisible(false);
		
		NDMapMgr& mgr = NDMapMgrObj;
		EmailData *data = mgr.GetMail(m_iMailID);
		EmailData& curEmail = *data;
		if (!data) 
		{
			return;
		}
		
		int iTag = cell->GetTag();
		switch (iTag) 
		{
			case eMail_AddFriend:
			{
				std::string name = data->getMNameStr();
				sendAddFriend(name);
			}	
				break;
			case eMail_GetAttach:
			{
				if (curEmail.isHavePayMoney() || curEmail.isHavePayEMoney()) {
					checkPayItem(curEmail);
				} else {
					sendAcceptMsg(curEmail);
				}
			}	
				break;
			case eMail_QueryAttach:
			{
				NDTransData bao(_MSG_ITEM);
				bao << curEmail.getMIncludeItem()->iID << (unsigned char)Item::ITEM_QUERY;
				SEND_DATA(bao);
				ShowProgressBar;
				ItemMgrObj.RemoveOtherItems();
			}	
				break;
			case eMail_RejectAttach:
			{
				if (curEmail.getMNameStr() == "系统") {
					showDialog("拒收失败", "系统邮件不允许拒收");
				} else {
					NDTransData bao(_MSG_LETTER_REQUEST);
					bao << int(curEmail.getId()) << (unsigned char)LETTER_ATTACH_REJECT;
					SEND_DATA(bao);
					ShowProgressBar;
				}
			}	
				break;
			case eMail_Reply:
			{
				std::string name = curEmail.getMNameStr();
				NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
				if (!scene->IsKindOfClass(RUNTIME_CLASS(GameScene))
					|| !scene->IsKindOfClass(RUNTIME_CLASS(EmailSendScene)))
				{
					NDDirector::DefaultDirector()->PopScene();
					scene = NDDirector::DefaultDirector()->GetRunningScene();
				}
				
				NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene(name));
			}	
				break;
			case eMail_ReturnMail:
			{
				NDDirector::DefaultDirector()->PopScene();
			}	
				break;
			default:
				break;
		}
	}
}

void EmailRecvScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	NDMapMgr& mgr = NDMapMgrObj;
	EmailData *data = mgr.GetMail(m_iMailID);
	EmailData& curEmail = *data;
	if (!data) 
	{
		return;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	if (player.money < curEmail.getMPayMoney()) {
		showDialog("接收失败", "您身上的银两不足.");
		return;
	}
	
	if (player.eMoney < curEmail.getMPayEMoney()) {
		showDialog("接收失败", "您身上的元宝不足.");
		return;
	}
	
	sendAcceptMsg(curEmail);
}

void EmailRecvScene::InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *btn = new NDUIButton(); \
btn->Initialization(); \
btn->SetFontSize(15); \
btn->SetTitle(text); \
btn->SetTag(iid); \
btn->SetFocusColor(ccc4(253, 253, 253, 255)); \
btn->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
section->AddCell(btn); \
} while (0)
	
	if (!tl || vec_str.empty() || vec_id.empty() || vec_str.size() != vec_id.size() )
	{
		NDLog(@"GameUIPlayerList::InitTLContentWithVec初始化失败");
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++)
	{
		fastinit(vec_str[i].c_str(), vec_id[i]);
	}
	
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
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
	
#undef fastinit	
}

NDUILabel * EmailRecvScene::InitText(CGRect rect, std::string str, NDUINode* pnode)
{
	if (!pnode) 
	{
		return NULL;
	}
	CGSize dim = getStringSizeMutiLine(str.c_str(), 13);
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetFontSize(13);
	lb->SetFontColor(ccc4(16, 56, 66, 255));
	lb->SetFrameRect(CGRectMake(rect.origin.x+(rect.size.width-dim.width)/2, rect.origin.y+(rect.size.height-dim.height)/2, dim.width, dim.height));
	lb->SetText(str.c_str());
	pnode->AddChild(lb);
	
	return lb;
}

void EmailRecvScene::InitEdit(CGRect rect, std::string str, NDUINode* pnode)
{
	if (!pnode) 
	{
		return;
	}
	EmailEdit *edit = new EmailEdit;
	edit->Initialization(false);
	edit->SetFrameRect(rect);
	edit->SetTextAlignment(LabelTextAlignmentCenter);
	edit->SetText(str.c_str());
	edit->SetFontColor(ccc4(16, 56, 66, 255));
	pnode->AddChild(edit);
}

void EmailRecvScene::InitButton(CGRect rect, std::string str, NDUINode* pnode)
{
	if (!pnode) 
	{
		return;
	}
	NDUIButton *btn = new NDUIButton;
	btn->Initialization();
	btn->SetFrameRect(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-2));
	btn->SetTitle(str.c_str());
	btn->CloseFrame();
	btn->SetBackgroundColor(ccc4(55, 147, 184, 255));
	btn->SetFontColor(ccc4(0, 0, 0, 255));
	pnode->AddChild(btn);
}

void EmailRecvScene::InitImage(CGRect rect, NDPicture *pic, NDUINode* pnode)
{
	if (!pic || !pnode) 
	{
		return;
	}
	NDUIImage *image = new NDUIImage;
	image->Initialization();
	image->SetPicture(pic);
	image->SetFrameRect(rect);
	pnode->AddChild(image);
}

void EmailRecvScene::checkPayItem(EmailData& curEmail)
{
	//dialog = new Dialog("温馨提示", "此物品为收费物品,是否支付\n" + curEmail.getMPayMoney()
//						+ " 银两,\n" + curEmail.getMPayEMoney() + " 元宝?",
//						Dialog.PRIV_HIGH);
//	TextView views[] = new TextView[OPERATOR_TEXT.length];
//	for (int i = 0; i < views.length; i++) {
//		views[i] = new TextView(OPERATOR_TEXT[i], 4);
//		views[i].bolShowBorder = false;
//		views[i].id = (7);
//		views[i].setOnClickListener(this);
//	}
//	dialog.setOperator(views);
	
	std::stringstream ss; 
	ss << "此物品为收费物品,是否支付\n" << curEmail.getMPayMoney()
	<< " 银两,\n" << curEmail.getMPayEMoney() << " 元宝?";
	
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show("温馨提示", ss.str().c_str(), "取消", "确定", NULL);
}

void EmailRecvScene::sendAcceptMsg(EmailData& curEmail)
{
	NDTransData bao(_MSG_LETTER_REQUEST);
	bao << int(curEmail.getId()) << (unsigned char)LETTER_ATTACH_ACCEPT;
	SEND_DATA(bao);
	ShowProgressBar;
}

////////////////////////////////////////////////////////////

GameMailsScene * GameMailsScene::s_MailsInstance = NULL;

IMPLEMENT_CLASS(GameMailsScene, NDScene)

enum  
{
	eOP_Query = 700,
	eOP_Del = 701,
};

GameMailsScene::GameMailsScene()
{
	m_lbTitle = NULL;
	m_tlMain = NULL;
	m_tlOperate = NULL;
	m_iOperateMailID = -1;
	s_MailsInstance = this;
}

GameMailsScene::~GameMailsScene()
{
	s_MailsInstance = NULL;
}

void GameMailsScene::Initialization()
{
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	//CGSize dim = getStringSizeMutiLine("收件箱", 15);
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	//m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, m_menulayerBG->GetTitleHeight()));
	m_lbTitle->SetText("收件箱");
	this->AddChild(m_lbTitle);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->VisibleSectionTitles(false);
	this->AddChild(m_tlMain);
	
	NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
	topLayerEx->Initialization();
	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	topLayerEx->AddChild(m_tlOperate);
	
	UpdateGui();
}

void GameMailsScene::UpdateGui()
{
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDSection *section = new NDSection;
	NDDataSource * dataSource = new NDDataSource;
	section->Clear();
	section->UseCellHeight(true);
	bool bChangeClr = false;
	
	vec_email& mails = NDMapMgrObj.m_vEmail;
	for_vec(mails, vec_email_it)
	{
		EmailData *data = *it;
		if (data->getMTimeStr().empty()) 
		{
			continue;
		}
		std::stringstream ss; 
		ss << data->getMTimeStr() << "   " << data->getMNameStr() << data->getMStateStr();
		
		//if (mEmail.getMNameStr().endsWith("系统") || mEmail.getMNameStr().endsWith("系统公告")) {
//			g.setColor(0xff0000);
//		}
		
		LabelLayer *layer = new LabelLayer;
		layer->Initialization();
		layer->SetTag(data->getId());
		layer->SetFontColor(ccc4(16, 56, 66, 255));
		layer->SetFrameRect(CGRectMake(0, 0, winsize.width, 30));
		std::vector<std::string> vec_str; vec_str.push_back(ss.str());
		layer->SetTexts(vec_str);
		layer->ShowFrame(false);
		if (bChangeClr) {
			layer->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			layer->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		section->AddCell(layer);
	}
	
	dataSource->AddSection(section);
	
	int iMaxH = winsize.height-title_height-bottom_height;
	int iH = 30*section->Count()+section->Count()+1;
	bool bScroll = false;
	if (iH > iMaxH) 
	{
		iH = iMaxH;
		bScroll = true;
	}
	
	m_tlMain->SetFrameRect(CGRectMake(0, title_height, winsize.width, iH));
	m_tlMain->SetVisible(true);
	m_tlMain->VisibleScrollBar(bScroll);
	
	if (m_tlMain->GetDataSource())
	{
		m_tlMain->SetDataSource(dataSource);
		m_tlMain->ReflashData();
	}
	else
	{
		m_tlMain->SetDataSource(dataSource);
	}
	
	//update title
	if (m_lbTitle) 
	{
		std::stringstream title;
		title << "收件箱[" << int(mails.size()) << "]";
		m_lbTitle->SetText(title.str().c_str());
	}
}

void GameMailsScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain && cell->IsKindOfClass(RUNTIME_CLASS(LabelLayer))) 
	{
		int iMailID = cell->GetTag();
		EmailData * mail = NDMapMgrObj.GetMail(iMailID);
		if (mail) 
		{
			CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
			NDSection *section = new NDSection;
			NDDataSource * dataSource = new NDDataSource;
			section->Clear();
			//section->UseCellHeight(true);
			int iHeight = 30;
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("查看");
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			btn->SetTag(eOP_Query);
			section->AddCell(btn);
			
			if (!(mail->getMNameStr() == "系统公告")) 
			{ // 不是系统公告的才能删除
				NDUIButton* btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle("删除");
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				btn->SetTag(eOP_Del);
				section->AddCell(btn);
				iHeight = 60;
			}
			
			dataSource->AddSection(section);
			
			m_tlOperate->SetFrameRect(CGRectMake((winsize.width-120)/2, (winsize.height-iHeight)/2, 120, iHeight));
			m_tlOperate->SetVisible(true);
			
			if (m_tlOperate->GetDataSource())
			{
				m_tlOperate->SetDataSource(dataSource);
				m_tlOperate->ReflashData();
			}
			else
			{
				m_tlOperate->SetDataSource(dataSource);
			}
		}
		
		m_iOperateMailID = mail == NULL ? -1 : iMailID;
	}
	else if (table == m_tlOperate && cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		m_tlOperate->SetVisible(false);
		EmailData * mail = NDMapMgrObj.GetMail(m_iOperateMailID);
		if (mail) 
		{
			int iOP = cell->GetTag();
			if (iOP == eOP_Query) 
			{
				if (mail->getMContent().empty()) 
				{
					NDTransData bao(_MSG_LETTER_REQUEST);
					bao << int(mail->getId());
					bao << (unsigned char)LETTER_LOOK;
					SEND_DATA(bao);
					ShowProgressBar; // 测试查看邮件
				}
				else 
				{
					EmailRecvScene *scene = new EmailRecvScene;
					scene->Initialization(mail);
					NDDirector::DefaultDirector()->PushScene(scene);
				}
			}
			else if (iOP == eOP_Del) 
			{
				if (mail->getMNameStr() == "系统公告") 
				{
					showDialog("删除失败", "系统公告邮件不能删除");
					return;
				}
				
				if (mail->getMState() == EmailData::STATE_HAVE_ITEM) 
				{
					showDialog("删除失败", "您的邮件中带有附件,不能直接删除");
				} 
				else 
				{
					NDTransData bao(_MSG_LETTER_REQUEST);
					bao << int(mail->getId());
					bao << (unsigned char)LETTER_DEL;
					SEND_DATA(bao);
					ShowProgressBar;
				}
			}
		}
	}

}

void GameMailsScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void GameMailsScene::UpdateMail()
{
	if (s_MailsInstance) 
	{
		s_MailsInstance->UpdateGui();
		s_MailsInstance->m_iOperateMailID = -1;
		if (s_MailsInstance->m_tlOperate) 
		{
			s_MailsInstance->m_tlOperate->SetVisible(false);
		}
	}
}

void GameMailsScene::UpddateMailInfo()
{
	if (s_MailsInstance) 
	{
		EmailData * mail = NDMapMgrObj.GetMail(s_MailsInstance->m_iOperateMailID);
		if (mail) 
		{
			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
			if (scene->IsKindOfClass(RUNTIME_CLASS(EmailRecvScene)))
			{
				NDDirector::DefaultDirector()->PopScene();
			}
			
			EmailRecvScene *emailscene = new EmailRecvScene;
			emailscene->Initialization(mail);
			NDDirector::DefaultDirector()->PushScene(emailscene);
		}
	}
}

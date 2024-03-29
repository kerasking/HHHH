/*
 *  NewMail.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NewMail.h"
#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"
#include "ItemMgr.h"
#include "NDMsgDefine.h"
#include "NewMailSend.h"
#include "NDUISpecialLayer.h"
#include "CGPointExtension.h"
#include <sstream>

#pragma mark 收件箱

enum  
{
	eNewMail_Begin = 8080,
	eNewMail_AddFriend = eNewMail_Begin,
	eNewMail_GetAttach,
	eNewMail_QueryAttach,
	eNewMail_RejectAttach,
	eNewMail_Reply,
	eNewMail_Del,
	eNewMail_End
};

enum
{
	NEW_LETTER_LOOK = 0, // 查看邮件
	NEW_LETTER_ATTACH_ACCEPT = 1, // 接收附件
	NEW_LETTER_ATTACH_REJECT = 2, // 拒收附件
	NEW_LETTER_DEL = 3,
};

IMPLEMENT_CLASS(MailInfo, NDUILayer)

	
MailInfo::MailInfo()
{
	m_emailData = NULL;
	
	m_layerScroll = NULL;
	
	m_lbSend = m_lbDate = NULL;
	
	m_lbAttach = NULL;
	
	m_lbGive = m_lbFee = NULL;
	
	m_imageGiveMoney = NULL; m_imageGiveMoneyBg = NULL; m_lbGiveMoney = NULL;
	
	m_imageGiveEMoney = NULL; m_imageGiveEMoneyBg = NULL; m_lbGiveEMoney = NULL;
	
	m_imageFeeMoney = NULL; m_imageFeeMoneyBg = NULL; m_lbFeeMoney = NULL;
	
	m_imageFeeEMoney = NULL; m_imageFeeEMoneyBg = NULL; m_lbFeeEMoney = NULL;
}

MailInfo::~MailInfo()
{
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		NDUIButton*& btn = *it;
		
		if (btn && btn->GetParent() == NULL) 
		{
			delete btn;
		}
	}
}

void MailInfo::Initialization(CGPoint pos)
{
	NDUILayer::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture* picBg = pool.AddPicture(GetImgPathNew("bag_left_bg.png"));
	
	CGSize sizeBg = picBg->GetSize();
	
	this->SetBackgroundImage(picBg, true);
	
	this->SetFrameRect(CGRectMake(pos.x, pos.y, sizeBg.width, sizeBg.height));
	
	NDUILayer *layContent = new NDUILayer;
	layContent->Initialization();
	layContent->SetBackgroundImage(pool.AddPicture(GetImgPathNew("attr_role_bg.png"), 196, 92), true);
	layContent->SetFrameRect(CGRectMake(0, 43, 196, 92));
	this->AddChild(layContent);
	
	m_layerScroll = new NDUIContainerScrollLayer;
	m_layerScroll->Initialization();
	m_layerScroll->SetFrameRect(CGRectMake(4, 8, 196-8, 92-16));
	layContent->AddChild(m_layerScroll);
	
	m_lbSend = new NDUILabel;
	m_lbSend->Initialization();
	m_lbSend->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSend->SetFontSize(12);
	m_lbSend->SetFrameRect(CGRectMake(5, 4, sizeBg.width, sizeBg.height));
	m_lbSend->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbSend);
	
	m_lbDate = new NDUILabel;
	m_lbDate->Initialization();
	m_lbDate->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbDate->SetFontSize(12);
	m_lbDate->SetFrameRect(CGRectMake(5, 23, sizeBg.width, sizeBg.height));
	m_lbDate->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbDate);
	
	NDPicture *picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	CGSize sizeCut = picCut->GetSize();
	
	NDUIImage* imageCut = new NDUIImage;
	
	imageCut->Initialization();
	
	imageCut->SetPicture(picCut, true);
	
	imageCut->SetFrameRect(CGRectMake((sizeBg.width-sizeCut.width)/2, 139, sizeCut.width, sizeCut.height));
	
	imageCut->EnableEvent(false);
	
	this->AddChild(imageCut);
	
	picCut = pool.AddPicture(GetImgPathNew("bag_left_fengge.png"));
	
	sizeCut = picCut->GetSize();
	
	imageCut = new NDUIImage;
	
	imageCut->Initialization();
	
	imageCut->SetPicture(picCut, true);
	
	imageCut->SetFrameRect(CGRectMake((sizeBg.width-sizeCut.width)/2, 204, sizeCut.width, sizeCut.height));
	
	imageCut->EnableEvent(false);
	
	this->AddChild(imageCut);
	
	m_lbAttach = new NDUILabel;
	m_lbAttach->Initialization();
	m_lbAttach->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbAttach->SetFontSize(12);
	m_lbAttach->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbAttach);
	
	m_lbGive = new NDUILabel;
	m_lbGive->Initialization();
	m_lbGive->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbGive->SetFontSize(12);
	m_lbGive->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbGive);
	
	m_lbFee = new NDUILabel;
	m_lbFee->Initialization();
	m_lbFee->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbFee->SetFontSize(12);
	m_lbFee->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbFee);
	
	InitMoney(false, m_imageGiveMoney, m_imageGiveMoneyBg, m_lbGiveMoney);
	
	InitMoney(true, m_imageGiveEMoney, m_imageGiveEMoneyBg, m_lbGiveEMoney);
	
	InitMoney(false, m_imageFeeMoney, m_imageFeeMoneyBg, m_lbFeeMoney);
	
	InitMoney(true, m_imageFeeEMoney, m_imageFeeEMoneyBg, m_lbFeeEMoney);
}

void MailInfo::OnButtonClick(NDUIButton* button)
{
	if (!m_emailData) return;
	
	EmailData *data = m_emailData;
	EmailData *mail = m_emailData;
	EmailData& curEmail = *data;
	
	int op = button->GetTag();
	
	switch (op) 
	{
		case eNewMail_AddFriend:
		{
			std::string name = data->getMNameStr();
			sendAddFriend(name);
		}
			break;
		case eNewMail_GetAttach:
		{
			if (curEmail.isHavePayMoney() || curEmail.isHavePayEMoney()) {
				checkPayItem(curEmail);
			} else {
				sendAcceptMsg(curEmail);
			}
		}
			break;
		case eNewMail_QueryAttach:
		{
			NDTransData bao(_MSG_ITEM);
			bao << curEmail.getMIncludeItem()->iID << (unsigned char)Item::ITEM_QUERY;
			SEND_DATA(bao);
			ShowProgressBar;
			ItemMgrObj.RemoveOtherItems();
		}
			break;
		case eNewMail_RejectAttach:
		{
			if (curEmail.getMNameStr() == NDCommonCString("system")) {
				showDialog(NDCommonCString("RejectFail"), NDCommonCString("SystemMainNotReject"));
			} else {
				NDTransData bao(_MSG_LETTER_REQUEST);
				bao << int(curEmail.getId()) << (unsigned char)NEW_LETTER_ATTACH_REJECT;
				SEND_DATA(bao);
				ShowProgressBar;
			}
		}
			break;
		case eNewMail_Reply:
		{
			NDDirector::DefaultDirector()->PushScene(NewMailSendScene::Scene(curEmail.getMNameStr().c_str()));
		}
			break;
		case eNewMail_Del:
		{
			if (mail->getMNameStr() == NDCommonCString("SysGongGao")) 
			{
				showDialog(NDCommonCString("DelFail"), NDCommonCString("SystemMainNotDel"));
				return;
			}
			
			if (mail->getMState() == EmailData::STATE_HAVE_ITEM) 
			{
				showDialog(NDCommonCString("DelFail"), NDCommonCString("MailWithAttachNotDel"));
			} 
			else 
			{
				NDTransData bao(_MSG_LETTER_REQUEST);
				bao << int(mail->getId());
				bao << (unsigned char)NEW_LETTER_DEL;
				SEND_DATA(bao);
				ShowProgressBar;
			}
		}
			break;
		default:
			break;
	}
}

void MailInfo::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	if (!m_emailData) return;
	
	EmailData& curEmail = *m_emailData;
	
	NDPlayer& player = NDPlayer::defaultHero();
	if (player.money < curEmail.getMPayMoney()) {
		showDialog(NDCommonCString("RecvFail"), NDCommonCString("MoneyNotEnough"));
		return;
	}
	
	if (player.eMoney < curEmail.getMPayEMoney()) {
		showDialog(NDCommonCString("RecvFail"),NDCommonCString("EMoneyNotEnough"));
		return;
	}
	
	sendAcceptMsg(curEmail);
}

void MailInfo::checkPayItem(EmailData& curEmail)
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
	ss << NDCommonCString("FeeItemTip") << "\n" << curEmail.getMPayMoney()
	<< " " << NDCommonCString("money") << ",\n" << curEmail.getMPayEMoney() << " " << NDCommonCString("emoney") << "?";
	
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show(NDCommonCString("WenXinTip"), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
}

void MailInfo::sendAcceptMsg(EmailData& curEmail)
{
	NDTransData bao(_MSG_LETTER_REQUEST);
	bao << int(curEmail.getId()) << (unsigned char)NEW_LETTER_ATTACH_ACCEPT;
	SEND_DATA(bao);
	ShowProgressBar;
}

void MailInfo::ChangeMail(EmailData* data)
{
	m_emailData = data;
	
	reset();
	
	if (!m_emailData) return;
	
	setLabel(m_lbSend, (std::string(NDCommonCString("MailSender"))+ " : " + data->getMNameStr()).c_str());
	
	bool bShowAttach = false;
	
	std::string limitTime = data->getMTimeLimit();
	switch (data->getMState()) {
		case EmailData::STATE_HAVE_ITEM: { // 未接收附件
			std::stringstream ss;
			ss << data->getMTimeLimit() << NDCommonCString("AttachNotRecvGuo");
			limitTime = ss.str();
			bShowAttach = true;
			break;
		}
		case EmailData::STATE_ACCEPT: {
			limitTime = NDCommonCString("YiJieShou");
			break;
		}
		case EmailData::STATE_REJECT: {
			limitTime = NDCommonCString("YiJuShou");
			break;
		}
		case EmailData::STATE_WITHDRAWAL: {
			limitTime = NDCommonCString("YiTuiHui");
			break;
		}
	}
	
	setLabel(m_lbDate, limitTime.c_str());
	
	SetText(data->getMContent().c_str());
	
	int startX = 5, startY = 143, width = this->GetFrameRect().size.width, height = this->GetFrameRect().size.height;
	
	std::string itemname;
	if (bShowAttach && data->isHaveItem()) { // 附件含 item
		itemname = data->getMItemStr();
		
		setLabelAndFrame(m_lbAttach, (std::string(NDCommonCString("attach")) + " : "+itemname).c_str(), CGRectMake(startX, startY, width, height));
		
		startY += 15;
	}
	
	int iGiveMoney = data->getMGetMoney(),
		iGiveEmoney = data->getMGetEMoney(),
		iFeeMoney = data->getMPayMoney(),
		iFeeEmoney = data->getMPayEMoney();
		
	if ( bShowAttach && (iGiveMoney > 0 || iGiveEmoney > 0))
	{
		setLabelAndFrame(m_lbGive, NDCommonCString("ZhengSong"), CGRectMake(startX, startY+3, width, height));
		
		int x = startX + 32;
		
		if (iGiveMoney > 0)
		{
			SetMoney(m_imageGiveMoney, m_imageGiveMoneyBg, m_lbGiveMoney, iGiveMoney, x, startY);
		
			x += 18 + 62 + 2;
		}
		
		if (iGiveEmoney > 0)
			SetMoney(m_imageGiveEMoney, m_imageGiveEMoneyBg, m_lbGiveEMoney, iGiveEmoney, x, startY);
		
		startY += 20;
	}
	
	if ( bShowAttach && (iFeeMoney > 0 || iFeeEmoney > 0))
	{
		setLabelAndFrame(m_lbFee, NDCommonCString("ShouFei"), CGRectMake(startX, startY+3, width, height));
		
		int x = startX + 32;
		
		if (iFeeMoney > 0)
		{
			SetMoney(m_imageFeeMoney, m_imageFeeMoneyBg, m_lbFeeMoney, iFeeMoney, x, startY);
		
			x += 18 + 62 + 2;
		}
		
		if (iFeeEmoney > 0)
			SetMoney(m_imageFeeEMoney, m_imageFeeEMoneyBg, m_lbFeeEMoney, iFeeEmoney, x, startY);
	}
	
	refreshOperate();
}

void MailInfo::SetMoney(NDUIImage*& image, NDUIImage*& imageBG, NDUILabel*& lb, int value, int startX, int startY)
{	
	int width = this->GetFrameRect().size.width, height = this->GetFrameRect().size.height;
	
	setImage(image, CGRectMake(startX, startY+2, 16, 16));
	
	startX += 18;
	
	setImage(imageBG, CGRectMake(startX, startY, 62, 18));
	
	std::stringstream ss; ss << value;
	
	setLabelAndFrame(lb, ss.str().c_str(), CGRectMake(2, 3, width, height));
}

void MailInfo::SetText(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_layerScroll) return;
	
	m_layerScroll->RemoveAllChildren(true);
	
	if (!text) return;
	
	CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_layerScroll->GetFrameRect().size.width, 320));
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(fontsize);
	lb->SetFrameRect(CGRectMake(0, 0, size.width, size.height));
	lb->SetFontColor(color);
	lb->SetText(text);
	m_layerScroll->AddChild(lb);
	
	m_layerScroll->refreshContainer();
}
	
void MailInfo::InitMoney(bool emoney, NDUIImage *& imageMoney, NDUIImage*& imageMoneyBG, NDUILabel*& lbMoney)
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picMoney = pool.AddPicture(GetImgPath(emoney ? "emoney.png" : "money.png" )); // 16X16
	
	NDPicture *picMoneyBG = pool.AddPicture(GetImgPathNew("money_input.png"), 62, 0); // 62X18
	
	imageMoney = new NDUIImage;
	imageMoney->Initialization();
	imageMoney->SetPicture(picMoney, true);
	this->AddChild(imageMoney);
	
	imageMoneyBG = new NDUIImage;
	imageMoneyBG->Initialization();
	imageMoneyBG->SetPicture(picMoneyBG, true);
	this->AddChild(imageMoneyBG);
	
	lbMoney = new NDUILabel;
	lbMoney->Initialization();
	lbMoney->SetTextAlignment(LabelTextAlignmentLeft);
	lbMoney->SetFontSize(12);
	lbMoney->SetFontColor(ccc4(255, 248, 198, 255));
	imageMoneyBG->AddChild(lbMoney);
}

void MailInfo::reset()
{
	resetLabel(m_lbSend);
	
	resetLabel(m_lbDate);
	
	resetLabel(m_lbAttach);
	
	resetLabel(m_lbGive);
	
	resetLabel(m_lbFee);
	
	resetImage(m_imageGiveMoney); resetImage(m_imageGiveMoneyBg); resetLabel(m_lbGiveMoney);
	
	resetImage(m_imageGiveEMoney); resetImage(m_imageGiveEMoneyBg); resetLabel(m_lbGiveEMoney);
	
	resetImage(m_imageFeeMoney); resetImage(m_imageFeeMoneyBg); resetLabel(m_lbFeeMoney);
	
	resetImage(m_imageFeeEMoney); resetImage(m_imageFeeEMoneyBg); resetLabel(m_lbFeeEMoney);
	
	resetOperate();
	
	if (m_layerScroll)
		m_layerScroll->RemoveAllChildren(true);
}

void MailInfo::HideAttach()
{
	resetLabel(m_lbAttach);
	
	resetLabel(m_lbGive);
	
	resetLabel(m_lbFee);
	
	resetImage(m_imageGiveMoney); resetImage(m_imageGiveMoneyBg); resetLabel(m_lbGiveMoney);
	
	resetImage(m_imageGiveEMoney); resetImage(m_imageGiveEMoneyBg); resetLabel(m_lbGiveEMoney);
	
	resetImage(m_imageFeeMoney); resetImage(m_imageFeeMoneyBg); resetLabel(m_lbFeeMoney);
	
	resetImage(m_imageFeeEMoney); resetImage(m_imageFeeEMoneyBg); resetLabel(m_lbFeeEMoney);
}

void MailInfo::resetLabel(NDUILabel*& lb)
{
	if (lb)
	{
		lb->SetText("");
		lb->SetVisible(false);
	}
}

void MailInfo::resetImage(NDUIImage*& image)
{
	if (image) 
	{
		image->SetVisible(false);
	}
}

void MailInfo::resetOperate()
{
	for_vec(m_vOpBtn, std::vector<NDUIButton*>::iterator)
	{
		(*it)->RemoveFromParent(false);
	}
}

void MailInfo::SetVisible(bool visible)
{
	//if (!visible)
		NDUILayer::SetVisible(visible);
//	else if (m_emailData)
	//	NDUILayer::SetVisible(visible);
}

void MailInfo::setLabel(NDUILabel*& lb, const char* text)
{
	if (lb && text)
	{
		lb->SetText(text);
		lb->SetVisible(true);
	}
}

void MailInfo::setLabelAndFrame(NDUILabel*& lb, const char* text, CGRect rect)
{
	if (lb)
		lb->SetFrameRect(rect);
	setLabel(lb, text);
}

void MailInfo::setImage(NDUIImage*& image, CGRect rect)
{
	if (image)
	{
		image->SetFrameRect(rect);
		image->SetVisible(true);
	}
}

void MailInfo::refreshOperate()
{
	if (!m_emailData) return;
	
	EmailData& curEmail = *m_emailData;
	
	std::vector<std::string> vec_str; std::vector<int> vec_id;
	
	std::string name = curEmail.getMNameStr();
	if (name == NDCommonCString("system") || name == NDCommonCString("SysGongGao")) {
	} else { // 增加一个添加好友选项
		if (!NDMapMgrObj.isFriendAdded(name)) {
			vec_str.push_back(NDCommonCString("JiaFriend")); vec_id.push_back(eNewMail_AddFriend);
		}
	}
	
	
	switch (curEmail.getMState()) {
		case EmailData::STATE_HAVE_ITEM: { // 未接收附件
			vec_str.push_back(NDCommonCString("ShouQu")); vec_id.push_back(eNewMail_GetAttach);
			if (curEmail.isHaveItem()) { // 附件含 item
				vec_str.push_back(NDCommonCString("ChaKang")); vec_id.push_back(eNewMail_QueryAttach);
			}
			vec_str.push_back(NDCommonCString("JuShou")); vec_id.push_back(eNewMail_RejectAttach);
			break;
		}
	}
	
	if (curEmail.getMNameStr() != NDCommonCString("system")) {
		vec_str.push_back(NDCommonCString("reply")); vec_id.push_back(eNewMail_Reply);
	}
	
	vec_str.push_back(NDCommonCString("del")); vec_id.push_back(eNewMail_Del);
	
	size_t sizeOperate = vec_id.size();
	
	if (sizeOperate != vec_str.size()) 
	{
		return;
	}
	
	size_t sizeBtns = m_vOpBtn.size();
	
	size_t max = sizeBtns;
	
	if (sizeOperate > sizeBtns) 
	{
		m_vOpBtn.resize(sizeOperate, NULL);
		
		max = sizeOperate;
	}
	
	int startx = 7, starty = 207, btnw = 43, btnh = 24, interval = 3, col = 4;
	
	for (size_t i = 0; i < max; i++) 
	{
		NDUIButton*& btn = m_vOpBtn[i];
		if (!btn) 
		{
			NDPicturePool& pool = *(NDPicturePool::DefaultPool());
			btn = new NDUIButton;
			
			btn->Initialization();
			
			btn->SetFontColor(ccc4(255, 255, 255, 255));
			
			btn->SetFontSize(12);
			
			btn->CloseFrame();
			
			btn->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), btnw, 0),
									  pool.AddPicture(GetImgPathNew("bag_btn_click.png"), btnw, 0),
									  false, CGRectZero, true);
			btn->SetDelegate(this);							 
			
			this->AddChild(btn);
		}
		
		btn->SetFrameRect(CGRectMake(startx+(btnw+interval)*(i%col),
									 starty+(btnh+interval)*(i/col), 
									 btnw, 
									 btnh));
		
		if (i >= sizeOperate) 
		{
			btn->SetTitle("");
			
			btn->SetTag(eNewMail_End);
			
			if (btn->GetParent() != NULL) 
			{
				btn->RemoveFromParent(false);
			}
			
			continue;
		}
		
		if (btn->GetParent() == NULL) 
		{
			this->AddChild(btn);
		}
		
		btn->SetTag(vec_id[i]);
		
		btn->SetTitle(vec_str[i].c_str());
	}
}

IMPLEMENT_CLASS(NDMailCell, NDPropCell)

NDMailCell::NDMailCell()
{
	m_picNotRead = m_picHadRead = NULL;
	
	m_emailData = NULL;
}

NDMailCell::~NDMailCell()
{
}

void NDMailCell::Initialization()
{
	NDPropCell::Initialization(false);
	
	this->SetFocusTextColor(ccc4(133, 40, 42, 255));
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	m_picNotRead = pool.AddPicture(GetImgPathNew("mail_not_read.png"));
	
	m_picHadRead = pool.AddPicture(GetImgPathNew("mail_read.png"));
}

void NDMailCell::draw()
{
	if (!this->IsVisibled()) return;
	
	if (!m_emailData) return;
	
	NDPropCell::draw();
	
	NDNode *parent = this->GetParent();
	
	NDPicture * pic = NULL;
	
	if (parent && parent->IsKindOfClass(RUNTIME_CLASS(NDUILayer)) && ((NDUILayer*)parent)->GetFocus() == this)
	{
		pic = m_picFocus;
	}
	else
	{
		pic = m_picBg;
	}
	
	if (!pic) return;
	
	CGSize size = pic->GetSize();
	
	if (m_emailData->getReadState() == EmailData::STATE_NOT_READ)
		pic = m_picNotRead;
	else
		pic = m_picHadRead;
	
	if (!pic) return;
	
	CGSize sizeState = pic->GetSize();
	
	CGRect scrRect = this->GetScreenRect();
	
	pic->DrawInRect(CGRectMake(scrRect.origin.x+scrRect.size.width-10-sizeState.width, 
							   scrRect.origin.y+(size.height-sizeState.height)/2, 
							   sizeState.width, sizeState.height));
}

void NDMailCell::ChangeMail(EmailData* data)
{
	m_emailData = data;
	
	if (m_emailData && m_lbKey)
		m_lbKey->SetText(m_emailData->getMNameStr().c_str());
	else if (!m_emailData && m_lbKey)
		m_lbKey->SetText("");
}

EmailData* NDMailCell::GetMail()
{
	return m_emailData;
}

IMPLEMENT_CLASS(NewMailUILayer, NDUILayer)

NewMailUILayer* NewMailUILayer::s_instance = NULL;

NewMailUILayer::NewMailUILayer()
{
	s_instance = this;
	
	m_tlMail = NULL;
	
	m_infoMail = NULL;
	
	m_btnNewMail = NULL;
}

NewMailUILayer::~NewMailUILayer()
{
	s_instance = NULL;
}

void NewMailUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table != m_tlMail || !cell->IsKindOfClass(RUNTIME_CLASS(NDMailCell))) return;
	
	NDMailCell *sc = (NDMailCell*)cell;
	
	EmailData* mail = sc->GetMail();
	
	if (!mail) return;

	if (mail->getMContent().empty()) 
	{
		NDTransData bao(_MSG_LETTER_REQUEST);
		bao << int(mail->getId());
		bao << (unsigned char)NEW_LETTER_LOOK;
		SEND_DATA(bao);
		ShowProgressBar; // 测试查看邮件
	}
	
	if (m_infoMail)
	{
		m_infoMail->ChangeMail(mail);
	}
}

void NewMailUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picNew = pool.AddPicture(GetImgPathNew("newui_btn.png"));
	
	CGSize sizeNew = picNew->GetSize();
	
	m_btnNewMail = new NDUIButton;
	
	m_btnNewMail->Initialization();
	
	m_btnNewMail->SetFrameRect(CGRectMake(7, 37-sizeNew.height, sizeNew.width, sizeNew.height));
	
	m_btnNewMail->SetImage(picNew, false, CGRectZero, true);
	
	m_btnNewMail->SetFontSize(14);
	
	m_btnNewMail->SetFontColor(ccc4(116, 13, 13, 255));
	
	m_btnNewMail->SetDelegate(this);
	
	this->AddChild(m_btnNewMail);
	
	NDPicture *picMail = pool.AddPicture(GetImgPathNew("newmail_btn.png"));
	
	CGSize sizeMail = picMail->GetSize();
	
	NDUIImage *imageMail = new NDUIImage;
	
	imageMail->Initialization();
	
	imageMail->SetPicture(picMail, true);
	
	imageMail->SetFrameRect(CGRectMake((sizeNew.width-sizeMail.width)/2, (sizeNew.height-sizeMail.height)/2, sizeMail.width, sizeMail.height));
	
	m_btnNewMail->AddChild(imageMail);
	
	m_infoMail = new MailInfo;
	
	m_infoMail->Initialization(CGPointMake(0, 48));
	
	this->AddChild(m_infoMail);
	
	m_infoMail->ChangeMail(NULL);
	
	//m_tlMail = new NDUITableLayer;
	
	//m_tlMail->Initialization();
	
	int width = 252;//, height = 274;
	do 
	{
		m_tlMail = new NDUITableLayer;
		m_tlMail->Initialization();
		m_tlMail->SetSelectEvent(false);
		m_tlMail->SetBackgroundColor(ccc4(0, 0, 0, 0));
		m_tlMail->VisibleSectionTitles(false);
		m_tlMail->SetFrameRect(CGRectMake(6+200, 17+37, width-10, 226));
		m_tlMail->VisibleScrollBar(false);
		m_tlMail->SetCellsInterval(2);
		m_tlMail->SetCellsRightDistance(0);
		m_tlMail->SetCellsLeftDistance(0);
		m_tlMail->SetDelegate(this);
		
		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;
		section->UseCellHeight(true);
		dataSource->AddSection(section);
		m_tlMail->SetDataSource(dataSource);
		this->AddChild(m_tlMail);
	} while (0);
	
	refreshMainList();
}

void NewMailUILayer::SetVisible(bool visible)
{
	NDUILayer::SetVisible(visible);
	
	if (visible)
		refreshMainList();
}

void NewMailUILayer::refreshMainList()
{
	if (!m_tlMail
		|| !m_tlMail->GetDataSource()
		|| m_tlMail->GetDataSource()->Count() != 1)
		return;
	
	NDSection* section = m_tlMail->GetDataSource()->Section(0);
	
	vec_email& mails = NDMapMgrObj.m_vEmail;
	
	vec_email tmpMail;
	for_vec(mails, vec_email_it)
	{
		EmailData *data = *it;
		
		if (!data) return;
		
		if (data->getMTimeStr().empty()) continue;
		
		tmpMail.push_back(data);
	}
	
	size_t maxCount = section->Count() > tmpMail.size() ? section->Count() : tmpMail.size();
	
	unsigned int infoCount = 0;
	
	for (size_t i = 0; i < maxCount; i++) 
	{
		EmailData *data = i < tmpMail.size() ? tmpMail[i] : NULL;
		
		if (data != NULL)
		{
			NDMailCell *cell = NULL;
			if (infoCount < section->Count())
				cell = (NDMailCell *)section->Cell(infoCount);
			else
			{
				cell = new NDMailCell;
				cell->Initialization();
				section->AddCell(cell);
			}
			cell->ChangeMail(data);
			
			infoCount++;
		}
		else
		{
			if (infoCount < section->Count() && section->Count() > 0)
			{
				section->RemoveCell(section->Count()-1);
			}
		}
	}
	
	m_tlMail->ReflashData();
	
	if (!m_infoMail) return;
	
	if (!m_infoMail->GetMail())
	{
		m_infoMail->ChangeMail(NULL);
		
		
		if (section->Count() > 0)
		{
			section->SetFocusOnCell(0);
			m_tlMail->ReflashData();
			
			OnTableLayerCellSelected(m_tlMail, section->Cell(0), 0, section);
		}
		
		return;
	}
	
	EmailData* curData = m_infoMail->GetMail();
	
	bool find = false;
	
	for (vec_email_it it = tmpMail.begin(); it != tmpMail.end(); it++) 
	{
		if (curData->getId() == (*it)->getId())
		{
			find = true;
			
			break;
		}
	}
	
	if (!find)
		m_infoMail->ChangeMail(NULL);
	else
		m_infoMail->ChangeMail(curData);
		
	if (!m_infoMail->GetMail())
	{
		m_infoMail->ChangeMail(NULL);
		
		
		if (section->Count() > 0)
		{
			section->SetFocusOnCell(0);
			m_tlMail->ReflashData();
			
			OnTableLayerCellSelected(m_tlMail, section->Cell(0), 0, section);
		}
		
		return;
	}
}

void NewMailUILayer::refresh()
{
	if (s_instance)
		s_instance->refreshMainList();
}

void NewMailUILayer::OnButtonClick(NDUIButton* button)
{
	if (button != m_btnNewMail) return;
	
	NDDirector::DefaultDirector()->PushScene(NewMailSendScene::Scene());
}

#pragma mark 发邮件

IMPLEMENT_CLASS(NewMailSendUILayer, NDUILayer)

NewMailSendUILayer::NewMailSendUILayer()
{
	m_btnSend = NULL;
	
	m_input = NULL;
	
	// ...
	m_lbRecvName = NULL; m_btnRecvName = NULL;
	
	m_contentScroll = NULL; m_lbMailContent = NULL;
	
	m_btnItem = m_btnItemCount = NULL; m_lbItemCount = NULL;
	
	m_lbGive = m_lbFee = NULL;
	
	m_imageGiveMoney = NULL; m_btnGiveMoneyBg = NULL; m_lbGiveMoney = NULL;
	
	m_imageGiveEMoney = NULL; m_btnGiveEMoneyBg = NULL; m_lbGiveEMoney = NULL;
	
	m_imageFeeMoney = NULL; m_btnFeeMoneyBg = NULL; m_lbFeeMoney = NULL;
	
	m_imageFeeEMoney = NULL; m_btnFeeEMoneyBg = NULL; m_lbFeeEMoney = NULL;
	
	m_iCurInput = eInputNone;
	
	m_tlOperate = NULL;
}

NewMailSendUILayer::~NewMailSendUILayer()
{
	if (m_lbMailContent)
	{
		m_lbMailContent->RemoveFromParent(false);
		SAFE_DELETE(m_lbMailContent);
	}	
}

void NewMailSendUILayer::OnButtonClick(NDUIButton* button)
{
	int op = eInputNone;
	
	if (button == m_btnSend)
	{
		if (!checkEmail()) 
		{
			return;
		}
		
		if (m_input)
			m_input->ShowContentTextField(false);
		
		m_iCurInput = eInputNone;
		
		std::string tip = NDCommonCString("MailFeeTip");
		if (m_lbRecvName)
			tip += m_lbRecvName->GetText();
		NDUIDialog *dlg = new NDUIDialog;
		dlg->Initialization();
		dlg->SetDelegate(this);
		dlg->Show(NDCommonCString("WenXinTip"), tip.c_str(), NDCommonCString("Cancel"),  NDCommonCString("Ok"), NULL);
		
		return;
	}
	else if (button == m_btnRecvName)
	{
		op = eInputRecvName;
	}
	else if (button == m_btnItem)
	{
		std::vector<std::string> vec_str; std::vector<int> vec_id;
		vec_str.push_back(NDCommonCString("wu")); vec_id.push_back(-1);
		VEC_ITEM& items = ItemMgrObj.GetPlayerBagItems();
		for_vec(items, VEC_ITEM_IT)
		{
			Item& item = *(*it);
			int type = Item::getIdRule(item.iItemType, Item::ITEM_TYPE);
			if(item.byBindState == BIND_STATE_BIND)
			{
				continue;
			}
			if (type < 3) 
			{ // 0装备,1宠物,2消耗品
				if (!item.isCanEmail()) {
					continue;
				}
				
				std::string name = item.getItemName();
				std::stringstream tempText;
				tempText << name;
				if (type == 2 && item.iAmount > 1) 
				{
					tempText << " x " << item.iAmount;
				}
				
				vec_str.push_back(tempText.str()); vec_id.push_back(item.iID);
			}
		}
		
		UpdateOperate(vec_str, vec_id);
		
		return;
	}
	else if (button == m_btnItemCount)
	{
		op = eInputItemAmount;
	}
	else if (button == m_btnGiveMoneyBg)
	{
		op = eInputGiveMoney;
	}
	else if (button == m_btnGiveEMoneyBg)
	{
		op = eInputGiveEMoney;
	}
	else if (button == m_btnFeeMoneyBg)
	{
		op = eInputFeeMoney;
	}
	else if (button == m_btnFeeEMoneyBg)
	{
		op = eInputFeeEMoney;
	}
	
	if (op <= eInputNone || op >= eInputEnd) return;
	
	if (!m_input) return;
	
	const char* text = GetTextContent(op);
	
	m_iCurInput = op;
	
	m_input->ShowContentTextField(true, text);
	
	if (m_tlOperate)
		m_tlOperate->SetVisible(false);
}

void NewMailSendUILayer::OnClickNDScrollLayer(NDScrollLayer* layer)
{
	if (layer != m_contentScroll || !m_input) return;
	
	const char* text = GetTextContent(eInputContent);
	
	m_iCurInput = eInputContent;
	
	m_input->ShowContentTextField(true, text);
}

bool NewMailSendUILayer::OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance)
{
	if (uiLayer == m_contentScroll)
		m_contentScroll->OnLayerMove(uiLayer, move, distance);
		
	return false;
}

void NewMailSendUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (chectValid())
		sendEmail();
	
	reset();
	
	dialog->Close();
}

void NewMailSendUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate && m_btnItem && m_lbItemCount)
	{
		int iTag = cell->GetTag();
		std::string content = "";
		std::string amount = "";
		Item* res = NULL;
		if (iTag != -1 && ItemMgrObj.HasItemByType(ITEM_BAG, iTag, res) && res) 
		{
			content = res->getItemName();
			amount = "1";
		}
		m_btnItem->SetTag(iTag);
		m_btnItem->SetTitle(content.c_str());
		m_lbItemCount->SetText(amount.c_str());
		table->SetVisible(false);
	}
}

bool NewMailSendUILayer::SetTextContent(CommonTextInput* input, const char* text)
{
	if (m_input == input)
	{
		if (!SetTextContent(m_iCurInput, text)) 
			return false;
	}
	m_iCurInput = eInputNone;
	return true;
}

void NewMailSendUILayer::Initialization(const char* recvName/*=NULL*/)
{
	NDUILayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picNew = pool.AddPicture(GetImgPathNew("newui_btn.png"));
	
	CGSize sizeNew = picNew->GetSize();
	
	m_btnSend = new NDUIButton;
	
	m_btnSend->Initialization();
	
	m_btnSend->SetFrameRect(CGRectMake(7, 37-sizeNew.height, sizeNew.width, sizeNew.height));
	
	m_btnSend->SetImage(picNew, false, CGRectZero, true);
	
	m_btnSend->SetFontSize(14);
	
	m_btnSend->SetFontColor(ccc4(116, 13, 13, 255));
	
	m_btnSend->SetDelegate(this);
	
	this->AddChild(m_btnSend);
	
	NDPicture *picMail = pool.AddPicture(GetImgPathNew("sendmail_btn.png"));
	
	CGSize sizeMail = picMail->GetSize();
	
	NDUIImage *imageMail = new NDUIImage;
	
	imageMail->Initialization();
	
	imageMail->SetPicture(picMail, true);
	
	imageMail->SetFrameRect(CGRectMake((sizeNew.width-sizeMail.width)/2, (sizeNew.height-sizeMail.height)/2, sizeMail.width, sizeMail.height));
	
	m_btnSend->AddChild(imageMail);
	
	m_input = new CommonTextInput;
	m_input->Initialization();
	m_input->SetDelegate(this);
	this->AddChild(m_input);
	
	//CGRect rect = m_input->GetFrameRect();
	
	//rect.origin.y -= 37;
	
	//m_input->SetFrameRect(rect);
	
	
	int startX = 17;
	// ...
	NDUILabel *lbrecvName = new NDUILabel;
	lbrecvName->Initialization();
	lbrecvName->SetTextAlignment(LabelTextAlignmentLeft);
	lbrecvName->SetFontSize(12);
	lbrecvName->SetFrameRect(CGRectMake(startX, 61, winsize.width, winsize.height));
	lbrecvName->SetFontColor(ccc4(188, 20, 17, 255));
	lbrecvName->SetText(NDCommonCString("reciever"));
	this->AddChild(lbrecvName);
	
	m_btnRecvName = new NDUIMutexStateButton;
	m_btnRecvName->Initialization();
	NDPicture* pic = pool.AddPicture(GetImgPathNew("text_back.png"), 359, 25);
	//m_btnRecvName->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	m_btnRecvName->SetNormalImage(pic, false, CGRectMake(0, 0, 0, 0));
	pic = pool.AddPicture(GetImgPathNew("text_back_focus.png"), 359, 25); 
	m_btnRecvName->SetFocusImage(pic, false, CGRectMake(0, 0, 0, 0));
	m_btnRecvName->SetFrameRect(CGRectMake(80, 55, 359, 25));
	m_btnRecvName->SetDelegate(this);
	this->AddChild(m_btnRecvName);
	
	m_lbRecvName = new NDUILabel;
	m_lbRecvName->Initialization();
	m_lbRecvName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbRecvName->SetFontSize(12);
	m_lbRecvName->SetFrameRect(CGRectMake(2, 6, winsize.width, winsize.height));
	m_lbRecvName->SetFontColor(ccc4(188, 20, 17, 255));
	m_lbRecvName->SetText(recvName == NULL ? "" : recvName);
	m_btnRecvName->AddChild(m_lbRecvName);
	
	NDUILabel *mailContent = new NDUILabel;
	mailContent->Initialization();
	mailContent->SetTextAlignment(LabelTextAlignmentLeft);
	mailContent->SetFontSize(12);
	mailContent->SetFrameRect(CGRectMake(startX, 92, winsize.width, winsize.height));
	mailContent->SetFontColor(ccc4(188, 20, 17, 255));
	mailContent->SetText(NDCommonCString("MailContent"));
	this->AddChild(mailContent);

	m_contentScroll = new NDUIContainerScrollLayer;
	m_contentScroll->Initialization();
	m_contentScroll->SetBackgroundImage(pool.AddPicture(GetImgPathNew("text_back.png"), 423, 124), true);
	m_contentScroll->SetBackgroundFocusImage(pool.AddPicture(GetImgPathNew("text_back_focus.png"), 423, 124), true);
	m_contentScroll->SetFrameRect(CGRectMake(startX, 111, 423, 124)); // CGRectMake(2, 3, 423-4, 124-6)
	m_contentScroll->SetDelegate(this);
	this->AddChild(m_contentScroll, -5);
	
	NDUILabel *attach = new NDUILabel;
	attach->Initialization();
	attach->SetTextAlignment(LabelTextAlignmentLeft);
	attach->SetFontSize(12);
	attach->SetFrameRect(CGRectMake(startX, 246, winsize.width, winsize.height));
	attach->SetFontColor(ccc4(188, 20, 17, 255));
	attach->SetText(NDCommonCString("AttachMaoHao"));
	this->AddChild(attach);
	
	m_btnItem = new NDUIButton;
	m_btnItem->Initialization();
	m_btnItem->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnItem->SetFontSize(12);
	m_btnItem->CloseFrame();
	m_btnItem->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png"), 298, 0),
							  pool.AddPicture(GetImgPathNew("bag_btn_click.png"), 298, 0),
							  false, CGRectZero, true);
	m_btnItem->SetFrameRect(CGRectMake(61, 242, 298, 24));
	m_btnItem->SetDelegate(this);							 
	this->AddChild(m_btnItem);
	
	NDUILabel *multiply = new NDUILabel;
	multiply->Initialization();
	multiply->SetTextAlignment(LabelTextAlignmentLeft);
	multiply->SetFontSize(12);
	multiply->SetFrameRect(CGRectMake(364, 249, winsize.width, winsize.height));
	multiply->SetFontColor(ccc4(188, 20, 17, 255));
	multiply->SetText("X");
	this->AddChild(multiply);
	
	
	m_btnItemCount = new NDUIMutexStateButton;
	m_btnItemCount->Initialization();
	pic = pool.AddPicture(GetImgPathNew("text_back.png"), 60, 20);
	//m_btnItemCount->SetImage(pic, false, CGRectMake(0, 0, 0, 0), true);
	m_btnItemCount->SetNormalImage(pic, false, CGRectMake(0, 0, 0, 0));
	pic = pool.AddPicture(GetImgPathNew("text_back_focus.png"), 60, 20); 
	m_btnItemCount->SetFocusImage(pic, false, CGRectMake(0, 0, 0, 0));
	m_btnItemCount->SetFrameRect(CGRectMake(376, 243, 60, 20));
	m_btnItemCount->SetDelegate(this);
	this->AddChild(m_btnItemCount);
	
	m_lbItemCount = new NDUILabel;
	m_lbItemCount->Initialization();
	m_lbItemCount->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbItemCount->SetFontSize(12);
	m_lbItemCount->SetFrameRect(CGRectMake(2, 4, winsize.width, winsize.height));
	m_lbItemCount->SetFontColor(ccc4(188, 20, 17, 255));
	m_btnItemCount->AddChild(m_lbItemCount);
	
	m_lbGive = new NDUILabel;
	m_lbGive->Initialization();
	m_lbGive->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbGive->SetFontSize(12);
	m_lbGive->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbGive);
	
	m_lbFee = new NDUILabel;
	m_lbFee->Initialization();
	m_lbFee->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbFee->SetFontSize(12);
	m_lbFee->SetFontColor(ccc4(188, 20, 17, 255));
	this->AddChild(m_lbFee);
	
	InitMoney(false, m_imageGiveMoney, m_btnGiveMoneyBg, m_lbGiveMoney);
	
	InitMoney(true, m_imageGiveEMoney, m_btnGiveEMoneyBg, m_lbGiveEMoney);
	
	InitMoney(false, m_imageFeeMoney, m_btnFeeMoneyBg, m_lbFeeMoney);
	
	InitMoney(true, m_imageFeeEMoney, m_btnFeeEMoneyBg, m_lbFeeEMoney);
	
	int startY = 269, width = winsize.width, height = winsize.height;
	
	{
		setLabelAndFrame(m_lbGive, NDCommonCString("ZhengSong"), CGRectMake(startX, startY+3, width, height));
		
		int x = startX + 32;
		
		{
			SetMoney(m_imageGiveMoney, m_btnGiveMoneyBg, m_lbGiveMoney, 0, x, startY);
			
			x += 18 + 62 + 12;
		}
		
		
		SetMoney(m_imageGiveEMoney, m_btnGiveEMoneyBg, m_lbGiveEMoney, 0, x, startY);
		
		startY += 20;
	}
	

	{
		setLabelAndFrame(m_lbFee, NDCommonCString("ShouFei"), CGRectMake(startX, startY+3, width, height));
		
		int x = startX + 32;
		
		{
			SetMoney(m_imageFeeMoney, m_btnFeeMoneyBg, m_lbFeeMoney, 0, x, startY);
			
			x += 18 + 62 + 12;
		}
		
		
		SetMoney(m_imageFeeEMoney, m_btnFeeEMoneyBg, m_lbFeeEMoney, 0, x, startY);
	}
	
	SetMailContent("");
	
	NDUITopLayerEx *layerOperate = new NDUITopLayerEx;
	layerOperate->Initialization();
	layerOperate->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(layerOperate, 1);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->SetDelegate(this);
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetVisible(false);
	m_tlOperate->SetBackgroundColor(ccc4(255, 221, 114, 255));
	layerOperate->AddChild(m_tlOperate);
}

void NewMailSendUILayer::SetMailContent(const char *text, ccColor4B color/*=ccc4(255, 0, 0, 255)*/, unsigned int fontsize/*=12*/)
{
	if (!m_contentScroll) return;
	
	m_contentScroll->RemoveAllChildren(true);
	
	if (!text) return;
	
	CGSize size = getStringSizeMutiLine(text, 12, CGSizeMake(m_contentScroll->GetFrameRect().size.width-4, 320));
	
	m_lbMailContent = new NDUILabel;
	m_lbMailContent->Initialization();
	m_lbMailContent->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbMailContent->SetFontSize(fontsize);
	m_lbMailContent->SetFrameRect(CGRectMake(2, 3, size.width, size.height));
	m_lbMailContent->SetFontColor(color);
	m_lbMailContent->SetText(text);
	
	if (m_lbMailContent->GetParent() == NULL)
		m_contentScroll->AddChild(m_lbMailContent);
	
	m_contentScroll->refreshContainer();
}

void NewMailSendUILayer::InitMoney(bool emoney, NDUIImage *& imageMoney, NDUIButton*& btnMoneyBG, NDUILabel*& lbMoney)
{
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picMoney = pool.AddPicture(GetImgPath(emoney ? "emoney.png" : "money.png" )); // 16X16
	
	NDPicture *picMoneyBG = pool.AddPicture(GetImgPathNew("money_input.png"), 62, 0); // 62X18
	
	imageMoney = new NDUIImage;
	imageMoney->Initialization();
	imageMoney->SetPicture(picMoney, true);
	this->AddChild(imageMoney);
	
	btnMoneyBG = new NDUIButton;
	btnMoneyBG->Initialization();
	btnMoneyBG->SetImage(picMoneyBG, false, CGRectZero, true);
	btnMoneyBG->SetDelegate(this);
	this->AddChild(btnMoneyBG);
	
	lbMoney = new NDUILabel;
	lbMoney->Initialization();
	lbMoney->SetTextAlignment(LabelTextAlignmentLeft);
	lbMoney->SetFontSize(12);
	lbMoney->SetFontColor(ccc4(255, 248, 198, 255));
	btnMoneyBG->AddChild(lbMoney);
}

void NewMailSendUILayer::setLabel(NDUILabel*& lb, const char* text)
{
	if (lb && text)
	{
		lb->SetText(text);
		lb->SetVisible(true);
	}
}

void NewMailSendUILayer::setLabelAndFrame(NDUILabel*& lb, const char* text, CGRect rect)
{
	if (lb)
		lb->SetFrameRect(rect);
	setLabel(lb, text);
}

void NewMailSendUILayer::setBtn(NDUIButton*& btn, CGRect rect)
{
	if (btn)
	{
		btn->SetFrameRect(rect);
		btn->SetVisible(true);
	}
}

void NewMailSendUILayer::setImage(NDUIImage*& image, CGRect rect)
{
	if (image)
	{
		image->SetFrameRect(rect);
		image->SetVisible(true);
	}
}

void NewMailSendUILayer::SetMoney(NDUIImage*& image, NDUIButton*& btnBG, NDUILabel*& lb, int value, int startX, int startY)
{
	int width = 480, height = 320;
	
	setImage(image, CGRectMake(startX, startY+2, 16, 16));
	
	startX += 18;
	
	setBtn(btnBG, CGRectMake(startX, startY, 62, 18));
	
	std::stringstream ss; ss << value;
	
	setLabelAndFrame(lb, (value == 0 ? "" : ss.str().c_str()), CGRectMake(2, 3, width, height));
}

bool NewMailSendUILayer::SetTextContent(int textType , const char* text)
{
	if (textType <= eInputNone || textType >= eInputEnd) return true;
	
	if (!text) return true;
	
	switch (textType) {
		case eInputRecvName:
		{
			if (std::string(text).size() > 15) 
			{
				ShowAlert(NDCommonCString("RecvNameLenLong"));
				return false;
			}
			
			if (!m_lbRecvName) return true;
			
			m_lbRecvName->SetText(text);
			
		}
			break;
		case eInputContent:
		{
			
			if (std::string(text).size() > 220) 
			{
				ShowAlert(NDCommonCString("ContentLen110"));
				return false;
			}
			
			SetMailContent(text);
		}
			break;
		case eInputItemAmount:
		{
			if (text && !(VerifyUnsignedNum(text)))
			{
				ShowAlert(NDCommonCString("NumberRequireTip"));
				return false;
			}
			
			if (!m_btnItem || !m_lbItemCount) return true;
			
			Item* res = NULL;
			int iItemID = m_btnItem->GetTag();
			if (iItemID == -1 || !ItemMgrObj.HasItemByType(ITEM_BAG, iItemID, res) || !res) 
			{
				return true;
			}
			
			int iAmount = atoi(text);
			
			if (iAmount <= 0) 
			{
				ShowAlert(NDCommonCString("FailAmount"));
				return false;
			}
			
			if (res->isEquip()) 
			{ // 表示装备
				if (iAmount != 1) 
				{
					ShowAlert(NDCommonCString("FailEquipAmount"));
					return false;
				} 
				else 
				{
					if (m_lbItemCount)
						m_lbItemCount->SetText(text);
				}
			} 
			else 
			{
				if (iAmount > res->iAmount) 
				{
					std::stringstream ss; ss << NDCommonCString("BagItemAmountTip") << res->iAmount << NDCommonCString("BagItemAmountTip2");
					ShowAlert(ss.str().c_str());
					return false;
				} 
				else 
				{
					if (m_lbItemCount)
						m_lbItemCount->SetText(text);
				}
			}
		}
			break;
		case eInputGiveMoney:
		{
			if (text && !(VerifyUnsignedNum(text)))
			{
				ShowAlert(NDCommonCString("NumberRequireTip"));
				return false;
			}
			
			if (!m_lbGiveMoney) return true;
			
			int iAmount = atoi(text);
			if (iAmount < 0) 
			{
				ShowAlert(NDCommonCString("FailSontMoney"));
				return false;
			}
			
			if (iAmount > NDPlayer::defaultHero().money) 
			{
				std::stringstream ss; ss << NDCommonCString("BagMoneyAmountTip") << NDPlayer::defaultHero().money << NDCommonCString("BagMoneyAmountTip2");
				ShowAlert(ss.str().c_str());
				return false;
			}
			
			if (m_lbGiveMoney)
				m_lbGiveMoney->SetText(iAmount == 0 ? "" : text);
		}
			break;
		case eInputGiveEMoney:
		{
			if (text && !(VerifyUnsignedNum(text)))
			{
				ShowAlert(NDCommonCString("NumberRequireTip"));
				return false;
			}
			
			if (!m_lbGiveEMoney) return true;
			
			int iAmount = atoi(text);
			if (iAmount < 0) 
			{
				ShowAlert(NDCommonCString("FailSontEMoney"));
				return false;
			}
			
			if (iAmount > NDPlayer::defaultHero().eMoney) 
			{
				std::stringstream ss; ss << NDCommonCString("BagEMoneyAmountTip") << NDPlayer::defaultHero().eMoney << NDCommonCString("BagMoneyAmountTip2");
				ShowAlert(ss.str().c_str());
				return false;
			}
			
			if (m_lbGiveEMoney)
				m_lbGiveEMoney->SetText(iAmount == 0 ? "" : text);
		}
			break;
		case eInputFeeMoney:
		case eInputFeeEMoney:
		{
			if (text && !(VerifyUnsignedNum(text)))
			{
				ShowAlert(NDCommonCString("NumberRequireTip"));
				return false;
			}
			
			int iAmount = atoi(text);
			if (iAmount < 0) 
			{
				ShowAlert(NDCommonCString("FailFeeMoney"));
				return false;
			}
			
			if (textType == eInputFeeMoney && !m_lbFeeMoney) return true;
			
			if (textType == eInputFeeEMoney && !m_lbFeeEMoney) return true;
			
			if (textType == eInputFeeMoney)
				m_lbFeeMoney->SetText(text);
				
			if (textType == eInputFeeEMoney)
				m_lbFeeEMoney->SetText(text);
		}
			break;
		default:
			break;
	}
	
	return true;
}

const char* NewMailSendUILayer::GetTextContent(int textType)
{
	if (textType <= eInputNone || textType >= eInputEnd) return NULL;
	
	switch (textType) {
		case eInputRecvName:
		{
			
			if (!m_lbRecvName) return NULL;
			
			return m_lbRecvName->GetText().c_str();
		}
			break;
		case eInputContent:
		{
			if (!m_lbMailContent) return NULL;
			
			return m_lbMailContent->GetText().c_str();
		}
			break;
		case eInputItemAmount:
		{
			if (!m_lbItemCount) return NULL;
			
			return m_lbItemCount->GetText().c_str();
		}
			break;
		case eInputGiveMoney:
		{
			if (!m_lbGiveMoney) return NULL;
			
			return m_lbGiveMoney->GetText().c_str();
		}
			break;
		case eInputGiveEMoney:
		{
			if (!m_lbGiveEMoney) return NULL;
			
			return m_lbGiveEMoney->GetText().c_str();
		}
			break;
		case eInputFeeMoney:
		{
			if (!m_lbFeeMoney) return NULL;
			
			return m_lbFeeMoney->GetText().c_str();
		}
			break;
		case eInputFeeEMoney:
		{
			if (!m_lbFeeEMoney) return NULL;
			
			return m_lbFeeEMoney->GetText().c_str();
		}
			break;
		default:
			break;
	}
	
	return NULL;
}

void NewMailSendUILayer::ShowAlert(const char* pszAlert)
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NDCommonCString_RETNS("tip") message:[NSString stringWithUTF8String:pszAlert] delegate:nil cancelButtonTitle:NDCommonCString_RETNS("haode") otherButtonTitles:nil];
	[alert show];
	[alert release];
}

bool NewMailSendUILayer::checkEmail()
{
	std::string recvname = "", content = "", itemname = "", itemcount = "", paymoney = "", payemoney = "";
	if (m_lbRecvName) 
	{
		recvname = m_lbRecvName->GetText();
	}
	
	if (m_lbMailContent) 
	{
		content = m_lbMailContent->GetText();
	}
	
	if (m_btnItem && m_btnItem->GetTag() > 0 && m_btnItem->GetTitle() != "") 
	{
		Item* res = NULL;
		int iItemID = m_btnItem->GetTag();
		if (iItemID == -1 || !ItemMgrObj.HasItemByType(ITEM_BAG, iItemID, res) || !res) 
		{
			return false;
		}
		itemname = m_btnItem->GetTitle();
	}
	
	if (m_lbItemCount) 
	{
		itemcount = m_lbItemCount->GetText();
	}
	
	if (m_lbFeeMoney) 
	{
		paymoney = m_lbFeeMoney->GetText();
	}
	
	if (m_lbFeeEMoney) 
	{
		payemoney = m_lbFeeEMoney->GetText();
	}
	
	if (recvname.empty()) {
		showDialog(NDCommonCString("fail"), NDCommonCString("NotEmptyRecvName"));
		return false;
	} 
	else if (content.empty()) {
		showDialog(NDCommonCString("fail"), NDCommonCString("NotEmptyMailContent"));
		return false;
	} 
	else if (!itemname.empty() && itemcount.empty()) 
	{
		showDialog(NDCommonCString("fail"), NDCommonCString("NotEmptyAttachAmount"));
		return false;
	} 
	else if (itemname.empty()) 
	{
		if ((!paymoney.empty() && atoi(paymoney.c_str()) > 0) || (!payemoney.empty() && atoi(payemoney.c_str()) > 0)) 
		{
			showDialog(NDCommonCString("fail"), NDCommonCString("NotEmptyFeeNotAttach"));
			return false;
		}
	}
	return true;
}

void NewMailSendUILayer::sendEmail()
{
	NDTransData bao(_MSG_SENDLETTER);
	
	int btAttachState = EmailData::ATTACH_NO;
	std::string text1 = m_btnItem->GetTitle();
	int iAmount = atoi(m_lbItemCount->GetText().c_str());
	if (!text1.empty() && iAmount > 0) {
		btAttachState |= EmailData::ATTACH_ITEM_ID; // 附件含 item
	}
	
	text1 = m_lbGiveMoney->GetText();
	int iGiveMoney = atoi(text1.c_str());
	if (!text1.empty() && iGiveMoney > 0) {
		btAttachState |= EmailData::ATTACH_MONEY; // 附件含 attach_money
	}
	
	text1 = m_lbGiveEMoney->GetText();
	int iGiveEmoney = atoi(text1.c_str());
	if (!text1.empty() && iGiveEmoney > 0) {
		btAttachState |= EmailData::ATTACH_EMONEY; // 附件含 attach_emoney
	}
	
	text1 = m_lbFeeMoney->GetText();
	int iPayMoney = atoi(text1.c_str());
	if (!text1.empty() && iPayMoney > 0) {
		btAttachState |= EmailData::ATTACH_REQUIRE_MONEY; // 附件含
		// require_money
	}
	
	text1 = m_lbFeeMoney->GetText();
	int iPayEmoney = atoi(text1.c_str());
	if (!text1.empty() && iPayEmoney > 0) {
		btAttachState |= EmailData::ATTACH_REQUIRE_EMONEY; // 附件含
		// require_emoney
	}
	
	bao << (unsigned char)btAttachState;
	
	text1 = m_btnItem->GetTitle();
	if (!text1.empty() && iAmount > 0) 
	{
		bao << int(m_btnItem->GetTag()) << (unsigned short)iAmount; // 附件含
	}
	
	if (iGiveMoney > 0) {
		bao << iGiveMoney; // 附件含 attach_money
	}
	
	if (iGiveEmoney > 0) {
		bao << iGiveEmoney; // 附件含 attach_emoney
	}
	
	if (iPayMoney > 0) {
		bao << iPayMoney; // 附件含 require_money
	}
	
	if (iPayEmoney > 0) {
		bao << iPayEmoney; // 附件含 require_emoney
	}
	
	//bao.write(0);// btCharSet
	//	byte[] data = T.stringToBytes(receiveEdit.getText(), 1);
	//	bao.writeShort(data.length);
	//	bao.write(data);
	//	
	//	bao.write(0);// btCharSet
	//	data = T.stringToBytes(contentBox.getText(), 1);
	//	bao.writeShort(data.length);
	//	bao.write(data);
	
	bao.WriteUnicodeString(m_lbRecvName->GetText());
	bao.WriteUnicodeString(m_lbMailContent->GetText());
	
	SEND_DATA(bao);
}

bool NewMailSendUILayer::chectValid()
{
	if (!m_lbRecvName || !m_lbMailContent || !m_btnItem
		|| !m_lbItemCount || !m_lbGiveMoney || !m_lbGiveEMoney
		|| !m_lbFeeMoney || !m_lbFeeEMoney)
		return false;
		
	return true;
}

void NewMailSendUILayer::reset()
{
	if (m_lbRecvName)
		m_lbRecvName->SetText("");
		
	if (m_lbMailContent)
		m_lbMailContent->SetText("");
		
	if (m_btnItem)
	{
		m_btnItem->SetTitle("");
		m_btnItem->SetTag(0);
	}
		
	if (m_lbItemCount)
		m_lbItemCount->SetText("");
		
	if (m_lbGiveMoney)
		m_lbGiveMoney->SetText("");
	
	if (m_lbGiveEMoney)
		m_lbGiveEMoney->SetText("");
		
	if (m_lbFeeMoney)
		m_lbFeeMoney->SetText("");
		
	if (m_lbFeeEMoney)
		m_lbFeeEMoney->SetText("");
}

void NewMailSendUILayer::UpdateOperate(std::vector<std::string> vec_str, std::vector<int> vec_id)
{
	if (!m_tlOperate || vec_str.empty() || vec_str.size() != vec_id.size()) 
	{
		return;
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDSection *section = new NDSection;
	NDDataSource * dataSource = new NDDataSource;
	section->Clear();
	//section->UseCellHeight(true);
	int iSize = vec_str.size();
	for (int i = 0; i < iSize; i++) 
	{
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(vec_str[i].c_str());
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		btn->SetTag(vec_id[i]);
		section->AddCell(btn);
	}
	
	dataSource->AddSection(section);
	
	int iHeight = iSize > 6 ? 180 : iSize*30;//+iSize+1;
	
	CGRect rect = CGRectMake((winsize.width-120)/2, (winsize.height-iHeight)/2, 120, iHeight);
	
	if (m_btnItem)
	{
		CGRect itemFrame = m_btnItem->GetFrameRect();
		
		rect.size.width = itemFrame.size.width;
		
		rect.origin = ccpAdd(ccp(0, -iHeight), itemFrame.origin);
	}
	
	m_tlOperate->SetFrameRect(rect);
	m_tlOperate->SetVisible(true);
	m_tlOperate->VisibleScrollBar(iHeight > 240);
	
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


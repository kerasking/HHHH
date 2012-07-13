/*
 *  NewMail.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_MAIL_H_
#define _NEW_MAIL_H_

#include "NDUILabel.h"
#include "NDUILayer.h"
#include "NDUIImage.h"
#include "NDUIButton.h"
#include "EmailData.h"
#include "NDUITableLayer.h"
#include "NDScrollLayer.h"
#include "NDCommonControl.h"
#include "NDUIDialog.h"
#include "NDUIEdit.h"
#include "NDUIDefaultButton.h"

#pragma mark 收件箱

class MailInfo : 
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(MailInfo)
	
	MailInfo();
	
	~MailInfo();
	
public:
	
	void Initialization(CGPoint pos); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void ChangeMail(EmailData* data);
	
	EmailData* GetMail() { return m_emailData; } 
private:
	void SetText(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	void InitMoney(bool emoney, NDUIImage *& imageMoney, NDUIImage*& imageMoneyBG, NDUILabel*& lbMoney);
	void reset();
	void resetLabel(NDUILabel*& lb);
	void resetImage(NDUIImage*& image);
	void resetOperate();
	void SetVisible(bool visible); override
	void setLabel(NDUILabel*& lb, const char* text);
	void setLabelAndFrame(NDUILabel*& lb, const char* text, CGRect rect);
	void setImage(NDUIImage*& image, CGRect rect);
	void SetMoney(NDUIImage*& image, NDUIImage*& imageBG, NDUILabel*& lb, int value, int startX, int startY);
	void refreshOperate();
	
	void checkPayItem(EmailData& curEmail);
	void sendAcceptMsg(EmailData& curEmail);
	
	void HideAttach();
private:
	EmailData* m_emailData;
	
	NDUIContainerScrollLayer *m_layerScroll;
	
	std::vector<NDUIButton*> m_vOpBtn;
	
	NDUILabel *m_lbSend, *m_lbDate;
	
	NDUILabel *m_lbAttach;
	
	NDUILabel *m_lbGive, *m_lbFee;
	
	NDUIImage *m_imageGiveMoney; NDUIImage *m_imageGiveMoneyBg; NDUILabel *m_lbGiveMoney;
	
	NDUIImage *m_imageGiveEMoney; NDUIImage *m_imageGiveEMoneyBg; NDUILabel *m_lbGiveEMoney;
	
	NDUIImage *m_imageFeeMoney; NDUIImage *m_imageFeeMoneyBg; NDUILabel *m_lbFeeMoney;
	
	NDUIImage *m_imageFeeEMoney; NDUIImage *m_imageFeeEMoneyBg; NDUILabel *m_lbFeeEMoney;
};

class NDMailCell : public NDPropCell
{
	DECLARE_CLASS(NDMailCell)
	
	NDMailCell();
	
	~NDMailCell();
	
public:
	void Initialization(); hide
	
	void draw(); override
	
	void ChangeMail(EmailData* data);
	
	EmailData* GetMail();
private:
	
	NDPicture *m_picNotRead, *m_picHadRead;
	
	EmailData* m_emailData;
};

class NewMailUILayer :
public NDUILayer,
public NDUITableLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NewMailUILayer)
	
public:
	static void refresh();
private:
	static NewMailUILayer* s_instance;
	
public:
	NewMailUILayer();
	~NewMailUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button); override
	void Initialization();
	void SetVisible(bool visible); override
	void refreshMainList();
private:
	NDUITableLayer* m_tlMail;
	
	MailInfo* m_infoMail;
	
	NDUIButton *m_btnNewMail;
};

#pragma mark 发邮件

class NewMailSendUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUILayerDelegate,
public NDScrollLayerDelegate,
public NDUIDialogDelegate,
public NDUITableLayerDelegate,
public CommonTextInputDelegate
{
	DECLARE_CLASS(NewMailSendUILayer)
	
public:
	NewMailSendUILayer();
	~NewMailSendUILayer();
	
	void OnButtonClick(NDUIButton* button); override
	void OnClickNDScrollLayer(NDScrollLayer* layer); override
	void Initialization(const char* recvName=NULL); override
	bool OnLayerMove(NDUILayer* uiLayer, UILayerMove move, float distance); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool SetTextContent(CommonTextInput* input, const char* text);
private:
	void SetMailContent(const char *text, ccColor4B color=ccc4(255, 0, 0, 255), unsigned int fontsize=12);
	void InitMoney(bool emoney, NDUIImage *& imageMoney, NDUIButton*& btnMoneyBG, NDUILabel*& lbMoney);
	void setLabel(NDUILabel*& lb, const char* text);
	void setLabelAndFrame(NDUILabel*& lb, const char* text, CGRect rect);
	void setBtn(NDUIButton*& btn, CGRect rect);
	void setImage(NDUIImage*& image, CGRect rect);
	void SetMoney(NDUIImage*& image, NDUIButton*& btnBG, NDUILabel*& lb, int value, int startX, int startY);
	bool SetTextContent(int textType , const char* text);
	
	const char* GetTextContent(int textType);
	void ShowAlert(const char* pszAlert);
	bool checkEmail();
	void sendEmail();
	bool chectValid();
	void reset();
	
	void UpdateOperate(std::vector<std::string> vec_str, std::vector<int> vec_id);
private:
	NDUIButton *m_btnSend;
	
	CommonTextInput *m_input;
	
	// ...
	NDUILabel	*m_lbRecvName; NDUIMutexStateButton *m_btnRecvName; 
	
	NDUIContainerScrollLayer	*m_contentScroll; NDUILabel* m_lbMailContent;
	
	NDUIButton	*m_btnItem;	NDUIMutexStateButton *m_btnItemCount; NDUILabel	*m_lbItemCount;
	
	NDUILabel *m_lbGive, *m_lbFee;
	
	NDUIImage *m_imageGiveMoney; NDUIButton *m_btnGiveMoneyBg; NDUILabel *m_lbGiveMoney;
	
	NDUIImage *m_imageGiveEMoney; NDUIButton *m_btnGiveEMoneyBg; NDUILabel *m_lbGiveEMoney;
	
	NDUIImage *m_imageFeeMoney; NDUIButton *m_btnFeeMoneyBg; NDUILabel *m_lbFeeMoney;
	
	NDUIImage *m_imageFeeEMoney; NDUIButton *m_btnFeeEMoneyBg; NDUILabel *m_lbFeeEMoney;
	
	// ...
	enum { eInputNone, eInputRecvName, eInputContent, eInputItemAmount, eInputGiveMoney, eInputGiveEMoney, eInputFeeMoney, eInputFeeEMoney, eInputEnd, };
	int m_iCurInput;
	
	NDUITableLayer *m_tlOperate;
};

#endif // _NEW_MAIL_H_
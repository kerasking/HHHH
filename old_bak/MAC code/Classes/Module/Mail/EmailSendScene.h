/*
 *  EmailSendScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _EMAIL_SEND_SCENE_H_
#define _EMAIL_SEND_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"
#include "NDUIDialog.h"
#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDUIMemo.h"
#include "NDUIBaseGraphics.h"
#include <string>

using namespace NDEngine;

class EmailEdit;

class EmailEditDelegate
{
public:
	virtual void OnEmailEditClick(EmailEdit* edit) {}
};

class EmailEdit : public NDUILayer
{
	DECLARE_CLASS(EmailEdit)
	
public:
	EmailEdit();
	~EmailEdit();
	
	void Initialization(bool bMemo = false); override
	void draw(); override
	bool TouchBegin(NDTouch* touch); override
	
	void SetText(std::string text);
	std::string GetText();
	
	void SetFontColor(ccColor4B color);
	void SetFontSize(unsigned int uisize);
	
	void SetTextAlignment(LabelTextAlignment alignment);
private:
	NDUILabel *m_lbText;
	NDUIMemo  *m_memoText;
	NDUICircleRect *m_crBG;
	bool	m_bMemo;
};

/////////////////////////////////
class  EmailSendScene :
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate,
public NDUIDialogDelegate,
public EmailEditDelegate
{
	DECLARE_CLASS( EmailSendScene)
public:
	EmailSendScene();
	~EmailSendScene();
	
	static EmailSendScene* Scene(std::string recvname);
	static EmailSendScene* Scene();
	void Initialization(std::string recvname); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnDialogClose(NDUIDialog* dialog); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnEmailEditClick(EmailEdit* edit); override
	
	static void UpdateReciever(std::string recvname);
private:
	void InitText(CGPoint pos, std::string str);
	void InitEdit(int index, CGRect rect, bool bMemo, int alignment=LabelTextAlignmentLeft);
	void ShowCustomView(int iTag, std::string tip);
	void UpdateOperate(std::vector<std::string> vec_str, std::vector<int> vec_id);
	bool checkEmail();
	void sendEmail();
	void resetAllEdits();
private:
	enum
	{ 
		eBegin = 0,
		eRecvName = eBegin, eContent, eAttachItem, eAttachAmount, eGiveEmoney, eGiveMoney, ePayEmoney, ePayMoney, 
		eEnd,
	};
	NDUIMenuLayer *m_menulayerBG;
	NDUIImage *m_imageMoney[2], *m_imageEMoney[2];
	NDPicture *m_picMoney[2], *m_picEMoney[2];
	EmailEdit *m_edit[eEnd];
	NDUIButton *m_btnFriend;
	NDUITableLayer *m_tlOperate;
	static EmailSendScene* s_instance;
	std::string customViewTip[eEnd];
};


#endif // _EMAIL_SEND_SCENE_H_

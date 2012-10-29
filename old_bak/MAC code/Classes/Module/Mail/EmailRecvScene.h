/*
 *  EmailRecvScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _EMAIL_RECV_SCENE_H_
#define _EMAIL_RECV_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDPicture.h"
#include "EmailData.h"

using namespace NDEngine;

enum
{
	LETTER_LOOK = 0, // 查看邮件
	LETTER_ATTACH_ACCEPT = 1, // 接收附件
	LETTER_ATTACH_REJECT = 2, // 拒收附件
	LETTER_DEL = 3,
};

class EmailRecvScene : 
public NDScene, 
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(EmailRecvScene)
public:
	EmailRecvScene();
	~EmailRecvScene();

	void Initialization(EmailData* data); hide
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	NDUILabel * InitText(CGRect rect, std::string str, NDUINode* pnode);
	void InitEdit(CGRect rect, std::string str, NDUINode* pnode);
	void InitButton(CGRect rect, std::string str, NDUINode* pnode);
	void InitImage(CGRect rect, NDPicture *pic, NDUINode* pnode);
	
	void checkPayItem(EmailData& curEmail);
	void sendAcceptMsg(EmailData& curEmail);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUITableLayer *m_tlOperate;
	NDPicture *m_picMoney[2], *m_picEMoney[2];
	NDPicture *m_picTitle;
	int m_iMailID;
};

class SocialElement;

class GameMailsScene : 
public NDScene,
public NDUITableLayerDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(GameMailsScene)
public:
	GameMailsScene();
	~GameMailsScene();
	void Initialization(); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnButtonClick(NDUIButton* button); override
private:
	void UpdateGui();
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlOperate;
	NDUITableLayer *m_tlMain;
	int	m_iOperateMailID;
public:
	static void UpdateMail();
	static void UpddateMailInfo();
private:
	static GameMailsScene *s_MailsInstance;
};

#endif // _EMAIL_RECV_SCENE_H_
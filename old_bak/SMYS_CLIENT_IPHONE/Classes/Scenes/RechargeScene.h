/*
 *  RechargeScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _RECHARGE_SCENE_H_
#define _RECHARGE_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"
#include "NDUIDialog.h"
#include "NDPicture.h"
#include "SocialElement.h"

using namespace NDEngine;

struct RechargeData 
{
	int textPadding;
	std::string title;
	std::vector<RechargeData> children;
	RechargeData(){ textPadding = 0; };
};

class RechargeButton : public NDUIButton
{
	DECLARE_CLASS(RechargeButton);
public:
	RechargeButton();
	~RechargeButton();
	void Initialization();
	void AddChildRechargeButton(RechargeButton* btn);
	
	bool GenTBList(NDUITableLayer* tl);
private:
	void ClearChildlist();
public:
	int textPadding;
	std::vector<RechargeData> children;
	//std::vector<RechargeButton*> m_childlist;
};

class RechargeScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(RechargeScene)
public:
	RechargeScene();
	~RechargeScene();
	
	static RechargeScene* Scene();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnCustomViewConfirm(NDUICustomView* customView);override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void dealRecharge();
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	int GetPageNum();
	void UpdatePage();
	void UpdateMainUI();
	void recharge(int askForRecharge);
	void showRechargeForm(); // 充值卡充值
	void showRechargeSMS(); // 短信充值
	void openEnquire();
	void sendRecharge();
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlMain, *m_tlOperate;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	int m_iCurPage;
	int m_iTotalPage;
	//RechargeButton *m_btnOperate;
	int askForRecharge; 
	std::string sendCardNum;
	std::string sendCardPassWord;
public:
	static std::vector<RechargeData> datas;
	static std::string rechargeInfoTitle;
	static std::string rechargeInfo;
};

class ReChargelistScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(ReChargelistScene)
public:
	ReChargelistScene();
	~ReChargelistScene();
	
	void Initialization(VEC_SOCIAL_ELEMENT& elements); hide
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
private:
	void ClearSocialElements();
	void UpdateMainUI();
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle, *m_lbSubTitle[2];
	NDUITableLayer *m_tlMain;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage; 
	NDPicture *m_picEMoney;
	int m_iCurPage;
	int m_iTotalPage;
	VEC_SOCIAL_ELEMENT m_vecElement;
};


#endif // _RECHARGE_SCENE_H_

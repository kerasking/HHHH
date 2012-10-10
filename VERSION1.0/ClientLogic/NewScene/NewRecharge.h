/*
 *  NewRecharge.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-9.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_RECHARGE_H_
#define _NEW_RECHARGE_H_

#include <vector>
#include "NDUILayer.h"
#include "NDScrollLayer.h"
#include "NDUILabel.h"
#include "NDCommonControl.h"
#include "NDTextNode.h"
#include "NDUIBaseGraphics.h"
#include "NDUIDialog.h"
#include "GlobalDialog.h"
#include "NDCommonScene.h"

#pragma mark　充值-数据

enum  
{
	RechargeData_None							= 0,
	RechargeData_MainType						= 1,	// 主类型(eg　神州行)
	RechargeData_Tip							= 2,	// 注意事项
	RechargeData_Card							= 3,	// 子类型卡(eg 50元,100元..)
	RechargeData_Message						= 4,	// 子类型短信(eg 2元,5元..)	
};

typedef struct _tagNewRechargeSubData
{
	int iId;
	int iDataType;
	std::string text;
	_tagNewRechargeSubData(int iId, int iDataType, std::string text)
	{
		this->iId = iId;
		this->iDataType = iDataType;
		this->text = text;
	}
	_tagNewRechargeSubData()
	{
		this->iId = 0;
		this->iDataType = RechargeData_None;
		text = "";
	}
}NewRechargeSubData;

typedef std::vector<NewRechargeSubData>		vec_recharge_subdata;
typedef vec_recharge_subdata::iterator		vec_recharge_subdata_it;

typedef struct _tagNewRechargeData
{
	NewRechargeSubData mainData;
	NewRechargeSubData tipData;
	vec_recharge_subdata vSubData;
	std::string tip;
}NewRechargeData;

typedef std::vector<NewRechargeData>	vec_recharge_data;
typedef vec_recharge_data::iterator		vec_recharge_data_it;

#pragma mark 充值信息基类

class RechargeInfoBase :
public NDUILayer
{
	DECLARE_CLASS(RechargeInfoBase)

public:
	RechargeInfoBase();
	
	~RechargeInfoBase();
	
	void Initialization(CGPoint point); override
	
	void SetTitle(const char* title);
	
	void SetInfo(const char* info);
	
	std::string GetInfo();
	
private:
	NDUILabel					*m_lbTitle;
	
	NDUIContainerScrollLayer	*m_contentScroll;
	
	std::string					m_info;
};

#pragma mark 充值基本输入界面

class RechargeBaseInput :
public NDUILayer,
public NDUIButtonDelegate,
public CommonTextInputDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(RechargeBaseInput)
	
public:
	RechargeBaseInput();
	
	virtual ~RechargeBaseInput();
	
	void Initialization(CGPoint point); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void SetData(NewRechargeSubData& data);
	
	void SetTip(const char* tip);
	
	bool GetData(NewRechargeSubData& data);
	
	bool SetTextContent(CommonTextInput* input, const char* text); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override

protected:
	void AddInput(int btnTag, const char* lbText, int startY);
	
	unsigned int GetButtonTag();
	
	std::string  GetTextByTag(unsigned int tag);
	
	NDUILabel*	 GetLabelByTag(unsigned int tag);
	
	void ShowCommitTipDialog();
	
	virtual CGSize InitInput();
	
	virtual void OnCommit();
	
	virtual void OnSend();
	
protected:
	NDUIText					*m_lbTitle;
	
	CommonTextInput				*m_input;
	
	// int => btn tag, NDUILabel* => 输入对应的文本
	std::map<unsigned int, NDUILabel*>	m_mapText;
	
	NDUIContainerScrollLayer	*m_contentScroll;
	
	NDUIButton					*m_btnCommit;
	
	CIDFactory					m_factoryTag;
	
	NewRechargeSubData			m_data;
	
	std::string					m_tip;
};

#pragma mark 充值卡输入界面

class RechargeCardInput : 
public RechargeBaseInput
{
	DECLARE_CLASS(RechargeCardInput)
	
public:
	RechargeCardInput();
	
	~RechargeCardInput();
	
	CGSize InitInput(); override
	
	void OnCommit(); override
	
	void OnSend(); override
	
private:
	unsigned int m_tagCardNum, m_tagCardPassword;
};

#pragma mark 短信充值输入界面

class RechargeMessageInput : 
public RechargeBaseInput
{
	DECLARE_CLASS(RechargeMessageInput)
	
public:
	RechargeMessageInput();
	
	~RechargeMessageInput();
	
	CGSize InitInput(); override
	
	void OnCommit(); override
	
	void OnSend(); override
	
private:
	unsigned int m_tagPhoneNum;
};

#pragma mark　卡类型基本UI

class CardBaseUI : 
public NDUIButton
{
	DECLARE_CLASS(CardBaseUI)
	
public:
	CardBaseUI();
	
	~CardBaseUI();
	
	void Initialization(CGRect rect); override
	
	void draw(); override
	
	void SetSubData(NewRechargeSubData& data);
	
	bool GetSubData(NewRechargeSubData& data);
	
protected:
	NewRechargeSubData		m_subdata;
	
	NDUIText				*m_text;
	
	NDUILabel				*m_textfocus;
};


#pragma mark 支付通道Cell

class RechargeChannelCell : 
public CardBaseUI
{
	DECLARE_CLASS(RechargeChannelCell)
	
public:
	RechargeChannelCell();
	
	~RechargeChannelCell();
	
	void SetData(NewRechargeData& data);
	
	bool GetData(NewRechargeData& data);
	
	void UpdateTip(std::string tip);
private:
	NewRechargeData m_data;
};


#pragma mark 支付面额Cell

class RechargeFaceValueCell :
public CardBaseUI
{
	DECLARE_CLASS(RechargeFaceValueCell)
	
public:
	RechargeFaceValueCell();
	
	~RechargeFaceValueCell();
};

#pragma mark 充值界面

class RechargeUI :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(RechargeUI)
	
public:
	RechargeUI();
	
	~RechargeUI();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void SetVisible(bool visible); override
	
	static void ProcessQueryTip(NDTransData& data);
	
	static void ProcessGiftInfo(NDTransData& data);
	
	bool UpdateQueryTip(std::string tip);
	
private:
	static RechargeUI *s_instance;
private:
	NDUILabel									*m_lbTitle;
	NDUIContainerScrollLayer					*m_scrollChannel;
	NDUIContainerScrollLayer					*m_scrollFaceValue;
	NDUILabel									*m_lbPage;
	NDUIButton									*m_btnPrev;
	NDUIButton									*m_btnNext;
	NDUIButton									*m_btnReturn;
	std::vector<RechargeFaceValueCell*>			m_vRechargeFaceValue;
	int											m_iCurFaceValuePage;
	std::string									m_curFaceValuetip;
	
	RechargeInfoBase							*m_infoGongGao, *m_infoTip;
	
	RechargeCardInput							*m_inputCard;
	
	RechargeMessageInput						*m_inputMessage;
	
	RechargeChannelCell							*m_curDealChannelCell;			
	
	int											m_iState;
	
	bool										m_bCard;
			
private:
	void ShowPageUI(bool show);

	void ShowFaceValue(NewRechargeData& data);
	
	void ShowRechargeChannel();
	
	void ShowInput(NewRechargeSubData& data, const char* tip);
	
	void ShowNext();
	
	void ShowPrev();
	
	void UpdateCurpageFaceValue();
	
	int GetPageCount();
public:
	static vec_recharge_data s_data;
	
public:
	enum  
	{
		State_None,
		State_ShowChannel,
		State_ShowFaceValue,
		State_ShowInput,
	};
};

#pragma mark 充值记录

typedef struct _tagRechargeRecordData
{
	std::string date, money;
	_tagRechargeRecordData(std::string date, std::string money)
	{
		this->date = date;
		this->money = money;
	}
}RechargeRecordData;

typedef std::vector<RechargeRecordData>			vec_recharge_record_data;
typedef vec_recharge_record_data::iterator		vec_recharge_record_data_it;

typedef struct _tagRechargeRecord
{
	int total;
	vec_recharge_record_data vData;
	_tagRechargeRecord() { total = 0; }
	void clear() { total = 0; vData.clear(); }
	
	bool empty() { return vData.empty(); }
}RechargeRecord;

class RechargeRecordUI :
public NDUILayer
{
	DECLARE_CLASS(RechargeRecordUI)
	
	static void prcessRecord(NDTransData& data);
	
	static RechargeRecord s_data;
	
private:
	static RechargeRecordUI* s_instance;
	
public:
	RechargeRecordUI();
	
	~RechargeRecordUI();
	
	void Initialization(); override
	
	void Update();
	
private:
	NDUILabel			*m_lbDate;
	
	NDUITableLayer		*m_tlRecord;
	
private:
	void refreshRecord();
	void SetTotal(const char*text);
};

#pragma mark 充值

class Recharge :
public NDCommonLayer
{
	DECLARE_CLASS(Recharge)
public:
	Recharge();
	~Recharge();
	
	void Initialization(); override
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
};

#endif // _NEW_RECHARGE_H_
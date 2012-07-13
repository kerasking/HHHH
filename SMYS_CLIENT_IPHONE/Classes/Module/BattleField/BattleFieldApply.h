/*
 *  BattleFieldApply.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BATTLE_FIELD_APPLY_H_
#define _BATTLE_FIELD_APPLY_H_

#include "NDCommonScene.h"
#include "NDCommonControl.h"
#include "BattleFieldData.h"
#include "NDUITableLayer.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

#pragma mark 战场报名列表Cell

class BFApplyCell : public NDUINode
{
	DECLARE_CLASS(BFApplyCell)
	
public:
	BFApplyCell();
	
	~BFApplyCell();
	
	void Initialization(CGSize size=CGSizeMake(238, 23)); override
	
	void draw(); override
	
	void ChangeApply(BFPlayerInfo& bfApply);
	
	void ResetApply();
	
private:
	NDUILabel			*m_lbName, *m_lbLvlAttach1, *m_lbLvlAttach2;
	NDUIButton			*m_btnLvl;
	NDUILabel			*m_lbRank;
	NDPicture			*m_picBg, *m_picFocus;
};

#pragma mark 战场报名信息

class BattleFieldApplyInfo :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(BattleFieldApplyInfo)
	
public:
	BattleFieldApplyInfo();
	
	~BattleFieldApplyInfo();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void OnTimer(OBJID tag); override
	
	void SetVisible(bool visible); override
	
	//  重新设置战场规则,倒计时,报名信息,报名状态
	void ChangeApplyInfo(BFApplyInfo& bfApplyInfo);
	
	//  更新玩家报名状态,报名信息
	void UpdateApplyInfo(BFApplyInfo& bfApplyInfo);
	
	bool IsEmptyContent();
private:
	NDUIContainerScrollLayer	*m_ruleScroll;
	NDUILabel					*m_lbTime, *m_lbTimeAttach;
	NDUIButton					*m_btnApply, *m_btnRefresh;
	NDUITableLayer				*m_tlApplyList;
	NDUILabel					*m_lbPlayer;
	
	int							m_bfSeq;
	int							m_bfType;
	bool						m_bApplyState;
	
	int							m_iTimeOutSecond;
	NDTimer						m_timer;
	
private:
	// 包括报包括报名信息与报名人数信息
	void refreshApply(BFApplyInfo& bfApplyInfo);

	// 设置战场规则
	void SetBattleFieldRule(const char* text);
	
#pragma mark 倒计时
	// 重新设置倒计时 (包括设置标签,重新打开定时器)
	void ResetTimeOut(int sec);
	
	// 根据当前保存的秒数设置定时器
	void SetTimeOutTimer();
	
	// 刷新定时器标签
	void RefreshTimeOutLabel();
	
#pragma mark 报名状态
	// 处理报名状态 (包括与原状作比较若状态不一样则切换状态,非报名状态重新设置倒计时以及主动请求报名信息定时器)
	void DealApplyState(BFApplyInfo& bfApplyInfo, bool forceSwitch=false);
	
	// 切换到指定报名状态(报名或取消报名) 处理包括(状态赋值,标签的显示与隐藏,定时器是否取消以及按钮名字)
	void SwitchToApplyState(bool apply);
	
	// 根据传入的报名数据返回报名状态
	bool IsApply(map_bf_apply& applyInfo);
	
	// 获取保存的报名状态
	bool hasApply();
};

#pragma mark 战场报名

typedef struct _tagApplyInstance
{
	int bfType;
	BattleFieldApplyInfo* info;
	_tagApplyInstance(int bfType, BattleFieldApplyInfo* info)
	{
		this->bfType = bfType;
		this->info =info;
	}
	_tagApplyInstance()
	{
		this->bfType = 0;
		this->info = NULL;
	}
}ApplyInstance;

typedef std::vector<ApplyInstance>			vec_apply_ins;
typedef vec_apply_ins::iterator				vec_apply_ins_it;

class BattleFieldApply :
public NDCommonLayer
{
	DECLARE_CLASS(BattleFieldApply)
public:
	BattleFieldApply();
	~BattleFieldApply();
	
	void Initialization(); override
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void ChangeBfApply(BFApplyInfo& bfApplyInfo);
	
	void UpdateBfApply(BFApplyInfo& bfApplyInfo);
	
private:
	vec_apply_ins m_vBfApply;
	
private:
	BattleFieldApplyInfo* GetBfApplyIns(int bfType);
};

#pragma mark 战场背景

typedef struct _tagBFBackStory
{
	int bfType;
	NDUIContainerScrollLayer *scroll;
	_tagBFBackStory(int bfType, NDUIContainerScrollLayer *scroll)
	{
		this->bfType = bfType;
		this->scroll = scroll;
	}
	_tagBFBackStory()
	{
		memset(this, 0, sizeof(*this));
	}
}BFBackStory;

class BattleFieldBackStory :
public NDCommonLayer
{
	DECLARE_CLASS(BattleFieldBackStory)
public:
	BattleFieldBackStory();
	~BattleFieldBackStory();
	
	void Initialization(); override
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void UpdateBfBackStory(int bfType, std::string str);
	
private:
	std::vector<BFBackStory> m_vBfBackStory;
	
private:
	NDUIContainerScrollLayer* GetBfScroll(int bfType);
};

#endif // _BATTLE_FIELD_APPLY_H_
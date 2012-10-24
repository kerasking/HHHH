/*
 *  FarmInfoScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FARM_INFO_SCENE_H_
#define _FARM_INFO_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
#include "NDUITimeStateBar.h"
#include "NDUIDialog.h"

using namespace NDEngine;

struct FarmResource;

#pragma mark 属性cell
class NDFarmPropCell : 
public NDUINode,
public ITimerCallback
{
	DECLARE_CLASS(NDFarmPropCell)
	
	NDFarmPropCell();
	
	~NDFarmPropCell();
	
public:
	void Initialization(std::string str, int t, int r); override

	void draw(); override
	
	void SetTime(unsigned long rest, unsigned long total);
	void SetFinishText(std::string text);
	void OnTimer(OBJID tag); override
	void ReduceRestTime(unsigned long add);
	
private:
	NDUILabel	*m_lbKey, *m_lbValue;
	NDPicture	*m_picBg, *m_picFocus;
	ccColor4B	m_clrFocusText, m_clrNormalText;
	
	NDUIImage   *m_imageStateBar;
	NDUIRecttangle *m_rectProcess;
	
	NDTimer *m_timer;
	
	unsigned long m_restime, m_totaltime;
	NSTimeInterval m_begintime;
	std::string m_strFinish;
	bool m_bFinish;
	float m_fPercent;
public:
	int iType;
	int iParam;
};

#pragma mark 新的农场动态
class FarmInfoLayer :
public NDUILayer
{
	DECLARE_CLASS(FarmInfoLayer)
	
	FarmInfoLayer();
	
	~FarmInfoLayer();
	
	static FarmInfoLayer* GetInstance();

	static void addState(int iType, std::string des, int totalTime, int restTime,int param);
	
	static void addFarmTotalResource(int itemtypes, int total, int need);
	
public:
	void Initialization(); override
	
	void InitTrends(NDUINode* parent);
	
	void RefreshState();
	
	void RefreshResurce();
	
	void addBuildSpeed(int iID, int time);
	
	void cancelBuilding(int iID);
	
private:
	void InitResurce();
	void RefreshRes(int type);
private:
	
	std::string m_strCurResource;
	
	std::string m_strMatainResource;
	
	NDUITableLayer *m_tbTrends;
	
	NDUILayer *m_layerFarmState;
	
	NDUIContainerScrollLayer *m_scrollCurRes, *m_scrollMainRes;
	
private:
	static std::vector<FarmResource> vec_farm_rsc;
	static std::vector<NDFarmPropCell*> vec_farm_status;
	static FarmInfoLayer* s_intance;
};

/////////////////////////////////////////
class FarmStatus :
public NDUILayer,
public NDUITimeStateBarDelegate
{
	DECLARE_CLASS(FarmStatus)
public:
	FarmStatus();
	~FarmStatus();
	
	void Initialization(std::string str, int t, int r); override
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	void OnTimeStateBarFinish(NDUITimeStateBar* statebar); override
	
	void draw(); override
	
	void SetFarmStatusFocus(bool bFocus);
	
	void SetFinishText(std::string text);
	
	void ReduceRestTime(unsigned long add);
	
	void SetTitleColor(ccColor4B color);

public:
	int iType;
	int iParam;
private:
	std::string des;
	long totalTime;
	long restTime;
	NDUITimeStateBar *m_bar;
	NDUILabel *m_lbTitle;
	bool m_bRecal;
	bool m_bFocus;
};
/////////////////////////////////////////
class FarmStatusDelegate
{
public:
	virtual void OnFarmStatusClick(FarmStatus* farmstatus, bool bFocused){};
	virtual void OnFarmStatusFinish(FarmStatus* farmstatus){};
};
/////////////////////////////////////////

struct FarmResource {
	std::string name;
	int num;
	int need_num;
};

class FarmInfoScene :
public NDScene,
public FarmStatusDelegate,
public NDUITableLayerDelegate,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(FarmInfoScene)
public:
	FarmInfoScene();
	~FarmInfoScene();
	
	static FarmInfoScene* Scene();
	
	void Initialization(); override
	
	void OnFarmStatusFinish(FarmStatus* farmstatus); override
	
	void OnFarmStatusClick(FarmStatus* farmstatus, bool bFocused); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	static void addState(int iType, std::string des, int totalTime, int restTime,int param);
	
	static void addFarmTotalResource(int itemtypes, int total, int need);
	
	void cancelBuilding(int iID);
	
	void addBuildSpeed(int iID, int time);
	
private:
	void DrawResourceString(std::string text, int x, int y, ccColor4B color1, ccColor4B color2, bool bAssign=false);
	void DrawResourceArray(int x, int y, int type);
	void DrawState();
	
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	
	void ClearFarmStatus(FarmStatus* status, bool bAll=false);
	void BeforoeFarmStatusClear(FarmStatus* status);
	int GetPageCount();
	
	void DefocusFarmStatusExcepet(FarmStatus* status);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel* m_lbTitle;
	NDUILabel* m_lbFarmTrend[2];
	
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	
	NDUITableLayer *m_tlOperate;
	
	FarmStatus* m_farmstatus;
	
	int m_iCurPage;
	
private:
	static std::vector<FarmResource> vec_farm_rsc;
	static std::vector<FarmStatus*> vec_farm_status;
};


#endif // _FARM_INFO_SCENE_H_
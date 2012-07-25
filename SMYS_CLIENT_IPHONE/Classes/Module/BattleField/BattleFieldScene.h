/*
 *  BattleFieldScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BATTLE_FIELD_SCENE_H_
#define _BATTLE_FIELD_SCENE_H_

#include "NDCommonScene.h"
#include "BattleFieldShop.h"
#include "BattleFieldApply.h"
#include "NDUISpecialLayer.h"

using namespace NDEngine;

enum  
{
	eBattleFieldBegin = 0,
	eBattleField = eBattleFieldBegin,
	eBattleFieldShop,
	eBattleFieldBackStory,
	eBattleFieldEnd,
};

class BattleFieldScene :
public NDCommonSocialScene,
public HFuncTabDelegate
{
	DECLARE_CLASS(BattleFieldScene)
	
	BattleFieldScene();
	
	~BattleFieldScene();
	
public:
	
	static BattleFieldScene* Scene();
	
	static void UpdateShop();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void OnHFuncTabSelect(NDHFuncTab* tab, unsigned int lastIndex, unsigned int curIndex);

	void ShowShop();
	
	void DealRecvBFDesc();
	
	BattleFieldApply* GetApply() { return m_apply; }
	
	BattleFieldBackStory *GetBackStory() { return m_backstroy; }
	
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
	void InitBattleFiled(NDUIClientLayer* client);
	void InitShop(NDUIClientLayer* client);
	void InitBackStory(NDUIClientLayer* client);
	
	void ShowBattleField();
	
	void ShowBackStory();
private:
	BattleFieldShop* m_shop;
	BattleFieldApply* m_apply;
	BattleFieldBackStory *m_backstroy;
	int m_iCurDealBfDesc;
	static BattleFieldScene* s_BFScene;
};

/***
* 临时性注释 郭浩
* begin
*/
// class BattleFieldRelive : 
// public NDUILayer,
// public NDUIButtonDelegate
// {
// 	DECLARE_CLASS(BattleFieldRelive)
// 	
// 	static void Show(int time = 0);
// 	
// 	static void SetTimeCount(int time);
// 	
// 	static void Hide();
// public:
// 	~BattleFieldRelive();
// 	
// 	void Initialization(); override
// 	
// 	void OnTimer(OBJID tag); override 
// 	
// 	void SetTime(int time);
// 	
// 	void OnButtonClick(NDUIButton* button);
// 	
// private:
// 	BattleFieldRelive();
// 
// 	void ShowMask(bool show);
// 	
// private:
// 	NDUILayer				*m_layerMask;
// 	NDUILabel				*m_lbTime;
// 	NDUIButton				*m_btnRelive, *m_btnReliveInCurPlace;
// 	NDTimer					m_timer;
// 	int						m_iCurTime;
// 	
// 	static BattleFieldRelive* s_instance;
// 	static int s_time;		
// };
/***
* 临时性注释 郭浩
* end
*/

#endif // _BATTLE_FIELD_SCENE_H_
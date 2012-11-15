/*
 *  PlayerSkillInfo.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __PLayer_SKILL_INFO_H__
#define __PLayer_SKILL_INFO_H__

#include "define.h"
#include "NDUILayer.h"
#include "NDPlayer.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"
#include "NDCommonScene.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

const unsigned int ITEM_QI_QIAO	= 28501002; // 七窍玲珑丹
// 主动技能
class CActSkillInfoLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(CActSkillInfoLayer)
public:
	CActSkillInfoLayer();
	~CActSkillInfoLayer();
	
	void Initialization();
	
	void RefreshBattleSkill(int idBattleSkill, int nSlotCount);
	virtual void OnButtonClick(NDUIButton* button);
	
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabel* m_lbReqLv;
	NDUILabelScrollLayer* m_skillInfo;
	NDUIButton* m_btnKaiQi;
};

class CActSkillLayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(CActSkillLayer)
	enum {
		COL_COUNT = 5,
		ACT_BTN_COUNT	= 10,
		SLOT_BTN_COUNT	= 10,
		MAX_SLOT_SKILL	= 16,
		SLOT_SKILL_BEGIN= 1000,
	};
	enum {
		BUTTON_INVALID	= -3,	// 无效的
		BUTTON_LOCK		= -2,	// 锁住的
		BUTTON_EMPTY	= -1,	// 空的
	};
	
public:
	CActSkillLayer();
	~CActSkillLayer();
	
	void Initialization(const SET_BATTLE_SKILL_LIST& battleSkills, CActSkillInfoLayer* skillInfoLayer, int nMaxSlot);
	
	void OnButtonClick(NDUIButton* button);
	virtual bool OnButtonDragOut(NDUIButton* button, CCPoint beginTouch, CCPoint moveTouch, bool longTouch);
	virtual bool OnButtonDragOutComplete(NDUIButton* button, CCPoint endTouch, bool outOfRange);
	virtual bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch);
	virtual void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	void	OpenGroove();		// 开技能格子
	void	SendOpenGrooveMsg();
protected:
	void	UpdatePage();		// 更新页
	void	UpdatePageSlot();	// 更新装备页
	int		GetSkillIdByPos(int nPos);
	int		GetKeyByPos(int nPos);
	int		GetSlotByKey(int nKey);
	void	SetButtonImage(NDUIButton* pBtn);
	NDUIButton*	CreatePageButton(const char* pszTitle);

private:
	NDUIButton* m_btnActSkills[ACT_BTN_COUNT];
	NDUIButton* m_btnSlotSkills[SLOT_BTN_COUNT];
	
	CActSkillInfoLayer* m_skillInfoLayer;
	std::map<int, NDPicture*> m_recylePictures;
	NDUIImage*	m_imageMouse;
	
	NDUIButton* m_btnBack;
	NDUIButton* m_btnNext;
	int			m_nPage;
	NDUIButton* m_btnBackSlot;
	NDUIButton* m_btnNextSlot;
	int			m_nPageSlot;
	int			m_nSlotCount;
	NDUILabel*	m_pLabelLearned;
	NDUILabel*	m_pLabelEquip;
	NDUILabel*	m_pLabelLearnedPage;
	NDUILabel*	m_pLabelEquipPage;
	
	
	std::map<int, int> m_mapSkillPos;
};

// 被动技能
class BattleSkillInfoLayer :
public NDUILayer
{
	DECLARE_CLASS(BattleSkillInfoLayer)
public:
	BattleSkillInfoLayer();
	~BattleSkillInfoLayer();
	
	void Initialization();
	
	void RefreshBattleSkill(int idBattleSkill);
	
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabel* m_lbReqLv;
	NDUILabelScrollLayer* m_skillInfo;
};

class BattleSkillLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(BattleSkillLayer)
	enum {
		ROW_COUNT = 5,
		COL_COUNT = 5,
	};
public:
	BattleSkillLayer();
	~BattleSkillLayer();
	
	void Initialization(const SET_BATTLE_SKILL_LIST& battleSkills, BattleSkillInfoLayer* skillInfoLayer);
	
	void OnButtonClick(NDUIButton* button);
	
private:
	NDUIButton* m_btnBattleSkills[ROW_COUNT][COL_COUNT];
	BattleSkillInfoLayer* m_skillInfoLayer;
};

//////////////////////////////////////////////////////////////////////////////////////////
class LifeSkillInfoLayer :
public NDUILayer
{
	DECLARE_CLASS(LifeSkillInfoLayer)
public:
	LifeSkillInfoLayer();
	~LifeSkillInfoLayer();
	
	void Initialization();
	
	void RefreshLifeSkill(int idSkill);
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabel* m_lbLv;
	NDUILabelScrollLayer* m_skillInfo;
};

//////////////////////////////////////////////////////////////////////////////////////////
class LifeSkillLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(LifeSkillLayer)
	enum {
		ROW_COUNT = 4,
		COL_COUNT = 5,
	};
public:
	LifeSkillLayer();
	~LifeSkillLayer();
	
	void Initialization(LifeSkillInfoLayer* skillInfoLayer);
	
	void OnButtonClick(NDUIButton* button);
	
	void UpdateLifeSkill();
	
private:
	NDUIButton* m_btnLifeSkillsLianYao[ROW_COUNT][COL_COUNT];
	NDUIButton* m_btnLifeSkillsBaoShi[ROW_COUNT][COL_COUNT];
	
	NDUILayer* m_layerLianYao;
	NDUILayer* m_layerBaoShi;
	
	NDUIButton* m_btnLianYao;
	NDUIButton* m_btnBaoShi;
	
	NDUIImage* m_imgFocus;
	
	NDUILabel* m_lbLifeSkillLV;
	ImageNumber* m_numLifeSkillExp;
	NDUIRecttangle* m_rectLifeSkillExp;
	
	LifeSkillInfoLayer* m_skillInfoLayer;
};

//////////////////////////////////////////////////////////////////////////////////////////
class UserStateInfoLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(UserStateInfoLayer)
public:
	UserStateInfoLayer();
	~UserStateInfoLayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void RefreshUserState(int idState);
	
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabelScrollLayer* m_skillInfo;
	NDUIButton* m_btnYiChu;
};

//////////////////////////////////////////////////////////////////////////////////////////
class UserStateIconLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(UserStateIconLayer)
	enum {
		ROW_COUNT = 5,
		COL_COUNT = 5,
	};
public:
	static void OnDelUserState();
	
	UserStateIconLayer();
	~UserStateIconLayer();
	
	void Initialization(UserStateInfoLayer* stateInfoLayer);
	
	void OnButtonClick(NDUIButton* button);
	
	void UpdateUserState();
	
private:
	NDUIButton* m_btnState[ROW_COUNT][COL_COUNT];
	
	UserStateInfoLayer* m_stateInfoLayer;
	static UserStateIconLayer* s_instance;
	
private:
	
};

//////////////////////////////////////////////////////////////////////////////////////////
class PlayerSkillInfo : 
public NDUILayer,
public TabLayerDelegate
{
	DECLARE_CLASS(PlayerSkillInfo)
public:
	PlayerSkillInfo();
	~PlayerSkillInfo();
	
	void Initialization();
	
	void AddActSkill(NDUINode* parent);
	void AddPasSkill(NDUINode* parent);
	void AddLifeSkill(NDUINode* parent);
	void AddPlayerState(NDUINode* parent);
	
	void Update();
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex);
	void OpenGroove();
private:
	static PlayerSkillInfo* s_instance;
	
	CActSkillLayer* m_actSkillLayer;
	BattleSkillLayer* m_pasSkillLayer;
	LifeSkillLayer* m_lifeSkillLayer;
	UserStateIconLayer* m_userStateLayer;
	
	CActSkillInfoLayer* m_actSkillInfoLayer;
	BattleSkillInfoLayer* m_pasSkillInfoLayer;
	LifeSkillInfoLayer* m_lifeSkillInfoLayer;
	UserStateInfoLayer* m_userStateInfoLayer;
};

#endif
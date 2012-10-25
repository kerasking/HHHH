/*
 *  UiPetSkill.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_PET_SKILL_H_
#define _UI_PET_SKILL_H_

#include "UiPetDefine.h"
#include "define.h"
#include "NDUILayer.h"
#include "NDPlayer.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"
#include "NDCommonScene.h"
#include "NDScrollLayer.h"
#include "NDString.h"

using namespace NDEngine;


class CUIPetSkillInfo :	// 技能信息
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(CUIPetSkillInfo)
public:
	CUIPetSkillInfo();
	~CUIPetSkillInfo();
	
	bool Init();
	void EnableOperate(bool bEnable);
	
	void OnButtonClick(NDUIButton* button);
	
	void RefreshPetSkill(OBJID idSkill, bool bLock);
	void RefreshItemSkill(OBJID idItem, bool bShowBtn);
	void RefreshLock(OBJID idPet);
	void UpdateSkillItemDesc(OBJID idItem, std::string& strDesc);
	
	virtual void SetVisible(bool bVisible);
protected:
	void ClearInfo();
	void UpdateButton();
	NDUIButton* CreateButton(const char* pszTitle);
	std::string QuerySkillItemDesc(OBJID idItem);
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabel* m_lbReqLv;
	NDUILabelScrollLayer* m_skillInfo;
	
	bool		m_bEnable;
	NDUIButton* m_btnKaiQi;
	NDUIButton* m_pBtnLock;
	NDUIButton* m_pBtnUnLock;
	NDUIButton* m_pBtnLearn;
	NDUIButton* m_pBtnFocus;
	
	NDUIButton*	m_pBtnClose;
	OBJID		m_idSkill;
	OBJID		m_idItem;
	
	std::map<OBJID, std::string>	m_mapStrSkillItem;
	
};

enum PET_SKILL_BTN_TYPE {
	PET_SKILL_BTN_TYPE_EMPTY,
	PET_SKILL_BTN_TYPE_LOCK,
	PET_SKILL_BTN_TYPE_SKILL,
	PET_SKILL_BTN_TYPE_ITEM,
};

class CUIPetSkill :
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(CUIPetSkill)
	enum {
		MARGIN_L	= 14,
		MARGIN_T	= 14,
		BG_SIZE		= 42,
		BUTTON_W	= 50,
		BUTTON_H	= 24,
		BUTTON_INTERVAL	= 4,
		
		COL_COUNT = 5,
		SKILL_BTN_COUNT	= 10,
		ITEM_BTN_COUNT	= 10,
		ITEM_BTN_BEGIN= 1000,
	};
	
public:
	CUIPetSkill();
	~CUIPetSkill();
	
	bool	Init();
	void	Update(OBJID idPet, bool bEnable = true);
	void	UpdateSkillItem(ID_VEC& vecItemId);
	PET_SKILL_BTN_TYPE GetBtnType();
	OBJID	GetSkillId();
	OBJID	GetItemId();
	bool	IsLockSkill(OBJID idSkill);
	
	virtual void OnButtonClick(NDUIButton* button);
	virtual void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	void	OpenGroove();		// 开技能格子
	void	LockSkill(OBJID idSkill);
	void	UnLockSkill(OBJID idSkill);
	void	LearnSkill();
protected:
	void	UpdatePage();		// 更新页
	void	UpdatePageItem();	// 更新物品页
	int		GetSkillIdByPos(int nPos);
	int		GetItemIdByPos(int nPos);
	int		GetKeyByPos(int nPos);
	void	SetButtonImage(NDUIButton* pBtn);
	NDUIButton* CreateButton(const char* pszTitle);
	void	UpdateLockSkill();
	void	SendLearnSkillMsg();
	
private:
	NDUIButton* m_btnSkills[SKILL_BTN_COUNT];
	NDUIButton* m_btnItems[ITEM_BTN_COUNT];
		
	NDUIButton* m_btnBack;
	NDUIButton* m_btnNext;
	int			m_nPage;
	NDUIButton* m_btnBackItem;
	NDUIButton* m_btnNextItem;
	int			m_nPageItem;
	int			m_nSlotCount;
	
	NDUILabel*	m_pLabelPage;
	NDUILabel*	m_pLabelItemPage;
	
	std::map<int, int> m_mapSkillPos;	// key begin 1
	std::map<int, int> m_mapItemPos;	// key begin 1001
	OBJID		m_idPet;
	bool		m_bEnable;
	int			m_nPos;
	
	std::set<OBJID>		m_setLockSkill;
};

#endif
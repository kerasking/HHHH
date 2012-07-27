/*
 *  NewPetScene.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-12.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _NEW_PET_SCENE_H_
#define _NEW_PET_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "Item.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUICustomView.h"
#include "NDUIItemButton.h"
#include "NDScrollLayer.h"
#include "NDCommonScene.h"

#include "UiPetDefine.h"
#include "UiPetEquip.h"
#include "UiPetAttr.h"
#include "UiPetPart.h"
#include "UiPetSkill.h"
#include "NewGamePetBag.h"

using namespace NDEngine;


class CUIPetTip :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(CUIPetTip)
public:
	CUIPetTip();
	~CUIPetTip();
	
	bool	Init(int nWidth);
		
private:
	NDUILabel*	m_pLabelTitle;
	NDUILabelScrollLayer* m_pLabelTip;
};

//////////////////////////////////////////////////////////////
class CUIPet
: public NDUILayer
, public NDUIButtonDelegate
, public TabLayerDelegate
, public NDUIDialogDelegate
, public CUIPetDelegate
{
	DECLARE_CLASS(CUIPet)
public:
	CUIPet();
	~CUIPet();
	bool Init(OBJID idUser, OBJID idFocusPet, bool bEnable = true);
	void UpdateUI(OBJID idPet);				// 不含背包更新
	void PetBagAddItem(OBJID idItem){}
	void PetBagDelItem(OBJID idItem){}
	void PetBagItemCount(OBJID idItem){}
	void UpdateSkillItemDesc(OBJID idItem, std::string& strDesc);
	
	virtual void SetVisible(bool bVisible);
	virtual void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex);
protected:
	bool	AddAttrInTab(NDFuncTab *pTab, int nIndex);
	bool	AddPartInTab(NDFuncTab *pTab, int nIndex);
	bool	AddSkillInTab(NDFuncTab *pTab, int nIndex);
	bool	AddBagInTab(NDFuncTab *pTab, int nIndex);
	bool	SetTabNodePic(TabNode* pTabNode, int nStartX);
	void	UpdateFocusLayer();
	void	GetPetItems(VEC_ITEM& vecItem);		// 不含宠物技能书
	void	GetPetSkillItems(ID_VEC& vecItem);// 宠物技能书
	void	RefreshAttrData();
	void	RefreshPartData();
	void	RefreshSkillData();
	void	RefreshSkillInfoData();
	
	// Delegate
	virtual void	UpdateSkillInfo();
	virtual void	CloseSkillInfo();
	virtual void	LockSkill(OBJID idSkill);
	virtual void	UnLockSkill(OBJID idSkill);
	virtual void	LearnSkill();
	virtual void	UpdateBagItemInfo();
	virtual void	UseItem();
	virtual void	DropItem();
	virtual void	CloseBagItemInfo();
	virtual OBJID	GetFocusPetId();
	virtual void	ChangePet();
protected:
	CUIPetTip*			m_pTip;
	CUIPetEquip*		m_pPetEquip;
	CUIPetAttr*			m_pPetAttr;
	CUIPetPart*			m_pPetPart;
	CUIPetSkillInfo*	m_pPetSkillInfo;
	CUIPetSkill*		m_pPetSkill;
	NewGamePetBag*		m_pPetBag;
	CUIItemInfo*		m_pItemInfo;
	
	NDUILayer*			m_pFocusLayer;
	unsigned int		m_nSkillInfoIndex;
	
	bool				m_bEnable;
	OBJID				m_idUser;
};

#endif
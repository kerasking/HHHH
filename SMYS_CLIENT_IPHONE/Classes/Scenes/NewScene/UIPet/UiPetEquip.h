/*
 *  UiPetEquip.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _UI_PET_EQUIP_H_
#define _UI_PET_EQUIP_H_

#include "define.h"
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
#include "NDCommonControl.h"

#include "UiPetDefine.h"
#include "CPetNode.h"

typedef std::map<int, NDUIItemButton*> MAP_BUTTON;

class CUIPetEquip		// 装备
: public NDUILayer
, public NDUIButtonDelegate
, public NDUIDialogDelegate
{
	DECLARE_CLASS(CUIPetEquip)
public:
	CUIPetEquip();
	~CUIPetEquip();
	bool	Init();
	void	Update(OBJID idUser, OBJID idFocusPet, bool bEnable = true);
	
	void	OnButtonClick(NDUIButton* button); override
	bool	OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	bool	OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool	OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	void	SetVisible(bool bVisible); override
	void	OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	OBJID	GetFocusPetId()	{ return m_idFocusPet; }
	void	UpdateFocusPet(OBJID idPet = 0);
	bool	CheckItemLimit(Item* item, bool isShow);
protected:
	void	UpdatePosition();
	void	UpdateName();
	void	UpdateEquip();
	void	UpdateExpHpMp();
	void	UpdatePetNode();
	void	UpdateButton();
	int		GetIconIndex(int nPos);
	NDUIButton*	CreateButton(const char* pszTitle);
	void	NextButtonXY(int nWidth, int& nX, int& nY);
	OBJID	GetLastPetId();
	OBJID	GetNextPetId();
	bool	DelPetId(OBJID idPet);
	bool	IsExistPetInVec(OBJID idPet);
protected:
	enum { 
		MARGIN_L = 10,
		MARGIN_R = 14,
		MARGIN_T = 10,
		MARGIN_B = 8,
		BUTTON_W = 50,
		BUTTON_H = 22,
		BUTTON_INTERVAL_W = 6,
		BUTTON_INTERVAL_H = 3,
	};
	MAP_BUTTON		m_mapButton;
	NDUIImage*		m_pImageMouse;
	NDUILabel*		m_pLabelName;
	NDUILabel*		m_pLabelPost;
	NDUILabel*		m_pLabelLevel;
	NDUILabel*		m_pLabelQuality;
	NDUILabel*		m_pLabelTrait;
	NDExpStateBar*	m_stateBarExp;
	NDUILabel*		m_pLabelHp;
	NDUILabel*		m_pLabelMp;
	NDUIButton*		m_pBtnRoleBg;
	
	NDUIButton*		m_pBtnMainPlayed;	// 主将
	NDUIButton*		m_pBtnRest;			// 休息
	NDUIButton*		m_pBtnPlayed;		// 出战
	NDUIButton*		m_pBtnIn;			// 收回
	NDUIButton*		m_pBtnOut;			// 溜宠
	NDUIButton*		m_pBtnDel;			// 丢弃
	NDUIButton*		m_pBtnDisboard;		// 卸下
	NDUIButton*		m_pBtnShow;			// 展示
	NDUIButton*		m_pBtnLeft;
	NDUIButton*		m_pBtnRight;
	
	ID_VEC			m_vecIdPet;
	OBJID			m_idFocusPet;
	CPetNode*		m_pPetNode;
	bool			m_bEnable;
};

#endif
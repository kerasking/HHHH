/*
 *  FarmStorage.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FARM_STORAGE_H_
#define _FARM_STORAGE_H_

#include "NDScene.h"
#include "NDDlgBackGround.h"
#include "GameUIAttrib.h"
#include "NDUIButton.h"
#include "NDUIMenuLayer.h"
#include "NDTimer.h"

class BtnLayer;

class FarmEntityNode :
public NDUILayer
{
	DECLARE_CLASS(FarmEntityNode)
public:
	FarmEntityNode();
	~FarmEntityNode();
	
	void draw(); override
	
	void Initialization(NDNode* parent); override
	
	NDUIStateBar* GetStateBar();
	
	NDUIButton* GetAddBtn();
	
	NDUIButton* GetMinusBtn();
	
	NDUILabel* GetTitleLabel();
	
	void UpdateLayOut();
	
	bool IsFocus();
	
private:
	void LayOut();

	int GetY(int iParentH, int iChildH);
	int GetX(int iParentW, int iChildW);
private:
	NDUILabel* m_lbTitle;
	NDUIButton* m_btnAdd;
	NDUIButton* m_btnMinus;
	NDUIStateBar* m_stateBar;
	NDPicture* m_picMinus, *m_picAdd;
	bool m_bNeedCacl;
	bool m_bFocus;
};

///////////////////////////////////////////

struct FarmEntityData{
	FarmEntityNode* node;
	int change;
	int itemType;
	FarmEntityData() { memset(this, 0, sizeof(*this)); }
};

class FarmStorageDialog :
//public NDDlgBackGround,
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public ITimerCallback
{
	DECLARE_CLASS(FarmStorageDialog)
public:
	FarmStorageDialog();
	~FarmStorageDialog();
	
	static FarmStorageDialog* Show(int lvl, int space);
	
	static FarmStorageDialog* GetInstance() { return s_instace; };
	
	void Initialization(int lvl, int space); hide
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void DealButton();
	
	void OnButtonDown(NDUIButton* button); override
	void OnButtonUp(NDUIButton* button); override
	void OnTimer(OBJID tag);
	
	
	void SetLeve(int lvl);
	
	void SetSpace(int freeSpace);
	
	FarmEntityNode* AddFarmEntity(int iItemType);
	
	FarmEntityNode* GetFarmEntity(int iTag);
	
	const std::vector<FarmEntityData>& GetFarmEntitys() { return m_vecFarmEntity; }
	
	BtnLayer *GetBtnLayer() { return m_btnLayer; }
	
	void ClearOperateData();
private:
	void sendChangeMaxSpace();
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
private:
	std::vector<FarmEntityData> m_vecFarmEntity;
	
	NDUILabel *m_lbRestSpace;
	
	int m_iLvl, m_iSpace, m_iSpaceOp;
	
	NDUIMenuLayer *m_menulayerBG;
	
	NDUITableLayer* m_tlMain;
	
	NDUITableLayer* m_tlOperate;
	
	NDTimer* m_timer;
	
	NDUIButton* m_btnOperate;
	
	BtnLayer *m_btnLayer;
	
private:
	static FarmStorageDialog *s_instace;
	
	int m_iBtnHeight;
};


#endif // _FARM_STORAGE_H_
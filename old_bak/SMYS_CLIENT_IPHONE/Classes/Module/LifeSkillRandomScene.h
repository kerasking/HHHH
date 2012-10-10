/*
 *  LifeSkillRandomScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _LIFE_SKILL_RANDOM_SCENE_H_
#define _LIFE_SKILL_RANDOM_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
#include "NDUIDialog.h"
#include "NDUICustomView.h"

using namespace NDEngine;

enum
{
	eChaoYao = 7,
	eBaoShiYuanShi = 8,
};

class FormulaRandomInfoLayer;

class FormulaRandomInfoLayerDelegate
{
public:
	virtual void OnFormulaRandomInfoLayerClick(FormulaRandomInfoLayer* layer) {}
};

//////////////////////////////////////////////


class LifeSkillRandomScene :
public NDScene,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate,
public FormulaRandomInfoLayerDelegate,
public GameItemBagDelegate,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(LifeSkillRandomScene)
public:
	LifeSkillRandomScene();
	~LifeSkillRandomScene();
	
	void Initialization(int iType); hide
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnFormulaRandomInfoLayerClick(FormulaRandomInfoLayer* layer); override
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void reset();
private:
	void FiltItem(bool isReset);
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	
private:
	NDUIMenuLayer		*m_menulayerBG;
	NDUILabel			*m_lbTitle;
	GameItemBag			*m_itemBag;
	NDUITableLayer		*m_tlOperate;
	
	enum { eMaxRandomInfo = 3 };
	FormulaRandomInfoLayer	*m_layerRandomInfo[eMaxRandomInfo];
	
	int m_iType;
	
	int m_iOperateInfoIndex;
};


#endif // _LIFE_SKILL_RANDOM_SCENE_H_
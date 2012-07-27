/*
 *  LifeSkillScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _LIFE_SKILL_SCENE_H_
#define _LIFE_SKILL_SCENE_H_

#include "NDScene.h"
#include "NDUITableLayer.h"
#include "NDUIButton.h"
#include "NDUIMenuLayer.h"
#include "NDUICustomView.h"
#include "NDUIDialog.h"
#include "NDUIImage.h"
#include "ImageNumber.h"
#include "GameUIAttrib.h"
#include "GameUIFormulaInfo.h"

using namespace NDEngine;

enum  
{
	LifeSkillScene_Query, // 查看
	LifeSkillScene_Product, // 生产
};

class LifeSkillScene :
public NDScene,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUIButtonDelegate,
public FormulaInfoDialogDelegate,
public NDUICustomViewDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(LifeSkillScene)
public:
	LifeSkillScene();
	~LifeSkillScene();
	
	void Initialization(int iType, int iOpen); hide
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnFormulaInfoDialogClose(FormulaInfoDialog* dialog); override
	void OnFormulaInfoDialogClick(FormulaInfoDialog* dialog, unsigned int buttonIndex); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	
	void UpdateSkillData();
	
private:
	void LoadData();
	void UpdateGUI();
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);

private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle;
	
	NDUILabel *m_lbLvl;
	NDUIImage *m_imageExp; NDPicture *m_picExp;
	
	NDUIStateBar *m_stateSkillVal;
	ImageNumber *m_imagenumSkillVal;
	
	NDUILayer *m_layerSubTitile;
	NDUICircleRect *m_crBG;
	
	NDUITableLayer *m_tlContent;
	
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	
	FormulaInfoDialog *m_formulaDialog;
	NDUIDialog *m_dlgProduct; int m_iProductFormulaID;
	
	int m_iType;
	int m_iOpenType;
	int m_iCurPage;
	int m_iMaxPage;
	std::vector<int> m_vecFormula;
	std::vector<int> m_vecOperate;
};

#endif // _LIFE_SKILL_SCENE_H_
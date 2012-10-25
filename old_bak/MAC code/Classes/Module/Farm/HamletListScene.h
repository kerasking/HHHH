/*
 *  HamletListScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _HAMLET_LIST_SCENE_H_
#define _HAMLET_LIST_SCENE_H_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUIMenuLayer.h"
#include "SocialElement.h"

using namespace NDEngine;

enum  
{
	HamletListScene_Begin,
	HamletListScene_Move = HamletListScene_Begin,
	HamletListScene_List,
	HamletListScene_End,
};

class HamletListScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(HamletListScene)
public:
	static HamletListScene* Scene();
	
	HamletListScene();
	~HamletListScene();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void refresh();
	
	void SetType(int iType);
	int GetType();
	void SetPage(int iCurPage, int iTotalPage);
private:
	int GetPageNum();
	void UpdateMainUI(VEC_SOCIAL_ELEMENT& elements);
	void ClearSocialElements();
	void QueryPage(int iPage);
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlMain, *m_tlOperate;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	VEC_SOCIAL_ELEMENT m_vecElement;
	int m_iCurPage, m_iTotalpage;
	int m_iType;
	int m_iCurOperateID;
};

#endif // _HAMLET_LIST_SCENE_H_

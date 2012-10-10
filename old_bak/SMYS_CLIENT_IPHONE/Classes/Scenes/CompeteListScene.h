/*
 *  CompeteListScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _COMPETE_LIST_SCENE_H_
#define _COMPETE_LIST_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"

using namespace NDEngine;

void CompetelistUpdate(int iType, int iCurpage, int iTotalPage, VEC_SOCIAL_ELEMENT& elements);
////////////////////////////////////
enum  
{
	Competelist_Begin = 0,
	Competelist_Joins = Competelist_Begin,
	Competelist_VS,
	Competelist_Wish,
	Competelist_End,
};


class CompetelistScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(CompetelistScene)
public:
	CompetelistScene();
	~CompetelistScene();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void refresh(int iType, int iCurPage, int iTotalpage, VEC_SOCIAL_ELEMENT& elements);
	void SetPage();
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	void UpdateMainUI(VEC_SOCIAL_ELEMENT& elements);
	int GetPageNum();
	void ClearSocialElements();
	void sendWish(int page);
	void sendCompetition(int page);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle, *m_lbSubTitle[2];
	NDUITableLayer *m_tlMain, *m_tlOperate;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	int m_iCurPage;
	int m_iTotalPage;
	int m_iType;
	VEC_SOCIAL_ELEMENT m_vecElement;
	SocialElement *m_curOpertaeElement;
};

#endif // _COMPETE_LIST_SCENE_H_
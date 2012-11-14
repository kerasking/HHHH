/*
 *  SynMbrListUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_MBR_LIST_UI_LAYER_H__
#define __SYNDICATE_MBR_LIST_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "SocialElement.h"

using namespace NDEngine;

class AssignJobLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(AssignJobLayer)
public:
	AssignJobLayer();
	~AssignJobLayer();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button);
	
	void SetMbrID(int idMbr);
	
private:
	NDUITableLayer* m_tlJobs;
	int m_idMbr;
};

class SynMbrInfo : 
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(SynMbrInfo)
	
	SynMbrInfo();
	
	~SynMbrInfo();
	
public:
	
	void Initialization(CCPoint pos); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void Change(SocialElement* se);
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	void refreshSocialData();
	
	SocialElement* GetCurElement() { return m_socialEle; }
private:	
	SocialFigure *m_figure;
	
	SocialEleInfo *m_info;
	
	AssignJobLayer* m_jobLayer;
	
	std::vector<NDUIButton*> m_vOpBtn;
	
	SocialElement* m_socialEle;
};

class SynMbrListUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	friend class SynMbrInfo;
	
	DECLARE_CLASS(SynMbrListUILayer)
public:
	static SynMbrListUILayer* GetCurInstance() {
		return s_instance;
	}
	
	void processMbrList(NDTransData& data);
	void processSocialData(SocialData& data);
private:
	static SynMbrListUILayer* s_instance;
	static map_social_data s_mapSocialData;
	
public:
	SynMbrListUILayer();
	~SynMbrListUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void Query();
	
private:
	SynMbrInfo* m_infoMbr;
	bool m_bFirstQuery;
	NDUITableLayer* m_tlMain;
	VEC_SOCIAL_ELEMENT m_vElement;
	NDUILabel* m_lbPages;
	NDUIButton* m_btnPrePage;
	NDUIButton* m_btnNextPage;
	int m_nCurPage;
	int m_nMaxPage;
	
private:
	void releaseElement();
};

#endif
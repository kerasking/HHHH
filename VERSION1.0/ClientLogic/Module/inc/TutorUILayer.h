/*
 *  TutorUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __TUTOR_UI_LAYER_H__
#define __TUTOR_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDUIDialog.h"

using namespace NDEngine;

typedef vector<SocialElement*> VEC_TUDI_ELEMENT;
typedef VEC_TUDI_ELEMENT::iterator VEC_TUDI_ELEMENT_IT;



class TutorInfo : 
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(TutorInfo)
	
	TutorInfo();
	
	~TutorInfo();
	
public:
	
	void Initialization(CGPoint pos, bool daoshi=false); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void ChangeTutor(SocialElement* se);
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	void refreshSocialData();
	
	SocialElement* GetTutor() { return m_socialEle; }
private:	
	SocialFigure *m_figure;
	
	SocialEleInfo *m_info;
	
	std::vector<NDUIButton*> m_vOpBtn;
	
	NDUIButton *m_btnClose;
	
	SocialElement* m_socialEle;
	
	bool m_daoshi;
};

class TutorUILayer :
public NDUILayer,
public NDUIButtonDelegate,
//public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	friend class TutorInfo;
	
	DECLARE_CLASS(TutorUILayer)
public:
	static void refreshScroll();
	static void processTutorList(NDTransData& data);
	static void processUserPos(NDTransData& data);
	static void processMsgTutor(NDTransData& data);
	static void reset();
	static void processSocialData(/*SocialData& data*/);
	static void processSeeEquip(int targetId, int lookface);
	
	static SocialElement* s_seDaoshi;
	static VEC_TUDI_ELEMENT s_vTudi;
private:
	static TutorUILayer* s_instance;
	static map_social_data s_mapTurtorData;
public:
	TutorUILayer();
	~TutorUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void Initialization();
	void SetVisible(bool visible); override
	void ShowTudiInfo(bool show);
	
	void refreshMainList();
	
	void ShowEquipInfo(bool show, int lookface=0, int targetId=0);
	
private:
	NDUITableLayer* m_tlTudi;
	SocialElement* m_curSelEle;
	
	TutorInfo* m_infoDaoShi;
	
	TutorInfo* m_infoTuDi; bool	m_infoTuDiShow;
	
	
	SocialPlayerEquip* m_infoEquip;
	
	// 传送位置
	int m_idDestMap;
	int m_destX;
	int m_destY;
	
private:
	void refreshTuDi();
	void refreshDaoShi();
	void refreshSocialData();
};

#endif
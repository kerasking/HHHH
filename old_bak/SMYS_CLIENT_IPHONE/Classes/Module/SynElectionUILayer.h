/*
 *  SynElectionUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_ELECTION_UI_LAYER_H__
#define __SYNDICATE_ELECTION_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "SocialElement.h"

using namespace NDEngine;

class NDSynEleCell :
public NDPropCell {
	DECLARE_CLASS(NDSynEleCell)
public:
	NDSynEleCell();
	~NDSynEleCell();
	
	void SetSocialElement(SocialElement* se) {
		m_se = se;
	}
	
	SocialElement* GetSocialElement() {
		return m_se;
	}
private:
	SocialElement* m_se;
};

class SynElectionUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(SynElectionUILayer)
public:
	static SynElectionUILayer* GetCurInstance() {
		return s_instance;
	}
	void processQueryOfficer(NDTransData& data);
private:
	static SynElectionUILayer* s_instance;
public:
	SynElectionUILayer();
	~SynElectionUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	void Query();
	
private:
	NDUIButton* m_btnElection;
	NDUITableLayer* m_tlCategory, *m_tlDetail;
	SocialElement* m_curSelEle;
	VEC_SOCIAL_ELEMENT m_vElement;
	bool m_bQuery;
	
private:
	void releaseElement();
};

#endif
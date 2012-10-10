/*
 *  SynVoteUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_VOTE_UI_LAYER_H__
#define __SYNDICATE_VOTE_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"

using namespace NDEngine;

class VoteListCell :
public NDPropCell {
	DECLARE_CLASS(VoteListCell)
public:
	VoteListCell();
	~VoteListCell();
	
	void Initialization();
	
	int m_idSponsor;
	
	CGRect GetYesRect();
	CGRect GetNoRect();
	
private:
	NDUIImage* m_imgYes;
	NDUIImage* m_imgNo;
};

class SynVoteUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(SynVoteUILayer)
	static SynVoteUILayer* s_instance;
	
public:
	static SynVoteUILayer* GetCurInstance() {
		return s_instance;
	}
	
	void processVoteList(NDTransData& data);
	
public:
	SynVoteUILayer();
	~SynVoteUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	virtual void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void Query();
	
private:
	NDUITableLayer* m_tlVoteList;
	NDUIButton *m_btnView;
	NDUIButton* m_btnCancelVote;
	bool m_bQuery;
};

#endif
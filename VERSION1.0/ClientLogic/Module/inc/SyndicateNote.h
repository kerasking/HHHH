/*
 *  SyndicateNote.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_NOTE_H__
#define __SYNDICATE_NOTE_H__

#include "NDUILayer.h"
#include "NDUIEdit.h"
#include "NDPicture.h"
#include "define.h"
#include "NDUITableLayer.h"

using namespace NDEngine;

class SyndicateNote : 
public NDUILayer,
public NDUIEditDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(SyndicateNote)
	SyndicateNote();
	~SyndicateNote();
	
public:
	static void Show(const string& note);
	
public:
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnEditInputFinish(NDUIEdit* edit);
	void Initialization(const string& note);
	void draw();
	
private:
	NDPicture* m_picLeftTop;		
	NDPicture* m_picRightTop;
	NDPicture* m_picLeftBottom;
	NDPicture* m_picRightBottom;
	
private:
	bool m_bTouchBegin;
	CCRect scrRect;
	string m_synNote;
};

#endif
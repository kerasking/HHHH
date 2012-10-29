/*
 *  SyndicateInvite.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_INVITE_H__
#define __SYNDICATE_INVITE_H__

#include "NDUILayer.h"
#include "NDUIEdit.h"
#include "NDPicture.h"
#include "define.h"
#include "NDUITableLayer.h"

using namespace NDEngine;

class SyndicateInvite : 
public NDUILayer,
public NDUIEditDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(SyndicateInvite)
	SyndicateInvite();
	~SyndicateInvite();
	
public:
	static void Show();
	
public:
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnEditInputFinish(NDUIEdit* edit);
	void Initialization();
	void draw();
	
private:
	NDPicture* m_picLeftTop;		
	NDPicture* m_picRightTop;
	NDPicture* m_picLeftBottom;
	NDPicture* m_picRightBottom;
	
private:
	bool m_bTouchBegin;
	CGRect scrRect;
	string m_strInvited;
};

#endif
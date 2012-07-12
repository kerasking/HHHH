/*
 *  StatusDialog.h
 *  DragonDrive
 *
 *  Created by wq on 11-5-6.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_STATUS_DIALOG_H___
#define __BATTLE_STATUS_DIALOG_H___

#include "define.h"
#include "NDUILayer.h"
#include "NDUITableLayer.h"
#include "NDTextNode.h"
//#include "SocialElement.h"
//#include "NDTip.h"

using namespace NDEngine;

class Fighter;
class StatusDialog :
public NDUILayer, 
public NDUITableLayerDelegate
{
	DECLARE_CLASS(StatusDialog)
public:
	StatusDialog();
	~StatusDialog();
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void Initialization(Fighter* f);
	void draw();
	
	virtual bool TouchEnd(NDTouch* touch);
	
private:
	NDPicture* m_picLeftTop;		
	NDPicture* m_picRightTop;
	NDPicture* m_picLeftBottom;
	NDPicture* m_picRightBottom;
	CGRect scrRect;
	NDUILabel* m_label;
	NDUIText* m_memo;
	NDUITableLayer* m_table;
	
	//VEC_SOCIAL_ELEMENT m_vElement;
	
	//TalkBox* m_talkBox;
	Fighter* m_fighter;
	
private:
	void releaseElement();
};

#endif
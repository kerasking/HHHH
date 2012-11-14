/*
 *  CreateSynDialog.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __CREATE_SYN_DIALOG_H__
#define __CREATE_SYN_DIALOG_H__

#include "NDUILayer.h"
#include "NDUIEdit.h"
#include "NDPicture.h"
#include "NDUICheckBox.h"
#include "NDUITableLayer.h"
#include "define.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class CreateSynDialog : 
public NDUILayer, 
public NDUITableLayerDelegate,
public NDUIEditDelegate,
public NDUICheckBoxDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(CreateSynDialog)
	CreateSynDialog();
	~CreateSynDialog();
	
public:
	static void Show();
	
public:
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnCBClick( NDUICheckBox* cb );
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
	CCRect scrRect;
	int m_tagCamp;
	string m_synName;
};

#endif
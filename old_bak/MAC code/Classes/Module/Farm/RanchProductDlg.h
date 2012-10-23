/*
 *  RanchProductDlg.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _RANCH_PRODUCT_DLG_H_
#define _RANCH_PRODUCT_DLG_H_

#include "NDDlgBackGround.h"
#include "FarmInfoScene.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class RanchProductDlg :
public NDDlgBackGround,
public NDUIDialogDelegate
{
	DECLARE_CLASS(RanchProductDlg)
public:
	RanchProductDlg();
	~RanchProductDlg();
	
	void Initialization(int iFarmID, int iEntityID, int iProductID, bool bHarvest); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void AddStatus(std::string text, int iTotalTime, int iRestTime);
	
	// make sure last call it
	void Show(std::string title, std::string content);
private:
	void SetText(std::string title, std::string content);
	void Send(int iAction);
private:
	FarmStatus* m_status;
	int m_iFarmID, m_iEntityID, m_iProductID, m_bIsMatured;
};

////////////////////////////////////////////
class FarmProductDlg : 
public RanchProductDlg
{
	DECLARE_CLASS(FarmProductDlg)
public:
	void Initialization(); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
};

#endif // _RANCH_PRODUCT_DLG_H_

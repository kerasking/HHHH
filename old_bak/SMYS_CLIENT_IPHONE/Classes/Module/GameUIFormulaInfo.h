/*
 *  GameUIFormulaInfo.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_FORMULA_INFO_H_
#define _GAME_UI_FORMULA_INFO_H_

#include "NDUILayer.h"
#include "NDUITableLayer.h"
#include "NDUIItemButton.h"

using namespace NDEngine;

class FormulaInfoLayer;

class FormulaInfoDelegate
{
public:
	// ret=true(user接管),=false(默认处理)
	virtual bool OnFormulaInfoClick(FormulaInfoLayer* layer) { return false; }
};


class FormulaInfoLayer : public NDUILayer
{
	DECLARE_CLASS(FormulaInfoLayer)
public:
	FormulaInfoLayer();
	~FormulaInfoLayer();
	
	void Initialization(int iFormulaID, int iItemCol=eCol); hide
	void draw(); override
	
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	void SetItemColumn(int iCol);
	int GetFormulaID();
	CGSize GetInfoSize();
private:
	void InitItemInfo(int itemType, int iRequireCount);
	
private:
	enum { eCol = 2, eTitleInterval = 8, eInfoInterval = 4, eInfoW = 50, eInfoH = 25, };
	struct  s_formula_info
	{
		NDUIItemButton	*btn;
		NDUILayer *layer;
		NDUILabel *lbInfo;
		Item* item;
		s_formula_info() { memset(this, 0, sizeof(*this)); }
	};
	
	typedef std::vector<s_formula_info>::iterator formula_info_it;
	
	NDUILabel *m_lbTitle;
	std::vector<s_formula_info> m_vecFormulaInfo;
	int m_iFormulaID;
	int m_iCol;
	bool m_bCacl;
};

////////////////////////////////////////////////
class FormulaInfoDialog;
class FormulaInfoDialogDelegate
{
public:
	virtual void OnFormulaInfoDialogShow(FormulaInfoDialog* dialog) {}
	virtual void OnFormulaInfoDialogClose(FormulaInfoDialog* dialog) {}
	virtual void OnFormulaInfoDialogClick(FormulaInfoDialog* dialog, unsigned int buttonIndex) {}
	/**
	 ret: true:user接管该事件处理, false: 内部默认处理
	*/
	virtual bool OnFormulaInfoClick(FormulaInfoDialog* dialog, int iFomulaID) { return false; }
};

class FormulaInfoDialog : 
public NDUILayer, 
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public FormulaInfoDelegate
{
	DECLARE_CLASS(FormulaInfoDialog)
	FormulaInfoDialog();
	~FormulaInfoDialog();
public:
	void SetWidth(unsigned int width); /*default values 200*/
	void SetTitleHeight(unsigned int height);/*default values 25*/
	void SetContextHeight(unsigned int height);/*default values 80*/
	void SetButtonHeight(unsigned int height);/*default values 30*/
	
	void Show(int foumulaID, const char* cancleButton, const std::vector<std::string>& ortherButtons);
	void Show(int foumulaID, const char* cancleButton, const char* ortherButtons,.../*must NULL end*/);  
	virtual void Close();
	
	int GetFormulaID();
public:
	void Initialization();
	void draw(); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnFormulaInfoClick(FormulaInfoLayer* layer); override
	bool DispatchTouchEndEvent(CGPoint beginTouch, CGPoint endTouch); override
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
private: 
	NDPicture* m_picLeftTop;		
	NDPicture* m_picRightTop;
	NDPicture* m_picLeftBottom;
	NDPicture* m_picRightBottom;
private:
	bool m_leaveButtonExists;
	FormulaInfoLayer *m_layerContext;
	NDUITableLayer* m_table;	
	
	unsigned int m_width, m_titleHeight, m_contextHeight, m_buttonHeight;
	bool m_bTouchBegin;
	
};

#endif // _GAME_UI_FORMULA_INFO_H_
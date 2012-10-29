/*
 *  GameUIPaiHang.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_PAIHANG_
#define _GAME_UI_PAIHANG_

#include <vector>
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"

using namespace NDEngine;

/**
 desc:label层,根据label个数调整lable显示,目前支持(左,中,右)最多三个,并可选择是否显示黑边框(默认显示)
*/
class LabelLayer : public NDUILayer
{
	DECLARE_CLASS(LabelLayer)
	
public:
	LabelLayer();
	~LabelLayer(){}
	
	void Initialization(); override
	void draw(); override
	// 注意:设置之前需要先设置frame
	// param: 只显示前三个,如果传入空,则清空原先所有文本
	void SetTexts(std::vector<std::string> vec_str);
	void ShowFrame(bool bShow);
	//　默认15
	void SetFontSize(unsigned int size);
	// 默认墨绿色
	void SetFontColor(ccColor4B color);
	
private:
	void SetText(std::string str, LabelTextAlignment align);
private:
	bool m_bShowFrame;
	unsigned int m_uiFontSize;
	ccColor4B m_colorFont;
};

/////////////////////////////////////////////////////////

class NDUITopLayerEx;

class GameUIPaiHang : 
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(GameUIPaiHang)
public:
	GameUIPaiHang();
	~GameUIPaiHang();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void draw(); override
	void UpdateMainUI();
private:
	void ShowQuery(bool bShow);
	void turnPage();

private:
	NDUITableLayer *m_tlMain;
	NDUITableLayer *m_tlQuery;
	LabelLayer *m_llTitle;
	NDUITopLayerEx *m_topLayerEx;
	int m_iCurPage, m_iNextPage;
	
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
public:
	static void DataInit();
	static std::vector<int> fildTypes;
	static std::vector<std::string> fildNames;
	static int curPaiHangType;
	static int itype;
	static int totalPages;
	static std::vector<std::string> values;
	//		PaiHang.getInstance().setCurPaiHangType(id);
	//		PaiHang.getInstance().type = type;
};
#endif // _GAME_UI_PAIHANG_
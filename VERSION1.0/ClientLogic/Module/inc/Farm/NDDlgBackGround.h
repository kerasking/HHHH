/*
 *  NDDlgBackGround.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_DLG_BACK_GROUND_H_
#define _ND_DLG_BACK_GROUND_H_

#include "NDPicture.h"
#include "NDUITableLayer.h"
#include <vector>
#include <string>

using namespace NDEngine;

class NDDlgBackGround;

class NDDlgBackGroundDelegate
{
public:
	virtual void OnDlgBackGroundBtnClick(NDDlgBackGround* dlgBG, std::string text, int iTag, unsigned int btnIndex) {};
};

class NDDlgBackGround :
public NDUILayer
//public NDUITableLayerDelegate ///< 临时性注释 郭浩
{
	DECLARE_CLASS(NDDlgBackGround)
public:
	NDDlgBackGround();
	~NDDlgBackGround();
	
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	void InitBtns(const std::vector<std::string>& vec_str, const std::vector<int>& vec_id);
	void draw(); override
	
	// 继承自该类,可重写该方法,不用设置delegate为自身
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override

protected:
	void Close();

private:
	void InitOpt();

private:
	NDPicture* m_picLeftTop;		
	NDPicture* m_picRightTop;
	NDPicture* m_picLeftBottom;
	NDPicture* m_picRightBottom;
protected:
	// 选项
	NDUITableLayer* m_tlOpt;
	std::vector<std::string> m_vecTLStr;
	std::vector<int> m_vecTLTag;
	bool m_bNeedInitTL;
	
};

#endif // _ND_DLG_BACK_GROUND_H_
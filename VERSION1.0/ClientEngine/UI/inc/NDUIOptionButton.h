/*
 *  NDOptionButton.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-10.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __ND_UI_OPTION_BUTTON_H__
#define __ND_UI_OPTION_BUTTON_H__

#include "NDUINode.h"
#include <string>
#include <vector>

#include "CCTexture2D.h"
#include "NDUILabel.h"
#include "NDTile.h"

namespace NDEngine
{
using namespace std;

class NDUIOptionButton;

typedef vector<string> VEC_OPTIONS;

class NDUIOptionButtonDelegate
{
public:
	virtual void OnOptionChange(NDUIOptionButton* option);
};

class NDUIOptionButton: public NDUINode
{
	DECLARE_CLASS (NDUIOptionButton)
public:
	NDUIOptionButton();
	~NDUIOptionButton();

public:
	void Initialization();override

	void SetFontColor(cocos2d::ccColor4B fontColor);
	void SetFontSize(unsigned int fontSize);
	void SetOptions(const VEC_OPTIONS& ops);
	int GetOptionIndex();
	void SetBgClr(cocos2d::ccColor4B clr);

	void SetFrameRect(CCRect rect);override

	void ShowFrame(bool show)
	{
		m_frameOpened = show;
	}

public:
	void draw();override
	void NextOpt();
	void PreOpt();
	void OnFrameRectChange(CCRect srcRect, CCRect dstRect);override
	void SetOptIndex(unsigned int index);

protected:
	NDTile *m_leftArrow;
	NDTile *m_rightArrow;
	NDUILabel *m_title;
	VEC_OPTIONS m_vOptions;

	int m_optIndex;

	cocos2d::ccColor4B m_clrBg;
	bool m_frameOpened;
};
}

#endif

/*
 *  DramaUI.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _DRAMA_UI_H_ZJH_
#define _DRAMA_UI_H_ZJH_

#include "NDUILayer.h"

using namespace NDEngine;

///////////////////////////////////////////////
class ClickLayer :
public NDUILayer
{
	DECLARE_CLASS(ClickLayer)
	
public:
	virtual bool TouchBegin(NDTouch* touch);
	virtual bool TouchEnd(NDTouch* touch);
};

///////////////////////////////////////////////
class DramaConfirmdlg :
public ClickLayer
{
	DECLARE_CLASS(DramaConfirmdlg)
	
public:
	void Initialization(); override
	
	void SetContent(std::string content);
};

///////////////////////////////////////////////
class DramaChatLayer :
public ClickLayer
{
	DECLARE_CLASS(DramaChatLayer)
	
	DramaChatLayer();
	~DramaChatLayer();

public:
	virtual void SetFigure(std::string filename, bool bReverse);
	virtual void SetTitle(std::string title, int nFontSize, int nFontColor);
	virtual void SetContent(std::string contentt, int nFontSize, int nFontColor);
	
protected:
	void SetFigureTag(int nTag);
	void SetTitleTag(int nTag);
	void SetContentTag(int nTag);
	
private:
	int m_nTagFigure;
	int m_nTagTitle;
	int m_nTagContent;
};

///////////////////////////////////////////////
class DramaLeftChat :
public DramaChatLayer
{
	DECLARE_CLASS(DramaLeftChat)
	
public:
	void Initialization(); override
};

///////////////////////////////////////////////
class DramaRightChat :
public DramaChatLayer
{
	DECLARE_CLASS(DramaRightChat)
	
public:
	void Initialization(); override
};

#endif // _DRAMA_UI_H_ZJH_
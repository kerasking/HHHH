/*
 *  UIExp.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UIEXP_H_ZJH_
#define _UIEXP_H_ZJH_

#include "NDUINode.h"
#include "NDPicture.h"
#include "NDUILabel.h"

#include <string>

using namespace NDEngine;

class CUIExp :
public NDUINode
{
	DECLARE_CLASS(CUIExp)
	
	CUIExp();
	~CUIExp();
	
public:
	void Initialization(const char* bgfile, const char* processfile); override
	
	void SetProcess(unsigned int unProcess);
	void SetTotal(unsigned int unTotal);
	
	unsigned int GetProcess();
	unsigned int GetTotal();
	
	//设置进度数字前面的文本
	void SetText(const char* text);	
	void SetTextFontColor(ccColor4B color);
	void SetTextFontSize(unsigned int unSize);
    void SetStyle(int nStyle) { m_nStyle = nStyle; }

private:
	NDPicture*				m_picBg;
	NDPicture*				m_picProcess;
	NDUILabel*				m_lbText;
	
	std::string				m_strBgFile;
	std::string				m_strProcessFile;
	std::string				m_strText;
	
	unsigned int			m_unTotal;
	unsigned int			m_unProcess;
    
    int                     m_nStyle;
	
	bool					m_bRecacl;
protected:
	void draw(); override
	
public:
	void SetFrameRect(CCSize rect); override
};

#endif // _UIEXP_H_ZJH_
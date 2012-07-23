/*
 *  UIRadioButton.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-17.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _CUIRADIOBUTTON_H_ZJH_
#define _CUIRADIOBUTTON_H_ZJH_

#include "UICheckBox.h"

class CUIRadioButton :
public CUICheckBox
{
	DECLARE_CLASS(CUIRadioButton)
	
	CUIRadioButton();
	~CUIRadioButton();

public:
	void Initialization(const char* imgUnCheck, const char* imgCheck); hide
	
protected:
	bool OnClick(NDObject* object); override
	
	DECLARE_AUTOLINK(CUIRadioButton)
	INTERFACE_AUTOLINK(CUIRadioButton)
};

class CUIRadioGroup :
public NDUINode
{
	DECLARE_CLASS(CUIRadioGroup)
	
	CUIRadioGroup();
	~CUIRadioGroup();
	
public:
	void AddRadio(CUIRadioButton* radio);
	void RemoveRadio(CUIRadioButton* radio);
	bool ContainRadio(CUIRadioButton* radio);
	
	void SetIndexSelected(unsigned int nIndex);
	void SetRadioSelected(CUIRadioButton* radio);
	
	CUIRadioButton* GetSelectedRadio();
	unsigned int GetSelectedIndex();
	
private:
	typedef CAutoLink<CUIRadioButton>			RADIO_LINK;
	typedef std::vector<RADIO_LINK>				VEC_RADIO_LINK;
	typedef VEC_RADIO_LINK::iterator			VEC_RADIO_LINK_IT;
	
	VEC_RADIO_LINK		m_vRadioLink;
	
public:
	bool OnClick(NDObject* object); override
};

#endif // _CUIRADIOBUTTON_H_ZJH_
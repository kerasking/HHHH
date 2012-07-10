/*
 *  NDUICheckBox.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_UI_CHECK_BOX_H_
#define _ND_UI_CHECK_BOX_H_

#include "NDUINode.h"
#include "NDUIImage.h"
#include <string>

namespace NDEngine
{	
	//delegates begin
	class NDUICheckBox;
	class NDUILabel;
	class NDUICheckBoxDelegate
	{
	public:
		virtual void OnCBClick( NDUICheckBox* cb ){};
	};
	//delegates end
	
	// checkbox 默认不打勾,默认大小为18*18
	class NDUICheckBox : public NDUINode
	{
		DECLARE_CLASS(NDUICheckBox)
	public:
		NDUICheckBox();
		~NDUICheckBox();
	public:	
		void Initialization(); override		
		void Initialization(NDPicture *checkPic, NDPicture *unCheckPic, bool bClearOnFree=false); hide
		void SetFrameRect(CGRect rect); override
	private:
		void draw(); override
	public:
		// 对外接口
		bool GetCBState();
		void ChangeCBState();
		void SetFocusColor(ccColor3B color);
		void SetFontColor(ccColor3B fontColor);
		void SetText(std::string text);
	private:
		NDUIImage		*m_imgChecked;
		bool		m_bChecked;
		ccColor3B	m_focusColor;
		NDUILabel	*m_title;
		
		NDPicture *m_picCheck, *m_picUnCheck;
		bool m_bClearOnFree;
	};
}


#endif // _ND_UI_CHECK_BOX_H_
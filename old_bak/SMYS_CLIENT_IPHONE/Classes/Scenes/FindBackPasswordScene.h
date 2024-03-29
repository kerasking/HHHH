/*
 *  FindBackPasswordScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _FIND_BACK_PASS_W0RD_SCENE_H_
#define _FIND_BACK_PASS_W0RD_SCENE_H_

#include "NDScene.h"
#include "NDUIDefaultButton.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDTimer.h"

class FindBackPasswordScene :
public NDScene,
public NDUIEditDelegate,
public NDUIButtonDelegate,
public ITimerCallback
{
	DECLARE_CLASS(FindBackPasswordScene)
	FindBackPasswordScene();
	~FindBackPasswordScene();
public:
	static FindBackPasswordScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	void OnTimer(OBJID tag); override
private:
	NDUICustomEdit		*m_edtAccount, *m_edtVerifyCode;
	NDUIButton			*m_sendVerify;
	NDUIOkCancleButton	*m_btnOk, *m_btnCancel;
	
	std::string			m_strAccount, m_strCode;
	
	NDTimer				m_time;
};


#endif // _FIND_BACK_PASS_W0RD_SCENE_H_
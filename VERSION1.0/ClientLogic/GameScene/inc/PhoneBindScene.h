/*
 *  PhoneBindScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PHONE_BIND_SCENE_H_
#define _PHONE_BIND_SCENE_H_

#include "NDScene.h"
#include "NDUIDefaultButton.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDTimer.h"

class PhoneBindScene :
public NDScene,
public NDUIEditDelegate,
public NDUIButtonDelegate,
public ITimerCallback
{
	DECLARE_CLASS(PhoneBindScene)
	PhoneBindScene();
	~PhoneBindScene();
public:
	static PhoneBindScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	void OnTimer(OBJID tag); override
private:
	NDUICustomEdit		*m_edtPhoneNum, *m_edtAccount, *m_edtPassword;
	NDUIImageButton		*m_btnCommit, *m_btnRet;
	
	std::string			m_strAccount, m_strPassword, m_strPhoneNum;
	
	NDTimer				m_time;
};

#endif // _PHONE_BIND_SCENE_H_

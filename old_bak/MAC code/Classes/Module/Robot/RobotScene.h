/*
 *  RobotScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ROBOT_SCENE_H_
#define _ROBOT_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDUICheckBox.h"

#define USE_ROBOT (0)

using namespace NDEngine;

class RobotScene :
public NDScene,
public NDUIButtonDelegate
{
	DECLARE_CLASS(RobotScene)
public:

	static RobotScene* Scene();
	
	RobotScene();
	
	~RobotScene();
	
	void Initialization(); override
	
	void draw(); override
	
	void OnButtonClick(NDUIButton* button); override

	void SetServerName(std::string name);
	
	bool IsOuterNet();
private:

	bool DealStartLogic();
	
	bool DealEndLogic();
	
	std::string GetNextAccount(const std::string& acct);
	
	bool WriteStringToFile(std::string str);
	
	void Save();
private:

	NDUIMenuLayer			*m_menuLayer;
	
	NDUILabel				*m_lbServer;
	NDUIButton				*m_btnSelServer;
	NDUICheckBox			*m_cbOuterNet;
	
	NDUIEdit				*m_edtStartAcct;
	NDUIEdit				*m_edtPW;
	NDUIEdit				*m_edtAcctNum;
	
	NDUILabel				*m_lbRate;
	NDUILabel				*m_lbTotalConnect;
	NDUILabel				*m_lbSucessConnect;
	NDUILabel				*m_lbFailConnect;
	NDUILabel				*m_lbServerClose;
	NDUILabel				*m_lbLoginFail;
	
	NDUIButton				*m_btnStart;

	bool					m_bStart;
};


#endif // _ROBOT_SCENE_H_
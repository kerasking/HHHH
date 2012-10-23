//
//  LoginScene.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __LoginScene_H
#define __LoginScene_H

#include "NDScene.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUIFrame.h"
#include "NDUIMenuLayer.h"
#include "NDUICheckBox.h"
#include "NDDataPersist.h"
#include "NDUIDefaultButton.h"
#include "NDPath.h"

using namespace NDEngine;

class LoginScene : public NDScene, public NDUIEditDelegate, public NDUIButtonDelegate //, public NDUICheckBoxDelegate
{
	DECLARE_CLASS(LoginScene)
	LoginScene();
	~LoginScene();
public:
	static LoginScene* Scene(bool changeServer=false);
	void Initialization(bool changeServer=false); override 
	void OnButtonClick(NDUIButton* button); override
	bool OnEditClick(NDUIEdit* edit); override
	//void OnCBClick(NDUICheckBox* checkbox); override
	void SetUserNameText(const char* username);
	void SetPasswordText(const char* password);
	void SetServerInfo(const char* serverIP, const char* serverName, int serverPort);
	
	virtual void OnEditInputFinish(NDUIEdit* edit);
	
private:
	NDUILayer* m_menuLayer;
	NDUIFrame* m_frame;
	NDUILabel* m_lbTitle, *m_lbAccount, *m_lbPwd, *m_errorNote;
	NDUICustomEdit* m_edtAccount, *m_edtPwd, *m_edtServer;
	NDUIButton* m_btnLogin, *m_btnChangeAccount, *m_btnChangeServer, *m_btnBind, *m_btnForgot;
	NDUICheckBox* m_cbSavePassword;
	NDUILabel *m_lbLastLoginServer;
	NDDataPersist m_loginData;
	std::string m_serverIP, m_serverName;
	int m_serverPort;
	
	NDUIOkCancleButton *m_btnOk, *m_btnCancel;
	bool m_hasClickChangeServer;
private:
	void SaveLoginData();
};


#endif

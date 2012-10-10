/*
 *  RegisterAccountScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _REGISTER_ACCOUNT_SCENE_H_
#define _REGISTER_ACCOUNT_SCENE_H_

#include "NDScene.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUIFrame.h"
#include "NDUIMenuLayer.h"
#include "NDUICheckBox.h"
#include "NDUICustomView.h"
#include "NDUIDefaultButton.h"

using namespace NDEngine;
/*
class RegisterAccountScene : public NDScene, public NDUIEditDelegate, public NDUIButtonDelegate, public NDUICustomViewDelegate
{
	DECLARE_CLASS(RegisterAccountScene)
	RegisterAccountScene();
	~RegisterAccountScene();
public:
	static RegisterAccountScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	bool OnEditClick(NDUIEdit* edit); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void SetAccountText(const char *pText) { if(m_edtAccount) m_edtAccount->SetText(pText); }
	void SetPasswordText(const char *pText) { if(m_edtPwd) m_edtPwd->SetText(pText); }
private:
	NDUIMenuLayer* m_menuLayer;
	NDUIFrame* m_frame;
	NDUILabel* m_lbTitle, *m_lbAccount, *m_lbPwd;
	NDUIEdit* m_edtAccount, *m_edtPwd;
	NDUICustomView *m_input;
	NDUICustomView* m_inputView;
	NDUIButton* m_btnRegister;
	NDUILabel	*m_lbTip1, *m_lbTip2;
};
*/

#pragma mark 新的注册帐号

class NewRegisterAccountScene : public NDScene, public NDUIEditDelegate, public NDUIButtonDelegate, public NDUICustomViewDelegate //, public NDUICheckBoxDelegate
{
	DECLARE_CLASS(NewRegisterAccountScene)
	NewRegisterAccountScene();
	~NewRegisterAccountScene();
public:
	static NewRegisterAccountScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	bool OnEditClick(NDUIEdit* edit); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void SetAccountText(const char *pText) { if(m_edtAccount) m_edtAccount->SetText(pText); }
	void SetPasswordText(const char *pText) { if(m_edtPwd) m_edtPwd->SetText(pText); }
private:
	NDUILayer* m_menuLayer;
	NDUICustomEdit* m_edtAccount, *m_edtPwd;
	NDUIImageButton *m_btnOk, *m_btnCancel;
	NDUICustomView *m_input;
};


#endif // _REGISTER_ACCOUNT_SCENE_H_
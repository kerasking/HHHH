/*
 *  CreateRoleScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __CREATE_ROLE_SCENE_H__
#define __CREATE_ROLE_SCENE_H__

#include "NDScene.h"
#include "NDUIEdit.h"
#include "NDUIButton.h"
#include "NDUILabel.h"
#include "NDUIFrame.h"
#include "NDUIMenuLayer.h"
#include "NDNode.h"
#include "CCPointExtension.h"
#include "NDDirector.h"
#include "NDManualRole.h"
#include "NDUIOptionButton.h"
#include "NDNetMsg.h"
#include "NDUIMemo.h"
#include "NDUIDefaultButton.h"
#include "NDUIOptionButtonEx.h"
#include <vector>
#include <string>

using namespace std;
using namespace NDEngine;

class RoleNode;
class CreateRoleScene : public NDScene,
public NDMsgObject,
public NDUIEditDelegate,
public NDUIButtonDelegate,
public NDUIOptionButtonExDelegate
{
	DECLARE_CLASS(CreateRoleScene)
	CreateRoleScene();
	~CreateRoleScene();
public:
	static CreateRoleScene* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	virtual void OnOptionChangeEx(NDUIOptionButtonEx* option); override
	bool OnClickOptionEx(NDUIOptionButtonEx* option); override
	
	virtual bool process(MSGID msgID, NDEngine::NDTransData*, int len); override
	bool OnEditClick(NDUIEdit* edit); override
private:
	enum { ePropSex, ePropStyle, eHair, eWeapon,};
	void SetProptImage(int index, CCPoint orgin, NDUINode* parent);
	void SetOptImage();
	NDCombinePicture* GetCreateCombinePic(CCRect cut, ...);
	
private:
	NDUILayer* m_menuLayer;
	NDUIFrame* m_frame;
	NDUILabel* m_lbTitle, *m_lbNickName, *m_lbSex, *m_lbSytle, *m_lbHairClr, *m_lbWeapon;
	NDUILabel* m_lbHint;
	NDUICustomEdit* m_edtNickName;
	RoleNode* m_role;
	NDUIOkCancleButton* m_btnOk, *m_btnCancel;
	NDUIOptionButtonEx* m_optSex, *m_optStyle, *m_optHair, *m_optWeapon;
	NDUIMemo* m_memoWeapon;
	vector<string> m_vWeaponMemo;
	bool m_bFirstClickNickName;
};


#endif
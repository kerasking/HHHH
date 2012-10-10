/*
 *  OtherPlayerInfoScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _OTHER_PLAYER_INFO_SCENE_H_
#define _OTHER_PLAYER_INFO_SCENE_H_

#include "NDCommonScene.h"
#include "PlayerNpcListLayers.h"
#include "Item.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class CUIPet;
class NDUIItemButton;
class OtherPlayerInfoScene :
public NDCommonScene,
public NDUIDialogDelegate
{
	DECLARE_CLASS(OtherPlayerInfoScene)
	
	OtherPlayerInfoScene();
	
	~OtherPlayerInfoScene();
	
public:
	static OtherPlayerInfoScene* Scene(NDManualRole* role);
	static void showPlayerInfo(std::deque<string>& deqInfo);
	static void showPlayerEquip();
	static void ShowPlayerPet(OBJID idRole);
	
	void Initialization(NDManualRole* role); hide
	
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
private:
	ManualRole* m_role;
	
	NDUILayer *m_layerEquip;
	NDUIItemButton *m_cellinfoEquip[Item::eEP_End];
	NDUIItemButton* m_focusCell;
	
	NDUILabel* m_lbTitle;
	NDUIContainerScrollLayer* m_layerInfo;
	
	CUIPet *m_pUiPet;
	
	static OtherPlayerInfoScene* s_instance;
private:
	void InitOtherPlayerInfo(NDUIClientLayer* client);
	void ShowPlayerInfo(std::deque<string>& deqInfo);
	int GetIconIndexByEquipPos(int pos);
	
	void InitEquipItemList(int iEquipPos, Item* item);
	
	void InitPet(NDUIClientLayer* client, OBJID idRole);
};

#endif
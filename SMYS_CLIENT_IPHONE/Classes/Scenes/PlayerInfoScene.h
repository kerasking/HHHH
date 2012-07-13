/*
 *  PlayerInfoScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PLAYER_INFO_SCENE_H_
#define _PLAYER_INFO_SCENE_H_

#include "NDCommonScene.h"
#include "NewGamePlayerBag.h"
#include "NewPetScene.h"

class PlayerSkillInfo;
class PlayerInfoScene :
public NDCommonScene
{
	DECLARE_CLASS(PlayerInfoScene)
	
	PlayerInfoScene();
	
	~PlayerInfoScene();
	
public:
	
	static PlayerInfoScene* Scene();
	
	static CUIPet* QueryPetScene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void DrawRole(bool draw, CGPoint pos=CGPointZero);
		
private:
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex); override
	
private:
	void InitBag(NDUIClientLayer* client);
	
	void InitAttr(NDUIClientLayer* client);
	
	//void InitTask(NDUIClientLayer* client);
	void InitPet(NDUIClientLayer* client);
	
	void InitSkill(NDUIClientLayer* client);
	
	void InitFarm(NDUIClientLayer* client);
	
	
	GameRoleNode	*m_GameRoleNode;
	PlayerSkillInfo* m_skillTab;
	
	bool m_hasGetFarmInfo;
	//bool m_hasGetCanAcceptTask;
	
	CUIPet* m_pUiPet;
};

#endif // _PLAYER_INFO_SCENE_H_
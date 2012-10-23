/*
 *  PlayerNpcListScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PLAYER_NPC_LIST_SCENE_H_
#define _PLAYER_NPC_LIST_SCENE_H_

#include "NDCommonScene.h"
#include "PlayerNpcListLayers.h"

class PlayerNpcListScene :
public NDCommonScene
{
	DECLARE_CLASS(PlayerNpcListScene)
	
public:	
	PlayerNpcListScene();
	
	~PlayerNpcListScene();
	
	void OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex);
	void OnTabLayerClick(TabLayer* tab, uint curIndex);
	
	static PlayerNpcListScene* Scene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void RefreshPlayerControl(int idPlayer);
	
	void RemoveNpcControlLayer();
	
private:
	NDFuncTab* m_tabFunc;
	
	NpcListLayer* m_npcList;
	
	NDUILayer* m_layerNpcControl;
	
	NDUILayer* m_layerPlayerControl;
	
	PlayerListLayer* m_playerList;
	
private:
	void InitPlayerNpcList(NDUIClientLayer* client);
	
	void InitPlayerList();
};

#endif // _PLAYER_INFO_SCENE_H_
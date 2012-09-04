/*
 *  DramaScene.h
 *  SMYS
 *
 *  Created by jhzheng on 12-4-19.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _DRAMA_SCENE_H_ZJH_
#define _DRAMA_SCENE_H_ZJH_

#include "NDScene.h"
#include "NDMapLayer.h"
#include "NDNpc.h"
#include "NDManualRole.h"
#include "NDMonster.h"
#include "DramaUI.h"
#include "DramaTransitionScene.h"
#include <map>

using namespace NDEngine;

///////////////////////////////////////////////
class DramaScene: public NDScene, public NDUITargetDelegate
{
	DECLARE_CLASS (DramaScene)

	DramaScene();
	~DramaScene();

public:
	void Init(int nMapId);

	bool SetCenter(CGPoint pos);

	CGPoint GetCenter();

	bool AddMonster(int nKey, int nLookFace);

	bool AddNpc(int nKey, int nLookFace);

	bool AddManuRole(int nKey, int nLookFace);

	bool AddSprite(int nKey, std::string filename);

	NDManualRole* GetManuRole(int nKey);

	NDMonster* GetMonster(int nKey);

	NDNpc* GetNpc(int nKey);

	NDSprite* GetSprite(int nKey);

	bool RemoveSprite(int nKey);

	bool PushScene(int nKey, DramaTransitionScene* scene);

	DramaTransitionScene* GetScene(int nKey);

	bool RemoveScene(int nKey);

	void OpenChat(bool bLeft);

	void CloseChat(bool bLeft);

	void SetChatFigure(bool bLeft, std::string filename, bool bReverse);

	void SetChatTitle(bool bLeft, std::string title, int nFontSize,
			int nFontColor);

	void SetChatTitleBySpriteKey(bool bLeft, int nKey, int nFontSize,
			int nFontColor);

	void SetChatContent(bool bLeft, std::string content, int nFontSize,
			int nFontColor);

	void ShowTipDlg(std::string content);

	bool ConsumeClick();

private:
	typedef std::map<int, NDManualRole*> MAP_MANUROLE;
	typedef MAP_MANUROLE::iterator MAP_MANUROLE_IT;

	typedef std::map<int, NDMonster*> MAP_MONSTER;
	typedef MAP_MONSTER::iterator MAP_MONSTER_IT;

	typedef std::map<int, NDNpc*> MAP_NPC;
	typedef MAP_NPC::iterator MAP_NPC_IT;

	typedef std::map<int, NDSprite*> MAP_SPRITE;
	typedef MAP_SPRITE::iterator MAP_SPRITE_IT;

	typedef std::map<int, CAutoLink<DramaTransitionScene> > MAP_SCENE;
	typedef MAP_SCENE::iterator MAP_SCENE_IT;

	NDMapLayer* m_layerMap;
	MAP_MANUROLE m_mapManuRole;
	MAP_MONSTER m_mapMonster;
	MAP_NPC m_mapNpc;
	MAP_SPRITE m_mapSprite;
	MAP_SCENE m_mapScene;

	DramaConfirmdlg* m_dlgConfirm;
	DramaChatLayer* m_chatlayerLeft;
	DramaChatLayer* m_chatlayerRight;
	bool m_bProductClick;

private:
	bool AddNodeToMap(NDNode* node);
	bool RemoveNodeFromMap(NDNode* node);

	bool RemoveNode(NDNode* node);
	bool RemoveSpriteNode(NDNode* node);
	bool RemoveNpcNode(NDNode* node);
	bool RemoveManuroleNode(NDNode* node);
	bool RemoveMonsterNode(NDNode* node);

	void ProductClick();

public:
	virtual bool OnTargetBtnEvent(NDUINode* uinode, int targetEvent);
};

#endif // _DRAMA_SCENE_H_ZJH_

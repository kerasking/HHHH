//
//  SMBattleScene.mm
//  SMYS
//
//  Created by cl on 12-2-29.
//  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
//


#include "SMBattleScene.h"
#include "NDDirector.h"
#include "NDMapLayerLogic.h"
#include "NDConstant.h"


IMPLEMENT_CLASS(CSMBattleScene, NDScene)

CSMBattleScene* CSMBattleScene::Scene()
{
	CSMBattleScene *scene = new CSMBattleScene;
	return scene;
}

CSMBattleScene::CSMBattleScene()
{
	m_mapLayer	= NULL;
}

CSMBattleScene::~CSMBattleScene()
{
}

void CSMBattleScene::Initialization(int mapID)
{
	NDScene::Initialization();
	
	CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_mapLayer = new NDMapLayerLogic();
	m_mapLayer->Initialization(mapID); 
	AddChild(m_mapLayer, MAPLAYER_Z, BATTLEMAPLAYER_TAG);
}

CCSize CSMBattleScene::GetSize()
{
	return m_mapLayer->GetContentSize();
}

cocos2d::CCArray* CSMBattleScene::GetSwitchs()
{
	return m_mapLayer->GetMapData()->getSwitchs();
}
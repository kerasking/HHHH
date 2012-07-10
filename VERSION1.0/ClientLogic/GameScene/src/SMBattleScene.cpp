//
//  SMBattleScene.mm
//  SMYS
//
//  Created by cl on 12-2-29.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_mapLayer = new NDMapLayerLogic();
	m_mapLayer->Initialization(mapID); 
	this->AddChild(m_mapLayer, MAPLAYER_Z, BATTLEMAPLAYER_TAG);
}

CGSize CSMBattleScene::GetSize()
{
	return this->m_mapLayer->GetContentSize();
}

cocos2d::CCArray* CSMBattleScene::GetSwitchs()
{
	return this->m_mapLayer->GetMapData()->getSwitchs();
}
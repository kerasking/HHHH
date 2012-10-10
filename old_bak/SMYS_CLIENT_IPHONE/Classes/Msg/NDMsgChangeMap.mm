/*
 *  NDMsgChangeMap.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgChangeMap.h"
#include "NDDirector.h"
#include "NDPlayer.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#include "NDUISceneLoadingLayer.h"

using namespace NDEngine;

void NDMsgChangeMap::Process(NDTransData* data, int len)
{
	data->ReadShort(); // 没有用到
	data->ReadInt(); // 没有用到
	int mapId = data->ReadInt();
	
	data->ReadInt(); // 没有用到
	int dwPortalX = data->ReadShort();
	int dwPortalY = data->ReadShort();
	data->ReadShort(); // 没有用到
	data->ReadShort(); // 没有用到
	data->ReadShort(); // 没有用到
	data->ReadShort(); // 没有用到
	int type = data->ReadInt(); // 没有用到
	data->ReadUnicodeString(); // 没有用到
	

	if (NDPlayer::defaultHero().GetParent() != NULL) 
	{
		NDPlayer::defaultHero().RemoveFromParent(false);
	}
	
	NDScene* aScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (aScene) 
	{
		aScene->RemoveChild(NDUISceneLoadingLayer::DefaultLayer(), false);
	}
	
	NDMapMgrObj.ClearNpc();
	NDMapMgrObj.ClearMonster();
	
	NDMapMgrObj.loadSceneByMapID(mapId);
	
	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene( NDDirector::DefaultDirector()->GetRunningScene());
	if (!layer) 
	{
		return;
	}
	
	//NSLog(@"%d", layer->GetChildren().size()); 
	
	NDPlayer::defaultHero().stopMoving();
	NDPlayer::defaultHero().SetPosition(ccp(dwPortalX*16+8, dwPortalY*16+8));
	
	layer->AddChild(&(NDPlayer::defaultHero()));
	layer->SetScreenCenter(ccp(dwPortalX*16+8, dwPortalY*16+8));
	
	NDPlayer::defaultHero().SetLoadMapComplete();
}
//
//  NDScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDScene.h"
namespace NDEngine
{
	IMPLEMENT_CLASS(NDScene, NDNode)
	
	
	NDScene::NDScene()
	{	
		
	}
	
	NDScene::~NDScene()
	{
		
	}
	
	NDScene* NDScene::Scene()
	{
		NDScene *scene = new NDScene();
		scene->Initialization();
		return scene;
	}
}
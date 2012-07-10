//
//  SMYSAppDelegate.m
//  SMYS
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SMYSAppDelegate.h"
#import "NDDirector.h"
#import "NDDataTransThread.h"
#import "KHttp.h"
#import <string>
#import "LoginScene.h"
#import "InitMenuScene.h"
#import "CreateRoleScene.h"
#include "NDTransData.h"
#include "WorldMapScene.h"
#include "RobotScene.h"
#include "TestScene.h"
#include "TestNewUI.h"
#include "BattleFieldScene.h"
#include "ScriptInc.h"
#include "NDBeforeGameMgr.h"
#include "GameSceneLoading.h"
#include "ScriptGlobalEvent.h"
#include "SMLoginScene.h"
#define ENABLE_NDCP_CUSTOM_LOGIN_EXTENT 1
#import <NdComPlatform/NdComPlatform.h>
#import	"NDPath.h"
//#import <RootViewController.h>
#include "NDDataTransThread.h"
#include "TestSceneZJH.h"
using namespace NDEngine;

NSAutoreleasePool *g_pool = [[NSAutoreleasePool alloc] init];	

@implementation SMYSAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
	UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = YES;
    
	// Obtain the shared director in order to...
	NDDirector* director = NDDirector::DefaultDirector();

	// Init game
	director->Initialization();
	
	// Turn on display FPS
	//director->SetDisplayFPS(true);
	
#ifdef USE_NDSDK
	// call after [window makeKeyAndVisible];
	[[NdComPlatform defaultPlatform] setAppId:100214];
	[[NdComPlatform defaultPlatform] setAppKey:@"0d80bf2b87cb08af6c4a52ce1d76485ecb23d8c02693ce76"];
	[NdComPlatform defaultPlatform].showLoadingWhenAutoLogin = NO;
	[[NdComPlatform defaultPlatform] NdSetScreenOrientation:UIInterfaceOrientationLandscapeRight];
#endif
	
	
#if USE_ROBOT == 1
	director->RunScene(RobotScene::Scene());
#else
	//director->RunScene(TestScene::Scene());
	//return;
	//Run the first scene
	//director->RunScene(InitMenuScene::Scene());
	//director->RunScene(BattleFieldScene::Scene());
    director->RunScene(CSMLoginScene::Scene());
#endif
	// load script;
	ScriptMgrObj.Load();
	
	//{
//		NDBeforeGameMgrObj.SetUserName("tcp0815");
//		NDBeforeGameMgrObj.SetPassWord("1");
	

//		NDBeforeGameMgrObj.SetUserName("tcp0815");
//
//		NDBeforeGameMgrObj.SetPassWord("1");
//
//		NDBeforeGameMgrObj.SetServerInfo("192.168.9.104","server05","server05",5877);
//		NDBeforeGameMgrObj.SetServerInfo("192.168.9.104","server03","server03",5877);
	
		//test
//		NDDataTransThread::DefaultThread()->Start(NDBeforeGameMgrObj.GetServerIP().c_str(), NDBeforeGameMgrObj.GetServerPort());
//		if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//		{
			//if (failBackToMenu)
//				NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
//			return false;
//			exit(0);
//		}
		
//		NDBeforeGameMgrObj.Login();
		//test end
//		LoginType logintype = LoginTypeFirst;
//		NDDirector::DefaultDirector()->RunScene(GameSceneLoading::Scene(true, logintype));
//
//	}
	
	
   //     NDScene* pLoginSence = CSMLoginScene::Scene();
      //  NDDirector::DefaultDirector()->RunScene(pLoginSence);
        ScriptGlobalEvent::OnEvent(GE_LOGIN_GAME);
		//LoginType logintype = LoginTypeFirst;
		//NDDirector::DefaultDirector()->RunScene(GameSceneLoading::Scene(true, logintype));
	//}
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
	NDDirector::DefaultDirector()->Pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	NDDirector::DefaultDirector()->Resume();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	NDDirector::DefaultDirector()->PurgeCachedData();
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	NDDirector::DefaultDirector()->Stop();
	
	[g_pool release];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NDDirector::DefaultDirector()->StopAnimation();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NDDirector::DefaultDirector()->StartAnimation();
}

- (void)dealloc 
{
	delete NDDirector::DefaultDirector();
	[super dealloc];
}

@end

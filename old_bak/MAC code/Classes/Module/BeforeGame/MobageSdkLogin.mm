/*
 *  NDSdkLogin.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "MobageSdkLogin.h"
#import "ScriptGlobalEvent.h"
#import "NDDirector.h"
#ifdef USE_MGSDK
#import "MobageViewController.h"
#import "MBGPlatform.h"
#endif
#import "NDBeforeGameMgr.h"
#import "SMLoginScene.h"
#import "SMGameScene.h"


@implementation MobageSdkLogin

- (id)init
{
	if ((self = [super init])) 
	{
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)LoginWithUser
{
#if defined(USE_MGSDK)
    NDEngine::NDDirector* director = NDEngine::NDDirector::DefaultDirector();
    UIWindow* win = director->GetWindow();

    //MobageViewController* pMobageView = [MobageViewController sharedViewController];
    //win.rootViewController = pMobageView;
    //win.backgroundColor = [UIColor whiteColor];
    
    [[MBGPlatform sharedPlatform] setDelegate:self withWindow:win withRootViewController:win.rootViewController];

//    if ([MBGPlatform isProductionEnv]) {
//        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_PRODUCTION consumerKey:@"a96f124b22bd7ccd7a4a" consumerSecret:@"1b72f31ec512c1e299d363842926f4884289694" appId:@"13000194"];
//    } else {
//        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_SANDBOX consumerKey:@"a96f124b22bd7ccd7a4a" consumerSecret:@"1b72f31ec512c1e299d363842926f4884289694" appId:@"13000194"];
//    }
    if ([MBGPlatform isProductionEnv]) {
        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_PRODUCTION consumerKey:@"sdk_app_id:13000194" consumerSecret:@"c966082ce0ffed1dc4d73b757c35a00a" appId:@"13000194"];
    }else {
        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_SANDBOX consumerKey:@"sdk_app_id:13000194" consumerSecret:@"2fb0c33d5b1461cf1ae70e3fe7c9d79b" appId:@"13000194"];
    }
    
//    if ([MBGPlatform isProductionEnv]) {
//        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_PRODUCTION consumerKey:@"sdk_app_id:13000156" consumerSecret:@"cf1292dfff4c951766443f9b82f29769" appId:@"13000156"];
//    }else {
//        [MBGPlatform initialize:MBG_REGION_CN serverType:MBG_SANDBOX consumerKey:@"sdk_app_id:13000156" consumerSecret:@"9cb5c03580e97ebc96b14b22d7900566" appId:@"13000156"];
//    }
    [MBGPlatform registerTick];
    [[MBGPlatform sharedPlatform] checkLoginStatus];
#endif
}

- (void) onLoginComplete:(NSString *)userId {
	NSLog(@"app delegate onLoginComplete userId %@", userId);
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	mgr.SetCurrentUser([userId intValue]);
    //ScriptGlobalEvent::OnEvent(GE_LOGINOK_NORMAL, [userId intValue]);
    CSMGameScene * pGameScene = (CSMGameScene *)NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
    if ( pGameScene )
    {
        ScriptMgrObj.excuteLuaFunc( "SetAccountID", "Login_ServerUI", [userId intValue] );
        quitGame();
        return;
    }
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
        if( pScene->GetChild( 2068 ) )//Login_ServerUI
        {
            ScriptMgrObj.excuteLuaFunc( "LoginOK_Normal", "Login_ServerUI", [userId intValue] );
            return;
        }
        else
			return pScene->OnEvent_LoginOKGuest([userId intValue]);
	}
}
- (void) onLoginRequired {
	NSLog(@"app delegate showLoginDialog");
    [[MBGPlatform sharedPlatform] showLoginDialog];
}
- (void) onLoginError:(MBGError *)error {
	NSLog(@"app delegate onLoginError %@", error.description);
    //ScriptGlobalEvent::OnEvent(GE_LOGINERROR, error.code);
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
		return pScene->OnEvent_LoginError(error.code);
	}
}
- (void) onSplashComplete {
	NSLog(@"app delegate hideSplashScreen");
    
    [[MBGPlatform sharedPlatform] hideSplashScreen];
}
@end


//
//  TQDelegate.m
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
//#include "RobotScene.h"
#include "TestScene.h"
#include "TestNewUI.h"
#include "BattleFieldScene.h"
#include "ScriptInc.h"
#include "NDBeforeGameMgr.h"
#include "GameSceneLoading.h"
#include "ScriptGlobalEvent.h"
#include "SMLoginScene.h"

#ifdef USE_NDSDK
#import <NdComPlatform/NdComPlatform.h>
#import <NdComPlatform/NdComPlatformAPIResponse.h>
#import <NdComPlatform/NdCPNotifications.h>
#import "ND91SDKViewController.h"
#endif

#ifdef USE_MGSDK
#import "MBGPlatform.h"
#import "MobageViewController.h"
#endif

#import	"NDPath.h"
#include "NDDataTransThread.h"
#include "TestSceneZJH.h"
#include "SqliteDBMgr.h"
#include "NDMapMgr.h"
#include "GameApp.h"
#include "NDUtility.h"
#import "CCDirectorIOS.h"
using namespace NDEngine;
NSAutoreleasePool *globalPool = [[NSAutoreleasePool alloc] init];
@implementation TQDelegate

@synthesize window;
/*
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	//extern void TQDelegate_Init(UIApplication* pApplication);
	TQDelegate_Init(application);
    return YES;
}
*/
- (void)applicationDidFinishLaunching:(UIApplication*)application
{
    //游戏启动把图标badge标志置空
    [application setApplicationIconBadgeNumber:nil];
    //定义接收push类型
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationType)(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];     
    //注销所有的本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
    //extern void TQDelegate_Init(UIApplication* pApplication);
	//TQDelegate_Init(application);
	//TQDelegate_Init(application);
    //TQDelegate_Init(application);
	UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = YES;
    
	// Obtain the shared director in order to...
	NDDirector* director = NDDirector::DefaultDirector();

	// Init game
	director->Initialization();
	
	// Turn on display FPS
	director->SetDisplayFPS(false);
	
#ifdef USE_NDSDK
	// call after [window makeKeyAndVisible];
	[[NdComPlatform defaultPlatform] setAppId:105433];
	[[NdComPlatform defaultPlatform] setAppKey:@"0c3f30337a8bb5506f9125b8aa8a5a1b98b9415a9514dda3"];
	[NdComPlatform defaultPlatform].showLoadingWhenAutoLogin = NO;
	[[NdComPlatform defaultPlatform] NdSetScreenOrientation:UIInterfaceOrientationLandscapeRight];
    [[NdComPlatform defaultPlatform] NdSetDebugMode:0];
    
    //NDEngine::NDDirector* director = NDEngine::NDDirector::DefaultDirector();
    UIWindow* win = director->GetWindow();
    if(win.rootViewController != nil) {
        return;
    }
    ND91SDKViewController* pND91SDKView = [ND91SDKViewController sharedViewController];
    win.rootViewController = pND91SDKView;
    win.backgroundColor = [UIColor whiteColor];
    
#endif
#ifdef USE_MGSDK
    UIWindow* win = director->GetWindow();
    if(win.rootViewController != nil) {
        return;
    }
    MobageViewController* pMobageView = [MobageViewController sharedViewController];
    win.rootViewController = pMobageView;
    win.backgroundColor = [UIColor whiteColor];
#endif
	
	//
    
	// load script;
    InitGameInstance();
    //首次运行的资源初始，
	//++
    director->RunScene( CSMLoginScene::Scene(true) );//版本更新在此
	/*HJQ MOD*/
//#ifdef UPDATE_RES
//    ScriptGlobalEvent::OnEvent(GE_UPDATE_GAME);//++Guosen 2012.8.2--
//#else
//    ScriptGlobalEvent::OnEvent(GE_LOGIN_GAME);//--Guosen 2012.8.2--
//#endif

	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(orientationChanged:) 
												 name:UIDeviceOrientationDidChangeNotification 
											   object:nil];
}
//iphone从apns服务器获取devicetoken后激活该方法
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //NSLog(@"My token is: %@", deviceToken);
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]; //去掉"<>"
    token = [[token description] stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉中间空格
    //const char *szTokenDevice = (char*) [token UTF8String];
    //ScriptMgrObj.excuteLuaFunc( "setMobileKey", "MsgLoginSuc" ,szTokenDevice);//++Guosen 2012.8.15 登录成功后发送消息放在
    NDBeforeGameMgrObj.SetDeviceToken( [token UTF8String] );
    NSLog(@"deviceToken: %@", token);
}
//注册push失败后返回错误信息，执行相应处理
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#ifdef USE_MGSDK
    [MBGPlatform pause];
#endif
	NDDirector::DefaultDirector()->StopAnimation();
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#ifdef USE_MGSDK
    [MBGPlatform resume];
#endif
	NDDirector::DefaultDirector()->StartAnimation();
    if (NDDataTransThread::DefaultThread()->GetQuitGame())
    {
        quitGame();
        NDDataTransThread::DefaultThread()->Stop();
        NDDataTransThread::ResetDefaultThread();
    }
}

- (void)dealloc 
{
    //[globalPool release];
    [globalPool release];
	delete NDDirector::DefaultDirector();
	[super dealloc];
}

// tell the director that the orientation has changed
-(void) orientationChanged:(NSNotification *)notification
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    ccDeviceOrientation cor = (ccDeviceOrientation)orientation;
    if (cor == (ccDeviceOrientation)UIDeviceOrientationLandscapeLeft)
    {
        [[CCDirector sharedDirector]setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
    }
    if (cor == (ccDeviceOrientation)UIDeviceOrientationLandscapeRight) {
        [[CCDirector sharedDirector]setDeviceOrientation:CCDeviceOrientationLandscapeRight];
    }
}
@end
int EndGameInstance()
{
	return 0;
}

//----------------------------------------


int InitGameInstance()//该函数在其他地方有调用到……
{
    CSqliteDBMgr::shareInstance().InitDataBase("DNSG.sqlite");
    GetLocalLanguage();
	NDMapMgrObj;
    BattleMgrObj;
	//ChatManager chatManager;
	//ItemMgr itemMgr;//mian.mm里已有
    NDColorPoolObj;
	//NDColorPool colorPool;//NDColorPoolObj也是
	//NDDataPersist::LoadGameSetting();//mian.mm里已有
	//NDFarmMgrObj;
	//BattleFieldMgrObj;
	//NDLocalXmlString::GetSingleton().LoadData();//载入文字资源//--改为在SMLoginScene里执行
    //ScriptMgrObj.Load();//--改为在SMLoginScene里执行
    //ScriptMgrObj.excuteLuaFunc( "LoadData", "GameSetting" );//载入游戏设置//--改为在SMLoginScene里执行
    NDBeforeGameMgrObj.InitAccountTable();
    return 0;
}
/*
int RegisterLocalNotification()
{
    //定义本地通知
    UILocalNotification *notification=[[UILocalNotification alloc] init]; 
    if (notification!=nil) 
    { 
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *noticeDate = @"2012-09-13 22:44:30";
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //设置触发时间
        notification.fireDate = [formatter dateFromString:noticeDate];
        [formatter release];
        //NSDate *now=[NSDate new]; 
        //notification.fireDate=[now addTimeInterval:10]; 
        notification.timeZone=[NSTimeZone defaultTimeZone]; 
        notification.applicationIconBadgeNumber = 1;
        notification.alertBody=@"服务器正式开启，大家一起来吧"; 
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}
*/
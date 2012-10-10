//
//  main.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>



#ifdef DEBUG
#define VALGRIND "/usr/local/bin/valgrind"
#endif

#undef VALGRIND

#include "NDLocalXmlString.h"
#include "NDMapMgr.h"
#include "BattleMgr.h"
#include "ItemMgr.h"
#include "NDDataPersist.h"
#include "cpLog.h"
#include "NDColorPool.h"
#include "NDUtility.h"
#include "FarmMgr.h"
#include "BattleFieldMgr.h"
#include "NDCrashUpload.h"

int main_g(int argc, char *argv[]) 
{

// memory check
#ifdef VALGRIND
	if (argc < 2 || (argc >=2 && strcmp(argv[1], "-valgrind") != 0)) {
		execl(VALGRIND, VALGRIND, 
			  "--leak-check=summary",
			  "--show-reachable=yes",
			  "--undef-value-errors=no",
			  argv[0], "-valgrind", NULL);
	}
#endif
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];		
	
#ifndef DEBUG
	if (![[NDCrashUpload Shared] EnableCrashCatch])
		NSLog(@"EnableCrashCatch failed!");
#endif
	
	// 获取本地化语言
	GetLocalLanguage();
	
	NDLocalXmlString::GetSingleton();
	
	NDEngine::NDMapMgr dataObj;
	BattleMgr battleMgr;
	//ChatManager chatManager;
	ItemMgr itemMgr;
	NDColorPool colorPool;
	NDDataPersist::LoadGameSetting();
	NDFarmMgrObj;
	BattleFieldMgrObj;
	
////////////////////////////////////////////
//
//	－－日志记录－－
//	作用：程序运行过程中不管时debug版本还是release版本都可以通过cpLog函数来记录日志
//	记录日志的方式：
//		在xcode的工程宏定义配置宏CPLOG
//		如果CPLOG＝0，不记录任何日志
//		如果CPLOG＝1，日志记录将发回cplogX服务器，服务器地址需修改代码
//		如果CPLOG＝2，日志记录于设备的"/tmp/DragonDrive.log"中，只记录程序最后一次运行的日志
//		如果CPLOG＝3，设备和服务器同时记录日志
//	注意：发布版本一定要关闭所有日志，即CPLOG＝0
//	...
#if CPLOG & 0x01 
	// cplog默认服务器
	NDDataPersist data;
	if (strlen(data.GetData(kCpLogData, kCpLogServerIP)) == 0 || strlen(data.GetData(kCpLogData, kCpLogServerPort)) == 0) {
		data.SetData(kCpLogData, kCpLogServerIP, "192.168.55.176");
		data.SetData(kCpLogData, kCpLogServerPort, "2046");
		data.SaveData();
	}
	
	cpLogEnable(true);
	cpLogSetPriority(LOG_DEBUG);
	KNetworkAddress addr("192.168.55.176", 2046);
	//KNetworkAddress addr(data.GetData(kCpLogData, kCpLogServerIP), atoi(data.GetData(kCpLogData, kCpLogServerPort)));
	cpLogConnServer(addr);
#endif
	
#if CPLOG & 0x02 
	cpLogEnable(true);
	cpLogSetPriority(LOG_DEBUG);
	cpLogOpen("/tmp/DragonDrive.log");
#endif
//	－－－－－－－－
////////////////////////////////////////////
	int retVal = UIApplicationMain(argc, argv, nil, @"TQDelegate");
	[pool release];
	
	[globalPool release];
	
	return retVal;
}

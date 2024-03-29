//
//  NDBaseDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDNode.h"
#import "NDBaseDirector.h"
#import "NDScene.h"
#import "NDDirector.h"
#import "NDLayer.h"
#import "NDMessageCenter.h"
#import "NDTransData.h"
#import "NDMapMgr.h"
//#import "RobotScene.h"
//#import "RobotMgr.h"
#import "NDNetMsg.h"
#import <string>
#import <vector>
#import "Performance.h"
#import "ScriptMgr.h"
#include "ScriptGameData.h"
#include "I_Analyst.h"

// 帧数限制开关
#define FRAME_LIMIT_SWITCH 1

// 帧数限制:每秒跑24帧
#define FRAME_LIMIT (24) 

#if FRAME_LIMIT_SWITCH == 1
#define FRAME_CACULATION \
		do{ \
		static NSTimeInterval frameBegin = 0.0f, frameEnd = 0.0f; \
		frameEnd = [NSDate timeIntervalSinceReferenceDate]; \
		if (frameBegin != 0.0f){ \
		NSTimeInterval limit = 1.0f / FRAME_LIMIT; \
		NSTimeInterval frame = frameEnd - frameBegin; \
		if (frame < limit) \
		usleep((limit-frame)*1000000); } \
		frameBegin = [NSDate timeIntervalSinceReferenceDate]; \
		} while (0)
#else
#define FRAME_CACULATION
#endif

#define PERFORMANCE_DEBUG_SWITCH 0

#if PERFORMANCE_DEBUG_SWITCH == 1
#define PERFORMANCE_DEBUG_1												\
		static NDPerformance::key64 key;								\
		PerformanceTest.EndTestModule(key);								\
		PerformanceEnd;													\
		PerformanceStart;												\
		PerformanceTestBeginName("消息处理");							
		
#define PERFORMANCE_DEBUG_2												\
		PerformanceTestEndName("消息处理");								\
		PerformanceTestBeginName("游戏场景");								
	
#define PERFORMANCE_DEBUG_3												\
		PerformanceTestEndName("游戏场景");								\
		PerformanceTest.BeginTestModule("游戏帧调用间隔", key);
#else
#define PERFORMANCE_DEBUG_1	

#define PERFORMANCE_DEBUG_2	

#define PERFORMANCE_DEBUG_3
#endif

using namespace NDEngine;

@implementation CCDirectorDisplayLink(ND)

- (void)dispatchOneMessage
{		
#if USE_ROBOT == 1
	//RobotMgrObj.Update();
#else
    TICK_ANALYST(ANALYST_MSG_PROCESS);
    
	static NDTransData bao;
	//NDTransData* data = NDMessageCenter::DefaultMessageCenter()->GetMessage();
	for (int n = 0; n < 10; n++) 
	{
		if (NDNetMsgMgr::GetSingleton().GetServerMsgPacket(bao))
		{
			NDNetMsgPoolObj.Process(&bao);
			if ( (bao.GetCode() != _MSG_WALK)			&& 
				 (bao.GetCode() != _MSG_PLAYER_EXT)		&&
				 (bao.GetCode() != _MSG_TALK)	
				 )
				 break;
			//NDMessageCenter::DefaultMessageCenter()->DelMessage();
			//delete data;
		}
		else 
		{
			break;
		}
	}
	
#endif
}

- (void)OnIdle
{
    TICK_ANALYST(ANALYST_IDLE);
	ScriptMgrObj.update();
}


- (void)drawScene
{

#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_1
#endif
	
	[self OnIdle];
	[self dispatchOneMessage];
	
#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_2
#endif
	NDDirector::DefaultDirector()->DisibleScissor();
    
    TICK_ANALYST(ANALYST_DRAW_SCENE);
    
	FRAME_CACULATION;

    if (NDDataTransThread::DefaultThread()->GetQuitGame())
    {
        if ( NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG) )//++Guosen 2012.8.5
        {
            quitGame();
            //ScriptGameDataObj.DelAllData();
        }
        NDDataTransThread::DefaultThread()->SetQuitGame(false);
    }
    else {
        [super drawScene];
    }
	
#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_3
#endif

#ifdef DEBUG
	static unsigned int s_frameCount = 0;
	s_frameCount++;
	if ( ( s_frameCount % (8 * 24) ) == 0 )
	{
		NDNetMsgMgr::GetSingleton().Report();
	}
	
    static struct timeval lastLog_;
    struct timeval now;
    gettimeofday( &now, NULL);
    if( ((now.tv_sec - lastLog_.tv_sec)*10 + (now.tv_usec - lastLog_.tv_usec) / 100000.0f) >= 100) //10s
    {
        Analyst()->OnTimer();
        lastLog_ = now;
    }
#endif
}

@end

//@implementation CCTimerDirector(ND)
//
//- (void)drawScene
//{
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_1
//#endif
//
//	[self dispatchOneMessage];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_2
//#endif
//	
//	FRAME_CACULATION;
//	
//	[super drawScene];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_3
//#endif
//
//#ifdef DEBUG
//	static unsigned int s_frameCount = 0;
//	s_frameCount++;
//	if ( ( s_frameCount % (8 * 24) ) == 0 )
//	{
//		NDNetMsgMgr::GetSingleton().Report();
//	}
//#endif
//}
//
//@end

//@implementation CCDisplayLinkDirector(ND)
//
//- (void)drawScene
//{
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_1
//#endif
//	
//	[self dispatchOneMessage];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_2
//#endif
//	
//	FRAME_CACULATION;
//	
//	[super drawScene];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_3
//#endif
//
//#ifdef DEBUG
//	static unsigned int s_frameCount = 0;
//	s_frameCount++;
//	if ( ( s_frameCount % (8 * 24) ) == 0 )
//	{
//		NDNetMsgMgr::GetSingleton().Report();
//	}
//#endif
//}
//
//@end

//@implementation CCFastDirector(ND)
//
//- (void)drawScene
//{
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_1
//#endif
//	
//	[self dispatchOneMessage];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_2
//#endif
//
//	FRAME_CACULATION;
//
//	[super drawScene];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_3
//#endif
//
//#ifdef DEBUG
//	static unsigned int s_frameCount = 0;
//	s_frameCount++;
//	if ( ( s_frameCount % (8 * 24) ) == 0 )
//	{
//		NDNetMsgMgr::GetSingleton().Report();
//	}
//#endif
//}
//
//@end

//@implementation CCThreadedFastDirector(ND)
//
//- (void)drawScene
//{
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_1
//#endif
//
//	[self dispatchOneMessage];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_2
//#endif	
//	
//	FRAME_CACULATION;
//	
//	[super drawScene];
//	
//#ifdef VIEW_PERFORMACE
//	PERFORMANCE_DEBUG_3
//#endif
//
//#ifdef DEBUG
//	static unsigned int s_frameCount = 0;
//	s_frameCount++;
//	if ( ( s_frameCount % (8 * 24) ) == 0 )
//	{
//		NDNetMsgMgr::GetSingleton().Report();
//	}
//#endif
//}
//
//@end

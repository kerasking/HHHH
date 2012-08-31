//
//  NDBaseDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 (缃戦緳)DeNA. All rights reserved.
//

#include "NDBaseDirector.h"
#include "NDDirector.h"
#include <string>
#include <vector>
#include "ScriptMgr.h"

// 甯ф暟闄愬埗寮�鍏�
#define FRAME_LIMIT_SWITCH 1

// 甯ф暟闄愬埗:姣忕璺�甯�
#define FRAME_LIMIT (24) ssss

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
		PerformanceTestBeginName("娑堟伅澶勭悊");							

#define PERFORMANCE_DEBUG_2												\
		PerformanceTestEndName("娑堟伅澶勭悊");								\
		PerformanceTestBeginName("娓告垙鍦烘櫙");								

#define PERFORMANCE_DEBUG_3												\
		PerformanceTestEndName("娓告垙鍦烘櫙");								\
		PerformanceTest.BeginTestModule("娓告垙甯ц皟鐢ㄩ棿闅�", key);
#else
#define PERFORMANCE_DEBUG_1	

#define PERFORMANCE_DEBUG_2	

#define PERFORMANCE_DEBUG_3
#endif

using namespace NDEngine;

void NDBaseDirector::mainLoop(void)
{
	this->OnIdle();

	NDDirector::DefaultDirector()->DisibleScissor();

	CCDisplayLinkDirector::mainLoop();
}

void NDBaseDirector::OnIdle()
{
	ScriptMgrObj.update();
}

// - (void)dispatchOneMessage
// {		
// #if USE_ROBOT == 1
// 	RobotMgrObj.Update();
// #else
// 	NDTransData bao;
// 	//NDTransData* data = NDMessageCenter::DefaultMessageCenter()->GetMessage();
// 	for (int n = 0; n < 10; n++) 
// 	{
// 		if (NDNetMsgMgr::GetSingleton().GetServerMsgPacket(bao))
// 		{
// 			NDNetMsgPoolObj.Process(&bao);
// 			if ( (bao.GetCode() != _MSG_WALK)			&& 
// 				 (bao.GetCode() != _MSG_PLAYER_EXT)		&&
// 				 (bao.GetCode() != _MSG_TALK)	
// 				 )
// 				 break;
// 			//NDMessageCenter::DefaultMessageCenter()->DelMessage();
// 			//delete data;
// 		}
// 		else 
// 		{
// 			break;
// 		}
// 	}
// 	
// #endif
// }

// - (void)drawScene
// {
// #ifdef VIEW_PERFORMACE
// 	PERFORMANCE_DEBUG_1
// #endif
// 	
// 	[self OnIdle];
// 	[self dispatchOneMessage];
// 	
// #ifdef VIEW_PERFORMACE
// 	PERFORMANCE_DEBUG_2
// #endif
// 
// 	NDDirector::DefaultDirector()->DisibleScissor();
// 	
// 	FRAME_CACULATION;
// 	
// 	[super drawScene];
// 	
// #ifdef VIEW_PERFORMACE
// 	PERFORMANCE_DEBUG_3
// #endif
// 
// #ifdef DEBUG
// 	static unsigned int s_frameCount = 0;
// 	s_frameCount++;
// 	if ( ( s_frameCount % (8 * 24) ) == 0 )
// 	{
// 		NDNetMsgMgr::GetSingleton().Report();
// 	}
// #endif
// }

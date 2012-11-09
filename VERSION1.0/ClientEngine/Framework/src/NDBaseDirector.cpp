//
//  NDBaseDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDBaseDirector.h"
#include "NDDirector.h"
#include <string>
#include <vector>
#include <NDTransData.h>
#include "ScriptMgr.h"
#include <NDNetMsg.h>
#include <NDMessageCenter.h>
#include "NDDebugOpt.h"
#include "CCScheduler.h"
#include "NDBaseNetMgr.h"


// 帧数限制�??�??
#define FRAME_LIMIT_SWITCH 1

// 帧数限制:每秒�??�??
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
		PerformanceTestBeginName("消息处理");							

#define PERFORMANCE_DEBUG_2												\
		PerformanceTestEndName("消息处理");								\
		PerformanceTestBeginName("游戏场景");								

#define PERFORMANCE_DEBUG_3												\
		PerformanceTestEndName("游戏场景");								\
		PerformanceTest.BeginTestModule("游戏帧调用间�??", key);
#else
#define PERFORMANCE_DEBUG_1	

#define PERFORMANCE_DEBUG_2	

#define PERFORMANCE_DEBUG_3
#endif

using namespace NDEngine;

void NDBaseDirector::mainLoop(void)
{
	if (NDDebugOpt::getMainLoopEnabled())
	{
		this->OnIdle();

		if (NDDebugOpt::getNetworkEnabled())
		{
			this->DispatchOneMessage();
		}

		//NDDirector::DefaultDirector()->DisibleScissor(); // ��ʱ��ע�͵�

		CCScheduler::sharedScheduler()->setTickEnabled( NDDebugOpt::getTickEnabled() );

		CCDisplayLinkDirector::mainLoop();
	}
}

void NDBaseDirector::OnIdle()
{
	if (NDDebugOpt::getScriptEnabled())
		ScriptMgrObj.update();
}

void NDBaseDirector::DispatchOneMessage()
{
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
}

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

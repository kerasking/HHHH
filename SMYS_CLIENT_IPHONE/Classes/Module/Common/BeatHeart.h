/*
 *  BeatHeart.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BEAT_HEART_H_
#define _BEAT_HEART_H_

#include "Singleton.h"
#include "NDObject.h"
#include "NDNetMsg.h"
#include "NDTimer.h"

using namespace NDEngine;

#define BeatHeartMgrObj (NDBeatHeart::GetSingleton())

class NDBeatHeart :
public TSingleton<NDBeatHeart>,
public NDObject,
public NDMsgObject,
public ITimerCallback
{
	DECLARE_CLASS(NDBeatHeart)
	
public:
	
	NDBeatHeart();
	
	~NDBeatHeart();
	
	// 登录成功启动心跳
	void Start();
	
	// 退出游戏结束心跳
	void Stop();
	
	// 有服务端消息到达
	//void HadServerMsgArrive(); ///< 临时性注释 郭浩
	
	void OnTimer(OBJID tag); override
	
	bool process(MSGID msgID, NDTransData* data, int len); override

private:
	
	void reverseState();

	void resetBeatData();
	
	void AddTipCount();
	
private:

	bool m_bStart;
	
	NDTimer *m_timer;
	
	unsigned int m_uiSendBeatCount, m_uiHadTipCount;
};

#endif // _BEAT_HEART_H_
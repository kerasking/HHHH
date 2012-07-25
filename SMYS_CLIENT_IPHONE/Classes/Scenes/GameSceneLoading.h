//
//  GameSceneLoading.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#ifndef __GameSceneLoading_H
#define __GameSceneLoading_H

#include "NDScene.h"
#include "NDUILayer.h"
#include "NDUILabel.h"
#include "NDManualRole.h"
#include "NDTimer.h"
#include "GameSceneLoading.h"


typedef enum
{
	LoginTypeNone,		// 无
	LoginTypeFirst,		// 当前连接是cmwap,则先切换到cmnet,连接,失败则downloadlist,再失败报错
	LoginTypeSecond,    // 直接连接已有的, 失败报错
	//LoginTypeThird,		// 当前连接是cmwap,则先切换到cmnet,连接，失败报错
}LoginType;

using namespace NDEngine;	

/***
* 临时性注释 郭浩
* this class
*/
// class GameSceneLoading : public NDScene, ITimerCallback
// {
// 	DECLARE_CLASS(GameSceneLoading)
// 	GameSceneLoading();
// 	~GameSceneLoading();
// public:
// 	static GameSceneLoading* Scene(bool connect=false, LoginType login=LoginTypeNone);
// 	void Initialization(bool connect=false, LoginType login=LoginTypeNone); override		
// 	void draw(); override	
// 	void UpdateTitle(const string& strTitle);
// 	void OnTimer(OBJID tag);
// 	void CheckVersionSucess();
// private:
// 	void DealNet();
// 	bool Login(bool failBackToMenu);
// private:	
// 	NDUILayer* m_layer;
// 	NDUILabel* m_lbTitle;
// 	NDManualRole* m_tangRole;
// 	NDManualRole* m_suiRole;
// 	int interval;
// 	float x;
// 	NDTimer m_timer;
// 	NDTimer *m_timerNet;
// 	LoginType m_curLoginType;
// 	NDPicture *m_picBg;
// 	NDUIImage *m_imageProcess;
// 	
// };

#endif
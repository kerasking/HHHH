/*
 *  NDUISynLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-11.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __NDUI_SYN_LAYER_H__
#define __NDUI_SYN_LAYER_H__

#include "NDUILayer.h"
//#include "NDUtility.h"
#include "NDTimer.h"
#include "NDLightEffect.h"
#include <string>

namespace NDEngine
{
	enum SYN_TAG
	{
		CLOSE = 0,			// 直接关闭
		SYN_CREATE_ROLE,		// 创建角色等待
		SYN_FAST_REGISTER,		// 快速注册
		SYN_ENTER_BATTLE,		// 进入战斗
		SYN_NPC,				// npc交流相关
		SYN_RELIEVE,			// 复活
	};
	
	class NDScene;
	class NDUILabel;
	class NDUISynLayer : public NDUILayer//, public ITimerCallback
	{
		DECLARE_CLASS(NDUISynLayer)
		NDUISynLayer();
		~NDUISynLayer();		
	public:
		static void Show(SYN_TAG tag = CLOSE);
		static void Close(SYN_TAG tag = CLOSE);
		static bool IsShown();
		
		static void ShowWithTitle(std::string title);
		
		void SetTitle(std::string title);
		
		void SetTimeOut(float seconds);
		virtual void OnTimer(OBJID tag);
		
	public:
		SYN_TAG m_tag;
		void Initialization(); override
		void draw(); override
		
	private:
		/*
		CCTexture2D* m_texLine;
		CCTexture2D* m_texBlock;
		CGPoint m_ptLine;
		CGPoint m_ptBlock;
		GLfloat m_cyclePosX;
		*/
		NDTimer m_timer;
		/*
		NDUILabel *m_lbText;
		NDLightEffect *m_ShaLou;
		*/
	};
}

#endif
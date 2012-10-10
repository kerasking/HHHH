//
//  NDMessageCenter.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
/*
 消息队列
*/
	
#ifndef __NDMessageCenter_H
#define __NDMessageCenter_H

#include "NDObject.h"
#include <deque>
#include <string>
#include "NDTransData.h"
#include "CircleBuffer.h"
#include "KMutex.h"

namespace NDEngine
{
	class NDMessageCenter : public NDObject
	{
		DECLARE_CLASS(NDMessageCenter)
	public:
		NDMessageCenter();
		~NDMessageCenter();
		struct _transdata 
		{
			NDTransData* data;
		};
	public:
//		
//		函数：DefaultMessageCenter
//		作用：单例静态方法，成员方法的访问请都通过该接口先。
//		参数：无
//		返回值：本对象指针
		static NDMessageCenter* DefaultMessageCenter();		
//		
//		函数：AddMessage
//		作用：添加消息到消息列表
//		参数：data从服务器接收到的一条消息
//		返回值：无
		void AddMessage(NDTransData* data);
//		
//		函数：CanAddMessage
//		作用：判断队列是否可添加消息
//		参数：无
//		返回值：true可添加 false不可添加
		bool CanAddMessage();
		
//		函数：GetMessage
//		作用：从消息队列获取一条消息，获取完成队列将不再保存这条数据，交由外部负责清理对象
//		参数：无
//		返回值：失败返回null
		NDTransData* GetMessage();
		
		
		//void DelMessage();
	private:
		//std::deque<NDTransData*> m_messageQueue;
		CRingBuffer<_transdata> m_messageQueue;
	};
	
	#pragma mark 网络消息管理单例(支持多线程)
	
	// 描述:网络消息管理单例(支持多线程)
	// 提供增加网络原始数据功能
	// 提供获取服务器消息包功能
	// 提供增加回主界面消息包功能
	// 提供清除所有网络原始数据功能
	// 提供销毁本单例功能
	// 提供跟踪网络接收数据量功能
	// jhzhen 2011.12.1
	
	class NDNetMsgMgr
	{
		public:
			static NDNetMsgMgr&	GetSingleton();
			
			static void purge();
			
			~NDNetMsgMgr();
			
			bool AddNetRawData(const unsigned char* data, unsigned int uilen, bool net = true);
			
			bool GetServerMsgPacket(NDTransData& data);
			
			bool AddBackToMenuPacket();
			
			bool ClearNetRawData();
			
			void Report();
			
		private:
			CRingBuffer<unsigned char, 1046 * 256, 1046> m_buffer;
			
			unsigned int m_uiTotalValidRecv, m_uiTotalInvalidRecv;
			
			unsigned int m_uiTotalNetData;
			
			KMutex m_lockNetData;
		private:
			NDNetMsgMgr();
			
	};
	
}

#endif

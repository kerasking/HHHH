/******************************************************************************
 *  File Name:		NDDataTransThread.h
 *  Author:			Guosen
 *  Create Date:	2012-4-9
 *  
 *****************************************************************************/

#ifndef _NDDATATRANSTHREAD_H_2012_04_09_10_32_57_
#define _NDDATATRANSTHREAD_H_2012_04_09_10_32_57_
/////////////////////////////////////////////////////////////////////////////

#include "NDObject.h"
#include "NDSocket.h"
#include <vector>
#include <string>
#include <pthread.h>

/////////////////////////////////////////////////////////////////////////////
//
namespace NDEngine
{
	typedef enum
	{
		ThreadStatusStoped,
		ThreadStatusPaused,
		ThreadStatusRunning
	}ThreadStatus;
	
/*
 接收服务端数据的线程
 单例，
 */
	class NDDataTransThread : public NDObject
	{
		DECLARE_CLASS(NDDataTransThread)
		NDDataTransThread();
		~NDDataTransThread();

	public:
		//		函数：DefaultThread
		//		作用：单例方法，其他方法的调用入口在此
		//		参数：无
		//		返回值：		
		static NDDataTransThread* DefaultThread();
			
		//		函数：Start
		//		作用：启动线程
		//		参数：ipAddr服务器地址 port端口号
		//		返回值：无
		void Start(const char* ipAddr, int port);
		
		//		函数：Stop
		//		作用：停止线程
		//		参数：无
		//		返回值：无
		void Stop();
		
		//		函数：GetThreadStatus
		//		作用：获取线程状态
		//		参数：无
		//		返回值：无
		ThreadStatus GetThreadStatus();		

		//		函数：GetSocket
		//		作用：获取套接字，一般用来发送数据
		//		参数：无
		//		返回值：屏幕大小
		NDSocket* GetSocket();	
		
	public:
		//		函数：Execute
		//		作用：线程内部执行体， 外部无须关心
		//		参数：无
		//		返回值：屏幕大小
		void Execute();

	private:
		NDSocket* m_socket;
		ThreadStatus m_status, m_operate;	
		void WaitStatus(ThreadStatus status);
		void BlockDeal();
		void NotBlockDeal();
	};
}

/////////////////////////////////////////////////////////////////////////////
#endif //_NDDATATRANSTHREAD_H_2012_04_09_10_32_57_

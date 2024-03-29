/******************************************************************************
 *  File Name:		NDDataTransThread.cpp
 *  Author:			Guosen
 *  Create Date:	2012-4-9
 *
 *****************************************************************************/

#include "NDDataTransThread.h"
#include <NDMessageCenter.h>
#include "NDTransData.h"
#include "CCCommon.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "unistd.h"
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "unistd.h"
#endif  // CC_PLATFORM_ANDROID
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WOPHONE)
#endif  // CC_PLATFORM_WOPHONE
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MARMALADE)
#endif  // CC_PLATFORM_MARMALADE
#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
#endif  // CC_PLATFORM_LINUX
#if (CC_TARGET_PLATFORM == CC_PLATFORM_BADA)
#endif  // CC_PLATFORM_BADA
#if (CC_TARGET_PLATFORM == CC_PLATFORM_QNX)
#endif // CC_PLATFORM_QNX\

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

#include "define.h"

using namespace cocos2d;
/////////////////////////////////////////////////////////////////////////////

#define BLOCK_SOCKET (0)

//===========================================================================
namespace NDEngine
{
void* execThread(void* ptr)
{
	NDDataTransThread* thread = (NDDataTransThread*) ptr;
	if (thread)
	{
		thread->Execute();
	}
	return NULL;
}

IMPLEMENT_CLASS(NDDataTransThread, NDObject)

static NDDataTransThread* NDDataTransThread_dafaultThread = NULL;

//===========================================================================
NDDataTransThread::NDDataTransThread()
{
	//NDAsssert(NDDataTransThread_dafaultThread == NULL);	//
	m_socket = new NDSocket;
	m_status = ThreadStatusStoped;
	m_operate = ThreadStatusStoped;
	m_bQuitGame = false;
}

NDDataTransThread::~NDDataTransThread()
{
	SAFE_DELETE(m_socket);
}

NDDataTransThread* NDDataTransThread::DefaultThread()
{
	if (!NDDataTransThread_dafaultThread)
	{
		NDDataTransThread_dafaultThread = new NDDataTransThread;
	}

	return NDDataTransThread_dafaultThread;
}

void NDDataTransThread::WaitStatus(ThreadStatus status)
{
	while (true)
	{
		if (m_status == status)
			break;
		//usleep(100);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		Sleep(1);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		usleep(100);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		usleep(100);
#endif  // CC_PLATFORM_ANDROID
	}
}

//===========================================================================
void NDDataTransThread::Start(const char* ipAddr, int port)
{
	CCLog( "@@login6.2: NDDataTransThread::Start()");

	if (m_status == ThreadStatusRunning)
	{
		CCLog("@@login6.3: the thread is running, can't start again!");
	}
	else if (m_status == ThreadStatusPaused)
	{
		CCLog("@@login6.4: the thread is paused, can't start, you can call resume methord!");
	}
	else
	{
		CCLog("@@login6.5: try to connect..." );

#if BLOCK_SOCKET == 1
		bool ret = m_socket->Connect(ipAddr, port, true);
#else
		bool ret = m_socket->Connect(ipAddr, port, false);
#endif

		if (ret)
		{
			pthread_t pid;
			if(pthread_create(&pid, NULL, execThread, this) != 0)
			{
				CCLog("@@login6.6: create thread error, maybe memory not enough!");
			}
			else
			{
				m_operate = ThreadStatusRunning;
				m_status = ThreadStatusRunning;
				CCLog("@@login6.7: thread running now.......");
			}
		}
		else
		{
			CCLog("@@login6.8: connect server failed, maybe the socket is connected!");
			return;
		}
	}
}

//===========================================================================
void NDDataTransThread::Stop()
{
	m_operate = ThreadStatusStoped;
#if BLOCK_SOCKET == 1
	m_socket->Close();
#else
	WaitStatus (m_operate);
#endif

	//NDNetMsgMgr::GetSingleton().purge();	//???????????????
	CCLog("user operate to stop the thread!");
}

//===========================================================================
ThreadStatus NDDataTransThread::GetThreadStatus()
{
	return m_status;
}

NDSocket* NDDataTransThread::GetSocket()
{
	return m_socket;
}

NDDataTransThread* NDDataTransThread::ResetDefaultThread()
{   
	SAFE_DELETE(NDDataTransThread_dafaultThread);
	return 0;
}

//===========================================================================
void NDDataTransThread::Execute()
{
	//sleep(1); //wait for status
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	Sleep(1000);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	sleep(1);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	sleep(1);
#endif  // CC_PLATFORM_ANDROID
#if BLOCK_SOCKET == 1
	//阻塞
	BlockDeal();
#else
	//非阻塄1�7
	NotBlockDeal();
#endif

	m_socket->Close();
	m_status = ThreadStatusStoped;
	CCLog("thread stop");
}

//===========================================================================
void NDDataTransThread::BlockDeal()
{
	while (m_operate != ThreadStatusStoped)
	{
		m_status = ThreadStatusRunning;

		if (m_operate == ThreadStatusPaused)
		{
			//usleep(300);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			Sleep(1);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			usleep(300);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			usleep(300);
#endif  // CC_PLATFORM_ANDROID
			m_status = ThreadStatusPaused;
		}
		else
		{
			//unsigned char buffer[512] = { 0x00 };
			int readedLen = 0;

			unsigned char buffer = 0x00;

			if (!m_socket->Receive(&buffer, readedLen, 1))
			{
				//NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();	//???????????????
				m_operate = ThreadStatusStoped;
				CCLog("quit when recive 0xfe");
				continue;
			}
			else
			{
				if (readedLen == 0)
				{
					//usleep(1000*50);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
					Sleep(50);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
					usleep(1000 * 50);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
					usleep(1000 * 50);
#endif  // CC_PLATFORM_ANDROID
					continue;
				}

				if (buffer != 0xfe)
					continue;

				//读大小及code
				unsigned char ucbuffer[4] =
				{ 0x0 };
				int hasRead = 0;
				unsigned char * ptr = (unsigned char*) ucbuffer;
				readedLen = 4;

				while (readedLen > 0)
				{
					int readlen = 0;
					if (!m_socket->Receive(ptr, readlen, readedLen))
					{
						//NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();	//???????????????
						m_operate = ThreadStatusStoped;
						CCLog("quit when recive size and len");
						break;
					}

					if (readlen != 0)
					{
						hasRead += readlen;
						ptr += readlen;
						readedLen = 4 - hasRead;
					}
				}

				if (hasRead != 4)
				{
					CCLog("read size and len error");
					continue;
				}

				int len = int(ucbuffer[0] + (ucbuffer[1] << 8));

				int code = int(ucbuffer[2] + (ucbuffer[3] << 8));

				CCLog("ready for read msg, msgid[%d], msglen[%d]",
						code, len);

				do
				{
					unsigned char ucbuffer[1046] =
					{ 0x0 };
					int hasRead = 0;
					unsigned char * ptr = (unsigned char*) ucbuffer;
					readedLen = len - 6;
					while (readedLen > 0)
					{
						int readlen = 0;
						if (!m_socket->Receive(ptr, readlen, readedLen))
						{
							//NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();	//???????????????
							m_operate = ThreadStatusStoped;
							CCLog("quit when recive msg");
							break;
						}

						if (readlen != 0)
						{
							hasRead += readlen;
							ptr += readlen;
							readedLen = len - 6 - hasRead;
						}
					}

					if (hasRead != len - 6)
					{
						CCLog("read msg error, msgid[%d], msglen[%d]",
								code, len);
						continue;
					}

					NDTransData bao;
					bao.WriteShort(code);
					bao.Write(ucbuffer, len - 6);

					//if (!NDNetMsgMgr::GetSingleton().AddNetRawData(bao.GetBuffer(), bao.GetSize()))	//???????????????
					//{
					//	m_operate = ThreadStatusStoped;
					//}
				} while (0);

			}
		}
	}
}

void NDDataTransThread::ChangeCode(DWORD dwCode)
{
    if(m_socket)
        m_socket->ChangeCode(dwCode);
}

//===========================================================================
void NDDataTransThread::NotBlockDeal()
{
	while (m_operate != ThreadStatusStoped)
	{
		m_status = ThreadStatusRunning;

		if (m_operate == ThreadStatusPaused)
		{
			//usleep(300);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			Sleep(1);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			usleep(300);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			usleep(300);
#endif  // CC_PLATFORM_ANDROID
			m_status = ThreadStatusPaused;
		}
		else
		{
			unsigned char buffer[1046] = { 0x00 };
			int readedLen = 0;
			if (!m_socket->Receive(buffer, readedLen))
			{
				//NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();	//???????????????
				m_operate = ThreadStatusStoped;
			}
			else if (readedLen)
			{
                if (readedLen != 0 && !NDBaseNetMsgPoolObj.AddNetRawData(buffer, readedLen))	//???????????????
                {
                    m_operate = ThreadStatusStoped;
                }
			}
			else if (readedLen == 0)
			{
					//usleep(1000*50);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
					Sleep(50);
#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
				usleep(1000 * 50);
#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
				usleep(1000 * 50);
#endif  // CC_PLATFORM_ANDROID
			}
		}
	}
}

}

//===========================================================================


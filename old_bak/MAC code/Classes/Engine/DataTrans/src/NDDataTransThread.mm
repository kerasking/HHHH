//
//  NDDataTransThread.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDDataTransThread.h"
#import "NDMessageCenter.h"
#import "define.h"
#import "NDMsgDefine.h"
#import "NDDirector.h"
#import "NDConstant.h"

#define BLOCK_SOCKET (0)

namespace NDEngine
{	
	void* execThread(void* ptr)
	{
		NDDataTransThread* thread = (NDDataTransThread*)ptr;
		if (thread) 
		{
			thread->Execute();
		}
		return NULL;
	}	
	
	IMPLEMENT_CLASS(NDDataTransThread, NDObject)
	
	static NDDataTransThread* NDDataTransThread_dafaultThread = NULL;
	
	NDDataTransThread::NDDataTransThread()
	{
		NDAsssert(NDDataTransThread_dafaultThread == NULL);
		m_socket = new NDSocket;
		m_status = ThreadStatusStoped;
		m_operate = ThreadStatusStoped;
        m_bQuitGame = false;
	}
	
	NDDataTransThread::~NDDataTransThread()
	{		
		delete m_socket;
		NDDataTransThread_dafaultThread = NULL;
	}
	
	NDDataTransThread* NDDataTransThread::DefaultThread()
	{
		if (!NDDataTransThread_dafaultThread) 
			NDDataTransThread_dafaultThread = new NDDataTransThread;
		return NDDataTransThread_dafaultThread;
	}
	
	NDDataTransThread* NDDataTransThread::ResetDefaultThread()
	{   
		delete NDDataTransThread_dafaultThread;
        NDDataTransThread_dafaultThread = NULL;
	}
	void NDDataTransThread::WaitStatus(ThreadStatus status)
	{		
		while (true) 
		{
			if (m_status == status) 
				break;
			usleep(100);
		}
	}
	
	void NDDataTransThread::Start(const char* ipAddr, int port)
	{		
        m_bQuitGame =false;
		if (m_status == ThreadStatusRunning) 
		{
			NDLog(@"the thread is running, can't start again!");
		}
		else if (m_status == ThreadStatusPaused)
		{
			NDLog(@"the thread is paused, can't start, you can call resume methord!");
		}
		else 
		{
			#if BLOCK_SOCKET == 1
			bool ret = m_socket->Connect(ipAddr, port, true);
			#else
			bool ret = m_socket->Connect(ipAddr, port, false);
			#endif
			
			if (ret) 
			{				
				pthread_t pid;
				if (pthread_create(&pid, NULL, execThread, this) != 0)
				{
					NDLog(@"create thread error, maybe memory not enough!");
				}
				else 
				{
					m_operate = ThreadStatusRunning;
					m_status  = ThreadStatusRunning;
					NDLog(@"thread running now.......");
				}
			}
			else 
			{
				NDLog(@"connect server failed, maybe the socket is connected!");
				return;
			}						
		}		
	}	
	
	void NDDataTransThread::Stop()
	{
#ifdef __USE_CFSOCKET__
		m_socket->StopLoop();
		m_status = ThreadStatusStoped;
#else
		m_operate = ThreadStatusStoped;

        
		#if BLOCK_SOCKET == 1
			m_socket->Close();
		#else
			WaitStatus(m_operate);
		#endif
		
		NDNetMsgMgr::GetSingleton().purge();
		NDLog(@"user operate to stop the thread!");
        
#endif
	}
	
    bool NDDataTransThread::GetQuitGame()
    {
        return m_bQuitGame;
    }
  
    void NDDataTransThread::SetQuitGame(bool bQuitGame)
    {
        m_bQuitGame = bQuitGame;
    }
    
#ifndef __USE_CFSOCKET__	
	void NDDataTransThread::Pause()
	{
		if (m_status == ThreadStatusRunning) 
		{			
			m_operate = ThreadStatusPaused;
			#if BLOCK_SOCKET == 0
			WaitStatus(m_operate);
			#endif
			NDLog(@"user operate to pause the thread!");
		}
		else 
		{
			NDLog(@"can't pause the thread, because the thread is not running!");
		}
	}
	
	void NDDataTransThread::Resume()
	{

		if (m_status == ThreadStatusPaused) 
		{			
			m_operate = ThreadStatusRunning;
			WaitStatus(m_operate);
			NDLog(@"user operate to resume the thread!");
		}
		else 
		{
			NDLog(@"can't resume the thread, because the thread is not paused!");
		}
	}
#endif
	
	ThreadStatus NDDataTransThread::GetThreadStatus()
	{
		return m_status;
	}
	
	NDSocket* NDDataTransThread::GetSocket()
	{
		return m_socket;
	}
	
	void NDDataTransThread::Execute()
	{
#ifdef __USE_CFSOCKET__
		m_socket->RunLoop();
		if (m_socket->Connected())
		{
			/*
			NDTransData *data = new NDTransData(_MSG_GAME_QUIT); //quit game message
			NDMessageCenter::DefaultMessageCenter()->AddMessage(data);
			*/
			NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
		}
#else				
		sleep(1); //wait for status
		#if BLOCK_SOCKET == 1
		//阻塞
		BlockDeal();
		#else	
		//非阻塞
		NotBlockDeal();
		#endif
		
#endif		
		m_socket->Close();
		m_status = ThreadStatusStoped;
        m_bQuitGame = true;
       //
        //this->Stop();
        //quitGame();
        
		NDLog(@"thread stop");

	}
    
    
    void NDDataTransThread::ChangeCode(DWORD dwCode)
    {
        if(m_socket)
            m_socket->ChangeCode(dwCode);
    }
	
	void NDDataTransThread::BlockDeal()
	{
		while (m_operate != ThreadStatusStoped) 
		{
			m_status = ThreadStatusRunning;
			
			if (m_operate == ThreadStatusPaused) 
			{
				usleep(300);
				m_status = ThreadStatusPaused;
			}
			else 
			{
				//unsigned char buffer[512] = { 0x00 };
				int readedLen = 0;
				
				unsigned char buffer = 0x00;
				
				if (!m_socket->Receive(&buffer, readedLen, 1)) 
				{
					NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
					m_operate = ThreadStatusStoped;
					NDLog(@"quit when recive 0xfe");
					continue;
				}
				else 
				{
					if (readedLen == 0)
					{
						usleep(1000*50);
						
						continue;
					}
					
					if (buffer != 0xfe)
						continue;
					
					// 读大小及code
					unsigned char ucbuffer[4] = { 0x0 };
					int hasRead = 0;
					unsigned char * ptr = (unsigned char*)ucbuffer;
					readedLen = 4;
					
					while (readedLen > 0) 
					{
						int readlen = 0;
						if (!m_socket->Receive(ptr, readlen, readedLen)) 
						{
							NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
							m_operate = ThreadStatusStoped;
							NDLog(@"quit when recive size and len");
							break;
						}
						
						if (readlen != 0)
						{
							hasRead += readlen;
							ptr += readlen;
							readedLen = 4-hasRead;
						}
					}
					
					if (hasRead != 4)
					{
						NDLog(@"read size and len error");
						continue;
					}
					
					int len = int(ucbuffer[0] + (ucbuffer[1] << 8));
					
					int code = int(ucbuffer[2] + (ucbuffer[3] << 8));
					
					NDLog(@"ready for read msg, msgid[%d], msglen[%d]", code, len);
					
					do
					{
						// 读消息
						unsigned char ucbuffer[1046] = { 0x0 };
						int hasRead = 0;
						unsigned char * ptr = (unsigned char*)ucbuffer;
						readedLen = len-6;
						while (readedLen > 0) 
						{
							int readlen = 0;
							if (!m_socket->Receive(ptr, readlen, readedLen)) 
							{
								NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
								m_operate = ThreadStatusStoped;
								NDLog(@"quit when recive msg");
								break;
							}
							
							if (readlen != 0)
							{
								hasRead += readlen;
								ptr += readlen;
								readedLen = len-6-hasRead;
							}
						}
						
						if (hasRead != len-6)
						{
							NDLog(@"read msg error, msgid[%d], msglen[%d]", code, len);
							continue;
						}
						
						NDTransData bao;
						bao.WriteShort(code);
						bao.Write(ucbuffer, len-6);
						
						if (!NDNetMsgMgr::GetSingleton().AddNetRawData(bao.GetBuffer(), bao.GetSize()))
						{
							m_operate = ThreadStatusStoped;
						}
					}while (0);
					
				}
			}
		}
	}
	
	void NDDataTransThread::NotBlockDeal()
	{
		while (m_operate != ThreadStatusStoped) 
		{
			m_status = ThreadStatusRunning;
			
			if (m_operate == ThreadStatusPaused) 
			{
				usleep(300);
				m_status = ThreadStatusPaused;
			}
			else 
			{
				unsigned char buffer[1046] = { 0x00 };
				int readedLen = 0;
				if (!m_socket->Receive(buffer, readedLen)) 
				{
					/*
					 NDTransData *data = new NDTransData(_MSG_GAME_QUIT); //quit game message
					 NDMessageCenter::DefaultMessageCenter()->AddMessage(data);
					 */
					//NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
					m_operate = ThreadStatusStoped;
                    //m_operate = ThreadStatusPaused;
				}
				else if (readedLen)
				{
					/*
					 if (!m_socket->DealReceivedData((const unsigned char*)buffer, readedLen)) 
					 {
					 m_operate = ThreadStatusStoped;
					 }
					 */
					
					if (readedLen != 0 && !NDNetMsgMgr::GetSingleton().AddNetRawData(buffer, readedLen))
					{
						m_operate = ThreadStatusStoped;
					}
				}
				else if (readedLen == 0)
				{
					if (readedLen == 0)
						usleep(1000*50);
				}
			}
		}
	}
	
}

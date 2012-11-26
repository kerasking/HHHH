//
//  NDMessageCenter.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "NDMessageCenter.h"
#include "basedefine.h"
#include "define.h"
#include "NDMsgDefine.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDMessageCenter, NDObject)
	
	static NDMessageCenter* NDMessageCenter_dafaultMessageCenter = NULL;
	
	NDMessageCenter::NDMessageCenter()
	{
		NDAsssert(NDMessageCenter_dafaultMessageCenter == NULL); 	
	}
	
	NDMessageCenter::~NDMessageCenter()
	{
		NDMessageCenter_dafaultMessageCenter = NULL;
	}
	
	NDMessageCenter* NDMessageCenter::DefaultMessageCenter()
	{
		if (NDMessageCenter_dafaultMessageCenter == NULL) 
		{
			NDMessageCenter_dafaultMessageCenter = new NDMessageCenter();
		}
		return NDMessageCenter_dafaultMessageCenter;	
	}
	
	void NDMessageCenter::AddMessage(NDTransData* data)
	{
		//const unsigned char* buf = data->GetBuffer();
		//unsigned short idMsg = 0;
		//idMsg = buf[4] + (buf[5] << 8);
		
		//NDLog(@"�յ���Ϣ%d", idMsg);
		
		_transdata *pWritePtr = NULL;
		unsigned int nWriteSize = 0;
		m_messageQueue.GetWritePtr(pWritePtr, nWriteSize);
		
		if ( nWriteSize  == 0 ) 
		{
			//NDLog(@"��Ϣ���Ľ��ջ����������ٽ�������!!![˲�Ӧ�ó��]");
			delete data;
			return;
		}
		
		(*pWritePtr).data = data;
		m_messageQueue.AddData(1);
		//m_messageQueue.push_back(data);
	}
	
	bool NDMessageCenter::CanAddMessage()
	{
		_transdata* pWritePtr = NULL;
		unsigned int nWriteSize = 0;
		m_messageQueue.GetWritePtr(pWritePtr, nWriteSize);
		return nWriteSize != 0;
	}
	
	NDTransData* NDMessageCenter::GetMessage()
	{
		/*
		if (m_messageQueue.size() > 0) 
		{
			return m_messageQueue.front();
		}
		 */
		NDTransData *result   = NULL;
		_transdata  *pReadPtr = NULL;
		unsigned int nReadSize = 0;
		m_messageQueue.GetReadPtr(pReadPtr, nReadSize);
		if (nReadSize == 0) 
		{
			result = NULL; 
		}
		else 
		{
			result = pReadPtr->data;
			m_messageQueue.DeleteData(1);
		}

		return result;
	}
	/*
	void NDMessageCenter::DelMessage()
	{
		if (m_messageQueue.size() > 0) 
		{
			delete m_messageQueue.front();
			m_messageQueue.pop_front();
		}
	}*/
	
#pragma mark �������Ϣ�������(�֧�ֶ��߳)
	
	// ����:�������Ϣ�������(�֧�ֶ��߳)
	// ��ṩ�������ԭʼ��ݹ��
	// ��ṩ��ȡ��������Ϣ���
	// ��ṩ��ӻ��������Ϣ���
	// ��ṩ�����������ԭʼ��ݹ��
	// ��ṩ������������������
	// jhzhen 2011.12.1
	
	static NDNetMsgMgr* s_NDNetMsgMgr = NULL;
	
	//NDNetMsgMgr& NDNetMsgMgr::GetSingleton()
	//{
	//	if (s_NDNetMsgMgr == NULL)
	//	{
	//		s_NDNetMsgMgr = new NDNetMsgMgr;
	//	}
	//	
	//	return *s_NDNetMsgMgr;
	//}
	
	void NDNetMsgMgr::purge()
	{
		NDAsssert(s_NDNetMsgMgr != NULL);
		
		SAFE_DELETE(s_NDNetMsgMgr);
	}
	
	NDNetMsgMgr::~NDNetMsgMgr()
	{
		s_NDNetMsgMgr = NULL;
	}
	
	bool NDNetMsgMgr::AddNetRawData(const unsigned char* data, unsigned int uilen, bool net /*= true*/)
	{
		if (!data || uilen == 0)
			return true;
			
		unsigned char* pWritePtr = NULL;
		unsigned int uiWriteSize = 0;
		
		m_buffer.GetWritePtr(pWritePtr, uiWriteSize);
		
#ifdef DEBUG 
		// ܹ۲�δ��Ļ����С
		static unsigned int s_maxHasWriteSize = 1046 * 15;
		
		unsigned int hasWriteSize = 0;
		
		if (uiWriteSize < 1046 * 256)
		{
			hasWriteSize = 1046 * 256 - uiWriteSize;
		}
		
		if (hasWriteSize > s_maxHasWriteSize)
		{
			//NDLog("\nNDNetMsgMgr::AddNetRawData net msg buffer has wite % space!!!", hasWriteSize);
			
			unsigned int newMaxWriteSize = (unsigned int)(float(s_maxHasWriteSize) * 1.2);
			
			if (hasWriteSize > newMaxWriteSize)
			{
				newMaxWriteSize = hasWriteSize;
			}
			
			s_maxHasWriteSize = newMaxWriteSize;
		}
		
		// �۲��ܵĽ�����ݴ�С
		if (net)
		{
			m_lockNetData.lock();
		
			m_uiTotalNetData += uilen;
		
			m_lockNetData.unlock();
		}
#endif
		
		if (uiWriteSize < 1046 * 128)
		{
			//NDLog(@"\nNDNetMsgMgr::AddNetRawData net msg buffer has only half space!!!");
		}
		
		if ( uiWriteSize == 0 )
		{
			//NDLog(@"\nNDNetMsgMgr::AddNetRawData net msg buffer has not space!!!");
			
			return false;
		}
		
		if ( uiWriteSize < uilen )
		{
			//NDLog(@"\nNDNetMsgMgr::AddNetRawData net msg buffer not enough space");
			
			return false;
		}
		
		bool sucess = m_buffer.PushData(data, uilen);
		
		if (!sucess)
		{
			//NDLog(@"\nDNetMsgMgr::AddNetRawData PushData failed!!!");
		}
		
		return sucess;
	}
	
	bool NDNetMsgMgr::GetServerMsgPacket(NDTransData& data)
	{
		unsigned char* pReadPtr = NULL;
		unsigned int uiReadSize = 0;
		
		m_buffer.GetReadPtr(pReadPtr, uiReadSize);
		
		if (uiReadSize < ND_C_MSGID_BEGIN)
		{
			return false;
		}
		
#if (defined(USE_NDSDK) || defined(USE_MGSDK))
		unsigned int msgLen = (pReadPtr[0] & 0xff) + ((pReadPtr[1] & 0xff) << 8);
#else
		while(0xff != pReadPtr[0] || 0xfe != pReadPtr[1])
		{
			NDLog(@"NDNetMsgMgr::GetServerMsgPacket received message not match protocol of we defined!");
			
			if (!m_buffer.DeleteData(2))
			{
				NDLog(@"NDNetMsgMgr::GetServerMsgPacket DeleteData(while) failed!!!");
				
				return false;
			}
			
			m_uiTotalInvalidRecv += 2;
			
			m_buffer.GetReadPtr(pReadPtr, uiReadSize);
			
			if (uiReadSize < 4)
			{
				return false;
			}
		}
        
        unsigned int msgLen = (pReadPtr[2] & 0xff) + ((pReadPtr[3] & 0xff) << 8);
#endif
		
		if (uiReadSize < msgLen)
		{
			return false;
		}

		data.Clear();

		if (!data.Write(pReadPtr + ND_C_MSGID_BEGIN, msgLen - ND_C_MSGID_BEGIN))
		{
			//NDLog(@"NDNetMsgMgr::GetServerMsgPacket write NDTransData failed!!!");
			
			return false;
		}
		
		if (!m_buffer.DeleteData(msgLen))
		{
			//NDLog(@"NDNetMsgMgr::GetServerMsgPacket DeleteData failed!!!");
			
			return false;
		}
		
		if (data.GetCode() != _MSG_GAME_QUIT)
		{
			m_uiTotalValidRecv += msgLen;
		}
		
		return true;
	}
	
	bool NDNetMsgMgr::AddBackToMenuPacket()
	{
		NDTransData bao(_MSG_GAME_QUIT);
		
		if ( !AddNetRawData(bao.GetBuffer(), bao.GetSize(), false) )
		{
			//NDLog(@"NDNetMsgMgr::AddBackToMenuPacket failed!!!");
			
			return false;
		}
		
		return true;
	}
	
	bool NDNetMsgMgr::ClearNetRawData()
	{
		m_buffer.Reset();
		
		return true;
	}
	
	NDNetMsgMgr::NDNetMsgMgr()
	{
		NDAsssert(s_NDNetMsgMgr == NULL);
		
		m_uiTotalInvalidRecv = m_uiTotalValidRecv = 0;
		
		m_uiTotalNetData = 0;
	}
	
	void NDNetMsgMgr::Report()
	{
		return;
		#ifdef DEBUG
			
			m_lockNetData.lock();
			//NDLog(@"\n---------------------------------------------");
			//NDLog(@"NDNetMsgMgr total recv data from net %u byte.", m_uiTotalNetData);
			
			m_lockNetData.unlock();
		
		#endif
		
		unsigned char* pReadPtr = NULL;
		unsigned int uiReadSize = 0;
		
		m_buffer.GetReadPtr(pReadPtr, uiReadSize);
		
		//NDLog(@"\n---------------------------------------------");
		//NDLog(@"NDNetMsgMgr total deal net data %u byte, %u byte remain in buffer, %u byte error data.", 
				//m_uiTotalValidRecv + m_uiTotalInvalidRecv + uiReadSize,
				//uiReadSize,
				//m_uiTotalInvalidRecv);
    }
}
/*
 *  Robot.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "Robot.h"
#include "MsgBase.h"
#include "NDBeforeGameMgr.h"

#define SEND_TIMER_TAG (202)
#define LIMIT_TIMER_TAG (203)
#define LOGIN_WAIT_TIMER_TAG (204)

#define JUDGE_SUCESS_TIME (30)
#define JUDGE_LIMIT_TIME (60*3)
#define LOGIN_WAIT_TIME (90)

//#define JUDGE_SUCESS (5)

#define SendRobotData(bao) \
do{if (m_socketClient && IsNormal()) m_socketClient->Send(&bao);}while(0)

Robot::Robot()
{
	m_socketClient = NULL;
	
	m_iConnectCount = 0;
	
	m_iSucessCount = 0; 
	
	m_iRecvBillBoardCount = 0;
	
	m_iLoginFailCount = 0;
	
	m_iServerCloseCount = 0;
	
	m_timer = NULL;
	
	m_timerLimit = NULL;
	
	m_timerWaitLogin = NULL;
}

Robot::~Robot()
{
	Quit();
}

void Robot::OnTimer(OBJID tag)
{
	if (tag == SEND_TIMER_TAG) 
	{
		if (m_iSucessCount) m_iSucessCount--;
		
		Reconnect(m_server, m_uiPort);
	}
	else if (tag == LIMIT_TIMER_TAG)
	{
		Reconnect(m_server, m_uiPort);
	}
	else if (tag == LOGIN_WAIT_TIMER_TAG)
	{
		if (m_iSucessCount) m_iSucessCount--;
		
		Reconnect(m_server, m_uiPort);
	}
}

void Robot::SetInfo(RobotInfo& info)
{
	m_info = info;
}

RobotInfo& Robot::GetInfo()
{
	return m_info;
}

void Robot::Connect(string ip, unsigned int port)
{
	if (ip == "" || port == (unsigned int)-1 || port == (unsigned int)0) return;
	
	if (!m_socketClient) m_socketClient = new NDSocket;
	
	m_socketClient->Close();
	
	RobotState state = RSDisConnect;
	
	m_iConnectCount++;
	
	m_iSucessCount++;
	
	if ( m_socketClient->Connect(ip.c_str(), port) )
	{
		m_server = ip;
		
		m_uiPort = port;
		
		state = RSConnect;
		
		m_info.start = (long)[NSDate timeIntervalSinceReferenceDate];
		
		if (!m_timerWaitLogin) 
		{
			m_timerWaitLogin = new NDTimer;
			m_timerWaitLogin->SetTimer(this, LOGIN_WAIT_TIMER_TAG, LOGIN_WAIT_TIME);
		}
	}
	
	m_info.state = state;
	
	if (m_info.state == RSConnect) 
	{
		generateClientKey();
		sendClientKey();
	}
}

void Robot::Reconnect(string ip, unsigned int port)
{
	Quit();
	
	Connect(ip, port);
}

void Robot::Quit()
{
	if (m_socketClient) 
	{
		m_socketClient->Close();
		
		delete m_socketClient;
		
		m_socketClient = NULL;
	}
	
	m_bufRecv.Reset();
	
	m_iRecvBillBoardCount = 0;
	
	if (m_timer) 
	{
		m_timer->KillTimer(this, SEND_TIMER_TAG);
		delete m_timer;
		m_timer = NULL;
	}
	
	if (m_timerLimit) 
	{
		m_timerLimit->KillTimer(this, LIMIT_TIMER_TAG);
		delete m_timerLimit;
		m_timerLimit = NULL;
	}
	
	if (m_timerWaitLogin)
	{
		m_timerWaitLogin->KillTimer(this, LOGIN_WAIT_TIMER_TAG);
		delete m_timerWaitLogin;
		m_timerWaitLogin = NULL;
	}
}

void Robot::Update()
{
	if (!IsNormal()) return;
	
	recvMsg();
	
	processMsg();
}

bool Robot::IsConnet()
{
	return CanDataTrans();
}

int Robot::GetSucessRate()
{
	return m_iConnectCount == 0 ? 0 : (float)m_iSucessCount / m_iConnectCount * 100;
}

int Robot::GetTotalConnectCount()
{
	return m_iConnectCount;
}

int Robot::GetSuccesConnectCount()
{
	return m_iSucessCount;
}

int Robot::GetFailConnectCount()
{
	return m_iConnectCount > m_iSucessCount ? m_iConnectCount - m_iSucessCount : 0;
}

int Robot::GetLoginFailCount()
{
	return m_iLoginFailCount;
}

int Robot::GetServerCloseCount()
{
	return m_iServerCloseCount;
}

bool Robot::CanDataTrans()
{
	return m_info.state == RSDataTrans;
}

bool Robot::IsNormal()
{
	return !(m_info.state == RSNone || m_info.state == RSDisConnect);
}

void Robot::recvMsg()
{
	if (!IsNormal() 
		|| !m_socketClient 
		|| !m_socketClient->Connected()) 
	{
		m_info.state = RSDisConnect;
		
		return;
	}
	
	unsigned char*	pWritePtr	= NULL;
	unsigned int	nWriteSize	= 0;
	
	m_bufRecv.GetWritePtr(pWritePtr, nWriteSize);
	if (nWriteSize == 0)
	{
		return;
	}
	
	int iSize = (int)nWriteSize;
	if (m_socketClient->Receive(pWritePtr, iSize))
	{
		if (iSize > 0) m_bufRecv.AddData(iSize);
	}
	else 
	{
		m_iServerCloseCount++;
		
		m_info.state = RSDisConnect;
		
		Reconnect(m_server, m_uiPort);
	}
}

void Robot::processMsg()
{
	unsigned char*	pReadPtr	= NULL;
	unsigned int		nReadSize	= 0;
	m_bufRecv.GetReadPtr(pReadPtr, nReadSize);
	
	while (nReadSize > 4)
	{
		if (0xff != pReadPtr[0] || 0xfe != pReadPtr[1]) 
		{
			break;
		}	
			
		unsigned int msgLen = (pReadPtr[2] & 0xff) + ((pReadPtr[3] & 0xff) << 8);
		
		if (nReadSize < msgLen)
		{
			break;
		}
		
		unsigned int msgID = pReadPtr[4] + (pReadPtr[5] << 8);
		
//		CMsgBase* pMsg = CNetMsgPool::GetNetMsg(msgID, msgLen-2);
//		
//		if (pMsg) 
//		{
//			pMsg->Create(pReadPtr+2, msgLen-2);
//			pMsg->Process(0);
//		}
//		else
//		{
			NDTransData recvdata;
			recvdata.Write(pReadPtr+4, msgLen-4);
			ProcessOtherMsg(msgID, recvdata);
//		}
		
		m_bufRecv.DeleteData(msgLen);
		m_bufRecv.GetReadPtr(pReadPtr, nReadSize);
	}
}

void Robot::generateClientKey()
{
	// ------ 产生随机key ------
	srandom(time(NULL));
	NSString *sb = [NSString stringWithFormat:@"%d",(int)[NSDate timeIntervalSinceReferenceDate]]; 
	NSMutableString *str = [[NSMutableString alloc] init];
	[str appendString:sb];
	for (int i = [str length]; i < 24; i++) { // 产生 a-z的随机串
		NSString *sb = [NSString stringWithFormat:@"%c", (char) ((random()%100 +1) % 26 + 97)];
		[str appendString:sb];
	}
	m_info.phoneKey.clear();
	for (int i = 0; i < 24; i++)
	{
		unichar c = [str characterAtIndex:i];
		m_info.phoneKey.push_back((char)c);
	}	
	[str release];
}

void Robot::sendClientKey()
{
	NDTransData bao(MB_LOGINSYSTEM_NORSA_EXCHANGE_KEY);
	
	int version = 0;
	bao << version;
	bao.Write((unsigned char*)(m_info.phoneKey.c_str()), m_info.phoneKey.size());
	SendRobotData(bao);
}

void Robot::HandleLoginSucess()
{
	if (!m_timer)
	{
		m_timer = new NDTimer;
		
		m_timer->SetTimer(this, SEND_TIMER_TAG, JUDGE_SUCESS_TIME);
		
		NDTransData bao(_MSG_BILLBOARD_QUERY);
		SendRobotData(bao);
	}
	
	if (!m_timerLimit) 
	{
		m_timerLimit = new NDTimer;
		
		m_timerLimit->SetTimer(this, LIMIT_TIMER_TAG, JUDGE_LIMIT_TIME);
	}
	
	if (m_timerWaitLogin) 
	{
		m_timerWaitLogin->KillTimer(this, LOGIN_WAIT_TIMER_TAG);
		delete m_timerWaitLogin;
		m_timerWaitLogin = NULL;
	}
}

void Robot::ResetTimerAndSend()
{
	if (m_timer)
	{
		m_timer->KillTimer(this, SEND_TIMER_TAG);
		delete m_timer;
		m_timer = NULL;
	}
	
	HandleLoginSucess();
}

//////////////////////////////////////////////////////////
void Robot::ProcessOtherMsg(int nMsgID, NDTransData& data)
{
	switch (nMsgID) {
		case MB_LOGINSYSTEM_EXCHANG_KEY:
			processLogin(data);
			break;
		case MB_LOGINSYSTEM_MOBILE_SERVER_NOTIFY:
			processNotify(data);
			break;
		case _MSG_BILLBOARD:
			processBillBoard(data);
			break;
		case _MSG_USERINFO:
			processUserInfo(data);
			break;
		default:
			break;
	}
}

void Robot::processLogin(NDTransData& data)
{
	if (!data.decrypt(m_info.phoneKey))
	{
		NDLog(@"解密失败,Robot::processLogin");
		m_iLoginFailCount++;
		Reconnect(m_server, m_uiPort);
		return;
	}
	
	int len = data.GetSize()-6;
	
	srandom(time(NULL));
	int nRandNum = random()%16 +1; //1~16
	
	NSMutableString *str = [[NSMutableString alloc] init];
	for (int i = 1; i <= nRandNum; i++) { // 产生 a-z的随机串
		NSString *sb = [NSString stringWithFormat:@"%c", (char) ((random()%100 +1) % 26 + 97)];
		[str appendString:sb];
	}
	
	
	char buf[1024] = {0x00};
	data.Read((unsigned char*)buf, len);
	
	m_info.serverPhoneKey.clear();
	
	for (int i=0; i < len; i++) {
		m_info.serverPhoneKey.push_back(buf[i]);
	} 
	
	
	NDTransData SEND_DATA;
	
	SEND_DATA.WriteShort(MB_LOGINSYSTEM_LOGIN_GAME_SERVER);
	SEND_DATA.WriteUnicodeString(m_info.usrname);
	SEND_DATA.WriteUnicodeString(m_info.pw);
	SEND_DATA.WriteUnicodeString(NDBeforeGameMgrObj.GetServerName());
	SEND_DATA.WriteShort([str length]);
	SEND_DATA.Write((unsigned char*)[str UTF8String], [str length]);
	
	[str release];
	
	if ( !SEND_DATA.encrypt(m_info.serverPhoneKey) )
	{
		NDLog(@"消息发送加密失败,Robot::processLogin");
		m_iLoginFailCount++;
		Reconnect(m_server, m_uiPort);
		return;
	}
	
	SendRobotData(SEND_DATA);
}

void Robot::processNotify(NDTransData& data)
{
	int action = data.ReadShort();
	int code = data.ReadShort();
	
	bool bSucess = true;
	
	if (action == MB_LOGINSYSTEM_LOGIN_GAME_SERVER) 
	{
		switch (code) 
		{
			case 0: // <帐号>服务器认证失败
				bSucess = false;
				break;
			case 1: // 登录<游戏>服务器成功
				HandleLoginSucess();
				break;
			case 2: // 登录<游戏>服务器失败
			case 3: // 连接<帐号>服务器失败
			case 4: // 连接<游戏>服务器失败
				bSucess = false;
				break;
			case 5: // 登录<帐号>服务器超时
			case 6: // 登录<游戏>服务器超时
				bSucess = false;
				break;
			case 7: // <代理服务器>繁忙
				bSucess = false;
				break;
			case 8: // <代理服务器>已达到人数上限
				bSucess = false;
				break;
			case 9: // 登录<游戏>服务器成功 无角色
				//暂时不处理创建角色消息
				bSucess = false;
				break;
			case 10: // 继续登录需要等待,由玩家选择
			{
				bSucess = false;
			}
				break;
			default: // 登录<游戏>服务器失败
				bSucess = false;
				break;
		}
	}
	
	if (!bSucess) 
	{
		if (m_iConnectCount)
		{
			m_iConnectCount--;
		}
		
		if (m_iSucessCount) 
		{
			m_iSucessCount--;
		}
		
		m_iLoginFailCount++;
		
		Reconnect(m_server, m_uiPort);
	}
}

void Robot::processUserInfo(NDTransData& data)
{
	HandleLoginSucess();
}

void Robot::processBillBoard(NDTransData& data)
{
	m_iRecvBillBoardCount++;
	
//	if (m_iRecvBillBoardCount >= JUDGE_SUCESS) 
//	{
//		Reconnect(m_server, m_uiPort);
//		
//		return;
//	}
	
	ResetTimerAndSend();
}

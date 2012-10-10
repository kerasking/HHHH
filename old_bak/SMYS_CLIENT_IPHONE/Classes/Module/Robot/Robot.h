/*
 *  Robot.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ROBOT_H_
#define _ROBOT_H_

#include "NDSocket.h"
#include "NDTransData.h"
#include "CircleBuffer.h"
#include "NDTimer.h"

#define MAX_RING_BACKUP (4096)
#define MAX_RING_BUFF (32*MAX_RING_BACKUP)

using namespace std;

using namespace NDEngine;

enum RobotState 
{
	RSNone,
	RSConnect,
	RSDisConnect,
	RSDataTrans,
};

struct RobotInfo 
{
	unsigned int uiID;
	
	string usrname, pw, phoneKey, serverPhoneKey;
	
	RobotState state;

	long start, end;
	
	RobotInfo() 
	{ 
		uiID = 0; state = RSNone;
		
		start = 0; end = 0;
	}
};

class Robot : public ITimerCallback
{
public:

	Robot();
	
	~Robot();
	
	void OnTimer(OBJID tag); override
	
	void SetInfo(RobotInfo& info);
	
	RobotInfo& GetInfo();
	
	void Connect(string ip, unsigned int port);
	
	void Reconnect(string ip, unsigned int port);
	
	void Quit();
	
	void Update();
	
	// 用于计算成功率
	bool IsConnet();
	
	int GetSucessRate();
	
	int GetTotalConnectCount();
	
	int GetSuccesConnectCount();
	
	int GetFailConnectCount();
	
	int GetLoginFailCount();
	
	int GetServerCloseCount();
private:
	bool CanDataTrans();

	bool IsNormal();

	void recvMsg();
	
	void processMsg();
	
	void generateClientKey();
	
	void sendClientKey();
	
	void HandleLoginSucess();
	
	void ResetTimerAndSend();
	
	///////////////////////////////////////////////////
	
	void ProcessOtherMsg(int nMsgID, NDTransData& data);
	
	void processLogin(NDTransData& data);
	
	void processUserInfo(NDTransData& data);
	
	void processNotify(NDTransData& data);
	
	void processBillBoard(NDTransData& data);
	
private:

	NDSocket *m_socketClient;
	
	RobotInfo m_info;
	
	string m_server;
	
	unsigned int m_uiPort;
	
	CRingBuffer<unsigned char, MAX_RING_BUFF, MAX_RING_BACKUP> m_bufRecv;
	//CRingBuffer<unsigned char, MAX_RING_BUFF, MAX_RING_BACKUP> m_bufSend;
	
	int m_iConnectCount;
	int m_iSucessCount;
	int m_iRecvBillBoardCount;
	int m_iLoginFailCount;
	int m_iServerCloseCount;
	
	NDTimer *m_timer, *m_timerLimit, *m_timerWaitLogin;
};

#endif // _ROBOT_H_
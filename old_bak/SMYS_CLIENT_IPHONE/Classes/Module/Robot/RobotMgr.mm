/*
 *  RobotMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RobotMgr.h"
#include "define.h"

RobotMgr::RobotMgr()
{
	m_uiPort = 0;
	
	m_iAddCount = 0;
}

RobotMgr::~RobotMgr()
{
	ClearRobot();
}

void RobotMgr::Start()
{
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		robot->Connect(m_strServer, m_uiPort);
	}
}

void RobotMgr::Stop()
{
	ClearRobot();
}

void RobotMgr::SetServer(string server, unsigned int port)
{
	m_strServer = server;
	
	m_uiPort = port;
}

void RobotMgr::AddAccount(string usrname, string password)
{
	RobotInfo robotinfo;
	robotinfo.uiID = m_idFactory.GetID();
	robotinfo.usrname = usrname;
	robotinfo.pw = password;
	
	Robot *robot = new Robot;
	robot->SetInfo(robotinfo);
	
	m_vecRobot.push_back(robot);
	
	m_iAddCount++;
}

void RobotMgr::Update()
{
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		robot->Update();
	}
}

int RobotMgr::GetSucessRate()
{
/*
	if (m_iAddCount == 0) return 0;
	
	int iConnectCount = 0;
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		if (robot->IsConnet()) iConnectCount++;
	}
	
	return iConnectCount / m_iAddCount * 100;
*/
	float fPercent = 0.0f, fSum = 0.0f;
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		fPercent += robot->GetSucessRate();
		
		fSum += 100;
	}
	
	return fSum == 0.0f ? 0 : int(fPercent / fSum * 100);
}

bool RobotMgr::GetConnectInfo(int& iTotalConnect, int& iSucessConnect, int &iFailConnect, int& iServerCloseCount, int& iLoginFailCount)
{
	bool bRet = false;
	
	iTotalConnect = 0; iSucessConnect = 0; iFailConnect = 0; iServerCloseCount = 0; iLoginFailCount = 0;
	
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		iTotalConnect += robot->GetTotalConnectCount();
		
		iSucessConnect += robot->GetSuccesConnectCount();
		
		iFailConnect += robot->GetFailConnectCount();
		
		iServerCloseCount += robot->GetServerCloseCount();
		
		iLoginFailCount += robot->GetLoginFailCount();
		
		bRet = true;
	}
	
	return bRet;
}

void RobotMgr::ClearData()
{
	m_strServer = "";
	
	m_uiPort = 0;
	
	m_idFactory.reset();
	
	ClearRobot();
}

void RobotMgr::ClearRobot()
{
	for_vec(m_vecRobot, vector<Robot*>::iterator)
	{
		Robot* robot = *it;
		
		robot->Quit();
		
		delete robot;
	}
	
	m_vecRobot.clear();
}
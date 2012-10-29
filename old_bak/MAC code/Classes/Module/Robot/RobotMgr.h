/*
 *  RobotMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ROBOT_MGR_H_
#define _ROBOT_MGR_H_

#include "Singleton.h"
#include "Robot.h"
#include "GlobalDialog.h"
#include <vector>

#define RobotMgrObj (RobotMgr::GetSingleton())

class RobotMgr : public TSingleton<RobotMgr>
{
public:

	RobotMgr();
	
	~RobotMgr();
	
	void Start();
	
	void Stop();
	
	void SetServer(string server, unsigned int port);
	
	void AddAccount(string usrname, string password);
	
	void Update();
	
	int GetSucessRate();
	
	bool GetConnectInfo(int& iTotalConnect, int& iSucessConnect, int &iFailConnect, int& iServerCloseCount, int& iLoginFailCount);
	
private:
	
	void ClearData();
	
	void ClearRobot();
	
private:

	string m_strServer;
	
	unsigned int m_uiPort;

	vector<Robot*> m_vecRobot;
	
	CIDFactory m_idFactory;
	
	int m_iAddCount;
};

#endif // _ROBOT_MGR_H_
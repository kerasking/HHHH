/*
 *  RobotScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RobotScene.h"
#include "NDDirector.h"
#include "ServerListScene.h"
#include "NDBeforeGameMgr.h"
#include "RobotMgr.h"
#include "NDString.h"
#include "NDUtility.h"
#include "NDUIDialog.h"

#define CTROL_BEGIN_X (200)

IMPLEMENT_CLASS(RobotScene, NDScene)

RobotScene* RobotScene::Scene()
{
	RobotScene *scene = new RobotScene;
	scene->Initialization();
	return scene;
}

RobotScene::RobotScene()
{
	m_menuLayer			= NULL;
	m_lbServer			= NULL;
	m_btnSelServer		= NULL;
	m_cbOuterNet		= NULL;
	m_edtStartAcct		= NULL;
	m_edtPW				= NULL;
	m_lbRate			= NULL;
	m_lbTotalConnect	= NULL;
	m_lbSucessConnect	= NULL;
	m_lbFailConnect		= NULL;
	m_lbServerClose		= NULL;
	m_lbLoginFail		= NULL;
	m_btnStart			= NULL;
	
	m_bStart			= true;
}

RobotScene::~RobotScene()
{
}

void RobotScene::Initialization()
{
	NDScene::Initialization();
	
	m_menuLayer = new NDUIMenuLayer;
	m_menuLayer->Initialization();
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILabel *lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lbTitle->SetFontSize(15);
	lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, m_menuLayer->GetTitleHeight()));
	lbTitle->SetText("Robot");
	m_menuLayer->AddChild(lbTitle);
	
	int iY = m_menuLayer->GetTitleHeight() + 10;
	
	m_lbServer = new NDUILabel;
	m_lbServer->Initialization();
	m_lbServer->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbServer->SetFontSize(15);
	m_lbServer->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbServer->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, winsize.width, 20));
	m_lbServer->SetText("当前选择的服务器:");
	m_menuLayer->AddChild(m_lbServer);
	
	iY += 30;
	
	m_btnSelServer = new NDUIButton();
	m_btnSelServer->Initialization();
	m_btnSelServer->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, 200, 32));
	m_btnSelServer->SetFontColor(ccc4(8, 32, 16, 255));
	m_btnSelServer->SetBackgroundColor(ccc4(108, 158, 155, 255));
	m_btnSelServer->SetTitle("选择服务器");
	m_btnSelServer->SetDelegate(this);
	m_menuLayer->AddChild(m_btnSelServer);
	
	m_cbOuterNet	= new NDUICheckBox;
	m_cbOuterNet->Initialization();
	m_cbOuterNet->SetFrameRect(CGRectMake(CTROL_BEGIN_X+210, iY+2, 100, 30));
	m_cbOuterNet->SetDelegate(this);
	m_cbOuterNet->SetText("外网");
	m_cbOuterNet->SetFontColor(ccc3(29, 59, 59));
	m_cbOuterNet->ChangeCBState();
	m_menuLayer->AddChild(m_cbOuterNet);
	
	iY += 42;
	
	NDUILabel *lbUsr = new NDUILabel;
	lbUsr->Initialization();
	lbUsr->SetTextAlignment(LabelTextAlignmentLeft);
	lbUsr->SetFontSize(15);
	lbUsr->SetFontColor(ccc4(0, 0, 0, 255));
	lbUsr->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, winsize.width, 20));
	lbUsr->SetText("起始帐号:");
	m_menuLayer->AddChild(lbUsr);
	
	m_edtStartAcct = new NDUIEdit();
	m_edtStartAcct->Initialization();
	m_edtStartAcct->SetFrameRect(CGRectMake(CTROL_BEGIN_X+100, iY, 111, 24));
	m_edtStartAcct->SetDelegate(this);
	m_edtStartAcct->SetText("tcp0801");
	m_menuLayer->AddChild(m_edtStartAcct);
	
	iY += 49;
	
	NDUILabel *lbPW = new NDUILabel;
	lbPW->Initialization();
	lbPW->SetTextAlignment(LabelTextAlignmentLeft);
	lbPW->SetFontSize(15);
	lbPW->SetFontColor(ccc4(0, 0, 0, 255));
	lbPW->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, winsize.width, 20));
	lbPW->SetText("密码:");
	m_menuLayer->AddChild(lbPW);
	
	m_edtPW = new NDUIEdit();
	m_edtPW->Initialization();
	m_edtPW->SetFrameRect(CGRectMake(CTROL_BEGIN_X+100, iY, 111, 24));
	m_edtPW->SetDelegate(this);
	m_edtPW->SetText("1");
	m_menuLayer->AddChild(m_edtPW);
	
	iY += 49;
	
	NDUILabel *lbUsrNum = new NDUILabel;
	lbUsrNum->Initialization();
	lbUsrNum->SetTextAlignment(LabelTextAlignmentLeft);
	lbUsrNum->SetFontSize(15);
	lbUsrNum->SetFontColor(ccc4(0, 0, 0, 255));
	lbUsrNum->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, winsize.width, 20));
	lbUsrNum->SetText("帐号数:");
	m_menuLayer->AddChild(lbUsrNum);
	
	m_edtAcctNum = new NDUIEdit();
	m_edtAcctNum->Initialization();
	m_edtAcctNum->SetFrameRect(CGRectMake(CTROL_BEGIN_X+100, iY, 111, 24));
	m_edtAcctNum->SetDelegate(this);
	m_edtAcctNum->SetText("1");
	m_menuLayer->AddChild(m_edtAcctNum);
	
	iY += 50;
	
	m_lbRate = new NDUILabel;
	m_lbRate->Initialization();
	m_lbRate->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbRate->SetFontSize(15);
	m_lbRate->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbRate->SetFrameRect(CGRectMake(CTROL_BEGIN_X, iY, winsize.width, 20));
	m_lbRate->SetText("成功率:");
	m_menuLayer->AddChild(m_lbRate);

	m_btnStart = new NDUIButton();
	m_btnStart->Initialization();
	m_btnStart->SetFrameRect(CGRectMake(CTROL_BEGIN_X+120, iY-12, 80, 32));
	m_btnStart->SetFontColor(ccc4(8, 32, 16, 255));
	m_btnStart->SetBackgroundColor(ccc4(108, 158, 155, 255));
	m_btnStart->SetTitle("开始");
	m_btnStart->SetDelegate(this);
	m_menuLayer->AddChild(m_btnStart);
	
	iY = m_menuLayer->GetTitleHeight()+10;
	
	m_lbTotalConnect = new NDUILabel;
	m_lbTotalConnect->Initialization();
	m_lbTotalConnect->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTotalConnect->SetFontSize(15);
	m_lbTotalConnect->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbTotalConnect->SetFrameRect(CGRectMake(10, iY, winsize.width, 20));
	m_lbTotalConnect->SetText("总连接次数:");
	m_menuLayer->AddChild(m_lbTotalConnect);
	
	iY += 25;
	
	m_lbSucessConnect = new NDUILabel;
	m_lbSucessConnect->Initialization();
	m_lbSucessConnect->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbSucessConnect->SetFontSize(15);
	m_lbSucessConnect->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbSucessConnect->SetFrameRect(CGRectMake(10, iY, winsize.width, 20));
	m_lbSucessConnect->SetText("连接成功次数:");
	m_menuLayer->AddChild(m_lbSucessConnect);
	
	iY += 25;
	
	m_lbFailConnect = new NDUILabel;
	m_lbFailConnect->Initialization();
	m_lbFailConnect->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbFailConnect->SetFontSize(15);
	m_lbFailConnect->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbFailConnect->SetFrameRect(CGRectMake(10, iY, winsize.width, 20));
	m_lbFailConnect->SetText("连接失败次数:");
	m_menuLayer->AddChild(m_lbFailConnect);
	
	iY += 25;
	
	m_lbServerClose = new NDUILabel;
	m_lbServerClose->Initialization();
	m_lbServerClose->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbServerClose->SetFontSize(15);
	m_lbServerClose->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbServerClose->SetFrameRect(CGRectMake(10, iY, winsize.width, 20));
	m_lbServerClose->SetText("服务器主动关闭次数:");
	m_menuLayer->AddChild(m_lbServerClose);
	
	iY += 25;
	
	m_lbLoginFail = new NDUILabel;
	m_lbLoginFail->Initialization();
	m_lbLoginFail->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbLoginFail->SetFontSize(15);
	m_lbLoginFail->SetFontColor(ccc4(0, 0, 0, 255));
	m_lbLoginFail->SetFrameRect(CGRectMake(10, iY, winsize.width, 20));
	m_lbLoginFail->SetText("登录失败次数:");
	m_menuLayer->AddChild(m_lbLoginFail);
}

void RobotScene::draw()
{
	string ss = "成功率: ";
	NDString str(RobotMgrObj.GetSucessRate());
	ss.append(str.getData());
	ss.append("%");
	
	if (m_lbRate) m_lbRate->SetText(ss.c_str());
	
	int iTotal = 0, iSucess = 0, iFail = 0, iServerClose = 0, iLoginFail = 0;
	
	RobotMgrObj.GetConnectInfo(iTotal, iSucess, iFail, iServerClose, iLoginFail);
	
	NDString total("总连接次数: "), sucess("连接成功次数: "), fail("连接失败次数: "),
			 serverClose("服务器主动关闭次数: "), loginFail("登录失败次数: ");
	
	total += iTotal; sucess += iSucess; fail += iFail; serverClose += iServerClose; loginFail += iLoginFail;
	
	if (m_lbTotalConnect) m_lbTotalConnect->SetText(total.getData());
	
	if (m_lbSucessConnect) m_lbSucessConnect->SetText(sucess.getData());
	
	if (m_lbFailConnect) m_lbFailConnect->SetText(fail.getData());
	
	if (m_lbServerClose) m_lbServerClose->SetText(serverClose.getData());
	
	if (m_lbLoginFail) m_lbLoginFail->SetText(loginFail.getData());
}

void RobotScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menuLayer->GetCancelBtn())
	{
		exit(0);
	}
	else if (button == m_btnSelServer) 
	{
		NDDirector::DefaultDirector()->PushScene(ServerListScene::Scene());
	}
	else if (button == m_btnStart) 
	{
		bool bRet = false;
		
		if (m_bStart) 
			bRet = DealStartLogic();
		else 
			bRet = DealEndLogic();
		
		if (!bRet) return;
		
		m_bStart = !m_bStart;
		
		button->SetTitle(m_bStart ? "开始" : "结束");
	}
}

bool RobotScene::DealStartLogic()
{
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	
	std::string ip = mgr.GetServerIP();
	
	int port = mgr.GetServerPort();
	
	if (ip == "" || port == -1) 
	{
		showDialog("提示", "未选择游戏服务器");
		return false;
	}
	
	string startAcc = m_edtStartAcct == NULL ? "" : m_edtStartAcct->GetText();
	
	int startAccNum = m_edtAcctNum == NULL ? 0 : atoi(m_edtAcctNum->GetText().c_str());
	
	if (startAcc == "" || startAccNum <= 0) 
	{
		showDialog("提示", "帐号或帐号数出错");
		return false;
	}
	
	RobotMgr& robotMgr = RobotMgrObj;
	
	int iCount = 0;
	
	for (int i = 0; i < startAccNum; i++) 
	{
		if	(startAcc == "") break;
		
		robotMgr.AddAccount(startAcc, m_edtPW ? m_edtPW->GetText() : "");
		
		startAcc = GetNextAccount(startAcc);
		
		iCount++;
	}
	
	if (iCount == 0) 
	{
		showDialog("提示", "帐号加入失败");
		return false;
	}
	
	robotMgr.SetServer(ip, port);
	
	robotMgr.Start();
	
	std::string startTime = "start :";
	
	startTime += getStringTime([NSDate timeIntervalSinceReferenceDate]);
	
	WriteStringToFile("\r\n");
	
	WriteStringToFile(startTime);
	
	WriteStringToFile("\r\n");
	
	return true;
}

bool RobotScene::DealEndLogic()
{
	Save();
	
	std::string endTime = "end :";
	
	endTime += getStringTime([NSDate timeIntervalSinceReferenceDate]);
	
	WriteStringToFile(endTime);
	
	WriteStringToFile("\r\n");
	
	RobotMgrObj.Stop();
	
	return true;
}

std::string RobotScene::GetNextAccount(const std::string& acct)
{
	int iSize = acct.size();
	
	bool bFind = false;
	
	int iIndex = 0;
	
	for (int i = iSize-1; i >= 0; i--) 
	{
		char cNum = acct.at(i);
		
		if (!isdigit(cNum)) break;
		
		if (atoi(&cNum) != 9)
		{
			iIndex = i;
			bFind = true;
			break;
		}
	}
	
	std::string res = "";
	
	if (bFind && iIndex != 0) 
	{
		res += acct.substr(0, iIndex);
		char cNum = acct.at(iIndex);
		int iNum = atoi(&cNum);
		NDString val(iNum + 1);
		res += val.getData();
		while (++iIndex < iSize) res += "0";
	}
	
	return res;
}

void RobotScene::SetServerName(std::string name)
{
	std::string server = "当前选择的服务器: ";
	server += name;
	
	if (m_lbServer) m_lbServer->SetText(server.c_str());
}

bool RobotScene::IsOuterNet()
{
	if (m_cbOuterNet) return m_cbOuterNet->GetCBState();
	
	return false;
}

bool RobotScene::WriteStringToFile(std::string str)
{
	NSString *file = [NSString stringWithFormat:@"%@%s", @"/DragonDrive/", "Robot.txt"];
	FILE* f = fopen([file UTF8String], "a");
	if (f) 
	{
		fputs(str.c_str(), f);
		fclose(f);
		return true;
	}
	
	return false;
}

void RobotScene::Save()
{
	string ss = "成功率: ";
	NDString str(RobotMgrObj.GetSucessRate());
	ss.append(str.getData());
	ss.append("%");
	
	int iTotal = 0, iSucess = 0, iFail = 0, iServerClose = 0, iLoginFail = 0;
	
	RobotMgrObj.GetConnectInfo(iTotal, iSucess, iFail, iServerClose, iLoginFail);
	
	NDString total("总连接次数: "), sucess("连接成功次数: "), fail("连接失败次数: "),
	serverClose("服务器主动关闭次数: "), loginFail("登录失败次数: ");
	
	total += iTotal; sucess += iSucess; fail += iFail; serverClose += iServerClose; loginFail += iLoginFail;
	
	WriteStringToFile("本次登录服务器: ");
	WriteStringToFile(NDBeforeGameMgrObj.GetServerName());
	WriteStringToFile("\r\n");
	
	WriteStringToFile(std::string(total.getData()));
	WriteStringToFile("\r\n");
	
	WriteStringToFile(std::string(sucess.getData()));
	WriteStringToFile("\r\n");
	
	WriteStringToFile(std::string(fail.getData()));
	WriteStringToFile("\r\n");
	
	WriteStringToFile(std::string(serverClose.getData()));
	WriteStringToFile("\r\n");
	
	WriteStringToFile(std::string(loginFail.getData()));
	WriteStringToFile("\r\n");
}
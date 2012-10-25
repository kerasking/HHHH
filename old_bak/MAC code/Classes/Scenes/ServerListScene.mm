/*
 *  ServerListScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "ServerListScene.h"
#import "NDUIFrame.h"
#import "NDUILabel.h"
#import "NDDirector.h"
#import "NDBeforeGameMgr.h"
#import "LoginScene.h"
#import "InitMenuScene.h"
#import "NDDataTransThread.h"
#include "NDDataPersist.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"
#include "NDTextNode.h"
#include "NDConstant.h"
//#include "RobotScene.h"
#include "CGPointExtension.h"
#include "NDPath.h"
#include "GameSceneLoading.h"

#define TIMER_TAG_LOAD_SERVER (1)

using namespace NDEngine;

IMPLEMENT_CLASS(ServerListRecord, NDUINode)

ServerListRecord::ServerListRecord()
{
	m_picState = m_picSel = NULL;
	
	m_lbText = NULL;
}

ServerListRecord::~ServerListRecord()
{
	SAFE_DELETE(m_picState);
	SAFE_DELETE(m_picSel);
}

void ServerListRecord::Initialization(std::string text, int state)
{
	NDUINode::Initialization();
	
	NDUINode::SetFrameRect(CGRectMake(0, 0, 30, 30));
	
	m_lbText = new NDUILabel();
	m_lbText->Initialization();
	m_lbText->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbText->SetFrameRect(CGRectMake(0, 0, 25, 19));
	m_lbText->SetFontSize(15);
	m_lbText->SetRenderTimes(1);
	m_lbText->SetText(text.c_str());
	this->AddChild(m_lbText);
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	std::string statefile = "";
	switch (state) {
		case SERVER_STATUS_LOAD_LOW:
			statefile += "serverstate_tongchang.png";
			break;
		case SERVER_STATUS_LOAD_COMMON:
			statefile += "serverstate_huobao.png";
			break;
		case SERVER_STATUS_LOAD_HIGH:
			statefile += "serverstate_yongji.png";
			break;
		case SERVER_STATUS_LOAD_OVER:
			statefile += "serverstate_chaofuhe.png";
			break;
		case SERVER_STATUS_LOAD_FULL:
			statefile += "serverstate_manyuang.png";
			break;
		case SERVER_STATUS_STOP:
			statefile += "serverstate_weihuzhong.png";
			break;
		default:
			break;
	}
	
	if (!statefile.empty()) 
	{
		m_picState = picpool.AddPicture(NDPath::GetImgPathNew(statefile.c_str()));
	}
}

void ServerListRecord::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	
	if (m_lbText) m_lbText->SetFrameRect(CGRectMake(80, (rect.size.height-15)/2, rect.size.width, rect.size.height));
	
	if (rect.size.width != 0 && rect.size.width != 0 && !m_picSel)
		m_picSel = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bg_focus.png"), rect.size.width*2/3-20, rect.size.height-4);
}

void ServerListRecord::draw()
{
	NDUINode::draw();	
	if (this->IsVisibled()) 
	{
		NDUILayer* parentNode = (NDUILayer*)this->GetParent();
		
		CGRect scrRect = this->GetScreenRect();
		
		//backgroud
		/*
		DrawRecttangle(scrRect, ccc4(255, 255, 255, 250));

		DrawLine(scrRect.origin, ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)), ccc4(89, 188, 200, 255), 1);
		DrawLine(ccpAdd(scrRect.origin, ccp(1, 0)), ccpAdd(scrRect.origin, ccp(1, scrRect.size.height)), ccc4(238, 248, 249, 255), 1);
		
		DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width-2, 0)), ccpAdd(scrRect.origin, ccp(scrRect.size.width-2, scrRect.size.height)), ccc4(238, 248, 249, 255), 1);
		DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width-1, 0)), ccpAdd(scrRect.origin, ccp(scrRect.size.width-1, scrRect.size.height)), ccc4(89, 188, 200, 255), 1);
		*/
		if (parentNode->GetFocus() == this && m_picSel) 
		{
			CGSize size = m_picSel->GetSize();
			
			int iStartX = 50;
			
			if (m_lbText) iStartX = m_lbText->GetFrameRect().origin.x - 50;
			
			m_picSel->DrawInRect(CGRectMake(scrRect.origin.x+iStartX, scrRect.origin.y+(scrRect.size.height-size.height)/2, size.width, size.height));
		}
		
		if (m_picState) 
		{
			CGSize size = m_picState->GetSize();
			
			int iStartX = scrRect.size.width-size.width-10;
			
			m_picState->DrawInRect(CGRectMake(iStartX, scrRect.origin.y+(scrRect.size.height-size.height)/2, size.width, size.height));
		}
	}
}


/////////////////////////////////////////
std::string STATE_NAMES[SERVER_STATUS_END] = {" (通畅)"," (火爆)"," (拥挤)","(超负荷)"," (满员)","(维护中)"};
int STATE_COLOR[SERVER_STATUS_END] = {0x7CFC00,0xFFFF00,0xFF0000,0xA52A2A,0xFF00FF,0x0B2212}; 
#define STATE_RGB(state_color) (ccc4(state_color&0xff, state_color>>8&0xff, state_color>>16&0xff,255))

IMPLEMENT_CLASS(ServerListScene, NDScene)

ServerListScene* ServerListScene::Scene()
{
	ServerListScene* scene = new ServerListScene();	
	scene->Initialization();	
	return scene;
}

ServerListScene::ServerListScene()
{
	m_menuLayer		= NULL;
	m_tableLayer	= NULL;
	m_curSection	= NULL;
	m_curCellIndex	= -1;
	m_timer			= NULL;
	m_timeCallCount	= 0;
}

ServerListScene::~ServerListScene()
{	
	if (m_timer)
	{
		m_timer->KillTimer(this, TIMER_TAG_LOAD_SERVER);
		delete m_timer;
	}
}

void ServerListScene::Initialization()
{
	NDScene::Initialization();
	
	m_timer = new NDTimer;
	m_timer->SetTimer(this, TIMER_TAG_LOAD_SERVER, 1.5f);
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILayer *layer = new NDUILayer();
	layer->Initialization();
	layer->SetBackgroundImage(NDPath::GetImgPathNew("login_background.png"));
	layer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(layer);
		
	m_menuLayer = new NDUILayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetBackgroundImage(NDPath::GetImgPathNew("createrole_bg.png"));
	m_menuLayer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	layer->AddChild(m_menuLayer);
	
	NDCombinePicture *combinePic = new NDCombinePicture;
	for (int i = 0; i < 5; i++) 
	{
		NDPicture *pic = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text.png"));
		pic->Cut(CGRectMake(96, 24*i, 24, 24));
		combinePic->AddPicture(pic, CombintPictureAligmentRight);
	}
	
	NDUIImage *imgSelServer = new NDUIImage;
	imgSelServer->Initialization();
	imgSelServer->SetFrameRect(CGRectMake(182, 16, 120, 24));
	imgSelServer->SetCombinePicture(combinePic, true);
	m_menuLayer->AddChild(imgSelServer);
	
	m_btnCancel = new NDUIOkCancleButton;
	m_btnCancel->Initialization(CGRectMake(305, 276, 77, 26),false);
	m_btnCancel->SetDelegate(this);
	m_menuLayer->AddChild(m_btnCancel);
	
//	if ( m_menuLayer->GetCancelBtn() ) 
//	{
//		m_menuLayer->GetCancelBtn()->SetDelegate(this);
//	}
	
	
//	NDUILabel* lblTitle = new NDUILabel();
//	lblTitle->Initialization();
//	lblTitle->SetFrameRect(CGRectMake(0, 0, 480, m_menuLayer->GetTitleHeight()));
//	lblTitle->SetText("选择服务器");
//	lblTitle->SetFontColor(ccc4(255, 232, 0, 255));
//	lblTitle->SetTextAlignment(LabelTextAlignmentCenter);
//	m_menuLayer->AddChild(lblTitle);
	
	m_btnOk = new NDUIOkCancleButton;
	m_btnOk->Initialization(CGRectMake(96, 276, 77, 26), true);
	m_btnOk->SetDelegate(this);
	m_menuLayer->AddChild(m_btnOk);
}

void ServerListScene::OnButtonClick(NDUIButton* button)
{
	if ( button == m_btnCancel)
	{
#if USE_ROBOT == 0
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
#else
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
#endif
	}
	else if ( button == m_btnOk)
	{
		OnClickOk();
	}

}
void ServerListScene::OnClickOk()
{
	if (!m_tableLayer || !m_curSection || m_curCellIndex == (unsigned int)-1) {
		return;
	}
	
	vector<NDBeforeGameMgr::big_area> vec_big_area = NDBeforeGameMgrObj.GetServerList();
	if (vec_big_area.empty()) 
	{
		return;
	}
	
	vector<NDBeforeGameMgr::big_area>::iterator it = vec_big_area.begin();
	for (; it != vec_big_area.end(); it++) 
	{
		NDBeforeGameMgr::big_area area = (*it);
		if ( area.name != m_curSection->GetTitle() ) 
			continue;
		
		if ( area.vec_lines.size() <= m_curCellIndex ) 
			break;
		
		NDBeforeGameMgr::big_area::line line = area.vec_lines[m_curCellIndex];
		NDBeforeGameMgr& beforeGameMgrObj = NDBeforeGameMgrObj;
		beforeGameMgrObj.SetServerInfo(area.ip.c_str(), line.displayName.c_str() ,line.sendName.c_str(), area.iPort);
		
#if USE_ROBOT == 1
        /*
		NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(RobotScene));
		if (scene) 
		{
			((RobotScene*)scene)->SetServerName(NDBeforeGameMgrObj.GetServerDisplayName());
		}
		NDDirector::DefaultDirector()->PopScene();
		return;
         */
#endif
		
		if (beforeGameMgrObj.IsInRegisterState() || beforeGameMgrObj.IsInAccountListState()) 
		{
			// 保存本次登录服务器信息
			NDDataPersist loginData;
			
			loginData.SetData(kLoginData, kLastServerIP, beforeGameMgrObj.GetServerIP().c_str());			
			loginData.SetData(kLoginData, kLastServerName, beforeGameMgrObj.GetServerDisplayName().c_str());			
			loginData.SetData(kLoginData, kLastServerSendName, beforeGameMgrObj.GetServerName().c_str());			
			NSString* strPort = [NSString stringWithFormat:@"%d", beforeGameMgrObj.GetServerPort()];
			loginData.SetData(kLoginData, kLastServerPort, [strPort UTF8String]);
			
			loginData.SaveLoginData();
			
			//NDDataTransThread::DefaultThread()->Start(beforeGameMgrObj.GetServerIP().c_str(), beforeGameMgrObj.GetServerPort());			
//			if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//			{
//				// 回到初始菜单
//				NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(),true);
//				showDialog(NDCommonCString("tip"), "网络连接失败");
//				return;
//			}
			//ShowProgressBar;
			//beforeGameMgrObj.CheckVersionAndLogin();
			
			NDDirector::DefaultDirector()->ReplaceScene(GameSceneLoading::Scene(true, LoginTypeSecond));
			return;
		}
		
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(true), true);
		
		return;
	}
	NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
}

void ServerListScene::OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	m_curSection = section;
	m_curCellIndex = cellIndex;
	return;
}

void ServerListScene::OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	OnClickOk();
}

void ServerListScene::OnDlgBackGroundBtnClick(NDDlgBackGround* dlgBG, std::string text, int iTag, unsigned int btnIndex)
{
	//exit(0);
}

void ServerListScene::ShowDialog(std::string title, std::string content)
{
	if (!m_menuLayer) return;
	
	NDDlgBackGround *dlg = new NDDlgBackGround;
	dlg->Initialization();
	dlg->SetDelegate(this);
//	std::vector<std::string> vec_str; std::vector<int> vec_id;
//	vec_str.push_back("确定"); vec_id.push_back(1);
//	dlg->InitBtns(vec_str, vec_id);
	
	NDUILabel *lb = new NDUILabel();
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentCenter);
	lb->SetFontColor(ccc4(255, 255, 0, 255));
	lb->SetText(title.c_str());
	lb->SetFrameRect(CGRectMake(17, 5, 300 - 34, 20));
	
	CGSize textSize;
	textSize.width = 300 - 34;
	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(content.c_str(), textSize.width, 13);
	
	float txtHeight = 80 < textSize.height ? 80 : textSize.height;
	NDUIText *memo = NDUITextBuilder::DefaultBuilder()->Build(content.c_str(), 
															  13, 
															  CGSizeMake(300 - 34, txtHeight), 
															  ccc4(255, 255, 255, 255),
															  true);
	memo->SetFrameRect(CGRectMake(17, 10 + lb->GetFrameRect().size.height, 300 - 34, txtHeight + 10));		
	dlg->AddChild(memo);
	
	dlg->AddChild(lb);
	dlg->SetFrameRect(CGRectMake((480-300)/2, (320-17-20-txtHeight - 10-32)/2, 300, 17+20+txtHeight+10+32));
	
	m_menuLayer->AddChild(dlg, UIDIALOG_Z);
}

void ServerListScene::OnTimer(OBJID tag)
{
	if	(tag == TIMER_TAG_LOAD_SERVER && m_timer)
	{
		if (m_timeCallCount == 0) 
		{
			ShowProgressBar;
			m_timeCallCount++;
			return;
		}
		
		m_timer->KillTimer(this, TIMER_TAG_LOAD_SERVER);
		delete m_timer;
		m_timer = NULL;
		
		NDBeforeGameMgrObj.Load();
		
		CloseProgressBar;
		
		vector<NDBeforeGameMgr::big_area> vec_big_area = NDBeforeGameMgrObj.GetServerList();
		if (vec_big_area.empty()) 
		{
			ShowDialog(NDCommonCString("tip"), NDCommonCString("ConnectServerErr"));
			//this->ShowDialog(NDCommonCString("tip"), NDCommonCString("ConnectServerErr"));
			return;
		}
		m_tableLayer = new NDUIDefaultTableLayer;
		m_tableLayer->Initialization();
		m_tableLayer->SetCellsInterval(0);
		m_tableLayer->SetCellsLeftDistance(15);
		m_tableLayer->SetCellsRightDistance(15);
		m_tableLayer->SetSectionTitlesHeight(30);
		m_tableLayer->SetSectionTitlesAlignment(LabelTextAlignmentLeft);
		m_tableLayer->SetCellBackgroundPicture("server_bg.png");
		m_tableLayer->VisibleScrollBar(false);
		m_tableLayer->SetFrameRect(CGRectMake(30, 47, 420, 220));
		NDDataSource *dataSource = new NDDataSource;
		vector<NDBeforeGameMgr::big_area>::iterator it = vec_big_area.begin();
		for (; it != vec_big_area.end(); it++) 
		{
			NDBeforeGameMgr::big_area area = (*it);
			NDSection *section = new NDSection;
			section->SetTitle(area.name.c_str());
			section->UseCellHeight(true);
			for (int i = 0; i<area.iLines; i++) 
			{
				if ( int(area.vec_lines.size()) <= i 
					|| area.vec_lines[i].iState >= SERVER_STATUS_END
					|| area.vec_lines[i].iState < SERVER_STATUS_LOAD_LOW 
					) 
				{
					break;
				}
				
				NDBeforeGameMgr::big_area::line line = area.vec_lines[i];
				
				/*
				 NDUIButton* button = new NDUIButton();
				 button->Initialization();
				 button->SetFocusColor(ccc4(253, 253, 253, 255));
				 //std::string title = line.displayName;
				 //			title.append("         ");
				 //			title.append(STATE_NAMES[line.iState]);
				 //			button->SetTitle(title.c_str());
				 //			button->SetFontSize(16);
				 //			button->SetFontColor(ccc4(255, 255, 255, 255));
				 button->SetText(line.displayName.c_str(),
				 STATE_NAMES[line.iState].c_str(),
				 20,
				 INTCOLORTOCCC4(0x0B2212),
				 INTCOLORTOCCC4(STATE_COLOR[line.iState]),
				 16,
				 16);
				 
				 */
				
				ServerListRecord *record = new ServerListRecord;
				record->Initialization(line.displayName, line.iState);
				section->AddCell(record);
			}
			
			dataSource->AddSection(section);
		}
		
		//m_tableLayer->SetStyle(DefaultTableLayerStyle_MutiSection);
		m_tableLayer->SetDataSource(dataSource);
		//m_tableLayer->OpenSection(0);
		m_tableLayer->SetDelegate(this);
		
		m_menuLayer->AddChild(m_tableLayer);
		
		CloseProgressBar;
	}
}
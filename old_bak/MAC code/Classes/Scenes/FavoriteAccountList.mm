/*
 *  FavoriteAccountList.mm
 *  DragonDrive
 *
 *  Created by wq on 11-2-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FavoriteAccountList.h"
#include "LoginScene.h"
#include "NDDirector.h"
#include "NDBeforeGameMgr.h"
#include "ServerListScene.h"
#include "NDUtility.h"
#include "NDPath.h"

/*
IMPLEMENT_CLASS(FavoriteAccountList, NDScene)

FavoriteAccountList* FavoriteAccountList::Scene()
{
	FavoriteAccountList* scene = new FavoriteAccountList();
	scene->Initialization();
	return scene;
}

FavoriteAccountList::FavoriteAccountList()
{
	m_accountList = NULL;
	m_menuLayer = NULL;
	m_lastAccountCellIndex = 0;
}

FavoriteAccountList::~FavoriteAccountList()
{
	
}

void FavoriteAccountList::Initialization()
{
	NDScene::Initialization();
	
	this->m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	
	m_menuLayer->SetDelegate(this);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	NDUILabel* title = new NDUILabel();
	title->Initialization();
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetText("请选择账号");
	title->SetFrameRect(CGRectMake(0, 5, winSize.width, 20));
	title->SetFontSize(20);
	title->SetFontColor(ccc4(255, 231, 0,255));
	m_menuLayer->AddChild(title);
	
	this->m_accountListData.GetAccount(this->m_vAccount);
	
	this->m_accountList = new NDUITableLayer;
	m_accountList->Initialization();
	m_accountList->VisibleSectionTitles(false);
	
	NDDataSource *ds = new NDDataSource;
	NDSection *sec = new NDSection;
	
	for (VEC_ACCOUNT::reverse_iterator it = m_vAccount.rbegin(); it != m_vAccount.rend(); it++) {
		NDUIButton *acc = new NDUIButton;
		acc->Initialization();
		acc->SetTitle((*it).first.c_str());
		acc->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(acc);
	}
	
	ds->AddSection(sec);
	m_accountList->SetDelegate(this);
	m_accountList->SetDataSource(ds);
	m_accountList->SetCellsInterval(1);
	m_accountList->SetFrameRect(CGRectMake(10, 30, 460, 234));
	m_accountList->SetCellsLeftDistance(2);
	m_accountList->SetCellsRightDistance(2);
	m_menuLayer->AddChild(m_accountList);
}

void FavoriteAccountList::OnButtonClick(NDUIButton* button)
{
	if ( m_menuLayer && (button == m_menuLayer->GetCancelBtn()) )
	{
		NDDirector::DefaultDirector()->PopScene(NULL, true);
	}
}

void FavoriteAccountList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	VEC_ACCOUNT_REVERSE_IT it = m_vAccount.rbegin();
	for (uint i = 0; it != m_vAccount.rend() && i < cellIndex; i++, it++) {
	}
	
	if (it == m_vAccount.rend()) {
		return;
	}
	
	string userName = it->first;
	string pwd = it->second;
	
	m_accountListData.SetData(kLoginData, kLastAccountName, userName.c_str());
	
	if (pwd.empty()) { // 无密码,进登录界面
		m_accountListData.SetData(kLoginData, kLastAccountPwd, "");
		m_accountListData.SaveLoginData();
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene());
	} else { // 有密码,进服务器列表界面
		m_accountListData.SetData(kLoginData, kLastAccountPwd, pwd.c_str());
		m_accountListData.SaveLoginData();
		
		m_accountListData.AddAcount(userName.c_str(), pwd.c_str());
		m_accountListData.SaveAccountList();
		
		NDBeforeGameMgr& beforeGameObj = NDBeforeGameMgrObj;
		beforeGameObj.SetUserName(userName);
		beforeGameObj.SetPassWord(pwd);
		beforeGameObj.m_LoginState = NDBeforeGameMgr::eLS_AccountList;

		NDDirector::DefaultDirector()->ReplaceScene(ServerListScene::Scene());
	}
}

*/

#pragma mark 新的账号列表

IMPLEMENT_CLASS(AccountListRecord, NDUINode)

AccountListRecord::AccountListRecord()
{
	m_picSel = NULL;
	
	m_lbText = NULL;
}

AccountListRecord::~AccountListRecord()
{
	SAFE_DELETE(m_picSel);
}

void AccountListRecord::Initialization(std::string text)
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
}

void AccountListRecord::SetFrameRect(CGRect rect)
{
	NDUINode::SetFrameRect(rect);
	
	if (m_lbText) m_lbText->SetFrameRect(CGRectMake(80, (rect.size.height-15)/2, rect.size.width, rect.size.height));
	
	if (rect.size.width != 0 && rect.size.width != 0 && !m_picSel)
		m_picSel = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bg_focus.png"), rect.size.width*2/3-20, rect.size.height-4);
}

void AccountListRecord::draw()
{
	NDUINode::draw();	
	if (this->IsVisibled()) 
	{
		NDUILayer* parentNode = (NDUILayer*)this->GetParent();
		
		CGRect scrRect = this->GetScreenRect();
		
		if (parentNode->GetFocus() == this && m_picSel) 
		{
			CGSize size = m_picSel->GetSize();
			
			int iStartX = 50;
			
			if (m_lbText) iStartX = m_lbText->GetFrameRect().origin.x - 50;
			
			m_picSel->DrawInRect(CGRectMake(scrRect.origin.x+iStartX, scrRect.origin.y+(scrRect.size.height-size.height)/2, size.width, size.height));
		}
	}
}


/////////////////////////////////////////
IMPLEMENT_CLASS(NewFavoriteAccountList, NDScene)

NewFavoriteAccountList* NewFavoriteAccountList::Scene()
{
	NewFavoriteAccountList* scene = new NewFavoriteAccountList();	
	scene->Initialization();	
	return scene;
}

NewFavoriteAccountList::NewFavoriteAccountList()
{
	m_menuLayer		= NULL;
	m_tableLayer	= NULL;
	m_curCellIndex	= -1;
}

NewFavoriteAccountList::~NewFavoriteAccountList()
{	
}

void NewFavoriteAccountList::Initialization()
{
	NDScene::Initialization();
	
	this->m_accountListData.GetAccount(this->m_vAccount);
	
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
	for (int i = 0; i < 2; i++) 
	{
		NDPicture *pic = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text.png"));
		pic->Cut(CGRectMake(96, 24*i, 24, 24));
		combinePic->AddPicture(pic, CombintPictureAligmentRight);
	}
	NDPicture *pic = picpool.AddPicture(NDPath::GetImgPathNew("create&login_text.png"));
	pic->Cut(CGRectMake(48, 24*9, 48, 24));
	combinePic->AddPicture(pic, CombintPictureAligmentRight);
	
	NDUIImage *imgSelServer = new NDUIImage;
	imgSelServer->Initialization();
	imgSelServer->SetFrameRect(CGRectMake(182, 16, 96, 24));
	imgSelServer->SetCombinePicture(combinePic, true);
	m_menuLayer->AddChild(imgSelServer);
	
	m_btnCancel = new NDUIOkCancleButton;
	m_btnCancel->Initialization(CGRectMake(305, 276, 77, 26),false);
	m_btnCancel->SetDelegate(this);
	m_menuLayer->AddChild(m_btnCancel);
	
	NDUIImage *imgTableBg = new NDUIImage;
	imgTableBg->Initialization();
	imgTableBg->SetFrameRect(CGRectMake(30, 47, 420, 220));
	imgTableBg->SetPicture(picpool.AddPicture(NDPath::GetImgPathNew("server_bg.png"), 420, 220), true);
	m_menuLayer->AddChild(imgTableBg);
	
	m_tableLayer = new NDUIDefaultTableLayer;
	m_tableLayer->Initialization();
	m_tableLayer->SetCellsInterval(0);
	m_tableLayer->SetCellsLeftDistance(15);
	m_tableLayer->SetCellsRightDistance(15);
	m_tableLayer->SetSectionTitlesHeight(30);
	m_tableLayer->SetSectionTitlesAlignment(LabelTextAlignmentLeft);
	//m_tableLayer->SetCellBackgroundPicture("server_bg.png");
	m_tableLayer->VisibleScrollBar(false);
	m_tableLayer->VisibleSectionTitles(false);
	m_tableLayer->SetFrameRect(CGRectMake(30, 47, 420, 210));
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	for (VEC_ACCOUNT::reverse_iterator it = m_vAccount.rbegin(); it != m_vAccount.rend(); it++) 
	{
		AccountListRecord *record = new AccountListRecord;
		record->Initialization((*it).first.c_str());
		section->AddCell(record);
	}
	
	dataSource->AddSection(section);
	m_tableLayer->SetDataSource(dataSource);
	m_tableLayer->SetDelegate(this);
	//m_tableLayer->OpenSection(0);
	m_menuLayer->AddChild(m_tableLayer);
	
	m_btnOk = new NDUIOkCancleButton;
	m_btnOk->Initialization(CGRectMake(96, 276, 77, 26), true);
	m_btnOk->SetDelegate(this);
	m_menuLayer->AddChild(m_btnOk);
	
	m_timer.SetTimer(this, 1, 1.5f);
}

void NewFavoriteAccountList::OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	m_curCellIndex = cellIndex;
	return;
}

void NewFavoriteAccountList::OnButtonClick(NDUIButton* button)
{
	if ( button == m_btnCancel)
	{
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
		//NDDirector::DefaultDirector()->PopScene(NULL, true);
	}
	else if ( button == m_btnOk)
	{
		OnClickOk();
	}
	
}
void NewFavoriteAccountList::OnClickOk()
{
	if (!m_tableLayer || m_curCellIndex == (unsigned int)-1) {
		return;
	}
	
	DealSel();
}

void NewFavoriteAccountList::OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	m_curCellIndex = cellIndex;
	
	DealSel();
}

void NewFavoriteAccountList::DealSel()
{
	VEC_ACCOUNT_REVERSE_IT it = m_vAccount.rbegin();
	for (uint i = 0; it != m_vAccount.rend() && i < m_curCellIndex; i++, it++) {
	}
	
	if (it == m_vAccount.rend()) {
		return;
	}
	
	string userName = it->first;
	string pwd = it->second;
	
	m_accountListData.SetData(kLoginData, kLastAccountName, userName.c_str());
	
	if (pwd.empty()) { // 无密码,进登录界面
		m_accountListData.SetData(kLoginData, kLastAccountPwd, "");
		m_accountListData.SaveLoginData();
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
	} else { // 有密码,进服务器列表界面
		m_accountListData.SetData(kLoginData, kLastAccountPwd, pwd.c_str());
		m_accountListData.SaveLoginData();
		
		m_accountListData.AddAcount(userName.c_str(), pwd.c_str());
		m_accountListData.SaveAccountList();
		
		NDBeforeGameMgr& beforeGameObj = NDBeforeGameMgrObj;
		beforeGameObj.SetUserName(userName);
		beforeGameObj.SetPassWord(pwd);
		beforeGameObj.m_LoginState = NDBeforeGameMgr::eLS_AccountList;
		
		NDDirector::DefaultDirector()->ReplaceScene(ServerListScene::Scene(), true);
	}	
}

void NewFavoriteAccountList::OnTimer(OBJID tag)
{
	m_timer.KillTimer(this, tag);
	
	if (m_tableLayer) 
	{
		m_tableLayer->OpenSection(0);
	}
}

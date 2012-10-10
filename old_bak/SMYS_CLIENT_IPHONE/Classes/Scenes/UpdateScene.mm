//
//  UpdateScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "UpdateScene.h"
#include "NDDirector.h"
#import "XMLReader.h"

#define TAG_INSTALL_SUCCESS 1
#define TAG_INSTALL_FAILED 2
#define TAG_TIMER_INIT		3
#define TAG_TIMER_GET_STATUS 4
#define TAG_TIMER_DOWNLOAD_SUCCESS	6
#define	TAG_REQUEST_URL_ERROR 5

IMPLEMENT_CLASS(UpdateScene, NDScene)
UpdateScene::UpdateScene()
{
	m_savePath = [[NSString stringWithFormat:@"%@DragonDrive.pxl", DataFilePath] UTF8String]; 
	m_timer = NULL;
	m_timer = new NDTimer();
}

UpdateScene::~UpdateScene()
{
	delete m_timer;
}

void UpdateScene::Initialization(const char* updateUrl, const char* title)
{
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_layer = new NDUILayer();
	m_layer->Initialization();
	m_layer->SetTouchEnabled(false);
	m_layer->SetBackgroundColor(ccc4(52, 146, 235, 255));
	m_layer->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	this->AddChild(m_layer);
	
	m_label = new NDUILabel();
	m_label->Initialization();
	m_label->SetFrameRect(CGRectMake(100, 130, 300, 30));
	m_label->SetText("正在向服务器请求下载地址......");
	m_layer->AddChild(m_label);
	
	m_progressBar = new NDUIProgressBar();
	m_progressBar->Initialization();
	m_progressBar->SetFrameRect(CGRectMake(90, 160, 300, 30));
	m_progressBar->SetStepCount(100);
	m_layer->AddChild(m_progressBar);
	
	NDUILabel* lblTitle = new NDUILabel();
	lblTitle->Initialization();
	lblTitle->SetFrameRect(CGRectMake(0, 20, 480, 30));
	lblTitle->SetTextAlignment(LabelTextAlignmentCenter);
	lblTitle->SetText(title);
	this->AddChild(lblTitle);
	
	m_updateURL = updateUrl;
	m_timer->SetTimer(this, TAG_TIMER_INIT, 0.5f);	
}

void UpdateScene::ReflashPercent(DownloadPackage* downer, int percent, int pos, int filelen)
{
	if (m_label) 
	{
		//NSString *str = [NSString stringWithFormat:@"已下载：%d\%", percent];
		//m_label->SetText([str UTF8String]);
		char buff[100] = {0x00};
		sprintf(buff, "已下载：%d\%%", percent);
		m_label->SetText(buff);
		
		m_progressBar->SetCurrentStep(percent);
	}
}

void UpdateScene::DidDownloadStatus(DownloadPackage* downer, DownloadStatus status)
{
	delete downer;
	
	if (status == DownloadStatusResNotFound) 
	{
		m_label->SetText("抱歉，下载资源未找到");
	}
	else if (status == DownloadStatusFailed)
	{
		m_label->SetText("下载失败，请检查网络链接");
	}
	else 
	{
		m_label->SetText("下载完成，正在进行安装升级，请稍候......");		
		m_timer->SetTimer(this, TAG_TIMER_DOWNLOAD_SUCCESS, 0.5f);
	}	
}

void UpdateScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog->GetTag() == TAG_INSTALL_SUCCESS) 
	{
		exit(0);
	}
	else if (dialog->GetTag() == TAG_INSTALL_FAILED)
	{
		exit(0);
	}
	else if (dialog->GetTag() == TAG_REQUEST_URL_ERROR)
	{
		exit(0);
	}
	
}

void UpdateScene::ShowRequestError()
{
	NDUIDialog* dlg = new NDUIDialog();
	dlg->Initialization();
	dlg->SetTag(TAG_REQUEST_URL_ERROR);
	dlg->SetDelegate(this);
	dlg->Show("错误", "向服务器请求下载地址失败，请重新启动程序", NULL, "确定", NULL);
}

void UpdateScene::OnTimer(OBJID tag)
{
	if (tag == TAG_TIMER_INIT) 
	{		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:m_savePath.c_str()]]) 
		{
			NSError* err = nil;
			[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:m_savePath.c_str()] error:&err];
			if (err) 
			{
				ShowRequestError();
				m_timer->KillTimer(this, TAG_TIMER_INIT);
				return;
			}
		}
		
		m_label->SetText("已下载：0\%");
		
		DownloadPackage* downer = new DownloadPackage();
		downer->SetDelegate(this);
		downer->FromUrl(m_updateURL.c_str());
		downer->ToPath(m_savePath.c_str()); 
		downer->Download();
		
		m_timer->KillTimer(this, TAG_TIMER_INIT);
	}
	else if (tag == TAG_TIMER_DOWNLOAD_SUCCESS)
	{
		InstallSelf::DefaultInstaller()->SetPackagePath(m_savePath.c_str());
		InstallSelf::DefaultInstaller()->Install();	
		m_timer->KillTimer(this, TAG_TIMER_DOWNLOAD_SUCCESS);
		
		m_timer->SetTimer(this, TAG_TIMER_GET_STATUS, 1.0f / 30.0f);
	}
	else 
	{
		InstallStatus status = InstallSelf::DefaultInstaller()->GetStatus();
		if (status == InstallStatusSuccess)
		{			
			NDUIDialog* dlg = new NDUIDialog();
			dlg->Initialization();
			dlg->SetTag(TAG_INSTALL_SUCCESS);
			dlg->SetDelegate(this);
			dlg->Show("提示", "安装成功，请重新启动程序", NULL, "确定", NULL);
			m_timer->KillTimer(this, TAG_TIMER_GET_STATUS);
		}
		else if (status == InstallStatusFailed)
		{				
			NDUIDialog* dlg = new NDUIDialog();
			dlg->Initialization();
			dlg->SetTag(TAG_INSTALL_FAILED);
			dlg->SetDelegate(this);
			dlg->Show("提示", "安装失败，请重新启动程序", NULL, "确定", NULL);
			m_timer->KillTimer(this, TAG_TIMER_GET_STATUS);
		}		
	}
	
}


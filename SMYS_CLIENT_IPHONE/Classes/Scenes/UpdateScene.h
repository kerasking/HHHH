//
//  UpdateScene.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __UpdateScene_H
#define __UpdateScene_H

#include "NDScene.h"
#include "NDUIProgressBar.h"
#include "NDUILayer.h"
#include "NDUILabel.h"
//#include "DownloadPackage.h"
#include "InstallSelf.h"
#include "NDTimer.h"
#include "NDUIDialog.h"

/*
 更新过程处理场景
 
 向已配置的服务器地址（channel.ini文件中配置）请求更新程序包信息，
 再解读信息，
 获取下载地址下载程序包。
 下载完成后直接安装，安装的方式是调用updatePxl程序.
 */

using namespace NDEngine;

class UpdateScene : 
	public NDScene, 
	//public DownloadPackageDelegate,
	public ITimerCallback,
	public NDUIDialogDelegate
{
	DECLARE_CLASS(UpdateScene)
	UpdateScene();
	~UpdateScene();
public:
	void Initialization(const char* updateUrl, const char* title); hide
// 	void ReflashPercent(DownloadPackage* downer, int percent, int pos, int filelen); override
// 	void DidDownloadStatus(DownloadPackage* downer, DownloadStatus status); override
	void OnTimer(OBJID tag); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
private:
	NDUILayer* m_layer;
	NDUIProgressBar* m_progressBar;
	NDUILabel* m_label;
	NDTimer* m_timer;
	
	std::string m_savePath, m_updateURL;
	
	void ShowRequestError();
};

#endif

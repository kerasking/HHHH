//
//  DownLoadPackage.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 文件下载器，主要用于下载更新包
 */

#ifndef __DownloadPackage_H
#define __DownloadPackage_H

#include "NDObject.h"
#include "KHttp.h"
#include "KData.h"
#include <string>

using namespace NDEngine;

bool isWifiNetWork();//判断wifi是否处于工作状态
KData getHttpProxy();//获取http代理

typedef enum
{
	DownloadStatusResNotFound,	//下载资源不存在
	DownloadStatusSuccess,		//下载成功
	DownloadStatusFailed,		//下载失败
}DownloadStatus;
//DownloadPackage类内部调用的objective-c方法，外部无需关心
// @interface MainThreadSelector : NSObject
// - (void)runWithParam:(NSArray *)param;
// @end
/*
class DownloadPackageDelegate
{
	virtual void DidDownloadStatus(DownloadStatus status){};
	virtual void ReflashPercent(int percent, int pos, int filelen){};
};
*/
//文件下载器类
class DownloadPackage 
{
	//DECLARE_CLASS(DownloadPackage)
public:
	DownloadPackage();
	~DownloadPackage();
public:
	//被下载的文件http地址
	void FromUrl(const char* url);
	//被下载的文件保存路径
	void ToPath(const char* path);
	//下载操作
	void Download();
public:
	int m_nFileLen;
	//一下三个方法可看作是私有方法，外部无需关心
	void DownloadThreadExcute();
	virtual void DidDownloadStatus(DownloadStatus status){};
	virtual void ReflashPercent(int percent, int pos, int filelen){};
public:	
	KHttp* m_pkHttp;
	std::string m_strDownloadURL, m_strDownloadPath;
	//MainThreadSelector *m_selObj;
	
};



#endif



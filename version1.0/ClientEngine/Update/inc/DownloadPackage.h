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
//#include "KHttp.h"
#include "KData.h"
#include <string>

using namespace NDEngine;

//bool isWifiNetWork();//判断wifi是否处于工作状态
KData getHttpProxy();//获取http代理

typedef enum
{
	DownloadStatusResNotFound,	//下载资源不存在
	DownloadStatusSuccess,		//下载成功
	DownloadStatusFailed,		//下载失败
}DownloadStatus;

class DownloadPackage;
class DownloadPackageDelegate	//委托
{
public:
	//下载的过程中此虚方法会被调用，用于输出下载过程的信息
	virtual void ReflashPercent(DownloadPackage* downer, int percent, int pos, int filelen){}
	//某一下载状态触发的时候，该虚方法会被调用，并输出是何种状态触发了该方法
	virtual void DidDownloadStatus(DownloadPackage* downer, DownloadStatus status){}
};

//DownloadPackage类内部调用的objective-c方法，外部无需关心
// @interface MainThreadSelector : NSObject
// - (void)runWithParam:(NSArray *)param;
// @end

//文件下载器类
class DownloadPackage : public NDObject
{
	DECLARE_CLASS(DownloadPackage)
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
	int m_fileLen;
	//一下三个方法可看作是私有方法，外部无需关心
	void DownloadThreadExcute();
	void DidDownloadStatus(DownloadStatus status);
	void ReflashPercent(int percent, int pos, int filelen);
private:	
//	KHttp* m_http;
	std::string m_url, m_path;
//	MainThreadSelector *m_selObj;
	
};



#endif



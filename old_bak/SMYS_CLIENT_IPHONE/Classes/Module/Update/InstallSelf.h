//
//  InstallSelf.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 软件的自我安装功能类
 单例类
 */

#ifndef __InstallSelf_H
#define __InstallSelf_H

#include "NDObject.h"
#include <string>
#include "NDTimer.h"

using namespace NDEngine;

typedef enum{
	InstallStatusInstalling,	//正在安装
	InstallStatusSuccess,		//安装成功
	InstallStatusFailed			//安装失败
}InstallStatus;

class InstallSelf : public NDObject, public ITimerCallback
{
	DECLARE_CLASS(InstallSelf)
	InstallSelf();
	~InstallSelf();
public:
//		
//	函数：DefaultInstaller
//	作用：获取类的对象指针，类方法的访问都通过该指针
//	参数：无
//	返回值：对象指针
	static InstallSelf* DefaultInstaller(); 
//		
//	函数：SetPackagePath
//	作用：安装文件的全路径文件名，安装之前请先调用该方法
//	参数：path全路径文件名
//	返回值：无
	void SetPackagePath(const char* path);
//		
//	函数：Install
//	作用：安装
//	参数：无
//	返回值：无
	void Install();
//		
//	函数：GetStatus
//	作用：获取安装状态
//	参数：无
//	返回值：安装状态
	InstallStatus GetStatus();
	void OnTimer(OBJID tag); override
private:
	std::string m_path;
	int m_cldPid;
	bool m_inInstalling;
	NDTimer *m_timer;
};


#endif
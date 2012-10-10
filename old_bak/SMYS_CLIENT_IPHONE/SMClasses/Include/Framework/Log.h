/**
日志类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#pragma once
#ifdef WIN32
#include <direct.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
using namespace std;

/**
在DEBUG下,使用方法:
默认在Debug目录下保存了"TQFramework+当天日期.log",日志级别为0
使用方法:
TQLOG(1, "未发现窗口[%d]配置信息", GetTemplateID());
**/
namespace TQFramework
{
	class CLog
	{
	public:
		CLog(const char* lpszDir/*保存的目录*/, const char* lpszPrefix/*文件名(不保含日期)*/, unsigned int nLogLevel/*日志级别*/);
		~CLog(void);

		//输出日志
		void Log(unsigned int nLogLevel/*日志级别*/, const char* fmt/*格式化文本*/, ...);

		void LogNoTimeTag(unsigned int nLogLevel, const char* fmt, ...);

		//设置日志级别
		void SetLogLevel(unsigned int nLevel);

		//获取日志级别
		unsigned int GetLogLevel();
	private:
		bool OpenLog(const char* lpszDir, const char* lpszPrefix);

		bool CloseLog();

		bool MakePath(const char* lpszDir, char* pFullPath, unsigned int nFullPathLen);

	private:
		FILE*	m_fpFile;
		string	m_sLogDir;
		string	m_sPrefix;

		time_t	m_tTimeLogBegin;
		time_t	m_tTimeLogEnd;
		unsigned int	m_nLogLevel;//日志级别(若TQLOG的级别小于设定的级别,则不保存)
	};
}
#endif

#ifdef _DEBUG
extern TQFramework::CLog g_logTq;
#define TQLOG	g_logTq.Log
#else
#define TQLOG	//
#endif
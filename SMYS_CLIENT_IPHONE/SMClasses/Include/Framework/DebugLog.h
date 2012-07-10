/**
屏幕调试输出类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __DEBUGLOG__ 
#define  __DEBUGLOG__ 
#include <vector>
#include <string>
using namespace std;

struct DebugLog{
	string strLog;
	long lColor;
};

class CDebugLog
{
public:

	//获取单例
	static CDebugLog& sharedInstance();

	//显示调试信息
	void ShowLog();

	//void SetLogArea(const int iWidth,const int iHeight);

	//设置Log输入显示的高度
	void SetHeight( const int iHeight );

	//输出
	void LogOut(const char* strLog/*文本*/,const long lColor=0/*颜色*/);

	//有颜色的格式化文本输出
	void LogPrintOut (const long lColor/*=0/*颜色*/,const char *format/*格式化文本*/, ...);

	//黑颜色的格式化文本输出
	void LogPrintOut (const char *format/*格式化文本*/, ...);

	//控制移动
	void OnMove(int iMoveX,int iMoveY/*Y坐标偏移*/);

	//清除所有调试信息
	void ClearLogs();

	//清除所有调试信息,除了当前显示的几行信息
	void ClearLogsButShow();

	//获取在屏幕log的左上角在屏幕上的高度
	int GetLogTop();

	//设置最多保存LOG条数
	void SetMaxLogs(const int iMax);

	//设置正在移动LOG查看LOG
	void SetIsMoving(bool bMoving=true);

	//正在移动LOG查看LOG
	bool GetIsMoving();

	//设置最多显示LOG信息的条数
	void SetShowLine(const int iShowLine);

	//获取最多显示LOG信息的条数
	int GetShowLine() const;

	//获取显示的宽度
	int GetShowWidth() const;

	//设置显示的宽度
	void SetShowWidth(const int iWidth);

protected:
	CDebugLog(void);
	~CDebugLog(void);

	int m_iShowLine;//最多显示LOG信息的条数(默认10)
	int m_iCurLine;//当前从第几行开始显示
	std::vector<DebugLog> m_vDebugLog;
	//int m_iTopShow;//开始显示的高度
	int m_iShowHeight;//log显示的高度(默认150,要加上最下面显示的FPS栏)
	int m_iShowWidth;//显示的宽度(默认为屏幕的宽度)
	bool m_bIsMoving;//正在移动LOG查看LOG(不能再自动滚屏)
	int m_iMaxLogs;//最多保存LOG条数(默认500)
private:
	int m_iScreenHeight;//屏幕的高度

};

#endif

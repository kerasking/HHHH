#ifndef __GAMEUPDATE_H__
#define __GAMEUPDATE_H__

#include "../NETWORK/myHttpFile.h"

class CGameUpdate
{
public:
	CGameUpdate(void);
	~CGameUpdate(void);
public:
	//初始化更新模块，读取本地版本号
	bool init();

	//连接版本更新服务器
	bool startUpdate();

	//在回调中接收数据及通知界面更新进度
	virtual void receiveVerPackCallBack(const char* szUri, int nPercent);

	//完成版本更新，通知游戏连接游戏服务器
	virtual bool  finishUpdate();

protected:
	bool _DownloadFile(const char* szUri, const char* szFileName);
	const char* _GetAppDocumentPath();
private:
	CMyHttpFile m_myHttpFile;


};


#endif //__GAMEUPDATE_H__
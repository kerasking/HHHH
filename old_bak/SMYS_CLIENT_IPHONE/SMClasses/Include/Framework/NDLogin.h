#ifndef __NDLOGIN__HEADER__FILE
#define __NDLOGIN__HEADER__FILE

#ifdef IOS

#include "BaseType.h"
enum eLOGIN_EVENT {
	LE_LOGIN,
    LE_LOGINCANCEL,
	LE_UPDATE,
    LE_BYRESULT,
};

class INDLoginEvent
{
public:
	virtual int NDLoginEvent(eLOGIN_EVENT eEvntID, WPARAM wParam, LPARAM lParam) = 0;
};

class CNDLogin
{
public:
	static CNDLogin& sharedInstance();
	//设置应用程序的91SDK登录的信息，这两个值是从dev.91.com上的注册开发者帐号中设置得到的。
	bool SetAppInfo(int nAppID/*应用程序的ID*/, const char* pAppKey/*应用程序的Key*/);
	
	//调用91平台的登录界面。
	bool Login();
	
	//退出91平台
	bool Logout(bool bClearAutoLogin/*是否同时取消自动登录*/);
	
	//是否自动登录91平台
	bool IsAutoLogin();
	
	//是否已经登录91平台
	bool IsLogin();
	
	//设置调试模式，主要用于支付和升级功能测试。
	void SetDebugMode();
	
	//检查程序更新,会回调UpdateResult接口
	int UpdateApp();
	
	//设置自动旋转
	void SetAutoRotation(bool bAutoRotation);
	
	//设置进入平台时的横竖屏状态。
	void SetScreenOrientation(int nOrientation);
	
	//设置事件的回调接口。返回旧的事件接口
	INDLoginEvent* SetEvent(INDLoginEvent* pEvent);
	
	//获取事件的接口
	INDLoginEvent* GetEvent();
    
    bool GetUserName(string& strUin);
    
    bool Get91SdkNickName(string& strName);
    
    void Pay(unsigned int nCount,const char *pszGoodID,const char*pszServerID,const char* pszGoodName);
    
private:
	CNDLogin(void);
	~CNDLogin(void);
	
	INDLoginEvent*	m_pEvent;
};
#endif

#endif
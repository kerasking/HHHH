/*
 *  NDBeforeGameMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_BEFORE_GAME_H_
#define _ND_BEFORE_GAME_H_

/*
 *  NDMapMgr.h
 *  DragonDrive
 *
 *  Created by wq on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Singleton.h"
#include "define.h"
#include "NDNetMsg.h"
#include "NDTransData.h"
#include "NDDataPersist.h"
#include "NDUIDialog.h"
//#include "NDDefaultHttp.h"
#include "NDTimer.h"
#include <string>
#include <vector>
#include "NDSocket.h"

#if defined(USE_NDSDK)
#include "NDSdkLogin.h"
#elif defined(USE_MGSDK)
#include "MobageSdkLogin.h"
#endif

using namespace std;
#define NDBeforeGameMgrObj	NDEngine::NDBeforeGameMgr::GetSingleton()
#define NDBeforeGameMgrPtr	NDEngine::NDBeforeGameMgr::GetSingletonPtr()

class KHttp;

namespace NDEngine
{
	class NDBeforeGameMgr : 
	public TSingleton<NDBeforeGameMgr>, 
	public NDMsgObject,
	public NDObject,
	public NDUIDialogDelegate,
	//public NDDefaultHttpDelegate,
	public ITimerCallback
	{
	public:
		NDBeforeGameMgr();
		~NDBeforeGameMgr();
		
		// http check version callback
		//void OnRecvData(id http, char* data, unsigned int len);
		//void OnRecvError(id http, NDHttpErrCode errCode);
		
		void OnDialogClose(NDUIDialog* dialog); override
		void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
		void OnTimer(OBJID tag); override
		//游戏加载时需要初始化的逻辑放这
		bool Load();
		
		/*处理感兴趣的网络消息*/
		
		bool process(MSGID msgID, NDTransData* data, int len); override
		void processLogin(NDTransData* data, int len);
		void processNotify(NDTransData* data, int len);
		void processAcquireServerInfoRecieve(NDTransData* data, int len);
		void processNotifyClient(NDTransData* data, int len);
		//void processMPFVersionMsg(NDTransData& data);
		/**其它逻辑*/
		
		void SetUserName( string name ){ username = name; };
		void SetPassWord( string pass ){ password = pass; };
		void SetServerInfo(const char* serverIP, const char* serverName, const char* serverSendName, int serverPort);
		
		string& GetUserName(){ return username; }
		string& GetPassWord(){ return password; }
		std::string& GetServerIP(){ return m_serverIP; }
		std::string& GetServerName(){ return m_serverName; }
		std::string& GetServerDisplayName(){ return m_serverDisplayName; }
		int GetServerPort(){ return m_serverPort; }
		bool CanFastLogin();
		
		void generateClientKey(); 
		void sendClientKey();

		void sendMsgConnect(int idAccount);
		
		// 注册账户by用户名,密码
		void RegisterAccout( string username, string password );
		void RegiserCallBack( int errCode, std::string strtip );/* errCode=(1,注册成功),(2,注册失败),(3,网络问题)*/
		
		// iType = 1 快速注册 , =2 快速游戏
		void FastGameOrRegister(int iType);
		void FastCallBack(int errCode, string username, int iType, std::string strtip="");/* errCode=(1,注册成功),(2,注册失败),(3,网络问题)*/
		bool IsInRegisterState(){ return m_LoginState == eLS_Register; }
		bool IsInAccountListState() { return m_LoginState == eLS_AccountList; }
		
		void CheckVersion();
		
		bool IsCMNet();
		bool SwitchToCMNet();
		void Login();
		
		bool doNDSdkLogin();
        bool doNDSdkChangeLogin();
		
		bool SynConnect();
		bool SynSEND_DATA(NDTransData& data);
		bool SynProcessData();
		void SynConnectClose();
		
		void VerifyVesion();
        
    public:
        bool SwichKeyToServer(const char* pszIp, int nPort, const char* pszAccountName, const char* pszPwd, const char* pszServerName);
        bool LoginByLastData();
        int  GetAccountListNum(void);
        const char* GetRecAccountNameByIdx(int idx);
        const char* GetRecAccountPwdByIdx(int idx);
        
        void  SetCurrentUser(unsigned int User_id) { m_CurrentUser_id = User_id; }
        unsigned int  GetCurrentUser() { return m_CurrentUser_id; }
        
        void  SetOAuthTokenOK() { m_bOAuthTokenOK = true; }
        bool  IsOAuthTokenOK() { return m_bOAuthTokenOK; }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        void  SetCurrentTransactionID(NSString* idTransaction) { m_CurrentTransactionID = idTransaction; }
        NSString*   GetCurrentTransactionID() { return m_CurrentTransactionID; }
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        void  SetCurrentTransactionID(std::string idTransaction) { m_CurrentTransactionID = idTransaction; }
        std::string   GetCurrentTransactionID() { return m_CurrentTransactionID; }
#endif
	private:
		//void CheckFail(NDHttpErrCode errCode);
		
    public:
        void CreateRole(const char* pszName, Byte nProfession, int nLookFace, const char* pszAccountName);
        void SetRole(unsigned long ulLookFace, const char* pszRoleName, int nProfession);
    private:
        unsigned long m_ulLookFace;
        std::string   m_strRoleName;
        int           m_nProfession;
        unsigned int  m_CurrentUser_id;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        NSString*     m_CurrentTransactionID;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        std::string     m_CurrentTransactionID;
#endif
		//服务器列表相关
	public:
		struct big_area
		{
			string name;
			string ip;
			int iPort;
			int iLines;
			struct line 
			{
				string displayName;
				string sendName;
				int iState;
				line()
				{
					displayName = "";
					sendName = "";
					iState = 0;
				}
			};
			
			vector<line> vec_lines;
			
			big_area()
			{
				ip = "";
				iPort = 0;
				iLines = 0;
			}
		};
	public:
		bool DownLoadServerList(bool switchNet=false);
		bool ConnectServer(const char* ip, unsigned int port, bool wapFlag,  bool switchNet=false);
        void InitAccountTable();
		void SaveAccountPwdToDB(const char* pszName, const char* pszPwd, int nType);
	public:
		vector<big_area>& GetServerList(){ return m_vecBigArea; }
		//服务器列表相关end
	private:
		std::string username;
		std::string password;
		std::string phoneKey;
		std::string serverPhoneKey;
		vector<big_area> m_vecBigArea;
		std::string m_serverIP, m_serverName, m_serverDisplayName;
		int m_serverPort;
		
		NDUIDialog *m_dlgWait;
		
		//NDDefaultHttp *m_httpCheckVersion;
		std::string m_fileUrl, m_latestVersion;
		unsigned int m_uiDlgCheckFail;
		bool m_bNeedCheck;
		NDTimer *m_timerCheckVersion;
		bool m_bInSwithCMNetState;
		
		NDSocket m_SynSocket;
		
#if (defined(USE_NDSDK) && defined(__APPLE__))
		NDSdkLogin *m_sdkLogin;
#endif
#if defined(USE_MGSDK)
        MobageSdkLogin *m_sdkLogin;
#endif
        bool m_bOAuthTokenOK;
	public:
		enum LoginState
		{
			eLS_Login,
			eLS_Register,
			eLS_AccountList,
		};
		LoginState m_LoginState;
	//
	public:
		bool CheckClientVersion( const char* szURL );
		bool isWifiNetWork();
		bool CheckFirstTimeRuning();
		void SetDeviceToken( const char * szDeviceToken ){ if ( szDeviceToken ) m_szDeviceToken = szDeviceToken;}
		std::string GetDeviceToken(){ return m_szDeviceToken;}
			
        static int CopyStatus;
        static int GetCopyStatus();
        void CopyRes();
	protected:
		std::string	m_szDeviceToken;
	};

	// 根据seed值，产生一个salt值，直接采用vc crt库的srand和rand算法
	int GetEncryptSalt(unsigned int seed);
}


#endif // _ND_BEFORE_GAME_H_


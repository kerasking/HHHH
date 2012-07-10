/*
游戏主窗口管理
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#if !defined __GAMEAPP__HEADER__
#define __GAMEAPP__HEADER__
#include "C3Primitive.h"
#include "FrameworkTypes.h"
#include "Log.h"


//游戏初始化入口
extern int InitGameInstance();

//游戏退出清理入口
extern int ExitGameInstance();

//创建目录
int CreateDirectory(const char * lpPath);

class INetHelper
{
public:
	//用户的网络线程接收到的数据，压入到框架内部时，内部派发完后，会调用此接口进行资源的释放
	virtual bool ReleaseData(void* pNetData) = 0;

	//用户封装的网络数据发送接口，内部框架会引用此接口进行网络数据发送,
	//pData可以是内存块，则lExData可为长度
	//pData也可是对象，则lExData可以用户自己解析任意值
	virtual bool SendData(const void* pData, long lExData = 0) = 0;
};

//输入HOOK的回调接口，参见CGameApp.SetTouchHook
class ITouchHook
{
public:
	//返回true，则会继续往下传，false则“吃”掉输入。
	virtual bool TouchEvent(TOUCH_EVENT_INFO& tei) = 0;
};

//网络数据包的HOOK回调接口，参见CGameApp.SetTouchHook
class INetPackageHook
{
public:
	//返回true，则会继续往下传，false则“吃”掉输入。
	virtual bool OnPackageFilter(void* pDataPkg) = 0;
};


typedef enum PLATFORM_TAG
{
	PLATFORM_WIN32,
	PLATFORM_IOS,
	PLATFORM_ANDROID,
	PLATFORM_UNKNOW,
} ePLATFORM;

class CGameApp 
{
public:
	//分发用户输入信息，一般由框架调用。
	bool DispatchUserEvent(TOUCH_EVENT_INFO& tei);	

	//设置用户输入HOOK，可以拦截所有的用户输入。配合DispatchUserEvent，可以实现"操作回放的功能"
	ITouchHook* SetTouchHook(ITouchHook* pTouchHook);

	//获取上次的触摸坐标(若不存在,则返回CPoint(-1,-1))
	CPoint GetLastTouchPos();

	//分发网络数据包，由用户的网络层调用，进行数据分发到各个可视主窗口和活动场景。
	//用户的网络包分发，一定要调用此接口。
	bool DispatchNetPackage(void* pDataPkg);

	//设置网络数据包分发时的HOOK，可以拦截分发的所有网络数据包。配合DispatchNetPackage，可以实现"网络数据回放的功能"
	INetPackageHook* SetNetPackageHook(INetPackageHook* pHook);

	//设置网络辅助接口，当用户调用DispatchNetPackage时，框架托管pDataPkg内存。
	//数据分发完成后，将调用此接口的ReleaseData进行数据释放
	INetHelper* SetHelperInterface(INetHelper* pHelperInf);

	//丢弃当前处理数据包，不进行数据分发，一般在OnNewNetPackage中调用。
	void DiscardPackage();

	//获得设备屏幕大小
	CSize GetWindowSize(void);
	
	//获得设备屏幕宽度
	int GetScreenWidth();

	//获得设备屏幕高度
	int GetScreenHeight();

	//获得设备屏幕的方向
	TQDeviceOrientation getDeviceOrientation(void);
	
	//设置游戏的最高帧速率
	void SetFrameRatio(float fRatio);

	//设置是否显示FPP、鼠标位置和Log调试(用户可以通过CDebugLog类进行日志输出)
	void SetShowDebugLog( bool bShow=true );
	
	//是否显示FPP、鼠标位置和Log调试
	bool IsShowDebugLog();

	//发送网络数据包，内部将调用INetHelper接口的SendData进行数据发送
	bool SendData(const void* pData, long lExData = 0);
	
	//获取当前程序路径
	const char* GetAppPath();

	//获取资源目录路径。
	const char* GetResPath();

	//设置长按事件的时间，默认为1秒,nElapse单位为毫秒
	void	SetLongPressTime(unsigned int nElapse);

	//获取长按事件的时间
	unsigned int GetLongPressTime();

	//获取本类的单例
	static CGameApp& sharedInstance();
	
	//设置显示激活区域
	void SetFocusRect(CRect& rc/*区域,为空则不显示激活区域*/,DWORD iColor=0xff0000/*颜色*/,int iBorder=1/*宽度*/);


	//设置UI的配置文件名(ini目录下)，只能在InitGameInstance里设置有效，且要在窗口创建之前。没有设置，则取默认值gui.ini
	bool SetUICfgFile(const char* lpFileName);

	//读取UI的配置文件名。
	const char* GetUICfgFile();

	//设置UI控件的默认字体风格
	void SetDefaultUIFontInfo(RENDER_TEXT_STYLE eStyle = RENDER_TEXT_SILHOUETTE, DWORD dwShadowColor = 0xff000000, const CPoint ptShadow = CPoint(1,1));

	//强制重新绘制帧，不处理网络消息，用户如果手动Run()方法也会重绘,但Run会处理网络消息可能会导致死循环。
	void ForceReDraw();

	//退出游戏.
	void ExitGame();

	//获取平台的类型
	ePLATFORM	GetPlatform();

	//IOS平台功能
#ifdef IOS
	//判断是否IPAD
	bool IsIPad();

	//是否支持高清屏
	bool IsRetina();
#endif


	//内部实现。外部不要调用
	bool InitApp(HEAGLDRAWABLE hEaglDrawable, const char* pszAppPath, int iWidth, int iHeight);
	void Run();

private:
	CGameApp();
	~CGameApp();


	bool MainLoop(TOUCH_EVENT_INFO* pKeyEvent, bool bHandleMsg = true);
	bool PreDraw();
	bool Draw();
	bool PostDraw();

	//显示FTP和鼠标位置
	void ShowDebugInfo();
	
	void CalcFrameRatio();
private:
	HEAGLDRAWABLE	m_hViewHandle;
	
	TOUCH_EVENT_INFO m_infoTouchLast;
	ITouchHook*		 m_pTouchHook;

	INetPackageHook* m_pNetPackageHook;

	TQTimeVal	m_timeLastFrame;//for Actions
	TQTimeVal	m_tmCurFrame;	//for Debug info
	float m_fCurFrameRatio;
	float m_fFrameInterval;
	int m_nFrameCount;
	
	struct FocusRect{
		CRect rc/*区域*/;
		DWORD iColor/*颜色*/;
		int iBorder/*宽度*/;
		FocusRect()
		{
			iColor=0xff0000/*颜色*/;
			iBorder=1/*宽度*/;
		}

	};

	int m_iTimerId;
	FocusRect m_FocusRect;
	bool	m_bShowFocusRect;//显示激活区域
	bool	m_bShowDebugLog;//是否显示FPS、鼠标位置和log
	bool   m_bDiscardPackage;
	unsigned int m_nLongPressElapse;
};

#endif

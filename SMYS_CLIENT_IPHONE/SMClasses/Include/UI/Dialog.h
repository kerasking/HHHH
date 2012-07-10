/*
 *  Dialog.h
 *  窗口类
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __BUSS_BASE_DIALOG_H__
#define __BUSS_BASE_DIALOG_H__

#include <map>
#include "DialogImpl.h"
#include "Log.h"
#include "Timer.h"

using namespace std;
//对话框
class CDialog:public CDialogImpl, public ISysTimerDelegate
{
public:
	//窗口飞的动作方向(从一个方向移动)
	enum DLG_FLY_ACTION {
		FROMTOP=0,//从上到下
		FROMBOTTOM,
		FROMLEFT,
		FROMRIGHT
	};
public: 
	CDialog();
	virtual ~CDialog();

	//该函数替换成WndProc
	//用于窗口自定义参数和命令
	//virtual void SetParam(int paramType, void* pParam);
	
	//获得控件类型 CTRL_DIALOG
 	virtual int GetType()const;

	//定时器
	virtual int OnTimer(int TimerId, void* pParam);

	//处理((用在模态对话框里))
	virtual bool Process(int nType, int nX, int nY);

	//本窗口和所有父窗口都可见时返回真(所有父窗口都是m_isVisible为真)
	virtual bool IsVisible();

	//是否可见(返回m_isVisible)
	bool IsShow();

	//执行视图动作时的回调函数(在CCtrlView也有)
	virtual void ActionCallBack(IActionCtrl* Sender, OBJ_ACTIONPOS_INFO& opInfo, bool bFinished);

	//设置是否显示窗口
	virtual void ShowDialog(bool bShow=true);

	//关闭对话框(目前对话框没有实际销毁,只是隐藏而已)
	virtual void EndDialog();

	//接收包,所有子窗口对话框都可接收到
	virtual void OnNetPackage(void* pDataPkg);
	
	//销毁窗口
	virtual void Destroy();//TODO:

	//窗口位置移动到
	virtual void MoveTo(int nX, int nY);

	//绘制窗口和子窗口画面(框架默认无调用)
	virtual void Render();

	//创建((对话框创建的函数执行顺序:
	/*CUI::CreateDialog,
			CRegistDlgClass_CDlgXXX::CreateDialog,
				CDialog::Create,
					CConstructorCtrl::ConfigDlg,
						CWndObject::Create,
							CDialog::DoCreated,
								CDialogImpl::DoCreated,
					CDialog::OnInitDialog)*/
	virtual void Create(int nIDTemplate/*资源ID号*/, CWndObject *pParent = NULL/*父窗口*/);	

	//不使用动作,置m_bFlyEffect为false
	void DisableShowAction();

	//使用动作,置m_bFlyEffect为true
	void EnableShowAction();

	//是否有动作
	bool HasShowAction();

	//设置窗口的动作
	void SetShowAction(DLG_FLY_ACTION FlyFrom=FROMTOP/*方向*/, int FlyTime=1000/*用时(ms)*/, bool isVisible=false);
	
	//此回调接口统一改为:WndProc回调接口
	//virtual void RefWndPro(int iType/*事件类型*/,CWndObject* obj/*子窗口*/,CPoint& pos/*位置*/,const void* lpParam=NULL);

	//初始化对话框
	virtual bool OnInitDialog();	

	//获取窗口实例的类名
// #if _DEBUG
	virtual	const char* GetDialogClassName();
// #endif
protected:

	//创建窗口
	virtual void DoCreated();

	bool WndProc(CWndObject* pObj/*触发消息的窗口*/,UINT message,WPARAM wParam, LPARAM lParam);
private:
	
	bool m_isInit;//对话框是否已创建(Create()后为true;若DoCreated时m_isInit为false,则执行初始化对话框OnInitDialog)
	CRect m_rcClient;//窗口位置和大小,即CWndObject::m_rect
	
	bool m_bFlyEffect;//动作
	DLG_FLY_ACTION m_FlyFrom;//方向
	int m_FlyTime;//动作执行时间
	IActionCtrl* m_pActionIn;//显示对话框的动作
	IActionCtrl* m_pActionOut;//隐藏对话框的动作
	int m_iDis;//对话框移动的偏移量
	
	//bool m_bPressed;
//	int m_count;
//	int m_timerID;
};






class CMyDialogBuilder;
typedef int DIALOG_IDD;
typedef  map<DIALOG_IDD, CMyDialogBuilder*> DLGBUILDER_MAP;//通过ID号找到对话框管理者
inline DLGBUILDER_MAP& get_DlgBuilderMap()
{
	static DLGBUILDER_MAP s_mapDlgBuilderMap;
	return s_mapDlgBuilderMap;
}
#define g_DialogBuilderMap get_DlgBuilderMap()


#define SET_DIALOGID(Dialog_ID) static int getDialogIDD(){return Dialog_ID;}

#define DIALOG_BUILDER_MUTI(Dialog_ClassName) \
class CRegistDlgClass_##Dialog_ClassName: public CMyDialogBuilder \
{\
public:\
	CRegistDlgClass_##Dialog_ClassName()\
	{\
		get_DlgBuilderMap()[Dialog_ClassName::getDialogIDD()] = this;\
	}\
	virtual CDialog* CreateDialog(){ return new Dialog_ClassName();}\
};\
CRegistDlgClass_##Dialog_ClassName regMe_##Dialog_ClassName;

//管理创建的对话框,程序一运行,s_mapDlgBuilderMap里就保存了所有还没创建的对话框的ID
#define DIALOG_BUILDER(Dialog_ClassName) \
	class CRegistDlgClass_##Dialog_ClassName: public CMyDialogBuilder \
	{\
	public:\
		CRegistDlgClass_##Dialog_ClassName()\
		{\
			get_DlgBuilderMap()[Dialog_ClassName::getDialogIDD()] = this;\
		}\
		~CRegistDlgClass_##Dialog_ClassName()\
		{\
			s_SingleDlg = NULL;\
		}\
		virtual CDialog* CreateDialog(CDialog* lpParent){ if (!s_SingleDlg) { s_SingleDlg = new Dialog_ClassName(); \
			if(s_SingleDlg!=NULL) { s_SingleDlg->Create(Dialog_ClassName::getDialogIDD(),lpParent); } } return s_SingleDlg;}\
		virtual const char* GetDialogClassName(){return #Dialog_ClassName;}\
	private:\
		static CDialog* s_SingleDlg;\
};\
CDialog* CRegistDlgClass_##Dialog_ClassName::s_SingleDlg=NULL;\
CRegistDlgClass_##Dialog_ClassName regMe_##Dialog_ClassName;

//对话框管理的基类
class CMyDialogBuilder {
public:

#ifdef WIN32
	#ifdef CreateDialog
		#undef CreateDialog
	#endif
#endif
	//创建对话框,不会重复创建;若已创建,则直接返回对应的对话框
	virtual CDialog* CreateDialog(CDialog* lpParent) = 0;
// #if _DEBUG
	virtual const char* GetDialogClassName()=0;
// #endif
};

// #if _DEBUG
// #define GetDialogClassName GetDialogClassNameA
// #else
// #define GetDialogClassName 
// #endif

#endif

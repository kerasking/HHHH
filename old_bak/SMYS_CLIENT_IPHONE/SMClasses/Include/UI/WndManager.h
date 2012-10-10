#ifndef  __WNDMANAGER_HH__
#define  __WNDMANAGER_HH__
#include "uitypes.h"

class CWndObject;
//对话框管理类
class CWndManager
{
public:

	//根据对话框ID创建对话框  
	static DLG_HANDLE CreateDialog(DLG_IDD nDialogIDD, DLG_HANDLE hParent=NULL);

	//根据窗口句柄得到窗口对象
	static CWndObject* GetDialog(DLG_HANDLE hDlg);

	//显示对话框(找到对话框句柄并显示;如果找不到,则返回false)
	static bool ShowDialog(DLG_HANDLE nDlgHandle/*句柄*/, bool bShow = true/*是否显示*/, bool bFront = false/*置顶*/);	

	//显示模态对话框
	static bool ShowModalDialog(DLG_HANDLE hModalDlg);

	//设置激活对话框
	static bool SetActiveDialog(CWndObject* lpActiveWnd);

	//设置模态对话框
	static bool SetModalDialog(CWndObject* lpModalObj);


	//取得对话框的区域大小
	static bool GetDialogRect(DLG_HANDLE hDlg, CRect& rcDialog);

	//设置对话框的区域大小
	static bool SetDialogRect(DLG_HANDLE hDlg, CRect& rcDialog);

	//发送对话框消息
	static bool SendMessage(DLG_HANDLE hDlg, UINT Msg, WPARAM wParam, LPARAM lParam =NULL);

	//判断对话框是否可视
	static bool IsDialogVisible(DLG_HANDLE hDlg);

	//移动对话框
	static bool MoveDialog(DLG_HANDLE hDlg, int nX, int nY);	

	//关闭所有对话框
	static bool CloseAllDialog();

	//获取坐标所在的控件(坐标为CPoint(-1,-1)则返回游戏主窗口)
	static CWndObject* GetPointObject(CPoint& pos);

	//根据控件获取屏幕上显示的区域
	static void GetWndViewRect(CWndObject* pWnd,CRect& reccScreen);

	//获取上次的触摸坐标(若不存在,则返回CPoint(-1,-1))
	//请改用:CGameApp::sharedInstance().GetLastTouchPos()
	//static CPoint GetLastTouchPos();

protected:
	CWndManager(void);
	~CWndManager(void);
};

#endif //__WNDMANAGER_HH__

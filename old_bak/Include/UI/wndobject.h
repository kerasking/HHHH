/*
 *  wndobject.h
 *	所有控件的基类
 *  Created by ndtq on 11-1-25.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __WND_OBJECT_H__
#define __WND_OBJECT_H__

#include <list>
#include "C3BaseFunc.h"
#include "graphic.h"
#include "uitypes.h"
#include "GameDataSet.h"
#include "DelegateEvent.h"
#include "IAniObj.h"
#include "FrameworkTypes.h"

using namespace std;

//#define _DEBUG_DRAW
#define _DEFAULT_FONT_COLOR 0xd2c2b2

class CWndObject;
typedef list<CWndObject*> LIST_CTRL;

#define CFM_BOLD 0x00000001
#define CFM_UNDERLINE 0x00000004

 /*定义控件类型,由控件的GetType()固定返回(ini里的"type"是代码生成器和界面编辑器约定的,不同,ini里的type配置:1:CDialog,2:CtrlStatic,3:CtrlButton,4:CtrlImageEx,5:CtrlList,6:CtrlComboBox,7:CtrlProgress,8:CtrlSlider,9:CCtrlCheckBox,10:CtrlEdit,
)*/
enum 
{
	CTRL_WNDOBJ,//0		  CWndObject	
	CTRL_STATIC,		//CCtrlStatic
	CTRL_IMG,    //2	  CCtrlImage
	CTRL_BUTTON,		//CCtrlButton
	CTRL_SLIDER,//4		  CCtrlSlider
	CTRL_CHECKBOX,		//CCtrlComboBox	
	CTRL_PROGRESS,//6     CCtrlProgress
	CTRL_LIST,			//CCtrlList
	CTRL_DLG,//8		//CCtrlDlg	
	CTRL_EDIT,			//CCtrlEdit
	CTRL_COMBOBOX,//10    CCtrlComboBox
	CTRL_LINK,			//CCtrlLink
	CTRL_DLG_INNER,//12    CCtrlComboBoxList(comboBox弹出的选项对话框)
	CTRL_DIALOG			 //CDialog
};

/** 
控件类关系图
CWndObject
	CCtrlView(控制视图)
		CCtrlEdit(编辑框)
		CListView(列表控件)
			CListDataView(列表数据视图)
			CListTitleView(列表标题视图)
		CCtrlDlg(对话框)
			CCtrlList(列表控件的对话框)
			CDialogImpl(自动配置对话框实现类)
				CDialog(对话框)
			CCtrlComboBox(组合框)
			CCtrlComboBoxList(comboBox弹出的选项对话框)
	CCtrlCheckBox(多选框)
	CCtrlSlider(滑块)
	CCtrlButton(按钮)
	CCtrlImage(图片控件)
	CCtrlStatic(静态文本)
	CCtrlProgress(进度条) 
	CCtrlLink(超链接)

CTabCtrl(选项卡)   
INumPad
	CNumPad(输入数字的组合控件,含CCtrlEdit,CCtrlSlider)
*/

enum //事件类型
{													//执行函数
	MSG_MOUSEENTER=1,	  //鼠标移进		MouseEnterHandler
	MSG_MOUSELEAVE,		  //鼠标移出		MouseLeaveHandler
	MSG_MOUSEMOVE,//3     //鼠标移动		MouseMoveHandler
	MSG_MOUSEDOWN,		  //鼠标按下		MouseDownHandler
	MSG_MOUSEUP,		  //鼠标弹起		MouseUpHandler
	MSG_MOUSEACTIVE,	  //鼠标激活		MouseActive
	MSG_MOUSEINACTIVE,	  //鼠标不激活		MouseActive
	MSG_KEYBOARDSHOW,	  //键盘显示		KeyboardShowed
	MSG_KEYBOARDHIDE,	  //键盘隐藏		KeyboardHidden
	MSG_KEYBOARDORGCHANGED,//改变键盘方向	KeyBoardChanged	
	MSG_KEYDOWN,		   //按下键盘		EnterKey
	MSG_BINDTOFRONT,	   //前置窗口		BindToFront
	MSG_BINDTOBACK,		   //后置窗口		BindToBack
	MSG_EDITLINKCLICK,//点击了编辑框链接(触摸弹起时触发)	WndProc(MSG_EDITLINKCLICK,编辑框,坐标,链接)
	MSG_BINDTOTOP,		  //设置置顶事件    BindToTop
	MSG_MOUSECLICKED,//16  //触摸完成点击    在WndProc里处理
	MSG_EDITBEYONDMAX,	  //编辑框字数超过最大
	MSG_DRAGTOUCH,//18	  //触摸拖动		鼠标弹起里判断并发送该消息(WPARAM)拖动到该窗口之上,(LPARAM)正要拖动的窗口
	MSG_LISTVIEWMOVE,	  //ListView拖动事件	//WndProc(message/*MSG_LISTVIEWMOVE*/, obj/*当前拖动的LIST控件*/, wParam/*鼠标拖动的位置*/, lpParam/*LPARAM类型,高位控件高度,低位pos.y */)
	MSG_LONGPRESS,		//WndProc长按事件 wPrarm :低位X坐标 高位Y坐标，lParam:NULL

	MSG_USEREVENT=1000,//用户自定事件
};

class CWndObject
{
public:
	enum  //宫格对齐方式 
	{
		LAYER_UNKNOWN,
		LAYER_LEFT_TOP,
		LAYER_RIGHT_TOP,
		LAYER_RIGHT_BOTTOM,
		LAYER_LEFT_BOTTOM,
		LAYER_TOP,
		LAYER_RIGHT,
		LAYER_BOTTOM,
		LAYER_LEFT,
		LAYER_CENTER //9 居中
	};

	enum //背景拉伸方式
	{
		BGTYPE_FIX,
		BGTYPE_NINESQUARE,		//1
		BGTYPE_NINESQUAREEX,	//2九宫格
		BGTYPE_STRETCH,			//3拉伸
		BGTYPE_PLAT,			
	};

	enum //控件垂直对齐方式
	{
		VERALIGN_TOP,//0居上
		VERALIGN_CENTER,//1居中
		VERALIGN_BOTTOM//2居下
	};

	enum  //控件水平对齐方式
	{
		HERALIGN_LEFT,//0居左
		HERALIGN_CENTER,//1居中
		HERALIGN_RIGHT//2居右
	};
	
	CWndObject();
	virtual ~CWndObject();

	//是否是最顶层的窗口CWndApp::m_rootWnd
	static bool IsRoot(CWndObject* lpWnd);

	//屏幕宽度
	static int GetScreenWidth();
	
	//屏幕高度
	static int GetScreenHeight();

	//绘制矩形框
	static void ShowRect(int x1/*左上角X坐标*/,int y1/*左上角Y坐标*/,int x2/*右下角X坐标*/,int y2/*右下角Y坐标*/,unsigned int color/*颜色*/);

	//获得字体大小
	int GetFontSize();

	//设置字体大小
	void SetFontSize(int iSize);

	//获得文本显示时的长度
	static void GetStringWidth(const char* lpStr/*文本*/,int iFontSize/*字体大小*/,int& outWidth/*获得的宽度*/,int& outHeight/*获得的高度*/,const char* fntName=NULL/*字体名*/);
	
	//无缩放显示图片
	static void DrawImgFix(char* lpAni/*ani文件里[]的名字*/,int frame/*帧号*/,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

	//无缩放显示图片,可控制显示区域
	static void DrawImgFixEx(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect/*要显示的大小*/);	

	//可缩放显示图片
	static void DrawImgStretch(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

	//可缩放显示图片,可控制显示区域
	static void DrawImgStretchEx(char* lpAni,int frame/*帧号*/,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect/*要显示的大小*/);	
	
	//
	static void DrawImgPlat(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	

	//
	static void DrawImgPlatEx(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect);		

	//
	static void DrawImgPlatEx2(CAni *pAni,int frame,CRect& imgSrc,CPoint& cntScreenOrg,CPoint& viewOrg,CRect& drawRect,CRect& showRect,CRect& cntRect);

	//
	static void DrawImgNineSquareEx(char* lpAni,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect);

	//
	static void DrawImgNineSplitSquareEx(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect,int borderSize);	
	
	//绘制图片
	static void DrawImgWithImageInterfaceEx(IImageObj* lpImg,CRect& frameRect,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,CRect& drawRect,bool isStretch);
	
	static void CumDrawImgNineSplitSquareEx(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,C3_NINESQUARE_RECT &nineSqrRect);
	
	//
	static void DrawImgNineSquare(char* lpAni,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	
	
	//
	static void DrawImgNineSplitSquare(char* lpAni,int frame,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg,int borderSize);	
	
	//
	void DrawImgWithImageInterface(IImageObj* lpImg,CRect& frameRect,CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect/*图片在屏幕上的区域*/,CPoint& viewOrg,bool isStretch);
	
	//获取图片大小
	static void GetImageSize(const char* lpAni/*ani文件里[]的名字*/,int frame/*帧*/,int& iWidth,int& iHeight);
	
	//绘制单行文本
	static void DrawText(const char* lpText/*文本*/,CPoint& cntScreenOrg/*开始绘制的原点*/,CRect& showRect,CRect& cntRect/*ini中配置的大小*/,CPoint& viewOrg,
				  int verAlign,int herAlign,int offSetX/*显示的文字X坐标偏移*/,int offSetY/*显示的文字Y坐标偏移*/,bool isTextRender/*增强的文字效果*/,unsigned int iColor,int iFontSize/*字体大小*/,int iWidth, bool isUnderLine=false,bool isBold=false);

	//绘制多行文本
	static void DrawMuliText(const char* lpText/*文本*/,CPoint& cntScreenOrg,CRect& showRect/*在本控件显示的位置大小*/,CRect& cntRect/*在父窗口的位置*/,CPoint& viewOrg,
					  int verAlign,int herAlign,int offSetX,int offSetY,bool isTextRender,unsigned int iColor,int iFontSize, bool widthSubOffSet=false);
	
	//点击时播放声音
	static void PlayClickSound();
	
	//获取九宫格大小
	static void GetNineSquareRect();

	//创建时设置窗口位置
	void Create(CRect& rect/*创建的位置大小*/,int posLayerType=LAYER_UNKNOWN/*宫格布局方式*/,CWndObject* lpParent=NULL/*父窗口*/);
	
	//释放窗口
	void DestroyWindow();	

	//绘制(parentScreenPos is the left-top conter of  parent. It is absolute value to screen.	parentDrawRect is the diplay rect for parent. that is relation value.)
	virtual void Paint(CPoint& parentScreenPos,CRect& parentDrawRect);

	//发送消息
	bool SendMessage(UINT message,WPARAM wParam, LPARAM lParam);

	//前置窗口(将窗口前置显示出来(所有子窗口不被遮挡),并触发MSG_BINDTOFRONT事件通知)
	void BindToFront();

	//将窗口前置置后
	void BindToBack();
	
	//置顶显示
	void BindToTop(bool bTop/*是否置顶*/);
	
	//将背景图片复制到背景图片1
	void PushAni();
	
	//将背景图片1复制到背景图片,设置无背景图片2
	void PopAni();
	
	//交换背景图片(若有背景图片2,则将背景图片1复制到背景图片(PopAni);否则设置背景图片为背景图片2)
	void ExchangeAni();
	
	//事件 
	MouseEvent EventMouseMove;
	ClickEvent EventClicked;//鼠标按下的事件
	MouseEvent EventMouseDown;
	MouseEvent EventMouseUp;
	ClickEvent EventMouseEnter;
	ClickEvent EventMouseLeave;
	ClickEvent EventDrag;//拖动窗口
	ClickEvent EventQuickMove;

	//设置窗口位置
	void SetClientRect(CRect& rect);

	//获得控件的位置大小
	CRect& GetClientRect();
	
	//获得视角的坐标原点
	CPoint& GetViewPos();

	//设置视角的坐标原点
	void SetViewPos(CPoint& pos);
	
	//设置窗口的背景图片
	void SetBgAni(const char* lpAni/*ani图片,若为NULL则删除原背景图片*/,int bgFillType=BGTYPE_FIX,int borderSize=0/*宽度*/);

	//设置窗口的背景图片，可指定ani文件
	void SetBgAniEx(const char* lpAni/*ani图片,若为NULL则删除原背景图片*/,const char* lpAniFile, int bgFillType=BGTYPE_FIX,int borderSize=0/*宽度*/);


	//获得窗口的背景图片
	const char* GetBgAni();

	//设置窗口的背景图片2(对应ini配置文件里的"Ani1")
	void SetBgAni2(const char* lpAni);

	//获得窗口的背景图片2
	const char* GetBgAni2();

	//直接设置窗口的背景图片(直接按默认配置调用SetBgAni)
	void SetBgAniDirect(const char* lpAni);
	
	//获得背景图片的拉伸方式
	int GetBgFillType() const;
	
	//设置背景图片的拉伸方式
	void SetBgFillType(int bgFillType/*拉伸方式*/,int borderSize=0);
	
	//设置ani背景图片帧的索引号
	void SetBgFrame(int index);

	//获得背景图片帧的索引号
	int GetBgFrame() const;
	
	//获取边框宽度
	int GetBgBorderSize()const;

	//设置边框宽度
	void SetBgBorderSize(int borderSize);
	
	//获取父窗口
	CWndObject* GetParent();
	
	//设置父窗口
	void SetParent(CWndObject* lpParent);

	//获取执行鼠标按下事件的控件
	CWndObject* GetNotifyCtrl();

	//设置执行鼠标按下事件的控件
	void SetNotifyCtrl(CWndObject* lpCtrl);
	
	//设置可见
	void SetVisible(bool bIsVisible);

	//是否可见
	bool IsVisible() const;
	
	//设置窗口激活
	void SetActive(bool active);

	//窗口是否激活
	bool IsActive() const;
	
	//设置宫格对齐方式
	void SetPosLayerType(int posLayType);
	
	//获得宫格对齐方式
	int GetPosLayerType() const;

	//返回获取控件的句柄号
	int GetHandle() const;

	//获取资源号
	virtual int GetTemplateID();

	//设置资源号
	void SetTemplateID(int templateID);

	//根据资源号找到子窗口下的控件
	CWndObject* GetDlgItem(int iTemplateID);

	//在子窗口列表里通过句柄找到对应的控件或对话框
	CWndObject* GetDlgWithHandle(int iHandle/*句柄*/);

	//是否消息透明
	bool IsMsgTransparent()const;

	//设置消息透明
	void SetMsgTransparent(bool isTransparent=true);	
	
	//是否消息穿透
	bool IsMsgThrough() const;
	
	//设置消息穿透
	void SetMsgThrough(bool isMsgThrough);
	
	//是否置顶
	bool IsTop()const;
	
	//获得视图的总大小(可以容纳所有的子窗口)
	virtual void GetViewSize(int& iWidth/*宽度*/,int& iHeight/*高度*/);


	//拖动窗口
	virtual bool MouseDragHandler(CWndObject* obj/*窗口*/,int relateX/*X坐标偏移*/,int relateY/*Y坐标偏移*/,const void* lpParam=NULL/*传参数据*/);

	//鼠标移入
	virtual void MouseEnterHandler(CWndObject* obj/*窗口*/,CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);
	
	//鼠标离开
	virtual void MouseLeaveHandler(CWndObject* obj/*窗口*/,CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);

	//鼠标移动
	virtual void MouseMoveHandler(CWndObject* obj/*窗口*/,CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);

	//鼠标正在拖动
	virtual bool MouseDragOverHandler(CWndObject* obj/*窗口*/,int relateX/*X坐标偏移*/,int relateY/*Y坐标偏移*/,const void* lpParam=NULL);

	//按下了鼠标
	virtual bool MouseDownHandler(CWndObject* obj/*窗口*/,CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);

	//弹起了鼠标
	virtual void MouseUpHandler(CWndObject* obj/*窗口*/, CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);

	//点击了鼠标
	virtual void MouseClickedHandler(CWndObject* obj/*窗口*/, CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);
	
	//激活了鼠标
	virtual void MouseActive(CWndObject* lpUnActive,CWndObject* lpActive,CPoint& pos/*鼠标位置*/,const void* lpParam=NULL);
	
	//在指定的区域中查找某一坐标上的窗口对象(若消息透明,返回NULL)
	CWndObject* PointInCtrl(CPoint& pos/*坐标*/,CRect& refRect/*区域大小*/);

	//获取控件的类型CTRL_WNDOBJ
	virtual int GetType()const;	

	//重新排列控件的布局(父窗口下的所有子窗口重新刷新一下布局)
	void SetClientRectWithLayerType(bool isDoSize=true/*是否重新设置窗口位置*/);
 

	//窗口坐标转屏幕坐标(窗口坐标是:坐标以该窗口为坐标原点)
	static void PointToScreen(CWndObject* lpSrc/*窗口*/,CPoint& point/*原窗口坐标,得到返回的屏幕坐标*/);

	//屏幕坐标转窗口坐标
	static void PointToCtrl(CWndObject* lpSrc/*窗口*/,CPoint& point/*原屏幕坐标,得到返回的窗口坐标*/);

	//控件区域转屏幕区域(控件区域是:坐标以该控件为坐标原点;例如rc为CRect(0,0,控件宽度,控件高度),则返回的是该控件在屏幕的区域)
	static void RectToScreen(CWndObject* lpSrc/*控件*/,CRect& rc/*区域*/);

	//向左上方向偏移该控件的屏幕坐标大小
	static void RectToCtrl(CWndObject* lpSrc,CRect& rc);
	
	//获取所在的主窗口(该主窗口的父窗口是游戏窗口)
	static CWndObject* GetOwnerDlg(CWndObject* lpCtrl);

	//获取两区域的相交区域( 若相交区域为空则返回false;参照GetCutRect函数)
	static bool RectIntersect(CRect& src1 /*区域1*/,CRect& src2/*区域2*/,CRect& resultRec/*相交区域*/);

	//重新计算控件的布局大小
	static void ReCalauSizeWithLayer(int layerType,CRect& rect/*要设置的控件大小*/,int iWidth/*控件宽度*/,int iHeght/*控件高度*/,int iPWidth/*父窗口宽度*/,int iPHeight/*父窗口高度*/);	
	
	//获取两区域裁剪大小,即相交(共同拥有)的区域大小(若相交区域偏移一定坐标后大小小于0,则返回false;参照RectIntersect函数)	
	static bool GetCutRect(CRect& imgRect/*区域1*/,CRect& showRect/*区域2*/,CPoint& viewOrg/*偏移坐标*/,CRect& resultRect/*相交区域*/); 


	//分派事件处理(默认往上层递归派发,see:MSG_XXX)
	void DispatchRef(int iType/*类型*/,CWndObject* obj/*处理的控件*/,CPoint& pos/*位置*/,const void* lpParam=NULL);

	//处理本窗口和子窗口事件(SendMessage后处理的事件;自定义事件消息名的值不能取1-18的系统事件,取MSG_USEREVENT以上的事件)
	virtual bool WndProc(CWndObject* pObj/*触发消息的窗口*/, UINT nMessage/*事件消息名*/,WPARAM wParam/*若是系统事件则为坐标*/, LPARAM lParam);

	//获得子窗口链表
	LIST_CTRL& GetChild();

	//获得视图的总大小(可以容纳所有的子窗口)
	virtual void GetViewRect(CRect& size); 


	//窗口前置显示
	void BindToFrontEx();

	//
	void BindToBackEx();

	//
	void BindToFront(CWndObject* lpCld);

	//窗口置后显示
	void BindToBack(CWndObject* lpCld);

	//删除一个子窗口,lpChild为要查找的子窗口
	void RemoveCld(CWndObject* lpChild);

	//删除全部子窗口
	void RemoveAllCld();

	//增加一个子窗口
	void AddCld(CWndObject* lpChild);

	//
	void BindToTopEx(bool bTop);

	//
	void BindToTop(CWndObject* lpCld,bool bTop);

#if _DEBUG
	static bool IsDrawDebugRect();
#endif

	//绘制正在拖动的窗口
	virtual void PaintDragTouchImage(CPoint& posDragTouch/*坐标*/,CRect& rcScreen);

	//设置是否允许拖动(if the obj EnableDragTouch flag is true,the obj's parent can reciev)
	virtual void EnableDragTouch(bool bDragTouchEnable);

	//是否允许拖动
	virtual bool IsDragTouchEnable();

protected:

	//控件创建后触发
	virtual void DoCreated();

	//正要改变窗口大小(在SetClientRect之前触发,返回失败则不执行SetClientRect)
	virtual bool DoSizing(CRect& rect/*改变后的窗口大小*/);

	//改变窗口大小后(SetClientRect后触发)
	virtual void DoSized(CRect& rect/*改变后的窗口大小*/);

	//only used CTRL_DLG 
	virtual void DoActive(CWndObject* lpPreActive);

	virtual void DoInActive(CWndObject* lpActive);

	//改变窗口是否显示后触发
	virtual void DoShow(bool isShow/*改变后是否显示*/);

	//改变视角的坐标原点事件(SetViewPos后触发)
	virtual void DoViewPos(CPoint& pos);

	//释放资源
	virtual void DoDestroy();
	
	//绘制窗口背景
	virtual void DoPaintBackground(CPoint& cntScreenOrg/*开始绘制的原点*/,CRect& showRect/*在原图片上显示的大小*/,CRect& cntRect/*图片在屏幕上的区域*/,CPoint& viewOrg/*视图原点*/);

	//绘制窗口的前景(如显示文本,显示对话框上的动作精灵)
	virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg/*视图原点*/);

	//绘制滑块
	virtual void DoPaintSlider(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);	
protected:
	int m_iFontSize;//字体大小
	bool m_bDragTouchEnable;//允许拖动(先按下再拖动)
	CPoint m_posDragOffset;//拖动时的位置相对于原控件位置的偏移距离
	bool m_isVisible;//是否显示
	//wstring m_strCaption;

private:
	static C3_NINESQUARE_RECT m_NineSquareRect;//九宫格
	CRect m_rect; //控件的位置大小
	int m_posLayerType;//宫格对齐方式(ini文件里的"layertype")
	CPoint m_viewPos;//视角的坐标原点
	
	CWndObject* m_lpParent;//父窗口
	CWndObject* m_lpNotifyCtrl;//穿透配置:绑定到执行鼠标按下事件的控件(两个控件会同时触发消息)
	
	bool m_isActive;//窗口是否激活
	LIST_CTRL m_lstChld;//子窗口列表(双向链表)
	int m_handle;//句柄(每个控件都拥有唯一的一个句柄号)
	
	char* m_lpBgAni;//背景图片
	int m_bgFillType;//背景拉伸方式
	int m_bgFrame;//背景ani文件的图片帧id号(enNormal,enDown,enDisable,enActive)
	int m_templateID;//每个对话框或对话框的资源ID
	int m_iNineBorderSize;//边框宽度
	bool m_bMsgTransparent;//消息透明(例:在指定的区域中查找某一坐标上的窗口对象,若消息透明,则取消查找;默认false)

	bool m_bMsgThrough;//消息穿透,默认false;在指定的区域中查找某一坐标上的窗口对象,若消息穿透,则再进入该窗口的子窗口查找
	
	char* m_lpBKAni;//背景图片1
	char* m_lpAni2;//背景图片2(备用图片,为了切换图片)
	bool m_bAni2;//有背景图片2
	bool m_isTop;//是否在最上面(控件或窗口不被遮挡)
};

#endif 
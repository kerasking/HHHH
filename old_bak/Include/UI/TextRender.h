#ifndef __HTMLHELPER_HH__
#define __HTMLHELPER_HH__
/*支持HTML的文字显示
*/

#include "ParserDom.h"
#include "WndObject.h"
#include "DataConvert.h"

using namespace std;
#define _DEFAULT_FONT_SIZE 12

#ifndef _WIN32
/*
 * Edit Control Styles
 */
// 水平居左/居中/居右
#define ES_LEFT             0x0000L
#define ES_CENTER           0x0001L
#define ES_RIGHT            0x0002L
#define ES_MULTILINE        0x0004L
// #define ES_UPPERCASE        0x0008L
// #define ES_LOWERCASE        0x0010L
#define ES_PASSWORD         0x0020L
// #define ES_AUTOVSCROLL      0x0040L
// #define ES_AUTOHSCROLL      0x0080L
// #define ES_NOHIDESEL        0x0100L
// #define ES_OEMCONVERT       0x0400L
#define ES_READONLY         0x0800L
// #define ES_WANTRETURN       0x1000L
// #define ES_NUMBER           0x2000L
#endif

//垂直居上/居中/居下(通过SetStyle(ES_RIGHT|ES_VTOP)设置
#define ES_VTOP				 0x4000L
#define ES_VCENTER           0x8000L
#define ES_VBOTTOM           0x10000L

//HTML属性
typedef struct sHtmlObj
{
	unsigned int m_color;//颜色
	unsigned int m_size;//字体大小
	bool m_isLink;//是否是链接
	//CWndObject* m_lpObj;
	char* m_lpHref;//链接文本
	char* m_lpText;//显示文本
	sHtmlObj()
	{
		m_size=_DEFAULT_FONT_SIZE;
		m_color = _DEFAULT_FONT_COLOR;
		m_isLink = false;
		m_lpText = NULL;
		//m_lpObj = NULL;
		m_lpHref = NULL;
	};
}HtmlObj,*LPHtmlObj;

//mac os
//keyboard type键盘类型
enum
{
	KT_UIKeyboardTypeDefault,
	KT_UIKeyboardTypeASCIICapable,
	KT_UIKeyboardTypeNumbersAndPunctuation,
	KT_UIKeyboardTypeURL,
	KT_UIKeyboardTypeNumberPad,     //iPad
	KT_UIKeyboardTypePhonePad,		//iPhone
	KT_UIKeyboardTypeNamePhonePad,  //iPhone & iPad
	KT_UIKeyboardTypeEmailAddress
};

//clear btn mode
enum
{
	KT_UITextFieldViewModeNever,
	KT_UITextFieldViewModeWhileEditing,
	KT_UITextFieldViewModeUnlessEditing,
	KT_UITextFieldViewModeAlways
};

//编辑框返回类型(return type)
enum
{
	KT_UIReturnKeyDefault,
	KT_UIReturnKeyGo,
	KT_UIReturnKeyGoogle,
	KT_UIReturnKeyJoin,
	KT_UIReturnKeyNext,
	KT_UIReturnKeyRoute,
	KT_UIReturnKeySearch,
	KT_UIReturnKeySend,
	KT_UIReturnKeyYahoo,
	KT_UIReturnKeyDone,
	KT_UIReturnKeyEmergencyCall,
};
//end mac os

//#define _DEFAULT_CURSOR_COLOR 0xffd2c2b2
#define _DEFAULT_CURSOR_COLOR 0xffffffff
#define _DEFAULT_FONT_BG_COLOR 0xff000000
#define _DEFAULT_CURSOR_SIZE 2

#define _MAX_LENGTH_PASSWORD 256
#define _PWD_SHOW_CHAR '*'
extern char g_PwdShowStr[_MAX_LENGTH_PASSWORD];

//一个字的属性
typedef struct tagTextAtt
{
	char* m_fntName;//字体名称
	int m_fntSize;//文字高度
	int m_fntColor;	//字体颜色
	int m_iRef; //文字计数
	tagTextAtt();
}TextAtt,*LPTextAtt;//一个字的属性

//一行文本
typedef struct tagLineAtt
{
	int m_iStart;//开始位置
	int m_iEnd;//结束位置
	int m_iHeight;//一行的高度
	int m_iWidth;
	tagLineAtt();
}LineAtt,*LPLineAtt;//一行文本

//超链接
typedef struct tagLinkAtt
{
	bool m_isClick;//是否点击过
	char* m_lpHref;//超链接保存的文本(如:event:player-1411;非显示的文本)
	int m_iRef;
	unsigned int m_clrNormal;//字体颜色
	unsigned int m_clrClicked;//点击后的字体颜色
	tagLinkAtt();
}LinkAtt,*LPLinkAtt;//超链接

typedef struct tagTextItem
{
	bool m_isObj;//是否为控件
	bool m_isAutoDestory;//是否自动销毁
	CWndObject* m_lpObj;//控件
	LPLinkAtt m_lpLinkAtt;//超链接
	char m_char[4];//一个字
	int m_iHeight;//一个字的高度
	int m_iWidth;//一个字的宽度
	LPTextAtt m_lpAtt;	//一个字的属性
	tagTextItem();
}TextItem,*LPTextItem;//一个字

//可视的文本属性
typedef struct tagVisibleItem
{
	CRect m_Rect;//显示区域
	CRect m_selRect;//选中的区域(要画背景)
	string m_str;//显示文本
	LPTextAtt m_lpAtt;//一个字的属性
	LPLinkAtt m_lpLink;//超链接
	int m_itemCount;//文字个数
	int iLine;//所在行号
	tagVisibleItem();
}VisibleItem,*LPVisibleItem;//可视的文本属性


typedef vector<LPTextItem> VECTEXT;//字符串
typedef vector<LPTextAtt> VECTEXTATT;//属性向量
typedef vector<LPLineAtt> VECLINE;//一行字符串
typedef vector<LPLinkAtt> VECLINK;
typedef vector<LPVisibleItem> VECVISI;

typedef vector<LPHtmlObj> VEC_HTML;//html属性向量

class CTextRender
{
public:
	CTextRender(void);
	~CTextRender(void);
	
	//获取所有文本的html属性(m_objs)
	VEC_HTML& GetObjs();

	//清除并销毁文本
	void ClearText();

	//获取文本
	const char* GetText(string& strGet/*获取的文本*/);

	//增加文本
	bool AddText(const char* lpText, int nFontColor = _DEFAULT_FONT_COLOR/*颜色*/, int nFontSize = _DEFAULT_FONT_SIZE/*字体*/);//,bool bIsLink=false,const char* lpHref=NULL);

	//增加HTML文本
	bool AddHtmlText(const char* lpTextHtml,int defFontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	void Paint(CRect* rcShow=NULL);//CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);


	void SetPaintWnd(CWndObject* pWnd);


	void SetRect(const CRect& rtPaint, bool bRelative = false);


//protected:
	//html解析(内部调用)
	void HtmlParse(const char* str,int defaultFontColor=_DEFAULT_FONT_COLOR,int defaultFontSize=_DEFAULT_FONT_SIZE);


	//用UTF8编码html解析(内部调用)
	void HtmlParseWithUTF8(const char* str,int defaultfontColor=_DEFAULT_FONT_COLOR,int defaultFontSize=_DEFAULT_FONT_SIZE);

	//创建HTML属性
	void HtmlCreateObjs(tree<htmlcxx::HTML::Node>& dom,int defaultFontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defaultFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	//html处理(内部调用)
	void HtmlPreProcess(string& str/*替换前*/,string& retStr/*替换后*/,const char* reg/*要替换的文本*/,const char* lpReplace/*替换成的文本*/);
	
	CDataConvert* GetDataConvert();

	void SetShowRect(CRect& val);

protected:
	VEC_HTML m_objs;//所有文本的html属性
	CDataConvert m_dataConvert;

	CRect m_rcShow;
	//CRect GetShowRect() const { return m_rcShow; }

	bool m_bRelative;

	CWndObject* m_pWnd;
	//VECVISI m_vecVisi;//可视的文本列表

	DWORD m_dStyle;//格式(默认ES_CENTER|ES_VCENTER)

};

#include "CtrlStatic.h"

//支持HTML的CCtrlStatic
class CCtrlStaticEx :public CCtrlStatic
{
public:
	//设置文本
	void SetHtmlWindowText(const char* lpText/*文本*/,int fontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	//设置文本
	void SetHtmlWindowTextWithUTF8(const char* lpText/*文本*/,int fontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	virtual const char* GetWindowText();

	CTextRender* GetTextRender();
protected:
	virtual  void DoPaintForeground( CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg );
protected:
	CTextRender m_textRender;

};

#include "CtrlButton.h"

//支持HTML的CCtrlStatic
class CCtrlButtonEx :public CCtrlButton
{
public:
	//设置文本
	void SetHtmlWindowText(const char* lpText/*文本*/,int fontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	//设置文本
	void SetHtmlWindowTextWithUTF8(const char* lpText/*文本*/,int fontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=_DEFAULT_FONT_SIZE/*默认字体*/);

	virtual const char* GetWindowText();

	CTextRender* GetTextRender();
protected:
	virtual  void DoPaintForeground( CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg );
protected:
	CTextRender m_textRender;

};






#endif //__HTMLHELPER_HH__

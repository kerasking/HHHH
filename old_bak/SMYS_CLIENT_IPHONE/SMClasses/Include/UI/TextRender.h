#ifndef __HTMLHELPER_HH__
#define __HTMLHELPER_HH__
/*支持HTML的文字显示
*/

#include "ParserDom.h"
#include "WndObject.h"
#include "DataConvert.h"

using namespace std;
#define _DEFAULT_FONT_SIZE 12

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

typedef vector<LPHtmlObj> VEC_HTML;//html属性向量

// typedef map<int,string> ColorMap;

class CTextRender
{
public:
	CTextRender(void);
	~CTextRender(void);
	
	//获取颜色表
	//void GetColorMap(int index, string& colorStr);

	//设置颜色表(如ID2的颜色是0xff0000,就可用[2#表示该颜色,而不用写<font color=\"0xff0000\"/>;此方法对应的结束符是#],而不是</font>;但使用此方法不能同时设置size)
//	void SetColorMap( ColorMap& ClrMap );

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

	//html设置替换成颜色(内部调用)
	//void HtmlReplaceColor(string& str,string& colorStr);

	//html设置颜色(内部调用)
	//void HtmlPreProcessColor(string& str,string& retStr);

	//html处理(内部调用)
	void HtmlPreProcess(string& str/*替换前*/,string& retStr/*替换后*/,const char* reg/*要替换的文本*/,const char* lpReplace/*替换成的文本*/);
	
	CDataConvert* GetDataConvert();

	void SetShowRect(CRect& val);

protected:
	VEC_HTML m_objs;//所有文本的html属性
//	ColorMap g_ColorIndex;//颜色表,如ID12的颜色是0xff0000,就可用[12#表示该颜色,而不用写<font color=\"0xff0000\"/>
	CDataConvert m_dataConvert;

	CRect m_rcShow;
	//CRect GetShowRect() const { return m_rcShow; }

	bool m_bRelative;

	CWndObject* m_pWnd;
	//VECVISI m_vecVisi;//可视的文本列表


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





#endif //__HTMLHELPER_HH__

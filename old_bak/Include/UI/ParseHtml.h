/*
 *  ParseHtml.h
 *  解析HTML
 */

#ifndef __HTML_IMPL_H__
#define __HTML_IMPL_H__

#include <string>
#include "ParserDom.h"
#include "CtrlEdit.h"



using namespace htmlcxx;
using namespace HTML;
using namespace std;
/*
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
		m_size=0;
		m_color = _DEFAULT_FONT_COLOR;
		m_isLink = false;
		m_lpText = NULL;
		//m_lpObj = NULL;
		m_lpHref = NULL;
	};
}HtmlObj,*LPHtmlObj;

typedef vector<LPHtmlObj> VEC_HTML;

typedef map<int,string> ColorMap;
*/

/**
大小写不区分,/号可有可无可多个
	格式化前		格式化后
	[数字#			<font color=\"颜色\"/>	设置成ID为该数字的字体号
	#]或</font>     <fontEnd></fontEnd>
	<br/>			  \n	换行
	<b/>			 空的(暂不支持设置粗体)
	<u>				 空格(暂不支持设置下划线,链接默认有下划线)
font可表示为0xff00ff或#ff00ff
a href代表链接

例子:
	ColorMap clrMap;
	clrMap[4]="0xff00ff";//注意不能没有""
	clrMap[104]="0x00ff00";
	clrMap[105]="0x00ffff";
	m_Parse.SetCorlorMap(clrMap);
	string strShow="[4#【<a href='event:player-11'>玥儿</a>】#]的[104#【<a href='event:hero-21874'>太史慈</a>】#]成功掌握了[105# size=33〖<a href='event:item-{\"id\":84209,\"itemID\":89}'>兵法虚实篇1</a>〗#]的使用秘诀，能力大大提高<br/><br/>";
	m_Parse.ParseToEdit(strShow,&m_edtword2,m_fontColor);

	//上一种方法用[4#设置颜色后不能同时设置字体大小,推荐使用下面一种方法,color和size必须写在<font>里:
	strShow="<font color=\"0xff0000\" size = 22/>【<a href='event:player-11'>玥儿</a>】</font>的<font color=\"0x0000ff\"/>【<a href='event:hero-21874'>太史慈</a>】</font>成功掌握了<font color=\"0x00ff00\" size = 44/>〖<a href='event:item-{\"id\":84209,\"itemID\":89}'>兵法虚实篇1</a>〗</font>的使用秘诀，能力大大提高<br/><br/>";
	m_Parse.ParseToEdit(strShow,&m_edtword2,m_fontColor);

处理点击链接在bool CDlgX::WndProc(CWndObject* pObj,UINT message,WPARAM wParam, LPARAM lpParam)
弹起链接MSG_EDITLINKCLICK时,LPARAM保存的是char*类型的字符串:event:item-{"id":84209,"itemID":89}

按下链接const char* strHref=m_Parse.GetMouseDownHref(&m_edtword2,pObj, message, wParam,  lpParam);
			printf("GetMouseDownHref=%s\n",strHref);


*/		
class IParseHtml
{
public:

    //parse
    virtual void Parse(string& str,int fontColor=_DEFAULT_FONT_COLOR)=0;
  
	virtual void ParseWithUTF8(string& str,int fontColor=_DEFAULT_FONT_COLOR)=0;
 
	//get push result
    virtual VEC_HTML& GetObjs()=0;

    //parse string to some edit
    virtual void ParseToEdit(string& str,CCtrlEdit* lpEdit,int fontColor=_DEFAULT_FONT_COLOR)=0;
  
	virtual void ParseToEditWithUTF8(string& str,CCtrlEdit* lpEdit,int fontColor=_DEFAULT_FONT_COLOR)=0;

    //add link to some edit
    virtual void AppendLink(CCtrlEdit* lpEdit,const char* lpText,const char* lpHref,unsigned int clr=_DEFAULT_FONT_COLOR)=0;
 
	virtual void AppendLinkWithUTF8(CCtrlEdit* lpEdit,const char* lpText,const char* lpHref,unsigned int clr=_DEFAULT_FONT_COLOR)=0;

    virtual void AppendText(CCtrlEdit* lpEdit,const char* lpText,unsigned int fontColor=_DEFAULT_FONT_COLOR,int fontSize=0,const char* fontName=NULL)=0;
   
	virtual void AppendTextWithUTF8(CCtrlEdit* lpEdit,const char* lpText,unsigned int fontColor=_DEFAULT_FONT_COLOR,int fontSize=0,const char* fontName=NULL)=0;

};

class CParseHtml:public IParseHtml
{
public:
    CParseHtml();   
	virtual ~CParseHtml();
  
	virtual void Parse(string& str,int fontColor=_DEFAULT_FONT_COLOR);
  
	virtual void ParseWithUTF8(string& str,int fontColor=_DEFAULT_FONT_COLOR);
  
	virtual void ParseToEdit(string& str,CCtrlEdit* lpEdit,int fontColor=_DEFAULT_FONT_COLOR);
   
	virtual void ParseToEditWithUTF8(string& str,CCtrlEdit* lpEdit,int fontColor=_DEFAULT_FONT_COLOR);

    //
    virtual void AppendLink(CCtrlEdit* lpEdit,const char* lpText,const char* lpHref,unsigned int clr=_DEFAULT_FONT_COLOR);

    virtual void AppendText(CCtrlEdit* lpEdit,const char* lpText,unsigned int fontColor=_DEFAULT_FONT_COLOR,int fontSize=0,const char* fontName=NULL);
  
	virtual void  AppendLinkWithUTF8(CCtrlEdit* lpEdit,const char* lpText,const char* lpHref,unsigned int clr=_DEFAULT_FONT_COLOR);

    virtual void AppendTextWithUTF8(CCtrlEdit* lpEdit,const char* lpText,unsigned int fontColor=_DEFAULT_FONT_COLOR,int fontSize=0,const char* fontName=NULL);
  
	//获取所有文本的html属性(m_objs)
	virtual VEC_HTML& GetObjs();

	//bool WndProc(CWndObject* pObj,UINT message,WPARAM wParam, LPARAM lParam);
	//设置颜色表(如ID12的颜色是0xff0000,就可用[12#表示该颜色,而不用写<font color=\"0xff0000\"/>)
	void SetCorlorMap(ColorMap& clrMap);

	//获取颜色表
	void MapColor(int index, string& colorStr);

	//获取鼠标按下的链接文本,若无链接,则返回NULL(将该函数写在WndProc里)
	const char* GetMouseDownHref(CCtrlEdit* pEdit/*要获取的处理的编辑框*/,CWndObject* pObj,UINT message,WPARAM wParam, LPARAM lParam=NULL);

protected:
    //constructor
    void CreateObjs(tree<HTML::Node>& dom,int defaultFontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defaultFontSize=0);

    void ReplaceColor(string& str,string& colorStr);

    //pre handle
    void PreProcessColor(string& str,string& retStr);

    void PreProcess(string& str/*替换前*/,string& retStr/*替换后*/,const char* reg/*要替换的文本*/,const char* lpReplace/*替换成的文本*/);

	//clear
    void ClearObj(LPHtmlObj lpObj);

    void Clear();


private:
    VEC_HTML m_objs;//所有文本的html属性
	ColorMap g_ColorIndex;//颜色表,如ID12的颜色是0xff0000,就可用[12#表示该颜色,而不用写<font color=\"0xff0000\"/>
};



#endif
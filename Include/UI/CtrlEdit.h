/*
 *  CtrlEdit.h
 *  Created by ndtq on 11-2-22.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __CTRL_EDIT_H__
#define __CTRL_EDIT_H__

#include <vector>
#include <string>
#include "CtrlView.h"
#include "CtrlSlider.h"
#include "DataConvert.h"
#include "TextRender.h"

using namespace std;


/**
  编辑框
**/
class CCtrlEdit:public CCtrlView
{
public:
    CCtrlEdit();
    virtual ~CCtrlEdit();

    //获取某一行的文本
    bool GetLineString(int iLine/*行号*/,string& ret/*文本*/);

    //获取当前光标所在的行
    int GetCurSelLine();

    //光标移到某一行
    void SetLineSelect(int iLine);

    //
    bool GetLinePos(int iLine, int& nBegin, int& nEnd);


    //根据某一坐标(以该编辑框为视角原点)获取焦点位置序号
    int GetCharIndexWithCntPoint(CPoint& pos);

    //
    void GetCntPointWithCharIndex(int index,CPoint& resPoint);

    //获取可视的行数和区域
    void GetVisibleLineRange(int& first/*开始行*/,int& last/*结束行*/,CRect& rect/*获取到的当前显示的区域*/);

    //获得控件类型 CTRL_EDIT
    virtual int GetType()const;

    //清空编辑框文本
    void Clear();

    //是否只读
    bool  IsReadOnly() const;

    //设置只读属性
    void SetReadOnly(bool readonly);

    //是否获得焦点
    bool IsFocus() const;

    //设置获取焦点
    void SetFocus(bool bFocus);

    //Get item length,include object. Not equal to strlen(GetWindowText());
    int GetLength()const;

    //获取文本(无超链接)
    const char* GetWindowText();

    //设置文本(无超链接)
    void SetWindowText(const char* lpText);

    //设置支持超链接的文本
    void SetSpecialWindowText(const char* str);

    //用UTF8编码设置有超链接的文本
    void SetSpecialWindowTextWithUTF8(const char* lpText);

    //用UTF8编码设置文本
    void SetWindowTextWithUTF8(const char* lpText);

    //获取输入框里显示的文本值的长度
    int GetTextLength() const;

    //是否多行
    bool IsMultiLine()const;

    //设置是否多行
    void SetMultiLine(bool isMultiLine);

    //获取总行数
    int GetLineCount() const;

    //获取某一行的开始位置
    int GetLineCharIndex(int iLine) const;

    //设置字体颜色
    void SetFontColor(unsigned int color);

    //获取字体颜色
    unsigned int GetFontColor() const;

    //设置字体高度
    void SetFontSize(int size);

    //获取字体高度
    int GetFontSize() const;

    //设置字体名字
    void SetFontName(const char* fntName);

    //获取字体名字
    const char* GetFontName();

    //设置选中时的背景颜色(bgColor must include alpha value begin head)
    void SetSelBgColor(unsigned int bgColor);

    //是否是密码输入
    bool IsPassword() const;

    //设置是否密码输入
    void SetPassword(bool isPassWord);

    //获取开始选中的位置
    int GetSelStart()const;

    //获取选中的文本长度
    int GetSelLen()const;

    //获取文本(m_vecText)
    VECTEXT& GetTextItems();

    //获取某一序号的超链接文本,若该序号无超链接,则返回NULL(序号是:第N个文字)
    const char* GetHref(int index/*序号*/);

    //根据某一序号获取超链接文本
    //返回值:是否获取成功
    bool GetLinkText(int index/*序号*/,char* lpRec/*超链接文本*/,int iSize/*超链接文本的最大长度*/);

    //获取文本显示的大小
    void GetContentSize(int& iWidth/*宽*/,int& iHeight/*高*/);

    //设置是否允许超链接(若没设置,隐藏输入框后,原链接将消失)
    void SetSpecial(bool isSpecial);

    //获取是否允许超链接
    bool GetSpecial()const;

    //设置最多可输入的字数
    void SetMaxLen(int iLenMAx);

    //获取最多可输入的字数
    int GetMaxLen();

    //获得已输入的长度
    int GetInputLength();

    //设置已输入的长度
    void SetInputLength(int iLen);

    //绑定一个滑块(调节数值大小)
    void BindSlider(CCtrlSlider* pBindSlider);

    //获取绑定的滑块
    CCtrlSlider* GetBindSlider();

    //string operator

    //设置选中
    void SetSel(int iStart/*开始位置*/,int iEnd/*结束位置,-1代表文本结束位置*/);

    //替换文本
    void Replace(const char* str/*文本*/,unsigned int fontColor=_DEFAULT_FONT_COLOR/*颜色*/,int fontSize=0/*字体大小*/,const char* fontName=NULL/*字体名*/,int iType=0/*删除类型*/);

    //替换成控件
    void ReplaceWithObj(CWndObject* lpObj/*控件*/,bool bAutoDestory=true/*自动销毁*/);

    //替换
    void ReplaceWithUTF8(const char* str/*文本*/,unsigned int fontColor=_DEFAULT_FONT_COLOR,int fontSize=0,const char* fontName=NULL);

    //替换成超链接
    bool ReplaceLink(const char* str/*显示的文本*/,const char* lpHref/*超链接保存的文本*/,unsigned int fontColor=_DEFAULT_FONT_COLOR/*字体颜色*/,
                     unsigned int clrClicked=_DEFAULT_FONT_COLOR/*点击后的字体颜色*/, int fontSize=0/*字体大小*/,const char* fontName=NULL/*字体名*/);

    //用UTF8编码替换成超链接
    bool ReplaceLinkWithUTF8(const char* str,const char* lpHref,unsigned int fontColor=_DEFAULT_FONT_COLOR,
                             unsigned int clrClicked=_DEFAULT_FONT_COLOR, int fontSize=0,const char* fontName=NULL);

    //用html替换文本(<font color=\"0xff0000\" size = 22/>【<a href='event:player-11'>测试</a>】<br/>)
    void ReplaceWithHtml(const char* str/*文本*/,int fontColor=_DEFAULT_FONT_COLOR/*默认颜色*/,int defFontSize=0/*默认字体*/);

    //用UTF8编码的html替换文本
    void ReplaceWithHtmlUTF8(const char* str,int fontColor=_DEFAULT_FONT_COLOR,int defFontSize=0/*默认字体*/);

    CTextRender* GetTextRender();

    //special key
    void BackspaceKey();

    void DelKey();

    void EnterKey();

    void OnBeyongMaxLen();

    //for mac  os
    //改变键盘方向
    void KeyBoardChanged(int iOrg);

    //获取键盘类型
    int GetKeyboardType()const;

    //设置键盘类型(gui.ini中kbtype=1004则说明是数字键)
    void SetKeyboardType(int ktype);

    //clear btn mode
    int GetClearBtnMode()const;

    void SetClearBtnMode(int mode);

    //获得返回类型
    int GetReturnType()const;

    //设置返回类型
    void SetReturnType(int retType);

    //key board event

    //分派键盘显示事件MSG_KEYBOARDSHOW
    virtual void KeyboardShowed(int iLeft,int iTop,int iRight,int iBottom);

    //分派键盘隐藏事件MSG_KEYBOARDHIDE
    virtual void KeyboardHidden();

    //编辑框改变文本
    ClickEvent EventChanged;

    //结束输入(隐藏输入法)
    ClickEvent EventInputEnd;

    //完成输入
    CommonEvent EventDone;

    //event
    virtual void MouseClickedHandler(CWndObject* obj, CPoint& pos,const void* lpParam=NULL);

    //设置最小值
    void SetMinValue(int iMin);

    //设置最大值
    void SetMaxValue(int iMax);

    //获取最小值
    int GetMinValue();

    //获取最大值
    int GetMaxValue();

    //完成输入
    void OnEditCtrlDone();

    //获取某几行显示的高度
    int GetLineHeight(int startIndex/*开始行*/,int endIndex/*结束行*/);

	//获取最多行数
	int GetMaxLine() const;

	//设置最多行数
	void SetMaxLine(int iMaxLine);

	//获取属性
 	DWORD GetStyle() const;
 
	//设置属性
	void SetStyle(DWORD dEditStyle);

	virtual void DoViewPos(CPoint& pos);

protected:

    virtual void DoPaintForeground(CPoint& cntScreenOrg,CRect& showRect,CRect& cntRect,CPoint& viewOrg);

    virtual void DoCreated();

    virtual void DoSized(CRect& rect);

    virtual void GetViewRect(CRect& rc);

    //设置链接属性
    bool SetLinkAtt(int iStart/*文本开始位置*/,int iLen/*超链接的文本长度*/, const char* lpHref,unsigned int fontColor=_DEFAULT_FONT_COLOR,
                    unsigned int clrClicked=_DEFAULT_FONT_COLOR, int fontSize=0,const char* fontName=NULL);

    //删除链接(adjust is destory link att)
    void AdjustDestoryLink(int iStartSel/*开始位置序号*/,int iType=0/*删除类型*/);

    //help
    VECTEXTATT& GetAttItems();

    //所有文本的字数
    int Length() const;

    LPTextAtt GetAttByIndex(int index);

    //创建默认字体
    void CreateDefaultFontAtt();

    //clear function
    void ClearAtt();

    void ClearItem(VECTEXT* lpVec);

    void ClearLine();

    //清除可视文本
    void ClearVisible();

    //清除所有超链接
    void ClearLink();

    //size function
    void ResetViewSize();

    void CaluViewSize();


    //获取显示的宽度
    int GetLineWidth(int iStart/*文本开始序号*/,int iEnd/*文本结束序号*/);

    //获取一行的文本显示的宽度
    int GetLineWidth(LPLineAtt lpAtt/*一行的文本*/);

    //string cut function

    //重建几行文本
    void RebuildLine(int startLine/*开始的行数*/);

    //删除几行文本
    void CutLineFromIndex(int startLine/*开始的行数*/);

	//重建一行文本用于显示
    int  RebuildSingleLine(LPLineAtt lpLine,int iStartChar,int iEndChar,int cntWidth/*显示宽度*/,CPoint& lineOrgPoint);

    //point function

    //根据屏幕坐标获取焦点位置序号
    int GetCharIndexWithPoint(CPoint& pos,CRect& realPos,bool& bInRange);

    //
    void GetPosWithCharIndex(int index,CPoint& pos);

    //根据位置序号得到行号
    int GetLineWithCharIndex(int index/*位置序号*/);


    //返回行数
    int GetLineOrgPosWithCharIndex(int index,CPoint& pos);

    //str function
    bool DeleteChar(int index,int endIndex);

    //增加文本
    int Append(int index/*位置*/,const char* str/*文本*/,int fontSize=0/*字体大小*/,const char* fontName=NULL/*字体名*/,unsigned int fontColor=
                   _DEFAULT_FONT_COLOR/*颜色*/);


    void SplitChinaStr(const char* lpStr,int fontSize,const char* fontName,VECTEXT& vecRet,LPTextAtt lpTextAtt);

    //获取显示文本的长度
    int GetTextLength();

    void GetWindowText(string& str/*获得的文本*/);

    //adjust link
    int LastIndexWithLink();

    //获取某段长度的文本(range:[start,end])
    void GetString(int iStart/*开始位置*/,int iEnd/*结束位置,必须小于文本的长度*/,string& ret/*文本*/);

    //cursor function
    void RebuildCursor();

	
private:
    //for malloc
    void ReleaseTextItem(LPTextItem lpItem);

    void ReleaseTextAtt(LPTextAtt lpAtt);

    //释放一行的文本
    void ReleaseLineAtt(LPLineAtt lpAtt/*一行文本*/);

    //清除超链接文本
    void ReleaseLinkAtt(LPLinkAtt lpAtt);

    //释放可视的文本
    void ReleaseVisibleItem(LPVisibleItem lpVisible);

    //文本序号超出
    bool OutOfRange(int index);

    //文本行序号超出
    bool OutOfLineRange(int index/*行号*/);

	//获取结束的序号
    int GetSameEndIndex(LPTextAtt lpSameAtt/*文本属性*/,LPLinkAtt lpLinkAtt/*超链接属性*/, int startIndex/*开始号*/,int endIndex/*结束号*/);

	//获取当前可视的文字的属性
    void GetItemVisAtt(int iLineIndex/*行数*/,int startIndex/*开始序号*/,int endIndex/*结束序号*/,CRect& retRect/*获取的文本区域*/,CRect& selRect/*获取的选中文本区域*/,string& retStr/*获取的文本*/);

    bool CompareToItem(LPTextItem lpItem,const char*& lpStr);

    void OnHtmlParse();

    //for mac os
    int m_keyboardType;//键盘类型(keyboard type,默认:KT_UIKeyboardTypeDefault)
    bool m_isPassword;//密码
    int m_returnType;//返回类型
    int m_clearType;//清除类型
    bool m_bSpecialLink;//是否允许有超链接(默认false)
    //end

    CRect m_viewSize;
    int m_iMaxWidth;//文本显示的宽度
    int m_iMaxHeight;//文本显示的高度
    VECTEXT m_vecText;//保存的文本
    VECTEXTATT m_vecTxtAtt;//属性向量
    VECLINE m_lineAtt;//每一行的文本组成的向量
    VECLINK m_linkAtt;
    int m_iSelLen;//选中的文本长度
    int m_iSelStart;//开始选中的位置序号(从全部文本第一个字符开始算起)
    TextAtt m_defaultAtt;//默认的一个字的属性
    int m_iCharSpace; //字间隔(默认0)
    int m_iLineSpace;//行间隔(默认4)

    //not handle
    bool m_bFocus;//是否得到焦点
    bool m_bReadOnly;//是否只读
    bool m_isMulLine;//是否多行
    unsigned int m_bgSelColor;//选中时的背景颜色(默认黑色)

    //cursor
    unsigned int m_iCurTicked;
    bool m_bCurShow;

    CPoint m_curPos;
    int m_iCurHeight;//文字高度(默认12)

    int m_iFirstVisLine;//可视首行的行数
    int m_iLastVisLine;//可视末行的行数
    CRect m_iVisibleRect;//可视区域
    VECVISI m_vecVisi;//当前显示的文本列表

    string m_text;	//输入框里显示的文本值
    int m_iMaxLen;//最多可输入的字数(默认0,无限制)
	int m_iInputLen;//已输入的长度
    int m_iMaxLine;//最多限制行数(默认300)

    int m_iMinVal;//最小值(编辑框不控制大小,只保存这个值)
    int m_iMaxVal;//最大值(编辑框不控制大小,只保存这个值)

    CCtrlSlider* m_pBindSlider;//要绑定的滑块(调节数值大小)

    int m_CurCharIndex;//光标所在的位置序号(初始-1)

    CTextRender m_textRender;
    CDataConvert m_dataConvert;
 	DWORD m_dStyle;
};

#endif

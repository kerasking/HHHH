/*
 *  CtrlList.h
 *  Created by ndtq on 11-2-18.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */

#ifndef __CTRL_LIST_H__
#define __CTRL_LIST_H__

#include <vector>
#include "CtrlDlg.h"
#include "CtrlView.h"
#include "CtrlStatic.h"
#include "CtrlImage.h"
//#include "Event.h"

using namespace std;

//列表视图控件的属性
typedef struct tagListCommAtt
{
	//for title
	int m_iColCount;//列数(对应ini文件里的"ColAmount")
	int* m_iColWidth;//一列的宽(对应ini文件里的"ColWidth")
	
	int* m_iTitleVerAlign;//保存每一列的标题栏水平对齐方式
	int* m_iTitleHerAlign;//保存每一列的标题栏垂直对齐方式
	
	int* m_iValueVerAlign;//保存每一列的控件垂直对齐方式
	int* m_iValueHerAlign;//保存每一列的控件水平对齐方式
	
	unsigned int* m_clrSel;//保存所有列的选中时的颜色
	unsigned int* m_clrComm;//保存所有列的颜色
	char* m_lpSelBg;
	int m_iRowHeight;	//行高度(默认16)
	//line space
	int m_iRowSpace;//每一行之间的间隔(默认0)
	int m_iColSpace;//每一列之间的间隔(默认0)
	//for value
	char* m_lpValueBg;//背景图片
	char* m_lpSelectBg;//选中时的背景图片
	DWORD* m_dwFontStyle;//保存所有列的字体样式
	
	tagListCommAtt();
}ListCommAtt,*LPListCommAtt;

enum //一格里的控件属性
{
	LISTITEM_TYPE_TEXT,//文字
	LISTITEM_TYPE_IMAGE,//图片
	LISTITEM_TYPE_OBJ//其他控件
};
typedef struct tagListTitleAtt
{
	CCtrlImage** m_lpBg;//背景图片
	CWndObject** m_lpObject;//控件
	bool m_isTitle;//是否设置了列头文本
	tagListTitleAtt();
}ListTitleAtt,*LPListTitleAtt;//所有列标题


typedef struct tagListValueAtt
{
	int m_type;
	bool m_autoDestory;//自动销毁(默认false)
	CCtrlImage* m_lpBg;//背景图片
	CWndObject* m_lpObject;//控件
	DWORD	m_dwData;
	tagListValueAtt();
}ListValueAtt,*LPListValueAtt;//一格


typedef struct tagRowAtt
{
	LPListValueAtt m_lpItems;//指向一行上的所有列的指针
	CCtrlImage* m_lpBg;
	int m_rowHeight;
	tagRowAtt();
}RowAtt,*LPRowAtt;//一行的属性


typedef vector<LPRowAtt> VECROWS; //所有的行
/*		CListView
			CListDataView
			CListTitleView
*/
//列表视图
class CListView:public CCtrlView
{
public:
	CListView();
	virtual ~CListView();
	virtual bool MouseDragHandler(CWndObject* obj,int relateX,int relateY,const void* lpParam=NULL);
	CommonEvent m_dragEvent;//(如CCtrlList::DoViewViewMove,CCtrlList::DoTitleViewMove)

	//是否可用
	bool IsEnabled() const;

	//设置是否可用
	void SetEnabled(bool isEnable);
private:
	bool m_isEnable;//是否可用
};		

//列表数据视图
class CListDataView:public CListView
{
public:
	CListDataView();
	virtual ~CListDataView();
	
	void SetRows(VECROWS* lpRows);

	void SetCommAtt(LPListCommAtt lpAtt);

	//视图滚动到选中行,使之可见
	void ScrollToSel();

	//视图滚动到某一行,使之可见
	void ScroolToRow(int iRow/*行号*/);
	
	//设置选中行
	void SetSelRow(int iRow);

	//设置选中列
	void SetSelCol(int iCol);
	
	//获取当前选中的行
	int GetSelRow() const;

	//获取当前选中的列
	int GetSelCol() const;

	//根据窗口坐标获得行列数(若找不到,则行列号都为-1)
	void GetRowAndCol(CPoint& pos/*窗口上的坐标*/,int& iRow/*行*/,int& iCol/*列*/);	

	//点击的事件(CCtrlList::DoSelChange)
	ClickEvent m_selEvent;

protected:

	//此回调接口统一改为:WndProc回调接口 
	//virtual void RefWndPro(int iType,CWndObject* obj,CPoint& pos,const void* lpParam=NULL);

	//处理本窗口和子窗口事件(SendMessage后处理的事件)
	virtual bool WndProc(CWndObject* pObj/*触发消息的窗口*/,UINT message,WPARAM wParam, LPARAM lParam);

	//获得视图的总大小(可以容纳所有的子窗口)
	virtual void GetViewRect(CRect& size); 


	//
	LPListCommAtt GetCommAtt();	

	//获取所有的行
	VECROWS* GetRows();	

private:
	VECROWS* m_lpRows;//所有的行
	LPListCommAtt m_lpCommAtt;//列表视图控件的属性
	int m_sel;//当前选中行
	int m_selCol;
};

//列表头视图
class CListTitleView:public CListView
{
public:
	CListTitleView();
	virtual ~CListTitleView();

	//设置所有列标题
	void SetTitleAtt(LPListTitleAtt lpAtt);

	//获取每一列的列头
	LPListTitleAtt GetTitleAtt();

	//设置列表视图控件的属性
	void SetCommAtt(LPListCommAtt lpAtt);

	//获取列表视图控件的属性
	LPListCommAtt GetCommAtt();	

	//点击标题栏的事件
	CommonEvent EventTitleClick;
protected:

	//此回调接口统一改为:WndProc回调接口
	//virtual void RefWndPro(int iType,CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
	
	//处理本窗口和子窗口事件(SendMessage后处理的事件)
	virtual bool WndProc(CWndObject* pObj/*触发消息的窗口*/,UINT message,WPARAM wParam, LPARAM lParam);

	//获得视图的总大小(可以容纳所有的子窗口)
	virtual void GetViewRect(CRect& size); 

	//获取选中列
	void GetSelCol(CPoint& pos,int& iCol);	
private:
	LPListTitleAtt m_lpTitleAtt;//所有列标题
	LPListCommAtt m_lpCommAtt;//列表视图控件的属性
	int m_selCol;
};

//列表控件
class CCtrlList:public CCtrlDlg
{
public:
	CCtrlList();
	virtual ~CCtrlList();

	//设置列数和列宽度(必须要先设置)
	void SetColCount(int iCountCols/*列数*/,int* iWidth/*每列宽度的数组*/,int rowHeight=16/*行高度*/);

	//获取列数
	int	 GetColCount();
	//titleText array must be match with col count

	//创建列标题头
	void CreateTitle(char** titleText/*所有列的名字*/,const char* titleBg=NULL, unsigned int titleColor=_DEFAULT_FONT_COLOR);
	
	//Item function
	//增加一行
	int  InsertRow();

	int  InsertRow(int iRow/*插入的行数*/);

	int  InsertRow(int iRow, LPRowAtt lpItem);

	//设置名字
	CWndObject* SetColValue(int row,int col,const char* lpText,bool isImage=false);

	//用UTF8编码设置名字
	CWndObject* SetColValueWithUTF8(int row,int col,const char* lpText,bool isImage=false);

	//获取一格上的文本
	int GetItemText(int row/*行*/,int col/*列*/, char *pszBuffer/*得到的文本*/, int nMaxLen/*最大获得的长度*/) const;

	//获取一格上的文本
	const char* GetItemText(int row/*行*/,int col/*列*/);

	//设置一格的对象
	CWndObject* SetColObj(int row/*行*/,int col/*列*/,CWndObject* lpObj/*控件*/,CRect& size/*大小*/,bool autoDestory=true/*自动释放内存*/);

	//删除一行
	void DeleteRow(int row/*行号*/);

	//删除一行
	void DeleteRowAtt(LPRowAtt lpItem/*指向要删除的行的指针*/);


	LPRowAtt RemoveRow(int row/*行号*/);

	//获得一格上的控件
	CWndObject* GetColObj(int row/*行*/,int col/*列*/);

	DWORD SetData(int row,int col,DWORD dwData);

	DWORD GetData(int row,int col);
	
	//视图滚动到选中行,使之可见
	void ScrollToSel();
	
	//获取选中的行号
	int GetSelRow() const;
	
	//获取选中的列号
	int GetSelCol() const;
	
	//设置选中第iRow行
	void SetSelRow(int iRow);

	//设置选中第iCol列
	void SetSelCol(int iCol);
	
	//设置选中时的背景图片
	void SetSelBgAni(const char* lpAni);

	//设置背景图片
	void SetContentAni(const char* lpAni);
	
	//设置一列的控件垂直对齐方式
	void SetValueVerAlign(int col/*列*/,int align/*对齐方式*/);

	//设置一列的控件水平对齐方式
	void SetValueHerAlign(int col,int align);

	//设置一列的标题栏垂直对齐方式
	void SetTitleHerAlign(int col,int align);

	//设置一列的标题栏水平对齐方式
	void SetTitleVerAlign(int col,int align);

	//设置一列的颜色
	void SetValueCommClr(int col,unsigned int clr);

	//设置一列的选中时的颜色
	void SetValueSelClr(int col,unsigned int clr);

	//设置一列的字体样式
	void SetValFontStyle(int col, DWORD dwFontStyle);
	
	//取消列标题
	void CancelTitle();

	//清除列表(清除所有行的视图数据)
	void ClearAllItems();

	//获得控件类型 CTRL_LIST
	virtual int GetType()const;

	//是否有选中行
	bool IsRowSel()const;

	//设置是否有选中行
	void SetRowSel(bool rowSel=true/*是否有选中行*/);

	//设置背景填充方式
	void SetSelBgFillType(int fillType,int borderSize=0/*边框宽度*/);

	//设置选择时的背景填充方式
	void SetValBgFillType(int fillType,int borderSize=0);	
	
	//设置一列的宽度
	void SetColWidth(int index/*列号*/,int iWidth/*宽度*/);

	//获取一列的宽度
	int GetColWidth(int index)/*列号*/;
	
	//设置一行的高度
	void SetRowHeight(int iHeight);

	//获取一行的高度
	int GetRowHeight()const;

	//设置一列选中时的颜色
	void SetSelColor(int iCol/*列*/,unsigned int clrSel/*颜色*/);
	
	//设置一列的颜色
	void SetValColor(int iCol/*列*/,unsigned int clrComm/*颜色*/);
	
	//是否有滚动条
	bool IsSlider()const;

	//设置是否有滚动条
	void SetSlider(bool slider);

	//获得滚动条的背景图
	const char* GetSliderAni();

	//设置滚动条的背景图
	void SetSliderAni(const char* lpAni);

	//是否有水平滚动条
	bool IsHerSlider()const;

	//设置有水平滚动条
	void SetHerSlider(bool slider);

	//获得水平滚动条的背景图片
	const char* GetHerSliderAni();

	//设置水平滚动条的背景图片
	void SetHerSliderAni(const char* lpAni);

	//滚动条的宽度
	int GetSliderSize()const;

	//设置滚动条的宽度
	void SetSliderSize(int size);

	//列表数据视图m_view的总大小(可以容纳所有的子窗口)
	void GetDataViewSize(int& iWidth,int& iHeight);

	//获得总行数
	int GetRowCount()const;

	//更改选中格的事件(响应ON_LIST_SEL_CHANGE(id,fun))
	ClickEvent SelChangeEvent;

	//点击标题栏的事件(响应ON_LIST_TITLE_CLICKED(id,fun))
	CommonEvent EventTitleClick;	

	//获取列表视图的位置(即滚动窗口的位置)
	CPoint GetListViewPos();

	//设置列表视图的位置(即滚动窗口的位置)
	void SetListViewPos(CPoint& ptRefPoint);

	bool IsEnabled() const;

	void SetEnabled(bool isEnable);

	//获取列标题的名字
	bool GetHeaderTitle(int nIndex/*列号*/, string& strTitle/*名字*/);

	//用UTF8编码设置列标题名字
	void SetHeaderTitleWithUTF8(int nIndex, const char* pszText);

	//设置一格的字体颜色(设置成功返回true)
	bool SetCellFontColor(int iRow/*行*/, int iCol/*列*/, DWORD dwColor/*颜色*/);

	//根据屏幕坐标获取坐标所在的单元格(若找不到,则行列号都为-1)
	void GetCell( CPoint& posScreen/*屏幕坐标*/,int& iRow/*行*/,int& iCol/*列*/);

protected:

	//销毁控件
	void Destory();

	//清除一格的控件
	void ClearValueItem(LPListValueAtt item/*指向该格的指针*/);

	//清除并销毁列标题
	void ClearTitleAtt();

	//清除并销毁该列表视图控件的属性
	void ClearCommAtt();

	//列号是否无效(超出范围或小于0)
	bool OutOfRange(int index/*列号*/);

	//控件创建后触发
	virtual void DoCreated();

	//改变窗口大小后(SetClientRect后触发)
	virtual void DoSized(CRect& rect);

	//移动列表视图
	void DoViewViewMove(WPARAM viewX, LPARAM viewY);

	//移动标题栏
	void DoTitleViewMove(WPARAM viewX, LPARAM viewY);

	//选中不同的行后,重新绘图(改变文本颜色,改变背景颜色)
	void DoSelChange();

	//重新排列视图位置
	void ResetSize();

	//重建列表大小
	void RebuildItemSize(int iStartRow/*开始行数*/);

	//点击标题栏的事件
	void DoTitleClicked(WPARAM wParam/*行*/,LPARAM lParam/*列*/);

	//根据行列数计算列表大小
	void CaluRectWidthRowAndCol(CRect& rect/*列表大小*/,int row/*行*/,int col/*列*/);

	//计算对齐方式的区域
	bool CaluAlignRect(CRect& rect,int iWidth,int iHeight,int iVerAlign/*垂直对齐方式*/,int iHerAlign/*水平对齐方式*/,CRect& retPos);

private:
	int m_iSelBgFillType;//选中时的背景填充方式
	int m_iValBgFillType;//背景填充方式
	int m_iSelBgBorderSize;//选中时的背景边框宽度
	int m_iValBgBorderSize;//背景边框宽度
	bool m_isEnable;
	bool m_isDragStatus;	//是否拖拽状态
	CListDataView m_view;//列表数据视图
	CListTitleView m_title;//列表头视图
	ListCommAtt m_commAtt;//该列表视图控件的属性
	ListTitleAtt m_titleAtt;//所有列标题
	VECROWS m_rows;//所有的行
	int m_selRow;//当前选中行
	int m_selCol;//当前选中列
	bool m_isRowSel;//是否有选中行
	
	typedef map<CCtrlStatic*, DWORD> CELL_COLOR;
	CELL_COLOR m_cellcolor;//颜色
};

//int CCtrlList::AppendItem( const char* lpText,int iValue,bool image )
//{
//	return InsertRow();
//}
//
//void CCtrlList::SetItemText( int row,int col,const char* lpText,bool image )
//{
//	SetColValue(row, col, lpText, image);
//}
//
//int CCtrlList::GetCurSel() const
//{
//	return GetSelRow();
//}
//
//int CCtrlList::AddString( const char* lpText )
//{
//	return InsertRow();
//}
#endif



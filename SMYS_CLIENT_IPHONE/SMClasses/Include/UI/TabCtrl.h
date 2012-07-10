/*
 *  TabCtrl.h
 *  选项卡控件和选项卡按钮类
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */
#ifndef __CTRL_TAB_CTRL_H__
#define __CTRL_TAB_CTRL_H__

#include "CtrlDlg.h"
#include "CtrlButton.h"
#include <vector>
#include <string>

using namespace std;

class CTabCtrl;
//选项卡上的每个按钮
class CTabCtrlBtn : public CCtrlButton
{
public:
	enum //状态
	{
		enNormal,
		enDown,
		enDisable,
		enActive
	};
public:
	CTabCtrlBtn();

	//设置为选中(改变按钮样式)
	void SetSelected(bool bSelected);

	//设置对应的选项卡控件
	void SetTabCtrl(CTabCtrl* pTabCtrl);

	//设置状态
	virtual void SetStatus(int status);

protected:
	bool m_bSelected;//是否选中
	CTabCtrl* m_pTabCtrl;//所在的选项卡控件
};

//一个选项卡标签
class CTabCtrlItem 
{
public:
	CTabCtrlItem();
	CWndObject* m_pDlg;//一个选项卡标签里的对话框
	CTabCtrlBtn* m_pBtn;//一个选项卡标签里的切换按钮
	bool m_bShow;//显示可见,默认true
};

typedef std::vector<CTabCtrlItem*> CTabItemArray;//所有标签向量

//选项卡事件类,点击了Tab选项卡的按钮(可以继承该类,当点击按钮时会执行ClickTabBtn)
class CTabCtrlEvent
{
public:
	virtual void ClickTabBtn(bool bSwitch/*切换选项卡*/, bool& bContinue/*设置是否继续切换*/) = 0;
};

/**
  选项卡
**/
class CTabCtrl  
{
public:
	CTabCtrl();
	virtual ~CTabCtrl();
	
public:
	//获得选项卡的所有标签的向量
	CTabItemArray& GetTabItemArray();

	//根据标签号获得对话框
	CWndObject* GetItemDlg(int nIndex) const;
	
	//插入一个选项卡
	virtual int InsertItem(int nItem/*序号*/, CWndObject* pDlg/*对话框*/, CTabCtrlBtn* pBtn/*选项卡按钮*/, bool bVisible=true/*可见*/);

	//删除一个标签(若删除的是当前选中的标签,则重新选中一个标签,保证当前选中的标签号不越界)
	virtual bool DeleteItem(int nItem);

	//设置一个标签可见
	virtual void SetItemVisible(int nItem, bool bVisible);

	//刷新选项卡
	virtual void RefreshTabCtrl();
	
	//删除所有标签,并把当前选中项置空
	virtual bool DeleteAllItems();

	//获得选中的标签号
	virtual int GetCurSel() const;

	//获得选中一个选项卡标签
	virtual int SetCurSel(int nItem);

	//设置选中一个选项卡标签
	int SetCurSel(CCtrlButton* pBtn/*选项卡上的切换按钮*/);

	//获得标签的数量
	virtual int GetItemCount() const;

	//设置一个标签对应的对话框
	bool	SetItemWnd(int nItem, CWndObject* pDlg);
	
	//设置选项卡事件类
	void SetTabCtrlListener(CTabCtrlEvent* pEvent);
	
protected:

	//删除所有标签
	void ClearAllItems();

	vector<CRect> m_RectList;//保存所有标签按钮的位置大小的向量
	
protected:
	CTabItemArray m_tabItems;//保存选项卡的所有标签的向量
	int m_nCurSel;	//当前选中的标签号
	CTabCtrlEvent* m_pEvent;//点击标签的事件
protected:

	//释放一个标签
	virtual bool ReleaseItem(int nItem);

	//重新排列nItem标签号以后的标签按钮
	virtual void ResetItemsPos(int nItem);
};

#endif
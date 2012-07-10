/*
 *  ComboBox.h
 *
 *  Created by ndtq on 11-3-10.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 *
 */

#ifndef __COMBO_BOX_H__
#define __COMBO_BOX_H__

#include <map>
#include "CtrlDlg.h"
#include "CtrlEdit.h"
#include "CtrlImage.h"
#include "CtrlList.h"
#include "CtrlButton.h"
#include "CtrlCheckBox.h"

enum  //对话框按钮显示类型
{
    enBTN_OK,//只显示确定
    enBTN_CANCEL,//只显取消
    enBTN_ALL,//全显
    enBTN_NULL,//全不显示
};

typedef CCtrlCheckBox CCtrlComboxCheckBox;
typedef vector<CCtrlButton*> BTNLIST;
typedef pair<int, LPRowAtt> RowIdxPair;
typedef vector<RowIdxPair> RowIdxPairList;

#define _COMBOBOX_DROPBUTTON_SIZE 18
#define _COMBOBOX_VIEW_BORDER_SIZE 5
#define _COMBOBOX_INPUT_BORDER_SIZE 2
#define _COMBOBOX_DEFAULT_LINE_SAPCE 0
#define _COMBOBOX_DROPBUTTON_COL_SPACE 2
#define _COMBOBOX_BUTTON_SPACE 2

class IRemoveItemNotify
{
public:
    virtual void NotifyRemoveItem(vector<int> ItemVec) = 0;
    virtual void Reset() = 0;

};

//组合框CCtrlComboBox弹出的选项列表对话框
class CCtrlComboBoxList:public CCtrlDlg
{
public:
    CCtrlComboBoxList();
    virtual ~CCtrlComboBoxList();

    //获取控件类型 CCtrlComboBoxList
    virtual int GetType()const;

    //设置边框宽度
    void SetBorderSize(int iSize);

    //获取边框宽度
    int GetBorderSize()const;

    //static area  hight
    void SetStaticHeight(int iHeight);
    int GetStaticHeight()const;

    //设置按钮高度
    void SetBtnHeight(int iHeight);

    //获取按钮高度
    int GetBtnHeight()const;

    //Bind obj
    void SetBindObj(CWndObject* lpBind);
    CWndObject* GetBindObj();

    //style

    //button type
    int GetBtnType()const;

    //设置对话框按钮显示类型
    void SetBtnType(int btnType);

    //item style
    void SetCheckBoxAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX);
    void SetDelItemBtnAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX);
    const char* GetCheckBoxAni();
    void SetSelAni(const char* lpAni,int fillType,int borderSize=0);
    void SetContentAni(const char* lpAni);
    void SetItemHeight(int iHeight);
    //button style
    void SetConfirmBtnStyle(const char* lpAni,int fillType,int borderSize=0);
    void SetCancelBtnStyle(const char* lpAni,int fillType,int borderSize=0);

    //bg style
    void SetFloodBg(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);
    void SetHeadBg(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);

    //设置标题的颜色
    void SetTitleColor(unsigned int color);

    //color
    void SetSelColor(unsigned int clrSel);
    void SetValColor(unsigned int clrComm);

    //设置标题
    void SetTitle(const char* lpText);


    //item
    int InsertItem();
    int InsertItem(int iRow, LPRowAtt lpItem);
    void DeleteItem(int iRow);
    LPRowAtt RemoveItem(int row);

    //设置列表框第index行的文本为lpText
    void SetItemText(int index,const char* lpText);

    const char* GetSelItemText();

    void Clear();

    void SetSelBgFillType(int fillType,int borderSize=0);

    //设置选中项
    void SetSelItem(int index);

    //获取选中项
    int GetSelItem()const;

    //获取选中的行列号
    void GetSelPos(int& iSelRow/*行*/, int& iSelCol/*列*/);

    //option
    bool IsClickedAndConfirm() const;
    void SetClickedAnConfirm(bool isClickedAndConfirm);

    //用户更改列表选中项
    void  OnListChanged();

    //点击确定
    void OnBtnClicked();

    //点击取消
    void OnCancelClicked();

    //查找某一文本的选项,返回行号
    int SearchSelItem(const char* lpText/*文本*/);

    //视图滚动到选中行,使之可见
    void ScrollToSel();

    ClickEvent EventShow;
    ClickEvent EventOK;
    ClickEvent EventCancel;

protected:
    //此回调接口统一改为:WndProc回调接口
    //virtual void RefWndPro(int iType,CWndObject* obj,CPoint& pos,const void* lpParam/*=NULL*/);
    virtual bool WndProc(CWndObject* pObj,UINT message,WPARAM wParam, LPARAM lParam);

    //获取某一行的文本
    const char* GetItemText(int index/*行*/);

    virtual void DoCreated();
    virtual void DoSized(CRect& rect);
    virtual bool DoSizing(CRect& rect);
    virtual void DoShow(bool isShow);
    //
    void ResetSize();
    void RecaluListSize();
protected:
    void RebuildMiniSize();
private:
    int m_iBorderSize;
    CCtrlStatic m_static;//标题(列表框上面的提示文本)
    CCtrlList m_list;//列表框
    int m_iBtnType;//对话框按钮显示类型
    CCtrlButton m_button;//确定按钮
    CCtrlButton m_cancel;//取消按钮
    CCtrlStatic m_buttonBg;
    int m_iStaticHeight;//高度
    int m_iButtonHeight;	//按钮高度
    CSize m_minSize;
    CWndObject* m_lpBindObj;
    //stype
    char* m_lpCheckBoxAni;
    char* m_lpDelBtnAni;
    int m_checkBoxFillType;
    int m_delBtnFillType;
    CRect m_checkBoxRect;
    int m_iSel;	//当前选中第几个
    bool m_isSelAndConfirm;
    CRect m_delItemRect;
    RowIdxPairList m_RemoveRows;
    IRemoveItemNotify* m_pINotifyCtrl;
    int m_iSide;
public:
    void ClearRemoveRows();
    void UndoRemove();
    void SetNotifyCtrl(IRemoveItemNotify* pNotifyCtrl);
    void SetDockSide(int iSide);
    void SetBtnTextWithUTF8(const char* pszOKText, const char* pszCancelText);
};


/**
组合框(继承自对话框,因为内部包含CCtrlEdit,CCtrlButton,CCtrlComboBoxList(本CCtrlComboBox弹出的选项对话框))
**/
class CCtrlComboBox:public CCtrlDlg
{
public:
    CCtrlComboBox();
    virtual ~CCtrlComboBox();

    //获取控件类型　CTRL_COMBOBOX
    virtual int GetType()const;

    //property
    //drop btn size
    void SetDropBtnWidth(int width);

    int GetDropBtnWidth()const;

    void SetDropDownBtnAni(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);

    //text
    void SetWindowText(const char* lpText);


    void SetWindowTextWithUTF8(const char* lpText);

    //获得m_edit输入框里的值
    const char* GetWindowText();

    //设置标题
    void SetTitleCaption(const char* lpText);

    //用UTF8编码设置标题
    void SetTitleCaptionWithUTF8(const char* lpText);

    //设置选中
    void SetSel(int sel);

    //获取选中项
    int GetSel()const;

    //增加选项(弹出的选项对话框列表里增加一行文本)
    void Append(const char* lpText);

    //用UTF8编码增加选项(弹出的选项对话框列表里增加一行文本)
    void AppendWithUTF8(const char* lpText);

    void Clear();

    void DeleteItem(int index);

    //edit style
    void SetFontColor(unsigned int color);
    void SetFontSize(int size);
    void SetFontName(const char* name);
    void SetEditBgAni(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);

    //设置编辑框是否只读
    void SetReadOnly(bool ReadOnly);

    //编辑框是否只读
    bool IsReadOnley()const;

    void SetSelBgFillType(int fillType,int borderSize=0);
    //item style

    //border size
    void SetBorderSize(int iSize);
    int GetBorderSize() const;

    //item dlg border size
    void SetItemDlgBorderSize(int iSize);

    //title area  hight
    void SetTitleAreaHeight(int iHeight);

    // confirm button area height
    void SetOKBtnAreaHeight(int iHeight);

    //check box
    void SetCheckBoxAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX);

    //DelBtn
    void SetDelItemBtnAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX);

    //sel ani
    void SetSelAni(const char* lpAni,int fillType=CWndObject::BGTYPE_NINESQUAREEX,int borderSize=2);

    //content ani
    void SetContentAni(const char* lpAni);

    //list line height
    void SetItemHeight(int iHeight);

    //设置确定按钮的样式
    void SetOKBtnAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX,int borderSize=0);

    //设置取消按钮的样式
    void SetCancelBtnAni(const char* lpAni,int fillType=CWndObject::BGTYPE_FIX,int borderSize=0);

    //设置标题的颜色
    void SetTitleColor(unsigned int color);

    //
    void SetItemDlgBgAni(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);
    void SetItemDlgBgFillType(int fillType,int borderSize);

    //color
    void SetSelColor(unsigned int clrSel);
    void SetValColor(unsigned int clrComm);

    //bg
    void SetFloodBg(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);
    void SetHeadBg(const char* lpAni,int fillType=CWndObject::BGTYPE_STRETCH,int borderSize=0);

    //btn type
    void SetBtnType(int btnType);

    //clicked and confirm
    void SetClickedAnConfirm(bool clickedAndConfirm);

    //drop button title
    void SetDropBtnText(const char* lpText);
    void SetDropBtnTextWithUTF8(const char* lpText);
    const char* GetDropBtnText();

    //enable
    bool IsEnabled() const;
    void SetEnabled(bool isEnable);

    void DragUp();
    void DragDown();

    CWndObject* GetDropBtn();

    ClickEvent SelChangeEvent;//用户更改列表选中的事件
    ClickEvent EventOK;	//按下ok按钮的事件
    ClickEvent EventCancel;//按下cancel按钮的事件
    CommonEvent ItemDelEvent;//删除一个选项的事件
protected:

    //按下确定
    void OnSelOK();

    //按下取消
    void OnCancel();

    void OnEditChange();
    void OnDlgShow();
    void OnDropClick();
    void OnEditClick();
    virtual void DoCreated();
    virtual void DoSized(CRect& rect);

    //此回调接口统一改为:WndProc回调接口
    //virtual void RefWndPro(int iType,CWndObject* obj,CPoint& pos,const void* lpParam=NULL);
    virtual bool WndProc(CWndObject* pObj,UINT message,WPARAM wParam, LPARAM lParam);

    void ResetSize();
private:
    CCtrlEdit m_edit;//组合框里的编辑框
    CCtrlButton m_button;
    CCtrlComboBoxList m_dlg;//本CCtrlComboBox弹出的选项对话框
    int m_iDropBtnSize;
    int m_iBorderSize;
    bool m_bEnable;
    bool m_editReady;//编辑框是否只读

public:
    void SetNotifyCtrl(IRemoveItemNotify* pNotifyCtrl);
    void GetSelPos(int& iSelRow, int& iSelCol);

    //设置对话框按钮显示类型
    void SetStyle(int iStyle=enBTN_ALL);
    void SetDockSide(int iSide);
    void SetListBtnTextWithUTF8(const char* pszOKText, const char* pszCancelText);
};



#endif


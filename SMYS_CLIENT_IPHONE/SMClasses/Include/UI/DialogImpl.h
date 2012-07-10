/*
 *  DialogImpl.h
 *  实现窗口类,读取ini配置自动初始化窗口
 *  Created by ndtq on 11-2-16.
 *  Copyright 2011 TQ Digital Entertainment. All rights reserved.
 */
#ifndef __DIALOG_IMPL_H__
#define __DIALOG_IMPL_H__

#include "CtrlDlg.h"

//点击按钮(fun())
#define ON_BN_CLICKED(id,fun) GetDlgItem(id)->EventClicked.bind(this,&MY_GUI_CLASS_NAME::fun);

//鼠标移动(fun(0,坐标))
#define ON_MOUSE_MOVE(id,fun) GetDlgItem(id)->EventMouseMove.bind(this,&MY_GUI_CLASS_NAME::fun);

//鼠标按下(fun((参数1,坐标))
#define ON_MOUSE_DOWN(id,fun) GetDlgItem(id)->EventMouseDown.bind(this,&MY_GUI_CLASS_NAME::fun);

//鼠标弹起(fun(0,坐标))
#define ON_MOUSE_UP(id,fun) GetDlgItem(id)->EventMouseUp.bind(this,&MY_GUI_CLASS_NAME::fun);

//鼠标进入窗口(fun(0,坐标))
#define ON_MOUSE_ENTER(id,fun) GetDlgItem(id)->EventMouseEnter.bind(this,&MY_GUI_CLASS_NAME::fun);

//鼠标离开窗口(fun(0,坐标))
#define ON_MOUSE_LEAVE(id,fun) GetDlgItem(id)->EventMouseLeave.bind(this,&MY_GUI_CLASS_NAME::fun);

//滑动条值改变(fun(资源ID号,当前滑块值))
#define ON_SLIDER_CHANGED(id,fun) ((CCtrlSlider*)GetDlgItem(id))->EventSlider.bind(this,&MY_GUI_CLASS_NAME::fun);

//编辑框改变文本(fun())
#define ON_EN_CHANGE(id,fun) ((CCtrlEdit*) GetDlgItem(id))->EventChanged.bind(this,&MY_GUI_CLASS_NAME::fun);

//列表框更改选中项(fun())
#define ON_LIST_SEL_CHANGE(id,fun) ((CCtrlList*)GetDlgItem(id))->SelChangeEvent.bind(this,&MY_GUI_CLASS_NAME::fun);

//列表框点击标题头(fun(参数1,参数2))
#define ON_LIST_TITLE_CLICKED(id,fun) ((CCtrlList*)GetDlgItem(id))->EventTitleClick.bind(this,&MY_GUI_CLASS_NAME::fun);

//组合框更改选中项(fun())
#define ON_COMBOBOX_SEL_CHANGE(id,fun) ((CCtrlComboBox*)GetDlgItem(id))->SelChangeEvent.bind(this,&MY_GUI_CLASS_NAME::fun);

//组合框删除选项(fun(参数1,参数2))
#define ON_COMBOBOX_DEL_ITEM(id,fun) ((CCtrlComboBox*)GetDlgItem(id))->ItemDelEvent.bind(this,&MY_GUI_CLASS_NAME::fun);

//组合框点击确定按钮(fun())
#define ON_COMBOBOX_CONFIRM_CLICK(id,fun) ((CCtrlComboBox*)GetDlgItem(id))->EventOK.bind(this,&MY_GUI_CLASS_NAME::fun);

//组合框点击取消按钮(fun())
#define ON_COMBOBOX_CANCEL_CLICK(id, fun) ((CCtrlComboBox*)GetDlgItem(id))->EventCancel.bind(this,&MY_GUI_CLASS_NAME::fun);

//拖动控件(fun())
#define ON_DRAG(id,fun) GetDlgItem(id)->EventDrag.bind(this,&MY_GUI_CLASS_NAME::fun);

//编辑框完成输入(fun(UITypes::WPARAM NULL,UITypes::WPARAM NULL))
#define ON_EN_DONE(id,fun) ((CCtrlEdit*) GetDlgItem(id))->EventDone.bind(this,&MY_GUI_CLASS_NAME::fun);

//自动绑定控件和事件
#define BEGIN_MESSAGE_MAP(theClass,baseClass) void theClass::BindEvent() {
#define END_MESSAGE_MAP() }
#define DECLARE_MESSAGE_MAP() virtual void BindEvent();

//自动配置对话框实现类
class CDialogImpl : public CCtrlDlg
{
public:
	CDialogImpl();
	virtual ~CDialogImpl();
	
	
protected:
	//根据ini文件自动配置控件的属性
	void DDX_Control(void *pDX, int nIDC, CWndObject &rControl);
};


#endif



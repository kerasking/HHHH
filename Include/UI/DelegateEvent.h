#ifndef __MY_EVENT_H__
#define __MY_EVENT_H__
/**
自定义函数绑定
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#include "FastDelegate.h"

//无函数参数的函数绑定(fun())
typedef fastdelegate::FastDelegate0<> ClickEvent;

//两个参数的函数绑定(fun(参数1,参数2))
typedef fastdelegate::FastDelegate2<WPARAM, LPARAM> CommonEvent;

//两个参数的函数绑定(fun(参数1,坐标))
typedef fastdelegate::FastDelegate2<UINT, CPoint/*坐标*/> MouseEvent;

//三个参数的函数绑定(fun(参数1,坐标,参数3))
typedef fastdelegate::FastDelegate3<UINT, CPoint/*坐标*/, short> MouseWheelEvent;

#endif

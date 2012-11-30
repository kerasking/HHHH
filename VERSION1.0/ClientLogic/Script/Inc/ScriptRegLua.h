/*
 *  ScriptRegLua.h
 *  DragonDrive
 *
 *  Created by zhangwq on 12-11-30.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *	
 *	说明：C++类注册到Luaplus，用确定的时机用确定的方法注册！平台无关！
 *			之前的注册时机是在模块的全局变量初始化（发生函数调用、对象构造等）的时候注册的，
 *			在不同编译器上有不同实现（这部分不属于C++标准，这是平台相关的，不属于语言范畴）
 *
 */

#pragma once

struct NDScriptRegLua
{
	static void doReg();
};
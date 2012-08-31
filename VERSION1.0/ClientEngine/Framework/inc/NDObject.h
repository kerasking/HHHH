//
//  NDObject.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	－－介绍－－
//	游戏框架基础籄1�7
//	程序中大多数的类都继承自该类
//	如果派生类分别在头文件中实现DECLARE_CLASS，在源文件中实现IMPLEMENT_CLASS这两个宏，那么该派生类就具有了动态识别功胄1�7
//	派生类必须拥有默认构造函数，以备动�1�7�生成使甄1�7

#ifndef __NDObject_H
#define __NDObject_H

#include "Utility.h"

#define override
#define hide
#define overload

namespace NDEngine
{
//－－模仿mfc动�1�7�识别－＄1�7
//......
class NDObject;

struct NDRuntimeClass
{
	char* className;
	int objectSize;
	NDObject* (*m_pfnCreateObject)();
	NDRuntimeClass* m_pBaseClass;
	NDRuntimeClass* m_pNextClass;
	static NDRuntimeClass* pFirstClass;
	static NDRuntimeClass* RuntimeClassFromString(const char* ndClassName);
	NDObject* CreateObject();
};

struct NDClassInit
{
	NDClassInit(NDRuntimeClass* pNewClass)
	{
		pNewClass->m_pNextClass = NDRuntimeClass::pFirstClass;
		NDRuntimeClass::pFirstClass = pNewClass;
	}
};

#define RUNTIME_CLASS(class_name) (&class_name::class##class_name)

#define DECLARE_CLASS(class_name) \
public:\
	static NDRuntimeClass class##class_name; \
	virtual NDRuntimeClass* GetRuntimeClass() const; \
	static NDObject* CreateObject();

#define IMPLEMENT_CLASS(class_name, base_class_name) \
	NDObject* class_name::CreateObject()\
	{ \
		return new class_name; \
	} \
	static char _lpsz##class_name[] = #class_name; \
	NDRuntimeClass class_name::class##class_name = { \
	_lpsz##class_name, sizeof(class_name), class_name::CreateObject, \
	RUNTIME_CLASS(base_class_name), NULL }; \
	static NDClassInit _init_##class_name(&class_name::class##class_name); \
	NDRuntimeClass* class_name::GetRuntimeClass() const \
	{\
		return &class_name::class##class_name; \
	}	
//－－－－

class NDObject
{
public:
	NDObject();
	virtual ~NDObject();

public:
//
//		函数：IsKindOfClass
//		作用：用于动态识别类型，用于验证对象是否时某丄1�7个类或其父类的对豄1�7
//		参数：runtimeClass霄1�7要被识别的类，例如：RUNTIME_CLASS(NDObject)
//		返回值：true正确 false错误
	bool IsKindOfClass(const NDRuntimeClass* runtimeClass);
//		
//		函数：SetDelegate
//		作用：设置委托，注意：全屄1�7对象注册完委托，释放时请注销SetDelegate(NULL)
//		参数：receiver委托事件接收耄1�7
//		返回值：旄1�7	
	void SetDelegate(NDObject* receiver);
//		
//		函数：GetDelegate
//		作用：获取委托的对象
//		参数：无
//		返回值：旄1�7	
	NDObject* GetDelegate();
//		
//		函数：GetRuntimeClass
//		作用：获取类识别信息
//		参数：无
//		返回值：类识别信息结构体	
	virtual NDRuntimeClass* GetRuntimeClass() const;

public:
	static NDRuntimeClass classNDObject;
	static NDObject* CreateObject();

private:
	NDObject* m_delegate;
};
}

#endif

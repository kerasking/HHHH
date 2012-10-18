//
//  NDObject.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (缃戦緳)DeNA. All rights reserved.
//
//	锛嶏紞浠嬬粛锛嶏紞
//	娓告垙妗嗘灦鍩虹绫??
//	绋嬪簭涓ぇ澶氭暟鐨勭被閮界户鎵胯嚜璇ョ被
//	濡傛灉娲剧敓绫诲垎鍒湪澶存枃浠朵腑瀹炵幇DECLARE_CLASS锛屽湪婧愭枃浠朵腑瀹炵幇IMPLEMENT_CLASS杩欎袱涓畯锛岄偅涔堣娲剧敓绫诲氨鍏锋湁浜嗗姩鎬佽瘑鍒姛鑳??
//	娲剧敓绫诲繀椤绘嫢鏈夐粯璁ゆ瀯閫犲嚱鏁帮紝浠ュ鍔ㄦ??佺敓鎴愪娇鐢??

#ifndef __NDObject_H
#define __NDObject_H

#include "Utility.h"

#define override
#define hide
#define overload

namespace NDEngine
{
//锛嶏紞妯′豢mfc鍔ㄦ??佽瘑鍒紞锛??
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
//锛嶏紞锛嶏紞

class NDObject
{
public:
	NDObject();
	virtual ~NDObject();

public:
//
//		函数：IsKindOfClass
//		作用：用于动态识别类型，用于验证对象是否时某一个类或其父类的对象
//		参数：runtimeClass需要被识别的类，例如：RUNTIME_CLASS(NDObject)
	bool IsKindOfClass(const NDRuntimeClass* runtimeClass);
//		
//		函数：SetDelegate
//		作用：设置委托，注意：全局对象注册完委托，释放时请注销SetDelegate(NULL)
//		参数：receiver委托事件接收者
//		返回值：无	
	void SetDelegate(NDObject* receiver);
//		
//		函数：GetDelegate
//		作用：获取委托的对象
//		参数：无
//		返回值：无	
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

//
//  NDObject.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-7.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDObject.h"
#include <string.h>

namespace NDEngine
{
NDRuntimeClass* NDRuntimeClass::pFirstClass = NULL;

NDRuntimeClass* NDRuntimeClass::RuntimeClassFromString(const char* ndClassName)
{
	NDRuntimeClass* pndClass = NDRuntimeClass::pFirstClass;

	while (pndClass != NULL)
	{
		if (strcmp(ndClassName, pndClass->className) == 0)
		{
			return pndClass;
		}
		pndClass = pndClass->m_pNextClass;
	}

	return NULL;
}

NDObject* NDRuntimeClass::CreateObject()
{
	if (m_pfnCreateObject == NULL)
	{
		return NULL;
	}

	NDObject* pObject = NULL;
	pObject = (*m_pfnCreateObject)();
	return pObject;
}

NDRuntimeClass NDObject::classNDObject =
{ (char*) "NDObject", sizeof(NDObject), NDObject::CreateObject, NULL, NULL };

NDObject::NDObject()
{
	m_delegate = NULL;
}

NDObject::~NDObject()
{

}

NDObject* NDObject::CreateObject()
{
	return new NDObject;
}

bool NDObject::IsKindOfClass(const NDRuntimeClass* runtimeClass)
{
	NDRuntimeClass* pClassThis = this->GetRuntimeClass();
	while (pClassThis != NULL)
	{
		if (pClassThis == runtimeClass)
			return true;
		pClassThis = pClassThis->m_pBaseClass;
	}
	return false;
}

NDRuntimeClass* NDObject::GetRuntimeClass() const
{
	return &NDObject::classNDObject;
}

void NDObject::SetDelegate(NDObject* receiver)
{
	m_delegate = receiver;
}

NDObject* NDObject::GetDelegate()
{
	return m_delegate;
}

}
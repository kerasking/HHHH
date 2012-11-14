//
//  NDClassFactory.h
//  NDClassFactory
//
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//	
//	@author 郭浩
//
//	－－介绍－－
//  弱引用智能指针类。

#ifndef NDWEAKPTR_H
#define NDWEAKPTR_H

template<typename T> class NDSharedPtr;
template<typename T> class NDWeakPtr;

#include "NDSharedPtr.h"
#include "BaseType.h"

template<typename T>
class NDWeakPtr
{
protected:
	T* m_ptPointer;
	NDSPtrCounted* m_pkCount;
public:
	NDWeakPtr()
	{
		m_ptPointer = NULL;
		m_pkCount = 0;
	}

	NDWeakPtr(const NDSharedPtr<T>& right)
	{
		m_ptPointer = right.get();
		m_pkCount = NDSharedPtr<T>::_get_counted(right);
		m_pkCount->m_kWeak.inc();
	}
	NDWeakPtr(const NDWeakPtr<T>& right)
	{
		m_ptPointer = right.m_ptPointer;
		m_pkCount = right.m_pkCount;
		m_pkCount->m_kWeak.inc();
	}
	~NDWeakPtr()
	{
		reset();
	}

	NDWeakPtr<T>& operator=(const NDWeakPtr<T>& right)
	{
		reset();
		m_ptPointer = right.m_ptPointer;
		m_pkCount = right.m_pkCount;
		m_pkCount->m_kWeak.inc();
		return *this;
	}

	NDWeakPtr<T>& operator=(const NDSharedPtr<T>& right)
	{
		reset();
		m_ptPointer = right.get();
		m_pkCount = right._get_sp();

		if(m_pkCount)
		{
			m_pkCount->m_kWeak.inc();
		}

		return *this;
	}

	void reset()
	{
		if (m_pkCount && m_pkCount->m_kWeak.dec() == 0)
		{
			delete m_pkCount;
			m_pkCount = NULL;
		}
	}

	T* get() const
	{
		if (!expired())
		{
			return m_ptPointer;
		}

		return 0;
	}

	BOOL expired() const
	{
		return m_pkCount == NULL || m_pkCount->m_kUsed.get() == 0;
	}

	NDSharedPtr<T> lock() const
	{
		if ( !expired() )
		{
			return NDSharedPtr<T>(*this);
		}
		return NDSharedPtr<T>(NULL);
	}

	NDSPtrCounted* _get_sp() const
	{
		return m_pkCount;
	}
};

#endif

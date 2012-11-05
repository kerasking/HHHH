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

template<typename T>
class NDWeakPtr
{
public:
	NDWeakPtr()
	{
		m_ptPointer = 0;
		m_pkCount = 0;
	}

	NDWeakPtr(const NDSharedPtr<T>& right)
	{
		m_ptPointer = right.GetPointer();
		m_pkCount = NDSharedPtr<T>::_get_counted(right);
		m_pkCount->m_kWeak.Increment();
	}
	NDWeakPtr(const NDWeakPtr<T>& right)
	{
		m_ptPointer = right.m_ptPointer;
		m_pkCount = right.m_pkCount;
		m_pkCount->m_kWeak.Increment();
	}
	~NDWeakPtr()
	{
		Reset();
	}

	NDWeakPtr<T>& operator=(const NDWeakPtr<T>& kRight)
	{
		Reset();
		m_ptPointer = kRight.m_ptPointer;
		m_pkCount = kRight.m_pkCount;
		m_pkCount->m_kWeak.Increment();
		return *this;
	}

	NDWeakPtr<T>& operator=(const NDSharedPtr<T>& right)
	{
		Reset();
		m_ptPointer = right.GetPointer();
		m_pkCount = right._get_sp();

		if(m_pkCount)
		{
			m_pkCount->m_kWeak.Increment();
		}

		return *this;
	}

	void Reset()
	{
		if (m_pkCount && m_pkCount->m_kWeak.Decrement() == 0)
		{
			delete m_pkCount;
			m_pkCount = NULL;
		}
	}

	T* GetPointer() const
	{
		if (!Expired())
		{
			return m_ptPointer;
		}

		return 0;
	}

	bool Expired() const
	{
		return m_pkCount == NULL || m_pkCount->m_kUsed.GetRef() == 0;
	}

	NDSharedPtr<T> Lock() const
	{
		if ( !Expired() )
		{
			return NDSharedPtr<T>(*this);
		}
		return NDSharedPtr<T>(0);
	}

	NDSPtrCounted* _get_sp() const
	{
		return m_pkCount;
	}

protected:

	T* m_ptPointer;
	NDSPtrCounted* m_pkCount;

private:
};

#endif

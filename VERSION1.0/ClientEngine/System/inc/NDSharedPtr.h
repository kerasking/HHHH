//
//  NDClassFactory.h
//  NDClassFactory
//
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//	
//	@author 郭浩
//
//	－－介绍－－
//  强引用智能指针类。

#ifndef NDSHAREDPTR_H
#define NDSHAREDPTR_H

template<typename T> class NDSharedPtr;
template<typename T> class NDWeakPtr;

#include "NDSPtrCounted.h"
#include "NDWeakPtr.h"
#include "NDEnableSharedFromThis.h"
#include "assert.h"
#define shared_ptr_assert(x)	//_assert_define(x)

inline void SpSetSharedFromThis( ... )
{
}
template<typename T> inline void SpSetSharedFromThis(NDSharedPtr<T>* sp,
														  NDEnableSharedFromThis<T>* p)
{
	if (p)
	{
		p->InternalAcceptOwner(*sp);
	}
}

template<class T>
class NDSharedPtr
{
public:
	typedef NDSharedPtr<T> ThisType;
	typedef NDRefLong::CountType CountType;
private:
	T* m_pkPointer;
	NDSPtrCounted*	m_pkCount;
public:
	NDSharedPtr(T * p = NULL)
	{
		m_pkPointer = p;
		m_pkCount = new NDSPtrCounted(1,1);
		SpSetSharedFromThis(this, m_pkPointer);
	}

	NDSharedPtr(const NDWeakPtr<T>& kRight)
	{
		m_pkPointer = kRight.GetPointer();
		m_pkCount = kRight._get_sp();
		AddRef();
		SpSetSharedFromThis(this, m_pkPointer);
	}

	NDSharedPtr(const ThisType& o)
	{
		m_pkPointer = o.m_pkPointer;
		m_pkCount = o.m_pkCount;
		AddRef();
		SpSetSharedFromThis(this, m_pkPointer);
	}
	
	~NDSharedPtr()
	{
		Release();
	}
	
	ThisType& operator=(const ThisType& o)
	{
		if(this != &o)
		{
			if(m_pkPointer!=o.m_pkPointer)
			{
				Release();
				m_pkPointer = o.m_pkPointer;
				m_pkCount = o.m_count;
				SpSetSharedFromThis(this, m_pkPointer);
				AddRef();
			}
		}
		return (*this);
	}

	ThisType& operator=(const T* pkPointer)
	{
		if (m_pkPointer != pkPointer)
		{
			Release();
			m_pkPointer = const_cast<T*>(pkPointer);
			m_pkCount = new NDSPtrCounted(1,1);
			SpSetSharedFromThis(this, m_pkPointer);
		}
		return (*this);
	}

	bool operator == (const ThisType& kObj) const
	{
		return m_pkPointer == kObj.m_pkPointer;
	}

	bool operator == (const T* pkPointer) const
	{
		return m_pkPointer == pkPointer;
	}

	bool operator != (const ThisType& kObj) const
	{
		return m_pkPointer != kObj.m_pkPointer;
	}
#if _MSC_VER < 1300
	bool operator != (const T* p) const
	{
		return m_pkPointer != p;
	}
#endif

	operator T*() const
	{
		return m_pkPointer;
	}

	T& operator*() const
	{
		return (*m_pkPointer);
	}
	
	T* operator->() const
	{
		shared_ptr_assert(m_pkPointer);
		return (m_pkPointer);
	}

	T* GetPointer() const
	{
		return m_pkPointer;
	}

	CountType UseCount() const
	{
		if (m_pkPointer)
		{
			return m_pkCount->m_kUsed.GetRef();
		}
		return 0;
	}

	void Reset()
	{
		Release();
	}

public:

	void AddRef()
	{
		m_pkCount->m_kUsed.Increment();
	}
	
	void Release()
	{
		if (m_pkCount)
		{
			if(m_pkCount->m_kUsed.Decrement() == 0)
			{
				DeleteObject(m_pkPointer);
				if( m_pkCount->m_kWeak.Decrement() == 0 )
				{
					delete m_pkCount;
				}
			}
			m_pkCount = NULL;
		}
		m_pkPointer = NULL;
	}
public:
	NDSPtrCounted* _get_sp() const
	{
		return m_pkCount;
	}
protected:
	void DeleteObject(T* pkObject)
	{
		if (pkObject)
		{
			delete pkObject;
		}
	}
};

#endif
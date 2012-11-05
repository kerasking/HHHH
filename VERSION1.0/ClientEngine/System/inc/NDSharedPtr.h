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

inline void SP_Set_Shared_From_This( ... )
{
}
template<typename T> inline void SP_Set_Shared_From_This(NDSharedPtr<T>* sp,
														  NDEnableSharedFromThis<T>* p)
{
	if (p)
	{
		p->_internal_accept_owner( *sp );
	}
}

template<class T>
class NDSharedPtr
{
public:
	typedef NDSharedPtr<T> ThisType;
	typedef NDRefLong::count_type CountType;
private:
	T* m_pkPointer;
	NDSPtrCounted*	m_pkCount;
public:
	NDSharedPtr(T * p = NULL)
	{
		m_pkPointer = p;
		m_pkCount = new NDSPtrCounted(1,1);
		SP_Set_Shared_From_This(this, m_pkPointer);
	}

	NDSharedPtr(const NDWeakPtr<T>& kRight)
	{
		m_pkPointer = kRight.get();
		m_pkCount = kRight._get_sp();
		addref();
		SP_Set_Shared_From_This(this, m_pkPointer);
	}

	NDSharedPtr(const ThisType& o)
	{
		m_pkPointer = o.m_pkPointer;
		m_pkCount = o.m_count;
		addref();
		SP_Set_Shared_From_This(this, m_pkPointer);
	}
	
	~NDSharedPtr()
	{
		release();
	}
	
	ThisType& operator=(const ThisType& o)
	{
		if(this!=&o)
		{
			if(m_pkPointer!=o.m_pkPointer)
			{
				release();
				m_pkPointer = o.m_pkPointer;
				m_pkCount = o.m_count;
				SP_Set_Shared_From_This(this, m_pkPointer);
				addref();
			}
		}
		return (*this);
	}

	ThisType& operator = (const T* pkPointer)
	{
		if (m_pkPointer != pkPointer)
		{
			release();
			m_pkPointer = const_cast<T*>(pkPointer);
			m_pkCount = new NDSPtrCounted(1,1);
			SP_Set_Shared_From_This(this, m_pkPointer);
		}
		return (*this);
	}

	BOOL operator == (const ThisType& kObj) const
	{
		return m_pkPointer == kObj.m_pkPointer;
	}

	BOOL operator == (const T* pkPointer) const
	{
		return m_pkPointer == pkPointer;
	}

	BOOL operator != (const ThisType& kObj) const
	{
		return m_pkPointer != kObj.m_pkPointer;
	}
#if _MSC_VER < 1300
	BOOL operator != (const T* p) const
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

	T* get() const
	{
		return m_pkPointer;
	}

	CountType use_count() const
	{
		if (m_pkPointer)
		{
			return m_pkCount->m_kUsed.get();
		}
		return 0;
	}

	void reset()
	{
		release();
	}

public:

	void addref()
	{
		m_pkCount->m_kUsed.inc();
	}
	
	void release()
	{
		if (m_pkCount)
		{
			if(m_pkCount->m_kUsed.dec() == 0)
			{
				delete_object(m_pkPointer);
				if( m_pkCount->m_kWeak.dec() == 0 )
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
	void delete_object(T* p)
	{
		if (p)
		{
			delete p;
		}
	}
};

#endif
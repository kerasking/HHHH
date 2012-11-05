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
	typedef NDSharedPtr<T> this_type;
	typedef NDRefLong::count_type count_type;
private:
	T* m_ptr;
	NDSPtrCounted*	m_pkCount;
public:
	NDSharedPtr(T * p = NULL)
	{
		m_ptr = p;
		m_pkCount = new NDSPtrCounted(1,1);
		SP_Set_Shared_From_This(this, m_ptr);
	}

	NDSharedPtr(const NDWeakPtr<T>& right)
	{
		m_ptr = right.get();
		m_pkCount = right._get_sp();
		addref();
		SP_Set_Shared_From_This(this, m_ptr);
	}

	NDSharedPtr(const this_type& o)
	{
		m_ptr = o.m_ptr;
		m_pkCount = o.m_count;
		addref();
		SP_Set_Shared_From_This(this, m_ptr);
	}
	
	~NDSharedPtr()
	{
		release();
	}
	
	this_type& operator=(const this_type& o)
	{
		if(this!=&o)
		{
			if(m_ptr!=o.m_ptr)
			{
				release();
				m_ptr = o.m_ptr;
				m_pkCount = o.m_count;
				SP_Set_Shared_From_This(this, m_ptr);
				addref();
			}
		}
		return (*this);
	}

	this_type& operator=(const T* p)
	{
		if (m_ptr != p)
		{
			release();
			m_ptr = const_cast<T*>(p);
			m_pkCount = new NDSPtrCounted(1,1);
			SP_Set_Shared_From_This(this, m_ptr);
		}
		return (*this);
	}

	BOOL operator == (const this_type& o) const
	{
		return m_ptr == o.m_ptr;
	}

	BOOL operator == (const T* p) const
	{
		return m_ptr == p;
	}

	BOOL operator != (const this_type& o) const
	{
		return m_ptr != o.m_ptr;
	}
#if _MSC_VER < 1300
	BOOL operator != (const T* p) const
	{
		return m_ptr != p;
	}
#endif

	operator T*() const
	{
		return m_ptr;
	}

	T& operator*() const
	{
		return (*m_ptr);
	}
	
	T* operator->() const
	{
		shared_ptr_assert(m_ptr);
		return (m_ptr);
	}

	T* get() const
	{
		return m_ptr;
	}

	count_type use_count() const
	{
		if (m_ptr)
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
	void addref(void)
	{
		m_pkCount->m_kUsed.inc();
	}
	
	void release(void)
	{
		if (m_pkCount)
		{
			if(m_pkCount->m_kUsed.dec() == 0)
			{
				delete_object(m_ptr);
				if( m_pkCount->m_kWeak.dec() == 0 )
				{
					delete m_pkCount;
				}
			}
			m_pkCount = NULL;
		}
		m_ptr = NULL;
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
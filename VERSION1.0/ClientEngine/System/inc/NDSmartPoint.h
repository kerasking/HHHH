/**
*
*/

#ifndef NDSMARTPOINT_H
#define NDSMARTPOINT_H

#include "define.h"

NS_NDENGINE_BGN

class NDSmartCount
{
public:

	NDSmartCount(int c = 0) :
	m_nUsedCount(c)
	{
	}
	~NDSmartCount()
	{
	}

	int addref()
	{
		return ++m_nUsedCount;
	}
	int release()
	{
		return --m_nUsedCount;
	}

private:
	int m_nUsedCount;
};

template<class T>
class NDSmartPoint
{
public:

	explicit NDSmartPoint(T* ptr) :
	m_pkPoint(ptr),
	m_pkRealPointer(new NDSmartCount(1))
	{
	}

	explicit NDSmartPoint() :
	m_pkPoint(NULL), m_pkRealPointer(NULL)
	{
	}

	~NDSmartPoint(void)
	{
		if (m_pkPoint && m_pkRealPointer->release() <= 0)
		{
			delete m_pkPoint;
			delete m_pkRealPointer;
			m_pkPoint = NULL;
		}
	}

	NDSmartPoint(const NDSmartPoint<T>& t)
	{
		m_pkPoint = t.m_pkPoint;
		m_pkRealPointer = t.m_pkCount;

		if (m_pkRealPointer)
		{

			m_pkRealPointer->addref();

		}

	}

	void operator=(NDSmartPoint<T>& t)
	{
		if (m_pkPoint && m_pkRealPointer->release() <= 0)
		{

			delete m_pkPoint;
			delete m_pkRealPointer;
		}

		m_pkPoint = t.m_pkPoint;
		m_pkRealPointer = t.m_pkCount;

		if (m_pkRealPointer)
		{
			m_pkRealPointer->addref();.
		}
	}

	T *operator->(void)
	{
		return m_pkPoint;
	}

	T& operator *(void)
	{
		return *m_pkPoint;
	}

	bool operator!() const
	{
		return !m_pkPoint;
	}

	typedef NDSmartPoint<T> this_type;
	typedef T * this_type::*unspecified_bool_type;
	operator unspecified_bool_type() const
	{
		return !m_pkPoint ? 0 : &this_type::m_pkPoint;
	}

	T* get()
	{
		return m_pkPoint;
	}
	void reset(T* ptr)
	{
		if (m_pkPoint && m_pkRealPointer->release() <= 0)
		{
			delete m_pkPoint;
			delete m_pkRealPointer;
		}

		m_pkPoint = ptr;

		if (m_pkPoint)
		{
			m_pkRealPointer = new NDSmartCount(1);
		}
		else
		{
			m_pkRealPointer = NULL;
		}
	}

	void reset(NDSmartPoint<T>& t)
	{
		if (m_pkPoint && m_pkRealPointer->release() <= 0)
		{
			SAFE_DELETE(m_pkPoint);
			SAFE_DELETE(m_pkRealPointer);
		}

		m_pkPoint = t.m_pkPoint;
		m_pkRealPointer = t.m_pkCount;

		if (m_pkRealPointer)
		{
			m_pkRealPointer->addref();
		}
	}

private:

	T* m_pkPoint;
	NDSmartCount* m_pkRealPointer;
};

template<class T, class U> inline bool operator==(NDSmartPoint<T> & a,
												  NDSmartPoint<U> & b)
{
	return a.get() == b.get();
}

template<class T, class U> inline bool operator!=(NDSmartPoint<T> & a,
												  NDSmartPoint<U> & b)
{
	return a.get() != b.get();
}

NS_NDENGINE_END

#endif
//
//  NDClassFactory.h
//  NDClassFactory
//
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//	
//	@author 郭浩
//
//	－－介绍－－
//  智能指针依赖引用类。

#ifndef NDREFLONG
#define NDREFLONG

#ifndef WIN32
#include <asm/atomic.h>
#endif

class NDRefLong
{
public:
	typedef volatile long CountType;

	explicit NDRefLong(CountType nRef)
	{
		m_nRef = nRef;
	}

	long Increment()
	{
#ifdef WIN32
		return InterlockedIncrement(&m_nRef);
#else
		return 0;//atomic_inc(&m_nRef); ///< atomic_inc不知道在哪个头文件 郭浩
#endif
	}
	
	long Decrement()
	{
#ifdef WIN32
		return InterlockedDecrement(&m_nRef);
#else
		return 0;//atomic_dec(&m_nRef);///< atomic_dec不知道在哪个头文件 郭浩
#endif
	}
	long operator++()
	{
		return Increment();
	}
	long operator--()
	{
		return Decrement();
	}
	long operator++(int)
	{
		return Increment() - 1;
	}
	long operator--(int)
	{
		return Decrement() + 1;
	}
public:
	CountType GetRef() const
	{
		return m_nRef;
	}
private:
	CountType m_nRef;
};

#endif
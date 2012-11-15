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

class NDRefLong
{
public:
	typedef volatile long count_type;

	explicit NDRefLong(count_type ref)
	{
		m_nRef = ref;
	}

	long inc()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		return InterlockedIncrement(&m_nRef);
#else
        return ++m_nRef;
#endif
	}
	
	long dec()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		return InterlockedDecrement(&m_nRef);
#else
        return --m_nRef;
#endif
	}
	long operator++()
	{
		return 	inc();
	}
	long operator--()
	{
		return dec();
	}
	long operator++(int)
	{
		return inc() - 1;
	}
	long operator--(int)
	{
		return dec() + 1;
	}
public:
	count_type get() const
	{
		return m_nRef;
	}
private:
	count_type m_nRef;
};

#endif
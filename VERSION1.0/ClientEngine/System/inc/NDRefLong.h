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
		return InterlockedIncrement(&m_nRef);
	}
	
	long dec()
	{
		return InterlockedDecrement(&m_nRef);
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
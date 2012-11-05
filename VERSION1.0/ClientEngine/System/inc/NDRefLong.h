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
	typedef volatile long CountType;

	explicit NDRefLong(CountType nRef)
	{
		m_nRef = nRef;
	}

	long Increment()
	{
		return InterlockedIncrement(&m_nRef);
	}
	
	long Decrement()
	{
		return InterlockedDecrement(&m_nRef);
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
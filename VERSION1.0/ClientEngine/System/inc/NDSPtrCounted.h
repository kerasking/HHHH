//
//  NDClassFactory.h
//  NDClassFactory
//
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//	
//	@author 郭浩
//
//	－－介绍－－
//  智能指针计数。

#ifndef NDSPTRCOUNTED_H
#define NDSPTRCOUNTED_H

#include "NDRefLong.h"

struct NDSPtrCounted
{
	NDRefLong m_kUsed;
	NDRefLong m_kWeak;

	NDSPtrCounted(NDRefLong::count_type _use, NDRefLong::count_type _weak):
	m_kUsed(_use),
	m_kWeak(_weak)
	{}
};

#endif
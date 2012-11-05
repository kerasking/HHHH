#pragma once

#ifndef _SP_COUNTED_H_
#define _SP_COUNTED_H_

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
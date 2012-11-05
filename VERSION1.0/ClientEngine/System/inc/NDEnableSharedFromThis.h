#pragma once

#ifndef _ENABLE_SHARED_FROM_THIS_H_
#define _ENABLE_SHARED_FROM_THIS_H_

#include "NDSharedPtr.h"
#include "NDWeakPtr.h"

template<typename T>
class NDEnableSharedFromThis
{
public:
	NDSharedPtr<T> shared_from_this()
	{
		return NDSharedPtr<T>( m_kWeakThis );
	}
public:
	void _internal_accept_owner(const NDSharedPtr<T>& p)
	{
		m_kWeakThis = p;
	}
private:
	NDWeakPtr<T> m_kWeakThis;
};

#endif
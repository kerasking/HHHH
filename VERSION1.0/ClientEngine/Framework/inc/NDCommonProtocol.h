/*
 *  NDCommonProtocol.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-15.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _ND_COMMON_PROTOCOL_H_
#define _ND_COMMON_PROTOCOL_H_

#include "NDObject.h"
#include "AutoLink.h"

#define DECLARE_PROTOCOLAUTOLINK(class_name) \
private: CAutoLink<class_name> m_autolink##class_name;

#define INTERFACE_PROTOCOLAUTOLINK(class_name) \
public: CAutoLink<class_name> QueryProtocolLink() { return  m_autolink##class_name; }

#define INIT_PROTOCOLAUTOLINK(class_name) \
m_autolink##class_name.Init(this)

namespace NDEngine
{

class NDCommonProtocol: public NDObject
{
	DECLARE_CLASS (NDCommonProtocol)

	NDCommonProtocol();
	virtual ~NDCommonProtocol();
	
	DECLARE_PROTOCOLAUTOLINK(NDCommonProtocol)
	INTERFACE_PROTOCOLAUTOLINK(NDCommonProtocol)

public:
	virtual bool CanHorizontalMove(NDObject* object, float& hDistance)
	{
		return true;
	}
	virtual bool CanVerticalMove(NDObject* object, float& vDistance)
	{
		return true;
	}

	virtual void OnScrollViewMove(NDObject* object, float fVertical,
			float fHorizontal)
	{
	}
	virtual void OnScrollViewScrollMoveStop(NDObject* object)
	{
	}
	virtual bool OnClick(NDObject* object)
	{
		return false;
	}

	//edit控件协议
	virtual bool OnEditReturn(NDObject* object)
	{
		return true;
	}
	virtual bool OnEditTextChange(NDObject* object, const char* inputString)
	{
		return true;
	}
};

}

#endif // _ND_COMMON_PROTOCOL_H_

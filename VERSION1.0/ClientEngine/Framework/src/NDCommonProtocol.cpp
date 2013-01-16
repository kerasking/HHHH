/*
 *  NDCommonProtocol.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-15.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDCommonProtocol.h"

namespace NDEngine
{
IMPLEMENT_CLASS(NDCommonProtocol, NDObject)

NDCommonProtocol::NDCommonProtocol()
{
	INIT_PROTOCOLAUTOLINK(NDCommonProtocol);
}

NDCommonProtocol::~NDCommonProtocol()
{
}

}
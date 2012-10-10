/*
 *  FriendElement.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __FRIEND_ELEMENT_H__
#define __FRIEND_ELEMENT_H__

#include "SocialElement.h"

class FriendElement : public SocialElement
{
public:
	FriendElement();
	~FriendElement();
	
	void SetState(ELEMENT_STATE state);
};

#endif
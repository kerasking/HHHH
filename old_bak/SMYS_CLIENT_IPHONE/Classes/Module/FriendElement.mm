/*
 *  FriendElement.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FriendElement.h"

FriendElement::FriendElement()
{
	
}

FriendElement::~FriendElement()
{
	
}

void FriendElement::SetState(ELEMENT_STATE state)
{
	this->m_state = state;
	switch(m_state){
		case ES_ONLINE:{
			this->m_text2 = STRING_ONLINE;
			break;
		}
		case ES_OFFLINE:{
			this->m_text2 = STRING_OFFLINE;
			break;
		}
	}
}
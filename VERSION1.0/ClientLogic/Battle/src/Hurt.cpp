/*
 *  Hurt.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-25.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "Hurt.h"
#include "Fighter.h"

Hurt::Hurt(Fighter* actor, int btType, int hurtHP, int hurtMP, int dwData, HURT_TYPE ht)
{
	this->theActor = actor;
	this->btType = btType;
	this->hurtHP = hurtHP;
	this->hurtMP = hurtMP;
	this->dwData = dwData;
	this->type = ht;
}
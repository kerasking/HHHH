/*
 *  AnimationList.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ANIMATION_LIST_H_
#define _ANIMATION_LIST_H_

#include "Singleton.h"
#include "NDSprite.h"

using namespace NDEngine;

#define AnimationListObj AnimationList::GetSingleton()

class AnimationList : public TSingleton<AnimationList>
{
public:
	AnimationList();
	~AnimationList();
	
	void moveAction(int type, NDSprite* sprite, int face);
	void sitAction(NDSprite* sprite);
	void ridePetMoveAction(int type, NDSprite* sprite, int face);
	void ridePetStandAction(int type, NDSprite* sprite, int face);
	void standPetStandAction(int type, NDSprite* sprite, int face);
	void standPetMoveAction(int type, NDSprite* sprite, int face);
	void setAction(int type, NDSprite* sprite, int face, int aniId);
	void standAction(int type, NDSprite* sprite, int face);
};

#endif // _ANIMATION_LIST_H_

/*
 *  AnimationList.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-12.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "AnimationList.h"
#include "NDConstant.h"
#include "NDSprite.h"

AnimationList::AnimationList()
{
}

AnimationList::~AnimationList()
{
}

void AnimationList::moveAction(int type, NDSprite* sprite, int face)
{

	if (sprite == NULL)
	{
		return;
	}

	if (face == FACE_LEFT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_WALK, false);
	}
	else if (face == FACE_RIGHT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_WALK, true);
	}

//	switch (type)
//	{
//		case TYPE_MANUALROLE:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(MANUELROLE_WALK, false);
//			} 
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(MANUELROLE_WALK, true);
//			}
//			break;
//		case TYPE_ENEMYROLE:
//			if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(MONSTER_MAP_MOVE, false);
//			}
//			else if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(MONSTER_MAP_MOVE, true);
//			}
//			break;
//		case TYPE_RIDEPET:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(RIDEPET_MOVE, false);
//			}
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(RIDEPET_MOVE, true);
//			}
//			break;
//		default:
//			{
//				if (face == FACE_LEFT)
//				{
//					sprite->SetCurrentAnimation(RIDEPET_MOVE, false);
//				} 
//				else if (face == FACE_RIGHT)
//				{
//					sprite->SetCurrentAnimation(RIDEPET_MOVE, true);
//				}
//				break;
//			}
//	}
}

void AnimationList::sitAction(NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	if (face == FACE_LEFT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_SEAT, false);
	} 
	else if (face == FACE_RIGHT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_SEAT, true);
	}
}

void AnimationList::ridePetMoveAction(int type, NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	switch (type)
	{
	case TYPE_MANUALROLE:
		if (face == FACE_LEFT) 
		{
			sprite->SetCurrentAnimation(MANUELROLE_RIDE_WALK, false);
		} 
		else if (face == FACE_RIGHT) 
		{
			sprite->SetCurrentAnimation(MANUELROLE_RIDE_WALK, true);
		}
		break;
	}
}

void AnimationList::ridePetStandAction(int type, NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	switch (type)
	{
	case TYPE_MANUALROLE:
		if (face == FACE_LEFT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_RIDE_STAND, false);
		}
		else if (face == FACE_RIGHT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_RIDE_STAND, true);
		}
		break;
	}
}

void AnimationList::standPetStandAction(int type, NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	switch (type)
	{
	case TYPE_MANUALROLE:
		if (face == FACE_LEFT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_STAND_PET_STAND, false);
		}
		else if (face == FACE_RIGHT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_STAND_PET_STAND, true);
		}
		break;
	}
}

void AnimationList::standPetMoveAction(int type, NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	switch (type)
	{
	case TYPE_MANUALROLE:
		if (face == FACE_LEFT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_STAND_PET_MOVE, false);
		}
		else if (face == FACE_RIGHT)
		{
			sprite->SetCurrentAnimation(MANUELROLE_STAND_PET_MOVE, true);
		}
		break;
	}
}

void AnimationList::setAction(int type, NDSprite* sprite, int face, int aniId)
{
	if (sprite == NULL)
	{
		return;
	}

	if (face == FACE_LEFT)
	{
		sprite->SetCurrentAnimation(aniId, false);
	}
	else if (face == FACE_RIGHT)
	{
		sprite->SetCurrentAnimation(aniId, true);
	}

//	switch (type)
//	{
//		case TYPE_MANUALROLE:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(aniId, false);
//			} 
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(aniId, true);
//			}
//			break;
//	}
}

void AnimationList::standAction(int type, NDSprite* sprite, int face)
{
	if (sprite == NULL)
	{
		return;
	}

	if (face == FACE_LEFT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_STAND, false);
	}
	else if (face == FACE_RIGHT)
	{
		sprite->SetCurrentAnimation(MANUELROLE_STAND, true);
	}

//	switch (type)
//	{
//		case TYPE_MANUALROLE:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(MANUELROLE_STAND, false);
//			}
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(MANUELROLE_STAND, true);
//			}
//			break;
//		case TYPE_ENEMYROLE:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(MONSTER_MAP_STAND, true);
//			} 
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(MONSTER_MAP_STAND, false);
//			}
//			break;
//		case TYPE_RIDEPET:
//			if (face == FACE_LEFT)
//			{
//				sprite->SetCurrentAnimation(RIDEPET_STAND, false);
//			}
//			else if (face == FACE_RIGHT)
//			{
//				sprite->SetCurrentAnimation(RIDEPET_STAND, true);
//			}
//			break;
//	}

}
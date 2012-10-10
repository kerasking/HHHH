/*
 *  NDRidePet.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_RIDE_PET_H_
#define _ND_RIDE_PET_H_

#include "NDSprite.h"


namespace NDEngine
{	/***
	* 临时性注释 郭浩
	* this class
	*/
// 	enum 
// 	{
// 		TYPE_RIDE = 0,//骑马
// 		TYPE_RIDE_BIRD = 1,
// 		TYPE_STAND = 2,
// 		TYPE_RIDE_FLY = 3,
// 		TYPE_RIDE_YFSH= 4,
// 		TYPE_RIDE_QL= 5,
// 	};
	
//	class NDBaseRole;
	

	//class NDRidePet : public NDSprite 
	//{
	//	DECLARE_CLASS(NDRidePet)
	//public:
	//	NDRidePet();
	//	~NDRidePet();
	//	void OnMoving(bool bLastPos); override 
	//public:
	//	//以下方法供逻辑层使用－－－begin
	//	//......	
	//	void Initialization(int lookface); hide
	//	
	//	void WalkToPosition(CGPoint toPos);
	//	
	//	void OnMoveEnd(); override
	//	
	//	void SetPosition(CGPoint newPosition); override
	//	void SetPositionEx(CGPoint pos);
	//	
	//	void OnMoveTurning(bool bXTurnigToY, bool bInc); override
	//	
	//	void SetOwner(NDBaseRole* role);
	//	
	//	bool IsOwnerPlayer();		
	//	//－－－end
	//	
	//	//bool canRide(); ///< 临时性注释 郭浩
	//public:
	//	int iType;
	//	int quality;
	//private:
	//	bool m_bLastPos;
	//private:
	//	CGPoint m_preSetPos;
	//	bool m_bMoveCorner;
	//	bool m_bXTurnigToY;
	//	bool m_bInc;
	//private:
	//	NDBaseRole *owner;
	//};
}

#endif // _ND_RIDE_PET_H_
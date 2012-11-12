#include "NDRidePet.h"
#include "NDConstant.h"
#include "CCPointExtension.h"
//#include "NDBaseRole.h"
#include "EnumDef.h"
//#include "NDPlayer.h"
//#include "NDMapMgr.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDRidePet, NDSprite)
		NDRidePet::NDRidePet()
	{
		iType = TYPE_RIDE;
		quality = 0;
		m_bLastPos = true;
		m_preSetPos = CGPointZero;
		m_bMoveCorner = false;
		m_bXTurnigToY = false;
		m_bInc = false;
		//owner = NULL;
	}

	NDRidePet::~NDRidePet()
	{
	}

	void NDRidePet::OnMoving(bool bLastPos)
	{
		m_bLastPos = bLastPos;
	}

	void NDRidePet::Initialization(int lookface)
	{
		NDSprite::SetNormalAniGroup(lookface);
		int nID = (lookface % 100000) / 10;
		switch (nID) 
		{
		case 2000:
		case 2008:
		case 2009:
			iType = TYPE_STAND;
			break;
		case 2004:
			iType = TYPE_RIDE_FLY;
			break;
		case 2002:
			iType = TYPE_RIDE;
			break;
		case 2003:
			iType = TYPE_RIDE_BIRD;
			break;
		case 2006:
			iType = TYPE_RIDE_YFSH;
			break;
		case 2007:
			iType = TYPE_RIDE_QL;
			break;
		default:
			iType = TYPE_RIDE;
			break;
		}
	}

	void NDRidePet::WalkToPosition(CGPoint toPos)
	{
		//this->SetCurrentAnimation(RIDEPET_MOVE, m_faceRight);
		m_bLastPos = false; 
	}

	void NDRidePet::OnMoveEnd()
	{
		//this->SetCurrentAnimation(RIDEPET_STAND, m_faceRight);
		//m_moving = false;
	}

	void NDRidePet::SetPosition(CGPoint newPosition)
	{
		NDSprite::SetPosition(newPosition);
		return;
		//		if (owner && owner->IsKindOfClass(RUNTIME_CLASS(NDManualRole)))
		//		{
		//			NDManualRole *role = (NDManualRole*)owner;
		//			if (!role->IsInState(USERSTATE_SPEED_UP))
		//			{
		//				NDSprite::SetPosition(newPosition);
		//				m_preSetPos = newPosition;
		//				return;
		//			}
		//		}

		//if (m_bMoveCorner)
		//		{
		//			if (m_bXTurnigToY)
		//			{ 
		//				if (m_bInc)
		//				{ // down
		//					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+8));
		//				}
		//				else
		//				{ // up
		//					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-8));
		//				}
		//			}
		//			else
		//			{
		//				if (m_bInc)
		//				{ // right
		//					NDSprite::SetPosition(ccp(newPosition.x+8,newPosition.y));
		//				}
		//				else
		//				{ // left
		//					NDSprite::SetPosition(ccp(newPosition.x-8,newPosition.y));
		//				}
		//			}
		//
		//			//NDSprite::SetPosition(newPosition);
		//			m_preSetPos = newPosition;
		//			m_bMoveCorner = false;
		//			return;
		//		}
		if(true) //(!m_bLastPos)
		{
			if (m_preSetPos.x == newPosition.x && m_preSetPos.y == newPosition.y)
			{
				NDSprite::SetPosition(newPosition);
			}
			else if (m_preSetPos.x == newPosition.x)
			{
				if (m_preSetPos.y <= newPosition.y)
				{ //down
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y+8));
				}
				else 
				{
					NDSprite::SetPosition(ccp(newPosition.x,newPosition.y-8));
				}
			}
			else if (m_preSetPos.y == newPosition.y)
			{
				//if(!m_faceRight)
				//				{
				//					NDSprite::SetPosition(ccp(newPosition.x-8,newPosition.y));
				//				}
				//				else
				//				{
				//					NDSprite::SetPosition(ccp(newPosition.x+8,newPosition.y));
				//				}
				if (m_preSetPos.x <= newPosition.x)
				{ //right
					NDSprite::SetPosition(ccp(newPosition.x+8,newPosition.y));
				}
				else 
				{
					NDSprite::SetPosition(ccp(newPosition.x-8,newPosition.y));
				}
			}
			else
			{
				NDSprite::SetPosition(newPosition);
			}


			//if (m_faceRight)
			//			{
			//				NDSprite::SetPosition(CGPointMake(newPosition.x+8, newPosition.y));
			//			}
			//			else 
			//			{
			//				NDSprite::SetPosition(CGPointMake(newPosition.x-8, newPosition.y));
			//			}
		}
		else 
		{

			NDSprite::SetPosition(newPosition);
		}

		m_preSetPos = newPosition;
	}

	void NDRidePet::SetPositionEx(CGPoint pos)
	{
		m_preSetPos = pos;
		NDSprite::SetPosition(pos);
	}

	bool NDRidePet::canRide()
	{
		//return NDMapMgrObj.canDrive();
		return false;
	}

	void NDRidePet::OnMoveTurning(bool bXTurnigToY, bool bInc)
	{
		m_bMoveCorner = true;
		m_bXTurnigToY = bXTurnigToY;
		m_bInc = bInc;
	}

// 	void NDRidePet::SetOwner(NDBaseRole* role)
// 	{
// 		owner = role;
// 	}

	bool NDRidePet::IsOwnerPlayer()
	{ 
// 		if(owner && owner->IsKindOfClass(RUNTIME_CLASS(NDPlayer)))
// 		{
// 			return true; 
// 		}

		return false;
	}
}
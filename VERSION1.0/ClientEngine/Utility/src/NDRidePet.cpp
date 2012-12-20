#include "NDRidePet.h"
#include "NDConstant.h"
#include "CCPointExtension.h"
//#include "NDBaseRole.h"
#include "EnumDef.h"
#include "ObjectTracker.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDRidePet, NDSprite)
		NDRidePet::NDRidePet()
	{
		INC_NDOBJ_RTCLS

		iType = TYPE_RIDE;
		quality = 0;
		m_bLastPos = true;
		m_preSetPos = CCPointZero;
		m_bMoveCorner = false;
		m_bXTurnigToY = false;
		m_bInc = false;
		//owner = NULL;
	}

	NDRidePet::~NDRidePet()
	{
		DEC_NDOBJ_RTCLS
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

	void NDRidePet::WalkToPosition(CCPoint toPos)
	{
		//this->SetCurrentAnimation(RIDEPET_MOVE, m_faceRight);
		m_bLastPos = false; 
	}

	void NDRidePet::OnMoveEnd()
	{
		//this->SetCurrentAnimation(RIDEPET_STAND, m_faceRight);
		//m_moving = false;
	}

	void NDRidePet::SetPosition(CCPoint newPosition)
	{
		NDSprite::SetPosition(newPosition);
		return;

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
		}
		else 
		{

			NDSprite::SetPosition(newPosition);
		}

		m_preSetPos = newPosition;
	}

	void NDRidePet::SetPositionEx(CCPoint pos)
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

	bool NDRidePet::IsOwnerPlayer()
	{ 
		return false;
	}
}
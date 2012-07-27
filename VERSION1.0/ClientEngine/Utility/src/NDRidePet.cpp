#include "NDRidePet.h"

namespace NDEngine
{
	NDRidePet::NDRidePet():iType(0),quality(0){}
	NDRidePet::~NDRidePet(){}
	void NDRidePet::Initialization( int lookface ){}
	void NDRidePet::WalkToPosition( CGPoint toPos ){}
	void NDRidePet::OnMoveEnd(){}
	void NDRidePet::SetPosition( CGPoint newPosition ){}
	void NDRidePet::SetPositionEx( CGPoint pos ){}
	void NDRidePet::OnMoveTurning( bool bXTurnigToY, bool bInc ){}
//	void NDRidePet::SetOwner( NDBaseRole* role ){}

	bool NDRidePet::IsOwnerPlayer()
	{
		return true;
	}
}
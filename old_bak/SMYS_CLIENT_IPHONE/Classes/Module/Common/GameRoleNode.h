/*
 *  GameRoleNode.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_ROLE_NODE_H_
#define _GAME_ROLE_NODE_H_

#include "NDUILayer.h"

using namespace NDEngine;

class GameRoleNode : public NDUILayer
{
	DECLARE_CLASS(GameRoleNode)
public:
	GameRoleNode();
	~GameRoleNode();
	
	void Initialization(); override
	void draw(); override
	//设置玩家显示位置,相对于屏幕左上角
	void SetDisplayPos(CGPoint pos);
	
	CGPoint GetPlayerPositionOnMapLayer();
private:
	CGPoint m_playerPostion;
	bool	m_faceRight;
	NDNode	*m_playerParent;
};


#endif // _GAME_ROLE_NODE_H_
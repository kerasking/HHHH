/*
 *  GameRoleNode.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameRoleNode.h"
#include "CGPointExtension.h"
#import "NDPlayer.h"
#import "NDConstant.h"
#include "NDMapMgr.h"

IMPLEMENT_CLASS(GameRoleNode, NDUILayer)

GameRoleNode::GameRoleNode()
{
	m_faceRight = false;
}

GameRoleNode::~GameRoleNode()
{
	NDPlayer& player = NDPlayer::defaultHero();
	
	if (!player.GetParent()) 
	{
		return;
	}
	
	player.RemoveFromParent(false);
	player.SetPositionEx(m_playerPostion);
	//player.SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
	player.OnMoveEnd();
	m_playerParent->AddChild(&player);
	//if (player.battlepet && !player.battlepet->GetParent())
//	{
//		m_playerParent->AddChild(player.battlepet);
//		player.battlepet->SetPosition(player.GetPosition());
//		player.battlepet->m_faceRight = !player.m_faceRight;
//	}
	player.SetAction(false);
	
	if (!player.isTeamLeader() && player.isTeamMember()) 
	{
		NDManualRole *leader = NDMapMgrObj.GetTeamLeader(player.teamId);
		if (leader) leader->SetTeamToLastPos();
	}
	
	player.ResetShowPetPosition();
}

void GameRoleNode::Initialization()
{
	NDUILayer::Initialization();
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->SetTouchEnabled(false);
	
	NDPlayer& player = NDPlayer::defaultHero();
	m_playerParent = player.GetParent();
	player.stopMoving();
	player.BackupPositon();
	m_playerPostion = player.GetPosition();
	m_faceRight = player.m_faceRight;
	
	if (!m_playerParent) 
	{
		NDLog(@"玩家对象没有父结点...");
		return;
	}
	
//	if (player.battlepet && player.battlepet->GetParent())
//	{
//		player.battlepet->RemoveFromParent(false);
//	}
	
	player.RemoveFromParent(false);
	player.SetPositionEx(ccp(0,0));
	player.SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
	this->AddChild(&player);
}

void GameRoleNode::draw()
{
	//glDisableClientState(GL_COLOR_ARRAY);
	if (DrawEnabled())
	{
		NDPlayer& player = NDPlayer::defaultHero();
		player.SetCurrentAnimation(MANUELROLE_STAND, m_faceRight);
		player.RunAnimation(true);
	}
	//glEnableClientState(GL_COLOR_ARRAY);
}

void GameRoleNode::SetDisplayPos(CGPoint pos)
{
	NDPlayer::defaultHero().SetPositionEx(pos);
}

CGPoint GameRoleNode::GetPlayerPositionOnMapLayer()
{
	return m_playerPostion;
}




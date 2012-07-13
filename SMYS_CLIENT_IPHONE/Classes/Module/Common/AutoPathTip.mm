/*
 *  AutoPathTip.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "AutoPathTip.h"
#include "Chat.h"
#include "NDPlayer.h"
#include "NDNpc.h"
#include <sstream>

AutoPathTip::AutoPathTip()
{
	m_bWork = false;
}

AutoPathTip::~AutoPathTip()
{
}

void AutoPathTip::work(std::string des)
{
	std::stringstream ss;
	
	if (m_bWork) 
	{
		
		ss << NDCommonCString("AutoPathTipGo") << "[";
	}
	else
	{
		ss << NDCommonCString("AutoPathTipGo2") << "[";
	}
	
	ss << des << "] ";
	
	//Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
	
	m_des = des;
	
	m_bWork = true;
}

bool AutoPathTip::IsWorking()
{
	return m_bWork;
}

void AutoPathTip::Arrive()
{
	Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("AutoPathTipTo"));
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	NDNpc* npc = player.GetFocusNpc();
	if (npc && npc->GetType() != 6) 
	{
		player.SendNpcInteractionMessage(npc->m_id);
//		if (npc->IsDirectOnTalk()) 
//		{
			//npc朝向修改	
//			if (player.GetPosition().x > npc->GetPosition().x) 
//				npc->DirectRight(true);
//			else 
//				npc->DirectRight(false);
//		}
	}
	
	m_bWork = false;
}

void AutoPathTip::Stop()
{
	//if (m_bWork)
		//Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("AutoPathTipBreak"));
	
	m_bWork = false;
}
/*
 *  AutoPathTip.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-26.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "AutoPathTip.h"
#include "Chat.h"
#include "NDPlayer.h"
#include "NDNpc.h"
#include "globaldef.h"
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
	std::stringstream kStringStream;
	
	if (m_bWork) 
	{
		
		//kStringStream << NDCommonCString("AutoPathTipGo") << "[";
	}
	else
	{
		//kStringStream << NDCommonCString("AutoPathTipGo2") << "[";
	}
	
	kStringStream << des << "] ";
	
	//Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str());
	
	m_strDes = des;
	
	m_bWork = true;
}

bool AutoPathTip::IsWorking()
{
	return m_bWork;
}

void AutoPathTip::Arrive()
{
	//Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("AutoPathTipTo"));
	
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	NDNpc* kNPC = kPlayer.GetFocusNpc();

	if (kNPC && kNPC->GetType() != 6) 
	{
		kPlayer.SendNpcInteractionMessage(kNPC->m_nID);
//		if (npc->IsDirectOnTalk()) 
//		{
			//npc³¯ÏòÐÞ¸Ä	
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
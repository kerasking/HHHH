/*
 *  Drama.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "Drama.h"
#include "ObjectTracker.h"
#include "ScriptGameData_New.h"

#define TAG_DRAMA_UPDATE (1)

Drama::Drama()
{
	INC_NDOBJ("Drama");
}

Drama::~Drama()
{
	DEC_NDOBJ("Drama");

	End();
}

void Drama::Start()
{
	End();

	StartUpdate();
}

void Drama::AddCommond(DramaCommandBase* command)
{
	m_kQueueCommond.push_back(command);
}

void Drama::QuitGame()
{
	End();
}

void Drama::End()
{
	EndUpdate();

	ReleaseQueue(true);
	ReleaseQueue(false);
}

void Drama::StartUpdate()
{
	m_kTimer.SetTimer(this, TAG_DRAMA_UPDATE, 0.04f);
}

void Drama::EndUpdate()
{
	m_kTimer.KillTimer(this, TAG_DRAMA_UPDATE);
}

void Drama::Update()
{
	if (m_kQueueCommondExcute.empty())
	{
		if (!FillExcuteQueue())
		{
			End();
			return;
		}
	}

	if (m_kQueueCommondExcute.empty())
	{
		End();
		return;
	}

	bool bFinish = true;
	for (COMMANDQUE_IT it = m_kQueueCommondExcute.begin();
			it != m_kQueueCommondExcute.end();)
	{
		DramaCommandBase* pkCommand = *it;
		if (!pkCommand)
		{
			continue;
		}

		pkCommand->SetPreCommandsFinish(bFinish);
		pkCommand->excute();
		if (!pkCommand->IsFinish() && bFinish)
		{
			bFinish = false;
		}

		if (pkCommand->IsFinish())
		{
			SAFE_DELETE(pkCommand);
			it = m_kQueueCommondExcute.erase(it);
		}
		else
		{
			it++;
		}
	}

	if (bFinish)
	{
		ReleaseQueue(true);
	}
}

void Drama::OnTimer(OBJID tag)
{
	if (TAG_DRAMA_UPDATE != tag)
	{
		return;
	}

	Update();
}

bool Drama::FillExcuteQueue()
{
	if (m_kQueueCommond.empty())
	{
		return false;
	}

	DramaCommandBase* command = NULL;

	while (0 < m_kQueueCommond.size() && (command = m_kQueueCommond.front()))
	{
		m_kQueueCommondExcute.push_back(command);
		m_kQueueCommond.pop_front();

		if (!command->CanExcuteNextCommand())
		{
			break;
		}
	}

	return true;
}

bool Drama::ReleaseQueue(bool bExcute)
{
	if (bExcute)
	{
		for (COMMANDQUE_IT it = m_kQueueCommondExcute.begin();
				it != m_kQueueCommondExcute.end(); it++)
		{
			DramaCommandBase* command = *it;
			delete command;
		}

		m_kQueueCommondExcute.clear();
	}
	else
	{
		for (COMMANDQUE_IT it = m_kQueueCommond.begin();
				it != m_kQueueCommond.end(); it++)
		{
			DramaCommandBase* command = *it;
			delete command;
		}

		m_kQueueCommond.clear();
	}

	return true;
}

/*
 *  Drama.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "Drama.h"

#define TAG_DRAMA_UPDATE (1)

Drama::Drama()
{
}

Drama::~Drama()
{
	End();
}

void Drama::Start()
{
	End();

	StartUpdate();
}

void Drama::AddCommond(DramaCommandBase* command)
{
	m_queueCommond.push_back(command);
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
	m_timer.SetTimer(this, TAG_DRAMA_UPDATE, 0.04f);
}

void Drama::EndUpdate()
{
	m_timer.KillTimer(this, TAG_DRAMA_UPDATE);
}

void Drama::Update()
{
	if (m_queueCommondExcute.empty())
	{
		if (!FillExcuteQueue())
		{
			End();
			return;
		}
	}

	if (m_queueCommondExcute.empty())
	{
		End();
		return;
	}

	bool bFinish = true;
	for (COMMANDQUE_IT it = m_queueCommondExcute.begin();
			it != m_queueCommondExcute.end();)
	{
		DramaCommandBase* command = *it;
		if (!command)
		{
			continue;
		}

		command->SetPreCommandsFinish(bFinish);
		command->excute();
		if (!command->IsFinish() && bFinish)
		{
			bFinish = false;
		}

		if (command->IsFinish())
		{
			delete command;
			it = m_queueCommondExcute.erase(it);
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
	if (m_queueCommond.empty())
	{
		return false;
	}

	DramaCommandBase* command = NULL;

	while (0 < m_queueCommond.size() && (command = m_queueCommond.front()))
	{
		m_queueCommondExcute.push_back(command);
		m_queueCommond.pop_front();

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
		for (COMMANDQUE_IT it = m_queueCommondExcute.begin();
				it != m_queueCommondExcute.end(); it++)
		{
			DramaCommandBase* command = *it;
			delete command;
		}

		m_queueCommondExcute.clear();
	}
	else
	{
		for (COMMANDQUE_IT it = m_queueCommond.begin();
				it != m_queueCommond.end(); it++)
		{
			DramaCommandBase* command = *it;
			delete command;
		}

		m_queueCommond.clear();
	}

	return true;
}

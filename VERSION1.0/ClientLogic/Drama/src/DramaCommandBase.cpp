/*
 *  DramaCommandBase.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "DramaCommandBase.h"
#include "ObjectTracker.h"

unsigned int DramaCommandBase::m_uiKeyGenerator = 0;

ID_VEC DramaCommandBase::m_vIdRecyle;

DramaCommandBase::DramaCommandBase()
{
	INC_NDOBJ("DramaCommandBase");

	m_bFinish = false;
	m_bCanExcuteNextCommand = true;
	m_bPreCommandsFinish = true;
}

DramaCommandBase::~DramaCommandBase()
{
	DEC_NDOBJ("DramaCommandBase");
}

bool DramaCommandBase::IsFinish()
{
	return m_bFinish;
}

void DramaCommandBase::SetFinish(bool bFinish)
{
	m_bFinish = bFinish;
}

bool DramaCommandBase::CanExcuteNextCommand()
{
	return m_bCanExcuteNextCommand;
}

void DramaCommandBase::SetCanExcuteNextCommand(bool bCan)
{
	m_bCanExcuteNextCommand = bCan;
}

void DramaCommandBase::SetPreCommandsFinish(bool bSet)
{
	m_bPreCommandsFinish = bSet;
}

bool DramaCommandBase::IsPreCommandsFinish()
{
	return m_bPreCommandsFinish;
}

unsigned int DramaCommandBase::AllocKey()
{
	if (m_vIdRecyle.size() > 0)
	{
		int nKey = m_vIdRecyle.back();
		m_vIdRecyle.erase(m_vIdRecyle.end() - 1);
		return nKey;
	}

	return ++m_uiKeyGenerator;
}

void DramaCommandBase::DeAllocKey(unsigned int nKey)
{
	m_vIdRecyle.push_back(nKey);
}

unsigned int DramaCommandBase::GetKey()
{
	return m_kParam.nKey;
}

void DramaCommandBase::ResetKeyAlloc()
{
	m_vIdRecyle.clear();
	m_uiKeyGenerator = 0;
}

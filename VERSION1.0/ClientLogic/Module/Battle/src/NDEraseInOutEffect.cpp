/*
 *  NDEraseInOutEffect.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-19.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDEraseInOutEffect.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "NDUIBaseGraphics.h"

#define timer_tag (126482)

IMPLEMENT_CLASS(NDEraseInOutEffect, NDUINode)

NDEraseInOutEffect::NDEraseInOutEffect()
{
	INIT_AUTOLINK(NDEraseInOutEffect);
	
	m_timer = NULL;
	
	inCount = 0;
	
	outCount = 0;
	
	state = eStateStop;
}

NDEraseInOutEffect::~NDEraseInOutEffect()
{
	if (m_timer) {
		m_timer->KillTimer(this, timer_tag);
		delete m_timer;
	}
	
	NDDirector::DefaultDirector()->EnableDispatchEvent(true);
}

void NDEraseInOutEffect::StartEraseOut()
{
	if (!m_timer)
	{
		m_timer = new NDTimer;
	
		m_timer->SetTimer(this, timer_tag, 0.05f);
	}
	
	if (!this->GetParent())
		NDDirector::DefaultDirector()->GetRunningScene()->AddChild(this, 20000);

	state = eStateEraseOut;
}

void NDEraseInOutEffect::StartEraseIn()
{
	if (!m_timer)
	{
		m_timer = new NDTimer;
		
		m_timer->SetTimer(this, timer_tag, 0.05f);
	}
	
	if (!this->GetParent())
		NDDirector::DefaultDirector()->GetRunningScene()->AddChild(this, 20000);
		
	NDDirector::DefaultDirector()->EnableDispatchEvent(false);
	
	state = eStateEraseIn;
}

bool NDEraseInOutEffect::isChangeComplete() {
	return state == eStateStop;
}

bool NDEraseInOutEffect::IsInStateEraseIn() {
	return state == eStateEraseIn;
}

bool NDEraseInOutEffect::IsInStateEraseOut()
{
	return state == eStateEraseOut;
}

void NDEraseInOutEffect::OnTimer(OBJID tag)
{
	if (state == eStateEraseIn)
	{
		refreshScreenIn();
	}
	else if (state == eStateEraseOut)
	{
		refreshScreenOut();
	}
	else if (state == eStateStop)
	{
		this->RemoveFromParent(false);
		
		if (m_timer) 
		{
			m_timer->KillTimer(this, timer_tag);
			delete m_timer;
			m_timer = NULL;
		}
	}
}

void NDEraseInOutEffect::draw()
{
	NDUINode::draw();
	if (state == eStateEraseIn)
	{
		drawScreenIn();
	}
	else if (state == eStateEraseOut)
	{
		drawScreenOut();
	}
}

void NDEraseInOutEffect::drawScreenIn() {
	// TODO Auto-generated method stub
	CGSize size = NDDirector::DefaultDirector()->GetWinSize();
	
	for (int i = 0; i < 50 - inCount; i++) {
		for (int j = 0; j < 50 - inCount; j++) {
			DrawRecttangle(CGRectMake(size.width - (i << 4) - ((33 - inCount - i - j) >> 1), size.height - (j << 4) - ((33 - inCount - i - j) >> 1), 40 - inCount - i - j, 40 - inCount - i - j),
						    ccc4(0, 0, 0, 255));
		}
	}
}

void NDEraseInOutEffect::drawScreenOut() {
	// TODO Auto-generated method stub
//	g.setColor(0);
//	g.setClip(0, 0, getScreenWidth(), getScreenHeight());
	for (int i = 0; i < outCount; i++) {
		for (int j = 0; j < outCount; j++) {
			DrawRecttangle(CGRectMake((i << 4) - ((outCount - i - j) >> 1), (j << 4) - ((outCount - i - j) >> 1), (outCount - i - j), (outCount - i - j)),
						   ccc4(0, 0, 0, 255));
		}
	}
}

void NDEraseInOutEffect::refreshScreenIn() {
	// TODO Auto-generated method stub
	inCount += 4;
	if (inCount >= 33) {
		//setChangeComplete(true);
		reset();
	}
	
}

void NDEraseInOutEffect::refreshScreenOut() {
	// TODO Auto-generated method stub
	outCount += 4;
	if (outCount >= 33) {
		//setChangeComplete(true);
		reset();
	}
}

void NDEraseInOutEffect::reset()
{
	state = eStateStop;
	inCount = 0;
	outCount = 0;
	
	NDDirector::DefaultDirector()->EnableDispatchEvent(true);
}
/*
 *  NDUITimeStateBar.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUITimeStateBar.h"
#include <sstream>

IMPLEMENT_CLASS(NDUITimeStateBar, NDUIStateBar)

NDUITimeStateBar::NDUITimeStateBar()
{
	m_restime = 0;
	m_totaltime = 0;
	
	m_timer = NULL;
	
	m_begintime = 0.0f;
	
	m_bFinish = false;
	
	m_strFinish = "";
	
	m_stateFinishColor = INTCOLORTOCCC4(0xf79c0c);
	m_slideFinishColor = INTCOLORTOCCC4(0xf8cf42);
}

NDUITimeStateBar::~NDUITimeStateBar()
{
	delete m_timer;
}

void NDUITimeStateBar::Initialization()
{
	NDUIStateBar::Initialization();
	this->SetStateColor(INTCOLORTOCCC4(0x0320f6));
	this->SetSlideColor(INTCOLORTOCCC4(0x4258fd));
}

void NDUITimeStateBar::SetTime(unsigned long rest, unsigned long total)
{
	if (!m_timer) 
	{
		m_timer = new NDTimer;
		m_timer->SetTimer(this, 1010, 1.0f);
	}
	
	m_restime = rest;
	m_totaltime = total;
	m_bFinish = false;
	m_begintime = [NSDate timeIntervalSinceReferenceDate];
	
	OnTimer(0);
}

void NDUITimeStateBar::OnTimer(OBJID tag)
{
	NDUILayer::OnTimer(tag);
	
	if (!(tag == 1010 || tag == 0)) return;
	
	int rest = (int) (m_restime - ([NSDate timeIntervalSinceReferenceDate] - m_begintime));
	if (rest < 0) {
		rest = 0;
	}
	
	int percent= m_totaltime == 0 ? 0 : ((int) ((m_totaltime-rest)*100/m_totaltime));
	
	this->SetPercent(percent);
	
	std::stringstream sb;
	if (m_restime >= 3600) {
		int h = rest / 3600;
		if (h > 9) {
			sb << h << ":";
		} else {
			sb << "0" << h << ":";
		}
	} else {
		sb << ("00:");
	}
	
	if (rest >= 60) {
		int m = (rest % 3600) / 60;
		if (m > 9) {
			sb << m << ":";
		} else {
			sb << "0" << m << ":";
		}
	} else {
		sb << "00:";
	}
	
	int s = rest % 60;
	if (s > 9) {
		sb << (s);
	} else {
		sb << "0" << s;
	}
	
	if(rest<=0){
		m_bFinish=true;
		m_timer->KillTimer(this, 1010);
		delete m_timer;
		m_timer = NULL;

		NDUITimeStateBarDelegate* delegate = dynamic_cast<NDUITimeStateBarDelegate*> (this->GetDelegate());
		if (delegate) 
		{
			delegate->OnTimeStateBarFinish(this);
		}
	}
	
	this->SetLabel(!m_bFinish || m_strFinish.empty() ? sb.str() : m_strFinish, ccc4(255, 255, 255, 255));
	
	if (m_bFinish) SetNormalColors(m_stateFinishColor, m_slideFinishColor);
}

void NDUITimeStateBar::SetFinishText(std::string text)
{
	m_strFinish = text;
	if (m_bFinish) 
	{
		this->SetLabel(text, ccc4(0, 0, 0, 255));
	}
}

void NDUITimeStateBar::ReduceRestTime(unsigned long add)
{
	if (m_restime < add) {
		m_restime = 0;
	}
	else 
	{
		m_restime -= add;
	}
}

void NDUITimeStateBar::SetNormalColors(ccColor4B stateColor, ccColor4B slideColor)
{
	this->SetStateColor(stateColor);
	this->SetSlideColor(slideColor);
}

void NDUITimeStateBar::SetFinishColors(ccColor4B stateColor, ccColor4B slideColor)
{
	m_stateFinishColor = stateColor;
	m_slideFinishColor = slideColor;
}



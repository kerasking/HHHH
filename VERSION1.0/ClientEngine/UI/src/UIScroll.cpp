/*
 *  UIScroll.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIScroll.h"
#include "NDDirector.h"

float UI_ACCER_FIRST = -100.0f;

float UI_POSI_UP_SPEED_MIN = 10.0f;
float UI_NEGA_UP_SPEED_MIN = -10.0f;
float UI_POSI_UP_SPEED_MAX = 1000.0f;
float UI_NEGA_UP_SPEED_MAX = -1000.0f;

IMPLEMENT_CLASS(CUIScroll, CUIMovableLayer)

CUIScroll::CUIScroll()
{
	m_style = UIScrollStyleVerical;
	
	m_bAccerate = false;
	
	ResetMoveData();
	
	UI_ACCER_FIRST = -40.0f * NDDirector::DefaultDirector()->GetScaleFactor();
	
	UI_POSI_UP_SPEED_MIN = 300.0f * NDDirector::DefaultDirector()->GetScaleFactor();
	UI_NEGA_UP_SPEED_MIN = -300.0f * NDDirector::DefaultDirector()->GetScaleFactor();
	UI_POSI_UP_SPEED_MAX = 800.0f * NDDirector::DefaultDirector()->GetScaleFactor();
	UI_NEGA_UP_SPEED_MAX = -800.0f * NDDirector::DefaultDirector()->GetScaleFactor();
//	m_bTouchDown				= false;
}

CUIScroll::~CUIScroll()
{
}

void CUIScroll::Initialization(bool bAccerate/*=false*/)
{
	CUIMovableLayer::Initialization();
	
	m_bAccerate = bAccerate;
}

void CUIScroll::SetScrollStyle(int style)
{
	if (style < UIScrollStyleBegin || style >= UIScrollStyleEnd )
	{
		return;
	}
	m_style = (UIScrollStyle)style;
}

bool CUIScroll::IsCanAccerate()
{
	return m_bAccerate;
}

bool CUIScroll::IsInAccceratState()
{
	return (this->m_nState > STATE_BEGIN) && 
		   (this->m_nState < STATE_END);
}

void CUIScroll::StopAccerate()
{
	SwitchStateTo(STATE_STOP);
}

UIScrollStyle CUIScroll::GetScrollStyle()
{
	return m_style;
}

void CUIScroll::SetContainer(NDUILayer* layer)
{
	if (!layer)
	{
		return;
	}
	
	m_linkContainer = layer->QueryLink();
}

void CUIScroll::draw()
{
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	if (IsCanAccerate() &&
		IsInAccceratState()) 
	{
		if ( !(UIScrollStyleHorzontal == m_style ||
			   UIScrollStyleVerical == m_style) )
		{
			SwitchStateTo(STATE_STOP);
			return;
		}
		
		if (m_bMoveInfoEmpty)
		{
			SwitchStateTo(STATE_STOP);
		}
		
		float  fDistance = GetMoveDistance();
		if (fDistance < 0.5f /** NDDirector::DefaultDirector()->GetScaleFactor()*/ && 
			fDistance > -0.5f /* NDDirector::DefaultDirector()->GetScaleFactor()*/)
		{
			SwitchStateTo(STATE_STOP);
		}
		
		CCRect rect = this->GetFrameRect();
		
		if (UIScrollStyleHorzontal == m_style)
		{
			if (!CanHorizontalMove(fDistance))
			{
				SwitchStateTo(STATE_STOP);
			}
            else if (CompareEqualFloat(fDistance, 0.0f))
            {
                SwitchStateTo(STATE_STOP);
            }
			else if (OnHorizontalMove(fDistance))
			{
				rect.origin.x += fDistance;
				this->SetFrameRect(rect);
			}
		}
		else if (UIScrollStyleVerical == m_style)
		{
			if (!CanVerticalMove(fDistance))
			{
				SwitchStateTo(STATE_STOP);
			}
			else if (OnVerticalMove(fDistance))
			{
				rect.origin.y += fDistance;
				this->SetFrameRect(rect);
			}
		}
		
		if (!IsInAccceratState())
		{
			OnMoveStop();
		}
	}
	
	CUIMovableLayer::draw();
}

bool CUIScroll::TouchBegin(NDTouch* touch)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	if (m_linkContainer &&
		!cocos2d::CCRect::CCRectContainsPoint(m_linkContainer->GetScreenRect(), touch->GetLocation()))
	{
		return false;
	}
	
	if (CUIMovableLayer::TouchBegin(touch)) 
	{
		ResetMove();
		
		if (IsCanAccerate())
		{
			OnMoveStop();
		}
		
       // UIMoveInfo info(touch->GetLocation(), [NSDate timeIntervalSinceReferenceDate]);
       // PushMove(info);
        
		return true;
	}
	
	return false;
}

bool CUIScroll::TouchEnd(NDTouch* touch)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	bool bRet = CUIMovableLayer::TouchEnd(touch);
	
	m_bUp = true;
	
	return true;
}

void CUIScroll::ResetMoveData()
{
	m_nState				= STATE_STOP;
	m_uiCurMoveIndex		= 0;
	m_uiFirstMoveIndex		= 0;
	//m_clockT0				= 0.0f;
	m_fV0					= 0.0f;
	m_fOldS					= 0.0f;
	m_bMoveInfoEmpty		= true;
	m_bUp					= false;
}

void CUIScroll::ResetMove()
{
	ResetMoveData();
}

void CUIScroll::SwitchStateTo(int nToState)
{
	if (nToState < STATE_BEGIN || nToState >= STATE_END)
	{
		return;
	}
	
	m_nState = nToState;
	
	switch(nToState)
	{
		case STATE_STOP:
			break;
		case STATE_FIRST:
			SetMoveParam();
			break;
		case STATE_SECOND:
			break;
		case STATE_THREE:
			break;
		default:
			break;
			
	}
}

void CUIScroll::SetMoveSpeed()
{
	if (m_bMoveInfoEmpty)
	{
		return;
	}
	
	unsigned int size = 0;
	if (m_uiCurMoveIndex > m_uiFirstMoveIndex)
	{
		size = m_uiCurMoveIndex - m_uiFirstMoveIndex;
	}
	else
	{
		size = m_uiCurMoveIndex + MAX_MOVES - m_uiFirstMoveIndex;
	}
	size = size > MAX_MOVES ? MAX_MOVES : size;
	
	double fSum = 0.0f;
	unsigned int uiTotal = 0;
	printf("size[%d]", size);
    float fMin = 100000.0f;
	for (unsigned int i = 0; i < size - 1; i++) 
	{
		unsigned int firstindex		= (m_uiFirstMoveIndex + i) % MAX_MOVES;
		unsigned int secondindex	= (firstindex + 1) % MAX_MOVES;
		
		double dispass		= 0.0f;
		if (UIScrollStyleVerical == m_style)
		{
			dispass = m_moveInfos[secondindex].pos.y - m_moveInfos[firstindex].pos.y;
		}
		else
		{
			dispass = m_moveInfos[secondindex].pos.x - m_moveInfos[firstindex].pos.x;
		}
		double clockpass	= ClockTimeMinus(m_moveInfos[secondindex].time, m_moveInfos[firstindex].time);
        double fV   = dispass / clockpass;
        if (fabs(fV) < fabs(fMin))
        {
            fMin    = fV;
            printf("fMin=[%f]", fMin);
        }
		printf("\ndis=[%f]time=[%f]v=[%f]", dispass, clockpass, fV);
		if (clockpass != 0)
		{
			fSum += dispass / clockpass;
			uiTotal ++;
		}
	}
    
	if (uiTotal == 0) 
	{
		m_bMoveInfoEmpty = true;
		return;
	}
	
	this->m_fV0 = fMin;
    
    if (size <= 3)
    {
        if  (m_fV0 > 0.0f)
        {
            m_fV0 = UI_POSI_UP_SPEED_MAX;
        }
        
        if  (m_fV0 < 0.0f)
        {
            m_fV0 = UI_NEGA_UP_SPEED_MAX;
        }
    }

    printf("\nvo=[%f]", this->m_fV0);
	
	if ( (this->m_fV0 < UI_POSI_UP_SPEED_MIN) && 
		(this->m_fV0 > UI_NEGA_UP_SPEED_MIN) )
	{
		m_bMoveInfoEmpty = true;
		return;
	}
	if (m_fV0 > UI_POSI_UP_SPEED_MAX)
	{
		m_fV0 = UI_POSI_UP_SPEED_MAX;
	}
	else if (m_fV0 < UI_NEGA_UP_SPEED_MAX)
	{
		m_fV0 = UI_NEGA_UP_SPEED_MAX;
	}
	
	//m_clockT0 = [NSDate timeIntervalSinceReferenceDate];
}

void CUIScroll::SetMoveParam()
{
	SetMoveSpeed();
}

float CUIScroll::GetMoveDistance()
{
	if (m_bMoveInfoEmpty)
	{
		return 0.0f;
	}
	
	double clockpass	= 0; //todo(zjh)(ClockTimeMinus([NSDate timeIntervalSinceReferenceDate], m_clockT0));
	
	float fAccer = UI_ACCER_FIRST;
	
	if (m_fV0 < 0.0f)
	{
		fAccer = -fAccer;
	}
	
	if (this->m_fV0 < 0.0f)
	{
		if (-fAccer * clockpass < this->m_fV0)
		{
			//clockpass = -this->m_fV0 / fAccer;
			return 0.0f;
		}
	}
	else
	{	
		if (-fAccer * clockpass > this->m_fV0)
		{
			//clockpass = -this->m_fV0 / fAccer;
			return 0.0f;
		}
	}
	
	double s = this->m_fV0 * clockpass + fAccer * (clockpass * clockpass) / 2.0f;
	
	float fRet = s - m_fOldS;
	
    printf("old[%f]new[%f]ret[%f]", m_fOldS, s, fRet);
    
	m_fOldS = s;
    
	return fRet;
}

void CUIScroll::PushMove(UIMoveInfo& move)
{
	if (m_uiCurMoveIndex == m_uiFirstMoveIndex && !m_bMoveInfoEmpty)
	{
		m_uiFirstMoveIndex = ++m_uiFirstMoveIndex % MAX_MOVES;
	}
	
	m_moveInfos[m_uiCurMoveIndex].pos	= move.pos;
	m_moveInfos[m_uiCurMoveIndex].time	= move.time;
	
	m_uiCurMoveIndex = ++m_uiCurMoveIndex % MAX_MOVES;
	
	m_bMoveInfoEmpty = false;
}

double CUIScroll::ClockTimeMinus(double sec, double fir)
{
  
    printf("cl[%f], cl2[%f]", sec, fir);
    /*
	clock_t clockret = 0;
	if (sec < fir)
	{
		clockret = ((unsigned long long)1 << (sizeof(clock_t) * 8)) - fir + sec;
	}
	else
	{
		clockret = sec - fir;
	}
	return clockret;
    */
    
    return (sec - fir);
}

bool CUIScroll::CanHorizontalMove(float& hDistance)
{
	if (m_style != UIScrollStyleHorzontal)
	{
		return false;
	}
	
	return CUIMovableLayer::CanHorizontalMove(hDistance);
}

bool CUIScroll::CanVerticalMove(float& vDistance)
{
	if (m_style != UIScrollStyleVerical)
	{
		return false;
	}
	
	return CUIMovableLayer::CanVerticalMove(vDistance);
}

bool CUIScroll::OnLayerMoveOfDistance(NDUILayer* uiLayer, float hDistance, float vDistance)
{
	if (uiLayer != this)
	{
		return false;
	}
	
	bool bRet = CUIMovableLayer::OnLayerMoveOfDistance(uiLayer, hDistance, vDistance);
	if (bRet && IsCanAccerate())
	{
		OnMove();
	}
	
	if (m_bUp && !IsCanAccerate())
	{
		OnMoveStop();
	}
	
	return bRet;
}

void CUIScroll::OnMove()
{
	//UIMoveInfo info(m_moveTouch, [NSDate timeIntervalSinceReferenceDate]);
	//PushMove(info);
	
	if (m_bUp) 
	{
		SwitchStateTo(STATE_FIRST);
	}
}
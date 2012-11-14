#include "time.h"
#include "SysTimer.h"
#include <stdio.h>
#include "I_Analyst.h"
#include "CCStdC.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <WinSock2.h>
#endif

// Low-resolution ticks value of the application
static struct timeval ticks_start;
static bool s_bInit = false;
#define MAX(A,B)	((A) > (B) ? (A) : (B))

void Sys_TickInit()
{
    gettimeofday( &ticks_start, NULL);
    s_bInit = true;
}

DWORD Sys_GetTicks()
{
    if(!s_bInit) {
        Sys_TickInit();
    }
	float ticks = 0.f;
    struct timeval now;
    gettimeofday( &now, NULL);

    ticks = (now.tv_sec - ticks_start.tv_sec)*10000 + (now.tv_usec - ticks_start.tv_usec) / 100.0f;
    ticks = MAX(0,ticks);

	return ticks;
}

DWORD Sys_TicksToMS(DWORD ticks)
{
	// Low resolution is ms already.
	return ticks;
}

DWORD Sys_Milliseconds()
{
	return Sys_GetTicks();
}

CTickAnalyst::CTickAnalyst(int nIdx)
{
	_analystIdx = nIdx;
	this->Start(); 
}

CTickAnalyst::~CTickAnalyst()
{
	this->Finish();
	Analyst()->TicksAdd(_analystIdx, GetUsedTicks());
}

void CTickAnalyst::Start()
{
	_tickStart = Sys_GetTicks(); 
}

void CTickAnalyst::Finish()
{
	_tickEnd	 = Sys_GetTicks(); 
}

int	CTickAnalyst::GetUsedTicks()
{
	return (_tickEnd - _tickStart); 
}

int	CTickAnalyst::GetUsedMS()
{
	return Sys_TicksToMS(GetUsedTicks()); 
}

void CTickCount::Start()
{ 
	tick_start = Sys_GetTicks(); 
}

void CTickCount::Finish()
{
	tick_end = Sys_GetTicks();
}

int CTickCount::GetUsedTicks()
{
	return (tick_end - tick_start);
}

int	CTickCount::GetUsedMS()
{
	return Sys_TicksToMS(GetUsedTicks()); 
}

//	SysTimer.h
//

#ifndef _Sys_Timer_H_
#define _Sys_Timer_H_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#include "I_Analyst.h"
#include "BaseType.h"

void	Sys_TickInit();
unsigned int	Sys_GetTicks();
unsigned int	Sys_TicksToMS(unsigned int ticks);
unsigned int	Sys_Milliseconds();				// Get the milliseconds from init

// helper


#endif //_Sys_Timer_H_
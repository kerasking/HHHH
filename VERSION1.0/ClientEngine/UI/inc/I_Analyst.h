#ifndef _I_ANALYST_H
#define _I_ANALYST_H

#include "BaseType.h"
#include "Analyst.h"
#include "AnalystType.h"

//////////////////////////////////////////////////////////////////////////
#define	TICK_ANALYST(x)		
//CTickAnalyst _analyst##x(x)

class CTickAnalyst
{
public:
	CTickAnalyst(int nIdx);
	~CTickAnalyst();		
public:
	void	Start();
	void	Finish();
	int		GetUsedTicks();
	int		GetUsedMS();
private:
	DWORD	_tickStart;
	DWORD	_tickEnd;
	int		_analystIdx;
	
};

class CTickCount
{
public:
	void	Start();		
	void	Finish();		
	int		GetUsedTicks();	
	int		GetUsedMS();	
private:
	DWORD	tick_start;
	DWORD	tick_end;
};

extern CAnalyst* Analyst();


#endif
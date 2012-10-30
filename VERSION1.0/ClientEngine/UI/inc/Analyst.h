//	Analyst.h
//

#ifndef _Analyst_H_
#define _Analyst_H_


#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

//////////////////////////////////////////////////////////////////////////
const int ANALYST_LOGTIMER		= 1*60*1000;	//多久统计一次

const int ANALYST_MASK_INVALID	= 0;		//无效
const int ANALYST_MASK_TICKS	= 1;		//统计ticks消耗
const int ANALYST_MASK_SIZE		= 2;		//统计size/bytes
//const int ANALYST_MASK_AMOUNT	= 4;		//统计数量

//////////////////////////////////////////////////////////////////////////
class CAnalyst
{
public:
	bool	AnalystAdd(int idx, int mask, const char* name);
	void    OnTimer();

public:
	void	TicksAdd	(int idx, int ticks);
	void	SizeAdd		(int idx, int size);
	//void	AmountAdd	(int idx, int nAmount);

public:		//按name索引，消耗会大一些
	void	TicksAdd	(const char* szKey, int ticks);

public:
	bool	GetInfoByIdx(int idx, long* total_ticks, long* max_ticks, long* amount);
	bool	GetInfoByName(const char* key, long* total_ticks, long* max_ticks, long* amount);
	int		GetAllTotalTicks() { return m_nTotalTicks; }
public:
	void			ReStart();				// Clear all history
	void			LogToDisk();			// Log to disk
protected:
	bool			Create();
public:
	~CAnalyst();
	static CAnalyst*		Instance();
private:
	CAnalyst();
	static void CreateInstance();
	static CAnalyst*	s_pInstance;
	int		m_nTotalTicks;
};

inline CAnalyst*	Analyst()	{ return CAnalyst::Instance(); }

#endif //_Analyst_H_

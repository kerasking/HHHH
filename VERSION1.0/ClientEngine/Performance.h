/*
 *  Performance.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-10-11.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef _PERFORMANCE_H_
#define _PERFORMANCE_H_

#include "Singleton.h"
#include "GlobalDialog.h"
#include <string>
#include <stdio.h>
#include <map>

#ifdef VIEW_PERFORMACE
#define PerformanceEnable \
	PerformanceTest.StartPerformanceTest()

#define PerformanceDisable \
	PerformanceTest.EndPerformanceTest()

#define PerformanceStart \
	PerformanceTest.StartFrame()

#define PerformanceEnd \
	PerformanceTest.EndFrame()

#define PerformanceSave \
	PerformanceTest.Save()

#define PerformanceTestFunc \
	NDPerformance::CPerformanceTestHelper CPerformanceTestHelper_help(__func__)

#define PerformanceTestName(name) \
	NDPerformance::CPerformanceTestHelper CPerformanceTestHelper_help(name)

#define PerformanceTestPerFrameFunc \
	NDPerformance::CPerformanceTestFrameHelper CPerformanceTestFrameHelper_help(__func__)

#define PerformanceTestPerFrameName(name) \
	NDPerformance::CPerformanceTestFrameHelper CPerformanceTestFrameHelper_help(name)

#define PerformanceTestBeginName(name) \
	do{ \
	NDPerformance::key64 tmp; \
	PerformanceTest.BeginTestModule(name, tmp)

#define PerformanceTestEndName(name) \
	if (tmp.valid()) \
	PerformanceTest.EndTestModule(tmp); \
	}while(0)

#define PerformanceTestPerFrameBeginName(name) \
	do{ \
	NDPerformance::key64 tmp; \
	PerformanceTest.BeginTestModule(name, tmp, true)

#define PerformanceTestPerFrameEndName(name) \
	if (tmp.valid()) \
	PerformanceTest.EndTestModule(tmp); \
	}while(0)
#else

#define PerformanceEnable

#define PerformanceDisable

#define PerformanceStart

#define PerformanceEnd

#define PerformanceSave

#define PerformanceTestFunc

#define PerformanceTestName(name)

#define PerformanceTestPerFrameFunc

#define PerformanceTestPerFrameName(name)

#define	PerformanceTestBeginName(name)
#define PerformanceTestEndName(name)

#define PerformanceTestPerFrameBeginName(name)
#define PerformanceTestPerFrameEndName(name)
#endif

namespace NDPerformance
{

#define invalid_key ((KEY)0)

typedef unsigned int KEY;
typedef std::string VALUE;

struct performance_data
{
	double consume;
	bool finish;
	bool perframe;
	bool clear;
	performance_data()
	{
		memset(this, 0, sizeof(*this));
	}
};

struct key64
{
	KEY keyHigh, keyLow;

	key64()
	{
		memset(this, 0, sizeof(*this));
	}

	key64(KEY high, KEY low)
	{
		keyHigh = high;
		keyLow = low;
	}

	bool operator==(const key64& rhl) const
	{
		return keyHigh == rhl.keyHigh && keyLow == rhl.keyLow;
	}

	bool valid()
	{
		return !(keyHigh == invalid_key || keyLow == invalid_key );
	}

	bool operator <(const key64& rhl) const
	{
		if (keyHigh < rhl.keyHigh)
			return true;
		else if (keyHigh == rhl.keyHigh)
			return keyLow < rhl.keyLow;
		return false;
	}
};

struct time_cacl
{
	double start;
	time_cacl()
	{
		start = 0.0f;
	}
};

class CPerformanceTest: public TSingleton<CPerformanceTest>
{
public:
	CPerformanceTest();
	~CPerformanceTest();

	bool StartPerformanceTest();
	bool EndPerformanceTest();
	bool StartFrame();
	bool EndFrame();
	bool Save();
	void LogOutConsole();

	bool BeginTestModule(const char *name, key64& key, bool flagFrame = false);
	bool EndTestModule(key64& key);

	bool m_bStart;
	bool m_bStartFrameTest;
	std::map<key64, performance_data> m_mapData;
	std::map<VALUE, KEY> m_keyCache;
	CIDFactory m_keyMain, m_keyHelp;
	std::map<key64, time_cacl> m_cacl;
private:
	void Output();
	void Output(FILE* f);
	void AverageOutput(FILE* f);

	KEY GetMainKey(VALUE name);
	KEY GetHelpKey();

	void Clear();
	bool IsStart();

	bool dealPerFrame();
};

//--------------------------------------------------------------

class CPerformanceTestHelper
{
public:
	CPerformanceTestHelper(const char* arg);
	~CPerformanceTestHelper();
private:
	key64 m_key;
};

class CPerformanceTestFrameHelper
{
public:
	CPerformanceTestFrameHelper(const char* arg);
	~CPerformanceTestFrameHelper();
private:
	key64 m_key;
};

#ifdef VIEW_PERFORMACE	
#define PerformanceTest \
	NDPerformance::CPerformanceTest::GetSingleton()
#else
#define PerformanceTest
#endif
}

#endif
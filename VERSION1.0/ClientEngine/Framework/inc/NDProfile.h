//-------------------------------------------------------------------------
//  NDProfile.h
//
//  Created by zhangwq on 22012-11-05.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	功能：性能调优（消耗时间片跟踪）
//-------------------------------------------------------------------------

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <windows.h>
#include <NDConsole.h>
#endif
#include <map>
#include <vector>
#include "ScriptDefine.h"
#include "platform.h"

NS_NDENGINE_BGN

using namespace std;

///////////////////////////////////////////////////
struct TimeSlice
{
private:
	TimeSlice();

public:
	TimeSlice(const string& _name)
		: name(_name)
		, parent(NULL) {
            CCTime::gettimeofdayCocos2d(&beginTime, NULL);
            endTime.tv_sec = 0;
            endTime.tv_usec = 0;
        }

	string	name;
	struct cc_timeval	beginTime;
	struct cc_timeval	endTime;
	TimeSlice* parent;

	double getTick() { return (endTime.tv_sec > 0) ? CCTime::timersubCocos2d(&beginTime, &endTime) : 999999; }

	string getTimeStr() {
		char str[100] = "";
		double t = getTick();
		if (t >= 1000) {
			sprintf( str, "%.2f (s)", t / 1000.f );
		}
		else {   
			sprintf( str, "%.0f (ms)", t );
		}
		return str;
	}

	int getParentCount() const {
		int cnt = 0;
		TimeSlice* p = parent;
		while (p) {
			cnt++; p = p->parent;
		}
		return cnt;
	}
};


///////////////////////////////////////////////////
struct NDProfileData
{
public:
	NDProfileData()
	{
		vecTimeSlice.reserve(50);
	}

	~NDProfileData()
	{
		for (vector<TimeSlice*>::iterator it = vecTimeSlice.begin();
				it != vecTimeSlice.end(); ++it)
		{
			delete *it;
		}
		vecTimeSlice.clear();
		mapTimeSliceCache.clear();
	}

public:
	void addTimeSlice( TimeSlice* slice ) 
	{
		//only once, not accumulate.
		if (!slice || findSlice(slice->name)) return;
		if (vecTimeSlice.size() >= 1000) return; //limit.

		slice->parent = getParentSlice();
		vecTimeSlice.push_back( slice );
		mapTimeSliceCache[ slice->name ] = slice;
	}

	void setTimeSliceEnd( const string& name )
	{
		TimeSlice* slice = findSlice( name );
		if (slice)
		{
            CCTime::gettimeofdayCocos2d(&slice->endTime, NULL);
		}
	}

private:
	TimeSlice* findSlice( const string& name )
	{
		map<string,TimeSlice*>::iterator it = mapTimeSliceCache.find( name );
		return (it != mapTimeSliceCache.end()) ? it->second : NULL;
	}

	TimeSlice* getParentSlice()
	{
		int cnt = vecTimeSlice.size();
		for (int i = cnt - 1; i >= 0; i--)
		{
			TimeSlice* slice = vecTimeSlice[i];
			if (slice && slice->endTime.tv_sec == 0) //not end.
				return slice;
		}
		return NULL;
	}

public:
	vector<TimeSlice*>		vecTimeSlice;
	map<string,TimeSlice*>	mapTimeSliceCache;
};


///////////////////////////////////////////////////
class NDProfile
{
private:
	NDProfile() 
	{
		data = new NDProfileData();
	}
	
public:
	static NDProfile& Instance() 
	{
		static NDProfile* inst = NULL;
		if (!inst)
		{
			inst = new NDProfile();
		}
		return *inst;
	}
	
	~NDProfile()
	{
		if (data) delete data;
	}

public:
	void addTimeSlice( const string& name )
	{
		TimeSlice* slice = new TimeSlice(name);
		data->addTimeSlice( slice );
	}

	void setTimeSliceEnd( const string& name )
	{
		data->setTimeSliceEnd( name );
	}

	NDProfileData& getData() { return *data; }

private:
	NDProfileData*	data;
};


///////////////////////////////////////////////////
class NDProfileHelper
{
private:
	NDProfileHelper();

public:
	NDProfileHelper( const string& in_name )
	{
		if (in_name.length() > 0)
		{
			name = in_name;
			NDProfile::Instance().addTimeSlice( in_name );
		}
	}

	~NDProfileHelper()
	{
		NDProfile::Instance().setTimeSliceEnd( name );
	}

private:
	string name;
};

///////////////////////////////////////////////////
class NDProfileHelperLua //for lua
{
public:
	static void regLua()
	{
		ETCFUNC("bgnTimeSlice", luaBeginTimeSlice)
		ETCFUNC("endTimeSlice", luaEndTimeSlice)
	}

	static int luaBeginTimeSlice( const char* name )
	{	
		if (name && name[0] != 0)
		{
			NDProfile::Instance().addTimeSlice( name );
		}
		return 0;
	}

	static int luaEndTimeSlice( const char* name )
	{
		if (name && name[0] != 0)
		{
			NDProfile::Instance().setTimeSliceEnd( name );
		}
		return 0;
	}
};

///////////////////////////////////////////////////
class NDProfileReport
{
public:
	static void report()
	{
		NDProfileData& data = NDProfile::Instance().getData();
		int cnt = data.vecTimeSlice.size();
		for (int i = 0; i < cnt; i++)
		{
			TimeSlice* slice = data.vecTimeSlice[i];
			CCAssert(slice && slice->endTime.tv_sec != 0, "NDProfileReport");

			string name = getMargin( slice ) + slice->name;
			char line[200] = "";
			sprintf( line, "%-80s%s\r\n", name.c_str(), slice->getTimeStr().c_str());
			
			writeLine(line);
		}
	}

	static void dump()
	{
		NDProfileData& data = NDProfile::Instance().getData();
		int cnt = data.vecTimeSlice.size();
		for (int i = 0; i < cnt; i++)
		{
			TimeSlice* slice = data.vecTimeSlice[i];
			if (slice)
			{
				char line[200] = "";
				sprintf( line, "start=%u, end=%u, name=%s, time=%s\r\n",
					slice->beginTime.tv_sec, slice->endTime.tv_sec, slice->name.c_str(), slice->getTimeStr().c_str());

				writeLine(line);
			}
		}
	}

	static string getMargin( TimeSlice* slice )
	{
		if (!slice) return "";
		
		string margin;
		int cnt = slice->getParentCount();
		
		if (cnt <= 5) //should be enough
		{
			char spaces[] = "    "; //4
			for (int i = 0; i < cnt; i++) 
			{
				margin += spaces;
			}
		}
		else
		{
			margin = "err!     ";
		}
		return margin;
	}

	static void writeLine( const string& line )
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		DWORD n = 0;
		HANDLE hOut = NDConsole::GetSingletonPtr()->getOutputHandle();
		WriteConsoleA( hOut, line.c_str(), line.length(), &n, NULL );
#endif
	}
};
///////////////////////////////////////////////////

#define WITH_PROFILE		1
#define WITH_PROFILE_LUA	1

#if WITH_PROFILE
	#define TIME_SLICE(name)		NDProfileHelper o(name);
#else
	#define TIME_SLICE(name)	
#endif

#if WITH_PROFILE && WITH_PROFILE_LUA
	#define PROFILE_REGLUA()	NDProfileHelperLua::regLua();
#else
	#define PROFILE_REGLUA()
#endif

///////////////////////////////////////////////////

NS_NDENGINE_END
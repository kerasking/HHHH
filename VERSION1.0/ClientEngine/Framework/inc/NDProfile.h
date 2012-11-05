//-------------------------------------------------------------------------
//  NDProfile.h
//
//  Created by zhangwq on 22012-11-05.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	功能：性能调优（消耗时间片跟踪）
//-------------------------------------------------------------------------

#include <windows.h>
#include <map>
#include <vector>
#include <NDConsole.h>
#include <ScriptDefine.h>

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
		, beginTime(GetTickCount())
		, endTime(0)
		, parent(NULL) {}

	string	name;
	DWORD	beginTime;
	DWORD	endTime;
	TimeSlice* parent;

	DWORD getTick() const { return endTime ? (endTime - beginTime) : 999999; }

	string getTimeStr() const {
		char str[100] = "";
		DWORD t = getTick();
		if (t >= 1000) {
			sprintf( str, "%.2f (s)", t / 1000.f );
		}
		else {
			sprintf( str, "%d (ms)", t );
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
			slice->endTime = GetTickCount();
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
			if (slice && slice->endTime == 0) //not end.
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
			CCAssert(slice && slice->endTime != 0);

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
					slice->beginTime, slice->endTime, slice->name.c_str(), slice->getTimeStr().c_str());

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
		DWORD n = 0;
		HANDLE hOut = NDConsole::GetSingletonPtr()->getOutputHandle();
		WriteConsoleA( hOut, line.c_str(), line.length(), &n, NULL );
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
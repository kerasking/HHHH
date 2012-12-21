//
//  ObjectTracker.cpp
//
//  Created by zhangwq on 2012-12-19.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	跟踪对象
//

#include "ObjectTracker.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define ENABLE_OBJ_TRACKER 1
#endif

#define ENABLE_OBJ_TRACKER 0 //总开关

void ObjectTracker::inc_imp( const char* clsName, map<string,TrackerData>& curMap ) 
{
#if ENABLE_OBJ_TRACKER
	if (!clsName) return;

	string name = clsName;
	ITER_MAP_STAT iter = curMap.find( name );

	if (iter == curMap.end())
	{
		TrackerData data;
		data.getCur() = 1;
		curMap.insert( map<string,TrackerData>::value_type(name, data ));
	}
	else
	{
		iter->second.getCur() += 1;
	}
#endif
}

void ObjectTracker::dec_imp( const char* clsName, map<string,TrackerData>& curMap ) 
{
#if ENABLE_OBJ_TRACKER
	if (!clsName) return;

	string name = clsName;
	ITER_MAP_STAT iter = curMap.find( name );
	
	if (iter != curMap.end())
	{
		iter->second.getCur() -= 1;
	}
#endif
}

void ObjectTracker::dump( string& info, int param )
{
#if ENABLE_OBJ_TRACKER
	this->report( info, param );
	this->flush();
#endif
}

void ObjectTracker::report_imp( map<string,TrackerData>& data, int param, 
								int& total, string& info )
{
#if ENABLE_OBJ_TRACKER
	char line[200] = "";

	for (ITER_MAP_STAT iter = data.begin();
		iter != data.end(); ++iter)
	{
		total += iter->second.getCur();

		TrackerData& data = iter->second;
		int diff = data.getCur() - data.getPrev();

		if (diff != 0 ||
			(data.getCur() > param || data.getPrev() > param))
		{
			char szDiff[100] = "";
			if (diff != 0)
			{
				sprintf( szDiff, "%d", diff );
			}

			sprintf( line, "%-25s %-10d %-10d %s\r\n", 
				iter->first.c_str(), data.getPrev(), data.getCur(), szDiff );
			
			info += line;
		}
	}
#endif
}

void ObjectTracker::report( string& info, int param )
{	
#if ENABLE_OBJ_TRACKER
	info = "";
	
	//
	int cc_obj = 0;	
	info += "\r\n------------ CC Obj Tracker ----------------\r\n";
	this->report_imp( mapStatCC, param, cc_obj, info );

	//
	int nd_obj = 0;	
	info += "\r\n------------ ND Obj Tracker ----------------\r\n";
	this->report_imp( mapStatND, param, nd_obj, info );

	//
	char line[200] = "";
	sprintf( line, "\r\n%d cc obj, %d nd obj, total %d\r\n", cc_obj, nd_obj, cc_obj + nd_obj );
	info += line;
#endif
}

void ObjectTracker::flush()
{
#if ENABLE_OBJ_TRACKER
	flush_imp( mapStatCC );
	flush_imp( mapStatND );
#endif
}

void ObjectTracker::flush_imp( map<string,TrackerData>& curMap )
{
#if ENABLE_OBJ_TRACKER
	for (ITER_MAP_STAT iter = curMap.begin();
		iter != curMap.end(); ++iter)
	{
		iter->second.cur2prev();
	}
#endif
}
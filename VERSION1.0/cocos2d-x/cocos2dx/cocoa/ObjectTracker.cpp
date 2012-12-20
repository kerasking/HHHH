//
//  ObjectTracker.cpp
//
//  Created by zhangwq on 2012-12-19.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//
//	¸ú×Ù¶ÔÏó
//

#include "ObjectTracker.h"

void ObjectTracker::inc_imp( const char* clsName, map<string,TrackerData>& curMap ) 
{
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
}

void ObjectTracker::dec_imp( const char* clsName, map<string,TrackerData>& curMap ) 
{
	if (!clsName) return;

	string name = clsName;
	ITER_MAP_STAT iter = curMap.find( name );
	
	if (iter != curMap.end())
	{
		iter->second.getCur() -= 1;
	}
}

void ObjectTracker::dump( string& info, int param )
{
	this->report( info, param );
	this->flush();
}

void ObjectTracker::report_imp( map<string,TrackerData>& data, int param, 
								int& total, string& info )
{
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
}

void ObjectTracker::report( string& info, int param )
{	
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
}

void ObjectTracker::flush()
{
	flush_imp( mapStatCC );
	flush_imp( mapStatND );
}

void ObjectTracker::flush_imp( map<string,TrackerData>& curMap )
{
	for (ITER_MAP_STAT iter = curMap.begin();
		iter != curMap.end(); ++iter)
	{
		iter->second.cur2prev();
	}
}
//
//  ObjectTracker.cpp
//
//  Created by zhangwq on 2012-12-19.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//
//	¸ú×Ù¶ÔÏó
//

#include "ObjectTracker.h"

void ObjectTracker::inc_imp( const char* clsName, map<string,int>& curMap ) 
{
	if (!clsName) return;

	string name = clsName;
	ITER_MAP_STAT iter = curMap.find( name );
	if (iter == curMap.end())
	{
		curMap.insert( map<string,int>::value_type(name, 1 ));
	}
	else
	{
		iter->second += 1;
	}
}

void ObjectTracker::dec_imp( const char* clsName, map<string,int>& curMap ) 
{
	if (!clsName) return;

	string name = clsName;
	ITER_MAP_STAT iter = curMap.find( name );
	
	if (iter != curMap.end())
	{
		iter->second -= 1;
	}
}

void ObjectTracker::dump( string& info )
{	
	info = "";
	char line[1024] = "";
	
	//
	int cc_obj = 0;	
	info += "\r\n------------ CC Obj Tracker ----------------\r\n";
	for (ITER_MAP_STAT iter = mapStatCC.begin();
		iter != mapStatCC.end(); ++iter)
	{
		if (iter->second > 0)
		{
			cc_obj += iter->second;
			sprintf( line, "%-25s %d\r\n", iter->first.c_str(), iter->second );
			info += line;
		}
	}

	//
	info += "\r\n------------ ND Obj Tracker ----------------\r\n";

	int nd_obj = 0;	
	for (ITER_MAP_STAT iter = mapStatND.begin();
		iter != mapStatND.end(); ++iter)
	{
		if (iter->second > 0)
		{
			nd_obj += iter->second;
			sprintf( line, "%-25s %d\r\n", iter->first.c_str(), iter->second );
			info += line;
		}
	}

	sprintf( line, "\r\n%d cc obj, %d nd obj, total %d\r\n", cc_obj, nd_obj, cc_obj + nd_obj );
	info += line;
}

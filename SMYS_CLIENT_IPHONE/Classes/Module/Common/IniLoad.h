/*
 *  IniLoad.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-7-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
 
 /*
	USE:
	1.define INIDATA struct in "IniData.h" (INIDATA must implement "INIDATA& operator <<(NSInputStream* stream)" method)
	2.load file by GlobalLoadIni(INIDATA, "*.ini", "*.ini");
	3.use data by const INIDATA* data = GlobalGetIniData(INIDATA, 10001);
 */

#ifndef _INI_LOAD_H_
#define _INI_LOAD_H_

#include <string>
#include <map>
#include "IniData.h"

using namespace NDEngine;

#define GlobalLoadIni(INIDATA, inifile, indexfile) IniLoadObj(INIDATA).Load(inifile, indexfile)

#define GlobalGetIniData(INIDATA, ID) IniLoadObj(INIDATA).QueryData(ID)

#define IniLoadObj(INIDATA) IniLoad<INIDATA>::GetSingleton() 

template<typename INIDATA>
class IniLoad : public TSingleton< IniLoad<INIDATA> >
{
public:
	typedef INIDATA* data_ptr;
	
	typedef const INIDATA* const_data_ptr;
	
	typedef INIDATA& data_ref;
	
	typedef const INIDATA& const_data_ref;
	
public:

	IniLoad() { m_cacheNum = 0; }
	
	virtual ~IniLoad() {}
	
	void Load(std::string inifile, std::string indexfile, unsigned int cacheNum = 100);
	
	virtual const_data_ptr QueryData(int ID);
	
	virtual void replace() {}
	
private:

	void LoadIndex(std::string indexfile);
	
private:
	std::string m_inifile;
	
	unsigned int m_cacheNum;
	
	typedef std::map<int, int> map_index;
	
	typedef map_index::iterator map_index_it;
	
	typedef std::pair<int, int> map_index_pair;
	
	typedef typename std::map<int, INIDATA> map_obj;
	
	typedef typename map_obj::iterator map_obj_it;
	
	typedef std::pair<int, INIDATA> map_obj_pair;
	
	map_index m_index;
	
	map_obj m_obj;
};

template<typename INIDATA>
void IniLoad<INIDATA>::Load(std::string inifile, std::string indexfile, unsigned int cacheNum/* = 100*/)
{
	NDAsssert( !(inifile.empty() || indexfile.empty()) );

	m_inifile = inifile;
	
	m_cacheNum = cacheNum;
	
	LoadIndex(indexfile);
}

template<typename INIDATA>
const INIDATA* IniLoad<INIDATA>::QueryData(int ID)
{
	map_obj_it it = m_obj.find(ID);
	if (it != m_obj.end()) 
	{
		return &(it->second);
	}
	
	// 从ini文件中读
	map_index_it itIndex = m_index.find(ID);
	if (itIndex == m_index.end()) 
	{
		return NULL;
	}
	
	std::string res = "";
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	CCString *table = new CCString(GetResPath(m_inifile.c_str()));
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:table];
	
	if (!stream) //|| ![stream hasBytesAvailable]) 
	{
		return NULL;
	}
	
	[stream open];
	
	INIDATA obj;
	
	[stream setProperty:[NSNumber numberWithInt:itIndex->second] forKey:NSStreamFileCurrentOffsetKey];
	
	obj << stream;
	
	[stream close];
	
	if (m_obj.size() > m_cacheNum) 
	{
		replace();
	}
	
	std::pair< map_obj_it, bool> respair;
	respair = m_obj.insert(map_obj_pair(ID, obj));
	if (!respair.second) 
	{
		return NULL;
	}
	
	return &(respair.first->second);
}

template<typename INIDATA>
void IniLoad<INIDATA>::LoadIndex(std::string indexfile)
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	CCString *table = new CCString(GetResPath(indexfile.c_str()));
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:table];
	
	if (stream)
	{
		[stream open];
		
		int size = [stream readInt];
		
		for (int i = 0; i < size; i++)
		{
			int ID = [stream readInt];
			int index = [stream readInt];
			m_index.insert(map_index_pair(ID, index));
		}
		
		[stream close];
	}
}

#endif // _INI_LOAD_H_
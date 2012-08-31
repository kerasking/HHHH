/*
 *  NDColorPool.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-7.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __ND_COLOR_POOL_H__
#define __ND_COLOR_POOL_H__

#include "Utility.h"

#define NDColorPoolObj NDColorPool::GetSingleton()

typedef std::vector<int> VEC_COLOR_ARRAY;
typedef VEC_COLOR_ARRAY::iterator VEC_COLOR_ARRAY_IT;

class NDColorPool : public TSingleton<NDColorPool>
{
public:
	NDColorPool();
	~NDColorPool();
	
	bool GetColorFromPool(const char* colorFile,
		uint colorIndex, VEC_COLOR_ARRAY& colorArray);
	
private:

	typedef std::pair<std::string, uint> PAIR_COLOR_KEY;
	typedef std::map<PAIR_COLOR_KEY, VEC_COLOR_ARRAY> MAP_COLOR;
	typedef MAP_COLOR::iterator MAP_COLOR_IT;
	MAP_COLOR m_kMapColors;
	
private:
	void LoadColor(const char* colorFile);
};

#endif
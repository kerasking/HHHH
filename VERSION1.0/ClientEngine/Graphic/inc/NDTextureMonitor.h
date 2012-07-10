/*
 *  NDTextureMonitor.h
 *  SMYS
 *
 *  Created by jhzheng on 12-3-30.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_TEXTURE_MONOITOR_H_ZJH_
#define _ND_TEXTURE_MONOITOR_H_ZJH_

#include "Singleton.h"

#define TextureMonitorObj	CNDTextureMonitor::GetSingleton()

class CNDTextureMonitor :
public TSingleton<CNDTextureMonitor>
{
public:
	void BeforeTextureAdd();
	/** nSize byte*/
	void TextureAdd(unsigned int nSize);
	/** nSize byte*/
	void TextureDel(unsigned int nSize);
	
	void Report();
	
private:
	unsigned int			m_nTotalSize;
	unsigned int			m_nGCSize;
	bool					m_bStartGC;
	
public:
	CNDTextureMonitor();
	
private:
	void GarbageCollect(int nLvl);
	void StartGC();
	void EndGC();
	void GCStatistics();
	bool IsGCState();
};

#endif // _ND_TEXTURE_MONOITOR_H_ZJH_
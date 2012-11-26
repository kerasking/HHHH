/*
 *  NDTextureMonitor.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-3-30.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDTextureMonitor.h"
#include "NDPicture.h"
#include "NDDirector.h"
#include "NDAnimationGroupPool.h"
#include "CCTextureCacheExt.h"
//#include "ScriptMgr.h"

using namespace NDEngine;


#define KBYTE					(1024)
#define MBYTE					(KBYTE	* 1024)
#define WARRINGSIZE				(MBYTE	* 30)
#define ERRORSIZE				(MBYTE	* 50)

enum
{
	TextureGCLvlNormal			= 0,
	TextureGCLvlWarring			= 1,
	TextureGCLvlError			= 2,
};

void CNDTextureMonitor::BeforeTextureAdd()
{
	if (m_nTotalSize >= WARRINGSIZE)
	{
		GarbageCollect(TextureGCLvlWarring);
	}
	else if (m_nTotalSize >= ERRORSIZE)
	{
		GarbageCollect(TextureGCLvlError);
	}
}

/** nSize byte*/
void CNDTextureMonitor::TextureAdd(unsigned int nSize)
{
	m_nTotalSize	+= nSize;
	
	if (m_nTotalSize >= WARRINGSIZE)
	{
		GarbageCollect(TextureGCLvlWarring);
	}
	else if (m_nTotalSize >= ERRORSIZE)
	{
		GarbageCollect(TextureGCLvlError);
	}
}

/** nSize byte*/
void CNDTextureMonitor::TextureDel(unsigned int nSize)
{
	if (m_nTotalSize < nSize)
	{
		//ScriptMgrObj.DebugOutPut("error texture del total size smaller than del size");
		NDAsssert(0);
		return;
	}
	
	if (IsGCState())
	{
		m_nGCSize	+= nSize;
	}
	
	m_nTotalSize	-= nSize;
}

void CNDTextureMonitor::GarbageCollect(int nLvl)
{
	switch (nLvl) {
		case TextureGCLvlNormal:
		{
		}
			break;
		case TextureGCLvlWarring:
		{
			StartGC();

			NDPicturePool::DefaultPool()->Recyle();
			//todo(zjh)
			//[[CCTextureCache sharedTextureCache] Recyle];
			//[[NDAnimationGroupPool defaultPool] Recyle];
			
			EndGC();
			
			GCStatistics();
		}
			break;
		case TextureGCLvlError:
		{
			NDAsssert(0);
		}
			break;
		default:
			break;
	}
}

void CNDTextureMonitor::StartGC()
{
	m_nGCSize		= 0;
	m_bStartGC		= true;
}

void CNDTextureMonitor::EndGC()
{
	m_bStartGC		= false;
}

void CNDTextureMonitor::GCStatistics()
{
	//printf("\ntexture recycle memory [%d] kbyte [%d] MByte", m_nGCSize / KBYTE, m_nGCSize / MBYTE );
	//printf("\ncur texture size [%d] kbyte [%d] MByte", m_nTotalSize / KBYTE, m_nTotalSize / MBYTE);
	if (m_nGCSize > 0)
	{
		//ScriptMgrObj.DebugOutPut("\ntexture recycle memory [%d] kbyte [%d] MByte", m_nGCSize / KBYTE, m_nGCSize / MBYTE );
		//ScriptMgrObj.DebugOutPut("\ncur texture size [%d] kbyte [%d] MByte", m_nTotalSize / KBYTE, m_nTotalSize / MBYTE);
	}
}

bool CNDTextureMonitor::IsGCState()
{
	return m_bStartGC;
}

CNDTextureMonitor::CNDTextureMonitor()
{
	m_nTotalSize			= 0;
	m_nGCSize				= 0;
	m_bStartGC				= false;
}

void CNDTextureMonitor::Report()
{
	//printf("\n*************cur texture size [%d] kbyte [%d] MByte", m_nTotalSize / KBYTE, m_nTotalSize / MBYTE);
	//ScriptMgrObj.DebugOutPut("\n*************cur texture size [%d] kbyte [%d] MByte", m_nTotalSize / KBYTE, m_nTotalSize / MBYTE);
}
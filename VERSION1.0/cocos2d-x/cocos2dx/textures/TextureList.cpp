//--------------------------------------------------------------------
//  TextureList.cpp
//  纹理链表
//
//  Created by zhangwq on 2012-12-27.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	用链表管理贴图资源，场景切换时释放所有贴图资源.
//	备注：仅考虑CCTexture2D对象本身，不考虑其他上层对象对它的引用.
//--------------------------------------------------------------------

#include "TextureList.h"
#include "CCTexture2D.h"
#include "CCTexturePVR.h"

#include <algorithm>
using namespace cocos2d;

#define ENABLE_TEX_LIST 1

void TextureList::add_tex( void* tex )
{
#if ENABLE_TEX_LIST
	if (!tex) return;
	mapTex.insert( VAL_MAPTEX(tex,1));
#endif
}

void TextureList::del_tex( void* tex )
{
#if ENABLE_TEX_LIST
	if (!tex) return;
	ITER_MAPTEX iter = mapTex.find( tex );
	if (iter != mapTex.end())
		mapTex.erase( iter );
#endif
}

//@pvr
void TextureList::add_tex_pvr( void* tex )
{
#if ENABLE_TEX_LIST
	if (!tex) return;
	mapTexPVR.insert( VAL_MAPTEX(tex,1));
#endif
}

//@pvr
void TextureList::del_tex_pvr( void* tex )
{
#if ENABLE_TEX_LIST
	if (!tex) return;
	ITER_MAPTEX iter = mapTexPVR.find( tex );
	if (iter != mapTexPVR.end())
		mapTexPVR.erase( iter );
#endif
}

void TextureList::purge()
{
// #if ENABLE_TEX_LIST
// 	while (mapTex.size() > 0)
// 	{
// 		CCTexture2D* tex = (CCTexture2D*) mapTex.begin()->first;
// 		if (tex) delete tex; //force delete!
// 		mapTex.erase( mapTex.begin() );
// 	}
// 	mapTex.clear();
// 
// 	//
// 	while (mapTexPVR.size() > 0)
// 	{
// 		CCTexturePVR* tex = (CCTexturePVR*) mapTexPVR.begin()->first;
// 		if (tex) delete tex; //force delete!
// 		mapTexPVR.erase( mapTexPVR.begin() );
// 	}
// 	mapTexPVR.clear();
// #endif
}

string TextureList::dump( const string& out_file )
{
#if ENABLE_TEX_LIST

	vector<void*> vecTex;
	sortTex( vecTex );

	string total;
	char szName[20] = "";
	char szSize[20] = "";
	char szBytes[20] = "";
	char line[200] = "";

	int index = 0;
	int ref1_count = 0, ref2_count = 0;
	int totalBytes = 0;

	for (vector<void*>::iterator iter = vecTex.begin(); iter != vecTex.end(); ++iter)
	{
		CCTexture2D* tex = (CCTexture2D*) *iter;
		if (!tex) continue;

		unsigned int bpp = tex->bitsPerPixelForFormat();
		unsigned int bytes = tex->getPixelsWide() * tex->getPixelsHigh() * bpp / 8;
		totalBytes += bytes;

		// make dbgInfo shorter
		char* res = "/SimplifiedChineseRes/";
		char* dbgInfo = (char*)tex->getDbgInfo().c_str();
		char* dbg = strstr(dbgInfo, res);
		if (dbg)
		{
			dbg += strlen(res);
			if (*dbg == '/') dbg++;
		}
		else
		{
			dbg = dbgInfo;
		}

		int ref = tex->retainCount();
		sprintf( szName, "tex[%d]", index++);
		sprintf( szSize, "%d*%d", (long)tex->getPixelsWide(), (long)tex->getPixelsHigh());
		sprintf( szBytes, "%.1fK", float(bytes)/1024);
		//sprintf( line, "%-10s %-10s %-10s [id=%03d ref=%02d] %s\r\n", szName, szSize, szBytes, (long)tex->getName(), ref, tex->getDbgInfo().c_str() );
		sprintf( line, "%-10s %-10s %-10s [id=%03d]  => %s\r\n", szName, szSize, szBytes, (long)tex->getName(), dbg );
		total += line;

		if (ref == 1)
			ref1_count++;
		else if (ref == 2)
			ref2_count++;
	}

	total += "\r\n";
	sprintf( line, "total %d tex, %.1fM, ref1_count=%d, ref2_count=%d\r\n", mapTex.size(), float(totalBytes)/(1024*1024), ref1_count, ref2_count );
	total += line;

	// output to file
	if (out_file.length() > 0)
	{
		char path[100] = "";
		sprintf( path, "c:/%s.txt", out_file.c_str());
		FILE* fp = fopen( path, "w" );
		if (fp)
		{
			fwrite( total.c_str(), 1, total.length(), fp );
			fclose(fp);
		}
	}
	return total;
#endif
	return "";
}

bool pr( void* tex1, void* tex2 )
{
	CCTexture2D* t1 = (CCTexture2D*) tex1;
	CCTexture2D* t2 = (CCTexture2D*) tex2;

	if (t1 && t2)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		return stricmp( t1->getDbgInfo().c_str(), t2->getDbgInfo().c_str() ) < 0;
#else
		return t1->getName() < t2->getName();
#endif	
	}
	return false;
};

void TextureList::sortTex( vector<void*>& vecTex )
{
	vecTex.clear();

	for (ITER_MAPTEX iter = mapTex.begin(); iter != mapTex.end(); ++iter)
	{
		CCTexture2D* tex = (CCTexture2D*) iter->first;
		if (!tex) continue;
		vecTex.push_back( tex );
	}

	sort( vecTex.begin(), vecTex.end(), pr );
}
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

string TextureList::dump()
{
#if ENABLE_TEX_LIST
	string total;
	char str1[20] = "";
	char str2[20] = "";
	char str3[20] = "";
	char line[200] = "";

	int index = 0;
	int ref1_count = 0, ref2_count = 0;
	int totalBytes = 0;

	for (ITER_MAPTEX iter = mapTex.begin(); iter != mapTex.end(); ++iter)
	{
		CCTexture2D* tex = (CCTexture2D*) iter->first;
		if (!tex) continue;

		unsigned int bpp = tex->bitsPerPixelForFormat();
		unsigned int bytes = tex->getPixelsWide() * tex->getPixelsHigh() * bpp / 8;
		totalBytes += bytes;

		int ref = tex->retainCount();
		sprintf( str1, "tex[%d]", index++);
		sprintf( str2, "%d*%d", (long)tex->getPixelsWide(), (long)tex->getPixelsHigh());
		sprintf( str3, "%.1fK", float(bytes)/1024);
		sprintf( line, "%-10s %-10s %-10s [id=%03d ref=%d]\r\n", str1, str2, str3, (long)tex->getName(), ref );
		total += line;

		if (ref == 1)
			ref1_count++;
		else if (ref == 2)
			ref2_count++;
	}

	total += "\r\n";
	sprintf( line, "total %d tex, %.1fM, ref1_count=%d, ref2_count=%d\r\n", mapTex.size(), float(totalBytes)/(1024*1024), ref1_count, ref2_count );
	total += line;
	return total;
#endif
	return "";
}
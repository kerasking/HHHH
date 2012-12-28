//--------------------------------------------------------------------
//  TextureList.h
//  纹理链表
//
//  Created by zhangwq on 2012-12-27.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	用链表管理贴图资源，场景切换时释放所有贴图资源.
//	备注：仅考虑CCTexture2D对象本身，不考虑其他上层对象对它的引用.
//		  贴图的创建和删除，用map管理可能会有点慢，
//		  但是考虑到贴图对象一般也就100来个，排序应该可以忍受.
//--------------------------------------------------------------------

#pragma once

#include <map>
#include <string>
#include <vector>
using namespace std;
#include "platform/CCPlatformMacros.h"

class CC_DLL TextureList
{
private:
	TextureList() {};

public:
	static TextureList& instance()
	{
		static TextureList s_obj;
		return s_obj;
	}

public:
	void add_tex( void* tex );
	void del_tex( void* tex );

	void add_tex_pvr( void* tex );
	void del_tex_pvr( void* tex );

	void purge();

	string dump( const string& out_file );

private:
	void sortTex( vector<void*>& vecTex );

private:
	map<void*,int> mapTex;
	map<void*,int> mapTexPVR;

	typedef map<void*,int>::iterator		ITER_MAPTEX;
	typedef map<void*,int>::value_type		VAL_MAPTEX;
};
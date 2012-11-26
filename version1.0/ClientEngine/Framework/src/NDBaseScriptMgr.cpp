#include "NDBaseScriptMgr.h"

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDBaseScriptMgr,NDObject)

NDBaseScriptMgr::NDBaseScriptMgr()
{

}

NDBaseScriptMgr::~NDBaseScriptMgr()
{

}

void NDBaseScriptMgr::Load()
{

}

bool NDBaseScriptMgr::AddRegClassFunc( RegisterClassFunc func )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, int param1 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, int param1, int param2 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, int param1, int param2, int param3 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, const char* param1 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, const char* param1, const char* param2 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, const char* param1, const char* param2, const char* param3 )
{
	return true;
}

bool NDBaseScriptMgr::excuteLuaFunc( const char* funcname, const char* modulename, int param1, int param2, int param3,int param4 )
{
	return true;
}

bool NDBaseScriptMgr::IsLuaFuncExist( const char* funcname, const char* modulename )
{
	return true;
}

int NDBaseScriptMgr::excuteLuaFuncRetN( const char* funcname, const char* modulename )
{
	return 0;
}

const char* NDBaseScriptMgr::excuteLuaFuncRetS( const char* funcname, const char* modulename )
{
	return 0;
}

cocos2d::ccColor4B NDBaseScriptMgr::excuteLuaFuncRetColor4( const char* funcname, const char* modulename,int param1 )
{
	ccColor4B kColor;
	return kColor;
}

void NDBaseScriptMgr::DebugOutPut( const char* fmt, ... )
{

}

void NDBaseScriptMgr::LoadLuaFile( const char* pszluaFile )
{

}

void NDBaseScriptMgr::WriteLog( const char* fmt, ... )
{

}

LuaPlus::LuaObject NDBaseScriptMgr::GetLuaFunc( const char* funcname, const char* modulename )
{
	LuaObject kObj;
	return kObj;
}

void NDBaseScriptMgr::update()
{

}

NS_NDENGINE_END
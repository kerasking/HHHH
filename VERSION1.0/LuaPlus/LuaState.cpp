///////////////////////////////////////////////////////////////////////////////
// This source file is part of the LuaPlus source distribution and is Copyright
// 2001-2005 by Joshua C. Jensen (jjensen@workspacewhiz.com).
//
// The latest version may be obtained from http://wwhiz.com/LuaPlus/.
//
// The code presented in this file may be used in any environment it is
// acceptable to use Lua.
///////////////////////////////////////////////////////////////////////////////
#define BUILDING_LUAPLUS
#include "LuaLink.h"
LUA_EXTERN_C_BEGIN
#define LUA_CORE
#include "src/lobject.h"
LUA_EXTERN_C_END
#include "LuaPlus.h"
#include "LuaState.h"
#include "LuaCall.h"
#include "LuaPlusCD.h"

#if defined(WIN32) && !defined(_XBOX)
#include <windows.h>
#undef GetObject
#undef LoadString
#elif defined(_XBOX)
#include <xtl.h>
#endif // WIN32

#ifdef _MSC_VER
#pragma warning(disable: 4702)
#endif // _MSC_VER

#include <ctype.h>

LUA_EXTERN_C_BEGIN
#include "src/lstate.h"
#include "src/lvm.h"
#include "src/lgc.h"
LUA_EXTERN_C_END


#ifndef LUAPLUS_ENABLE_INLINES
#include "LuaState.inl"
#endif // LUAPLUS_ENABLE_INLINES

namespace LuaPlus {

LuaStackObject LuaState::Stack(int index)
{
    return LuaStackObject(this, index);
}

LuaStackObject LuaState::StackTop()
{
    return LuaStackObject(this, GetTop());
}

LuaStackObject LuaState::PushVFString(const char *fmt, va_list argp)
{
	lua_State* L = m_state;
	lua_lock(L);
	luaC_checkGC(L);
	luaO_pushvfstring(L, fmt, argp);
	lua_unlock(L);
	return LuaStackObject(this, lua_gettop(m_state));
}


LuaStackObject LuaState::PushFString(const char *fmt, ...)
{
	lua_State* L = m_state;
	va_list argp;
	lua_lock(L);
	luaC_checkGC(L);
	va_start(argp, fmt);
	luaO_pushvfstring(L, fmt, argp);
	va_end(argp);
	lua_unlock(L);
	return LuaStackObject(this, lua_gettop(m_state));
}






int LuaState::Equal(const LuaObject& o1, const LuaObject& o2)
{
	int i = equalobj(o1.GetCState(), o1.GetTObject(), o2.GetTObject());
	return i;
}


int LuaState::LessThan(const LuaObject& o1, const LuaObject& o2)
{
	int i = luaV_lessthan(o1.GetCState(), o1.GetTObject(), o2.GetTObject());
	return i;
}


LuaObject LuaState::NewUserDataBox(void* u)
{
	LuaObject obj(this);
	obj.AssignUserData(this, u);
	return obj;
}


int LuaState::TypeError(int narg, const char* tname)
{
	return luaL_typerror(m_state, narg, tname);
}


int LuaState::ArgError(int narg, const char* extramsg)
{
	return luaL_argerror(m_state, narg, extramsg);
}


const char* LuaState::CheckLString(int numArg, size_t* len)
{
	return luaL_checklstring(m_state, numArg, len);
}


const char* LuaState::OptLString(int numArg, const char *def, size_t* len)
{
	return luaL_optlstring(m_state, numArg, def, len);
}


lua_Number LuaState::CheckNumber(int numArg)
{
	return luaL_checknumber(m_state, numArg);
}


lua_Number LuaState::OptNumber(int nArg, lua_Number def)
{
	return luaL_optnumber(m_state, nArg, def);
}


lua_Integer LuaState::CheckInteger(int numArg)
{
	return luaL_checkinteger(m_state, numArg);
}


lua_Integer LuaState::OptInteger(int nArg, lua_Integer def)
{
	return luaL_optinteger(m_state, nArg, def);
}


void LuaState::ArgCheck(bool condition, int numarg, const char* extramsg)
{
	luaL_argcheck(m_state, condition, numarg, extramsg);
}


const char* LuaState::CheckString(int numArg)
{
	return luaL_checkstring(m_state, numArg);
}


const char* LuaState::OptString(int numArg, const char* def)
{
	return luaL_optlstring(m_state, numArg, def, NULL);
}


int LuaState::CheckInt(int numArg)
{
	return (int)luaL_checkint(m_state, numArg);
}


long LuaState::CheckLong(int numArg)
{
	return (long)luaL_checklong(m_state, numArg);
}


int LuaState::OptInt(int numArg, int def)
{
	return (int)luaL_optint(m_state, numArg, def);
}


long LuaState::OptLong(int numArg, int def)
{
	return (long)luaL_optlong(m_state, numArg, def);
}


void LuaState::CheckStack(int sz, const char* msg)
{
	luaL_checkstack(m_state, sz, msg);
}


void LuaState::CheckType(int narg, int t)
{
	luaL_checktype(m_state, narg, t);
}


void LuaState::CheckAny(int narg)
{
	luaL_checkany(m_state, narg);
}


LuaStackObject LuaState::NewMetaTable(const char* tname)
{
	luaL_newmetatable(m_state, tname);
	return LuaStackObject(this, GetTop());
}

	
void* LuaState::CheckUData(int ud, const char* tname)
{
	return luaL_checkudata(m_state, ud, tname);
}


int LuaState::Where(int lvl)
{
	luaL_where(m_state, lvl);
	return LuaStackObject(this, GetTop());
}

	
const char* LuaState::GSub(const char *s, const char *p, const char *r)
{
	return luaL_gsub(m_state, s, p, r);
}


const char* LuaState::FindTable(int idx, const char *fname, int szhint)
{
	return luaL_findtable(m_state, idx, fname, szhint);
}


static size_t lua_WChar_len(const lua_WChar* str)
{
	const lua_WChar* ptr = str;
	while (*ptr != 0)
	{
		ptr++;
	}

	return (size_t)(ptr - str);
}

LuaObject LuaState::GetLocalByName( int level, const char* name )
{
	lua_State * L = GetCState();
	lua_Debug ar;
	int i;
	const char *localName;
	if (lua_getstack(L, level, &ar) == 0)
		return LuaObject(this);  /* failure: no such level in the stack */
	i = 1;
	while ((localName = lua_getlocal(L, &ar, i++)) != NULL) {
		if (strcmp(name, localName) == 0)
		{
			LuaObject obj(this, -1);
			lua_pop(L, 1);
			return obj;
		}
		lua_pop(L, 1);  /* remove variable value */
	}
	return LuaObject(this);
}



int LuaState::LoadWString(const lua_WChar* str)
{
	return luaL_loadwbuffer(m_state, str, lua_WChar_len(str), "name");
}


LuaStackObject LuaState::PushCClosure(int (*f)(LuaState*), int n)
{
	unsigned char* buffer = (unsigned char*)lua_newuserdata(m_state, sizeof(f));
	memcpy(buffer, &f, sizeof(f));
	Insert(-n-1);
	lua_pushcclosure(m_state, LPCD::LuaStateFunctionDispatcher, n + 1);
	return LuaStackObject(this, lua_gettop(m_state));
}

int LuaState::UpValueIndex(int i)
{
	return lua_upvalueindex(i);
}

int LuaState::LoadString(const char* str)
{
	return luaL_loadbuffer(m_state, str, strlen(str), str);
}

int LuaState::DoString( const char *str, LuaObject& fenvObj )
{
	int status = luaL_loadbuffer(m_state, str, strlen(str), str);
	if (status == 0)
	{
		fenvObj.Push();
		SetFEnv(-2);
	}
	return aux_do(m_state, status);
}


LuaObject LuaState::GetGlobal(const char *name)
{
	return GetGlobals()[name];
}


LuaObject LuaState::GetRegistry()
{
	return LuaObject(this, LUA_REGISTRYINDEX);  //{  lua_getregistry(m_state);
}

//ND_MOD
int LuaState::DoFile( const char *filename)
{
	if (IsLuaFile(filename))
	{
		return DoLoadFile(filename);
	}
	else
	{
		return LoadFileBuf(filename);     
	}
	return 0;
}

//ND_MOD
/************************************************************************************************************
 Function:         DoLoadFile
 Description:	   lua通过文件名加载文件
 Input:            filename文件名字
 Output:     
 return:            
 other:
 version:  1. add by tangziqin  2012.8.27   新建函数   
 2.
 ************************************************************************************************************/
int LuaState::DoLoadFile( const char *filename)
{
 	int status = luaL_loadfile(this->GetCState(), filename);
	if (status)
	{
		bool isnil = lua_isnil(this->GetCState(), -1);
		if (!isnil)
		{
			const char* errorString = lua_tostring(this->GetCState(), -1);
			if (GetExceptInfoOutHandler())
			{
				GetExceptInfoOutHandler()(this, errorString);
			}
		}
		return 1;
	}
	
	lua_State *L = this->GetCState();
    
	if (docall(L, 0, LUA_MULTRET) != 0)
	{
		const char* errorString = lua_tostring(L, -1);
        
		if (GetExceptInfoOutHandler())
		{
			GetExceptInfoOutHandler()(this, errorString);
		}
	}
    
	return 0;   
}  

//ND_MOD
/************************************************************************************************************
 Function:         IsLuaFile
 Description:    
 Input:            判断输入文件是否为.lua文件
 Output:     
 other:
 version:  1. add by tangziqin  2012.8.22    
 2.
 ************************************************************************************************************/
bool LuaState::IsLuaFile(const char* pszluaFile)
{
    int iFileTileLen = strlen(pszluaFile); 
    
    // 读取后缀名字
    if (iFileTileLen > 3)
    {
        char strTemp[8];  
        memset(strTemp, 0, sizeof(strTemp));
        
        strcpy(strTemp, (pszluaFile + iFileTileLen - 3));
        if (strcmp(strTemp, "lua") == 0)
        {
            FILE *FileHandle = fopen(pszluaFile, "rb");
            if (FileHandle != NULL)
            {
                fclose(FileHandle);
                return true;
            }
        }
        else if (strcmp(strTemp, "bin") == 0)
        {
            return false;
        }
    }
    return false;
}   

//ND_MOD
/************************************************************************************************************
 Function:         LoadFileBuf
 Description:      以加载buf方式加载文件
 Input:            pszluaFile文件的名字
 Output:     
 other:
 version:  1. add by tangziqin  2012.8.22  新建函数  
 2.
 ************************************************************************************************************/
int LuaState::LoadFileBuf(const char* pszluaFile)
{
	if (!pszluaFile || pszluaFile[0] == 0) return 0;
    FILE *FileHandle = fopen(pszluaFile, "rb");
	
    
    //如果读取不到文件更换文件后缀再试
    if ( FileHandle == NULL) 
    { 
        int iFileTileLen = strlen(pszluaFile); 
        
        //读取后缀名字
        if (iFileTileLen > 3)
        {
			char strNewFileName[1024] = {0};
			char strTemp[8] = {0};  
			char strAddName[8] = {0};  
            memset(strTemp, 0, sizeof(strTemp));
            memset(strAddName, 0, sizeof(strAddName));    
            memset(strNewFileName, 0, 1024);
            
            strcpy(strTemp, (pszluaFile + iFileTileLen - 3));
            if (strcmp(strTemp, "bin") == 0)
            {
                strcpy(strAddName, "lua");
            }
            else if (strcmp(strTemp, "lua") == 0)
            {
                strcpy(strAddName, "bin");
            }
            strncpy(strNewFileName, pszluaFile, iFileTileLen - 3);
            strncpy(strNewFileName + iFileTileLen - 3, strAddName, 3);
          //  strcat(strNewFileName, strAddName);
            FileHandle = fopen(strNewFileName, "rb");
        }
    } 
    
	if (FileHandle == NULL)
	{
		return 0;
	}

	// get file len
    fseek (FileHandle, 0, SEEK_END);
    size_t filesize = ftell(FileHandle);
    fseek(FileHandle, 0, SEEK_SET);
    
	// read file
	int buflen = filesize + 1;
	char *strBuf = new char[buflen];
    size_t nReadNum = fread(strBuf, 1, filesize, FileHandle);
    fclose(FileHandle);

    if( nReadNum != filesize ) 
    { 
        delete []strBuf;
        strBuf = NULL;
        return 0;
    }
    
	//DecryptString
    nReadNum = DecryptString((unsigned char* )strBuf, filesize);
    DoBuffer((const char*)strBuf, nReadNum, pszluaFile); 
    delete []strBuf;
    
    return 1;
}  

//ND_MOD
/************************************************************************************************************
 Function:         DecryptString
 Description:	   文本解密代码
 Input:            buf要解密的buffer, len buffer的长度
 Output:     
 return:           int文本解密后的长度
 other:
 version:  1. add by tangziqin  2012.8.22   新建函数     
 2.
 ************************************************************************************************************/
//static const char ENCRYPT_STR[] = "tqdigital";

static const char STR_CAT[] = "denadhlj";
static char ENCRYPT_STR[11] ;
int LuaState::DecryptString(unsigned char* buf, int len)
{
    int iRet = len;
    ENCRYPT_STR[0] = 'd';
    ENCRYPT_STR[1] = 'e';
    ENCRYPT_STR[2] = 'n';
    ENCRYPT_STR[3] = 'a';
    ENCRYPT_STR[4] = 'b';
    ENCRYPT_STR[5] = 'y';
    ENCRYPT_STR[6] = 'w';
    ENCRYPT_STR[7] = 'x';
    ENCRYPT_STR[8] = 'n';
    ENCRYPT_STR[9] = 'b';
    ENCRYPT_STR[10] = '\0';

    //获取文本后面strlen(ENCRYPT_STR)的长度比较是否与ENCRYPT_STR一致
    int iENum = strlen(STR_CAT);
    if (len <= iENum)
    {
        return iRet;
    }
    
    char strTemp[64];
    memset(strTemp, 0, sizeof(strTemp));
    strncpy(strTemp, ( const char *)(buf + len - iENum - 1), iENum);
    
    //需要解密
    if ( strcmp(strTemp, STR_CAT) == 0)
    {
        iRet = len - strlen(STR_CAT);
         //iRet = len - sizeof(STR_CAT);
        memset((buf + iRet), 0, sizeof(STR_CAT));
 
        for (int i = 0; i < iRet; ++i)
        {
            unsigned char cXor = ENCRYPT_STR[ i % sizeof(ENCRYPT_STR) ];
            unsigned char cOpt = buf[i];
            int num = buf[i];
            cOpt = (cOpt << 4) | (cOpt >> 4);
            buf[i] = cOpt ^ cXor;
            num = buf[i];
        }
    }

    return iRet;
}


int LuaState::DoFile( const char *filename, LuaObject& fenvObj )
{
	int status = luaL_loadfile(m_state, filename);
	if (status == 0)
	{
		fenvObj.Push();
		SetFEnv(-2);
	}
	return aux_do(m_state, status);
}


int LuaState::DoBuffer( const char *buff, size_t size, const char *name, LuaObject& fenvObj )
{
	int status = luaL_loadbuffer(m_state, buff, size, name);
	if (status == 0)
	{
		fenvObj.Push();
		SetFEnv(-2);
	}
	return aux_do(m_state, status);
}


namespace LuaHelper {

LUAPLUS_API void MergeObjects(LuaObject& mergeTo, LuaObject& mergeFrom, bool replaceDuplicates)
{
	if (mergeTo.GetState() == mergeFrom.GetState())
	{
		for (LuaTableIterator it(mergeFrom); it; ++it)
		{
			LuaObject toNodeKeyObj = mergeTo[it.GetKey()];
			if (it.GetValue().IsTable())
			{
				if (toNodeKeyObj.IsNil()  ||  replaceDuplicates)
				{
					toNodeKeyObj = mergeTo.CreateTable(it.GetKey());
				}
				MergeObjects(toNodeKeyObj, it.GetValue(), replaceDuplicates);
			}
			else if (toNodeKeyObj.IsNil()  ||  replaceDuplicates)
			{
				mergeTo.SetObject(it.GetKey(), it.GetValue());
			}
		}
	}
	else
	{
		for (LuaTableIterator it(mergeFrom); it; ++it)
		{
			LuaObject obj;
			switch (it.GetKey().Type())
			{
				case LUA_TBOOLEAN:	obj.AssignBoolean(mergeTo.GetState(), it.GetKey().GetBoolean());		break;
				case LUA_TNUMBER:	obj.AssignNumber(mergeTo.GetState(), it.GetKey().GetNumber());			break;
				case LUA_TSTRING:	obj.AssignString(mergeTo.GetState(), it.GetKey().GetString());			break;
				case LUA_TWSTRING:	obj.AssignWString(mergeTo.GetState(), it.GetKey().GetWString());		break;
			}

			LuaObject toNodeKeyObj = mergeTo[obj];

			if (it.GetValue().IsTable())
			{
				if (toNodeKeyObj.IsNil()  ||  replaceDuplicates)
				{
					toNodeKeyObj = mergeTo.CreateTable(it.GetKey());
				}
				MergeObjects(toNodeKeyObj, it.GetValue(), replaceDuplicates);
			}
			else if (toNodeKeyObj.IsNil()  ||  replaceDuplicates)
			{
				LuaObject toKeyObj;
				switch (it.GetKey().Type())
				{
					case LUA_TBOOLEAN:	toKeyObj.AssignBoolean(mergeTo.GetState(), it.GetKey().GetBoolean());		break;
					case LUA_TNUMBER:	toKeyObj.AssignNumber(mergeTo.GetState(), it.GetKey().GetNumber());			break;
					case LUA_TSTRING:	toKeyObj.AssignString(mergeTo.GetState(), it.GetKey().GetString());			break;
					case LUA_TWSTRING:	toKeyObj.AssignWString(mergeTo.GetState(), it.GetKey().GetWString());		break;
				}

				switch (it.GetValue().Type())
				{
					case LUA_TBOOLEAN:	mergeTo.SetBoolean(toKeyObj, it.GetValue().GetBoolean());	break;
					case LUA_TNUMBER:	mergeTo.SetNumber(toKeyObj, it.GetValue().GetNumber());		break;
					case LUA_TSTRING:	mergeTo.SetString(toKeyObj, it.GetValue().GetString());		break;
					case LUA_TWSTRING:	mergeTo.SetWString(toKeyObj, it.GetValue().GetWString());	break;
				}
			}
		}
	}
}

} // namespace LuaHelper

} // namespace LuaPlus


namespace LPCD
{
	void Push(lua_State* L, int (*value)(LuaState*))
	{
		LuaState* state = LuaState::CastState(L);
		state->PushCClosure(value, 0);
	}
}

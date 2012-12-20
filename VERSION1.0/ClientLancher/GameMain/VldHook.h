//
//  VldHook.h
//
//  Created by zhangwq on 2012-11-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	检测内存泄露
//	备注：检测机制不要很多代码，不要调用new，以免影响VLD正常工作.
//

#pragma once


#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#ifdef _DEBUG
#define WITH_VLD 1
#endif
#endif

#define WITH_VLD 0 //don't compile with VLD.
#if WITH_VLD
	#include "vld.h"
	#define VLD_HOOK	\
		if (0 == VLDSetReportHook( VLD_RPTHOOK_INSTALL, VldHook::vldReport ))	\
			{ CCLog( "[vld] hook report ok.\r\n" ); }
#else
	#define VLD_HOOK
#endif


///////////////////////////////////////////////////////////
class VldHook
{
public:
	enum ACCEPT_MSG_STATE
	{
		E_ACCEPT_PENDING,
		E_ACCEPT_YES,
		E_ACCEPT_NO,
	} state;

private:
	VldHook() : state(E_ACCEPT_NO) {}

public:
	static VldHook& instance()
	{
		static VldHook s_obj;
		return s_obj;
	}

	ACCEPT_MSG_STATE& getState() { return state; }

	/*cdecl*/ static int vldReport(int reportType, wchar_t *message, int *returnValue)
	{
		static bool s_noReport = false;
		if (s_noReport) { return 1; } //discard.

		//return 0;
		ACCEPT_MSG_STATE& theState = VldHook::instance().getState();

		// check key word
		bool isCallStack = false;
		if (wcsstr( message, L"Call Stack:" ) != NULL)
		{
			isCallStack = true;
			theState = E_ACCEPT_PENDING;
		}
		else if (wcsstr( message, L"Data:" ) != NULL)
		{
			theState = E_ACCEPT_NO;
		}

		// pending -> yes
		bool bAccept = false;
		if (theState == E_ACCEPT_NO)
		{
			bAccept = false;
		}
		else if (theState == E_ACCEPT_PENDING)
		{
			if (isCallStack)
			{
				bAccept = false;
			}
			else if (VldHook::instance().isMessageImportant( message ))
			{
				CCLog( "Call Stack:");
				theState = E_ACCEPT_YES;
				bAccept = true;
			}
			else
			{
				theState = E_ACCEPT_NO;
				bAccept = false;
			}
		}
		else if (theState == E_ACCEPT_YES)
		{
			bAccept = VldHook::instance().isMessageImportant( message );
		}
		return (bAccept ? 0 : 1);
	}

	bool isMessageImportant( wchar_t *message )
	{
		if (!message) return false;

		wchar_t* key[] = {
			L"\\clientengine\\",
			L"\\clientlancher\\",
			L"\\clientlogic\\",
			L"\\cocos2d-x\\",
			L"\\network\\",
#if 0
			L"\\kutil\\",
			L"\\libiconv\\",
			L"\\libs\\",
			L"\\mobagesdk\\",
			L"\\pthreads\\",
			L"\\sqlite3\\",
			L"\\tinyxml\\",
#endif
			//L"\\test\\",
		};

		wchar_t* skip[] = {
			L"\\graphic\\",
			L"\\luastatemgr.cpp",
			L"\\ndprofile.h",
			L"\\singleton.h",
			L"\\luaplushelper.h",
			L"\\scriptgamedata_new.h",
		};

		// check if it's important
		bool bMatch = false;
		int n = sizeof(key) / sizeof(key[0]);
		for (int i = 0; i < n; i++)
		{
			if (wcsstr(message, key[i]) != 0)
			{
				bMatch = true;
				break;;
			}
		}

		// check if to skip
		bool bSkip = false;
		if (bMatch)
		{
			int n = sizeof(skip) / sizeof(skip[0]);
			for (int i = 0; i < n; i++)
			{
				if (wcsstr(message, skip[i]) != 0)
				{
					bSkip = true;
					break;;
				}
			}			
		}

		return bMatch && !bSkip;
	}
};

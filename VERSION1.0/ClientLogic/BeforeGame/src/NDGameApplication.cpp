#include "NDGameApplication.h"
#include "NDDirector.h"
#include "SMLoginScene.h"
#include "CCEGLView.h"
#include "NDPath.h"
#include "ScriptCommon.h"
#include "ScriptGlobalEvent.h"
#include "ScriptNetMsg.h"
#include "ScriptUI.h"
#include "ScriptGameLogic.h"
#include "SMGameScene.h"
#include "GameScene.h"
#include "ScriptTimer.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "NDNpc.h"
#include "ScriptDrama.h"
#include <ScriptGameLogic.h>
#include <NDSocket.h>
#include "NDMapMgr.h"
#include "LuaStateMgr.h"
#include "NDBeforeGameMgr.h"
#include "ScriptGameData.h"
#include "NDDebugOpt.h"
#include "NDClassFactory.h"
#include "Battle.h"
#include "NDProfile.h"
#include "NDBaseDirector.h"

#if 0
#include "HelloWorldScene.h" //@todo
#endif

NS_NDENGINE_BGN
using namespace NDEngine;

NDGameApplication::NDGameApplication()
{
	NDConsole::GetSingletonPtr()->RegisterConsoleHandler(this,"script ");
}
NDGameApplication::~NDGameApplication()
{
}

bool NDGameApplication::applicationDidFinishLaunching()
{
	CCDirector* pDirector = CCDirector::sharedDirector();
	CCAssert(pDirector);
	pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

	TargetPlatform target = getTargetPlatform();

	if (target == kTargetIpad)
	{
		// ipad

		CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");

		// don't enable retina because we don't have ipad hd resource
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(960, 640, kResolutionNoBorder);
	}
	else if (target == kTargetIphone)
	{
		// iphone

		// try to enable retina on device
		if (true == CCDirector::sharedDirector()->enableRetinaDisplay(true))
		{
			// iphone hd
			CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");
		}
		else 
		{
			CCFileUtils::sharedFileUtils()->setResourceDirectory("iphone");
		}
	}
	else 
	{
		// android, windows, blackberry, linux or mac
		// use 960*640 resources as design resolution size
		//CCFileUtils::sharedFileUtils()->setResourceDirectory("iphonehd");
		//CCEGLView::sharedOpenGLView()->setDesignResolutionSize(480*2, 320*2, kResolutionNoBorder);//@todo
		//CCDirector::sharedDirector()->enableRetinaDisplay(true);//@retina

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

		// initialize socket
		InitSocket();

		// Initialize OpenGLView instance, that release by CCDirector when application terminate.
		// The HelloWorld is designed as HVGA.
		NDPath::SetResPath( "../../Bin/SimplifiedChineseRes/res/" );
#endif
	}

	// turn on display FPS
	//pDirector->setDisplayStats(true); //@fps 

	// set FPS. the default value is 1.0/60 if you don't call this
	//pDirector->setAnimationInterval(1.0 / 60);
	pDirector->setAnimationInterval(1.0 / 24);

#if 0 //@todo @hello
 	// create a scene. it's an autorelease object
 	CCScene *pScene = HelloWorld::scene();
 
 	// run
 	pDirector->runWithScene(pScene);
	//////////////////////////////////////////////
#else
	this->MyInit();
#endif


	return true;
}

void NDGameApplication::MyInit()
{
	REGISTER_CLASS(NDBaseBattle,Battle);
	REGISTER_CLASS(NDBaseFighter,Fighter);

	NDSprite* pkSprite = CREATE_CLASS(NDSprite,"NDBaseRole");

	NDMapMgr& kMapMgr = NDMapMgrObj;
	ScriptMgr &kScriptManager = ScriptMgr::GetSingleton();
	NDBeforeGameMgrObj;

	NDDirector* pkDirector = NDDirector::DefaultDirector();
	pkDirector->Initialization();
	pkDirector->RunScene(CSMLoginScene::Scene());

//	kMapMgr.processChangeRoom(0,0);

#if 0 //@todo
	ScriptNetMsg* pkNetMsg = new ScriptNetMsg;
	ScriptObjectGameLogic* pkLogic = new ScriptObjectGameLogic;
	NDScriptGameData* pkData = new NDScriptGameData;
	//ScriptGlobalEvent* pkGlobalEvent = new ScriptGlobalEvent;
	ScriptObjectCommon* pkCommon = new ScriptObjectCommon;
	ScriptObjectUI* pkScriptUI = new ScriptObjectUI;
	ScriptTimerMgr* pkTimerManager = new ScriptTimerMgr;
	ScriptObjectDrama* pkDrama = new ScriptObjectDrama;

	pkData->Load();
	pkTimerManager->OnLoad();
	pkNetMsg->OnLoad();
	pkLogic->OnLoad();
	pkDrama->OnLoad();
	pkCommon->OnLoad();
	ScriptGlobalEvent::Load();
	//pkGlobalEvent->OnLoad();
	pkScriptUI->OnLoad();
#endif

	//kScriptManager.Load();
	ScriptMgrObj.Load();

	//CC_SAFE_DELETE(pkNetMsg);

	//ScriptGlobalEvent::OnEvent (GE_GENERATE_GAMESCENE);
	
	ScriptGlobalEvent::OnEvent(GE_LOGIN_GAME);

	//NDPlayer::pugeHero();
	//NDPlayer& kPlayer = NDPlayer::defaultHero(1);

	//int x = 100;
	//int y = 100;

 // 	kPlayer.SetPosition(ccp(528, 512));		///< x * 32 + 16, y * 32 + 16
 // 	kPlayer.SetServerPositon(x, y);
 // 	kPlayer.m_nID = 1;
 // 	kPlayer.m_strName = "白富美";
 // 	kPlayer.SetLoadMapComplete();
 // 
 //  	CSMGameScene* pkScene = (CSMGameScene*)pkDirector->GetRunningScene();
 //  	NDNode* pkNode = pkScene->GetChild(MAPLAYER_TAG);
 //  
 //  	if (!pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
 //  	{
 //  		return false;
 //  	}
 //  
 //  	NDMapLayer* pkLayer = (NDMapLayer*) pkNode;
 //  	pkLayer->AddChild(&kPlayer, 111, 1000);
 //  	kPlayer.standAction(true);
 //  	//pkScene->setUpdatePlayer(&kPlayer);
 // 
 //  	//add by ZhangDi 120904
 //  	//DramaObj.Start();
 //  
 //   //	DramaCommandScene* commandScene = new DramaCommandScene;
 //   //	commandScene->InitWithLoadDrama(5);
 //  	//DramaObj.AddCommond(commandScene);
 //  
 //  
 //  	//DramaCommandSprite* commandSprite = new DramaCommandSprite;
 //  	//commandSprite->InitWithAdd(31000112, ST_NPC, FALSE, "华佗");
 //  	////commandSprite->InitWithSetPos(command->GetKey(), 9, 11);
 //  	//DramaObj.AddCommond(commandSprite);
 // 
 // 
 // 	for (int i = 0; i < 4; i++)
 // 	{
 // 		NDNpc* npc = new NDNpc;
 // 		npc->m_nID = 10001 + i;
 // 		//npc->col = 9;
 // 		//npc->row = 11;
 // 		//npc->look = 31000112;
 // 
 // 		switch (i)
 // 		{
 // 		case 0:
 // 			npc->m_strName = "郭嘉";
 // 			break;
 // 		case 1:
 // 			npc->m_strName = "华佗";
 // 			break;
 // 		case 2:
 // 			npc->m_strName = "袁绍";
 // 			break;
 // 		case 3:
 // 			npc->m_strName = "刘表";
 // 			break;
 // 		default:
 // 			npc->m_strName = "西门无名";
 // 			break;
 // 		}
 // 
 // 		npc->Initialization(111 + i);		//31000112
 // 		npc->SetPosition(
 // 				ccp((5 + i * 6) * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
 // 						11 * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
 // 
 // 		//npc->dataStr = "哈哈";
 // 		//npc->talkStr = "你想知道什么？";
 // 		npc->SetType(0);
 // 		//npc->SetActionOnRing(FALSE);
 // 		//npc->SetDirectOnTalk(FALSE);
 // 		//npc->initUnpassPoint();
 // 
 // 		if (!pkLayer->ContainChild(npc))
 // 		{
 // 			pkLayer->AddChild((NDNode *) npc, 100 + i, 10001 + i);
 // 			//npc->HandleNpcMask(TRUE);
 // 		}
 // 
 // 		NDPlayer::defaultHero().UpdateFocus();
 // 	}

	// 现在这里登陆
	// SwichKeyToServer("192.168.9.47", 9500/*9528*/, "285929910", "", "xx");
}

void NDGameApplication::applicationDidEnterBackground()
{
	CCDirector::sharedDirector()->stopAnimation();

	// if you use SimpleAudioEngine, it must be pause
	// SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

void NDGameApplication::applicationWillEnterForeground()
{
	CCDirector::sharedDirector()->startAnimation();

	// if you use SimpleAudioEngine, it must resume here
	// SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}

//@pm
bool NDGameApplication::processConsole( const char* pszInput )
{
	if (0 == pszInput || !*pszInput)
	{
		return false;
	}

	LuaStateMgrObj.GetState().m_state->DoString(pszInput);

	return true;
}

//@pm
bool NDGameApplication::processPM(const char* cmd) 
{
	if (cmd == 0 || cmd[0] == 0) return false;

	int val = 0;
	char szDebugOpt[50] = {0};

	HANDLE hOut = NDConsole::GetSingletonPtr()->getOutputHandle();

	if (stricmp(cmd, "opt help") == 0)
	{
		TCHAR help[] =	L"syntax: opt arg 0/1\r\n"
			L"arg can be: tick, script, network, mainloop, drawhud, drawui, drawmap, drawrole, drawrolenpc, drawrolemonster, drawroleplayer, drawrolemanual.\r\n";

		DWORD n = 0;
		WriteConsoleW( hOut, help, sizeof(help)/sizeof(TCHAR), &n, NULL );
	}
	else if (sscanf(cmd, "opt %s %d", szDebugOpt, &val) == 2)
	{
		if (stricmp(szDebugOpt, "tick") == 0)
			NDDebugOpt::setTickEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "script") == 0)
			NDDebugOpt::setScriptEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "network") == 0)
			NDDebugOpt::setNetworkEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "mainloop") == 0)
			NDDebugOpt::setMainLoopEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawhud") == 0)
			NDDebugOpt::setDrawHudEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawui") == 0)
			NDDebugOpt::setDrawUIEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawmap") == 0)
			NDDebugOpt::setDrawMapEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawrole") == 0)
			NDDebugOpt::setDrawRoleEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawrolenpc") == 0)
			NDDebugOpt::setDrawRoleNpcEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawrolemonster") == 0)
			NDDebugOpt::setDrawRoleMonsterEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawroleplayer") == 0)
			NDDebugOpt::setDrawRolePlayerEnabled( val != 0 );

		else if (stricmp(szDebugOpt, "drawrolemanual") == 0)
			NDDebugOpt::setDrawRoleManualEnabled( val != 0 );
	}
	else if (sscanf(cmd, "openmap %d", &val) == 1)
	{
		//NDMapMgrObj.Hack_loadSceneByMapDocID( val );
	}
	else if (stricmp(cmd, "profile") == 0)
	{
		NDProfileReport::report();
	}
	else if (stricmp(cmd, "profile dump") == 0)
	{
		NDProfileReport::dump();
	}
	else
	{
		DWORD n = 0;
		TCHAR msg[] = L"err: unknown cmd.\r\n";
		WriteConsole( hOut, msg, sizeof(msg)/sizeof(TCHAR), &n, NULL );
	}
	return true;
}

NS_NDENGINE_END
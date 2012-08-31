#include "NDGameApplication.h"
#include "NDDirector.h"
#include "SMLoginScene.h"
#include "../../../cocos2d-x/cocos2dx/platform/CCEGLView_platform.h"
#include "NDPath.h"
#include "GameData.h"
#include "ScriptCommon.h"
#include "ScriptGlobalEvent.h"
#include "ScriptUI.h"
#include "ScriptGameLogic.h"
#include "SMGameScene.h"
#include "GameScene.h"
#include "ScriptTimer.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "NDConstant.h"

namespace NDEngine
{
NDGameApplication::NDGameApplication()
{
}
NDGameApplication::~NDGameApplication()
{
}

bool NDGameApplication::initInstance()
{
	bool bRet = false;
	do
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

		// Initialize OpenGLView instance, that release by CCDirector when application terminate.
		// The HelloWorld is designed as HVGA.
		NDPath::SetResPath(
				"../../SMYS_CLIENT_IPHONE/SimplifiedChineseRes/res/");
		CCEGLView* pMainWnd = new CCEGLView();
		CC_BREAK_IF(!pMainWnd || !pMainWnd->Create(L"大话龙将", 320, 480));

#endif  // CC_PLATFORM_WIN32
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

		// OpenGLView initialized in testsAppDelegate.mm on ios platform, nothing need to do here.

#endif  // CC_PLATFORM_IOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

		// OpenGLView initialized in HelloWorld/android/jni/helloworld/main.cpp
		// the default setting is to create a fullscreen view
		// if you want to use auto-scale, please enable view->create(320,480) in main.cpp
		// if the resources under '/sdcard" or other writeable path, set it.
		// warning: the audio source should in assets/
		// cocos2d::CCFileUtils::setResourcePath("/sdcard");

#endif  // CC_PLATFORM_ANDROID
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WOPHONE)

		// Initialize OpenGLView instance, that release by CCDirector when application terminate.
		// The HelloWorld is designed as HVGA.
		CCEGLView* pMainWnd = new CCEGLView(this);
		CC_BREAK_IF(! pMainWnd || ! pMainWnd->Create(320,480, WM_WINDOW_ROTATE_MODE_CW));

#ifndef _TRANZDA_VM_  
		// on wophone emulator, we copy resources files to Work7/NEWPLUS/TDA_DATA/Data/ folder instead of zip file
		cocos2d::CCFileUtils::setResource("HelloWorld.zip");
#endif

#endif  // CC_PLATFORM_WOPHONE
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MARMALADE)
		// MaxAksenov said it's NOT a very elegant solution. I agree, haha
		CCDirector::sharedDirector()->setDeviceOrientation(kCCDeviceOrientationLandscapeLeft);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)

		// Initialize OpenGLView instance, that release by CCDirector when application terminate.
		// The HelloWorld is designed as HVGA.
		CCEGLView * pMainWnd = new CCEGLView();
		CC_BREAK_IF(! pMainWnd
				|| ! pMainWnd->Create("cocos2d: Hello World", 480, 320 ,480, 320));

		CCFileUtils::setResourcePath("../Resources/");

#endif  // CC_PLATFORM_LINUX
#if (CC_TARGET_PLATFORM == CC_PLATFORM_BADA)

		CCEGLView * pMainWnd = new CCEGLView();
		CC_BREAK_IF(! pMainWnd|| ! pMainWnd->Create(this, 480, 320));
		pMainWnd->setDeviceOrientation(Osp::Ui::ORIENTATION_LANDSCAPE);
		CCFileUtils::setResourcePath("/Res/");

#endif  // CC_PLATFORM_BADA
#if (CC_TARGET_PLATFORM == CC_PLATFORM_QNX)
		CCEGLView * pMainWnd = new CCEGLView();
		CC_BREAK_IF(! pMainWnd|| ! pMainWnd->Create(1024, 600));
		CCFileUtils::setResourcePath("app/native/Resources");
#endif // CC_PLATFORM_QNX
		bRet = true;
	} while (0);

	return bRet;
}

bool NDGameApplication::applicationDidFinishLaunching()
{
	NDDirector* pkDirector = NDDirector::DefaultDirector();
	ScriptMgr kScriptManager = ScriptMgr::GetSingleton();

	pkDirector->Initialization();
	pkDirector->RunScene(GameScene::Scene());

	ScriptObjectGameLogic* pkLogic = new ScriptObjectGameLogic;
	NDScriptGameData* pkData = new NDScriptGameData;
	ScriptGlobalEvent* pkGlobalEvent = new ScriptGlobalEvent;
	ScriptObjectCommon* pkCommon = new ScriptObjectCommon;
	ScriptObjectUI* pkScriptUI = new ScriptObjectUI;
	ScriptTimerMgr* pkTimerManager = new ScriptTimerMgr;

	pkData->Load();
	pkTimerManager->OnLoad();
	pkLogic->OnLoad();
	pkCommon->OnLoad();
	pkGlobalEvent->OnLoad();
	pkScriptUI->OnLoad();

	kScriptManager.Load();

	ScriptGlobalEvent::OnEvent (GE_GENERATE_GAMESCENE);
		ScriptGlobalEvent::OnEvent(GE_LOGIN_GAME);

	NDPlayer::pugeHero();
	NDPlayer& kPlayer = NDPlayer::defaultHero(1);

	int x = 100;
	int y = 100;

	kPlayer.SetPositionEx(ccp(500, 500));		///< x * 32 + 16, y * 32 + 16
	kPlayer.SetServerPositon(x, y);
	kPlayer.m_nID = 1;
	kPlayer.m_name = "白富美";
	kPlayer.SetLoadMapComplete();

	NDScene* pkScene = pkDirector->GetRunningScene();
	NDNode* pkNode = pkScene->GetChild(MAPLAYER_TAG);

	if (!pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return false;
	}

	NDMapLayer* pkLayer = (NDMapLayer*) pkNode;
	pkLayer->AddChild(&kPlayer, 111, 1000);

	return true;
}

void NDGameApplication::applicationDidEnterBackground()
{
}
void NDGameApplication::applicationWillEnterForeground()
{
}

}
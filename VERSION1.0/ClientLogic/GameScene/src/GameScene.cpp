/*
 *  GameScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-29.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "GameUIAttrib.h"
#include <GameUIPetAttrib.h>
#include "InitMenuScene.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "define.h"
#include "NDUIFrame.h"
#include "WorldMapScene.h"
#include "NDUIButton.h"
//#include "CCPointExtension.h"
#include "GameSettingScene.h"
#include "NDMiniMap.h"
//#include "NDDataPersist.h"
///< #include "NDMapMgr.h" 临时性注�?? 郭浩
#include "NDUISynLayer.h"
#include "NDDataTransThread.h"
#include "NDNpc.h"
#include "GamePlayerBagScene.h"
#include "NDUISynLayer.h"
#include "ItemMgr.h"
#include "InitMenuScene.h"
#include "GameUITaskList.h"
#include "BattleMgr.h"
#include "GlobalDialog.h"
#include "Task.h"
#include "GameUIPlayerList.h"
//#include "GameUIRequest.h"
#include "GoodFriendUILayer.h"
//#include "GameUIPaiHang.h" ///< 临时性注�?? 郭浩
#include "TutorUILayer.h"
#include "GameUINpcStore.h"
#include "UserStateUILayer.h"
#include "UserStateLayer.h"
#include "VendorUILayer.h"
#include "GameScene.h"
#include "GameUIBattleSkill.h"
#include "LifeSkillScene.h"
#include "VendorBuyUILayer.h"
#include "VipStoreScene.h"
#include "ChatRecordManager.h"
#include "PetSkillScene.h"
#include "SyndicateCommon.h"
//#include "EmailSendScene.h"
//#include "EmailRecvScene.h"
#include "SyndicateInvite.h"
//#include "ChatInput.h"
#include "NDBeforeGameMgr.h"
#include "NpcList.h"
#include "NDLightEffect.h"
#include "NDPath.h"
#include "UpdateScene.h"
#include "FarmMgr.h"
#include "RanchProductDlg.h"
#include "PlayerInfoScene.h"
#include "QuickInteraction.h"
//#include "QuickItem.h"
//#include "QuickFunc.h"
//#include "QuickTeam.h"
//#include "RequestListScene.h"
//#include "NewVipStoreScene.h"
#include "BattleFieldScene.h"
#include "NDUISpecialLayer.h"

#include <sstream>
#include "NDPicture.h"
#include "NDDataSource.h"
#include "ScriptMgr.h"

const int TAG_CV_SEND_QUESTION = 1;
const int TAG_CV_CHANG_PWD = 2;

const unsigned int TAG_UPDATE_FORCE = 333;
const unsigned int TAG_UPDATE_NOT_FORCE = 444;

const char* MENU_SYNDICATE[6] =
{ "1", "2", "3", "4", "5", "6" };
const char* MENU_SYN_MANAGE[9] =
{ "1", "2", "3", "4", "5", "6", "7", "8", "9" };

IMPLEMENT_CLASS(MapUILayer, NDUILayer)

///////////////////////////////////////////////

enum
{
	interactive_begin = 0,
	interactive_playinfo = interactive_begin,
	interactive_equipinfo,
	interactive_aviteteam,
	interactive_trade,
	interactive_addfriend,
	interactive_chat,
	interactive_pk,
	interactive_duel,
	interactive_petinfo,
	interactive_viewvendor,
	interactive_end,
};

enum MENU_TYPE
{
	MT_DUI_WU = 1,
};

/***
* ��ʱ���޸� ����
* @warning ��Щ�ַ����Ǳ��벻���ġ���
*/
static std::string interactive_str[interactive_end] =
{ "1", "1", "1", "1", "1", "1", "1", "1", "1", };

using namespace NDEngine;

//////////////////////////////////////////////////
IMPLEMENT_CLASS(GameScene, NDScene)

bool GameScene::bWeaponBroken = false;
bool GameScene::bDefBroken = false;
bool GameScene::bRidePetBroken = false;

GameScene* GameScene::Scene()
{
	GameScene* scene = new GameScene();
	scene->Initialization(1);
	return scene;
}

void GameScene::AddUserState(int idState, string& str)
{
	//m_userState->AddStateLabel(idState, str); ///< 临时性注�?? 郭浩
}

void GameScene::DelUserState(int idState)
{
//	m_userState->RemoveStateLabel(idState);
}

void GameScene::SetUIShow(bool bShow)
{
	m_bUIShow = bShow;

	if (m_bUIShow)
	{ // 玩家操作UI时需要停止寻路等放这
		NDPlayer& player = NDPlayer::defaultHero();
		if (player.isTeamLeader() || !player.isTeamMember())
		{
			player.stopMoving();
		}
	}
	else
	{
		if (!m_stackUIMenu.empty())
		{
			int menuType = m_stackUIMenu.front();
			m_stackUIMenu.pop_front();

			switch (menuType)
			{
			case MT_DUI_WU:
				onClickTeam();
				break;
			default:
				break;
			}
		}
	}
}

GameScene* GameScene::s_curGameScene = NULL;
MAP_POS_TEXT GameScene::s_mapPosText;

GameScene* GameScene::GetCurGameScene()
{
	return s_curGameScene;
}

void GameScene::SetTargetHead(NDBaseRole* target)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	if (m_targetHead) 
// 	{
// 		if (!target)
// 		{
// 			m_targetHead->RemoveFromParent(false);
// 		} 
// 		else
// 		{
// 			//m_targetHead->SetRole(target); ///< 临时性注�?? 郭浩
// 
// 			if (m_targetHead->GetParent() == NULL) 
// 			{
// 				AddUIChild(m_targetHead);
// 			}
// 		}
// 	}
}

void GameScene::RefreshQuickInterationBar(NDBaseRole* target)
{
	if (m_quickInteration)
	{
		//m_quickInteration->Refresh(target); ///< 临时性注�?? 郭浩
		return;
	}
}

GameScene::GameScene()
{
	s_curGameScene = this;

//	m_userState = NULL; ///< 临时性注�?? 郭浩
//	m_playerHead = NULL; ///< 临时性注�?? 郭浩
//	m_targetHead = NULL; ///< 临时性注�?? 郭浩
//	m_petHead = NULL; ///< 临时性注�?? 郭浩
// 	m_tlRelieve = NULL;
// 	m_relieveLayer = NULL;
// 	m_pkMapLayerLogic = NULL;
// 
// 	m_hccOPItem = NULL;
// 
// 	m_pkUpdatePlayer = 0;
// 
// 	m_picMap = new NDPicture();
// 	m_picMap->Initialization(NDPath::GetFullImagepath("ui_map.png"));
// 	m_btnMap = NULL;
// 
// 	m_picTarget = new NDPicture();
// 	m_picTarget->Initialization(NDPath::GetFullImagepath("ui_target.png"));
// 	m_btnTarget = NULL;
// 
// 	m_picInterative = new NDPicture();
// 	m_picInterative->Initialization(
// 			NDPath::GetFullImagepath("ui_interective.png"));
// 	m_btnInterative = NULL;
// 
// 	//m_hccOPMenu = NULL;		///< 临时性注�?? 郭浩
// 
// 	m_picTeam = new NDPicture();
// 	m_picTeam->Initialization(NDPath::GetFullImagepath("ui_team.png"));
// 	m_btnTeam = NULL;
// 
// 	m_picSocial = new NDPicture();
// 	m_picSocial->Initialization(NDPath::GetFullImagepath("ui_social.png"));
// 	m_btnSocial = NULL;
// 
// 	m_picTalk = new NDPicture();
// 	m_picTalk->Initialization(NDPath::GetFullImagepath("ui_talk.png"));
// 	m_btnTalk = NULL;
// 
// 	m_picTask = new NDPicture();
// 	m_picTask->Initialization(NDPath::GetFullImagepath("ui_task.png"));
// 	m_btnTask = NULL;
// 
// 	m_picBag = new NDPicture();
// 	m_picBag->Initialization(NDPath::GetFullImagepath("ui_bag.png"));
// 	m_btnBag = NULL;
// 
// 	m_picStore = new NDPicture();
// 	m_picStore->Initialization(NDPath::GetFullImagepath("ui_store.png"));
// 	m_btnStore = NULL;
// 
// 	m_picMenu = new NDPicture();
// 	m_picMenu->Initialization(NDPath::GetFullImagepath("ui_menu.png"));
// 	m_btnMenu = NULL;
// 
// 	m_tlShare = NULL;

	//m_anilayerRequest = NULL;		///< 临时性注�?? 郭浩
	//m_anilayerMail = NULL;		///< 临时性注�?? 郭浩

	//m_dlgNPC = NULL;
	m_dlgTaskAwardItemTag = ID_NONE;
	m_dlgTaskAwardItemConfirmTag = ID_NONE;
	m_dlgSyndicateResign = ID_NONE;
	m_dlgSyndicateQuit = ID_NONE;
	m_dlgDelRoleTag = ID_NONE;
	m_curSelTaskAwardItemIndex = 0;

	m_tlInteractive = NULL;

	SetWeaponBroken(false);

	SetDefBroken(false);

	SetRidePetBroken(false);

	m_bUIShow = false;

	m_uiNPCTagDialog = -1;

	m_tlInvitePlayers = NULL;

	m_tlKickPlayers = NULL;
	m_tlTiShengPlayers = NULL;
	m_tlPaiHang = NULL;
	m_tlMarriage = NULL;
	m_uiLayer = NULL;

	m_dlgFarm = NULL;
//	m_directKey = NULL; ///< 临时性注�?? 郭浩

	m_quickItem = NULL;

//	m_quickFunc = NULL; ///< 临时性注�?? 郭浩

	m_quickTeam = NULL;
}

GameScene::~GameScene()
{
	if (s_curGameScene == this)
	{
		s_curGameScene = NULL;
	}

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	if (m_targetHead && m_targetHead->GetParent() == NULL)
// 	{
// 		SAFE_DELETE(m_targetHead);
// 	}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	BattleMgrObj.quitBattle(false);
	SAFE_DELETE (m_picMap);
	SAFE_DELETE (m_picTarget);
	SAFE_DELETE (m_picInterative);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */

// 	if (m_hccOPItem) {
// 		NDMapMgrObj.bRootItemZhangKai = m_hccOPItem->IsZhangKai();
// 	}
// 
// 	if (m_hccOPMenu) {
// 		NDMapMgrObj.bRootMenuZhangKai = m_hccOPMenu->IsZhangKai();
// 	}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	/*
	 if (m_directKey && m_directKey->GetParent() == NULL)
	 {
	 delete m_directKey;
	 m_directKey = NULL;
	 }
	 */

	if (m_uiLayer->GetParent() == NULL)
	{
		SAFE_DELETE(m_uiLayer);
	}
}

void GameScene::AddUIChild(NDNode* node)
{
	m_uiLayer->AddChild(node);
}

void GameScene::AddUIChild(NDNode* node, int z)
{
	m_uiLayer->AddChild(node, z);
}

void GameScene::AddUIChild(NDNode* node, int z, int tag)
{
	m_uiLayer->AddChild(node, z, tag);
}

void GameScene::OnBattleEnd()
{
	//AddChild(m_uiLayer);
	GlobalDialogObj.SetInBattle(false);

//	if (m_directKey)
//		m_directKey->OnBattleEnd();
//		
//	if (m_quickItem)
//	{
//		m_quickItem->RefreshUI();
//		m_quickItem->SetShrink(m_quickItem->IsShrink());
//	}
}

void GameScene::OnBattleBegin()
{
	GlobalDialogObj.SetInBattle(true);

	RemoveChild(m_uiLayer, false);

	std::vector<NDNode*> vDel;

	std::vector<NDNode*>::iterator it = m_kChildrenList.begin();

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
	//for (; it != m_childrenList.end(); it++) 
	//{
	//	if ((*it)->IsKindOfClass(RUNTIME_CLASS(NDMapLayerLogic)) ||
	//	    (*it)->IsKindOfClass(RUNTIME_CLASS(TextControl)) ||
	//	    (*it)->IsKindOfClass(RUNTIME_CLASS(NDUIScrollText)) ||
	//		(*it)->IsKindOfClass(RUNTIME_CLASS(TalkBox)) ||
	//(*it)->IsKindOfClass(RUNTIME_CLASS(NDUIDirectKeyTop)) ||
	//(*it)->IsKindOfClass(RUNTIME_CLASS(BattleFieldRelive)) ||
	//(*it)->IsKindOfClass(RUNTIME_CLASS(NDUIMaskLayer)) )
	//		)
	//	{
	//		if ((*it)->IsKindOfClass(RUNTIME_CLASS(TalkBox))) ((NDUINode*)(*it))->SetVisible(false);
	//			continue;
	//	} 
	//	else 
	//	{
	//		vDel.push_back(*it);
	//	}
	//}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	for (it = vDel.begin(); it != vDel.end(); it++)
	{
		if ((*it)->IsKindOfClass(RUNTIME_CLASS(NDUIDialog)))
		{
			if (!(*it)->IsKindOfClass(RUNTIME_CLASS(GameQuitDialog)))
			{
				((NDUIDialog*) (*it))->Close();
			}
		}
		else
		{
			(*it)->RemoveFromParent(true);
		}
	}

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	if (m_directKey)
// 		m_directKey->OnBattleBegin();
// 		
// 	if (m_quickFunc)
// 		m_quickFunc->OnBattleBegin();
// 		
// 	if (m_quickInteration)
// 		m_quickInteration->OnBattleBegin();
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */
}

void GameScene::Initialization(int mapID)
{
	NDScene::Initialization();

	m_timer.SetTimer(this, 1, 1);

	// test
	//m_timer.SetTimer(this, 2, 1.5f);

	m_bHeadShow = true;

	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();

	m_pkMapLayerLogic = new NDMapLayerLogic();
	m_pkMapLayerLogic->Initialization(mapID);
	AddChild(m_pkMapLayerLogic, MAPLAYER_Z, MAPLAYER_TAG);

	m_uiLayer = new MapUILayer;
	m_uiLayer->Initialization();
	AddChild(m_uiLayer, MAP_UILAYER_Z);

	// 确保方向键最先加入到uilayer
	ShowDirectKey(true);
	/*
	 do
	 {
	 m_hccOPItem = new NDUIHControlContainer;
	 m_hccOPItem->Initialization();
	 m_hccOPItem->SetFrameRect(CCRectMake(480-103, 120, 40, 200+2));
	 m_hccOPItem->SetRectInit(CCRectMake(480-103, 120, 40, 200+2));
	 m_hccOPItem->SetButtonName("ui_menu_scroll.png");
	 m_hccOPItem->SetUINodeInterval(20);

	 m_btnMap = new NDUIButton;
	 m_btnMap->Initialization();
	 m_btnMap->SetImage(m_picMap);
	 m_btnMap->SetDelegate(this);
	 m_btnMap->SetFrameRect(CCRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnMap);

	 m_btnTarget = new NDUIButton;
	 m_btnTarget->Initialization();
	 m_btnTarget->SetImage(m_picTarget);
	 m_btnTarget->SetDelegate(this);
	 m_btnTarget->SetFrameRect(CCRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnTarget);

	 m_btnInterative = new NDUIButton;
	 m_btnInterative->Initialization();
	 m_btnInterative->SetImage(m_picInterative);
	 m_btnInterative->SetDelegate(this);
	 m_btnInterative->SetFrameRect(CCRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnInterative);

	 m_hccOPItem->SetDelegate(this);

	 AddUIChild(m_hccOPItem);
	 } while (0);

	 do
	 {
	 m_hccOPMenu = new NDUIHControlContainer;
	 m_hccOPMenu->Initialization();
	 m_hccOPMenu->SetFrameRect(CCRectMake(480-40, 0, 40, 320));
	 m_hccOPMenu->SetRectInit(CCRectMake(480-40, 0, 40, 320));
	 m_hccOPMenu->SetButtonName("ui_item_scroll.png");
	 m_hccOPMenu->SetUINodeInterval(0);
	 m_hccOPMenu->SetBGImage("ui_menu_line.png");

	 #define fastinit(btn,pic) \
do \
{ \
NDUILayer *layer = new NDUILayer; \
layer->Initialization(); \
layer->SetFrameRect(CCRectMake(0, 0, 40, 40)); \
layer->SetBackgroundImage(GetImgPath("ui_btn_bg.png")); \
m_hccOPMenu->AddUINode(layer); \
btn = new NDUIButton; \
btn->Initialization(); \
btn->SetImage(pic); \
btn->SetDelegate(this); \
btn->SetFrameRect(CCRectMake(0, 0, 40, 40)); \
layer->AddChild(btn); \
} while (0);

	 fastinit(m_btnTeam, m_picTeam)
	 fastinit(m_btnSocial, m_picSocial)
	 fastinit(m_btnTalk, m_picTalk)
	 fastinit(m_btnTask, m_picTask)
	 fastinit(m_btnBag, m_picBag)
	 fastinit(m_btnStore, m_picStore)
	 fastinit(m_btnMenu, m_picMenu)
	 #undef fastinit

	 m_hccOPMenu->SetDelegate(this);
	 AddUIChild(m_hccOPMenu);
	 } while (0); */

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_anilayerRequest = new NDUIAniLayer;
// 	m_anilayerRequest->Initialization("cuebubble.spr");
// 	m_anilayerRequest->SetFrameRect(CCRectMake(0, 0, 480, 320));
// 	//原先x坐标�??由于模拟器盲�??,无法测试,故把x坐标调为40
// //#ifdef DEBUG
// 	m_anilayerRequest->SetAniRectXYSize(CCRectMake(0, 320-53-9, 57, 53), CCSizeMake(17, 17));
// //#else
// 	//m_anilayerRequest->SetAniRectXYSize(CCRectMake(0, 120, 25, 22), CCSizeMake(2, 2));
// //#endif
// 	m_anilayerRequest->SetCurrentAnimation(0);
// 	m_anilayerRequest->SetDelegate(this);
// 	AddUIChild(m_anilayerRequest);
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	/*
	 m_anilayerMail = new NDUIAniLayer;
	 m_anilayerMail->Initialization("mail_flash.spr");
	 m_anilayerMail->SetFrameRect(CCRectMake(0, 0, 480, 320));
	 #ifdef DEBUG
	 m_anilayerMail->SetAniRectXYSize(CCRectMake(40, 160, 25, 17), CCSizeMake(2, 2));
	 #else
	 m_anilayerMail->SetAniRectXYSize(CCRectMake(0, 160, 25, 17), CCSizeMake(2, 2));
	 #endif
	 m_anilayerMail->SetCurrentAnimation(0);
	 m_anilayerMail->SetDelegate(this);
	 AddUIChild(m_anilayerMail);
	 */

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_tlShare = new NDUITableLayer;
// 	m_tlShare->Initialization();
// 	m_tlShare->VisibleSectionTitles(false);
// 	m_tlShare->SetDelegate(this);
// 	m_tlShare->SetVisible(false);
// 	AddUIChild(m_tlShare);
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	//m_tlInvitePlayers = new NDUITableLayer;
	//m_tlInvitePlayers->Initialization();
	//m_tlInvitePlayers->VisibleSectionTitles(false);
	//m_tlInvitePlayers->SetDelegate(this);
	//m_tlInvitePlayers->SetVisible(false);
	//AddUIChild(m_tlInvitePlayers);
	//m_tlKickPlayers = new NDUITableLayer;
	//m_tlKickPlayers->Initialization();
	//m_tlKickPlayers->VisibleSectionTitles(false);
	//m_tlKickPlayers->SetDelegate(this);
	//m_tlKickPlayers->SetVisible(false);
	//AddUIChild(m_tlKickPlayers);
	//
	//m_tlTiShengPlayers = new NDUITableLayer;
	//m_tlTiShengPlayers->Initialization();
	//m_tlTiShengPlayers->VisibleSectionTitles(false);
	//m_tlTiShengPlayers->SetDelegate(this);
	//m_tlTiShengPlayers->SetVisible(false);
	//AddUIChild(m_tlTiShengPlayers);
	//
	//m_tlPaiHang = new NDUITableLayer;
	//m_tlPaiHang->Initialization();
	//m_tlPaiHang->VisibleSectionTitles(false);
	//m_tlPaiHang->SetDelegate(this);
	//m_tlPaiHang->SetVisible(false);
	//AddUIChild(m_tlPaiHang);
	//
	//m_tlMarriage = new NDUITableLayer;
	//m_tlMarriage->Initialization();
	//m_tlMarriage->VisibleSectionTitles(false);
	//m_tlMarriage->SetDelegate(this);
	//m_tlMarriage->SetVisible(false);
	//AddUIChild(m_tlMarriage);
	do
	{
		//m_tlInteractive = new NDUITableLayer;
		//m_tlInteractive->Initialization();
		//m_tlInteractive->VisibleSectionTitles(false);
		//m_tlInteractive->SetVisible(false);
		//m_tlInteractive->SetDelegate(this);
		//AddUIChild(m_tlInteractive);
	} while (0);

	//ShowMiniMap(NDDataPersist::IsGameSettingOn(GS_SHOW_MINI_MAP));
	//ShowPlayerHead(NDDataPersist::IsGameSettingOn(GS_SHOW_HEAD));
	ShowMiniMap(true);
	ShowPlayerHead(true);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_userState = new UserStateLayer;
// 	m_userState->Initialization();
// 	AddUIChild(m_userState, 2);
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	NDUILayer* pkLayer = new NDUILayer;
	pkLayer->Initialization();
	pkLayer->SetFrameRect(CCRectMake(0, 0, 36, 42));

	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("scenerolehandle.png"), false);
	m_pkHeadShowImage = new NDUIImage;
	m_pkHeadShowImage->Initialization();
	m_pkHeadShowImage->SetPicture(pic, true);
	m_pkHeadShowImage->SetFrameRect(CCRectMake(0, 0, 27, 46));
	AddUIChild(m_pkHeadShowImage, 1);

	m_btnHeadShow = new NDUIButton;
	m_btnHeadShow->Initialization();
	m_picHeadShow = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("handlearraw.png"), false);
	m_picHeadShow->Rotation(PictureRotation180);
	m_btnHeadShow->SetImage(m_picHeadShow, true, CCRectMake(10, 13, 9, 16),
			true);
	m_btnHeadShow->SetFrameRect(CCRectMake(0, 0, 27, 46));
	m_btnHeadShow->SetDelegate(this);
	pkLayer->AddChild(m_btnHeadShow);
	AddUIChild(pkLayer, 1);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_targetHead = new TargetHeadInMap;
// 	m_targetHead->Initialization();
// 	m_targetHead->SetFrameRect(CCRectMake(210.0f, 0.0f, 87.0f, 40.0f));
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	NDUIImage* imgShrinkBg = new NDUIImage;
	imgShrinkBg->Initialization();
	imgShrinkBg->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bar_shrink.png"), false));
	imgShrinkBg->SetFrameRect(CCRectMake(35.5, 284, 62, 36));
	AddUIChild(imgShrinkBg);

	imgShrinkBg = new NDUIImage;
	imgShrinkBg->Initialization();
	imgShrinkBg->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bar_shrink.png"), false));
	imgShrinkBg->SetFrameRect(
			CCRectMake(kWinSize.width - 66.5 - 31, 284, 62, 36));
	AddUIChild(imgShrinkBg);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_bQuickInterationShow = true;
// 	
// 	m_quickInteration = new QuickInteraction;
// 	m_quickInteration->Initialization();
// 	//m_quickInteration->SetBackgroundColor(ccc4(255, 0, 255, 255));
// 	m_quickInteration->SetFrameRect(CCRectMake(66.5, 247.0f, 347, 75.0f));
// 	AddUIChild(m_quickInteration);
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	pkLayer = new NDUILayer;
	pkLayer->Initialization();
	pkLayer->SetFrameRect(CCRectMake(35.5, 284, 62, 36));

	NDUIImage* imgQuickInterationShrink = new NDUIImage;
	imgQuickInterationShrink->Initialization();
	imgQuickInterationShrink->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bottom_shrink.png"), false),
			true);
	imgQuickInterationShrink->SetFrameRect(CCRectMake(14, 14, 34, 22));
	pkLayer->AddChild(imgQuickInterationShrink);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	m_quickItem = new QuickItem;
// 	m_quickItem->Initialization();
// 	m_quickItem->SetFrameRect(CCRectMake(66.5, 244.0f, 400.0f, 78.0f));
// 	AddUIChild(m_quickItem);
//	RefreshQuickItem();
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

//	m_quickItem->SetShrink(true); ///< 临时性注�?? 郭浩
	m_btnQuickInterationShrink = new NDUIButton;
	m_btnQuickInterationShrink->Initialization();
	m_picQuickInteration = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("handlearraw.png"), false);
	m_picQuickInteration->Rotation(PictureRotation90);
	m_btnQuickInterationShrink->SetImage(m_picQuickInteration, true,
			CCRectMake(10, 20, 16, 9), true);
	m_btnQuickInterationShrink->SetFrameRect(CCRectMake(13, 00, 62, 56));
	m_btnQuickInterationShrink->SetDelegate(this);
	pkLayer->AddChild(m_btnQuickInterationShrink);
	AddUIChild(pkLayer);

//	m_quickFunc = new QuickFunc; ///< 临时性注�?? 郭浩
//	m_quickFunc->Initialization(true); ///< 临时性注�?? 郭浩
//	AddUIChild(m_quickFunc); ///< 临时性注�?? 郭浩

	TeamRefreh(false);
}

CCSize GameScene::GetSize()
{
	return m_pkMapLayerLogic->GetContentSize();
}

cocos2d::CCArray* GameScene::GetSwitchs()
{
	return m_pkMapLayerLogic->GetMapData()->getSwitchs();
}

void GameScene::SetMiniMapVisible(bool bVisible)
{
// 	if (m_miniMap)
// 	{
	//m_miniMap->EnableDraw(bVisible);
//	}

	// 同时也设置头�??
//	if (m_playerHead)
//	{
	//m_playerHead->EnableDraw(bVisible);
//	}

//	if (m_petHead)
//	{
	//m_petHead->EnableDraw(bVisible);
//	}
}

void GameScene::ShowPetHead(bool bShow)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	NDBattlePet* battlepet = (NDBattlePet*)NDPlayer::defaultHero().GetShowPet();
// 	
// 	if (bShow && battlepet)
// 	{
// 		if (!m_petHead)
// 		{
// 			m_petHead = new PlayerHeadInMap(battlepet);
// 			m_petHead->Initialization();
// 			AddUIChild(m_petHead, 0);
// 		}
// 		else
// 		{
// 			m_petHead->ChangeBattlePet(battlepet);
// 		}
// 	}
// 	else if (m_petHead) 
// 	{
// 		m_petHead->RemoveFromParent(true);
// 		m_petHead = NULL;
// 	}
}

void GameScene::ShowPlayerHead(bool bShow)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	if (bShow)
// 	{
// 		if (!m_playerHead)
// 		{
// 			m_playerHead = new PlayerHeadInMap(&NDPlayer::defaultHero());
// 			m_playerHead->Initialization();
// 			AddUIChild(m_playerHead);
// 		}
// 	} 
// 	else
// 	{
// 		if (m_playerHead) 
// 		{
// 			m_uiLayer->RemoveChild(m_playerHead, true);
// 			m_playerHead = NULL;
// 		}
// 	}
// 
// 	ShowPetHead(bShow);
}

void GameScene::ShowDirectKey(bool bShow)
{
	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	if (bShow)
// 	{
// 		if (!m_directKey) 
// 		{
// 			m_directKey = new DirectKey();
// 			m_directKey->Initialization();
// 		}
// 		
// 		if (m_directKey->GetParent() == NULL) 
// 		{
// 			AddUIChild(m_directKey);
// 			
// 			m_directKey->ShowFinish(this);
// 		}
// 	}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

//	else 
//	{
//		SAFE_DELETE_NODE(m_directKey);
//	}
}

const CCRect RECT_MINI_MAP = CCRectMake(308.0f, 0.0f, 172.0f, 84.0f);

void GameScene::ShowMiniMap(bool bShow)
{
	/***
	 * 临时性注�?? 郭浩
	 * this function
	 */
// 	if (bShow) 
// 	{
// 		if (!m_miniMap) 
// 		{
// 			m_miniMap = new NDMiniMap();
// 			m_miniMap->Initialization();
// 			//m_miniMap->SetGameScene(this);
// 			m_miniMap->SetFrameRect(RECT_MINI_MAP);
// 			AddUIChild(m_miniMap);
// 		}
// 	} 
// 	else
// 	{
// 		if (m_miniMap) 
// 		{
// 			m_uiLayer->RemoveChild(m_miniMap, true);
// 			m_miniMap = NULL;
// 		}
// 	}
}

void GameScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
		unsigned int cellIndex, NDSection* section)
{
	/***
	 * 临时性注�?? 郭浩
	 */

//	if (table == m_tlInteractive && m_tlInteractive->IsVisibled() && cellIndex < interactive_end)
//	{
//		NDPlayer& player = NDPlayer::defaultHero();
//		NDManualRole *role = NDMapMgrObj.GetManualRole(player.m_iFocusManuRoleID);
//		if (!role)
//		{
//			return;
//		}
//		
//		if (!cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
//		{
//			return;
//		}
//		std::string str = ((NDUIButton*)cell)->GetTitle();
//		if ( str == "玩家信息")
//		{ // "玩家信息"
//			sendQueryPlayer(role->m_id, _SEE_USER_INFO);
//		}
//		else if ( str == "查看装备")
//		{ // "查看装备"
//			sendQueryPlayer(role->m_id, SEE_EQUIP_INFO);
//		}
//		else if ( str == "�??请组�??")
//		{ // "�??请组�??"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "加入队伍")
//		{ // "加入队伍"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_JOIN << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//			
//		}
//		else if ( str == "�??请组�??")
//		{ // "�??请组�??"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "交易")
//		{ // "交易"
//			//if (AutoFindPath.getInstance().isWork()) {
//			//				if (!AutoFindPath.getInstance().isClickScreenMode()) {
//			//					GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "系统", "您正在使用自动导航，不能进行交易�??"));
//			//					break;
//			//				}
//			//				AutoFindPath.getInstance().stop();
//			//			} todo
//			trade(role->m_id, 0);
//		}
//		else if ( str == "添加好友")
//		{ // "添加好友"
//			sendAddFriend(role->m_name);
//		}
//		else if ( str == "私聊")
//		{ // "私聊"
//			PrivateChatInput::DefaultInput()->SetLinkMan(role->m_name.c_str());
//			PrivateChatInput::DefaultInput()->Show();
//		}
//		else if ( str == "PK")
//		{ // "PK"
//			sendPKAction(*role, BATTLE_ACT_PK);
//		}
//		else if ( str == "比武")
//		{ // "比武"
//			sendRehearseAction(role->m_id, REHEARSE_APPLY);
//		}
//		else if ( str == "查看宠物")
//		{ // "查看宠物"
//			NDTransData bao(_MSG_SEE);
//			bao << (unsigned char)3 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "拜师")
//		{ // "拜师"
//			NDTransData bao(_MSG_TUTOR);
//			bao << (unsigned char)1 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "收徒")
//		{ // "收徒"
//			NDTransData bao(_MSG_TUTOR);
//			bao << (unsigned char)4 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "查看摆摊" )
//		{
//			NDUISynLayer::Show();
//			VendorBuyUILayer::s_idVendor = role->m_id;
//			
//			NDTransData bao(_MSG_BOOTH);
//			bao << Byte(BOOTH_QUEST) << role->m_id << int(0);
//			// SEND_DATA(bao);
//		}
//
//		m_tlInteractive->SetVisible(false);
//		SetUIShow(false);
//		return;
//	}
//	if (table == m_tlShare && m_tlShare && m_tlShare->IsVisibled())
//	{
//		m_tlShare->SetVisible(false);
//		std::string strCurSel = GetTLShareSelText(cell);
//		SetUIShow(false);
//		if (strCurSel == "")
//		{
//			return;
//		}
//		
//		if (strCurSel == "世界地图")
//		{
//			//NDDirector::DefaultDirector()->PushScene(WorldMapScene::Scene(maplayer->GetMapIndex()));
//			//table->SetVisible(false);
//		}
//		else if (strCurSel == "NPC导航")
//		{
//			NpcList::refreshScroll();
//		}
//		else if (strCurSel == "军团")
//		{
//			onClickSyndicate();
//		}
//		else if (strCurSel == "玩家")
//		{
//			GameUIPlayerList *playerlist = new GameUIPlayerList;
//			playerlist->Initialization();
//			AddChild(playerlist, UILAYER_Z, UILAYER_PLAYER_LIST_TAG);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "师徒")
//		{
//			/*
//			TutorUILayer *list = new TutorUILayer;
//			list->Initialization();
//			AddChild(list, UILAYER_Z);
//			table->SetVisible(false);
//			SetUIShow(true);
//			*/
//		}
//		else if (strCurSel == "好友")
//		{
//			GoodFriendUILayer *friendList = new GoodFriendUILayer;
//			friendList->Initialization();
//			AddChild(friendList, UILAYER_Z, UILAYER_GOOD_FRIEND_LIST_TAG);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "商城")
//		{
//			//map_vip_item& items = ItemMgrObj.GetVipStore();
////			if (items.empty()) 
////			{
////				NDTransData bao(_MSG_SHOP_CENTER);
////				bao << (unsigned char)0;
////				// SEND_DATA(bao);
////				ShowProgressBar;
////			} 
////			else 
////			{
////				NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene());
////			}
//		}
//		else if (strCurSel == "充�????")
//		{
//			//sendChargeInfo(0);
//		}
//		else if (strCurSel == "人物")
//		{
//			InitTLShareContent("属�????", "�??�??", "摆摊", "特殊状�????", NULL);
//		}
//		else if (strCurSel == "宠物")
//		{
//			InitTLShareContent("宠物属�????", "宠物�??�??", NULL);
//		}
//		else if (strCurSel == "庄园")
//		{
//			if (false) // 如果没有庄园 todo 暂时先不�??
//			{
//				InitTLShareContent("立即创建", NULL);
//			}
//			else 
//			{
//				InitTLShareContent("庄园商城", "庄园动�????", "远程进入", NULL);
//			}
//			//showDialog("", "暂未�??�??,敬请关注");
//		}
//		else if (strCurSel == "系统")
//		{
//			InitTLShareContent("游戏设置", "删除角色", "登录信息", "回主界面", "卡死复位", NULL);
//		}
//		else if (strCurSel == "排行")
//		{
//			ShowProgressBar;
//			NDTransData bao(_MSG_BILLBOARD_QUERY);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "活动")
//		{
//			ShowProgressBar;
//			NDTransData bao(_MSG_ACTIVITY);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "客服")
//		{
//			InitTLShareContent("我要提问", "修改密码", "客服声明", "公告查看", NULL);
//		}
//		else if (strCurSel == "军团排行")
//		{
//			sendQueryTaxis(0);
//		}
//		else if (strCurSel == "军团应征")
//		{
//			queryCreatedInSynList(0);
//		}
//		else if (strCurSel == "�??请函")
//		{
//			sendQueryInviteList();
//		}
//		else if (strCurSel == "职位竞�????")
//		{
//			InitTLShareContent("军团�??", "副团�??", "元�????", "堂主", "门主", NULL);
//		}
//		else if (strCurSel == "军团�??")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 12);
//		}
//		else if (strCurSel == "副团�??")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 11);
//		}
//		else if (strCurSel == "元�????")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 10);
//		}
//		else if (strCurSel == "堂主")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 5);
//		}
//		else if (strCurSel == "门主")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 1);
//		}
//		else if (strCurSel == "投票�??")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_VOTE_LIST);
//		}
//		else if (strCurSel == "军团管理")
//		{
//			int synRank = NDPlayer::defaultHero().getSynRank();
//			
//			vector<string> vMgrOpt;
//			
//			for (int i = 0; i < 9; i++) {
//				if (i == 4) {// "军团升级"，副团及以上有权�??
//					if (synRank < SYNRANK_VICE_LEADER) {
//						continue;
//					}
//				} else if (i == 5 || i == 6 || i == 7) {// "军团�??�??"//"人员审核"//"辞职"，门主及以上有权�??
//					if (synRank < SYNRANK_MENZHU_SHENG) {
//						continue;
//					}
//				}
//				vMgrOpt.push_back(MENU_SYN_MANAGE[i]);
//			}
//			InitTLShareContent(vMgrOpt);
//		}
//		else if (strCurSel == "军团公告")
//		{
//			sendQueryAnnounce();
//		}
//		else if (strCurSel == "军团信息")
//		{
//			sendQueryPanelInfo();
//		}
//		else if (strCurSel == "军团仓库")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_SYN_STORAGE);
//		}
//		else if (strCurSel == "军团升级")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_SYN_UPGRADE_INFO);
//		}
//		else if (strCurSel == "军团�??�??")
//		{
//			SyndicateInvite::Show();
//		}
//		else if (strCurSel == "人员审核")
//		{
//			sendQueryApprove(0);
//		}
//		else if (strCurSel == "军团成员")
//		{
//			sendQueryMembers(0);
//		}
//		else if (strCurSel == "辞职")
//		{
//			m_dlgSyndicateResign = GlobalDialogObj.Show(this, 
//									  "温馨提示",
//									  "请您确认是否要辞掉当前官�??", 0, "确认辞职", NULL);
//		}
//		else if (strCurSel == "离开军团")
//		{
//			m_dlgSyndicateQuit = GlobalDialogObj.Show(this, 
//									  "温馨提示",
//									  "大侠您确定要离开本军�??", 0, NDCommonCString("Ok"), NULL);
//		}
//		else if (strCurSel == "属�????")
//		{
//			//SetUIShow(true);
////			GameUIAttrib *attrib = new GameUIAttrib;
////			attrib->Initialization();
////			AddChild(attrib, UILAYER_Z, UILAYER_ATTRIB_TAG);
//			NDDirector::DefaultDirector()->PushScene(GameAttribScene::Scene());
//			table->SetVisible(false);
//		}
//		else if (strCurSel == "�??�??")
//		{
//			InitTLShareContent("战斗�??�??", "炼金�??�??", "宝石合成", NULL);
//		}
//		else if (strCurSel == "摆摊")
//		{
//			if (NDMapMgrObj.canBooth()) {
//				VendorUILayer::Show(this);
//				table->SetVisible(false);
//				SetUIShow(true);
//			} else {
//				showDialog("温馨提示", "您不能在这里摆摊");
//			}
//		}
//		else if (strCurSel == "特殊状�????")
//		{
//			UserStateUILayer *list = new UserStateUILayer;
//			list->Initialization();
//			AddChild(list, UILAYER_Z);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "宠物属�????")
//		{
//			//if (NDPlayer::defaultHero().battlepet)
//			//{
//				//GameUIPetAttrib *attrib = new GameUIPetAttrib;
////				attrib->Initialization();
////				AddChild(attrib, UILAYER_Z, UILAYER_PET_ATTRIB_TAG);
//				//NDDirector::DefaultDirector()->PushScene(GamePetAttribScene::Scene());
//			//}
//			//else 
//			//{
//			//	GlobalDialogObj.Show(NULL, "提示", "您没有装备宠�??", NULL, NULL);
//			//}	
//			
//			//table->SetVisible(false);
//			//SetUIShow(true);
//		}
//		else if (strCurSel == "宠物�??�??")
//		{
//			PetSkillScene *scene = new PetSkillScene;
//			scene->Initialization();
//			NDDirector::DefaultDirector()->PushScene(scene);
//		}
//		else if (strCurSel == "游戏设置")
//		{
//			NDDirector::DefaultDirector()->PushScene(GameSettingScene::Scene());
//			table->SetVisible(false);
//		}
//		else if (strCurSel == "删除角色")
//		{
//			m_dlgDelRoleTag = GlobalDialogObj.Show(this, "温馨提示", "大侠您确定要删除角色,删除后将无法找回�??有数�??.是否删除",
//					     NULL, NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
//		}
//		else if (strCurSel == "登录信息")
//		{
//			stringstream ss;
//			NDPlayer& player = NDPlayer::defaultHero();
//			ss << NDBeforeGameMgrObj.GetServerDisplayName()
//			<< " (" << player.GetCol() << ", " << player.GetRow() << ")";
//			GlobalDialogObj.Show(NULL, "登录信息", ss.str().c_str(), NULL, NULL);
//		}
//		else if (strCurSel == "回主界面")
//		{
//			quitGame();
//		}
//		else if (strCurSel == "卡死复位")
//		{
//			NDTransData bao(_MSG_RESET_POSITION);
//			// SEND_DATA(bao);
//			
//			ShowProgressBar;
//		}
//		else if (strCurSel == "我要提问")
//		{
//			NDUICustomView *view = new NDUICustomView;
//			view->Initialization();
//			view->SetTag(TAG_CV_SEND_QUESTION);
//			view->SetDelegate(this);
//			std::vector<int> vec_id; vec_id.push_back(1);
//			std::vector<std::string> vec_str; vec_str.push_back("请输入内�??,�??多输�??个汉�??");
//			view->SetEdit(1, vec_id, vec_str);
//			view->Show();
//			AddChild(view);
//		}
//		else if (strCurSel == "修改密码")
//		{
//			NDUICustomView *view = new NDUICustomView;
//			view->Initialization();
//			view->SetTag(TAG_CV_CHANG_PWD);
//			view->SetDelegate(this);
//			std::vector<int> vec_id;
//			vec_id.push_back(1);
//			vec_id.push_back(2);
//			vec_id.push_back(3);
//			
//			std::vector<std::string> vec_str;
//			vec_str.push_back("请输入当前密�??(12位以�??)");
//			vec_str.push_back("请输入新密码:(7-12�??)");
//			vec_str.push_back("请再次输入新密码:(7-12�??)");
//			
//			view->SetEdit(3, vec_id, vec_str);
//			view->Show();
//			
//			AddChild(view);
//		}
//		else if (strCurSel == "客服声明")
//		{
//			NDTransData bao(_MSG_CUSTOMER_SERVICE);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "公告查看")
//		{
//			NDMapMgr& mgr = NDMapMgrObj;
//			GlobalShowDlg(mgr.noteTitle, mgr.noteContent);
//		}
//		else if (strCurSel == "战斗�??�??")
//		{
//			NDPlayer& player = NDPlayer::defaultHero();
//			
//			if ( player.GetSkillList(SKILL_TYPE_ATTACK).size() != 0 
//				 || player.GetSkillList(SKILL_TYPE_PASSIVE).size() != 0 ) 
//			{
//				//T.closeTopDialog();
////				T.addDialog(new com.nd.kgame.system.skill.SkillDialog(1));
//				
//				GameUIBattleSkill *battleskill = new GameUIBattleSkill;
//				battleskill->Initialization();
//				AddChild(battleskill, UILAYER_Z, UILAYER_BATTLE_SKILL_TAG);
//				SetUIShow(true);
//			}
//			else
//			{
//				showDialog("操作失败", "大侠你还木有学习战斗�??能呢!");
//			}
//		}
//		else if (strCurSel == "炼金�??�??")
//		{
//			if ( NDMapMgrObj.getLifeSkill(ALCHEMY_IDSKILL) != NULL )
//			{
//				LifeSkillScene *scene = new LifeSkillScene;
//				scene->Initialization(ALCHEMY_IDSKILL, LifeSkillScene_Query);
//				NDDirector::DefaultDirector()->PushScene(scene);
//			}
//			else 
//			{
//				GlobalShowDlg("操作失败", "大侠你还木有学习炼金�??能呢!赶紧去初级炼金技能npc那里学习�??.");
//			}
//			
//		}
//		else if (strCurSel == "宝石合成")
//		{
//			if ( NDMapMgrObj.getLifeSkill(GEM_IDSKILL) != NULL )
//			{
//				LifeSkillScene *scene = new LifeSkillScene;
//				scene->Initialization(GEM_IDSKILL, LifeSkillScene_Query);
//				NDDirector::DefaultDirector()->PushScene(scene);
//			}
//			else 
//			{
//				GlobalShowDlg("操作失败", "大侠你还木有学习宝石合成�??能呢!赶紧去初级宝石合成npc那里学习�??.");
//			}
//		}
//		else if (strCurSel == "收件�??")
//		{
//			GameMailsScene *scene = new GameMailsScene;
//			scene->Initialization();
//			NDDirector::DefaultDirector()->PushScene(scene);
//		}
//		else if (strCurSel == "发件�??")
//		{
//			NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene());
//		}
//		else if (strCurSel == "关闭加入" || strCurSel == "�??启加�??")
//		{
//			m_stackUIMenu.clear();
//			NDTransData bao(_MSG_TEAM);
//			if (NDMapMgrObj.bolEnableAccept) 
//			{
//				bao << (unsigned short)MSG_TEAM_DISABLEACCEPT;
//			}
//			else 
//			{
//				bao << (unsigned short)MSG_TEAM_ENABLEACCEPT;
//			}
//			
//			bao << NDPlayer::defaultHero().m_id << int(0);
//			
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "�??请入�??")
//		{
//			SetUIShow(true);
//			m_stackUIMenu.push_front(MT_DUI_WU);
//			NDMapMgr& mapmgr = NDMapMgrObj;
//			NDMapMgr::map_manualrole& roles = mapmgr.GetManualRoles();
//			
//			NDMapMgr::map_manualrole_it it = roles.begin();
//			std::vector<std::string> vec_str; std::vector<int> vec_id;
//			for (; it != roles.end(); it++) 
//			{
//				NDManualRole *role = it->second;
//				if (role && !role->bClear && role->teamId == 0) 
//				{
//					vec_str.push_back(role->m_name); vec_id.push_back(role->m_id);
//				}
//			}
//			if (vec_str.empty()) 
//			{
//				vec_str.push_back("�??"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlInvitePlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "请出队伍")
//		{
//			m_stackUIMenu.push_front(MT_DUI_WU);
//			NDMapMgr& mapmgr = NDMapMgrObj;
//			s_team_info info;
//			if ( !mapmgr.GetTeamInfo(NDPlayer::defaultHero().m_id, info) )
//			{
//				return;
//			}
//			
//			std::vector<NDManualRole*> tempRoleList = NDMapMgrObj.GetPlayerTeamList();
//			if (tempRoleList.empty()) 
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "没有队员�??");
//			//				GameScreen.getInstance().initNewChat(
//			//													 new ChatRecord(5, GameScreen.role.getName(), "没有队员�??"));
//			//				return;
//			//			}
//			
//			std::vector<std::string> vec_str; std::vector<int> vec_id;
//			for (int i=1; i < eTeamLen; i++) 
//			{
//				if (info.team[i] != 0) 
//				{
//					NDManualRole *role = mapmgr.GetTeamRole(info.team[i]);
//					if (role) 
//					{
//						vec_str.push_back(role->m_name); vec_id.push_back(role->m_id);
//					}
//				}
//			}
//			
//			if (vec_str.empty()) 
//			{
//				vec_str.push_back("�??"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlKickPlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "离开队伍")
//		{
//			m_stackUIMenu.clear();
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_LEAVE << NDPlayer::defaultHero().m_id << int(0);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "显示成员")
//		{
//			m_stackUIMenu.push_front(MT_DUI_WU);
//			NDMapMgr& mapmgr = NDMapMgrObj;
//			s_team_info info;
//			if ( !mapmgr.GetTeamInfo(NDPlayer::defaultHero().teamId, info) )
//			{
//				return;
//			}
//			
//			std::vector<NDManualRole*> tempRoleList = NDMapMgrObj.GetPlayerTeamList();
//			if (tempRoleList.empty()) 
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "没有队员�??");
//			
//			std::vector<std::string> vec_str;
//			for (int i=0; i < eTeamLen; i++) 
//			{
//				if (info.team[i] != 0) 
//				{
//					NDManualRole *role = mapmgr.GetTeamRole(info.team[i]);
//					if (role) 
//					{
//						if (role->isTeamLeader()) 
//						{
//							std::string str = "[队长]"; str += role->m_name;
//							vec_str.push_back(str);
//						}
//						else 
//						{
//							vec_str.push_back(role->m_name);
//						}
//					}
//				}
//			}
//			
//			if (!vec_str.empty()) 
//			{
//				InitTLShareContent(vec_str);
//			}
//		}
//		else if (strCurSel == "解散队伍")
//		{
//			m_stackUIMenu.clear();
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_DISMISS << NDPlayer::defaultHero().m_id << int(0);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "提升队长")
//		{
//			m_stackUIMenu.push_front(MT_DUI_WU);
//			NDMapMgr& mapmgr = NDMapMgrObj;
//			s_team_info info;
//			if ( !mapmgr.GetTeamInfo(NDPlayer::defaultHero().m_id, info) )
//			{
//				return;
//			}
//			
//			std::vector<NDManualRole*> tempRoleList = mapmgr.GetPlayerTeamList();
//			if (tempRoleList.empty()) 
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "没有队员�??");
//			
//			std::vector<std::string> vec_str; std::vector<int> vec_id;
//			for (int i=1; i < eTeamLen; i++) 
//			{
//				if (info.team[i] != 0) 
//				{
//					NDManualRole *role = mapmgr.GetTeamRole(info.team[i]);
//					if (role) 
//					{
//						vec_str.push_back(role->m_name); vec_id.push_back(role->m_id);
//					}
//				}
//			}
//			
//			if (vec_str.empty()) 
//			{
//				vec_str.push_back("�??"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlTiShengPlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "庄园商城")
//		{
//			NDTransData bao(_MSG_SHOPINFO);
//			bao << int(99998) << (unsigned char)0;
//			// SEND_DATA(bao);
//			ShowProgressBar;
//			//map_vip_item& items = ItemMgrObj.GetVipStore();
////			if (items.empty()) 
////			{
////				NDTransData bao(_MSG_SHOP_CENTER);
////				bao << (unsigned char)0;
////				// SEND_DATA(bao);
////				ShowProgressBar;
////			} 
////			else 
////			{
////				VipStoreScene *scene = VipStoreScene::Scene();
////				scene->SetTab(4);
////				NDDirector::DefaultDirector()->PushScene(scene);
////			}
//		} 
//		else if (strCurSel == "庄园动�????")
//		{
//			NDTransData bao(_MSG_ENTER_HAMLET);
//			bao << (unsigned char)2 << int(0);
//			// SEND_DATA(bao);
//		} 
//		else if (strCurSel == "远程进入")
//		{
//			std::stringstream ss; ss << "点击确认使用�??个城镇传送卷�??";
//			m_dlgFarm = new NDUIDialog;
//			m_dlgFarm->Initialization();
//			m_dlgFarm->SetDelegate(this);
//			m_dlgFarm->Show("", ss.str().c_str(), NDCommonCString("Cancel"), "确认", NULL);
//		} 
//		//else if (strCurSel == "立即创建") 暂时先不�??
////		{
////			NDMapMgr& mgr = NDMapMgr;
////			if (mar.m_iMapID == 21003) // 21003为长安城地图id 
////			{
////				showDialog("提示", "请去长安城找XXXX（aa,bb），他能指导你创建自己的庄园�??");
////			}
////			else 
////			{
////				// 自动寻路到npc
////			}
////		}
//
//	} else if (m_tlRelieve == table) {
//		if (cellIndex == 0) { // 回城
//			NDUISynLayer::Show(SYN_RELIEVE);
//			NDTransData data(_MSG_REBORN);
//			NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//			table->SetVisible(false);
//			SetUIShow(false);
//		} else if (cellIndex == 1) { // 使用道具
//			VEC_ITEM& itemList = ItemMgrObj.GetPlayerBagItems();
//			for (size_t i = 0; i < itemList.size(); i++) {
//				Item& item = *itemList.at(i);
//				if (item.iItemType == 28000003) {
//					sendItemUse(item);
//					//table->SetVisible(false);
//					SetUIShow(false);
//					return;
//				}
//			}
//			
//			showDialog(NDCommonCString("YouHavetReliveItem"));
//		}
//	}
//	if (table == m_tlInvitePlayers) 
//	{
//		m_stackUIMenu.clear();
//		NDMapMgr& mapmgr = NDMapMgrObj;
//		int iTag = cell->GetTag();
//		if (iTag != 0) 
//		{
//			NDManualRole *role = mapmgr.GetManualRole(iTag);
//			if (role && !role->bClear) 
//			{
//				NDTransData bao(_MSG_TEAM);
//				bao << (unsigned short)MSG_TEAM_INVITE << NDPlayer::defaultHero().m_id
//					<< role->m_id;
//				// SEND_DATA(bao);
//			}
//		}
//		m_tlInvitePlayers->SetVisible(false);
//		SetUIShow(false);
//	}
//	if (table == m_tlKickPlayers) 
//	{
//		m_stackUIMenu.clear();
//		NDMapMgr& mapmgr = NDMapMgrObj;
//		int iTag = cell->GetTag();
//		if (iTag != 0) 
//		{
//			NDManualRole *role = mapmgr.GetManualRole(iTag);
//			if (role && !role->bClear) 
//			{
//				NDTransData bao(_MSG_TEAM);
//				bao << (unsigned short)MSG_TEAM_KICK << NDPlayer::defaultHero().m_id
//				<< role->m_id;
//				// SEND_DATA(bao);
//			}
//		}
//		m_tlKickPlayers->SetVisible(false);
//		SetUIShow(false);
//	}
//	if (table == m_tlTiShengPlayers) 
//	{
//		m_stackUIMenu.clear();
//		NDMapMgr& mapmgr = NDMapMgrObj;
//		int iTag = cell->GetTag();
//		if (iTag != 0) 
//		{
//			NDManualRole *role = mapmgr.GetManualRole(iTag);
//			if (role && !role->bClear) 
//			{
//				NDTransData bao(_MSG_TEAM);
//				bao << (unsigned short)MSG_TEAM_CHGLEADER << NDPlayer::defaultHero().m_id
//				<< role->m_id;
//				// SEND_DATA(bao);
//			}
//		}
//		m_tlTiShengPlayers->SetVisible(false);
//		SetUIShow(false);
//	}
//	if (table == m_tlPaiHang) 
//	{
//		int iTag = cell->GetTag();
//		NDTransData bao(_MSG_BILLBOARD);
//		bao << iTag << int(-1);
//		// SEND_DATA(bao);
//		m_tlPaiHang->SetVisible(false);
//		SetUIShow(false);
//		ShowProgressBar;
//	}
//	if (table == m_tlMarriage)
//	{
//		sendMarry(NDPlayer::defaultHero().m_id, cell->GetTag(), _MARRIAGE_APPLY, 0);
//		SetUIShow(false);
//		m_tlMarriage->SetVisible(false);
//	}
}

void GameScene::OnButtonClick(NDUIButton* button)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */

//	if(HideTLShare()) return;
//	
//	if (button == m_btnQuickInterationShrink) {
//		m_bQuickInterationShow = !m_bQuickInterationShow;
//		
//		if (m_bQuickInterationShow) {
//			if (m_quickInteration) {
//				m_quickInteration->SetShrink(false);
//			}
//		} else {
//			if (m_quickInteration) {
//				m_quickInteration->SetShrink(true);
//			}
//		}
//		
//		if (m_picQuickInteration) {
//			m_picQuickInteration->Rotation(m_bQuickInterationShow ? PictureRotation90 : PictureRotation270);
//		}
//		
//		if (m_bQuickInterationShow)
//			ShrinkQuickItem();
//	} else if (button == m_btnHeadShow) {
//		if (m_bHeadShow) {
//			if (m_playerHead) {
//				m_playerHead->SetShrink(true);
//			}
//			if (m_petHead) {
//				m_petHead->SetShrink(true);
//			}
//		} else {
//			if (m_playerHead) {
//				m_playerHead->SetShrink(false);
//			}
//			if (m_petHead) {
//				m_petHead->SetShrink(false);
//			}
//		}
//		
//		m_bHeadShow = !m_bHeadShow;
//		
//		if (m_picHeadShow) {
//			m_picHeadShow->Rotation(m_bHeadShow ? PictureRotation180 : PictureRotation0);
//		}
//	}
//	else if (button == m_btnMap)
//	{
//		InitTLShareContent("世界地图", "NPC导航", NULL);
//	}
//	else if (button == m_btnTarget)
//	{
//		NDPlayer::defaultHero().NextFocusTarget();
//	}
//	else if (button == m_btnInterative)
//	{
//		NDPlayer *player = &NDPlayer::defaultHero();
//		
//		//if (!player || player->m_iFocusManuRoleID == -1)
////		{
////			NDUIDialog *dlg = new NDUIDialog;
////			dlg->Initialization();
////			dlg->Show("提示", "没有互动目标", "", NULL);
////			return;
////		}
//		//if ( player->m_iFocusManuRoleID != -1 )
////		{
//			NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(player->m_iFocusManuRoleID);
//			if ( !otherplayer && !player->IsFocusNpcValid())
//			{ //与其它玩家交�??
//				
//				NDUIDialog *dlg = new NDUIDialog;
//				dlg->Initialization();
//				dlg->Show("提示", "没有交互目标", "", NULL);
//				return;
//			}
//			
//			if (m_tlInteractive && otherplayer && !player->IsFocusNpcValid())
//			{
//				std::vector<std::string> vec_str;
//				vec_str.push_back("玩家信息");
//				vec_str.push_back("查看装备");
//				
//				if (!player->isTeamMember())
//				{
//					if (otherplayer->isTeamMember()) 
//					{
//						vec_str.push_back("2");
//					} 
//					else 
//					{
//						vec_str.push_back("1");
//					}
//				} 
//				else if (player->isTeamLeader()) 
//				{
//					if (!otherplayer->isTeamMember()) 
//					{
//						vec_str.push_back("3");
//					}
//				}
//				vec_str.push_back("交易");
//				vec_str.push_back("添加好友");
//				vec_str.push_back("私聊");
//				vec_str.push_back("PK");
//				vec_str.push_back("比武");
//				vec_str.push_back("查看宠物");
//			
//				if (player->level < 20 && otherplayer->level >= 20) 
//				{
//					vec_str.push_back("拜师");
//				} 
//				else if (player->level >= 20 && otherplayer->level < 20)
//				{
//					vec_str.push_back("收徒");
//				}
//				if(otherplayer->IsInState(USERSTATE_BOOTH))
//				{
//					vec_str.push_back("查看摆摊");
//				}
//				
//				NDDataSource *source =  new NDDataSource;
//				NDSection *section = new NDSection;
//				section->UseCellHeight(true);
//				for_vec(vec_str, std::vector<std::string>::iterator)
//				{
//					//NDUILabel *lbText = new NDUILabel; 
////					lbText->Initialization(); 
////					lbText->SetText((*it).c_str()); 
////					lbText->SetFontSize(13); 
////					lbText->SetTextAlignment(LabelTextAlignmentCenter); 
////					lbText->SetFrameRect(CCRectMake(0, 8, 120, 13)); 
////					lbText->SetFontColor(ccc4(16, 56, 66,255)); 
////					section->AddCell(lbText);
//					
//					NDUIButton *button = new NDUIButton;
//					button->Initialization();
//					button->SetFrameRect(CCRectMake(0, 0, 120, 30));
//					button->SetTitle((*it).c_str());
//					//button->SetFontColor(ccc4(16, 56, 66,255));
//					button->SetFontColor(ccc4(0, 0, 0,255));
//					button->SetFocusColor(ccc4(253, 253, 253, 255));
//					section->AddCell(button);
//				}
//				
//				if (section->Count() > 0) 
//				{
//					section->SetFocusOnCell(0);
//				}
//				
//				source->AddSection(section);
//				
//				m_tlInteractive->SetFrameRect(CCRectMake((480-200)/2, (320-vec_str.size()*30-vec_str.size()-1)/2, 200, vec_str.size()*30+vec_str.size()+1));
//				
//				m_tlInteractive->SetVisible(true);
//				
//				if (m_tlInteractive->GetDataSource())
//				{
//					m_tlInteractive->SetDataSource(source);
//					m_tlInteractive->ReflashData();
//				}
//				else 
//				{
//					m_tlInteractive->SetDataSource(source);
//				}
//
//				SetUIShow(true);
//			}
//			
//			
//			if (!otherplayer && player->IsFocusNpcValid())
//			{
//				ShowProgressBar;
//				NDTransData data(_MSG_NPC);
//				data << player->GetFocusNpcID() << (unsigned char)0 << (unsigned char)0 << int(123);
//				NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//				
//				NDNpc *focusNpc = player->GetFocusNpc();
//				
//				if (!focusNpc) return;
//				
////				if (player->GetPosition().x > focusNpc->GetPosition().x) 
////					focusNpc->DirectRight(true);
////				else 
////					focusNpc->DirectRight(false);
//			}
//			
//			return;
//		//}
//	}
//	else if (button == m_btnTeam)
//	{	
//		onClickTeam();
//	}
//	else if (button == m_btnSocial)
//	{
//		InitTLShareContent("军团", "玩家", "师徒", "好友", NULL);
//	}
//	else if (button == m_btnTalk)
//	{
//		ChatRecordManager::DefaultManager()->Show();
//	}
//	else if (button == m_btnTask)
//	{
//		GameUITaskList *tasklist = new GameUITaskList;
//		tasklist->Initialization();
//		AddChild(tasklist, UILAYER_Z, UILAYER_TASK_LIST_TAG);
//		SetUIShow(true);
//	}
//	else if (button == m_btnBag)
//	{
//		m_playerPosWithMap = NDPlayer::defaultHero().GetPosition();
//		NDDirector::DefaultDirector()->PushScene(GamePlayerBagScene::Scene());
//	}
//	else if (button == m_btnStore)
//	{
//		//InitTLShareContent("商城", "充�????", NULL);
//	}
//	else if (button == m_btnMenu)
//	{
//		InitTLShareContent("人物", "宠物", "庄园", "系统", "排行", "活动", "客服", NULL);
//	}
}

void GameScene::onClickTeam()
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */

	//NDPlayer& player = NDPlayer::defaultHero();
	//NDMapMgr& mapmgr = NDMapMgrObj;
	//if (player.teamId > 0) 
	//{
	//	std::vector<std::string> vec_str; 
	//	
	//	if (player.isTeamLeader()) 
	//	{
	//		if (mapmgr.bolEnableAccept)
	//		{
	//			vec_str.push_back("关闭加入");
	//		} 
	//		else 
	//		{
	//			vec_str.push_back("�??启加�??");
	//		}
	//		
	//		vec_str.push_back("�??请入�??");
	//		vec_str.push_back("请出队伍");
	//		vec_str.push_back("离开队伍");
	//		vec_str.push_back("显示成员");
	//		vec_str.push_back("解散队伍");
	//		vec_str.push_back("提升队长");
	//	}
	//	else 
	//	{
	//		vec_str.push_back("显示成员");
	//		vec_str.push_back("离开队伍");
	//		
	//	}
	//	
	//	InitTLShareContent(vec_str);
	//} 
	//else 
	//{
	//	showDialog("队伍", "您还没有队伍");
	//}
}

void GameScene::ShowRelieve(bool bShow)
{
	if (bShow)
	{
		if (m_relieveLayer)
		{
			return;
		}

		m_relieveLayer = new NDUILayer;
		m_relieveLayer->Initialization();
		m_relieveLayer->SetFrameRect(CCRectMake(0, 0, 480, 320));
		AddChild(m_relieveLayer, UIDIALOG_Z);

		CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();

		m_tlRelieve = new NDUITableLayer;
		m_tlRelieve->Initialization();
		m_tlRelieve->VisibleSectionTitles(false);
		m_tlRelieve->SetDelegate(this);
		//m_tlRelieve->SetFrameRect(CCRectMake(30, 10, 120, 60));
		m_tlRelieve->SetFrameRect(
				CCRectMake((winsize.width - 120) / 2, (winsize.height - 60) / 2,
						120, 60));
		m_relieveLayer->AddChild(m_tlRelieve);

		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;

		NDUIButton *button = new NDUIButton;
		button->Initialization();
		button->SetFrameRect(CCRectMake(0, 0, 120, 30));
		button->SetTitle(NDCommonCString("ReliveInCity"));
		section->AddCell(button);

		button = new NDUIButton;
		button->Initialization();
		button->SetFrameRect(CCRectMake(0, 0, 120, 30));
		button->SetTitle(NDCommonCString("ReliveUseItem"));
		section->AddCell(button);

		dataSource->AddSection(section);
		m_tlRelieve->SetDataSource(dataSource);
		SetUIShow(true);
	}
	else
	{
		if (m_relieveLayer)
		{
			RemoveChild(m_relieveLayer, true);
			m_relieveLayer = NULL;
			m_tlRelieve = NULL;
			SetUIShow(false);
		}
	}
}

void GameScene::PushWorldMapScene()
{
	//NDDirector::DefaultDirector()->PushScene(WorldMapScene::Scene(maplayer->GetMapIndex()));
}

void GameScene::ShowPaiHang(const std::vector<std::string>& vec_str,
		const std::vector<int>& vec_id)
{
	InitContent(m_tlPaiHang, vec_str, vec_id);
}

/***
 *	临时性注�?? 郭浩
 *   this function
 */
//bool GameScene::OnClickHControlContainer(NDUIHControlContainer* hcontrolcontainer)
//{
//	if (hcontrolcontainer == m_hccOPItem || hcontrolcontainer == hcontrolcontainer)
//	{
//		return HideTLShare();
//	}
//
//	return false;
//}
/***
 *	临时性注�?? 郭浩
 *   this function
 */
//void GameScene::OnClickNDUIAniLayer(NDUIAniLayer* anilayer)
//{
//	if(HideTLShare()) return;
//	
//	if (anilayer == m_anilayerRequest)
//	{
//		//GameUIRequest *request = new GameUIRequest;
////		request->Initialization();
////		AddChild(request, UILAYER_Z, UILAYER_REQUEST_LIST_TAG);
////		SetUIShow(true);
//		
//		m_anilayerRequest->SetCurrentAnimation(0);
//		
//		NDDirector::DefaultDirector()->PushScene(RequestListScene::Scene());
//	}
//	else if (anilayer == m_anilayerMail)
//	{
//		InitTLShareContent("收件�??", "发件�??", NULL);
//		m_anilayerMail->SetCurrentAnimation(0);
//	}
//}
void GameScene::OnDialogButtonClick(NDUIDialog* dialog,
		unsigned int buttonIndex)
{
	/***
	 *	临时性注�?? 郭浩
	 *   all
	 */
//	if (dialog == m_dlgFarm) 
//	{
//		NDTransData  bao(_MSG_ENTER_HAMLET);
//		bao << (unsigned char)1 << int(0);
//		// SEND_DATA(bao);
//		dialog->Close();
//		return;
//	}
//	
//	OBJID tagDlg = dialog->GetTag();
//	if (tagDlg == m_dlgNPCTag)
//	{
//		NDMapMgr& mapmgr = NDMapMgrObj;
//		if(buttonIndex < mapmgr.vecNPCOPText.size())
//		{
//			ShowProgressBar;
//			NDMapMgr::st_npc_op op = mapmgr.vecNPCOPText[buttonIndex];
//			
//			NDTransData data(_MSG_DIALOG);
//			data << mapmgr.GetDlgNpcID()//int(op.idx) 
//				 << (unsigned short)(mapmgr.usData) << (unsigned char)(op.idx);
//			data << (unsigned char)_TXTATR_ENTRANCE;
//			data.WriteUnicodeString(op.str);
//			NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//			
//			mapmgr.ClearNPCChat();
//		}
//		
//		dialog->Close();
//		//m_dlgNPC = NULL;
//		SetUIShow(false);
//	} else if (tagDlg == m_dlgTaskAwardItemTag) {
//		Item* selItem = NULL;
//		if (buttonIndex < m_vTaskAwardItem.size())
//			selItem = m_vTaskAwardItem.at(buttonIndex);
//		NDAsssert(selItem != NULL);
//		
//		if (selItem)
//		{
//			m_curSelTaskAwardItemIndex = buttonIndex;
//			
//			dialog->Close();
//			m_dlgTaskAwardItemTag = -1;
//			
//			m_dlgTaskAwardItemConfirmTag = 
//				GlobalDialogObj.Show(this, 
//									selItem->getItemName().c_str(),
//									selItem->makeItemDes(false, false).c_str(), NULL, NDCommonCString("return"), NDCommonCString("GetAward"), NULL);
//		}
//	} else if (tagDlg == m_dlgTaskAwardItemConfirmTag) {
//		dialog->Close();
//		m_dlgTaskAwardItemConfirmTag = -1;
//		if (buttonIndex == 0) {
//			// 重新显示物品选择对话�??
//			ReShowTaskAwardItemOpt();
//		} else if (buttonIndex == 1) {
//			// 发�??�物品�??�项,同时释放资源
//			NDUISynLayer::Show();
//			NDTransData bao(_MSG_TASK_ITEM_OPT);
//			bao << (Byte)m_curSelTaskAwardItemIndex;
//			
//			// SEND_DATA(bao);
//			
//			for (VEC_ITEM_IT it = m_vTaskAwardItem.begin(); it != m_vTaskAwardItem.end(); it++) {
//				SAFE_DELETE(*it);
//			}
//			m_vTaskAwardItem.clear();
//		}
//	} else if (tagDlg == m_dlgSyndicateResign) {
//		dialog->Close();
//		sendQuerySynNormalInfo(ACT_RESIGN);
//	} else if (tagDlg == m_dlgSyndicateQuit) {
//		dialog->Close();
//		sendQuerySynNormalInfo(QUIT_SYN);
//	} else if (tagDlg == m_dlgDelRoleTag) {
//		dialog->Close();
//		if (buttonIndex == 1) {
//			NDTransData bao(_MSG_DELETEROLE);
//			// SEND_DATA(bao);
//			//ShowProgressBar;
//			quitGame();
//		}
//	}
//	else if (tagDlg == TAG_UPDATE_FORCE || tagDlg == TAG_UPDATE_NOT_FORCE)
//	{
////		UpdateScene* scene = new UpdateScene();
////		scene->Initialization(m_updateUrl.c_str());
////		NDDirector::DefaultDirector()->PushScene(scene);
//		ShowProgressBar;
//		NDBeforeGameMgrObj.CheckVersion();
//	}
}

void GameScene::OnDialogClose(NDUIDialog* dialog)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */

	//OBJID tagDlg = dialog->GetTag();
	//if (tagDlg == m_dlgNPCTag)
	//{
	//	m_dlgNPCTag = -1;
	//	NDMapMgrObj.ClearNPCChat();
	//	SetUIShow(false);
	//}
	//else if (tagDlg == TAG_UPDATE_FORCE)
	//{
	//	//to do terminate application
	//	exit(0);
	//}
	//
	//if (dialog == m_dlgFarm) 
	//{
	//	m_dlgFarm = NULL;
	//}
}

void GameScene::flashAniLayer(int type, bool bFlash)
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
	//if (type == 0)
	//{ //请求列表
	//	if (m_anilayerRequest)
	//	{
	//		m_anilayerRequest->SetCurrentAnimation(bFlash);
	//	}
	//}
	//else if (type == 1)
	//{ //邮箱
	//	if (m_anilayerMail)
	//	{
	//		m_anilayerMail->SetCurrentAnimation(bFlash);
	//	}
	//}
}

bool GameScene::HideTLShare()
{
#define TLCommonDeal(tl) \
	if(tl && tl->IsVisibled()) \
	{ \
		tl->SetVisible(false); \
		SetUIShow(false); \
		return true; \
	}

	TLCommonDeal(m_tlShare);
	TLCommonDeal(m_tlInteractive);
	TLCommonDeal(m_tlPaiHang);
	TLCommonDeal(m_tlInvitePlayers);
	TLCommonDeal(m_tlKickPlayers);
	TLCommonDeal(m_tlTiShengPlayers);
	TLCommonDeal(m_tlMarriage);

#undef TLCommonDeal
	return false;
}

void GameScene::InitTLShareContent(std::vector<std::string>& vec_str)
{
#define fastinit(pszText) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CCRectMake(0, 0, 120, 30)); \
button->SetTitle(pszText); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);

	if (!m_tlShare)
	{
		return;
	}

	if (vec_str.empty())
	{
		return;
	}

	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::iterator it = vec_str.begin();
	for (; it != vec_str.end(); it++)
	{
		fastinit(((*it).c_str()))
	}
	section->SetFocusOnCell(0);

	dataSource->AddSection(section);

	m_tlShare->SetFrameRect(
			CCRectMake((480 - 200) / 2,
					(320 - 30 * vec_str.size() - vec_str.size() - 1) / 2, 200,
					30 * vec_str.size() + vec_str.size() + 1));

	m_tlShare->SetVisible(true);
	SetUIShow(true);

	if (m_tlShare->GetDataSource())
	{
		m_tlShare->SetDataSource(dataSource);
		m_tlShare->ReflashData();
	}
	else
	{
		m_tlShare->SetDataSource(dataSource);
	}

#undef fastinit
}

void GameScene::InitContent(NDUITableLayer* tl,
		const std::vector<std::string>& vec_str, const std::vector<int>& vec_id)
{
#define fastinit(pszText, iid) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CCRectMake(0, 0, 200, 30)); \
button->SetTitle(pszText); \
button->SetTag(iid); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);

	if (!tl)
	{
		return;
	}

	if (vec_str.empty() || vec_str.size() != vec_id.size())
	{
		return;
	}

	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::const_iterator it = vec_str.begin();
	for (int i = 0; it != vec_str.end(); it++, i++)
	{
		fastinit(((*it).c_str()), vec_id[i])
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);

	int iHeightX, iHeight;
	if ((320 - 30 * vec_str.size() - vec_str.size() - 1) / 2 < 20)
	{
		iHeightX = 20;
	}
	else
	{
		iHeightX = (320 - 30 * vec_str.size() - vec_str.size() - 1) / 2;
	}
	if (30 * vec_str.size() + vec_str.size() + 1 > 300)
	{
		iHeight = 300;
	}
	else
	{
		iHeight = 30 * vec_str.size() + vec_str.size() + 1;
	}

	tl->SetFrameRect(CCRectMake((480 - 120) / 2, iHeightX, 120, iHeight));
	tl->SetVisible(true);
	SetUIShow(true);

	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}

#undef fastinit
}

void GameScene::InitTLShareContent(const char* pszText, ...)
{
	if (!m_tlShare)
	{
		return;
	}

	va_list argumentList;
	char *eachObject;
	std::vector < std::string > vectext;

	if (pszText)
	{
		vectext.push_back(std::string(pszText));
		va_start(argumentList, pszText);
		while ((eachObject = va_arg(argumentList, char*)))
		{
			vectext.push_back(std::string(eachObject));
		}
		va_end(argumentList);
	}

	if (vectext.empty())
	{
		return;
	}

	InitTLShareContent (vectext);
}

std::string GameScene::GetTLShareSelText(NDUINode* uinode)
{
	//std::string result = "";
	//	if( m_tlShare 
	//	   && m_tlShare->IsVisibled() 
	//	   && uinode
	//	   && uinode->IsKindOfClass(RUNTIME_CLASS(NDUIFrame))
	//	   )
	//	{
	//		std::vector<NDNode*> children = uinode->GetChildren();
	//		if (children.size() == 1
	//			&& children[0]->IsKindOfClass(RUNTIME_CLASS(NDUILabel))
	//			)
	//		{
	//			NDUILabel *lable = (NDUILabel*)children[0];
	//			result = lable->GetText();
	//		}
	//	}

	std::string result = "";
	if (m_tlShare
	// && m_tlShare->IsVisibled()
			&& uinode && uinode->IsKindOfClass(RUNTIME_CLASS(NDUIButton)))
	{
		NDUIButton *button = (NDUIButton*) uinode;
		result = button->GetTitle();
	}

	return result;
}

void GameScene::ReShowTaskAwardItemOpt()
{
#if 0
	std::vector < std::string > strOP;

	for (VEC_ITEM_IT it = m_vTaskAwardItem.begin();
			it != m_vTaskAwardItem.end(); it++)
	{
		if (!*it)
		{
			continue;
		}

		Item& tempItem = *(*it);
		stringstream sb;
		sb << tempItem.getItemName();

		if (tempItem.isEquip())
		{
			// 如果是装备类的将当前的�??�久值改为最大�????
			tempItem.m_nAmount = tempItem.getAmount_limit();
		}
		else
		{
			if (tempItem.m_nAmount > 1)
			{
				sb << " x" << tempItem.m_nAmount;
			}
		}

		strOP.push_back(sb.str());
	}

	m_dlgTaskAwardItemTag = GlobalDialogObj.Show(this, NULL, NULL, NULL,
			strOP);
#endif
}

void GameScene::ShowTaskAwardItemOpt(Task* task)
{
	#if 0
NDAsssert(task != NULL);

	if (task->award_item1 != 0)
	{
		Item *item = new Item(task->award_item1);
		item->m_nAmount = task->award_num1;
		m_vTaskAwardItem.push_back(item);
	}

	if (task->award_item2 != 0)
	{
		Item *item = new Item(task->award_item2);
		item->m_nAmount = task->award_num2;
		m_vTaskAwardItem.push_back(item);
	}

	if (task->award_item3 != 0)
	{
		Item *item = new Item(task->award_item3);
		item->m_nAmount = task->award_num3;
		m_vTaskAwardItem.push_back(item);
	}

	ReShowTaskAwardItemOpt();
#endif
}

void GameScene::ShowNPCDialog(bool bShowLeaveBtn/*=true*/)
{
	//m_dlgNPC = new NDUIDialog;
//	m_dlgNPC->Initialization();
//	m_dlgNPC->SetDelegate(this);

	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
	//NDMapMgr& mapmgr = NDMapMgrObj;
	//std::string strTitle="";
	//if (mapmgr.strTitle.empty())
	//{
	//	NDNpc* focusNpc = NDPlayer::defaultHero().GetFocusNpc();
	//	if (focusNpc)
	//	{
	//		strTitle = focusNpc->m_name;
	//	}
	//}
	//else
	//{
	//	strTitle = mapmgr.strTitle;
	//}
	//std::vector<GlobalDialogBtnContent> strOP;
	//vector<NDMapMgr::st_npc_op>::iterator it = mapmgr.vecNPCOPText.begin();
	//for (; it != mapmgr.vecNPCOPText.end(); it++)
	//{
	//	strOP.push_back(GlobalDialogBtnContent((*it).str, (*it).bArrow));
	//}
	//std::string text = mapmgr.strNPCText;
	//if (strOP.empty() && text.empty()) 
	//{
	//	mapmgr.ClearNPCChat();
	//	return;
	//}
	//// 农场
	//if (NDFarmMgrObj.fs.bNew) {
	//	std::vector<std::string> vec_str;
	//	vector<NDMapMgr::st_npc_op>::iterator it = mapmgr.vecNPCOPText.begin();
	//	for (; it != mapmgr.vecNPCOPText.end(); it++)
	//	{
	//		vec_str.push_back((*it).str);
	//	}
	//	if (bShowLeaveBtn)
	//		vec_str.push_back(mapmgr.strLeaveMsg.empty()? NDCommonCString("leave") : mapmgr.strLeaveMsg.c_str());
	//	NDFarmMgr& farm = NDFarmMgrObj;
	//	std::vector<int> vec_id;
	//	int iSize = vec_str.size();
	//	for (int i = 0; i < iSize; i++) {
	//		vec_id.push_back(0);
	//	}
	//	farm.fs.bNew = false;
	//	FarmProductDlg *dlg = new FarmProductDlg;
	//	dlg->Initialization();
	//	if (iSize > 0) {
	//		dlg->InitBtns(vec_str, vec_id);
	//	}
	//	dlg->AddStatus(farm.fs.title, farm.fs.total, farm.fs.left);
	//	dlg->Show(strTitle, text);
	//	return;
	//}
	//if (strOP.empty() && mapmgr.strLeaveMsg.empty() )
	//{
	//	//m_dlgNPC->Show(strTitle.c_str(), text.c_str(), NULL, NULL);
	//	m_dlgNPCTag = GlobalDialogObj.Show(this, strTitle.c_str(), text.c_str(), NULL, NULL );
	//}
	//else
	//{
	//	//m_dlgNPC->Show(strTitle.c_str(), text.c_str(), 
	//	//			       mapmgr.strLeaveMsg.empty()? NDCommonCString("leave") : mapmgr.strLeaveMsg.c_str(), strOP);
	//	m_dlgNPCTag = GlobalDialogObj.Show(this, strTitle.c_str(), 
	//		text.c_str(),
	//		//!bShowLeaveBtn ? NULL : (mapmgr.strLeaveMsg.empty()? NDCommonCString("leave") : mapmgr.strLeaveMsg.c_str()),
	//		0,
	//		strOP);
	//}
	//SetUIShow(true);
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */
}

void GameScene::SetWeaponBroken(bool bSet)
{
	bWeaponBroken = bSet;
}

void GameScene::SetDefBroken(bool bSet)
{
	bDefBroken = bSet;
}

void GameScene::SetRidePetBroken(bool bSet)
{
	bRidePetBroken = bSet;
}

void GameScene::ShowUIPaiHang()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		return;
	}

	NDNode *node = scene->GetChild(UILAYER_PAIHANG_TAG);
	if (!node)
	{
		/***
		 * 临时性注�?? 郭浩
		 * begin
		 */
// 		GameUIPaiHang *paihang = new GameUIPaiHang;
// 		paihang->Initialization();
// 		scene->AddChild(paihang, UILAYER_Z, UILAYER_PAIHANG_TAG);
		/***
		 * 临时性注�?? 郭浩
		 * end
		 */
		//CloseProgressBar;
	}
	else
	{
		//((GameUIPaiHang*)node)->UpdateMainUI(); ///< 临时性注�?? 郭浩
	}
	((GameScene*) scene)->SetUIShow(true);
}

void GameScene::ShowShop(int iNPCID /*= 0*/)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
	// 	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene)))
// 	{
// 		NDDirector::DefaultDirector()->PushScene(GameNpcStoreScene::Scene(iNPCID));
// 		return;
// 	}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	NDNode *pkNode = scene->GetChild(UILAYER_NPCSHOP_TAG);
	if (!pkNode)
	{
		//GameUINpcStore *npcstore = new GameUINpcStore;
//		npcstore->Initialization();
//		scene->AddChild(npcstore, UILAYER_Z, UILAYER_NPCSHOP_TAG);
		return;
	}
	else
	{
		//((GameUIPaiHang*)node)->UpdateMainUI();
		((GameUINpcStore*) pkNode)->UpdateBag();
		((GameUINpcStore*) pkNode)->UpdateMoney();
	}
	//((GameScene*)scene)->SetUIShow(true);
}

void GameScene::onClickSyndicate()
{
	NDPlayer& role = NDPlayer::defaultHero();

	std::vector < std::string > vOpts;

	vOpts.push_back(MENU_SYNDICATE[1]);

	switch (role.getSynRank())
	{
	case SYNRANK_NONE:
	{
		vOpts.push_back(MENU_SYNDICATE[0]);
		vOpts.push_back(MENU_SYNDICATE[2]);
	}
		break;
	case SYNRANK_LEADER:
	{
		vOpts.push_back(MENU_SYNDICATE[3]);
		vOpts.push_back(MENU_SYNDICATE[4]);
	}
		break;
	default:
	{
		vOpts.push_back(MENU_SYNDICATE[4]);
		vOpts.push_back(MENU_SYNDICATE[3]);
		vOpts.push_back(MENU_SYNDICATE[5]);
	}
		break;
	}

	InitTLShareContent (vOpts);
}

/***
 * 临时性注�?? 郭浩
 * this function
 */
//bool GameScene::OnCustomViewConfirm(NDUICustomView* customView)
//{
//	int tag = customView->GetTag();
//	switch (tag) {
//		case TAG_CV_SEND_QUESTION:
//		{
//			string text = customView->GetEditText(0);
//			if (!text.empty()) {
//				if (text.size() > 50) {
//					customView->ShowAlert(NDCommonCString("InputMax50"));
//					return false;
//				} else {
//					NDTransData bao(_MSG_GM_MAIL);
//					bao.WriteUnicodeString(text);
//					// SEND_DATA(bao);
//				}
//			}
//		}
//			break;
//		case TAG_CV_CHANG_PWD:
//		{
//			string oldPwd = customView->GetEditText(0);
//			if (oldPwd.size() == 0 || oldPwd.size() > 12) {
//				customView->ShowAlert(NDCommonCString("InputOldPW12"));
//				return false;
//			}
//			string newPwd1 = customView->GetEditText(1);
//			string newPwd2 = customView->GetEditText(2);
//			if (!checkNewPwd(newPwd1)) {
//				customView->ShowAlert(NDCommonCString("OnlyAllowAlphaNum"));
//				return false;
//			}
//			if (newPwd1.size() < 7 || newPwd1.size() > 12) {
//				customView->ShowAlert(NDCommonCString("InputPW12"));
//				return false;
//			}
//			if (newPwd1 != newPwd2) {
//				customView->ShowAlert(NDCommonCString("TwoInputPWTip"));
//				return false;
//			}
//			
//			ShowProgressBar;
//			NDTransData bao(MB_MSG_CHANGE_PASS);
//			NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
//			bao.WriteUnicodeString(mgr.GetUserName());
//			bao.WriteUnicodeString(oldPwd);
//			bao.WriteUnicodeString(newPwd1);
//			// SEND_DATA(bao);
//		}
//			break;
//		default:
//			break;
//	}
//	
//	return true;
//}
bool GameScene::checkNewPwd(const string& pwd)
{
	if (pwd.empty())
	{
		return false;
	}

	char c = 0;

	for (size_t i = 0; i < pwd.size(); i++)
	{
		c = pwd.at(i);

		if (!(((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'z'))
				|| ((c >= 'A') && (c <= 'Z'))))
		{
			return false;
		}
	}

	return true;
}

void GameScene::processMsgLightEffect(NDTransData& data)
{
	CloseProgressBar;

	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
	//NDLayer *layer = NDMapMgrObj.getMapLayerOfScene(this);
	//if (!layer)
	//{
	//	return;
	//}	
	//
	//int idActor = data.ReadInt();
	//int idLight = data.ReadInt();
	//int pos_x = data.ReadShort();
	//int pos_y = data.ReadShort();
	//int times = data.ReadByte();
	//
	//if (idLight / 1000 == 6) 
	//{
	//	NDLightEffect* lightEffect = new NDLightEffect();
	//	
	//	std::string sprFullPath = NDPath::GetAnimationPath();
	//	sprFullPath.append("firework.spr");
	//	lightEffect->Initialization(sprFullPath.c_str());
	//	
	//	lightEffect->SetLightId(idLight - 6001);
	//	
	//	NDManualRole *role = NDMapMgrObj.GetManualRole(idActor);
	//	if (role) 
	//	{
	//		if (role->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) 
	//			lightEffect->SetPosition(m_playerPosWithMap);			
	//		else			
	//			lightEffect->SetPosition(role->GetPosition());
	//	}
	//	else 
	//	{
	//		lightEffect->SetPosition(ccp(pos_x, pos_y));
	//	}
	//	
	//	lightEffect->SetRepeatTimes(times);
	//	
	//	layer->AddChild(lightEffect);
	//}		 
}

void GameScene::processVersionMsg(const char* version, int flag,
		const char* url)
{
	if (url)
	{
		m_updateUrl = url;
	}

	NDUIDialog* dlg = new NDUIDialog();
	dlg->Initialization();
	dlg->SetDelegate(this);

	if (flag != 0)
	{
		//强制更新		
		dlg->SetTag(TAG_UPDATE_FORCE);
	}
	else
	{
		//普�??�更�??
		dlg->SetTag(TAG_UPDATE_NOT_FORCE);
	}

	dlg->Show(NDCommonCString("VersionUpdate"), version,
			NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
}

/***
 * 临时性注�?? 郭浩
 * begin
 */
// DirectKey* const GameScene::GetDirectKey()
// {
// 	return m_directKey;
// }
/***
 * 临时性注�?? 郭浩
 * end
 */

void GameScene::HandleRootMenuAfterSceneLoad()
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
	//if (NDMapMgrObj.bRootItemZhangKai) 
	//{
	//	if (m_hccOPItem)
	//		m_hccOPItem->ZhangKai();
	//}
	//else 
	//{
	//	if (m_hccOPItem)
	//		m_hccOPItem->InitFinish();
	//}
	//
	//if (NDMapMgrObj.bRootMenuZhangKai) 
	//{
	//	if (m_hccOPMenu)
	//		m_hccOPMenu->ZhangKai();
	//}
	//else 
	//{
	//	if (m_hccOPMenu)
	//		m_hccOPMenu->InitFinish();
	//}
}

void GameScene::RefreshQuickItem()
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	if (m_quickItem) 
// 	{
// 		m_quickItem->Refresh();
// 	}
}

void GameScene::ShrinkQuickInteraction()
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	if (m_quickInteration)
// 	{
// 		m_quickInteration->SetShrink(true);
// 		m_bQuickInterationShow = false;
// 		if (m_picQuickInteration)
// 		{
// 			m_picQuickInteration->Rotation(m_bQuickInterationShow ? PictureRotation90 : PictureRotation270);
// 		}
// 	}
}

void GameScene::OnTimer(OBJID tag)
{
	/***
	 * 临时性注�?? 郭浩
	 * begin
	 */
// 	if (1 == tag) 
// 	{
// 		for (MAP_POS_TEXT_IT it = s_mapPosText.begin(); it != s_mapPosText.end();) 
// 		{
// 			if (it->second->OnTimer()) 
// 			{
// 				m_userState->RemovePosText(it->second);
// 				SAFE_DELETE(it->second);
// 				s_mapPosText.erase(it++);
// 			}
// 			else
// 			{
// 				it++;
// 			}
// 		}
// 	}
	/***
	 * 临时性注�?? 郭浩
	 * end
	 */

	// test

// 	if (m_pkUpdatePlayer)
// 	{
// 		m_pkUpdatePlayer->Update(10);
// 	}

	if (2 == tag)
	{
		//quitGame();
	}
}

void GameScene::processMsgPosText(NDTransData& data)
{
	int action = data.ReadByte();
	int idPosText = data.ReadByte();

	switch (action)
	{
	case 0: // 新建
	{
		MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);

		if (it != s_mapPosText.end())
		{
			SAFE_DELETE(it->second);
			s_mapPosText.erase(it);
		}

		if (s_mapPosText.count(idPosText) == 0)
		{
			int direction = data.ReadByte();
			int posX = data.ReadByte();
			int posY = data.ReadByte();
			int showSec = data.ReadShort();
			int showClr = data.ReadByte();
			// add by jhzheng
			int showBackColor = data.ReadByte();
			int num = data.ReadInt();
			string str = data.ReadUnicodeString();
			//			PosText* pt = new PosText(idPosText, direction, posX, posY, showSec, showClr, num, str, showBackColor); ///< 临时性注�?? 郭浩
			//			s_mapPosText[idPosText] = pt; ///< 临时性注�?? 郭浩
//				m_userState->AddPosText(pt); ///< 临时性注�?? 郭浩
		}
	}
		break;
	case 1: // 更新数字和文�??
	{
		/***
		 * 临时性注�?? 郭浩
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_num = data.ReadInt();
// 				pt->m_str = data.ReadUnicodeString();;
// 				//m_userState->AddPosText(pt); ///< 临时性注�?? 郭浩
// 			}
		/***
		 * 临时性注�?? 郭浩
		 * end
		 */
	}
		break;
	case 2: // 更新数字
	{
		/***
		 * 临时性注�?? 郭浩
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_num = data.ReadInt();
// 			//	m_userState->AddPosText(pt); ///< 临时性注�?? 郭浩
// 			}
		/***
		 * 临时性注�?? 郭浩
		 * end
		 */
	}
		break;
	case 3: // 更新文字
	{
		/***
		 * 临时性注�?? 郭浩
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_str = data.ReadUnicodeString();
// 			//	m_userState->AddPosText(pt); ///< 临时性注�?? 郭浩
// 			}
		/***
		 * 临时性注�?? 郭浩
		 * end
		 */
	}
		break;
	case 4: // 删除
	{
		MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
		if (it != s_mapPosText.end())
		{
			//			m_userState->RemovePosText(it->second); ///< 临时性注�?? 郭浩
			SAFE_DELETE(it->second);
			s_mapPosText.erase(it);
		}
	}
		break;
	default:
		break;
	}
}

void GameScene::ShowShopAndRecharge()
{
	//InitTLShareContent("商城", "充�????", NULL);
	map_vip_item& items = ItemMgrObj.GetVipStore();

	if (items.empty())
	{
		NDTransData bao(_MSG_SHOP_CENTER);
		bao << (unsigned char) 0;
		// SEND_DATA(bao);
		ShowProgressBar;
	}
	else
	{
		//NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene()); ///< 临时性注�?? 郭浩
	}
}

void GameScene::ShowMarriageList(vec_marriage& vMarriage)
{
	std::vector < std::string > vec_str;
	std::vector<int> vec_id;

	for_vec(vMarriage, vec_marriage_it)
	{
		vec_str.push_back((*it).name);
		vec_id.push_back((*it).iId);
	}

	InitContent(m_tlMarriage, vec_str, vec_id);
}

void GameScene::ShrinkQuickItem()
{
	/***
	 * 临时性注�?? 郭浩
	 * all
	 */
// 	if (m_quickItem)
// 		m_quickItem->SetShrink(true);
}

void GameScene::TeamRefreh(bool newJoin)
{
	/***
	 *  临时性注�?? 郭浩
	 *  all
	 */
	//NDPlayer& player = NDPlayer::defaultHero();
	//
	//if (!player.isTeamMember())
	//{
	//	SAFE_DELETE_NODE(m_quickTeam);
	//	
	//	return;
	//}
	//
	//s_team_info teaminfo;
	//
	//if (!NDMapMgrObj.GetTeamInfo(player.teamId, teaminfo))
	//{
	//	SAFE_DELETE_NODE(m_quickTeam);
	//	
	//	return;
	//}
	//else
	//{
	//	int memberCount  = 0;
	//	
	//	for (int i = 0; i < eTeamLen; i++) 
	//	{
	//		if (teaminfo.team[i] <= 0 || teaminfo.team[i] == player.m_id) continue;
	//		
	//		memberCount++;
	//	}
	//	
	//	if (memberCount == 0)
	//	{
	//		SAFE_DELETE_NODE(m_quickTeam);
	//		
	//		return;
	//	}
	//}
	//
	//if (!m_quickTeam)
	//{
	//	m_quickTeam = new QuickTeam;
	//	
	//	m_quickTeam->Initialization();
	//	
	//	AddUIChild(m_quickTeam);
	//}
	//
	//m_quickTeam->Refresh();
	//
	//if (newJoin)
	//{
	//	m_quickTeam->SetShrink(false, true);
	//}
}

void GameScene::ShowTaskFinish(bool show, std::string tip)
{
//	if (!m_quickFunc) return; ///< 临时性注�?? 郭浩

//	m_quickFunc->ShowTaskTip(show, tip); ///< 临时性注�?? 郭浩
}

bool GameScene::AddMonster(int nKey, int nLookFace)
{
	MAP_MONSTER_IT it = m_mapMonster.find(nKey);

	if (m_mapMonster.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut("DramaScene::AddMonster m_mapMonster.end() != it lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	NDMonster *monster = new NDMonster;
	monster->Initialization(nLookFace, nKey, 1);
	if (!AddNodeToMap(monster))
	{
		delete monster;
		ScriptMgrObj.DebugOutPut("DramaScene::AddMonster !AddNodeToMap lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	m_mapMonster.insert(std::make_pair(nKey, monster));

	return true;
}

bool GameScene::AddNpc(int nKey, int nLookFace)
{
	MAP_NPC_IT it = m_mapNpc.find(nKey);

	if (m_mapNpc.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut("DramaScene::AddNpc m_mapNpc.end() != it lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	NDNpc *npc = new NDNpc;
	npc->Initialization(nLookFace);
	if (!AddNodeToMap(npc))
	{
		delete npc;
		ScriptMgrObj.DebugOutPut("DramaScene::AddNpc !AddNodeToMap lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	m_mapNpc.insert(std::make_pair(nKey, npc));

	return true;
}

bool GameScene::AddManuRole(int nKey, int nLookFace)
{
	MAP_MANUROLE_IT it = m_mapManuRole.find(nKey);

	if (m_mapManuRole.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut("DramaScene::AddManuRole m_mapManuRole.end() != it lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	NDManualRole *role  = new NDManualRole;
	role->Initialization(nLookFace);
	if (!AddNodeToMap(role))
	{
		delete role;
		ScriptMgrObj.DebugOutPut("DramaScene::AddManuRole !AddNodeToMap lookface[%d]key[%d]", nLookFace, nKey);
		return false;
	}

	m_mapManuRole.insert(std::make_pair(nKey, role));

	return true;
}

NDManualRole* GameScene::GetManuRole(int nKey)
{
	MAP_MANUROLE_IT it = m_mapManuRole.find(nKey);

	if (m_mapManuRole.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDMonster* GameScene::GetMonster(int nKey)
{
	MAP_MONSTER_IT it = m_mapMonster.find(nKey);

	if (m_mapMonster.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDNpc* GameScene::GetNpc(int nKey)
{
	MAP_NPC_IT it = m_mapNpc.find(nKey);

	if (m_mapNpc.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDSprite* GameScene::GetSprite(int nKey)
{
	MAP_SPRITE_IT it = m_mapSprite.find(nKey);

	if (m_mapSprite.end() != it)
	{
		return it->second;
	}

	NDSprite* sprite = GetManuRole(nKey);

	if (NULL != sprite)
	{
		return sprite;
	}

	sprite = GetMonster(nKey);

	if (NULL != sprite)
	{
		return sprite;
	}

	sprite = GetNpc(nKey);

	if (NULL != sprite)
	{
		return sprite;
	}

	return NULL;
}

bool GameScene::RemoveNpcNode( NDNode* node )
{
	bool bSucces = false;
	for (MAP_NPC_IT it = m_mapNpc.begin(); 
		it != m_mapNpc.end(); 
		it++) 
	{
		if (node == it->second)
		{
			bSucces = RemoveNodeFromMap(node);

			if (bSucces)
			{
				m_mapNpc.erase(it);
			}

			return bSucces;
		}
	}
 
 	return false;
}

bool GameScene::AddNodeToMap( NDNode* node )
{
	NDNode* pkNode = GetChild(MAPLAYER_TAG);
	//asssert(pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer));
	NDMapLayer* pkLayer = (NDMapLayer*) pkNode;

	if (!pkLayer || !node || NULL != node->GetParent())
	{
		return false;
	}

	pkLayer->AddChild(node,0,0);

	return true;
}

bool GameScene::RemoveNodeFromMap( NDNode* node )
{
	NDNode* pkNode = GetChild(MAPLAYER_TAG);
	//asssert(pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer));
	NDMapLayer* pkLayer = (NDMapLayer*) pkNode;

	if (!pkLayer || !node || node->GetParent() != pkLayer)
	{
		return false;
	}

	pkLayer->RemoveChild(node, true);

	return true;
}

//////////////////////////////////

IMPLEMENT_CLASS(GameSceneReleaseHelper, NDObject)

GameSceneReleaseHelper* GameSceneReleaseHelper::s_instance = NULL;

GameSceneReleaseHelper::GameSceneReleaseHelper()
{
	NDDirector::DefaultDirector()->AddDelegate(this);

	m_bGameSceneRelease = false;
}

GameSceneReleaseHelper::~GameSceneReleaseHelper()
{
	NDDirector::DefaultDirector()->RemoveDelegate(this);
}

void GameSceneReleaseHelper::BeforeDirectorPopScene(NDDirector* director,
		NDScene* scene, bool cleanScene)
{
	if (scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
	{
		m_bGameSceneRelease = true;

		NDManualRole::ms_bGameSceneRelease = true;
	}
}

void GameSceneReleaseHelper::AfterDirectorPopScene(NDDirector* director,
		bool cleanScene)
{
	if (m_bGameSceneRelease)
	{
		NDManualRole::ms_bGameSceneRelease = false;

		m_bGameSceneRelease = false;
	}
}

void GameSceneReleaseHelper::Begin()
{
	//assert(s_instance == NULL);
	if (!s_instance)
	{
		s_instance = new GameSceneReleaseHelper();
	}
}

void GameSceneReleaseHelper::End()
{
	//assert(s_instance != NULL);
	SAFE_DELETE (s_instance);
}


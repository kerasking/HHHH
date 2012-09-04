/*
 *  GameScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-29.
 *  Copyright 2011 (缃戦緳)DeNA. All rights reserved.
 *
 */

#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "GameUIAttrib.h"
#include "GameUIPetAttrib.h"
#include "InitMenuScene.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "define.h"
#include "NDUIFrame.h"
#include "WorldMapScene.h"
#include "NDUIButton.h"
//#include "CGPointExtension.h"
#include "GameSettingScene.h"
#include "NDMiniMap.h"
//#include "NDDataPersist.h"
///< #include "NDMapMgr.h" 涓存椂鎬ф敞閲� 閮旦
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
#include "GameUIRequest.h"
#include "GoodFriendUILayer.h"
//#include "GameUIPaiHang.h" ///< 涓存椂鎬ф敞閲� 閮旦
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
#include "QuickItem.h"
#include "QuickFunc.h"
#include "QuickTeam.h"
#include "RequestListScene.h"
#include "NewVipStoreScene.h"
#include "BattleFieldScene.h"
#include "NDUISpecialLayer.h"

#include <sstream>
#include "NDPicture.h"
#include "..\..\ClientEngine\Utility\inc\NDDataSource.h"

const int TAG_CV_SEND_QUESTION = 1;
const int TAG_CV_CHANG_PWD = 2;

const unsigned int TAG_UPDATE_FORCE = 333;
const unsigned int TAG_UPDATE_NOT_FORCE = 444;

const char* MENU_SYNDICATE[6] =
{ "1", "2", "3", "4", "5", "6" };					///< 涓存椂鎬т慨鏀� 閮旦 瀛楃涓蹭贡鐮�
const char* MENU_SYN_MANAGE[9] =
{ "1", "2", "3", "4", "5", "6", "7", "8", "9" };	///< 涓存椂鎬т慨鏀� 閮旦 瀛楃涓蹭贡鐮�

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
 * 涓存椂鎬т慨鏀� 閮旦
 * @warning 杩欎簺瀛楃涓叉槸缂栬瘧涓嶈繃鐨勨�︹��
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
	//this->m_userState->AddStateLabel(idState, str); ///< 涓存椂鎬ф敞閲� 閮旦
}

void GameScene::DelUserState(int idState)
{
//	this->m_userState->RemoveStateLabel(idState);
}

void GameScene::SetUIShow(bool bShow)
{
	m_bUIShow = bShow;

	if (m_bUIShow)
	{ // 鐜╁鎿嶄綔UI鏃堕渶瑕佸仠姝㈠璺瓑鏀捐繖
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
				this->onClickTeam();
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
// 			//m_targetHead->SetRole(target); ///< 涓存椂鎬ф敞閲� 閮旦
// 
// 			if (m_targetHead->GetParent() == NULL) 
// 			{
// 				this->AddUIChild(m_targetHead);
// 			}
// 		}
// 	}
}

void GameScene::RefreshQuickInterationBar(NDBaseRole* target)
{
	if (m_quickInteration)
	{
		//m_quickInteration->Refresh(target); ///< 涓存椂鎬ф敞閲� 閮旦
		return;
	}
}

GameScene::GameScene()
{
	s_curGameScene = this;

//	m_userState = NULL; ///< 涓存椂鎬ф敞閲� 閮旦
//	m_playerHead = NULL; ///< 涓存椂鎬ф敞閲� 閮旦
//	m_targetHead = NULL; ///< 涓存椂鎬ф敞閲� 閮旦
//	m_petHead = NULL; ///< 涓存椂鎬ф敞閲� 閮旦
	m_tlRelieve = NULL;
	m_relieveLayer = NULL;
//	m_miniMap = NULL; ///< 涓存椂鎬ф敞閲� 閮旦
	maplayer = NULL;

	m_hccOPItem = NULL;

	m_picMap = new NDPicture();
	m_picMap->Initialization(NDPath::GetFullImagepath("ui_map.png"));
	m_btnMap = NULL;

	m_picTarget = new NDPicture();
	m_picTarget->Initialization(NDPath::GetFullImagepath("ui_target.png"));
	m_btnTarget = NULL;

	m_picInterative = new NDPicture();
	m_picInterative->Initialization(
			NDPath::GetFullImagepath("ui_interective.png"));
	m_btnInterative = NULL;

	//m_hccOPMenu = NULL;		///< 涓存椂鎬ф敞閲� 閮旦

	m_picTeam = new NDPicture();
	m_picTeam->Initialization(NDPath::GetFullImagepath("ui_team.png"));
	m_btnTeam = NULL;

	m_picSocial = new NDPicture();
	m_picSocial->Initialization(NDPath::GetFullImagepath("ui_social.png"));
	m_btnSocial = NULL;

	m_picTalk = new NDPicture();
	m_picTalk->Initialization(NDPath::GetFullImagepath("ui_talk.png"));
	m_btnTalk = NULL;

	m_picTask = new NDPicture();
	m_picTask->Initialization(NDPath::GetFullImagepath("ui_task.png"));
	m_btnTask = NULL;

	m_picBag = new NDPicture();
	m_picBag->Initialization(NDPath::GetFullImagepath("ui_bag.png"));
	m_btnBag = NULL;

	m_picStore = new NDPicture();
	m_picStore->Initialization(NDPath::GetFullImagepath("ui_store.png"));
	m_btnStore = NULL;

	m_picMenu = new NDPicture();
	m_picMenu->Initialization(NDPath::GetFullImagepath("ui_menu.png"));
	m_btnMenu = NULL;

	m_tlShare = NULL;

	//m_anilayerRequest = NULL;		///< 涓存椂鎬ф敞閲� 閮旦
	//m_anilayerMail = NULL;		///< 涓存椂鎬ф敞閲� 閮旦

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

	m_dlgNPCTag = -1;

	m_tlInvitePlayers = NULL;

	m_tlKickPlayers = NULL;
	m_tlTiShengPlayers = NULL;
	m_tlPaiHang = NULL;
	m_tlMarriage = NULL;
	m_uiLayer = NULL;

	m_dlgFarm = NULL;
//	m_directKey = NULL; ///< 涓存椂鎬ф敞閲� 閮旦

	m_quickItem = NULL;

//	m_quickFunc = NULL; ///< 涓存椂鎬ф敞閲� 閮旦

	m_quickTeam = NULL;
}

GameScene::~GameScene()
{
	if (s_curGameScene == this)
	{
		s_curGameScene = NULL;
	}

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	if (m_targetHead && m_targetHead->GetParent() == NULL)
// 	{
// 		SAFE_DELETE(m_targetHead);
// 	}
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	BattleMgrObj.quitBattle(false);
	SAFE_DELETE (m_picMap);
	SAFE_DELETE (m_picTarget);
	SAFE_DELETE (m_picInterative);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	/*
	 if (m_directKey && m_directKey->GetParent() == NULL)
	 {
	 delete m_directKey;
	 m_directKey = NULL;
	 }
	 */

	if (this->m_uiLayer->GetParent() == NULL)
	{
		SAFE_DELETE(this->m_uiLayer);
	}
}

void GameScene::AddUIChild(NDNode* node)
{
	this->m_uiLayer->AddChild(node);
}

void GameScene::AddUIChild(NDNode* node, int z)
{
	this->m_uiLayer->AddChild(node, z);
}

void GameScene::AddUIChild(NDNode* node, int z, int tag)
{
	this->m_uiLayer->AddChild(node, z, tag);
}

void GameScene::OnBattleEnd()
{
	//this->AddChild(m_uiLayer);
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

	this->RemoveChild(this->m_uiLayer, false);

	std::vector<NDNode*> vDel;

	std::vector<NDNode*>::iterator it = this->m_pkChildrenList.begin();

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
	//for (; it != this->m_childrenList.end(); it++) 
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
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

	CGSize kWinSize = NDDirector::DefaultDirector()->GetWinSize();

	maplayer = new NDMapLayerLogic();
	maplayer->Initialization(mapID);
	this->AddChild(maplayer, MAPLAYER_Z, MAPLAYER_TAG);

	m_uiLayer = new MapUILayer;
	m_uiLayer->Initialization();
	this->AddChild(m_uiLayer, MAP_UILAYER_Z);

	// 纭繚鏂瑰悜閿渶鍏堝姞鍏ュ埌uilayer
	this->ShowDirectKey(true);
	/*
	 do
	 {
	 m_hccOPItem = new NDUIHControlContainer;
	 m_hccOPItem->Initialization();
	 m_hccOPItem->SetFrameRect(CGRectMake(480-103, 120, 40, 200+2));
	 m_hccOPItem->SetRectInit(CGRectMake(480-103, 120, 40, 200+2));
	 m_hccOPItem->SetButtonName("ui_menu_scroll.png");
	 m_hccOPItem->SetUINodeInterval(20);

	 m_btnMap = new NDUIButton;
	 m_btnMap->Initialization();
	 m_btnMap->SetImage(m_picMap);
	 m_btnMap->SetDelegate(this);
	 m_btnMap->SetFrameRect(CGRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnMap);

	 m_btnTarget = new NDUIButton;
	 m_btnTarget->Initialization();
	 m_btnTarget->SetImage(m_picTarget);
	 m_btnTarget->SetDelegate(this);
	 m_btnTarget->SetFrameRect(CGRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnTarget);

	 m_btnInterative = new NDUIButton;
	 m_btnInterative->Initialization();
	 m_btnInterative->SetImage(m_picInterative);
	 m_btnInterative->SetDelegate(this);
	 m_btnInterative->SetFrameRect(CGRectMake(0, 0, 40, 40));
	 m_hccOPItem->AddUINode(m_btnInterative);

	 m_hccOPItem->SetDelegate(this);

	 this->AddUIChild(m_hccOPItem);
	 } while (0);

	 do
	 {
	 m_hccOPMenu = new NDUIHControlContainer;
	 m_hccOPMenu->Initialization();
	 m_hccOPMenu->SetFrameRect(CGRectMake(480-40, 0, 40, 320));
	 m_hccOPMenu->SetRectInit(CGRectMake(480-40, 0, 40, 320));
	 m_hccOPMenu->SetButtonName("ui_item_scroll.png");
	 m_hccOPMenu->SetUINodeInterval(0);
	 m_hccOPMenu->SetBGImage("ui_menu_line.png");

	 #define fastinit(btn,pic) \
do \
{ \
NDUILayer *layer = new NDUILayer; \
layer->Initialization(); \
layer->SetFrameRect(CGRectMake(0, 0, 40, 40)); \
layer->SetBackgroundImage(GetImgPath("ui_btn_bg.png")); \
m_hccOPMenu->AddUINode(layer); \
btn = new NDUIButton; \
btn->Initialization(); \
btn->SetImage(pic); \
btn->SetDelegate(this); \
btn->SetFrameRect(CGRectMake(0, 0, 40, 40)); \
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
	 this->AddUIChild(m_hccOPMenu);
	 } while (0); */

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_anilayerRequest = new NDUIAniLayer;
// 	m_anilayerRequest->Initialization("cuebubble.spr");
// 	m_anilayerRequest->SetFrameRect(CGRectMake(0, 0, 480, 320));
// 	//鍘熷厛x鍧愭爣涓�鐢变簬妯℃嫙鍣ㄧ洸鍖�,鏃犳硶娴嬭瘯,鏁呮妸x鍧愭爣璋冧负40
// //#ifdef DEBUG
// 	m_anilayerRequest->SetAniRectXYSize(CGRectMake(0, 320-53-9, 57, 53), CGSizeMake(17, 17));
// //#else
// 	//m_anilayerRequest->SetAniRectXYSize(CGRectMake(0, 120, 25, 22), CGSizeMake(2, 2));
// //#endif
// 	m_anilayerRequest->SetCurrentAnimation(0);
// 	m_anilayerRequest->SetDelegate(this);
// 	this->AddUIChild(m_anilayerRequest);
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	/*
	 m_anilayerMail = new NDUIAniLayer;
	 m_anilayerMail->Initialization("mail_flash.spr");
	 m_anilayerMail->SetFrameRect(CGRectMake(0, 0, 480, 320));
	 #ifdef DEBUG
	 m_anilayerMail->SetAniRectXYSize(CGRectMake(40, 160, 25, 17), CGSizeMake(2, 2));
	 #else
	 m_anilayerMail->SetAniRectXYSize(CGRectMake(0, 160, 25, 17), CGSizeMake(2, 2));
	 #endif
	 m_anilayerMail->SetCurrentAnimation(0);
	 m_anilayerMail->SetDelegate(this);
	 this->AddUIChild(m_anilayerMail);
	 */

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_tlShare = new NDUITableLayer;
// 	m_tlShare->Initialization();
// 	m_tlShare->VisibleSectionTitles(false);
// 	m_tlShare->SetDelegate(this);
// 	m_tlShare->SetVisible(false);
// 	this->AddUIChild(m_tlShare);
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	//m_tlInvitePlayers = new NDUITableLayer;
	//m_tlInvitePlayers->Initialization();
	//m_tlInvitePlayers->VisibleSectionTitles(false);
	//m_tlInvitePlayers->SetDelegate(this);
	//m_tlInvitePlayers->SetVisible(false);
	//this->AddUIChild(m_tlInvitePlayers);
	//m_tlKickPlayers = new NDUITableLayer;
	//m_tlKickPlayers->Initialization();
	//m_tlKickPlayers->VisibleSectionTitles(false);
	//m_tlKickPlayers->SetDelegate(this);
	//m_tlKickPlayers->SetVisible(false);
	//this->AddUIChild(m_tlKickPlayers);
	//
	//m_tlTiShengPlayers = new NDUITableLayer;
	//m_tlTiShengPlayers->Initialization();
	//m_tlTiShengPlayers->VisibleSectionTitles(false);
	//m_tlTiShengPlayers->SetDelegate(this);
	//m_tlTiShengPlayers->SetVisible(false);
	//this->AddUIChild(m_tlTiShengPlayers);
	//
	//m_tlPaiHang = new NDUITableLayer;
	//m_tlPaiHang->Initialization();
	//m_tlPaiHang->VisibleSectionTitles(false);
	//m_tlPaiHang->SetDelegate(this);
	//m_tlPaiHang->SetVisible(false);
	//this->AddUIChild(m_tlPaiHang);
	//
	//m_tlMarriage = new NDUITableLayer;
	//m_tlMarriage->Initialization();
	//m_tlMarriage->VisibleSectionTitles(false);
	//m_tlMarriage->SetDelegate(this);
	//m_tlMarriage->SetVisible(false);
	//this->AddUIChild(m_tlMarriage);
	do
	{
		//m_tlInteractive = new NDUITableLayer;
		//m_tlInteractive->Initialization();
		//m_tlInteractive->VisibleSectionTitles(false);
		//m_tlInteractive->SetVisible(false);
		//m_tlInteractive->SetDelegate(this);
		//this->AddUIChild(m_tlInteractive);
	} while (0);

	//this->ShowMiniMap(NDDataPersist::IsGameSettingOn(GS_SHOW_MINI_MAP));
	//this->ShowPlayerHead(NDDataPersist::IsGameSettingOn(GS_SHOW_HEAD));
	this->ShowMiniMap(true);
	this->ShowPlayerHead(true);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_userState = new UserStateLayer;
// 	m_userState->Initialization();
// 	this->AddUIChild(m_userState, 2);
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	NDUILayer* layer = new NDUILayer;
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(0, 0, 36, 42));

	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("scenerolehandle.png"), false);
	m_imgHeadShow = new NDUIImage;
	m_imgHeadShow->Initialization();
	m_imgHeadShow->SetPicture(pic, true);
	m_imgHeadShow->SetFrameRect(CGRectMake(0, 0, 27, 46));
	this->AddUIChild(m_imgHeadShow, 1);

	m_btnHeadShow = new NDUIButton;
	m_btnHeadShow->Initialization();
	m_picHeadShow = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("handlearraw.png"), false);
	m_picHeadShow->Rotation(PictureRotation180);
	m_btnHeadShow->SetImage(m_picHeadShow, true, CGRectMake(10, 13, 9, 16),
			true);
	m_btnHeadShow->SetFrameRect(CGRectMake(0, 0, 27, 46));
	m_btnHeadShow->SetDelegate(this);
	layer->AddChild(m_btnHeadShow);
	this->AddUIChild(layer, 1);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_targetHead = new TargetHeadInMap;
// 	m_targetHead->Initialization();
// 	m_targetHead->SetFrameRect(CGRectMake(210.0f, 0.0f, 87.0f, 40.0f));
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	NDUIImage* imgShrinkBg = new NDUIImage;
	imgShrinkBg->Initialization();
	imgShrinkBg->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bar_shrink.png"), false));
	imgShrinkBg->SetFrameRect(CGRectMake(35.5, 284, 62, 36));
	this->AddUIChild(imgShrinkBg);

	imgShrinkBg = new NDUIImage;
	imgShrinkBg->Initialization();
	imgShrinkBg->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bar_shrink.png"), false));
	imgShrinkBg->SetFrameRect(
			CGRectMake(kWinSize.width - 66.5 - 31, 284, 62, 36));
	this->AddUIChild(imgShrinkBg);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_bQuickInterationShow = true;
// 	
// 	m_quickInteration = new QuickInteraction;
// 	m_quickInteration->Initialization();
// 	//m_quickInteration->SetBackgroundColor(ccc4(255, 0, 255, 255));
// 	m_quickInteration->SetFrameRect(CGRectMake(66.5, 247.0f, 347, 75.0f));
// 	this->AddUIChild(m_quickInteration);
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	layer = new NDUILayer;
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(35.5, 284, 62, 36));

	NDUIImage* imgQuickInterationShrink = new NDUIImage;
	imgQuickInterationShrink->Initialization();
	imgQuickInterationShrink->SetPicture(
			NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPathBattleUI("bottom_shrink.png"), false),
			true);
	imgQuickInterationShrink->SetFrameRect(CGRectMake(14, 14, 34, 22));
	layer->AddChild(imgQuickInterationShrink);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
// 	m_quickItem = new QuickItem;
// 	m_quickItem->Initialization();
// 	m_quickItem->SetFrameRect(CGRectMake(66.5, 244.0f, 400.0f, 78.0f));
// 	this->AddUIChild(m_quickItem);
//	RefreshQuickItem();
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

//	m_quickItem->SetShrink(true); ///< 涓存椂鎬ф敞閲� 閮旦
	m_btnQuickInterationShrink = new NDUIButton;
	m_btnQuickInterationShrink->Initialization();
	m_picQuickInteration = NDPicturePool::DefaultPool()->AddPicture(
			NDPath::GetImgPathBattleUI("handlearraw.png"), false);
	m_picQuickInteration->Rotation(PictureRotation90);
	m_btnQuickInterationShrink->SetImage(m_picQuickInteration, true,
			CGRectMake(10, 20, 16, 9), true);
	m_btnQuickInterationShrink->SetFrameRect(CGRectMake(13, 00, 62, 56));
	m_btnQuickInterationShrink->SetDelegate(this);
	layer->AddChild(m_btnQuickInterationShrink);
	this->AddUIChild(layer);

//	m_quickFunc = new QuickFunc; ///< 涓存椂鎬ф敞閲� 閮旦
//	m_quickFunc->Initialization(true); ///< 涓存椂鎬ф敞閲� 閮旦
//	this->AddUIChild(m_quickFunc); ///< 涓存椂鎬ф敞閲� 閮旦

	TeamRefreh(false);
}

CGSize GameScene::GetSize()
{
	return this->maplayer->GetContentSize();
}

cocos2d::CCArray* GameScene::GetSwitchs()
{
	return this->maplayer->GetMapData()->getSwitchs();
}

void GameScene::SetMiniMapVisible(bool bVisible)
{
// 	if (m_miniMap)
// 	{
	//this->m_miniMap->EnableDraw(bVisible);
//	}

	// 鍚屾椂涔熻缃ご鍍�
//	if (m_playerHead)
//	{
	//this->m_playerHead->EnableDraw(bVisible);
//	}

//	if (m_petHead)
//	{
	//this->m_petHead->EnableDraw(bVisible);
//	}
}

void GameScene::ShowPetHead(bool bShow)
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
// 			this->AddUIChild(m_petHead, 0);
// 		}
// 		else
// 		{
// 			m_petHead->ChangeBattlePet(battlepet);
// 		}
// 	}
// 	else if (this->m_petHead) 
// 	{
// 		m_petHead->RemoveFromParent(true);
// 		m_petHead = NULL;
// 	}
}

void GameScene::ShowPlayerHead(bool bShow)
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * all
	 */
// 	if (bShow)
// 	{
// 		if (!this->m_playerHead)
// 		{
// 			m_playerHead = new PlayerHeadInMap(&NDPlayer::defaultHero());
// 			m_playerHead->Initialization();
// 			this->AddUIChild(m_playerHead);
// 		}
// 	} 
// 	else
// 	{
// 		if (this->m_playerHead) 
// 		{
// 			this->m_uiLayer->RemoveChild(m_playerHead, true);
// 			m_playerHead = NULL;
// 		}
// 	}
// 
// 	this->ShowPetHead(bShow);
}

void GameScene::ShowDirectKey(bool bShow)
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
// 			this->AddUIChild(m_directKey);
// 			
// 			m_directKey->ShowFinish(this);
// 		}
// 	}
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

//	else 
//	{
//		SAFE_DELETE_NODE(m_directKey);
//	}
}

const CGRect RECT_MINI_MAP = CGRectMake(308.0f, 0.0f, 172.0f, 84.0f);

void GameScene::ShowMiniMap(bool bShow)
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * this function
	 */
// 	if (bShow) 
// 	{
// 		if (!this->m_miniMap) 
// 		{
// 			m_miniMap = new NDMiniMap();
// 			m_miniMap->Initialization();
// 			//m_miniMap->SetGameScene(this);
// 			m_miniMap->SetFrameRect(RECT_MINI_MAP);
// 			this->AddUIChild(m_miniMap);
// 		}
// 	} 
// 	else
// 	{
// 		if (this->m_miniMap) 
// 		{
// 			this->m_uiLayer->RemoveChild(m_miniMap, true);
// 			m_miniMap = NULL;
// 		}
// 	}
}

void GameScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
		unsigned int cellIndex, NDSection* section)
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
//		if ( str == "鐜╁淇℃伅")
//		{ // "鐜╁淇℃伅"
//			sendQueryPlayer(role->m_id, _SEE_USER_INFO);
//		}
//		else if ( str == "鏌ョ湅瑁呭")
//		{ // "鏌ョ湅瑁呭"
//			sendQueryPlayer(role->m_id, SEE_EQUIP_INFO);
//		}
//		else if ( str == "閭�璇风粍闃�")
//		{ // "閭�璇风粍闃�"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "鍔犲叆闃熶紞")
//		{ // "鍔犲叆闃熶紞"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_JOIN << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//			
//		}
//		else if ( str == "閭�璇风粍闃�")
//		{ // "閭�璇风粍闃�"
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "浜ゆ槗")
//		{ // "浜ゆ槗"
//			//if (AutoFindPath.getInstance().isWork()) {
//			//				if (!AutoFindPath.getInstance().isClickScreenMode()) {
//			//					GameScreen.getInstance().initNewChat(new ChatRecordManager(5, "绯荤粺", "鎮ㄦ鍦ㄤ娇鐢ㄨ嚜鍔ㄥ鑸紝涓嶈兘杩涜浜ゆ槗锛�"));
//			//					break;
//			//				}
//			//				AutoFindPath.getInstance().stop();
//			//			} todo
//			trade(role->m_id, 0);
//		}
//		else if ( str == "娣诲姞濂藉弸")
//		{ // "娣诲姞濂藉弸"
//			sendAddFriend(role->m_name);
//		}
//		else if ( str == "绉佽亰")
//		{ // "绉佽亰"
//			PrivateChatInput::DefaultInput()->SetLinkMan(role->m_name.c_str());
//			PrivateChatInput::DefaultInput()->Show();
//		}
//		else if ( str == "PK")
//		{ // "PK"
//			sendPKAction(*role, BATTLE_ACT_PK);
//		}
//		else if ( str == "姣旀")
//		{ // "姣旀"
//			sendRehearseAction(role->m_id, REHEARSE_APPLY);
//		}
//		else if ( str == "鏌ョ湅瀹犵墿")
//		{ // "鏌ョ湅瀹犵墿"
//			NDTransData bao(_MSG_SEE);
//			bao << (unsigned char)3 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "鎷滃笀")
//		{ // "鎷滃笀"
//			NDTransData bao(_MSG_TUTOR);
//			bao << (unsigned char)1 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "鏀跺緬")
//		{ // "鏀跺緬"
//			NDTransData bao(_MSG_TUTOR);
//			bao << (unsigned char)4 << role->m_id;
//			// SEND_DATA(bao);
//		}
//		else if ( str == "鏌ョ湅鎽嗘憡" )
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
//		if (strCurSel == "涓栫晫鍦板浘")
//		{
//			//NDDirector::DefaultDirector()->PushScene(WorldMapScene::Scene(maplayer->GetMapIndex()));
//			//table->SetVisible(false);
//		}
//		else if (strCurSel == "NPC瀵艰埅")
//		{
//			NpcList::refreshScroll();
//		}
//		else if (strCurSel == "鍐涘洟")
//		{
//			this->onClickSyndicate();
//		}
//		else if (strCurSel == "鐜╁")
//		{
//			GameUIPlayerList *playerlist = new GameUIPlayerList;
//			playerlist->Initialization();
//			this->AddChild(playerlist, UILAYER_Z, UILAYER_PLAYER_LIST_TAG);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "甯堝緬")
//		{
//			/*
//			TutorUILayer *list = new TutorUILayer;
//			list->Initialization();
//			this->AddChild(list, UILAYER_Z);
//			table->SetVisible(false);
//			SetUIShow(true);
//			*/
//		}
//		else if (strCurSel == "濂藉弸")
//		{
//			GoodFriendUILayer *friendList = new GoodFriendUILayer;
//			friendList->Initialization();
//			this->AddChild(friendList, UILAYER_Z, UILAYER_GOOD_FRIEND_LIST_TAG);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "鍟嗗煄")
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
//		else if (strCurSel == "鍏呭��")
//		{
//			//sendChargeInfo(0);
//		}
//		else if (strCurSel == "浜虹墿")
//		{
//			InitTLShareContent("灞炴��", "鎶�鑳�", "鎽嗘憡", "鐗规畩鐘舵��", NULL);
//		}
//		else if (strCurSel == "瀹犵墿")
//		{
//			InitTLShareContent("瀹犵墿灞炴��", "瀹犵墿鎶�鑳�", NULL);
//		}
//		else if (strCurSel == "搴勫洯")
//		{
//			if (false) // 濡傛灉娌℃湁搴勫洯 todo 鏆傛椂鍏堜笉浣�
//			{
//				InitTLShareContent("绔嬪嵆鍒涘缓", NULL);
//			}
//			else 
//			{
//				InitTLShareContent("搴勫洯鍟嗗煄", "搴勫洯鍔ㄦ��", "杩滅▼杩涘叆", NULL);
//			}
//			//showDialog("", "鏆傛湭寮�鏀�,鏁鍏虫敞");
//		}
//		else if (strCurSel == "绯荤粺")
//		{
//			InitTLShareContent("娓告垙璁剧疆", "鍒犻櫎瑙掕壊", "鐧诲綍淇℃伅", "鍥炰富鐣岄潰", "鍗℃澶嶄綅", NULL);
//		}
//		else if (strCurSel == "鎺掕")
//		{
//			ShowProgressBar;
//			NDTransData bao(_MSG_BILLBOARD_QUERY);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "娲诲姩")
//		{
//			ShowProgressBar;
//			NDTransData bao(_MSG_ACTIVITY);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "瀹㈡湇")
//		{
//			InitTLShareContent("鎴戣鎻愰棶", "淇敼瀵嗙爜", "瀹㈡湇澹版槑", "鍏憡鏌ョ湅", NULL);
//		}
//		else if (strCurSel == "鍐涘洟鎺掕")
//		{
//			sendQueryTaxis(0);
//		}
//		else if (strCurSel == "鍐涘洟搴斿緛")
//		{
//			queryCreatedInSynList(0);
//		}
//		else if (strCurSel == "閭�璇峰嚱")
//		{
//			sendQueryInviteList();
//		}
//		else if (strCurSel == "鑱屼綅绔為��")
//		{
//			InitTLShareContent("鍐涘洟闀�", "鍓洟闀�", "鍏冭��", "鍫備富", "闂ㄤ富", NULL);
//		}
//		else if (strCurSel == "鍐涘洟闀�")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 12);
//		}
//		else if (strCurSel == "鍓洟闀�")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 11);
//		}
//		else if (strCurSel == "鍏冭��")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 10);
//		}
//		else if (strCurSel == "鍫備富")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 5);
//		}
//		else if (strCurSel == "闂ㄤ富")
//		{
//			sendSynElection(ACT_QUERY_OFFICER, 1);
//		}
//		else if (strCurSel == "鎶曠エ绠�")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_VOTE_LIST);
//		}
//		else if (strCurSel == "鍐涘洟绠＄悊")
//		{
//			int synRank = NDPlayer::defaultHero().getSynRank();
//			
//			vector<string> vMgrOpt;
//			
//			for (int i = 0; i < 9; i++) {
//				if (i == 4) {// "鍐涘洟鍗囩骇"锛屽壇鍥㈠強浠ヤ笂鏈夋潈闄�
//					if (synRank < SYNRANK_VICE_LEADER) {
//						continue;
//					}
//				} else if (i == 5 || i == 6 || i == 7) {// "鍐涘洟閭�璇�"//"浜哄憳瀹℃牳"//"杈炶亴"锛岄棬涓诲強浠ヤ笂鏈夋潈闄�
//					if (synRank < SYNRANK_MENZHU_SHENG) {
//						continue;
//					}
//				}
//				vMgrOpt.push_back(MENU_SYN_MANAGE[i]);
//			}
//			InitTLShareContent(vMgrOpt);
//		}
//		else if (strCurSel == "鍐涘洟鍏憡")
//		{
//			sendQueryAnnounce();
//		}
//		else if (strCurSel == "鍐涘洟淇℃伅")
//		{
//			sendQueryPanelInfo();
//		}
//		else if (strCurSel == "鍐涘洟浠撳簱")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_SYN_STORAGE);
//		}
//		else if (strCurSel == "鍐涘洟鍗囩骇")
//		{
//			sendQuerySynNormalInfo(ACT_QUERY_SYN_UPGRADE_INFO);
//		}
//		else if (strCurSel == "鍐涘洟閭�璇�")
//		{
//			SyndicateInvite::Show();
//		}
//		else if (strCurSel == "浜哄憳瀹℃牳")
//		{
//			sendQueryApprove(0);
//		}
//		else if (strCurSel == "鍐涘洟鎴愬憳")
//		{
//			sendQueryMembers(0);
//		}
//		else if (strCurSel == "杈炶亴")
//		{
//			this->m_dlgSyndicateResign = GlobalDialogObj.Show(this, 
//									  "娓╅Θ鎻愮ず",
//									  "璇锋偍纭鏄惁瑕佽緸鎺夊綋鍓嶅畼鑱�", 0, "纭杈炶亴", NULL);
//		}
//		else if (strCurSel == "绂诲紑鍐涘洟")
//		{
//			this->m_dlgSyndicateQuit = GlobalDialogObj.Show(this, 
//									  "娓╅Θ鎻愮ず",
//									  "澶т緺鎮ㄧ‘瀹氳绂诲紑鏈啗鍥�", 0, NDCommonCString("Ok"), NULL);
//		}
//		else if (strCurSel == "灞炴��")
//		{
//			//SetUIShow(true);
////			GameUIAttrib *attrib = new GameUIAttrib;
////			attrib->Initialization();
////			this->AddChild(attrib, UILAYER_Z, UILAYER_ATTRIB_TAG);
//			NDDirector::DefaultDirector()->PushScene(GameAttribScene::Scene());
//			table->SetVisible(false);
//		}
//		else if (strCurSel == "鎶�鑳�")
//		{
//			InitTLShareContent("鎴樻枟鎶�鑳�", "鐐奸噾鎶�鑳�", "瀹濈煶鍚堟垚", NULL);
//		}
//		else if (strCurSel == "鎽嗘憡")
//		{
//			if (NDMapMgrObj.canBooth()) {
//				VendorUILayer::Show(this);
//				table->SetVisible(false);
//				SetUIShow(true);
//			} else {
//				showDialog("娓╅Θ鎻愮ず", "鎮ㄤ笉鑳藉湪杩欓噷鎽嗘憡");
//			}
//		}
//		else if (strCurSel == "鐗规畩鐘舵��")
//		{
//			UserStateUILayer *list = new UserStateUILayer;
//			list->Initialization();
//			this->AddChild(list, UILAYER_Z);
//			table->SetVisible(false);
//			SetUIShow(true);
//		}
//		else if (strCurSel == "瀹犵墿灞炴��")
//		{
//			//if (NDPlayer::defaultHero().battlepet)
//			//{
//				//GameUIPetAttrib *attrib = new GameUIPetAttrib;
////				attrib->Initialization();
////				this->AddChild(attrib, UILAYER_Z, UILAYER_PET_ATTRIB_TAG);
//				//NDDirector::DefaultDirector()->PushScene(GamePetAttribScene::Scene());
//			//}
//			//else 
//			//{
//			//	GlobalDialogObj.Show(NULL, "鎻愮ず", "鎮ㄦ病鏈夎澶囧疇鐗�", NULL, NULL);
//			//}	
//			
//			//table->SetVisible(false);
//			//SetUIShow(true);
//		}
//		else if (strCurSel == "瀹犵墿鎶�鑳�")
//		{
//			PetSkillScene *scene = new PetSkillScene;
//			scene->Initialization();
//			NDDirector::DefaultDirector()->PushScene(scene);
//		}
//		else if (strCurSel == "娓告垙璁剧疆")
//		{
//			NDDirector::DefaultDirector()->PushScene(GameSettingScene::Scene());
//			table->SetVisible(false);
//		}
//		else if (strCurSel == "鍒犻櫎瑙掕壊")
//		{
//			this->m_dlgDelRoleTag = GlobalDialogObj.Show(this, "娓╅Θ鎻愮ず", "澶т緺鎮ㄧ‘瀹氳鍒犻櫎瑙掕壊,鍒犻櫎鍚庡皢鏃犳硶鎵惧洖鎵�鏈夋暟鎹�.鏄惁鍒犻櫎",
//					     NULL, NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
//		}
//		else if (strCurSel == "鐧诲綍淇℃伅")
//		{
//			stringstream ss;
//			NDPlayer& player = NDPlayer::defaultHero();
//			ss << NDBeforeGameMgrObj.GetServerDisplayName()
//			<< " (" << player.GetCol() << ", " << player.GetRow() << ")";
//			GlobalDialogObj.Show(NULL, "鐧诲綍淇℃伅", ss.str().c_str(), NULL, NULL);
//		}
//		else if (strCurSel == "鍥炰富鐣岄潰")
//		{
//			quitGame();
//		}
//		else if (strCurSel == "鍗℃澶嶄綅")
//		{
//			NDTransData bao(_MSG_RESET_POSITION);
//			// SEND_DATA(bao);
//			
//			ShowProgressBar;
//		}
//		else if (strCurSel == "鎴戣鎻愰棶")
//		{
//			NDUICustomView *view = new NDUICustomView;
//			view->Initialization();
//			view->SetTag(TAG_CV_SEND_QUESTION);
//			view->SetDelegate(this);
//			std::vector<int> vec_id; vec_id.push_back(1);
//			std::vector<std::string> vec_str; vec_str.push_back("璇疯緭鍏ュ唴瀹�,鏈�澶氳緭鍏�涓眽瀛�");
//			view->SetEdit(1, vec_id, vec_str);
//			view->Show();
//			this->AddChild(view);
//		}
//		else if (strCurSel == "淇敼瀵嗙爜")
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
//			vec_str.push_back("璇疯緭鍏ュ綋鍓嶅瘑鐮�(12浣嶄互鍐�)");
//			vec_str.push_back("璇疯緭鍏ユ柊瀵嗙爜:(7-12浣�)");
//			vec_str.push_back("璇峰啀娆¤緭鍏ユ柊瀵嗙爜:(7-12浣�)");
//			
//			view->SetEdit(3, vec_id, vec_str);
//			view->Show();
//			
//			this->AddChild(view);
//		}
//		else if (strCurSel == "瀹㈡湇澹版槑")
//		{
//			NDTransData bao(_MSG_CUSTOMER_SERVICE);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "鍏憡鏌ョ湅")
//		{
//			NDMapMgr& mgr = NDMapMgrObj;
//			GlobalShowDlg(mgr.noteTitle, mgr.noteContent);
//		}
//		else if (strCurSel == "鎴樻枟鎶�鑳�")
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
//				this->AddChild(battleskill, UILAYER_Z, UILAYER_BATTLE_SKILL_TAG);
//				SetUIShow(true);
//			}
//			else
//			{
//				showDialog("鎿嶄綔澶辫触", "澶т緺浣犺繕鏈ㄦ湁瀛︿範鎴樻枟鎶�鑳藉憿!");
//			}
//		}
//		else if (strCurSel == "鐐奸噾鎶�鑳�")
//		{
//			if ( NDMapMgrObj.getLifeSkill(ALCHEMY_IDSKILL) != NULL )
//			{
//				LifeSkillScene *scene = new LifeSkillScene;
//				scene->Initialization(ALCHEMY_IDSKILL, LifeSkillScene_Query);
//				NDDirector::DefaultDirector()->PushScene(scene);
//			}
//			else 
//			{
//				GlobalShowDlg("鎿嶄綔澶辫触", "澶т緺浣犺繕鏈ㄦ湁瀛︿範鐐奸噾鎶�鑳藉憿!璧剁揣鍘诲垵绾х偧閲戞妧鑳絥pc閭ｉ噷瀛︿範鍚�.");
//			}
//			
//		}
//		else if (strCurSel == "瀹濈煶鍚堟垚")
//		{
//			if ( NDMapMgrObj.getLifeSkill(GEM_IDSKILL) != NULL )
//			{
//				LifeSkillScene *scene = new LifeSkillScene;
//				scene->Initialization(GEM_IDSKILL, LifeSkillScene_Query);
//				NDDirector::DefaultDirector()->PushScene(scene);
//			}
//			else 
//			{
//				GlobalShowDlg("鎿嶄綔澶辫触", "澶т緺浣犺繕鏈ㄦ湁瀛︿範瀹濈煶鍚堟垚鎶�鑳藉憿!璧剁揣鍘诲垵绾у疂鐭冲悎鎴恘pc閭ｉ噷瀛︿範鍚�.");
//			}
//		}
//		else if (strCurSel == "鏀朵欢绠�")
//		{
//			GameMailsScene *scene = new GameMailsScene;
//			scene->Initialization();
//			NDDirector::DefaultDirector()->PushScene(scene);
//		}
//		else if (strCurSel == "鍙戜欢绠�")
//		{
//			NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene());
//		}
//		else if (strCurSel == "鍏抽棴鍔犲叆" || strCurSel == "寮�鍚姞鍏�")
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
//		else if (strCurSel == "閭�璇峰叆闃�")
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
//				vec_str.push_back("鏃�"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlInvitePlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "璇峰嚭闃熶紞")
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
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "娌℃湁闃熷憳锛�");
//			//				GameScreen.getInstance().initNewChat(
//			//													 new ChatRecord(5, GameScreen.role.getName(), "娌℃湁闃熷憳锛�"));
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
//				vec_str.push_back("鏃�"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlKickPlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "绂诲紑闃熶紞")
//		{
//			m_stackUIMenu.clear();
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_LEAVE << NDPlayer::defaultHero().m_id << int(0);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "鏄剧ず鎴愬憳")
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
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "娌℃湁闃熷憳锛�");
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
//							std::string str = "[闃熼暱]"; str += role->m_name;
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
//		else if (strCurSel == "瑙ｆ暎闃熶紞")
//		{
//			m_stackUIMenu.clear();
//			NDTransData bao(_MSG_TEAM);
//			bao << (unsigned short)MSG_TEAM_DISMISS << NDPlayer::defaultHero().m_id << int(0);
//			// SEND_DATA(bao);
//		}
//		else if (strCurSel == "鎻愬崌闃熼暱")
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
//				Chat::DefaultChat()->AddMessage(ChatTypeSystem, "娌℃湁闃熷憳锛�");
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
//				vec_str.push_back("鏃�"); vec_id.push_back(0);
//			}
//			
//			InitContent(m_tlTiShengPlayers, vec_str, vec_id);
//		}
//		else if (strCurSel == "搴勫洯鍟嗗煄")
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
//		else if (strCurSel == "搴勫洯鍔ㄦ��")
//		{
//			NDTransData bao(_MSG_ENTER_HAMLET);
//			bao << (unsigned char)2 << int(0);
//			// SEND_DATA(bao);
//		} 
//		else if (strCurSel == "杩滅▼杩涘叆")
//		{
//			std::stringstream ss; ss << "鐐瑰嚮纭浣跨敤涓�涓煄闀囦紶閫佸嵎杞�";
//			m_dlgFarm = new NDUIDialog;
//			m_dlgFarm->Initialization();
//			m_dlgFarm->SetDelegate(this);
//			m_dlgFarm->Show("", ss.str().c_str(), NDCommonCString("Cancel"), "纭", NULL);
//		} 
//		//else if (strCurSel == "绔嬪嵆鍒涘缓") 鏆傛椂鍏堜笉鍋�
////		{
////			NDMapMgr& mgr = NDMapMgr;
////			if (mar.m_iMapID == 21003) // 21003涓洪暱瀹夊煄鍦板浘id 
////			{
////				showDialog("鎻愮ず", "璇峰幓闀垮畨鍩庢壘XXXX锛坅a,bb锛夛紝浠栬兘鎸囧浣犲垱寤鸿嚜宸辩殑搴勫洯銆�");
////			}
////			else 
////			{
////				// 鑷姩瀵昏矾鍒皀pc
////			}
////		}
//
//	} else if (this->m_tlRelieve == table) {
//		if (cellIndex == 0) { // 鍥炲煄
//			NDUISynLayer::Show(SYN_RELIEVE);
//			NDTransData data(_MSG_REBORN);
//			NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//			table->SetVisible(false);
//			SetUIShow(false);
//		} else if (cellIndex == 1) { // 浣跨敤閬撳叿
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
	 * 涓存椂鎬ф敞閲� 閮旦
	 * all
	 */

//	if(HideTLShare()) return;
//	
//	if (button == m_btnQuickInterationShrink) {
//		m_bQuickInterationShow = !m_bQuickInterationShow;
//		
//		if (this->m_bQuickInterationShow) {
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
//		if (this->m_bHeadShow) {
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
//		InitTLShareContent("涓栫晫鍦板浘", "NPC瀵艰埅", NULL);
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
////			dlg->Show("鎻愮ず", "娌℃湁浜掑姩鐩爣", "", NULL);
////			return;
////		}
//		//if ( player->m_iFocusManuRoleID != -1 )
////		{
//			NDManualRole *otherplayer = NDMapMgrObj.GetManualRole(player->m_iFocusManuRoleID);
//			if ( !otherplayer && !player->IsFocusNpcValid())
//			{ //涓庡叾瀹冪帺瀹朵氦浜�
//				
//				NDUIDialog *dlg = new NDUIDialog;
//				dlg->Initialization();
//				dlg->Show("鎻愮ず", "娌℃湁浜や簰鐩爣", "", NULL);
//				return;
//			}
//			
//			if (m_tlInteractive && otherplayer && !player->IsFocusNpcValid())
//			{
//				std::vector<std::string> vec_str;
//				vec_str.push_back("鐜╁淇℃伅");
//				vec_str.push_back("鏌ョ湅瑁呭");
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
//				vec_str.push_back("浜ゆ槗");
//				vec_str.push_back("娣诲姞濂藉弸");
//				vec_str.push_back("绉佽亰");
//				vec_str.push_back("PK");
//				vec_str.push_back("姣旀");
//				vec_str.push_back("鏌ョ湅瀹犵墿");
//			
//				if (player->level < 20 && otherplayer->level >= 20) 
//				{
//					vec_str.push_back("鎷滃笀");
//				} 
//				else if (player->level >= 20 && otherplayer->level < 20)
//				{
//					vec_str.push_back("鏀跺緬");
//				}
//				if(otherplayer->IsInState(USERSTATE_BOOTH))
//				{
//					vec_str.push_back("鏌ョ湅鎽嗘憡");
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
////					lbText->SetFrameRect(CGRectMake(0, 8, 120, 13)); 
////					lbText->SetFontColor(ccc4(16, 56, 66,255)); 
////					section->AddCell(lbText);
//					
//					NDUIButton *button = new NDUIButton;
//					button->Initialization();
//					button->SetFrameRect(CGRectMake(0, 0, 120, 30));
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
//				m_tlInteractive->SetFrameRect(CGRectMake((480-200)/2, (320-vec_str.size()*30-vec_str.size()-1)/2, 200, vec_str.size()*30+vec_str.size()+1));
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
//		this->onClickTeam();
//	}
//	else if (button == m_btnSocial)
//	{
//		InitTLShareContent("鍐涘洟", "鐜╁", "甯堝緬", "濂藉弸", NULL);
//	}
//	else if (button == m_btnTalk)
//	{
//		ChatRecordManager::DefaultManager()->Show();
//	}
//	else if (button == m_btnTask)
//	{
//		GameUITaskList *tasklist = new GameUITaskList;
//		tasklist->Initialization();
//		this->AddChild(tasklist, UILAYER_Z, UILAYER_TASK_LIST_TAG);
//		SetUIShow(true);
//	}
//	else if (button == m_btnBag)
//	{
//		m_playerPosWithMap = NDPlayer::defaultHero().GetPosition();
//		NDDirector::DefaultDirector()->PushScene(GamePlayerBagScene::Scene());
//	}
//	else if (button == m_btnStore)
//	{
//		//InitTLShareContent("鍟嗗煄", "鍏呭��", NULL);
//	}
//	else if (button == m_btnMenu)
//	{
//		InitTLShareContent("浜虹墿", "瀹犵墿", "搴勫洯", "绯荤粺", "鎺掕", "娲诲姩", "瀹㈡湇", NULL);
//	}
}

void GameScene::onClickTeam()
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
	//			vec_str.push_back("鍏抽棴鍔犲叆");
	//		} 
	//		else 
	//		{
	//			vec_str.push_back("寮�鍚姞鍏�");
	//		}
	//		
	//		vec_str.push_back("閭�璇峰叆闃�");
	//		vec_str.push_back("璇峰嚭闃熶紞");
	//		vec_str.push_back("绂诲紑闃熶紞");
	//		vec_str.push_back("鏄剧ず鎴愬憳");
	//		vec_str.push_back("瑙ｆ暎闃熶紞");
	//		vec_str.push_back("鎻愬崌闃熼暱");
	//	}
	//	else 
	//	{
	//		vec_str.push_back("鏄剧ず鎴愬憳");
	//		vec_str.push_back("绂诲紑闃熶紞");
	//		
	//	}
	//	
	//	InitTLShareContent(vec_str);
	//} 
	//else 
	//{
	//	showDialog("闃熶紞", "鎮ㄨ繕娌℃湁闃熶紞");
	//}
}

void GameScene::ShowRelieve(bool bShow)
{
	if (bShow)
	{
		if (this->m_relieveLayer)
		{
			return;
		}

		this->m_relieveLayer = new NDUILayer;
		m_relieveLayer->Initialization();
		m_relieveLayer->SetFrameRect(CGRectMake(0, 0, 480, 320));
		this->AddChild(m_relieveLayer, UIDIALOG_Z);

		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();

		this->m_tlRelieve = new NDUITableLayer;
		m_tlRelieve->Initialization();
		m_tlRelieve->VisibleSectionTitles(false);
		m_tlRelieve->SetDelegate(this);
		//m_tlRelieve->SetFrameRect(CGRectMake(30, 10, 120, 60));
		m_tlRelieve->SetFrameRect(
				CGRectMake((winsize.width - 120) / 2, (winsize.height - 60) / 2,
						120, 60));
		m_relieveLayer->AddChild(m_tlRelieve);

		NDDataSource *dataSource = new NDDataSource;
		NDSection *section = new NDSection;

		NDUIButton *button = new NDUIButton;
		button->Initialization();
		button->SetFrameRect(CGRectMake(0, 0, 120, 30));
		button->SetTitle(NDCommonCString("ReliveInCity"));
		section->AddCell(button);

		button = new NDUIButton;
		button->Initialization();
		button->SetFrameRect(CGRectMake(0, 0, 120, 30));
		button->SetTitle(NDCommonCString("ReliveUseItem"));
		section->AddCell(button);

		dataSource->AddSection(section);
		m_tlRelieve->SetDataSource(dataSource);
		SetUIShow(true);
	}
	else
	{
		if (this->m_relieveLayer)
		{
			this->RemoveChild(this->m_relieveLayer, true);
			this->m_relieveLayer = NULL;
			this->m_tlRelieve = NULL;
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
 *	涓存椂鎬ф敞閲� 閮旦
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
 *	涓存椂鎬ф敞閲� 閮旦
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
////		this->AddChild(request, UILAYER_Z, UILAYER_REQUEST_LIST_TAG);
////		SetUIShow(true);
//		
//		m_anilayerRequest->SetCurrentAnimation(0);
//		
//		NDDirector::DefaultDirector()->PushScene(RequestListScene::Scene());
//	}
//	else if (anilayer == m_anilayerMail)
//	{
//		InitTLShareContent("鏀朵欢绠�", "鍙戜欢绠�", NULL);
//		m_anilayerMail->SetCurrentAnimation(0);
//	}
//}
void GameScene::OnDialogButtonClick(NDUIDialog* dialog,
		unsigned int buttonIndex)
{
	/***
	 *	涓存椂鎬ф敞閲� 閮旦
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
//	} else if (tagDlg == this->m_dlgTaskAwardItemTag) {
//		Item* selItem = NULL;
//		if (buttonIndex < this->m_vTaskAwardItem.size())
//			selItem = this->m_vTaskAwardItem.at(buttonIndex);
//		NDAsssert(selItem != NULL);
//		
//		if (selItem)
//		{
//			m_curSelTaskAwardItemIndex = buttonIndex;
//			
//			dialog->Close();
//			this->m_dlgTaskAwardItemTag = -1;
//			
//			this->m_dlgTaskAwardItemConfirmTag = 
//				GlobalDialogObj.Show(this, 
//									selItem->getItemName().c_str(),
//									selItem->makeItemDes(false, false).c_str(), NULL, NDCommonCString("return"), NDCommonCString("GetAward"), NULL);
//		}
//	} else if (tagDlg == this->m_dlgTaskAwardItemConfirmTag) {
//		dialog->Close();
//		this->m_dlgTaskAwardItemConfirmTag = -1;
//		if (buttonIndex == 0) {
//			// 閲嶆柊鏄剧ず鐗╁搧閫夋嫨瀵硅瘽妗�
//			this->ReShowTaskAwardItemOpt();
//		} else if (buttonIndex == 1) {
//			// 鍙戦�佺墿鍝侀�夐」,鍚屾椂閲婃斁璧勬簮
//			NDUISynLayer::Show();
//			NDTransData bao(_MSG_TASK_ITEM_OPT);
//			bao << (Byte)this->m_curSelTaskAwardItemIndex;
//			
//			// SEND_DATA(bao);
//			
//			for (VEC_ITEM_IT it = this->m_vTaskAwardItem.begin(); it != m_vTaskAwardItem.end(); it++) {
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
	 * all
	 */
	//if (type == 0)
	//{ //璇锋眰鍒楄〃
	//	if (m_anilayerRequest)
	//	{
	//		m_anilayerRequest->SetCurrentAnimation(bFlash);
	//	}
	//}
	//else if (type == 1)
	//{ //閭
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
#define fastinit(text) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
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
			CGRectMake((480 - 200) / 2,
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
#define fastinit(text, iid) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, 200, 30)); \
button->SetTitle(text); \
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

	tl->SetFrameRect(CGRectMake((480 - 120) / 2, iHeightX, 120, iHeight));
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

void GameScene::InitTLShareContent(const char* text, ...)
{
	if (!m_tlShare)
	{
		return;
	}

	va_list argumentList;
	char *eachObject;
	std::vector < std::string > vectext;
	if (text)
	{
		vectext.push_back(std::string(text));
		va_start(argumentList, text);
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
	std::vector < std::string > strOP;

	for (VEC_ITEM_IT it = this->m_vTaskAwardItem.begin();
			it != this->m_vTaskAwardItem.end(); it++)
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
			// 濡傛灉鏄澶囩被鐨勫皢褰撳墠鐨勮�愪箙鍊兼敼涓烘渶澶у��
			tempItem.iAmount = tempItem.getAmount_limit();
		}
		else
		{
			if (tempItem.iAmount > 1)
			{
				sb << " x" << tempItem.iAmount;
			}
		}

		strOP.push_back(sb.str());
	}

	this->m_dlgTaskAwardItemTag = GlobalDialogObj.Show(this, NULL, NULL, NULL,
			strOP);
}

void GameScene::ShowTaskAwardItemOpt(Task* task)
{
	NDAsssert(task != NULL);

	if (task->award_item1 != 0)
	{
		Item *item = new Item(task->award_item1);
		item->iAmount = task->award_num1;
		this->m_vTaskAwardItem.push_back(item);
	}

	if (task->award_item2 != 0)
	{
		Item *item = new Item(task->award_item2);
		item->iAmount = task->award_num2;
		this->m_vTaskAwardItem.push_back(item);
	}

	if (task->award_item3 != 0)
	{
		Item *item = new Item(task->award_item3);
		item->iAmount = task->award_num3;
		this->m_vTaskAwardItem.push_back(item);
	}

	this->ReShowTaskAwardItemOpt();
}

void GameScene::ShowNPCDialog(bool bShowLeaveBtn/*=true*/)
{
	//m_dlgNPC = new NDUIDialog;
//	m_dlgNPC->Initialization();
//	m_dlgNPC->SetDelegate(this);

	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
	//// 鍐滃満
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
		 * 涓存椂鎬ф敞閲� 閮旦
		 * begin
		 */
// 		GameUIPaiHang *paihang = new GameUIPaiHang;
// 		paihang->Initialization();
// 		scene->AddChild(paihang, UILAYER_Z, UILAYER_PAIHANG_TAG);
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * end
		 */
		//CloseProgressBar;
	}
	else
	{
		//((GameUIPaiHang*)node)->UpdateMainUI(); ///< 涓存椂鎬ф敞閲� 閮旦
	}
	((GameScene*) scene)->SetUIShow(true);
}

void GameScene::ShowShop(int iNPCID /*= 0*/)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * begin
	 */
	// 	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene)))
// 	{
// 		NDDirector::DefaultDirector()->PushScene(GameNpcStoreScene::Scene(iNPCID));
// 		return;
// 	}
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	NDNode *node = scene->GetChild(UILAYER_NPCSHOP_TAG);
	if (!node)
	{
		//GameUINpcStore *npcstore = new GameUINpcStore;
//		npcstore->Initialization();
//		scene->AddChild(npcstore, UILAYER_Z, UILAYER_NPCSHOP_TAG);
		return;
	}
	else
	{
		//((GameUIPaiHang*)node)->UpdateMainUI();
		((GameUINpcStore*) node)->UpdateBag();
		((GameUINpcStore*) node)->UpdateMoney();
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
 * 涓存椂鎬ф敞閲� 閮旦
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
//			if (!this->checkNewPwd(newPwd1)) {
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
		//寮哄埗鏇存柊		
		dlg->SetTag(TAG_UPDATE_FORCE);
	}
	else
	{
		//鏅�氭洿鏂�
		dlg->SetTag(TAG_UPDATE_NOT_FORCE);
	}

	dlg->Show(NDCommonCString("VersionUpdate"), version,
			NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
}

/***
 * 涓存椂鎬ф敞閲� 閮旦
 * begin
 */
// DirectKey* const GameScene::GetDirectKey()
// {
// 	return m_directKey;
// }
/***
 * 涓存椂鎬ф敞閲� 閮旦
 * end
 */

void GameScene::HandleRootMenuAfterSceneLoad()
{
	/***
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
	 * end
	 */

	// test
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
	case 0: // 鏂板缓
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
			//			PosText* pt = new PosText(idPosText, direction, posX, posY, showSec, showClr, num, str, showBackColor); ///< 涓存椂鎬ф敞閲� 閮旦
			//			s_mapPosText[idPosText] = pt; ///< 涓存椂鎬ф敞閲� 閮旦
//				m_userState->AddPosText(pt); ///< 涓存椂鎬ф敞閲� 閮旦
		}
	}
		break;
	case 1: // 鏇存柊鏁板瓧鍜屾枃瀛�
	{
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_num = data.ReadInt();
// 				pt->m_str = data.ReadUnicodeString();;
// 				//m_userState->AddPosText(pt); ///< 涓存椂鎬ф敞閲� 閮旦
// 			}
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * end
		 */
	}
		break;
	case 2: // 鏇存柊鏁板瓧
	{
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_num = data.ReadInt();
// 			//	m_userState->AddPosText(pt); ///< 涓存椂鎬ф敞閲� 閮旦
// 			}
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * end
		 */
	}
		break;
	case 3: // 鏇存柊鏂囧瓧
	{
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * begin
		 */
// 			MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
// 			if (it != s_mapPosText.end()) 
// 			{
// 				PosText* pt = it->second;
// 				pt->m_str = data.ReadUnicodeString();
// 			//	m_userState->AddPosText(pt); ///< 涓存椂鎬ф敞閲� 閮旦
// 			}
		/***
		 * 涓存椂鎬ф敞閲� 閮旦
		 * end
		 */
	}
		break;
	case 4: // 鍒犻櫎
	{
		MAP_POS_TEXT_IT it = s_mapPosText.find(idPosText);
		if (it != s_mapPosText.end())
		{
			//			m_userState->RemovePosText(it->second); ///< 涓存椂鎬ф敞閲� 閮旦
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
	//InitTLShareContent("鍟嗗煄", "鍏呭��", NULL);
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
		//NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene()); ///< 涓存椂鎬ф敞閲� 閮旦
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
	 * 涓存椂鎬ф敞閲� 閮旦
	 * all
	 */
// 	if (m_quickItem)
// 		m_quickItem->SetShrink(true);
}

void GameScene::TeamRefreh(bool newJoin)
{
	/***
	 *  涓存椂鎬ф敞閲� 閮旦
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
	//	this->AddUIChild(m_quickTeam);
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
//	if (!m_quickFunc) return; ///< 涓存椂鎬ф敞閲� 閮旦

//	m_quickFunc->ShowTaskTip(show, tip); ///< 涓存椂鎬ф敞閲� 閮旦
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


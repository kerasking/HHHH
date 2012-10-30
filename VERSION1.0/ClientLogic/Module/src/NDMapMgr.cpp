#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "NDMapLayer.h"
#include "GameScene.h"
#include "NDItemType.h"
#include "Battle.h"
#include "define.h"
#include "NDUISynLayer.h"
#include "SMGameScene.h"
#include "GameDataBase.h"
#include "ItemMgr.h"
#include "ScriptGlobalEvent.h"
#include "NDNetMsg.h"
#include "TutorUILayer.h"
#include "ScriptMgr.h"
#include "TaskListener.h"
#include "BattleMgr.h"
#include "CPet.h"
#include "NDMsgDefine.h"
#include "NDUtility.h"
#include "BeatHeart.h"
#include "NDDataPersist.h"
// #include "Chat.h"
// #include "NewChatScene.h"			///< 这俩包含需要汤哥和张迪的东西 郭浩
#include "SMLoginScene.h"
#include "GlobalDialog.h"
#include "NDMonster.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDMapMgr, NDObject);

bool NDMapMgr::m_bVerifyVersion = true;
bool NDMapMgr::m_bFirstCreate = false;

bool GetIntData(int& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (int) atoi(strNumber.c_str());

	return true;
}

bool GetShortData(short& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (short) atoi(strNumber.c_str());

	return true;
}

bool GetCharData(char& t, string strValue, string strType)
{
	int nPos = strValue.find(strType);

	if (-1 == nPos || strValue.length() < strType.length())
	{
		return false;
	}

	string strNumber = strValue.substr(strType.length() + 1, strValue.length());

	t = (char) atoi(strNumber.c_str());

	return true;
}

NDMapMgr::NDMapMgr():
m_nCurrentMonsterBound(0),
m_nRoadBlockX(0),
m_nRoadBlockY(0),
m_nSaveMapID(0),
m_nMapID(0),
m_nMapDocID(0),
m_nCurrentMonsterRound(0)
{
	NDNetMsgPool& kNetPool = NDNetMsgPoolObj;
	kNetPool.RegMsg(_MSG_NPCINFO_LIST, this);
	kNetPool.RegMsg(_MSG_ROOM, this);

	mapType = MAPTYPE_NORMAL;

	NDConsole::GetSingletonPtr()->RegisterConsoleHandler(this, "sim ");

	m_kTimer.SetTimer(this, 1, 0.1);

	isShowName = true;
	isShowOther = true;
}

NDMapMgr::~NDMapMgr()
{
	m_vNPC.clear();
	m_mapManualRole.clear();
}

bool NDMapMgr::process(MSGID usMsgID, NDEngine::NDTransData* pkData,
		int nLength)
{
	switch (usMsgID)
	{
	case _MSG_REQUEST_ACCESS_TOKEN_RET:
	{
		ProcessTempCredential(*pkData);
	}
		break;
	case _MSG_ROADBLOCK:
	{
		processRoadBlock(*pkData);
	}
		break;
	case _MSG_QUERY_PETCKILL:
	{
		processQueryPetSkill(*pkData);
	}
		break;
	case _MSG_CHARGE_GIFT_INFO:
	{
		//RechargeUI::ProcessGiftInfo(*kData); ///< 依赖汤自勤的 NewRecharge 郭浩
	}
		break;
	case _MSG_KICK_OUT_TIP:
	{
		processKickOutTip(*pkData);
	}
		break;
	case 3003: //_MSG_RESPOND_TREASURE_HUNT_PR0B: 此宏找不到？？？？郭浩
	{
		processRespondTreasureHuntProb(*pkData);
	}
		break;
	case 3005: //_MSG_RESPOND_TREASURE_HUNT_INFO:	此宏找不到？？？？郭浩
	{
		processRespondTreasureHuntInfo(*pkData);
	}
		break;
	case _MSG_SHOW_TREASURE_HUNT_AWARD:
	{
		processShowTreasureHuntAward(*pkData);
	}
		break;
	case _MSG_MARRIAGE:
	{
		processMarriage(*pkData);
	}
		break;
	case 2562:	///< 为什么_MSG_PORTAL找不到
	{
		processPortal(*pkData);
	}
		break;
	case _MSG_DELETEROLE:
	{
		processDeleteRole(*pkData);
	}
		break;
	case _MSG_ACTIVITY:
	{
		processActivity(*pkData);
	}
		break;
	case _MSG_CLIENT_VERSION:
	{
		processVersionMsg(*pkData);
	}
		break;
	case MB_MSG_RECHARGE_RETURN:
	{
		processRechargeReturn(*pkData);
	}
		break;
	case MB_MSG_CHANGE_PASS:
	{
		CloseProgressBar;
		GlobalShowDlg(NDCommonCString("SysTip"), pkData->ReadUnicodeString());
	}
		break;
	case _MSG_SEE:
	{
		processSee(*pkData);
	}
		break;
	case _MSG_SYSTEM_DIALOG:
	{
		m_strNoteTitle = pkData->ReadUnicodeString();
		m_strNoteContent = pkData->ReadUnicodeString();
		GlobalDialogObj.Show(NULL, m_strNoteTitle.c_str(),
				m_strNoteContent.c_str(), NULL, NULL);
	}
		break;
	case _MSG_TALK:
	{
		processTalk(*pkData);
	}
		break;
	case _MSG_GAME_QUIT:
	{
		processGameQuit(pkData, nLength);
	}
		break;
	case MB_MSG_RECHARGE:
	{
		processReCharge(*pkData);
	}
		break;
	case _MSG_PLAYERLEVELUP:
	{
		processPlayerLevelUp(*pkData);
	}
		break;
	case _MSG_COLLECTION:
	{
		processCollection(*pkData);
	}
		break;
	case _MSG_AUCTION:
	{
		///< 依赖张迪 AuctionUILayer 郭浩
		//AuctionUILayer::processAuction(*kData);
	}
		break;
	case _MSG_AUCTIONINFO:
	{
		///< 依赖张迪 AuctionUILayer 郭浩
		//AuctionUILayer::processAuctionInfo(*pkData);
	}
		break;
	case _MSG_PETINFO:
	{
		processPetInfo(pkData, nLength);
	}
		break;
	case _MSG_COMPETITION:
	{
		processCompetition(*pkData);
	}
		break;
	case _MSG_KICK_BACK:
	{
		processKickBack(pkData, nLength);
	}
		break;
	case MB_MSG_DISAPPEAR:
	{
		processDisappear(pkData, nLength);
	}
		break;
	case _MSG_CHGPOINT:
	{
		processChgPoint(pkData, nLength);
	}
		break;
	case _MSG_REPUTE:
	{
		NDPlayer& kRole = NDPlayer::defaultHero();
		kRole.m_nSWCountry = pkData->ReadInt();
		kRole.m_nSWCamp = pkData->ReadInt();
		kRole.m_nHonour = pkData->ReadInt();
		kRole.m_nExpendHonour = pkData->ReadInt();
		kRole.m_strRank = pkData->ReadUnicodeString();

		updateTaskRepData(kRole.m_nSWCamp, false);
		updateTaskHrData(kRole.m_nHonour, false);
	}
		break;
	case _MSG_NPC_STATUS:
	{
		processNpcStatus(pkData, nLength);
	}
		break;
	case _MSG_MONSTER_INFO_LIST:
	{
		processMonsterInfo(pkData, nLength);
	}
		break;
	case _MSG_COMMON_LIST:
	{
		processMsgCommonList(*pkData);
	}
		break;
	case _MSG_COMMON_LIST_RECORD:
	{
		processMsgCommonListRecord(*pkData);
	}
		break;
	case _MSG_CHG_PET_POINT:
	{
		int nBtAnswer = pkData->ReadByte();
	}
		break;
	case _MSG_PLAYER:
	{
		processPlayer(pkData, nLength);
	}
		break;
	case _MSG_LOGIN_SUC:
	{
		ProcessLoginSuc(*pkData);
	}
		break;
	case _MSG_PLAYER_EXT:
	{
		processPlayerExt(pkData, nLength);
	}
		break;
	case _MSG_ITEM_TYPE_INFO:
	{
		processItemTypeInfo(*pkData);
	}
		break;
	case _MSG_NPC_TALK:
	{
		processNpcTalk(*pkData);
	}
		break;
	case _MSG_WALK_TO:
	{
		processWalkTo(*pkData);
	}
		break;
	case _MSG_NPCINFO_LIST:
	{
		processNPCInfoList(pkData, nLength);
	}
		break;
	case _MSG_ROOM:
	{
		processChangeRoom(pkData, nLength);
	}
		break;
	case _MSG_WALK:
	{
		processWalk(pkData, nLength);
	}
		break;
	case _MSG_TASKINFO:
	case _MSG_DOING_TASK_LIST:
	case _MSG_QUERY_TASK_LIST:
	case _MSG_TASK_ITEM_OPT:
	case _MSG_QUERY_TASK_LIST_EX:
	{
		processTask(usMsgID, pkData);
	}
		break;
	case _MSG_NPCINFO:
	{
		processNPCInfo(*pkData);
	}
		break;
	case _MSG_REHEARSE:
	{
		processRehearse(*pkData);
	}
		break;
	case _MSG_GOODFRIEND:
	{
		processGoodFriend(*pkData);
	}
		break;
	case _MSG_TUTOR:
	{
		///< 依赖张迪的TutorUILayer 郭浩
		//TutorUILayer::processMsgTutor(*kData);
	}
		break;
	case _MSG_REG_TUTOR_INFO:
	{
		///< 依赖张迪的MasterUILayer 郭浩
		//MasterUILayer::refreshScroll(*kData);
	}
		break;
	case _MSG_TUTOR_INFO:
	{
		///< 依赖张迪的TutorUILayer 郭浩
		//TutorUILayer::processTutorList(*kData);
	}
		break;
	case _MSG_USER_POS:
	{
		///< 依赖张迪的TutorUILayer 郭浩
		//TutorUILayer::processUserPos(*kData);
	}
		break;
	case _MSG_CHG_MAP_FAIL:
	{
		NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();

		///< 依赖汤自勤的GameSceneLoading 郭浩
// 		if (pkScene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading))) 
// 		{
// 			NDDirector::DefaultDirector()->PopScene();
// 		}
	}
		break;
	case _MSG_USERINFO_SEE:
	{
		processUserInfoSee(*pkData);
	}
		break;
	case _MSG_POS_TEXT:
	{
		GameScene* pkGameScene = GameScene::GetCurGameScene();

		if (pkGameScene)
		{
			pkGameScene->processMsgPosText(*pkData);
		}
	}
		break;
	case _MSG_FORMULA:
	{
		processFormula(*pkData);
	}
		break;
	case _MSG_BOOTH:
	{
		//VendorUILayer::processMsgBooth(*kData);	///< 依赖张迪的VendorUILayer 郭浩
	}
		break;
	case _MSG_BOOTH_GOODS:
	{
		//VendorBuyUILayer::Show(*kData);		///< 依赖张迪的VendorBuyUILayer 郭浩
	}
		break;
	case _MSG_QUERY_REG_SYN_LIST:
	{
		//SyndicateRegListUILayer::refreshScroll(*kData); ///< 这个不知道是谁的 郭浩
	}
		break;
	case _MSG_SYNDICATE:
	{
		processSyndicate(*pkData);
	}
		break;
	case _MSG_SYN_INFO:
	{
		int nRank = pkData->ReadByte(); // 个人在帮派中的职位
		string strSynName = pkData->ReadUnicodeString(); // 帮派名字
		NDPlayer& kRole = NDPlayer::defaultHero();
		kRole.setSynRank(nRank);
		kRole.m_strSynName = (strSynName);
		break;
	}
		break;
	case _MSG_SYN_ANNOUNCE:
	{
		/***
		 * 依赖张迪的SynInfoUILayer
		 * 郭浩
		 */
		//SynInfoUILayer* synInfo = SynInfoUILayer::GetCurInstance();
		//if (synInfo) {
		//	synInfo->processSynBraodcast(*kData);
		//}
	}
		break;
	case _MSG_APPLY_LIST:
	{
		/***
		 * 依赖张迪的 SynApproveUILayer
		 * 郭浩
		 */
		//SynApproveUILayer* approve = SynApproveUILayer::GetCurInstance();
		//if (approve) {
		//	approve->processApproveList(*kData);
		//}
	}
		break;
	case _MSG_DIGOUT:
	{
		processDigout(*pkData);
	}
		break;
	case _MSG_MBR_LIST:
	{
		/***
		 * 依赖张迪的 SynMbrListUILayer
		 * 郭浩
		 */
		//SynMbrListUILayer* mbrList = SynMbrListUILayer::GetCurInstance();
		//if (mbrList) {
		//	mbrList->processMbrList(*kData);
		//}
	}
		break;
	case _MSG_TIP:
	{
		/***
		 * 依赖汤自勤的GameSceneLoading 郭浩
		 */
// 			NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();
// 			if (pkScene->IsKindOfClass(RUNTIME_CLASS(GameSceneLoading))) 
// 			{
// 				GameSceneLoading* pkGameSceneLoading = (GameSceneLoading*)pkScene;
// 				pkGameSceneLoading->UpdateTitle(kData->ReadUnicodeString());
// 			}
	}
		break;
	case _MSG_NAME:
	{
		//showDialog(NDCommonCString("tip"), NDCommonCString("RenameSucc")); ///< 依赖showDialog 郭浩
	}
		break;
	case _MSG_NPC_POSITION:
	{
		processNpcPosition(*pkData);
	}
		break;
	case _MSG_NPC:
	{
		processNPC(*pkData);
	}
		break;
	default:
		break;
	}

	return true;
}

void NDMapMgr::processPlayer(NDTransData* pkData, int nLength)
{
	if (!pkData || nLength == 0)
		return;

	int nUserID = 0;
	(*pkData) >> nUserID; // 用户id 4个字节
	int nLife = 0;
	(*pkData) >> nLife; // 生命值4个字节
	int nMaxLife = 0;
	(*pkData) >> nMaxLife; // 生命值4个字节
	int nMana = 0;
	(*pkData) >> nMana; // 魔法值
	int nMoney = 0;
	(*pkData) >> nMoney; // 银币 4个字节
	int dwLookFace = 0;
	(*pkData) >> dwLookFace; // 创建人物的时候有6种外观可供选择外观 脸型 4个字节
	unsigned short usRecordX = 0;
	(*pkData) >> usRecordX; // 记录点信息X
	unsigned short usRecordY = 0;
	(*pkData) >> usRecordY; // 记录点信息Y
	unsigned char btDir = 0;
	(*pkData) >> btDir; // 玩家面部朝向，左右两个方向 1个字节
	unsigned char btProfession = 0;
	(*pkData) >> btProfession; // 玩家的职业 1个字节
	unsigned char btLevel = 0;
	(*pkData) >> btLevel; // 用户等级
	int dwState = 0;
	(*pkData) >> dwState; // 状态位
	// System.out.println(" 状态 " + dwState);
	int synRank = 0;
	(*pkData) >> synRank; // 帮派等级
	int dwArmorType = 0;
	(*pkData) >> dwArmorType; // 盔甲id 4个字节
	int dwPkPoint = 0;
	(*pkData) >> dwPkPoint; // pk值
	//int weaponTypeID=0; (*pkData) >> weaponTypeID;
	//int armorTypeID=0; (*pkData) >> armorTypeID;
	unsigned char btCamp = 0;
	(*pkData) >> btCamp; // 阵营
	std::string name = "";
	std::string strRank = "";
	std::string synName = ""; // 帮派名字

	unsigned char uiNum = 0;
	(*pkData) >> uiNum; // TQMB 个数 1字节
	for (int i = 0; i < uiNum; i++)
	{
		std::string strString = pkData->ReadUnicodeString();
		if (i == 0)
		{
			name = strString;
		}
		else if (i == 1 && strString.length() > 2)
		{
			strRank = strString;
		}
		else if (i == 2)
		{
			synName = strString;
		}
	}

	if (synName.empty())
	{
		synRank = SYNRANK_NONE;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	if (nUserID == kPlayer.m_nID)
	{
		if (dwState & USERSTATE_SHAPESHIFT)
		{
			kPlayer.updateTransform(pkData->ReadInt());
		}
		else
		{
			kPlayer.updateTransform(0);
		}

		// 光效
		int effectAmount = pkData->ReadByte();
		std::vector<int> vEffect;
		for (int i = 0; i < effectAmount; i++)
		{
			vEffect.push_back(pkData->ReadInt());
		}

		kPlayer.SetPosition(
				ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
						usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
		kPlayer.SetState(dwState);
		kPlayer.SetServerPositon(usRecordX, usRecordY);
		kPlayer.SetAction(false);
		return;
	}

	NDManualRole *pkRole = NULL;
	bool bAdd = true;
	pkRole = NDMapMgrObj.GetManualRole(nUserID);
	if (!pkRole)
	{
		pkRole = new NDManualRole;
		pkRole->m_nID = nUserID;
		pkRole->Initialization(dwLookFace, true);
		bAdd = false;
	}

	if (dwState & USERSTATE_SHAPESHIFT)
	{
		pkRole->updateTransform(pkData->ReadInt());
	}
	else
	{
		pkRole->updateTransform(0);
	}

	// 光效
	int nEffectAmount = pkData->ReadByte();
	std::vector<int> vEffect;
	for (int i = 0; i < nEffectAmount; i++)
	{
		vEffect.push_back(pkData->ReadInt());
	}
	//++Guosen 2012.7.15
	int tRank = pkData->ReadByte();
	int nRideStatus = pkData->ReadInt();
	int nMountType = pkData->ReadInt();
	int nQuality = pkData->ReadByte();
	//unsigned int nMountlookface = ScriptDBObj.GetN( "mount_model_config", nMountType, DB_MOUNT_MODEL_LOOKFACE );
	pkRole->ChangeModelWithMount(nRideStatus, nMountType);
	//++

	pkRole->m_nQuality = nQuality;

	pkRole->m_nLife = nLife;
	pkRole->m_nMaxLife = nMaxLife;
	pkRole->m_nMana = nMana;
	pkRole->m_nMoney = nMoney;
	pkRole->m_nLookface = dwLookFace;
	pkRole->m_nProfesstion = btProfession;
	pkRole->m_nLevel = btLevel;
	pkRole->SetState(dwState);
	pkRole->setSynRank(synRank);
	pkRole->m_nPKPoint = dwPkPoint;
	pkRole->SetCamp((CAMP_TYPE) btCamp);
	pkRole->m_strName = name;
	pkRole->m_strRank = strRank;
	pkRole->m_strSynName = synName;
	pkRole->m_nTeamID = dwArmorType;
	pkRole->SetPosition(
			ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
	pkRole->SetSpriteDir(btDir);
	pkRole->SetServerPositon(usRecordX, usRecordY);

	if (!bAdd)
	{
		NDMapMgrObj.AddManualRole(nUserID, pkRole);
	}

	pkRole->SetAction(false);
	pkRole->SetServerEffect(vEffect);

	if (dwState & USERSTATE_PRACTISE)
	{
		// todo设置玩家打坐状态
		pkRole->SetCurrentAnimation(7, pkRole->IsReverse());
	}
	else
	{
		// todo取消打坐状态
		if (pkRole->AssuredRidePet())
		{
// 			pkRole->SetCurrentAnimation(pkRole->GetPetStandAction(),
// 					pkRole->IsReverse());
		}
		else
		{
			pkRole->SetCurrentAnimation(0, pkRole->IsReverse());
		}
	}
}

void NDMapMgr::AddManualRole(int nID, NDManualRole* pkRole)
{
	if (0 == pkRole || -1 == nID)
	{
		return;
	}

	m_mapManualRole.insert(make_pair(nID, pkRole));

	NDLayer* pkLayer = (NDLayer*) getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG));

	if (0 == pkLayer)
	{
		return;
	}

	pkLayer->AddChild((NDNode*) pkRole);

	if (pkRole->m_nID == NDPlayer::defaultHero().m_iFocusManuRoleID)
	{
		GameScene* pkGameScene = GameScene::GetCurGameScene();

		if (0 != pkGameScene)
		{
			pkGameScene->SetTargetHead(pkRole);
		}

		pkRole->SetFocus(true);
	}
}

NDManualRole* NDMapMgr::GetManualRole(int nID)
{
	NDPlayer& kRole = NDPlayer::defaultHero();

	if (nID == kRole.m_nID)
	{
		return &kRole;
	}

	if (m_mapManualRole.empty())
	{
		return 0;
	}

	map_manualrole::iterator it = m_mapManualRole.find(nID);

	if (m_mapManualRole.end() != it)
	{
		return it->second;
	}

	return 0;
}

NDManualRole* NDMapMgr::GetManualRole(const char* pszName)
{
	NDManualRole* pkResult = 0;

	for (map_manualrole::iterator it = m_mapManualRole.begin();
			m_mapManualRole.end() != it; it++)
	{
		NDManualRole* pkRole = it->second;

		if (0 == strcmp(pkRole->m_strName.c_str(), pszName))
		{
			pkResult = it->second;
			break;
		}
	}

	return pkResult;
}

void NDMapMgr::Update(unsigned long ulDiff)
{
	NDPlayer& player = NDPlayer::defaultHero();
	player.Update(ulDiff);

	// 所有其它玩家
	do
	{
		map_manualrole::iterator it = m_mapManualRole.begin();
		while (it != m_mapManualRole.end())
		{
			NDManualRole *role = it->second;
			if (role->m_bClear)
			{
				//	updateTeamListDelPlayer(*role);			///< No team 郭浩
				SAFE_DELETE_NODE(role->m_pkRidePet);
				SAFE_DELETE_NODE(role);
				m_mapManualRole.erase(it++);
			}
			else
			{
				it++;
			}
		};

		it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole* role = it->second;

			if (role == &player)
				continue;

			if (role)
			{
				NDNode* parent = role->GetParent();
				if (parent && !parent->IsKindOfClass(RUNTIME_CLASS(Battle)))
				{
					role->Update(ulDiff);
				}
			}
		}
	} while (0);

	// 所有地图上的怪
	do
	{
		if (NDPlayer::defaultHero().IsInState(USERSTATE_FIGHTING)
				|| NDPlayer::defaultHero().IsGathering()
				|| NDUISynLayer::IsShown())
		{
			break;
		}

		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
		{
			GameScene *gamescene = (GameScene*) scene;
			if (gamescene->IsUIShow())
			{
				break;
			}
		}

		VEC_MONSTER::iterator it = m_vMonster.begin();
		while (it != m_vMonster.end())
		{
			NDMonster* tmp = *it;
			if (!tmp->m_bClear)
			{
				it++;
				continue;
			}

			if (GetBattleMonster() == tmp)
			{
				tmp = NULL;
			}

			SAFE_DELETE_NODE(tmp);
			it = m_vMonster.erase(it);
		}

		it = m_vMonster.begin();
		for (; it != m_vMonster.end(); it++)
		{
			NDMonster* monster = *it;
			if (monster && it == m_vMonster.begin())
			{
				monster->Update(ulDiff);
			}
		}
	} while (0);
}

NDMapLayer* NDMapMgr::getMapLayerOfScene(NDScene* pkScene)
{
	if (0 == pkScene)
	{
		return 0;
	}

	NDNode* pkNode = pkScene->GetChild(MAPLAYER_TAG);

	if (0 == pkNode || 0 == pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		return 0;
	}

	return (NDMapLayer*) pkNode;
}

void NDMapMgr::DelManualRole(int nID)
{
	if (-1 == nID)
	{
		return;
	}

	map_manualrole::iterator it = m_mapManualRole.find(nID);

	if (m_mapManualRole.end() != it)
	{
		NDManualRole* pkRole = it->second;

		if (pkRole)
		{
			SAFE_DELETE_NODE(pkRole);
		}

		m_mapManualRole.erase(it);
	}
}

void NDMapMgr::processPlayerExt(NDTransData* pkData, int nLength)
{
	if (0 == pkData || 0 == nLength)
	{
		return;
	}

	int nUserID = 0;
	(*pkData) >> nUserID;
	int dwStatus = 0;
	(*pkData) >> dwStatus;

	NDManualRole* pkRole = 0;
	pkRole = NDMapMgrObj.GetManualRole(nUserID);

	if (0 == pkRole)
	{
		return;
	}

	pkRole->SetState(dwStatus);
	pkRole->unpakcAllEquip();

	unsigned char btAmount = 0;
	(*pkData) >> btAmount;

	for (int i = 0; i < btAmount; i++)
	{
		int nEquipTypeID = 0;
		(*pkData) >> nEquipTypeID;
		NDItemType* pkItem = ItemMgrObj.QueryItemType(nEquipTypeID);

		if (0 == pkItem)
		{
			continue;
		}

		pkRole->m_vEquipsID.push_back(nEquipTypeID);
		int nID = pkItem->m_data.m_lookface;
		int nQuality = nEquipTypeID % 10;

		if (0 == nID)
		{
			continue;
		}

		int nAnimationID = 0;

		if (10000 < nID)
		{
			nAnimationID = (nID % 100000) / 10;
		}

		if (nAnimationID >= 1900 && nAnimationID < 2000
				|| nID >= 19000 && nID < 20000)
		{
			ShowPetInfo kShowPetInfo(nEquipTypeID, nID, nQuality);
			pkRole->SetShowPet(kShowPetInfo);
		}
		else
		{
			pkRole->SetEquipment(nID, nQuality);
		}
	}

	if (pkRole->IsInState(USERSTATE_SHAPESHIFT))
	{
		pkRole->updateTransform(pkData->ReadInt());
	}
	else
	{
		pkRole->updateTransform(0);
	}

	if (pkRole->GetParent() != 0
			&& !pkRole->GetParent()->IsKindOfClass(RUNTIME_CLASS(Battle)))
	{
		pkRole->SetAction(pkRole->isMoving(), true);
	}
}

void NDMapMgr::processWalk(NDTransData* pkData, int nLength)
{
	if (0 == pkData || 0 == nLength)
	{
		return;
	}

	int nID = 0;
	(*pkData) >> nID;
	unsigned char ucDir = 0;
	(*pkData) >> ucDir;

	if (NDPlayer::defaultHero().m_nID != nID)
	{
		NDManualRole* pkRole = 0;
		pkRole = NDMapMgrObj.GetManualRole(nID);

		if (pkRole->isTeamLeader())
		{
			pkRole->teamSetServerDir(ucDir);
		}
	}
}

void NDMapMgr::processWalkTo(NDTransData& kData)
{
	int nPlayerID = kData.ReadInt();
	int nAmount = kData.ReadByte();
	NDPlayer& kPlayer = NDPlayer::defaultHero();

	for (int i = 0; i < nAmount; i++)
	{
		int nPosX = kData.ReadShort();
		int nPosY = kData.ReadShort();
		int nNPCID = kData.ReadInt();

		if (kPlayer.m_nID == nPlayerID)
		{
			CloseProgressBar;

			if (0 != nNPCID)
			{
				NDNpc* pkNPC = 0;
			}
		}
	}
}

NDNpc* NDMapMgr::GetNPC(int nID)
{
	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkTemp = *it;

		if (nID != pkTemp->m_nID)
		{
			continue;
		}

		return pkTemp;
	}

	return 0;
}

void NDMapMgr::processChangeRoom(NDTransData* pkData, int nLength)
{
	if (0 == pkData || 0 == nLength)
	{
		return;
	}

	m_nCurrentMonsterBound = 0;

	if (m_bVerifyVersion)
	{
		m_bVerifyVersion = false;
		//NDBeforeGameMgrObj.VerifyVersion();
	}

	m_nRoadBlockX = -1;
	m_nRoadBlockY = -1;

	BattleMgrObj.quitBattle(false);

	pkData->ReadShort();
	pkData->ReadInt();

	int nMapID = pkData->ReadInt();
	int nMapDocID = pkData->ReadInt();

	int dwPortalX = pkData->ReadShort();
	int dwPortalY = pkData->ReadShort();

	pkData->ReadShort();
	pkData->ReadShort();
	pkData->ReadShort();
	pkData->ReadShort();

	m_nMapType = pkData->ReadInt();

	m_strMapName = pkData->ReadUnicodeString();

	NDPlayer& kPlayer = NDPlayer::defaultHero(1);
// 
// 	if (kPlayer.IsInState(USERSTATE_DEAD))
// 	{
// 		NDUISynLayer::Close (SYN_RELIEVE);
// 	}
// 
// 	NDUISynLayer::Close (SYN_CREATE_ROLE);

	NDMapMgrObj.ClearManualRole();

	m_nMapID = nMapID;

	if (1 == m_nMapID || 2 == m_nMapID)
	{
		m_nSaveMapID = m_nMapID;
	}

	kPlayer.m_nCurMapID = nMapDocID;

	ShowPetInfo kPetInfoRerserve;
	// 	kPlayer.GetShowPetInfo(kPetInfoRerserve);
	kPlayer.m_strName = string("efawfawe");
	//	kPlayer.ResetShowPet();

//   	if (kPlayer.GetParent() != 0)
//   	{
//   		NDRidePet* pkRidePet = NDPlayer::defaultHero().GetRidePet();
//   
//   		if (0 != pkRidePet && 0 != pkRidePet->GetParent())
//   		{
//   			pkRidePet->RemoveFromParent(false);
//   		}
//   
//   		kPlayer.RemoveFromParent(false);
//   	}

	while (NDDirector::DefaultDirector()->PopScene())
	{
	}

	NDMapMgrObj.ClearNPC();
	NDMapMgrObj.ClearMonster();
	NDMapMgrObj.ClearGP();
	NDMapMgrObj.loadSceneByMapDocID(nMapDocID);

	NDMapLayer* pkLayer = NDMapMgrObj.getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());

	int nTheID = GetMotherMapID();
	// 	int nTitleID = ScriptDBObj.GetN("map", nTheID, DB_MAP_TITLE);
	//pkLayer->ShowTitle(nTitleID, 0);

	if (0 == pkLayer)
	{
		return;
	}

	kPlayer.SetPosition(
			ccp(dwPortalX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					dwPortalY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
	kPlayer.SetServerPositon(dwPortalX, dwPortalY);
	kPlayer.SetShowPet(kPetInfoRerserve);
	kPlayer.stopMoving();

//   	NDRidePet* pkRidePet = kPlayer.GetRidePet();
//   
//   	if (0 != pkRidePet)
//   	{
//   		pkRidePet->stopMoving();
//   		pkRidePet->SetPositionEx(
//   				ccp(dwPortalX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
//   						dwPortalY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
//   	}

	pkLayer->SetScreenCenter(
			ccp(dwPortalX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					dwPortalY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));

	kPlayer.SetAction(false);
	kPlayer.SetLoadMapComplete();

	//	ItemMgrObj.SortBag();

	ScriptGlobalEvent::OnEvent (GE_GENERATE_GAMESCENE);

	if (nTheID / 100000000 > 0)
	{
		//	ScriptMgrObj.excuteLuaFunc("SetUIVisible","",0);
	}
	else
	{
		pkLayer->AddChild(&kPlayer, 111, 1000);
		//	ScriptMgrObj.executeLuaFunc("SetUIVisible","",1);
	}

//	CloseProgressBar;

//	NDMapMgrObj.LoadSceneMonster();
}

void NDMapMgr::processNPCInfoList(NDTransData* pkData, int nLength)
{
	const int LIST_ACTION_END = 1;
	//NDLog(@"处理NPC消息-----------");
	unsigned char btAction = 0;
	(*pkData) >> btAction;
	unsigned char btCount = 0;
	(*pkData) >> btCount;

	for (int i = 0; i < btCount; i++)
	{
		int nID = 0;
		(*pkData) >> nID; // 4个字节 pkNpc id
		unsigned char uitype = 0;
		(*pkData) >> uitype; // 该字段用于过滤寻路的pkNpc列表
		int usLook = 0;
		(*pkData) >> usLook; // 4个字节
		unsigned char btSort = 0;
		(*pkData) >> btSort;
		unsigned short usCellX = 0;
		(*pkData) >> usCellX; // 2个字节
		unsigned short usCellY = 0;
		(*pkData) >> usCellY; // 2个字节
		unsigned char btState = 0;
		(*pkData) >> btState; // 1个字节表状态
		unsigned char btCamp = 0;
		(*pkData) >> btCamp;
		CCString* pstrTemp = CCString::stringWithUTF8String(
				pkData->ReadUnicodeString().c_str());
		std::string strName = pstrTemp->toStdString();
		SAFE_DELETE(pstrTemp);

		pstrTemp = CCString::stringWithUTF8String(
				pkData->ReadUnicodeString().c_str());
		std::string dataStr = pstrTemp->toStdString();
		SAFE_DELETE(pstrTemp);
		pstrTemp = CCString::stringWithUTF8String(
				pkData->ReadUnicodeString().c_str());
		std::string talkStr = pstrTemp->toStdString();
		SAFE_DELETE(pstrTemp);

		NDNpc *pkNPC = new NDNpc;
		pkNPC->m_nID = nID;
		pkNPC->m_nCol = usCellX;
		pkNPC->m_nRow = usCellY;
		pkNPC->m_nLook = usLook;
		pkNPC->SetCamp(CAMP_TYPE(btCamp));

		if (uitype == 6)
		{
			pkNPC->m_strName = "";
		}
		else
		{
			pkNPC->m_strName = strName;
		}

		pkNPC->SetPosition(
				ccp(usCellX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
						usCellY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
		pkNPC->m_strData = dataStr;
		pkNPC->m_strTalk = talkStr;
		pkNPC->SetType(uitype);
		pkNPC->Initialization(usLook);

		if (btSort != 0)
		{
			pkNPC->SetActionOnRing(false);
			pkNPC->SetDirectOnTalk(false);
		}

		pkNPC->initUnpassPoint();
		NDMapMgrObj.m_vNPC.push_back(pkNPC);
	}

	if (btAction == LIST_ACTION_END)
	{ // 收发结束
		NDMapMgrObj.AddAllNPCToMap();
	}

	NDMapMgrObj.AddAllNPCToMap();
}

void NDMapMgr::AddAllNPCToMap()
{
	NDMapLayer* pkLayer = (NDMapLayer*) getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());

	if (0 == pkLayer)
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkNPC = *it;

		if (pkLayer->ContainChild(pkNPC))
		{
			continue;
		}

		pkLayer->AddChild((NDNode*) pkNPC, 2, 100);

// 		if (0 != pkNPC->GetRidePet())
// 		{
// 			pkNPC->GetRidePet()->stopMoving();
// 			pkNPC->GetRidePet()->SetPositionEx(pkNPC->GetPosition());
// 			pkNPC->GetRidePet()->SetCurrentAnimation(RIDEPET_STAND,
// 					pkNPC->m_bFaceRight);
// 		}

		pkNPC->HandleNpcMask(true);
	}

	NDPlayer::defaultHero().UpdateFocus();
}

void NDMapMgr::OnCustomViewRadioButtonSelected(NDUICustomView* customView,
		unsigned int radioButtonIndex, int ortherButtonTag)
{
	throw std::exception("The method or operation is not implemented.");
}

void NDMapMgr::ClearManualRole()
{
	if (m_mapManualRole.empty())
	{
		return;
	}

	for (map_manualrole::iterator it = m_mapManualRole.begin();
			m_mapManualRole.end() != it; it++)
	{
		NDManualRole* pkRole = it->second;
		SAFE_DELETE_NODE(pkRole);
	}
}

void NDMapMgr::ClearNPC()
{
	if (m_vNPC.empty())
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); m_vNPC.end() != it; it++)
	{
		NDNpc* pkRole = *it;
		SAFE_DELETE_NODE(pkRole);
	}
}

void NDMapMgr::ClearMonster()
{
	if (m_vMonster.empty())
	{
		return;
	}

	for (VEC_MONSTER::iterator it = m_vMonster.begin(); m_vMonster.end() != it;
			it++)
	{
		NDMonster* pkRole = *it;
		SAFE_DELETE_NODE(pkRole);
	}
}

void NDMapMgr::ClearGP()
{

}

bool NDMapMgr::loadSceneByMapDocID(int nMapID)
{
	m_nMapDocID = nMapID;

	NDDirector::DefaultDirector()->PurgeCachedData();
	NDDirector::DefaultDirector()->ReplaceScene(NDScene::Scene());

	CSMGameScene* pkScene = CSMGameScene::Scene();
	NDDirector::DefaultDirector()->ReplaceScene(pkScene);
	pkScene->Initialization(nMapID);
	pkScene->SetTag(SMGAMESCENE_TAG);

	NDMapLayer* pkMapLayer = getMapLayerOfScene(pkScene);

	if (0 != pkMapLayer)
	{
		m_kMapSize = pkMapLayer->GetContentSize();
	}
	else
	{
		m_kMapSize = CCSizeZero;
	}

	AddSwitch();

	return true;
}

void NDMapMgr::AddSwitch()
{
	NDScene* pkScene = NDDirector::DefaultDirector()->GetScene(
			RUNTIME_CLASS(CSMGameScene));
	NDMapLayer* pkLayer = 0;
	NDMapData* pkMapData = 0;

	if (0 != pkScene || 0 == (pkLayer = getMapLayerOfScene(pkScene))
			|| 0 == (pkMapData = pkLayer->GetMapData()))
	{
		return;
	}

	ScriptDB& kScriptDB = ScriptDBObj;
	ID_VEC kIDList;
	kScriptDB.GetIdList("portal", kIDList);

	for (ID_VEC::iterator it = kIDList.begin(); kIDList.end() != it; it++)
	{
		int nMapID = GetMapID();

		if (kScriptDB.GetN("portal", *it, DB_PORTAL_MAPID) == nMapID)
		{
			int nIndex = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTAL_INDEX);
			int nX = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTALX);
			int nY = kScriptDB.GetN("portal", *it, DB_PORTAL_PORTALY);

			string strDesc = "城門";

			pkMapData->addMapSwitch(nX, nY, nIndex, nMapID, strDesc.c_str(),
					"");
		}
	}

	pkLayer->MapSwitchRefresh();
}

int NDMapMgr::GetMapID()
{
	return m_nMapID;
}

int NDMapMgr::GetMotherMapID()
{
	int nTheID = m_nMapID;

	if (m_nMapID / 10000000 > 0)
	{
		nTheID = m_nMapID / 100000 * 100000;
	}

	return nTheID;
}

void NDMapMgr::LoadSceneMonster()
{
	int nTheID = GetMotherMapID();
	ID_VEC kIDList;
	ScriptDBObj.GetIdList("mapzone", kIDList);

	for (unsigned int i = 0; i < kIDList.size(); i++)
	{
		int m_nID = ScriptDBObj.GetN("mapzone", kIDList.at(i),
				DB_MAPZONE_MAPID);
		if (m_nID == nTheID)
		{

			NDMapLayer* pkLayer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!pkLayer)
			{
				return;
			}
			NDMonster* pkMonster = new NDMonster();
			int elite_flag = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ELITE_FLAG);

			pkMonster->m_nID = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ID);
			int col = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_POS_X);
			int row = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_POS_Y);
			int idType = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_MONSTER_TYPE);
			int atk_area = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_ATK_AREA);
			int rule_id = ScriptDBObj.GetN("mapzone", kIDList.at(i),
					DB_MAPZONE_GENERATE_RULE_ID);
			pkMonster->Initialization(idType);
			NDMapMgrObj.m_vMonster.push_back(pkMonster);
		}
	}
	NDMapMgrObj.AddAllMonsterToMap();
}

void NDMapMgr::AddAllMonsterToMap()
{
	NDMapLayer* pkLayer = getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());

	if (0 == pkLayer)
	{
		return;
	}

	for (VEC_MONSTER::iterator it = m_vMonster.begin(); m_vMonster.end() != it;
			it++)
	{
		NDMonster* pkMonster = *it;

		if (0 != pkMonster && pkMonster->m_nID > 0
				&& pkMonster->getState() == MONSTER_STATE_DEAD)
		{
			continue;
		}

		if (pkMonster->GetParent() == 0)
		{
			pkLayer->AddChild((NDNode*) pkMonster, 0, 0);
		}

		///< 这里添加gather... 郭浩
	}
}

bool NDMapMgr::processConsole(const char* pszInput)
{
	if (true)
	{
		return false;
	}

	string strInput = pszInput;

	printf("開始分析要模擬的包……\n");

	NDTransData kTransData;

	vector < string > kStringVector;
	int nPos = 0;
	int nStartPos = 0;
	int nOmegaPos = 0;
	short usMsgID = 0;
	unsigned char szBuffer[1024] =
	{ 0 };
	unsigned int pPos = 0;

	nOmegaPos = strInput.find(';');
	unsigned int nLength = strInput.length();

	if (strInput.length() - 3 != nOmegaPos)
	{
		printf("语法错误\n");
		return false;
	}

	while (true)
	{
		nPos = strInput.find(',');
		int nKeywordPos = 0;

		string strNum;

		if (-1 == nPos)
		{
			strNum = strInput.substr(0, strInput.length() - 3);
			break;
		}
		else
		{
			strNum = strInput.substr(nStartPos, nPos);
		}

		if (0 == strNum.length())
		{
			printf("出错\n");
			break;
		}

		int uiData = 0;
		short usData = 0;
		char ucData = 0;
		strInput = strInput.substr(nPos + 1, strInput.length());

		if (GetShortData(usMsgID, strNum, string("id")))
		{
			if (0 == usMsgID)
			{
				return false;
			}
		}
		else if (GetIntData(uiData, strNum, string("int")))
		{
			kTransData.WriteInt(uiData);
		}
		else if (GetShortData(usData, strNum, string("short")))
		{
			kTransData.WriteShort(usData);
		}
		else if (GetCharData(ucData, strNum, string("char")))
		{
			kTransData.WriteByte(ucData);
		}
	}

	process(usMsgID, &kTransData, 0);

	printf("分析完畢!\n");

	return true;
}

void NDMapMgr::OnTimer(OBJID tag)
{
	const char* pszCommand = NDConsole::GetSingletonPtr()->GetSpecialCommand(
			"sim ");

	if (0 != pszCommand && *pszCommand)
	{
		string strInput = pszCommand;

		printf("開始分析要模擬的包……\n");

		NDTransData kTransData;

		vector < string > kStringVector;
		int nPos = 0;
		int nStartPos = 0;
		int nOmegaPos = 0;
		short usMsgID = 0;
		unsigned char szBuffer[1024] =
		{ 0 };
		unsigned int pPos = 0;

		nOmegaPos = strInput.find(';');
		unsigned int nLength = strInput.length();

		if (strInput.length() - 3 != nOmegaPos)
		{
			printf("语法错误\n");
			return;
		}

		while (true)
		{
			nPos = strInput.find(',');
			int nKeywordPos = 0;

			string strNum;

			if (-1 == nPos)
			{
				strNum = strInput.substr(0, strInput.length() - 3);
				break;
			}
			else
			{
				strNum = strInput.substr(nStartPos, nPos);
			}

			if (0 == strNum.length())
			{
				printf("出错\n");
				break;
			}

			int uiData = 0;
			short usData = 0;
			char ucData = 0;
			strInput = strInput.substr(nPos + 1, strInput.length());

			if (GetShortData(usMsgID, strNum, string("id")))
			{
				if (0 == usMsgID)
				{
					return;
				}
			}
			else if (GetIntData(uiData, strNum, string("int")))
			{
				kTransData.WriteInt(uiData);
			}
			else if (GetShortData(usData, strNum, string("short")))
			{
				kTransData.WriteShort(usData);
			}
			else if (GetCharData(ucData, strNum, string("char")))
			{
				kTransData.WriteByte(ucData);
			}
		}

		process(usMsgID, &kTransData, 0);

		printf("分析完畢!\n");
	}
}

NDMonster* NDMapMgr::GetBattleMonster()
{
	return m_apWaitBattleMonster;
}

void NDMapMgr::SetBattleMonster(NDMonster* pkMonster)
{
	if (0 == pkMonster)
	{
		m_apWaitBattleMonster.Clear();
	}
	else
	{
		m_apWaitBattleMonster = pkMonster->QueryLink();
	}
}

void NDMapMgr::ProcessLoginSuc(NDTransData& kData)
{
	ScriptMgrObj.excuteLuaFunc("ProcessLoginSuc", "MsgLoginSuc", 0);
}

void NDMapMgr::processNpcTalk(NDTransData& kData)
{
	int nAction = kData.ReadByte();
	int nID = kData.ReadInt();
	int nTime = kData.ReadInt();
	std::string strMessage = kData.ReadUnicodeString2();
	switch (nAction)
	{
	case 0:
	{
		NDManualRole* pkPlayer = GetManualRole(nID);
		if (pkPlayer != NULL)
		{
			pkPlayer->addTalkMsg(strMessage, nTime);
		}
		break;
	}
	case 1:
	{
		CloseProgressBar;
		NDNpc *pkNPC = GetNPC(nID);
		if (pkNPC != NULL)
		{
			pkNPC->addTalkMsg(strMessage, nTime);
		}
		break;
	}
	case 2:
	{
		NDMonster *pkMonster = GetMonster(nID);
		if (pkMonster != NULL)
		{
			pkMonster->addTalkMsg(strMessage, nTime);
		}
	}
		break;
	}
}

NDMonster* NDMapMgr::GetMonster(int nID)
{
	for (VEC_MONSTER::iterator it = m_vMonster.begin(); it != m_vMonster.end();
			it++)
	{
		NDMonster *pkTempMonster = *it;

		if (pkTempMonster->m_nID == nID)
		{
			return pkTempMonster;
		}
	}

	return NULL;
}

void NDMapMgr::processMsgCommonList(NDTransData& kData)
{
	///< 依赖汤自勤的NewPaiHangScene 郭浩

// 	int iID = kData.ReadInt();
// 	int field_count = kData.ReadInt();
// 	int button_count = kData.ReadInt();
// 	string title = kData.ReadUnicodeString();
// 
// 	NewPaiHangScene::curPaiHangType = iID;
// 
// 	std::vector<int>& fildTypes = NewPaiHangScene::s_PaiHangTitle[iID].fildTypes;
// 	std::vector<std::string>& fildNames = NewPaiHangScene::s_PaiHangTitle[iID].fildNames;
// 
// 	fildTypes.clear();
// 	fildNames.clear();
// 
// 	for (int i = 0; i < field_count; i++) {
// 		fildTypes.push_back(kData.ReadByte());
// 		fildNames.push_back(kData.ReadUnicodeString());
// 	}
// 
// 	for (int i = 0; i < button_count; i++) {
// 		kData.ReadUnicodeString();
// 	}
}

void NDMapMgr::processMsgCommonListRecord(NDTransData& kData)
{
	///< 依赖汤自勤的NewPaiHangScene 郭浩

// 	int packageFlag = kData.ReadByte();
// 	int curCount = kData.ReadByte();
// 	kData.ReadShort();
// 
// 
// 	std::vector<int>& fildTypes = NewPaiHangScene::s_PaiHangTitle[NewPaiHangScene::curPaiHangType].fildTypes;
// 	std::vector<std::string>& values = NewPaiHangScene::values[NewPaiHangScene::curPaiHangType];
// 	values.clear();
// 	for (int i = 0; i < curCount; i++) {
// 		kData.ReadInt(); // button id
// 		for (int j = 0; j < int(fildTypes.size()); j++) {
// 			if (fildTypes[j] == 0) {
// 				std::stringstream ss; ss << (kData.ReadInt());
// 				values.push_back(ss.str());
// 			} else if (fildTypes[j] == 1) {
// 				values.push_back(kData.ReadUnicodeString());				
// 			}
// 		}
// 	}
// 
// 	if ((packageFlag & 2) > 0) {
// 		NewPaiHangScene::refresh();
// 		CloseProgressBar;
// 	}
}

void NDMapMgr::processMonsterInfo(NDTransData* pkData, int nLength)
{
	///< 此函数所有注释都依赖汤自勤的GatherPoint 郭浩

	unsigned char btAction = 0;
	(*pkData) >> btAction;
	unsigned char count = 0;
	(*pkData) >> count;

	switch (btAction)
	{
	case MONSTER_INFO_ACT_INFO:
		for (int i = 0; i < count; i++)
		{

			int idType = 0;
			(*pkData) >> idType;
			int lookFace = 0;
			(*pkData) >> lookFace;
			unsigned char lev = 0;
			(*pkData) >> lev;
			unsigned char btAiType = 0;
			(*pkData) >> btAiType;
			unsigned char btCamp = 0;
			(*pkData) >> btCamp;
			unsigned char btAtkArea = 0;
			(*pkData) >> btAtkArea;
			std::string name = pkData->ReadUnicodeString(); //这个字符串可能需要做修改

			monster_type_info info;
			info.idType = idType;
			info.lookFace = lookFace;
			info.lev = lev;
			info.btAiType = btAiType;
			info.btCamp = btCamp;
			info.btAtkArea = btAtkArea;
			info.name = name;
			//if (lookFace == 19070 || lookFace == 206) continue;

			NDMapMgrObj.m_mapMonsterInfo.insert(
					monster_info_pair(idType, info));
		}
		break;
	case MONSTER_INFO_ACT_POS:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			int idType = 0;
			(*pkData) >> idType;
			unsigned short col = 0;
			(*pkData) >> col;
			unsigned short row = 0;
			(*pkData) >> row;
			unsigned char btState = 0;
			(*pkData) >> btState;

			NDLayer *layer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!layer)
			{
				return;
			}

			if (idType / 1000000 == 6)
			{ // 采集
			  //GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						//map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}

				//if (gp == NULL) 
				//{
				//gp = new GatherPoint(idMonster, idType, col*MAP_UNITSIZE,
				//					 row *MAP_UNITSIZE, idMonster > 0, "");
				//m_mapGP.insert(map_gather_point_pair(idMonster, gp));
				//}

				//gp->setState(btState);

				continue;
			}

			monster_type_info info;
			if (!NDMapMgrObj.GetMonsterInfo(info, idType))
				continue;

			NDMonster* monster = new NDMonster;
			monster->m_nID = idMonster;
			monster->SetPosition(ccp(col * MAP_UNITSIZE, row * MAP_UNITSIZE));
			monster->Initialization(idType);
			monster->SetType(MONSTER_ELITE);
			if (idMonster > 0)
			{
				monster->setState(btState);
			}

			NDMapMgrObj.m_vMonster.push_back(monster);

		}
		NDMapMgrObj.AddAllMonsterToMap();
		break;
	case MONSTER_INFO_ACT_STATE:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			unsigned char btState = 0;
			(*pkData) >> btState;
			if (idMonster > 0)
			{
// 					GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}
// 					
// 					if (gp == NULL) 
// 					{
// 						for_vec(m_vMonster, vec_monster_it)
// 						{
// 							if ((*it)->m_nID == idMonster)
// 							{
// 								(*it)->setState(btState);
// 							}
// 						}
// 					}
// 					else
// 					{
// 						gp->setState(btState);
// 					}
			}
		}
		break;
	case MONSTER_INFO_ACT_BOSS_POS:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			int idType = 0;
			(*pkData) >> idType;
			unsigned short col = 0;
			(*pkData) >> col;
			unsigned short row = 0;
			(*pkData) >> row;
			unsigned char btState = 0;
			(*pkData) >> btState;

			NDLayer *layer = NDMapMgrObj.getMapLayerOfScene(
					NDDirector::DefaultDirector()->GetRunningScene());
			if (!layer)
			{
				return;
			}

			if (idType / 1000000 == 6)
			{ // 采集
// 					GatherPoint *gp = NULL;
// 					if (idMonster > 0)
// 					{
// 						map_gather_point_it it = m_mapGP.find(idMonster);
// 						if (it != m_mapGP.end())
// 						{
// 							gp = it->second;
// 						}
// 					}
// 					
// 					if (gp == NULL) 
// 					{
// 						gp = new GatherPoint(idMonster, idType, col*MAP_UNITSIZE,
// 											 row *MAP_UNITSIZE, idMonster > 0, "");
// 						m_mapGP.insert(map_gather_point_pair(idMonster, gp));
// 					}
// 					
// 					gp->setState(btState);

				continue;
			}

			monster_type_info info;
			NDMonster *monster = new NDMonster;
			monster->m_nID = idMonster;
			monster->SetPosition(ccp(col * MAP_UNITSIZE, row * MAP_UNITSIZE));
			monster->Initialization(idType);
			monster->SetType(MONSTER_BOSS);
			if (idMonster > 0)
			{
				monster->setState(btState);
			}

			NDMapMgrObj.m_vMonster.push_back(monster);

		}
		NDMapMgrObj.AddAllMonsterToMap();
		break;
	case MONSTER_INFO_ACT_BOSS_STATE:
		for (int i = 0; i < count; i++)
		{
			int idMonster = 0;
			(*pkData) >> idMonster;
			unsigned char btState = 0;
			(*pkData) >> btState;
			if (idMonster > 0)
			{
				for_vec(m_vMonster, vec_monster_it)
				{
					if ((*it)->m_nID == idMonster
							&& (*it)->GetType() == MONSTER_BOSS)
					{
						(*it)->setState(btState);
					}
				}
			}
		}
		break;
	}
}

bool NDMapMgr::GetMonsterInfo(monster_type_info& kInfo, int nType)
{
	monster_info_it it = m_mapMonsterInfo.find(nType);

	if (it == m_mapMonsterInfo.end())
	{
		return false;
	}

	kInfo = it->second;
	return true;
}

void NDMapMgr::BattleEnd(int iResult)
{
	NDMonster* monster = GetBattleMonster();
	if (monster && monster->getState() != MONSTER_STATE_DEAD)
	{
		monster->endBattle();
		monster->setMonsterStateFromBattle(iResult);
		SetBattleMonster(0);
	}

	if (BATTLE_COMPLETE_WIN == iResult)
	{
		m_nCurrentMonsterRound++;
	}
	else
	{
		if (BattleMgrObj.GetBattle()->GetBattleType() == BATTLE_TYPE_MONSTER)
		{
			if (monster)
			{
				monster->restorePosition();

				NDPlayer& player = NDPlayer::defaultHero();

				player.SetPosition(
						ccp(monster->m_nSelfMoveRectX - 64,
								monster->GetPosition().y));
				player.SetServerPositon(
						(monster->m_nSelfMoveRectX - 64) / MAP_UNITSIZE,
						(monster->GetPosition().y) / MAP_UNITSIZE);

				Battle* battle = BattleMgrObj.GetBattle();
				if (battle)
				{
					battle->setSceneCetner(monster->m_nSelfMoveRectX - 64,
							monster->GetPosition().y);
					player.stopMoving();
				}
				else
				{
					NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(
							NDDirector::DefaultDirector()->GetRunningScene());

					if (layer)
					{
						layer->SetScreenCenter(
								ccp(monster->m_nSelfMoveRectX - 64,
										monster->GetPosition().y));
					}
					player.stopMoving();
				}
			}
		}
	}

	NDPlayer::defaultHero().BattleEnd(iResult);
}

void NDMapMgr::processNpcStatus(NDTransData* pkData, int nLength)
{
	unsigned char ucCount = 0;
	(*pkData) >> ucCount;

	for (int i = 0; i < ucCount; i++)
	{
		int nNPCID = 0;
		nNPCID = pkData->ReadInt();
		unsigned char ucState = 0;
		(*pkData) >> ucState;
		NDNpc *pkNPC = NULL;
		for_vec(m_vNPC, VEC_NPC::iterator)
		{
			if ((*it) && (*it)->m_nID == nNPCID)
			{
				pkNPC = *it;
			}
		}
		if (pkNPC)
		{
			pkNPC->SetNpcState(NPC_STATE(ucState));
		}
	}
}

void NDMapMgr::processDisappear(NDTransData* pkData, int nLength)
{
	if (!pkData || nLength == 0)
		return;

	int nUserID = 0;
	(*pkData) >> nUserID;

	NDManualRole *pkRole = GetManualRole(nUserID);
	if (pkRole)
	{
		pkRole->m_bClear = true;

		BattleMgr& kBattleMgr = BattleMgrObj;

		if (kBattleMgr.GetBattle()
				&& kBattleMgr.GetBattle()->OnRoleDisapper(pkRole->m_nID))
		{
			pkRole->RemoveFromParent(false);
		}

		NDPlayer::defaultHero().UpdateFocusPlayer();
	}
}

void NDMapMgr::processKickBack(NDTransData* pkData, int nLength)
{
	if (!pkData || nLength == 0)
		return;

	unsigned short usRecordX = 0;
	(*pkData) >> usRecordX;
	unsigned short usRecordY = 0;
	(*pkData) >> usRecordY;

	NDPlayer& player = NDPlayer::defaultHero();

	player.SetPosition(
			ccp(usRecordX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					usRecordY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
	player.SetServerPositon(usRecordX, usRecordY);
	if (player.isTeamLeader())
	{
		player.teamSetServerPosition(usRecordX, usRecordY);
	}

	Battle* battle = BattleMgrObj.GetBattle();
	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetRunningScene());
	player.stopMoving();
	if (battle)
	{
		//NDLog(@"x,y=%d,%d",usRecordX,us);
		battle->setSceneCetner(usRecordX * 32 + DISPLAY_POS_X_OFFSET,
				usRecordY * 32 + DISPLAY_POS_X_OFFSET);
	}
	else
	{

		if (!layer)
		{
			return;
		}
		layer->SetScreenCenter(
				ccp(usRecordX * 32 + DISPLAY_POS_X_OFFSET,
						usRecordY * 32 + DISPLAY_POS_Y_OFFSET));
	}
}

void NDMapMgr::processChgPoint(NDTransData* pkData, int nLength)
{
	unsigned char ucAnswer = 0;
	(*pkData) >> ucAnswer;

	if (ucAnswer == 1)
	{
		// 出错了,还原，修改用户属性
		NDPlayer::defaultHero().m_nPhyPoint -=
				NDPlayer::defaultHero().m_iTmpPhyPoint;
		NDPlayer::defaultHero().m_nDexPoint -=
				NDPlayer::defaultHero().m_iTmpDexPoint;
		NDPlayer::defaultHero().m_nMagPoint -=
				NDPlayer::defaultHero().m_iTmpMagPoint;
		NDPlayer::defaultHero().m_nDefPoint -=
				NDPlayer::defaultHero().m_iTmpDefPoint;
		NDPlayer::defaultHero().m_nRestPoint =
				NDPlayer::defaultHero().m_iTmpRestPoint;
	}

	// 清除加点属性缓存
	NDPlayer::defaultHero().m_iTmpPhyPoint = 0;
	NDPlayer::defaultHero().m_iTmpDexPoint = 0;
	NDPlayer::defaultHero().m_iTmpMagPoint = 0;
	NDPlayer::defaultHero().m_iTmpDefPoint = 0;
	NDPlayer::defaultHero().m_iTmpRestPoint = 0;

	/***
	 * 以下依赖汤自勤的 GameUIAttrib  郭浩
	 */
	// 如果人物属性界面处于打开状态,则更新该界面
// 	GameUIAttrib *pkAttr = GameUIAttrib::GetInstance();
// 	if (pkAttr) 
// 	{
// 		pkAttr->UpdateGameUIAttrib();
// 	}
}

void NDMapMgr::processPetInfo(NDTransData* pkData, int nLength)
{
	NDPlayer& player = NDPlayer::defaultHero();

	NDManualRole* pkRole = NULL;

	bool bUseNewScene = false;

	int action = 0;
	(*pkData) >> action;

	int idPet = 0;
	(*pkData) >> idPet;

	if (action == 2)
	{
		NDPlayer & player = NDPlayer::defaultHero();
		ShowPetInfo showPetInfo;
		player.GetShowPetInfo(showPetInfo);
		if (OBJID(idPet) == showPetInfo.idPet)
		{
			player.ResetShowPet();
		}

		PetMgrObj.DelPet(idPet);
		//CUIPet* pUIPet = PlayerInfoScene::QueryPetScene();///< 此处注释依赖汤自勤的 PlayerInfoScene  郭浩
		//if (pUIPet) {
		///< 此处注释依赖汤自勤的 CUIPet  郭浩
		//pUIPet->UpdateUI(idPet);
		//}
		return;
	}

	int ownerid = 0;
	(*pkData) >> ownerid;

	if (ownerid == player.m_nID)
	{
		pkRole = (NDManualRole*) &player;
	}
	else
	{
		pkRole = GetManualRole(ownerid);
	}

	if (action != 1)
	{
		return;
	}

	PetInfo* kPetInfo = PetMgrObj.GetPetWithCreate(ownerid, idPet);

	NDAsssert(kPetInfo != NULL);

	PetInfo::PetData* pkPet = &kPetInfo->data;

	pkPet->int_PET_ID = idPet;

	bool bSwithPlayerInfoScene = false;

	int attrNum = 0;
	(*pkData) >> attrNum;
	for (int i = 0; i < attrNum; i++)
	{
		int type = 0;
		(*pkData) >> type;
		int value = 0;

		if (type != 100)
		{
			value = pkData->ReadInt();
		}

		switch (type)
		{
		case 1:		// PET_ATTR_LEVEL
			pkPet->int_PET_ATTR_LEVEL = value;
			break;
		case 2:		// PET_ATTR_EXP
			pkPet->int_PET_ATTR_EXP = value;
			break;
		case 3:		// PET_ATTR_LIFE
			pkPet->int_PET_ATTR_LIFE = value;
			break;
		case 4:		// PET_ATTR_MAX_LIFE
			pkPet->int_PET_ATTR_MAX_LIFE = value;
			break;
		case 5:		// PET_ATTR_MANA
			pkPet->int_PET_ATTR_MANA = value;
			break;
		case 6:		// PET_ATTR_MAX_MANA6
			pkPet->int_PET_ATTR_MAX_MANA = value;
			break;
		case 7:		// PET_ATTR_STR7
			pkPet->int_PET_ATTR_STR = value;
			break;
		case 8:		// PET_ATTR_STA8
			pkPet->int_PET_ATTR_STA = value;
			break;
		case 9:		// PET_ATTR_AGI9
			pkPet->int_PET_ATTR_AGI = value;
			break;
		case 10:		// PET_ATTR_INI10
			pkPet->int_PET_ATTR_INI = value;
			break;
		case 11:		// PET_ATTR_LEVEL_INIT11
			pkPet->int_PET_ATTR_LEVEL_INIT = value;
			break;
		case 12:		// PET_ATTR_STR_INIT12
			pkPet->int_PET_ATTR_STR_INIT = value;
			break;
		case 13:		// PET_ATTR_STA_INIT13
			pkPet->int_PET_ATTR_STA_INIT = value;
			break;
		case 14:		// PET_ATTR_AGI_INIT14
			pkPet->int_PET_ATTR_AGI_INIT = value;
			break;
		case 15:		// PET_ATTR_INI_INIT15
			pkPet->int_PET_ATTR_INI_INIT = value;
			break;
		case 16:		// PET_ATTR_LOYAL16
			pkPet->int_PET_ATTR_LOYAL = value;
			break;
		case 17:		// PET_ATTR_AGE17
			pkPet->int_PET_ATTR_AGE = value;
			break;
		case 18:		// PET_ATTR_FREE_SP18
			pkPet->int_PET_ATTR_FREE_SP = value;
			break;
		case 19:		// PET_ATTR_STR_RATE19
			pkPet->int_PET_PHY_ATK_RATE = value;
			break;
		case 20:		// PET_ATTR_STA_RATE20
			pkPet->int_PET_PHY_DEF_RATE = value;
			break;
		case 21:		// PET_ATTR_AGI_RATE21
			pkPet->int_PET_MAG_ATK_RATE = value;
			break;
		case 22:		// PET_ATTR_INI_RATE22
			pkPet->int_PET_MAG_DEF_RATE = value;
			break;
		case 23:		// PET_ATTR_HP_RATE23
			pkPet->int_PET_ATTR_HP_RATE = value;
			break;
		case 24:		// PET_ATTR_MP_RATE24
			pkPet->int_PET_ATTR_MP_RATE = value;
			break;
		case 25:		// PET_ATTR_LEVEUP_EXP25
			pkPet->int_PET_ATTR_LEVEUP_EXP = value;
			break;
		case 26:		// PET_ATTR_PHY_ATK26
			pkPet->int_PET_ATTR_PHY_ATK = value;
			break;
		case 27:		// PET_ATTR_PHY_DEF27
			pkPet->int_PET_ATTR_PHY_DEF = value;
			break;
		case 28:		// PET_ATTR_MAG_ATK28
			pkPet->int_PET_ATTR_MAG_ATK = value;
			break;
		case 29:		// PET_ATTR_MAG_DEF29
			pkPet->int_PET_ATTR_MAG_DEF = value;
			break;
		case 30:		// PET_ATTR_HARD_HIT30
			pkPet->int_PET_ATTR_HARD_HIT = value;
			break;
		case 31:		// PET_ATTR_DODGE31
			pkPet->int_PET_ATTR_DODGE = value;
			break;
		case 32:		// PET_ATTR_ATK_SPEED32
			pkPet->int_PET_ATTR_ATK_SPEED = value;
			break;
		case 33:		// PET_ATTR_TYPE33 ;类型
			pkPet->int_PET_ATTR_TYPE = value;
			break;
		case 34:		// 外观
			pkPet->int_PET_ATTR_LOOKFACE = value;
			break;
		case 35:		// PET_ATTR_SKILL_1 32
			pkPet->int_PET_MAX_SKILL_NUM = value;
			//PetSkillSceneUpdate();
			//PetSkillIconLayer::OnUnLockSkill(); ///< 未知 待查
			bUseNewScene = true;
			break;
		case 36:			// PET_ATTR_SKILL_2 33
			pkPet->int_ATTR_FREE_POINT = value;
			break;
		case 37:			// 速度资质
			pkPet->int_PET_SPEED_RATE = value;
			break;
		case 38:			// 物攻资质上限
			pkPet->int_PET_PHY_ATK_RATE_MAX = value;
			break;
		case 39:			// 物防资质上限
			pkPet->int_PET_PHY_DEF_RATE_MAX = value;
			break;
		case 40:			// 法攻资质上限
			pkPet->int_PET_MAG_ATK_RATE_MAX = value;
			break;
		case 41:			// 法防资质上限
			pkPet->int_PET_MAG_DEF_RATE_MAX = value;
			break;
		case 42:			// 生命加成资质上限
			pkPet->int_PET_ATTR_HP_RATE_MAX = value;
			break;
		case 43:			// 魔法加成资质上限
			pkPet->int_PET_ATTR_MP_RATE_MAX = value;
			break;
		case 44:			// 速度资质上限
			pkPet->int_PET_SPEED_RATE_MAX = value;
			break;
		case 45:			// 成长率
			pkPet->int_PET_GROW_RATE = value;
			break;
		case 46:			// 成长率上限
			pkPet->int_PET_GROW_RATE_MAX = value;
			break;
		case 47:			// 命中
			pkPet->int_PET_HIT = value;
			break;
		case 48:			//绑定状态
			pkPet->bindStatus = value;
			break;
		case 49: //宠物位置
		{
			if (pkPet->int_PET_ATTR_POSITION != value)
			{
				bSwithPlayerInfoScene = true;
			}

			pkPet->int_PET_ATTR_POSITION = value;
		}
			break;
		case 100: // 名字
		{
			std::string petName = pkData->ReadUnicodeString();
			kPetInfo->str_PET_ATTR_NAME = petName;
			break;
		}
		default:
			break;
		}
	}

	if (pkPet->int_PET_ATTR_POSITION & PET_POSITION_SHOW)
	{
		if (pkRole)
		{
			ShowPetInfo showPetInfo(pkPet->int_PET_ID,
					pkPet->int_PET_ATTR_LOOKFACE, kPetInfo->GetQuality());
			pkRole->SetShowPet(showPetInfo);
		}
	}
	else if (pkRole)
	{
		ShowPetInfo showPetInfo;
		pkRole->GetShowPetInfo(showPetInfo);
		if (OBJID(pkPet->int_PET_ID) == showPetInfo.idPet)
		{
			pkRole->ResetShowPet();
		}
	}

	if (bSwithPlayerInfoScene && pkRole->m_nID == ownerid)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();

		//if (scene && scene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) ///< 此处注释依赖汤自勤的 PlayerInfoScene  郭浩
		{
			///< 此两处注释依赖汤自勤的 PlayerInfoScene  郭浩
			//PlayerInfoScene *playerInfoScene = (PlayerInfoScene*)scene;

			//playerInfoScene->SetTabFocusOnIndex(3, true);
		}
	}

	///< 此处注释依赖汤自勤的 PlayerInfoScene  郭浩
	//CUIPet* pUIPet = PlayerInfoScene::QueryPetScene();
	//if (pUIPet) {
	///< 此处注释依赖汤自勤的 CUIPet  郭浩
	//pUIPet->UpdateUI(pet->int_PET_ID);
	//}
}

void NDMapMgr::processCollection(NDTransData& kData)
{
	CloseProgressBar;
	int itemtype = 0;
	kData >> itemtype;
	Item *item = new Item(itemtype);
	stringstream ss;
	ss << NDCommonCString("GatheredTip") << " " << item->getItemName();
	//showDialog(string("system"), ss.str().c_str()); ///< showDialog暂时找不到 郭浩
	delete item;
}

void NDMapMgr::processPlayerLevelUp(NDTransData& kData)
{
	std::stringstream kMessageStream;
	kMessageStream << NDCommonCString("up") << "！！！";
	int nPlayerID = kData.ReadInt();
	kMessageStream << " " << NDCommonCString("up") << NDCommonCString("object")
			<< "：" << nPlayerID;
	int dwNewExp = kData.ReadInt();
	kMessageStream << " " << NDCommonCString("NewExpVal") << dwNewExp;
	int usNewLevel = kData.ReadShort();
	kMessageStream << " " << NDCommonCString("NewLev") << usNewLevel;
	int usAddPoint = kData.ReadShort();
	kMessageStream << " " << NDCommonCString("NewRestDian") << usAddPoint;

	NDPlayer& kRole = NDPlayer::defaultHero();
	if (nPlayerID == kRole.m_nID)
	{
		kRole.m_nExp = dwNewExp;
		kRole.m_nLevel = usNewLevel;
		kRole.m_nRestPoint = usAddPoint;

		kRole.m_bLevelUp = true;
		kRole.playerLevelUp();

//		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("UpTip")); ///< 依赖张迪Chat 郭浩

		if (usNewLevel == 20)
		{
			//Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("UpTip20"));	///< 依赖张迪Chat 郭浩
		}

	}
	else
	{	// 其他玩家升级
		map_manualrole_it it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole& kPlayer = *(it->second);
			if (kPlayer.m_nID == nPlayerID)
			{
				kPlayer.m_nExp = dwNewExp;
				kPlayer.m_nLevel = usNewLevel;
				kPlayer.m_nRestPoint = usAddPoint;

				kPlayer.m_bLevelUp = true;
				NDPlayer & kPlayer = NDPlayer::defaultHero();
				if (kPlayer.GetParent()
						&& kPlayer.GetParent()->IsKindOfClass(
								RUNTIME_CLASS(GameScene)))
				{
					kPlayer.playerLevelUp();
				}

				break;
			}
		}
	}
}

void NDMapMgr::processGameQuit(NDTransData* pkData, int nLength)
{
	//BeatHeartMgrObj.Stop(); ///< 此处依赖张迪 BeatHeart 郭浩
	CloseProgressBar;

	quitGame();
	ScriptGlobalEvent::OnEvent (GE_LOGIN_GAME);
}

void NDMapMgr::processNPCInfo(NDTransData& kData)
{
	int iid = 0;
	kData >> iid;
	unsigned char _unuse = 0;
	unsigned char uctype = 0;
	kData >> _unuse >> uctype;

	int usLook = 0;
	kData >> usLook;
	kData >> _unuse;
	unsigned short col = 0, row = 0;
	kData >> col >> row;

	unsigned char btState = 0, btCamp = 0;
	kData >> btState >> btCamp;

	std::string strName = kData.ReadUnicodeString();
	std::string strData = kData.ReadUnicodeString();
	std::string strTalk = kData.ReadUnicodeString();

	DelNpc(iid);

	NDNpc* pkNPC = new NDNpc;
	pkNPC->m_nID = iid;
	pkNPC->m_nCol = col;
	pkNPC->m_nRow = row;
	pkNPC->m_nLook = usLook;
	pkNPC->m_strName = strName;
	pkNPC->SetPosition(
			ccp(col * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET,
					row * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
	pkNPC->SetCamp(CAMP_TYPE(btCamp));
	pkNPC->SetNpcState(NPC_STATE(btState));
	pkNPC->m_strData = strData;
	pkNPC->m_strTalk = strTalk;
	pkNPC->SetType(uctype);
	pkNPC->Initialization(usLook);
	pkNPC->initUnpassPoint();
	AddOneNPC(pkNPC);
}

void NDMapMgr::DelNpc(int nID)
{
	if (m_vNPC.empty())
	{
		return;
	}

	VEC_NPC::iterator it = m_vNPC.begin();
	for (; it != m_vNPC.end(); it++)
	{
		NDNpc* pkNPC = *it;

		if (pkNPC->m_nID != nID)
		{
			continue;
		}

		if (pkNPC->m_nID == NDPlayer::defaultHero().GetFocusNpcID())
		{
			NDPlayer::defaultHero().InvalidNPC();
		}

		//pkNPC->HandleNpcMask(false); ///< 此处依赖张迪的NDNpc 郭浩

		SAFE_DELETE_NODE(pkNPC->m_pkRidePet);

		SAFE_DELETE_NODE(pkNPC);

		m_vNPC.erase(it);
		break;
	}
}

void NDMapMgr::AddOneNPC(NDNpc* pkNpc)
{
	NDMapLayer* pkLayer = getMapLayerOfScene(
			NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));

	if (!pkLayer || !pkNpc)
	{
		return;
	}

	for_vec(m_vNPC, VEC_NPC::iterator)
	{
		if (pkNpc->m_nID == (*it)->m_nID)
		{
			return;
		}
	}

	if (pkLayer->ContainChild(pkNpc))
	{
		return;
	}

	m_vNPC.push_back(pkNpc);
	//pkLayer->AddChild((NDNode*)pkNpc); ///< 此处需要修改Layer 郭浩

	// 骑宠
	if (pkNpc->GetRidePet())
	{
		pkNpc->GetRidePet()->stopMoving();

		pkNpc->GetRidePet()->SetPositionEx(pkNpc->GetPosition());
		pkNpc->GetRidePet()->SetCurrentAnimation(RIDEPET_STAND,
				pkNpc->m_bFaceRight);
		pkNpc->SetCurrentAnimation(MANUELROLE_RIDE_PET_STAND,
				pkNpc->m_bFaceRight);
	}

	//pkNpc->HandleNpcMask(true); ///< 此处依赖张迪的NDNpc

	NDPlayer::defaultHero().UpdateFocus();
}

void NDMapMgr::processTalk(NDTransData& kData)
{
	/***
	 * 此函数胆量依赖Chat和GameRequstUI 所以需要张迪和汤自勤配合
	 */
// 	unsigned char _ucUnuse = 0;
// 	kData >> _ucUnuse;
// 	unsigned char pindao = 0;
// 	kData >> pindao;
// 	int _iUnuse = 0;
// 	kData >> _iUnuse;
// 	kData >> _ucUnuse;
// 	unsigned char amount = 0;
// 	kData >> amount;
// 
// 	std::string speaker;
// 	std::string text;
// 	for (int i = 0; i < amount; i++) 
// 	{
// 		std::string c = kData.ReadUnicodeString();
// 		if (i == 0) 
// 		{
// 			text = c;
// 		} else if (i == 1) 
// 		{
// 			speaker = c;
// 		}
// 		// msg.append("内容" + c);
// 
// 	}
// 
// 	CloseProgressBar;
// 
// 	if (speaker.empty()) {// 字段数为0，导致没有Speaker，不处理
// 		return;
// 	}
// 
// 	if (NewChatScene::DefaultManager()->IsFilterBySpeaker(speaker.c_str())) {
// 		return;
// 	}
// 
// 	if (speaker == "SYSTEM" ) {
// 		speaker = NDCommonCString("system");
// 	}
	//ChatType chatType = GetChatTypeFromChannel(pindao); ///< 此处所有ChatType依赖张迪的GetChatTypeFromChannel 郭浩
// 	if (chatType == ChatTypeWorld && !NDDataPersist::IsGameSettingOn(GS_SHOW_WORLD_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeArmy && !NDDataPersist::IsGameSettingOn(GS_SHOW_SYN_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeQueue && !NDDataPersist::IsGameSettingOn(GS_SHOW_TEAM_CHAT)) 
// 	{
// 		return;
// 	}
// 	else if (chatType == ChatTypeSection && !NDDataPersist::IsGameSettingOn(GS_SHOW_AREA_CHAT)) 
// 	{
// 		return;
// 	}	
// 
// 	if (chatType == ChatTypeSecret) 
// 	{
// 		std::string text(speaker);
// 		if (text != (NDPlayer::defaultHero().m_strName)) 
// 		{
// 			RequsetInfo info;
// 			info.set(0, NDCommonCString("YouHaveNewChat"), RequsetInfo::ACTION_NEWCHAT);
// 			NDMapMgrObj.addRequst(info);
// 		}
// 
// 	}
	//Chat::DefaultChat()->AddMessage(chatType, text.c_str(), speaker.c_str()); ///< 此处依赖张迪的 Chat 郭浩
}

/***
 * 依赖汤自勤的 RequsetInfo
 * 郭浩
 */
// void NDMapMgr::addRequst( RequsetInfo& request )
// {
// 	std::stringstream strBuf;
// 	strBuf << NDCommonCString("YouHaveNew") << request.info << "," << NDCommonCString("OpenRequestList");
// 	//Chat::DefaultChat()->AddMessage(ChatTypeSystem, strBuf.str().c_str()); ///< 此处依赖张迪的Chat 郭浩
// 
// 	std::vector<RequsetInfo>::iterator it = m_vecRequest.begin();
// 	for (; it != m_vecRequest.end(); it++)
// 	{
// 		RequsetInfo& info = *it;
// 		if (info.iRoleID == request.iRoleID && info.iAction == request.iAction && (info.iAction != RequsetInfo::ACTION_NEWMAIL || info.iAction != RequsetInfo::ACTION_NEWCHAT))
// 		{
// 			DelRequest(info.iID);
// 			break;
// 		}
// 	}
// 	request.iID = m_idAlloc.GetID();
// 	m_vecRequest.push_back(request);
// 
// 	//NewGameUIRequest::refreshQuestList(); ///< 此处依赖汤自勤的NewGameUIRequest
// 
// 	NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
// 	if (scene) 
// 	{
// 		GameScene* gamescene = (GameScene*)scene;
// 		gamescene->flashAniLayer(0, true);
// 
// 		NDNode *node = gamescene->GetChild(UILAYER_REQUEST_LIST_TAG);
// 		if (node && node->IsKindOfClass(RUNTIME_CLASS(GameUIRequest)))
// 		{
// 			///< 此处依赖汤自勤的GameUIRequest 郭浩
// // 			GameUIRequest *request = (GameUIRequest*)node;
// // 			if (request->IsVisibled())
// // 			{
// // 				request->UpdateMainUI();
// // 			}
// 		}
// 	}
// }
/***
 * 依赖汤自勤的 RequsetInfo
 * 郭浩
 */
bool NDMapMgr::DelRequest(int nID)
{
// 	std::vector<RequsetInfo>::iterator it = m_vecRequest.begin();
// 	for(; it != m_vecRequest.end(); it++)
// 	{
// 		if (nID == (*it).iID)
// 		{
// 			m_idAlloc.ReturnID(nID);
// 			m_vecRequest.erase(it);
// 			return true;
// 		}
// 	}

	return false;
}

void NDMapMgr::processRehearse(NDTransData& kData)
{
	unsigned char btAction = 0;
	kData >> btAction;
	int idTarget = 0;
	kData >> idTarget;

	NDManualRole* role = GetManualRole(idTarget);
	//RequsetInfo info;	///< 依赖汤自勤RequsetInfo 郭浩

	switch (btAction)
	{
	case REHEARSE_APPLY:
	{
		if (role != NULL)
		{
			//info.set(idTarget, role->m_strName, RequsetInfo::ACTION_BIWU);///< 依赖汤自勤RequsetInfo 郭浩
			//addRequst(info);		///< 依赖汤自勤GameUIRequst 郭浩
		}
		break;
	}
	case REHEARSE_REFUSE:
	{
		if (role != NULL)
		{
			std::stringstream ss;
			ss << role->m_strName << NDCommonCString("RejectRefraseTip");
			//Chat::DefaultChat()->AddMessage(ChatTypeSystem, ss.str().c_str()); ///< 依赖张迪Chat 郭浩
		}
		break;
	}
	case REHEARSE_LOGOUT:
	{
		Battle* battle = BattleMgrObj.GetBattle();
		if (battle)
		{
			battle->SetFighterOnline(idTarget, false);
		}
	}
		break;
	case REHEARSE_LOGIN:
	{
		Battle* battle = BattleMgrObj.GetBattle();
		if (battle)
		{
			battle->SetFighterOnline(idTarget, true);
		}
	}
		break;
	}
}

void NDMapMgr::processGoodFriend(NDTransData& kData)
{
	/***
	 * 此函数大量依赖张迪的GoodFriendUILayer
	 * 郭浩
	 */

// 	unsigned char action = 0; kData >> action;
// 	unsigned char friendCount = 0; kData >> friendCount;
// 
// 	RequsetInfo info;
// 	switch (action) {
// 			case _FRIEND_APPLY: {
// 				int iID = 0; kData >> iID;
// 				// TAMBGString
// 				std::string name = kData.ReadUnicodeString();
// 				info.set(iID, name, RequsetInfo::ACTION_FRIEND);
// 				addRequst(info);
// 				break;
// 								}
// 			case _FRIEND_ACCEPT: {
// 									 {
// 										 int idFriend = kData.ReadInt();
// 										 string name = kData.ReadUnicodeString();
// 
// 										 FriendElement& fe = m_mapFriend[idFriend];
// 										 fe.m_id = idFriend;
// 										 fe.m_text1 = name;
// 										 fe.SetState(ES_ONLINE);
// 
// 										 onlineNum++;
// 
// 										 GoodFriendUILayer::refreshScroll();
// 										 NewGoodFriendUILayer::refreshScroll();
// 
// 										 name += " "; name += NDCommonCString("BeFriendTip"); name += "。";
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, name.c_str());
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_ONLINE: {
// 									 {
// 										 int idFriend = kData.ReadInt();
// 
// 										 FriendElement& fe = m_mapFriend[idFriend];
// 										 fe.SetState(ES_ONLINE);
// 										 onlineNum++;
// 
// 										 string content = std::string("") + NDCommonCString("YourFriend") + " " + fe.m_text1 + " " + NDCommonCString("logined");
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										 GoodFriendUILayer::refreshScroll();
// 										 NewGoodFriendUILayer::refreshScroll();
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_OFFLINE: {
// 									  {
// 										  int idFriend = kData.ReadInt();
// 
// 										  FriendElement& fe = m_mapFriend[idFriend];
// 										  fe.SetState(ES_OFFLINE);
// 										  onlineNum--;
// 
// 										  string content = std::string("") + NDCommonCString("YourFriend") + " " + fe.m_text1 + " " + NDCommonCString("OfflineTip");
// 										  Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 			case _FRIEND_BREAK: {
// 									{
// 										int idFriend = kData.ReadInt();
// 										FriendElement& fe = m_mapFriend[idFriend];
// 
// 										string content = fe.m_text1 + " " + NDCommonCString("DeFriendTip");
// 										Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										onlineNum--;
// 
// 										m_mapFriend.erase(idFriend);
// 										GoodFriendUILayer::refreshScroll();
// 										NewGoodFriendUILayer::refreshScroll();
// 										NDUISynLayer::Close();
// 									}
// 									break;
// 								}
// 			case _FRIEND_GETINFO: {
// 									  {
// 										  m_mapFriend.clear();
// 										  onlineNum = 0;
// 
// 										  for (int i = 0; i < friendCount; i++) {
// 											  int idFriend = kData.ReadInt();
// 
// 											  Byte state = kData.ReadByte();
// 
// 											  string name = kData.ReadUnicodeString();
// 
// 											  FriendElement& fe = m_mapFriend[idFriend];
// 
// 											  fe.m_id = idFriend;
// 											  fe.m_text1 = name;
// 											  fe.SetState((ELEMENT_STATE(state)));
// 
// 											  if (state == ES_ONLINE) { // 0表下线状态
// 												  onlineNum++;
// 											  }
// 
// 										  }
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 			case _FRIEND_REFUSE: {
// 									 {
// 										 kData.ReadInt();
// 										 string name = kData.ReadUnicodeString();
// 
// 										 name += " "; name += NDCommonCString("RejectFriendTip");
// 										 Chat::DefaultChat()->AddMessage(ChatTypeSystem, name.c_str());
// 									 }
// 									 break;
// 								 }
// 			case _FRIEND_DELROLE: {
// 									  {
// 										  int idFriend = kData.ReadInt();
// 
// 										  FriendElement& fe = m_mapFriend[idFriend];
// 
// 										  if (fe.m_state == ES_ONLINE) {
// 											  onlineNum--;
// 										  }
// 
// 										  string content = fe.m_text1 + " " + NDCommonCString("DeFriendTip");
// 										  Chat::DefaultChat()->AddMessage(ChatTypeSystem, content.c_str());
// 
// 										  m_mapFriend.erase(idFriend);
// 
// 										  GoodFriendUILayer::refreshScroll();
// 										  NewGoodFriendUILayer::refreshScroll();
// 									  }
// 									  break;
// 								  }
// 	}
}

void NDMapMgr::processUserInfoSee(NDTransData& kData)
{
	std::deque < string > deqStrings;
	int targeId = kData.ReadInt();

	// 社交用到的数据采集
	SocialData social;
	social.iId = targeId;

	std::stringstream sb;
	int bSex = kData.ReadByte(); // 1男2女
	sb << NDCommonCString("sex") << "       " << NDCommonCString("bie") << ": ";
	if (bSex == USER_SEX_MALE)
	{
		social.sex = NDCommonCString("male");
		sb << NDCommonCString("male");
	}
	else
	{
		social.sex = NDCommonCString("female");
		sb << NDCommonCString("female");
	}
	deqStrings.push_back(sb.str());
	sb.str("");
	int bLevel = kData.ReadByte(); // 等级
	sb << NDCommonCString("deng") << "       " << NDCommonCString("Ji") << ": "
			<< bLevel;
	deqStrings.push_back(sb.str());
	sb.str("");

	social.lvl = bLevel;
	kData.ReadByte();
	int iPkPoint = kData.ReadInt(); // PK值
	int iHornor = kData.ReadInt(); // 荣誉值

	sb << "PK" << "      " << NDCommonCString("val") << ": " << iPkPoint;
	deqStrings.push_back(sb.str());
	sb.str("");

	sb << NDCommonCString("HonurVal") << ": " << iHornor;
	deqStrings.push_back(sb.str());
	sb.str("");

	int bShow = kData.ReadByte(); // 指明是否有帮派,配偶,按位取
	std::string name = kData.ReadUnicodeString(); // 玩家名字
	sb << NDCommonCString("PlayerXingMing") << ": " << name; // 插入名字
	deqStrings.push_front(sb.str());
	sb.str("");

	bool isHaveSyn = false; // 是否有帮派
	bool isMarry = false; // 是否结婚
	for (int i = 0; i < 2; i++)
	{
		int a = bShow & 0x1;
		if (a == 1)
		{
			if (i == 0)
			{
				isHaveSyn = true;
			}
			else
			{
				isMarry = true;
			}
		}
		bShow = bShow >> 1;
	}
	if (isHaveSyn)
	{
		std::string synName = kData.ReadUnicodeString(); // 帮派名字
		int bRank = kData.ReadByte(); // 帮派等级
		sb << NDCommonCString("JunTuanName") << ": " << synName;
		deqStrings.push_back(sb.str());
		sb.str("");

		sb << NDCommonCString("JunTuanPost") << ": " << getRankStr(bRank);
		deqStrings.push_back(sb.str());
		sb.str("");

		social.SynName = synName;
		social.rank = getRankStr(bRank);
	}
	else
	{
		sb << NDCommonCString("jun") << "       " << NDCommonCString("tuan")
				<< ": " << NDCommonCString("wu");
		deqStrings.push_back(sb.str());
		sb.str("");
	}
	if (isMarry)
	{
		std::string marryName = kData.ReadUnicodeString(); // 配偶名字
		sb << NDCommonCString("pei") << "       " << NDCommonCString("ou")
				<< ": " << marryName;
		deqStrings.push_back(sb.str());
		sb.str("");
	}
	else
	{
		sb << NDCommonCString("pei") << "       " << NDCommonCString("ou")
				<< ": " << NDCommonCString("wu");
		deqStrings.push_back(sb.str());
		sb.str("");
	}

	CloseProgressBar;
	//OtherPlayerInfoScene::showPlayerInfo(deqStrings); ///< 依赖汤自勤的OtherPlayerInfoScene 郭浩

	/***
	 * 依赖张迪的 SynMbrListUILayer
	 * 郭浩
	 */
// 	SynMbrListUILayer* mbrList = SynMbrListUILayer::GetCurInstance();
// 	if (mbrList) {
// 		mbrList->processSocialData(social);
// 	}
	//GlobalShowDlg("玩家信息", content.str());
}

void NDMapMgr::processFormula(NDTransData& kData)
{
	/***
	 * 找不到 FormulaMaterialData
	 * 郭浩
	 */
// 	int byStudyType = kData.ReadByte();//0是下发，1是学习
// 	int btSkillCount = kData.ReadByte();
// 	for(int i = 0;i<btSkillCount;i++){
// 		int t_idFormula = kData.ReadInt();
// 		int t_lev = kData.ReadByte();
// 		int t_matID_1 = kData.ReadInt();
// 		int t_matCount_1 = kData.ReadByte();
// 		int t_matID_2 = kData.ReadInt();
// 		int t_matCount_2 = kData.ReadByte();
// 		int t_matID_3 = kData.ReadInt();
// 		int t_matCount_3 = kData.ReadByte();
// 		int t_producID = kData.ReadInt();
// 		int t_money = kData.ReadInt();
// 		int t_emoney = kData.ReadInt();
// 		// TODO: 新增图标索引字段
// 		int iconIndex = kData.ReadInt();
// 		std::string s_formulaName = kData.ReadUnicodeString();
// 		std::string strIconName = kData.ReadUnicodeString();
// 		FormulaMaterialData* t_formula = getFormulaData(t_idFormula);
// 		if(t_formula != NULL){
// 			t_formula->init(t_lev,t_matID_1,t_matCount_1,t_matID_2,t_matCount_2,t_matID_3,t_matCount_3,t_producID,t_money,t_emoney,iconIndex);
// 		}else{
// 			m_mapFomula.insert( map_fomula_pair(t_idFormula,
// 				new FormulaMaterialData(t_idFormula,t_lev,t_matID_1,t_matCount_1,t_matID_2,t_matCount_2,t_matID_3,t_matCount_3,t_producID,t_money,t_emoney,s_formulaName,iconIndex) ) 
// 				);
// 		}
// 		if(byStudyType == 1){//0是下发，1是学习
// 			//					String formulaName = new Item(t_idFormula).getItemName();
// 			Item item(t_idFormula);
// 			std::stringstream ss; ss << NDCommonCString("Common_LearnedTip") << item.getItemName();
// 			GlobalShowDlg(NDCommonCString("OperateSucess"), ss.str());
// 		}
// 	}
	CloseProgressBar;
}

void NDMapMgr::processSyndicate(NDTransData& kData)
{
	int answer = kData.ReadByte();

	/***
	 * 此函数大量依赖SynApproveUILayer
	 * 张迪的
	 * 郭浩
	 */

// 	switch (answer)
// 	{
// 	case ANS_SYN_PANEL_INFO:
// 		{
// 			SynInfoUILayer* infoLayer = SynInfoUILayer::GetCurInstance();
// 			if (infoLayer) {
// 				infoLayer->processSynInfo(kData);
// 			}
// 		}
// 		break;
// 	case ANS_REG_SYN_INFO:
// 	case ANS_SYN_LIST_INFO:
// 	case ANS_QUERY_VOTE_INFO:
// 		{
// 			CloseProgressBar;
// 			string t_wndTitle = kData.ReadUnicodeString();
// 			string t_wndDetail = kData.ReadUnicodeString();
// 
// 			SyndicateInfoScene* synInfoScene = new SyndicateInfoScene;
// 			synInfoScene->Initialization(t_wndTitle, t_wndDetail);
// 			NDDirector::DefaultDirector()->PushScene(synInfoScene);
// 			return;
// 		}
// 	case ANS_QUERY_OFFICER:
// 		{
// 			SynElectionUILayer* election = SynElectionUILayer::GetCurInstance();
// 			if (election) {
// 				election->processQueryOfficer(kData);
// 			}
// 			return;
// 		}
// 	case ANS_QUERY_VOTE_LIST:{// 下发投票列表
// 		SynVoteUILayer* voteLayer = SynVoteUILayer::GetCurInstance();
// 		if (voteLayer) {
// 			voteLayer->processVoteList(kData);
// 		}
// 		return;
// 							 }
// 	case ANS_QUERY_SYN_STORAGE:{
// 		SynDonateUILayer* donate = SynDonateUILayer::GetCurInstance();
// 		if (donate) {
// 			donate->processSynDonate(kData);
// 		}
// 		return;
// 							   }
// 	case ANS_SYN_UPGRADE_INFO:{// 军团升级信息
// 		SynUpgradeUILayer* upgrade = SynUpgradeUILayer::GetCurInstance();
// 		if (upgrade) {
// 			upgrade->processSynUpgrade(kData);
// 		}
// 		return;
// 							  }
// 	case APPROVE_ACCEPT_OK:
// 	case APPROVE_ACCEPT_FAIL:
// 	case APPROVE_REFUSE_OK: {
// 		CloseProgressBar;
// 		SynApproveUILayer* approve = SynApproveUILayer::GetCurInstance();
// 		if (approve) {
// 			approve->delCurSelCell();
// 		}
// 		break;
// 		}
// 	case ANS_UPDATE_SYN_MBR_RANK:
// 		NDPlayer::defaultHero().setSynRank(kData.ReadByte());
// 		return;
// 	case QUIT_SYN_OK:
// 		{
// 		NDPlayer& role = NDPlayer::defaultHero();
// 		role.synName = "";
// 		role.setSynRank(SYNRANK_NONE);
// 		return;
// 		}
// 	default:
// 		break;
// 	}
}

void NDMapMgr::processDigout(NDTransData& kData)
{
	int nItemID = kData.ReadInt();
	kData.ReadByte();
	int nNumber = kData.ReadByte();
	std::vector<int> kStoneItemTypes;
	for (int i = 0; i < nNumber; i++)
	{
		kStoneItemTypes.push_back(kData.ReadInt());
	}
	Item* pkItem = NULL;
	VEC_ITEM& kItemList = ItemMgrObj.GetPlayerBagItems();
	for (int i = 0; i < int(kItemList.size()); i++)
	{
		pkItem = kItemList[i];
		if (pkItem->m_nID == nItemID)
		{
			break;
		}
	}
	if (pkItem != NULL)
	{
		for (int i = 0; i < int(kStoneItemTypes.size()); i++)
		{
			for (int j = 0; j < int(pkItem->m_vStone.size()); j++)
			{
				Item* pkItemStone = pkItem->m_vStone[j];
				if (pkItemStone->m_nItemType == kStoneItemTypes[i])
				{
					pkItem->DelStone(pkItemStone->m_nID);
					break;
				}
			}
		}
	}
	//RemoveStoneScene::Refresh(); ///< 依赖汤自勤的RemoveStoneScene 郭浩
	//showDialog(NDCommonCString("tip"), NDCommonCString("WaChuBaoShiSucc")); ///< showDialog不知道是谁的
}

void NDMapMgr::processNPC(NDTransData& kData)
{
	CloseProgressBar;
	int iid = kData.ReadInt(); // 4个字节 npc id
	int btAction = kData.ReadByte(); // 1个字节 操作类型：EVENT_DELNPC = 3;
	int btType = kData.ReadByte(); // 1个字节 NPC类型

	if (btAction == 3)
	{ // 删除NPC
		DelNpc(iid);
	}
	else if (btAction == 10)
	{ // 任务提示
		setNpcTaskStateById(iid, btType);
	}
}

void NDMapMgr::setNpcTaskStateById(int nNPCID, int nState)
{
	if (m_vNPC.empty())
	{
		return;
	}

	for (VEC_NPC::iterator it = m_vNPC.begin(); it != m_vNPC.end(); it++)
	{
		NDNpc* pkTempNPC = *it;

		if (pkTempNPC->m_nID != nNPCID)
		{
			continue;
		}

		pkTempNPC->SetNpcState(NPC_STATE(nState));
		break;
	}
}

void NDMapMgr::processSee(NDTransData& kData)
{
	CloseProgressBar;

	enum
	{
		SEE_USER_INFO = 0,	// 查看玩家信息
		SEE_EQUIP_INFO = 1,	// 查看玩家装备
		SEE_PET_INFO = 2,	// 查询宠物信息
		SEE_USER_PET_INFO = 3,	// 查询玩家宠物信息
		//查询结果
		SEE_OK = 4,	// 查询成功
		SEE_FAIL = 5,	// 查询失败

		SEE_TUTOR_POS = 6,	// 查询有师徒关系的人的位置,
		SEE_PET_INFO_OK = 7,
		SEE_USER_INFO_OK = 8,
	};

	int nAction = kData.ReadByte();	// action
	int nTargetID = kData.ReadInt();	// idtarget

	if (nAction == SEE_PET_INFO_OK)
	{
		// 查询单只宠物
		PetInfo* pkPetInfo = PetMgrObj.GetPet(nTargetID);
		if (pkPetInfo)
		{
			///< 依赖张迪（貌似是……）的NewPetInfoScene 郭浩
			//NDDirector::DefaultDirector()->PushScene(NewPetInfoScene::Scene(idTarget));
		}
	}
	else if (nAction == SEE_USER_INFO_OK)
	{
		///< 依赖汤自勤的 OtherPlayerInfoScene 郭浩
		//OtherPlayerInfoScene::ShowPlayerPet(idTarget);
	}
}

void NDMapMgr::processNpcPosition(NDTransData& kData)
{
	int npcId = kData.ReadInt();
	short col = kData.ReadShort();
	short row = kData.ReadShort();

	NDNpc *npc = GetNpc(npcId);
	if (npc != NULL)
	{
		//npc->AddWalkPoint(col, row); ///< 依赖张迪 NDNpc
	}
}

NDNpc* NDMapMgr::GetNpc(int nID)
{
	for (VEC_NPC::iterator it = m_vNPC.begin(); it != m_vNPC.end(); it++)
	{
		NDNpc* pkTempNPC = *it;

		if (pkTempNPC->m_nID != nID)
		{
			continue;
		}

		return pkTempNPC;
	}

	return NULL;
}

void NDMapMgr::processItemTypeInfo(NDTransData& kData)
{
	int cnt = kData.ReadByte();

	for (int i = 0; i < cnt; i++)
	{
		NDItemType *itemtype = new NDItemType;
		itemtype->m_data.m_id = kData.ReadInt();
		itemtype->m_data.m_level = kData.ReadByte();
		itemtype->m_data.m_req_profession = kData.ReadInt();
		itemtype->m_data.m_req_level = kData.ReadShort();
		itemtype->m_data.m_req_sex = kData.ReadShort();
		itemtype->m_data.m_req_phy = kData.ReadShort();
		itemtype->m_data.m_req_dex = kData.ReadShort();
		itemtype->m_data.m_req_mag = kData.ReadShort();
		itemtype->m_data.m_req_def = kData.ReadShort();
		itemtype->m_data.m_price = kData.ReadInt();
		itemtype->m_data.m_emoney = kData.ReadInt();
		itemtype->m_data.m_save_time = kData.ReadInt();
		itemtype->m_data.m_life = kData.ReadShort();
		itemtype->m_data.m_mana = kData.ReadInt();
		itemtype->m_data.m_amount_limit = kData.ReadShort();
		itemtype->m_data.m_hard_hitrate = kData.ReadShort();
		itemtype->m_data.m_mana_limit = kData.ReadShort();
		itemtype->m_data.m_atk_point_add = kData.ReadShort();
		itemtype->m_data.m_def_point_add = kData.ReadShort();
		itemtype->m_data.m_mag_point_add = kData.ReadShort();
		itemtype->m_data.m_dex_point_add = kData.ReadShort();
		itemtype->m_data.m_atk = kData.ReadShort();
		itemtype->m_data.m_mag_atk = kData.ReadShort();
		itemtype->m_data.m_def = kData.ReadShort();
		itemtype->m_data.m_mag_def = kData.ReadShort();
		itemtype->m_data.m_hitrate = kData.ReadShort();
		itemtype->m_data.m_atk_speed = kData.ReadShort();
		itemtype->m_data.m_dodge = kData.ReadShort();
		itemtype->m_data.m_monopoly = kData.ReadShort();
		itemtype->m_data.m_lookface = kData.ReadInt();
		itemtype->m_data.m_iconIndex = kData.ReadInt();
		itemtype->m_data.m_holeNum = kData.ReadByte();
		itemtype->m_data.m_suitData = kData.ReadInt();
		itemtype->m_data.m_idUplev = kData.ReadInt();
		itemtype->m_data.m_enhancedId = kData.ReadInt();
		itemtype->m_data.m_enhancedStatus = kData.ReadInt();
		itemtype->m_data.m_recycle_time = kData.ReadInt();

		itemtype->m_name = kData.ReadUnicodeString();
		itemtype->m_des = kData.ReadUnicodeString();

		// 描述为"无"的不显示
		if (itemtype->m_des == NDCommonCString("wu"))
		{
			itemtype->m_des.clear();
		}
		// 以服务端为准,存储或更新内存数据
		ItemMgrObj.ReplaceItemType(itemtype);
	}
}

void NDMapMgr::processCompetition(NDTransData& kData)
{
	/***
	 * 依赖张迪 SocialElement
	 * 郭浩
	 */

// 	CloseProgressBar;
// 	int act = kData.ReadByte();
// 	short curPage = kData.ReadShort();
// 	short allPage = kData.ReadShort();
// 	int amount =  kData.ReadByte();
// 	VEC_SOCIAL_ELEMENT roles;
// 	for (int i = 0; i < amount;) 
// 	{
// 		SocialElement *se = new SocialElement;
// 		se->m_id = kData.ReadInt();
// 		se->m_text1 = kData.ReadUnicodeString();
// 
// 		if (act == Competelist_VS) 
// 		{
// 			se->m_text2 = "VS";
// 			se->m_param = kData.ReadInt();
// 			se->m_text3 = kData.ReadUnicodeString();
// 		}
// 		else 
// 		{
// 			se->m_text2 = "   ";
// 		}
// 
// 
// 		roles.push_back(se);
// 
// 		act == Competelist_Joins ? i++ : i+=2;
// 	}
	//CompetelistUpdate(act, curPage, allPage, roles); 这句不知道哪里的 郭浩
}

void NDMapMgr::processReCharge(NDTransData& kData)
{
	int amount = kData.ReadShort();
	int isEnd = kData.ReadShort();
	for (int i = 0; i < amount; i++)
	{
		int b1 = kData.ReadInt();		// 菜单ID
		int b2 = kData.ReadByte();		// 菜单类型
		std::string s = kData.ReadUnicodeString();		// 名字
		int id2 = b1 % 100;

		/***
		 * 此处依赖汤自勤的NewRecharge
		 * 郭浩
		 * begin
		 */
// 			if (id2 == 0) 
// 			{
// 				RechargeUI::s_data.push_back(NewRechargeData());
// 				NewRechargeData& kData = RechargeUI::s_data.back();
// 				kData.mainData = NewRechargeSubData(b1, b2, s);
// 			} 
// 			else 
// 			{
// 				if (!RechargeUI::s_data.empty())
// 				{
// 					NewRechargeData& kData = RechargeUI::s_data.back();
// 					NDAsssert(b2 == RechargeData_Tip 
// 							  || b2 == RechargeData_Card
// 							  || b2 == RechargeData_Message);
// 					switch (b2) {
// 						case RechargeData_Tip:
// 							kData.tipData = NewRechargeSubData(b1, b2, s);
// 							break;
// 						case RechargeData_Card:
// 						case RechargeData_Message:
// 							kData.vSubData.push_back(NewRechargeSubData(b1, b2, s));
// 							break;
// 						default:
// 							break;
// 					}
// 				}
// 			}
// 		}
		/***
		 * end
		 */

		/***
		 * 依赖张迪的NewVipStoreScene
		 * 郭浩
		 * begin
		 */
// 		if (isEnd == 1) 
// 		{
// 			CloseProgressBar;
// 			NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
// 			if (scene && scene->IsKindOfClass(RUNTIME_CLASS(NewVipStoreScene)))
// 			{
// 				NewVipStoreScene *vipscene = (NewVipStoreScene*)scene;
// 				
// 				vipscene->ShowRechare();
// 			}
// 		}
		/***
		 * end
		 */
	}

}

void NDMapMgr::processRechargeReturn(NDTransData& kData)
{
	/***
	 * 等汤自勤完成后再实现
	 * 郭浩
	 */
}

void NDMapMgr::processVersionMsg(NDTransData& kData)
{
	CSMLoginScene* pkScene =
			(CSMLoginScene*) NDDirector::DefaultDirector()->GetSceneByTag(
					SMLOGINSCENE_TAG);
	if (pkScene)
	{
		//return pkScene->OnMsg_ClientVersion(kData); ///< 依赖汤自勤的CSMLoginScene 郭浩
	}
}

void NDMapMgr::processActivity(NDTransData& kData)
{
	/***
	 * CustomActivity 为未知类
	 * 郭浩
	 */
	CloseProgressBar;
	int flag = kData.ReadByte();
	int amount = kData.ReadByte();
	if (flag == 1)
	{
		//CustomActivity::ClearData();
	}
	for (int i = 0; i < amount; i++)
	{
		std::string str = kData.ReadUnicodeString();
		//CustomActivity::AddData(str);
	}
	if (flag == 2 || flag == 3)
	{
		//CustomActivity::refresh();
	}
}

void NDMapMgr::processDeleteRole(NDTransData& kData)
{
	CloseProgressBar;
	quitGame();
}

void NDMapMgr::processPortal(NDTransData& kData)
{
	///< 怀疑被废弃，因为直接return了 郭浩
	//CloseProgressBar;

	return;
}

void NDMapMgr::processMarriage(NDTransData& kData)
{
	/***
	 * 配偶的……游戏中没有配偶……
	 * 郭浩
	 */
}

void NDMapMgr::processShowTreasureHuntAward(NDTransData& kData)
{
	std::string strText = kData.ReadUnicodeString();
	GlobalShowDlg(NDCommonCString("XunBao"), strText.c_str());
}

void NDMapMgr::processRespondTreasureHuntProb(NDTransData& kData)
{
	CloseProgressBar;

	int huntLost = 0;
	int equipAdd = 0;
	int druation = 0;

	huntLost = kData.ReadByte();
	equipAdd = kData.ReadByte();
	druation = kData.ReadInt();

	///< 找不到TreasureHuntScene 郭浩
// 	TreasureHuntScene *scene = TreasureHuntScene::Scene();
// 	scene->SetRateInfo(huntLost, equipAdd, druation);
// 	NDDirector::DefaultDirector()->PushScene(scene);
}

void NDMapMgr::processRespondTreasureHuntInfo(NDTransData& kData)
{
	CloseProgressBar;
	//TreasureHuntScene::processHuntDesc(kData); ///< 找不到  郭浩
}

void NDMapMgr::processKickOutTip(NDTransData& kData)
{
	CloseProgressBar;
	std::string strTip = kData.ReadUnicodeString();

	GameQuitDialog::DefaultShow(NDCommonCString("tip"), strTip.c_str(), 5.0f,
			true);
}

void NDMapMgr::processQueryPetSkill(NDTransData& kData)
{
	///< 依赖汤自勤的 NewPetScene 郭浩
// 	CUIPet* pUIPet	= PlayerInfoScene::QueryPetScene();
// 	if (pUIPet) {
// 		OBJID idItem	= kData.ReadInt();
// 		std::string	str	= kData.ReadUnicodeString();
// 		pUIPet->UpdateSkillItemDesc(idItem, str);
// 	}
}

void NDMapMgr::processRoadBlock(NDTransData& kData)
{
	int nX = kData.ReadInt();
	int nY = kData.ReadInt();
	unsigned int uiTime = kData.ReadInt();

	NDScene* pkScene = NDDirector::DefaultDirector()->GetScene(
			RUNTIME_CLASS(CSMGameScene));

	if (!pkScene)
	{
		return;
	}

	NDMapLayer* pkLayer = getMapLayerOfScene(pkScene);

	if (!pkLayer)
	{
		return;
	}

	pkLayer->setStartRoadBlockTimer(uiTime, nX, nY);
}

void NDMapMgr::ProcessTempCredential(NDTransData& kData)
{
	///< 这两行先注释掉 郭浩
// 	NSString* temporaryCredential = data.ReadUTF8NString();
// 	if(temporaryCredential == nil) return;

#ifdef USE_MGSDK
	[MBGSocialAuth authorizeToken:temporaryCredential onSuccess:^(NSString *verifier)
	{
		sendVerifier(verifier);
	}onError:^(MBGError *error)
	{
		VerifierError(error);
	}];
#endif
}

NDMonster* NDMapMgr::GetBoss()
{
	vec_monster_it it = m_vMonster.begin();
	for (; it != m_vMonster.end(); it++)
	{
		NDMonster *pkMonster = *it;
		if ( pkMonster && pkMonster->GetType() == MONSTER_BOSS &&
			pkMonster->getState() != MONSTER_STATE_DEAD )
		{
			return pkMonster;
		}
	}
	return NULL;
}

NDManualRole* NDMapMgr::NearestDacoityManualrole( NDManualRole& role, int iDis )
{
	int minDist = iDis;

	NDManualRole * resrole = NULL;

	map_manualrole_it it = m_mapManualRole.begin();
	for (; it != m_mapManualRole.end(); it++)
	{
		NDManualRole* manualrole = it->second;

		if (role.m_nID == manualrole->m_nID) continue;

		if (!manualrole->IsInDacoity()) continue;

		if (manualrole->IsInState(USERSTATE_FIGHTING) 
			|| manualrole->IsInState(USERSTATE_DEAD)
			|| manualrole->IsInState(USERSTATE_PVE)
			) 
		{
			continue;
		}

		if ( !(role.IsInState(USERSTATE_BATTLE_POSITIVE) && manualrole->IsInState(USERSTATE_BATTLE_NEGATIVE) ||
			role.IsInState(USERSTATE_BATTLE_NEGATIVE) && manualrole->IsInState(USERSTATE_BATTLE_POSITIVE))
			)
			continue;

		int dis = getDistBetweenRole(manualrole, &role);

		if ( dis <= minDist )
		{
			resrole = manualrole;
			minDist = dis;
		}
	}

	return resrole;
}

NDManualRole* NDMapMgr::NearestBattleFieldManualrole( NDManualRole& role, int iDis )
{
	int minDist = iDis;

	NDManualRole * resrole = NULL;

	map_manualrole_it it = m_mapManualRole.begin();
	for (; it != m_mapManualRole.end(); it++)
	{
		NDManualRole* manualrole = it->second;

		if (role.m_nID == manualrole->m_nID) continue;

		if (!manualrole->IsInState(USERSTATE_BATTLEFIELD)) 
		{
			continue;
		}


		if (manualrole->IsInState(USERSTATE_BF_WAIT_RELIVE))
		{
			continue;
		}

		if (manualrole->IsInState(USERSTATE_FIGHTING) || manualrole->IsInState(USERSTATE_DEAD)) {
			continue;
		}

		if (manualrole->m_eCamp == role.m_eCamp)
		{
			continue;
		}

		int dis = getDistBetweenRole(manualrole, &role);

		if ( dis <= minDist )
		{
			resrole = manualrole;
			minDist = dis;
		}
	}

	return resrole;
}

int NDMapMgr::getDistBetweenRole( NDBaseRole *firstrole, NDBaseRole *secondrole )
{
	if (!firstrole || !secondrole)
	{
		return FOCUS_JUDGE_DISTANCE;
	}


	int w = (firstrole->GetPosition().x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE - (secondrole->GetPosition().x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE;
	int h = (firstrole->GetPosition().y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE - (secondrole->GetPosition().y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE;

	return w * w + h * h;
}

void NDMapMgr::BattleStart()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene));
	if (scene) 
	{
		/***
		* 等待张迪的 DirectKey
		* 郭浩
		*/
		//DirectKey* dk = ((GameScene*)scene)->GetDirectKey();
		//if (dk) 
		//{
		//	dk->OnButtonUp(NULL);
		//}
	}

	NDPlayer::defaultHero().BattleStart();
}

NDBaseRole* NDMapMgr::GetNextTarget( int iDistance )
{
	NDPlayer *player = &NDPlayer::defaultHero();

	NDBaseRole * resrole = NULL;

	if (!player)
	{
		return resrole;
	}

	if (player->m_nTargetIndex >= int(m_vNPC.size()+m_mapManualRole.size()))
	{
		player->m_nTargetIndex = 0;
	}

	if (player->m_nTargetIndex < int(m_vNPC.size()) )
	{
		VEC_NPC::iterator it = m_vNPC.begin()+ player->m_nTargetIndex;
		for (; it != m_vNPC.end(); it++)
		{
			player->m_nTargetIndex++;
			NDNpc* npc = *it;

			if (npc->m_nID == player->GetFocusNpcID() )
			{
				continue;
			}

			int dis = getDistBetweenRole(player, npc);
			if ( dis < iDistance )
			{
				resrole = npc;
				return resrole;
			}
		}
	}

	int iIndexManuRole = player->m_nTargetIndex - m_vNPC.size();

	if (iIndexManuRole < 0)
	{
		iIndexManuRole = 0;
	}

	if (iIndexManuRole < (int)m_mapManualRole.size())
	{
		map_manualrole_it it = m_mapManualRole.begin();
		for (int i = 0; i < iIndexManuRole; i++)
		{
			it++;
		}

		for (; it != m_mapManualRole.end(); it++)
		{
			player->m_nTargetIndex++;

			NDManualRole *otherplayer = it->second;

			if (otherplayer->m_nID == player->m_iFocusManuRoleID )
			{
				continue;
			}

			int dis = getDistBetweenRole(player, otherplayer);
			if ( dis < iDistance )
			{
				resrole = otherplayer;
				return resrole;
			}
		}
	}

	return resrole;
}

NDBaseRole* NDMapMgr::GetRoleNearstPlayer( int iDistance )
{
	int minDist = iDistance;

	NDPlayer *player = &NDPlayer::defaultHero();

	NDBaseRole * resrole = NULL;

	if (!player)
	{
		return resrole;
	}

	do 
	{
		VEC_NPC::iterator it = m_vNPC.begin();
		for (; it != m_vNPC.end(); it++)
		{
			NDNpc *npc = *it;
			int dis = getDistBetweenRole(player, npc);
			if ( dis < minDist )
			{
				resrole = npc;
				minDist = dis;
				player->m_nTargetIndex = 0;

				//npc在附近则返回
				return resrole;
			}
		}
	} while (0);

	do 
	{
		map_manualrole_it it = m_mapManualRole.begin();
		for (; it != m_mapManualRole.end(); it++)
		{
			NDManualRole *otherplayer = it->second;

			if (player->m_nTeamID !=0 && player->m_nTeamID == otherplayer->m_nTeamID)
			{
				continue;
			}

			int dis = getDistBetweenRole(player, otherplayer);
			if ( dis < minDist )
			{
				resrole = otherplayer;
				minDist = dis;
			}
		}
	} while (0);

	return resrole;
}

NS_NDENGINE_END
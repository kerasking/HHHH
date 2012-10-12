#include "NDMapMgr.h"
#include "NDPlayer.h"
#include "NDConstant.h"

namespace NDEngine
{

IMPLEMENT_CLASS(NDMapMgr,NDObject);

NDMapMgr::NDMapMgr()
{

}

NDMapMgr::~NDMapMgr()
{

}

bool NDMapMgr::process(MSGID usMsgID, NDEngine::NDTransData* pkData,
		int nLength)
{
	switch (usMsgID)
	{
	case _MSG_CHG_PET_POINT:
	{
		int nBtAnswer = pkData->ReadByte();
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
		std::string str = pkData->ReadUnicodeString();
		if (i == 0)
		{
			name = str;
		}
		else if (i == 1 && str.length() > 2)
		{
			strRank = str;
		}
		else if (i == 2)
		{
			synName = str;
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
	int effectAmount = pkData->ReadByte();
	std::vector<int> vEffect;
	for (int i = 0; i < effectAmount; i++)
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
	pkRole->m_dwLookFace = dwLookFace;
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

// 	if (pkRole->isTeamMember())
// 	{
// 		updateTeamListAddPlayer(*pkRole);
// 	}

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

	NDLayer* pkLayer = getMapLayerOfScene(
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
	return 0;
}

NDManualRole* NDMapMgr::GetManualRole(const char* pszName)
{
	return 0;
}

void NDMapMgr::Update(unsigned long ulDiff)
{

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

void NDMapMgr::DelManualRole( int nID )
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
			SAFE_DELETE_NODE(pkRole->GetRidePet()); ///< 還有寵物這玩意嗎？ 郭浩
			SAFE_DELETE_NODE(pkRole);
		}
	}
}

}
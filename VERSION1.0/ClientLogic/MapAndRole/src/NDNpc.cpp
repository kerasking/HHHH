//
//  NDNpc.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDNpc.h"
#include "NDPath.h"
#include "NDMapData.h"
#include "NDMapLayer.h"
#include "NDUILayer.h"
#include "NDDirector.h"
#include "NDConstant.h"
#include "EnumDef.h"
//#include "NDRidePet.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "CCPointExtension.h"
///< #include "NDMapMgr.h" 临时性注释 郭浩
#include "GameScene.h"
#include "NDMapLayer.h"
#include "SMGameScene.h"

#include "ScriptGameData.h"
#include "ScriptDataBase.h"
#include "ScriptTask.h"
#include "TableDef.h"
#include "ScriptGameLogic.h"
#include "NDAnimationGroup.h"

using namespace NDEngine;

// lable->SetRenderTimes(3);

#define InitNameLable(pkLables) \
do \
{ \
	if (!pkLables) \
	{ \
		pkLables = new NDUILabel; \
		pkLables->Initialization(); \
		pkLables->SetFontSize(12); \
		pkLables->SetRenderTimes(3); \
	} \
	if (!pkLables->GetParent() && m_pkSubNode) \
	{ \
		m_pkSubNode->AddChild(pkLables); \
	} \
} while (0)

#define DrawLable(pkLables, bDraw) do { if (bDraw && pkLables) pkLables->draw(); }while(0)

IMPLEMENT_CLASS(NDNpc, NDBaseRole)

NDNpc::NDNpc() :
m_eNPCState(NPC_STATE_NO_MARK)
{
	m_bRoleNpc = false;
	//ridepet = NULL;
	memset(m_pkNameLabel, 0, sizeof(m_pkNameLabel));
	memset(m_pkDataStrLebel, 0, sizeof(m_pkDataStrLebel));

	m_pkPicBattle = NULL;
	m_pkPicState = NULL;

	m_bActionOnRing = true;
	m_bDirectOnTalk = true;

	m_iStatus = -1;

	m_pkUpdate = NULL;

	m_iType = 0;

	m_bFarmNpc = false;

	m_bUnpassTurn = false;

	m_kRectState = CGRectZero;
}

NDNpc::~NDNpc()
{
	CC_SAFE_DELETE (m_pkPicBattle);
	CC_SAFE_DELETE (m_pkPicState);
}

void NDNpc::Initialization(int nLookface)
{
	m_nSex = nLookface / 100000000 % 10;
	m_nModel = nLookface % 1000;

	tq::CString sprFile;

	if (nLookface <= 0)
	{
		sprFile.Format("%snpc1.spr", NDPath::GetAnimationPath().c_str());
	}
	else
	{
		sprFile.Format("%smodel_%d%s", NDPath::GetAnimationPath().c_str(),
			m_nModel, ".spr");
	}

	NDSprite::Initialization(sprFile);

	m_bFaceRight = m_nDirect == 2;
	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
}

bool NDNpc::OnDrawBegin(bool bDraw)
{
	NDNode* pkNode = this->GetParent();
	CGSize kSizeMap;

	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		kSizeMap = pkNode->GetContentSize();
	}
	else
	{
		return true;
	}

	RefreshTaskState();

	NDPlayer& kPlayer = NDPlayer::defaultHero();

	ShowShadow(m_nID != kPlayer.GetFocusNpcID());

	NDBaseRole::OnDrawBegin(bDraw);

	m_pkSubNode->SetContentSize(kSizeMap);

	if (m_pkRidePet)
	{
		m_pkRidePet->SetPosition(GetPosition());

		if (!m_pkRidePet->GetParent())
		{
			m_pkSubNode->AddChild(m_pkRidePet);
		}
	}

	return true;
}

void NDNpc::OnDrawEnd(bool bDraw)
{
	NDNode* pkNode = this->GetParent();

	CGSize kSizeMap;
	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		kSizeMap = pkNode->GetContentSize();
	}
	else
	{
		return;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	CGPoint kPlayerPos = kPlayer.GetPosition();
	CGPoint kNPCPos = this->GetPosition();

	CGRect kRectRole;
	CGRect kRectNPC;
	kRectRole = CGRectMake(kPlayerPos.x - SHOW_NAME_ROLE_W,
			kPlayerPos.y - SHOW_NAME_ROLE_H, SHOW_NAME_ROLE_W << 1,
			SHOW_NAME_ROLE_H << 1);
	kRectNPC = CGRectMake(kNPCPos.x, kNPCPos.y, 16, 16);
	bool bCollides = CGRectIntersectsRect(kRectRole, kRectNPC);

	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	CGSize kSize = getStringSize(m_strName.c_str(), 12);

	int nShowX = kNPCPos.x;
	int nShowY = kNPCPos.y - kSize.height
			- (m_pkCurrentAnimation ?
					(m_pkCurrentAnimation->getBottomY()
							- m_pkCurrentAnimation->getY()) : 0);

	bool isEmemy = false;
	if (kPlayer.IsInState(USERSTATE_FIGHTING))
	{
		isEmemy = (GetCamp() != CAMP_NEUTRAL && kPlayer.GetCamp() != CAMP_NEUTRAL
				&& GetCamp() != kPlayer.GetCamp());
	}

	unsigned int uiColor = isEmemy ? 0xe30318 : 0xffff00;

	if (!m_strName.empty())
	{
		InitNameLable(m_pkNameLabel[0]);
		InitNameLable(m_pkNameLabel[1]);
// 		SetLable(eLableName, nShowX, nShowY, m_strName, INTCOLORTOCCC4(uiColor),
// 				ccc4(0, 0, 0, 255)); ///< 不知道为什么会在这里卡住 郭浩
		DrawLable(m_pkNameLabel[1], bDraw);
		DrawLable(m_pkNameLabel[0], bDraw);
		//showY -= 5 * fScaleFactor;
	}

	if ((m_eNPCState & NPC_STATE_BATTLE) > 0)
	{
		if (m_pkPicBattle == NULL)
		{
			m_pkPicBattle = NDPicturePool::DefaultPool()->AddPicture(
					NDPath::GetImgPath("battle.png"));
			CGSize sizeBattle = m_pkPicBattle->GetSize();
			m_pkPicBattle->DrawInRect(
					CGRectMake(kNPCPos.x - 16,
							GetPosition().y - 64
									+ NDDirector::DefaultDirector()->GetWinSize().height
									- kSizeMap.height, sizeBattle.width,
							sizeBattle.height));
		}
	}
	else
	{
		if (m_pkPicState != NULL)
		{
			CGSize sizeState = m_pkPicState->GetSize();
			CGRect rect = CGRectMake(kNPCPos.x - sizeState.width / 2,
					nShowY + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height - sizeState.height,
					sizeState.width, sizeState.height);
			m_kRectState = CGRectMake(kNPCPos.x - sizeState.width / 2,
					nShowY - sizeState.height, sizeState.width,
					sizeState.height);
			m_pkPicState->DrawInRect(rect);
		}
	}
//	}
}

void NDNpc::SetExpresstionImage(int nExpresstion)
{
	int nExpress = 10400;
	switch (nExpresstion)
	{
	case 0: //
		break;
	case 1: //
		nExpress = 10400;
		break;
	case 2: //
		nExpress = 10401;
		break;
	case 3: //
		nExpress = 10404;
		break;
	case 4: //
		nExpress = 10405;
		break;
	case 5: //
		nExpress = 10406;
		break;
	case 6: //
		nExpress = 10407;
		break;
	case 7: //
		nExpress = 10408;
		break;
	case 8: //
		nExpress = 10409;
		break;
	case 9: //
		nExpress = 10410;
		break;
	}

	if (nExpress >= 10400 && nExpress < 10600)
	{
		tq::CString str("%s%d.png", NDPath::GetImagePath().c_str(), nExpress);
		SetExpressionImage(str.c_str());
	}
}

void NDNpc::SetNpcState(NPC_STATE state)
{
	if (state == this->m_eNPCState)
	{
		return;
	}

	if (m_pkPicState)
	{
		CC_SAFE_DELETE (m_pkPicState);
	}
	this->m_eNPCState = state;

	if ((m_eNPCState & QUEST_CANNOT_ACCEPT) > 0)
	{
		//m_picState = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("task_state_1.png"));
	}
	else if ((m_eNPCState & QUEST_CAN_ACCEPT) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(
				GetSMImgPath("mark_submit.png"));
	}
	else if ((m_eNPCState & QUEST_NOT_FINISH) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(
				GetSMImgPath("mark_task_accepted.png"));
	}
	else if ((m_eNPCState & QUEST_FINISH) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(
				GetSMImgPath("mark_task_accept.png"));
	}

	if (!m_pkPicState)
	{
		//m_picState = ScriptMgrObj.excuteLuaFunc<NDPicture*>("GetNpcFuncPic", "NPC", this->m_id); ///< 临时性注释 郭浩
	}
}

void NDNpc::SetStatus(int status)
{
	m_iStatus = status;
}

void NDNpc::SetType(int iType)
{
	m_iType = iType;
}

int NDNpc::GetType()
{
	return m_iType;
}

void NDNpc::SetLable(LableType eLableType, int x, int y, std::string text,
		cocos2d::ccColor4B color1, cocos2d::ccColor4B color2)
{
	if (!m_pkSubNode)
	{
		return;
	}

	NDUILabel* pkLables[2] = {0};
	memset(pkLables, 0, sizeof(pkLables));

	if (eLableType == eLableName)
	{
		pkLables[0] = m_pkNameLabel[0];
		pkLables[1] = m_pkNameLabel[1];
	}
	else if (eLableType == eLabelDataStr)
	{
		pkLables[0] = m_pkDataStrLebel[0];
		pkLables[1] = m_pkDataStrLebel[1];
	}

	if (!pkLables[0] || !pkLables[1])
	{
		return;
	}

	pkLables[0]->SetText(text.c_str());
	pkLables[1]->SetText(text.c_str());

	pkLables[0]->SetFontColor(color1);
	pkLables[1]->SetFontColor(color2);

	CGSize kSizeMap;
	kSizeMap = m_pkSubNode->GetContentSize();
	CGSize kSizeWin = NDDirector::DefaultDirector()->GetWinSize();
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
	CGSize kSize = getStringSize(text.c_str(), 12);
	pkLables[1]->SetFrameRect(
			CGRectMake(x - (kSize.width / 2) + 1,
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height, kSizeWin.width,
					20 * fScaleFactor));
	pkLables[0]->SetFrameRect(
			CGRectMake(x - (kSize.width / 2),
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height, kSizeWin.width,
					20 * fScaleFactor));
}

bool NDNpc::IsPointInside(CGPoint point)
{
	if (m_pkCurrentAnimation)
	{
		CGRect kRect = CGRectMake(this->m_kPosition.x - this->GetWidth() / 2,
				this->m_kPosition.y - this->GetHeight(), this->GetWidth(),
				this->GetHeight());

		if (CGRectContainsPoint(kRect, point))
		{
			return true;
		}
	}

	if (m_pkPicState)
	{
		if (CGRectContainsPoint(m_kRectState, point))
		{
			return true;
		}
	}

	return false;
}

bool NDNpc::getNearestPoint(CGPoint srcPoint, CGPoint& dstPoint)
{
	/***
	 * 临时性注释 郭浩
	 * begin
	 */

// 	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
// 	if (!scene) return false;
// 	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
// 	if (!layer) return false;
// 	NDMapData* mapdata = layer->GetMapData();
// 	if (!mapdata) return false;
// 	
// 	int resX = 0, resY = 0;
// 	
// 	int srcY = int((srcPoint.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE), srcX = int((srcPoint.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE);
// 	
// 	int maxDis = mapdata->getColumns()*mapdata->getColumns() + mapdata->getRows()*mapdata->getRows();
// 	
// 	int nArrayX[4] = {0, -1, 0, 1};
// 	int nArrayY[4] = {1, 0, -1, 0};
// 	
// 	{
// 		for(int i = 0; i < 4; ++i)
// 		{
// 			int newX = col + nArrayX[i];
// 			int newY = row + nArrayY[i];
// 			if(newX < 0)
// 				continue;
// 			if(newX < 0)
// 				continue;
// 			if(newX > int([mapdata columns]))
// 				continue;
// 			if(newY > int([mapdata rows]))
// 				continue;
// 			
// 			if (![mapdata canPassByRow:newY andColumn:newX])
// 				continue;
// 			
// 			int cacl = (newX-srcX) * (newX-srcX) + (newY-srcY) * (newY-srcY);
// 			
// 			if (cacl < maxDis)
// 			{
// 				maxDis = cacl;
// 				
// 				resX = newX;
// 				
// 				resY = newY;
// 			}
// 		}	
// 	}
// 
// 	if (resX == 0 && resY == 0)
// 	{
// 		resX = this->GetPosition().x;
// 		resY = this->GetPosition().y;
// 	}
// 	
// 	dstPoint = CGPointMake(resX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, resY*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET);
	/***
	 * 临时性注释 郭浩
	 * end
	 */

	return true;
}

void NDNpc::RefreshTaskState()
{
	// 玩家已接任务列表
	ID_VEC idlistAccept;
	ScriptGameDataObj.GetDataIdList(eScriptDataRole,
			NDPlayer::defaultHero().m_nID, eRoleDataTask, idlistAccept);
	if (!idlistAccept.empty())
	{
		for (ID_VEC::iterator it = idlistAccept.begin();
				it != idlistAccept.end(); it++)
		{
			// 可交
			int nState = ScriptGetTaskState(*it);
			if (TASK_STATE_COMPLETE == nState)
			{
				if (m_nID
						== ScriptDBObj.GetN("task_type", *it,
								DB_TASK_TYPE_FINISH_NPC))
				{
					this->SetNpcState((NPC_STATE) QUEST_FINISH);
					return;
				}
			}
		}
	}

	ID_VEC idVec;
	GetTaskList(idVec);

	ID_VEC idCanAccept;
	if (GetPlayerCanAcceptList(idCanAccept))
	{
		for (ID_VEC::iterator it = idVec.begin(); it != idVec.end(); it++)
		{
			// 可接
			for (ID_VEC::iterator itCanAccept = idCanAccept.begin();
					itCanAccept != idCanAccept.end(); itCanAccept++)
			{
				if (*it == *itCanAccept)
				{
					this->SetNpcState((NPC_STATE) QUEST_CAN_ACCEPT);
					return;
				}
			}
		}
	}

	for (ID_VEC::iterator it = idVec.begin(); it != idVec.end(); it++)
	{
		// 未完成
		int nState = ScriptGetTaskState(*it);
		if (TASK_STATE_UNCOMPLETE == nState)
		{
			this->SetNpcState((NPC_STATE) QUEST_NOT_FINISH);
			return;
		}
	}

	this->SetNpcState((NPC_STATE) QUEST_CANNOT_ACCEPT);
}

int NDNpc::GetDataBaseData(int nIndex)
{
	int nKey = ScriptDBObj.GetKey("npc");
	if (0 == nKey)
	{
		return 0;
	}
	return ScriptGameDataObj.GetData<unsigned long long>(eScriptDataDataBase,
			nKey, eRoleDataPet, this->m_nID, nIndex);
}

bool NDNpc::GetTaskList(ID_VEC& idVec)
{
	idVec.clear();

	int nTask = GetDataBaseData(DB_NPC_TASK0);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK1);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK2);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK3);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK4);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK5);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK6);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK7);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK8);
	if (0 < nTask)
		idVec.push_back(nTask);

	nTask = GetDataBaseData(DB_NPC_TASK9);
	if (0 < nTask)
		idVec.push_back(nTask);

	return !idVec.empty();
}

bool NDNpc::GetPlayerCanAcceptList(ID_VEC& idVec)
{
	idVec.clear();

	if (!ScriptGameDataObj.GetDataIdList(eScriptDataRole,
			NDPlayer::defaultHero().m_nID, eRoleDataTaskCanAccept, idVec))
	{
		return false;
	}

	return true;
}

void NDNpc::ShowHightLight(bool bShow)
{
	if (m_pkPicState)
	{
		m_pkPicState->SetColor(
				bShow ? ccc4(255, 255, 255, 125) : ccc4(255, 255, 255, 255));
	}

	this->SetHightLight(bShow);
}

bool NDEngine::NDNpc::IsActionOnRing()
{
	//throw std::exception("The method or operation is not implemented.");
	return true;
}

void NDEngine::NDNpc::initUnpassPoint()
{
	//throw std::exception("The method or operation is not implemented.");
}

void NDEngine::NDNpc::SetDirectOnTalk( bool bOn )
{
	//throw std::exception("The method or operation is not implemented.");
}

void NDEngine::NDNpc::HandleNPCMask( bool bSet )
{
	//throw std::exception("The method or operation is not implemented.");
}

void NDEngine::NDNpc::SetActionOnRing( bool bOn )
{

}
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

#define InitNameLable(lable) \
do \
{ \
if (!lable) \
{ \
lable = new NDUILabel; \
lable->Initialization(); \
lable->SetFontSize(12); \
lable->SetRenderTimes(3); \
} \
if (!lable->GetParent() && m_pkSubNode) \
{ \
m_pkSubNode->AddChild(lable); \
} \
} while (0)

#define DrawLable(lable, bDraw) do { if (bDraw && lable) lable->draw(); }while(0)

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

	m_rectState = CGRectZero;
}

NDNpc::~NDNpc()
{
	CC_SAFE_DELETE (m_pkPicBattle);
	CC_SAFE_DELETE (m_pkPicState);
}

void NDNpc::Initialization(int nLookface)
{
	sex = nLookface / 100000000 % 10;
	model = nLookface / 1000 % 100;
	//lookface = 2000000;

	tq::CString sprFile;

	if (nLookface <= 0)
	{
		sprFile.Format("%snpc1.spr", NDPath::GetAnimationPath().c_str());
	}
	else
	{
// 		sprFile.Format("%@model_%d%s", NDPath::GetAnimationPath().c_str(),
// 				nLookface / 1000000, ".spr");
		sprFile.Format("%smodel_%d%s", NDPath::GetAnimationPath().c_str(),
			nLookface, ".spr");
	}

	NDSprite::Initialization(sprFile);

	m_bFaceRight = direct == 2;
	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
}

bool NDNpc::OnDrawBegin(bool bDraw)
{
	NDNode *pkNode = this->GetParent();
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

	ShowShadow(this->m_nID != kPlayer.GetFocusNpcID());

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
	NDNode *node = this->GetParent();

	CGSize sizemap;
	if (node && node->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		sizemap = node->GetContentSize();
	}
	else
	{
		return;
	}

	NDPlayer& player = NDPlayer::defaultHero();
	CGPoint playerpos = player.GetPosition();
	CGPoint npcpos = this->GetPosition();

	CGRect rectRole, rectNPC;
	rectRole = CGRectMake(playerpos.x - SHOW_NAME_ROLE_W,
			playerpos.y - SHOW_NAME_ROLE_H, SHOW_NAME_ROLE_W << 1,
			SHOW_NAME_ROLE_H << 1);
	rectNPC = CGRectMake(npcpos.x, npcpos.y, 16, 16);
	bool collides = CGRectIntersectsRect(rectRole, rectNPC);

	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	CGSize size = getStringSize(m_name.c_str(), 12);

	int showX = npcpos.x;
	int showY = npcpos.y - size.height
			- (m_pkCurrentAnimation ?
					(m_pkCurrentAnimation->getBottomY()
							- m_pkCurrentAnimation->getY()) :
					0);

//	if (collides)
//	{
	bool isEmemy = false;
	if (player.IsInState(USERSTATE_FIGHTING))
	{
		isEmemy = (GetCamp() != CAMP_NEUTRAL && player.GetCamp() != CAMP_NEUTRAL
				&& GetCamp() != player.GetCamp());
	}

	//unsigned int iColor = isEmemy ? 0xe30318 : 0x88EEFF;
	unsigned int iColor = isEmemy ? 0xe30318 : 0xffff00;

// 		if (!dataStr.empty() && dataStr != NDCommonCString("wu"))
// 		{
// 			InitNameLable(m_lbDataStr[0]);InitNameLable(m_lbDataStr[1]);
// 			SetLable(eLabelDataStr, showX, showY, dataStr, INTCOLORTOCCC4(iColor), ccc4(0, 0, 0, 255));
// 			DrawLable(m_lbDataStr[1], bDraw); DrawLable(m_lbDataStr[0], bDraw);
// 			showY -= 20 * fScaleFactor;
// 		}

	if (!m_name.empty())
	{
		InitNameLable(m_pkNameLabel[0]);
		InitNameLable(m_pkNameLabel[1]);
		SetLable(eLableName, showX, showY, m_name, INTCOLORTOCCC4(iColor),
				ccc4(0, 0, 0, 255));
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
					CGRectMake(npcpos.x - 16,
							GetPosition().y - 64
									+ NDDirector::DefaultDirector()->GetWinSize().height
									- sizemap.height, sizeBattle.width,
							sizeBattle.height));
		}
	}
	else
	{
		if (m_pkPicState != NULL)
		{
			CGSize sizeState = m_pkPicState->GetSize();
			CGRect rect = CGRectMake(npcpos.x - sizeState.width / 2,
					showY + NDDirector::DefaultDirector()->GetWinSize().height
							- sizemap.height - sizeState.height,
					sizeState.width, sizeState.height);
			m_rectState = CGRectMake(npcpos.x - sizeState.width / 2,
					showY - sizeState.height, sizeState.width,
					sizeState.height);
			m_pkPicState->DrawInRect(rect);
		}
	}
//	}
}

void NDNpc::SetExpresstionImage(int nExpresstion)
{
	int express = 10400;
	switch (nExpresstion)
	{
	case 0: //
		break;
	case 1: //
		express = 10400;
		break;
	case 2: //
		express = 10401;
		break;
	case 3: //
		express = 10404;
		break;
	case 4: //
		express = 10405;
		break;
	case 5: //
		express = 10406;
		break;
	case 6: //
		express = 10407;
		break;
	case 7: //
		express = 10408;
		break;
	case 8: //
		express = 10409;
		break;
	case 9: //
		express = 10410;
		break;
	}

	if (express >= 10400 && express < 10600)
	{
		tq::CString str("%s%d.png", NDPath::GetImagePath().c_str(), express);
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

	NDUILabel *lable[2];
	memset(lable, 0, sizeof(lable));
	if (eLableType == eLableName)
	{
		lable[0] = m_pkNameLabel[0];
		lable[1] = m_pkNameLabel[1];
	}
	else if (eLableType == eLabelDataStr)
	{
		lable[0] = m_pkDataStrLebel[0];
		lable[1] = m_pkDataStrLebel[1];
	}

	if (!lable[0] || !lable[1])
	{
		return;
	}

	lable[0]->SetText(text.c_str());
	lable[1]->SetText(text.c_str());

	lable[0]->SetFontColor(color1);
	lable[1]->SetFontColor(color2);

	//lable[0]->SetFontBoderColer(color1);
	//lable[1]->SetFontBoderColer(color2);

	CGSize sizemap;
	sizemap = m_pkSubNode->GetContentSize();
	CGSize sizewin = NDDirector::DefaultDirector()->GetWinSize();
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
	CGSize size = getStringSize(text.c_str(), 12);
	lable[1]->SetFrameRect(
			CGRectMake(x - (size.width / 2) + 1,
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- sizemap.height, sizewin.width,
					20 * fScaleFactor));
	lable[0]->SetFrameRect(
			CGRectMake(x - (size.width / 2),
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- sizemap.height, sizewin.width,
					20 * fScaleFactor));
}

bool NDNpc::IsPointInside(CGPoint point)
{
	if (m_pkCurrentAnimation)
	{
		CGRect kRect = CGRectMake(this->m_position.x - this->GetWidth() / 2,
				this->m_position.y - this->GetHeight(), this->GetWidth(),
				this->GetHeight());

		if (CGRectContainsPoint(kRect, point))
		{
			return true;
		}
	}

	if (m_pkPicState)
	{
		if (CGRectContainsPoint(m_rectState, point))
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
	return true;
}

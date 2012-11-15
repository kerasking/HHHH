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
#include "NDMapMgr.h"
#include "GameScene.h"
#include "NDMapLayer.h"
#include "SMGameScene.h"

#include "ScriptGameData.h"
#include "ScriptDataBase.h"
#include "ScriptTask.h"
#include "TableDef.h"
#include "ScriptGameLogic.h"
#include "NDDebugOpt.h"
#include "NDNpcLogic.h"

#define NPC_NAME_FONT_SIZE 14

using namespace NDEngine;

// lable->SetRenderTimes(3);

#define InitNameLable(pkLables) \
do \
{ \
	if (!pkLables) \
	{ \
		pkLables = new NDUILabel; \
		pkLables->Initialization(); \
		pkLables->SetFontSize(NPC_NAME_FONT_SIZE); \
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

	m_kRectState = CCRectZero;

	m_npcLogic = new NDNpcLogic(this);
}

NDNpc::~NDNpc()
{
	CC_SAFE_DELETE (m_pkPicBattle);
	CC_SAFE_DELETE (m_pkPicState);
}

void NDNpc::Init()
{
}

void NDNpc::SetActionOnRing(bool on)
{
	m_bActionOnRing = on;
}

bool NDNpc::IsActionOnRing()
{
	return m_bActionOnRing;
}

void NDNpc::SetDirectOnTalk(bool on)
{
	m_bDirectOnTalk = on;
}

bool NDNpc::IsDirectOnTalk()
{
	return m_bDirectOnTalk;
}

void NDNpc::Initialization(int nLookface, bool bFaceRight/*true*/)
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

	m_bFaceRight = bFaceRight;
	SetCurrentAnimation(MANUELROLE_STAND, m_bFaceRight);
}

void NDNpc::WalkToPosition(CCPoint toPos)
{
	std::vector<CCPoint> vec_pos; vec_pos.push_back(toPos);
	this->MoveToPosition(vec_pos, SpriteSpeedStep4, false);
}

void NDNpc::OnMoving(bool bLastPos)
{

}

void NDNpc::OnMoveEnd()
{
	if (m_dequePos.empty()) 
	{
		return;
	}

	CCPoint pos = m_dequePos.front();
	m_dequePos.pop_front();

	std::vector<CCPoint> vec_pos; vec_pos.push_back(pos);
	MoveToPosition(vec_pos, m_pkRidePet == NULL ? SpriteSpeedStep4 : SpriteSpeedStep8, false);
}

bool NDNpc::OnDrawBegin(bool bDraw)
{
	if (!NDDebugOpt::getDrawRoleNpcEnabled()) return false;

	NDNode* pkNode = this->GetParent();
	CCSize kSizeMap;

	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		kSizeMap = pkNode->GetContentSize();
	}
	else
	{
		return true;
	}

	m_npcLogic->RefreshTaskState(); //logic

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

	//画骑宠
	if (m_pkRidePet)
	{
		m_pkRidePet->RunAnimation(bDraw);
	}


// 	if (m_talkBox && m_talkBox->IsVisibled() && bDraw) 
// 	{
// 		CCPoint scrPos = GetScreenPoint();
// 		scrPos.x -= DISPLAY_POS_X_OFFSET;
// 		scrPos.y -= DISPLAY_POS_Y_OFFSET;
// 		//NDLog(@"x=[%d],y=[%d]",int(scrPos.x), int(scrPos.y));
// 
// 		CCSize sizeTalk = m_talkBox->GetSize();
// 
// 		scrPos.x = scrPos.x-8+GetWidth()/2-sizeTalk.width/2;
// 
// 		scrPos.y = scrPos.y-getGravityY()+30;
// 
// 		TipTriangleAlign align = TipTriangleAlignCenter;
// 
// 		CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();
// 
// 		if (scrPos.x + sizeTalk.width > winsize.width) 
// 		{
// 			align = TipTriangleAlignRight;
// 
// 			scrPos.x -= sizeTalk.width/2;
// 		}
// 		else if (scrPos.x < 0)
// 		{
// 			scrPos.x = scrPos.x+sizeTalk.width/2; 
// 
// 			align = TipTriangleAlignLeft;
// 		}
// 
// 		m_talkBox->SetTriangleAlign(align);
// 		m_talkBox->SetDisPlayPos(scrPos);
// 		m_talkBox->SetVisible(true);
// 	}


	return true;
}

void NDNpc::OnDrawEnd(bool bDraw)
{
	return; //@todo

	NDNode* pkNode = this->GetParent();

	CCSize kSizeMap;
	if (pkNode && pkNode->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
	{
		kSizeMap = pkNode->GetContentSize();
	}
	else
	{
		return;
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	CCPoint kPlayerPos = kPlayer.GetPosition();
	CCPoint kNPCPos = this->GetPosition();

	CCRect kRectRole;
	CCRect kRectNPC;
	kRectRole = CCRectMake(kPlayerPos.x - SHOW_NAME_ROLE_W,
			kPlayerPos.y - SHOW_NAME_ROLE_H, SHOW_NAME_ROLE_W << 1,
			SHOW_NAME_ROLE_H << 1);
	kRectNPC = CCRectMake(kNPCPos.x, kNPCPos.y, 16, 16);
	bool bCollides = cocos2d::CCRect::CCRectIntersectsRect(kRectRole, kRectNPC);

	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	CCSize kSize = getStringSize(m_strName.c_str(), NPC_NAME_FONT_SIZE*fScaleFactor);

	int nShowX = kNPCPos.x - 30;		///< 临时性调整 郭浩
	//高度临时调整，后续应该修改为在缩放时进行数据处理，否则坐标外部需要处理HJQ
	int nShowY = kNPCPos.y - kSize.height
			- ((m_pkCurrentAnimation ?
					(m_pkCurrentAnimation->getBottomY()
							- m_pkCurrentAnimation->getY()) : 0)
											 * 0.5f * fScaleFactor + 45.0f);	///< 临时性调整 + 10.0f 郭浩

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
  		SetLable(eLableName, nShowX, nShowY, m_strName, INTCOLORTOCCC4(uiColor),
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
			CCSize sizeBattle = m_pkPicBattle->GetSize();
			m_pkPicBattle->DrawInRect(
					CCRectMake(kNPCPos.x - 16,
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
			CCSize sizeState = m_pkPicState->GetSize();
			CCRect rect = CCRectMake(kNPCPos.x - sizeState.width / 2,
					nShowY + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height - sizeState.height,
					sizeState.width, sizeState.height);
			m_kRectState = CCRectMake(kNPCPos.x - sizeState.width / 2,
					nShowY - sizeState.height, sizeState.width,
					sizeState.height);
			m_pkPicState->DrawInRect(rect);
		}
	}
//	}

	if (!m_strTalk.empty() && m_strTalk.size() > 3 && abs(kPlayer.GetCol()-m_nCol) <= 2 && abs(kPlayer.GetRow()-m_nRow) <= 2) 
		addTalkMsg(m_strTalk, 0);
// 	else if (m_pkTalkBox)
// 		SAFE_DELETE_NODE(m_talkBox);

	//升级特效
	ShowUpdate(m_iStatus == 1, bDraw);
}

void NDNpc::BeforeRunAnimation(bool bDraw)
{
// 	if (m_pkTalkBox && m_pkTalkBox->IsVisibled() && !bDraw) 
// 	{
// 		m_pkTalkBox->SetVisible(false);
// 	}
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
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("mark_submit.png"));
	}
	else if ((m_eNPCState & QUEST_NOT_FINISH) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("mark_task_accepted.png"));
	}
	else if ((m_eNPCState & QUEST_FINISH) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("mark_task_accept.png"));
	}
	else if ( (m_eNPCState & QUEST_FINISH_SUB) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("mark_task_accept2.png"));
	}       
	else if ( (m_eNPCState & QUEST_CAN_ACCEPT_SUB) > 0)
	{
		m_pkPicState = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetSMImgPath("mark_submit2.png"));
	}

	if (!m_pkPicState)
	{
		m_pkPicState = ScriptMgrObj.excuteLuaFunc<NDPicture*>("GetNpcFuncPic", "NPC", m_nID);
	}
	if (m_pkPicState) {
		//根据分辨率进行缩放
		m_pkPicState->setScale(0.5f*NDDirector::DefaultDirector()->GetScaleFactor());
	}
}

void NDNpc::AddWalkPoint(int col, int row)
{
	m_nCol = col;
	m_nRow = row;

	m_dequePos.push_back(ccp(col*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, row*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));

	if (!m_bIsMoving) 
	{
		CCPoint pos = m_dequePos.front();
		m_dequePos.pop_front();

		std::vector<CCPoint> vec_pos; vec_pos.push_back(pos);
		MoveToPosition(vec_pos, m_pkRidePet == NULL ? SpriteSpeedStep4 : SpriteSpeedStep8, false);
	}
}


void NDNpc::SetStatus(int status)
{
	m_iStatus = status;
}

void NDNpc::ShowUpdate(bool bshow, bool bDraw)
{
	if (!m_pkUpdate && bshow) 
	{
		m_pkUpdate = new NDSprite;
		
		char aniPath[256];
		_snprintf(aniPath, 256, "%sbuiltupdate.spr", NDPath::GetAnimationPath().c_str());
		m_pkUpdate->Initialization(aniPath);
		m_pkUpdate->SetCurrentAnimation(0, false);

		if (m_pkSubNode) m_pkSubNode->AddChild(m_pkUpdate);
	}

	if (m_pkUpdate && !bshow) 
	{
		SAFE_DELETE_NODE(m_pkUpdate);
	}

	if (bshow) 
	{
		CCPoint pos = this->GetPosition();
		pos.x -= DISPLAY_POS_X_OFFSET;
		pos.y -= DISPLAY_POS_Y_OFFSET;

		//if (aniGroup != null) {
		//			updateEffect.draw(g, x - 5, y - aniGroup.getGravityY(),
		//							  offsetX, offsetY);
		//		} else if (baseRole != null) {
		//			updateEffect.draw(g, x - 5, y - baseRole.getHeight(), offsetX,
		//							  offsetY);
		//		} else {
		//			updateEffect.draw(g, x - 5, y - 20, offsetX, offsetY);
		//		}

		pos.x -= 5;
		pos.y -= getGravityY();

		m_pkUpdate->SetPosition(pos);
		m_pkUpdate->RunAnimation(bDraw);
	}
}

void NDNpc::HandleNpcMask(bool bSet)
{
	NDMapLayer *layer = NDMapMgrObj.getMapLayerOfScene(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
	if (!layer)
	{
		return;
	}

	NDMapData *mapdata = layer->GetMapData();

	if (!mapdata) {
		return;
	}

	CCPoint point = this->GetPosition();
	int iCellY = int((point.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE), iCellX = int((point.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE);

	vector<int>* unpass = m_pkAniGroup->getUnpassPoint();
	int unpassCount = unpass->size();
	if (unpass == nil || unpassCount % 2 != 0) {
		if (bSet)
			mapdata->addObstacleCell(iCellY, iCellX);
		else
			mapdata->removeObstacleCell(iCellY, iCellX);
		return;
	}

	for (int i = 0; i < unpassCount; i+= 2) {
		int cellX = unpass->at(i);
		int cellY = unpass->at(i+1);
		if (cellX && cellY) {
			if (bSet)
				mapdata->addObstacleCell(cellY+iCellY, cellX+iCellX);
			else
				mapdata->removeObstacleCell(cellY+iCellY, cellX+iCellX);
		}
	}

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

	CCSize kSizeMap;
	kSizeMap = m_pkSubNode->GetContentSize();
	CCSize kSizeWin = NDDirector::DefaultDirector()->GetWinSize();
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
	CCSize kSize = getStringSize(text.c_str(), NPC_NAME_FONT_SIZE*fScaleFactor);
	pkLables[1]->SetFrameRect(
			CCRectMake(x - (kSize.width / 2) + 1,
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height, kSizeWin.width,
					30 * fScaleFactor));
	pkLables[0]->SetFrameRect(
			CCRectMake(x - (kSize.width / 2),
					y + NDDirector::DefaultDirector()->GetWinSize().height
							- kSizeMap.height, kSizeWin.width,
					30 * fScaleFactor));
}

void NDNpc::initUnpassPoint()
{
	if (m_pkAniGroup == nil)
		return;

	CCPoint point = this->GetPosition();

	vector<int>* unpass = m_pkAniGroup->getUnpassPoint();
	int unpassCount = 0;
	if(unpass)
		unpassCount = unpass->size();
	if (unpass == nil || unpassCount % 2 != 0) {
		m_vUnpassRect.clear();

		m_vUnpassRect.push_back(CCRectMake(point.x-4, point.y-16, 20, 16));

		return;
	}

	//int iCellY = int((point.y-DISPLAY_POS_Y_OFFSET)/16), iCellX = int((point.x-DISPLAY_POS_X_OFFSET)/16);

	for (int i = 0; i < unpassCount; i+= 2) {
		int cellX = unpass->at(i);
		int cellY = unpass->at(i+1);

		CCPoint pos;
		pos.x = (IsUnpassNeedTurn() ? (-cellX) : cellX) * 16 + point.x;
		pos.y = cellY * 16 + 8 + point.y;


		m_vUnpassRect.push_back(CCRectMake(pos.x, pos.y, 16, 16));
	}
}

bool NDNpc::IsUnpassNeedTurn()
{
	return m_bUnpassTurn;
}

bool NDNpc::IsPointInside(CCPoint point)
{
	if (m_pkCurrentAnimation)
	{
		CCRect kRect = CCRectMake(this->m_kPosition.x - this->GetWidth() / 2,
				this->m_kPosition.y - this->GetHeight(), this->GetWidth(),
				this->GetHeight());

		if (cocos2d::CCRect::CCRectContainsPoint(kRect, point))
		{
			return true;
		}
	}

	if (m_pkPicState)
	{
		if (cocos2d::CCRect::CCRectContainsPoint(m_kRectState, point))
		{
			return true;
		}
	}

	std::vector<CCRect>::iterator it = m_vUnpassRect.begin();

	for (; it != m_vUnpassRect.end(); it++) {
		CCRect rect = *it;
		rect.origin.y -= 24;
		rect.size.height += 24;
		rect.origin.x -= 8;
		rect.size.width += 8;
		if (cocos2d::CCRect::CCRectContainsPoint(rect, point))
			return true;
	}

	return false;
}

bool NDNpc::getNearestPoint(CCPoint srcPoint, CCPoint& dstPoint)
{
	NDScene *scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
	if (!scene) return false;
	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
	if (!layer) return false;
	NDMapData* mapdata = layer->GetMapData();
	if (!mapdata) return false;
	
	int resX = 0, resY = 0;
	
	int srcY = int((srcPoint.y-DISPLAY_POS_Y_OFFSET)/MAP_UNITSIZE), srcX = int((srcPoint.x-DISPLAY_POS_X_OFFSET)/MAP_UNITSIZE);
	
	int maxDis = mapdata->getColumns()*mapdata->getColumns() + mapdata->getRows()*mapdata->getRows();
	
	int nArrayX[4] = {0, -1, 0, 1};
	int nArrayY[4] = {1, 0, -1, 0};
	
	if (m_pkAniGroup != nil && m_pkAniGroup->getUnpassPoint() != nil)
	{
		vector<int>* unpass = m_pkAniGroup->getUnpassPoint();
		int unpassCount = unpass->size();

		for (int i = 0; i < unpassCount; i+= 2) {
			int cellX = unpass->at(i);
			int cellY = unpass->at(i + 1);

			int x, y;

			x = m_nCol + (IsUnpassNeedTurn() ? (-cellX) : cellX);
			y = m_nRow + cellY;

			int newX, newY;

			for(int i = 0; i < 4; ++i)
			{
				newX = x + nArrayX[i];
				newY = y + nArrayY[i];
				if(newX < 0)
					continue;
				if(newX < 0)
					continue;
				if(newX > int(mapdata->getColumns()))
					continue;
				if(newY > int(mapdata->getRows()))
					continue;

				if (!mapdata->canPassByRow(newY, newX))
					continue;

				int cacl = (newX-srcX) * (newX-srcX) + (newY-srcY) * (newY-srcY);

				if (cacl < maxDis)
				{
					maxDis = cacl;

					resX = newX;

					resY = newY;
				}
			}	
		}
	}
	else 
	{

		for(int i = 0; i < 4; ++i)
		{
			int newX = m_nCol + nArrayX[i];
			int newY = m_nRow + nArrayY[i];
			if(newX < 0)
				continue;
			if(newX < 0)
				continue;
			if(newX > int(mapdata->getColumns()))
				continue;
			if(newY > int(mapdata->getRows()))
				continue;
			
			if (!mapdata->canPassByRow(newY, newX))
				continue;
			
			int cacl = (newX-srcX) * (newX-srcX) + (newY-srcY) * (newY-srcY);
			
			if (cacl < maxDis)
			{
				maxDis = cacl;
				
				resX = newX;
				
				resY = newY;
			}
		}	
	}

	if (resX == 0 && resY == 0)
	{
		resX = this->GetPosition().x;
		resY = this->GetPosition().y;
	}
	
	dstPoint = CCPointMake(resX*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, resY*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET);

	return true;
}

int NDNpc::GetDataBaseData(int nIndex)
{
	int nKey = ScriptDBObj.GetKey("npc");
	if (0 == nKey)
	{
		return 0;
	}
	return ScriptGameDataObj.GetData<unsigned long long>(eScriptDataDataBase,
			nKey, eRoleDataPet, m_nID, nIndex);
}

/*
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
*/

void NDNpc::ShowHightLight(bool bShow)
{
	if (m_pkPicState)
	{
		m_pkPicState->SetColor(
				bShow ? ccc4(255, 255, 255, 125) : ccc4(255, 255, 255, 255));
	}

	this->SetHightLight(bShow);
}
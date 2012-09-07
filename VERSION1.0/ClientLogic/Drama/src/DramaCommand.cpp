/*
 *  DramaCommand.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "DramaCommand.h"
#include "DramaScene.h"
#include "DramaUI.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "GameScene.h"

///////////////////////////////////////////////
DramaScene* GetDramaScene()
{
	NDDirector* director = NDDirector::DefaultDirector();

	if (!director)
	{
		return NULL;
	}

	NDScene* scene = director->GetScene(RUNTIME_CLASS(DramaScene));

	if (!scene)
	{
		return NULL;
	}

	return (DramaScene*) scene;
}

///////////////////////////////////////////////
void DramaCommandDlg::InitWithOpen(bool bLeft)
{
	m_param.type = DCT_OPEN;
	m_param.u3.bLeft = bLeft;
}

void DramaCommandDlg::InitWithClose(bool bLeft)
{
	m_param.type = DCT_CLOSE;
	m_param.u3.bLeft = bLeft;
}

void DramaCommandDlg::InitWithSetFigure(bool bLeft, std::string filename,
		bool bReverse)
{
	m_param.type = DCT_SETDLGFIG;
	m_param.str = filename;
	m_param.u3.bLeft = bLeft;
	m_param.u1.bReverse = bReverse;
}

void DramaCommandDlg::InitWithSetTitle(bool bLeft, std::string title,
		int nFontSize, int nFontColor)
{
	m_param.type = DCT_SETDLGTITLE;
	m_param.str = title;
	m_param.u3.bLeft = bLeft;
	m_param.u2.nFontSize = nFontSize;
	m_param.u1.nFontColor = nFontColor;
	m_param.nKey = 0;
}

void DramaCommandDlg::InitWithSetTitleBySpriteKey(bool bLeft, int nKey,
		int nFontSize, int nFontColor)
{
	m_param.type = DCT_SETDLGTITLE;
	m_param.u3.bLeft = bLeft;
	m_param.u2.nFontSize = nFontSize;
	m_param.u1.nFontColor = nFontColor;
	m_param.nKey = nKey;
}

void DramaCommandDlg::InitWithSetContent(bool bLeft, std::string content,
		int nFontSize, int nFontColor)
{
	m_param.type = DCT_SETDLGCONTENT;
	m_param.str = content;
	m_param.u3.bLeft = bLeft;
	m_param.u2.nFontSize = nFontSize;
	m_param.u1.nFontColor = nFontColor;
}

void DramaCommandDlg::InitWithTip(std::string content)
{
	m_param.type = DCT_SHOWTIPDLG;
	m_param.str = content;
}

void DramaCommandDlg::excute()
{
	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	if (DCT_OPEN == m_param.type)
	{
		dramaScene->OpenChat(m_param.u3.bLeft);
	}
	else if (DCT_CLOSE == m_param.type)
	{
		dramaScene->CloseChat(m_param.u3.bLeft);
	}
	else if (DCT_SETDLGFIG == m_param.type)
	{
		dramaScene->SetChatFigure(m_param.u3.bLeft, m_param.str,
				m_param.u1.bReverse);
	}
	else if (DCT_SETDLGTITLE == m_param.type)
	{
		if (0 == m_param.nKey)
		{
			dramaScene->SetChatTitle(m_param.u3.bLeft, m_param.str,
					m_param.u2.nFontSize, m_param.u1.nFontColor);
		}
		else
		{
			dramaScene->SetChatTitleBySpriteKey(m_param.u3.bLeft, m_param.nKey,
					m_param.u2.nFontSize, m_param.u1.nFontColor);
		}
	}
	else if (DCT_SETDLGCONTENT == m_param.type)
	{
		dramaScene->SetChatContent(m_param.u3.bLeft, m_param.str,
				m_param.u2.nFontSize, m_param.u1.nFontColor);
	}
	else if (DCT_SHOWTIPDLG == m_param.type)
	{
		dramaScene->ShowTipDlg(m_param.str);
	}
}

///////////////////////////////////////////////
void DramaCommandSprite::InitWithAdd(int nLookFace, int nType, bool faceRight,
		std::string name)
{
<<<<<<< HEAD
	m_param.nKey						= AllocKey();
	m_param.type						= DCT_ADDSPRITE;
	m_param.u1.nLookFace				= nLookFace;
	m_param.u2.nSpriteType				= nType;
	m_param.u3.bFaceRight				= faceRight;
	m_param.str							= name;

	//add by ZhangDi 120904
	m_param.u1.nPosX					= 9*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET;
	m_param.u2.nPoxY					= 11*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET;
=======
	m_param.nKey = AllocKey();
	m_param.type = DCT_ADDSPRITE;
	m_param.u1.nLookFace = nLookFace;
	m_param.u2.nSpriteType = nType;
	m_param.u3.bFaceRight = faceRight;
	m_param.str = name;
>>>>>>> 2b6ecf919ada6b494993550bd4de51f991eb4356
}

void DramaCommandSprite::InitWithAddByFile(std::string filename)
{
	m_param.nKey = AllocKey();
	m_param.type = DCT_ADDSPRITEBYFILE;
	m_param.str = filename;
}

void DramaCommandSprite::InitWithRemove(int nKey)
{
	m_param.u3.nTargetKey = nKey;
	m_param.type = DCT_REMOVESPRITE;
}

void DramaCommandSprite::InitWithSetAnimation(int nKey, int nAniIndex)
{
	m_param.u3.nTargetKey = nKey;
	m_param.type = DCT_SETSPRITEANI;
	m_param.u1.nAniIndex = nAniIndex;
}

void DramaCommandSprite::InitWithSetPos(int nKey, int nPosX, int nPosY)
{
	m_param.u3.nTargetKey = nKey;
	m_param.type = DCT_SETSPRITEPOS;
	m_param.u1.nPosX = nPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;
	m_param.u2.nPoxY = nPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
}

void DramaCommandSprite::InitWithMove(int nKey, int nToPosX, int nToPosY,
		int nStep)
{
	m_param.nKey = nKey;
	m_param.type = DCT_MOVESPRITE;
	m_param.u1.nToPosX = nToPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;
	m_param.u2.nToPosY = nToPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
	m_param.u3.nMoveStep = nStep;
}

void DramaCommandSprite::excute()
{
	if (DCT_ADDSPRITE == m_param.type)
	{
		ExcuteAddSprite();
	}
	else if (DCT_ADDSPRITEBYFILE == m_param.type)
	{
		ExcuteAddSpriteByFile();
	}
	else if (DCT_REMOVESPRITE == m_param.type)
	{
		ExcuteRemoveSprite();
	}
	else if (DCT_SETSPRITEANI == m_param.type)
	{
		ExcuteSetAnimation();
	}
	else if (DCT_SETSPRITEPOS == m_param.type)
	{
		ExcuteSetPostion();
	}
	else if (DCT_MOVESPRITE == m_param.type)
	{
		ExcuteMoveSprite();
	}
}

void DramaCommandSprite::ExcuteAddSprite()
{
	NDAsssert(DCT_ADDSPRITE == m_param.type);

	this->SetFinish(true);
<<<<<<< HEAD
	
	//modified by ZhangDi 120905
	//DramaScene* dramaScene	= GetDramaScene();
	NDDirector* director = NDDirector::DefaultDirector();
	//GameScene* dramaScene = (GameScene*)director->GetRunningScene();
	GameScene* dramaScene = (GameScene*)director->GetScene(RUNTIME_CLASS(GameScene));
	NDAsssert(dramaScene != NULL);
	
	m_param.u2.nSpriteType = ST_NPC;

	switch (m_param.u2.nSpriteType) {
		case ST_PLAYER:
			dramaScene->AddManuRole(m_param.nKey, m_param.u1.nLookFace);
			break;
		case ST_NPC:
			dramaScene->AddNpc(m_param.nKey, m_param.u1.nLookFace);
			break;
		case ST_MONSTER:
			dramaScene->AddMonster(m_param.nKey, m_param.u1.nLookFace);
			break;
		default:
			break;
=======

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	switch (m_param.u2.nSpriteType)
	{
	case ST_PLAYER:
		dramaScene->AddManuRole(m_param.nKey, m_param.u1.nLookFace);
		break;
	case ST_NPC:
		dramaScene->AddNpc(m_param.nKey, m_param.u1.nLookFace);
		break;
	case ST_MONSTER:
		dramaScene->AddMonster(m_param.nKey, m_param.u1.nLookFace);
		break;
	default:
		break;
>>>>>>> 2b6ecf919ada6b494993550bd4de51f991eb4356
	}

	NDSprite* sprite = dramaScene->GetSprite(m_param.nKey);

	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
	{
		((NDBaseRole*) sprite)->m_name = m_param.str;
	}
}

void DramaCommandSprite::ExcuteAddSpriteByFile()
{
	NDAsssert(DCT_ADDSPRITEBYFILE == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	dramaScene->AddSprite(m_param.nKey, m_param.str);

	NDSprite* sprite = dramaScene->GetSprite(m_param.nKey);

	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
	{
		sprite->SetCurrentAnimation(0, false);
	}
}

void DramaCommandSprite::ExcuteRemoveSprite()
{
	NDAsssert(DCT_REMOVESPRITE == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	dramaScene->RemoveSprite(m_param.u3.nTargetKey);
	DeAllocKey(m_param.u3.nTargetKey);
}

void DramaCommandSprite::ExcuteSetAnimation()
{
	NDAsssert(DCT_SETSPRITEANI == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_param.u3.nTargetKey);

	if (!sprite)
	{
		return;
	}

	sprite->SetCurrentAnimation(m_param.u1.nAniIndex, sprite->IsReverse());
}

void DramaCommandSprite::ExcuteSetPostion()
{
	NDAsssert(DCT_SETSPRITEPOS == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_param.u3.nTargetKey);
	if (!sprite)
	{
		return;
	}

	sprite->SetPosition(ccp(m_param.u1.nPosX, m_param.u2.nPoxY));
}

void DramaCommandSprite::ExcuteMoveSprite()
{
	NDAsssert(DCT_MOVESPRITE == m_param.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		this->SetFinish(true);
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_param.nKey);
	if (!sprite)
	{
		this->SetFinish(true);
		return;
	}

	bool bXArrive = false;
	bool bYArrive = false;
	CGPoint curPos = sprite->GetPosition();
	if (abs(int(curPos.x) - m_param.u1.nToPosX) <= m_param.u3.nMoveStep)
	{
		curPos.x = m_param.u1.nToPosX;
		bXArrive = true;
	}
	else if (int(curPos.x) > m_param.u1.nToPosX)
	{
		curPos.x -= m_param.u3.nMoveStep;
	}
	else if (int(curPos.x) < m_param.u1.nToPosX)
	{
		curPos.x += m_param.u3.nMoveStep;
	}

	if (abs(int(curPos.y) - m_param.u2.nToPosY) <= m_param.u3.nMoveStep)
	{
		curPos.y = m_param.u2.nToPosY;
		bYArrive = true;
	}
	else if (int(curPos.y) > m_param.u2.nToPosY)
	{
		curPos.y -= m_param.u3.nMoveStep;
	}
	else if (int(curPos.y) < m_param.u2.nToPosY)
	{
		curPos.y += m_param.u3.nMoveStep;
	}

	sprite->SetCurrentAnimation(MANUELROLE_WALK, sprite->IsReverse());
	sprite->SetPosition(curPos);

	if (bXArrive && bYArrive)
	{
		this->SetFinish(true);
	}
}

///////////////////////////////////////////////
void DramaCommandScene::InitWithLoadDrama(int nMapId)
{
	m_param.type = DCT_LOADMAPSCENE;
	m_param.u1.nMapId = nMapId;
}

void DramaCommandScene::InitWithFinishDrama()
{
	m_param.type = DCT_OVER;
}

void DramaCommandScene::InitWithLoad(std::string centerText, int nFontSize,
		int nFontColor)
{
	m_param.nKey = AllocKey();
	m_param.type = DCT_LOADERASESCENE;
	m_param.str = centerText;
	m_param.u2.nFontSize = nFontSize;
	m_param.u1.nFontColor = nFontColor;
}

void DramaCommandScene::InitWithRemove(int nKey)
{
	m_param.type = DCT_REMOVEERASESCENE;
	m_param.u3.nTargetKey = nKey;
}

void DramaCommandScene::excute()
{
	if (DCT_LOADMAPSCENE == m_param.type)
	{
		ExcuteLoadDramaScene();
	}
	else if (DCT_OVER == m_param.type)
	{
		ExcuteFinishDrama();
	}
	else if (DCT_LOADERASESCENE == m_param.type)
	{
		ExcuteLoadEraseScene();
	}
	else if (DCT_REMOVEERASESCENE == m_param.type)
	{
		ExcuteRemoveEraseScene();
	}
}

void DramaCommandScene::ExcuteLoadDramaScene()
{
	NDAsssert(DCT_LOADMAPSCENE == m_param.type);

	this->SetFinish(true);

	DramaScene* scene = new DramaScene;
	scene->Init(m_param.u1.nMapId);
	NDDirector::DefaultDirector()->PushScene(scene);
}

void DramaCommandScene::ExcuteFinishDrama()
{
	NDAsssert(DCT_OVER == m_param.type);

	this->SetFinish(true);

	NDDirector* director = NDDirector::DefaultDirector();
	if (!director)
	{
		return;
	}

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDScene* runScene = NULL;
	while ((runScene = director->GetRunningScene()))
	{
		bool bfind = runScene->IsKindOfClass(RUNTIME_CLASS(DramaScene));
		if (!director->PopScene(true) || bfind)
		{
			break;
		}
	}

	DramaCommandBase::ResetKeyAlloc();
}

void DramaCommandScene::ExcuteLoadEraseScene()
{
	NDAsssert(DCT_LOADERASESCENE == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	DramaTransitionScene* scene = new DramaTransitionScene;
	scene->Init();
	scene->SetText(m_param.str, m_param.u2.nFontSize, m_param.u1.nFontColor);

	if (!dramaScene->PushScene(m_param.nKey, scene))
	{
		delete scene;
	}
}

void DramaCommandScene::ExcuteRemoveEraseScene()
{
	NDAsssert(DCT_REMOVEERASESCENE == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	dramaScene->RemoveScene(m_param.u3.nTargetKey);
	DeAllocKey(m_param.u3.nTargetKey);
}

///////////////////////////////////////////////
void DramaCommandCamera::InitWithSetPos(int nPosX, int nPosY)
{
	m_param.type = DCT_SETCAMERA;
	m_param.u1.nPosX = nPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;
	m_param.u2.nPoxY = nPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
}

void DramaCommandCamera::InitWithMove(int nToPosX, int nToPosY, int nStep)
{
	m_param.type = DCT_MOVECAMERA;
	m_param.u1.nToPosX = nToPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;
	m_param.u2.nToPosY = nToPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
	m_param.u3.nMoveStep = nStep;
}

void DramaCommandCamera::excute()
{
	if (DCT_SETCAMERA == m_param.type)
	{
		ExcuteSetPosition();
	}
	else if (DCT_MOVECAMERA == m_param.type)
	{
		ExcuteMovePostion();
	}
}

void DramaCommandCamera::ExcuteSetPosition()
{
	NDAsssert(DCT_SETCAMERA == m_param.type);

	this->SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	dramaScene->SetCenter(ccp(m_param.u1.nPosX, m_param.u2.nPoxY));
}

void DramaCommandCamera::ExcuteMovePostion()
{
	NDAsssert(DCT_MOVECAMERA == m_param.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		this->SetFinish(true);
		return;
	}

	bool bXArrive = false;
	bool bYArrive = false;
	CGPoint curPos = dramaScene->GetCenter();
	if (abs(int(curPos.x) - m_param.u1.nToPosX) <= m_param.u3.nMoveStep)
	{
		curPos.x = m_param.u1.nToPosX;
		bXArrive = true;
	}
	else if (int(curPos.x) > m_param.u1.nToPosX)
	{
		curPos.x -= m_param.u3.nMoveStep;
	}
	else if (int(curPos.x) < m_param.u1.nToPosX)
	{
		curPos.x += m_param.u3.nMoveStep;
	}

	if (abs(int(curPos.y) - m_param.u2.nToPosY) <= m_param.u3.nMoveStep)
	{
		curPos.y = m_param.u2.nToPosY;
		bYArrive = true;
	}
	else if (int(curPos.y) > m_param.u2.nToPosY)
	{
		curPos.y -= m_param.u3.nMoveStep;
	}
	else if (int(curPos.y) < m_param.u2.nToPosY)
	{
		curPos.y += m_param.u3.nMoveStep;
	}

	bool bOverBoder = dramaScene->SetCenter(curPos);

	if ((bXArrive && bYArrive) || bOverBoder)
	{
		this->SetFinish(true);
	}
}

///////////////////////////////////////////////
#define TAG_TIME_WAIT (1)

void DramaCommandWait::InitWithWait(float fTime)
{
	m_param.type = DCT_WAITTIME;
	m_param.u1.fTime = fTime;
	m_param.u2.bTimeStart = false;
	m_param.u3.bTimeout = false;

	this->SetCanExcuteNextCommand(false);
}

void DramaCommandWait::InitWithWaitPreActionFinish()
{
	m_param.type = DCT_WAITPREACTFINISH;

	this->SetCanExcuteNextCommand(false);
}

void DramaCommandWait::InitWithWaitPreActFinishAndClick()
{
	m_param.type = DCT_WAITPREACTFINISHANDCLICK;

	this->SetCanExcuteNextCommand(false);
}

void DramaCommandWait::OnTimer(OBJID tag)
{
	if (TAG_TIME_WAIT != tag)
	{
		return;
	}

	m_param.u3.bTimeout = true;
	m_timer.KillTimer(this, TAG_TIME_WAIT);
}

void DramaCommandWait::excute()
{
	if (DCT_WAITTIME == m_param.type)
	{
		ExcuteWaitTime();
	}
	else if (DCT_WAITPREACTFINISH == m_param.type)
	{
		ExcuteWaitPreAction();
	}
	else if (DCT_WAITPREACTFINISHANDCLICK == m_param.type)
	{
		ExcuteWaitPreActionAndClick();
	}
}

void DramaCommandWait::ExcuteWaitTime()
{
	NDAsssert(DCT_WAITTIME == m_param.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene || m_param.u3.bTimeout)
	{
		this->SetFinish(true);
		this->SetCanExcuteNextCommand(true);
		return;
	}

	if (!m_param.u2.bTimeStart)
	{
		m_timer.SetTimer(this, TAG_TIME_WAIT, m_param.u1.fTime);

		m_param.u2.bTimeStart = true;
	}
}

void DramaCommandWait::ExcuteWaitPreAction()
{
	NDAsssert(DCT_WAITPREACTFINISH == m_param.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene || this->IsPreCommandsFinish())
	{
		this->SetFinish(true);
		this->SetCanExcuteNextCommand(true);
	}
	else
	{
		dramaScene->ConsumeClick();
	}
}

void DramaCommandWait::ExcuteWaitPreActionAndClick()
{
	NDAsssert(DCT_WAITPREACTFINISHANDCLICK == m_param.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		this->SetFinish(true);
		this->SetCanExcuteNextCommand(true);
	}

	if (!this->IsPreCommandsFinish())
	{
		dramaScene->ConsumeClick();
		return;
	}

	if (dramaScene->ConsumeClick())
	{
		this->SetFinish(true);
		this->SetCanExcuteNextCommand(true);
	}
}

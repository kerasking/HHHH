/*
 *  DramaCommand.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-17.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "DramaCommand.h"
#include "DramaScene.h"
#include "DramaUI.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDConstant.h"
#include "BattleMgr.h"
#include "NDPath.h"
#include "NDUtility.h"
#include "ScriptMgr.h"

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
	m_kParam.type = DCT_OPEN;
	m_kParam.u3.bLeft = bLeft;
}

void DramaCommandDlg::InitWithClose(bool bLeft)
{
	m_kParam.type = DCT_CLOSE;
	m_kParam.u3.bLeft = bLeft;
}

void DramaCommandDlg::InitWithSetFigure(bool bLeft, std::string filename, bool bReverse, int nCol, int nRow)
{
	m_kParam.type = DCT_SETDLGFIG;
	m_kParam.str = filename;
	m_kParam.u3.bLeft = bLeft;
	m_kParam.u1.bReverse = bReverse;
	m_kParam.m_Pic_CellX = nCol;
	m_kParam.m_Pic_CellY = nRow;
}

void DramaCommandDlg::InitWithSetTitle(bool bLeft, std::string title,
		int nFontSize, int nFontColor)
{
	m_kParam.type = DCT_SETDLGTITLE;
	m_kParam.str = title;
	m_kParam.u3.bLeft = bLeft;
	m_kParam.u2.nFontSize = nFontSize;
	m_kParam.u1.nFontColor = nFontColor;
	m_kParam.nKey = 0;
}

void DramaCommandDlg::InitWithSetTitleBySpriteKey(bool bLeft, int nKey,
		int nFontSize, int nFontColor)
{
	m_kParam.type = DCT_SETDLGTITLE;
	m_kParam.u3.bLeft = bLeft;
	m_kParam.u2.nFontSize = nFontSize;
	m_kParam.u1.nFontColor = nFontColor;
	m_kParam.nKey = nKey;
}

void DramaCommandDlg::InitWithSetContent(bool bLeft, std::string content,
		int nFontSize, int nFontColor)
{
	m_kParam.type = DCT_SETDLGCONTENT;
	m_kParam.str = content;
	m_kParam.u3.bLeft = bLeft;
	m_kParam.u2.nFontSize = nFontSize;
	m_kParam.u1.nFontColor = nFontColor;
}

void DramaCommandDlg::InitWithTip(std::string content)
{
	m_kParam.type = DCT_SHOWTIPDLG;
	m_kParam.str = content;
}

void DramaCommandDlg::excute()
{
	SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	if (DCT_OPEN == m_kParam.type)
	{
		dramaScene->OpenChat(m_kParam.u3.bLeft);
	}
	else if (DCT_CLOSE == m_kParam.type)
	{
		dramaScene->CloseChat(m_kParam.u3.bLeft);
	}
	else if (DCT_SETDLGFIG == m_kParam.type)
	{
		dramaScene->SetChatFigure(m_kParam.u3.bLeft, m_kParam.str, m_kParam.u1.bReverse,
			                    m_kParam.m_Pic_CellX, m_kParam.m_Pic_CellY);
	}
	else if (DCT_SETDLGTITLE == m_kParam.type)
	{
		if (0 == m_kParam.nKey)
		{
			dramaScene->SetChatTitle(m_kParam.u3.bLeft, m_kParam.str,
					m_kParam.u2.nFontSize, m_kParam.u1.nFontColor);
		}
		else
		{
			dramaScene->SetChatTitleBySpriteKey(m_kParam.u3.bLeft, m_kParam.nKey,
					m_kParam.u2.nFontSize, m_kParam.u1.nFontColor);
		}
	}
	else if (DCT_SETDLGCONTENT == m_kParam.type)
	{
		dramaScene->SetChatContent(m_kParam.u3.bLeft, m_kParam.str,
				m_kParam.u2.nFontSize, m_kParam.u1.nFontColor);
	}
	else if (DCT_SHOWTIPDLG == m_kParam.type)
	{
		dramaScene->ShowTipDlg(m_kParam.str);
	}
}

///////////////////////////////////////////////
void DramaCommandSprite::InitWithAdd(int nLookFace, int nType, bool faceRight,
		std::string name)
{
	m_kParam.nKey = AllocKey();
	m_kParam.type = DCT_ADDSPRITE;
	m_kParam.u1.nLookFace = nLookFace;
	m_kParam.u2.nSpriteType = nType;
	m_kParam.u3.bFaceRight = faceRight;
	m_kParam.str = name;
}

void DramaCommandSprite::InitWithAddByFile(std::string filename)
{
	m_kParam.nKey = AllocKey();
	m_kParam.type = DCT_ADDSPRITEBYFILE;
	m_kParam.str = filename;
}

void DramaCommandSprite::InitWithRemove(int nKey)
{
	m_kParam.u3.nTargetKey = nKey;
	m_kParam.type = DCT_REMOVESPRITE;
}

void DramaCommandSprite::InitWithSetAnimation(int nKey, int nAniIndex)
{
	m_kParam.u3.nTargetKey = nKey;
	m_kParam.type = DCT_SETSPRITEANI;
	m_kParam.u1.nAniIndex = nAniIndex;
}
void DramaCommandSprite::InitWithSetReverse(int nKey, bool bReverse)
{
	m_kParam.nKey						= nKey;
	m_kParam.type						= DCT_SPRITE_REVERSE;
	m_kParam.u1.bReverse              = bReverse;

}
void DramaCommandSprite::InitWithSetPos(int nKey, int nPosX, int nPosY)
{
	m_kParam.u3.nTargetKey = nKey;
	m_kParam.type = DCT_SETSPRITEPOS;
// 	m_kParam.u1.nPosX = nPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;//@del
// 	m_kParam.u2.nPoxY = nPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
	m_kParam.u1.nPosX = ConvertUtil::convertCellToDisplayX(nPosX);
	m_kParam.u2.nPoxY = ConvertUtil::convertCellToDisplayY(nPosY);
}

void DramaCommandSprite::InitWithMove(int nKey, int nToPosX, int nToPosY,
		int nStep)
{
	m_kParam.nKey = nKey;
	m_kParam.type = DCT_MOVESPRITE;
// 	m_kParam.u1.nToPosX = nToPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;//@del
// 	m_kParam.u2.nToPosY = nToPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
	m_kParam.u1.nToPosX = ConvertUtil::convertCellToDisplayX(nToPosX);
	m_kParam.u2.nToPosY = ConvertUtil::convertCellToDisplayY(nToPosY);
	m_kParam.u3.nMoveStep = nStep;
}
void DramaCommandSprite::InitWithEffect(int nKey,int nEffectId)
{
	m_kParam.nKey						= nKey;
	m_kParam.type						= DCT_SPRITE_EFFECT;

}
void DramaCommandSprite::excute()
{
	if (DCT_ADDSPRITE == m_kParam.type)
	{
		ExcuteAddSprite();
	}
	else if (DCT_ADDSPRITEBYFILE == m_kParam.type)
	{
		ExcuteAddSpriteByFile();
	}
	else if (DCT_REMOVESPRITE == m_kParam.type)
	{
		ExcuteRemoveSprite();
	}
	else if (DCT_SETSPRITEANI == m_kParam.type)
	{
		ExcuteSetAnimation();
	}
	else if (DCT_SETSPRITEPOS == m_kParam.type)
	{
		ExcuteSetPostion();
	}
	else if (DCT_MOVESPRITE == m_kParam.type)
	{
		ExcuteMoveSprite();
	}
	else if(DCT_SPRITE_EFFECT == m_kParam.type)
	{
		ExcuteSpriteEffect();
	}
	else if(DCT_SPRITE_REVERSE == m_kParam.type)
	{
		ExcuteSpriteReverse();
	}    
}

void DramaCommandSprite::ExcuteAddSprite()
{
	NDAsssert(DCT_ADDSPRITE == m_kParam.type);

	SetFinish(true);

	DramaScene* pkDramaScene = GetDramaScene();

	if (!pkDramaScene)
	{
		return;
	}

	switch (m_kParam.u2.nSpriteType) {
		case ST_PLAYER:
			pkDramaScene->AddManuRole(m_kParam.nKey, m_kParam.u1.nLookFace, m_kParam.u3.bFaceRight);
			break;
		case ST_NPC:
			pkDramaScene->AddNpc(m_kParam.nKey, m_kParam.u1.nLookFace, m_kParam.u3.bFaceRight);
			break;
		case ST_MONSTER:
			pkDramaScene->AddMonster(m_kParam.nKey, m_kParam.u1.nLookFace, m_kParam.u3.bFaceRight);
			break;
		default:
			break;
	}

	NDSprite* sprite = pkDramaScene->GetSprite(m_kParam.nKey);

	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
	{
		((NDBaseRole*) sprite)->m_strName = m_kParam.str;
	}
	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDMonster)))
	{
		//((NDMonster*)sprite)->SetNameColor(ccc4(0, 255, 0, 255));
	}
}

void DramaCommandSprite::ExcuteAddSpriteByFile()
{
	NDAsssert(DCT_ADDSPRITEBYFILE == m_kParam.type);

	SetFinish(true);

	DramaScene* pkDramaScene = GetDramaScene();

	if (!pkDramaScene)
	{
		return;
	}

	pkDramaScene->AddSprite(m_kParam.nKey, m_kParam.str);

	NDSprite* sprite = pkDramaScene->GetSprite(m_kParam.nKey);

	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
	{
		sprite->SetCurrentAnimation(0, false);
	}
}

void DramaCommandSprite::ExcuteRemoveSprite()
{
	NDAsssert(DCT_REMOVESPRITE == m_kParam.type);

	SetFinish(true);

	DramaScene* pkDramaScene = GetDramaScene();

	if (!pkDramaScene)
	{
		return;
	}

	pkDramaScene->RemoveSprite(m_kParam.u3.nTargetKey);
	DeAllocKey(m_kParam.u3.nTargetKey);
}

void DramaCommandSprite::ExcuteSetAnimation()
{
	NDAsssert(DCT_SETSPRITEANI == m_kParam.type);

	SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_kParam.u3.nTargetKey);

	if (!sprite)
	{
		return;
	}

	sprite->SetCurrentAnimation(m_kParam.u1.nAniIndex, sprite->IsReverse());
}

void DramaCommandSprite::ExcuteSetPostion()
{
	NDAsssert(DCT_SETSPRITEPOS == m_kParam.type);

	SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_kParam.u3.nTargetKey);
	if (!sprite)
	{
		return;
	}

	sprite->SetPosition(ccp(m_kParam.u1.nPosX, m_kParam.u2.nPoxY));
}

void DramaCommandSprite::ExcuteSpriteReverse()
{
	NDAsssert(DCT_SPRITE_REVERSE == m_kParam.type);
	SetFinish(true);
	DramaScene* dramaScene	= GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_kParam.nKey);
	if (!sprite)
	{
		return;
	}
	sprite->SetCurrentAnimation(0, m_kParam.u1.bReverse);
}

void DramaCommandSprite::ExcuteSpriteEffect()
{
	NDAsssert(DCT_SETSPRITEPOS == m_kParam.type);
	SetFinish(true);

	DramaScene* dramaScene	= GetDramaScene();
	if (!dramaScene)
	{
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_kParam.nKey);
}

void DramaCommandSprite::ExcuteMoveSprite()
{
	NDAsssert(DCT_MOVESPRITE == m_kParam.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		SetFinish(true);
		return;
	}

	NDSprite* sprite = dramaScene->GetSprite(m_kParam.nKey);
	if (!sprite)
	{
		SetFinish(true);
		return;
	}
	
	bool bRight   = false;
	bool bXArrive = false;
	bool bYArrive = false;
	CCPoint curPos = sprite->GetPosition();
	if (abs(int(curPos.x) - m_kParam.u1.nToPosX) <= m_kParam.u3.nMoveStep)
	{
		curPos.x = m_kParam.u1.nToPosX;
		bXArrive = true;
	}
	else if (int(curPos.x) > m_kParam.u1.nToPosX)
	{
		curPos.x -= m_kParam.u3.nMoveStep;
	}
	else if (int(curPos.x) < m_kParam.u1.nToPosX)
	{
		curPos.x += m_kParam.u3.nMoveStep;
		bRight = true;
	}

	if (abs(int(curPos.y) - m_kParam.u2.nToPosY) <= m_kParam.u3.nMoveStep)
	{
		curPos.y = m_kParam.u2.nToPosY;
		bYArrive = true;
	}
	else if (int(curPos.y) > m_kParam.u2.nToPosY)
	{
		curPos.y -= m_kParam.u3.nMoveStep;
	}
	else if (int(curPos.y) < m_kParam.u2.nToPosY)
	{
		curPos.y += m_kParam.u3.nMoveStep;
	}

	sprite->SetSpriteDir(bRight ? 0 : 2);
	sprite->SetCurrentAnimation(MANUELROLE_WALK, sprite->IsReverse());
	sprite->SetPosition(curPos);

	if (bXArrive && bYArrive)
	{
		sprite->SetCurrentAnimation(0, m_kParam.bRightTmp ? 2 : 0);
		SetFinish(true);
		return;
	}
	m_kParam.bRightTmp = bRight;
}

///////////////////////////////////////////////
void DramaCommandScene::InitWithLoadDrama(int nMapId)
{
    m_kParam.nKey = AllocKey();
	m_kParam.type = DCT_LOADMAPSCENE;
	m_kParam.u1.nMapId = nMapId;
}

void DramaCommandScene::InitWithFinishDrama()
{
	m_kParam.type = DCT_OVER;
}

void DramaCommandScene::InitWithLoad(std::string centerText, int nFontSize,
		int nFontColor)
{
	m_kParam.nKey = AllocKey();
	m_kParam.type = DCT_LOADERASESCENE;
	m_kParam.str = centerText;
	m_kParam.u2.nFontSize = nFontSize;
	m_kParam.u1.nFontColor = nFontColor;
}

void DramaCommandScene::InitWithRemove(int nKey)
{
	m_kParam.type = DCT_REMOVEERASESCENE;
	m_kParam.u3.nTargetKey = nKey;
}

void DramaCommandScene::excute()
{
	if (DCT_LOADMAPSCENE == m_kParam.type)
	{
		ExcuteLoadDramaScene();
	}
	else if (DCT_OVER == m_kParam.type)
	{
		ExcuteFinishDrama();
	}
	else if (DCT_LOADERASESCENE == m_kParam.type)
	{
		ExcuteLoadEraseScene();
	}
	else if (DCT_REMOVEERASESCENE == m_kParam.type)
	{
		ExcuteRemoveEraseScene();
	}
}

void DramaCommandScene::ExcuteLoadDramaScene()
{
	NDAsssert(DCT_LOADMAPSCENE == m_kParam.type);

	SetFinish(true);

	DramaScene* scene = new DramaScene;
	scene->Init(m_kParam.u1.nMapId);

	//pop上一个场景
	if(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(DramaScene)) != NULL )
	{
		NDDirector::DefaultDirector()->PopScene();
	} 

	NDDirector::DefaultDirector()->PushScene(scene);
}

void DramaCommandScene::ExcuteFinishDrama()
{
	NDAsssert(DCT_OVER == m_kParam.type);

	SetFinish(true);

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

	NDScene* pkRunScene = NULL;
	while ((pkRunScene = director->GetRunningScene()))
	{
		bool bfind = pkRunScene->IsKindOfClass(RUNTIME_CLASS(DramaScene));
		if (!director->PopScene(true) || bfind)
		{
			break;
		}
	}

#if 0
	//继续战斗
	if (BattleMgrObj.GetBattle() != NULL){
		ScriptMgrObj.excuteLuaFunc("DramaEnd", "Drama");
		BattleMgrObj.BattleContinue();
	}
#endif

	DramaCommandBase::ResetKeyAlloc();
}

void DramaCommandScene::ExcuteLoadEraseScene()
{
	NDAsssert(DCT_LOADERASESCENE == m_kParam.type);

	SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	DramaTransitionScene* scene = new DramaTransitionScene;
	scene->Init();
	scene->SetText(m_kParam.str, m_kParam.u2.nFontSize, m_kParam.u1.nFontColor);

	if (!dramaScene->PushScene(m_kParam.nKey, scene))
	{
		delete scene;
	}
}

void DramaCommandScene::ExcuteRemoveEraseScene()
{
	NDAsssert(DCT_REMOVEERASESCENE == m_kParam.type);

	SetFinish(true);

	DramaScene* pkDramaScene = GetDramaScene();

	if (!pkDramaScene)
	{
		return;
	}

	pkDramaScene->RemoveScene(m_kParam.u3.nTargetKey);
	DeAllocKey(m_kParam.u3.nTargetKey);
}

///////////////////////////////////////////////
void DramaCommandCamera::InitWithSetPos(int nPosX, int nPosY)
{
	m_kParam.type = DCT_SETCAMERA;
// 	m_kParam.u1.nPosX = nPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;//@del
// 	m_kParam.u2.nPoxY = nPosY * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET;
	m_kParam.u1.nPosX = ConvertUtil::convertCellToDisplayX(nPosX);
	m_kParam.u2.nPoxY = ConvertUtil::convertCellToDisplayY(nPosY);
}

void DramaCommandCamera::InitWithMove(int nToPosX, int nToPosY, int nStep)
{
	m_kParam.type = DCT_MOVECAMERA;
//	m_kParam.u1.nToPosX = nToPosX * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET;//@del
	m_kParam.u1.nToPosX = ConvertUtil::convertCellToDisplayX(nToPosX);
	m_kParam.u2.nToPosY = nToPosY * MAP_UNITSIZE;
	m_kParam.u3.nMoveStep = nStep;
}

void DramaCommandCamera::excute()
{
	if (DCT_SETCAMERA == m_kParam.type)
	{
		ExcuteSetPosition();
	}
	else if (DCT_MOVECAMERA == m_kParam.type)
	{
		ExcuteMovePostion();
	}
}

void DramaCommandCamera::ExcuteSetPosition()
{
	NDAsssert(DCT_SETCAMERA == m_kParam.type);

	SetFinish(true);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		return;
	}

	dramaScene->SetCenter(ccp(m_kParam.u1.nPosX, m_kParam.u2.nPoxY));
}

void DramaCommandCamera::ExcuteMovePostion()
{
	NDAsssert(DCT_MOVECAMERA == m_kParam.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		SetFinish(true);
		return;
	}

	bool bXArrive = false;
	bool bYArrive = false;
	CCPoint curPos = dramaScene->GetCenter();
	if (abs(int(curPos.x) - m_kParam.u1.nToPosX) <= m_kParam.u3.nMoveStep)
	{
		curPos.x = m_kParam.u1.nToPosX;
		bXArrive = true;
	}
	else if (int(curPos.x) > m_kParam.u1.nToPosX)
	{
		curPos.x -= m_kParam.u3.nMoveStep;
	}
	else if (int(curPos.x) < m_kParam.u1.nToPosX)
	{
		curPos.x += m_kParam.u3.nMoveStep;
	}

	if (abs(int(curPos.y) - m_kParam.u2.nToPosY) <= m_kParam.u3.nMoveStep)
	{
		curPos.y = m_kParam.u2.nToPosY;
		bYArrive = true;
	}
	else if (int(curPos.y) > m_kParam.u2.nToPosY)
	{
		curPos.y -= m_kParam.u3.nMoveStep;
	}
	else if (int(curPos.y) < m_kParam.u2.nToPosY)
	{
		curPos.y += m_kParam.u3.nMoveStep;
	}

	//越界判定
	bool bOverBoder = dramaScene->SetCenter(curPos);

	if ((bXArrive && bYArrive) || bOverBoder)
	{
		SetFinish(true);
	}
}

///////////////////////////////////////////////
#define TAG_TIME_WAIT (1)

void DramaCommandWait::InitWithWait(float fTime)
{
	m_kParam.type = DCT_WAITTIME;
	m_kParam.u1.fTime = fTime;
	m_kParam.u2.bTimeStart = false;
	m_kParam.u3.bTimeout = false;

	SetCanExcuteNextCommand(false);
}

void DramaCommandWait::InitWithWaitPreActionFinish()
{
	m_kParam.type = DCT_WAITPREACTFINISH;

	SetCanExcuteNextCommand(false);
}

void DramaCommandWait::InitWithWaitPreActFinishAndClick()
{
	m_kParam.type = DCT_WAITPREACTFINISHANDCLICK;

	SetCanExcuteNextCommand(false);
}

void DramaCommandWait::OnTimer(OBJID tag)
{
	if (TAG_TIME_WAIT != tag)
	{
		return;
	}

	m_kParam.u3.bTimeout = true;
	m_timer.KillTimer(this, TAG_TIME_WAIT);
}

void DramaCommandWait::excute()
{
	if (DCT_WAITTIME == m_kParam.type)
	{
		ExcuteWaitTime();
	}
	else if (DCT_WAITPREACTFINISH == m_kParam.type)
	{
		ExcuteWaitPreAction();
	}
	else if (DCT_WAITPREACTFINISHANDCLICK == m_kParam.type)
	{
		ExcuteWaitPreActionAndClick();
	}
}

void DramaCommandWait::ExcuteWaitTime()
{
	NDAsssert(DCT_WAITTIME == m_kParam.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene || m_kParam.u3.bTimeout)
	{
		SetFinish(true);
		SetCanExcuteNextCommand(true);
		return;
	}

	if (!m_kParam.u2.bTimeStart)
	{
		m_timer.SetTimer(this, TAG_TIME_WAIT, m_kParam.u1.fTime);

		m_kParam.u2.bTimeStart = true;
	}
}

void DramaCommandWait::ExcuteWaitPreAction()
{
	NDAsssert(DCT_WAITPREACTFINISH == m_kParam.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene || IsPreCommandsFinish())
	{
		SetFinish(true);
		SetCanExcuteNextCommand(true);
	}
	else
	{
		dramaScene->ConsumeClick();
	}
}

void DramaCommandWait::ExcuteWaitPreActionAndClick()
{
	NDAsssert(DCT_WAITPREACTFINISHANDCLICK == m_kParam.type);

	DramaScene* dramaScene = GetDramaScene();

	if (!dramaScene)
	{
		SetFinish(true);
		SetCanExcuteNextCommand(true);
	}

	if (!IsPreCommandsFinish())
	{
		dramaScene->ConsumeClick();
		return;
	}

	if (dramaScene->ConsumeClick())
	{
		SetFinish(true);
		SetCanExcuteNextCommand(true);
	}
}
//qbw音效播放
void DramaCommandSoundEffect::InitWithSoundEffectId(int nId)
{
	m_kParam.type			= DCT_SOUND_EFFECT;
	m_kParam.nKey			= nId;	
}
void DramaCommandSoundEffect::excute()
{
	ScriptMgrObj.excuteLuaFunc("PlayEffectSound", "Music", m_kParam.nKey);
	SetFinish(true);
	SetCanExcuteNextCommand(true);
}

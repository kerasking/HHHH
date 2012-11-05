/*
 *  DramaScene.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-19.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "DramaScene.h"
#include "NDDirector.h"
#include "NDTargetEvent.h"
#include "NDConstant.h"
#include "define.h"



class DramaMapLayer : public NDMapLayer
{
	DECLARE_CLASS(DramaMapLayer);
public:
	DramaMapLayer()						{}
	~DramaMapLayer()					{}
	bool TouchBegin(NDTouch* touch) override
	{
		DispatchClickOfViewr(this);
		return true;
	}
};
IMPLEMENT_CLASS(DramaMapLayer, NDMapLayer)

///////////////////////////////////////////////
IMPLEMENT_CLASS(DramaScene, NDScene)

DramaScene::DramaScene()
{
	m_layerMap = NULL;
	m_dlgConfirm = NULL;
	m_chatlayerLeft = NULL;
	m_chatlayerRight = NULL;
	m_bProductClick = false;
}

DramaScene::~DramaScene()
{
	if(m_layerMap != NULL)
	{
		delete (m_layerMap);
		m_layerMap = NULL;
	}
}

void DramaScene::Init(int nMapId)
{
	NDScene::Initialization();
	m_layerMap = new DramaMapLayer();
	m_layerMap->Initialization(nMapId); 
	m_layerMap->AddViewer(this);
	AddChild(m_layerMap, MAPLAYER_Z, MAPLAYER_TAG);
}

bool DramaScene::SetCenter(CGPoint pos)
{
	if (!m_layerMap)
	{
		return true;
	}

	return m_layerMap->SetScreenCenter(pos);
}

CGPoint DramaScene::GetCenter()
{
	if (!m_layerMap)
	{
		return CGPointZero;
	}

	return m_layerMap->GetScreenCenter();
}

bool DramaScene::AddMonster(int nKey, int nLookFace, bool bFaceRight/*=true*/)
{
	MAP_MONSTER_IT it = m_mapMonster.find(nKey);

	if (m_mapMonster.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddMonster m_mapMonster.end() != it lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	NDMonster* pkMonster = new NDMonster;
	//pkMonster->Initialization(nLookFace, nKey, 1, bFaceRight);
	if (!AddNodeToMap(pkMonster))
	{
		SAFE_DELETE(pkMonster);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddMonster !AddNodeToMap lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	m_mapMonster.insert(std::make_pair(nKey, pkMonster));

	return true;
}
bool DramaScene::AddNpc(int nKey, int nLookFace, bool bFaceRight/*=true*/)
{
	MAP_NPC_IT it = m_mapNpc.find(nKey);

	if (m_mapNpc.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddNpc m_mapNpc.end() != it lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	NDNpc *pkNPC = new NDNpc;
	//pkNPC->Initialization(nLookFace, bFaceRight);
	if (!AddNodeToMap(pkNPC))
	{
		delete pkNPC;
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddNpc !AddNodeToMap lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	m_mapNpc.insert(std::make_pair(nKey, pkNPC));

	return true;
}

bool DramaScene::AddManuRole(int nKey, int nLookFace, bool bFaceRight/*=true*/)
{
	MAP_MANUROLE_IT it = m_mapManuRole.find(nKey);

	if (m_mapManuRole.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddManuRole m_mapManuRole.end() != it lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	NDManualRole *pkRole = new NDManualRole;
	pkRole->Initialization(nLookFace, bFaceRight);
	if (!AddNodeToMap(pkRole))
	{
		delete pkRole;
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddManuRole !AddNodeToMap lookface[%d]key[%d]",
				nLookFace, nKey);
		return false;
	}

	m_mapManuRole.insert(std::make_pair(nKey, pkRole));

	return true;
}

bool DramaScene::AddSprite(int nKey, std::string filename, bool bFaceRight/*=true*/)
{
	MAP_SPRITE_IT it = m_mapSprite.find(nKey);

	if (m_mapSprite.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddSprite m_mapSprite.end() != it filename[%s]key[%d]",
				filename.c_str(), nKey);
		return false;
	}

	if (filename.empty())
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut("DramaScene::AddSprite filename.empty key[%d]",
				nKey);
		return false;
	}

	NDSprite *sprite = new NDSprite;
	//sprite->Initialization(filename.c_str(), bFaceRight);
	if (!AddNodeToMap(sprite))
	{
		delete sprite;
		ScriptMgrObj.DebugOutPut(
				"DramaScene::AddSprite !AddNodeToMap filename[%s]key[%d]",
				filename.c_str(), nKey);
		return false;
	}

	m_mapSprite.insert(std::make_pair(nKey, sprite));

	return true;
}

NDManualRole* DramaScene::GetManuRole(int nKey)
{
	MAP_MANUROLE_IT it = m_mapManuRole.find(nKey);

	if (m_mapManuRole.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDMonster* DramaScene::GetMonster(int nKey)
{
	MAP_MONSTER_IT it = m_mapMonster.find(nKey);

	if (m_mapMonster.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDNpc* DramaScene::GetNpc(int nKey)
{
	MAP_NPC_IT it = m_mapNpc.find(nKey);

	if (m_mapNpc.end() != it)
	{
		return it->second;
	}

	return NULL;
}

NDSprite* DramaScene::GetSprite(int nKey)
{
	MAP_SPRITE_IT it = m_mapSprite.find(nKey);

	if (m_mapSprite.end() != it)
	{
		return it->second;
	}

	NDSprite* pkSprite = GetManuRole(nKey);

	if (NULL != pkSprite)
	{
		return pkSprite;
	}

	pkSprite = GetMonster(nKey);

	if (NULL != pkSprite)
	{
		return pkSprite;
	}

	pkSprite = GetNpc(nKey);

	if (NULL != pkSprite)
	{
		return pkSprite;
	}

	return NULL;
}

bool DramaScene::RemoveSprite(int nKey)
{
	NDSprite* sprite = GetSprite(nKey);

	if (NULL == sprite)
	{
		return false;
	}

	return RemoveNode(sprite);
}

bool DramaScene::PushScene(int nKey, DramaTransitionScene* scene)
{
	if (!scene)
	{
		return false;
	}

	MAP_SCENE_IT it = m_mapScene.find(nKey);

	if (m_mapScene.end() != it)
	{
		NDAsssert(0);
		ScriptMgrObj.DebugOutPut(
				"DramaScene::PushScene m_mapScene.end() != it key[%d]", nKey);
		return false;
	}

	m_mapScene.insert(std::make_pair(nKey, scene->QueryLink()));

	NDDirector* pkDirector = NDDirector::DefaultDirector();
	if (!pkDirector)
	{
		return false;
	}

	pkDirector->PushScene(scene, true);

	return true;
}

DramaTransitionScene* DramaScene::GetScene(int nKey)
{
	MAP_SCENE_IT it = m_mapScene.find(nKey);

	if (m_mapScene.end() != it)
	{
		return it->second;
	}

	return NULL;
}

bool DramaScene::RemoveScene(int nKey)
{
	MAP_SCENE_IT it = m_mapScene.find(nKey);

	if (m_mapScene.end() == it)
	{
		return false;
	}

	DramaTransitionScene* scene = it->second;

	NDDirector* director = NDDirector::DefaultDirector();
	if (!director)
	{
		return false;
	}

	if (scene != director->GetRunningScene())
	{
		return false;
	}

	m_mapScene.erase(it);

	if (scene)
	{
		director->PopScene();
	}

	return true;
}

void DramaScene::OpenChat(bool bLeft)
{
	DramaChatLayer*& chat = bLeft ? m_chatlayerLeft : m_chatlayerRight;

	if (!chat)
	{
		if (bLeft)
		{
			chat = new DramaLeftChat;
		}
		else
		{
			chat = new DramaRightChat;
		}
		chat->Initialization();
		chat->SetTargetDelegate(this);
		AddChild(chat, 1);
	}
}

void DramaScene::CloseChat(bool bLeft)
{
	DramaChatLayer*& chat = bLeft ? m_chatlayerLeft : m_chatlayerRight;
	SAFE_DELETE_NODE(chat);
}

void DramaScene::SetChatFigure(bool bLeft, std::string filename, bool bReverse,int nCol, int nRow)
{
	DramaChatLayer*& chat = bLeft ? m_chatlayerLeft : m_chatlayerRight;
	if (!chat)
	{
		return;
	}
	chat->SetFigure(filename, bReverse, nCol,  nRow);
}

void DramaScene::SetChatTitle(bool bLeft, std::string title, int nFontSize,
		int nFontColor)
{
	DramaChatLayer*& chat = bLeft ? m_chatlayerLeft : m_chatlayerRight;
	if (!chat)
	{
		return;
	}
	chat->SetTitle(title, nFontSize, nFontColor);
}

void DramaScene::SetChatTitleBySpriteKey(bool bLeft, int nKey, int nFontSize,
		int nFontColor)
{
	std::string title = "";

	NDSprite* sprite = GetSprite(nKey);

	if (sprite && sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)))
	{
		title = ((NDBaseRole*) sprite)->m_strName;
	}

	SetChatTitle(bLeft, title, nFontSize, nFontColor);
}

void DramaScene::SetChatContent(bool bLeft, std::string content, int nFontSize,
		int nFontColor)
{
	DramaChatLayer*& chat = bLeft ? m_chatlayerLeft : m_chatlayerRight;
	if (!chat)
	{
		return;
	}
	chat->SetContent(content, nFontSize, nFontColor);
}

void DramaScene::ShowTipDlg(std::string content)
{
	if (!m_dlgConfirm)
	{
		m_dlgConfirm = new DramaConfirmdlg;
		m_dlgConfirm->Initialization();
		m_dlgConfirm->SetTargetDelegate(this);
		AddChild(m_dlgConfirm, 2);
	}

	m_dlgConfirm->SetContent(content);
}

bool DramaScene::ConsumeClick()
{
	if (!m_bProductClick)
	{
		return false;
	}

	m_bProductClick = false;

	return true;
}

///////////////////////////////////////////////
bool DramaScene::AddNodeToMap(NDNode* node)
{
	if (!m_layerMap || !node || NULL != node->GetParent())
	{
		return false;
	}

	m_layerMap->AddChild(node, 0, 0);

	return true;
}

bool DramaScene::RemoveNodeFromMap(NDNode* node)
{
	if (!m_layerMap || !node || node->GetParent() != m_layerMap)
	{
		return false;
	}

	m_layerMap->RemoveChild(node, true);

	return true;
}

bool DramaScene::RemoveNode(NDNode* node)
{
	bool bRet = RemoveSpriteNode(node);

	if (!bRet)
	{
		bRet = RemoveNpcNode(node);
	}

	if (!bRet)
	{
		bRet = RemoveManuroleNode(node);
	}

	if (!bRet)
	{
		bRet = RemoveMonsterNode(node);
	}

	return bRet;
}

bool DramaScene::RemoveSpriteNode(NDNode* node)
{
	bool bSucces = false;
	for (MAP_SPRITE_IT it = m_mapSprite.begin(); it != m_mapSprite.end(); it++)
	{
		if (node == it->second)
		{
			bSucces = RemoveNodeFromMap(node);

			if (bSucces)
			{
				m_mapSprite.erase(it);
			}

			return bSucces;
		}
	}

	return false;
}

bool DramaScene::RemoveNpcNode(NDNode* node)
{
	bool bSucces = false;
	for (MAP_NPC_IT it = m_mapNpc.begin(); it != m_mapNpc.end(); it++)
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

bool DramaScene::RemoveManuroleNode(NDNode* node)
{
	bool bSucces = false;
	for (MAP_MANUROLE_IT it = m_mapManuRole.begin();
		it != m_mapManuRole.end();it++)
	{
		if (node == it->second)
		{
			bSucces = RemoveNodeFromMap(node);

			if (bSucces)
			{
				m_mapManuRole.erase(it);
			}

			return bSucces;
		}
	}

	return false;
}

bool DramaScene::RemoveMonsterNode(NDNode* node)
{
	bool bSucces = false;
	for (MAP_MONSTER_IT it = m_mapMonster.begin(); it != m_mapMonster.end();
			it++)
	{
		if (node == it->second)
		{
			bSucces = RemoveNodeFromMap(node);

			if (bSucces)
			{
				m_mapMonster.erase(it);
			}

			return bSucces;
		}
	}

	return false;
}

void DramaScene::ProductClick()
{
	m_bProductClick = true;
}

bool DramaScene::OnTargetBtnEvent(NDUINode* uinode, int targetEvent)
{
	if (TE_TOUCH_BTN_CLICK != targetEvent)
	{
		return false;
	}

	if (uinode == m_chatlayerLeft || uinode == m_chatlayerRight
			|| uinode == m_dlgConfirm)
	{
		ProductClick();
		return true;
	}

	return false;
}

bool DramaScene::OnClick(NDObject* object) 
{ 
	if (object!= m_layerMap)
	{
		return false;
	}
	ProductClick();
	return true; 
}
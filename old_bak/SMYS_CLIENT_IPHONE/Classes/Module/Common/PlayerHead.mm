/*
 *  PlayerHead.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-16.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PlayerHead.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "ItemImage.h"
#include "NDMapMgr.h"
#include "GameScene.h"
#include "NDNpc.h"
#include "PlayerInfoScene.h"
#include "PetInfoScene.h"
#include "CGPointExtension.h"
#include "OtherPlayerInfoScene.h"
#include "CPet.h"

const CGRect RECT_MAP_HPMP = CGRectMake(0.0f, 0.0f, 124.0f, 43.0f);
const CGRect RECT_MAP_HP = CGRectMake(49.0f, 21.0f, 13.0f, 7.0f);
const CGRect RECT_MAP_MP = CGRectMake(49.0f, 31.0f, 13.0f, 7.0f);
const CGRect RECT_MAP_NUM_HP = CGRectMake(70.0f, 16.0f, 11.0f, 9.0f);
const CGRect RECT_MAP_NUM_MP = CGRectMake(70.0f, 27.0f, 11.0f, 9.0f);
const CGRect RECT_MAP_NUM_PLAYER_LEVEL = CGRectMake(45.0f, 9.0f, 10.0f, 6.0f);

const CGRect RECT_BATTLE_HPMP = CGRectMake(178.0f, 0.0f, 124.0f, 43.0f);
const CGRect RECT_BATTLE_HP = CGRectMake(227.0f, 21.0f, 13.0f, 7.0f);
const CGRect RECT_BATTLE_MP = CGRectMake(227.0f, 31.0f, 13.0f, 7.0f);
const CGRect RECT_BATTLE_NUM_HP = CGRectMake(248.0f, 16.0f, 11.0f, 9.0f);
const CGRect RECT_BATTLE_NUM_MP = CGRectMake(248.0f, 27.0f, 11.0f, 9.0f);
const CGRect RECT_BATTLE_NUM_PLAYER_LEVEL = CGRectMake(223.0f, 9.0f, 10.0f, 6.0f);

const float SHRINK_STEP = 3.0f;

IMPLEMENT_CLASS(HeadNode, NDNode)

HeadNode::HeadNode(NDManualRole* role, bool bBattle, bool drawInClipPos/*=false*/)
{
	m_role = role;
	m_bBattle = bBattle;
	m_drawInClipPos = drawInClipPos;
}

HeadNode::~HeadNode()
{
	
}

void HeadNode::SetRole(NDManualRole* role)
{
	m_role = role;
}

void HeadNode::draw()
{	
	if (!this->m_role) return;
	
	if (m_drawInClipPos)
	{
		drawOfClipPos();
		
		return;
	}
	
	CGRect rectClip = CGRectMake(0.0f, 0.0f, 320.0f, 36.0f);
	NDDirector::DefaultDirector()->SetViewRect(rectClip, this);
	CGPoint pos = m_bBattle ? CGPointMake(196.0f, 9.0f) : m_pos;
	this->m_role->DrawHead(pos);
}

void HeadNode::drawOfClipPos()
{
	if (!this->m_role) return;
	NDDirector::DefaultDirector()->SetViewRect(CGRectMake(m_pos.x, m_pos.y, 320.0f, 30.0f), this);
	CGPoint pos = m_bBattle ? CGPointMake(196.0f, 9.0f) : m_pos;
	this->m_role->DrawHead(pos);
}

IMPLEMENT_CLASS(PlayerHead, NDLayer)

PlayerHead::PlayerHead(NDManualRole* role)
{
	this->m_role = role;
	this->m_imgNumHp = NULL;
	this->m_imgNumMp = NULL;
	this->m_imgNumPlayerLevel = NULL;
	this->m_bBattle = false;
	this->m_player = NULL;
	this->m_imgHp = NULL;
	this->m_imgMp = NULL;
}

PlayerHead::~PlayerHead()
{
}

void PlayerHead::Initialization(bool bBattle)
{
	this->m_bBattle = bBattle;
	
	NDLayer::Initialization();
	
	NDUIImage* imgPlayerHeadBg = new NDUIImage;
	imgPlayerHeadBg->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("rolebackground.png"));

	imgPlayerHeadBg->SetPicture(pic, true);
	imgPlayerHeadBg->SetFrameRect(m_bBattle ? RECT_BATTLE_HPMP : RECT_MAP_HPMP);
	this->AddChild(imgPlayerHeadBg);
	
	m_imgHp = new NDUIImage;
	m_imgHp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("hp_block.png"), 0, 0);
	m_imgHp->SetPicture(pic, true);
	this->AddChild(m_imgHp);
	
	m_imgMp = new NDUIImage;
	m_imgMp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("mp_block.png"), 0, 0);
	m_imgMp->SetPicture(pic, true);
	this->AddChild(m_imgMp);
	
	this->m_imgNumHp = new ImageNumber;
	m_imgNumHp->Initialization();
	m_imgNumHp->SetFrameRect(m_bBattle ? RECT_BATTLE_NUM_HP : RECT_MAP_NUM_HP);
	this->AddChild(m_imgNumHp);
	
	this->m_imgNumMp = new ImageNumber;
	m_imgNumMp->Initialization();
	m_imgNumMp->SetFrameRect(m_bBattle ? RECT_BATTLE_NUM_MP : RECT_MAP_NUM_MP);
	this->AddChild(m_imgNumMp);
	
	this->m_imgNumPlayerLevel = new ImageNumber;
	m_imgNumPlayerLevel->Initialization();
	m_imgNumPlayerLevel->SetFrameRect(m_bBattle ? RECT_BATTLE_NUM_PLAYER_LEVEL : RECT_MAP_NUM_PLAYER_LEVEL);
	m_imgNumPlayerLevel->SetSmallGoldNumber(m_role->level);
	this->AddChild(m_imgNumPlayerLevel);
	
	NDUIImage* imgPlayerHp = new NDUIImage;
	imgPlayerHp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("battlehp.png"));
	imgPlayerHp->SetPicture(pic, true);
	imgPlayerHp->SetFrameRect(m_bBattle ? RECT_BATTLE_HP : RECT_MAP_HP);
	this->AddChild(imgPlayerHp);
	
	NDUIImage* imgPlayerMp = new NDUIImage;
	imgPlayerMp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("battlemp.png"));
	imgPlayerMp->SetPicture(pic, true);
	imgPlayerMp->SetFrameRect(m_bBattle ? RECT_BATTLE_MP : RECT_MAP_MP);
	this->AddChild(imgPlayerMp);
	
	HeadNode* head = new HeadNode(m_role, bBattle);
	head->Initialization();
	this->AddChild(head);
}

/*void PlayerHead::InitPet()
{
	this->m_imgNumPetLevel = new ImageNumber;
	m_imgNumPetLevel->Initialization();
	m_imgNumPetLevel->SetFrameRect(this->m_bBattle ? RECT_BATTLE_NUM_PET_LEVEL : RECT_MAP_NUM_PET_LEVEL);
	this->AddChild(m_imgNumPetLevel);
	
	this->m_picPet = ItemImage::GetItem(20);
}*/

void PlayerHead::draw()
{
	if (this->m_bBattle) {
		this->drawInBattle();
	} else {
		this->drawInMap();
	}
}

void PlayerHead::drawInBattle()
{
	if (!this->m_player) {
		return;
	}
	
	this->m_imgNumHp->SetSmallRedNumber(this->m_player->m_info.nLife);
	this->m_imgNumMp->SetSmallRedNumber(this->m_player->m_info.nMana);
	
	GLfloat width = 53.0f * this->m_player->m_info.nLife / this->m_player->m_info.nLifeMax;
	width = width > 53.0f ? 53.0f : width;
	this->m_imgHp->SetFrameRect(CGRectMake(243.0f, 23.0f, width, 3.0f));
	
	width = 53.0f * this->m_player->m_info.nMana / this->m_player->m_info.nManaMax;
	width = width > 53.0f ? 53.0f : width;
	this->m_imgMp->SetFrameRect(CGRectMake(243.0f, 33.0f, width, 3.0f));
	
	/*drawRectBar2(195, 15, 0xC7321A, this->m_player->m_info.nLife, this->m_role.maxLife, 50);
	drawRectBar2(195, 25, 0x3C4ACF, this->m_player->m_info.nMana, this->m_role.maxMana, 50);
	
	this->m_imgNumHp->SetSmallRedNumber(this->m_player->m_info.nLife);
	this->m_imgNumMp->SetSmallRedNumber(this->m_player->m_info.nMana);
	
	int width = 75;
	
	DrawRecttangle(CGRectMake(178.0f, 33.0f, 63.0f, 3.0f), INTCOLORTOCCC4(0x1C5555));
	DrawLine(CGPointMake(166.0f, 37.0f), CGPointMake(245.0f, 37.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawLine(CGPointMake(241.0f, 33.0f), CGPointMake(246.0f, 33.0f), INTCOLORTOCCC4(0x6C9E9B), 1);
	DrawRecttangle(CGRectMake(242.0f, 34.0f, 5.0f, 3.0f), INTCOLORTOCCC4(0x1C5555));
	
	DrawLine(CGPointMake(241.0f, 32.0f), CGPointMake(245.0f, 32.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawLine(CGPointMake(246.0f, 33.0f), CGPointMake(246.0f, 33.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawPolygon(CGRectMake(242.0f, 34.0f, 2.0f, 3.0f), INTCOLORTOCCC4(0x0B2212), 1);
	
	DrawRecttangle(CGRectMake(178.0f, 34.0f, 63.0f, 2.0f), INTCOLORTOCCC4(0x6C9E9B));
	
	int expWidth = this->m_role.exp * (width - 12) / this->m_role.lvUpExp;
	if(this->m_role.exp > this->m_role.lvUpExp){
		expWidth = width - 12;
	}
	DrawRecttangle(CGRectMake(178.0f, 34.0f, expWidth, 2.0f), INTCOLORTOCCC4(0xEDE282));
	
	// 绘制宠物
	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
	if (this->m_role.battlepet && this->m_role.battlepet->m_id == petData.int_PET_ID) {
		if (this->m_bPetOk) {
			if (!this->m_pet) {
				return;
			}
			
			this->m_imgNumPetLevel->SetSmallRedNumber(petData.int_PET_ATTR_LEVEL);
			DrawRecttangle(RECT_BATTLE_PET, INTCOLORTOCCC4(0x525252));
			
			DrawPolygon(RECT_BATTLE_PET, INTCOLORTOCCC4(0), 1);
			
			this->m_picPet->DrawInRect(RECT_BATTLE_PET);
			
			drawRectBar2(268.0f, 14.0f, 0xDA7132, this->m_pet->m_info.nLife,
				     petData.int_PET_ATTR_MAX_LIFE, 40);
			
			drawRectBar2(268.0f, 19.0f, 0x2D42CB, this->m_pet->m_info.nMana,
				     petData.int_PET_ATTR_MAX_MANA, 40);
			
			drawRectBar2(268.0f, 24.0f, 0xC5A91C, petData.int_PET_ATTR_EXP,
				     petData.int_PET_ATTR_LEVEUP_EXP, 40);
		} else {
			this->InitPet();
		}
	}*/
}

void PlayerHead::drawInMap()
{
	//drawRectBar2(53, 16, 0xC7321A, this->m_role.life, this->m_role.maxLife, 50);
	//drawRectBar2(53, 26, 0x3C4ACF, this->m_role.mana, this->m_role.maxMana, 50);
	this->m_imgNumPlayerLevel->SetSmallGoldNumber(this->m_role->level);
	this->m_imgNumHp->SetSmallRedNumber(this->m_role->life);
	this->m_imgNumMp->SetSmallRedNumber(this->m_role->mana);
	
	GLfloat width = 53.0f * this->m_role->life / this->m_role->maxLife;
	this->m_imgHp->SetFrameRect(CGRectMake(65.0f, 23.0f, width, 3.0f));
	
	width = 53.0f * this->m_role->mana / this->m_role->maxMana;
	this->m_imgMp->SetFrameRect(CGRectMake(65.0f, 33.0f, width, 3.0f));
	
	/*int width = 75;
	
	DrawRecttangle(CGRectMake(36, 34, 63, 3), INTCOLORTOCCC4(0x1C5555));
	DrawLine(CGPointMake(24.0f, 38.0f), CGPointMake(103.0f, 38.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawLine(CGPointMake(99.0f, 34.0f), CGPointMake(104.0f, 34.0f), INTCOLORTOCCC4(0x6C9E9B), 1);
	DrawRecttangle(CGRectMake(100.0f, 35.0f, 5.0f, 3.0f), INTCOLORTOCCC4(0x1C5555));
	
	DrawLine(CGPointMake(99.0f, 33.0f), CGPointMake(103.0f, 33.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawLine(CGPointMake(104.0f, 34.0f), CGPointMake(104.0f, 37.0f), INTCOLORTOCCC4(0x0B2212), 1);
	DrawPolygon(CGRectMake(100.0f, 35.0f, 2.0f, 3.0f), INTCOLORTOCCC4(0x0B2212), 1);
	
	DrawRecttangle(CGRectMake(36.0f, 35.0f, 63.0f, 2.0f), INTCOLORTOCCC4(0x6C9E9B));
	
	int expWidth = this->m_role.exp * (width - 12) / this->m_role.lvUpExp;
	if(this->m_role.exp > this->m_role.lvUpExp){
		expWidth = width - 12;
	}
	DrawRecttangle(CGRectMake(36, 35, expWidth, 2), INTCOLORTOCCC4(0xEDE282));*/
	
	// 绘制宠物
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		GameScene* gameScene = (GameScene*)scene;
		
		PetInfo* petInfo = PetMgrObj.GetShowPet(NDPlayer::defaultHero().m_id);
		
		gameScene->ShowPetHead(petInfo != NULL);
	}
}

//////////////////////////////////////////////////////////////////////////
const CGRect RECT_MAP_HPMP_PET = CGRectMake(126.0f, 3.0f, 93.0f, 26.0f);
const CGRect RECT_MAP_HP_PET = CGRectMake(154.0f, 8.0f, 13.0f, 7.0f);
const CGRect RECT_MAP_MP_PET = CGRectMake(154.0f, 18.0f, 13.0f, 7.0f);
//const CGRect RECT_MAP_NUM_HP_PET = CGRectMake(183.0f, 15.0f, 11.0f, 9.0f);
//const CGRect RECT_MAP_NUM_MP_PET = CGRectMake(183.0f, 27.0f, 11.0f, 9.0f);
//const CGRect RECT_MAP_NUM_PLAYER_LEVEL_PET = CGRectMake(160.0f, 8.0f, 10.0f, 6.0f);
const CGRect RECT_MAP_PET_HEAD = CGRectMake(133.0f, 8.0f, 16.0f, 16.0f);

const CGRect RECT_BATTLE_HPMP_PET = CGRectMake(209.0f, 38.0f, 93.0f, 26.0f);
const CGRect RECT_BATTLE_HP_PET = CGRectMake(237.0f, 43.0f, 13.0f, 7.0f);
const CGRect RECT_BATTLE_MP_PET = CGRectMake(237.0f, 53.0f, 13.0f, 7.0f);
//const CGRect RECT_BATTLE_NUM_HP_PET = CGRectMake(250.0f, 57.0f, 11.0f, 9.0f);
//const CGRect RECT_BATTLE_NUM_MP_PET = CGRectMake(250.0f, 69.0f, 11.0f, 9.0f);
//const CGRect RECT_BATTLE_NUM_PLAYER_LEVEL_PET = CGRectMake(224.0f, 50.0f, 10.0f, 6.0f);
const CGRect RECT_BATTLE_PET_HEAD = CGRectMake(216.0f, 42.0f, 16.0f, 16.0f);

IMPLEMENT_CLASS(PetHead, NDLayer)

PetHead::PetHead()
{
	this->m_pet = NULL;
	//this->m_battlepet = NULL;
	
	/*this->m_imgNumHp = NULL;
	this->m_imgNumMp = NULL;
	this->m_imgNumLevel = NULL;*/
	
	this->m_imgHp = NULL;
	this->m_imgMp = NULL;
}

PetHead::~PetHead()
{
	
}

void PetHead::Initialization(Fighter* pet)
{
	NDLayer::Initialization();
	
	this->m_pet = pet;
	//this->m_battlepet = NDPlayer::defaultHero().battlepet;
	//PetInfo* petInfo = PetMgrObj.GetPetWithPos(NDPlayer::defaultHero().m_id, PET_POSITION_MAIN);
	//if (!petInfo || !this->m_battlepet) {
	//	return;
	//}
	
	//PetInfo::PetData& petData = petInfo->data;
	
	bool bBattle = pet != NULL;
	NDUIImage* imgHeadBg = new NDUIImage;
	imgHeadBg->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("eudemonbackground.png"));
	imgHeadBg->SetPicture(pic, true);
	imgHeadBg->SetFrameRect(bBattle ? RECT_BATTLE_HPMP_PET : RECT_MAP_HPMP_PET);
	this->AddChild(imgHeadBg);
	
	m_imgHp = new NDUIImage;
	m_imgHp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("hp_block.png"), 0, 0);
	m_imgHp->SetPicture(pic, true);
	this->AddChild(m_imgHp);
	
	m_imgMp = new NDUIImage;
	m_imgMp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("mp_block.png"), 0, 0);
	m_imgMp->SetPicture(pic, true);
	this->AddChild(m_imgMp);
	
	/*this->m_imgNumHp = new ImageNumber;
	m_imgNumHp->Initialization();
	m_imgNumHp->SetFrameRect(bBattle ? RECT_BATTLE_NUM_HP_PET : RECT_MAP_NUM_HP_PET);
	this->AddChild(m_imgNumHp);
	
	this->m_imgNumMp = new ImageNumber;
	m_imgNumMp->Initialization();
	m_imgNumMp->SetFrameRect(bBattle ? RECT_BATTLE_NUM_MP_PET : RECT_MAP_NUM_MP_PET);
	this->AddChild(m_imgNumMp);
	
	this->m_imgNumLevel = new ImageNumber;
	m_imgNumLevel->Initialization();
	m_imgNumLevel->SetFrameRect(bBattle ? RECT_BATTLE_NUM_PLAYER_LEVEL_PET : RECT_MAP_NUM_PLAYER_LEVEL_PET);
	m_imgNumLevel->SetSmallGoldNumber(petData.int_PET_ATTR_LEVEL);
	this->AddChild(m_imgNumLevel);*/
	
	NDUIImage* imgHp = new NDUIImage;
	imgHp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("battlehp.png"));
	imgHp->SetPicture(pic, true);
	imgHp->SetFrameRect(bBattle ? RECT_BATTLE_HP_PET : RECT_MAP_HP_PET);
	this->AddChild(imgHp);
	
	NDUIImage* imgMp = new NDUIImage;
	imgMp->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("battlemp.png"));
	imgMp->SetPicture(pic, true);
	imgMp->SetFrameRect(bBattle ? RECT_BATTLE_MP_PET : RECT_MAP_MP_PET);
	this->AddChild(imgMp);
	
	pic = ItemImage::GetItem(20);
	NDUIImage* imgPetHead = new NDUIImage;
	imgPetHead->Initialization();
	imgPetHead->SetPicture(pic);
	imgPetHead->SetFrameRect(bBattle ? RECT_BATTLE_PET_HEAD : RECT_MAP_PET_HEAD);
	this->AddChild(imgPetHead);
}

void PetHead::draw()
{
	if (m_pet) {
		this->drawInBattle();
	} else {
		this->drawInMap();
	}
}

void PetHead::drawInMap()
{
	PetInfo* petInfo = PetMgrObj.GetShowPet(NDPlayer::defaultHero().m_id);
	if (!petInfo) {
		return;
	}
	
	PetInfo::PetData& petData = petInfo->data;
	
	/*this->m_imgNumLevel->SetSmallGoldNumber(petData.int_PET_ATTR_LEVEL);
	this->m_imgNumHp->SetSmallRedNumber(petData.int_PET_ATTR_LIFE);
	this->m_imgNumMp->SetSmallRedNumber(petData.int_PET_ATTR_MANA);*/
	
	GLfloat width = 44.0f * petData.int_PET_ATTR_LIFE / petData.int_PET_ATTR_MAX_LIFE;
	this->m_imgHp->SetFrameRect(CGRectMake(170.0f, 10.0f, width, 3.0f));
	
	width = 44.0f * petData.int_PET_ATTR_MANA / petData.int_PET_ATTR_MAX_MANA;
	this->m_imgMp->SetFrameRect(CGRectMake(170.0f, 20.0f, width, 3.0f));
}

void PetHead::drawInBattle()
{
	/*this->m_imgNumHp->SetSmallRedNumber(this->m_pet->m_info.nLife);
	this->m_imgNumMp->SetSmallRedNumber(this->m_pet->m_info.nMana);*/
	
	GLfloat width = 44.0f * this->m_pet->m_info.nLife / this->m_pet->m_info.nLifeMax;
	if (this->m_imgHp)
		this->m_imgHp->SetFrameRect(CGRectMake(253.0f, 45.0f, width, 3.0f));
	
	width = 44.0f * this->m_pet->m_info.nMana / this->m_pet->m_info.nManaMax;
	
	if (this->m_imgMp)
		this->m_imgMp->SetFrameRect(CGRectMake(253.0f, 55.0f, width, 3.0f));
}

//////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PlayerHeadInMap, NDUILayer)

const CGRect RECT_PLAYER_HEAD_IN_MAP = CGRectMake(30.0f, 0.0f, 87.0f, 40.0f);
const CGRect RECT_PLAYER_HEAD_IN_MAP_LEVEL = CGRectMake(36.0f, 5.0f, 10.0f, 6.0f);

const CGRect RECT_PLAYER_HEAD_HIDE = CGRectMake(-87.0f, 0.0f, 87.0f, 40.0f);
const CGRect RECT_PLAYER_HEAD_HIDE_WITH_PET = CGRectMake(-176.0f, 0.0f, 87.0f, 40.0f);

const CGRect RECT_PET_HEAD_IN_MAP = CGRectMake(118.0f, 0.0f, 87.0f, 40.0f);
const CGRect RECT_PET_HEAD_IN_MAP_LEVEL = CGRectMake(36.0f, 5.0f, 10.0f, 6.0f);
const CGRect RECT_PET_HEAD_HEAD_IN_MAP = CGRectMake(11.0f, 9.0f, 22.0f, 22.0f);

const CGPoint PT_PLAYER_HEAD_IN_MAP = CGPointMake(38.0f, 7.0f);
const CGPoint PT_PLAYER_HEAD_HIDE = CGPointMake(-75.0f, 7.0f);
const CGPoint PT_PLAYER_HEAD_HIDE_WITH_PET = CGPointMake(-164.0f, 7.0f);

PlayerHeadInMap::PlayerHeadInMap(NDPlayer* role)
{
	m_rectBase = RECT_PLAYER_HEAD_IN_MAP;
	this->m_role= role;
	//this->m_battlepet = NULL;
	this->m_imgNumPlayerLevel = NULL;
	this->m_imgHp = NULL;
	this->m_imgMp = NULL;
	this->m_imgExp = NULL;
}

PlayerHeadInMap::PlayerHeadInMap(NDBattlePet *battlepet)
{
	m_rectBase = RECT_PET_HEAD_IN_MAP;
	this->m_role = NULL;
	if (battlepet)
		this->m_battlepet = battlepet->QueryLink();
	this->m_imgNumPlayerLevel = NULL;
	this->m_imgHp = NULL;
	this->m_imgMp = NULL;
	this->m_imgExp = NULL;
}

PlayerHeadInMap::~PlayerHeadInMap()
{
	
}

void PlayerHeadInMap::ChangeBattlePet(NDBattlePet *battlepet)
{
	if (battlepet)
		this->m_battlepet = battlepet->QueryLink();
	else
		this->m_battlepet.Clear();
}

void PlayerHeadInMap::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(m_rectBase);
	
	this->m_showStatus = SS_SHOW;
	
	if (m_role) {
		m_ptHeadNode = PT_PLAYER_HEAD_IN_MAP;
		
		NDUIImage* imgPlayerHeadJoint = new NDUIImage;
		imgPlayerHeadJoint->Initialization();
		NDPicture* pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("scenehandletorole.png"));
		
		imgPlayerHeadJoint->SetPicture(pic, true);
		imgPlayerHeadJoint->SetFrameRect(CGRectMake(-10.0f, 10.0f, 15.0f, 20.0f));
		this->AddChild(imgPlayerHeadJoint);
		
		NDUIImage* imgPlayerHeadBg = new NDUIImage;
		imgPlayerHeadBg->Initialization();
		pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("scenerolebg.png"));
		
		imgPlayerHeadBg->SetPicture(pic, true);
		imgPlayerHeadBg->SetFrameRect(CGRectMake(0.0f, 0.0f, m_rectBase.size.width, m_rectBase.size.height));
		this->AddChild(imgPlayerHeadBg);
		
		m_imgHp = new NDUIImage;
		m_imgHp->Initialization();
		pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("hp_block.png"), 0, 0);
		m_imgHp->SetPicture(pic, true);
		this->AddChild(m_imgHp);
		
		m_imgMp = new NDUIImage;
		m_imgMp->Initialization();
		pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("mp_block.png"), 0, 0);
		m_imgMp->SetPicture(pic, true);
		this->AddChild(m_imgMp);
		
		m_imgExp = new NDUILayer;
		m_imgExp->Initialization();
		m_imgExp->SetBackgroundColor(ccc4(200, 200, 0, 255));
		this->AddChild(m_imgExp);
		
		this->m_imgNumPlayerLevel = new ImageNumber;
		m_imgNumPlayerLevel->Initialization();
		m_imgNumPlayerLevel->SetFrameRect(RECT_PLAYER_HEAD_IN_MAP_LEVEL);
		m_imgNumPlayerLevel->SetSmallGoldNumber(m_role->level);
		this->AddChild(m_imgNumPlayerLevel);
		
		m_head = new HeadNode(m_role, false);
		m_head->Initialization();
		this->AddChild(m_head);
	} else if (m_battlepet) {
	
		PetInfo* petInfo = PetMgrObj.GetShowPet(NDPlayer::defaultHero().m_id);
		if (!petInfo) {
			return;
		}
		
		PetInfo::PetData& petData = petInfo->data;
		
		if (this->m_battlepet->m_id != petData.int_PET_ID) {
			return;
		}
		
		NDUIImage* imgHeadBg = new NDUIImage;
		imgHeadBg->Initialization();
		NDPicture* pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("scenerolebg.png"));
		imgHeadBg->SetPicture(pic, true);
		imgHeadBg->SetFrameRect(CGRectMake(0.0f, 0.0f, m_rectBase.size.width, m_rectBase.size.height));
		this->AddChild(imgHeadBg);
		
		m_imgHp = new NDUIImage;
		m_imgHp->Initialization();
		pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("hp_block.png"), 0, 0);
		m_imgHp->SetPicture(pic, true);
		this->AddChild(m_imgHp);
		
		m_imgMp = new NDUIImage;
		m_imgMp->Initialization();
		pic = new NDPicture;
		pic->Initialization(GetImgPathBattleUI("mp_block.png"), 0, 0);
		m_imgMp->SetPicture(pic, true);
		this->AddChild(m_imgMp);
		
		m_imgExp = new NDUILayer;
		m_imgExp->Initialization();
		m_imgExp->SetBackgroundColor(ccc4(200, 200, 0, 255));
		this->AddChild(m_imgExp);
		
		this->m_imgNumPlayerLevel = new ImageNumber;
		m_imgNumPlayerLevel->Initialization();
		m_imgNumPlayerLevel->SetFrameRect(RECT_PET_HEAD_IN_MAP_LEVEL);
		m_imgNumPlayerLevel->SetSmallGoldNumber(petData.int_PET_ATTR_LEVEL);
		this->AddChild(m_imgNumPlayerLevel);
		
		pic = ItemImage::GetItem(20);
		NDUIImage* imgPetHead = new NDUIImage;
		imgPetHead->Initialization();
		imgPetHead->SetPicture(pic);
		imgPetHead->SetFrameRect(RECT_PET_HEAD_HEAD_IN_MAP);
		this->AddChild(imgPetHead);
	}
}

const float SHRINK_RATE = 20.0f;

void PlayerHeadInMap::draw()
{
	switch (this->m_showStatus) {
		case SS_HIDE:
			return;
			break;
		case SS_SHRINKING:
		{
			CGRect rect = this->GetFrameRect();
			rect.origin.x -= SHRINK_RATE;
			m_ptHeadNode.x -= SHRINK_RATE;
			
			// 是否收缩完成
			if (rect.origin.x <= this->m_rectHide.origin.x) {
				this->SetFrameRect(this->m_rectHide);
				m_ptHeadNode = m_bHasBattlepet ? PT_PLAYER_HEAD_HIDE_WITH_PET : PT_PLAYER_HEAD_HIDE;
				this->m_showStatus = SS_HIDE;
			} else {
				this->SetFrameRect(rect);
			}
		}
			break;
		case SS_EXTENDING:
		{
			CGRect rect = this->GetFrameRect();
			rect.origin.x += SHRINK_RATE;
			m_ptHeadNode.x += SHRINK_RATE;
			
			// 是否展开完成
			if (rect.origin.x >= this->m_rectBase.origin.x) {
				this->SetFrameRect(this->m_rectBase);
				m_ptHeadNode = PT_PLAYER_HEAD_IN_MAP;
				this->m_showStatus = SS_SHOW;
			} else {
				this->SetFrameRect(rect);
			}
		}
			break;
		default:
			break;
	}
	
	if (m_role) {
		m_head->SetPos(m_ptHeadNode);
		
		this->m_imgNumPlayerLevel->SetSmallGoldNumber(this->m_role->level);
		
		GLfloat width = 39.0f * min(1.f, (float)this->m_role->life / this->m_role->maxLife);
		this->m_imgHp->SetFrameRect(CGRectMake(41.0f, 17.0f, width, 3.0f));
		
		width = 39.0f * min(1.f, (float)this->m_role->mana / this->m_role->maxMana);
		this->m_imgMp->SetFrameRect(CGRectMake(39.0f, 25.0f, width, 3.0f));
		
		width = 39.0f * min(1.f, (float)this->m_role->exp / this->m_role->lvUpExp);
		this->m_imgExp->SetFrameRect(CGRectMake(34.0f, 33.0f, width, 3.0f));
		
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			GameScene* gameScene = (GameScene*)scene;
			
			PetInfo* petInfo = PetMgrObj.GetShowPet(NDPlayer::defaultHero().m_id);
			gameScene->ShowPetHead(petInfo != NULL);
		}
	} else if (m_battlepet) {
		PetInfo* petInfo = PetMgrObj.GetShowPet(NDPlayer::defaultHero().m_id);
		if (!petInfo || !this->m_battlepet) {
			return;
		}
		
		PetInfo::PetData& petData = petInfo->data;
		
		this->m_imgNumPlayerLevel->SetSmallGoldNumber(petData.int_PET_ATTR_LEVEL);
		
		GLfloat width = 39.0f * petData.int_PET_ATTR_LIFE / petData.int_PET_ATTR_MAX_LIFE;
		this->m_imgHp->SetFrameRect(CGRectMake(41.0f, 17.0f, width, 3.0f));
		
		width = 39.0f * petData.int_PET_ATTR_MANA / petData.int_PET_ATTR_MAX_MANA;
		this->m_imgMp->SetFrameRect(CGRectMake(39.0f, 25.0f, width, 3.0f));
		
		width = 39.0f * petData.int_PET_ATTR_EXP / petData.int_PET_ATTR_LEVEUP_EXP;
		this->m_imgExp->SetFrameRect(CGRectMake(34.0f, 33.0f, width, 3.0f));
	}
}

void PlayerHeadInMap::SetShrink(bool bShrink)
{
	switch (this->m_showStatus) {
		case SS_SHOW:
		case SS_EXTENDING:
			m_showStatus = SS_SHRINKING;
			break;
		case SS_HIDE:
		case SS_SHRINKING:
			m_showStatus = SS_EXTENDING;
			break;
		default:
			break;
	}
	
	if (m_role) {
		if (m_bHasBattlepet) {
			this->m_rectHide = RECT_PLAYER_HEAD_HIDE_WITH_PET;
		} else {
			this->m_rectHide = RECT_PLAYER_HEAD_HIDE;
		}
	} else if (m_battlepet) {
		this->m_rectHide = RECT_PLAYER_HEAD_HIDE;
	}
}

bool PlayerHeadInMap::TouchEnd(NDTouch* touch)
{
	if (this->m_showStatus != SS_SHOW) {
		return false;
	}
	
	if (m_role != NULL)
	{
		NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) {
			PlayerInfoScene* scene = PlayerInfoScene::Scene(); 
			NDDirector::DefaultDirector()->PushScene(scene);
			scene->SetTabFocusOnIndex(0, true);
		}
		return true;
	}
	
	if (m_battlepet != NULL)
	{
	#pragma mark todo
		//NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
//		if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(PetInfoScene))) {
//			PetInfoScene* scene = PetInfoScene::Scene(); 
//			NDDirector::DefaultDirector()->PushScene(scene);
//			scene->SetTabFocusOnIndex(0, true);
//		}
		NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) {
			PlayerInfoScene* scene = PlayerInfoScene::Scene(); 
			NDDirector::DefaultDirector()->PushScene(scene);
			scene->SetTabFocusOnIndex(3, true);
		}
		
		return true;
	}
	
	
	return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////
const CGPoint POINT_TARGET_HEAD = CGPointMake(218.0f, 8.0f);

IMPLEMENT_CLASS(TargetHeadNode, NDNode)

TargetHeadNode::TargetHeadNode()
{
	m_bNpc = false;
	m_idRole = ID_NONE;
}

TargetHeadNode::~TargetHeadNode()
{
	
}

void TargetHeadNode::draw()
{
	CGRect rectClip = CGRectMake(160.0f, 0.0f, 320.0f, 36.0f);
	NDDirector::DefaultDirector()->SetViewRect(rectClip, this);
	
	if (m_bNpc) {
		NDNpc* npc = NDMapMgrObj.GetNpcByID(m_idRole);
		if (npc) {
			npc->DrawHead(POINT_TARGET_HEAD);
		}
	} else {
		NDManualRole* role = NDMapMgrObj.GetManualRole(m_idRole);
		if (role) {
			role->DrawHead(POINT_TARGET_HEAD);
		}
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(TargetHeadInMap, NDUILayer)

TargetHeadInMap::TargetHeadInMap()
{
	this->m_imgNumPlayerLevel = NULL;
	m_imgHp = NULL;
	m_imgMp = NULL;
	m_head = NULL;
	m_idRole = ID_NONE;
	m_imgHead = NULL;
	m_bNpc = false;
}

TargetHeadInMap::~TargetHeadInMap()
{
	if (m_imgNumPlayerLevel && m_imgNumPlayerLevel->GetParent() == NULL) {
		SAFE_DELETE(m_imgNumPlayerLevel);
	}
	
	if (m_head && m_head->GetParent() == NULL) {
		SAFE_DELETE(m_head);
	}
	
	if (m_imgHead && m_imgHead->GetParent() == NULL) {
		SAFE_DELETE(m_imgHead);
	}
}

void TargetHeadInMap::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgHeadBg = new NDUIImage;
	imgHeadBg->Initialization();
	NDPicture* pic = new NDPicture;
	pic->Initialization(GetImgPathBattleUI("scenetargetbg.png"));
	imgHeadBg->SetPicture(pic, true);
	imgHeadBg->SetFrameRect(CGRectMake(0.0f, 0.0f, 87.0f, 40.0f));
	this->AddChild(imgHeadBg);
	
	this->m_imgNumPlayerLevel = new ImageNumber;
	m_imgNumPlayerLevel->Initialization();
	//m_imgNumPlayerLevel->SetSmallGoldNumber(50);
	m_imgNumPlayerLevel->SetFrameRect(CGRectMake(35.0f, 5.0f, 10.0f, 6.0f));
	//this->AddChild(m_imgNumPlayerLevel);
	
	m_imgHp = new NDUILayer;
	m_imgHp->Initialization();
	m_imgHp->SetBackgroundColor(ccc4(255, 0, 0, 255));
	m_imgHp->SetFrameRect(CGRectMake(42.0f, 19.0f, 40.0f, 3.0f));
	this->AddChild(m_imgHp);
	
	m_imgMp = new NDUILayer;
	m_imgMp->Initialization();
	m_imgMp->SetBackgroundColor(ccc4(66, 183, 250, 255));
	m_imgMp->SetFrameRect(CGRectMake(39.0f, 29.0f, 40.0f, 3.0f));
	this->AddChild(m_imgMp);
	
	m_imgHead = new NDUIImage;
	m_imgHead->Initialization();
	pic = new NDPicture;
	pic->Initialization(GetImgPath("bg.png"));
	pic->Cut(CGRectMake(32.0f, 1.0f, 25.0f, 25.0f));
	pic->SetReverse(true);
	m_imgHead->SetPicture(pic, true);
	m_imgHead->SetFrameRect(CGRectMake(7.0f, 9.0f, 25.0f, 25.0f));
	//this->AddChild(m_imgHead);
	
	m_head = new TargetHeadNode();
	m_head->Initialization();
//	this->AddChild(m_head);
}

void TargetHeadInMap::SetRole(NDBaseRole* role)
{
	if (role) {
		m_idRole = role->m_id;
		
		if (role->IsKindOfClass(RUNTIME_CLASS(NDNpc))) {
			m_bNpc = true;
			
			m_imgHp->SetFrameRect(CGRectMake(42.0f, 19.0f, 40.0f, 3.0f));
			
			if (m_imgNumPlayerLevel->GetParent() != NULL) {
				m_imgNumPlayerLevel->RemoveFromParent(false);
			}
			
			// 人形npc仍然绘制头像
			if (((NDNpc*)role)->IsRoleNpc()) {
				m_head->SetTargetRole(true, m_idRole);
				if (m_imgHead->GetParent() != NULL) {
					m_imgHead->RemoveFromParent(false);
				}
				if (m_head->GetParent() == NULL) {
					this->AddChild(m_head);
				}
			} else { // 其他npc绘制统一图标
				if (m_head->GetParent() != NULL) {
					m_head->RemoveFromParent(false);
				}
				if (m_imgHead->GetParent() == NULL) {
					this->AddChild(m_imgHead);
				}
			}
		} else if (role->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) {
			m_bNpc = false;
			
			if (m_imgNumPlayerLevel->GetParent() == NULL) {
				this->AddChild(m_imgNumPlayerLevel);
			}
			
			if (m_imgHead->GetParent() != NULL) {
				m_imgHead->RemoveFromParent(false);
			}
			
			m_head->SetTargetRole(false, m_idRole);
			if (m_head->GetParent() == NULL) {
				this->AddChild(m_head);
			}
		}
	}
}

void TargetHeadInMap::draw()
{
	// 根据 idRole 查找对应目标实体，如果找不到，则目标失效
	if (m_bNpc) {
		NDNpc* npc = NDMapMgrObj.GetNpcByID(m_idRole);
		
		if (!npc) {
			this->RemoveFromParent(false);
			return;
		}
	} else {
		NDManualRole* role = NDMapMgrObj.GetManualRole(m_idRole);
		if (!role) {
			this->RemoveFromParent(false);
			return;
		}
		
		GLfloat width = 40.0f * role->life / role->maxLife;
		m_imgHp->SetFrameRect(CGRectMake(42.0f, 19.0f, width, 3.0f));
		
		this->m_imgNumPlayerLevel->SetSmallGoldNumber(role->level);
	}
}

bool TargetHeadInMap::TouchEnd(NDTouch* touch)
{
	NDPlayer& player = NDPlayer::defaultHero();
	NDManualRole *role = NDMapMgrObj.GetManualRole(player.m_iFocusManuRoleID);
	if (role) 
	{
		NDDirector::DefaultDirector()->PushScene(OtherPlayerInfoScene::Scene(role));
	}
	else
	{
		NDNpc* npc = player.GetFocusNpc();
		if (npc && npc->GetType() != 6) 
		{
			player.SendNpcInteractionMessage(npc->m_id);
			if (npc->IsDirectOnTalk()) 
			{
				//npc朝向修改	
				if (player.GetPosition().x > npc->GetPosition().x) 
					npc->DirectRight(true);
				else 
					npc->DirectRight(false);
			}
		}
	}
	
	return true;
}


#pragma mark 队伍角色按钮
IMPLEMENT_CLASS(TeamRoleButton, NDUIButton)

TeamRoleButton::TeamRoleButton()
{
	m_head = NULL;
	
	m_lbName = NULL;
	
	m_imgNumPlayerLevel = NULL;
	
	m_iTeamID = -1;
	
	m_iIndexInTeam = -1;
	
	m_imgHp = NULL;
	
	m_imgMp = NULL;
}

TeamRoleButton::~TeamRoleButton()
{

}

void TeamRoleButton::Initialization()
{
	NDUIButton::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDUIImage* imgHeadBg = new NDUIImage;
	imgHeadBg->Initialization();
	NDPicture* pic = pool.AddPicture(GetImgPathNew("team_role_back.png"));
	imgHeadBg->SetPicture(pic, true);
	imgHeadBg->SetFrameRect(CGRectMake(0.0f, 0.0f, 49.0f, 39.0f));
	this->AddChild(imgHeadBg);
	
	this->m_imgNumPlayerLevel = new ImageNumber;
	m_imgNumPlayerLevel->Initialization();
	//m_imgNumPlayerLevel->SetSmallGoldNumber(50);
	m_imgNumPlayerLevel->SetFrameRect(CGRectMake(29.0f, 6.0f, 10.0f, 6.0f));
	this->AddChild(m_imgNumPlayerLevel);
	
	m_imgHp = new NDUILayer;
	m_imgHp->Initialization();
	m_imgHp->SetBackgroundColor(ccc4(255, 0, 0, 255));
	m_imgHp->SetFrameRect(CGRectMake(31.0f, 20.0f, 16.0f, 2.0f));
	m_imgHp->SetTouchEnabled(false);
	this->AddChild(m_imgHp);
	
	m_imgMp = new NDUILayer;
	m_imgMp->Initialization();
	m_imgMp->SetBackgroundColor(ccc4(66, 183, 250, 255));
	m_imgMp->SetFrameRect(CGRectMake(30.0f, 27.0f, 17.0f, 2.0f));
	m_imgMp->SetTouchEnabled(false);
	this->AddChild(m_imgMp);
	
	
	m_head = new HeadNode(NULL, false, true);
	m_head->Initialization();
	this->AddChild(m_head);
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbName->SetFontSize(14);
	m_lbName->SetFontColor(ccc4(0, 0, 255, 255));
	m_lbName->SetFrameRect(CGRectMake(2, 34, 480, 320));
	this->AddChild(m_lbName);
}

void TeamRoleButton::draw()
{
	if (!this->IsVisibled()) return;
	
	if (m_iTeamID < 0 || m_iIndexInTeam < 0) return;
	
	NDManualRole* role = NDMapMgrObj.GetTeamRole(m_iTeamID, m_iIndexInTeam);
	if (!role) {
		if (m_head)
			m_head->SetRole(NULL);
		return;
	}
	
	GLfloat width = role->maxLife == 0 ? 0 : (16.0f * role->life / role->maxLife);
	
	if (m_imgHp)
		m_imgHp->SetFrameRect(CGRectMake(31.0f, 20.0f, width, 2.0f));
		
	width = role->maxMana == 0 ? 0 : (17.0f * role->mana / role->maxMana);
	
	if (m_imgMp)
		m_imgMp->SetFrameRect(CGRectMake(30.0f, 27.0f, width, 2.0f));
	
	if (m_imgNumPlayerLevel)
		m_imgNumPlayerLevel->SetSmallGoldNumber(role->level);
	
	if (m_head)
	{
		m_head->SetRole(role);
		m_head->SetPos(ccpAdd(ccp(0, 6), this->GetScreenRect().origin));
	}
	
	if (m_lbName)
		m_lbName->SetText(role->m_name.c_str());
}

void TeamRoleButton::SetRole(int teamId, int index)
{
	m_iTeamID = teamId;
	
	m_iIndexInTeam = index;
}

void TeamRoleButton::GetTeamRole(int& teamId, int& index)
{
	teamId = m_iTeamID;
	
	index = m_iIndexInTeam;
}

void TeamRoleButton::SetVisible(bool visible)
{
	NDUIButton::SetVisible(visible);
	
	if (!visible && m_head)
		m_head->SetRole(NULL);
}

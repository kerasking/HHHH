/*
 *  UiPetDefine.h
 *  DragonDrive
 *
 *  Created by xwq on 12-1-14.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_PET_DEFINE_H_
#define _UI_PET_DEFINE_H_

#include "define.h"

enum ID_BUTTON
{
	ID_BUTTON_AMULDT1	= 1,		// 护符1
	ID_BUTTON_HEAD,					// 头盔
	ID_BUTTON_ARMOR,				// 武器
	ID_BUTTON_DLOTHES,				// 衣服
	ID_BUTTON_AMULDT2,				// 护符2
	ID_BUTTON_SHOES,				// 鞋子
};

enum MSG_PET_ACTION
{
	MSG_PET_ACTION_TOBAG=0,	//放入背包
	MSG_PET_ACTION_GENERAL,	//主将任命
	MSG_PET_ACTION_FIGHT,	//出战
	MSG_PET_ACTION_SHOW,	//遛宠
	MSG_PET_ACTION_DROP,	//丢弃
	MSG_PET_ACTION_REST,	//休息
	MSG_PET_ACTION_UNSHOW,	//收回，停止溜宠
	MSG_PET_ACTION_USEITEM,	//宠物背包中的宠物使用物品
};

const OBJID	ID_SUO_LING_FU	= 28301005;	// 锁灵符

class CUIPetDelegate
{
public:
	// SkillInfo
	virtual void	UpdateSkillInfo()	{}
	virtual void	CloseSkillInfo()	{}
	
	// PetSkill
	virtual void	LockSkill(OBJID idSkill)	{}
	virtual void	UnLockSkill(OBJID idSkill)	{}
	virtual void	LearnSkill()				{}
	
	virtual void	UpdateBagItemInfo()	{}
	virtual void	CloseBagItemInfo()	{}
	virtual void	UseItem()			{}
	virtual void	DropItem()			{}
	
	virtual OBJID	GetFocusPetId()		{ return 0; }
	virtual void	ChangePet()			{}
};

#endif
/*
 *  Hurt.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-25.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_HURT_H__
#define __BATTLE_HURT_H__

#include "string.h"

enum HURT_TYPE
{
	HURT_TYPE_ACTIVE = 0,
	HURT_TYPE_PASSIVE = 1,
};

class Fighter;
struct Hurt
{
	Hurt()
	{
		memset(this, 0L, sizeof(Hurt));
	}

	Hurt(Fighter* actor, int btType, int hurtHP, int hurtMP, int dwData,
			HURT_TYPE ht);

	Fighter* theActor; // 被谁打的，如果是状态扣血，不要至指定被谁打的。
	int btType; // 以何种方式伤害
	int hurtHP; // 伤了多少血
	int hurtMP; // 伤了多少蓝
	int dwData; // 对应dwData，0-普通伤害，其他数值-特定法术效果伤害。
	HURT_TYPE type; // 主动伤害还是被动效果伤害
};

enum
{
	EXIST_TIME_MAX = 10,
};

class HurtNumber
{
public:
	HurtNumber(int num)
	{
		m_nHurtNum = num;
		m_nExistTime = EXIST_TIME_MAX;
		m_nHurtNumberY = 0;
		m_bIsDisappear = false;
	}

	void timeLost()
	{
		if (m_nExistTime < EXIST_TIME_MAX)
		{
			m_nExistTime--;
			if (m_nExistTime > EXIST_TIME_MAX - 2)
			{
				m_nHurtNumberY += 1;
			}
			if (m_nExistTime == 0)
			{
				m_bIsDisappear = true;
				m_nExistTime = EXIST_TIME_MAX;
			}
		}
	}

	bool isNew()
	{
		return m_nExistTime == EXIST_TIME_MAX ? true : false;
	}

	void beginAppear()
	{
		m_nExistTime = EXIST_TIME_MAX - 1;
		m_nHurtNumberY = 1;
	}

	bool isDisappear()
	{
		return m_bIsDisappear;
	}

	void setDisappear(bool bDis)
	{
		m_bIsDisappear = bDis;
	}

	int getHurtNum()
	{
		return m_nHurtNum;
	}

	void setHurtNum(int hn)
	{
		m_nHurtNum = hn;
	}

	int getHurtNumberY()
	{
		return m_nHurtNumberY;
	}

	void setHurtNumberY(int hnY)
	{
		m_nHurtNumberY = hnY;
	}

private:
	int m_nHurtNum;
	int m_nExistTime;

	bool m_bIsDisappear;
	int m_nHurtNumberY;
};

#endif

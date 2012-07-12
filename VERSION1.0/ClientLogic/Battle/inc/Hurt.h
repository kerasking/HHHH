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

enum HURT_TYPE {
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
	
	Hurt(Fighter* actor, int btType, int hurtHP, int hurtMP, int dwData, HURT_TYPE ht);
	
	Fighter* theActor;// 被谁打的，如果是状态扣血，不要至指定被谁打的。
	int btType;// 以何种方式伤害
	int hurtHP;// 伤了多少血
	int hurtMP;// 伤了多少蓝
	int dwData;// 对应dwData，0-普通伤害，其他数值-特定法术效果伤害。
	HURT_TYPE type;// 主动伤害还是被动效果伤害
};

enum {
	EXIST_TIME_MAX = 10,
};

class HurtNumber {
public:
	HurtNumber(int num) {
		hurtNum = num;
		existTime = EXIST_TIME_MAX;
		hurtNumberY = 0;
		disappear = false;
	}
	
	void timeLost() {
		if (existTime < EXIST_TIME_MAX) {
			existTime--;
			if (existTime > EXIST_TIME_MAX - 3) {
				hurtNumberY += 2;
			}
			if (existTime == 0) {
				disappear = true;
				existTime = EXIST_TIME_MAX;
			}
		}
	}
	
	bool isNew() {
		return existTime == EXIST_TIME_MAX ? true : false;
	}
	
	void beginAppear() {
		existTime = EXIST_TIME_MAX - 1;
		hurtNumberY = 1;
	}
	
	bool isDisappear() {
		return disappear;
	}
	
	void setDisappear(bool bDis) {
		disappear = bDis;
	}
	
	int getHurtNum() {
		return hurtNum;
	}
	
	void setHurtNum(int hn) {
		hurtNum = hn;
	}
	
	int getHurtNumberY() {
		return hurtNumberY;
	}
	
	void setHurtNumberY(int hnY) {
		hurtNumberY = hnY;
	}
	
private:
	int hurtNum;
	int existTime;
	
	bool disappear;
	int hurtNumberY;
};

#endif
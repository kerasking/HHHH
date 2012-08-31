//
//  NDMonster.h
//  DragonDrive
//
//  Created by jhzheng on 10-12-31.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef __ND_MONSTER_H
#define __ND_MONSTER_H

#include "NDBaseRole.h"
#include "NDUILabel.h"
#include <string>

namespace NDEngine
{

#define	NORMAL_MOVE_RECTW 90
#define	NORMAL_MOVE_RECTH 90 // 普通怪物自身的活动范围we
#define	BOSS_MOVE_RECTW	60
#define	BOSS_MOVE_RECTH 50 // 精英怪物自身的活动范围we
#define BASE_BOTTOM_WH 32

#define	REFRESH_TIME 90  // 普通怪物打死后刷新时间
#define	FROZEN_TIME 10

#define	MONSTER_VIEW_AI 5 //怪物视野格子数,如果1就是3*3,2就是5*5,依此类推
#define MOVE_DISTANCE 32 // 表每步距离
#define EVERY_MOVE_COUNT 4 // 表每步分成多少次走完,配合程序刷屏时不产生跳帧现象
#define EVERY_MOVE_DISTANCE ( MOVE_DISTANCE / EVERY_MOVE_COUNT ) // 每一帧所走距离
#define MOVE_MIN 2 // 表一个最小基数,用来下面的计算,
#define BOSS_PROTECT_TIME (10)

enum
{
	MONSTER_STATE_DEAD = 0, // 怪物已经被消灭
	MONSTER_STATE_NORMAL = 1, // 怪物正常
	MONSTER_STATE_BATTLE = 2, // 怪物正处于战斗中
};

enum
{
	LEVEL_GRAY = -7, // 怪物低于
	LEVEL_GREEN = -2,
	LEVEL_YELLOW = 2,
	LEVEL_ORANGE = 5,
};

enum
{
	MONSTER_NORMAL = 0, // 普通怪
	MONSTER_ELITE,		// 精英怪
	MONSTER_BOSS,		// BOSS怪
	MONSTER_Farm,		// 庄园
};

// 0表上,1表下,2左, 3右 ,-1表无方向
enum
{
	dir_up = 0, dir_down = 1, dir_left = 2, dir_right = 3, dir_invalid = -1,
};

class NDMonster: public NDBaseRole
{
	DECLARE_CLASS (NDMonster)
public:
	static bool isRoleMonster(int lookface);
public:
	NDMonster();
	~NDMonster();
	//void Init(); override
	virtual void OnMoving(bool bLastPos);
public:
	//以下方法供逻辑层使用－－－begin
	//......
	void Initialization(int idType);hide

	void Initialization(int lookface, int idNpc, int lvl);

	bool OnDrawBegin(bool bDraw);override

	void MoveToPosition(CGPoint toPos, SpriteSpeed speed = SpriteSpeedStep4,
			bool moveMap = false);hide

	void WalkToPosition(CGPoint toPos);

	void Update(unsigned long ulDiff);override

	void SetType(int type);
	int GetType()
	{
		return m_nMonsterCatogary;
	}

	//　精英怪处理
	void ElementMonsterDeal();
	//－－－end
public:
	void setMonsterStateFromBattle(int result);
	void startBattle();
	void endBattle();
	int getState()
	{
		return state;
	}
	void restorePosition();
	void changeLookface(int lookface);
	void SetCanBattle(bool bCanBattle);
	void SetMoveRect(CGPoint point, int size);
	//CGRect GetMoveRect(){return CGRectMake(selfMoveRectX, selfMoveRectY, self_move_rectW, self_move_rectH);}
	bool CanBattele();
private:
	bool isUseAI();
	int getRandomAIDirect();
	void randomMonsterUseAI();
	void randomMonsterNotAI();
	void setAnigroupFace();
	void setMonsterFrozen(bool f);	// 精英怪才有冻结状态,防止战败后又遇怪
	void monsterInit();				// 解锁怪物一切状态
	void runLogic();
	void directLogic();
	void LogicDraw();
	void LogicNotDraw(bool bClear = false);
	void doMonsterCollides();
	int getCollideW();
	int getCollideH();
	void sendBattleAction();
	void drawName(bool bDraw);
public:
	void setState(int monsterState);
	void setOriginalPosition(int o_x, int o_y);
public:
	int state;						//怪物状态
private:
	int m_nAttackArea;					//怪物攻击范围
	int m_nType;						//怪物类型
	CGSize m_moveSize;
	int m_nFigure;						// 体型：0-小只，1-大只。
	NDSprite *bossRing;				//精英怪光环
	NDUILabel *m_lbName;
	bool m_bIsHunt;
	int m_nOriginal_x;
	int m_nOriginal_y;
public:
	int m_nMoveDirect;
	bool m_bIsAIUseful; // AI算法是否遇到掩码无法走动,是的话用普通走法
	bool m_bRoleMonster;

	bool m_bIsAutoAttack; // 怪物主动攻击
	int m_nMonsterCatogary;

	int self_move_rectw;
	int self_move_rectH; // 怪物活动范围we
	int selfMoveRectX, selfMoveRectY; // 怪物自身活动范围的左上角xy

	bool isMonsterCollide; // 表示怪物碰撞后不能运动

	bool isFrozen; // 精英怪才有冻结状态

	long deadTime, frozenTime; // 怪物死亡时间,精英怪冻结
private:
	int m_nMoveCount; // 有基数计算得出的步数

	int stop_time_count; // 每次怪走完路后会固定停顿一定时间

	int curStopCount; // 表当前停顿

	int curMoveCount; // 配合EVERY_MOVE_COUNT, 将每一步拆分多个小步

	int curCount; // 表当前步数

	/** 某些资源朝向相反需重新定义移动方向如坐骑 */
	bool turnFace;

	bool m_bCanBattle;

	//守卫,没用到
	int moveRectW;
	int moveRectH;

	double m_timeBossProtect;
public:
	//是否是战场里的
	bool bBattleMap;
	bool isSafeProtected;
	bool bClear;

	DECLARE_AUTOLINK (NDMonster)
	INTERFACE_AUTOLINK (NDMonster)
};
}

#endif // __ND_MONSTER_H

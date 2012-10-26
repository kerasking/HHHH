/*
*
*/

#ifndef NDBASEBATTLE_H
#define NDBASEBATTLE_H

#include "NDObject.h"
#include "define.h"
#include "NDUITableLayer.h"
#include "NDDataSource.h"

NS_NDENGINE_BGN

class BattleSkill;
class FighterStatus;
class FightAction;

struct Command
{
	Command()
	{
		memset(this, 0L, sizeof(Command));
	}

	~Command()
	{

	}

	int btEffectType;
	int idActor;
	int idTarget;
	int nHpLost;
	int nMpLost;

	/**
	 * 该命令所使用的技能,由服务端下发,含技能id,名字,atkType(id亿位解析出来)
	 */
	BattleSkill* skill;
	FighterStatus* status;
	Command* cmdNext; //command连锁
	bool complete;
};

class NDBaseBattle:public NDObject
{
	DECLARE_CLASS(NDBaseBattle);

public:

	NDBaseBattle();
	virtual ~NDBaseBattle();

	virtual Fighter* GetMainUser() = 0;
	virtual Fighter* getMainEudemon() = 0;
	virtual bool IsPracticeBattle() = 0;
	virtual int GetBattleType() = 0;

	virtual void SetTurn(int turn) = 0;
	virtual void StartFight() = 0;
	virtual void RestartFight() = 0;
	virtual void dealWithCommand() = 0;
	virtual void AddCommand(Command* cmd) = 0;

	virtual void AddActionCommand(FightAction* action) = 0;
	virtual void InitSpeedBar() = 0;
	virtual void InitEudemonOpt() = 0;
	virtual void Initialization(int action) = 0;
	virtual bool TouchEnd(NDTouch* touch)  = 0;
	virtual void draw() = 0;
	virtual void drawSubAniGroup() = 0;
	virtual void OnTableLayerCellSelected(NDUITableLayer* table,
		NDUINode* cell,unsigned int cellIndex, NDSection* section) = 0;

	virtual void AddFighter(Fighter* f) = 0;

	virtual void SetFighterOnline(int idFighter, bool bOnline) = 0;

protected:
private:
};

NS_NDENGINE_END

#endif
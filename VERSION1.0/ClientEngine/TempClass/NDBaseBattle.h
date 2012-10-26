/*
 *
 */

#ifndef NDBASEBATTLE_H
#define NDBASEBATTLE_H

#include "NDObject.h"
#include "define.h"
#include "NDDataSource.h"

class BattleSkill;
class FighterStatus;
class FightAction;

NS_NDENGINE_BGN

class NDBaseBattle
{
public:

	NDBaseBattle(){}
	virtual ~NDBaseBattle(){}

// 	virtual Fighter* GetMainUser() = 0;
// 	virtual Fighter* getMainEudemon() = 0;
	virtual bool IsPracticeBattle() = 0;
	virtual int GetBattleType() = 0;

	virtual void SetTurn(int turn) = 0;
	virtual void StartFight() = 0;
	virtual void RestartFight() = 0;
	virtual void dealWithCommand() = 0;
	//virtual void AddCommand(Command* cmd) = 0;

	virtual void AddActionCommand(FightAction* action) = 0;
	virtual void InitSpeedBar() = 0;
	virtual void InitEudemonOpt() = 0;
	virtual void Initialization(int action) = 0;
	virtual bool TouchEnd(NDTouch* touch) = 0;
	virtual void draw() = 0;
	virtual void drawSubAniGroup() = 0;
	virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
			unsigned int cellIndex, NDSection* section) = 0;

	//virtual void AddFighter(Fighter* f) = 0;

	virtual void SetFighterOnline(int idFighter, bool bOnline) = 0;

protected:
private:
};

NS_NDENGINE_END

#endif
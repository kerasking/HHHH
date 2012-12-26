/*
 *
 */

#ifndef NDBASEBATTLE_H
#define NDBASEBATTLE_H

#include "NDObject.h"
#include "define.h"
#include "NDDataSource.h"
#include "NDUILayer.h"

class BattleSkill;
class FighterStatus;
class FightAction;

NS_NDENGINE_BGN

class NDBaseBattle
{
public:

	//DECLARE_CLASS(NDBaseBattle);

	NDBaseBattle(){}
	virtual ~NDBaseBattle(){}

// 	virtual Fighter* GetMainUser() = 0;
// 	virtual Fighter* getMainEudemon() = 0;
	virtual bool IsPracticeBattle(){return true;}
	virtual int GetBattleType(){return 0;}

	virtual void SetTurn(int turn){}
	virtual void StartFight(){}
	virtual void RestartFight(){}
	virtual void dealWithCommand(){}
	//virtual void AddCommand(Command* cmd) = 0;

	virtual void AddFighterAction(FightAction* action){}
	virtual void InitSpeedBar(){}
	virtual void InitEudemonOpt(){}
	virtual void Initialization(int action){}
	virtual bool TouchEnd(NDTouch* touch){return true;}
	virtual void draw(){}
	virtual void drawSubAniGroup(){}
	virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell,
		unsigned int cellIndex, NDSection* section){}

	//virtual void AddFighter(Fighter* f) = 0;

	virtual void SetFighterOnline(int idFighter, bool bOnline){};

protected:
private:
};

//IMPLEMENT_CLASS(NDBaseBattle,NDUILayer);

NS_NDENGINE_END

#endif
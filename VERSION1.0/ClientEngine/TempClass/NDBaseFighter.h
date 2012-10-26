/*
*
*/

#ifndef NDBASEFIGHTER_H
#define NDBASEFIGHTER_H

#include "define.h"
#include "NDObject.h"

class FighterStatus;
class NDBaseRole;

typedef vector<FighterStatus*> VEC_FIGHTER_STATUS;
typedef VEC_FIGHTER_STATUS::iterator VEC_FIGHTER_STATUS_IT;

enum HURT_TYPE
{
	HURT_TYPE_ACTIVE = 0,
	HURT_TYPE_PASSIVE = 1,
};

NS_NDENGINE_BGN

class NDBaseFighter:public NDObject
{
	DECLARE_CLASS(NDBaseFighter);

public:

	NDBaseFighter(){}
	virtual ~NDBaseFighter(){}

	virtual void SetRole(NDBaseRole* role) = 0;
	virtual void LoadMonster(int nLookFace, int lev, const string& name) = 0;
	virtual void LoadRole(int nLookFace, int lev, const string& name) = 0;
	virtual NDBaseRole* GetRole() const = 0;

	virtual void setPosition(int offset) = 0;
	virtual void updatePos() = 0;
	virtual void draw() = 0;
	virtual void setOnline(bool bOnline) = 0;
	virtual int GetNormalAtkType() const;
	virtual void AddAHurt(NDBaseFighter* actor, int btType, int hurtHP, int hurtMP,
		int dwData, HURT_TYPE ht) = 0;
	//virtual void AddAStatusTarget(StatusAction& f) = 0;
	virtual void AddATarget(NDBaseFighter* f) = 0;

	//virtual VEC_FIGHTER& getArrayTarget() = 0;
	//virtual VEC_STATUS_ACTION& getArrayStatusTarget() = 0;

	virtual void AddPasStatus(int dwData) = 0;
	//virtual PAIR_GET_HURT getHurt(NDBaseFighter* actor, int btType, int dwData, int type) = 0;
	virtual int getActionTime() = 0;
	virtual void setActionTime(int waitToActionTime) = 0;
	virtual void actionTimeIncrease() = 0;
	virtual void removeAStatusAniGroup(FighterStatus* status) = 0;
	virtual bool isActionOK() = 0;
	virtual void setActionOK(bool bOK) = 0;
	virtual void setBeginAction(bool bBegin) = 0;
	virtual bool isBeginAction() = 0;

	virtual bool isVisiable() = 0;
	virtual bool isCatchable() = 0;
	virtual bool isAlive() = 0;
	virtual void setAlive(bool a) = 0;
	virtual bool isEscape() = 0;
	virtual void setEscape(bool esc) = 0;
	virtual bool isHurtOK() = 0;
	virtual void setHurtOK(bool htOK) = 0;
	virtual bool isDodgeOK() = 0;
	virtual void setDodgeOK(bool bOK) = 0;
	virtual bool isDefenceOK() = 0;

	virtual void setDefenceOK(bool bOK) = 0;
	virtual void setOriginPos(int x, int y) = 0;
	virtual bool isDieOK() = 0;
	virtual void setDieOK(bool bOK) = 0;
	//virtual BattleSkill* getUseSkill() = 0;
	//virtual void setUseSkill(BattleSkill* skill) = 0;
	//virtual ATKTYPE getSkillAtkType() = 0;
	//virtual void setSkillAtkType(ATKTYPE atkType) = 0;
	virtual bool completeOneAction() = 0;
	virtual bool moveTo(int tx, int ty) = 0;

	virtual int getX() = 0;
	virtual int getY() = 0;

	virtual int getOriginX() = 0;
	virtual int getOriginY() = 0;
	virtual bool StandInOrigin() = 0;
	virtual void hurted(int num) = 0;

	virtual void setCurrentHP(int hp) = 0;
	virtual void setCurrentMP(int mp) = 0;

	virtual void showSkillName(bool b) = 0;
	virtual void showFighterName(bool b) = 0;

	virtual void drawHurtNumber() = 0;
	virtual void drawActionWord() = 0;
	virtual void drawHPMP() = 0;

	virtual void clearFighterStatus() = 0;
	virtual int getAPasStatus() = 0;

	virtual bool hasMorePasStatus() = 0;
	virtual void LoadEudemon() = 0;

	virtual void setWillBeAtk(bool bSet) = 0;
	//virtual void setBattle(Battle* parent) = 0;

	virtual void setSkillName(std::string name) = 0;
	//virtual void addAStatus(FighterStatus* fs) = 0;
	//virtual VEC_FIGHTER_STATUS& getFighterStatus() = 0;

protected:
private:
};

NS_NDENGINE_BGN

#endif
#ifndef NDBASEFIGHTER_H
#define NDBASEFIGHTER_H

#include "define.h"
#include "NDObject.h"
#include "EnumDef.h"

class FighterStatus;

typedef struct _FIGHTER_INFO
{
	_FIGHTER_INFO()
	{
		::memset(this, 0L, sizeof(_FIGHTER_INFO));
	}

	int idObj;
	int idType;
	int idlookface;
	Byte btBattleTeam;
	Byte btStations;
	FIGHTER_TYPE fighterType;
	BATTLE_GROUP group;
	int original_life;
	int original_mana;
	int nLife;
	int nLifeMax;
	int nMana;
	int nManaMax;
	int skillId;
	int atk_type;
	short level;
	int nQuality;
} FIGHTER_INFO;

NS_NDENGINE_BGN

class NDBaseRole;

class NDBaseFighter:public NDObject
{
	//DECLARE_CLASS (NDBaseFighter);

public:

	NDBaseFighter()
	{
	}
	virtual ~NDBaseFighter()
	{
	}

	//virtual void SetRole(NDBaseRole* role){}
	virtual void LoadMonster(int nLookFace, int lev, const string& name){}
	virtual void LoadRole(int nLookFace, int lev, const string& name){}
	//virtual NDBaseRole* GetRole() const{}

	virtual void setPosition(int offset){}
	virtual void updatePos(){}
	virtual void draw(){}
	virtual void setOnline(bool bOnline){}
	virtual int GetNormalAtkType() const{return 0;};
	// 	virtual void AddAHurt(NDBaseFighter* actor, int btType, int hurtHP, int hurtMP,
	// 		int dwData, HURT_TYPE ht){}
	//virtual void AddAStatusTarget(StatusAction& f){}
	virtual void AddATarget(NDBaseFighter* f){}

	//virtual VEC_FIGHTER& getArrayTarget(){}
	//virtual VEC_STATUS_ACTION& getArrayStatusTarget(){}

	virtual void AddPasStatus(int dwData){}
	//virtual PAIR_GET_HURT getHurt(NDBaseFighter* actor, int btType, int dwData, int type){}
	virtual int getActionTime(){return 0;}
	virtual void setActionTime(int waitToActionTime){}
	virtual void actionTimeIncrease(){}
	virtual void removeAStatusAniGroup(FighterStatus* status){}
	virtual bool isActionOK(){return true;}
	virtual void setActionOK(bool bOK){}
	virtual void setBeginAction(bool bBegin){}
	virtual bool isBeginAction(){return true;}

	virtual bool isVisiable(){return true;}
	virtual bool isCatchable(){return true;}
	virtual bool isAlive(){return true;}
	virtual void setAlive(bool a){}
	virtual bool isEscape(){return true;}
	virtual void setEscape(bool esc){}
	virtual bool isHurtOK(){return true;}
	virtual void setHurtOK(bool htOK){}
	virtual bool isDodgeOK(){return false;}
	virtual void setDodgeOK(bool bOK){}
	virtual bool isDefenceOK(){return false;}

	virtual void setDefenceOK(bool bOK){}
	virtual void setOriginPos(int x, int y){}
	virtual bool isDieOK(){return false;}
	virtual void setDieOK(bool bOK){}
	//virtual BattleSkill* getUseSkill(){}
	//virtual void setUseSkill(BattleSkill* skill){}
	//virtual ATKTYPE getSkillAtkType(){}
	//virtual void setSkillAtkType(ATKTYPE atkType){}
	virtual bool completeOneAction(){return false;}
	virtual bool moveTo(int tx, int ty){return false;}

	virtual int getX(){return 0;}
	virtual int getY(){return 0;}

	virtual int getOriginX(){return 0;}
	virtual int getOriginY(){return 0;}
	virtual bool StandInOrigin(){return false;}
	virtual void hurted(int num){}

	virtual void setCurrentHP(int hp){}
	virtual void setCurrentMP(int mp){}

	virtual void showSkillName(bool b){}
	virtual void showFighterName(bool b){}

	virtual void drawHurtNumber(){}
	virtual void drawActionWord(){}
	virtual void drawHPMP(){}

	virtual void clearFighterStatus(){}
	virtual int getAPasStatus(){return 0;}

	virtual bool hasMorePasStatus(){return false;}
	virtual void LoadEudemon(){}

	virtual void setWillBeAtk(bool bSet){}
	//virtual void setBattle(Battle* parent){}

	virtual void setSkillName(std::string name){}
	//virtual void addAStatus(FighterStatus* fs){}
	//virtual VEC_FIGHTER_STATUS& getFighterStatus(){}

	FIGHTER_INFO getFighterInfo(){return m_kInfo;}
	void setFighterInfo(FIGHTER_INFO kInfo){m_kInfo = kInfo;}

	FIGHTER_INFO m_kInfo;

	//CC_SYNTHESIZE(FIGHTER_INFO,m_kInfo,FighterInfo); ///< 你妹……又是大量直接引用！！

protected:
private:
};

//IMPLEMENT_CLASS(NDBaseFighter,NDObject);

NS_NDENGINE_END

#endif
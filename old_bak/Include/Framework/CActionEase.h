/**
曲线动作类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __ACTION_CCEASE_ACTION_H__
#define __ACTION_CCEASE_ACTION_H__

#include "CActionInterval.h"

/** 
 @brief Base class for Easing actions
 加速度曲线动作

 曲线动作是在一段时间改变的特殊复合动作。在动画世界里它们经常被称为Tweening或者Easing action。

 这些动作在内部修改动作的速度。但是它们不能修改运行时间。如果一个运行是5秒，那么动作的持续时间就是5秒。

 曲线动作在时间片内改变直线。

 比如它们可以加速或者减速内部动作。

 这些动作被声明为3个类型：

 In actions:加速器在动作的开始
 Out actions:加速器在动作的结尾
 InOut actions:加速器在动作的开始和结尾
(
	In    由慢至快
	Out   由快至慢
	InOut 由慢至快再由快至慢
)
Speed 人工设定速度,还可通过 SetSpeed 不断调整。

CActionEase:加速度变化的基类
 */
class CActionEase : public CActionInterval
{
public:
	virtual ~CActionEase(void);

	/** initializes the action */
    bool InitWithAction(CActionInterval *pAction);

	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);

public:
	/** creates the action */
	static CActionEase* ActionWithAction(CActionInterval *pAction);

protected:
	CActionInterval *m_pOther;
};

/** 
 @brief Base class for Easing actions with rate parameters
 failed test
 加速度变化动作
 */
class CEaseRateAction : public CActionEase
{
public:
	virtual ~CEaseRateAction(void);

	/** set rate value for the actions */
	//设置当前加速度
	void SetRate(float rate);

	/** get rate value for the actions */
	//获取当前加速度
	float GetRate(void);

	/** Initializes the action with the inner action and the rate parameter */
	bool InitWithAction(CActionInterval *pAction, float fRate);

	virtual CActionInterval* Reverse(void);

public:
	/** Creates the action with the inner action and the rate parameter */
	static CEaseRateAction* ActionWithAction(CActionInterval* pAction, float fRate);

protected:
	float m_fRate;//当前的加速度
};

/** 
由慢至快
 @brief CEaseIn action with a rate
 */
class CEaseIn : public CEaseRateAction
{
public:
	virtual void Update(fTime time);

public:
	/** Creates the action with the inner action and the rate parameter */
	static CEaseIn* ActionWithAction(CActionInterval* pAction, float fRate);
};

/** 
 @brief CEaseOut action with a rate
由快至慢
 */
class CEaseOut : public CEaseRateAction
{
public:
	virtual void Update(fTime time);


public:
	/** Creates the action with the inner action and the rate parameter */
	//pAction动作,fRate变化的倍数
    static CEaseOut* ActionWithAction(CActionInterval* pAction, float fRate);
};

/** 
由慢至快再由快至慢
 @brief CEaseInOut action with a rate
 */
class CEaseInOut : public CEaseRateAction
{
public:
	virtual void Update(fTime time);

	virtual CActionInterval* Reverse(void);

public:
	/** Creates the action with the inner action and the rate parameter */
	static CEaseInOut* ActionWithAction(CActionInterval* pAction, float fRate);
};

/** 
 @brief CCEase Exponential In
 指数型曲线动作,由慢至快
 */
class CEaseExponentialIn : public CActionEase
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseExponentialIn* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief Ease Exponential Out
 指数型曲线动作,由快至慢
 */
class CEaseExponentialOut : public CActionEase
{
public:
    virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseExponentialOut* ActionWithAction(CActionInterval* pAction);

};

/** 
 @brief Ease Exponential InOut
 指数型曲线动作,由慢至快再由快至慢
 */
class CEaseExponentialInOut : public CActionEase
{
public:
	virtual void Update(fTime time);


public:
	/** creates the action */
	static CEaseExponentialInOut* ActionWithAction(CActionInterval* pAction);

};

/** 
 @brief Ease Sine In
 由慢至快,呈正弦曲线动作的加速度
 */
class CEaseSineIn : public CActionEase
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseSineIn* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief Ease Sine Out
 由快至慢,呈正弦曲线动作的加速度
 */
class CEaseSineOut : public CActionEase
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseSineOut* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief Ease Sine InOut
 由慢至快再由快至慢,呈正弦曲线动作的加速度
 */
class CEaseSineInOut : public CActionEase
{
public:
	virtual void Update(fTime time);


public:
	/** creates the action */
	static CEaseSineInOut* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief Ease Elastic abstract class
 
 心电图型动作：

 这些动作在时间片内模仿心电图图形，这个动作使用时间在0～1s内，所以这个内部动作操作这个特殊的值

 这些值要不止一次使用（这个函数不是对象）。所以内部动作准备修改这个值。比如CMoveBy,CScaleBy,CRotateBy等等，但是CCSquence或CSpawn也许是不期望的结果。
 */
class CEaseElastic : public CActionEase
{
public:
	/** get period of the wave in radians. default is 0.3 */
	inline float GetPeriod(void) { return m_fPeriod; }
	/** set period of the wave in radians. */
	inline void SetPeriod(float fPeriod) { m_fPeriod = fPeriod; }

	/** Initializes the action with the inner action and the period in radians (default is 0.3) */
	bool InitWithAction(CActionInterval *pAction, float fPeriod);
	/** initializes the action */
	bool InitWithAction(CActionInterval *pAction);

	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseElastic* ActionWithAction(CActionInterval *pAction);
	/** Creates the action with the inner action and the period in radians (default is 0.3) */
	static CEaseElastic* ActionWithAction(CActionInterval *pAction, float fPeriod);

protected:
	float m_fPeriod;//周期
};

/** 
 @brief Ease Elastic In action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 
由慢至快,心电图型动作
 */
class CEaseElasticIn : public CEaseElastic
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseElasticIn* ActionWithAction(CActionInterval *pAction);
	/** Creates the action with the inner action and the period in radians (default is 0.3) */
	static CEaseElasticIn* ActionWithAction(CActionInterval *pAction, float fPeriod);
};

/** 
 @brief Ease Elastic Out action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 
 由快至慢,心电图型动作
 */
class CEaseElasticOut : public CEaseElastic
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseElasticOut* ActionWithAction(CActionInterval *pAction);
	/** Creates the action with the inner action and the period in radians (default is 0.3) */
	static CEaseElasticOut* ActionWithAction(CActionInterval *pAction, float fPeriod);
};

/** 
 @brief Ease Elastic InOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 
 心电图型动作
 */
class CEaseElasticInOut : public CEaseElastic
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseElasticInOut* ActionWithAction(CActionInterval *pAction);
	/** Creates the action with the inner action and the period in radians (default is 0.3) */
	static CEaseElasticInOut* ActionWithAction(CActionInterval *pAction, float fPeriod);
};

/** 
 @brief CEaseBounce abstract class.
 
 股市型：
 股市型模拟了一个反弹效果。
 这些要不止一次使用（这个函数不是对象）。所以内部动作应该准备修改这个值。比如CMoveBy,CScaleBy,CRotateBy等等，但是CCSquence或CSpawn也许是不期望的结果。
*/
class CEaseBounce : public CActionEase
{
public:
	fTime BounceTime(fTime time);


public:
	/** creates the action */
	static CEaseBounce* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief CEaseBounceIn action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 由慢至快的股市型动作
*/
class CEaseBounceIn : public CEaseBounce
{
public:
    virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseBounceIn* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief EaseBounceOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 由快至慢的股市型动作
 */
class CEaseBounceOut : public CEaseBounce
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseBounceOut* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief CEaseBounceInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 由慢至快再由快至慢的股市型动作
 */
class CEaseBounceInOut : public CEaseBounce
{
public:
	virtual void Update(fTime time);


public:
	/** creates the action */
	static CEaseBounceInOut* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief CEaseBackIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 由慢至快的速度渐变动作
 */
class CEaseBackIn : public CActionEase
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseBackIn* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief CEaseBackOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 由快至慢的速度渐变动作
 */
class CEaseBackOut : public CActionEase
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action */
	static CEaseBackOut* ActionWithAction(CActionInterval* pAction);
};

/** 
 @brief CEaseBackInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 由慢至快再由快至慢的速度渐变动作
*/
class CEaseBackInOut : public CActionEase
{
public:
	virtual void Update(fTime time);


public:
	/** creates the action */
	static CEaseBackInOut* ActionWithAction(CActionInterval* pAction);
};

#endif // __ACTION_CCEASE_ACTION_H__


/**
  时间间隔动作类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __ACTION_CCINTERVAL_ACTION_H__
#define __ACTION_CCINTERVAL_ACTION_H__

#include "CAction.h"
#include "cTypes.h"
#include "CPointExtension.h"
#include "Sprite.h"

/** 
@brief An interval action is an action that takes place within a certain period of time.
It has an start time, and a finish time. The finish time is the parameter
duration plus the start time.

These CActionInterval actions have some interesting properties, like:
- They can run normally (default)
- They can run reversed with the reverse method
- They can run with the time altered with the Accelerate, AccelDeccel and Speed actions.

For example, you can simulate a Ping Pong effect running the action normally and
then running it again in Reverse mode.

Example:

CAction *pingPongAction = CSequence::Actions(action, action->Reverse(), NULL);
延时动作:动作的完成需要一定时间
***To: 意味着运动到指定的位置。

***By:意味着运动到按照指定癿 x、y 增量的位置。(x、y 可以是负值)

移动到 – CMoveTo

移动– CMoveBy

跳跃到 – CJumpTo

设置终点位置和跳跃癿高度和次数。

跳跃 – CJumpBy

设置终点位置和跳跃癿高度和次数。

贝塞尔 – CBezierBy

支持 3 次贝塞尔曲线:P0-起点,P1-起点切线方向,P2-终点切线方向,P3-终点。

首先设置定 Bezier 参数,然后执行。

放大到 – CScaleTo

设置放大倍数,是浮点型。

放大 – CScaleBy

旋转到 – CRotateTo

旋转 – CRotateBy

闪烁 – CBlink
设定闪烁次数

色调变化到 – CTintTo

色调变换 – CTintBy

变暗到 – CFadeTo

由无变亮 – CFadeIn

由亮变无 – CFadeOut

*/
//延时动作
class  CActionInterval : public CFiniteTimeAction
{
public:
//	CActionInterval():m_bIsEnd(false){}
	/** how many seconds had elapsed since the actions started to run. */
	inline fTime GetElapsed(void) { return m_elapsed; }

	/** initializes the action */
	bool InitWithDuration(fTime d);

	/** returns true if the action has finished */
	//动作是否结束
	virtual bool IsDone(void);

// 	virtual CCObject* copyWithZone(CCZone* pZone);

	virtual void Step(fTime dt);
	virtual void StartWithTarget(IActionDelegate *pTarget);

	//反向动作
	virtual CActionInterval* Reverse(void);

public:
	/** creates the action */
	static CActionInterval* ActionWithDuration(fTime d);

public:
    //extension in CCGridAction 
	void SetAmplitudeRate(float amp);
	float GetAmplitudeRate(void);

protected:
	fTime m_elapsed;
	bool   m_bFirstTick;
// private:
	//bool m_bIsEnd;
};

/** @brief Runs actions sequentially, one after another
序列动作
主要作用就是线序排列若干个动作,然后按先后次序逐个执行。
 */
class  CSequence : public CActionInterval
{
public:
	~CSequence(void);

	/** initializes the action */
    bool InitOneTwo(CFiniteTimeAction *pActionOne, CFiniteTimeAction *pActionTwo);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** helper constructor to create an array of sequenceable actions */
	//连续的N个动作,切记:最后一个参数必须设为NULL
	static CFiniteTimeAction* Actions(CFiniteTimeAction *pAction1, ...);
	/** helper contructor to create an array of sequenceable actions given an array */
//	static CFiniteTimeAction* actionsWithArray(CCArray *actions);

	/** creates the action */
	static CSequence* ActionOneTwo(CFiniteTimeAction *pActionOne, CFiniteTimeAction *pActionTwo);
protected:
	CFiniteTimeAction *m_pActions[2];
	fTime m_split;
	int m_last;
};

/** @brief Repeats an action a number of times.
 * To repeat an action forever use the CRepeatForever action.
 重复有限次数 – Repeate
 */
class  CRepeat : public CActionInterval
{
public:
	~CRepeat(void);

	/** initializes a CRepeat action. Times is an unsigned integer between 1 and pow(2,30) 
	pAction:待续时间
	times:重复的次数
	*/
	bool InitWithAction(CFiniteTimeAction *pAction, unsigned int times);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);
	virtual bool IsDone(void);

	//反向动作
	virtual CActionInterval* Reverse(void);

	inline void SetInnerAction(CFiniteTimeAction *pAction)
	{
		if (m_pInnerAction != pAction)
		{
			CC_SAFE_RELEASE(m_pInnerAction);
			m_pInnerAction = pAction;
//			CC_SAFE_RETAIN(m_pInnerAction);
		}
	}

	inline CFiniteTimeAction* GetInnerAction()
	{
		return m_pInnerAction;
	}

public:
	/** creates a CRepeat action. Times is an unsigned integer between 1 and pow(2,30) */
	//pAction重复执行的动作,times执行重复次数
	static CRepeat* ActionWithAction(CFiniteTimeAction *pAction, unsigned int times);

protected:
	unsigned int m_uTimes;
	unsigned int m_uTotal;
	/** Inner action */
	CFiniteTimeAction *m_pInnerAction;
};

/** @brief Repeats an action for ever.
To repeat the an action for a limited number of times use the Repeat action.
@warning This action can't be Sequenceable because it is not an IntervalAction
重复一直循环
*/
class  CRepeatForever : public CActionInterval
{
public:
	CRepeatForever()
		: m_pInnerAction(NULL)
	{}
	virtual ~CRepeatForever();

	/** initializes the action */
	bool InitWithAction(CActionInterval *pAction);

	virtual void StartWithTarget(IActionDelegate* pTarget);
	virtual void Step(fTime dt);
	virtual bool IsDone(void);

	//反向动作
	virtual CActionInterval* Reverse(void);

	inline void SetInnerAction(CActionInterval *pAction)
	{
		if (m_pInnerAction != pAction)
		{
			CC_SAFE_RELEASE(m_pInnerAction);
			m_pInnerAction = pAction;
		//	CC_SAFE_RETAIN(m_pInnerAction);
		}
	}

	inline CActionInterval* GetInnerAction()
	{
		return m_pInnerAction;
	}

public:
	/** creates the action */
	static CRepeatForever* ActionWithAction(CActionInterval *pAction);

protected:
	/** Inner action */
	CActionInterval *m_pInnerAction;
};

/** @brief Spawn a new action immediately
同步 – Spawn  
同时并列执行若干个动作,但要求动作都必须是可以同时执行的。比如:移动式翻转、变色、变大小等。
注意:同步执行最后的完成时间由基本动作中用时最大者决定。
 */
class  CSpawn : public CActionInterval
{
public:
	~CSpawn(void);

	/** initializes the Spawn action with the 2 actions to spawn */
	bool InitOneTwo(CFiniteTimeAction *pAction1, CFiniteTimeAction *pAction2);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** helper constructor to create an array of spawned actions */
	//pAction1,...同步执行的N个动作,最后一个参数必须为NULL
	static CFiniteTimeAction* Actions(CFiniteTimeAction *pAction1, ...);

	/** helper contructor to create an array of spawned actions given an array */
//	static CFiniteTimeAction* actionsWithArray(CCArray *actions);

	/** creates the Spawn action */
	static CSpawn* ActionOneTwo(CFiniteTimeAction *pAction1, CFiniteTimeAction *pAction2);

protected:
	CFiniteTimeAction *m_pOne;
	CFiniteTimeAction *m_pTwo;
};

/** @brief Rotates a IActionDelegate object to a certain angle by modifying it's
 rotation attribute.
 The direction will be decided by the shortest angle.
 自旋转到多少度,按顺时针算多少度
*/ 
class  CRotateTo : public CActionInterval
{
public:
	/** initializes the action */
	bool InitWithDuration(fTime duration, float fDeltaAngle);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** creates the action */
	static CRotateTo* ActionWithDuration(fTime duration, float fDeltaAngle);

protected:
	float m_fDstAngle;
	float m_fStartAngle;
	float m_fDiffAngle;
};

/** @brief Rotates a IActionDelegate object clockwise a number of degrees by modifying it's rotation attribute.
自旋转多少度
*/
class  CRotateBy : public CActionInterval
{
public:
	/** initializes the action */
	//duration:所花时间,fDeltaAngle:转的角度,如90度就填90
    bool InitWithDuration(fTime duration, float fDeltaAngle);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	static CRotateBy* ActionWithDuration(fTime duration, float fDeltaAngle);

protected:
	float m_fAngle;
	float m_fStartAngle;
};

/** @brief Moves a IActionDelegate object to the position x,y. x and y are absolute coordinates by modifying it's position attribute.
移动到一个位置
*/
class  CMoveTo : public CActionInterval
{
public:
	/** initializes the action */
	bool InitWithDuration(fTime duration, const CPoint& position);


// 	virtual CAction* copyWithZone(IActionDelegate* pZone);
	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** creates the action */
	static CMoveTo* ActionWithDuration(fTime duration, const CPoint& position);
protected:
	CPoint m_endPosition;
	CPoint m_startPosition;
	CPoint m_delta;
};

/** @brief Moves a IActionDelegate object x,y pixels by modifying it's position attribute.
 x and y are relative to the position of the object.
 Duration is is seconds.
 移动的相对距离
*/ 
class  CMoveBy : public CMoveTo
{
public:
	/** initializes the action */
	bool InitWithDuration(fTime duration, const CPoint& position);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	static CMoveBy* ActionWithDuration(fTime duration/*执行时间(秒)*/, const CPoint& position);
};

/** Skews a IActionDelegate object to given angles by modifying it's skewX and skewY attributes
扭曲:(未实现)
*/
#if 0
class  CSkewTo : public CActionInterval
{
public:
	CSkewTo();
	virtual bool InitWithDuration(fTime t, float sx, float sy);
	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	static CSkewTo* ActionWithDuration(fTime t, float sx, float sy);

protected:
	float m_fSkewX;
	float m_fSkewY;
	float m_fStartSkewX;
	float m_fStartSkewY;
	float m_fEndSkewX;
	float m_fEndSkewY;
	float m_fDeltaX;
	float m_fDeltaY;
};

/** Skews a IActionDelegate object by skewX and skewY degrees
扭曲:(未实现)
*/
class  CSkewBy : public CSkewTo
{
public:
	virtual bool InitWithDuration(fTime t, float sx, float sy);
	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	static CSkewBy* ActionWithDuration(fTime t, float deltaSkewX, float deltaSkewY);
};
#endif

/** @brief Moves a IActionDelegate object simulating a parabolic jump movement by modifying it's position attribute.
跳跃相对距离
*/
class  CJumpBy : public CActionInterval
{
public:
	/** initializes the action */
	bool InitWithDuration(fTime duration, const CPoint& position, fTime height, unsigned int jumps);

	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	//
	static CJumpBy* ActionWithDuration(fTime duration/*持续时间*/, const CPoint& position/*终点坐标*/, fTime height/*跳跃高度*/, unsigned int jumps/*跳跃次数*/);

protected:
	CPoint			m_startPosition;
	CPoint			m_delta;
	fTime			m_height;
	unsigned int    m_nJumps;
};

/** @brief Moves a IActionDelegate object to a parabolic position simulating a jump movement by modifying it's position attribute.
跳跃到
*/ 
class  CJumpTo : public CJumpBy
{
public:
    virtual void StartWithTarget(IActionDelegate *pTarget);

public:
	/** creates the action */
	static CJumpTo* ActionWithDuration(fTime duration/*持续时间*/, const CPoint& position/*终点坐标*/, fTime height/*跳跃高度*/, int jumps/*跳跃次数*/);
};

/** @typedef bezier configuration structure
 */
typedef struct _ccBezierConfig {
	//! end position of the bezier
	CPoint endPosition;
	//! Bezier control point 1
	CPoint controlPoint_1;
	//! Bezier control point 2
	CPoint controlPoint_2;
} ccBezierConfig;

/** @brief An action that moves the target with a cubic Bezier curve by a certain distance.
贝赛尔曲线运动
 */
class  CBezierBy : public CActionInterval
{
public:
	/** initializes the action with a duration and a bezier configuration */
	bool InitWithDuration(fTime t, const ccBezierConfig& c);

	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action with a duration and a bezier configuration */
	static CBezierBy* ActionWithDuration(fTime t, const ccBezierConfig& c);

protected:
	ccBezierConfig m_sConfig;
	CPoint m_startPosition;
};

/** @brief An action that moves the target with a cubic Bezier curve to a destination point.
贝赛尔曲线运动到,要设置三个点坐标,如
		ccBezierConfig bezier;
		bezier.controlPoint_1 = CPointMake(0, 200);
		bezier.controlPoint_2 = CPointMake(240, 500);
		bezier.endPosition = pos;
		actionTo = CBezierTo::ActionWithDuration(2.0f,bezier);
 */
class  CBezierTo : public CBezierBy
{
public:
    virtual void StartWithTarget(IActionDelegate *pTarget);

public:
	/** creates the action with a duration and a bezier configuration */
    static CBezierTo* ActionWithDuration(fTime t, const ccBezierConfig& c);
};

/** @brief Scales a IActionDelegate object to a zoom factor by modifying it's scale attribute.
 @warning This action doesn't support "reverse"
 精灵放大到的倍数(相对初始的大小:效果是从当前大小变成要放大到的倍数(相对初始的倍数))
 */
class  CScaleTo : public CActionInterval
{
public:
	/** initializes the action with the same scale factor for X and Y */
	bool InitWithDuration(fTime duration, float s);

	/** initializes the action with and X factor and a Y factor */
	bool InitWithDuration(fTime duration, float sx, float sy);

	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** creates the action with the same scale factor for X and Y 
		放大到的倍数
		duration持续时间
		fScaleFactor,放大到的倍数
	*/
	static CScaleTo* ActionWithDuration(fTime duration, float fScaleFactor);

	/** creates the action with and X factor and a Y factor
		放大到的倍数
		duration:持续时间
		fScaleFactorX:X坐标放大到的倍数
		fScaleFactorY:Y坐标放大到的倍数
	*/
	static CScaleTo* ActionWithDuration(fTime duration, float fScaleFactorX, float fScaleFactorY);
protected:
	float m_fScaleX;
	float m_fScaleY;
	float m_fStartScaleX;
  	float m_fStartScaleY;
    float m_fEndScaleX;
	float m_fEndScaleY;
	float m_fDeltaX;
	float m_fDeltaY;
};

/** @brief Scales a IActionDelegate object a zoom factor by modifying it's scale attribute.
精灵放大的倍数(相对现在的大小,如2.0f,就是放大到当前大小的两倍)
*/
class  CScaleBy : public CScaleTo
{
public:
    virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/*
	    creates the action with the same scale factor for X and Y 
		duration:所花时间,
		fScaleFactor:放大的倍数(缩放因子)(如0.5就是缩小一半)
	*/
	static CScaleBy* ActionWithDuration(fTime duration, float fScaleFactor);

	/*
		creates the action with and X factor and a Y factor 
		duration:所花时间,
		fScaleFactor:放大的倍数(缩放因子)(fXScale:X坐标,fYScale:Y坐标)
	*/
	static CScaleBy* ActionWithDuration(fTime duration, float fXScale, float fYScale);
};

/** @brief Blinks a IActionDelegate object by modifying it's visible attribute
闪烁
*/
class  CBlink : public CActionInterval
{
public:
	/**
	initializes the action
	*/
	//duration:闪烁所花的时间,uBlinks:闪烁次数
	bool InitWithDuration(fTime duration, unsigned int uBlinks);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	static CBlink* ActionWithDuration(fTime duration, unsigned int uBlinks);
protected:
	unsigned int m_nTimes;
};


/** @brief Fades In an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 0 to 255.
 The "reverse" of this action is FadeOut
 透明变化:从无到有显示出来
 */
class  CFadeIn : public CActionInterval
{
public:
    virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	static CFadeIn* ActionWithDuration(fTime d);
};

/** @brief Fades Out an object that implements the CCRGBAProtocol protocol. It modifies the opacity from 255 to 0.
 The "reverse" of this action is FadeIn
 透明变化:从有到无,慢慢变没
*/
class  CFadeOut : public CActionInterval
{
public:
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作


public:
	/** creates the action */
	//dTime:执行动作所花的时间
	static CFadeOut* ActionWithDuration(fTime dTime);
};

/** @brief Fades an object that implements the CCRGBAProtocol protocol. It modifies the opacity from the current value to a custom one.
 @warning This action doesn't support "reverse"
 透明变化:变透明到,显示到透明度为X(0-255)
 */
class  CFadeTo : public CActionInterval
{
public:
	/** initializes the action with duration and opacity */
	bool InitWithDuration(fTime duration, GLubyte opacity/*变化到的透明度值,0-255,如90就是RGB的每个颜色变为原值的90/255倍*/);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** creates an action with duration and opacity */
	static CFadeTo* ActionWithDuration(fTime duration, GLubyte opacity);

protected:
	GLubyte m_toOpacity;
	GLubyte m_fromOpacity;
};

/** @brief Tints a IActionDelegate that implements the CCNodeRGB protocol from current tint to a custom one.
 @warning This action doesn't support "reverse"
 颜色变化:颜色变化到X(RGB的值)
*/
class  CTintTo : public CActionInterval
{
public:
	/** initializes the action with duration and color */
	bool InitWithDuration(fTime duration, GLubyte red, GLubyte green, GLubyte blue);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** creates an action with duration and color
	duration:用时
	//要变化的RGB颜色值大小,如27, 55, -27
	*/
	static CTintTo* ActionWithDuration(fTime duration, GLubyte red, GLubyte green, GLubyte blue);

protected:
	Color3B m_to;
	Color3B m_from;
};

/** @brief Tints a IActionDelegate that implements the CCNodeRGB protocol from current tint to a custom one 
颜色变化:颜色变化了多少(RGB的值,负号-代表减去多少值)
 */
class  CTintBy : public CActionInterval
{
public:
	/** initializes the action with duration and color */
	bool InitWithDuration(fTime duration, GLshort deltaRed, GLshort deltaGreen, GLshort deltaBlue);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

	//反向动作
	virtual CActionInterval* Reverse(void);

public:
	/** creates an action with duration and color */
	static CTintBy* ActionWithDuration(fTime duration, GLshort deltaRed, GLshort deltaGreen, GLshort deltaBlue);//变化到的RGB颜色值,如-127, -255, -127

protected:
	GLshort m_deltaR;
	GLshort m_deltaG;
	GLshort m_deltaB;

	GLshort m_fromR;
	GLshort m_fromG;
	GLshort m_fromB;
};

/** @brief Delays the action a certain amount of seconds
延迟时间的动作(什么动作都不做,停住一定的时间)
*/
class  CDelayTime : public CActionInterval
{
public:
//	CDelayTime(){m_bIsEnd=false;}
	virtual void Update(fTime time);
	
	//void end();
	//反向动作
	virtual CActionInterval* Reverse(void);


public:
	/** creates the action 
	*/
	static CDelayTime* ActionWithDuration(fTime d/*要延时的时间*/);

};

/** @brief Executes an action in reverse order, from time=duration to time=0
 
 @warning Use this action carefully. This action is not
 sequenceable. Use it as the default "reversed" method
 of your own actions, but using it outside the "reversed"
 scope is not recommended.
 时间逆向(暂时没有用到)
*/
class  CReverseTime : public CActionInterval
{
public:
	~CReverseTime(void);
	CReverseTime();

	/** initializes the action */
    bool InitWithAction(CFiniteTimeAction *pAction);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);
	virtual CActionInterval* Reverse(void);//反向动作

public:
	/** creates the action */
	static CReverseTime* ActionWithAction(CFiniteTimeAction *pAction);

protected:
	CFiniteTimeAction *m_pOther;
};

#define CAnimation CSprite
//动画
/** @brief Animates a sprite given the name of an Animation */
class  CAnimate : public CActionInterval
{
public:
	~CAnimate(void);
	/** Get animation used for the animate */
	inline CAnimation* GetAnimation(void) { return m_pAnimation; }
	/** Set animation used for the animate, the object is retained */
	inline void SetAnimation(CAnimation *pAnimation) 
	{
//		CC_SAFE_RETAIN(pAnimation);
		CC_SAFE_RELEASE(m_pAnimation);
		m_pAnimation = pAnimation;
	}

	/** initializes the action with an Animation and will restore the original frame when the animation is over */
    bool InitWithAnimation(CAnimation *pAnimation);

	/** initializes the action with an Animation */
	bool InitWithAnimation(CAnimation *pAnimation, bool bRestoreOriginalFrame);

	/** initializes an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
	 The 'delay' parameter of the animation will be overridden by the duration parameter.

	 */
	bool InitWithDuration(fTime duration, CAnimation *pAnimation, bool bRestoreOriginalFrame);


	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Stop(void);
	virtual void Update(fTime time);

	//反向动作
	virtual CActionInterval* Reverse(void);

public:
	/** creates the action with an Animation and will restore the original frame when the animation is over */
	static CAnimate* ActionWithAnimation(CAnimation *pAnimation);

	/** creates the action with an Animation */
	static CAnimate* ActionWithAnimation(CAnimation *pAnimation, bool bRestoreOriginalFrame);

	/** creates an action with a duration, animation and depending of the restoreOriginalFrame, it will restore the original frame or not.
	 The 'delay' parameter of the animation will be overridden by the duration parameter.
	duration:每一帧动画持续时间,
	pAnimation:精灵CMySprite
	bRestoreOriginalFrame:动画结束后,是否恢复到默认的第一帧动画
	 */	
     static CAnimate* ActionWithDuration(fTime duration, CAnimation *pAnimation, bool bRestoreOriginalFrame=false/*动画结束后,是否恢复到默认的第一帧动画*/);
protected:
	CAnimation *m_pAnimation;
    bool m_bRestoreOriginalFrame;
};


#endif //__ACTION_CCINTERVAL_ACTION_H__

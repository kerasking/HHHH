/**
  动作和精灵类常用的定义
  Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
**/
#ifndef __COCOS_CGGEMETRY_H__
#define __COCOS_CGGEMETRY_H__
#include "C3Primitive.h"
#include "FrameworkTypes.h"

#define MIN     min
#define MAX     max

//时间
#define  fTime float

#if ! defined(_USE_MATH_DEFINES)
#define _USE_MATH_DEFINES       // make M_PI can be use
#endif

/** PROPERTY_READONLY is used to declare a protected variable.
 We can use getter to read the variable.
 @param varType : the type of variable.
 @param varName : variable name.
 @param funName : "get + funName" is the name of the getter.
 @warning : The getter is a public virtual function, you should rewrite it first.
 The variables and methods declared after PROPERTY_READONLY are all public.
 If you need protected or private, please declare.
 */
#define PROPERTY_READONLY(varType, varName, funName)\
protected: varType varName;\
public: virtual varType Get##funName(void);

#define PROPERTY_READONLY_PASS_BY_REF(varType, varName, funName)\
protected: varType varName;\
public: virtual const varType& Get##funName(void);

/** PROPERTY is used to declare a protected variable.
 We can use getter to read the variable, and use the setter to change the variable.
 @param varType : the type of variable.
 @param varName : variable name.
 @param funName : "get + funName" is the name of the getter.
 "set + funName" is the name of the setter.
 @warning : The getter and setter are public virtual functions, you should rewrite them first.
 The variables and methods declared after PROPERTY are all public.
 If you need protected or private, please declare.
 */
#define PROPERTY(varType, varName, funName)\
protected: varType varName;\
public: virtual varType Get##funName(void);\
public: virtual void Set##funName(varType var);

#define PROPERTY_PASS_BY_REF(varType, varName, funName)\
protected: varType varName;\
public: virtual const varType& Get##funName(void);\
public: virtual void Set##funName(const varType& var);

/** SYNTHESIZE_READONLY is used to declare a protected variable.
 We can use getter to read the variable.
 @param varType : the type of variable.
 @param varName : variable name.
 @param funName : "get + funName" is the name of the getter.
 @warning : The getter is a public inline function.
 The variables and methods declared after SYNTHESIZE_READONLY are all public.
 If you need protected or private, please declare.
 */
#define SYNTHESIZE_READONLY(varType, varName, funName)\
protected: varType varName;\
public: inline varType Get##funName(void) const { return varName; }

#define SYNTHESIZE_READONLY_PASS_BY_REF(varType, varName, funName)\
protected: varType varName;\
public: inline const varType& Get##funName(void) const { return varName; }


#define SYNTHESIZE_PASS_BY_REF(varType, varName, funName)\
protected: varType varName;\
public: inline const varType& Get##funName(void) const { return varName; }\
public: inline void Set##funName(const varType& var){ varName = var; }

#define CC_SAFE_DELETE(p)			if(p) { delete p; p = 0; }
#define CC_SAFE_DELETE_ARRAY(p)    if(p) { delete[] p; p = 0; }
#define CC_SAFE_FREE(p)			if(p) { free(p); p = 0; }
#define CC_SAFE_RELEASE(p) //  if(p) { p->Release();}
#define CC_SAFE_RELEASE_NULL(p)//	if(p) { p = 0; p->Release(); }
#define CC_SAFE_RETAIN(p)		//	if(p) { p->Retain(); }
#define BREAK_IF(cond)			if(cond) break;



/** @def RANDOM_MINUS1_1
 returns a random float between -1 and 1
 */
#define RANDOM_MINUS1_1() ((2.0f*((float)rand()/RAND_MAX))-1.0f)

/** @def RANDOM_0_1
 returns a random float between 0 and 1
 */
#define RANDOM_0_1() ((float)rand()/RAND_MAX)

/** @def DEGREES_TO_RADIANS
 converts degrees to radians
 */
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180

/** @def RADIANS_TO_DEGREES
 converts radians to degrees
 */
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180


#define CPointMake(x, y) CPoint((x), (y))

#define CSizeMake(width, height) CSize((width), (height))

#define CRectMake(left, top, right, bottom) CRect((left), (top), (right), (bottom))


const CPoint CPointZero = CPoint(0,0);

/* The "zero" size -- equivalent to CCSizeMake(0, 0). */ 
const CSize CSizeZero = CSizeMake(0,0);

/* The "zero" rectangle -- equivalent to CCRectMake(0, 0, 0, 0). */ 
const CRect CRectZero = CRectMake(0,0,0,0);

#endif // __COCOS_CGGEMETRY_H__

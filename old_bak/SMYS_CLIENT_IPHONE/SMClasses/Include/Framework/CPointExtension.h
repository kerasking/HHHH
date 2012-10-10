#ifndef __SUPPORT_CGPOINTEXTENSION_H__
#define __SUPPORT_CGPOINTEXTENSION_H__

#include "C3Primitive.h"
#include <math.h>
#include "CGeometry.h"

/** @def CC_SWAP
simple macro that swaps 2 variables
*/
#define CC_SWAP(x, y, type)	\
{	type temp = (x);		\
	x = y; y = temp;		\
}

/**
 @file
 CPoint extensions based on Chipmunk's cpVect file.
 These extensions work both with CPoint and cpVect.
 
 The "ccp" prefix means: "CoCos2d Point"
 
 Examples:
  - ccpAdd( ccp(1,1), ccp(2,2) ); // preferred cocos2d way
  - ccpAdd( CPointMake(1,1), CPointMake(2,2) ); // also ok but more verbose
  
  - cpvadd( cpv(1,1), cpv(2,2) ); // way of the chipmunk
  - ccpAdd( cpv(1,1), cpv(2,2) ); // mixing chipmunk and cocos2d (avoid)
  - cpvadd( CPointMake(1,1), CPointMake(2,2) ); // mixing chipmunk and CG (avoid)
 */


/** Helper macro that creates a CPoint
 @return CPoint
 
 */
#define ccp(__X__,__Y__) CPointMake((int)(__X__), (int)(__Y__))

/** Returns opposite of point.
 @return CPoint
 
 */
static inline CPoint
ccpNeg(const CPoint& v)
{
	return ccp(-v.x, -v.y);
}

/** Calculates sum of two points.
 @return CPoint
 
 */
static inline CPoint
ccpAdd(const CPoint& v1, const CPoint& v2)
{
	return ccp(v1.x + v2.x, v1.y + v2.y);
}

/** Calculates difference of two points.
 @return CPoint
 
 */
static inline CPoint
ccpSub(const CPoint& v1, const CPoint& v2)
{
	return ccp(v1.x - v2.x, v1.y - v2.y);
}

/** Returns point multiplied by given factor.
 @return CPoint
 
 */
static inline CPoint
ccpMult(const CPoint& v, const float s)
{
	return ccp(v.x*s, v.y*s);
}

/** Calculates midpoint between two points.
 @return CPoint
 
 */
static inline CPoint
ccpMidpoint(const CPoint& v1, const CPoint& v2)
{
	return ccpMult(ccpAdd(v1, v2), 0.5f);
}

/** Calculates perpendicular of v, rotated 90 degrees counter-clockwise -- cross(v, perp(v)) >= 0
 @return CPoint
 
 */
static inline CPoint
ccpPerp(const CPoint& v)
{
	return ccp(-v.y, v.x);
}

/** Calculates perpendicular of v, rotated 90 degrees clockwise -- cross(v, rperp(v)) <= 0
 @return CPoint
 
 */
static inline CPoint
ccpRPerp(const CPoint& v)
{
	return ccp(v.y, -v.x);
}

/** Rotates two points.
 @return CPoint
 
 */
static inline CPoint
ccpRotate(const CPoint& v1, const CPoint& v2)
{
	return ccp(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

/** Unrotates two points.
 @return CPoint
 
 */
static inline CPoint
ccpUnrotate(const CPoint& v1, const CPoint& v2)
{
	return ccp(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

/** Calculates distance between point an origin
 @return float
 
 */
float  ccpLength(const CPoint& v);

/** Calculates the distance between two points
 @return float
 
 */
float  ccpDistance(const CPoint& v1, const CPoint& v2);

/** Returns point multiplied to a length of 1.
 @return CPoint
 
 */
CPoint  ccpNormalize(const CPoint& v);

/** Converts radians to a normalized vector.
 @return CPoint
 
 */
CPoint  ccpForAngle(const float a);

/** Converts a vector to radians.
 @return float
 
 */
float  ccpToAngle(const CPoint& v);


/** Clamp a value between from and to.
 
 */
float  clampf(float value, float min_inclusive, float max_inclusive);

/** Clamp a point between from and to.
 
 */
CPoint  ccpClamp(const CPoint& p, const CPoint& from, const CPoint& to);

/** Quickly convert CSize to a CPoint
 
 */
CPoint  ccpFromSize(const CSize& s);

/** Run a math operation function on each point component
 * absf, fllorf, ceilf, roundf
 * any function that has the signature: float func(float);
 * For example: let's try to take the floor of x,y
 * ccpCompOp(p,floorf);
 
 */
CPoint  ccpCompOp(const CPoint& p, float (*opFunc)(float));

/** Linear Interpolation between two points a and b
 @returns
	alpha == 0 ? a
	alpha == 1 ? b
	otherwise a value between a..b
 
 */
CPoint  ccpLerp(const CPoint& a, const CPoint& b, float alpha);


/** @returns if points have fuzzy equality which means equal with some degree of variance.
 
 */
bool  ccpFuzzyEqual(const CPoint& a, const CPoint& b, float variance);


/** Multiplies a nd b components, a.x*b.x, a.y*b.y
 @returns a component-wise multiplication
 
 */
CPoint  ccpCompMult(const CPoint& a, const CPoint& b);

/** @returns the signed angle in radians between two vector directions
 
 */
float  ccpAngleSigned(const CPoint& a, const CPoint& b);

/** @returns the angle in radians between two vector directions
 
*/
float  ccpAngle(const CPoint& a, const CPoint& b);

/** Rotates a point counter clockwise by the angle around a pivot
 @param v is the point to rotate
 @param pivot is the pivot, naturally
 @param angle is the angle of rotation cw in radians
 @returns the rotated point
 
 */
CPoint  ccpRotateByAngle(const CPoint& v, const CPoint& pivot, float angle);

/** A general line-line intersection test
 @param p1 
	is the startpoint for the first line P1 = (p1 - p2)
 @param p2 
	is the endpoint for the first line P1 = (p1 - p2)
 @param p3 
	is the startpoint for the second line P2 = (p3 - p4)
 @param p4 
	is the endpoint for the second line P2 = (p3 - p4)
 @param s 
	is the range for a hitpoint in P1 (pa = p1 + s*(p2 - p1))
 @param t
	is the range for a hitpoint in P3 (pa = p2 + t*(p4 - p3))
 @return bool 
	indicating successful intersection of a line
	note that to truly test intersection for segments we have to make 
	sure that s & t lie within [0..1] and for rays, make sure s & t > 0
	the hit point is		p3 + t * (p4 - p3);
	the hit point also is	p1 + s * (p2 - p1);
 
 */
bool  ccpLineIntersect(const CPoint& p1, const CPoint& p2, 
					  const CPoint& p3, const CPoint& p4,
					  float *s, float *t);

/*
ccpSegmentIntersect returns YES if Segment A-B intersects with segment C-D

*/
bool  ccpSegmentIntersect(const CPoint& A, const CPoint& B, const CPoint& C, const CPoint& D);

/*
ccpIntersectPoint returns the intersection point of line A-B, C-D

*/
CPoint  ccpIntersectPoint(const CPoint& A, const CPoint& B, const CPoint& C, const CPoint& D);


#endif // __SUPPORT_CGPOINTEXTENSION_H__


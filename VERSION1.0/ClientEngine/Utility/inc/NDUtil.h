/*
*
*/

#ifndef NDUTIL_H
#define NDUTIL_H

#include "define.h"

NS_NDENGINE_BGN

#define MAP_UNITSIZE (16 * ((int)(NDDirector::DefaultDirector()->GetScaleFactor())))
#define SCREEN_SCALE (NDDirector::DefaultDirector()->GetScaleFactor())

bool IsPointInside(CGPoint kPoint, CGRect kRect);

NS_NDENGINE_END

#endif
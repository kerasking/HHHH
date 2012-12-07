/*
*
*/

#ifndef NDUTIL_H
#define NDUTIL_H

#include "define.h"
#include "CCGeometry.h"

NS_NDENGINE_BGN

//Ëõ·ÅÏµÊý
#define SCREEN_SCALE					(NDDirector::DefaultDirector()->GetScaleFactor())

bool IsPointInside(cocos2d::CCPoint kPoint, cocos2d::CCRect kRect);

//const char* GetSMImgPath(const char* name);


NS_NDENGINE_END

#endif
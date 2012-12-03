/*
*
*/

#ifndef NDUTIL_H
#define NDUTIL_H

#include "define.h"
#include "NDPath.h"
#include "CCGeometry.h"

NS_NDENGINE_BGN

//缩放系数
#define SCREEN_SCALE					(NDDirector::DefaultDirector()->GetScaleFactor())

bool IsPointInside(cocos2d::CCPoint kPoint, cocos2d::CCRect kRect);

//const char* GetSMImgPath(const char* name);


//格子相关的宏定义
//---------------------------------------------------------------------------------------------------------<<
//格子尺寸（像素）
#define MAP_UNITSIZE					(16 * ((int)(NDDirector::DefaultDirector()->GetScaleFactor())))

//角色显示时相对于Cell的偏移
#define DISPLAY_POS_X_OFFSET			(MAP_UNITSIZE / 2)
#define DISPLAY_POS_Y_OFFSET			(MAP_UNITSIZE)

//--------------------------------------------------------------------------------------------------------->>

NS_NDENGINE_END

#endif
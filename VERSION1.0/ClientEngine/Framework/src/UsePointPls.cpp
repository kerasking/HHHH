//
//  UsePointPls.cpp
//  use point coordinate please.
//
//  Created by zhangwq on 2012-11-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	说明：
//	引用层涉及坐标时（顶点坐标、纹理坐标）不要使用像素概念，
//	统一使用Point概念（可理解为GL坐标单位，世界坐标单位），
//	使用Point则引擎会自动适应多分辨率！
//

#include "UsePointPls.h"
#include "CCDirector.h"
#include "NDDirector.h"
#include "CCPointExtension.h"

USING_NS_CC;

NS_NDENGINE_BGN

//Pixel -> Point
void ConvertUtil::convertToPointCoord( CCPoint& pt )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		pt.x /= fScale;
		pt.y /= fScale;
	}
#endif
}

//Pixel -> Point
void ConvertUtil::convertToPointCoord( cocos2d::CCSize& sz )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		sz.width /= fScale;
		sz.height /= fScale;
	}
#endif
}

//Pixel -> Point
void ConvertUtil::convertToPointCoord( cocos2d::CCRect& rc )
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		rc.origin.x /= fScale;
		rc.origin.y /= fScale;
		rc.size.width /= fScale;
		rc.size.height /= fScale;
	}
#endif
}

//Point -> Pixel
void ConvertUtil::convertToPixelCoord( CCPoint& pt )
{
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		pt.x *= fScale;
		pt.y *= fScale;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android //@todo
#endif
}

//Point -> Pixel
void ConvertUtil::convertToPixelCoord( CCSize& sz )
{
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		sz.width *= fScale;
		sz.height *= fScale;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android //@todo
#endif
}

//Point -> Pixel
void ConvertUtil::convertToPixelCoord( CCRect& rc )
{
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	if (fScale != 0) {
		rc.origin.x *= fScale;
		rc.origin.y *= fScale;
		rc.size.width *= fScale;
		rc.size.height *= fScale;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android //@todo
#endif
}

//返回贴图逻辑点尺寸
CCSize ConvertUtil::getTextureSizeInPoints( /*const*/ cocos2d::CCTexture2D& tex )
{
	float fScale = CCDirector::sharedDirector()->getContentScaleFactor();
	return CCSizeMake( 
		tex.getPixelsWide() / fScale,
		tex.getPixelsHigh() / fScale );
}



//Pixel -> Point
void ConvertUtil::convertToPointCoord_Android( CCPoint& pt )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	pt.x *= getAndroidScale().x;
	pt.y *= getAndroidScale().y;
#endif
}

//Pixel -> Point
void ConvertUtil::convertToPointCoord_Android( cocos2d::CCSize& sz )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	sz.width	*= getAndroidScale().x;
	sz.height	*= getAndroidScale().y;
#endif
}

//@android
//Pixel -> Point
void ConvertUtil::convertToPointCoord_Android( cocos2d::CCRect& rc )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	rc.origin.x		*= getAndroidScale().x;
	rc.origin.y		*= getAndroidScale().y;
	rc.size.width	*= getAndroidScale().x;
	rc.size.height	*= getAndroidScale().y;
#endif
}

//格子坐标 -> 显示坐标
CCPoint ConvertUtil::convertCellToDisplay( const int cellX, const int cellY )
{
	return ccp( cellX * MAP_UNITSIZE_X + DISPLAY_POS_X_OFFSET,
				cellY * MAP_UNITSIZE_Y + DISPLAY_POS_Y_OFFSET);
}

//显示坐标 -> 格子坐标
CCPoint ConvertUtil::convertDisplayToCell( const CCPoint& display )
{
	return ccp( (display.x - DISPLAY_POS_X_OFFSET) / MAP_UNITSIZE_X,
				(display.y - DISPLAY_POS_Y_OFFSET) / MAP_UNITSIZE_Y);
}

//格子坐标 -> 屏幕坐标
CCPoint ConvertUtil::convertCellToScreen( const int cellX, const int cellY )
{
	return ccp( cellX * MAP_UNITSIZE_X, cellY * MAP_UNITSIZE_Y );
}

//屏幕坐标 -> 格子坐标
CCPoint ConvertUtil::convertScreenToCell( const CCPoint& screen )
{
	return ccp( screen.x / MAP_UNITSIZE_X, screen.y / MAP_UNITSIZE_Y );
}

//格子坐标 -> 显示坐标 （X）
float ConvertUtil::convertCellToDisplayX( const int cellX )
{
	return (float) cellX * MAP_UNITSIZE_X + DISPLAY_POS_X_OFFSET;
}

//格子坐标 -> 显示坐标 （Y）
float ConvertUtil::convertCellToDisplayY( const int cellY )
{
	return (float) cellY * MAP_UNITSIZE_Y + DISPLAY_POS_Y_OFFSET;
}

//取格子尺寸
CCSize ConvertUtil::getCellSize()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	float fScale = getAndroidScale().y; //以Y方向优先，维持高宽比，等比缩放
	return CCSizeMake( 32 * fScale, 32 * fScale );
#else
	float fSize = 16 * CCDirector::sharedDirector()->getContentScaleFactor();
	return CCSizeMake( fSize, fSize );
#endif
}

//@android
CCPoint ConvertUtil::getAndroidScale()
{
	return NDDirector::DefaultDirector()->getAndroidScale();
}

NS_NDENGINE_END

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
	pt.x *= NDDirector::DefaultDirector()->getAndroidScale().x;
	pt.y *= NDDirector::DefaultDirector()->getAndroidScale().y;
#endif
}

//Pixel -> Point
void ConvertUtil::convertToPointCoord_Android( cocos2d::CCSize& sz )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	sz.width	*= NDDirector::DefaultDirector()->getAndroidScale().x;
	sz.height	*= NDDirector::DefaultDirector()->getAndroidScale().y;
#endif
}

//@android
//Pixel -> Point
void ConvertUtil::convertToPointCoord_Android( cocos2d::CCRect& rc )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //@android
	rc.origin.x		*= NDDirector::DefaultDirector()->getAndroidScale().x;
	rc.origin.y		*= NDDirector::DefaultDirector()->getAndroidScale().y;
	rc.size.width	*= NDDirector::DefaultDirector()->getAndroidScale().x;
	rc.size.height	*= NDDirector::DefaultDirector()->getAndroidScale().y;
#endif
}


NS_NDENGINE_END

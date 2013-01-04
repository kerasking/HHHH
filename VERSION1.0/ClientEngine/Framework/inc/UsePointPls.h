//
//  UsePointPls.h
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

#pragma once

#include "define.h"
#include "CCGeometry.h"
#include "CCTexture2D.h"
#include "NDUtil.h"

USING_NS_CC;

NS_NDENGINE_BGN

class ConvertUtil
{
public:
	// pixel -> point (仅用于android) 备注：分一套出来比较保险.
	static void convertToPointCoord_Android( CCPoint& pt );
	static void convertToPointCoord_Android( CCSize& sz );
	static void convertToPointCoord_Android( CCRect& rc );

	// pixel -> point
	static void convertToPointCoord( CCPoint& pt );
	static void convertToPointCoord( CCSize& sz );
	static void convertToPointCoord( CCRect& rc );

	// point -> pixel
	static void convertToPixelCoord( CCPoint& pt );
	static void convertToPixelCoord( CCSize& sz );
	static void convertToPixelCoord( CCRect& rc );

	static CCSize getTextureSizeInPoints( /*const*/ CCTexture2D& tex );

public: //格子坐标相关转换 @cell

	//格子坐标 -> 显示坐标
	static CCPoint convertCellToDisplay( const int cellX, const int cellY );

	//显示坐标 -> 格子坐标
	static CCPoint convertDisplayToCell( const CCPoint& display );

	//格子坐标 -> 屏幕坐标
	static CCPoint convertCellToScreen( const int cellX, const int cellY );

	//屏幕坐标 -> 格子坐标
	static CCPoint convertScreenToCell( const CCPoint& screen );

	//格子坐标 -> 显示坐标 （拆分开转换）
	static float convertCellToDisplayX( const int cellX );
	static float convertCellToDisplayY( const int cellY );

public:
	static CCSize getCellSize();

public: //@android
	static CCPoint getAndroidScale();
	static float getIosScale();
};

//之前的格子是方格（即等宽等高），考虑到android平台多分辨率，MAP_UNITSIZE应拆分为xy两个分量.

#define MAP_UNITSIZE_X				(ConvertUtil::getCellSize().width)
#define MAP_UNITSIZE_Y				(ConvertUtil::getCellSize().height)

//角色显示时相对于Cell的偏移
#define DISPLAY_POS_X_OFFSET		(MAP_UNITSIZE_X / 2)
#define DISPLAY_POS_Y_OFFSET		(MAP_UNITSIZE_Y)

//android缩放比例（以Y为主）
#define ANDROID_SCALE				(ConvertUtil::getAndroidScale().y)

#define IOS_SCALE					(ConvertUtil::getIosScale())

NS_NDENGINE_END
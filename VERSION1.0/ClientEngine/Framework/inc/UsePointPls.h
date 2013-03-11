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
#include "NDDirector.h"

USING_NS_CC;

//-----------------------------------------------------------------------------------------------------------
//	***	资源缩放比例 & 字体缩放比例	***
//
//	备注：这些比例已经考虑到了ios & android的差异.
//	举例：
//		分辨率480*320		scale=1
//		分辨率960*640		scale=2
//		分辨率800*480		scale=1.5（以Y为主）

//资源缩放比例&字体缩放比例（一般相同）
//备注：以"_960"结尾的宏，表示基于960*640，否则基于480*320
//		提供两套宏，避免在代码中出现乘2除2的.

/** 【资源缩放比例】 */
#define RESOURCE_SCALE		(NDDirector::DefaultDirector()->getResourceScale())			//基于480*320
#define RESOURCE_SCALE_INT	int(RESOURCE_SCALE)											//基于480*320
#define RESOURCE_SCALE_960	(0.5f * RESOURCE_SCALE)										//基于960*640

/** 【坐标缩放比例】 */
#define COORD_SCALE_X_960	(NDDirector::DefaultDirector()->getCoordScaleX())			//基于960*640
#define COORD_SCALE_Y_960	(NDDirector::DefaultDirector()->getCoordScaleY())			//基于960*640
#define COORD_SCALE_X		(COORD_SCALE_X_960 * 2.0f)									//基于480*320
#define COORD_SCALE_Y		(COORD_SCALE_Y_960 * 2.0f)									//基于480*320

/** 【字体缩放比例】 */
#define FONT_SCALE			RESOURCE_SCALE												//基于480*320
#define FONT_SCALE_INT		int(FONT_SCALE)												//基于480*320

#define FONT_SCALE_X		(COORD_SCALE_X)											//基于480*320（字体缩放以X方向为基准）
#define FONT_SCALE_DRAMA	(FONT_SCALE_X > 2 ? 2 : FONT_SCALE_X)					//基于480*320

//-----------------------------------------------------------------------------------------------------------

#define IPHONE5_POINT_SIZE_WIDTH	568



NS_NDENGINE_BGN
class ConvertUtil
{
public:
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
	static CCPoint convertDisplayToCell( const CCPoint& display, bool bAligned = false );

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

public:
	static bool		is_iphone5();
	static float	get_iphone5_width_scale_for_ui_480_based();
};

//-----------------------------------------------------------------------------------------------------------

//之前的格子是方格（即等宽等高），考虑到android平台多分辨率，MAP_UNITSIZE应拆分为xy两个分量.
#define MAP_UNITSIZE_X				int(ConvertUtil::getCellSize().width)
#define MAP_UNITSIZE_Y				int(ConvertUtil::getCellSize().height)

//角色显示时相对于Cell的偏移
#define DISPLAY_POS_X_OFFSET		(MAP_UNITSIZE_X / 2)
#define DISPLAY_POS_Y_OFFSET		(MAP_UNITSIZE_Y)

//-----------------------------------------------------------------------------------------------------------

#define IS_IPHONE5					(ConvertUtil::is_iphone5())
#define IPHONE5_WIDTH_SCALE			(ConvertUtil::get_iphone5_width_scale_for_ui_480_based())

NS_NDENGINE_END
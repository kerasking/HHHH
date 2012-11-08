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

USING_NS_CC;

NS_NDENGINE_BGN

class ConvertUtil
{
public:
	static void convertToPointCoord( CCSize& sz );
	static void convertToPointCoord( CCRect& rc );
	static CCSize getTextureSizeInPoints( /*const*/ CCTexture2D& tex );
};

NS_NDENGINE_END
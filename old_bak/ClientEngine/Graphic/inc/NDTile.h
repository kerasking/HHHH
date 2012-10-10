//
//  NDTile.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _ND_TILE_H_
#define _ND_TILE_H_

#include "CCTexture2D.h"

typedef enum
{
	NDRotationEnumRotation0,	//不旋转
	NDRotationEnumRotation15,	//顺时针旋转15
	NDRotationEnumRotation30,	//顺时针旋转30
	NDRotationEnumRotation45,	//顺时针旋转45
	NDRotationEnumRotation60,	//顺时针旋转60
	NDRotationEnumRotation75,	//顺时针旋转75
	NDRotationEnumRotation90,	//顺时针旋转90
	NDRotationEnumRotation105,	//顺时针旋转105
	NDRotationEnumRotation120,	//顺时针旋转120
	NDRotationEnumRotation135,	//顺时针旋转135
	NDRotationEnumRotation150,	//顺时针旋转150
	NDRotationEnumRotation165,	//顺时针旋转165
	NDRotationEnumRotation180,	//顺时针旋转180
	NDRotationEnumRotation195,	//顺时针旋转195
	NDRotationEnumRotation210,	//顺时针旋转210
	NDRotationEnumRotation225,	//顺时针旋转225
	NDRotationEnumRotation240,	//顺时针旋转240
	NDRotationEnumRotation255,	//顺时针旋转255
	NDRotationEnumRotation270,	//顺时针旋转270
	NDRotationEnumRotation285,	//顺时针旋转285
	NDRotationEnumRotation300,	//顺时针旋转300
	NDRotationEnumRotation315,	//顺时针旋转315
	NDRotationEnumRotation330,	//顺时针旋转330
	NDRotationEnumRotation345,	//顺时针旋转345
	NDRotationEnumRotation360,	//顺时针旋转360
}NDRotationEnum;

void TileSetHightLight(bool bHightLight);
bool IsTileHightLight();

class NDTile : public cocos2d::CCObject 
{
	CC_SYNTHESIZE_RETAIN(CCTexture2D*, m_Texture, Texture)
	CC_PROPERTY(CGRect, m_CutRect, CutRect)
	CC_PROPERTY(CGRect, m_DrawRect, DrawRect)
	CC_PROPERTY(bool, m_bReverse, Reverse)
	CC_PROPERTY(NDRotationEnum, m_Rotation, Rotation)
	CC_PROPERTY(CGSize, m_MapSize, MapSize)

public:
	void make();
	void draw();
	void drawSubRect(CGRect rect);
	void makeTex(float* pData);
	void makeVetex(float* pData, CGRect rect);

private:
	float *m_vertices;
	float *m_coordinates;
};
@property (nonatomic, retain)CCTexture2D *texture;
@property (nonatomic, assign)CGRect cutRect;
@property (nonatomic, assign)CGRect drawRect;
@property (nonatomic, assign)BOOL reverse;
@property (nonatomic, assign)NDRotationEnum rotation;
@property (nonatomic, assign)CGSize mapSize;

- (void)make;
- (void)draw;
- (void)drawSubRect:(CGRect) rect;
- (void)makeTex:(float*)pData;
- (void)makeVetex:(float*)pData Rect:(CGRect)rect;
@end

#endif
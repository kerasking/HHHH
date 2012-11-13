//
//  NDTile.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_TILE_H_
#define _ND_TILE_H_

#include "Utility.h"
#include "CCTexture2D.h"
#include "CCDirector.h"
#include "shaders/ccGLStateCache.h"
#include "shaders/ccGLProgram.h"
#include "ccTypes.h"
#include "CCPlatformMacros.h"
#include "UsePointPls.h"

USING_NS_CC;
using namespace NDEngine;

typedef enum
{
	NDRotationEnumRotation0,
	NDRotationEnumRotation15,
	NDRotationEnumRotation30,
	NDRotationEnumRotation45,
	NDRotationEnumRotation60,
	NDRotationEnumRotation75,
	NDRotationEnumRotation90,
	NDRotationEnumRotation105,
	NDRotationEnumRotation120,
	NDRotationEnumRotation135,
	NDRotationEnumRotation150,
	NDRotationEnumRotation165,
	NDRotationEnumRotation180,
	NDRotationEnumRotation195,
	NDRotationEnumRotation210,
	NDRotationEnumRotation225,
	NDRotationEnumRotation240,
	NDRotationEnumRotation255,
	NDRotationEnumRotation270,
	NDRotationEnumRotation285,
	NDRotationEnumRotation300,
	NDRotationEnumRotation315,
	NDRotationEnumRotation330,
	NDRotationEnumRotation345,
	NDRotationEnumRotation360,
}NDRotationEnum;

void TileSetHightLight(bool bHightLight);
bool IsTileHightLight();


//////////////////////////////////////////////////////////////////////////////
class NDTile : public cocos2d::CCObject 
{
	CC_SYNTHESIZE_RETAIN(cocos2d::CCTexture2D*, m_pkTexture, Texture)
	CC_SYNTHESIZE(bool, m_bReverse, Reverse)
	CC_SYNTHESIZE(NDRotationEnum, m_Rotation, Rotation)
	CC_SYNTHESIZE(CGSize, m_kMapSize, MapSize)
	CC_SYNTHESIZE(CGRect, m_kCutRect, CutRect)
	CC_SYNTHESIZE(CGRect, m_kDrawRect, DrawRect)

public:
	NDTile();
	~NDTile();

	void make();
	void draw();
	void drawSubRect(CGRect kRect);
	void makeTex(float* pData);
	void makeVetex(float* pData, CGRect kRect);

public: //@shader
	CC_SYNTHESIZE_RETAIN(CCGLProgram*, m_pShaderProgram, ShaderProgram);
	CC_SYNTHESIZE(ccGLServerState, m_glServerState, GLServerState);

protected:
	void DrawSetup( const char* shaderType = kCCShader_PositionTextureColor );
	virtual void debugDraw();
	CGRect getDrawRectInPoints();

private:

	float m_pfVertices[12];
	float m_pfCoordinates[8];
};

#endif
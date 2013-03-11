//
//  NDTile.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDTile.h"
#include "shaders/CCShaderCache.h"
#include "CCDrawingPrimitives.h"
#include "CCPointExtension.h"
#include "UsePointPls.h"
#include "NDDebugOpt.h"
#include "NDPicture.h"
#include "ObjectTracker.h"

using namespace cocos2d;

static bool gs_bTileHightLight = false;

void TileSetHightLight(bool bHightLight)
{
	gs_bTileHightLight = bHightLight;
}

bool IsTileHightLight()
{
	return gs_bTileHightLight;
}

NDTile::NDTile() :
	m_pkTexture(NULL),
	m_bReverse(false),
	m_Rotation(NDRotationEnumRotation0)//,
	// m_pfVertices(NULL),
	// m_pfCoordinates(NULL)
{
	INC_NDOBJ("NDTile");

	m_kCutRect = CCRectMake(0, 0, 0, 0);
	m_kDrawRect = CCRectMake(0, 0, 0, 0);
	m_kMapSize = CCSizeMake(0, 0);

// 	m_pfCoordinates = (float *) malloc(sizeof(float) * 8);
// 	m_pfVertices = (float *) malloc(sizeof(float) * 12);

	m_pShaderProgram = NULL; //@shader
	m_glServerState = CC_GL_BLEND;
}

NDTile::~NDTile()
{
	DEC_NDOBJ("NDTile");

	NDEngine::NDPicturePool::DefaultPool()->RemovePictureByTex(m_pkTexture);

	CC_SAFE_RELEASE (m_pkTexture);

	CC_SAFE_RELEASE(m_pShaderProgram); //@shader
}

//@check
void NDTile::makeTex(float* pData)
{
	if (!m_pkTexture) return;

	//<-------------------纹理坐标
	float *pfCoordinates = pData;
	CCSize texSize = CCSizeMake( m_pkTexture->getPixelsWide(), m_pkTexture->getPixelsHigh());

	//BOOL re=NO;
	if (getReverse())
	{
		*pfCoordinates++ = (m_kCutRect.origin.x + m_kCutRect.size.width) / texSize.width;
		*pfCoordinates++ = (m_kCutRect.origin.y + m_kCutRect.size.height) / texSize.height;

		*pfCoordinates++ = m_kCutRect.origin.x / texSize.width;
		*pfCoordinates++ = pData[1];

		*pfCoordinates++ = pData[0];
		*pfCoordinates++ = m_kCutRect.origin.y / texSize.height;
		
		*pfCoordinates++ = pData[2];
		*pfCoordinates++ = pData[5];
	}
	else
	{
		*pfCoordinates++ = m_kCutRect.origin.x / texSize.width;
		*pfCoordinates++ = (m_kCutRect.origin.y + m_kCutRect.size.height) / texSize.height;
		
		*pfCoordinates++ = (m_kCutRect.origin.x + m_kCutRect.size.width) / texSize.width;
		*pfCoordinates++ = pData[1];
		
		*pfCoordinates++ = pData[0];
		*pfCoordinates++ = m_kCutRect.origin.y / texSize.height;
		
		*pfCoordinates++ = pData[2];
		*pfCoordinates++ = pData[5];
	}
}

//@check
void NDTile::makeVetex(float* pData, CCRect kRect)
{
	//--------------->屏幕坐标
	float* pfVector = pData;
	//int r=NDRotationEnumRotation15;
	switch (m_Rotation)
	{
	case NDRotationEnumRotation0:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = SCREEN2GL_Y( kRect.origin.y + kRect.size.height );
		*pfVector++ = 0;

		*pfVector++ = kRect.origin.x + kRect.size.width;
		*pfVector++ = SCREEN2GL_Y( kRect.origin.y + kRect.size.height );
		*pfVector++ = 0;

		*pfVector++ = kRect.origin.x;
		*pfVector++ = SCREEN2GL_Y(kRect.origin.y);
		*pfVector++ = 0;

		*pfVector++ = kRect.origin.x + kRect.size.width;
		*pfVector++ = SCREEN2GL_Y(kRect.origin.y);
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation15:
		//			NDLog("15");
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * COS15;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS15 * kRect.size.width;
		*pfVector++ = pData[1] - SIN15 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN15 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[6] + COS15 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN15 * kRect.size.width;
		*pfVector++ = 0;

		//			*pv++		=	rect.origin.x+COS75*rect.size.height;
		//			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN75-COS75*rect.size.width;
		//			*pv++		=	0;
		//			*pv++		=	m_vertices[0]+SIN75*rect.size.width;
		//			*pv++		=	m_MapSize.height - rect.origin.y-SIN75*rect.size.height;
		//			*pv++		=	0;
		//			*pv++		=	rect.origin.x;
		//			*pv++		=	m_MapSize.height - rect.origin.y-COS75*rect.size.width;
		//			*pv++		=	0;
		//			*pv++		=	rect.origin.x+SIN75*rect.size.width;
		//			*pv++		=	m_MapSize.height - rect.origin.y;
		//			*pv++		=	0;
		break;
	case NDRotationEnumRotation30:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * COS30;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS30 * kRect.size.width;
		*pfVector++ = pData[1] - SIN30 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN30 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[6] + COS30 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN30 * kRect.size.width;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation45:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * COS45;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS45 * kRect.size.width;
		*pfVector++ = pData[1] - SIN45 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN45 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[6] + COS45 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN45 * kRect.size.width;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation60:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * COS60;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS60 * kRect.size.width;
		*pfVector++ = pData[1] - SIN60 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN60 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[6] + COS60 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN60 * kRect.size.width;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation75:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * COS75;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS75 * kRect.size.width;
		*pfVector++ = pData[1] - SIN75 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN75 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[6] + COS75 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN75 * kRect.size.width;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation90:

		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[0];
		*pfVector++ = pData[1] - kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + kRect.size.height;
		*pfVector++ = pData[1];
		*pfVector++ = 0;
		*pfVector++ = pData[6];
		*pfVector++ = pData[4];
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation105:
		//			NDLog("105");
		*pfVector++ = kRect.origin.x + SIN15 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS15 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + COS15 * kRect.size.height;
		*pfVector++ = pData[1] - SIN15 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS15 * kRect.size.height;
		*pfVector++ = pData[4] - SIN15 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation120:

		*pfVector++ = kRect.origin.x + SIN30 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS30 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + COS30 * kRect.size.height;
		*pfVector++ = pData[1] - SIN30 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS30 * kRect.size.height;
		*pfVector++ = pData[4] - SIN30 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation135:

		*pfVector++ = kRect.origin.x + SIN45 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS45 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + COS45 * kRect.size.height;
		*pfVector++ = pData[1] - SIN45 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS45 * kRect.size.height;
		*pfVector++ = pData[4] - SIN45 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation150:

		*pfVector++ = kRect.origin.x + SIN60 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS60 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + COS60 * kRect.size.height;
		*pfVector++ = pData[1] - SIN60 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS60 * kRect.size.height;
		*pfVector++ = pData[4] - SIN60 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation165:

		*pfVector++ = kRect.origin.x + SIN75 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS75 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + COS75 * kRect.size.height;
		*pfVector++ = pData[1] - SIN75 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS75 * kRect.size.height;
		*pfVector++ = pData[4] - SIN75 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation180:
		*pfVector++ = kRect.origin.x + kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = pData[1];
		*pfVector++ = 0;
		*pfVector++ = pData[0];
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = pData[3];
		*pfVector++ = pData[7];
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation195:
		*pfVector++ = kRect.origin.x + COS15 * kRect.size.width
				+ SIN15 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN15 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN15 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS15 * kRect.size.width;
		*pfVector++ = pData[1] - COS15 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS15 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation210:
		*pfVector++ = kRect.origin.x + COS30 * kRect.size.width
				+ SIN30 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN30 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN30 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS30 * kRect.size.width;
		*pfVector++ = pData[1] - COS30 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS30 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation225:
		*pfVector++ = kRect.origin.x + COS45 * kRect.size.width
				+ SIN45 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN45 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN45 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS45 * kRect.size.width;
		*pfVector++ = pData[1] - COS45 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS45 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation240:
		*pfVector++ = kRect.origin.x + COS60 * kRect.size.width
				+ SIN60 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN60 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN60 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS60 * kRect.size.width;
		*pfVector++ = pData[1] - COS60 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS60 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation255:
		*pfVector++ = kRect.origin.x + COS75 * kRect.size.width
				+ SIN75 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN75 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN75 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + COS75 * kRect.size.width;
		*pfVector++ = pData[1] - COS75 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS75 * kRect.size.height;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation270:
		*pfVector++ = kRect.origin.x + kRect.size.height;
		*pfVector++ = m_kMapSize.height - (kRect.origin.y + kRect.size.width);
		*pfVector++ = 0;
		*pfVector++ = pData[0];
		*pfVector++ = pData[1] + kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] - kRect.size.height;
		*pfVector++ = pData[1];
		*pfVector++ = 0;
		*pfVector++ = pData[6];
		*pfVector++ = pData[4];
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation285:
		*pfVector++ = kRect.origin.x + COS15 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * SIN15
				- COS15 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + SIN15 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN15 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS15 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN15 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation300:
		*pfVector++ = kRect.origin.x + COS30 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * SIN30
				- COS30 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + SIN30 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN30 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS30 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN30 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation315:
		*pfVector++ = kRect.origin.x + COS45 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * SIN45
				- COS45 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + SIN45 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN45 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS45 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN45 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation330:
		*pfVector++ = kRect.origin.x + COS60 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * SIN60
				- COS60 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + SIN60 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN60 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS60 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN60 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		break;
	case NDRotationEnumRotation345:
		//			NDLog("345");
		*pfVector++ = kRect.origin.x + COS75 * kRect.size.height;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height * SIN75
				- COS75 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = pData[0] + SIN75 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - SIN75 * kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - COS75 * kRect.size.width;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + SIN75 * kRect.size.width;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		break;
	default:
		break;
	}
}

CCRect NDTile::getDrawRectInPoints()
{
	CCRect rectInPoints = m_kDrawRect;
	ConvertUtil::convertToPointCoord( rectInPoints );
	return rectInPoints;
}

void NDTile::make()
{
	CCRect rectInPoints = this->getDrawRectInPoints();

	makeTex(m_pfCoordinates);
	makeVetex(m_pfVertices, rectInPoints);
}

static GLubyte gs_nTileColors[] =
		{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
				255, 255 };

static GLubyte gs_nTileHightLightColors[] =
		{ 255, 255, 255, 125, 255, 255, 255, 125, 255, 255, 255, 125, 255, 255,
				255, 125 };

void NDTile::draw()
{
	if (!m_pkTexture) return;

	DrawSetup();

	ccGLBindTexture2D(m_pkTexture->getName());		//绑定纹理

	// attribute
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, m_pfVertices);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, m_pfCoordinates);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, 
										gs_bTileHightLight ? gs_nTileHightLightColors : gs_nTileColors );

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);


// 	{
// 		glBindTexture(GL_TEXTURE_2D, m_pkTexture->getName());		//绑定纹理
// 		glVertexPointer(3, GL_FLOAT, 0, m_pfVertices);		//绑定目标位置数组
// 		glColorPointer(4, GL_UNSIGNED_BYTE, 0,
// 				gs_bTileHightLight ? gs_nTileHightLightColors : gs_nTileColors);
// 		glTexCoordPointer(2, GL_FLOAT, 0, m_pfCoordinates);	//绑定瓦片数组
// 		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
// 	}

	this->debugDraw();
}

void NDTile::drawSubRect(CCRect kRect)
{
	/**纹理坐标*/
	float fCoordinates[8] = {0.0f};
	float *pfCoordinates = fCoordinates;

	float xl = m_kCutRect.origin.x + m_kCutRect.size.width * kRect.origin.x;
	
	float xr = m_kCutRect.origin.x
			+ m_kCutRect.size.width * (kRect.size.width + kRect.origin.x);
	
	float yt = m_kCutRect.origin.y + m_kCutRect.size.height * kRect.origin.y;
	
	float yb = m_kCutRect.origin.y
			+ m_kCutRect.size.height * (kRect.size.height + kRect.origin.y);

	//BOOL re=NO;
	if (getReverse())
	{
		*pfCoordinates++ = xr / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = yb / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = xl / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = fCoordinates[1];
		*pfCoordinates++ = fCoordinates[0];
		*pfCoordinates++ = yt / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = fCoordinates[2];
		*pfCoordinates++ = fCoordinates[5];
	}
	else
	{
		*pfCoordinates++ = xl / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = yb / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = xr / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = fCoordinates[1];
		*pfCoordinates++ = fCoordinates[0];
		*pfCoordinates++ = yt / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = fCoordinates[2];
		*pfCoordinates++ = fCoordinates[5];
	}

	float fVertices[12] =
	{ 0.0f };

	CCRect drawRectInPoints = this->getDrawRectInPoints();
	CCRect kDrawRect;

	kDrawRect.origin.x = drawRectInPoints.origin.x
			+ kRect.origin.x * drawRectInPoints.size.width;
	
	kDrawRect.origin.y = drawRectInPoints.origin.y
			+ kRect.origin.y * drawRectInPoints.size.height;
	
	kDrawRect.size.width = kRect.size.width * drawRectInPoints.size.width;
	
	kDrawRect.size.height = kRect.size.height * drawRectInPoints.size.height;

	makeVetex(fVertices, kDrawRect);

	if (m_pkTexture)
	{
// 		glBindTexture(GL_TEXTURE_2D, m_pkTexture->getName());		//绑定纹理
// 		glVertexPointer(3, GL_FLOAT, 0, fVertices);					//绑定目标位置数组
// 		glColorPointer(4, GL_UNSIGNED_BYTE, 0, gs_nTileColors);
// 		glTexCoordPointer(2, GL_FLOAT, 0, fCoordinates);			//绑定瓦片数组
// 		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);						//由opengl组合画图


		DrawSetup();

		ccGLBindTexture2D(m_pkTexture->getName());		//绑定纹理

		// attribute
		ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

		glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, fVertices);
		glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, fCoordinates);
		glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, gs_nTileColors);

		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
}

//@shader
void NDTile::DrawSetup( const char* shaderType /*=kCCShader_PositionTextureColor*/ )
{
	if (getShaderProgram() == NULL)
	{
		setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(shaderType));
	}

	ccGLEnable( m_glServerState );
	CCAssert(getShaderProgram(), "No shader program set for this node");

	getShaderProgram()->use();
	getShaderProgram()->setUniformForModelViewProjectionMatrix();
}

void NDTile::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	glLineWidth(1);
	ccDrawColor4F(1,0,0,1);
	CCPoint lb = ccp(m_pfVertices[0],m_pfVertices[1]);
	CCPoint rt = ccp(m_pfVertices[9],m_pfVertices[10]);
	ccDrawRect( lb, rt );
	ccDrawLine( lb, rt );
}

//@android @iphone5
//战斗地图需要缩放裁剪
bool NDTile::withBattleMapScale() const
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) && WITH_ANDROID_BATTLEMAP_SCALE
	return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && WITH_IPHONE5_BATTLEMAP_SCALE
	return IS_IPHONE5;
#else
	return false;
#endif
}

//@android @iphone5
void NDTile::SetDrawRect( CCRect rect, bool bBattleMap ) 
{
	//传入的尺寸都是基于960*640的
	float fScale = RESOURCE_SCALE_960;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) && WITH_ANDROID_BATTLEMAP_SCALE
	if (bBattleMap)
	{
		//android战斗地图下以X为主等比缩放
		fScale = ConvertUtil::getAndroidScale().x;
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && WITH_IPHONE5_BATTLEMAP_SCALE
	if (bBattleMap)
	{
		//IPHONE5战斗地图下以X为主等比缩放
		fScale = IPHONE5_WIDTH_SCALE;
	}	
#endif

	//等比缩放
	rect.origin.x	*= fScale;	
	rect.origin.y	*= fScale;
	rect.size.width *= fScale;
	rect.size.height*= fScale;

	//如果是android战斗地图（或剧情地图）则再裁剪一下Y.
	if (withBattleMapScale() && bBattleMap)
	{
		cutHeightForBattleMap( rect );
	}

	m_kDrawRect = rect;
}

//@android @iphone5
//				战斗地图宽度不够会有黑边，解决方法如下：
//				等比缩放战斗地图确保宽度足够，高度方面则从上面裁剪多余尺寸.
//其他平台：	保持不变
void NDTile::SetCutRect( CCRect rect, bool bBattleMap ) //@android
{
	if (withBattleMapScale() && bBattleMap)
	{
		float cutHeight = 0.0f;
		if (cutHeightForBattleMap( rect, &cutHeight ))
		{
			rect.origin.y = cutHeight;
		}
	}

	m_kCutRect = rect;
}

//@android: android战斗地图专用，裁剪高度
bool NDTile::cutHeightForBattleMap( CCRect& rect, float* cutHeight )
{
	if (withBattleMapScale())
	{
		CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
		float screenAspect = visibleSize.height / visibleSize.width;
		float picAspect = rect.size.height / rect.size.width;

		if (picAspect > screenAspect)
		{
			float newHeight = rect.size.width * screenAspect;
			if (cutHeight)
			{
				*cutHeight = rect.size.height - newHeight; //被裁剪掉的尺寸
			}
			rect.size.height = newHeight; //裁剪高度
			return true;
		}
	}
	return false;
}
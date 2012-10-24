//
//  NDTile.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDTile.h"

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
m_Rotation(NDRotationEnumRotation0),
m_pfVertices(NULL),
m_pfCoordinates(NULL)
{
	m_kCutRect = CGRectMake(0, 0, 0, 0);
	m_kDrawRect = CGRectMake(0, 0, 0, 0);
	m_kMapSize = CGSizeMake(0, 0);

	m_pfCoordinates = (float *) malloc(sizeof(float) * 8);
	m_pfVertices = (float *) malloc(sizeof(float) * 12);
}

NDTile::~NDTile()
{
	free (m_pfCoordinates);
	free (m_pfVertices);
	CC_SAFE_FREE (m_pkTexture);
}

void NDTile::makeTex(float* pData)
{
	//<-------------------纹理坐标
	float *pfCoordinates = pData;
	//BOOL re=NO;
	if (getReverse())
	{
		*pfCoordinates++ = (m_kCutRect.origin.x + m_kCutRect.size.width)
				/ m_pkTexture->getPixelsWide();
		*pfCoordinates++ = (m_kCutRect.origin.y + m_kCutRect.size.height)
				/ m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = m_kCutRect.origin.x / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = pData[1];
		*pfCoordinates++ = pData[0];
		*pfCoordinates++ = m_kCutRect.origin.y / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = pData[2];
		*pfCoordinates++ = pData[5];
	}
	else
	{
		*pfCoordinates++ = m_kCutRect.origin.x / m_pkTexture->getPixelsWide();
		*pfCoordinates++ = (m_kCutRect.origin.y + m_kCutRect.size.height)
				/ m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = (m_kCutRect.origin.x + m_kCutRect.size.width)
				/ m_pkTexture->getPixelsWide();
		*pfCoordinates++ = pData[1];
		*pfCoordinates++ = pData[0];
		*pfCoordinates++ = m_kCutRect.origin.y / m_pkTexture->getPixelsHigh();
		*pfCoordinates++ = pData[2];
		*pfCoordinates++ = pData[5];
	}
}

void NDTile::makeVetex(float* pData, CGRect kRect)
{
	//--------------->屏幕坐标
	float* pfVector = pData;
	//int r=NDRotationEnumRotation15;
	switch (m_Rotation)
	{
	case NDRotationEnumRotation0:
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y - kRect.size.height;
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x + kRect.size.width;
		*pfVector++ = pData[1];
		*pfVector++ = 0;
		*pfVector++ = kRect.origin.x;
		*pfVector++ = m_kMapSize.height - kRect.origin.y;
		*pfVector++ = 0;
		*pfVector++ = pData[3];
		*pfVector++ = pData[7];
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

void NDTile::make()
{
	makeTex(m_pfCoordinates);
	makeVetex(m_pfVertices, m_kDrawRect);
}

static GLbyte gs_nTileColors[] =
		{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
				255, 255 };

static GLbyte gs_nTileHightLightColors[] =
		{ 255, 255, 255, 125, 255, 255, 255, 125, 255, 255, 255, 125, 255, 255,
				255, 125 };

void NDTile::draw()
{
	if (m_pkTexture)
	{
		glBindTexture(GL_TEXTURE_2D, m_pkTexture->getName());		//绑定纹理
		glVertexPointer(3, GL_FLOAT, 0, m_pfVertices);		//绑定目标位置数组
		glColorPointer(4, GL_UNSIGNED_BYTE, 0,
				gs_bTileHightLight ? gs_nTileHightLightColors : gs_nTileColors);
		glTexCoordPointer(2, GL_FLOAT, 0, m_pfCoordinates);	//绑定瓦片数组
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
	}
}

void NDTile::drawSubRect(CGRect kRect)
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

	CGRect kDrawRect;
	kDrawRect.origin.x = m_kDrawRect.origin.x
			+ kRect.origin.x * m_kDrawRect.size.width;
	kDrawRect.origin.y = m_kDrawRect.origin.y
			+ kRect.origin.y * m_kDrawRect.size.height;
	kDrawRect.size.width = kRect.size.width * m_kDrawRect.size.width;
	kDrawRect.size.height = kRect.size.height * m_kDrawRect.size.height;

	makeVetex(fVertices, kDrawRect);

	if (m_pkTexture)
	{
		glBindTexture(GL_TEXTURE_2D, m_pkTexture->getName());		//绑定纹理
		glVertexPointer(3, GL_FLOAT, 0, fVertices);					//绑定目标位置数组
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, gs_nTileColors);
		glTexCoordPointer(2, GL_FLOAT, 0, fCoordinates);			//绑定瓦片数组
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);						//由opengl组合画图
	}
}

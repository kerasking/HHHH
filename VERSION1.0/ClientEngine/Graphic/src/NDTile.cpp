//
//  NDTile.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDTile.h"

using namespace cocos2d;

static bool	s_bTileHightLight = false;

void TileSetHightLight(bool bHightLight)
{
	s_bTileHightLight = bHightLight;
}

bool IsTileHightLight()
{
	return s_bTileHightLight;
}

NDTile::NDTile()
: m_Texture(NULL)
, m_bReverse(false)
, m_Rotation(NDRotationEnumRotation0)
, m_vertices(NULL)
, m_coordinates(NULL)
{
	m_CutRect		= CGRectMake(0, 0, 0, 0);
	m_DrawRect		= CGRectMake(0, 0, 0, 0);
	m_MapSize		= CGSizeMake(0, 0);

	m_coordinates = (float *)malloc(sizeof(float) * 8);
	m_vertices = (float *)malloc(sizeof(float) * 12);
}

NDTile::~NDTile()
{
	free(m_coordinates);
	free(m_vertices);
	CC_SAFE_FREE(m_Texture);
}

void NDTile::makeTex(float* pData)
{
	//<-------------------纹理坐标
	float *pc = pData;
	//BOOL re=NO;
	if (m_bReverse) 
	{
		*pc++ = (m_CutRect.origin.x + m_CutRect.size.width) / m_Texture->getPixelsWide();
		*pc++ = (m_CutRect.origin.y + m_CutRect.size.height) / m_Texture->getPixelsHigh();
		*pc++ = m_CutRect.origin.x / m_Texture->getPixelsWide();
		*pc++ = pData[1];
		*pc++ = pData[0];
		*pc++ = m_CutRect.origin.y / m_Texture->getPixelsHigh();
		*pc++ = pData[2];
		*pc++ = pData[5];		
	}
	else 
	{
		*pc++ = m_CutRect.origin.x / m_Texture->getPixelsWide();
		*pc++ = (m_CutRect.origin.y + m_CutRect.size.height) / m_Texture->getPixelsHigh();
		*pc++ = (m_CutRect.origin.x + m_CutRect.size.width) / m_Texture->getPixelsWide();
		*pc++ = pData[1];
		*pc++ = pData[0];
		*pc++ = m_CutRect.origin.y / m_Texture->getPixelsHigh();
		*pc++ = pData[2];
		*pc++ = pData[5];			
	}
}

void NDTile::makeVetex(float* pData, CGRect rect)
{
	//--------------->屏幕坐标
	float *pv = pData;
	//int r=NDRotationEnumRotation15;
	switch(m_Rotation){
		case NDRotationEnumRotation0:
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x + rect.size.width;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[3];
			*pv++		=	pData[7];
			*pv++		=	0;
			break;
		case NDRotationEnumRotation15:
			//			NDLog("15");
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*COS15;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS15*rect.size.width;
			*pv++		=	pData[1]-SIN15*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN15*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS15*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN15*rect.size.width;
			*pv++		=	0;
			
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
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*COS30;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS30*rect.size.width;
			*pv++		=	pData[1]-SIN30*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN30*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS30*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN30*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation45:
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*COS45;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS45*rect.size.width;
			*pv++		=	pData[1]-SIN45*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN45*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS45*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN45*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation60:
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*COS60;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS60*rect.size.width;
			*pv++		=	pData[1]-SIN60*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN60*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS60*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN60*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation75:
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*COS75;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS75*rect.size.width;
			*pv++		=	pData[1]-SIN75*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN75*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS75*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN75*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation90:
			
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	pData[0];
			*pv++		=	pData[1] - rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0] + rect.size.height;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	pData[6];
			*pv++		=	pData[4];
			*pv++		=	0;	
			break;
		case NDRotationEnumRotation105:
			//			NDLog("105");
			*pv++		=	rect.origin.x+SIN15*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS15*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+COS15*rect.size.height;
			*pv++		=	pData[1]-SIN15*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS15*rect.size.height;
			*pv++		=	pData[4]-SIN15*rect.size.height;
			*pv++		=	0;	
			break;
		case NDRotationEnumRotation120:
			
			*pv++		=	rect.origin.x+SIN30*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS30*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+COS30*rect.size.height;
			*pv++		=	pData[1]-SIN30*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS30*rect.size.height;
			*pv++		=	pData[4]-SIN30*rect.size.height;
			*pv++		=	0;	
			break;
		case NDRotationEnumRotation135:
			
			*pv++		=	rect.origin.x+SIN45*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS45*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+COS45*rect.size.height;
			*pv++		=	pData[1]-SIN45*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS45*rect.size.height;
			*pv++		=	pData[4]-SIN45*rect.size.height;
			*pv++		=	0;		
			break;
		case NDRotationEnumRotation150:
			
			*pv++		=	rect.origin.x+SIN60*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS60*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+COS60*rect.size.height;
			*pv++		=	pData[1]-SIN60*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS60*rect.size.height;
			*pv++		=	pData[4]-SIN60*rect.size.height;
			*pv++		=	0;		
			break;
		case NDRotationEnumRotation165:
			
			*pv++		=	rect.origin.x+SIN75*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS75*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+COS75*rect.size.height;
			*pv++		=	pData[1]-SIN75*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS75*rect.size.height;
			*pv++		=	pData[4]-SIN75*rect.size.height;
			*pv++		=	0;	
			break;
		case NDRotationEnumRotation180:
			*pv++		=	rect.origin.x + rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	pData[0];
			*pv++		=	m_MapSize.height - rect.origin.y -  rect.size.height;
			*pv++		=	0;
			*pv++		=	pData[3];
			*pv++		=	pData[7];
			*pv++		=	0;
			break;
		case NDRotationEnumRotation195:
			*pv++		=	rect.origin.x+COS15*rect.size.width+SIN15*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN15*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN15*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS15*rect.size.width;
			*pv++		=	pData[1]-COS15*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS15*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation210:
			*pv++		=	rect.origin.x+COS30*rect.size.width+SIN30*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN30*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN30*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS30*rect.size.width;
			*pv++		=	pData[1]-COS30*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS30*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation225:
			*pv++		=	rect.origin.x+COS45*rect.size.width+SIN45*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN45*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN45*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS45*rect.size.width;
			*pv++		=	pData[1]-COS45*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS45*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation240:
			*pv++		=	rect.origin.x+COS60*rect.size.width+SIN60*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN60*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN60*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS60*rect.size.width;
			*pv++		=	pData[1]-COS60*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS60*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation255:
			*pv++		=	rect.origin.x+COS75*rect.size.width+SIN75*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN75*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN75*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS75*rect.size.width;
			*pv++		=	pData[1]-COS75*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS75*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation270:
			*pv++		=	rect.origin.x + rect.size.height;
			*pv++		=	m_MapSize.height - (rect.origin.y + rect.size.width);
			*pv++		=	0;
			*pv++		=	pData[0];
			*pv++		=	pData[1] + rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0] - rect.size.height;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	pData[6];
			*pv++		=	pData[4];
			*pv++		=	0;
			break;
		case NDRotationEnumRotation285:
			*pv++		=	rect.origin.x+COS15*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN15-COS15*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN15*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN15*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS15*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN15*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation300:
			*pv++		=	rect.origin.x+COS30*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN30-COS30*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN30*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN30*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS30*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN30*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation315:
			*pv++		=	rect.origin.x+COS45*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN45-COS45*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN45*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN45*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS45*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN45*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation330:
			*pv++		=	rect.origin.x+COS60*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN60-COS60*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN60*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN60*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS60*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN60*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation345:
			//			NDLog("345");
			*pv++		=	rect.origin.x+COS75*rect.size.height;
			*pv++		=	m_MapSize.height - rect.origin.y - rect.size.height*SIN75-COS75*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN75*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y-SIN75*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	m_MapSize.height - rect.origin.y-COS75*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN75*rect.size.width;
			*pv++		=	m_MapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		default:
			break;
	}	
}

void NDTile::make()
{
	this->makeTex(m_coordinates);
	this->makeVetex(m_vertices, m_DrawRect);	
}

static GLbyte tileColors[] = {255, 255, 255, 255,
	255, 255, 255, 255,
	255, 255, 255, 255,
	255, 255, 255, 255};
	
static GLbyte tileHightLightColors[] = 
{
	255, 255, 255, 125,
	255, 255, 255, 125,
	255, 255, 255, 125,
	255, 255, 255, 125
};

void NDTile::draw()
{
	if (m_Texture) 
	{				
		glBindTexture(GL_TEXTURE_2D, m_Texture->getName());		//绑定纹理
		
		glVertexPointer(3, GL_FLOAT, 0, m_vertices);		//绑定目标位置数组		
		
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, s_bTileHightLight ? tileHightLightColors : tileColors);
		
		glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);	//绑定瓦片数组				
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
	}	
}

void NDTile::drawSubRect(CGRect rect)
{
	/**纹理坐标*/
	float coordinates[8];
	float *pc = coordinates;
	
	float xl = m_CutRect.origin.x + m_CutRect.size.width * rect.origin.x;
	float xr = m_CutRect.origin.x + m_CutRect.size.width * (rect.size.width + rect.origin.x);
	float yt = m_CutRect.origin.y + m_CutRect.size.height * rect.origin.y;
	float yb = m_CutRect.origin.y + m_CutRect.size.height * (rect.size.height + rect.origin.y);
	
	//BOOL re=NO;
	if (m_bReverse) 
	{
		*pc++ = xr / m_Texture->getPixelsWide();
		*pc++ = yb / m_Texture->getPixelsHigh();
		*pc++ = xl / m_Texture->getPixelsWide();
		*pc++ = coordinates[1];
		*pc++ = coordinates[0];
		*pc++ = yt / m_Texture->getPixelsHigh();
		*pc++ = coordinates[2];
		*pc++ = coordinates[5];		
	}
	else 
	{
		*pc++ = xl / m_Texture->getPixelsWide();
		*pc++ = yb / m_Texture->getPixelsHigh();
		*pc++ = xr / m_Texture->getPixelsWide();
		*pc++ = coordinates[1];
		*pc++ = coordinates[0];
		*pc++ = yt / m_Texture->getPixelsHigh();
		*pc++ = coordinates[2];
		*pc++ = coordinates[5];			
	}
	
	float vertices[12];
	
	CGRect drawRect;
	drawRect.origin.x		= m_DrawRect.origin.x + rect.origin.x * m_DrawRect.size.width;
	drawRect.origin.y		= m_DrawRect.origin.y + rect.origin.y * m_DrawRect.size.height;
	drawRect.size.width		= rect.size.width * m_DrawRect.size.width;
	drawRect.size.height	= rect.size.height * m_DrawRect.size.height;
	
	this->makeVetex(vertices, drawRect);
	
	if (m_Texture) 
	{				
		glBindTexture(GL_TEXTURE_2D, m_Texture->getName());		//绑定纹理
		
		glVertexPointer(3, GL_FLOAT, 0, vertices);		//绑定目标位置数组		
		
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, tileColors);
		
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates);	//绑定瓦片数组				
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
	}
}
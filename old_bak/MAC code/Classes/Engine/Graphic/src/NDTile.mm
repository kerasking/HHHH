//
//  NDTile.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDTile.h"
#import "define.h"
#include "I_Analyst.h"

static bool	s_bTileHightLight = false;

void TileSetHightLight(bool bHightLight)
{
	s_bTileHightLight = bHightLight;
}

bool IsTileHightLight()
{
	return s_bTileHightLight;
}
@implementation NDTile

@synthesize texture = _texture, cutRect = _cutRect, drawRect = _drawRect, reverse = _reverse, rotation = _rotation, mapSize = _mapSize;

- (id)init
{
	if ((self = [super init])) 
	{
		_cutRect = CGRectMake(0, 0, 0, 0);
		_drawRect = CGRectMake(0, 0, 0, 0);
		_reverse = NO;
		_rotation = NDRotationEnumRotation0;
		_mapSize = CGSizeMake(0, 0);
		_texture = nil;
		m_coordinates = (float *)malloc(sizeof(float) * 8);
		m_vertices = (float *)malloc(sizeof(float) * 12);	
	}
	return self;
}

- (void)dealloc
{
	free(m_coordinates);
	free(m_vertices);
    if(_texture.ContainerType == NDEngine::ContainerTypeAddPic || _texture.ContainerType == NDEngine::ContainerTypeAddTexture) {
        NDEngine::NDPicturePool::DefaultPool()->RemoveTexture(_texture);
    }
    [_texture release];
//    delete m_pic;
	[super dealloc];
}

/*
- (CCTexture2D*)GetTexture
{
    return m_pic.GetTexture();
}
*/
- (void)makeTex:(float*)pData;
{
	//<-------------------纹理坐标
	float *pc = pData;
	//BOOL re=NO;
	if (_reverse) 
	{
		*pc++ = (_cutRect.origin.x + _cutRect.size.width) / _texture.pixelsWide;
		*pc++ = (_cutRect.origin.y + _cutRect.size.height) / _texture.pixelsHigh;
		*pc++ = _cutRect.origin.x / _texture.pixelsWide;
		*pc++ = pData[1];
		*pc++ = pData[0];
		*pc++ = _cutRect.origin.y / _texture.pixelsHigh;
		*pc++ = pData[2];
		*pc++ = pData[5];		
	}
	else 
	{
		*pc++ = _cutRect.origin.x / _texture.pixelsWide;
		*pc++ = (_cutRect.origin.y + _cutRect.size.height) / _texture.pixelsHigh;
		*pc++ = (_cutRect.origin.x + _cutRect.size.width) / _texture.pixelsWide;
		*pc++ = pData[1];
		*pc++ = pData[0];
		*pc++ = _cutRect.origin.y / _texture.pixelsHigh;
		*pc++ = pData[2];
		*pc++ = pData[5];			
	}
}

- (void)makeVetex:(float*)pData Rect:(CGRect)rect;
{
	//--------------->屏幕坐标
	float *pv = pData;
	//int r=NDRotationEnumRotation15;
	switch(_rotation){
		case NDRotationEnumRotation0:
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x + rect.size.width;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[3];
			*pv++		=	pData[7];
			*pv++		=	0;
			break;
		case NDRotationEnumRotation15:
			//			NDLog(@"15");
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*COS15;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS15*rect.size.width;
			*pv++		=	pData[1]-SIN15*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN15*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS15*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN15*rect.size.width;
			*pv++		=	0;
			
			//			*pv++		=	rect.origin.x+COS75*rect.size.height;
			//			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN75-COS75*rect.size.width;
			//			*pv++		=	0;
			//			*pv++		=	m_vertices[0]+SIN75*rect.size.width;
			//			*pv++		=	_mapSize.height - rect.origin.y-SIN75*rect.size.height;
			//			*pv++		=	0;
			//			*pv++		=	rect.origin.x;
			//			*pv++		=	_mapSize.height - rect.origin.y-COS75*rect.size.width;
			//			*pv++		=	0;
			//			*pv++		=	rect.origin.x+SIN75*rect.size.width;
			//			*pv++		=	_mapSize.height - rect.origin.y;
			//			*pv++		=	0;
			break;
		case NDRotationEnumRotation30:
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*COS30;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS30*rect.size.width;
			*pv++		=	pData[1]-SIN30*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN30*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS30*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN30*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation45:
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*COS45;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS45*rect.size.width;
			*pv++		=	pData[1]-SIN45*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN45*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS45*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN45*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation60:
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*COS60;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS60*rect.size.width;
			*pv++		=	pData[1]-SIN60*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN60*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS60*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN60*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation75:
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*COS75;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS75*rect.size.width;
			*pv++		=	pData[1]-SIN75*rect.size.width;
			*pv++		=	0;
			*pv++		=   rect.origin.x+SIN75*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	pData[6]+COS75*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN75*rect.size.width;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation90:
			
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y; 
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
			//			NDLog(@"105");
			*pv++		=	rect.origin.x+SIN15*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS15*rect.size.width;
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
			*pv++		=	_mapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS30*rect.size.width;
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
			*pv++		=	_mapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS45*rect.size.width;
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
			*pv++		=	_mapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS60*rect.size.width;
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
			*pv++		=	_mapSize.height - rect.origin.y; 
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS75*rect.size.width;
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
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	pData[1];
			*pv++		=	0;
			*pv++		=	pData[0];
			*pv++		=	_mapSize.height - rect.origin.y -  rect.size.height;
			*pv++		=	0;
			*pv++		=	pData[3];
			*pv++		=	pData[7];
			*pv++		=	0;
			break;
		case NDRotationEnumRotation195:
			*pv++		=	rect.origin.x+COS15*rect.size.width+SIN15*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y-SIN15*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN15*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS15*rect.size.width;
			*pv++		=	pData[1]-COS15*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS15*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation210:
			*pv++		=	rect.origin.x+COS30*rect.size.width+SIN30*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y-SIN30*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN30*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS30*rect.size.width;
			*pv++		=	pData[1]-COS30*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS30*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation225:
			*pv++		=	rect.origin.x+COS45*rect.size.width+SIN45*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y-SIN45*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN45*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS45*rect.size.width;
			*pv++		=	pData[1]-COS45*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS45*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation240:
			*pv++		=	rect.origin.x+COS60*rect.size.width+SIN60*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y-SIN60*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN60*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS60*rect.size.width;
			*pv++		=	pData[1]-COS60*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS60*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation255:
			*pv++		=	rect.origin.x+COS75*rect.size.width+SIN75*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y-SIN75*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN75*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			*pv++		=	rect.origin.x+COS75*rect.size.width;
			*pv++		=	pData[1]-COS75*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS75*rect.size.height;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation270:
			*pv++		=	rect.origin.x + rect.size.height;
			*pv++		=	_mapSize.height - (rect.origin.y + rect.size.width);
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
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN15-COS15*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN15*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN15*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS15*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN15*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation300:
			*pv++		=	rect.origin.x+COS30*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN30-COS30*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN30*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN30*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS30*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN30*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation315:
			*pv++		=	rect.origin.x+COS45*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN45-COS45*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN45*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN45*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS45*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN45*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation330:
			*pv++		=	rect.origin.x+COS60*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN60-COS60*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN60*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN60*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS60*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN60*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		case NDRotationEnumRotation345:
			//			NDLog(@"345");
			*pv++		=	rect.origin.x+COS75*rect.size.height;
			*pv++		=	_mapSize.height - rect.origin.y - rect.size.height*SIN75-COS75*rect.size.width;
			*pv++		=	0;
			*pv++		=	pData[0]+SIN75*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y-SIN75*rect.size.height;
			*pv++		=	0;
			*pv++		=	rect.origin.x;
			*pv++		=	_mapSize.height - rect.origin.y-COS75*rect.size.width;
			*pv++		=	0;
			*pv++		=	rect.origin.x+SIN75*rect.size.width;
			*pv++		=	_mapSize.height - rect.origin.y;
			*pv++		=	0;
			break;
		default:
			break;
	}	
}

- (void)make
{
	[self makeTex:m_coordinates];
	[self makeVetex:m_vertices Rect:_drawRect];	
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
- (void)draw
{
	if (_texture) 
	{			
        TICK_ANALYST(ANALYST_NDTILE);
        glBindTexture(GL_TEXTURE_2D, [_texture name]);		//绑定纹理
        
        TICK_ANALYST(ANALYST_NDTILE1);
        glVertexPointer(3, GL_FLOAT, 0, m_vertices);		//绑定目标位置数组		
        
        TICK_ANALYST(ANALYST_NDTILE2);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, s_bTileHightLight ? tileHightLightColors : tileColors);
        
        TICK_ANALYST(ANALYST_NDTILE3);
        glTexCoordPointer(2, GL_FLOAT, 0, m_coordinates);	//绑定瓦片数组				
        
        TICK_ANALYST(ANALYST_NDTILE4);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
	}	
}

- (void)drawSubRect:(CGRect) rect
{
	/**纹理坐标*/
	float coordinates[8];
	float *pc = coordinates;
	
	float xl = _cutRect.origin.x + _cutRect.size.width * rect.origin.x;
	float xr = _cutRect.origin.x + _cutRect.size.width * (rect.size.width + rect.origin.x);
	float yt = _cutRect.origin.y + _cutRect.size.height * rect.origin.y;
	float yb = _cutRect.origin.y + _cutRect.size.height * (rect.size.height + rect.origin.y);
	
	//BOOL re=NO;
	if (_reverse) 
	{
		*pc++ = xr / _texture.pixelsWide;
		*pc++ = yb / _texture.pixelsHigh;
		*pc++ = xl / _texture.pixelsWide;
		*pc++ = coordinates[1];
		*pc++ = coordinates[0];
		*pc++ = yt / _texture.pixelsHigh;
		*pc++ = coordinates[2];
		*pc++ = coordinates[5];		
	}
	else 
	{
		*pc++ = xl / _texture.pixelsWide;
		*pc++ = yb / _texture.pixelsHigh;
		*pc++ = xr / _texture.pixelsWide;
		*pc++ = coordinates[1];
		*pc++ = coordinates[0];
		*pc++ = yt / _texture.pixelsHigh;
		*pc++ = coordinates[2];
		*pc++ = coordinates[5];			
	}
	
	float vertices[12];
	
	CGRect drawRect;
	drawRect.origin.x		= _drawRect.origin.x + rect.origin.x * _drawRect.size.width;
	drawRect.origin.y		= _drawRect.origin.y + rect.origin.y * _drawRect.size.height;
	drawRect.size.width		= rect.size.width * _drawRect.size.width;
	drawRect.size.height	= rect.size.height * _drawRect.size.height;
	
	[self makeVetex:vertices Rect:drawRect];
	
	if (_texture) 
	{				
		glBindTexture(GL_TEXTURE_2D, [_texture name]);		//绑定纹理
		
		glVertexPointer(3, GL_FLOAT, 0, vertices);		//绑定目标位置数组		
		
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, tileColors);
		
		glTexCoordPointer(2, GL_FLOAT, 0, coordinates);	//绑定瓦片数组				
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				//由opengl组合画图
	}
}

@end

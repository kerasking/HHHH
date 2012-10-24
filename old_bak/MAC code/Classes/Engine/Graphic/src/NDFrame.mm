//
//  NDFrame.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDFrame.h"
#import "NDTile.h"
#import "NDAnimationGroup.h"
#import "NDAnimation.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"
#import "NDConstant.h"
#import "NDSprite.h"
#import "NDPath.h"
#import "NDMonster.h"
#import "NDNpc.h"
#import "NDPlayer.h"
//#import "NDBaseRole.h"
#import "NDMapData.h"
#import "NDPicture.h"

typedef struct _TILE_REVERSE_ROTATION
{
	BOOL reverse;					//是否翻转
	NDRotationEnum rotation;		//旋转角度
	float tileW;
}TILE_REVERSE_ROTATION;


@implementation NDFrameRunRecord

@synthesize nextFrameIndex = _nextFrameIndex, currentFrameIndex = _currentFrameIndex, runCount = _runCount;
@synthesize isCompleted = _isCompleted, repeatTimes = _repeatTimes;
@synthesize enduration = _enduration, totalFrame = _totalFrame;

- (id)init
{
	if ((self = [super init])) 
	{
		[self Clear];
	}
	return self;
}

- (void)Clear
{
    
    _nextFrameIndex = 0;
    _currentFrameIndex = 0;
    _runCount = 0;
    _isCompleted = NO;
    _repeatTimes = 0;
    _bSetPlayRange		= false;
    _nStartFrame		= 0;
    _nEndFrame			= 0;
    _enduration         = 0;
    _totalFrame         = 0;
}

- (BOOL)isThisFrameEnd
{
	if (_enduration && _runCount >= _enduration - 1) 
	{
		return YES;
	}
	else 
	{
		return NO;
	}
}

- (BOOL)enableRunNextFrame
{
	if (_runCount >= _enduration - 1) 
	{
		_runCount = 0;
		return YES;
	}
	else 
	{
		_runCount++;
		return NO;
	}
}

- (void)SetPlayRange:(int)nStartFrame EndAt:(int)nEndFrame
{
	_bSetPlayRange			= true;
	_nStartFrame			= nStartFrame;
	_nEndFrame				= nEndFrame;
	_currentFrameIndex		= nStartFrame;
	_nextFrameIndex			= nStartFrame;
}
- (void)NextFrame:(int)nTotalFrames
{
	if (_bSetPlayRange)
	{
        _nEndFrame = nTotalFrames < _nEndFrame ? nTotalFrames : _nEndFrame;
        /*
        if (_currentFrameIndex == _nEndFrame-1) {
            _currentFrameIndex=0;
            _nextFrameIndex=0;
            _nEndFrame =0;
            return;
        }*/
		_currentFrameIndex= ((_nStartFrame < _nEndFrame) && (_currentFrameIndex+1 < _nEndFrame)) ? _currentFrameIndex+1 : _currentFrameIndex;
		_nextFrameIndex= ((_nStartFrame < _nEndFrame) && (_nextFrameIndex+1<_nEndFrame))? _nextFrameIndex+1 : _nextFrameIndex;
	/*	
		if (_nStartFrame < _nEndFrame)
		{
			if (_currentFrameIndex >= _nEndFrame)
			{
				_currentFrameIndex	= _nEndFrame;
				_nextFrameIndex		= _nEndFrame;
			}
		}
		else if (_nStartFrame == _nEndFrame)
		{
			_currentFrameIndex	= _nEndFrame;
			_nextFrameIndex		= _nEndFrame;
		}
		else 
		{
			if (_nextFrameIndex <= _nEndFrame)
			{
				_currentFrameIndex	= _nEndFrame;
				_nextFrameIndex		= _nEndFrame;
			}
		}
		if (_currentFrameIndex < 0)
		{
			_currentFrameIndex = 0;
		}
		if (_currentFrameIndex >= nTotalFrames)
		{
			_currentFrameIndex--;
		}
		if (_nextFrameIndex < 0)
		{
			_nextFrameIndex = 0;
		}
		if (_nextFrameIndex >= nTotalFrames)
		{
			_nextFrameIndex	--;
		}
     */
		return;
	}
	//当前帧的索引值改变
	if (++_currentFrameIndex == nTotalFrames) 
	{
		_currentFrameIndex = 0;
		if (_repeatTimes > 0) 
		{
			_repeatTimes--;
		}
	}
	//下一帧的索引值改变
	_nextFrameIndex = _currentFrameIndex + 1;
	if (_nextFrameIndex == nTotalFrames) 
	{
		_nextFrameIndex = 0;
	}
    
    if (_currentFrameIndex == (nTotalFrames-1) && _repeatTimes <= 0) 
    {
        _isCompleted = YES;
    }
}

@end

@implementation NDFrameTile

@synthesize x = _x, y = _y, rotation = _rotation, tableIndex = _tableIndex;

@end

@interface NDFrame(hidden)

- (TILE_REVERSE_ROTATION)tileReverseRotationWithReverse:(BOOL)reverse rotation:(int)rota ;
- (CCTexture2D *)getTileTextureWithImageIndex:(int)imageIndex replace:(int)replace;
- (float)getTileW:(int)w height:(int)h rota:(NDRotationEnum)rotation;

@end

@implementation NDFrame

@synthesize enduration = _enduration, subAnimationGroups = _subAnimationGroups, frameTiles = _frameTiles, belongAnimation = _belongAnimation;

- (id)init
{
	if ((self = [super init])) 
	{
		m_count = 0;
		
		_subAnimationGroups = [[NSMutableArray alloc] init];
		_frameTiles = [[NSMutableArray alloc] init];
		_belongAnimation = nil;
		_enduration = 0;
		
		m_needInitTitles = YES;
		m_tiles = [[NSMutableArray alloc] init];
		
	}
	return self;
}

- (void)dealloc
{
	self.subAnimationGroups = nil;
	self.frameTiles = nil;
	[m_tiles release];
	[super dealloc];
}

- (void)initTiles
{
	if (m_needInitTitles) {
		for (int i = 0; i < (int)[_frameTiles count]; i++) 
		{
			NDTile *tile = [[NDTile alloc] init];
			[m_tiles addObject:tile];
			[tile release];
		}
	}
	m_needInitTitles = NO;
}


- (void)drawHeadAt:(CGPoint)pos
{
	
	int faceX = 5;
	int faceY = 8;
	int coordX = 0;
	int coordY = 0;
	
	NDAnimation *animation = self.belongAnimation;
	NDAnimationGroup *animationGroup = animation.belongAnimationGroup;
	
	if (m_needInitTitles) 
	{
		[self run];
	}
	
	// 计算脸部偏移
	for (uint i = 0; i < [_frameTiles count]; i++) 
	{
		NDFrameTile *frameTile = [_frameTiles objectAtIndex:i];
		NDTileTableRecord *record = [animationGroup.tileTable objectAtIndex:frameTile.tableIndex];
		if (record.replace == REPLACEABLE_FACE && record.x == 0 && record.y == 0) {
			coordX = (frameTile.x - animation.x) - faceX;
			coordY = (frameTile.y - animation.y) - faceY;
			break;
		}
	}	
	
	for (uint i = 0; i < [_frameTiles count]; i++) {
		NDFrameTile *frameTile = [_frameTiles objectAtIndex:i];
		NDTileTableRecord *record = [animationGroup.tileTable objectAtIndex:frameTile.tableIndex];
		
		int fx = frameTile.x;
		int fy = frameTile.y;
		
		int clipw = record.w;
		int replace = record.replace;
		
		if (replace == REPLACEABLE_FACE ||
		    replace == REPLACEABLE_HAIR ||
		    replace == REPLACEABLE_EXPRESSION) 
		{
			NDTile *tile = [m_tiles objectAtIndex:i];
			
			if (!tile) {
				continue;
			}
			
			tile.texture = [self getTileTextureWithImageIndex:record.imageIndex replace:record.replace];
			if (tile.texture == nil) 
			{
				continue;
			}			
			
			int xx = pos.x + (animation.midX + (animation.midX - fx - clipw) - animation.x) - coordX;
			int yy = pos.y + (fy - animation.y) - coordY;
			
			tile.reverse = true;
			
			tile.drawRect = CGRectMake(xx, yy, record.w, record.h);
			
			tile.mapSize = CGSizeMake(480.0f, 320.0f);
			
			[tile make];
			
			[tile draw];
		}
	}
	 
}

-(void)run
{
	[self run:1.0f];
}

- (void)run:(float) scale
{
	if (m_needInitTitles) {
		[self initTiles];
	}
	
	NDAnimation *animation = self.belongAnimation;
	NDAnimationGroup *animationGroup = animation.belongAnimationGroup;
	
	for (int i = 0; i < (int)[_frameTiles count]; i++) 
	{
		NDFrameTile *frameTile = [_frameTiles objectAtIndex:i];
		NDTileTableRecord *record = [animationGroup.tileTable objectAtIndex:frameTile.tableIndex];
		
		NDTile *tile = [m_tiles objectAtIndex:i];
		
		tile.texture = [self getTileTextureWithImageIndex:record.imageIndex replace:record.replace];
		if (tile.texture == nil) 
		{
			continue;
		}
		
		TILE_REVERSE_ROTATION reverseRotation = [self tileReverseRotationWithReverse:animation.reverse rotation:frameTile.rotation];
		tile.reverse = reverseRotation.reverse;
		tile.rotation = reverseRotation.rotation;
		
		NDSprite *sprite = [animationGroup getRuningSprite];
		
		if (sprite && !sprite->IsCloakEmpty() &&
			record.replace >= REPLACEABLE_LEFT_SHOULDER &&
			record.replace <= REPLACEABLE_SKIRT_LIFT_LEG) 
		{
			tile.cutRect = CGRectMake(0, 0, [tile.texture maxS]*[tile.texture pixelsWide], [tile.texture maxT]*[tile.texture pixelsHigh]);
		}else 
		{
			tile.cutRect = CGRectMake(record.x, record.y, record.w, record.h);
		}
		
		GLfloat x = animationGroup.position.x, y = animationGroup.position.y;
		if (animation.midX != 0) 
		{
			x -= (animation.midX - animation.x)*scale;
		}
		if (animation.bottomY != 0) 
		{
			y -= (animation.bottomY - animation.y)*scale;
		}
		y = y + frameTile.y*scale - animation.y*scale;		
		if (animation.reverse) 
		{
			int tileW = [self getTileW:record.w height:record.h rota:reverseRotation.rotation];
//			if (reverseRotation.rotation == NDRotationEnumRotation90 || reverseRotation.rotation == NDRotationEnumRotation270) 
//			{
//				tileW = record.h;
//			}
			int newX = animation.midX + (animation.midX - frameTile.x - tileW);
			x = x + newX*scale - animation.x*scale;			
		}
		else 
		{			
			x = x + frameTile.x*scale - animation.x*scale;
		}
		
		tile.drawRect = CGRectMake(x, y, tile.cutRect.size.width*scale, tile.cutRect.size.height*scale);
		
		tile.mapSize = animationGroup.runningMapSize;
		
		[tile make];
		
		[tile draw];
	}
}

- (float)getTileW:(int)w height:(int)h rota:(NDRotationEnum)rotation
{
	switch(rotation)
	{
		case NDRotationEnumRotation0:
		case NDRotationEnumRotation180:
			return w;
		case NDRotationEnumRotation15:
		case NDRotationEnumRotation195:
			return SIN15*h+COS15*w;
		case NDRotationEnumRotation30:
		case NDRotationEnumRotation210:
			return SIN30*h+COS30*w;
		case NDRotationEnumRotation45:
		case NDRotationEnumRotation225:
			return SIN45*h+COS45*w;
		case NDRotationEnumRotation60:
		case NDRotationEnumRotation240:
			return SIN60*h+COS60*w;
		case NDRotationEnumRotation75:
		case NDRotationEnumRotation255:
			return SIN75*h+COS75*w;
		case NDRotationEnumRotation90:
		case NDRotationEnumRotation270:
			return h;
		case NDRotationEnumRotation105:
		case NDRotationEnumRotation285:
			return COS15*h+SIN15*w;
		case NDRotationEnumRotation120:
		case NDRotationEnumRotation300:
			return COS30*h+SIN30*w;
		case NDRotationEnumRotation135:
		case NDRotationEnumRotation315:
			return COS45*h+SIN45*w;
		case NDRotationEnumRotation150:
		case NDRotationEnumRotation330:
			return COS60*h+SIN60*w;
		case NDRotationEnumRotation165:
		case NDRotationEnumRotation345:
			return COS75*h+SIN75*w;
		case NDRotationEnumRotation360:
			return w;
		default:
			return w;
	}
}

- (TILE_REVERSE_ROTATION)tileReverseRotationWithReverse:(BOOL)reverse rotation:(int)rota 
{
	//reverse = YES;
	static TILE_REVERSE_ROTATION reverseRotaionResult;
	switch (rota) {
		case 0:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation0;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation0;
			}
			break;
		case 1:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation345;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation15;
			}
			break;
		case 2:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation330;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation30;
			}
			break;
		case 3:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation315;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation45;
			}
			break;
		case 4:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation300;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation60;;
			}
			break;
		case 5:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation285;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation75;
			}
			break;
		case 6:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation270;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation90;
			}
			break;
		case 7:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation255;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation105;
			}
			break;
		case 8:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation240;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation120;
			}
			break;
		case 9:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation225;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation135;
			}
			break;
		case 10:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation210;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation150;
			}
			break;
		case 11:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation195;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation165;
			}
			break;
		case 12:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation180;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation180;
			}
			break;
		case 13:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation165;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation195;
			}
			break;
		case 14:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation150;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation210;
			}
			break;
		case 15:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation135;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation225;
			}
			break;
		case 16:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation120;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation240;
			}
			break;
		case 17:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation105;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation255;
			}
			break;
		case 18:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation90;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation270;
			}
			break;
		case 19:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation75;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation285;
			}
			break;
		case 20:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation60;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation300;
			}
			break;
		case 21:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation45;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation315;
			}
			break;
		case 22:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation30;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation330;
			}
			break;
		case 23:
			if (reverse) {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation15;
			} else {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation345;
			}
			break;
		case 24:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation0;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation0;
			}
			break;
		case 25:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation15;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation345;
			}
			break;
		case 26:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation30;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation330;
			}
			break;
		case 27:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation45;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation315;
			}
			break;
		case 28:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation60;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation300;
			}
			break;
		case 29:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation75;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation285;
			}
			break;
		case 30:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation90;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation270;
			}
			break;
		case 31:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation105;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation255;
			}
			break;
		case 32:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation120;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation240;
			}
			break;
		case 33:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation135;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation225;
			}
			break;
		case 34:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation150;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation210;
			}
			break;
		case 35:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation165;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation195;
			}
			break;
		case 36:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation180;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation180;
			}
			break;
		case 37:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation195;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation165;
			}
			break;
		case 38:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation210;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation150;
			}
			break;
		case 39:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation225;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation135;
			}
			break;
		case 40:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation240;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation120;
			}
			break;
		case 41:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation255;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation105;
			}
			break;
		case 42:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation270;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation90;
			}
			break;
		case 43:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation285;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation75;
			}
			break;
		case 44:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation300;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation60;
			}
			break;
		case 45:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation315;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation45;
			}
			break;
		case 46:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation330;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation30;
			}
			break;
		case 47:
			if (reverse) {
				reverseRotaionResult.reverse = NO;
				reverseRotaionResult.rotation = NDRotationEnumRotation345;
			} else {
				reverseRotaionResult.reverse = YES;
				reverseRotaionResult.rotation = NDRotationEnumRotation15;
			}
			break;
	}
	
	return reverseRotaionResult;
}

- (CCTexture2D *)getTileTextureWithImageIndex:(int)imageIndex replace:(int)replace
{
	NDAnimation *animation = self.belongAnimation;
	NDAnimationGroup *animationGroup = animation.belongAnimationGroup;
	NDSprite *sprite = [animationGroup getRuningSprite];
	
	CCTexture2D *tex = nil;
	if (sprite) 
	{
		tex = sprite->getColorTexture(imageIndex, animationGroup);
		if (tex) 
		{
			return tex;
		}
		
		if (sprite->IsNonRole()) {
            /*HJQ MOD*/
           // NDPicture* ptexpic = NDPicturePool::DefaultPool()->AddPicture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
            //tex = [[MapTexturePool defaultPool] addImage:[animationGroup.images objectAtIndex:imageIndex] keepData:true];
			//tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
            tex = NDPicturePool::DefaultPool()->AddTexture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
           // tex = ptexpic->GetTexture();
            //SAFE_DELETE(ptexpic);
			//tex	= NDPicturePool::DefaultPool()->GetTexture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
		}
		
		if (tex) {
			return tex;
		}
	}

	//武器
	if (replace==REPLACEABLE_ONE_HAND_WEAPON_1){
		tex=sprite->GetWeaponImage();
	}
	if (!tex)
	{
        /*HJQ MOD*/
        //NDPicture* ptexpic = NDPicturePool::DefaultPool()->AddPicture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
        //tex = [[MapTexturePool defaultPool] addImage:[animationGroup.images objectAtIndex:imageIndex] keepData:true];
        //tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
        tex = NDPicturePool::DefaultPool()->AddTexture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
        //tex = ptexpic->GetTexture();
        //SAFE_DELETE(ptexpic);
		//tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
        //tex = [[MapTexturePool defaultPool] addImage:[animationGroup.images objectAtIndex:imageIndex] keepData:true];
		//tex	= NDPicturePool::DefaultPool()->GetTexture([[animationGroup.images objectAtIndex:imageIndex] UTF8String]);
	}
	//NDLog(@"replace:%d",replace);
	/*switch (replace) 
	{
		case REPLACEABLE_NONE:
			tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
			break;		
		case REPLACEABLE_HAIR:
			if (sprite) 
			{
				tex = sprite->GetHairImage();
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_FACE:
			if (sprite) 
			{
				tex = sprite->GetFaceImage();
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_EXPRESSION:
			if (sprite)
			{
				tex = sprite->GetExpressionImage();
				if ( !tex ) 
				{
					tex = [[CCTextureCache sharedTextureCache] addImage:[animationGroup.images objectAtIndex:imageIndex]];
				}
			}
			break;
		case REPLACEABLE_CAP:
			if (sprite)
				tex = sprite->GetCapImage();
			break;
		case REPLACEABLE_ARMOR:
			if (sprite)
			{
				if (sprite->IsCloakEmpty())
				{
					tex = sprite->GetArmorImage();
					if ( !tex ) //非普通NPC 
					{
						tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
					}
				}
				else
					tex = sprite->GetCloakImage();
			}
			break;
		case REPLACEABLE_ONE_HAND_WEAPON_1:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == ONE_HAND_WEAPON )
				tex = sprite->GetRightHandWeaponImage();
			break;
		case REPLACEABLE_ONE_HAND_WEAPON_2:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetSecWeaponType() == ONE_HAND_WEAPON)
				tex = sprite->GetLeftHandWeaponImage();
			break;
		case REPLACEABLE_TWO_HAND_WEAPON:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_WEAPON)
				tex = sprite->GetDoubleHandWeaponImage();
			break;
		case REPLACEABLE_DUAL_SWORD:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == DUAL_SWORD)
				tex = sprite->GetDualSwordImage();
			break;
		case REPLACEABLE_DUAL_KNIFE:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_KNIFE)
				tex = sprite->GetDualKnifeImage();
			break;
		case REPLACEABLE_TWO_HAND_WAND:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_WAND)
				tex = sprite->GetDoubleHandWandImage();
			break;
		case REPLACEABLE_TWO_HAND_BOW:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_BOW)
				tex = sprite->GetDoubleHandBowImage();
			break;
		case REPLACEABLE_SHIELD:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == SEC_SHIELD)
				tex = sprite->GetShieldImage();
			break;
		case REPLACEABLE_FAQI:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == SEC_FAQI)
				tex = sprite->GetFaqiImage();
			break;
		case REPLACEABLE_SKIRT_STAND:
			if (sprite)
			{
				tex = sprite->GetSkirtStandImage();
				
				if( !tex )
				{
					tex = sprite->getArmorImageByCloak();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			if (sprite)
			{
				if (sprite->IsCloakEmpty())
				{ //使用原装备，没有进行换裙子
					if( !tex )
					{
						tex = sprite->getArmorImageByCloak();
					}
					
					if ( !tex ) //非普通NPC 
					{
						tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
					}
				}
				else 
				{ //换裙子了
					tex = sprite->GetSkirtStandImage();
				}
			}
			
			break;
		case REPLACEABLE_LEFT_SHOULDER:
			//if (sprite)
//			{
//				tex = sprite->GetLeftShoulderImage();
//				if ( !tex ) //非普通NPC 
//				{
//					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
//				}
//			}
			if (sprite)
			{
				if (!sprite->IsCloakEmpty())
				{ //换裙子了
					tex = sprite->GetLeftShoulderImage();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_RIGHT_SHOULDER:
			//if (sprite)
//			{
//				tex = sprite->GetRightShoulderImage();
//				if ( !tex ) //非普通NPC 
//				{
//					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
//				}
//			}
			if (sprite)
			{
				if (!sprite->IsCloakEmpty())
				{ //换裙子了
					tex = sprite->GetRightShoulderImage();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			
			break;
		case REPLACEABLE_SKIRT_LIFT_LEG:
			//if (sprite)
//			{				
//				tex = sprite->GetSkirtLiftLegImage();
//				if( !tex && sprite->IsCloakEmpty() )
//				{
//					tex = sprite->GetArmorImage();
//				}
//				
//				if ( !tex ) //非普通NPC 
//				{
//					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
//				}
//			}
			if (sprite)
			{
				if (!sprite->IsCloakEmpty())
				{ //换裙子了
					tex = sprite->GetSkirtLiftLegImage();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_SKIRT_SIT:
			//if (sprite)
//			{
//				tex = sprite->GetSkirtSitImage();
//				if( !tex && sprite->IsCloakEmpty() )
//				{
//					tex = sprite->GetArmorImage();
//				}
//				if ( !tex ) //非普通NPC 
//				{
//					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
//				}
//			}
			if (sprite)
			{
				if (!sprite->IsCloakEmpty())
				{ //换裙子了
					tex = sprite->GetSkirtSitImage();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_SKIRT_WALK:	
			//if (sprite) 
//			{
//				tex = sprite->GetSkirtWalkImage();
//				if( !tex && sprite->IsCloakEmpty() )
//				{
//					tex = sprite->GetArmorImage();
//				}
//				
//				if ( !tex ) //非普通NPC 
//				{
//					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
//				}
//			}
			if (sprite)
			{
				if (!sprite->IsCloakEmpty())
				{ //换裙子了
					tex = sprite->GetSkirtWalkImage();
				}
				
				if ( !tex ) //非普通NPC 
				{
					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
				}
			}
			break;
		case REPLACEABLE_TWO_HAND_SPEAR:
			if (sprite && 
				sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
				((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_SPEAR) 
				tex = sprite->GetDoubleHandSpearImage();
			break;
		default:
			break;
	}*/
	
	return tex;	
}




@end

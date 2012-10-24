//
//  NDAnimationGroup.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDAnimationGroup.h"
#import "NDAnimation.h"
#import "NDPath.h"
#import "JavaMethod.h"
#import "NDFrame.h"

@implementation NDTileTableRecord

@synthesize imageIndex = _imageIndex, x = _x, y = _y, w = _w, h = _h, replace = _replace;

@end

@interface NDAnimationGroup(hidden)

- (void)decodeSprtFile:(NSInputStream *)stream;
- (void)decodeSprFile:(NSInputStream *)stream;

@end

@implementation NDAnimationGroup

@synthesize type = _type, identifer = _identifer, animations = _animations, position = _position, runningMapSize = _runningMapSize, 
tileTable = _tileTable, reverse = _reverse, images = _images, unpassPoint = _unpassPoint;

- (id)init
{
	if ((self = [super init])) 
	{
		_type = 0;
		_identifer = 0;	
		_position = CGPointMake(0, 0);
		_reverse = NO;
		_runningMapSize = CGSizeMake(0, 0);
		_animations = [[NSMutableArray alloc] init];
		_tileTable = [[NSMutableArray alloc] init];
		_images = [[NSMutableArray alloc] init];
		_unpassPoint = nil;
		m_runningSprite = NULL;
	}
	return self;
}



- (id)initWithSprFile:(NSString *)sprFile
{
	if ((self = [self init])) 
	{		
		NSString *sprtFile = [NSString stringWithFormat:@"%@t", sprFile];
		if ([[NSFileManager defaultManager] fileExistsAtPath:sprtFile]) 
		{
			NSInputStream *sprtStream  = [NSInputStream inputStreamWithFileAtPath:sprtFile];
			if (sprtStream) 
			{
				[sprtStream open];
				[self decodeSprtFile:sprtStream];
				[sprtStream close];
			}
		}
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:sprFile]) 
		{
			NSInputStream *sprStream  = [NSInputStream inputStreamWithFileAtPath:sprFile];
			if (sprStream) 
			{
				[sprStream open];
				[self decodeSprFile:sprStream];
				[sprStream close];
			}
		}			
	}
	return self;
}

- (void)dealloc
{
	[_animations release];
	[_tileTable release];
	[_images release];
	[_unpassPoint release];
	[super dealloc];
}

- (void)setReverse:(BOOL)newReverse
{
	_reverse = newReverse;
	for (int i = 0; i < (int)[_animations count]; i++) 
	{
		NDAnimation *animation = [_animations objectAtIndex:i];
		animation.reverse = newReverse;
	}
}

- (void)setRuningSprite:(NDSprite*)sprite
{
	m_runningSprite = sprite;
}

- (NDSprite*)getRuningSprite
{
	return m_runningSprite;
}

- (void)decodeSprtFile:(NSInputStream *)stream
{
	int count = [stream readByte];
	for (int i = 0; i < count; i++) 
	{
		NDTileTableRecord *record = [[NDTileTableRecord alloc] init];
		record.imageIndex = [stream readByte];
		record.x = [stream readShort];
		record.y = [stream readShort];
		record.w = [stream readShort];
		record.h = [stream readShort];
		record.replace = [stream readByte];
		[_tileTable addObject:record];
		[record release];	
		
	}
}



- (void)decodeSprFile:(NSInputStream *)stream
{
	//动画用到的图片数目		
	int imageCount = [stream readByte];
	for (int i = 0; i < imageCount; i++) 
	{
		NSString *imageName = [stream readUTF8String];
		NSString *imagePath = [NSString stringWithUTF8String:NDEngine::NDPath::GetImagePath().c_str()];
		NSString *image = [NSString stringWithFormat:@"%@%@", imagePath, imageName];
		[_images addObject:image];
		
	}
	
	int animationCount = [stream readByte];
	for (int i = 0; i < animationCount; i++) 
	{
		NDAnimation *animation = [[NDAnimation alloc] init];
		animation.x = [stream readShort];
		animation.y = [stream readShort];
		animation.w = [stream readShort];
		animation.h = [stream readShort];
		animation.midX = [stream readShort];
		animation.bottomY = [stream readShort];
		animation.type = [stream readByte];
		animation.reverse = NO;
		animation.belongAnimationGroup = self;
		
		int frameSize = [stream readByte];		
		for (int j = 0; j < frameSize; j++) 
		{
			NDFrame *frame = [[NDFrame alloc] init];
			frame.enduration = [stream readShort];
			frame.belongAnimation = animation;
			//读取音乐信息，暂不处理
			int sound_num=[stream readShort];
			for(int n=0;n<sound_num;n++){
				[stream readUTF8String];
			}
			int sagSize = [stream readByte];
			for (int k = 0; k < sagSize; k++) 
			{				
				NSString *animationPath = [NSString stringWithUTF8String:NDEngine::NDPath::GetAnimationPath().c_str()];
				NSString *sprFile = [NSString stringWithFormat:@"%@%@", animationPath, [stream readUTF8String]];
				NDAnimationGroup *sag = [[NDAnimationGroup alloc] initWithSprFile:sprFile];
				sag.type = [stream readByte];
				sag.identifer = [stream readInt];
				CGFloat xx = [stream readShort];
				CGFloat yy = [stream readShort];
				sag.position = CGPointMake(xx, yy);
				sag.reverse = [stream readByte];
				
				[frame.subAnimationGroups addObject:sag];
				[sag release];
			}
			
			int tileSize = [stream readByte];
			for (int k = 0; k < tileSize; k++) 
			{				
				NDFrameTile *frameTile = [[NDFrameTile alloc] init];
				
				frameTile.x = [stream readShort];
				frameTile.y = [stream readShort];
				frameTile.rotation = (unsigned char)[stream readShort];
				frameTile.tableIndex = [stream readShort];
				
				[frame.frameTiles addObject:frameTile];
				[frameTile release];
			}
			
			[animation.frames addObject:frame];
			[frame release];
			
		}
		
		[_animations addObject:animation];
		[animation release];
	}
	
	//根据特殊字符怕是是否是带掩码点的动画
	NSString* judge = [stream readUTF8StringNoExcept];
	if ([judge isEqualToString:@"■"]) 
	{
		if (!_unpassPoint) {
			_unpassPoint = [[NSMutableArray alloc] init];
		}
		int size= [stream readByte];
		for (int i = 0; i < size; i++) {
			[_unpassPoint addObject:[NSNumber numberWithChar:[stream readByte]]];
			[_unpassPoint addObject:[NSNumber numberWithChar:[stream readByte]]];
		}
	}
}

- (void)drawHeadAt:(CGPoint)pos
{
	NDAnimation* firstAni = [_animations objectAtIndex:0];
	NDFrame* firstFrame = [firstAni.frames objectAtIndex:0];
	[firstFrame drawHeadAt:pos];
}

@end

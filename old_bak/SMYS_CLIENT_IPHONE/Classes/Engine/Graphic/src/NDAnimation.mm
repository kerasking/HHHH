//
//  NDAnimation.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDAnimation.h"
#import "NDTile.h"
#import "NDAnimationGroup.h"

@implementation NDAnimation

@synthesize x = _x, y = _y, w = _w, h = _h, midX = _midX, bottomY = _bottomY, type = _type, frames = _frames, reverse = _reverse, 
belongAnimationGroup = _belongAnimationGroup, curIndexInAniGroup = _curIndexInAniGroup;

- (id)init
{
	if ((self = [super init])) 
	{		
		_belongAnimationGroup = nil;
		_frames = [[NSMutableArray alloc] init];
		_curIndexInAniGroup = -1;
	}
	return self;
}

- (void)dealloc
{
	self.frames = nil;
	[super dealloc];
}

- (CGRect)getRect
{
	if (_belongAnimationGroup) 
	{
		int px = _belongAnimationGroup.position.x, py = _belongAnimationGroup.position.y;
		if (_midX != 0) 
		{
			px -= _midX - _x; 
		}
		if (_bottomY != 0) 
		{
			py -= _bottomY - _y;
		}
		return CGRectMake(px, py, _w, _h);
	}
	return CGRectZero;
}

- (void)runWithRunFrameRecord:(NDFrameRunRecord *)runFrameRecord draw:(BOOL)needDraw scale:(float)drawScale
{
	if ([_frames count]) 
	{		
		if (runFrameRecord.currentFrameIndex >= (int)[_frames count]) 
		{
			return;
		}
		
		if (runFrameRecord.nextFrameIndex != 0 && runFrameRecord.currentFrameIndex == 0) 
		{
			if (_type == ANIMATION_TYPE_ONCE_END) 
			{
				NDFrame* frame = [_frames lastObject];
				if (needDraw) 
				{
					[frame run:drawScale];
				}
				return;
			}
			else if (_type == ANIMATION_TYPE_ONCE_START)
			{
				NDFrame* frame = [_frames objectAtIndex:0];
				if (needDraw) 
				{
					[frame run:drawScale];
				}
				return;
			}
		}
		
		//获取动画的当前帧
		NDFrame *frame = [_frames objectAtIndex:runFrameRecord.currentFrameIndex];
		
		//判断是否允许跑下一帧，如果允许则跑下一帧，否则还是跑当前帧
		if ([frame enableRunNextFrame:runFrameRecord]) 
		{
			//runFrameRecord.isCompleted = NO;	
			//取下一帧
			frame = [_frames objectAtIndex:runFrameRecord.nextFrameIndex];
			
			[runFrameRecord NextFrame:(int)[_frames count]];
			/*
			//当前帧的索引值改变
			if (++runFrameRecord.currentFrameIndex == (int)[_frames count]) 
			{
				runFrameRecord.currentFrameIndex = 0;
				
				if (runFrameRecord.repeatTimes > 0) 
				{
					runFrameRecord.repeatTimes--;
				}
			}
			
			//下一帧的索引值改变
			runFrameRecord.nextFrameIndex = runFrameRecord.currentFrameIndex + 1;
			if (runFrameRecord.nextFrameIndex == (int)[_frames count]) 
			{
				runFrameRecord.nextFrameIndex = 0;
				if (runFrameRecord.repeatTimes == 0) 
				{
					runFrameRecord.isCompleted = YES;
				}

			}
			*/
		}
		
		if (needDraw) 
		{
			//跑一帧
			[frame run:drawScale];
		}
		
	}
}

- (void)runWithRunFrameRecord:(NDFrameRunRecord *)runFrameRecord draw:(BOOL)needDraw
{	
	[self runWithRunFrameRecord:runFrameRecord draw:needDraw scale:1.0f];
}

- (void)SlowDown:(NSInteger)multi
{
	if ([_frames count]) 
	{
		for (NSUInteger i=0; i < [_frames count]; i++) 
		{
			NDFrame *frame = [_frames objectAtIndex:i];
			frame.enduration = frame.enduration*multi;
		}
	}
}

@end

//
//  NDFrame.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NDFrameRunRecord : NSObject
{
	int _nextFrameIndex, _currentFrameIndex, _runCount, _repeatTimes;
	BOOL _isCompleted;
	int _nStartFrame, _nEndFrame;
	BOOL _bSetPlayRange;
    int _enduration;
    int _totalFrame;
}
@property (nonatomic, assign)int nextFrameIndex;
@property (nonatomic, assign)int currentFrameIndex;
@property (nonatomic, assign)int runCount;
@property (nonatomic, assign)BOOL isCompleted;
@property (nonatomic, assign)int repeatTimes;
@property (nonatomic, assign)int enduration;
@property (nonatomic, assign)int totalFrame;
- (void)SetPlayRange:(int)nStartFrame EndAt:(int)nEndFrame;
- (void)NextFrame:(int)nTotalFrames;
- (BOOL)isThisFrameEnd;
//是否允许跑下一帧
- (BOOL)enableRunNextFrame;
- (void)Clear;
@end


//动画中所使用到的瓦片
@interface NDFrameTile : NSObject
{
	int _x, _y, _rotation, _tableIndex;
}
@property (nonatomic, assign)int x;
@property (nonatomic, assign)int y;
@property (nonatomic, assign)int rotation;
@property (nonatomic, assign)int tableIndex;

@end

@class NDAnimation;
@interface NDFrame : NSObject 
{
	int _enduration;
	NSMutableArray *_subAnimationGroups;
	NSMutableArray *_frameTiles;
	NDAnimation *_belongAnimation;
	int m_count;
	
	NSMutableArray *m_tiles;
	BOOL m_needInitTitles;
}
@property (nonatomic, assign)int enduration;
@property (nonatomic, retain)NSMutableArray *subAnimationGroups;
@property (nonatomic, retain)NSMutableArray *frameTiles;
@property (nonatomic, assign)NDAnimation *belongAnimation;

- (void)initTiles;
//跑一帧
- (void)run;
- (void)run:(float)scale;

// 绘制人物头像
- (void)drawHeadAt:(CGPoint)pos;
@end

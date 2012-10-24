//
//  NDAnimation.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NDFrame.h"

#define ANIMATION_TYPE_ONCE_CYCLE 0
#define ANIMATION_TYPE_ONCE_END 1
#define ANIMATION_TYPE_ONCE_START 2

@class NDAnimationGroup;
@interface NDAnimation : NSObject 
{
	int _x, _y, _w, _h, _midX, _bottomY, _type;
	NSMutableArray *_frames;
	BOOL _reverse;
	NDAnimationGroup *_belongAnimationGroup;
	int _curIndexInAniGroup;
    int _m_nPlayCount;
}
@property (nonatomic, assign)int x;
@property (nonatomic, assign)int y;
@property (nonatomic, assign)int w;
@property (nonatomic, assign)int h;
@property (nonatomic, assign)int midX;
@property (nonatomic, assign)int bottomY;
@property (nonatomic, assign)int type;
@property (nonatomic, assign)BOOL reverse;
@property (nonatomic, retain)NSMutableArray *frames;
@property (nonatomic, assign)NDAnimationGroup *belongAnimationGroup;
@property (nonatomic, assign)int curIndexInAniGroup;
@property (nonatomic, assign)int m_nPlayCount;
- (CGRect)getRect;

- (void)runWithRunFrameRecord:(NDFrameRunRecord *)runFrameRecord draw:(BOOL)needDraw;
- (void)runWithRunFrameRecord:(NDFrameRunRecord *)runFrameRecord draw:(BOOL)needDraw scale:(float)drawScale;
- (void)SlowDown:(NSInteger)multi;
- (BOOL)lastFrameEnd:(NDFrameRunRecord *)runFrameRecord;
@end

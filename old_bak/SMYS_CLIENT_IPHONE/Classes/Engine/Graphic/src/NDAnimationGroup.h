//
//  NDAnimationGroup.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NDSprite.h"
#import "CCTexture2D.h"

using namespace NDEngine;

@interface NDTileTableRecord : NSObject
{
	int _imageIndex, _x, _y, _w, _h, _replace;
}
@property (nonatomic, assign)int imageIndex;
@property (nonatomic, assign)int x;
@property (nonatomic, assign)int y;
@property (nonatomic, assign)int w;
@property (nonatomic, assign)int h;
@property (nonatomic, assign)int replace;

@end

@interface NDAnimationGroup : NSObject 
{
	int _type, _identifer;
	NSMutableArray *_animations;
	NSMutableArray *_tileTable;
	NSMutableArray *_images;
	CGPoint _position;
	BOOL _reverse;
	CGSize _runningMapSize;	
	int _orderId;
	
	NDSprite* m_runningSprite;
	
	NSMutableArray	*_unpassPoint;
}
@property (nonatomic, assign)int type;
@property (nonatomic, assign)int identifer;
@property (nonatomic, readonly)NSArray *animations;
@property (nonatomic, readonly)NSArray *tileTable;
@property (nonatomic, readonly)NSArray *images;
@property (nonatomic, assign)BOOL reverse;
@property (nonatomic, readonly)NSArray *unpassPoint;

//以下属性在每次绘画时必须被重新设定
@property (nonatomic, assign)CGPoint position;
@property (nonatomic, assign)CGSize runningMapSize;

- (id)initWithSprFile:(NSString *)sprFile;

- (void)setRuningSprite:(NDSprite*)sprite;
- (NDSprite*)getRuningSprite;

- (void)drawHeadAt:(CGPoint)pos;

@end

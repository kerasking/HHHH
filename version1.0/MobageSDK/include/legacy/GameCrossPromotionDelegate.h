//
//  GameCrossPromotionDelegate.h
//  MyNativeTest
//
//  Created by panzaofeng on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameCrossPromotionController;

@protocol GameCrossPromotionDelegate <NSObject>

@optional
- (void)GameCrossPromotionWillShown;
- (void)GameCrossPromotionWillClose;

@end
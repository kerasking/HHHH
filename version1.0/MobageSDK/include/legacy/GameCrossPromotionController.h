//
//  GameCrossPromotionController.h
//  MyNativeTest
//
//  Created by panzaofeng on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCrossPromotionDelegate.h"
#import "ASIHTTPRequestDelegate.h"
#import "GameCrossPromotionView.h"

@interface GameCrossPromotionController : UIViewController
{
    GameCrossPromotionView *promotionView;
    
    id<GameCrossPromotionDelegate> delegate;
}

@property (nonatomic, assign) id<GameCrossPromotionDelegate> delegate;

+ (GameCrossPromotionController*)shareInstance;

- (void)startShowCrossPromotion:(NSString *) title url:(NSString *)url;
- (BOOL)isCrossPromotionLaunched;
@end

//
//  GameResumeCoverController.h
//  MyNativeTest
//
//  Created by panzaofeng on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "GameResumeCoverDelegate.h"
#import "GameResumeCoverView.h"

@interface GameResumeCoverController : UIViewController<ASIHTTPRequestDelegate>
{
    id<GameResumeCoverDelegate> delegate;
    
    GameResumeCoverView *coverView;
    
    NSTimer *nextShowTimer;
    
    BOOL canBeShown;
}

@property (nonatomic, assign) id<GameResumeCoverDelegate> delegate;

+ (GameResumeCoverController*)shareInstance;

- (void)startShowResumeCover;
@end

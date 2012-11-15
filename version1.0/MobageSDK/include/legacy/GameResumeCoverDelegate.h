//
//  GameResumeCoverDelegate.h
//  MyNativeTest
//
//  Created by panzaofeng on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameResumeCoverController;

@protocol GameResumeCoverDelegate <NSObject>

@optional
- (void)GameCoverControllerWillShown:(GameResumeCoverController*)controller;
- (void)GameCoverControllerWillClose:(GameResumeCoverController*)controller;

@end

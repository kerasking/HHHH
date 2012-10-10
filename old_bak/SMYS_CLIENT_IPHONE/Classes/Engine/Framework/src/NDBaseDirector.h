//
//  NDBaseDirector.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDirectorIOS.h"

@interface CCDirectorDisplayLink(ND)

- (void)dispatchOneMessage;

- (void)OnIdle;

- (void)drawScene;

@end


//@interface CCTimerDirector(ND)
//
//- (void)drawScene;
//
//@end

//@interface CCDisplayLinkDirector(ND)
//
//- (void)drawScene;
//
//@end

//@interface CCFastDirector(ND)
//
//- (void)drawScene;
//
//@end

//@interface CCThreadedFastDirector(ND)
//
//- (void)drawScene;
//
//@end


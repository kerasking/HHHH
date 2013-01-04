//
//  MobageNotificationContainerView.h
//  MyNativeTest
//
//  Created by panzaofeng on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobageNotificationTypes.h"

@interface MobageNotificationContainerView : UIView


@property (nonatomic, retain, readonly) UIView *contentView;
@property (nonatomic) MobageNotificationDisplayPosition displayPosition;

- (id)initWithDisplayPosition:(MobageNotificationDisplayPosition)position;
- (void)containerViewShow;
- (void)containerViewOriginalStatus;
@end
//
//  MobageNotificationView.h
//  MyNativeTest
//
//  Created by panzaofeng on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobageNotificationTypes.h"

@class MobageNotification;

@interface MobageNotificationView : UIView

@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic) BOOL showsCloseButton;
@property (nonatomic, retain) MobageNotification *notification;


- (id)initWithMessage:(NSString*)message frame:(CGRect)frame;

@end

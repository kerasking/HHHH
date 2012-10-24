//
//  MobageViewController.h
//  DHLJ
//
//  Created by liujh on 12/07/24
//  Copyright (c) 2012  DeNA co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobageViewController : UIViewController
{
}

+ (MobageViewController *)sharedViewController;
- (void) showBalanceButton:(CGRect)rect;
- (void) hideBalanceButton;

@end

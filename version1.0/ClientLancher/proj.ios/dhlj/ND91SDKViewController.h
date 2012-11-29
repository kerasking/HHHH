//
//  ND91SDKViewController.h
//  DHLJ
//
//  Created by liujh on 12/08/18
//  Copyright (c) 2012  DeNA co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ND91SDKViewController : UIViewController
{
}

+ (ND91SDKViewController *)sharedViewController;
- (void) showBalanceButton:(CGRect)rect;
- (void) hideBalanceButton;

@end

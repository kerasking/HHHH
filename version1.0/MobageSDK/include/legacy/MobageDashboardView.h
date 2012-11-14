//
//  MobageDashboardView.h
//  MyNativeTest
//
//  Created by panzaofeng on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobageDashboardDelegate.h"
#import "MobageUIGradientView.h"
#import "MBGCNPurchaseControllerDelegate.h"
//#import "MBGCNBalanceButton.h"

@interface MobageDashboardView : UIView <UIWebViewDelegate,MBGCNPurchaseControllerDelegate> 
{
    UIWebView* dashboardWebview;
    
    id<MobageDashboardDelegate> delegate;
}

@property (nonatomic,retain) UIWebView* dashboardWebview;
@property (nonatomic,assign) id<MobageDashboardDelegate> delegate;

- (void)loadURL:(NSString*)url;
- (void)loadPage:(NSString*)url;

- (void)ShowDashBoardView;
- (void)CloseDashBoardView;
@end

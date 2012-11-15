//
//  LoginWebViewController.h
//  MobagePortal
//
//  Created by Charlene Jiang on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginWebViewController : UIViewController <UIWebViewDelegate> {
    UIButton *passButton;
    UIWebView *loginWebView;
}


//Charlene
@property (nonatomic,retain) NSString* view_url;
@property (nonatomic,retain) NSString* btn_url;

@property (nonatomic, retain) UIButton *buttonBgView;
@property (nonatomic, retain) UIButton *passButton;
@property (nonatomic, retain) UIWebView *loginWebView;


@property (nonatomic, retain) UIView *waitingView;
@property (nonatomic, retain) MBProgressHUD *HUD;

+ (LoginWebViewController*) shareInstance;


- (void)initialWithViewUrl: (NSString*)_viewUrl andButtonUrl:(NSString*)_buttonUrl;


@end

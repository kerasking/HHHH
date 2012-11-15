//
//  GameCrossPromotionView.h
//  MyNativeTest
//
//  Created by panzaofeng on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameCrossPromotionDelegate.h"
#import "ASIHTTPRequestDelegate.h"

@interface GameCrossPromotionView : UIView <UIWebViewDelegate, GameCrossPromotionDelegate>
{
     id<GameCrossPromotionDelegate> delegate;
    
    UIView *crossPromotionView;
    NSString *titleString;
    UILabel *titleLabel;
    UIImageView *titleLogo;
    UIImageView *titleBg;
    UIButton *closeButton;
    UIWebView *webView;
    
    UIActivityIndicatorView *webViewActivity;
}

@property(nonatomic,assign) id<GameCrossPromotionDelegate> delegate;

@property(nonatomic,copy) NSString *titleString;
@property(nonatomic,retain) UIView *crossPromotionView;
@property(nonatomic,retain) UIImageView *titleLogo;
@property(nonatomic,retain) UIImageView *titleBg;
@property(nonatomic,retain) UIButton *closeButton;
@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic,retain) UILabel *titleLabel;
@property(nonatomic,retain) UIActivityIndicatorView *webViewActivity;

- (void)crossPromtionOpen:(NSString *)url;

@end

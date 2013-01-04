//
//  MobageCheckView.h
//  MyNativeTest
//
//  Created by panzaofeng on 10/22/12.
//
//

#import <UIKit/UIKit.h>

@interface MobageCheckView : UIView
{
    UILabel *sandboxLabel;
    UIActivityIndicatorView *webViewActivity;
    UIImageView *imageView;
    
    UILabel *promptLabel;
    UIView *loadingView;
}

@property (nonatomic, retain) UILabel *sandboxLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *webViewActivity;
@property (nonatomic, retain) UILabel *promptLabel;
@property (nonatomic, retain) UIView *loadingView;

@end

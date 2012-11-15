//
//  GameResumeCoverView.h
//  MyNativeTest
//
//  Created by panzaofeng on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameResumeCoverView : UIView
{
    UIImageView *imageView;
    UIButton *closeButton;

    NSString *adsURL;
}

@property (retain, nonatomic)UIImageView *imageView;
@property (retain, nonatomic)UIButton *closeButton;
@property (retain, nonatomic)NSString *adsURL;

@end

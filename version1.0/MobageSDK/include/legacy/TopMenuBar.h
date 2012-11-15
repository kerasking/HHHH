//
//  TopMenuBar.h
//  smart_gomoku
//
//  Created by Charlene Jiang on 11/10/11.
//  Copyright 2011 Mighty Craft Co. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TopMenuBar : UIView
{

}

+ (TopMenuBar *)shareInstance;

- (void)showTopMenuBar;

- (void)setHidden:(BOOL)hidden; //set hidden for the top menu
@end

//
//  TopMenubarButton.h
//  MyNativeTest
//
//  Created by panzaofeng on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum MENUBAR_BUTTON_STATUS {
    MENUBAR_BUTTON_STATIC,
    MENUBAR_BUTTON_NORMAL,
    MENUBAR_BUTTON_HIGHT,
    };

enum MENUBAR_BUTTON_OPENTYPE {
    MENUBAR_BUTTON_OPENBY_DASHBOARD,
    MENUBAR_BUTTON_OPENBY_CROSSPROMOTION,
    };

@interface TopMenubarButton : UIButton
{
    int buttonID;
    int buttonStatus;
    int buttonOpenType;
    
    NSString *openLink;
    NSString *normalImageURL;
    NSString *activeImageURL;
}

@property(nonatomic, assign)int buttonID;
@property(nonatomic, assign)int buttonStatus;
@property(nonatomic, assign)int buttonOpenType;
@property(nonatomic, retain)NSString *openLink;
@property(nonatomic, retain)NSString *normalImageURL;
@property(nonatomic, retain)NSString *activeImageURL;

-(void)reSetToNormalImage;

@end

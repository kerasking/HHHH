//
//  CheckViewController.h
//  webgame
//
//  Created by Zhaojian Dou on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginUtility.h"
#import "LoginConstants.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@interface CheckViewController : UIViewController<ASIHTTPRequestDelegate,UIAlertViewDelegate> {
    NSString* userId;
    NSString* userName;
}
@property (nonatomic,retain) NSString* game_id;
@property (nonatomic,retain) NSString* affcode;
@property (nonatomic,retain) NSString* login_id;
@property (nonatomic,retain) NSString* view_url;
@property (nonatomic,retain) NSString* btn_url;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,retain) NSString* userId;
@property (retain) NSMutableDictionary* connection_user_info;

+(CheckViewController*) shareInstance;

-(void)initialWithGameId:(NSString*)gameId withAffCode:(NSString*)affCode;
-(void)closeViewController;

@end

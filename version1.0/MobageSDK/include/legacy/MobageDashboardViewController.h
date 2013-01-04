//
//  MobageDashboardViewController.h
//  Sample
//
//  Created by nakanishi.tomoyuki on 11/03/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobageDashboardDelegate.h"
#import "MobageDashboardView.h"

@interface MobageDashboardViewController : UIViewController 
{
	NSString* gameId;
    NSString* userId;
        
    MobageDashboardView *dashBoardView;
    id<MobageDashboardDelegate> delegate;
}

@property (nonatomic,assign) id<MobageDashboardDelegate> delegate;
@property (nonatomic,retain) NSString* gameId;
@property (nonatomic,retain) NSString* userId;

+ (MobageDashboardViewController*) shareInstance;

- (void)initializeWithGameId:(NSString*)newGameId withUserId:(NSString*)newUserId;

- (BOOL)isDashBoardLaunched;

- (void)launchDashboardWithUrl:(NSString*)url;
- (void)launchDashboardWithPage:(NSString*)page;
- (void)dismissDashboard;

- (void)launchDashboardWithHomePage;
- (void)launchDashboardWithGamePage;
- (void)launchDashboardWithGameRankingPage;
- (void)launchDashboardWithMessagePage;
- (void)launchDashboardWithGroupPage:(NSString*)groupId;
- (void)launchDashboardWithUserProfile:(NSString *)userid;

- (void)launchImagePicker:(NSString*) url;
@end

